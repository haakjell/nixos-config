{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./vanilla-wiiu.nix
  ];

  networking.hostName = "NixPad";
}
