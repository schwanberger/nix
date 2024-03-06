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

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

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
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  # TODO: Set your username
  home = {
    username = "thsc";
    homeDirectory = "/home/thsc";
  };

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  # home.packages = with pkgs; [ steam ];
  home.packages = with pkgs.unstable; [ yaml-language-server ];

  # Enable home-manager and git
  programs.home-manager.enable = true;
  #programs.git.enable = true;

  programs = {
    fzf = {
      enable = true;
      package = pkgs.unstable.fzf;
      enableZshIntegration = true;
    };
    starship = {
      package = pkgs.unstable.starship;
      enable = false;
      enableZshIntegration = true;
      enableBashIntegration = true;
      settings = {
        # add_newline = false;
        # line_break = { disabled = true; };
        character = {
          success_symbol = "[>](green)";
          error_symbol = "[>](red)";
          vimcmd_symbol = "[>](purple)";
        };
        #   format = ''
        #     $username
        #     $hostname
        #     $character'';
      };
    };
    zsh = {
      enable = true;
      package = pkgs.unstable.zsh;
      enableAutosuggestions = true;
      enableCompletion = true;
      syntaxHighlighting = {
        enable = true;
        package = pkgs.unstable.zsh-syntax-highlighting;
      };
      defaultKeymap = "emacs";
      #enableCompletion = false;
      #       initExtra = ''
      # zstyle ':autocomplete:*' min-input 1
      #     '';
      # zplug = {
      #   enable = true;
      #   plugins = [
      #     { name = "zsh-users/zsh-autosuggestions"; } # Simple plugin installation
      #     { name = "zsh-users/zsh-syntax-highlighting"; } # Simple plugin installation
      #     { name = "marlonrichert/zsh-autocomplete"; } # Simple plugin installation
      #     { name = "zdharma-continuum/fast-syntax-highlighting"; } # Simple plugin installation
      #   ];
      # };
      initExtra = "TERM=alacritty-direct";
      history.extended = true;
      plugins = [
        {
          name = "zsh-autocomplete";
          src = pkgs.fetchFromGitHub {
            owner = "marlonrichert";
            repo = "zsh-autocomplete";
            rev = "c7b65508fd3a016dc9cdb410af9ee7806b3f9be1";
            #sha256 = "npflZ7sr2yTeLQZIpozgxShq3zbIB5WMIZwMv8rkLJg=";
            sha256 = "u2BnkHZOSGVhcJvhGwHBdeAOVdszye7QZ324xinbELE=";
          };
        }
        {
          name = "zsh-nix-shell";
          file = "nix-shell.plugin.zsh";
          src = pkgs.fetchFromGitHub {
            owner = "chisui";
            repo = "zsh-nix-shell";
            rev = "v0.7.0";
            sha256 = "149zh2rm59blr2q458a5irkfh82y3dwdich60s9670kl3cl5h2m1";

          };

        }
        {
          name = "gradle-completion";
          src = pkgs.fetchFromGitHub {
            owner = "gradle";
            repo = "gradle-completion";
            rev = "25da917cf5a88f3e58f05be3868a7b2748c8afe6";
            sha256 = "8CNzTfnYd+W8qX40F/LgXz443JlshHPR2I3+ziKiI2c=";
          };
        }
        {
          name = "powerlevel10k";
          src = pkgs.unstable.zsh-powerlevel10k;
          file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
        }
        {
          name = "powerlevel10k-config";
          src = ./p10k-config;
          file = "p10k.zsh";
          #file = "p10k-robbyrussell.zsh";
        }
      ];
      oh-my-zsh = {
        enable = true;
        package = pkgs.unstable.oh-my-zsh;
        theme = "";
        plugins = [ "git" "fzf" ];
      };
    };

    bash = {
      enable = true;
      #package = pkgs.unstable.bash;
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
