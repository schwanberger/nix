{ inputs, outputs, lib, config, pkgs, ... }: {
  imports = [ ../../home-manager/home.nix ];
  home.username = "thsc";
  home.homeDirectory = "/home/thsc";
  home.packages = with pkgs; [
    ghostty
    master.proton-pass
    wine
    winetricks
  ];
  # home.packages = [
  #   (pkgs.azure-cli.withExtensions [
  #     pkgs.azure-cli.extensions.ssh
  #     pkgs.azure-cli.extensions.ad
  #     pkgs.azure-cli.extensions.fzf
  #   ])
  # ];
}
