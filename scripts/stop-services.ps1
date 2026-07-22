. "$PSScriptRoot/common.ps1"
Push-Location $RepoRoot
try { Invoke-Native docker compose --env-file .env down } finally { Pop-Location }
Write-Ok 'Containers stopped; persistent volumes were preserved.'
