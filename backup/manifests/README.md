# 备份清单

`scripts/backup.sh` 会在 `backup/manifests/generated/` 下生成每次备份的清单。

清单包含：

| 字段 | 说明 |
|---|---|
| `time_bj` | 北京时间 |
| `summary` | 本次备份说明 |
| `branch` | 当前分支 |
| `head_before` | 备份前提交 |
| `hugo` | Hugo 版本 |
| `posts` | 文章数量 |
| `static_files` | 静态文件数量 |
| `assets_files` | 资源文件数量 |
| `tracked_files` | Git 跟踪文件列表 |

这些清单是小文本文件，可以提交到 GitHub，方便以后确认某个版本包含了哪些内容。
