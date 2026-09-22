{ plasma-manager, ... }:

{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = { inherit plasma-manager; };

  home-manager.users.haakjell = { lib, pkgs, ... }: {
    imports = [ plasma-manager.homeModules.plasma-manager ];

    home.stateVersion = "26.05";

    # Clones the dotfiles repo anonymously over HTTPS on first activation (so
    # it works before SSH is set up), then switches origin to the SSH URL for
    # future pushes. On later activations it only fetches - never touches the
    # working tree - and never fails the switch if offline.
    home.activation.fetchDotfiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      DOTFILES_DIR="$HOME/git/config"
      REPO_SSH_URL="git@github.com:haakjell/config.git"
      REPO_HTTPS_URL="https://github.com/haakjell/config.git"
      GIT="${pkgs.git}/bin/git"
      TIMEOUT="${pkgs.coreutils}/bin/timeout 15"

      if [ ! -d "$DOTFILES_DIR/.git" ]; then
        $DRY_RUN_CMD mkdir -p "$(dirname "$DOTFILES_DIR")"
        if $DRY_RUN_CMD $TIMEOUT $GIT clone "$REPO_HTTPS_URL" "$DOTFILES_DIR"; then
          $DRY_RUN_CMD $GIT -C "$DOTFILES_DIR" remote set-url origin "$REPO_SSH_URL"
        else
          echo "dotfiles: clone failed (offline?), skipping" >&2
        fi
      else
        $DRY_RUN_CMD $TIMEOUT $GIT -C "$DOTFILES_DIR" fetch origin \
          || echo "dotfiles: fetch failed (offline?), skipping" >&2
      fi
    '';

    programs.plasma.enable = true;

    programs.plasma.workspace = {
      lookAndFeel = "org.kde.breezedark.desktop";
      colorScheme = "BreezeDark";
    };

    programs.plasma.configFile = {
      # Alt-drag instead of Meta-drag to move windows
      kwinrc.MouseBindings.CommandAllKey = "Alt";
      # Much faster window/effect animations
      kdeglobals.KDE.AnimationDurationFactor = 0.35355339059327373;
    };

    programs.plasma.shortcuts = {
      kwin = {
        "Window Maximize" = [ "Meta+PgUp" "Meta+Up" ];
        "Window Minimize" = [ "Meta+Down" "Meta+PgDown" ];
      };
      "services/net.local.kitty.desktop"._launch = "Meta+Return";
    };

    # KDE creates this local desktop entry when a global shortcut to run a
    # command is added; recreated here so the shortcut above resolves.
    home.file.".local/share/applications/net.local.kitty.desktop".text = ''
      [Desktop Entry]
      Exec=kitty
      Name=Start termimal
      NoDisplay=true
      StartupNotify=false
      Type=Application
      X-KDE-GlobalAccel-CommandShortcut=true
    '';
  };
}
