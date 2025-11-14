{ inputs, outputs, lib, config, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./nk.nix
  ];

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.stable-packages
      outputs.overlays.emacs-overlay
      outputs.overlays.master-packages
    ];
    config = {
      allowUnfree = true;
    };
  };

  # systemd.tmpfiles.settings = {
  #   "10-wslg-x11" = lib.mkForce {};
  # };

 # programs.gnupg.agent = {
 #   enable = true;
 #   pinentryPackage = pkgs.pinentry-tty;
 # };

   nix = {
    settings = {
      experimental-features = "nix-command flakes";
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
    SSL_CERT_DIR = "/etc/ssl/certs";
    CURL_CA_BUNDLE = "/etc/ssl/certs/ca-bundle.crt";
    REQUESTS_CA_BUNDLE = "/etc/ssl/certs/ca-certificates.crt";
  };


  time.timeZone = "Europe/Copenhagen";

  environment.systemPackages = with pkgs; [
    wget
    curl
    cachix
    # python3
    docker-compose
    linux-manual
    man-pages
    man-pages-posix
  ];

  documentation = {
    enable = true;
    # dev.enable = true;
    man.enable = true;
    # man.generateCaches = true;
    # nixos.includeAllModules = true;
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

  virtualisation.podman.enable = true;

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

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";
}
