# clip.ps1 - read a clipboard screenshot via the configured vision model.
# Usage: & clip.ps1 ["<optional prompt>"]
param([string]$Prompt = "")

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$img = Get-Clipboard -Format Image -ErrorAction SilentlyContinue
if ($null -eq $img) {
    Write-Error "No image on the clipboard (copy a screenshot first)"
    exit 2
}

$tmp = Join-Path $env:TEMP ("vision-reader-" + [guid]::NewGuid().ToString("N") + ".png")
try { $img.Save($tmp, [System.Drawing.Imaging.ImageFormat]::Png) } finally { $img.Dispose() }

$see = Join-Path $PSScriptRoot "see.mjs"
try {
    if ($Prompt) { node $see $tmp $Prompt } else { node $see $tmp }
    $code = $LASTEXITCODE
} finally {
    Remove-Item $tmp -Force -ErrorAction SilentlyContinue
}
exit $code
