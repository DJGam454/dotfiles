# dotfiles

Personal dotfiles for macOS and Windows. Forked from
[kunchenguid/dotfiles](https://github.com/kunchenguid/dotfiles) (MIT-0).

- **macOS** uses Nix (`nix-darwin` + `home-manager`): installs packages and
  symlinks the config files in `home/` into `~`.
- **Windows** uses `windows/bootstrap.ps1`: links the exact same config files
  into the right Windows locations with junctions and hardlinks. The Nix files
  are macOS-only.

## Layout

| Path | What it is |
| --- | --- |
| `flake.nix`, `flake.lock` | nix-darwin + home-manager inputs |
| `configuration.nix` | macOS system defaults, Homebrew packages |
| `home.nix` | user packages and the symlinks from `~` into `home/` |
| `rebuild.sh` | macOS: link `~/.dotfiles` and run `nix-darwin switch` |
| `home/AGENTS.md` | global agent instructions (Claude, Codex, opencode) |
| `home/skills/` | global agent skills |
| `home/.claude/settings.json` | Claude Code settings and git guardrail hook |
| `home/.config/nvim/` | Neovim + lazy.nvim |
| `home/.config/wezterm/` | WezTerm |
| `home/.config/herdr/` | herdr config |
| `home/.config/opencode/` | opencode MCP servers and the graphify skill |
| `home/.pi/agent/` | pi agent config |
| `windows/bootstrap.ps1` | Windows setup: links everything into place |
| `windows/opencode.json` | Windows variant of the opencode config |
| `windows/setup-scrapling-mcp.ps1` | recreates the scrapling-mcp venv on Windows |

## macOS

Prereqs: [Determinate Nix](https://determinate.systems/nix) and the repo cloned
anywhere (for example `~/github/DJGam454/dotfiles`).

```sh
./rebuild.sh
```

`rebuild.sh` symlinks `~/.dotfiles` to the repo and runs:

```sh
sudo nix run nix-darwin -- switch --flake ~/.dotfiles#mac
```

Re-run it after any change to `home.nix`, `configuration.nix`, or `flake.nix`.

## Windows

Prereqs: Windows 10/11, PowerShell 5.1+, Git for Windows, winget.

```powershell
git clone https://github.com/DJGam454/dotfiles-private.git "$env:USERPROFILE\dotfiles"
powershell -ExecutionPolicy Bypass -File "$env:USERPROFILE\dotfiles\windows\bootstrap.ps1" -InstallApps
```

Drop `-InstallApps` if you prefer to install apps yourself. The script moves any
existing file aside to `<name>.backup-<timestamp>` before linking. No admin
rights or Developer Mode are needed (junctions for folders, hardlinks for
files).

Then install the tools that winget does not carry:

```powershell
uv tool install graphifyy
powershell -ExecutionPolicy Bypass -c "irm https://herdr.dev/install.ps1 | iex"
powershell -ExecutionPolicy Bypass -c "irm https://claude.ai/install.ps1 | iex"
```

opencode: see https://opencode.ai/docs/
scrapling-mcp: `powershell -ExecutionPolicy Bypass -File windows\setup-scrapling-mcp.ps1`

Restart the terminal, then log in to each tool (`gh auth login`,
`opencode auth login`, Claude Code) since credentials are not stored in the repo.

### What gets linked where

| Repo path | Windows path |
| --- | --- |
| `home/.config/wezterm` | `%USERPROFILE%\.config\wezterm` |
| `home/.config/nvim` | `%LOCALAPPDATA%\nvim` |
| `home/.config/herdr` | `%APPDATA%\herdr` |
| `home/.config/opencode/skills` | `%USERPROFILE%\.config\opencode\skills` |
| `windows/opencode.json` | `%USERPROFILE%\.config\opencode\opencode.json` |
| `home/.claude/settings.json` | `%USERPROFILE%\.claude\settings.json` |
| `home/skills` | `%USERPROFILE%\.claude\skills` and `%USERPROFILE%\.agents\skills` |
| `home/AGENTS.md` | `%USERPROFILE%\.config\opencode\AGENTS.md`, `%USERPROFILE%\.claude\CLAUDE.md`, `%USERPROFILE%\.codex\AGENTS.md` |
| `home/.pi/agent` | `%USERPROFILE%\.pi\agent` |

Because the links point back into the repo, editing any of these files edits the
repo. Commit changes from `%USERPROFILE%\dotfiles` to keep both machines in sync.

## opencode

`home/.config/opencode/opencode.json` defines three local MCP servers:

- `chrome-devtools` via `npx chrome-devtools-mcp@latest`
- `playwright` via `npx @playwright/mcp@latest`
- `scrapling` via the venv at `~/.config/opencode/venvs/scrapling-mcp`

The venv is platform specific and not committed. On macOS it already exists; on
Windows run `windows/setup-scrapling-mcp.ps1`, which creates it at
`%USERPROFILE%\.config\opencode\venvs\scrapling-mcp` and installs the browsers.
`windows/opencode.json` points there with `{env:USERPROFILE}`, so the two
platforms get identical MCP servers from their own file.

`graphify` is installed as a `uv` tool (`uv tool install graphifyy`) and its
skill lives in `home/.config/opencode/skills/graphify`.

## Notes

- WezTerm background blur is a macOS setting, guarded in `wezterm.lua`, so the
  same file runs on Windows.
- The Claude Code statusline and git guardrail hook use `jq` and bash. Install
  Git for Windows and `jq` (both in the winget list) so they work.
- herdr runs natively on Windows with a few limitations, see
  https://herdr.dev/docs/windows-beta/
- Nix and Homebrew are macOS only. On Windows, winget replaces them; system
  settings in `configuration.nix` have no Windows equivalent.
