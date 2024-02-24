---
title: 'CKAD模拟题:2-CronJob'
tags:
  - kubernetes
  - ckad
  - cncf
  - ckad题
abbrlink: d95d044a
date: 2024-02-24 01:54:38
---

## 题目要求

1. 在清单文件 /ckad/CKAD00016/periodic.yaml 中定义此 Pod
2. 在一个 **busybox:stable** 容器中运行命令 **date** 该命令必须每分钟运行一次，并且必须在 **10** 秒内完成运行，或者被 Kubernetes 终止运行。注意： CronJob 名称和容器名称都必须为 **hello**
3. 在上述清单文件中创建此资源，并验证此 Job 至少成功执行一次。

## 参考

[https://kubernetes.io/zh-cn/docs/tasks/job/automated-tasks-with-cron-jobs/](https://kubernetes.io/zh-cn/docs/tasks/job/automated-tasks-with-cron-jobs/)

[https://kubernetes.io/zh-cn/docs/concepts/workloads/controllers/job/](https://kubernetes.io/zh-cn/docs/concepts/workloads/controllers/job/)

## 解答

```bash
# 1.编辑文件
vim /ckad/CKAD00016/periodic.yaml
# 2.根据要求编辑文件内容
apiVersion: batch/v1
kind: CronJob
metadata:
  name: hello
spec:
  schedule: "* * * * *" # 2.1 每分钟执行一次
  jobTemplate:
    spec:
      template:
        spec:
          activeDeadlineSeconds: 10 # 2.1 必须在 10 秒内完成运行，或者被 Kubernetes 终止运行
          containers:
          - name: hello
            image: busybox:stable # 2.1 镜像名为：busybox:stable
            imagePullPolicy: IfNotPresent
            command: # 2.1 执行date命令
            - /bin/sh
            - -c
            - date
          restartPolicy: OnFailure
# 3.创建资源并验证job执行成功
kubectl apply -f /ckad/CKAD00016/periodic.yaml
# 查看cronjob
kubectl get cronjob hello
NAME    SCHEDULE    SUSPEND   ACTIVE   LAST SCHEDULE   AGE
hello   * * * * *   False     0        47s             3m
# 查看job
kubectl get job | grep hello
hello-1708415580       1/1           3s         2m35s
hello-1708415640       1/1           2s         94s
hello-1708415700       1/1           2s         34s
# 查看pod
kubectl get pod | grep hello
hello-1708415580-wgtc7   0/1     Completed   0          2m51s
hello-1708415640-vq5z7   0/1     Completed   0          110s
hello-1708415700-nmxkq   0/1     Completed   0          50s
# 查看执行结果
kubectl logs hello-1708415700-nmxkq
Tue Feb 20 07:55:04 UTC 2024
```
