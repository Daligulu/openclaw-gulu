# OpenClaw Workspace 云端备份方案（GitHub）

本文档记录了使用 GitHub 对 OpenClaw workspace 进行自动云端备份的完整配置方案，供其他 OpenClaw 实例参考和复用。

---

## 方案概述

- **备份目标**：将 `/workspace` 目录同步到 GitHub 私有仓库
- **触发方式**：每 6 小时自动执行一次（cron）
- **有变更才提交**，无变更静默跳过
- **推送失败**自动通过 Telegram 通知用户

---

## 前置准备

### 1. 创建 GitHub 私有仓库

在 GitHub 上新建一个仓库（建议设为 **Private**），例如：
```
https://github.com/<用户名>/<仓库名>
```

### 2. 生成 Personal Access Token（Classic）

路径：GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)

- 点击 **Generate new token (classic)**
- 勾选 `repo` 权限
- 生成后保存好 token（格式：`ghp_xxx...`）

---

## 配置步骤

### 步骤一：初始化 Git 仓库

```bash
cd /workspace
git init
git branch -m main
git config user.email "your@email.com"
git config user.name "你的名字"
```

### 步骤二：配置 .gitignore

在 `/workspace/.gitignore` 中排除大文件和敏感信息：

```gitignore
# 敏感配置文件
openclaw.json
*.bak
*.bak.*

# 大型目录（浏览器、虚拟环境、依赖）
playwright-browsers/
venv-ar/
venv-ar2/
venv-camou/
agent-reach-venv/
node_modules/
.uv-cache/

# 日志和临时文件
*.log
logs/
*.tmp
*.temp
__pycache__/
*.pyc

# workspace 状态
workspace-state.json
.profile

# 提取缓存
extract/raw_content/
```

> ⚠️ **重要**：`openclaw.json` 含有 API Key 和 Token，必须加入 .gitignore，不能推送到 Git。

### 步骤三：添加远程仓库

```bash
git remote add origin "https://<用户名>:<token>@github.com/<用户名>/<仓库名>.git"
```

### 步骤四：首次提交并推送

```bash
git add -A
git commit -m "初始备份"
git push -u origin main
```

---

## 自动备份脚本

创建 `/workspace/scripts/git-backup.sh`：

```bash
#!/bin/bash
# OpenClaw workspace 自动备份脚本
export GIT_DIR=/workspace/.git
export GIT_WORK_TREE=/workspace

cd /workspace

git add -A
git diff --cached --quiet && echo "无变更，跳过" && exit 0

git commit -m "自动备份 $(date '+%Y-%m-%d %H:%M')"
git push origin main && echo "备份成功" || echo "推送失败"
```

```bash
chmod +x /workspace/scripts/git-backup.sh
```

手动测试：
```bash
bash /workspace/scripts/git-backup.sh
```

---

## 配置定时任务（Cron）

通过 OpenClaw cron 工具添加定时任务（每 6 小时执行一次）：

```json
{
  "name": "Workspace 自动备份",
  "schedule": {
    "kind": "cron",
    "expr": "0 */6 * * *",
    "tz": "Asia/Shanghai"
  },
  "sessionTarget": "isolated",
  "payload": {
    "kind": "agentTurn",
    "message": "运行 /workspace/scripts/git-backup.sh 脚本，将 workspace 备份到 GitHub。如果成功输出'备份成功'或'无变更，跳过'，静默结束（回复 HEARTBEAT_OK）。如果失败，通过 Telegram 发给用户（channel=telegram, to=<用户ID>）报告错误。",
    "timeoutSeconds": 60
  },
  "delivery": {
    "mode": "announce",
    "channel": "telegram",
    "to": "<用户Telegram ID>"
  },
  "notify": false
}
```

---

## 备份内容说明

| 内容 | 路径 | 是否备份 |
|------|------|----------|
| 人格与记忆 | `SOUL.md`、`MEMORY.md`、`memory/` | ✅ |
| 工作区配置 | `AGENTS.md`、`USER.md`、`TOOLS.md` | ✅ |
| 技能文件 | `skills/` | ✅ |
| 备份脚本 | `scripts/` | ✅ |
| 主配置（含密钥）| `openclaw.json` | ❌ 排除 |
| 虚拟环境 | `venv-*/`、`node_modules/` | ❌ 排除 |
| 浏览器 | `playwright-browsers/` | ❌ 排除 |

---

## 注意事项

1. **token 安全**：Classic token 写在 remote URL 里，不要把 remote URL 泄露出去
2. **仓库设为 Private**：workspace 含有个人记忆和配置，不要用公开仓库
3. **定期验证**：偶尔手动跑一次脚本，确认备份链路正常
4. **迁移恢复**：新环境安装 OpenClaw 后，克隆仓库覆盖 workspace 即可恢复

---

## 快速复用清单

- [ ] 创建 GitHub 私有仓库
- [ ] 生成 Classic Token（repo 权限）
- [ ] `git init` + 配置 remote
- [ ] 写入 `.gitignore`
- [ ] 首次 `git push`
- [ ] 创建 `scripts/git-backup.sh` 并赋权
- [ ] 添加 cron 定时任务（每 6 小时）
- [ ] 手动测试验证

---

*本方案由咕噜 🐾 配置于 2026-03-02，适用于 OpenClaw 云端部署环境。*
