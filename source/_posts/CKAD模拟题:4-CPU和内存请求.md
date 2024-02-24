---
title: CKAD模拟题:4-CPU和内存请求
date: 2024-02-24T09:56:19+08:00
tags:
  - kubernetes
  - ckad
  - cncf
  - ckad
---

## 题目要求

在现有的 namespace **pod-resources**中创建一个名为**nginx-resource**s 的 Pod 。镜像为 **nginx:1.16** ,为其容器指定资源请求**40m**的 CPU 和**50Mi**的内存

## 参考

[https://kubernetes.io/zh-cn/docs/concepts/configuration/manage-resources-containers/](https://kubernetes.io/zh-cn/docs/concepts/configuration/manage-resources-containers/)

官方示例：

```bash
---
apiVersion: v1
kind: Pod
metadata:
  name: frontend
spec:
  containers:
  - name: app
    image: images.my-company.example/app:v4
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
```

## 解答

```bash
# 1.1 创建pod配置
kubectl run nginx-resources --image=nginx:1.16 --dry-run=client -o yaml > 4.pod-resources.yaml
cat 4.pod-resources.yaml

apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx-resources
  name: nginx-resources
spec:
  containers:
  - image: nginx:1.16
    name: nginx-resources
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}

# 1.2 根据题目要求修改request
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx-resources
  name: nginx-resources
spec:
  containers:
  - image: nginx:1.16
    name: nginx-resources
    resources:
      requests:
        memory: "50Mi"
        cpu: "40m"
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}
# 1.3 部署
kubectl apply -f 4.pod-resources.yaml

```
