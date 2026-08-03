{ config, lib, pkgs, ... }:

{
  ## Nix
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  nixpkgs.config.allowUnfree = true;

  ## Boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  ## Networking
  networking.networkmanager.enable = true;

  ## Localization
  time.timeZone = "Europe/Oslo";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_TIME = "nb_NO.UTF-8";
    LC_MONETARY = "nb_NO.UTF-8";
    LC_MEASUREMENT = "nb_NO.UTF-8";
    LC_PAPER = "nb_NO.UTF-8";
  };
  console.keyMap = "no";

  ## Desktop environment
  services.xserver.enable = true;
  services.xserver.xkb.layout = "no";
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.enable = true;

  ## Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  ## GPU
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  ## Audio
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };
  security.rtkit.enable = true;

  ## Fonts
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    liberation_ttf
    dejavu_fonts
  ];
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      serif = [ "Liberation Serif" ];
      sansSerif = [ "Liberation Sans" "Noto Sans" ];
      monospace = [ "DejaVu Sans Mono" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  ## Users
  # Don't forget to set a password with `passwd`.
  users.users.haakjell = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    initialPassword = "changeme";
  };

  ## Programs
  programs.firefox = {
    enable = true;
    preferences = {
      "gfx.text.subpixel-position.force-enabled" = true;
    };
  };
  programs.ssh.startAgent = true;
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "haakjell" ];
  };

  ## Packages
  environment.systemPackages = with pkgs; [
    git
    wget
    pciutils
    killall
    neovim
    fastfetch
    kitty
    claude-code
  ];
  environment.variables.EDITOR = "nvim";

  ## Terminal: use kitty instead of the KDE/X11 defaults
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    konsole
  ];
  services.xserver.excludePackages = [ pkgs.xterm ];
  environment.etc."xdg/xdg-terminals.list".text = ''
    kitty.desktop
  '';
  environment.variables.TERMINAL = "kitty";

  # See https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion
  # Do not change after install unless you've read the manual on upgrading.
  system.stateVersion = "26.05";
}
