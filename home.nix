{ plasma-manager, ... }:

{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = { inherit plasma-manager; };

  home-manager.users.haakjell = { ... }: {
    imports = [ plasma-manager.homeModules.plasma-manager ];

    home.stateVersion = "26.05";

    programs.plasma.enable = true;
  };
}
