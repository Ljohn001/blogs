---
title: 'CKAD模拟题:27-Secret 秘钥'
abbrlink: 3f10f995
date: 2024-03-09 07:37:51
tags:
  - kubernetes
  - ckad
categories:
  - ckad
---

## 题目要求

在 **test** 命名空间，创建一个名为 **mysecret** 的密钥，其值 **username** 为 **devuser** 和 **password为A!B*d$zDsb=** 在 **test** 命名空间，创建一个 pod，镜像使用 **nginx:1.16** ，名字为 **mypod** ，将秘密 **mysecret** 挂载到路径 **/etc/foo** 上的卷中

## 参考

[https://kubernetes.io/zh-cn/docs/tasks/configmap-secret/managing-secret-using-kubectl/](https://kubernetes.io/zh-cn/docs/tasks/configmap-secret/managing-secret-using-kubectl/)

[https://kubernetes.io/zh-cn/docs/concepts/configuration/secret/#using-secrets-as-files-from-a-pod](https://kubernetes.io/zh-cn/docs/concepts/configuration/secret/#using-secrets-as-files-from-a-pod)

## 解答

```yaml
# 创建一个namespace
kubectl create ns **test
# 创建秘钥配置
echo -n 'devuser' > ./username.txt
echo -n 'A!B*d$zDsb=' > ./password.txt
# 创建秘钥
kubectl -n test create secret generic db-user-pass \\
    --from-file=username=./username.txt \\
    --from-file=password=./password.txt
# 创建容器挂在该secret
cat 27.secret-pod-test.yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
  - name: mypod
    image: nginx:1.16
    volumeMounts:
    - name: foo
      mountPath: "/etc/foo"
      readOnly: true
  volumes:
  - name: foo
    secret:
      secretName: mysecret
      optional: true
# 应用配置,注意上面我没加namespace，下面命令加也是一样的，别忘记就好
kubectl -n test apply -f 27.secret-pod-test.yaml**
```
