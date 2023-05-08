---
title: kubelet状态更新和自驱逐参数优化
tags:
  - kubernetes
  - k8s
categories:
  - kubernetes
abbrlink: 7f9c3178
---
# 环境信息

* kubelet： v1.19.10
* os：centos7.9
* deploy：[kubeasz](https://github.com/easzlab/kubeasz)

# 概览

当 Kubernetes 中 Node 节点出现状态异常的情况下，节点上的 Pod 会被重新调度到其他节点上去，但是有的时候我们会发现节点 Down 掉以后，Pod 并不会立即触发重新调度，这实际上就是和 Kubelet 的状态更新机制密切相关的，Kubernetes 提供了一些参数配置来触发重新调度的时间，为了简单起见，将跳过 HA 的部分，仅描述 Kubelet<->Controller Manager 通信流程。

默认情况下，正常行为：

* kubelet 自身会定期更新状态到 apiserver，通过参数 --node-status-update-frequency 指定上报频率，默认是 10s 上报一次。
* Kubernetes controller manager 每隔 --node-monitor-period 检查 Kubelet 的状态。默认值为 5 秒。
* 如果状态在 --node-monitor-grace-period 时间内更新，Kubernetes controller manager 认为 Kubelet 处于健康状态。默认值为 40 秒。

> Kubernetes controller manager 和 kubelet 是异步工作。这意味着延迟可能包括任何网络延迟、API Server 延迟、etcd 延迟、由控制平面节点上的负载引起的延迟等。所以如果 --node-status-update-frequency 设置为 5s 实际上它可能会在 6-7 秒甚至更长的时间出现在 etcd 中，因为 etcd 无法将数据提交到仲裁节点。

## 节点故障时

Kubelet将尝试进行 `nodeStatusUpdateRetry` POST。目前在kubelet.go中，`nodeStatusUpdateRetry`经常设置为5。

Kubelet将尝试更新 tryUpdateNodeStatus函数中的状态。Kubelet使用 `http.Client() Golang`方法，但没有指定的超时时间。因此，在建立TCP连接时，当API服务器过载时可能会出现一些故障。

因此，将会有 `nodeStatusUpdateRetry*--node-status-update-furn`尝试设置节点的状态。

同时，Kubernetes控制器管理器将尝试每隔一段时间-node-monitor-period，检查节点状态更新nodeStatusUpdateRetry重试次数  。在节点监视器宽限期-node-monitor-grace-period之后，它将认为节点运行不正常。然后，将根据您单独设置的基于污染的逐出计时器或API服务器的全局计时器重新调度Pod：`--default-not-ready-toleration-seconds & --default-unreachable-toleration-seconds`

kube-proxy在API上有一个监视器。Pod被逐出后，kube-proxy会注意到并更新节点的iptable。它将从服务中删除端点，因此故障节点中的POD将不再可访问。

# 基于不同场景配置

## 默认参数

| 组件                    | 参数                                                        | 说明                                                                                                                    | 默认值 |
| ----------------------- | ----------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------- | ------ |
| kubelet                 | –node-status-update-frequency or nodeStatusUpdateFrequency | node状态更新频率                                                                                                        | 10s    |
| kube-controller-manager | -node-monitor-period                                        | 在kube-controller中同步Node状态的时间                                                                                   | 5s     |
| kube-controller-manager | –node-monitor-grace-period                                 | 允许运行节点无响应的时间。（必须是kubelet的nodeStatusUpdateFrequency的N倍，其中N表示允许kubelet发布节点状态的重试次数） | 40s    |
| kube-controller-manager | –pod-eviction-timeout                                      | 删除失败节点上的pod的宽限期。                                                                                           | 5m0s   |
| kube-apiserver          | --default-not-ready-toleration-seconds                      | 指示notReady:NoExecute的容忍度的容忍度时间（秒）                                                                        | 300    |
| kube-apiserver          | --default-unreachable-toleration-seconds                    | 指示对不可访问的容忍度的容忍时间（秒）                                                                                  | 300    |

## 快速更新和快速反应

```bash
# 修改 kube-controller-manager启动参数或者配置文件新增如下配置
--node-monitor-period: 2s (default 5s)
--node-monitor-grace-period: 20s (default 40s)
--pod-eviction-timeout: 30s (default 5m0s)
# 修改 kubelet配置参数
--node-status-update-frequency: 4s （default 10s）
或
(nodeStatusUpdateFrequency: 4s default 10s)
# 修改 kube-apiserver配置参数
--default-unreachable-toleration-seconds=60 (default 300) #指示对不可访问的容忍度的容忍度秒数：NoExecute，默认情况下添加到尚未具有这种容忍度的每个pod
--default-not-ready-toleration-seconds=60 (default 300) #指示notReady:NoExecute的容忍度的容忍度秒数，默认情况下，该值会添加到尚未具有此类容忍度的每个pod中。

```

> 在这种情况下，Pod 将在 50s 被驱逐，因为该节点在 20s 后被视为Down掉了，--pod-eviction-timeout 在 30s 之后发生，Kubelet将尝试每4秒更新一次状态。因此，在Kubernetes控制器管理器考虑节点的不健康状态之前，它将是 (20s / 4s * 5) = 25 次尝试，但是，这种情况会给 etcd 产生很大的开销，因为每个节点都会尝试每 2s 更新一次状态。
>
> 如果环境有1000个节点，那么每分钟将有(60s / 4s * 1000) = 15000次节点更新操作，这可能需要大型 etcd 容器甚至是 etcd 的专用节点。

## 中等更新和平均反应

```bash
# 修改 kube-controller-manager 启动参数或者配置文件新增如下配置
--node-monitor-period: 5s (default 5s)
--node-monitor-grace-period: 1m0s (default 40s)
--pod-eviction-timeout: 1m0s (default 5m0s)
# 修改 kubelet配置参数
--node-status-update-frequency: 10s （default 10s）
或
(nodeStatusUpdateFrequency: 10s (default 10s)
# 修改 kube-apiserver配置参数
--default-unreachable-toleration-seconds=60 (default 300) #指示对不可访问的容忍度的容忍度秒数：NoExecute，默认情况下添加到尚未具有这种容忍度的每个pod
--default-not-ready-toleration-seconds=60 (default 300) #指示notReady:NoExecute的容忍度的容忍度秒数，默认情况下，该值会添加到尚未具有此类容忍度的每个pod中。
```

> 这种场景下会，Kubelet将尝试每10秒更新一次状态。因此，在Kubernetes控制器管理器检查节点的不健康状态之前，它将是 (1m / 10s *5) = 30 次尝试，节点异常后Pod将在 3m以内被驱逐。目前我们生产就采用该配置。

## 低更新和慢反应

```bash
# 修改 kube-controller-manager 启动参数或者配置文件新增如下配置
--node-monitor-period: 5s (default 5s)
--node-monitor-grace-period: 5m0s (default 40s)
--pod-eviction-timeout: 1m0s (default 5m0s)
# 修改 kubelet配置参数
--node-status-update-frequency: 60s （default 10s）
或
(nodeStatusUpdateFrequency: 60s (default 10s)
# 修改 kube-apiserver配置参数
--default-unreachable-toleration-seconds=60 (default 300) #指示对不可访问的容忍度的容忍度秒数：NoExecute，默认情况下添加到尚未具有这种容忍度的每个pod
--default-not-ready-toleration-seconds=60 (default 300) #指示notReady:NoExecute的容忍度的容忍度秒数，默认情况下，该值会添加到尚未具有此类容忍度的每个pod中。
```

> 这种场景下会，Kubelet将尝试每10秒更新一次状态。因此，在Kubernetes控制器管理器检查节点的不健康状态之前，它将是 (5m / 1m *5) = 20 次尝试。节点被标记为不健康状态之后，Pod 将在 1m以内被驱逐。（总计6分钟左右）

# 参考

[https://github.com/kubernetes-sigs/kubespray/blob/master/docs/kubernetes-reliability.md?spm=a2c6h.12873639.article-detail.148.5575136eM59wC5&amp;file=kubernetes-reliability.md](https://github.com/kubernetes-sigs/kubespray/blob/master/docs/kubernetes-reliability.md?spm=a2c6h.12873639.article-detail.148.5575136eM59wC5&file=kubernetes-reliability.md)

[http://team.jiunile.com/blog/2019/08/k8s-kubelet-sync-node-status.html](http://team.jiunile.com/blog/2019/08/k8s-kubelet-sync-node-status.html)
