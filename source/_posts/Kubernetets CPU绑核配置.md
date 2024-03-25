---
title: Kubernetets CPU绑核配置
tags:
  - kubernetes
  - k8s
  - linux
categories:
  - kubernetes
abbrlink: 19c6e9f2
---
# CPU绑核配置

默认情况下，kubelet 使用 [CFS 配额](https://www.kernel.org/doc/html/latest/scheduler/sched-design-CFS.html) 来执行 Pod 的 CPU 约束。 当节点上运行了很多 CPU 密集的 Pod 时，工作负载可能会迁移到不同的 CPU 核， 这取决于调度时 Pod 是否被扼制，以及哪些 CPU 核是可用的。许多应用对这种迁移不敏感，因此无需任何干预即可正常工作。有些应用对CPU敏感，CPU敏感型应用有如下特点。

* 对CPU throttling 敏感
* 对上下文切换敏感
* 对处理器缓存未命中敏感
* 对跨socket内存访问敏感
* 期望运行在同一物理CPU的超线程

如果您的应用有以上其中一个特点，可以利用kubernetes中提供的绑核策略去给应用绑核，提升应用性能，减少应用的调度延迟。cpu manager会优先在一个Socket上分配资源，也会优先分配完整的物理核，避免一些干扰。

# **如何为Pod绑核**

想要让Pod能够绑核，有如下几点要求：

* 节点上开启静态绑核策略。
* Pod的定义里都要设置request和limits，request和limits要一致。
* 对于要绑核的容器，request值必须是整数。
* 如果有init container希望进行绑核的话，init container的request最好与业务容器设置的request一致（避免业务容器未继承init container的cpu分配结果，导致cpu manager多预留一部分cpu）。更多信息请参见[App Containers can&#39;t inherit Init Containers CPUs - CPU Manager Static Policy](https://github.com/kubernetes/kubernetes/issues/94220#issuecomment-868489201)。

在使用时您可以利用[调度策略（亲和与反亲和）](https://support.huaweicloud.com/usermanual-cce/cce_10_0232.html)将如上配置的Pod调度到开启静态绑核策略的节点上，这样就能够达到绑核的效果。

### **开启CPU管理策略**

[CPU 管理策略](https://kubernetes.io/zh/docs/tasks/administer-cluster/cpu-management-policies/)通过 kubelet 参数 --cpu-manager-policy 来指定。支持两种策略：

* 关闭（none）：默认策略，显式地启用现有的默认 CPU 亲和方案，不提供操作系统调度器默认行为之外的亲和性策略。
* 开启（static）：针对具有整数型 CPU requests 的 Guaranteed Pod ，它允许该类 Pod 中的容器访问节点上的独占 CPU 资源（绑核）。

```yaml
# 先驱逐节点，停止kubeket
systemctl stop kubelet
# 修改kubelet启动配置
--cpu-manager-policy="static" # 新版本已经废弃该用--config方式
# v1.19以后新版本在config.yml配置中新增
cpuManagerPolicy: static
# 另外，需要配置 kubeReserved预留否则会报错
kubeReserved:
  cpu: 2000m
# 删除配置
mv  /var/lib/kubelet/cpu_manager_state{,.bak}
# 重启kubelet
systemctl daemon-reload && systemctl restart kubelet
```

## ****Pod资源配置****

Pod的resources中cpu的request值需为整数，且request和limits要一致。

```yaml
# 创建一个pod
kubectl create -f -<<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nettools-deploy
spec:
  selector:
      matchLabels:
        name: nettools-deploy
  template:
    metadata:
      labels:
        name: nettools-deploy
    spec:
      nodeName: "10.4.83.28"
      containers:
      - name: nettools-deploy
        image: registry.XXXX.com/base/network-multitool:lastet
        imagePullPolicy: IfNotPresent
        name: nettools-deploy
        resources:
          requests:
            memory: "200Mi"
            cpu: "2"
          limits:
            memory: "200Mi"
            cpu: "2"
EOF
# 验证绑核效果,可以看到容器实例帮核已经到2,34核心
$ cat /var/lib/kubelet/cpu_manager_state
{"policyName":"static","defaultCpuSet":"0-1,3-33,35-63","entries":{"4378c1c9-7a86-48a0-8ad9-5a0d4ff4b3ac":{"nettools-deploy":"2,34"}},"checksum":239816225}
# 查找pod 对应的pid
$ docker ps -a | grep nettools-deploy-7b4df69496-8rzn4 | head -n 1  | awk '{print $1}'  | xargs -i docker inspect {} |grep Pid
            "Pid": 234293,
            "PidMode": "",
            "PidsLimit": null,

# 命令查看帮核效果，跟kubelet记录一致
$ taskset -c -p 234293
pid 234293's current affinity list: 2,34
```

# 参考

[](https://kubernetes.io/zh-cn/docs/tasks/administer-cluster/cpu-management-policies/)[https://kubernetes.io/zh-cn/docs/tasks/administer-cluster/cpu-management-policies/](https://kubernetes.io/zh-cn/docs/tasks/administer-cluster/cpu-management-policies/)

[](https://support.huaweicloud.com/usermanual-cce/cce_10_0351.html)[https://support.huaweicloud.com/usermanual-cce/cce_10_0351.html](https://support.huaweicloud.com/usermanual-cce/cce_10_0351.html)

[](https://imroc.cc/kubernetes/best-practices/performance-optimization/cpu.html)[https://imroc.cc/kubernetes/best-practices/performance-optimization/cpu.html](https://imroc.cc/kubernetes/best-practices/performance-optimization/cpu.html)

[](https://cloud.tencent.com/developer/article/1642977)[https://cloud.tencent.com/developer/article/1642977](https://cloud.tencent.com/developer/article/1642977)
