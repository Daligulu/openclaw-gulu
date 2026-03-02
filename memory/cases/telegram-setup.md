# Case-003: Telegram Bot 接入配置

## 核心步骤

| 步骤 | 关键动作 | 注意事项 |
|------|----------|----------|
| 1. 创建 Bot | @BotFather → /newbot | 保存 Token，别泄露 |
| 2. 获取 ID | @userinfobot | 记录自己的 User ID |
| 3. 编辑配置 | `~/.openclaw/openclaw.json` 的 `channels.telegram` | 键名必须准确 |
| 4. 重启服务 | MaxClaw 设置菜单点重启 | 查看日志确认生效 |

## 易错点

- ❌ `botPolicy` → ✅ `dmPolicy`
- ❌ `streaming: {partial: true}` → ✅ `streamMode: "partial"`
- 忘记重启 Gateway，配置不生效

## 完整配置示例

```json
"channels": {
  "telegram": {
    "botToken": "<your_token>",
    "dmPolicy": "pairing",
    "groupPolicy": "open",
    "streamMode": "partial",
    "groups": {
      "*": {
        "groupPolicy": "open",
        "requireMention": false
      }
    }
  }
}
```

## 群组权限说明

| 配置项 | 值 | 效果 |
|--------|----|------|
| `groupPolicy` | `"open"` | 允许进入任何群组 |
| `groupPolicy` | `"allowlist"` | 只允许白名单群组 |
| `requireMention` | `false` | 收到所有消息，自主决定是否回复 |
| `requireMention` | `true` | 只有 @ 才触发回复 |
| `groupAllowFrom` | `[uid]` | 只响应特定用户 |

## 配对流程

Bot 加入后，用户私聊 Bot 会收到配对码，需运行：
```
openclaw pairing approve telegram <code>
```

日期：2026-02-27
