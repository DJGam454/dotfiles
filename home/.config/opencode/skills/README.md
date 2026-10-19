opencode loads global skills from this directory, one `<name>/SKILL.md` per
skill. `home.nix` symlinks it to `~/.config/opencode/skills`; `.claude/skills`
and `.agents/skills` point at `home/skills/` instead. This file keeps the
directory tracked by git.
