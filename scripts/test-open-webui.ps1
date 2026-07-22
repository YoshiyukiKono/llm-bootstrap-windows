. "$PSScriptRoot/common.ps1"
$map=Get-EnvMap; $port=$map['OPEN_WEBUI_PORT']; if (-not $port) {$port='3000'}
Write-Step 'Testing Open WebUI'
if (-not (Wait-Http -Uri "http://127.0.0.1:$port/health" -TimeoutSeconds 180)) { throw 'Open WebUI health endpoint did not become ready.' }
Write-Ok "Open WebUI is ready at http://127.0.0.1:$port"
