{
  description = "Look ma, no hands!";

  nixConfig = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [
      "https://cache.nixos.org/"
    ];

    extra-substituters = [
      # Nix community's cache server
      "https://nix-community.cachix.org"
      "https://devenv.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable"; # primary nixpkgs
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-23.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    devenv.url = "github:cachix/devenv";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, devenv, ... }@inputs: {
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
