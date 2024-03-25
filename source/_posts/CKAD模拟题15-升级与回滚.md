---
title: 'CKAD模拟题:15-升级与回滚'
abbrlink: b18304f5
date: 2024-03-09 07:32:37
tags:
  - kubernetes
  - ckad
categories:
  - ckad
---
## 题目要求

1. 更新 namespace **ckad00015** 中的 Deployment **webapp** 的比例缩放配置 将 **maxSurge** 设置为 **10%** ，将 **maxUnavailable** 设置为 **4**
2. 更新 Deployment **webapp** 以让容器镜像 **lfccncf/nginx** 使用版本标签 **1.13.7**
3. 将 Deployment **webapp** 回滚至 **前一版本**

## 参考

[https://kubernetes.io/zh-cn/docs/concepts/workloads/controllers/deployment/](https://kubernetes.io/zh-cn/docs/concepts/workloads/controllers/deployment/)

## 解答

环境准备

```bash
cat ~/ckad/15-deployment-rollout
apiVersion: v1
kind: Namespace
metadata:
  creationTimestamp: null
  name: ckad00015
spec: {}
status: {}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: webapp
  name: webapp
  namespace: ckad00015
spec:
  replicas: 1
  selector:
    matchLabels:
      app: webapp
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: webapp
    spec:
      containers:
      - image: lfccncf/nginx:1.12.2
        name: nginx
        resources: {}
status: {}
```

```bash
# 1.修改deployment 滚动升级策略
kubectl -n ckad00015 edit deployments.apps webapp
			rollingUpdate:
			  maxSurge: 10%
			  maxUnavailable: 4
# 2.修改image版本
kubectl -n ckad00015 set image deployment webapp nginx=lfccncf/nginx:1.13.7
# 3.回滚上一个版本
kubectl -n ckad00015 rollout undo deployment webapp

# 测试验证
kubectl -n ckad00015 get deployments.apps webapp -oyaml | grep image
```
