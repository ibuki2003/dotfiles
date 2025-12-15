{
  description = "fuwa dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nil = {
      url = "github:oxalica/nil";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
      system = "x86_64-linux";
      overlays = [
        inputs.neovim-nightly-overlay.overlays.default
        inputs.nil.overlays.nil
        (self: super: {
          cargo-binutils = super.rustPlatform.buildRustPackage (
            let old = super.cargo-binutils; in rec {
              inherit (old) pname meta;
              version = "0.4.0";
              src = super.fetchCrate {
                inherit pname version;
                hash = "sha256-AF1MRBH8ULnHNHT2FS/LxMH+b06QMTIZMIR8mmkn17c=";
              };
              cargoHash = "sha256-pK6pFgOxQdEc4hYFj6mLEiIuPhoutpM2h3OLZgYrf6Q=";
            });
        })
      ];
      pkgs = import nixpkgs {
        inherit system overlays;
        allowUnfree = true;
      };
      sources = pkgs.callPackage ./nix/_sources/generated.nix {};
    in
  {

    nixosConfigurations = pkgs.lib.attrsets.mapAttrs (k: v: inputs.nixpkgs.lib.nixosSystem ({
      system = "x86_64-linux";
      modules = [
        (_: { nixpkgs.overlays = overlays; })
      ] ++ v.modules;
      specialArgs = {
        inherit inputs sources;
      };
    })) {
      fuwavermeer-nix = { modules = [ ./nix/nixos/hosts/fuwavermeer.nix ]; };
      fuwathink10-nix = { modules = [ ./nix/nixos/hosts/fuwathink10.nix ]; };
    };

    homeConfigurations = {
      fuwa = inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit inputs sources;
        };
        modules = [
          inputs.nix-index-database.homeModules.nix-index
          ./nix/home/desktop.nix
        ];
      };
      headless = inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit inputs sources;
        };
        modules = [
          inputs.nix-index-database.homeModules.nix-index
          ./nix/home/base.nix
        ];
      };

      # fuwa@host = headless; # aliases here like this
    };

    apps.${system} = {
      nvfetcher = {
        type = "app";
        program = toString (pkgs.writeShellScript "nvfetcher" ''
          ${pkgs.nvfetcher}/bin/nvfetcher \
            -c ./nix/nvfetcher.toml \
            -o ./nix/_sources \
            "$@"
        '');
      };
    };
  };
}
