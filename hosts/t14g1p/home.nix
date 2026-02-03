{ inputs, outputs, lib, config, pkgs, ... }: {
  imports = [ ../../home-manager/home.nix ];
  home.username = "thsc";
  home.homeDirectory = "/home/thsc";
  home.packages = with pkgs; [
    ghostty
    proton-pass
    wine
    winetricks
    signal-desktop
    master.qbittorrent
    master.vlc
    master.protonvpn-gui
  ];
  # home.packages = [
  #   (pkgs.azure-cli.withExtensions [
  #     pkgs.azure-cli.extensions.ssh
  #     pkgs.azure-cli.extensions.ad
  #     pkgs.azure-cli.extensions.fzf
  #   ])
  # ];
}
