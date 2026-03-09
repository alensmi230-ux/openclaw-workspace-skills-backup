# Public read-only fallbacks for X

Use these only when xreach auth is unavailable or overkill.

## 1. Jina Reader mirror

Good for quick page text, profile titles, and some post text.

```bash
curl -LfsS "https://r.jina.ai/http://x.com/Alens"
curl -LfsS "https://r.jina.ai/http://x.com/Alens/status/123"
```

Limitations:

- often login-walled
- incomplete for media-heavy pages
- not reliable for latest-post discovery

## 2. Nitter RSS

Sometimes useful for recent visible posts and embedded image references.

```bash
curl -LfsS "https://nitter.net/Alens/rss"
```

What it can reveal:

- recent visible posts
- timestamps
- direct image references embedded in RSS HTML

Limitations:

- instance availability is unstable
- rate limits and blocks are common
- not an official source
- may expose retweets before original posts, depending on feed order

## 3. Direct media URLs

When a public source exposes image filenames, direct media URLs may work:

```text
https://pbs.twimg.com/media/<MEDIA_ID>.jpg
https://pbs.twimg.com/media/<MEDIA_ID>.png
```

Use this only after a public source has already revealed the media ID.

## Rule of thumb

- Need dependable search/timeline/thread access → use xreach
- Need a quick public peek and auth is missing → try Jina Reader, then Nitter RSS
- Do not present public fallbacks as equivalent to authenticated X access
