---
title: 'CKAD模拟题:19-Ingress排错 - 1'
tags:
  - kubernetes
  - ckad
categories:
  - ckad
abbrlink: '841334'
date: 2024-03-09 07:34:26
---
## 题目要求

在namespace **ingress-ckad** 下，有 deployment service ingress 三个资源已经部署好了, 但是他们的配置有问题，导致的ingress 网络不通。

3个资源的配置清单在目录 **/ckad/CKAD202206** 中 ，请将其修改为正确的，并重新创建。

## 参考

[https://kubernetes.io/zh-cn/docs/concepts/services-networking/ingress/](https://kubernetes.io/zh-cn/docs/concepts/services-networking/ingress/)

## 解答

```bash
# 查看配置，进行修改
vim /ckad/CKAD202206/ingress.yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-dm
  namespace: ingress-ckad
spec:
  replicas: 2
  selector:
    matchLabels:
      name: nginx-ing
  template:
    metadata:
      labels:
        name: nginx-ing #标签
    spec:
      containers:
      - name: nginx
        image: vicuu/nginx:hello81
        imagePullPolicy: IfNotPresent
        ports:
          - containerPort: 81 #容器端口
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-ing-svc #服务名
  namespace: ingress-ckad
spec:
  ports:
  - port: 80 #和ingress的端口一致
    targetPort: 81 #这个端口需要和deployment的containerPort值一致
    protocol: TCP
  selector:
    name: nginx-ing #修改标签 和deployment的一致

---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress-test
  namespace: ingress-ckad
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx-example123
  rules:
  - http:
      paths:
      - path: /hello
        pathType: Prefix
        backend:
          service:
            name: nginx-ing-svc #需要和service的服务名一致
            port:
              number: 80 # 需要和service的port的值一致

# 应用配置，测试验证
kubectl apply -f /ckad/CKAD202206/ingress.yaml
curl 10.106.76.153
curl 10.102.130.182/hello
```
