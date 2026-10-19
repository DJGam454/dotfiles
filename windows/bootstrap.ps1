<#
.SYNOPSIS
  Links this dotfiles repo into the right places on Windows.

.DESCRIPTION
  Mirrors what nix-darwin and home-manager do on macOS, using directory
  junctions and file hardlinks (no admin rights needed). Existing files are
  moved aside to <name>.backup-<timestamp> before a link is created.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File windows\bootstrap.ps1

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File windows\bootstrap.ps1 -InstallApps
#>
[CmdletBinding()]
param(
  [switch]$InstallApps
)

$ErrorActionPreference = "Stop"

$Repo = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$User = $env:USERPROFILE
$Config = Join-Path $User ".config"

function New-Dotlink {
  param(
    [Parameter(Mandatory)][string]$Path,
    [Parameter(Mandatory)][string]$Target
  )

  $resolved = (Resolve-Path -LiteralPath $Target).Path
  $existing = Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue

  if ($existing) {
    $targets = @($existing.Target) | ForEach-Object { $_.ToString() }
    if ($existing.LinkType -and ($targets -contains $resolved)) {
      Write-Host "  ok      $Path"
      return
    }
    $backup = "$Path.backup-$(Get-Date -Format yyyyMMdd-HHmmss)"
    Move-Item -LiteralPath $Path -Destination $backup
    Write-Host "  backup  $Path -> $backup"
  }

  $parent = Split-Path -Parent $Path
  if (-not (Test-Path -LiteralPath $parent)) {
    New-Item -ItemType Directory -Force -Path $parent | Out-Null
  }

  if ((Get-Item -LiteralPath $resolved).PSIsContainer) {
    New-Item -ItemType Junction -Path $Path -Target $resolved | Out-Null
  }
  else {
    try {
      New-Item -ItemType SymbolicLink -Path $Path -Target $resolved -ErrorAction Stop | Out-Null
    }
    catch {
      try {
        New-Item -ItemType HardLink -Path $Path -Target $resolved -ErrorAction Stop | Out-Null
      }
      catch {
        Copy-Item -LiteralPath $resolved -Destination $Path
        Write-Host "  copy    $Path (enable Developer Mode and re-run to link it instead)"
        return
      }
    }
  }
  Write-Host "  link    $Path"
}

Write-Host "dotfiles: $Repo"
Write-Host ""

if ([System.IO.Path]::GetPathRoot($Repo) -ne [System.IO.Path]::GetPathRoot($User)) {
  Write-Host "note: the repo is on a different drive than Windows."
  Write-Host "      folders become junctions automatically. Plain files need Developer Mode"
  Write-Host "      (Settings > System > For developers) to become symlinks; without it they"
  Write-Host "      are copied and will not sync back."
  Write-Host ""
}

New-Dotlink -Path (Join-Path $Config "wezterm")                -Target (Join-Path $Repo "home/.config/wezterm")
New-Dotlink -Path (Join-Path $env:LOCALAPPDATA "nvim")         -Target (Join-Path $Repo "home/.config/nvim")
New-Dotlink -Path (Join-Path $env:APPDATA "herdr")             -Target (Join-Path $Repo "home/.config/herdr")
New-Dotlink -Path (Join-Path $Config "opencode\opencode.json") -Target (Join-Path $Repo "windows/opencode.json")
New-Dotlink -Path (Join-Path $Config "opencode\AGENTS.md")     -Target (Join-Path $Repo "home/AGENTS.md")
New-Dotlink -Path (Join-Path $Config "opencode\skills")        -Target (Join-Path $Repo "home/.config/opencode/skills")
New-Dotlink -Path (Join-Path $User ".claude\settings.json")    -Target (Join-Path $Repo "home/.claude/settings.json")
New-Dotlink -Path (Join-Path $User ".claude\CLAUDE.md")        -Target (Join-Path $Repo "home/AGENTS.md")
New-Dotlink -Path (Join-Path $User ".claude\skills")           -Target (Join-Path $Repo "home/skills")
New-Dotlink -Path (Join-Path $User ".agents\skills")           -Target (Join-Path $Repo "home/skills")
New-Dotlink -Path (Join-Path $User ".codex\AGENTS.md")         -Target (Join-Path $Repo "home/AGENTS.md")
New-Dotlink -Path (Join-Path $User ".AGENTS.md")               -Target (Join-Path $Repo "home/AGENTS.md")
New-Dotlink -Path (Join-Path $User ".pi\agent")                -Target (Join-Path $Repo "home/.pi/agent")

Write-Host ""

if ($InstallApps) {
  if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw "winget not found. Install App Installer from the Microsoft Store and re-run."
  }

  $packages = @(
    "Git.Git",
    "wez.wezterm",
    "Neovim.Neovim",
    "OpenJS.NodeJS.LTS",
    "Python.Python.3.12",
    "astral-sh.uv",
    "BurntSushi.ripgrep.MSVC",
    "sharkdp.fd",
    "junegunn.fzf",
    "jqlang.jq",
    "JesseDuffield.lazygit",
    "SST.opencode",
    "DEVCOM.HackNerdFont"
  )

  foreach ($id in $packages) {
    Write-Host "winget install $id"
    winget install --id $id --exact --silent --accept-source-agreements --accept-package-agreements --disable-interactivity
  }

  Write-Host ""
  Write-Host "Still to install by hand:"
  Write-Host "  freebuff:    install the desktop app from https://freebuff.com"
  Write-Host "  herdr:       irm https://herdr.dev/install.ps1 | iex"
  Write-Host "  claude code: irm https://claude.ai/install.ps1 | iex"
  Write-Host "  scrapling:   & `"$Repo\windows\setup-scrapling-mcp.ps1`""
}

Write-Host "done."
