{ inputs, config, pkgs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];
  security.pam.loginLimits = [
    {
      domain = "*";
      type = "soft";
      item = "nofile";
      value = "65536";
    }
    {
      domain = "*";
      type = "hard";
      item = "nofile";
      value = "1048576";

    }
  ];

  # security.pam.loginLimits = [
  #   {
  #     domain = "*";
  #     type = "-";
  #     item = "nofile";
  #     value = "65536";
  #   }
  # ];

systemd.user.extraConfig = "DefaultLimitNOFILE=65536:1048576";
systemd.extraConfig = "DefaultLimitNOFILE=65536:1048576";
#systemd.services."user@1000".serviceConfig.LimitNOFILE = "65536";
systemd.services."nix-daemon".serviceConfig.LimitNOFILE = pkgs.lib.mkForce "65536:1048576";

time.timeZone = "Europe/Copenhagen";

  environment.systemPackages = with pkgs; [ vim home-manager zsh git gnupg ];
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
          "gradle"
        ];
      };
    };
  };

  # GnuPG
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  services.pcscd.enable = true;



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
