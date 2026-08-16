// see.mjs — send one image to a vision-capable model (OpenAI-compatible API) and print its answer.
// Usage: node see.mjs "<image-path>" ["<prompt>"]
import { readFileSync, existsSync } from 'node:fs';
import { homedir } from 'node:os';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const skillDir = dirname(__dirname); // the vision-reader/ folder

const [imagePath, ...promptParts] = process.argv.slice(2);
if (!imagePath) {
  console.error('usage: node see.mjs "<image-path>" ["<prompt>"]');
  process.exit(2);
}

// ---- resolve config: config.json beside the skill, overridden by env vars ----
let cfg = {};
const configPath = join(skillDir, 'config.json');
if (existsSync(configPath)) {
  try {
    cfg = JSON.parse(readFileSync(configPath, 'utf8').replace(/^\uFEFF/, ''));
  } catch (e) {
    console.error('config.json is not valid JSON:', e.message);
    process.exit(3);
  }
}

function readDshCredential() {
  const dshHome = process.env.DSH_HOME || join(homedir(), '.dsh');
  const credPath = join(dshHome, '.credentials.yaml');
  if (existsSync(credPath)) {
    const m = readFileSync(credPath, 'utf8').match(/^\s*MINIMAX_CN_API_KEY\s*:\s*(.+?)\s*$/m);
    if (m) return m[1].replace(/^["']|["']$/g, '');
  }
  return null;
}

const baseURL = (process.env.VISION_BASE_URL || cfg.baseURL || '').replace(/\/+$/, '');
const model = process.env.VISION_MODEL || cfg.model || '';
const apiKey = process.env.VISION_API_KEY || cfg.apiKey || process.env.MINIMAX_CN_API_KEY || readDshCredential();

if (!baseURL || !model || !apiKey) {
  console.error('Missing configuration. Fill baseURL, model, apiKey in config.json next to the skill,');
  console.error('or set the VISION_BASE_URL / VISION_MODEL / VISION_API_KEY environment variables.');
  process.exit(4);
}

// ---- media type by extension ----
const ext = (imagePath.split('.').pop() || '').toLowerCase();
const mediaTypes = { png: 'image/png', jpg: 'image/jpeg', jpeg: 'image/jpeg', webp: 'image/webp', gif: 'image/gif' };
const mediaType = mediaTypes[ext];
if (!mediaType) {
  console.error(`Unsupported image extension: .${ext} (use png/jpg/jpeg/webp/gif)`);
  process.exit(5);
}

const buf = readFileSync(imagePath);
if (buf.length > 10 * 1024 * 1024) {
  console.error('Image exceeds the 10 MB limit');
  process.exit(6);
}
const dataUrl = `data:${mediaType};base64,${buf.toString('base64')}`;

const prompt = promptParts.join(' ').trim()
  || '请详细描述这张图片的内容。如果图中有文字，请把文字原样读出来（逐字转录）。';

const body = {
  model,
  messages: [
    {
      role: 'user',
      content: [
        { type: 'text', text: prompt },
        { type: 'image_url', image_url: { url: dataUrl } },
      ],
    },
  ],
};

let res;
try {
  res = await fetch(`${baseURL}/chat/completions`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${apiKey}` },
    body: JSON.stringify(body),
    signal: AbortSignal.timeout(180000),
  });
} catch (e) {
  console.error('request failed:', e.cause?.code ?? e.message);
  process.exit(7);
}

const text = await res.text();
if (!res.ok) {
  console.error(`HTTP ${res.status}: ${text.slice(0, 2000)}`);
  process.exit(8);
}

let data;
try { data = JSON.parse(text); } catch {
  console.error('non-JSON response:', text.slice(0, 2000));
  process.exit(9);
}

const stripThinking = (s) => s.replace(/<think>[\s\S]*?<\/think>\s*/g, '').trim();
const content = data?.choices?.[0]?.message?.content;
if (typeof content === 'string') {
  console.log(stripThinking(content));
} else if (Array.isArray(content)) {
  for (const part of content) if (part?.type === 'text') console.log(stripThinking(part.text));
} else {
  console.log(JSON.stringify(data, null, 2));
}
