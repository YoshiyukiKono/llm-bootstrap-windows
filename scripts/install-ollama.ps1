. "$PSScriptRoot/common.ps1"
if (Test-Command ollama) { Write-Ok "Ollama already installed: $((ollama --version) -join ' ')"; return }
if (-not (Test-Command winget)) { throw 'winget is unavailable. Install Ollama manually from the official Windows installer, then rerun.' }
Write-Step 'Installing Ollama with winget'
Invoke-Native winget install --id $Config.Ollama.WingetId --exact --accept-package-agreements --accept-source-agreements
$env:Path = [Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [Environment]::GetEnvironmentVariable('Path','User')
if (-not (Test-Command ollama)) { Write-Warn 'Ollama installed, but this PowerShell session has not picked up PATH. Open a new terminal and rerun bootstrap.ps1.'; return }
Write-Ok 'Ollama installed'
