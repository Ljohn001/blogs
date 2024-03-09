---
title: 'CKAD模拟题:21-Service , Configmap , Sidecar'
abbrlink: 5cf371a8
date: 2024-03-09 07:35:53
tags:
  - kubernetes
  - ckad
categories:
  - ckad
---
## 题目要求

1. 更新在 namespace **default** 中的 Service **nginxsvc** 来暴露端口  **9090** 。
2. 在 namespace **default** 中创建一个名为 **haproxy-config** 并存储着的**/ckad/ambassador/haproxy.cfg** 的内容的 ConfigMap。
3. 更新在 namespace **default** 中名为 **poller** 的 Pod：
   * 首先，添加一个使用 **haproxy:lts** 镜像、暴露端口 **80** 并名为 **ambassador-container** 的 ambassador 容器（sidecar模式）。
   * 最后，ConfigMap **haproxy-config** 要挂载到 ambassador 容器 **ambassador-container** 的**/usr/local/etc/haproxy/**目录。

## 参考

[https://kubernetes.io/zh-cn/docs/concepts/configuration/configmap/](https://kubernetes.io/zh-cn/docs/concepts/configuration/configmap/)

[https://kubernetes.io/docs/reference/kubectl/generated/kubectl_create/kubectl_create_configmap/](https://kubernetes.io/docs/reference/kubectl/generated/kubectl_create/kubectl_create_configmap/)

```bash
# 挂在示例
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
  - name: mypod
    image: redis
    volumeMounts:
    - name: foo
      mountPath: "/etc/foo"
      readOnly: true
  volumes:
  - name: foo
    configMap:
      name: myconfigmap
```

## 解答

```bash
# 1. 修改SVC端口
kubectl -n default get svc
kubectl -n default edit svc nginxsvc
apiVersion: v1
kind: Service
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"v1","kind":"Service","metadata":{"annotations":{},"name":"nginxsvc","namespace":"default"},"spec":{"ports":[{"port":80,"protocol":"TCP","targetPort":80}],"selector":{"app":"nginxsvc"}}}
  creationTimestamp: "2023-05-24T13:45:01Z"
  name: nginxsvc
  namespace: default
  resourceVersion: "17051"
  uid: cd4c38bd-e282-414f-a4cb-9fe3a5ccd0c5
spec:
  clusterIP: 10.111.178.212
  clusterIPs:
  - 10.111.178.212
  internalTrafficPolicy: Cluster
  ipFamilies:
  - IPv4
  ipFamilyPolicy: SingleStack
  ports:
  - port: 9090 #修改这里为题目要求
    protocol: TCP
    targetPort: 80
  selector:
    app: nginxsvc
  sessionAffinity: None
  type: ClusterIP
status:
  loadBalancer: {}
# 测试验证
kubectl -n default get svc nginxsvc -owide

# 2. 使用文件创建CONFIGMAP
kubectl create configmap **haproxy-config** --from-file=**/ckad/ambassador/haproxy.cfg

# 3.更新POD**
kubectl -n default get pod poller -oyaml > poller.yaml
cp poller.yaml poller_bak.yaml
# 删除当前pod
kubectl delete -f poller.yaml
# 编辑配置
vim poller.yaml
# 增加如下配置
...
  - name: **ambassador-container**
    image: **haproxy:lts**
    volumeMounts:
    - name: foo
      mountPath: "**/usr/local/etc/haproxy/**"
      readOnly: true
  volumes:
  - name: foo
    configMap:
      name: **haproxy-config
...

# 应用配置，并创建pod
kubectl apply -f poller.yaml
# 测试验证
curl 10.111.178.212:9090**
```
