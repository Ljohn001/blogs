---
title: 'CKAD模拟题:10-RBAC 授权'
abbrlink: 53e4a736
date: 2024-03-09 07:28:15
tags:
  - kubernetes
  - ckad
categories:
  - ckad
---
## 题目要求

在名为 **honeybee-deployment** 的 Deployment 和 namespace **gorilla** 中的一个 Pod 正在记录错误

1. 查看日志以识别错误消息找出错误,包括 **User "system:serviceaccount:gorilla:default "can not list resource "serviceaccounts "[…] in the namespace "gorilla"**
2. 更新 Deployment **honeybee-deployment** 以解决 Pod 日志中的错误。您可以在 **/ckad/prompt-escargot/honeybee-deployment.yaml** 中找到 **honeybee-deployment** 的 清单文件

## 参考

[https://kubernetes.io/zh-cn/docs/reference/access-authn-authz/rbac/](https://kubernetes.io/zh-cn/docs/reference/access-authn-authz/rbac/)

## 解答

环境创建

```bash
# deployment yaml
apiVersion: v1
kind: Namespace
metadata:
  creationTimestamp: null
  name: gorilla
spec: {}
status: {}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: honeybee-deployment
  name: honeybee-deployment
  namespace: gorilla
spec:
  replicas: 1
  selector:
    matchLabels:
      app: honeybee-deployment
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: honeybee-deployment
    spec:
      containers:
      - image: nginx
        name: nginx
      serviceAccountName: default
      serviceAccountName: default
# serviceaccount role rolebingding
apiVersion: v1
kind: ServiceAccount
metadata:
  creationTimestamp: null
  name: gorilla-sa
  namespace: gorilla
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  creationTimestamp: null
  namespace: gorilla
  name: gorilla-role
rules:
- apiGroups:
  - apps
  resources:
  - deployments
  - pods
  - serviceaccounts
  verbs:
  - get
  - list
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  creationTimestamp: null
  name: gorilla-rolebinding
  namespace: gorilla
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: gorilla-role
subjects:
- kind: ServiceAccount
  name: gorilla-sa
  namespace: gorilla
```

```bash
# 查看 honeybee-deployment 对应的ServiceAccount 
kubectl -n gorilla describe deployments.apps honeybee-deployment 
# ServiceAccount 为default
Service Account:default
# 查看该名称空间的role,rolebinding,sa
kubectl -n gorilla describe role,rolebinding,sa
# 通过如上命令找到, gorilla-role 具有 get list 权限, 对应的sa为 gorilla-sa,所以修改sa为 gorilla-sa
# 通过如下命令来修改也可以
kubectl -n gorilla set serviceaccount deployments honeybee-deployment gorilla-sa
# 或者 ，直接编辑修改ServiceAccount 为 gorilla-sa
kubectl -n gorilla edit deployment honeybee-deployment 

# 测试验证
kubectl -n gorilla logs honeybee-deployment-d8b9685f9-bhh6s
```
