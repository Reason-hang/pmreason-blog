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
| `待生成` | 新架构：新手恢复文档 + backup/restore/verify 脚本 + Nginx 归档 | 2026-06-10 |

