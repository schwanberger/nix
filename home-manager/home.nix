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

  # Enable home-manager and git
  programs.home-manager.enable = true;
  #programs.git.enable = true;

  programs = {
    fzf = { enable = true; };
    starship = {
      enable = true;
      enableZshIntegration = true;
    };
    zsh = {
      enable = true;
      package = pkgs.unstable.zsh;
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
      plugins = [
        {
          name = "zsh-autocomplete";
          src = pkgs.fetchFromGitHub {
            owner = "marlonrichert";
            repo = "zsh-autocomplete";
            rev = "afc5afd15fe093bfd96faa521abe0255334c85b0";
            sha256 = "npflZ7sr2yTeLQZIpozgxShq3zbIB5WMIZwMv8rkLJg=";
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
      ];
      oh-my-zsh = {
        enable = true;
        theme = "robbyrussell";
        plugins = [ "git" "fzf" ];
      };
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
