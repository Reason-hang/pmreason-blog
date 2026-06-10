# 版本号规范

PMReason 博客使用 Git commit + Git tag 双层版本。

## Tag 格式

```text
blog-YYYYMMDD-HHMMSS-bj-shortsha
```

示例：

```text
blog-20260610-213000-bj-690544e
```

| 字段 | 说明 |
|---|---|
| `blog` | 项目标识 |
| `YYYYMMDD` | 北京日期 |
| `HHMMSS` | 北京时间 |
| `bj` | Beijing timezone |
| `shortsha` | 7 位 Git commit ID |

## 提交说明格式

建议使用：

```text
type: 简短说明
```

常用类型：

| 类型 | 用途 |
|---|---|
| `post` | 新增或修改文章 |
| `docs` | 文档 |
| `style` | 样式 |
| `deploy` | 部署配置 |
| `backup` | 备份清单或恢复脚本 |
| `fix` | 修复问题 |

示例：

```text
post: 新增产品方法论文章
docs: 优化新手一键恢复指南
backup: 生成博客长期基线备份
```

## 回滚规则

查看版本：

```bash
git tag --sort=-creatordate
```

回滚到指定版本：

```bash
git checkout blog-YYYYMMDD-HHMMSS-bj-shortsha
bash scripts/restore.sh
```

确认没问题后，如果要让 `main` 也回到这个版本：

```bash
git checkout main
git reset --hard blog-YYYYMMDD-HHMMSS-bj-shortsha
git push --force-with-lease
```

`git reset --hard` 会丢弃当前工作区改动，只在确认要回滚主线时使用。

