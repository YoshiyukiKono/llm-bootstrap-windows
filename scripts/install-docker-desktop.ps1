. "$PSScriptRoot/common.ps1"
if (Test-Command docker) { Write-Ok 'Docker CLI already installed'; return }
if (-not (Test-Command winget)) { throw 'winget is unavailable. Install Docker Desktop manually, then rerun.' }
Write-Step 'Installing Docker Desktop with winget'
Invoke-Native winget install --id $Config.DockerDesktop.WingetId --exact --accept-package-agreements --accept-source-agreements
Write-Warn 'Start Docker Desktop once and accept its terms. A Windows restart may be required. Then rerun bootstrap.ps1.'
return
