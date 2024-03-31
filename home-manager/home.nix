# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{ inputs, outputs, lib, config, pkgs, ... }: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
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
    yaml-language-server
    nodePackages_latest.bash-language-server
    shellcheck
  ];

  # Enable home-manager and git
  programs.home-manager.enable = true;
  #programs.git.enable = true;

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
    zsh = {
      enable = true;
      package = pkgs.zsh;
      autosuggestion.enable = true;
      enableCompletion = false;
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
      '';
      history.extended = true;
      plugins = [
        {
          name = "zsh-autocomplete";
          src = pkgs.fetchFromGitHub {
            owner = "marlonrichert";
            repo = "zsh-autocomplete";
            rev = "c7b65508fd3a016dc9cdb410af9ee7806b3f9be1";
            sha256 = "sha256-u2BnkHZOSGVhcJvhGwHBdeAOVdszye7QZ324xinbELE=";
          };
        }
        {
          name = "zsh-nix-shell";
          file = "nix-shell.plugin.zsh";
          src = pkgs.fetchFromGitHub {
            owner = "chisui";
            repo = "zsh-nix-shell";
            rev = "8b86281cf9e9ef9f207433dd8b36d157dd48d50a";
            sha256 = "sha256-Z6EYQdasvpl1P78poj9efnnLj7QQg13Me8x1Ryyw+dM=";
          };
        }
        {
          name = "gradle-completion";
          src = pkgs.fetchFromGitHub {
            owner = "gradle";
            repo = "gradle-completion";
            rev = "5bce7f2a6997b9303c8f5803740aa0f11b5cb178";
            sha256 = "sha256-go4N1z/UI3rIEMaWp2SVuDicuBKrGFLSOhDBEUUyYJU=";
          };
        }
      ];
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
