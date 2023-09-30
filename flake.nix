{
  description = "Look ma, no hands!";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import inputs.nixpkgs { inherit system; };
    in
    {
      nixosConfigurations."PF3LZDKP" = inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./configuration.nix
          inputs.nixos-wsl.nixosModules.wsl
          {
            system.stateVersion = "23.05";
            wsl = {
              enable = true;
              defaultUser = "thsc";
              nativeSystemd = true;
              wslConf = {
                network.hostname = "PF3LZDKP";
                interop.enabled = true;
              };
            };
            users.users."thsc" = {
              isNormalUser = true;
            };
          }
        ];
      };
    };
}
