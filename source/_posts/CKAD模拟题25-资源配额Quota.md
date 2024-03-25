---
title: 'CKAD模拟题:25-资源配额Quota'
abbrlink: 89e8fc71
date: 2024-03-09 07:37:13
tags:
  - kubernetes
  - ckad
categories:
  - ckad
---

## 题目要求

在 **qutt** 命名空间，创建一个名为 **myquota** 的 Quota，该资源 Quota 具有 **1** 个CPU， **1G** 内存和 **2个** pod的硬限制。

## 参考

[https://kubernetes.io/zh-cn/docs/concepts/policy/resource-quotas/#viewing-and-setting-quotas](https://kubernetes.io/zh-cn/docs/concepts/policy/resource-quotas/#viewing-and-setting-quotas)

## 解答

```yaml
# 创建一个ns
kubectl create ns qutt
# 创建一个容器pod
kubectl create quota myquota --hard=count/pods=2 --namespace=qutt --dry-run=client -o yaml > 25-resource-quota.yaml
# 修改配置
vim 25-resource-quota.yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  creationTimestamp: null
  name: myquota
  namespace: qutt
spec:
  hard:
    limits.cpu: "1"
    limits.memory: 1Gi
    count/pods: "2"
status: {}
# 应用配置
kubectl apply -f 25-resource-quota.yaml
# 检查配置
kubectl -n qutt  describe quota myquota
Name:          myquota
Namespace:     qutt
Resource       Used  Hard
--------       ----  ----
count/pods     0     2
limits.cpu     0     1
limits.memory  0     1Gi
```
