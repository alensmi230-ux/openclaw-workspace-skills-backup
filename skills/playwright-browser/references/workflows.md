# Playwright Browser Workflows

## 1. Simple screenshot of a known URL

Use when the user says "open this page and screenshot it".

1. Run `scripts/check-playwright.sh`
2. If runtime/fonts are missing, run `scripts/ensure-playwright.sh --smoke`
3. Capture with:

```bash
/home/node/.openclaw/workspace/skills/playwright-browser/scripts/playwright.sh screenshot --browser=chromium "https://example.com" /home/node/.openclaw/workspace/output/example.png
```

## 2. Reconnaissance → action for JS-heavy pages

Use when selectors are unknown or the page is dynamic.

1. Open the page with `domcontentloaded`
2. Wait for `networkidle` when practical
3. Take a screenshot or inspect DOM
4. Collect candidate selectors/links from the rendered state
5. Only then click, type, or navigate again

Rule of thumb: do not blindly click before seeing what actually rendered.

## 3. Search page → first matching result

Prefer extracting result URLs over brittle pixel-clicking.

Pattern:

1. Load the search page
2. Query `a[href*="/video/"]`, `a[href*="/status/"]`, or another site-specific anchor pattern
3. Normalize `//host/path` URLs into full `https://...`
4. Navigate directly to the selected URL

This is often more stable than trying to click the first card.

## 4. Video playback screenshot

Use for Bilibili, YouTube-like players, or embedded videos.

1. Open the video page
2. Close simple popups if present
3. Click the player or play button
4. In page JS, locate `document.querySelector('video')`
5. Set `muted = true`, call `play()`, wait a few seconds
6. Verify `paused === false` and `currentTime > 0`
7. Take the screenshot

## 5. Chinese / emoji rendering issues

Symptoms: boxes, tofu, or garbled title text in screenshots.

Fix path:

1. Run `scripts/ensure-playwright.sh`
2. Re-run `scripts/check-playwright.sh`
3. Confirm `fc-match 'Noto Sans CJK SC'` or `fc-match 'sans:lang=zh-cn'` resolves to a CJK font
4. Confirm `fc-match 'Noto Color Emoji'` resolves to an emoji font
5. Re-capture the page

## 6. Safety boundaries

Ask before:

- logging into accounts with user credentials
- posting, purchasing, or submitting irreversible actions
- bypassing paywalls, captchas, or anti-bot checks

Reading public pages, navigating, inspecting DOM, and taking screenshots are normally safe.
