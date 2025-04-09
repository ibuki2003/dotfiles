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


    waveforms = {
      url = "github:liff/waveforms-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
      fuwavermeer = { modules = [ ./nix/nixos/hosts/fuwavermeer.nix ]; };
      fuwathink10 = { modules = [ ./nix/nixos/hosts/fuwathink10.nix ]; };
    };

    homeConfigurations = {
      myHome = inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit inputs sources;
        };
        modules = [
          ./nix/home/desktop.nix
        ];
      };
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
