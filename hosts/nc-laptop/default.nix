# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{ inputs, outputs, lib, config, pkgs, ... }:
let
  emacs-pgtk-unstable = with pkgs.unstable-emacs-overlay;
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
      outputs.overlays.unstable-packages
      outputs.overlays.unstable-packages-emacs-overlay

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

  home-manager = {
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

  networking.hostName = "PF3LZDKP";

  #boot.loader.systemd-boot.enable = true;

  time.timeZone = "Europe/Copenhagen";
  i18n.defaultLocale = "en_DK.UTF-8";
  i18n.extraLocaleSettings = { LC_ALL = "en_DK.UTF-8"; };

  environment.systemPackages = with pkgs.unstable; [
    # Shell stuff
    zsh-completions
    zsh-fzf-tab
    zsh-autopair
    zsh-nix-shell
    zsh-autocomplete
    zsh-fast-syntax-highlighting
    zsh-fzf-history-search
    fzf
    bat
    yq
    jq
    wget
    xclip

    # Doom Emacs stuff
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
  ]
  ++ [ emacs-pgtk-unstable ];

  programs.nix-ld.enable = true;

  # services.emacs = {
  #   enable = true;
  #   package = emacs-pgtk-unstable;
  #   #install = true;
  #   #defaultEditor = true;
  #   #extraOptions = [ "--init-directory=~/doom-vertico" ];
  # };

  # systemd.services.emacs.serviceConfig.ExecStart = let
  #   cfg = config.services.emacs;
  #   in lib.mkForce "${pkgs.bash}/bin/bash -l -i -c 'source ${config.system.build.setEnvironment}; exec emacs --daemon'";

  # systemd.user.services = {
  #   emacs = {
  #     description = "Emacs: the extensible, self-documenting text editor";
  #     environment = {
  #       GTK_DATA_PREFIX = config.system.path;
  #       SSH_AUTH_SOCK = "%t/ssh-agent";
  #       GTK_PATH = "${config.system.path}/lib/gtk-3.0:${config.system.path}/lib/gtk-2.0";
  #     };
  #     serviceConfig = {
  #       Type = "forking";
  #       ExecStart = "${pkgs.bash}/bin/bash -l -c 'source ${config.system.build.setEnvironment}; exec emacs --daemon'";
  #       #ExecStart = "${pkgs.unstable.zsh}/bin/zsh -l -c 'exec emacs --daemon'";
  #       ExecStop = "${emacs-pgtk-unstable}/bin/emacsclient --eval (kill-emacs)";
  #       Restart = "always";
  #     };
  #     wantedBy = [ "default.target" ];
  #   };
  # };

  # systemd.services.emacs.enable = true;

  # environment.systemPackages = [
  #   pkgs.emacs-git
  # ];

  virtualisation.containers.enable = true;
  virtualisation.podman = {
    enable = true;
    package = pkgs.unstable.podman;

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
