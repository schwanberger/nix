{ inputs, config, pkgs, ... }:

{
#systemd.thsc.extraConfig = "DefaultLimitNOFILE=32000";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
