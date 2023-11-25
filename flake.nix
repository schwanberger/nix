{
  description = "Look ma, no hands!";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable"; # primary nixpkgs
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-23.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, ... }@inputs: {
    nixosConfigurations."PF3LZDKP" = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      specialArgs = {
        inherit inputs;
        pkgs-unstable = import nixpkgs-unstable {
          system = system;
          config.allowUnfree = true;
        };
      };
      modules = [
        ./nixos-wsl/configuration.nix
        inputs.nixos-wsl.nixosModules.wsl
        {
          wsl = {
            enable = true;
            defaultUser = "thsc";
            nativeSystemd = true;
            wslConf = {
              network.hostname = "PF3LZDKP";
              interop.enabled = true;
            };
          };
        }
      ];
    };
  };
}
