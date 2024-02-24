---
title: CKAD模拟题:3-Dockerfile
date: 2024-02-24T09:55:44+08:00
tags:
  - kubernetes
  - ckad
  - cncf
  - ckad
---

## 题目要求

一个Dockerfile 已经存在于 **/ckad/DF/Dockerfile**

1. 使用已存在的 Dockerfile ，构建一个名为 **centos**和标签为 **8.2** 的容器镜像。您可以安装和使用您选择的工具。
2. 使用您选择的工具，以 OCI 格式导出构建的容器镜像，并将其存储在 **/ckad/DF/centos-8.2.tar**

## 参考

参考docker 构建

[https://docs.docker.com/language/java/build-images/](https://docs.docker.com/language/java/build-images/)

## 解答

```bash

#1.查看dockerfile文件，根据要求构建镜像
/ckad/DF/Dockerfile
# 1.1修改dockerfile文件
FROM centos:8
LABEL maintainer="test dockerfile"
LABEL test=dockerfile
USER root
RUN useradd shadow
RUN mkdir /opt/shadow
# 1.2构建镜像
cd /ckad/DF/
sudo docker build -t centos:8.2 .
sudo docker images
# 2. 导出镜像到文件：/ckad/DF/centos-8.2.tar
sudo docker save centos:8.2 > /ckad/DF/centos-8.2.tar
```
