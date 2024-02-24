---
title: 'CKAD模拟题:5-CPU和内存限制'
tags:
  - kubernetes
  - ckad
  - cncf
  - ckad
categories:
  - ckad
abbrlink: fe30d26b
date: 2024-02-24 01:56:19
---
## 题目要求

namespace **haddock** 中名为 **nosql** 的 Deployment 的 Pod 因其容器已用完资源而无法启动。

请更新 **haddock** Deployment ，使 Pod

* 为其容器请求 **15Mi** 的内存
* 将内存限制为 **haddock** namespace 设置的**最大内存容量**的 **一半** 。您可以在 **/ckad/chief-cardinal/nosql.yaml** 找到 **nosql** Deployment 的配置清单。

## 参考

[https://kubernetes.io/zh-cn/docs/concepts/configuration/manage-resources-containers/](https://kubernetes.io/zh-cn/docs/concepts/configuration/manage-resources-containers/)

官方的示例

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
  - name: log-aggregator
    image: images.my-company.example/log-aggregator:v6
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
```

## 解答

查看namespace最大资源请求

```bash
kubectl describe ns haddock
#或者
kubectl -n haddock describe limitranges

# 示例
# 题目资源创建
---
apiVersion: v1
kind: Namespace
metadata:
  creationTimestamp: null
  name: haddock
spec: {}
status: {}
---
apiVersion: v1
kind: LimitRange
metadata:
  name: example-limitrange
  namespace: haddock
spec:
  limits:
  - defaultRequest:
      memory: 8Mi
    default:
      memory: 16Mi
    max:
      memory: 40Mi
    type: Container

# 查看ns的limitranges
kubectl describe ns haddock
Name:         haddock
Labels:       kubernetes.io/metadata.name=haddock
Annotations:  <none>
Status:       Active

No resource quota.

Resource Limits
 Type       Resource  Min  Max   Default Request  Default Limit  Max Limit/Request Ratio
 ----       --------  ---  ---   ---------------  -------------  -----------------------
 Container  memory    -    40Mi  8Mi              16Mi           -
kubectl -n haddock describe limitranges
Name:       example-limitrange
Namespace:  haddock
Type        Resource  Min  Max   Default Request  Default Limit  Max Limit/Request Ratio
----        --------  ---  ---   ---------------  -------------  -----------------------
Container   memory    -    40Mi  8Mi              16Mi           -
```

修改deployment配置

```bash
# 直接命令修改
kubectl -n haddock edit deployments.apps nosql
# 添加
         resources:
           limits:
             memory: 20Mi
           requests:
             memory: 15Mi
# 或者修改配置文件应用
vim /ckad/chief-cardinal/nosql.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nosql
  namespace: haddock
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nosql
  template:
    metadata:
      labels:
        app: nosql
    spec:
      containers:
      - image: nginx:1.16
        name: nginx
        # 添加下面的资源请求
        resources:
          requests:
            memory: "15Mi"
          limits:
            memory: "20Mi"

# 应用配置
kubectl apply -f /ckad/chief-cardinal/nosql.yaml

# 验证查看
kubectl -n haddock describe deployments.apps nosql

Name:                   nosql
Namespace:              haddock
CreationTimestamp:      Fri, 23 Feb 2024 06:07:59 +0000
Labels:                 <none>
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=nosql
Replicas:               1 desired | 1 updated | 1 total | 0 available | 1 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=nosql
  Containers:
   nginx:
    Image:      nginx:1.16
    Port:       <none>
    Host Port:  <none>
    Limits:            # 被修改字段
      memory:  20Mi    # 被修改字段
    Requests:          # 被修改字段
      memory:     15Mi # 被修改字段
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
```
