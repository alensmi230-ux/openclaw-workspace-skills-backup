#!/usr/bin/env python3
import argparse
import base64
import json
import mimetypes
import os
import sys
import urllib.request
import urllib.error
from pathlib import Path
from typing import Dict, Any

DEFAULT_CONFIG_PATH = "/home/node/.openclaw/workspace/.openclaw/local/nanobanana-providers.json"
DEFAULT_MODEL = "gemini-3.1-flash-image-preview"
VALID_ASPECTS = {
    "auto", "1:1", "1:4", "1:8", "2:3", "3:2", "3:4", "4:1", "4:3",
    "4:5", "5:4", "8:1", "9:16", "16:9", "21:9"
}
VALID_SIZES = {"auto", "512px", "1K", "2K", "4K"}


def err(msg: str, code: int = 1):
    print(f"Error: {msg}", file=sys.stderr)
    sys.exit(code)


def load_provider_config() -> Dict[str, Any]:
    cfg_path = os.environ.get("NANOBANANA_PROVIDER_CONFIG", DEFAULT_CONFIG_PATH)
    p = Path(cfg_path)
    if not p.exists():
        err(f"provider config not found: {cfg_path}")
    try:
        return json.loads(p.read_text())
    except Exception as e:
        err(f"failed to parse provider config {cfg_path}: {e}")


def choose_provider(cfg: Dict[str, Any], provider_name: str | None) -> tuple[str, Dict[str, Any]]:
    providers = cfg.get("providers") or {}
    if not providers:
        err("provider config has no providers")
    name = provider_name or os.environ.get("NANOBANANA_PROVIDER") or cfg.get("default_provider")
    if not name:
        err("no provider selected and no default_provider configured")
    if name not in providers:
        err(f"provider '{name}' not found in config")
    prov = providers[name]
    if not prov.get("base_url") or not prov.get("api_key"):
        err(f"provider '{name}' is missing base_url or api_key")
    return name, prov


def build_endpoint(base_url: str, model: str) -> str:
    base = base_url.rstrip("/")
    if base.endswith(":generateContent"):
        return base
    if "/v1beta/models/" in base:
        return f"{base}:generateContent"
    return f"{base}/v1beta/models/{model}:generateContent"


def load_image_part(path: str) -> Dict[str, Any]:
    p = Path(path)
    if not p.exists():
        err(f"input image not found: {path}")
    mime, _ = mimetypes.guess_type(str(p))
    if not mime:
        mime = "application/octet-stream"
    data = base64.b64encode(p.read_bytes()).decode("ascii")
    return {"inlineData": {"mimeType": mime, "data": data}}


def extension_for_mime(mime: str) -> str:
    mapping = {
        "image/png": ".png",
        "image/jpeg": ".jpg",
        "image/webp": ".webp",
        "image/gif": ".gif",
    }
    return mapping.get((mime or "").lower(), ".bin")


def build_request(prompt: str, inputs: list[str], aspect: str, size: str) -> Dict[str, Any]:
    parts = [load_image_part(p) for p in inputs]
    parts.append({"text": prompt})
    gen_cfg: Dict[str, Any] = {"responseModalities": ["IMAGE", "TEXT"]}
    image_cfg: Dict[str, Any] = {}
    if aspect != "auto":
        image_cfg["aspectRatio"] = aspect
    if size != "auto":
        image_cfg["imageSize"] = size
    if image_cfg:
        gen_cfg["imageConfig"] = image_cfg
    return {
        "contents": [{"parts": parts}],
        "generationConfig": gen_cfg,
    }


def api_post(url: str, api_key: str, payload: Dict[str, Any]) -> Dict[str, Any]:
    body = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(
        url,
        data=body,
        method="POST",
        headers={
            "Content-Type": "application/json",
            "x-goog-api-key": api_key,
        },
    )
    try:
        with urllib.request.urlopen(req, timeout=180) as resp:
            return json.loads(resp.read().decode("utf-8"))
    except urllib.error.HTTPError as e:
        data = e.read().decode("utf-8", errors="replace")
        try:
            obj = json.loads(data)
            err(json.dumps(obj, ensure_ascii=False))
        except Exception:
            err(f"HTTP {e.code}: {data}")
    except urllib.error.URLError as e:
        err(f"request failed: {e}")


def extract_image(response: Dict[str, Any]) -> tuple[bytes, str]:
    candidates = response.get("candidates") or []
    for cand in candidates:
        parts = ((cand.get("content") or {}).get("parts") or [])
        for part in parts:
            inline = part.get("inlineData") or part.get("inline_data")
            if inline and inline.get("data"):
                mime = inline.get("mimeType") or inline.get("mime_type") or "application/octet-stream"
                return base64.b64decode(inline["data"]), mime
    if response.get("error"):
        err(json.dumps(response["error"], ensure_ascii=False))
    err("no image returned by provider")


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description="Generate/edit images via Gemini-compatible providers")
    p.add_argument("prompt", nargs="?", help="Prompt text")
    p.add_argument("-i", dest="inputs", action="append", default=[], help="Input image (repeatable)")
    p.add_argument("-o", dest="output", default="", help="Output filename")
    p.add_argument("-aspect", default="auto", help="Aspect ratio or auto")
    p.add_argument("-size", default="auto", help="Image size or auto")
    p.add_argument("--provider", default=None, help="Provider name from local config")
    p.add_argument("--model", default=DEFAULT_MODEL, help="Model name")
    p.add_argument("-version", action="store_true", help="Show version")
    return p.parse_args()


def main():
    args = parse_args()
    if args.version:
        print("nanobanana-provider 1.0")
        return
    if not args.prompt:
        err("no prompt provided")
    if args.aspect not in VALID_ASPECTS:
        err(f"invalid aspect ratio: {args.aspect}")
    if args.size not in VALID_SIZES:
        err(f"invalid image size: {args.size}")

    cfg = load_provider_config()
    provider_name, provider = choose_provider(cfg, args.provider)
    endpoint = build_endpoint(provider["base_url"], args.model)
    payload = build_request(args.prompt, args.inputs, args.aspect, args.size)

    print("Generating image...")
    print(f"  Provider: {provider_name}")
    print(f"  Endpoint: {endpoint}")
    print(f"  Model:    {args.model}")
    print(f"  Aspect:   {args.aspect}")
    print(f"  Size:     {args.size}")
    if args.inputs:
        print(f"  Inputs:   {', '.join(args.inputs)}")

    response = api_post(endpoint, provider["api_key"], payload)
    image_bytes, mime = extract_image(response)

    output = args.output
    ext = extension_for_mime(mime)
    if not output:
        from datetime import datetime
        output = f"image_{datetime.utcnow().strftime('%Y%m%d_%H%M%S')}{ext}"
    else:
        current_ext = Path(output).suffix.lower()
        if current_ext != ext:
            output = str(Path(output).with_suffix(ext))
            print(f"Info: adjusted output extension to match returned mime type: {output}")

    Path(output).write_bytes(image_bytes)
    print(f"\nImage saved to: {output}")


if __name__ == "__main__":
    main()
