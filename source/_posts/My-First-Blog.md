---
title: My-First-Blog
date: 2021-06-22 10:46:14
tags:
---
**dlv**专业调试Go语言的一款工具。

安装：

```
go get -u github.com/go-delve/delve/cmd/dlv
```

配置：

```
export GOROOT=/usr/lib/golang
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
```

使用：

1、dlv debug xxx.go 指定需要debug的文件

2、进入dlv交互式窗口后，b : 指定断点

3、r arg 指定运行参数

4、n 执行一行

5、c 运行至断点或程序结束
