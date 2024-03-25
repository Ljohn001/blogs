---
title: 'CKAD模拟题:1-CronJob'

abbrlink: e0d0388f
date: 2024-02-24 01:47:29
tags:
  - kubernetes
  - ckad
categories:
  - ckad
---
## 题目要求

1.创建一个名为 ppi 并执行一个运行以下单一容器的 Pod 的 CronJob

```bash
- name: pi
  image: perl:5
  command: ["perl", " Mbignum=bpi", " wle", "print bpi(2000)"]
```

CronJob配置 为：

* 每隔 5 分钟执行一次
* 保留 2 个已完成的 Job
* 保留 4 个失败的 Job
* 永不重启 Pod
* 在 8 秒后终止 Pod

2.为测试目的，从 CronJob ppi 中 手动创建并执行一个名为 ppi-test 的 Job 。

* job完成与否不重要

## 参考

[https://kubernetes.io/zh-cn/docs/tasks/job/automated-tasks-with-cron-jobs/](https://kubernetes.io/zh-cn/docs/tasks/job/automated-tasks-with-cron-jobs/)

[https://kubernetes.io/zh-cn/docs/concepts/workloads/controllers/job/](https://kubernetes.io/zh-cn/docs/concepts/workloads/controllers/job/)

cronjob定时与[Linux的定时](https://www.runoob.com/linux/linux-comm-crontab.html)任务语法一致

```bash
*    *    *    *    *
-    -    -    -    -
|    |    |    |    |
|    |    |    |    +----- 星期中星期几 (0 - 6) (星期天 为0)
|    |    |    +---------- 月份 (1 - 12) 
|    |    +--------------- 一个月中的第几天 (1 - 31)
|    +-------------------- 小时 (0 - 23)
+------------------------- 分钟 (0 - 59)
```

## 解答

```bash
# 1.编辑配置文件
vim cronjob-1.yaml

---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: ppi #修改为对应的
spec:
  schedule: "*/5 * * * *" # 1.1 每隔5分钟执行一次
  successfulJobsHistoryLimit: 2 # 1.2 保留2个已完成的Job
  failedJobsHistoryLimit: 4     # 1.3 保留4个失败的Job
  jobTemplate:
    spec:
      activeDeadlineSeconds: 8  # 1.4 pod存活时间,8秒
      template:
        spec:
          containers:
          - name: pi            # 名称
            image: perl:5       # 镜像
            imagePullPolicy: IfNotPresent
            command: ["perl", "Mbignum=bpi", " wle", "print bpi(2000)"] 
          restartPolicy: Never  # 1.5 重启策略,永不重启

# 应用配置文件
kubectl apply -f cronjob-1.yaml
# 查看配置
kubectl get cronjobs
NAME   SCHEDULE      SUSPEND   ACTIVE   LAST SCHEDULE   AGE
ppi    */5 * * * *   False     0        30s             44s
# 2.手动触发cronjob
kubectl create job ppi-test --from=cronjob/ppi
kubectl get jobs
NAME                   COMPLETIONS   DURATION   AGE
ppi-test               0/1           56s        56s
# 这里可以看到job执行了。
```
