---
title: kubelet无法创建线程异常处理
tags: [linux,kubernetes,k8s,容器]
categories: [kubernetes]
---
## 问题描述

1、少量的应用出现OOM报错，查看pod资源开销情况发现并未出现内存溢出

2、查看kubelet异常日志发现报错如下：`pthread_create failed: Resource tmporarily unavailable`

```bash
5月 11 09:01:37 HZPL004094050 kubelet[5347]: I0511 09:01:37.778960    5347 prober.go:117] Readiness probe for "tidb-second-biz-prod-rq-55787858cf-vpgv4_pangu(fff52887-bb5f-4af9-8ba4-e3416dcd32b9):java" failed (failure): Get "http://10.6.181.96:8166/health": dial tcp 10.6.181.96:8166: connect: connection timed out
5月 11 09:01:38 HZPL004094050 kubelet[5347]: I0511 09:01:38.754255    5347 prober.go:117] Liveness probe for "calico-node-nh7n4_kube-system(213160f6-13e1-41bb-b2db-2a8a763aec67):calico-node" failed (failure): runtime/cgo: pthread_create failed: Resource temporarily unavailable
5月 11 09:01:38 HZPL004094050 kubelet[5347]: SIGABRT: abort
5月 11 09:01:38 HZPL004094050 kubelet[5347]: PC=0x7f0e6e62f37f m=0 sigcode=18446744073709551610
5月 11 09:01:38 HZPL004094050 kubelet[5347]: goroutine 0 [idle]:
5月 11 09:01:38 HZPL004094050 kubelet[5347]: runtime: unknown pc 0x7f0e6e62f37f
5月 11 09:01:38 HZPL004094050 kubelet[5347]: stack: frame={sp:0x7fff7573f1c0, fp:0x0} stack=[0x7fff74f40a48,0x7fff7573fa80)
…

5月 11 09:01:38 HZPL004094050 kubelet[5347]: goroutine 1 [runnable, locked to thread]:
5月 11 09:01:38 HZPL004094050 kubelet[5347]: bytes.(*Buffer).grow(0xc0002d0f38, 0x1, 0x0)
5月 11 09:01:38 HZPL004094050 kubelet[5347]: /usr/local/go-cgo/src/bytes/buffer.go:128 +0x238
5月 11 09:01:38 HZPL004094050 kubelet[5347]: bytes.(*Buffer).WriteByte(0xc0002d0f38, 0xc000054423, 0x0, 0x0)
5月 11 09:01:38 HZPL004094050 kubelet[5347]: /usr/local/go-cgo/src/bytes/buffer.go:267 +0x85
5月 11 09:01:38 HZPL004094050 kubelet[5347]: github.com/PuerkitoBio/urlesc.Escape(0xc0001bc000, 0xc00034a1b0, 0x2000)
5月 11 09:01:38 HZPL004094050 kubelet[5347]: /go/pkg/mod/github.com/!puerkito!bio/urlesc@v0.0.0-20170810143723-de5bf2ad4578/urlesc.go:176 +0x19a
5月 11 09:01:38 HZPL004094050 kubelet[5347]: github.com/PuerkitoBio/purell.NormalizeURL(0xc0001bc000, 0x207f, 0xc0001bc000, 0x0)
5月 11 09:01:38 HZPL004094050 kubelet[5347]: /go/pkg/mod/github.com/!puerkito!bio/purell@v1.1.1/purell.go:183 +0xbf
5月 11 09:01:38 HZPL004094050 kubelet[5347]: github.com/go-openapi/jsonreference.(*Ref).parse(0xc0002d1040, 0xc000054420, 0x17, 0x4, 0xc0001ba088)
5月 11 09:01:38 HZPL004094050 kubelet[5347]: /go/pkg/mod/github.com/go-openapi/jsonreference@v0.19.3/reference.go:117 +0x65
5月 11 09:01:38 HZPL004094050 kubelet[5347]: github.com/go-openapi/jsonreference.New(...)

```
