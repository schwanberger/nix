{ inputs, config, pkgs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  systemd.user.extraConfig = "DefaultLimitNOFILE=65536";

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

  time.timeZone = "Europe/Copenhagen";

  environment.systemPackages = with pkgs; [ vim home-manager zsh git gnupg p7zip zsh-completions ];
  environment.shells = with pkgs; [ zsh ];

  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  i18n.defaultLocale = "en_DK.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ALL="en_DK.UTF-8";
  };

  virtualisation.containers.enable = true;
  virtualisation.podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
  };
  # Will have to wait until Windows 11 WSL2
  #virtualisation.libvirtd.enable = true;
  #virtualisation.virtualbox.host.enable = true;
  #virtualisation.virtualbox.guest.enable = true;
  #virtualisation.virtualbox.host.enableHardening = false;
  #virtualisation.virtualbox.host.headless = true;
  #boot.kernelModules = [ "kvm-amd" "kvm-intel" "virtualbox" ];

  # GnuPG
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  services.pcscd.enable = true;

  # I'm sorry Stallman-taichou
  nixpkgs.config.allowUnfree = true;

  # Networking
  networking.hostName = "PF3LZDKP"; # Define your hostname.

  # I use zsh btw
  users.defaultUserShell = pkgs.zsh;

    programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    #enableCompletion = false;
    syntaxHighlighting.enable = true;
  };

  users.users.thsc = {
    isNormalUser = true;
    description = "Thomas Schwanberger";
    #shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "qemu-libvirtd" "libvirtd" "disk" "video" "audio" "vboxusers" ];
    uid = 1000;
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      thsc = import ./home.nix;
    };
  };
  # It is ok to leave this unchanged for compatibility purposes
  system.stateVersion = "23.05";
}
