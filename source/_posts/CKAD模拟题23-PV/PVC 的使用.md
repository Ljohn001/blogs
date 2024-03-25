---
title: CKAD模拟题:23-PV/PVC的使用
abbrlink: 81f11c7
date: 2024-03-09 07:36:36
tags:
  - kubernetes
  - ckad
categories:
  - ckad
---
## 题目要求

1. 在 node02 节点上创建一个文件 **/opt/KDSP00101/data/index.html** ,内容为 **WEPKEY=7789**
2. 使用 hostPath 创建一个名为 **task-pv-volume** 的 **PersistentVolume** ，并分配 **2Gi** 容量，指定该卷位于集群节点上的 **/opt/KDSP00101/data** ，访问模式 **ReadWriteOnce** 。它应该为 **PersistentVolume** 定义 **StorageClass** 名称为 **keys** ，它将被用来绑定 **PersistentVolumeClaim** 请求到这个  **PersistenetVolume** 。
3. 创建一个名为 **task-pv-claim** 的  **PersistentVolumeClaim** ，请求容量 **200Mi** ，并指定访问模式 **ReadWriteOnce**
4. 创建一个 pod，使用 PersistentVolmeClaim 作为一个卷，带有一个标签 **app:my-storage-app** ，将卷挂载到 pod 内的 **/usr/share/nginx/html**

## 参考

[https://kubernetes.io/zh-cn/docs/tasks/configure-pod-container/configure-persistent-volume-storage/](https://kubernetes.io/zh-cn/docs/tasks/configure-pod-container/configure-persistent-volume-storage/)

```yaml
# 参考官方配置
apiVersion: v1
kind: PersistentVolume
metadata:
  name: task-pv-volume
  labels:
    type: local
spec:
  storageClassName: manual
  capacity:
    storage: 2Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/**data**"

```

## 解答

```yaml
# 1.创建一个文件
sudo mkdir -p /opt/KDSP00101/data/
echo "**WEPKEY=7789**" > **/opt/KDSP00101/data/index.html** 
# 2.创建一个容量为2Gi的pv
cat task-pv-volume.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: task-pv-volume
  labels:
    type: local
spec:
  storageClassName: **keys**
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "**/opt/KDSP00101/data**"
# 应用
kubectl apply -f task-pv-volume.yaml
# 3.创建一个pvc 
cat task-pvc-volume.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: task-pv-claim
spec:
  storageClassName: keys
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: **200Mi**
# 应用
kubectl apply -f task-pvc-volume.yaml      ****
# 应用配置，查看pvc,发现已经绑定到了pv
kubectl get pvc
NAME            STATUS   VOLUME           CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
task-pv-claim   Bound    task-pv-volume   10Gi       RWO            keys           <unset>                 7s
# 4.根据需求创建pod
cat test-pvc-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: task-pv-pod
  labels:
    app: **my-storage-app**
spec:
  volumes:
    - name: task-pv-storage
      persistentVolumeClaim:
        claimName: task-pv-claim
  containers:
    - name: task-pv-container
      image: nginx
      ports:
        - containerPort: 80
          name: "http-server"
      volumeMounts:
        - mountPath: "/usr/share/nginx/html"
          name: task-pv-storage
# 应用pod配置
kubectl appp -f test-pvc-pod.yaml
```
