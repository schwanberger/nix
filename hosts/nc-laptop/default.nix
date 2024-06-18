# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{ inputs, outputs, lib, config, pkgs, ... }: {
  # You can import other NixOS modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    # outputs.nixosModules.example

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.stable-packages
      outputs.overlays.emacs-overlay
      # outputs.overlays.doom-emacs-overlay

     inputs.nix-doom-emacs-unstraightened.overlays.default


      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;

      # permittedInsecurePackages = [ "openssl-1.1.1w" ];
    };
  };

  wsl = {
    enable = true;
    defaultUser = "thsc";
    nativeSystemd = true;
    useWindowsDriver = true;
    # docker-desktop.enable = true;
    extraBin = with pkgs; [
      # Binaries for Docker Desktop wsl-distro-proxy
      { src = "${coreutils}/bin/mkdir"; }
      { src = "${coreutils}/bin/cat"; }
      { src = "${coreutils}/bin/whoami"; }
      { src = "${coreutils}/bin/ls"; }
      { src = "${busybox}/bin/addgroup"; }
      { src = "${su}/bin/groupadd"; }
      {
        src = "${su}/bin/usermod";
      }
      # VS Code's "Remote - Tunnels" extension does not respect `~/.vscode-server/server-env-setup`, so we need to provide these binaries under `/bin`.
      { src = "${coreutils}/bin/uname"; }
      {
        src = "${coreutils}/bin/rm";
      }
      # { src = "${coreutils}/bin/mkdir"; } # Already defined
      { src = "${coreutils}/bin/mv"; }

      { src = "${coreutils}/bin/dirname"; }
      { src = "${coreutils}/bin/readlink"; }
      { src = "${coreutils}/bin/wc"; }
      { src = "${coreutils}/bin/date"; }
      { src = "${coreutils}/bin/sleep"; }
      { src = "${coreutils}/bin/cat"; }
      { src = "${gnused}/bin/sed"; }
      { src = "${gnutar}/bin/tar"; }
      { src = "${gzip}/bin/gzip"; }
    ];
    wslConf = {
      network.hostname = "PF3LZDKP";
      #network.generateResolvConf = false;
      network.generateResolvConf = true;
      network.generateHosts = true;
      interop.enabled = true;
    };
  };

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    extraSpecialArgs = { inherit inputs outputs; };
    users = { thsc = import ../../home-manager/home.nix; };
  };

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    package = pkgs.nixVersions.latest;
    # package = pkgs.nixFlakes;
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Opinionated: disable global registry
      flake-registry = "";
      # Workaround for https://github.com/NixOS/nix/issues/9574
      nix-path = config.nix.nixPath;
      substituters =
        [ "https://nix-community.cachix.org" "https://devenv.cachix.org" ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      ];
      trusted-users = [ "root" "@wheel" ];
      extra-sandbox-paths =
        lib.mkIf config.wsl.useWindowsDriver [ "/usr/lib/wsl" ];
      max-substitution-jobs = 64;
      # upgrade-nix-store-path-url = "https://install.determinate.systems/nix-upgrade/stable/universal";
      upgrade-nix-store-path-url = "https://releases.nixos.org/nix/nix-2.22.1/fallback-paths.nix";
    };
    # Opinionated: disable channels
    channel.enable = false;

    # Opinionated: make flake registry and nix path match flake inputs
    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };

  environment.extraInit = ''
    ulimit -n 524288
  '';

  # nix.optimise.automatic = true;

  # nix.gc = {
  #   automatic = true;
  #   dates = "weekly";
  #   options = "--delete-older-than 30d";
  # };

  # Increase open file limit for sudoers
  security.pam.loginLimits = [
    {
      domain = "@wheel";
      item = "nofile";
      type = "soft";
      value = "524288";
    }
    {
      domain = "@wheel";
      item = "nofile";
      type = "hard";
      value = "1048576";
    }
  ];

  # FIXME: Add the rest of your current configuration

  #boot.loader.systemd-boot.enable = true;

  environment.pathsToLink = [ "/share/zsh" ];

  time.timeZone = "Europe/Copenhagen";
  # i18n.defaultLocale = "en_DK.UTF-8";

  environment.systemPackages = with pkgs; [ wget curl cachix python3 ];

  # environment.systemPackages = with pkgs; [
  #   bat
  #   yq
  #   jq
  #   wget
  #   xclip
  #   gnumake

  #   # Latex
  #   texlab # lsp
  #   texlive.combined.scheme-full
  #   evince
  #   #texlive.combined.scheme-medium

  #   # Doom Emacs stuff
  #   #myEmacs
  #   #emacs29-pgtk
  #   # ((emacsPackagesFor emacs29-pgtk).emacsWithPackages (epkgs: [epkgs.vterm]))
  #   emacs-unstable-pgtk-with-packages
  #   (ripgrep.override { withPCRE2 = true; })
  #   fd
  #   (aspellWithDicts (ds: with ds; [ en en-computers en-science ]))
  #   nodejs
  #   sqlite

  #   # Nix stuff
  #   nil # nil seems like the better choice 2023-11-28
  #   #rnix-lsp # Another lsp
  #   nixfmt

  #   # Uncatogorized
  #   openssh
  #   pandoc
  #   p7zip
  #   zstd
  #   vim
  #   git
  #   p7zip
  #   inetutils
  #   gcc
  #   asciidoctor-with-extensions

  #   # Langs
  #   python3
  # ]
  # # ++ [ emacs-pgtk-unstable ]
  # ;

   programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/thsc/nix";
  };

  programs.nix-ld = {
    enable = true;
    libraries = [
      # Required by NodeJS installed by VS Code's Remote WSL extension
      pkgs.stdenv.cc.cc
    ];
    package = inputs.nix-ld-rs.packages.${pkgs.system}.nix-ld-rs;
  };
  programs.zsh.enable = true;

  virtualisation.containers.enable = true;
  virtualisation.podman = {
    enable = true;

    # Create a `docker` alias for podman, to use it as a drop-in replacement
    #dockerCompat = true;

    # Required for containers under podman-compose to be able to talk to each other.
    defaultNetwork.settings.dns_enabled = true;
  };

  environment.shells = with pkgs; [ zsh ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  services.pcscd.enable = true;

  services.xserver.videoDrivers = lib.mkDefault [ "modesetting" ];

  # hardware.opengl = {
  #   enable = true;
  #   extraPackages = with pkgs; [ intel-media-driver intel-ocl ];
  # };

  # From: https://github.com/Atry/nixos-wsl-vscode/blob/main/flake.nix
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    setLdLibraryPath = true;
  };

  fonts = {
    enableDefaultPackages = true;
    # Fonts handled in home manager
    fontconfig = {
      antialias = true;
      hinting = {
        enable = true;
        autohint = false; # Default
        style = "full";
      };
      subpixel = {
        #lcdfilter = "default";
        #lcdfilter = "legacy";
        lcdfilter = "light";
        #rgba = "none";
        #rgba = "bgr";
      };
      defaultFonts.monospace = [ "JetBrainsMonoNL Nerd Font" ];
      #useEmbeddedBitmaps = true;
    };
  };

  users.extraGroups.docker.members = [ "thsc" ];

  users.defaultUserShell = pkgs.zsh;
  users.users = {
    thsc = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [ ];
      extraGroups = [ "wheel" ];
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
