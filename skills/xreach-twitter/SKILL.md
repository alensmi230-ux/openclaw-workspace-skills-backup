---
name: xreach-twitter
description: Read, search, and inspect X/Twitter with xreach CLI plus cookie auth. Use when Codex needs to open an x.com/twitter.com post, fetch a user's latest posts or media, search X, read a thread, inspect replies, or configure X access from browser cookies. Prefer this skill for requests like "去 X 上看", "search X", "read tweet", "latest post", "timeline", "media", or "配置 Twitter Cookie".
---

# Xreach Twitter

Use this skill for reliable X/Twitter access.

Prefer the local wrapper script:

- `scripts/xreach.sh` — run xreach from the workspace-local install first, then fall back to any global install
- `scripts/check-xreach.sh` — report install/auth status
- `scripts/ensure-xreach.sh` — install or update workspace-local xreach

## Quick decision tree

1. **Single post URL / status URL** → use `tweet`
2. **Whole conversation / thread** → use `thread`
3. **User profile or latest posts** → use `user` or `tweets`
4. **Search on X** → use `search`
5. **Need media-heavy recent posts** → use `tweets` first; if auth is unavailable, use the public fallbacks in `references/public-fallbacks.md`
6. **Auth missing** → configure cookies via `auth extract` or `auth set`; read `references/setup-twitter.md`

## Core commands

Run the wrapper from the skill directory or via absolute path.

### Check status

```bash
/home/node/.openclaw/workspace/skills/xreach-twitter/scripts/check-xreach.sh
```

### Read one post

```bash
/home/node/.openclaw/workspace/skills/xreach-twitter/scripts/xreach.sh tweet "https://x.com/user/status/123" --json
```

### Read a thread

```bash
/home/node/.openclaw/workspace/skills/xreach-twitter/scripts/xreach.sh thread "https://x.com/user/status/123" --json
```

### Get a user profile

```bash
/home/node/.openclaw/workspace/skills/xreach-twitter/scripts/xreach.sh user Alens --json
```

### Get recent posts from a user

```bash
/home/node/.openclaw/workspace/skills/xreach-twitter/scripts/xreach.sh tweets Alens -n 10 --json
```

Add `--replies` when the user explicitly wants replies.

### Search X

```bash
/home/node/.openclaw/workspace/skills/xreach-twitter/scripts/xreach.sh search "query" --type latest -n 10 --json
/home/node/.openclaw/workspace/skills/xreach-twitter/scripts/xreach.sh search "query" --type photos -n 10 --json
/home/node/.openclaw/workspace/skills/xreach-twitter/scripts/xreach.sh search "query" --type videos -n 10 --json
```

## Authentication workflow

Use cookie auth for anything beyond brittle public scraping.

### Option 1: Extract from a local browser

```bash
/home/node/.openclaw/workspace/skills/xreach-twitter/scripts/xreach.sh auth extract --browser chrome --profile Default
/home/node/.openclaw/workspace/skills/xreach-twitter/scripts/xreach.sh auth check
```

If Chrome is not the right browser, list profiles first:

```bash
/home/node/.openclaw/workspace/skills/xreach-twitter/scripts/xreach.sh auth browsers
```

### Option 2: Set tokens directly

```bash
/home/node/.openclaw/workspace/skills/xreach-twitter/scripts/xreach.sh auth set --auth-token "$AUTH_TOKEN" --ct0 "$CT0"
/home/node/.openclaw/workspace/skills/xreach-twitter/scripts/xreach.sh auth check
```

Read `references/setup-twitter.md` before guiding a user through cookie setup.

## Operating rules

- Prefer `--json` for machine-readable output, then summarize.
- Do not claim full X access when auth is missing.
- Treat public fallbacks as partial and unstable.
- For image requests, fetch the post first, then extract the direct `pbs.twimg.com` media URLs if present.
- For large results, save raw JSON to `/tmp/` and summarize the important bits.
- If the user asks to configure cookies, warn that a dedicated alt account is safer than a primary account.

## Public fallbacks

If xreach auth is unavailable, use the lighter fallbacks in `references/public-fallbacks.md`:

- `r.jina.ai/http://x.com/...` for limited readable page text
- Nitter RSS for recent posts when available

These are useful for quick inspection, but xreach is the primary method for serious X work.

## References

- For setup and cookie guidance: `references/setup-twitter.md`
- For public read-only fallbacks: `references/public-fallbacks.md`
