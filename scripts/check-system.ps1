. "$PSScriptRoot/common.ps1"
Write-Step 'Checking Windows prerequisites'
if (-not $IsWindows) { throw 'This repository supports Windows only.' }
Write-Ok "PowerShell $($PSVersionTable.PSVersion)"
if (Test-Command winget) { Write-Ok 'winget found' } else { Write-Warn 'winget not found; installers must be run manually.' }
if (Test-Command wsl) { try { wsl --status | Out-Null; Write-Ok 'WSL command found' } catch { Write-Warn 'WSL exists but may require setup.' } } else { Write-Warn 'WSL not found. Docker Desktop WSL 2 backend requires it.' }
