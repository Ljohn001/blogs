---
title: Ubuntu内核管理
tags:
  - ubuntu
  - linux
categories:
  - linux
abbrlink: b97fcc87
---
# 背景

由于公司目前开始全面开始推进ubuntu系统的使用，使用时发现内核更新太过频繁，对于ubuntu桌面版本内核升级可能会提升用户体验和安全性，但对于ubuntu server服务器，我们一般会采用固定版本。默认情况下ubuntu不管是桌面版还是server版本，执行 `apt update`会升级下载所有需要升级的包（包括内核包）。版本固定方便统一维护，如果某个版本的内核存在bug，可以安排统一更新。

# 升级和卸载内核

1、升级内核

```
# 查看当前内核
uname -r
# 升级软件包
sudo apt update
# 查看可用内核
apt-cache search linux-image
# 选择合适的内核进行安装
sudo apt-get install linux-image-XXXX-generic

or 
之前执行过 sudo apt update 更新过，执行如下
dpkg --list | grep linux-image

or 
另外，可以自行下载制定内核进行安装，下载地址如下：
http://kernel.ubuntu.com/~kernel-ppa/mainline/ 
sudo dpkg -i *.deb

```

2、卸载内核

```
# 查看内核安装情况：
dpkg --list | grep linux-image
dpkg --list | grep linux-headers
# 手动指定卸载内核：
sudo apt purge linux-image-xx
sudo apt purge linux-headers-xx
sudo apt autoremove

# 这里也可以选择卸载所有不在使用的内核版本(5.4.187为当前在使用版本)
sudo apt-get autoremove --purge $(dpkg -l 'linux-*' | awk '/^ii/{print $2}' | grep -E 'linux-(image|headers|modules|modules-extra)-[0-9]+' | grep -v "5.4.187" | awk '{print $1}')

# 执行更新grub
sudo update-grub 
```

3、修改默认启动的内核版本

如果已经更新了内核，主机上就会存在多个已安装版本，默认情况下重启会自动选择最新的，这个时候如何选择某个版本下次重启生效

```
# 查看已经在启动列表的内核
cat /boot/grub/grub.cfg | grep "menuentry 'Ubuntu," | awk -F '--class' '{print $1}
        menuentry 'Ubuntu, with Linux 5.10.87-051087-generic'
        menuentry 'Ubuntu, with Linux 5.10.87-051087-generic (recovery mode)'
        menuentry 'Ubuntu, with Linux 5.4.187-0504187-generic'
        menuentry 'Ubuntu, with Linux 5.4.187-0504187-generic (recovery mode)'
        menuentry 'Ubuntu, with Linux 4.15.0-163-generic'
        menuentry 'Ubuntu, with Linux 4.15.0-163-generic (recovery mode)'
        menuentry 'Ubuntu, with Linux 4.15.0-162-generic'
        menuentry 'Ubuntu, with Linux 4.15.0-162-generic (recovery mode)'
# 修改/etc/default/grub 找到 GRUB_DEFAULT 行，并将其值设置为所选择的内核版本的完整名称或索引号。
vi /etc/default/grub
GRUB_DEFAULT='Ubuntu, with Linux 4.15.0-162-generic'
# 更新grub，重启主机生效
update-grub

```

# 关闭内核自动更新

1、固定某个版本的内核

```
# 固定hold某个软件包，以后执行update就不会升级和下载内核
sudo apt-mark hold linux-image-generic linux-headers-generic
# 查看hold状态包
sudo dpkg --get-selections | grep hold 
# 如果要重新启用内核更新
sudo apt-mark unhold linux-image-generic linux-headers-generic
```

2、或，如下方式关闭软件包自动更新配置

```
# 修改如下配置，其中的值改成 "0"
/etc/apt/apt.conf.d/10periodic
/etc/apt/apt.conf.d/20auto-upgrades

cat /etc/apt/apt.conf.d/20auto-upgrades
APT::Periodic::Update-Package-Lists "0";
APT::Periodic::Unattended-Upgrade "0";

cat /etc/apt/apt.conf.d/10periodic
APT::Periodic::Update-Package-Lists "0";
APT::Periodic::Download-Upgradeable-Packages "0";
APT::Periodic::AutocleanInterval "0";


```

# 参考

https://www.cnblogs.com/open-skill/p/8295234.html

https://linux.cn/article-6245-1.html
