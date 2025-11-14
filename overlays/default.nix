# This file defines overlays
{ inputs, ... }: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs { pkgs = final; };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev:
    {
      # example = prev.example.overrideAttrs (oldAttrs: rec {
      # ...
      # });
    };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.stable'
  stable-packages = final: _prev: {
    stable = import inputs.nixpkgs-stable {
      system = final.system;
      config.allowUnfree = true;
    };
  };

  master-packages = final: _prev: {
    master = import inputs.nixpkgs-master {
      system = final.system;
      config.allowUnfree = true;
      # overlays = [ (import inputs.nixpkgs-master) ];
    };
  };

  emacs-overlay = final: _prev: {
    emacs-overlay = import inputs.nixpkgs {
      system = final.system;
      config.allowUnfree = true;
      overlays = [ (import inputs.emacs-overlay) ];
    };
  };

  # doom-emacs-overlay = final: _prev: {
  #   doom-emacs-overlay = import inputs.nixpkgs {
  #     system = final.system;
  #     config.allowUnfree = true;
  #     overlays = (import inputs.nix-doom-emacs-unstraightened);
  #   };
  # };
}
