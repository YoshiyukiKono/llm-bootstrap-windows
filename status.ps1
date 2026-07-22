$ErrorActionPreference='Continue'
. "$PSScriptRoot/scripts/common.ps1"
Write-Host "Ollama:" -ForegroundColor Cyan
try { Invoke-RestMethod "$($Config.Ollama.ApiUrl)/api/tags" -TimeoutSec 5 | Select-Object -ExpandProperty models | Select-Object name,size,modified_at | Format-Table } catch { Write-Warning 'Ollama API unavailable' }
Write-Host "Containers:" -ForegroundColor Cyan
Push-Location $RepoRoot
try { docker compose --env-file .env ps } finally { Pop-Location }
