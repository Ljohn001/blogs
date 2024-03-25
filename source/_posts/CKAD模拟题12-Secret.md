---
title: 'CKAD模拟题:12-Secret'
abbrlink: ceabd3ac
date: 2024-03-09 07:29:58
tags:
  - kubernetes
  - ckad
categories:
  - ckad
---
## 题目要求

1. 在 namespace **default** 中创建一个名为 **another-secret** 并包含以下单个键值对的 Secret **key1:value2**
2. 在 namespace **default** 中创建一个名为 **nginx-secret** 的 Pod 。 用 **nginx:1.16** 的镜像来指定一个容器 。添加一个名为 **COOL_VARIABLE** 的环境变量来使用 secret 键 **key1** 的值。

## 参考

[https://kubernetes.io/zh-cn/docs/concepts/configuration/secret/](https://kubernetes.io/zh-cn/docs/concepts/configuration/secret/)

[https://kubernetes.io/zh-cn/docs/tasks/inject-data-application/distribute-credentials-secure/#configure-all-key-value-pairs-in-a-secret-as-container-env-var](https://kubernetes.io/zh-cn/docs/tasks/inject-data-application/distribute-credentials-secure/#configure-all-key-value-pairs-in-a-secret-as-container-env-var)

## 解答

```bash
# 创建secret
kubectl create secret generic another-secret --from-literal key1=value2 
# 创建pod,并按要求修改配置
kubectl run nginx-secret --image=nginx:1.16 --dry-run=client -o yaml  > nginx-secret.yaml

vim nginx-secret.yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx-secret
  name: nginx-secret
spec:
  containers:
  - image: nginx:1.16 # 题目要求
    name: nginx-secret
    env: # 题目要求
    - name: COOL_VARIABLE # 题目要求
      valueFrom: # 题目要求
        secretKeyRef: # 题目要求
          name: another-secret # 题目要求
          key: key1 # 题目要求
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}

# 应用配置
kubectl apply -f nginx-secret.yaml
# 测试验证
kubectl exec -it nginx-secret -- env | grep COOL

```
