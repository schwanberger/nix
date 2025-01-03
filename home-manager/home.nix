{ inputs, outputs, lib, config, pkgs, ... }:
let
  emacs-unstable-for-doom-emacs = pkgs.emacs-overlay.emacs-unstable;
  another-emacs-unstable-with-packages =
    (pkgs.emacsPackagesFor (pkgs.emacs-overlay.emacs-unstable)).emacsWithPackages # Lucid is the X toolkit defaul value in emacs-overlay
      (epkgs: with epkgs; [
        vterm
        eat
        org-super-agenda
        org-edna
        org-gtd
        tabspaces
        meow
        avy
        consult
        embark
        embark-consult
        vertico
        standard-themes
        marginalia
        nerd-icons
        nerd-icons-completion
        corfu
        nerd-icons-corfu
        nerd-icons-dired
        corfu-terminal
        cape
        kind-icon
        orderless
        wgrep
        nix-mode
        all-the-icons-dired
        transient
        magit
        modus-themes
        ef-themes
        dired-subtree
        gcmh
        envrc
        markdown-mode
        treesit-grammars.with-all-grammars
      ]);
in {
  imports = [
    inputs.nix-doom-emacs-unstraightened.hmModule
    inputs.sops-nix.homeManagerModules.sops
  ];

  home = {
    username = "thsc";
    homeDirectory = "/home/thsc";
  };

  home.packages = with pkgs; [
    another-emacs-unstable-with-packages
    bat
    jfrog-cli
    yq
    jq
    wget
    xclip
    gnumake
    yaml-language-server
    nodePackages.prettier
    unzip
    #nodePackages_latest.bash-language-server
    shellcheck
    nix-tree
    file
    socat

    devenv

    # Latex
    #texlab # lsp
    #texlive.combined.scheme-full
    #evince
    #texlive.combined.scheme-medium

    # Doom Emacs stuff
    (ripgrep.override { withPCRE2 = true; })
    fd
    (aspellWithDicts (ds: with ds; [ en en-computers en-science ]))
    nodejs
    sqlite
    editorconfig-core-c
    zstd
    ansible

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
    (keepass.override { plugins = [ pkgs.keepass-keepasshttp ]; })

    # Secrets
    rage
    sops
    pinentry-tty

    # Langs
    python3
    zulu11

    # Fonts
    dejavu_fonts
    nerd-fonts.symbols-only
    nerd-fonts.jetbrains-mono
    nerd-fonts.iosevka
    nerd-fonts.ubuntu-sans
    # (nerdfonts.override {
    #   fonts = [
    #     "FiraCode"
    #     "JetBrainsMono"
    #     "Iosevka"
    #     "IosevkaTerm"
    #     "IosevkaTermSlab"
    #     "Meslo"
    #     "FiraMono"
    #     "SourceCodePro"
    #     "VictorMono"
    #     "RobotoMono"
    #     "NerdFontsSymbolsOnly"
    #     "Inconsolata"
    #     # "InconsolataGo"
    #     "InconsolataLGC"
    #   ];
    #   enableWindowsFonts = true;
    # })
    iosevka-comfy.comfy-fixed
    iosevka-comfy.comfy-motion-fixed
  ];

  programs.home-manager.enable = true;

  programs.doom-emacs = {
    enable = true;
    doomDir = inputs.doom-config;
    emacs = emacs-unstable-for-doom-emacs;
    extraBinPackages = with pkgs; [ git python3 pinentry-tty pyright ruff ruff-lsp ];
    extraPackages = epkgs:
      with epkgs; [
        vterm
        treesit-grammars.with-all-grammars
        eat
        pinentry
        denote
        esh-autosuggest
        consult-notes
        hyperbole
        standard-themes
        # v: A fix for treemacs, but I don't really use it.
        # treemacs
        # lsp-treemacs
        evil
      ];
    provideEmacs = false;
    experimentalFetchTree = true;
  };

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      # monospace = [ "JetBrainsMonoNL Nerd Font" ];
      # monospace = [ "InconsolataGo Nerd Font Mono" ];
      # monospace = [ "IosevkaTermSlab Nerd Font Mono" ];
      # monospace = [ "IosevkaTerm Nerd Font" ];
      # monospace = [ "Inconsolata Nerd Font" ];
      monospace = [ "Iosevka Comfy Motion Fixed" ];
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
    secrets.access_tokens = {
      sopsFile = ../secrets/secrets.yaml;
    };
  };

  programs = {
    atuin = {
      enable = true;
      enableNushellIntegration = true;
      enableBashIntegration = false;
      enableZshIntegration = false;
    };
    fish = {
      enable = false;
    };
    carapace = {
      enable = true;
      enableNushellIntegration = true;
      enableBashIntegration = true;
      enableZshIntegration = false;
      enableFishIntegration = true;
    };
    direnv = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      enableNushellIntegration = true;
      package = pkgs.direnv;
      nix-direnv.enable = true;
      nix-direnv.package = pkgs.nix-direnv;
    };
    fzf = {
      enable = true;
      package = pkgs.fzf;
      enableZshIntegration = true;
      enableBashIntegration = true;
      enableFishIntegration = false;
    };
    nushell = {
      enable = true;
      package = pkgs.nushell;
    };
    starship = {
      package = pkgs.starship;
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = false;
      enableNushellIntegration = true;
      settings = {
        nix_shell = { symbol = "󱄅 "; };
        hostname.ssh_only = false;
        hostname.style = "bold green";
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
      shellAliases = { "history" = "history 1"; };
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
      controlMaster = "auto";
      controlPath = "~/.ssh/ssh-socket-%C";
      controlPersist = "60m";
      includes = [
        # Too tiresome to handle fluctuating ssh config like this
        # "${config.sops.secrets.ssh_config_work.path}"
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
      enableNushellIntegration = true;
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

  nix.extraOptions = ''
    !include ${config.sops.secrets.access_tokens.path}
'';
}
