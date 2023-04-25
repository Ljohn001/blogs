

---
title: calico-node异常重启
tags: [calico,kubernetes,linux,k8s]
categories: [calico]
---
# 环境信息

* os 版本： centos7.
* kernel 版本：3.10.0-1160.59.1.el7.x86_64
* k8s 版本：v1.19.4
* calico-node 版本：v3.8.8-1

# 问题描述

calico异常重启导致容器网络异常超时，查看日志发现报错如下

```bash
# 获取异常节点calico-node重启多次
kubectl -n kube-system get pod -owide | grep calico-node-56bgm
calico-node-56bgm                             1/1     Running   21         246d   10.165.6.26      10.165.6.26   <none>           <none>

# 查看calico-node历史日志如下
kubectl -n kube-system logs -p calico-node-56bgm | less
runtime: failed to create new OS thread (have 41 already; errno=11)
runtime: may need to increase max user processes (ulimit -u)
fatal error: newosproc

runtime stack:
runtime.throw(0x1aa0343, 0x9)
        /usr/local/go/src/runtime/panic.go:608 +0x72
runtime.newosproc(0xc00062ea80)
        /usr/local/go/src/runtime/os_linux.go:166 +0x1c0
runtime.newm1(0xc00062ea80)
        /usr/local/go/src/runtime/proc.go:1940 +0xfe
runtime.newm(0x1b62358, 0x0)
        /usr/local/go/src/runtime/proc.go:1919 +0x9b
runtime.startTheWorldWithSema(0xc0000b7501, 0x45b1b6)
        /usr/local/go/src/runtime/proc.go:1209 +0x1ce
runtime.gcMarkTermination.func3()
        /usr/local/go/src/runtime/mgc.go:1644 +0x26
runtime.systemstack(0x0)
        /usr/local/go/src/runtime/asm_amd64.s:351 +0x66
runtime.mstart()
        /usr/local/go/src/runtime/proc.go:1229

goroutine 35 [running]:
runtime.systemstack_switch()
        /usr/local/go/src/runtime/asm_amd64.s:311 fp=0xc0000b7568 sp=0xc0000b7560 pc=0x4577d0
runtime.gcMarkTermination(0x3fecb9f8bbbbdd6c)
        /usr/local/go/src/runtime/mgc.go:1644 +0x3f5 fp=0xc0000b7738 sp=0xc0000b7568 pc=0x41a695
runtime.gcMarkDone()
        /usr/local/go/src/runtime/mgc.go:1510 +0x21e fp=0xc0000b7760 sp=0xc0000b7738 pc=0x41a23e
runtime.gcBgMarkWorker(0xc00005f900)
        /usr/local/go/src/runtime/mgc.go:1909 +0x2b2 fp=0xc0000b77d8 sp=0xc0000b7760 pc=0x41b162
runtime.goexit()
        /usr/local/go/src/runtime/asm_amd64.s:1333 +0x1 fp=0xc0000b77e0 sp=0xc0000b77d8 pc=0x459731
created by runtime.gcBgMarkStartWorkers
        /usr/local/go/src/runtime/mgc.go:1720 +0x77

```

# 根因分析

查看系统ulimit限制

```bash
cat /etc/security/limits.conf | tail -n 5
*       soft    nofile  65535
*       hard    nofile  65535
*       soft    nproc   65535
*       hard    nproc   65535
```

查看用户进程限制，默认限制用户进程的数量 4096 太小

```bash
cat /etc/security/limits.d/20-nproc.conf
# Default limit for number of user's processes to prevent
# accidental fork bombs.
# See rhbz #432903 for reasoning.

*          soft    nproc     4096
root       soft    nproc     unlimited
```
