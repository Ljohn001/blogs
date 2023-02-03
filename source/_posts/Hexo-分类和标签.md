---
title: Hexo 分类和标签
date: 2021-11-08 11:15:02
tags: [hexo,blog]
categories: [hexo]

---

### **一、主题配置打开**

打开`themes/next/_config.yml` **主题配置文件** 找到`Menu Settings` ，把 `categories` 和 `tags` 取消注释。

```bash
tags: /tags/ || fa fa-tags
categories: /categories/ || fa fa-th
```
<!--more-->
## 二、添加分类模块

新建一个分类页面。
`$ hexo new page categories`
你会发现你的source文件夹下有了categories\[index.md](http://index.md/)，打开index.md文件将 title 设置为title: 分类 

把文章归入分类只需在文章的顶部标题下方添加categories字段，即可自动创建分类名并加入对应的分类中

## 三、添加标签模块

新建一个标签页面 。
`$ hexo new page tags`
你会发现你的source文件夹下有了tags\[index.md](http://index.md/)，打开index.md文件将 title 设置为title: 标签 
把文章添加标签只需在文章的顶部标题下方添加tags字段，即可自动创建标签名并归入对应的标签中 

## **四、修改 [index.md](http://index.md/) 文件**

打开 `categories` 文件夹下的 `index.md` ，在最下面一行加一行文字就行，注意中间有空格。

```bash
---
title: tags
date: 2021-11-08 10:47:33
type: categories
---
```

同理，`tags` 也是如此。

## **五、效果展示**

![Untitled](https://www.notion.so/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2Fa09cb93c-83ec-4922-aa88-0099b188004d%2FUntitled.png?table=block&id=d0b3c0ae-9ace-4cd9-b464-fd7f0457e3ff&spaceId=06ecef21-3e7b-477c-b390-8768131a1226&width=2000&userId=6268f095-2b48-4979-9b0b-e6e1a111ccd1&cache=v2)
