---
title: CentOS7安装基于BPF的bcc-tools系统性能工具库
categories: [linux]
tags: [linux,bcc,bpf,系统]
---
# 准备

* OS版本：CentOS7.6.1810
* Kernel：5.4.207-1.el7.elrepo.x86_64
* ```
  # 内核依赖包
  rpm -qa | grep kernel-lt
  kernel-lt-tools-5.4.207-1.el7.elrepo.x86_64
  kernel-lt-tools-libs-5.4.207-1.el7.elrepo.x86_64
  kernel-lt-devel-5.4.207-1.el7.elrepo.x86_64
  kernel-lt-5.4.207-1.el7.elrepo.x86_64
  kernel-lt-headers-5.4.207-1.el7.elrepo.x86_64
  ```

# 安装

内核必须升级到4.x版本以上，才可以使用。我的内核版本已经升级过，具体升级内核过程这里不展开，建议使用[elrepo](http://elrepo.org/tiki/HomePage) 安装高版本内核。

```
# 安装bcc-tools
yum install -y bcc-tools
# 添加环境变量
export PATH=$PATH:/usr/share/bcc/tools
# 测试
# cachestat
    HITS   MISSES  DIRTIES HITRATIO   BUFFERS_MB  CACHED_MB
   11224        0        0  100.00%            1      61258
   10865        0        0  100.00%            1      61259
    5021        0        0  100.00%            1      61259
    4403        0        0  100.00%            1      61259
   12214        0        0  100.00%            1      61259
   26951        0        0  100.00%            1      61259
```

# FAQ

1、安装后执行命令报错

```
# cachestat
modprobe: FATAL: Module kheaders not found.
chdir(/lib/modules/5.4.207-1.el7.elrepo.x86_64/build): No such file or directory
Traceback (most recent call last):
  File "/usr/share/bcc/tools/cachestat", line 96, in <module>
    b = BPF(text=bpf_text)
  File "/usr/lib/python2.7/site-packages/bcc/__init__.py", line 325, in __init__
    raise Exception("Failed to compile BPF text")
Exception: Failed to compile BPF text
```

原因是由于kernel-devel 版本不一致导致的，建议下载跟操作系统内核版本对齐。

```
# 可以yum安装
yum install "kernel-devel-$(uname -r)"
# 或者下载对应内核版本rpm包安装
# 下载地址：http://mirrors.coreix.net/elrepo-archive-archive/kernel/el7/x86_64/RPMS/
rpm -ivh kernel-lt-devel-5.4.207-1.el7.elrepo.x86_64.rpm
```

2、执行命令报错

```

In file included from /virtual/main.c:2:
In file included from /lib/modules/5.4.207-1.el7.elrepo.x86_64/build/include/uapi/linux/ptrace.h:143:
In file included from /lib/modules/5.4.207-1.el7.elrepo.x86_64/build/arch/x86/include/asm/ptrace.h:5:
/lib/modules/5.4.207-1.el7.elrepo.x86_64/build/arch/x86/include/asm/segment.h:266:2: error: expected '(' after 'asm'
        alternative_io ("lsl %[seg],%[p]",
        ^
/lib/modules/5.4.207-1.el7.elrepo.x86_64/build/arch/x86/include/asm/alternative.h:240:2: note: expanded from macro 'alternative_io'
        asm_inline volatile (ALTERNATIVE(oldinstr, newinstr, feature)   \
        ^
/lib/modules/5.4.207-1.el7.elrepo.x86_64/build/include/linux/compiler_types.h:214:24: note: expanded from macro 'asm_inline'
#define asm_inline asm __inline
                       ^
1 error generated.
Traceback (most recent call last):
  File "/usr/share/bcc/tools/cachestat", line 96, in <module>
    b = BPF(text=bpf_text)
  File "/usr/lib/python2.7/site-packages/bcc/__init__.py", line 325, in __init__
    raise Exception("Failed to compile BPF text")
Exception: Failed to compile BPF text
```

这个是由于内核版本的原因，kernel-5.4.X之后才会出现该问题。内核头文件中用 asm 替换 asm_inline即可，具体参考BCC官方[issues](https://github.com/iovisor/bcc/issues/2546)

```
 vim /lib/modules/5.4.207-1.el7.elrepo.x86_64/build/arch/x86/include/asm/segment.h 在最上新增如下内核，保存并退出

#ifdef asm_inline
#undef asm_inline
#define asm_inline asm
#endif

```
