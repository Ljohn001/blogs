---
title: 'CKAD模拟题:24-sidecar 边车容器'
abbrlink: 8ad8a03
date: 2024-03-09 07:36:49
tags:
  - kubernetes
  - ckad
categories:
  - ckad
---
## 题目要求

* 在 **default** 命名空间创建一个 deployment 名为 **deploymenb-web**
* 包含一个主容器 **lfccncf/busybox:1** ，名称 **logger-123**
* 包含一个边车容器 **lfccncf/fluentd:v0.12** ，名称 **adaptor-dev**
* 在两个容器上挂载一个共享卷 **/ckad/log** ,当 pod  **删除** ，这个卷 **不会持久** 。
* 在 **logger-123** 容器运行以下命令：

  ```yaml
  while true; do
  echo "i luv cncf" >> /ckad/log/input.log; sleep 10;
  done
  ```

  结果会文本输出到 **/ckad/log/input.log** ，格式示例如下：

  i luv cncf

  i luv cncf

  i luv cncf
* **adaptor-dev** 容器读取 **/ckad/log/input.log** ，并将数据输出到 /ckad/log/output 格式为 Fluentd JSON

  > 请注意 ：完成此任务不需要了解 Fluentd ， 完成此任务所需要的知识 .从/ckad/KDMC00102/fluentd-configmap.yaml 提供规范文件中创建 configmap ，并将该 configmap 挂载到边车容器 adapter-dev 中的 /fluentd/etc
  >

## 参考

[https://kubernetes.io/zh-cn/docs/concepts/cluster-administration/logging/](https://kubernetes.io/zh-cn/docs/concepts/cluster-administration/logging/)

## 解答
