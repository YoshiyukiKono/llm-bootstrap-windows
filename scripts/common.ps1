Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:RepoRoot = Split-Path -Parent $PSScriptRoot
$script:Config = Import-PowerShellDataFile (Join-Path $RepoRoot 'config/bootstrap.psd1')

function Write-Step([string]$Message) { Write-Host "`n==> $Message" -ForegroundColor Cyan }
function Write-Ok([string]$Message) { Write-Host "[OK] $Message" -ForegroundColor Green }
function Write-Warn([string]$Message) { Write-Warning $Message }
function Test-Command([string]$Name) { return [bool](Get-Command $Name -ErrorAction SilentlyContinue) }
function Invoke-Native {
    param([Parameter(Mandatory)][string]$FilePath,[Parameter(ValueFromRemainingArguments)][string[]]$ArgumentList)
    & $FilePath @ArgumentList
    if ($LASTEXITCODE -ne 0) { throw "$FilePath exited with code $LASTEXITCODE" }
}
function New-RandomSecret([int]$Bytes = 32) {
    $buffer = New-Object byte[] $Bytes
    [System.Security.Cryptography.RandomNumberGenerator]::Fill($buffer)
    return [Convert]::ToHexString($buffer).ToLowerInvariant()
}
function Get-EnvMap {
    $path = Join-Path $RepoRoot '.env'
    $map = @{}
    if (Test-Path $path) {
        foreach ($line in Get-Content $path) {
            if ($line -match '^\s*#' -or $line -notmatch '=') { continue }
            $key,$value = $line -split '=',2
            $map[$key.Trim()] = $value.Trim()
        }
    }
    return $map
}
function Wait-Http {
    param([string]$Uri,[int]$TimeoutSeconds=120)
    $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
    do {
        try { Invoke-WebRequest -UseBasicParsing -Uri $Uri -TimeoutSec 5 | Out-Null; return $true } catch { Start-Sleep -Seconds 3 }
    } while ((Get-Date) -lt $deadline)
    return $false
}
function Start-DockerDesktopIfNeeded {
    if (Test-Command docker) {
        try { docker info *> $null; if ($LASTEXITCODE -eq 0) { return } } catch {}
    }
    $candidates = @(
      "$env:LOCALAPPDATA\Programs\Docker\Docker\Docker Desktop.exe",
      "$env:LOCALAPPDATA\Programs\DockerDesktop\Docker Desktop.exe",
      "$env:ProgramFiles\Docker\Docker\Docker Desktop.exe"
    )
    $exe = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
    if (-not $exe) { throw 'Docker Desktop executable was not found. Install it, start it once, and accept its terms.' }
    Start-Process $exe | Out-Null
    $deadline=(Get-Date).AddSeconds($Config.DockerDesktop.StartupTimeoutSeconds)
    do { Start-Sleep 3; try { docker info *> $null; if ($LASTEXITCODE -eq 0) { return } } catch {} } while ((Get-Date)-lt $deadline)
    throw 'Docker Desktop did not become ready before the timeout.'
}
