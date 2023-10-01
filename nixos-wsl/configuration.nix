{ inputs, config, pkgs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];
  security.pam.loginLimits = [{
    domain = "*";
    type = "soft";
    item = "nofile";
    value = "8192";
  }];
  environment.systemPackages = [ pkgs.vim pkgs.home-manager pkgs.zsh pkgs.git ];
  environment.shells = with pkgs; [ zsh ];

  programs = {
    zsh = {
      enable = true;
      ohMyZsh = {
        enable = true;
        theme = "robbyrussell";
        plugins = [
          "git"
          "fzf"
        ];
      };
    };
  };

  users.users.thsc = {
    isNormalUser = true;
    shell = pkgs.zsh;
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "23.05";

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      thsc = import ./home.nix;
    };
  };
}
