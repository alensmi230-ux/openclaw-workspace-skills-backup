---
name: nanobanana-image-edit
description: Generate, edit, restyle, and composite images through Gemini-compatible image APIs using a local provider-aware runtime. Use when Codex needs to create an image from text, modify an existing image, apply a style from one image to another, combine multiple reference images, or generate slides, banners, thumbnails, and social assets. Trigger on requests like "edit this image", "change the background", "combine these images", "create a hero image", or "make a consistent slide set".
---

# Nanobanana Image Edit

This skill now uses a **local Python runtime** that talks directly to **Gemini-compatible provider endpoints**. It does **not** require the upstream nanobanana binary for API calls.

## Current provider setup

Local provider config file:

- `/home/node/.openclaw/workspace/.openclaw/local/nanobanana-providers.json`

Default provider:

- `vectorengine`

Configured alternates:

- `yinli`

## Quick start

Check provider and local runtime status:

```bash
/home/node/.openclaw/workspace/skills/nanobanana-image-edit/scripts/check-nanobanana.sh
```

Generate from text with the default provider:

```bash
/home/node/.openclaw/workspace/skills/nanobanana-image-edit/scripts/nanobanana.sh \
  -o /tmp/hero.png \
  "hero image for an AI product landing page, dark gradient, premium SaaS aesthetic"
```

Use a specific provider:

```bash
/home/node/.openclaw/workspace/skills/nanobanana-image-edit/scripts/nanobanana.sh \
  --provider yinli -o /tmp/alt.png \
  "clean product banner, soft studio lighting, modern minimal background"
```

## Important behavior

- The runtime sends requests **directly to the configured provider URL** in Google/Gemini-compatible format.
- It supports image input, multi-image composition, aspect ratio, and image size.
- **Default aspect behavior is `auto`**: if you do not specify `-aspect`, the runtime omits `aspectRatio` and lets the provider/model decide. This better matches official Gemini behavior.
- **Default size behavior is also `auto`**: if you do not specify `-size`, the runtime omits `imageSize` and lets the provider/model decide.

## Core commands

### Generate from text

```bash
/home/node/.openclaw/workspace/skills/nanobanana-image-edit/scripts/nanobanana.sh \
  -aspect 16:9 -size 2K -o /tmp/hero.png \
  "hero image for an AI workspace, dark navy gradient, subtle glow, premium startup visual"
```

### Edit an existing image

```bash
/home/node/.openclaw/workspace/skills/nanobanana-image-edit/scripts/nanobanana.sh \
  -i /path/to/input.png -o /tmp/edited.png \
  "change the background to a warm sunset, keep the subject and framing unchanged"
```

### Combine multiple images

```bash
/home/node/.openclaw/workspace/skills/nanobanana-image-edit/scripts/nanobanana.sh \
  -i /path/to/background.png -i /path/to/subject.png -o /tmp/composite.png \
  "place the subject naturally into the scene, match lighting and perspective"
```

### Keep style consistent across a set

```bash
# Create a template first
/home/node/.openclaw/workspace/skills/nanobanana-image-edit/scripts/nanobanana.sh \
  -aspect 16:9 -size 2K -o /tmp/template.png \
  "presentation slide template, dark blue gradient, elegant glowing separators"

# Reuse the template as a style reference
/home/node/.openclaw/workspace/skills/nanobanana-image-edit/scripts/nanobanana.sh \
  -i /tmp/template.png -aspect 16:9 -size 2K -o /tmp/slide-01.png \
  "using this style, create a title slide for Q4 business review"
```

## Options

### Provider selection

- Omit `--provider` to use the configured default provider.
- Use `--provider <name>` to switch providers for one call.

### Aspect ratio

Supported explicit values:

- `1:1`, `1:4`, `1:8`, `2:3`, `3:2`, `3:4`, `4:1`, `4:3`, `4:5`, `5:4`, `8:1`, `9:16`, `16:9`, `21:9`

Special value:

- `auto` → omit `aspectRatio` from the request and let the provider/model decide

### Size

Supported explicit values:

- `512px`, `1K`, `2K`, `4K`

Special value:

- `auto` → omit `imageSize` from the request and let the provider/model decide

## Prompting rules

- Be specific about **subject**, **background**, **style**, **lighting**, and **composition**.
- For edits, explicitly say what to **keep unchanged**.
- For multi-image work, specify the role of each input image.
- For batches, build one good template and reuse it.
- Prefer `16:9` for slides and banners, `1:1` for square social posts, `9:16` for story/vertical outputs.

Read `references/editing-patterns.md` for editing and composition examples.
Read `references/prompting-guide.md` for prompt patterns and size/aspect recommendations.

## Operating notes

- Provider credentials are stored in the local config file, not in the skill docs.
- This skill is designed for **Gemini-compatible** endpoints, not necessarily Google's own base URL.
- When the user provides source images, write outputs to `/tmp/` or the workspace, then return/send the generated file.
- **QQ/qqbot note**: when sending a generated local image back with `<qqimg>`, use the **absolute path** to the **actual saved file**. Do not use a relative path. Do not assume the requested output extension survived unchanged: providers may return a different mime type, and the runtime may auto-correct `.jpg` to `.png` or similar. Send the final saved path, not the originally requested filename.
- If the user wants multiple variants, generate them one at a time and keep filenames distinct.
- Prefer smaller sizes first unless the user explicitly needs a large export.

## References

- Editing and composition patterns: `references/editing-patterns.md`
- Prompting and aspect guidance: `references/prompting-guide.md`
- Local implementation notes: `references/source-notes.md`
