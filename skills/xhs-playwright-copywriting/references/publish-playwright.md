# Xiaohongshu publishing with Playwright

Use this file when the user wants to log in, publish, verify a note, inspect note status, or reply to comments on Xiaohongshu.

## 1. Pick the right publish flow

Use the creator platform:

- `https://creator.xiaohongshu.com/publish/publish?source=official`

Current web entry points:

- `上传视频` — video-led posts
- `上传图文` — image-led posts
- `写长文` — pure-text or text-first posts

### Choose like this

- **Images already provided** → use `上传图文`
- **Only text / essay / self-intro** → use `写长文`
- **Video asset** → use `上传视频`

## 2. Login best practice

In this environment, `creator.xiaohongshu.com/login` may show **SMS login only**.

If QR login is needed:

1. Open `https://www.xiaohongshu.com/explore`
2. Trigger the site login modal
3. Capture/send the QR for the user to scan
4. Reuse the authenticated browser profile for creator-platform actions

Important practical result: the login session from `www.xiaohongshu.com` carries over to the creator platform.

### Critical QR-login caveat: keep the session alive

A QR screenshot is **not enough by itself**. If you capture the QR and then close the page/browser/context, the code may still look scannable in chat but the backend login session can already be dead or expired. The user scans what looks like a valid code, but login fails.

Use this safer pattern instead:

1. Open the login modal and confirm the QR is visible.
2. **Keep that exact browser page/context running** while the user scans.
3. Send the QR image (or modal screenshot) to the user **without closing the session**.
4. Wait for either:
   - the login modal to disappear,
   - logged-in UI to appear, or
   - cookie/auth state to update.
5. Only after login is confirmed should you move on to creator actions or tear down the waiting session.

Practical rule: **do not send a QR from a one-shot script that exits immediately after screenshotting** unless another persistent watcher page is still alive and holding the same login flow open.

If the user says the QR failed, suspect one of these first:

- the QR expired naturally,
- the page/browser/context that generated it was already closed,
- the screenshot was old and not freshly generated,
- the modal switched state and the captured code no longer matched the active session.

## 3. Browser/profile best practice

Use a persistent Playwright profile directory so login survives between steps.

Example pattern:

- keep one profile directory for the XHS session
- open creator pages and public note pages from the same profile
- avoid relogging unless the session expires

## 4. 图文 note flow

Use when the user provides local images/attachments and wants a standard image post.

Reliable pattern:

1. Open creator publish page
2. Switch to `上传图文`
3. Use the hidden upload input (commonly `.upload-input`) with `setInputFiles(...)`
4. Wait for uploads and preview thumbnails
5. Fill title
6. Fill body / caption
7. Review preview panel
8. Click `发布`
9. Verify in note management

Practical notes:

- Wait generously after file upload; image processing is not instant.
- The page may auto-suggest extra hashtags. Keep or remove intentionally.
- Prefer filling body after uploads finish; UI state is more stable.

## 5. 长文 flow

Use when the user wants text-first content.

Reliable pattern discovered in practice:

1. Open publish page
2. Click `写长文`
3. Click `新的创作`
4. Fill title textarea
5. Fill the main editor (often ProseMirror / `contenteditable`)
6. Click `一键排版`
7. On the template/cover step, click `下一步`
8. On the final settings page, click `发布`
9. Verify in note management

Practical notes:

- This flow can convert text into image-like long-form pages.
- If the user says “文字配图” but only provides text, this long-form route can still produce a visually formatted result.

## 6. Verification workflow

Use note management after publishing:

- `https://creator.xiaohongshu.com/new/note-manager?source=official`

What to check:

- title appears in the list
- latest publish time matches expectations
- status is visible (`审核中`, etc.)
- view/comment counters update later

If the user wants proof, send a screenshot of note management.

## 7. Public note / comment reply workflow

For comment replies, public note pages are often easier than the creator manager UI.

Useful pattern:

1. Get the note from note management
2. Open the public note page in the same logged-in browser profile
3. Read visible comments from the page
4. Click `回复` under each relevant comment
5. Fill reply input and send
6. Re-read the thread and verify replies appeared

Reply style guidance:

- keep replies shorter than the original post
- answer as the approved persona
- do not over-explain

## 8. Debugging / advanced inspection

If the UI is hard to navigate, inspect network responses from the creator platform.

Useful internal endpoints may reveal:

- note IDs
- xsec tokens
- posted-note lists
- note detail data

Use these as debugging aids, not as the primary workflow.

## 9. Safety and quality checks

Before publishing or replying:

- confirm the user explicitly wants the public action
- confirm which assets are the real publish assets vs inspiration screenshots
- avoid implying authorship of third-party art unless the user says it is theirs
- avoid clicking `删除` or changing permissions unless explicitly requested

## 10. Minimal execution checklist

Before action:

- choose note type
- draft final copy
- confirm assets
- confirm public posting is intended

After action:

- verify in note management
- send the user a concise status update
- include a screenshot when helpful
