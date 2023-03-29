---
title: docker报错打开太多文件（too many open files）
tags: [docker,k8s,linux]
categories: [linux,docker]
---
在Linux系统内默认对所有进程打开的文件数量有限制（也可以称为文件句柄，包含打开的文件，套接字，网络连接等都算是一个文件句柄）

## 查看当前系统限制最大文件打开数量

```bash
cat /proc/sys/fs/file-max
2000000
```

## 查询当前系统已打开文件数量

```bash
cat /proc/sys/fs/file-nr
8640    0       2000000    # 左边的值为当前系统已打开文件数量，右侧表示当前系统限制最大文件打开数
```

以上查询得知当前系统打开文件句柄数未达到上限，往下排查Docker进程的最大文件句柄数限制及已打开文件数

## 查询当前Docker进程最大可打开文件数量及已打开文件数量

```bash
systemctl status docker | grep PID      #获取Docker进程的PID号
Main PID: 14644 (dockerd)
cat /proc/`pidof dockerd`/limits
# 或者使用
ls -l /proc/`pidof dockerd`/fd/* | wc -l    ## 获取当前Docker进程已打开的文件数量
65342      #报错时该值达到了最大限制65536
```

## 临时动态修改当前Docker进程的nofile限制，问题修复

```bash
#将Docker进程的nofile限制调整为655360
prlimit --pid 14644 --nofile=655360:655360   
#再次查询Docker进程状态发现问题已修复
systemctl status docker 
#查看当前Docker进程最大可打开文件数量
cat /proc/`pidof dockerd`/limits   
Max cpu time              unlimited            unlimited            seconds
Max file size             unlimited            unlimited            bytes
Max data size             unlimited            unlimited            bytes
Max stack size            8388608              unlimited            bytes
Max core file size        unlimited            unlimited            bytes
Max resident set          unlimited            unlimited            bytes
Max processes             unlimited            unlimited            processes
Max open files            655360               655360               files
Max locked memory         65536                65536        				bytes
Max address space         unlimited            unlimited            bytes
Max file locks            unlimited            unlimited            locks
Max pending signals       61943                61943                signals
Max msgqueue size         819200               819200               bytes
Max nice priority         0                    0
Max realtime priority     0                    0
Max realtime timeout      unlimited            unlimited            us
```

## FAQ

Q、修改daoker systemd服务配置参数LimitNOFILE=****infinity，不生效问题。****

```bash
$ cat  /etc/redhat-release
CentOS Linux release 7.6.1810 (Core)
$ rpm -qa | grep systemd-sysv
systemd-sysv-219-62.el7.x86_64
$ uname -a
Linux HZPL004094053 3.10.0-1160.76.1.el7.x86_64 #1 SMP Wed Aug 10 16:21:17 UTC 2022 x86_64 x86_64 x86_64 GNU/Linux
$ cat /etc/systemd/system/docker.service | grep LimitNOFILE
LimitNOFILE=infinity 
#最终却得到65536
cat /proc/`pidof dockerd`/limits |grep files
Max open files            65536                65536                files
```

A、根治方案，修改systemd配置LimitNOFILE值

该问题应该是systemd服务[bug issue](https://github.com/systemd/systemd/issues/6559)

```bash
cat /etc/systemd/system/docker.service | grep LimitNOFILE
LimitNOFILE=200000 # 可以修改配置文件到20w以上。
systemctl daemon-reload
systemctl restart docker
cat /proc/`pidof dockerd`/limits |grep files
Max open files            200000                200000                files
```
