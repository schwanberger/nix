# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{ inputs, outputs, lib, config, pkgs, ... }:
let
  # emacsWithPackages = (pkgs.emacsPackagesFor
  #   pkgs.emacs29-pgtk).emacsWithPackages;
  # myEmacs = emacsWithPackages
  #   (p: with p; [ vterm sqlite magit treesit-grammars.with-all-grammars ]);
  emacs-pgtk-unstable = with pkgs.emacs-overlay;
    ((emacsPackagesFor emacs-unstable-pgtk).emacsWithPackages
      (epkgs: with epkgs; [ vterm sqlite ]));
in {
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
    };
  };

  wsl = {
    enable = true;
    defaultUser = "thsc";
    nativeSystemd = true;
    # docker-desktop.enable = true;
    extraBin = with pkgs; [
      # Binaries for Docker Desktop wsl-distro-proxy
      { src = "${coreutils}/bin/mkdir"; }
      { src = "${coreutils}/bin/cat"; }
      { src = "${coreutils}/bin/whoami"; }
      { src = "${coreutils}/bin/ls"; }
      { src = "${busybox}/bin/addgroup"; }
      { src = "${su}/bin/groupadd"; }
      { src = "${su}/bin/usermod"; }
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

  # This will add each flake input as a registry
  # To make nix3 commands consistent with your flake
  nix.registry = (lib.mapAttrs (_: flake: { inherit flake; }))
    ((lib.filterAttrs (_: lib.isType "flake")) inputs);

  # This will additionally add your inputs to the system's legacy channels
  # Making legacy nix commands consistent as well, awesome!
  nix.nixPath = [ "/etc/nix/path" ];
  environment.etc = lib.mapAttrs' (name: value: {
    name = "nix/path/${name}";
    value.source = value.flake;
  }) config.nix.registry;

  nix = {
    package = pkgs.nixVersions.nix_2_21;
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Deduplicate and optimize nix store
      auto-optimise-store = true;
      substituters =
        [ "https://nix-community.cachix.org" "https://devenv.cachix.org" ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      ];
      trusted-users = [ "root" "@wheel" ];
    };
  };

  environment.shellInit = ''
    ulimit -n 524288
  '';

  nix.optimise.automatic = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

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
  i18n.defaultLocale = "en_DK.UTF-8";

  environment.systemPackages = with pkgs; [
    bat
    yq
    jq
    wget
    xclip

    # Doom Emacs stuff
    #myEmacs
    #emacs29-pgtk
    # ((emacsPackagesFor emacs29-pgtk).emacsWithPackages (epkgs: [epkgs.vterm]))
    emacs-pgtk-unstable
    (ripgrep.override { withPCRE2 = true; })
    nerdfonts
    fd
    (aspellWithDicts (ds: with ds; [ en en-computers en-science ]))
    nodejs
    sqlite

    # Nix stuff
    nil # nil seems like the better choice 2023-11-28
    #rnix-lsp # Another lsp
    nixfmt

    # Uncatogorized
    openssh
    pandoc
    p7zip
    zstd
    vim
    git
    p7zip
    inetutils
    gcc
    asciidoctor-with-extensions

    # Langs
    python3
  ]
  # ++ [ emacs-pgtk-unstable ]
  ;

  programs.nix-ld.enable = true;
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

  fonts.packages = with pkgs; [ nerdfonts ];

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
  system.stateVersion = "23.05";
}
