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
      outputs.overlays.unstable-packages
      #outputs.overlays.emacs-overlay
      (import inputs.emacs-overlay)

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

  nix.optimise.automatic = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # FIXME: Add the rest of your current configuration

  networking.hostName = "PF3LZDKP";

  #boot.loader.systemd-boot.enable = true;

  time.timeZone = "Europe/Copenhagen";
  i18n.defaultLocale = "en_DK.UTF-8";
  i18n.extraLocaleSettings = { LC_ALL = "en_DK.UTF-8"; };

  environment.systemPackages = with pkgs; [
    unstable.bat
    (unstable.ripgrep.override { withPCRE2 = true; })
    unstable.openssh
    unstable.nerdfonts
    unstable.nodejs
    unstable.pandoc
    unstable.fd
    unstable.p7zip
    unstable.yq
    unstable.jq
    unstable.zstd
    (unstable.aspellWithDicts (ds: with ds; [ en en-computers en-science ]))
    unstable.sqlite
    unstable.nil # nil seems like the better choice 2023-11-28
    #unstable.rnix-lsp # Another lsp
    unstable.zsh-completions
    unstable.nixfmt
    unstable.vim
    unstable.p7zip
    unstable.inetutils
    unstable.gcc
    #unstable.emacs29-pgtk
    ((emacsPackagesFor emacs-unstable-pgtk).emacsWithPackages
      (epkgs: with epkgs; [ vterm ]))
    #emacs-pgtk
  ];

  # environment.systemPackages = [
  #   pkgs.emacs-git
  # ];

  virtualisation.containers.enable = true;
  virtualisation.podman = {
    enable = true;

    # Create a `docker` alias for podman, to use it as a drop-in replacement
    #dockerCompat = true;

    # Required for containers under podman-compose to be able to talk to each other.
    defaultNetwork.settings.dns_enabled = true;
  };

  environment.shells = with pkgs.unstable; [ zsh ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  services.pcscd.enable = true;

  fonts.packages = with pkgs.unstable; [ nerdfonts ];

  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    #enableCompletion = false;
    syntaxHighlighting.enable = true;
  };

  users.defaultUserShell = pkgs.unstable.zsh;
  users.users = {
    thsc = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [ ];
      extraGroups = [ "wheel" ];
      packages = [ inputs.home-manager.packages.${pkgs.system}.default ];
    };
  };

  # This setups a SSH server. Very important if you're setting up a headless system.
  # Feel free to remove if you don't need it.
  # services.openssh = {
  #   enable = true;
  #   settings = {
  #     # Forbid root login through SSH.
  #     PermitRootLogin = "no";
  #     # Use keys only. Remove if you want to SSH using password (not recommended)
  #     PasswordAuthentication = false;
  #   };
  # };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}