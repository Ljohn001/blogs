---
title: 'CKAD模拟题:28-Jobs'
abbrlink: 36fb4e14
date: 2024-03-09 07:38:06
tags:
  - kubernetes
  - ckad
categories:
  - ckad
---

## 题目要求

1. 用执行命令**'date; echo Hello from the Kubernetes cluster'**的镜像 busybox ，创建一个名为 **busybox-job** 的 Job 。
2. 修改此 Job ，确保在执行时间超过 **3000** 秒后，kubernetes 会自动终止该 Job。
3. 如果容器失败，则尝试重启容器，但最多尝试重启 **5** 次。
4. 检查此Job的日志

## 参考

[https://kubernetes.io/zh-cn/docs/concepts/workloads/controllers/job/](https://kubernetes.io/zh-cn/docs/concepts/workloads/controllers/job/)

```bash
# 参考命令
kubectl explain job.spec
# 配置示例
apiVersion: batch/v1
kind: Job
metadata:
  name: pi
spec:
  template:
    spec:
      containers:
      - name: pi
        image: perl:5.34.0
        command: ["perl",  "-Mbignum=bpi", "-wle", "print bpi(2000)"]
      restartPolicy: Never
  backoffLimit: 4
```

## 解答

```yaml
# cat 28-jobs.yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: **busybox-job**
spec:
  activeDeadlineSeconds: 3000  # 执行时间超过 **3000** 秒后，kubernetes 会自动终止该 Job。
  template:
    spec:
      containers:
      - name: **busybox-job**
        image: busybox
        command: ["**date;","echo Hello from the Kubernetes cluster**"]
      restartPolicy: OnFailure # 失败重启
  backoffLimit: 5 # 重启 **5** 次
# 应用
kubectl apply -f 28-jobs.yaml
# 测试验证
kubectl get job
NAME          COMPLETIONS   DURATION   AGE
busybox-job   0/1           6s         6s
```
