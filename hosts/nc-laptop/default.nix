{ inputs, outputs, lib, config, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
  ];

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.stable-packages
      outputs.overlays.emacs-overlay
    ];
    config = {
      allowUnfree = true;
    };
  };

  # systemd.tmpfiles.settings = {
  #   "10-wslg-x11" = lib.mkForce {};
  # };

  wsl = {
    enable = true;
    defaultUser = "thsc";
    useWindowsDriver = true;
    # docker-desktop.enable = true; # Use windows docker-desktop (or rancher)
    wslConf = {
      network.hostname = "PF3LZDKP";
      interop.enabled = true;
    };
  };

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    extraSpecialArgs = { inherit inputs outputs; };
    users = { thsc = import ../../home-manager/home.nix; };
  };

  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-tty;
  };

   nix = {
    settings = {
      experimental-features = "nix-command flakes";
      trusted-users = [ "thsc" ];
      accept-flake-config = true;
      auto-optimise-store = true;
    };

    registry = {
      nixpkgs = {
        flake = inputs.nixpkgs;
      };
    };

    nixPath = [
      "nixpkgs=${inputs.nixpkgs.outPath}"
      "nixos-config=/etc/nixos/configuration.nix"
      "/nix/var/nix/profiles/per-user/root/channels"
    ];

    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    # Clean-up handled by nh
    # gc = {
    #   automatic = true;
    #   options = "--delete-older-than 7d";
    # };
  };

  environment.variables = {
    VISUAL = "emacsclient --create-frame";
    EDITOR = "emacsclient --tty";
  };


  time.timeZone = "Europe/Copenhagen";

  environment.systemPackages = with pkgs; [
    wget
    curl
    cachix
    python3
    docker-compose
  ];

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/thsc/personal/nix";
  };

  programs.nix-ld.dev = {
    enable = true;
    libraries = with pkgs; [
      libsecret # Required for vscode devcontainer /shrug
      glib # Required for vscode devcontainer /shrug
      # Below are the standard included by nix-ld.dev
      zlib
      zstd
      stdenv.cc.cc
      curl
      openssl
      attr
      libssh
      bzip2
      libxml2
      acl
      libsodium
      util-linux
      xz
      systemd
    ];
  };

  programs.zsh.enable = true;

  users.defaultUserShell = pkgs.bash;

  # virtualisation.containers.enable = true;
  virtualisation.docker =  {
    enable = true;
    storageDriver = "overlay2";
  };

  services.gnome.gnome-keyring.enable = true; # required for vscode devcontainer /shrug
  services.pcscd.enable = true;
  security.sudo.wheelNeedsPassword = false;

  fonts = {
    enableDefaultPackages = true;
    # Fonts handled in home manager
    fontconfig = {
      # hinting.style = "full";
      # subpixel.lcdfilter = "none";
    };
  };

  users.users = {
    thsc = {
      isNormalUser = true;
      shell = pkgs.bash;
      extraGroups = [ "wheel" "docker" ];
      packages = [ inputs.home-manager.packages.${pkgs.system}.default ];
    };
  };

  networking = {
    hostName = "PF3LZDKP";
    firewall.enable = false;
    enableIPv6 = false;
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";
}
