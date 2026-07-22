. "$PSScriptRoot/common.ps1"
$map=Get-EnvMap; $port=$map['SEARXNG_PORT']; if (-not $port) {$port='8080'}
Write-Step 'Testing SearXNG JSON search'
$r=Invoke-RestMethod -Uri "http://127.0.0.1:$port/search?q=ollama&format=json" -TimeoutSec 20
if (-not $r.results) { Write-Warn 'SearXNG responded, but returned no results.' } else { Write-Ok "SearXNG returned $(@($r.results).Count) results" }
