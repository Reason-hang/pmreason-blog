# PMReason Blog 备份标准操作说明

本文档给后续 AI、agent 或人工操作者使用，用于规范 `Reason-hang/pmreason-blog` 的后续备份、验证、提交和恢复记录。执行时必须优先保护源码完整性、密钥安全和可回滚性。

## 1. 仓库定位

`pmreason-blog` 是 PMReason 个人博客源码的唯一真相源，负责保存 Hugo 静态博客的文章、配置、主题引用、自定义模板、轻量静态资源、部署配置和恢复说明。它不是大媒体仓库，也不是密钥仓库。

| 层级 | 内容 | 处理原则 |
|---|---|---|
| Layer 1 博客源码层 | `content/`、`hugo.toml`、`.gitmodules`、主题引用、文章模板 | 明文提交，必须可 diff、可回滚 |
| Layer 2 媒体资产层 | favicon、头像、Banner、小封面、轻量文章配图 | 小文件可进 Git，大视频和原始素材禁止进 Git |
| Layer 3 部署运行层 | GitHub Actions、Nginx 备份、部署路径、Cloudflare 说明 | 脱敏后提交，真实 Secret 不进仓库 |
| Layer 4 凭证密钥层 | Deploy Key、SSH 私钥、Cloudflare Token、API Key | 禁止明文提交，只记录变量名和恢复说明 |
| Layer 5 恢复治理层 | README、RESTORE、VERSIONING、备份清单、脚本 | 明文提交，保持新手可执行 |

## 2. 执行前检查

```bash
git status --short --branch
git remote -v
git submodule status --recursive
hugo version
```

执行前必须确认工作区没有不明来源改动。如果发现已有改动，不要覆盖或回滚，先阅读改动内容并判断是否属于本次备份范围。

## 3. 禁止提交内容

| 类型 | 例子 | 处理方式 |
|---|---|---|
| 密钥 | `.env`、SSH 私钥、Cloudflare Token、GitHub Token | 放 GitHub Secrets、Cloudflare 后台或本地加密备份 |
| 构建产物 | `public/`、`.hugo_build.lock` | 不提交，可重新构建 |
| 大媒体 | `.mp4`、`.mov`、`.psd`、`.fig`、大 zip | 后续放 R2/S3/NAS/restic，仓库只放清单 |
| 私密素材 | 未公开照片、账号截图、后台截图 | 不直接提交，必要时脱敏 |

## 4. 标准备份流程

1. 拉取最新代码：

```bash
git checkout main
git pull --ff-only
git submodule update --init --recursive
```

2. 新增或更新文章、配置、轻量静态资源和文档。

3. 执行验证：

```bash
bash scripts/verify.sh
```

4. 执行备份脚本，生成清单、提交和标签：

```bash
bash scripts/backup.sh "docs: describe this backup"
```

5. 推送主分支和标签：

```bash
git push origin main
git push origin --tags
```

## 5. 版本号规则

正式备份标签必须使用：

```text
blog-YYYYMMDD-HHMMSS-bj-shortsha
```

示例：

```text
blog-20260611-103000-bj-50e4dd3
```

普通文档小改可以只提交，不强制打 tag；涉及文章发布、部署配置、恢复脚本、目录结构变化时必须打 tag。

## 6. 验证标准

| 检查项 | 命令或方式 |
|---|---|
| Hugo 构建成功 | `bash scripts/verify.sh` |
| 首页可访问 | `curl -I https://pmreason.top/` |
| RSS 可访问 | `curl -I https://pmreason.top/index.xml` |
| 搜索索引可访问 | `curl -I https://pmreason.top/index.json` |
| 主题完整 | `git submodule status --recursive` |
| 无大文件误入库 | `find . -path ./.git -prune -o -type f -size +50M -print` |
| 无明显密钥 | `git grep -nE "ghp_|github_pat_|BEGIN OPENSSH PRIVATE KEY|OPENAI_API_KEY|SECRET|TOKEN|PASSWORD" -- .` 后人工判断 |

## 7. 恢复演练

恢复演练必须从 fresh clone 开始：

```bash
git clone git@github.com:Reason-hang/pmreason-blog.git /tmp/pmreason-blog-restore-test
cd /tmp/pmreason-blog-restore-test
git submodule update --init --recursive
bash scripts/restore.sh
```

演练结束后检查 `public/index.html`、`public/index.xml`、`public/index.json` 是否生成，并确认线上站点未被意外破坏。

## 8. Agent 执行规则

AI/agent 只能修改与本次备份目标有关的文件，不得重写无关历史，不得提交密钥，不得把 `public/` 或大媒体塞进 Git。每次执行后必须在最终回复中给出提交 SHA、标签名、验证结果和未完成风险。

