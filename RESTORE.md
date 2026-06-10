# PMReason 一键恢复指南

这份文档用于新 VPS、重装系统、回滚版本或本地演练时恢复博客。

## 恢复目标

恢复完成后应满足：

| 项目 | 目标 |
|---|---|
| 源码 | GitHub 仓库完整克隆 |
| 主题 | PaperMod submodule 已初始化 |
| 构建 | `hugo --minify` 成功 |
| 部署 | 静态文件同步到 `/home/hermes/blog/public/` |
| Nginx | 配置可通过 `nginx -t` |
| 站点 | `https://pmreason.top/` 可访问 |

## 新 VPS 三步恢复

### 1. 准备基础软件

Ubuntu/Debian 示例：

```bash
sudo apt update
sudo apt install -y git rsync curl nginx
```

安装 Hugo Extended 0.147.0。可以用系统包、官方 release，或你自己的运维脚本安装。安装后确认：

```bash
hugo version
```

### 2. 克隆仓库

```bash
git clone git@github.com:Reason-hang/pmreason-blog.git
cd pmreason-blog
```

如果 SSH 没权限，先在 GitHub 仓库配置 Deploy Key，或使用你自己的 GitHub SSH key。

### 3. 执行恢复脚本

```bash
bash scripts/restore.sh
```

脚本会自动：

| 步骤 | 动作 |
|---|---|
| 检查环境 | 检查 Hugo、Git、rsync、curl、nginx |
| 拉取主题 | 初始化 `themes/PaperMod` |
| 构建站点 | 执行 `hugo --minify` |
| 部署文件 | 同步 `public/` 到 `/home/hermes/blog/public/` |
| 恢复 Nginx | 提示或安装 `deploy/nginx/pmreason.nginx.conf` |
| 健康检查 | 检查首页、RSS、搜索 JSON |
| 输出结果 | 显示恢复成功或失败位置 |

## 回滚到指定版本

查看版本：

```bash
git tag --sort=-creatordate
```

切换到指定版本：

```bash
git checkout blog-YYYYMMDD-HHMMSS-bj-shortsha
bash scripts/restore.sh
```

恢复到最新版：

```bash
git checkout main
git pull
bash scripts/restore.sh
```

## 手动恢复 Nginx

如果 `restore.sh` 提示没有权限，请手动执行：

```bash
sudo cp deploy/nginx/pmreason.nginx.conf /etc/nginx/sites-available/pmreason.conf
sudo ln -sf /etc/nginx/sites-available/pmreason.conf /etc/nginx/sites-enabled/pmreason.conf
sudo nginx -t
sudo systemctl reload nginx
```

如果你的系统使用 `/etc/nginx/conf.d/`，也可以复制到：

```bash
sudo cp deploy/nginx/pmreason.nginx.conf /etc/nginx/conf.d/pmreason.conf
sudo nginx -t
sudo systemctl reload nginx
```

## 恢复完成检查清单

| 检查项 | 验证方式 |
|---|---|
| Git 仓库正常 | `git status --short --branch` |
| 主题已拉取 | `git submodule status --recursive` |
| Hugo 可用 | `hugo version` |
| 构建成功 | `bash scripts/verify.sh` |
| 部署目录存在 | `ls /home/hermes/blog/public/` |
| 首页文件存在 | `test -f /home/hermes/blog/public/index.html` |
| RSS 存在 | `test -f /home/hermes/blog/public/index.xml` |
| 搜索索引存在 | `test -f /home/hermes/blog/public/index.json` |
| Nginx 配置有效 | `sudo nginx -t` |
| Nginx 已重载 | `sudo systemctl status nginx --no-pager` |
| 线上首页可访问 | `curl -I https://pmreason.top/` |
| 文章页可访问 | 浏览器打开任意文章 |
| 图片正常显示 | 检查首页 Banner、头像、favicon |
| GitHub Actions 正常 | GitHub Actions 页面显示成功 |

## 常见问题

### Hugo 找不到主题

执行：

```bash
git submodule update --init --recursive
```

### 没有权限写入部署目录

确认目录存在并归属 `hermes`：

```bash
sudo mkdir -p /home/hermes/blog/public
sudo chown -R hermes:hermes /home/hermes/blog
```

### Nginx 访问 404

检查配置里的 root 是否等于：

```text
/home/hermes/blog/public
```

然后执行：

```bash
sudo nginx -t
sudo systemctl reload nginx
```

### GitHub Actions 部署失败

检查 GitHub Secrets：

| Secret | 用途 |
|---|---|
| `DEPLOY_KEY` | 登录 VPS 的 SSH 私钥 |
| `HOST` | VPS 公网 IP 或域名 |

不要把这些值写进仓库。

