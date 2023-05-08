---
title: Linux 使用crash分析vmcore dump文件
tags:
  - linux
  - 内核
  - vmcore
  - crash
categories:
  - linux
abbrlink: 76d974f3
---
## vmcore是什么？

vmcore是指操作系统在遇到致命错误（比如内核崩溃）时所生成的内存转储文件。这个文件包含了操作系统在崩溃前的内存状态，因此可以用于诊断崩溃的原因。

在 Linux 系统中，当内核崩溃时，通常会生成一个称为vmcore的文件。该文件位于/var/crash目录下，其命名类似于vmcore.<时间戳>。vmcore文件通常是非常大的，因为它包含了操作系统在崩溃前的全部内存内容。

一般情况下，vmcore文件可以通过分析工具进行分析，以确定崩溃的原因。例如，可以使用GNU Debugger（GDB）或crash工具来分析vmcore文件。

## 手动触发vmcore的文件

vmcore文件通常是在系统遇到严重故障、例如操作系统崩溃或Panic时自动生成的，而无法手动触发。在一些情况下，我们可能需要手动触发一个vmcore文件的生成，例如在进行内核调试时。这时，可以使用kdump工具来手动触发vmcore文件的生成。

### 安装kexec-tools和kernel-debuginfo包

这里系统采用的CentOS7.9

```
# yum install yum-utils kexec-tools
# debuginfo-install kernel
```

如果 `kernel-debuginfo`安装不成功，直接下载CentOS官方下载：http://debuginfo.centos.org/7/x86_64/

```bash
curl -o kernel-debuginfo-$(uname -r).rpm http://debuginfo.centos.org/7/x86_64/kernel-debuginfo-$(uname -r).rpm
curl -o kernel-debuginfo-common-x86_64-$(uname -r).rpm http://debuginfo.centos.org/7/x86_64/kernel-debuginfo-common-x86_64-$(uname -r).rpm
rpm -ivh kernel-debuginfo-common-x86_64-$(uname -r).rpm
rpm -ivh kernel-debuginfo-$(uname -r).rpm
```

在使用kdump之前，需要先安装kexec-tools和kernel-debuginfokernel-debuginf包，它们可以通过Linux发行版的软件包管理器来安装。

### 配置kdump

可以使用命令 `systemctl status kdump`来检查kdump是否已经安装并启用。

如果没有启用，需要编辑/etc/default/grub文件并添加以下行：

```bash
RUB_CMDLINE_LINUX_DEFAULT="crashkernel=auto rd.lvm.lv=<rootvg>/<rootlv>"
```

其中 `<rootvg>`和 `<rootlv>`是根分区的名称。

保存并关闭文件后，执行以下命令以重新生成grub.cfg文件：

```bash
# grub2-mkconfig -o /boot/grub2/grub.cfg
```

### 启用kdump服务

执行以下命令以启用kdump服务：

```bash
# systemctl enable kdump
# systemctl start kdump
```

### 手动生成vmcore文件

要手动生成vmcore文件，可以使用以下命令：

```bash
# echo 1 > /proc/sys/kernel/sysrq
# echo c > /proc/sysrq-trigger
```

这将触发系统崩溃，并在/var/crash目录下生成一个vmcore文件。可以使用crash工具或其他工具来分析vmcore文件以诊断问题。

需要注意的是，生成vmcore文件需要一定的时间和系统资源，因此建议在空闲时段进行操作，并确保系统有足够的磁盘空间来存储生成的vmcore文件。

### 配置core dump大小限制

`ulimit -c unlimited` 命令用于设置当前用户在发生崩溃或者程序异常退出时所产生的 core dump 文件的最大大小限制。如果将其设置为 `unlimited`，则表示没有限制，即允许生成任意大小的 core dump 文件。

需要注意的是，`ulimit` 命令只会在当前的 shell 会话中生效。如果要在整个系统中永久性地修改 core dump 文件大小限制，可以将相应的配置写入 `/etc/security/limits.conf` 文件中。例如：

```bash
* soft core unlimited
* hard core unlimited
```

## 调试vmcore dump文件

### 使用crash工具分析vmcore文件

crash是一个用于分析vmcore文件的强大工具，可以用来诊断操作系统故障和性能问题。可以使用以下命令安装crash：

```bash
# yum install crash
```

然后可以使用以下命令来打开vmcore文件并启动crash工具：

```bash
crash /path/to/vmcore /usr/lib/debug/lib/modules/$(uname -r)/vmlinux
```

其中 `/path/to/vmcore`是vmcore文件的路径，`/usr/lib/debug/lib/modules/$(uname -r)/vmlinux`是当前正在运行的内核镜像的路径。

一旦打开了crash工具，就可以使用各种命令来分析vmcore文件，例如 `bt`命令可以显示进程的调用堆栈，`ps`命令可以显示进程列表，`mem`命令可以显示内存使用情况等等。

### 使用gdb工具分析vmcore文件

除了crash工具外，还可以使用gdb工具来分析vmcore文件。gdb是一个用于调试和分析程序的强大工具，可以用于分析操作系统崩溃的原因和调用堆栈等信息。可以使用以下命令安装gdb：

```bash
yum install gdb
```

然后可以使用以下命令来打开vmcore文件并启动gdb工具：

```bash
gdb /usr/lib/debug/lib/modules/$(uname -r)/vmlinux /path/to/vmcore
```

一旦打开了gdb工具，就可以使用各种命令来分析vmcore文件，例如 `bt`命令可以显示进程的调用堆栈，`info proc`命令可以显示进程列表，`info mem`命令可以显示内存使用情况等等。

### crash常用的命令

1、bt命令

backtrace打印内核栈回溯信息，bt pid 打印指定进程栈信息

```bash
crash> bt 832
PID: 832    TASK: ffff974f77b63150  CPU: 0   COMMAND: "vector"
 #0 [ffff974f7367fc28] __schedule at ffffffffaad8057a
 #1 [ffff974f7367fcb0] schedule at ffffffffaad80a29
 #2 [ffff974f7367fcc0] futex_wait_queue_me at ffffffffaa712086
 #3 [ffff974f7367fd00] futex_wait at ffffffffaa712e2b
 #4 [ffff974f7367fe48] do_futex at ffffffffaa714b76
 #5 [ffff974f7367fed8] sys_futex at ffffffffaa715090
 #6 [ffff974f7367ff50] system_call_fastpath at ffffffffaad8dede
    RIP: 00007fbc3d51cb43  RSP: 00007ffe3cede1f0  RFLAGS: 00010246
    RAX: 00000000000000ca  RBX: 00007fbc3d51caa5  RCX: 0000000000000000
    RDX: 0000000000000001  RSI: 0000000000000080  RDI: 00007fbc3df64930
    RBP: 0000000000000080   R8: 0000000000000070   R9: 00007fbc3df64910
    R10: 0000000000000000  R11: 0000000000000212  R12: 0000000000000001
    R13: 00007fbc3df64930  R14: 00007fbc38002080  R15: 00007fbc38002000
    ORIG_RAX: 00000000000000ca  CS: 0033  SS: 002b
```

2、log命令

打印vmcore所在的系统内核dmesg日志信息

```bash
crash> log
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Initializing cgroup subsys cpuacct
[    0.000000] Linux version 3.10.0-1062.12.1.el7.x86_64 (mockbuild@kbuilder.bsys.centos.org) (gcc version 4.8.5 20150623 (Red Hat 4.8.5-39) (GCC) ) #1 SMP Tue Feb 4 23:02:59 UTC 2020
[    0.000000] Command line: BOOT_IMAGE=/vmlinuz-3.10.0-1062.12.1.el7.x86_64 root=/dev/mapper/centos-root ro crashkernel=auto rd.lvm.lv=centos/root rd.lvm.lv=centos/swap rhgb quiet LANG=en_US.UTF-8
[    0.000000] Disabled fast string operations
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009ebff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009ec00-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000dc000-0x00000000000fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000007fedffff] usable
[    0.000000] BIOS-e820: [mem 0x000000007fee0000-0x000000007fefefff] ACPI data
[    0.000000] BIOS-e820: [mem 0x000000007feff000-0x000000007fefffff] ACPI NVS
[    0.000000] BIOS-e820: [mem 0x000000007ff00000-0x000000007fffffff] usable
[    0.000000] BIOS-e820: [mem 0x00000000f0000000-0x00000000f7ffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fec00000-0x00000000fec0ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fee00000-0x00000000fee00fff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fffe0000-0x00000000ffffffff] reserved
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.4 present.
[    0.000000] DMI: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 12/12/2018
[    0.000000] Hypervisor detected: VMware
```

3、ps命令

ps 打印内核崩溃时，正常的进程信息，带 > 标识代表是活跃的进程，ps pid打印某指定进程的状态信息

```bash
crash> bt 832
PID: 832    TASK: ffff974f77b63150  CPU: 0   COMMAND: "vector"
 #0 [ffff974f7367fc28] __schedule at ffffffffaad8057a
 #1 [ffff974f7367fcb0] schedule at ffffffffaad80a29
 #2 [ffff974f7367fcc0] futex_wait_queue_me at ffffffffaa712086
 #3 [ffff974f7367fd00] futex_wait at ffffffffaa712e2b
 #4 [ffff974f7367fe48] do_futex at ffffffffaa714b76
 #5 [ffff974f7367fed8] sys_futex at ffffffffaa715090
 #6 [ffff974f7367ff50] system_call_fastpath at ffffffffaad8dede
    RIP: 00007fbc3d51cb43  RSP: 00007ffe3cede1f0  RFLAGS: 00010246
    RAX: 00000000000000ca  RBX: 00007fbc3d51caa5  RCX: 0000000000000000
    RDX: 0000000000000001  RSI: 0000000000000080  RDI: 00007fbc3df64930
    RBP: 0000000000000080   R8: 0000000000000070   R9: 00007fbc3df64910
    R10: 0000000000000000  R11: 0000000000000212  R12: 0000000000000001
    R13: 00007fbc3df64930  R14: 00007fbc38002080  R15: 00007fbc38002000
    ORIG_RAX: 00000000000000ca  CS: 0033  SS: 002b
```

4、file命令

files pid 打印指定进程所打开的文件信息

```bash
crash> files 832
PID: 832    TASK: ffff974f77b63150  CPU: 0   COMMAND: "vector"
ROOT: /    CWD: /
 FD       FILE            DENTRY           INODE       TYPE PATH
  0 ffff974f7761b300 ffff974f7950db00 ffff974f7a3b0850 CHR  /dev/null
  1 ffff974f7761b100 ffff974f7957f740 ffff974f7954ad30 SOCK UNIX
  2 ffff974f7761b100 ffff974f7957f740 ffff974f7954ad30 SOCK UNIX
  3 ffff974f6dab5b00 ffff974f7582fec0 ffff974f7951b090 UNKN [eventpoll]
  4 ffff974f6dab4900 ffff974f73a1fbc0 ffff974f7951b090 UNKN [eventfd]
  5 ffff974f6dab5b00 ffff974f7582fec0 ffff974f7951b090 UNKN [eventpoll]
  6 ffff974f6dab4500 ffff974f75856fc0 ffff974f35c1e6b0 SOCK UNIX
  7 ffff974f6dab5d00 ffff974f758f9800 ffff974f35c18a30 SOCK UNIX
  8 ffff974f6dab4500 ffff974f75856fc0 ffff974f35c1e6b0 SOCK UNIX
  9 ffff974f6dab5400 ffff974f75ab1380 ffff974f75a8b9d0 FIFO
 10 ffff974f6dab7700 ffff974f75ab1380 ffff974f75a8b9d0 FIFO
 11 ffff974f6dab4700 ffff974f75ab1800 ffff974f75a8bc20 FIFO
 12 ffff974f6dab5200 ffff974f75ab1800 ffff974f75a8bc20 FIFO
 13 ffff974f6dab4100 ffff974f75ab18c0 ffff974f75a8be70 FIFO
 14 ffff974f6dab4200 ffff974f75ab18c0 ffff974f75a8be70 FIFO
 15 ffff974f6dab6000 ffff974f75ab1980 ffff974f75a8c0c0 FIFO
 16 ffff974f6dab5f00 ffff974f75ab1980 ffff974f75a8c0c0 FIFO
 17 ffff974f60b45e00 ffff974f61e6bd40 ffff974f61e99bb0 SOCK TCP
 18 ffff974f60b47f00 ffff974f61db6900 ffff974f61e99e30 SOCK TCP
```

5、vm命令

vm pid 打印某指定进程当时虚拟内存基本信息

```bash
crash> vm 832
PID: 832    TASK: ffff974f77b63150  CPU: 0   COMMAND: "vector"
       MM               PGD          RSS    TOTAL_VM
ffff974f3615abc0  ffff974f736b0000  73656k  206980k
      VMA           START       END     FLAGS FILE
ffff974f6356d518 7fbc31f38000 7fbc31f3a000 8000070
ffff974f6356d6c8 7fbc31f3a000 7fbc32140000 8100073
ffff974f6356d440 7fbc32140000 7fbc32142000 8000070
ffff974f6356d878 7fbc32142000 7fbc32348000 8100073
ffff974f6356d5f0 7fbc32348000 7fbc3234a000 8000070
ffff974f6356da28 7fbc3234a000 7fbc32550000 8100073
ffff974f6356d7a0 7fbc32550000 7fbc32552000 8000070
ffff974f6356de60 7fbc32552000 7fbc32758000 8100073
ffff974f6356d950 7fbc32758000 7fbc3275a000 8000070
ffff974f6356dcb0 7fbc3275a000 7fbc32960000 8100073
ffff974f6356db00 7fbc32960000 7fbc32962000 8000070
ffff974f69324d80 7fbc32962000 7fbc32b68000 8100073
ffff974f6356dd88 7fbc32b68000 7fbc32b6a000 8000070
ffff974f69324ca8 7fbc32b6a000 7fbc32d70000 8100073
ffff974f69324bd0 7fbc32d70000 7fbc32ff0000 8200073
ffff974f69324510 7fbc32ff0000 7fbc32ff2000 8000070
ffff974f69324360 7fbc32ff2000 7fbc331f8000 8100073
```

6、task命令

task 查看当前进程或指定进程task_struct和thread_info的信息

```bash
crash> task 832
PID: 832    TASK: ffff974f77b63150  CPU: 0   COMMAND: "vector"
struct task_struct {
  state = 1,
  stack = 0xffff974f7367c000,
  usage = {
    counter = 2
  },
  flags = 1077944320,
  ptrace = 0,
  wake_entry = {
    next = 0x0
  },
  on_cpu = 0,
  last_wakee = 0xffff974f76cbe2a0,
  wakee_flips = 100,
  wakee_flip_decay_ts = 4294674675,
  wake_cpu = 0,
  on_rq = 0,
  prio = 120,
  static_prio = 120,
  normal_prio = 120,
  rt_priority = 0,
  sched_class = 0xffffffffaae1e3c0,
  se = {
    load = {
      weight = 1024,
      inv_weight = 4194304
    },
    run_node = {
      __rb_parent_color = 1,
      rb_right = 0x0,
      rb_left = 0x0
    },
```
