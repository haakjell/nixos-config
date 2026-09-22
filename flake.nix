{
  description = "NixPad system config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05"; # or nixos-25.11 etc, match what you're on

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = { self, nixpkgs, home-manager, plasma-manager, ... }: {
    nixosConfigurations.NixPad = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit plasma-manager; };
      modules = [
        ./configuration.nix
        ./hosts/nixpad/configuration.nix
        home-manager.nixosModules.home-manager
        ./home.nix
      ];
    };
    nixosConfigurations.NixPad-Two = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit plasma-manager; };
      modules = [
        ./configuration.nix
        ./hosts/nixpad-two/configuration.nix
        home-manager.nixosModules.home-manager
        ./home.nix
      ];
    };
  };
}
