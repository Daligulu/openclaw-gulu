---
title: "OpenClaw 多 Agent 玩法，我的AI 团队越来越壮大了！"
source: "https://mp.weixin.qq.com/s/K2XJ42FhRx1SS5C-jmndiQ"
author:
  - "[[彭少]]"
published:
created: 2026-02-28
description:
tags:
  - "clippings"
---
彭少 *2026年2月21日 23:51*

**点击上方卡片关注我**

**设置星标 学习更多AI出海知识**

我的 Telegram 里最近多了好多群。一个群跟龙虾聊日常事务，一个群专门让写作助手润色文章，还有一个群让资讯助手收集行业信息。这些群背后是同一个 Bot，只是按任务拆成了不同的 Agent。

之前所有事情都堆在一个 session 里，写文章的对话和日常闲聊混在一起，聊着聊着上下文就串了，记忆也越来越臃肿。拆开之后各管各的，干净多了。

这是 OpenClaw 原生支持的多 Agent 方案，一个实例内配多个 Agent，通过路由规则把不同群组分配给不同 Agent，比跑多个进程轻量。

加上我本来就配了好几个实例，现在每个实例还能再拆 Agent，相当于手上有了一支可以持续扩编的 AI 团队。

[有了这8个AI员工，直接原地起飞！](https://mp.weixin.qq.com/s?__biz=Mzg3NzU2NjY3OQ==&mid=2247490488&idx=1&sn=8618d2810aa185821e922c0479813e03&scene=21#wechat_redirect)

## 多实例 vs 多 Agent

简单说一下这两种方式的差异。

多实例的优势是容灾能力强，一个实例挂了，另一个可以主动修复，不需要人为干预。缺点是每个实例都要单独启动、监控、更新，服务器资源占用也更多。

单实例多 Agent 的优势是轻量，一个进程、一个端口，配置集中管理。但如果进程挂了，所有 Agent 一起挂。

两层不冲突。建议保留多实例做容灾基础，在单个实例内部再用多 Agent 做任务细分。

多实例 vs 单实例多 Agent 架构对比

## Agent 隔离机制

在 OpenClaw 里，一个 Agent 不只是一段 prompt。每个 Agent 有自己的工作目录（SOUL.md、USER.md、skills 都在这里）、自己的状态目录（session 数据、记忆文件，按 agentId 自动隔离）、自己的对话历史。即使两个 Agent 在同一个 Telegram bot 下运行，它们的记忆也是完全分开的。

这种隔离是物理级别的，不同 Agent 的记忆存储在不同的目录和数据库文件里，不会互相污染。

## 实操：全部让龙虾帮我配

拿我的一个实例来说，一个 Telegram bot 专门负责内容营销，日常沟通就交给主 Agent，公众号写作交给写作助手，资讯收集交给另一个助手。

配置 Agent 自己要做的事情很简单：建 Telegram 群，把 bot 拉进去，然后把群 ID 告诉主 Agent。剩下的配置工作全部交给龙虾完成。

龙虾会为每个 Agent 创建独立的工作目录，写入各自的 SOUL.md 定义人格（写作助手专注润色文章，资讯助手专注信息收集），在 openclaw.json 里注册 Agent 列表和路由规则（bindings），把群组加入白名单并设置为不需要 @ 就能响应。

OpenClaw 也提供了命令行向导 openclaw agents add，可以自动处理目录结构和基础配置，不过让龙虾来做的好处是它能根据你的描述直接把 SOUL.md 和路由规则一步到位写好。

这个过程有几个点值得记录一下。

**第一个是 Telegram bot 的 Group Privacy 模式。**

默认开启的情况下，bot 在群里只能看到 @ 它的消息，普通消息收不到。需要去 @BotFather 发 /setprivacy，选 Disable 关掉。改完之后要把 bot 从群里移除再重新拉进来，Telegram 要求重新入群才能让新设置生效。

还有一个替代方案：直接把 bot 设为群管理员，管理员不受 Privacy 模式限制，省去移除再拉回的操作。

**第二个是群 ID。**

从 Telegram Web 地址栏拿到的数字可以直接用，但要注意普通群和超级群的 ID 格式不同。

## Workspace 共享还是独立

这个问题我跟龙虾专门讨论了一下。结论是：workspace 共享，记忆独立。

共享 workspace 意味着写作助手能读到主 Agent 的 SOUL.md、USER.md、写作风格偏好、素材文件，不用重复维护。而写作助手的对话历史和 session 记忆不会污染主 Agent，因为状态目录（agentDir）是始终按 agentId 自动隔离的。

这样写作助手既了解我的风格和上下文，又不会因为写了 10 篇文章把主 Agent 的记忆撑爆。

如果某个 Agent 会大量创建文件（比如生成很多草稿），那就给它独立 workspace，避免文件操作干扰其他 Agent。每个 Agent 的 workspace 路径可以在 openclaw.json 里单独指定，不指定则默认共享。

## 两种交互方式

配好之后，跟子 Agent 交互有两种方式。

第一种是直接去对应的群里聊。适合长时间的协作场景，比如花一个小时跟写作助手打磨一篇文章。群组会保留完整的对话上下文，方便反复迭代。

第二种是通过主 Agent 委派。OpenClaw 支持 sessions\_spawn，主 Agent 可以把任务派给写作助手，完成后把结果回传。适合临时小任务，比如"帮我把这段口述润色一下"。

需要注意的是，目前委派层级是平的，子 Agent 不能再往下派任务，所有任务拆分都要由主 Agent 来做。

两种方式可以并存，按场景选。日常写作协作走群组直聊，临时任务走主 Agent 委派。

## 模型分配和扩编节奏

多 Agent 还有一个好处：可以按任务分配模型。需要深度思考的（写作、复杂分析）用 Claude Opus，只需要跑腿的（信息查询、格式转换）用其他大模型，成本能省不少。

不用上来就设计 10 个 Agent。先创建实例用着，哪个场景觉得该拆了就拆出来，每次加一个就行。一般 3 到 5 个 Agent 就能覆盖日常需求了。不过上限很高，我现在配了好几个实例，每个实例还可以配多个 Agent，只要场景拆得够细，这支团队可以一直扩。各自分工、各自干活、互不干扰，需要协作的时候又能通过主 Agent 串起来。

跟带团队一个道理，创业初期什么都自己干，业务复杂了就得招人分工。AI Agent 也一样，从"一人公司"到"专家团队"，是个自然的过程。如果你还没试过多 Agent，可以先从拆一个写作助手开始，这是最容易看到效果的场景。

## 加入 OpenClaw 交流群

如果你对 OpenClaw 感兴趣，或者在实践中遇到问题，欢迎加入 OpenClaw 中文交流群。

49 元入群，送 $50 aigocode.com 算力额度。群里不卖课，都是实际在用 OpenClaw 的玩家，每天分享使用技巧和踩坑经验，氛围很活跃。

一个人 + OpenClaw + aigocode = 一个小团队。

**[一天100人，我的OpenClaw群爆了！](https://mp.weixin.qq.com/s?__biz=Mzg3NzU2NjY3OQ==&mid=2247490460&idx=1&sn=7c287d1e8d7bf6c3fc72e93f83b470c8&scene=21#wechat_redirect)**

**[OpenClaw 玩法分享：搭一套推特 AI 资讯自动推送](https://mp.weixin.qq.com/s?__biz=Mzg3NzU2NjY3OQ==&mid=2247490415&idx=1&sn=b6a8dd8e50ca2d36ec02a87092bd58bd&scene=21#wechat_redirect)**

**[OpenClaw 真香！我让它每天帮我干这些活](https://mp.weixin.qq.com/s?__biz=Mzg3NzU2NjY3OQ==&mid=2247490327&idx=1&sn=84003d687dce8869dd36746a88657792&scene=21#wechat_redirect)**

**[（2026年最新）Codex CLI 国内使用全攻略：终端 + VSCode + Cursor + Opencode 四种姿势全搞定](https://mp.weixin.qq.com/s?__biz=Mzg3NzU2NjY3OQ==&mid=2247490089&idx=1&sn=0a7f51a79aea7e1f372ea9e705a1e7be&scene=21#wechat_redirect)**

**[实测 4 个爆火 Skill，一句话生成画布/知识库/任务规划/自动发布](https://mp.weixin.qq.com/s?__biz=Mzg3NzU2NjY3OQ==&mid=2247489787&idx=1&sn=dcb1baa3a3af539a26e2730ef776c161&scene=21#wechat_redirect)**

**[从海外公司注册到 Stripe 收款，跑通了出海收付款全流程（实操分享）](https://mp.weixin.qq.com/s?__biz=Mzg3NzU2NjY3OQ==&mid=2247489551&idx=1&sn=08058b274add835f37b3374fa43b6757&scene=21#wechat_redirect)**

**[出海建站必备：告别AI味，这两个页面设计 Skills 太牛了！](https://mp.weixin.qq.com/s?__biz=Mzg3NzU2NjY3OQ==&mid=2247489451&idx=1&sn=0447e337cef1e12f577b2fed72048cad&scene=21#wechat_redirect)**

**[玩转 Claude Code Hooks：让自动化渗透到每个环节](https://mp.weixin.qq.com/s?__biz=Mzg3NzU2NjY3OQ==&mid=2247489503&idx=1&sn=b81277c62e501d497b7f621e3a726b34&scene=21#wechat_redirect)**

**[出海网站实战：Stripe 支付接入，从 0 到收款全流程](https://mp.weixin.qq.com/s?__biz=Mzg3NzU2NjY3OQ==&mid=2247488496&idx=1&sn=ea69777b985c23576fe59777ab1f0da9&scene=21#wechat_redirect)**

[阅读原文](https://mp.weixin.qq.com/s/)

继续滑动看下一个

程序员章鱼哥

向上滑动看下一个