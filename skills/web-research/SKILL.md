---
name: web-research
description: >
  Search the web, inspect links, and gather online information with lightweight,
  low-dependency methods. Use when a user asks to search online, look something
  up on the internet, inspect a URL, summarize a webpage, research a topic,
  check GitHub repositories/issues, read Reddit or article pages, or compare
  search results from multiple sources. Triggers include: "上网搜", "帮我查",
  "查一下这个链接", "搜索网页", "全网搜索", "research", "look this up",
  "inspect this URL", "summarize this page", "search GitHub", "search Reddit".
---

# Web Research

Prefer the lightest source that can answer the question.

## Priority order

1. **Direct URL provided** → fetch and summarize the page.
2. **GitHub-specific request** → use `gh` CLI when available.
3. **General web/article page** → use Jina Reader mirror via `https://r.jina.ai/http://...` or `https://r.jina.ai/http://...`.
4. **Reddit/basic public JSON endpoints** → use direct JSON endpoints with a user-agent.
5. **If the first source is weak** → cross-check with a second source.

## Direct page reading

Use `curl` through the shell tool:

```bash
curl -LfsS "https://r.jina.ai/http://example.com"
curl -LfsS "https://r.jina.ai/http://example.com/article"
```

Notes:
- Replace `https://` URLs as `https://r.jina.ai/http://...` and `http://` URLs as `https://r.jina.ai/http://...` only if needed after normalization.
- If Jina Reader fails, fall back to raw page fetch and extract what is still readable:

```bash
curl -LfsS "https://example.com"
```

## Simple web search

No guaranteed general search API is bundled. Use targeted sources first:

- GitHub topics/repos/code via `gh`
- Reddit JSON search for Reddit discussions
- Known site search endpoints when the user names a site
- If the user gives candidate links, inspect those directly

Be explicit when a true broad web search engine is unavailable.

## GitHub

```bash
gh repo view owner/repo
gh search repos "query" --limit 10 --sort stars
gh search issues "query repo:owner/repo" --limit 10
gh issue list -R owner/repo --state open
```

Use GitHub first for:
- repo summaries
- stars/forks/issues activity
- README / issue / PR inspection
- code search

## Reddit

```bash
curl -LfsS "https://www.reddit.com/search.json?q=QUERY&limit=10" -H "User-Agent: web-research/1.0"
curl -LfsS "https://www.reddit.com/r/SUBREDDIT/hot.json?limit=10" -H "User-Agent: web-research/1.0"
```

Notes:
- Some server IPs may get 403. Say so plainly if blocked.
- Prefer summaries over dumping raw JSON.

## Research workflow

For non-trivial questions:

1. Clarify the target if the query is ambiguous.
2. Gather 2–3 relevant sources.
3. Summarize the answer first.
4. Then list supporting links or caveats.
5. Distinguish observed facts from inference.

## Safety and honesty

- Do not claim broad internet access if a source was not actually fetched.
- Say when a page is blocked, JavaScript-heavy, or only partially readable.
- Do not fabricate search results.
- Ask before using user-provided credentials or API keys.

## Optional upgrades

If the user wants stronger search coverage, ask for permission/details before setting up:
- Exa or other search API key
- Agent Reach or other multi-source CLI scaffolding
- Cookies for sites that require login
- Proxy for sites that block server IPs
