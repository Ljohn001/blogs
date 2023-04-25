---
title: Linux系统平均负载过高内存的转储文件vmcore分析
tags: [linux,内核,vmcore,crash,gdb]
categories: [linux]
---
内核coredump分析

> crash分析vmcore内存转储文件参考：https://www.ljohn.cn/2023/02/28/linux-shi-yong-crash-fen-xi-vmcore-dump-wen-jian/



通过 crash 命令 "foreach bt > bt.log"获得所有进程的堆栈信息。根据 jbd2 关键字过滤进程，主要有以下几类：

1、内核的 Journal 线程阻塞等待在jbd2_journal_commit_transaction函数

```bash

# crash /var/crash/127.0.0.1-2023-04-14-14\:41\:25/vmcore /usr/lib/debug/lib/modules/$(uname -r)/vmlinux
WARNING: kernel relocated [588MB]: patching 87301 gdb minimal_symbol values

      KERNEL: /usr/lib/debug/lib/modules/3.10.0-1160.11.1.el7.x86_64/vmlinux
    DUMPFILE: /var/crash/127.0.0.1-2023-04-14-14:41:25/vmcore  [PARTIAL DUMP]
        CPUS: 64
        DATE: Fri Apr 14 14:54:59 2023
      UPTIME: 265 days, 18:15:40
LOAD AVERAGE: 8014.48, 8010.96, 7991.18
       TASKS: 71817
    NODENAME: SHTL165002027
     RELEASE: 3.10.0-1160.11.1.el7.x86_64
     VERSION: #1 SMP Fri Dec 18 16:34:56 UTC 2020
     MACHINE: x86_64  (2300 Mhz)
      MEMORY: 511.6 GB
       PANIC: "SysRq : Trigger a crash"
         PID: 227456
     COMMAND: "bash"
        TASK: ffff89da9e094200  [THREAD_INFO: ffff8a112094c000]
         CPU: 19
       STATE: TASK_RUNNING (SYSRQ)

# 获得所有进程的堆栈信息
crash> foreach bt > bt.log

# 根据bt.log 文件可以查询jbd2进程堆栈信息
PID: 1436   TASK: ffff89ee1e34b180  CPU: 53  COMMAND: "jbd2/dm-2-8"
 #0 [ffff89edeb353c08] __schedule at ffffffffa63868a7
 #1 [ffff89edeb353c98] schedule at ffffffffa6386dc9
 #2 [ffff89edeb353ca8] jbd2_journal_commit_transaction at ffffffffc0b1833c [jbd2]
 #3 [ffff89edeb353e48] kjournald2 at ffffffffc0b1ef89 [jbd2]
 #4 [ffff89edeb353ec8] kthread at ffffffffa5cc5e71
 #5 [ffff89edeb353f50] ret_from_fork_nospec_begin at ffffffffa6393ddd

# bt获取进程
crash> bt 1436
PID: 1436   TASK: ffff89ee1e34b180  CPU: 53  COMMAND: "jbd2/dm-2-8"
 #0 [ffff89edeb353c08] __schedule at ffffffffa63868a7
 #1 [ffff89edeb353c98] schedule at ffffffffa6386dc9
 #2 [ffff89edeb353ca8] jbd2_journal_commit_transaction at ffffffffc0b1833c [jbd2]
 #3 [ffff89edeb353e48] kjournald2 at ffffffffc0b1ef89 [jbd2]
 #4 [ffff89edeb353ec8] kthread at ffffffffa5cc5e71
 #5 [ffff89edeb353f50] ret_from_fork_nospec_begin at ffffffffa6393ddd

# 根据线程信息反编译
# dis -rl ffffffffc0b1833c | tail
0xffffffffc0b18314 <jbd2_journal_commit_transaction+532>:       mov    0x98(%rbx),%eax
0xffffffffc0b1831a <jbd2_journal_commit_transaction+538>:       test   %eax,%eax
0xffffffffc0b1831c <jbd2_journal_commit_transaction+540>:       je     0xffffffffc0b182c0 <jbd2_journal_commit_transaction+448>
0xffffffffc0b1831e <jbd2_journal_commit_transaction+542>:       mov    -0x118(%rbp),%rdi
0xffffffffc0b18325 <jbd2_journal_commit_transaction+549>:       movb   $0x0,(%rdi)
0xffffffffc0b18328 <jbd2_journal_commit_transaction+552>:       nopl   0x0(%rax)
0xffffffffc0b1832c <jbd2_journal_commit_transaction+556>:       mov    -0x130(%rbp),%rax
0xffffffffc0b18333 <jbd2_journal_commit_transaction+563>:       lock incl 0x4(%rax)
0xffffffffc0b18337 <jbd2_journal_commit_transaction+567>:       callq  0xffffffffa6386da0 <schedule>
0xffffffffc0b1833c <jbd2_journal_commit_transaction+572>:       mov    -0x130(%rbp),%rdi

# 从上面的查询到的代码块

```
