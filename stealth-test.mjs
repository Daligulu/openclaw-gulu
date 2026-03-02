/**
 * Stealth Browser Template - playwright-bot-bypass
 * 基于 greekr4/playwright-bot-bypass 项目
 * 使用 rebrowser-playwright 绕过 bot 检测
 */
import { chromium } from 'rebrowser-playwright';

async function stealthBrowser(url) {
  const browser = await chromium.launch({
    headless: true,
    args: [
      '--no-sandbox',
      '--disable-setuid-sandbox',
      '--disable-dev-shm-usage',
    ]
  });

  const context = await browser.newContext({
    userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36',
    viewport: { width: 1280, height: 800 },
  });

  const page = await context.newPage();

  // Remove webdriver property
  await page.addInitScript(() => {
    Object.defineProperty(navigator, 'webdriver', { get: () => undefined });
  });

  await page.goto(url, { waitUntil: 'domcontentloaded', timeout: 30000 });
  
  const title = await page.title();
  const webdriver = await page.evaluate(() => navigator.webdriver);
  
  console.log(`Title: ${title}`);
  console.log(`navigator.webdriver: ${webdriver}`);
  
  await browser.close();
  return { title, webdriver };
}

// Export for use as module
export { stealthBrowser };

// Run if called directly
if (process.argv[1] === new URL(import.meta.url).pathname) {
  const url = process.argv[2] || 'https://example.com';
  stealthBrowser(url).then(result => {
    console.log('Result:', result);
  }).catch(console.error);
}
