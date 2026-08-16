---
name: vision-reader
description: Read an image's content by delegating to a user-configured vision model (OpenAI-compatible API) when the session model cannot accept images. Use when the user asks you to look at, describe, or transcribe an image (PNG/JPEG/WebP/GIF) and the read_image tool is unavailable or refused.
---

When the user needs an image understood (describe it, transcribe text in it, answer a question about it) and the current model cannot accept image input, delegate the vision to the configured external vision model through the bundled scripts instead of failing.

## Where the scripts live

Both scripts sit in this skill's `scripts/` folder. Resolve their absolute path from the skill's install directory. The default install location is:

- Windows: `C:\Users\<你的用户名>\.agents\skills\vision-reader\scripts\`
- macOS/Linux: `~/.agents/skills/vision-reader/scripts/`

## Method A — image is already a file on disk

Run:

    node "<skill-dir>/scripts/see.mjs" "<absolute-image-path>" "<optional question or prompt>"

## Method B — image is on the Windows clipboard (a copied screenshot)

Run:

    & "<skill-dir>/scripts/clip.ps1" "<optional question or prompt>"

(Clipboard method is Windows-only. It grabs the clipboard bitmap, saves a temp PNG, calls `see.mjs`, then deletes the temp file. Use it when the user says "read my clipboard", "read this screenshot I copied", or copies a screenshot and asks you to look at it.)

## Configuration

The scripts read the endpoint from `config.json` next to the skill's `SKILL.md` (see `config.example.json` for the shape):

```json
{ "baseURL": "https://api.minimaxi.com/v1", "model": "MiniMax-M3", "apiKey": "..." }
```

The environment variables `VISION_BASE_URL`, `VISION_MODEL`, `VISION_API_KEY` override the file.

## Rules

- Supported types: PNG / JPEG / WebP / GIF; max 10 MB per image.
- The API key lives only in the local `config.json` / environment; never put it on the command line.
- These calls happen OUTSIDE the session model, so they never change the session's model and never add an image to the conversation history (no "cannot switch back" problem).
- Prefer the native `read_image` tool when the session model already accepts images; use these scripts only as the fallback.
- Summarize the returned description for the user rather than dumping it verbatim, unless they asked for a transcription.
