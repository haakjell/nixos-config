{ plasma-manager, ... }:

{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = { inherit plasma-manager; };

  home-manager.users.haakjell = { ... }: {
    imports = [ plasma-manager.homeModules.plasma-manager ];

    home.stateVersion = "26.05";

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
