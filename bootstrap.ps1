[CmdletBinding()]
param([switch]$PullDefaultModel)
$ErrorActionPreference='Stop'
& "$PSScriptRoot/scripts/check-system.ps1"
& "$PSScriptRoot/scripts/install-docker-desktop.ps1"
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) { Write-Warning 'Open a new PowerShell session after Docker Desktop installation, complete first-run setup, then rerun bootstrap.ps1.'; return }
& "$PSScriptRoot/scripts/install-ollama.ps1"
if (-not (Get-Command ollama -ErrorAction SilentlyContinue)) { Write-Warning 'Open a new PowerShell session after Ollama installation, then rerun bootstrap.ps1.'; return }
& "$PSScriptRoot/scripts/configure-environment.ps1"
Write-Host "`nStart Ollama from the Windows Start menu if it is not already running." -ForegroundColor Yellow
& "$PSScriptRoot/scripts/start-services.ps1"
& "$PSScriptRoot/test.ps1"
if ($PullDefaultModel) { & "$PSScriptRoot/scripts/pull-model.ps1" }
Write-Host "`nBootstrap complete. Open http://localhost:3000" -ForegroundColor Green
