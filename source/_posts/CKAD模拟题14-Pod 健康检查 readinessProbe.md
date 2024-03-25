---
title: 'CKAD模拟题:14-Pod 健康检查 readinessProbe'
abbrlink: '90023889'
date: 2024-03-09 07:32:06
tags:
  - kubernetes
  - ckad
categories:
  - ckad
---
## 题目要求

修改现有的 deployment **probe-http** 增加 **readinessProbe** 探测 器，规格如下：

```
使用 httpGet 进行探测
探测路径为 /healthz/return200
探测端口为 80
在执行第一次探测前应该等待 15 秒
执行探测的时间间隔为 20 秒
```

## 解答

[https://kubernetes.io/zh-cn/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/](https://kubernetes.io/zh-cn/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)

```bash
# 参考如下配置
apiVersion: v1
kind: Pod
metadata:
  name: goproxy
  labels:
    app: goproxy
spec:
  containers:
  - name: goproxy
    image: registry.k8s.io/goproxy:0.1
    ports:
    - containerPort: 8080
    readinessProbe:
      tcpSocket:
        port: 8080
      initialDelaySeconds: 15
      periodSeconds: 10
    livenessProbe:
      tcpSocket:
        port: 8080
      initialDelaySeconds: 15
      periodSeconds: 20

```

## 解答

```bash
# 根据题目要求修改配置
kubectl edit deployment probe-http
    readinessProbe:
      httpGet:
        path: /healthz/return200
        port: 80
      initialDelaySeconds: 15
      periodSeconds: 20
```
