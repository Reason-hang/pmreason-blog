# PMReason Blog

PMReason 是一个个人技术博客，用来沉淀产品、软硬件研发、AI、工程实践和个人思考。

当前站点使用 Hugo + PaperMod 构建，源码保存在 GitHub 私有仓库，GitHub Actions 自动构建后通过 SSH 部署到 VPS。

## 当前信息

| 项目 | 内容 |
|---|---|
| 站点地址 | https://pmreason.top |
| 技术栈 | Hugo 0.147.0 + PaperMod |
| 文章目录 | `content/posts/` |
| 静态资源目录 | `static/` |
| 自定义样式 | `assets/css/extended/theme.css` |
| 自定义模板 | `layouts/` |
| GitHub Actions | `.github/workflows/deploy.yml` |
| VPS 部署目录 | `/home/hermes/blog/public/` |
| Nginx 配置备份 | `deploy/nginx/pmreason.nginx.conf` |

## 仓库定位

这个仓库是博客源码的唯一真相源，适合保存可审计、可 diff、可回滚的小文件。

## 5 个分层架构和对应内容

PMReason 博客按“源码可回滚、媒体可迁移、部署可复现、密钥不裸奔、恢复有入口”的原则分成 5 层。GitHub 私有仓库主要保存第 1 层、第 2 层的小文件、第 3 层的脱敏配置和第 5 层文档；大媒体和密钥凭证不直接明文放入仓库。

| 层级 | 层名 | 对应内容 | 备份方式 | 恢复方式 |
|---|---|---|---|---|
| Layer 1 | 博客源码层 | Markdown 文章、Hugo 配置、PaperMod 主题引用、自定义模板、自定义样式、文章 archetype | 明文提交到 GitHub 私有仓库，使用 commit/tag 回滚 | `git clone` 后执行 `git submodule update --init --recursive` 和 `hugo --minify` |
| Layer 2 | 媒体资产层 | favicon、头像、首页 Banner、小封面、文章轻量配图；后续的大图片、视频、原始素材单独管理 | 小文件进 Git；大文件不进 Git，后续迁移到对象存储、NAS、移动硬盘或加密快照 | 小文件随仓库恢复；大文件按媒体清单从外部存储拉回或改用 CDN URL |
| Layer 3 | 部署运行层 | GitHub Actions、Nginx 配置、VPS 部署目录、Cloudflare 域名/CDN/Tunnel 说明、Hugo 构建版本 | 脱敏配置和说明进 Git；真实 Secret 只放 GitHub Secrets、Cloudflare 后台或 VPS 本地环境 | `scripts/restore.sh` 构建并同步到 `/home/hermes/blog/public/`，必要时复制 `deploy/nginx/pmreason.nginx.conf` |
| Layer 4 | 凭证密钥层 | GitHub Deploy Key、SSH 私钥、Cloudflare Token、R2/S3 Key、后台密码、API Token | 不明文进 Git；只记录变量名、用途和恢复说明；必要时用 age/sops 加密后备份到独立位置 | 先恢复密钥到 GitHub Secrets、Cloudflare 或 VPS 环境，再执行部署/恢复脚本 |
| Layer 5 | 恢复治理层 | README、RESTORE、VERSIONING、备份清单、恢复检查清单、版本记录、脚本使用说明 | 明文进 Git，随每次重要改动更新 | 新机器按 README/RESTORE 操作，按检查清单确认首页、文章、RSS、搜索、图片和 Nginx 都正常 |

| 内容 | 是否放入本仓库 | 说明 |
|---|---:|---|
| Markdown 文章 | 是 | `content/posts/` |
| Hugo 配置 | 是 | `hugo.toml` |
| 主题引用 | 是 | `themes/PaperMod` submodule |
| 自定义模板/样式 | 是 | `layouts/`、`assets/` |
| 小图标、小封面、小头像 | 是 | `static/` |
| 构建产物 `public/` | 否 | 可重新构建 |
| 大图片、视频、原始素材 | 否 | 后续放对象存储或离线备份 |
| `.env`、私钥、Token | 否 | 只放 GitHub Secrets 或本地加密备份 |

## 日常写文章

新建文章：

```bash
hugo new content/posts/文章标题.md
```

本地预览：

```bash
hugo server -D --bind 0.0.0.0
```

发布：

```bash
git add .
git commit -m "post: 新文章标题"
git push
```

推送到 `main` 后，GitHub Actions 会自动构建并部署到 VPS。

## 一键检查

提交前建议执行：

```bash
bash scripts/verify.sh
```

它会检查 Hugo、Git、主题 submodule、构建结果、RSS、搜索 JSON 和关键页面。

## 一键备份

文章、配置或样式更新后执行：

```bash
bash scripts/backup.sh "V1.0: 更新文章和恢复文档"
```

脚本会执行检查、生成备份清单、提交并打标签。版本号格式：

```text
blog-YYYYMMDD-HHMMSS-bj-shortsha
```

## 一键恢复

新 VPS 或回滚时，先克隆仓库：

```bash
git clone git@github.com:Reason-hang/pmreason-blog.git
cd pmreason-blog
bash scripts/restore.sh
```

详细步骤见 [RESTORE.md](RESTORE.md)。

## 恢复完成检查清单

| 检查项 | 验证方式 |
|---|---|
| 首页可访问 | `curl -I https://pmreason.top/` 返回 200/301/302 |
| 文章页可访问 | 打开任意 `/posts/.../` 页面 |
| RSS 正常 | `curl -I https://pmreason.top/index.xml` |
| 搜索索引正常 | `curl -I https://pmreason.top/index.json` |
| 图片正常显示 | 打开首页 Hero、头像、favicon |
| Hugo 构建成功 | `bash scripts/verify.sh` 无错误 |
| Nginx 配置有效 | `sudo nginx -t` |
| GitHub Actions 成功 | GitHub 仓库 Actions 页面显示绿色 |
| 部署目录存在 | `ls /home/hermes/blog/public/` |

## 备份记录

| 提交 | 版本说明概述 | 北京时间 |
|---|---|---|
| `690544e` | 旧 README：月度备份记录格式 | 2026-06-10 前 |
| `b39ba91` | 新架构：新手恢复文档 + backup/restore/verify 脚本 + Nginx 归档 | 2026-06-10 |
| `本次提交` | README 增加 5 个分层架构和对应内容 | 2026-06-11 |
