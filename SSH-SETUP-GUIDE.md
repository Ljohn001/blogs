# GitHub 多账号 SSH 配置完成指南

## ✅ 已完成配置

### 1. SSH 密钥生成
- ✅ **pvesphere 账号**: `~/.ssh/id_rsa_github`
- ✅ **Ljohn001 账号**: `~/.ssh/id_rsa_ljohn` (新生成)

### 2. SSH 配置文件
已更新 `~/.ssh/config`，配置了两个 GitHub 账号：
- `github-pvesphere` → pvesphere 账号
- `github-ljohn` → Ljohn001 账号

### 3. 仓库配置
- ✅ Git remote URL: `git@github-ljohn:Ljohn001/blogs.git`
- ✅ Hexo deploy 配置: `git@github-ljohn:Ljohn001/blogs.git`

## 🔑 下一步：添加公钥到 GitHub

### Ljohn001 账号的公钥

```
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDqgDIpgz7W0bu4vZ5RrvA7s9LGaP95VKtxgtQvaFudk4inQMa8X+oeo9sN4wWzqiceDkg4Txeu1gtjAwZ+Fk3oSeZ9Fa7UbNiL4+6zoXo1rn1rPa+Jp4fJTqGhcU2sRVxpd0ZHavVnETPdxaNNnqopi7aflBTElji8yf0yid6RmOGuzp1iHo2ZHbl1tJfSR+VWzjZxwM6eT9dL9i2l6y4bT0tNiIvAaBdN5jqIqD/YYZN6ZFPGoLoQg6d6NZKkb02h8hksJ5CRcPDiH/py5qjipmg/LR+nf3VkncrZsT419CE7B5h6obXTOX3rKjCwpvw6cey+aVP+WO2kEQTJKwn3E21Z5dJ39wB0O1lsZsdVIe+QgPXj29DOltEFHanL+hIcbZssGWEf8INr0KyekoCD1oV6mjQWDcuMjjwlBKO64FwGebqzn94SNDdAz2U+JbK+x/d/erh+zy32ZI1da+w3rTblzCE9aZErytzK9ln9HvT5u1VHo2g1EodNfnRFlm4JKgdeVqDAK9HHjCQQf0uTOA7FVEKcbdTnVz1IjXDdSPhTZMRT3+OHdGjgXvrIeo8ic8Lc+ecBwfY9Hj8WXbCwzBBtLTVrxkpkNL6lCqALekZKsCrR8uAT+vAf/lHQ+tKWa90bZ4acg0LzwA56aKdGBE7f9KC1LdRoSysX6lDQiw== ljohn001@github
```

### 添加步骤

1. **登录 GitHub Ljohn001 账号**
   - 访问：https://github.com/settings/keys

2. **点击 "New SSH key"**

3. **填写信息**
   - Title: `Ljohn001 - MacBook` (或其他描述性名称)
   - Key type: `Authentication Key`
   - Key: 粘贴上面的公钥内容

4. **点击 "Add SSH key"**

## 🧪 测试连接

添加公钥后，测试 SSH 连接：

```bash
# 测试 Ljohn001 账号
ssh -T git@github-ljohn

# 应该看到: Hi Ljohn001! You've successfully authenticated...
```

```bash
# 测试 pvesphere 账号
ssh -T git@github-pvesphere

# 应该看到: Hi pvesphere! You've successfully authenticated...
```

## 🚀 部署博客

测试成功后，就可以正常部署了：

```bash
# 方式 1: 使用 deploy.sh 脚本
./deploy.sh

# 方式 2: 手动部署
hexo clean && hexo generate && hexo deploy
```

## 📌 日常使用

### blogs 仓库 (Ljohn001 账号)

```bash
# 推送到 hexo 分支
git push origin hexo

# Hexo 部署（会自动推送到 main 分支）
hexo deploy
```

### pvesphere 仓库操作

对于 pvesphere 账号的其他仓库：

```bash
# 设置 remote URL
git remote set-url origin git@github-pvesphere:pvesphere/repo-name.git

# 然后正常 push
git push origin main
```

## ⚠️ 常见问题

### 如果遇到 Permission denied

1. 确认公钥已添加到正确的 GitHub 账号
2. 检查 SSH 配置：`cat ~/.ssh/config`
3. 测试连接：`ssh -Tv git@github-ljohn`

### 切换账号

只需在 git remote URL 中使用不同的 Host 别名：
- `git@github-ljohn:` → Ljohn001 账号
- `git@github-pvesphere:` → pvesphere 账号

---

*配置完成时间: 2026-01-12*
