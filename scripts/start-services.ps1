. "$PSScriptRoot/common.ps1"
Start-DockerDesktopIfNeeded
Write-Step 'Starting Open WebUI and SearXNG'
Push-Location $RepoRoot
try { Invoke-Native docker compose --env-file .env up -d } finally { Pop-Location }
Write-Ok 'Containers started'
