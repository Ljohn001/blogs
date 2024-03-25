---
title: 使用kubeadm部署kubernetes v1-29-2集群
tags:
  - kubeadm
  - kubernetes
  - linux
  - k8s
abbrlink: c03d6b40
date: 2024-02-23 04:20:51
---
## 0.准备

最近准备开始考CKAD，之前考过了CKA，CKS，但环境有些陈旧了，现在最新版考试需要v1.29了。所以重新使用kubeadm部署一套最新版本kubernetes集群v1.29.2，用于练习模拟题。

```bash
1.虚拟机环境
VirtualBox6.1
Linux :ubuntu20.04.3
CPU 2C Memory 2G
2.集群中节点网络互通
3.禁用swap
sudo swapoff -a
sudo sed -ri 's/.*swap.*/#&/' /etc/fstab
4.允许 iptables 检查桥接流量
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF
lsmod | grep br_netfilter
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sudo sysctl --system
```

## 1.安装工具包及安装kubeadm,kubectl,kubelet

```bash
# 基础软件
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
# 导入google 证书
sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL <https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key> | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
# 导入repo
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] <https://pkgs.k8s.io/core:/stable:/v1.29/deb/> /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
# 安装
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

## 2.安装 container runtime(containerd)

[Kubernetes 从版本 v1.20 之后](https://kubernetes.io/zh-cn/blog/2020/12/02/dont-panic-kubernetes-and-docker/)，[弃用 Docker](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.20.md#deprecation) 这个容器运行时。

下面需要使用docker的源来安装containerd

```bash
# 清理系统上docker
sudo apt-get remove docker docker-engine docker.io containerd runc
# 添加docker仓库的GPG Key
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL <https://download.docker.com/linux/ubuntu/gpg> -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# 添加docker仓库
echo \\
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] <https://download.docker.com/linux/ubuntu> \\
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \\
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update# 安装 containerd
sudo apt-get update
sudo apt-get install containerd.io -y

# 配置contained
# 创建配置
containerd config default | sudo tee /etc/containerd/config.toml
# 编辑配置，将如下 SystemdCgroup = false 修改成 SystemdCgroup = true
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
# 重启containerd服务
sudo service containerd restart
```

## 3.集群安装初始化

```bash
# 初始化，（注意这里我使用了阿里云的镜像仓库，默认的google的仓库国内下载走代理有点问题。）
sudo kubeadm init --kubernetes-version=v1.29.2 --pod-network-cidr=10.244.0.0/16 --image-repository=registry.aliyuncs.com/google_containers -v=5

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  <https://kubernetes.io/docs/concepts/cluster-administration/addons/>

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 10.0.2.15:6443 --token rd8xr5.xeoa283lefjzbm4k \\
        --discovery-token-ca-cert-hash sha256:75d02d63fc10729857ec6a5d68628e6ef4d0857d17bff9cb826390a13c6e3dd4
```

`kubeadm init`，后面的参数是需要安装的集群版本，因为我们这里选择 `flannel`作为 Pod 的网络插件，所以需要指定 `–pod-network-cidr=10.244.0.0/16`

## 4.设置集群

配置kubectl访问集群

```bash
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

kubectl 来查看集群的信息

```bash
kubectl get csr
# 现在master 还是not ready 状态是因为CNI插件没有安装，这里不用担心，在预期内
kubectl get nodes
NAME    STATUS     ROLES           AGE   VERSION
svr01   NotReady   control-plane   50m   v1.29.2
# 查看pod 发现coredns 处于Pending 状态也是预期内的，因为没有部署CNI网络插件
kubectl get pod -A 
NAMESPACE     NAME                            READY   STATUS    RESTARTS      AGE
kube-system   coredns-78fcd69978-g7srs        0/1     Pending   0             7s
kube-system   coredns-78fcd69978-j56d6        0/1     Pending   0             51m
kube-system   etcd-svr01                      1/1     Running   0             51m
kube-system   kube-apiserver-svr01            1/1     Running   1 (51m ago)   51m
kube-system   kube-controller-manager-svr01   1/1     Running   0             51m
kube-system   kube-proxy-gqhsh                1/1     Running   0             51m
kube-system   kube-scheduler-svr01            1/1     Running   0             51m
```

## 5.安装CNI

接下来我们来安装 `flannel`网络插件，很简单，和安装普通的 POD 没什么两样：

```bash
wget <https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml>
kubectl apply -f  kube-flannel.yml
```

另外需要注意的是如果你的节点有多个网卡的话，需要在 kube-flannel.yml 中使用 `-iface`参数指定集群主机内网网卡的名称，否则可能会出现 dns 无法解析。flanneld 启动参数加上 `-iface=<iface-name>`

```bash
args:
- --ip-masq
- --kube-subnet-mgr
- --iface=eth0
```

安装完成后使用 kubectl get pods 命令可以查看到我们集群中的组件运行状态，如果都是Running 状态的话，那么恭喜你，你的 master 节点安装成功了。

```bash
kubectl get pods --all-namespaces
```

## 6.添加节点

6.1.初始化后，会显示加入集群的方法，但如果忘记了可以获取集群token 和sha356 值，也可以重新创建token

```bash
kubeadm token list
TOKEN                     TTL         EXPIRES                USAGES                   DESCRIPTION                                                EXTRA GROUPS
wk74a5.scpx0nunatjjplj9   23h         2021-11-26T00:53:34Z   authentication,signing   The default bootstrap token generated by 'kubeadm init'.   system:bootstrappers:kubeadm:default-node-token

# 如果token 过期可以新创建一个token
kubeadm token create --print-join-command
kubeadm join 10.0.2.15:6443 --token pspakn.67wqsy4mix16qu17 --discovery-token-ca-cert-hash sha256:75d02d63fc10729857ec6a5d68628e6ef4d0857d17bff9cb826390a13c6e3dd4
```

6.2.添加，先参考如下对node进行初始化配置安装

* 0.准备
* 1.安装工具包及安装kubeadm,kubectl,kubelet，
* 2.安装 container runtime(containerd)

配置要添加的node节点，接下来就可以直接在 Node 节点上执行 `kubeadm join`命令了

```bash
kubeadm join 10.0.2.15:6443 --token pspakn.67wqsy4mix16qu17 --discovery-token-ca-cert-hash sha256:75d02d63fc10729857ec6a5d68628e6ef4d0857d17bff9cb826390a13c6e3dd4
```

## 7.额外配置

配置命令自动补全

```bash
# 安装 bash-completio
sudo apt-get install bash-completion
source /usr/share/bash-completion/bash_completion

# 启动 kubectl 自动补全功能
echo 'source <(kubectl completion bash)' >>~/.bashrc
kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl

# 别名
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -F __start_kubectl k' >>~/.bashrc

# 生效
source ~/.bashrc
```

apt代理

```bash
cat << EOF | sudo tee /etc/apt/apt.conf.d/proxy.conf
Acquire::http::proxy "<http://192.168.50.222:7890>";
Acquire::https::proxy "<http://192.168.50.222:7890>";
EOF
```

containerd代理

```bash
sudo mkdir /etc/systemd/system/containerd.service.d
cat << EOF | sudo tee /etc/systemd/system/containerd.service.d/http-proxy.conf 
[Service]
Environment="HTTP_PROXY=http://192.168.50.222:7890"
Environment="HTTPS_PROXY=http://192.168.50.222:7890"
EOF
sudo systemctl daemon-reload ; sudo systemctl restart containerd
```

## 8.清理集群

```bash
# 驱逐node 节点容器
kubectl drain <node name> --delete-local-data --force --ignore-daemonsets
# 删除node
kubectl delete node <node name>
# 工作节点上
ifconfig cni0 down && ip link delete cni0
ifconfig flannel.1 down && ip link delete flannel.1
rm -rf /etc/cni/net.d
iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X
# 所有工作节点清理完，在管理节点执行
kubeadm reset
```
