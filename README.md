# vision-reader

> 让你的 AI 助手在「用纯文本模型」的时候，也能**看懂图片**。

平时你用的可能是 DeepSeek 这类**纯文本模型**——它不会看图片，你贴一张截图它就说「当前模型没有视觉能力」。
这个技能（skill）就是解决这个问题的：它在你需要看图的瞬间，悄悄调用**另一个会看图的模型**帮你读图，再把文字结果拿回来。你**不用切换模型**，也**不会污染对话历史**。

---

## 对专业人士（快速安装）

**依赖**：Node.js ≥ 18；任意一家 OpenAI 兼容的视觉模型（MiniMax / OpenAI / qwen-vl / glm-4v / Kimi / SiliconFlow 等）。

**Windows 一键**：

```powershell
git clone https://github.com/shimisizhuanyuan-6969/DSH-vision-reader.git && cd DSH-vision-reader
./install.bat          # 或 ./install.ps1
```

**手动（任意系统）**：

```bash
cp -r vision-reader ~/.agents/skills/
cat > ~/.agents/skills/vision-reader/config.json <<'EOF'
{"baseURL":"https://api.minimaxi.com/v1","model":"MiniMax-M3","apiKey":"你的Key"}
EOF
```

**使用**：

```bash
node vision-reader/scripts/see.mjs "<图片路径>" "[问题]"      # 读磁盘图片
pwsh -File vision-reader/scripts/clip.ps1 "[问题]"            # 读剪贴板（仅 Windows）
```

配置优先级：环境变量 `VISION_BASE_URL` / `VISION_MODEL` / `VISION_API_KEY` > `config.json`（`baseURL` / `model` / `apiKey`）。更多细节见 `vision-reader/SKILL.md`。

## For professionals (Quick start)

**Prerequisites**: Node.js ≥ 18, plus any OpenAI-compatible vision model (MiniMax / OpenAI / qwen-vl / glm-4v / Kimi / SiliconFlow, etc.).

**Windows (one-shot)**:

```powershell
git clone https://github.com/shimisizhuanyuan-6969/DSH-vision-reader.git && cd DSH-vision-reader
./install.bat          # or ./install.ps1
```

**Manual (any OS)**:

```bash
cp -r vision-reader ~/.agents/skills/
cat > ~/.agents/skills/vision-reader/config.json <<'EOF'
{"baseURL":"https://api.minimaxi.com/v1","model":"MiniMax-M3","apiKey":"YOUR_KEY"}
EOF
```

**Usage**:

```bash
node vision-reader/scripts/see.mjs "<image-path>" "[question]"   # image on disk
pwsh -File vision-reader/scripts/clip.ps1 "[question]"           # clipboard (Windows only)
```

Config precedence: env vars `VISION_BASE_URL` / `VISION_MODEL` / `VISION_API_KEY` > `config.json` (`baseURL` / `model` / `apiKey`). See `vision-reader/SKILL.md`.

---

## 对小白（一步步教程）

> 零基础看这里。第一次接触这类东西，照着做就行。

### 它能干什么

- 📷 描述一张图片里有什么
- 🔤 把图片里的**文字**原样读出来（比如截图里的报错、表格、聊天记录）
- ❓ 回答关于图片的问题（「这张图里的报错是什么意思」）
- 支持格式：PNG / JPEG / WebP / GIF，单张不超过 10 MB

### 装之前，你只需要准备 2 样东西

1. **一台装了 Node.js 的电脑**
2. **一个「能看图的模型」的 API Key**（哪家都行，比如 MiniMax、OpenAI、通义千问、智谱、Kimi、硅基流动……）

> 别被「API Key」吓到，它就是一段字符串，相当于你访问那个模型服务的「门禁卡」。下面会一步步教你拿到。

### 第 0 步：装 Node.js（如果没装过）

1. 打开网站：**https://nodejs.org**
2. 点那个**绿色的大按钮**（写着 LTS 的那个），下载安装包
3. 双击安装，一路「下一步」默认装完即可

怎么确认装好了？按 `Win + R`，输入 `cmd` 回车，在弹出的黑窗口里输入：

```
node --version
```

如果显示类似 `v20.x.x` 或 `v22.x.x`，就是装好了。

### 第 1 步：拿到一个「能看图的模型」的 API Key

下面以 **MiniMax** 为例（国内注册方便）。你手上有别家的 Key 也完全没问题。

1. 打开 **https://platform.minimaxi.com** （MiniMax 开放平台），注册并登录
2. 按提示完成**实名认证**（国内平台基本都要）
3. 进入**「接口密钥 / API Key」**页面，点**「创建密钥」**
4. 复制生成出来的那一长串 Key（通常以 `eyJ...` 开头）
5. 确认账号里有**余额 / 免费额度**（读图按用量扣一点点钱，非常少）

> 各家的 Key 页面位置都差不多，关键词都是 **API Key / 接口密钥 / Access Token**。找不到就在后台搜这三个词。

**常见厂商对照表**（安装时直接选编号就行）：

| 厂商 | 安装时选哪个 | 接口地址（已内置，不用你填） | 默认视觉模型 |
|---|---|---|---|
| MiniMax 国内 | 1 | https://api.minimaxi.com/v1 | MiniMax-M3 |
| OpenAI | 2 | https://api.openai.com/v1 | gpt-4o |
| 阿里云·通义千问 | 3 | https://dashscope.aliyuncs.com/compatible-mode/v1 | qwen-vl-max |
| 智谱 AI | 4 | https://open.bigmodel.cn/api/paas/v4 | glm-4v-plus |
| 月之暗面 Kimi | 5 | https://api.moonshot.cn/v1 | moonshot-v1-8k-vision-preview |
| 硅基流动 | 6 | https://api.siliconflow.cn/v1 | Qwen/Qwen2.5-VL-72B-Instruct |

> ⚠️ 模型名可能会被厂商更新/下线。如果哪天读图报错说模型不存在，去厂商文档查一下最新的「视觉模型名」，改一下 `config.json` 里的 `model` 就行（见文末「进阶」）。

### 第 2 步：安装（二选一）

#### 方式 A：一键安装（推荐，Windows）

1. 回到本仓库页面，点绿色 **Code** 按钮 → **Download ZIP**，下载后**解压**
2. 进入解压出来的文件夹，**双击 `install.bat`**
3. 按提示：**输入厂商编号** → **粘贴 API Key** → 回车
4. 看到「安装完成」就 OK 了

> 如果双击没反应，就右键 `install.bat` → 「以管理员身份运行」。

#### 方式 B：手动复制（任何系统都行）

1. 把本仓库里的 `vision-reader` 文件夹，整个复制到技能目录：
   - Windows：`C:\Users\你的用户名\.agents\skills\`
   - macOS/Linux：`~/.agents/skills/`
   - 结果应该是 `...\.agents\skills\vision-reader\` 这样的路径
2. 进入 `vision-reader` 文件夹，把里面的 `config.example.json` **复制一份改名为 `config.json`**
3. 用记事本打开 `config.json`，改成下面这样（换成你自己的地址/模型/Key）：

```json
{
  "baseURL": "https://api.minimaxi.com/v1",
  "model": "MiniMax-M3",
  "apiKey": "把这里换成你的Key"
}
```

4. 保存。

### 第 3 步：使用

回到你的 AI 工具（DSH）里，用大白话跟它说就行：

- **剪贴板方式**：先用微信 / QQ / 系统截图复制一张图到剪贴板，然后说：
  > 读剪贴板

- **文件方式**：直接给图片路径：
  > 读这张图 C:\Users\xxx\Desktop\截图.png
  > 或者：这张图里的报错信息是什么？

它会自动调用你的视觉模型，把结果用文字告诉你。

### 常见问题（FAQ）

**Q：双击 install.bat 一闪而过 / 没反应？**
右键 `install.bat` → 「以管理员身份运行」。还不行就用手动方式 B。

**Q：安装时报「没检测到 Node.js」？**
回去做第 0 步装 Node.js，装完重跑 install.bat。

**Q：读图报 `401` 或 `Unauthorized`？**
Key 填错了（多了空格、少了字符、或者复制了别的）。重新粘贴一次。

**Q：报「模型不存在 / model not found」？**
去厂商后台查当前可用的视觉模型名，改 `config.json` 里的 `model`。

**Q：报「余额不足 / insufficient」？**
去厂商后台充值，或换一个有额度的账号。

**Q：剪贴板方式报「No image on the clipboard」？**
说明剪贴板里现在没有图片。先截图 / 复制一张图，再说「读剪贴板」。

**Q：它和我现在用的模型冲突吗？**
不冲突。它是在「外面」另开一次请求，不影响你当前会话用的模型，也不往对话历史里塞图片。

### 隐私与安全

- 你的 API Key 只存在**你自己电脑**的 `config.json` 里，本仓库的 `.gitignore` 已把它排除，**不会**被提交到 GitHub。
- 图片只是在你「读图」那一刻临时发给视觉模型，读脚本用完即删临时文件，不会在本地留副本。
- 传给视觉模型的只有图片本身 + 你的问题，别在问题里附带敏感信息。

### 进阶：改配置 / 换厂商 / 自定义地址

配置都在这一个文件里（位于技能文件夹内的 `config.json`）：

```json
{
  "baseURL": "https://api.minimaxi.com/v1",
  "model": "MiniMax-M3",
  "apiKey": "你的Key"
}
```

- 换厂商：改 `baseURL`（接口地址）+ `model`（模型名）+ `apiKey`。
- 用冷门厂商：只要它提供 **OpenAI 兼容** 的接口（绝大多数都提供），填它的地址和模型名即可。
- 不想写进文件，也可以用环境变量：`VISION_BASE_URL`、`VISION_MODEL`、`VISION_API_KEY`。

### 目录结构

```
vision-reader-skill/
├── README.md               ← 你现在看的这个说明
├── install.bat             ← Windows 双击安装入口
├── install.ps1             ← 交互式安装向导
├── LICENSE
└── vision-reader/          ← 真正的技能本体
    ├── SKILL.md            ← 给 AI 看的指令
    ├── config.example.json ← 配置模板（复制改成 config.json）
    └── scripts/
        ├── see.mjs         ← 读磁盘图片
        └── clip.ps1        ← 读剪贴板截图
```
