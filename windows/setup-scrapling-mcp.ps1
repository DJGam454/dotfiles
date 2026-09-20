<#
.SYNOPSIS
  Recreates the scrapling-mcp virtualenv used by opencode on Windows.

.DESCRIPTION
  The venv is platform specific, so it is not stored in the repo. This script
  recreates it at the exact path windows/opencode.json points at:
  %USERPROFILE%\.config\opencode\venvs\scrapling-mcp

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File windows\setup-scrapling-mcp.ps1
#>
[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

$venv = Join-Path $env:USERPROFILE ".config\opencode\venvs\scrapling-mcp"

if (-not (Test-Path -LiteralPath $venv)) {
  Write-Host "creating venv at $venv"
  if (Get-Command py -ErrorAction SilentlyContinue) {
    & py -3.12 -m venv $venv
  }
  else {
    & python -m venv $venv
  }
}

$pip = Join-Path $venv "Scripts\pip.exe"
$scrapling = Join-Path $venv "Scripts\scrapling.exe"

& $pip install --upgrade pip
& $pip install "scrapling[ai]"
& $scrapling install

Write-Host ""
Write-Host "done. scrapling-mcp: $(Join-Path $venv 'Scripts\scrapling-mcp.exe')"
