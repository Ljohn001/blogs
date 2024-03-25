---
title: 'CKAD模拟题:20-Ingress-2'
abbrlink: 5896ef20
date: 2024-03-09 07:35:27
tags:
  - kubernetes
  - ckad
categories:
  - ckad


---
## 题目要求

在namespace **ingress-kk**下有一个 ingress ，但是它貌似不能被正常访问请排除出原因，并修复。

## 参考

[https://kubernetes.io/zh-cn/docs/concepts/services-networking/service/](https://kubernetes.io/zh-cn/docs/concepts/services-networking/service/)

[https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#expose](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#expose)

```bash
# 参考官方示例
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  selector:
    app.kubernetes.io/name: MyApp
  ports:
    - protocol: TCP
      port: 80
      targetPort: 9376
# 或者
kubectl expose -h 
```

## 解答

```bash
# 查看 **ingress-kk namespace下的所有资源**
kubectl -n ingress-kk get all
# 发现没有service , 查看ingress 信息
kubectl -n ingress-kk

# 通过 deployment中找 标签,targetport
kubectl -n ingress-kk get deployments.apps nginxdep -oyaml 
···
name: nginx-lab
containerPort: 80
···

# ingress中找svc所需的svc名和port
kubectl -n ingress-kk get ingress -o yaml 
...
service: 
  name: nginxsvc-kk
  port: 
    number: 80
...

# 通过上面获取到的信息，使用命令创建
# 参考： $ kubectl expose (-f FILENAME | TYPE NAME) [--port=port] [--protocol=TCP|UDP|SCTP] [--target-port=number-or-name] [--name=name] [--external-ip=external-ip-of-service] [--type=type]
kubectl expose deployment nginxdep --port=80 --protocol=TCP --target-port=80 --name=nginxsvc-kk --selector name=nginx-lab

# 测试验证
...
```
