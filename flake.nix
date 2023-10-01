{
  description = "Look ma, no hands!";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-23.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, ... }@inputs:
    {
      nixosConfigurations."PF3LZDKP" = nixpkgs.lib.nixosSystem {
        specialArgs  = { inherit inputs; };
        system = "x86_64-linux";
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
