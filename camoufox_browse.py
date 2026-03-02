#!/usr/bin/env python3
"""
Camoufox 浏览器自动化脚本
基于 jo-inc/camofox-browser 项目中的 Camoufox 引擎
提供 C++ 层面的指纹欺骗，无法被 JS 层检测
"""

from camoufox.sync_api import Camoufox


def stealth_browse(url: str, headless: bool = True) -> dict:
    """
    使用 Camoufox 进行隐身浏览
    
    Args:
        url: 要访问的 URL
        headless: 是否无头模式
    
    Returns:
        包含页面标题、WebDriver 状态等信息的字典
    """
    with Camoufox(headless=headless) as browser:
        page = browser.new_page()
        page.goto(url, timeout=30000)
        
        title = page.title()
        webdriver = page.evaluate("() => navigator.webdriver")
        user_agent = page.evaluate("() => navigator.userAgent")
        webgl_renderer = page.evaluate("""() => {
            const canvas = document.createElement('canvas');
            const gl = canvas.getContext('webgl');
            if (!gl) return 'no webgl';
            const ext = gl.getExtension('WEBGL_debug_renderer_info');
            return ext ? gl.getParameter(ext.UNMASKED_RENDERER_WEBGL) : 'no ext';
        }""")
        
        return {
            "title": title,
            "webdriver": webdriver,
            "user_agent": user_agent[:50] + "..." if len(user_agent) > 50 else user_agent,
            "webgl_renderer": webgl_renderer,
        }


def google_search(query: str) -> str:
    """使用 Camoufox 执行 Google 搜索，绕过 CAPTCHA"""
    url = f"https://www.google.com/search?q={query.replace(' ', '+')}"
    with Camoufox(headless=True) as browser:
        page = browser.new_page()
        page.goto(url, timeout=30000)
        # 等待搜索结果
        page.wait_for_selector('#search', timeout=10000)
        # 提取搜索结果标题
        results = page.evaluate("""() => {
            return Array.from(document.querySelectorAll('h3')).slice(0, 5).map(h => h.textContent);
        }""")
        return results


if __name__ == "__main__":
    import sys
    url = sys.argv[1] if len(sys.argv) > 1 else "https://bot.sannysoft.com"
    print(f"Testing: {url}")
    result = stealth_browse(url)
    for k, v in result.items():
        print(f"  {k}: {v}")
