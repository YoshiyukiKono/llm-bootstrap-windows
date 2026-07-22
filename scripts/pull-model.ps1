param([string]$Model)
. "$PSScriptRoot/common.ps1"
if (-not $Model) { $Model=$Config.Ollama.DefaultModel }
Write-Step "Pulling Ollama model: $Model"
Invoke-Native ollama pull $Model
Write-Ok "Model ready: $Model"
