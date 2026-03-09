---
name: playwright-browser
description: Operate Chromium through Playwright for public webpages and local web apps. Use when Codex needs to open a URL, search a site, click buttons, fill forms, inspect rendered DOM, play a video, capture screenshots, or debug browser behavior. Prefer this skill for requests like "打开这个网页", "点进去截图", "用 playwright 操作浏览器", "看一下这个页面", "搜一下再点开", or "测试本地 webapp".
---

# Playwright Browser

Use this skill for browser automation that needs a real rendered page.

Prefer the bundled scripts as black boxes:

- `/home/node/.openclaw/workspace/skills/playwright-browser/scripts/check-playwright.sh` — report runtime, browser, and font status
- `/home/node/.openclaw/workspace/skills/playwright-browser/scripts/ensure-playwright.sh` — install or repair the no-root Playwright runtime
- `/home/node/.openclaw/workspace/skills/playwright-browser/scripts/playwright.sh` — run Playwright CLI with the correct libraries/fonts loaded
- `/home/node/.openclaw/workspace/skills/playwright-browser/scripts/node-playwright.sh` — run Node commands/scripts with the same runtime

## Quick decision tree

1. **Known URL + simple screenshot** → use `scripts/playwright.sh screenshot ...`
2. **Multi-step interaction or unknown selectors** → write a short Node Playwright script and run it with `scripts/node-playwright.sh`
3. **Chinese / emoji text renders as boxes** → run `scripts/ensure-playwright.sh`, then re-test
4. **Dynamic or JS-heavy page** → use reconnaissance first, then act
5. **Login, posting, purchases, or credentials** → ask before proceeding

## Quick start

### Check the runtime

```bash
/home/node/.openclaw/workspace/skills/playwright-browser/scripts/check-playwright.sh
```

### Install or repair the runtime

```bash
/home/node/.openclaw/workspace/skills/playwright-browser/scripts/ensure-playwright.sh --smoke
```

This runtime is designed for the current workspace without root access. It installs Debian browser libraries and CJK/emoji fonts into the workspace, then installs Playwright locally for Node scripts.

### Capture a page screenshot

```bash
/home/node/.openclaw/workspace/skills/playwright-browser/scripts/playwright.sh screenshot --browser=chromium "https://example.com" /home/node/.openclaw/workspace/output/example.png
```

### Run a custom Node automation script

```bash
/home/node/.openclaw/workspace/skills/playwright-browser/scripts/node-playwright.sh node /abs/path/to/script.js
```

## Operating rules

- Prefer `domcontentloaded` first; add `networkidle` for JS-heavy pages when useful.
- Use a reconnaissance-then-action pattern on dynamic sites: render, inspect, then click/type.
- Prefer extracting useful `href` values from the rendered page over brittle blind clicking.
- For video tasks, mute and call `play()` on the `<video>` element, then verify playback state before screenshotting.
- Save screenshots under `/home/node/.openclaw/workspace/output/` unless a better location is requested.
- If a site-specific popup blocks actions, close the smallest obvious popup instead of introducing aggressive hacks.
- Do not claim a page loaded correctly until you have either a screenshot, DOM evidence, or an explicit state check.

## Common pitfalls

- Missing system libraries: Chromium starts and then exits immediately.
- Missing CJK/emoji fonts: page loads, but titles or labels render as boxes.
- Misleading font checks: prefer explicit `Noto Sans CJK SC` / `Noto Color Emoji` checks over generic aliases when debugging.
- Clicking too early: DOM changes after hydration and selectors disappear.
- Requiring `playwright` from Node without the runtime wrapper: module resolution or font setup may differ.

## References

- Read `references/workflows.md` for task selection, search→open, video playback, and rendering fixes.
- Read `references/node-patterns.md` for short Node Playwright snippets and debugging patterns.
