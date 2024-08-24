# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{ inputs, outputs, lib, config, pkgs, ... }:
let
  # emacs-unstable-pgtk-with-packages = with pkgs.emacs-overlay;
  #   ((emacsPackagesFor emacs-unstable-pgtk).emacsWithPackages (epkgs:
  #     with epkgs; [
  my-emacs-unstable = pkgs.emacs-overlay.emacs-unstable.override {
    withNativeCompilation = true;
    withSQLite3 = true;
    withTreeSitter = true;
    # withGTK3 = true; # Default is false to use the Lucid X toolkit isntead
  };
  my-emacs-unstable-with-packages =
    (pkgs.emacsPackagesFor my-emacs-unstable).emacsWithPackages
    (epkgs: with epkgs; [ vterm treesit-grammars.with-all-grammars ]);
in {
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix

    inputs.nix-doom-emacs-unstraightened.hmModule
    inputs.sops-nix.homeManagerModules.sops
  ];

  # nixpkgs = {
  #   # You can add overlays here
  #   overlays = [
  #     # Add overlays your own flake exports (from overlays and pkgs dir):
  #     outputs.overlays.additions
  #     outputs.overlays.modifications
  #     outputs.overlays.stable-packages

  #     # You can also add overlays exported from other flakes:
  #     # neovim-nightly-overlay.overlays.default

  #     # Or define it inline, for example:
  #     # (final: prev: {
  #     #   hi = final.hello.overrideAttrs (oldAttrs: {
  #     #     patches = [ ./change-hello-to-hi.patch ];
  #     #   });
  #     # })
  #   ];
  #   # Configure your nixpkgs instance
  #   config = {
  #     # Disable if you don't want unfree packages
  #     allowUnfree = true;
  #     # Workaround for https://github.com/nix-community/home-manager/issues/2942
  #     allowUnfreePredicate = _: true;
  #   };
  # };

  # TODO: Set your username
  home = {
    username = "thsc";
    homeDirectory = "/home/thsc";
  };

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  # home.packages = with pkgs; [ steam ];
  home.packages = with pkgs; [
    bat
    yq
    jq
    wget
    xclip
    gnumake
    yaml-language-server
    #nodePackages_latest.bash-language-server
    shellcheck
    nix-tree
    file

    # Latex
    #texlab # lsp
    #texlive.combined.scheme-full
    #evince
    #texlive.combined.scheme-medium

    # Doom Emacs stuff
    my-emacs-unstable-with-packages
    (ripgrep.override { withPCRE2 = true; })
    fd
    (aspellWithDicts (ds: with ds; [ en en-computers en-science ]))
    nodejs
    sqlite
    editorconfig-core-c
    zstd

    # Nix stuff
    #nil # nil seems like the better choice 2023-11-28
    #rnix-lsp # Another lsp
    nixd
    nixfmt

    # Uncategorized
    pandoc
    p7zip
    vim
    p7zip
    inetutils
    gcc
    asciidoctor-with-extensions

    # Secrets
    rage
    sops
    pinentry-tty

    # Langs
    python3
    zulu11

    # Fonts
    dejavu_fonts
    (nerdfonts.override {
      fonts = [
        "FiraCode"
        "JetBrainsMono"
        "Iosevka"
        "IosevkaTerm"
        "Meslo"
        "FiraMono"
        "SourceCodePro"
        "VictorMono"
        "RobotoMono"
        "NerdFontsSymbolsOnly"
        "Inconsolata"
        "InconsolataGo"
        "InconsolataLGC"
      ];
      enableWindowsFonts = true;
    })
  ];

  programs.home-manager.enable = true;

  programs.doom-emacs = {
    enable = true;
    doomDir = inputs.doom-config;
    emacs = my-emacs-unstable;
    extraBinPackages = with pkgs; [ git python3 pinentry-tty ];
    extraPackages = epkgs:
      with epkgs; [
        vterm
        treesit-grammars.with-all-grammars
        eat
        eshell-prompt-extras
        esh-autosuggest
        fish-completion
        esh-help
        eshell-syntax-highlighting
        pinentry
      ];
    provideEmacs = false;
    experimentalFetchTree = true;
  };

  fonts.fontconfig =
    {
      enable = true;
      defaultFonts = {
        monospace = [ "JetBrainsMonoNL Nerd Font" ];
        serif = [ "DejaVu Serif" ];
        sansSerif = [ "DejaVu Sans" ];
        emoji = [ "Symbols Nerd Font" ];
      };
    };

  sops = {
    gnupg.home = "~/.gnupg";
    secrets.git_config_work = {
      sopsFile = ../secrets/git_config_work.enc;
      format = "binary";
    };
    secrets.ssh_config_work = {
      sopsFile = ../secrets/ssh_config_work.enc;
      format = "binary";
    };
  };

  programs = {
    direnv = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      package = pkgs.direnv;
      nix-direnv.enable = true;
      nix-direnv.package = pkgs.nix-direnv;
    };
    fzf = {
      enable = true;
      package = pkgs.fzf;
      enableZshIntegration = true;
      enableBashIntegration = true;
    };
    starship = {
      package = pkgs.starship;
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = false;
      settings = {
        # add_newline = false;
        # line_break = { disabled = true; };
        # character = {
        #   success_symbol = "[>](bold green)";
        #   error_symbol = "[x](bold red)";
        #   vimcmd_symbol = "[<](bold green)";
        # };
        nix_shell = { symbol = "󱄅 "; };
        #   format = ''
        #     $username
        #     $hostname
        #     $character'';
      };
    };
    bash = {
      enable = true;
      historyControl = [ "ignoredups" "ignorespace" ];
      initExtra = ''
        [ -n "$EAT_SHELL_INTEGRATION_DIR" ] && \
          source "$EAT_SHELL_INTEGRATION_DIR/bash"
      '';
    };
    zsh = {
      enable = true;
      package = pkgs.zsh;
      autosuggestion.enable = true;
      enableCompletion = false;
      history = {
        ignoreAllDups = true;
        extended = true;
        size = 999999999;
        save = 999999999;
      };
      syntaxHighlighting = {
        enable = true;
        package = pkgs.zsh-syntax-highlighting;
      };
      defaultKeymap = "emacs";
      initExtra = ''
        export TERM=xterm-256color
        export COLORTERM=truecolor
        setopt interactive_comments
        vterm_printf() {
          if [ -n "$TMUX" ] && ([ "''${TERM%%-*}" = "tmux" ] || [ "''${TERM%%-*}" = "screen" ]); then
            # Tell tmux to pass the escape sequences through
            printf "\ePtmux;\e\e]%s\007\e\\" "$1"
          elif [ "''${TERM%%-*}" = "screen" ]; then
            # GNU screen (screen, screen-256color, screen-256color-bce)
            printf "\eP\e]%s\007\e\\" "$1"
          else
            printf "\e]%s\e\\" "$1"
          fi
        }
        function my-precmd() {
          vterm_printf "51;A$USER@$HOST:$PWD" >$TTY
        }

        autoload -Uz add-zsh-hook
        add-zsh-hook precmd my-precmd

        [ -n "$EAT_SHELL_INTEGRATION_DIR" ] && \
        source "$EAT_SHELL_INTEGRATION_DIR/zsh"

        [ -z "$INSIDE_EMACS" ] && EDITOR="emacsclient --tty" || EDITOR="emacsclient --create-frame"
      '';
      plugins = [
        {
          name = "zsh-autocomplete";
          src = pkgs.fetchFromGitHub {
            owner = "marlonrichert";
            repo = "zsh-autocomplete";
            rev = "cfc3fd9a75d0577aa9d65e35849f2d8c2719b873";
            sha256 = "sha256-QcPNXpTFRI59Oi59WP4XlC+xMyN6aHRPF4UpJ6E1vok=";
          };
        }
        {
          name = "zsh-nix-shell";
          file = "nix-shell.plugin.zsh";
          src = pkgs.fetchFromGitHub {
            owner = "chisui";
            repo = "zsh-nix-shell";
            rev = "82ca15e638cc208e6d8368e34a1625ed75e08f90";
            sha256 = "sha256-Rtg8kWVLhXRuD2/Ctbtgz9MQCtKZOLpAIdommZhXKdE=";
          };
        }
        {
          name = "gradle-completion";
          src = pkgs.fetchFromGitHub {
            owner = "gradle";
            repo = "gradle-completion";
            rev = "25da917cf5a88f3e58f05be3868a7b2748c8afe6";
            sha256 = "sha256-8CNzTfnYd+W8qX40F/LgXz443JlshHPR2I3+ziKiI2c=";
          };
        }
      ];
    };

    git = {
      enable = true;
      extraConfig = {
        core = {
          autocrlf = "false";
          eol = "lf";
        };
        commit = { gpgsign = "true"; };
        init = { defaultBranch = "main"; };
        submodule = { recurse = "true"; };
        user = {
          name = "Thomas Schwanberger";
          email = "thomas@schwanberger.dk";
          signingkey = "217A106699BDAC7C30A1BCA26C981500690C3297";
        };
        github = {
          user = "schwanberger";
          name = "Thomas Schwanberger";
          email = "thomas@schwanberger.dk";
        };
      };
      includes = [
        {
          condition = "gitdir:~/work/";
          path = config.sops.secrets.git_config_work.path;
        }
        {
          condition = "gitdir:/mnt/c/work/";
          path = config.sops.secrets.git_config_work.path;
        }
      ];

    };
    ssh = {
      enable = true;
      controlPath = "~/.ssh/%C";
      includes = [
        "${config.sops.secrets.ssh_config_work.path}"
        "~/.ssh/adhoc_config" # For ad-hoc stuff and staging for new low effort iterations (not in VC)
      ];
      matchBlocks = {
        "github.com" = {
          user = "schwanberger";
          identityFile = "~/.ssh/personal_id_ed25519";
        };
      };
    };
    keychain = {
      enable = true;
      keys = [ ];
    };

    gpg = {
      enable = true;
      settings = { pinentry-mode = "loopback"; };
    };
  };

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 86400;
    maxCacheTtl = 86400;
    # pinentryPackage = pkgs.pinentry-curses;
    pinentryPackage = pkgs.pinentry-tty;
    extraConfig = ''
      allow-loopback-pinentry
    '';
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";
}
