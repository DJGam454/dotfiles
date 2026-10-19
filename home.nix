{ config, pkgs, ... }:

let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
in
{
  home.username = "divyantiwari";
  home.homeDirectory = "/Users/divyantiwari";
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    ripgrep
    fd
    fzf
    jq
    lazygit
    neovim
    nerd-fonts.hack
  ];

  fonts.fontconfig.enable = true;

  home.sessionVariables.EDITOR = "nvim";
  home.sessionPath = [ "$HOME/.opencode/bin" ];

  programs.zsh = {
    enable = true;

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    initContent = ''
      bindkey '^f' autosuggest-accept
    '';

    shellAliases = {
      ".." = "cd ..";
      ll = "ls -lah";
      add = "git add .";
      push = "git push";
      pull = "git pull";
      m = "git switch main";
      cc = "claude --dangerously-skip-permissions";
      co = "codex --full-auto";
    };
  };

  programs.starship = {
    enable = true;

    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$cmd_duration$line_break$character";

      character = {
        success_symbol = "[❯](purple)";
        error_symbol = "[❯](red)";
      };

      cmd_duration.format = "[$duration]($style) ";
    };
  };

  # Dotfiles managed directly from the repository.
  home.file.".config/wezterm".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/wezterm";

  home.file.".config/nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/nvim";

  home.file.".config/herdr".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/herdr";

  home.file.".claude/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.claude/settings.json";

  home.file.".pi/agent/themes".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/themes";

  home.file.".pi/agent/extensions".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/extensions";

  home.file.".pi/agent/models.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/models.json";

  home.file.".pi/agent/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/settings.json";

  home.file.".claude/CLAUDE.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";

  home.file.".codex/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";

  home.file.".config/opencode/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";

  # Freebuff loads user knowledge from home-level .AGENTS.md / .CLAUDE.md.
  home.file.".AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";

  home.file.".config/opencode/opencode.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/opencode/opencode.json";

  home.file.".config/opencode/skills".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/opencode/skills";

  # Global agent skills (opencode auto-loads both of these too).
  home.file.".claude/skills".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/skills";

  home.file.".agents/skills".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/skills";
}
