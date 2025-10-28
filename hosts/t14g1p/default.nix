{ inputs, outputs, lib, config, pkgs, hostname, ... }: {
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


  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable networking
  networking = {
    hostName = hostname;
    firewall.enable = false;
    networkmanager.enable = true;
    enableIPv6 = false;
  };

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    extraSpecialArgs = { inherit inputs outputs; };
    users = { thsc = import ./home.nix; };
  };

  # Enable network manager applet
  programs.nm-applet.enable = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_DK.UTF-8";


  services.xserver = {
    enable = true;
    xkb = {
      layout = "dk";
      variant = "";
    };
    displayManager.lightdm.enable = true;
    desktopManager = {
      xterm.enable = false;
      xfce.enable = true;
    };
  };

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  services.displayManager.defaultSession = "xfce";

  # Lenovo updates
  services.fwupd.enable = true;

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/thsc/personal/nix";
  };


  nix.settings.trusted-users = [ "thsc" ];

  # Configure console keymap
  console.keyMap = "dk-latin1";

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.thsc = {
    isNormalUser = true;
    description = "Thomas Schwanberger";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = [ inputs.home-manager.packages.${pkgs.system}.default ];
  };

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "thsc";

  # Install firefox.
  programs.firefox.enable = true;

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
  ];

  documentation = {
    dev.enable = true;
    man.generateCaches = true;
    nixos.includeAllModules = true;
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

  services.pcscd.enable = true;
  security.sudo.wheelNeedsPassword = false;

  fonts = {
    enableDefaultPackages = true;
    # Fonts handled in home manager
    fontconfig = {
      hinting.style = "full";
      # subpixel.lcdfilter = "light";
      # subpixel.rgba = "rgb";
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";
}
