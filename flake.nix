{
  description = "NixPad system config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05"; # or nixos-25.11 etc, match what you're on
  };

  outputs = { self, nixpkgs, ... }: {
    nixosConfigurations.NixPad = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        ./hosts/nixpad/configuration.nix
      ];
    };
  };
}
