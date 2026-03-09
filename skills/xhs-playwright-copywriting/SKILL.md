---
name: xhs-playwright-copywriting
description: Write Xiaohongshu/XHS copy and operate Xiaohongshu through Playwright for login, publishing, note verification, and comment replies. Use when the user asks for 小红书文案、爆款标题、图文/长文 caption、角色向发帖、看参考图学文案风格、用 Playwright 发小红书、回评论、查发布状态，或需要把本地图片/附件发布成 XHS notes.
---

# XHS Playwright Copywriting

Use this skill when the task is about either:

1. **writing Xiaohongshu-native copy**, or
2. **publishing / verifying / replying on Xiaohongshu with Playwright**.

## Workflow decision tree

- **Only need copy** → Read `references/copywriting.md`.
- **Need to publish / verify / reply** → Read `references/publish-playwright.md`.
- **Need both** → Read `references/copywriting.md` first, draft the post, then read `references/publish-playwright.md` and execute.

## Core operating rules

- Get explicit user approval before any public action: publish, delete, edit, or reply as a persona.
- If the user provides example screenshots, extract the **structure, rhythm, and hook style**; do not copy wording too literally.
- If images are likely not the user’s own original art, avoid implying authorship. Prefer wording like “分享 / 存档 / 壁纸 / 喜欢这组图” unless the user explicitly wants another framing.
- Prefer **one strong first draft** over many weak variants; then offer 2–3 directional rewrites.
- Keep XHS copy visually scannable: short paragraphs, strong first line, low-friction ending, limited hashtags.
- For QQ/other chat attachments, treat the local file paths as ready-to-upload assets for Playwright file inputs.

## What good output looks like

A solid XHS result usually includes:

- a title that can stand alone in feed previews
- a body with 1 clear emotional thread
- a reason to pause, save, or reply
- tags that are relevant, not spammy
- a publishing choice that matches the content type:
  - **上传图文** for image-led posts
  - **写长文** for pure-text or text-first posts
  - **上传视频** for video-led posts

## Preferred execution pattern

1. Identify the asset type: image set, text-only, video, comment reply, or account action.
2. Identify the desired voice: neutral sharer, character roleplay, personal diary, wallpaper account, tool/AI account.
3. Draft copy that fits Xiaohongshu reading habits.
4. If publishing is requested, choose the correct creator workflow and verify the result in note management.
5. If comments/replies are requested, answer briefly and in-character, then re-check the thread.

## References

- `references/copywriting.md` — title formulas, body patterns, hook styles, tags, character-roleplay guidance
- `references/publish-playwright.md` — current creator-platform flows, QR login workaround, publishing steps, verification, comment reply workflow
