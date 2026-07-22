. "$PSScriptRoot/common.ps1"
Write-Step 'Testing Ollama API'
try {
  $r=Invoke-RestMethod -Uri "$($Config.Ollama.ApiUrl)/api/tags" -TimeoutSec 10
  Write-Ok "Ollama API responded; models: $(@($r.models).Count)"
} catch { throw "Ollama API is unavailable at $($Config.Ollama.ApiUrl). Start Ollama from the Windows Start menu. $($_.Exception.Message)" }
