---
title: 'CKAD模拟题:17-更新 Deployment 并暴露 Service'
abbrlink: b7ce7f10
date: 2024-03-09 07:33:19
tags:
  - kubernetes
  - ckad
categories:
  - ckad
---
## 题目要求

1. 首先 更新在 namespace **ckad00017** 中的 Deployment **ckad00017-deployment** :
   * 以使其运行 **5** 个 Pod 的副本
   * 将以下标签添加到 Pod tier: dmz
2. 然后 在 namespace **ckad00017** 中创建一个名为 **rover** 的 **NodePort** Service 以在 TCP 端口 **81** 上公开 Deployment **ckad00017-deployment**

## 参考

[https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#expose](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#expose)

## 解答

```bash
# 1.1 扩容副本数到5
kubectl -n **ckad00017 scale deployment ckad00017-deployment --replicas=5
# 1.2 添加标签
kubectl -n ckad00017 get deployments.apps -oyaml > 17.yaml
kubectl delete -f 17.yaml
vim 17.yaml
...
spec:
	selector:
	  matchLabels
	    app:ckad00017-deployment
	    tier:dmz  # 题目需求
template:
	metadata:
		labels:
		  app:ckad00017-deployment
		  tier:dmz # 题目需求

# 2.expose 暴露端口, port为service的端口, target-port为容器端口, 默认为80,以检查为准
kubectl -n ckad00017 expose deployment ckad00017-deployment --name rover --protocol TCP --port 81 --target-port 81 --type NodePort 
# 测试验证
kubectl -n ckad00017 get svc**

```
