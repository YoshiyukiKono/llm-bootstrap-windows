. "$PSScriptRoot/common.ps1"
Write-Step 'Creating local environment configuration'
$envPath = Join-Path $RepoRoot '.env'
$example = Join-Path $RepoRoot '.env.example'
if (-not (Test-Path $envPath)) { Copy-Item $example $envPath }
$content = Get-Content $envPath -Raw
if ($content -match 'WEBUI_SECRET_KEY=replace-me') { $content = $content.Replace('WEBUI_SECRET_KEY=replace-me', 'WEBUI_SECRET_KEY=' + (New-RandomSecret)) }
if ($content -match 'SEARXNG_SECRET_KEY=replace-me') { $content = $content.Replace('SEARXNG_SECRET_KEY=replace-me', 'SEARXNG_SECRET_KEY=' + (New-RandomSecret)) }
Set-Content -Path $envPath -Value $content -Encoding utf8NoBOM
$map = Get-EnvMap
$templatePath = Join-Path $RepoRoot 'config/searxng/settings.yml.template'
$settingsPath = Join-Path $RepoRoot 'config/searxng/settings.yml'
$template = Get-Content $templatePath -Raw
$template = $template.Replace('__SEARXNG_SECRET_KEY__', $map['SEARXNG_SECRET_KEY'])
Set-Content -Path $settingsPath -Value $template -Encoding utf8NoBOM
Write-Ok '.env and SearXNG settings are ready'
