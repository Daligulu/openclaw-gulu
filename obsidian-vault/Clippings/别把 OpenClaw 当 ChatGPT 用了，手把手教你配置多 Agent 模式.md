---
title: "别把 OpenClaw 当 ChatGPT 用了，手把手教你配置多 Agent 模式"
source: "https://mp.weixin.qq.com/s/_9ERlECVFOd4CsTDXvmIfw"
author:
  - "[[AI工具进化论]]"
published:
created: 2026-02-28
description: "很多人装上 OpenClaw 后，只是把它当成另一个 ChatGPT、DeepSeek 或豆包来用。这其实挺"
tags:
  - "clippings"
---
原创 AI工具进化论 *2026年2月19日 23:17*

很多人装上 OpenClaw 后，只是把它当成另一个 ChatGPT、DeepSeek 或豆包来用。这其实挺可惜的，你只用到了它最基础的能力。

OpenClaw 真正强大的地方在于 **多 Agent 能力** 。同一个 OpenClaw 可以有多个分身，每个分身都有独立的工作目录、身份设定、记忆和 Skill，并且可以高度自定义。

我现在已经创建了 **五六个 Agent** ，分别负责不同的工作。今天把其中最成熟的一个，写作工作 Agent，分享给大家，带你快速从零搭建一个子 Agent。

![图片](https://mmbiz.qpic.cn/mmbiz_png/ofvKmnZC1iaLAm6ibYXuq5msu5C3kI9KRyicTDxS9H7r1TSjMzU8PI6WvIbxxxSVHTPy43b7Pib4iauQBzsnK1AaA06BP42kUowG4YPRfrMWJeXE/640?wx_fmt=png&from=appmsg&watermark=1&tp=webp&wxfrom=5&wx_lazy=1#imgIndex=0)

## 🤔 为什么要用多 Agent

有些人为了实现类似需求，可能会去新建两个飞书机器人或者创建多个 Telegram Bot。这种操作成本其实挺高的。

用 OpenClaw 的多 Agent 模式，最简单：

1. 拉一个群，把 Bot 拉进去
2. 创建一个子 Agent，并将它绑定到当前的群聊

这样这个 Agent 就在该群内工作，上下文非常独立，专门的事情可以在专门的群里完成。

而且你可以在群里设定无需「@」它就能工作。直接在群里说话，Agent 就能做出响应。这种模式下，你交代工作或执行任务时就不会乱。 **每一个群就像是一个员工或助理** ，整体效率更高，不容易错乱，而且支持多任务并行。

![多 Agent 协作概念图](https://mp.weixin.qq.com/s/www.w3.org/2000/svg'%20xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg%20stroke='none'%20stroke-width='1'%20fill='none'%20fill-rule='evenodd'%20fill-opacity='0'%3E%3Cg%20transform='translate(-249.000000,%20-126.000000)'%20fill='%23FFFFFF'%3E%3Crect%20x='249'%20y='126'%20width='1'%20height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E "多 Agent 协作概念图")

## 🛠️ 创建子 Agent 的完整流程

### 太长不看版本

复制这篇文章，发给你的 OpenClaw bot，让它帮你创建

然后让 bot 告诉你需要配合做什么事情。

### 第一步：创建子 Agent

最简单的方式，用 CLI 命令。

```
openclaw agents add writer --workspace ~/openclaw-workspace-writer
```

这会自动创建配置和工作空间。如果你想手动配置，编辑 `~/.openclaw/openclaw.json` ，在 `agents.list` 中添加：

```
{
  "id": "writer",
  "name": "写作助手",
  "workspace": "/path/to/writer-workspace",
  "skills": ["vibe-writing", "wechat-publisher"]
}
```

### 第二步：配置群聊

创建一个群聊，把 Bot 拉进去。群名就叫「写作」「开发」这种，一看就知道干什么的。

### 第三步：绑定群 ID

在群里发一句话（比如「Hi」），然后回到主 Agent，让它帮你查日志找到群 ID。

找到后，编辑配置文件，添加绑定：

```
{
  "id":"writer",
"bindings":[{
    "channelId":"telegram",
    "chatId":"-1001234567890",
    "mentionless":true
}]
}
```

`mentionless: true` 就是开启无需 @ 的功能。

### 第四步：重启生效

重启 Gateway 使配置生效。

```
systemctl --user restart openclaw-gateway
```

去群里说话，Agent 响应了就说明成功了。

![配置流程示意图](https://mp.weixin.qq.com/s/www.w3.org/2000/svg'%20xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg%20stroke='none'%20stroke-width='1'%20fill='none'%20fill-rule='evenodd'%20fill-opacity='0'%3E%3Cg%20transform='translate(-249.000000,%20-126.000000)'%20fill='%23FFFFFF'%3E%3Crect%20x='249'%20y='126'%20width='1'%20height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E "配置流程示意图")

## 💡 进阶配置：独立模型

每个子 Agent 都能独立配置模型。重要任务用 **Claude Sonnet 4.6** ，实验性的用便宜模型。

顺便推荐一个便宜大碗的 Claude API：https://aicodewith.com/zh/login?tab=register&invitation=Q71I6P （点击阅读原文可跳转注册） <sup><span>[1]</span></sup>

**稳定，只有官方的 1.9 折，支持最新的 Claude Sonnet 4.6 模型** 。我现在把这个作为主力 API，性价比很高。

配置示例：

```
{
  "id": "writer",
  "model": {
    "primary": "anthropic/claude-sonnet-4-6"
  }
}
```

整体来讲，这是一种非常经济高效的做法。

## 📦 一个 Agent 到底是什么

在 OpenClaw 里，一个 Agent 不只是一个名字，它是一个完整的隔离单元。

- **Workspace** ：独立的工作目录，包含 AGENTS.md、SOUL.md、USER.md 等人格文件和记忆文件
- **Session Store** ：独立的会话存储，位于 `~/.openclaw/agents/<agentId>/sessions/`
- **Skills** ：可以配置专属的技能集
- **Model** ：可以指定不同的模型
- **Identity** ：名字、emoji、头像，在 IM 端可以展示不同身份

Agent 之间默认完全隔离，不共享会话历史，不共享认证凭据。

## ✨ 我的实践经验

我现在有 **五六个 Agent** ，每个都有明确的分工。

- **写作 Agent** ：负责公众号文章、博客写作，配置了 vibe-writing 和 wechat-publisher 技能。
	（完整的自动化写作工作流：下次单独写文章分享，每天 AI 自动写文章、排版、配图，发布到微信公众号后台，我只需要审核发布即可。
![图片](https://mp.weixin.qq.com/s/www.w3.org/2000/svg'%20xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg%20stroke='none'%20stroke-width='1'%20fill='none'%20fill-rule='evenodd'%20fill-opacity='0'%3E%3Cg%20transform='translate(-249.000000,%20-126.000000)'%20fill='%23FFFFFF'%3E%3Crect%20x='249'%20y='126'%20width='1'%20height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)
- **开发 Agent** ：负责写代码、调试，工作目录在项目文件夹
- **研究 Agent** ：负责信息搜索、资料整理
- **实验 Agent** ：用便宜模型做一些测试性的工作

每个 Agent 都在独立的群里工作，互不干扰。我交代任务时，直接去对应的群里说就行，不会搞混。

而且因为上下文独立，每个 Agent 的记忆都很清晰。写作 Agent 记得我的写作风格和素材库，开发 Agent 记得项目的技术栈和架构。

## 总结

OpenClaw 的多 Agent 模式，本质上是让你用一个工具，管理多个专业助理。

配置流程总结。

1. 创建子 Agent（CLI 命令最简单）
2. 创建群聊，把 Bot 拉进去
3. 绑定群 ID，开启 mentionless
4. 重启 Gateway 生效

这样你就有了一个专门的 Agent，在专门的群里，做专门的事。

**效率会高很多，也不容易乱。**

**试试看吧。**

---

如果这篇文章对你有帮助，请随手点赞、在看、转发三连，可以让更多小伙伴看到；如果你想第一时间收到推送，也可以给我一个星标⭐️，感谢你的支持。

![读者群二维码](https://mp.weixin.qq.com/s/www.w3.org/2000/svg'%20xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg%20stroke='none'%20stroke-width='1'%20fill='none'%20fill-rule='evenodd'%20fill-opacity='0'%3E%3Cg%20transform='translate(-249.000000,%20-126.000000)'%20fill='%23FFFFFF'%3E%3Crect%20x='249'%20y='126'%20width='1'%20height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E "读者群二维码")

---

**关于作者**

Ben，ALL in AI 出海

- 前字节 PM
- WaytoAGI 从 1-10 策划人，AI 编程区主理人
- AI 编程实践者，上线了 30+ 产品
- 个人网站：https://benx.ai <sup><span>[2]</span></sup>

### 引用链接

\[1\] *https://aicodewith.com/zh/login?tab=register&invitation=Q71I6P*

\[2\] *https://benx.ai*

[阅读原文](https://mp.weixin.qq.com/s/)

继续滑动看下一个

AI工具进化论

向上滑动看下一个