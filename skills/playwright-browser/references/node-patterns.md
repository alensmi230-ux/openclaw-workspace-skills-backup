# Node Playwright Patterns

## Minimal page-open template

```js
const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage({ viewport: { width: 1280, height: 720 } });
  await page.goto('https://example.com', { waitUntil: 'domcontentloaded', timeout: 60000 });
  await page.waitForLoadState('networkidle').catch(() => {});
  await page.screenshot({ path: '/home/node/.openclaw/workspace/output/example.png' });
  await browser.close();
})();
```

Run it with:

```bash
/home/node/.openclaw/workspace/skills/playwright-browser/scripts/node-playwright.sh node /abs/path/to/script.js
```

## Collect candidate links from a rendered page

```js
const links = await page.locator('a[href*="/video/"]').evaluateAll(nodes =>
  nodes.map(a => a.href || a.getAttribute('href')).filter(Boolean)
);
```

Normalize `//...` URLs before navigation.

## Video autoplay nudge

```js
await page.evaluate(async () => {
  const v = document.querySelector('video');
  if (!v) return null;
  v.muted = true;
  try { await v.play(); } catch {}
  return { paused: v.paused, currentTime: v.currentTime, readyState: v.readyState };
});
```

## Debugging checklist

- Take a screenshot before and after the action
- Log candidate hrefs before navigating
- Print player state (`paused`, `currentTime`, `readyState`) for video tasks
- Prefer role/text selectors first; fall back to CSS only when needed
- If DOM is still changing, wait a bit longer or wait for a stable selector instead of fixed rapid clicks
