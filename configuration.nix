{ inputs, config, pkgs, ... }:

{
  security.pam.loginLimits = [{
    domain = "*";
    type = "soft";
    item = "nofile";
    value = "8192";
  }];
  environment.systemPackages = [ pkgs.vim pkgs.home-manager ];
  programs.zsh.enable = true;
  programs.git.enable = true;
  users.users."thsc" = {
    isNormalUser = true;
    shell = pkgs.zsh;
  };
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
