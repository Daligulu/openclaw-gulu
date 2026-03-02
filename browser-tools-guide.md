# Agent 浏览器绕过方案指南

## 项目1: playwright-bot-bypass (greekr4)

### 核心原理
通过 `rebrowser-playwright` 绕过 bot 检测：
1. 删除 `navigator.webdriver` 属性
2. 使用真实 Chrome User Agent（非 HeadlessChrome）
3. 真实 GPU 渲染指纹

### 安装
```bash
npm install rebrowser-playwright
```

### 使用示例
```javascript
import { chromium } from 'rebrowser-playwright';

const browser = await chromium.launch({ headless: true });
const context = await browser.newContext({
  userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) ...'
});
const page = await context.newPage();

// 关键：删除 webdriver 标记
await page.addInitScript(() => {
  Object.defineProperty(navigator, 'webdriver', { get: () => undefined });
});

await page.goto('https://target.com');
```

### 安装为 OpenClaw Skill
```bash
npx skills add greekr4/playwright-bot-bypass
```

---

## 项目2: camofox-browser (jo-inc)

### 核心原理
基于 Camoufox（Firefox C++ fork），在 JS 层之前完成指纹欺骗：
- WebGL、AudioContext、屏幕分辨率、WebRTC 全部在 C++ 层修改
- JS 根本无法检测到欺骗

### 安装方式

**作为 OpenClaw 插件（推荐）**
```bash
openclaw plugins install @askjo/camofox-browser
```

**Python 直接使用（camoufox 已安装）**
```python
from camoufox.sync_api import Camoufox

with Camoufox(headless=True) as browser:
    page = browser.new_page()
    page.goto('https://target.com')
    print(page.title())
```

### 环境状态
- ✅ `camoufox` Python 库已安装 (v135.0.1-beta.24)
- ✅ Camoufox Firefox 二进制已下载
- ⚠️  当前容器缺少 GTK3 系统库（需要 root 权限安装）

### REST API 模式（独立部署）
```bash
git clone https://github.com/jo-inc/camofox-browser
cd camofox-browser && npm install && npm start
```

API 端点示例：
```
GET  /tabs          # 列出所有标签页
POST /tabs          # 创建新标签页
GET  /tabs/{id}/snapshot  # 获取无障碍快照
POST /tabs/{id}/click     # 点击元素
POST /tabs/{id}/type      # 输入文字
```

### 搜索宏（内置）
```
@google_search <query>
@youtube_search <query>
@twitter_search <query>
```
