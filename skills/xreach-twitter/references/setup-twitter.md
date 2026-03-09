# xreach setup for X/Twitter

This skill uses `xreach-cli`, the same primary method referenced by Agent Reach for advanced X access.

## What xreach is for

Use xreach for:

- searching tweets
- reading a single post
- reading a full thread
- fetching a user's recent posts
- fetching user profile data

## Fast checks

Use the local wrapper:

```bash
/home/node/.openclaw/workspace/skills/xreach-twitter/scripts/check-xreach.sh
```

Install or update the local copy:

```bash
/home/node/.openclaw/workspace/skills/xreach-twitter/scripts/ensure-xreach.sh
```

## Cookie setup

xreach works best with X cookies, especially `auth_token` and `ct0`.

### Browser extraction

```bash
/home/node/.openclaw/workspace/skills/xreach-twitter/scripts/xreach.sh auth browsers
/home/node/.openclaw/workspace/skills/xreach-twitter/scripts/xreach.sh auth extract --browser chrome --profile Default
/home/node/.openclaw/workspace/skills/xreach-twitter/scripts/xreach.sh auth check
```

### Direct token setup

```bash
/home/node/.openclaw/workspace/skills/xreach-twitter/scripts/xreach.sh auth set --auth-token "$AUTH_TOKEN" --ct0 "$CT0"
/home/node/.openclaw/workspace/skills/xreach-twitter/scripts/xreach.sh auth check
```

## Safety note

Cookie auth can trigger platform risk controls. Prefer a dedicated alt account over a primary account when guiding a user through setup.

## Useful commands

```bash
/home/node/.openclaw/workspace/skills/xreach-twitter/scripts/xreach.sh user Alens --json
/home/node/.openclaw/workspace/skills/xreach-twitter/scripts/xreach.sh tweets Alens -n 10 --json
/home/node/.openclaw/workspace/skills/xreach-twitter/scripts/xreach.sh tweet "https://x.com/user/status/123" --json
/home/node/.openclaw/workspace/skills/xreach-twitter/scripts/xreach.sh thread "https://x.com/user/status/123" --json
/home/node/.openclaw/workspace/skills/xreach-twitter/scripts/xreach.sh search "query" --type latest -n 10 --json
```

## Source notes

Distilled from:

- `agent_reach/channels/twitter.py`
- `agent_reach/guides/setup-twitter.md`
- `agent_reach/skill/SKILL.md`
