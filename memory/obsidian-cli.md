# Obsidian CLI Reference

> 学习于 2026-03-02，来源：https://help.obsidian.md/cli
> 需要 Obsidian 1.12 installer

## 基本用法

```bash
obsidian <command> [parameters]
obsidian vault=<vaultname> <command>  # 指定 vault（必须第一个参数）
```

### 全局选项
- `vault=<name>` — 指定 vault
- `--copy` — 复制输出到剪贴板

---

## 命令分类速查

### 文件操作
| 命令 | 说明 |
|------|------|
| `files` | 列出所有文件 |
| `file` | 获取文件信息 |
| `open file=<name>` | 打开文件 |
| `create name=<name>` | 创建笔记 |
| `read file=<name>` | 读取文件内容 |
| `append file=<name> content=<text>` | 追加内容 |
| `prepend file=<name> content=<text>` | 前置内容 |
| `move file=<name> to=<path>` | 移动文件 |
| `rename file=<name> name=<new>` | 重命名 |
| `delete file=<name>` | 删除文件 |

### 日记
| 命令 | 说明 |
|------|------|
| `daily` | 打开今日日记 |
| `daily:path` | 获取日记路径 |
| `daily:read` | 读取日记内容 |
| `daily:append content=<text>` | 追加到日记 |
| `daily:prepend content=<text>` | 前置到日记 |

### 搜索
| 命令 | 说明 |
|------|------|
| `search query=<text>` | 搜索 vault |
| `search:context query=<text>` | 带上下文搜索 |

### 链接分析
| 命令 | 说明 |
|------|------|
| `backlinks file=<name>` | 反向链接 |
| `links file=<name>` | 出链 |
| `orphans` | 孤立文件 |
| `unresolved` | 未解析链接 |
| `deadends` | 无出链文件 |

### 任务
| 命令 | 说明 |
|------|------|
| `tasks` | 列出任务 |
| `tasks file=<name>` | 按文件筛选 |
| `tasks status=<status>` | 按状态筛选 |

### 标签
| 命令 | 说明 |
|------|------|
| `tags` | 列出所有标签 |
| `tags counts` | 带数量 |

### 插件管理
| 命令 | 说明 |
|------|------|
| `plugins` | 列出所有插件 |
| `plugin:enable id=<id>` | 启用插件 |
| `plugin:disable id=<id>` | 禁用插件 |
| `plugin:install id=<id>` | 安装插件 |
| `plugin:reload id=<id>` | 重载插件 |

### 属性（Frontmatter）
| 命令 | 说明 |
|------|------|
| `property:read file=<name>` | 读取属性 |
| `property:set file=<name> name=<key> value=<val>` | 设置属性 |
| `property:remove file=<name> name=<key>` | 删除属性 |

### Bases
| 命令 | 说明 |
|------|------|
| `bases` | 列出所有 .base 文件 |
| `base:query file=<name> format=json` | 查询 base |
| `base:create file=<name> view=<view> name=<item>` | 创建条目 |

### Sync
| 命令 | 说明 |
|------|------|
| `sync` | 触发同步 |
| `sync:status` | 同步状态 |
| `sync:restore file=<name> timestamp=<ts>` | 恢复版本 |

### 历史版本
| 命令 | 说明 |
|------|------|
| `history:list` | 列出版本 |
| `history:read` | 读取特定版本 |
| `history:restore` | 恢复版本 |
| `diff file=<name> from=1 to=3` | 对比版本 |

### 开发者
| 命令 | 说明 |
|------|------|
| `eval code=<js>` | 执行 JavaScript |
| `dev:screenshot path=<file>` | 截图 |
| `devtools` | 开发者工具 |
| `command id=<id>` | 执行命令面板命令 |

### 工作区
| 命令 | 说明 |
|------|------|
| `workspaces` | 列出工作区 |
| `workspace:save name=<name>` | 保存工作区 |
| `workspace:load name=<name>` | 加载工作区 |
| `tabs` | 列出打开的标签页 |
| `recents` | 最近打开的文件 |

---

## 参数语法
- `parameter=value` — 普通参数
- `"多个词"` — 含空格时加引号
- `\n` — 换行，`\t` — 制表符
- 布尔 flag 直接写名称（如 `open`、`overwrite`）

## 常用示例
```bash
obsidian daily:append content="- [ ] 买菜"
obsidian search query="会议记录"
obsidian create name="旅行计划" template=Travel
obsidian tags counts
obsidian eval code="app.vault.getFiles().length"
obsidian plugin:reload id=my-plugin
obsidian vault=笔记本 daily:read
```

## TUI 模式
直接运行 `obsidian` 进入交互终端，支持：
- Tab 自动补全
- Ctrl+R 历史搜索
