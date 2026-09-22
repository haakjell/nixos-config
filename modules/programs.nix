{ pkgs, ... }:

{
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
}
