# install.ps1 — vision-reader 一键安装向导（Windows）
$ErrorActionPreference = 'Stop'

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "   vision-reader 安装向导" -ForegroundColor Cyan
Write-Host "   让「纯文本模型」也能看懂图片" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# 0) 检查 Node.js
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "[!] 没检测到 Node.js。" -ForegroundColor Yellow
    Write-Host "    请先去 https://nodejs.org 下载安装（点绿色 LTS 按钮，一路下一步）。"
    Write-Host "    装完 Node.js 后，重新运行本脚本即可。"
    Read-Host "按回车退出"
    exit 1
}
Write-Host ("[OK] 已检测到 Node.js " + (node --version)) -ForegroundColor Green
Write-Host ""

# 1) 选择厂商
$presets = @(
    [pscustomobject]@{ Name = "MiniMax（国内）";             BaseURL = "https://api.minimaxi.com/v1";                     Model = "MiniMax-M3" },
    [pscustomobject]@{ Name = "OpenAI";                      BaseURL = "https://api.openai.com/v1";                       Model = "gpt-4o" },
    [pscustomobject]@{ Name = "阿里云·通义千问（qwen-vl）";    BaseURL = "https://dashscope.aliyuncs.com/compatible-mode/v1"; Model = "qwen-vl-max" },
    [pscustomobject]@{ Name = "智谱 AI（glm-4v）";            BaseURL = "https://open.bigmodel.cn/api/paas/v4";             Model = "glm-4v-plus" },
    [pscustomobject]@{ Name = "月之暗面 Kimi";               BaseURL = "https://api.moonshot.cn/v1";                       Model = "moonshot-v1-8k-vision-preview" },
    [pscustomobject]@{ Name = "硅基流动 SiliconFlow";         BaseURL = "https://api.siliconflow.cn/v1";                    Model = "Qwen/Qwen2.5-VL-72B-Instruct" }
)

Write-Host "第一步：你的「能看图的模型」是哪一家？" -ForegroundColor Cyan
for ($i = 0; $i -lt $presets.Count; $i++) {
    Write-Host ("  {0}. {1}" -f ($i + 1), $presets[$i].Name)
}
Write-Host "  0. 其他 / 冷门厂商（我自己填接口地址）"
Write-Host ""

$baseURL = ""
$model = ""
$pick = Read-Host "请输入编号（例如 1）"

if ($pick -match '^\d+$' -and [int]$pick -ge 1 -and [int]$pick -le $presets.Count) {
    $sel = $presets[[int]$pick - 1]
    $baseURL = $sel.BaseURL
    $model = $sel.Model
    Write-Host ""
    Write-Host ("已选：{0}" -f $sel.Name) -ForegroundColor Green
    Write-Host ("  接口地址 baseURL：{0}" -f $baseURL)
    Write-Host ("  默认模型名：{0}" -f $model)
    Write-Host "  （如果这个模型名以后失效了，去厂商文档查最新的「视觉模型名」填进去即可）"
    $change = Read-Host "  模型名要改吗？直接回车用默认；要改就输入新模型名"
    if ($change.Trim()) { $model = $change.Trim() }
}
else {
    Write-Host ""
    Write-Host "自定义模式：请准备好 接口地址 + 模型名。" -ForegroundColor Yellow
    $baseURL = (Read-Host "接口地址 baseURL（例如 https://api.xxx.com/v1）").Trim()
    $model = (Read-Host "模型名（例如 your-vision-model）").Trim()
    if (-not $baseURL -or -not $model) {
        Write-Host "[!] 地址或模型名为空，安装中止。" -ForegroundColor Yellow
        Read-Host "按回车退出"
        exit 1
    }
}
Write-Host ""

# 2) API Key
Write-Host "第二步：粘贴你的 API Key" -ForegroundColor Cyan
Write-Host "  （在厂商后台的「API 密钥 / API Key」页面创建并复制；"
Write-Host "   粘贴时终端不显示内容，是正常的，别担心。）"
$apiKey = (Read-Host "API Key").Trim()
if (-not $apiKey) {
    Write-Host "[!] Key 为空，安装中止。你可以之后手动编辑 config.json。" -ForegroundColor Yellow
    Read-Host "按回车退出"
    exit 1
}
Write-Host ""

# 3) 复制到技能目录
Write-Host "第三步：复制文件到技能目录" -ForegroundColor Cyan
$agentsHome = if ($env:DSH_AGENTS_HOME) { $env:DSH_AGENTS_HOME } else { Join-Path $env:USERPROFILE ".agents" }
$skillsRoot = Join-Path $agentsHome "skills"
$dest = Join-Path $skillsRoot "vision-reader"

New-Item -ItemType Directory -Force -Path $dest | Out-Null
$source = Join-Path $PSScriptRoot "vision-reader"
Copy-Item -Path (Join-Path $source "*") -Destination $dest -Recurse -Force

$config = [ordered]@{ baseURL = $baseURL; model = $model; apiKey = $apiKey }
$json = $config | ConvertTo-Json
[System.IO.File]::WriteAllText((Join-Path $dest "config.json"), $json, (New-Object System.Text.UTF8Encoding $false))

Write-Host ("[OK] 已安装到：" + $dest) -ForegroundColor Green
Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "   安装完成！" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "回到 DSH（或你的 AI 工具）里，这样说："
Write-Host "  · 先复制一张截图，然后说：读剪贴板"
Write-Host "  · 或者直接说：读这张图 C:\某目录\图片.png"
Write-Host ""
Write-Host "提示：如果 AI 还没识别到这个技能，重启一下 DSH / AI 工具。"
Write-Host ""
Read-Host "按回车关闭"
