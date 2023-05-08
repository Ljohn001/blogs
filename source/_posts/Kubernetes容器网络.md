---
title: Kubernetes容器网络
abbrlink: 484087c6
date: 2021-07-15 09:14:37
tags:
---
## 容器是什么

容器其实是一种沙盒技术。顾名思义，沙盒就是能够像一个集装箱一样，把你的应用“装”起来的技术。这样，应用与应用之间，就因为有了边界而不至于相互干扰；而被装进集装箱的应用，也可以被方便地搬到任何地方运行。对于大多数如Docker、RKT，等Linux容器，其实就是利用Linux Namespace技术创建隔离的进程空间、文件系统、网络命名空间、用户空间、主机名的一组进程。

所以说，容器，其实是一种特殊的进程而已。

一个“容器”，实际上是一个由 Linux Namespace、Linux Cgroups 和 rootfs 三种技术构建出来的进程的隔离环境。

### 容器优势

- 开销更少，无需像虚拟化一样虚拟完整的内核以及初始化环境，和启动一些多余的系统进程。
- 可移植性强，容器可以轻松在不同平台移植，如直接运行`docker run -d --name nginx -p 80:80 nginx`
- 高效率，开发打完包构建容器后，可以更快部署，发布
- 敏捷开发，更快的移植，无需担心依赖的环境不一致的问题
- ....

### Kebernetes

k8s 是什么？为什么要引入 k8s，kubernetes 其实是google公司开源，和Redhat公司一起开发的一个容器编排项目。

- k8s 是什么，为什么要引入k8s：https://kubernetes.io/zh/docs/concepts/overview/what-is-kubernetes/

- k8s 组件有哪些：https://kubernetes.io/zh/docs/concepts/overview/components/ 

## 容器网络模型

### docker 的三种网络模式

在将容器网络之前先讲一下docker 的网络模式，`docker network ls`  可以看到

```
 NETWORK ID          NAME                DRIVER              SCOPE
7152832275d0        bridge              bridge              local
bfc2647e9b0b        host                host                local
00ed57db3efb        none                null                local
```

- bridge 借助虚拟网桥设备为容器建立网络连接

- host 设置容器直接共享当前节点主机的网络名称空间

- none 对于此容器，禁用所有网络。通常与自定义网络驱动程序结合使用

  ```bash
  # 每个容器都有自己的独立的'网络栈'，如果你想要实现两台主机之间的通信，最直接的办法，就是把它们用一根网线连接起来；而如果你想要实现多台主机之间的通信，那就需要用网线，把它们连接在一台交换机上，即网桥（Bridge）。它是一个工作在数据链路层（Data Link）的设备，主要功能是根据 MAC 地址学习来将数据包转发到网桥的不同端口（Port）上
  # 在容器中，Docker安装完成时会创建一个名为docker0的linux bridge，不指定网络时，创建的网络默认为桥接网络，都会桥接到docker0上。
  # 如何把容器连接到这个docker0 网桥上呢？这个时候就需要 Veth Pair 的虚拟设备了，该设备一般是成对的出现，并且，从其中一个“网卡”发出的数据包，可以直接出现在与它对应的另一张“网卡”上，哪怕这两个“网卡”在不同的 Network Namespace 里
  $ brctl show
  bridge name     bridge id               STP enabled     interfaces
  docker0         8000.0242f2caa77e       no
  pan1            8000.000000000000       no
  $ docker run -d -u daemon  --name 'net-bridge' busybox top 
  $ docker exec -ti net-bridge  /bin/sh
  # Veth Pair虚拟网卡设备eth0@if62
  / $ ip a
  1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue qlen 1000
      link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
      inet 127.0.0.1/8 scope host lo
         valid_lft forever preferred_lft forever
  61: eth0@if62: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1500 qdisc noqueue
      link/ether 02:42:ac:11:00:02 brd ff:ff:ff:ff:ff:ff
      inet 172.17.0.2/16 brd 172.17.255.255 scope global eth0
         valid_lft forever preferred_lft forever
  / $ route -n
  Kernel IP routing table
  Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
  0.0.0.0         172.17.0.1      0.0.0.0         UG    0      0        0 eth0
  172.17.0.0      0.0.0.0         255.255.0.0     U     0      0        0 eth0
  # 宿主机上查看接口信息,启动了一个虚拟网卡设备 vethaf3497b@if61
  $ ip a | tail -4
  62: vethaf3497b@if61: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master docker0 state UP group default
      link/ether ca:2f:b0:6a:a1:28 brd ff:ff:ff:ff:ff:ff link-netnsid 0
      inet6 fe80::c82f:b0ff:fe6a:a128/64 scope link
         valid_lft forever preferred_lft forever
  
  # brctl show 可以看到docker0 设备上多了一个接口 vethf29b81e 即刚才启动容器的虚拟网卡
  $ brctl show
  bridge name     bridge id               STP enabled     interfaces
  docker0         8000.0242f2caa77e       no              vethaf3497b
  pan1            8000.000000000000       no
  
  # host网络，就是和host主机共享网络，会和host使用一样的网络，host网络的性能比较高，但也会不可避免地引入共享网络资源的问题，比如端口冲突，比如隔离性问题。
  
  $ docker run --net=host busybox ifconfig
  docker0   Link encap:Ethernet  HWaddr 02:42:F2:CA:A7:7E
            inet addr:172.17.0.1  Bcast:172.17.255.255  Mask:255.255.0.0
            inet6 addr: fe80::42:f2ff:feca:a77e/64 Scope:Link
            UP BROADCAST MULTICAST  MTU:1500  Metric:1
            RX packets:274096 errors:0 dropped:0 overruns:0 frame:0
            TX packets:323190 errors:0 dropped:0 overruns:0 carrier:0
            collisions:0 txqueuelen:0
            RX bytes:13525456 (12.8 MiB)  TX bytes:1664281006 (1.5 GiB)
  
  enp0s31f6 Link encap:Ethernet  HWaddr 54:E1:AD:08:B4:21
            UP BROADCAST MULTICAST  MTU:1500  Metric:1
            RX packets:0 errors:0 dropped:0 overruns:0 frame:0
            TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
            collisions:0 txqueuelen:1000
            RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
            Interrupt:16 Memory:f2200000-f2220000
  
  lo        Link encap:Local Loopback
            inet addr:127.0.0.1  Mask:255.0.0.0
            inet6 addr: ::1/128 Scope:Host
            UP LOOPBACK RUNNING  MTU:65536  Metric:1
            RX packets:1850471 errors:0 dropped:0 overruns:0 frame:0
            TX packets:1850471 errors:0 dropped:0 overruns:0 carrier:0
            collisions:0 txqueuelen:1000
            RX bytes:1186483790 (1.1 GiB)  TX bytes:1186483790 (1.1 GiB)
  
  pan1      Link encap:Ethernet  HWaddr 12:AA:30:13:D7:A4
            inet addr:10.6.207.1  Bcast:10.6.207.255  Mask:255.255.255.0
            inet6 addr: fe80::10aa:30ff:fe13:d7a4/64 Scope:Link
            UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
            RX packets:0 errors:0 dropped:0 overruns:0 frame:0
            TX packets:14194 errors:0 dropped:0 overruns:0 carrier:0
            collisions:0 txqueuelen:1000
            RX bytes:0 (0.0 B)  TX bytes:2916067 (2.7 MiB)
  wlp3s0    Link encap:Ethernet  HWaddr F8:59:71:8E:3F:55
            inet addr:10.10.134.147  Bcast:10.10.143.255  Mask:255.255.240.0
            inet6 addr: fe80::54ce:44cc:368:d288/64 Scope:Link
            UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
            RX packets:16914279 errors:0 dropped:0 overruns:0 frame:0
            TX packets:4101535 errors:0 dropped:0 overruns:0 carrier:0
            collisions:0 txqueuelen:1000
            RX bytes:7919534294 (7.3 GiB)  TX bytes:2673781183 (2.4 GiB)          
  ....
  
  # none网络，在该网络下的容器仅有lo网卡，属于封闭式网络，通常用于对安全性要求较高并且不需要联网的应用
  docker run --rm -it --network=none busybox ip a
  1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue qlen 1000
      link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
      inet 127.0.0.1/8 scope host lo
         valid_lft forever preferred_lft forever
   
  ```

接下来以docker 两种通信方式来介绍容器通信模式：

### 单机容器通信

同一个宿主机上的不同容器通过 docker0 网桥进行通信的流程如图：

![image-20210713104524840](https://i.loli.net/2021/07/14/VutyxR1TczBPSpv.png)

如图说所示，在容器中，通过docker0网桥，凡是连接到docker0的容器，就可以通过它来进行通信。要想容器能够连接到docker0网桥，我们需要类似网线的虚拟设备Veth Pair来把容器连接到网桥上。 

```bash
# 启动一个container1 
$ docker run -d --name 'container1' nginx
$ dockrer exec -ti container1  /bin/sh
$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
65: eth0@if66: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
    link/ether 02:42:ac:11:00:03 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 172.17.0.3/16 brd 172.17.255.255 scope global eth0
       valid_lft forever preferred_lft forever
$ route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         172.17.0.1      0.0.0.0         UG    0      0        0 eth0
172.17.0.0      0.0.0.0         255.255.0.0     U     0      0        0 eth0

# 启动一个container2
$ docker run -d --name 'container2' nginx
$ dockrer exec -ti container2  /bin/sh
$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
63: eth0@if64: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
    link/ether 02:42:ac:11:00:02 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 172.17.0.2/16 brd 172.17.255.255 scope global eth0
       valid_lft forever preferred_lft forever
# route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         172.17.0.1      0.0.0.0         UG    0      0        0 eth0
172.17.0.0      0.0.0.0         255.255.0.0     U     0      0        0 eth0

# 查看宿主机上的虚拟设备Veth Pair, veth182b3a5@if63 和 container2 的eth0@if64 是一对，container1 同理。
$ ip a | tail -8
64: veth182b3a5@if63: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master docker0 state UP group default
    link/ether 76:97:8e:fe:a9:c7 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet6 fe80::7497:8eff:fefe:a9c7/64 scope link
       valid_lft forever preferred_lft forever
66: veth877c7d8@if65: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master docker0 state UP group default
    link/ether 12:7e:d0:0f:ae:99 brd ff:ff:ff:ff:ff:ff link-netnsid 1
    inet6 fe80::107e:d0ff:fe0f:ae99/64 scope link
       valid_lft forever preferred_lft forever

# container1 ping container2 测试
# ping 172.17.0.3
PING 172.17.0.3 (172.17.0.3) 56(84) bytes of data.
64 bytes from 172.17.0.3: icmp_seq=1 ttl=64 time=0.091 ms
64 bytes from 172.17.0.3: icmp_seq=2 ttl=64 time=0.059 ms
64 bytes from 172.17.0.3: icmp_seq=3 ttl=64 time=0.034 ms
# 可以看到同一宿主机容器默认都是通的，是因为他们默认网关都是docker0 这块网卡。 

```

### 跨主机容器通信

跨主机通信方案有以下几种方案：

- NAT方式
  NAT就是传统的docker网络，利用宿主机的IP和Iptables来达到容器，主机之间的通信。容器对外IP都是宿主机的IP，NAT的性能损耗比较大。但只要宿主机之间三层IP可达，容器之间就可以通信，比较普适。
- Tunnel（overlay）方式，VPN，ipip，VXLAN等都是tunnel技术，简单讲就是在容器的数据包间封装一层或多层其他的数据协议头，达到连通的效果。这种方式一般也是只需要三层可达，容器就能互通，比较普适。
- Routing方式
  路由方案主要是通过路由设置的方式让容器对容器，容器对宿主机之间相通信。例如：calico的BGP路由方案（非IPIP）。这种方式一般适用于单个数据中心，最常见的是同一个vlan中使用，如果不是，需要设置路由规则。路由方案性能损耗少，和主机网络性能比较接近。

先介绍下NAT方式，所有接入到该桥接设备上的容器都会被NAT隐藏，它们发往Docker主机外部的所有流量都会经过源地址转换后发出(SNAT)，并且默认是无法直接接受节点之外的其他主机发来的请求。当需要接入Docker主机外部流量，就需要进行目标地址转换(DNAT)甚至端口转换将其暴露在外部网络当中。大致的流程图：

![image-20210713111835432](https://i.loli.net/2021/07/14/scPfALv6ibqEMWI.png)

容器内的属于私有地址，需要在左侧的主机上的eth0上进行源地址转换，而右侧的地址需要被访问，就需要将eth0的地址进行NAT转换。SNAT---->DNAT。

```
#具体方案在2个主机上通过主机路由和iptables 地址伪装来实现跨主机容器的互通，这里就不做过多解释
```

## Kubernetes 容器网络CNI插件

这里介绍完docker的网络方案之后，我们来聊聊kubernetes的容器间网络的通信方案。

官网中文doc：https://kubernetes.io/zh/docs/concepts/cluster-administration/networking/

那么什么是CNI（container network interface）容器网络接口，k8s为了更好的控制网络的接入，推出了CNI即容器网络的API接口。CNI维护了一个单独的网桥来代替 docker0。这个网桥的名字就叫作：CNI 网桥，它在宿主机上的设备名称默认是：cni0。

CNI主要解决Pod间的通信，目前流行的CNI插件如：calico, cilium, flannel, kube-ovn, kube-router

## Flannel 插件跨主机通信原理

Flannel 项目是 CoreOS 公司主推的容器网络方案。事实上，Flannel 项目本身只是一个框架，真正为我们提供容器网络功能的，是 Flannel 的后端实现。目前，Flannel 支持三种后端实现，分别是：

- UDP
- VXLAN
- host-gw

### udp模式

![image-20210713190907679](https://i.loli.net/2021/07/14/zSH467pZwVF1LBg.png)

可以看到，Flannel UDP 模式提供的其实是一个三层的 Overlay 网络，即：它首先对发出端的 IP 包进行 UDP 封装，然后在接收端进行解封装拿到原始的 IP 包，进而把这个 IP 包转发给目标容器。这就好比，Flannel 在不同宿主机上的两个容器之间打通了一条“隧道”，使得这两个容器可以直接使用 IP 地址进行通信，而无需关心容器和宿主机的分布情况。

但是UDP 模式有严重的性能问题，基本已经上被废弃了。

基于 Flannel UDP 模式的容器通信多了一个额外的步骤，即 flanneld 的处理过程。而这个过程，由于使用到了 flannel0 这个 TUN 设备，仅在发出 IP 包的过程中，就需要经过三次用户态与内核态之间的数据拷贝，其性能可想而知。

### VXLAN模式

VXLAN，即 Virtual Extensible LAN（虚拟可扩展局域网），是 Linux 内核本身就支持的一种网络虚似化技术。所以说，VXLAN 可以完全在内核态实现上述封装和解封装的工作，从而通过与前面相似的“隧道”机制，构建出覆盖网络（Overlay Network）

![image-20210713191114467](https://i.loli.net/2021/07/14/Kqv7ULZscznIGFC.png)

VXLAN 模式组建的覆盖网络，其实就是一个由不同宿主机上的 VTEP 设备，也就是 flannel.1 设备组成的虚拟二层网络。对于 VTEP 设备来说，它发出的“内部数据帧”就仿佛是一直在这个虚拟的二层网络上流动。这，也正是覆盖网络的含义,具体就不展开了。

## Kubernetes 三层网络方案

讲了以上flannel 的以上2种方案，我们接下来讲一下纯三层的网络方案，如于 Flannel 的 host-gw 模式和 Calico BGP

###  Flannel 的 host-gw 模式

![image-20210714221235728](https://i.loli.net/2021/07/14/xp64BmUif5PMXsl.png)

假设现在，Node 1 上的 Infra-container-1，要访问 Node 2 上的 Infra-container-2。

当你设置 Flannel 使用 host-gw 模式之后，flanneld 会在宿主机上创建这样一条规则，以 Node 1 为例：

```bash
$ ip route
...
10.244.1.0/24 via 10.168.0.3 dev eth0
```

这条路由规则的含义是：目的 IP 地址属于 10.244.1.0/24 网段的 IP 包，应该经过本机的 eth0 设备发出去（即：dev eth0）；并且，它下一跳地址（next-hop）是 10.168.0.3（即：via 10.168.0.3）。

如图所示这个下一跳地址对应的，正是我们的目的宿主机 Node 2。

一旦配置了下一跳地址，那么接下来，当 IP 包从网络层进入链路层封装成帧的时候，eth0 设备就会使用下一跳地址对应的 MAC 地址，作为该数据帧的目的 MAC 地址。显然，这个 MAC 地址，正是 Node 2 的 MAC 地址。这样，这个数据帧就会从 Node 1 通过宿主机的二层网络顺利到达 Node 2 上。

而 Node 2 的内核网络栈从二层数据帧里拿到 IP 包后，会“看到”这个 IP 包的目的 IP 地址是 10.244.1.3，即 Infra-container-2 的 IP 地址。这时候，根据 Node 2 上的路由表，该目的地址会匹配到第二条路由规则（也就是 10.244.1.0 对应的路由规则），从而进入 cni0 网桥，进而进入到 Infra-container-2 当中。

host-gw 模式的工作原理，其实就是将每个 Flannel 子网（Flannel Subnet，比如：10.244.1.0/24）的“下一跳”，设置成了该子网对应的宿主机的 IP 地址。所以宿主机充当了“网关”的角色，即顾名思义“host-gw”

### Calico

Calico 是一套开源的网络和网络安全方案，用于容器、虚拟机、宿主机之前的网络连接，可以用在kubernetes、OpenShift、DockerEE、OpenStrack等PaaS或IaaS平台上。

首先看下calico 架构图

[摘自网上]: https://www.programmersought.com/article/18013193559/

![image-20210713170229021](https://i.loli.net/2021/07/14/t4dhz5sQkFiPWcl.png)

- `Felix`：`calico`的核心组件，运行在每个节点上。主要的功能有接口管理、路由规则、ACL规则和状态报告
- `Etcd`：保证数据一致性的数据库，存储集群中节点的所有路由信息。为保证数据的可靠和容错建议至少三个以上etcd节点。
- `Bird`：BGP客户端，`Calico`在每个节点上的都会部署一个BGP客户端（利用Daemonset方式部署），它的作用是将Felix的路由信息读入内核，并通过BGP协议在集群中分发。当Felix将路由插入到Linux内核FIB中时，BGP客户端将获取这些路由并将它们分发到部署中的其他节点。这可以确保在部署时有效地路由流量。
- `BGP Router Reflector`：使用 BGP client 形成 mesh 全网互联的方案就会导致规模限制，所有节点需要 N^2 个连接，为了解决这个规模问题，BGP 的 `Router Reflector`的方法，使所有 BGP Client 仅与特定 RR 节点互联并做路由同步，从而大大减少连接数。

#### Calico 网络模式

-  IPIP模式，把 IP 层封装到 IP 层的一个 tunnel。作用其实基本上就相当于一个基于IP层的网桥！一般来说，普通的网桥是基于mac层的，根本不需 IP，而这个 ipip 则是通过两端的路由做一个 tunnel，把两个本来不通的网络通过点对点连接起来。
- Router Reflector 模式（RR），Calico 维护的网络在默认是（Node-to-Node Mesh）全互联模式，Calico集群中的节点之间都会相互建立连接，用于路由交换。但是随着集群规模的扩大，mesh模式将形成一个巨大服务网格，连接数成倍增加。这时就需要使用 Route Reflector（路由器反射）模式解决这个问题。

#### BGP 协议

`BGP（border gateway protocol）是外部路由协议（边界网关路由协议）`，用来在AS之间传递路由信息是一种增强的距离矢量路由协议（应用场景），基本功能是在自治系统间自动交换无环路的路由信息，通过交换带有自治系统号序列属性的路径可达信息，来构造自治系统的拓扑图，从而消除路由环路并实施用户配置的路由策略。**只要记住BGP简单理解其实就是实现大规模网络中节点路由信息同步共享的一种协议**。

>实际上，Calico 项目提供的 `BGP` 网络解决方案，与 `Flannel` 的 `host-gw` 模式几乎一样。也就是说，Calico也是基于路由表实现容器数据包转发，但不同于Flannel使用flanneld进程来维护路由信息的做法，而Calico项目使用BGP协议来自动维护整个集群的路由信息。

BGP模式

- `全互联模式`（node-to-node mesh） 每一个BGP Speaker都需要和其他BGP Speaker建立BGP连接，这样BGP连接总数就是N^2，如果数量过大会消耗大量连接。如果集群数量超过100台官方不建议使用此种模式。
- RR模式（Router Reflection），会指定一个或多个BGP Speaker为RouterReflection，它与网络中其他Speaker建立连接，每个Speaker只要与Router Reflection建立BGP就可以获得全网的路由信息。在calico中可以通过`Global Peer`实现RR模式。

#### Calico IPIP

![image-20210714210320203](https://i.loli.net/2021/07/14/dtF9w1YTnsIZ4Ek.png)

IPIP 是linux内核的驱动程序，可以对数据包进行隧道，上图可以看到两个不同的网络 vlan1 和 vlan2。基于现有的以太网将原始包中的原始IP进行一次封装，通过tunl0解包，这个tunl0类似于ipip模块，和Flannel vxlan的veth很类似。

Pod1 访问 Pod2 流程如下：

1. 数据包从 Pod1 出到达Veth Pair另一端（宿主机上，以cali前缀开头）。

2. 进入IP隧道设备（tunl0），由Linux内核IPIP驱动封装，把源容器ip换成源宿主机ip，目的容器ip换成目的主机ip，这样就封装成 Node1 到 Node2 的数据包。

   ```bash
   此时包的类型：
     原始IP包：
     源IP：10.244.1.10
     目的IP：10.244.2.10
   
      TCP：
      源IP: 192.168.31.62
      目的iP：192.168.32.63
   ```

3. 数据包经过路由器三层转发到 Node2

4. Node2 收到数据包后，网络协议栈会使用IPIP驱动进行解包，从中拿到原始IP包。

5. 然后根据路由规则，将数据包转发给cali设备，从而到达 Pod2。

通过如上步骤可以看出，当 Calico 使用 IPIP 模式的时候，集群的网络性能会因为额外的封包和解包工作而下降。所以建议你将所有宿主机节点放在一个子网里，避免使用 IPIP。**不过这里可以利用IPIP模式的CrossSubnet来突破node不能跨VALN的问题，这个目前已经测试通过。**

#### Calico BGP RR

calico还和flannel host-gw不同之处在于，它不会创建网桥设备，而是通过路由表来维护每个pod的通信，如下图：

![image-20210714200920896](https://i.loli.net/2021/07/14/2nKSBwmRChpUqgD.png)

Pod1 访问 Pod2大致流程如下：

- 数据包从Pod1出到达Veth Pair另一端（宿主机上，以cali前缀开头）
- 宿主机根据路由规则，将数据包转发给下一跳（网关）
- 到达Node2，根据路由规则将数据包转发给cali设备，从而到达Pod2

实际例子：

```bash
1.启动2个容器
kubectl create -f -<<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nettools-deploy
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nettools-deploy
  template:
    metadata:
      labels:
        app: nettools-deploy
    spec:
      containers:
        - name: nettools-deploy
          image: registry.XXX.com/base/network-multitool:lastet
          imagePullPolicy: IfNotPresent     
          ports:
            - containerPort: 80
EOF
2.查看2个pod 目前所在的node节点
kubectl get pod -owide
NAME                               READY   STATUS    RESTARTS   AGE    IP             NODE         NOMINATED NODE   READINESS GATES
nettools-deploy-68b646bdfb-2ckgt   1/1     Running   0          113s   10.5.231.54    10.4.83.14   <none>           <none>
nettools-deploy-68b646bdfb-xbpwd   1/1     Running   0          113s   10.5.228.128   10.4.83.11   <none>           <none>
3.查看pod中的路由和网卡信息，可以看到路由指向的是一个不存在的网关地址169.254.1.1，这个主要利用了ARP代理欺骗的技术来把pod 所有数据流导到宿主机的 cali70d877f367d@if3 网卡上
kubectl exec -ti nettools-deploy-68b646bdfb-2ckgt  /bin/sh
ip r
default via 169.254.1.1 dev eth0
169.254.1.1 dev eth0 scope link
/ # ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
3: eth0@if9431: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
    link/ether be:11:81:9a:9b:d4 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.5.231.54/32 scope global eth0
       valid_lft forever preferred_lft forever
4.可以登录node 查看Veth Pair 设备和路由信息，这里可以看到网卡的编号和pod 中的网卡名是一样的。所以称之为虚拟网卡对(Veth Pair)，有了这个cali70d877f367d@if3 设备那么容器发出的IP包就会通过veth pair设备到达宿主机
ip r  | grep 10.5.231.54
10.5.231.54 dev cali70d877f367d scope link

ip a | grep -A 4  9431
9431: cali70d877f367d@if3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
    link/ether ee:ee:ee:ee:ee:ee brd ff:ff:ff:ff:ff:ff link-netnsid 7
    inet6 fe80::ecee:eeff:feee:eeee/64 scope link
       valid_lft forever preferred_lft forever
5.pod1要想跟其他主机pod2通信那么检查node上是否存在相应的路由，然后到达目标宿主机，再到达目标容器
ip r | grep 10.5.228.128
10.5.228.128/26 via 10.4.83.11 dev bond0 proto bird
```

其中，这里最核心的 下一跳 路由规则，就是由 Calico 的 Felix 进程负责维护的。这些路由规则信息，则是通过 BGP Client 中 BIRD 组件，使用 BGP 协议来传输。

不难发现，Calico 项目实际上将集群里的所有节点，都当作是边界路由器来处理，它们一起组成了一个全连通的网络，互相之间通过 BGP 协议交换路由规则。这些节点，我们称为 BGP Peer。

需要注意的是calico 维护网络的默认模式是 node-to-node mesh ,这种模式下，每台宿主机的BGP client都会跟集群所有的节点BGP client进行通信交换路由。这样一来，随着节点规模数量N的增加，连接会以N的2次方增长，会集群网络本身带来巨大压力，在集群规模比较大时，官方建议是使用BGP-RR 如下是我们使用网络硬件设备作为RR

```bash
calicoctl node status
Calico process is running.

IPv4 BGP status
+--------------+-----------+-------+------------+-------------+
| PEER ADDRESS | PEER TYPE | STATE |   SINCE    |    INFO     |
+--------------+-----------+-------+------------+-------------+
| 10.4.36.250  | global    | up    | 2021-05-11 | Established |
| 10.4.36.251  | global    | up    | 2021-05-11 | Established |
+--------------+-----------+-------+------------+-------------+

```



#### 目前calico架构图

![image-20210714205042267](https://i.loli.net/2021/07/14/cOREUpCYqS5omPI.png)

现在的架构考虑到了冗余，隔离，性能

- 网络隔离，所有的bgp 学习在一组交换机内，不向上通报，避免容器的bgp 影响到我们sdn 的bgp，带来的排障的麻烦，这是隔离。
- 性能方面，现在集群 bgp 关闭full mesh，改为global，降低因容器集群规模变大，导致路由过多的问题。
- 冗余方面，现在每台机器2条线，接2个交换机，bgp 跟2个交换机互联，实现了冗余，所有流量通过 交换机交换，满足了性能跟冗余的要求。

#### Calico 优劣势

优势

- BGP RR没有封包和解包过程，完全基于两端宿主机的路由表进行转发
- 可以配合使用 `Network Policy` 做 pod 和 pod 之前的访问控制

劣势

- 要求宿主机处于同一个2层网络下，也就是连在一台交换机上，但也可以突破
- 每个node上会设置大量（大量)的iptables规则、路由，运维、排障难度大
- 安全策略隔离上也略显不足

### CNI插件性能比较

基于flannel解包包的路由和转发的操作都是在CPU上进行的，这样就造成了计算资源的浪费。下图是从网上找的各种开源网络组件的性能对比。可以看出，无论是带宽还是网络延迟，性能都和calico主机差不多。

![image-20210714212457115](https://i.loli.net/2021/07/14/5r1QBLDSUpcR7Hk.png)

## Kubernetes Service NodePort 和Ingress

#### Service

Service 这个 Kubernetes 里重要的服务对象。而 Kubernetes 之所以需要 Service，

- 一方面是因为 Pod 的 IP 不是固定的

- 另一方面则是因为一组 Pod 实例之间总会有负载均衡的需求

实际上，Service 是由 kube-proxy 组件，加上 iptables 来共同实现的。

> 并且现在还支持IPVS的模式，kube-proxy 通过 iptables 处理 Service 的过程，其实需要在宿主机上设置相当多的 iptables 规则。而且，kube-proxy 还需要在控制循环里不断地刷新这些规则来确保它们始终是正确的。当pod数量巨大时，成百上千条 iptables 规则不断地被刷新，会大量占用该宿主机的 CPU 资源，甚至会让宿主机“卡”在这个过程中。所以说，一直以来，基于 iptables 的 Service 实现，都是制约 Kubernetes 项目承载更多量级的 Pod 的主要障碍。我们知道IPVS跟IPtables都是工作基于内核的Netfilter 的 NAT 模式工作的，IPVS 并不需要在宿主机上为每个 Pod 设置 iptables 规则，而是把对这些“规则”的处理放到了内核态，从而极大地降低了维护这些规则的代价。所以当集群规模比较大的时候，可以使用ipvs 来提高性能。

ClusterIP 服务是默认的 Kubernetes Service。它为您提供集群内的服务，集群内的其他应用程序可以访问该服务,默认外部无法访问改地址。如图所示

![image-20210714223846542](https://i.loli.net/2021/07/14/5VXtAYkF86OxiNH.png)

#### NodePort

 NodePort服务是将外部流量直接发送到您的服务的最原始方式。NodePort，顾名思义，在所有节点（VM）上打开一个特定的端口，发送到这个端口的任何流量都会转发到服务，如图所示。

![image-20210714224044599](https://i.loli.net/2021/07/14/w8H4RvuPsiJnDzN.png)

#### Ingress

Ingress 实际上不是一种服务。相反，它位于多个服务的前面，充当“智能路由器”或集群的入口点。

Ingress 的功能其实很容易理解：所谓 Ingress，就是 Service 的“Service”，如图所示：

![image-20210714224239095](https://i.loli.net/2021/07/14/hgznYwIPp87KHJF.png)

## FAQ

1. 为什么要用calico 
2. cilium 取代calico
3. ....
