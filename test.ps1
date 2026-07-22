$ErrorActionPreference='Stop'
& "$PSScriptRoot/scripts/test-ollama.ps1"
& "$PSScriptRoot/scripts/test-searxng.ps1"
& "$PSScriptRoot/scripts/test-open-webui.ps1"
Write-Host "`nAll smoke tests passed." -ForegroundColor Green
