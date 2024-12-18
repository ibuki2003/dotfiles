{
  description = "fuwa dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    neovim-nightly-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          inputs.neovim-nightly-overlay.overlays.default
        ];
        allowUnfree = true;
      };
      sources = pkgs.callPackage ./nix/_sources/generated.nix {};
    in
  {

    nixosConfigurations = pkgs.lib.attrsets.mapAttrs (k: v: inputs.nixpkgs.lib.nixosSystem ({
      system = "x86_64-linux";
      modules = [ ];
      specialArgs = {
        inherit inputs sources;
      };
    } // v)) {
      vermeer = { modules = [ ./nix/hosts/fuwavermeer.nix ]; };
      fuwathink10 = { modules = [ ./nix/hosts/fuwathink10.nix ]; };
    };

    homeConfigurations = {
      myHome = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = import inputs.nixpkgs {
          system = system;
          config.allowUnfree = true;
          overlays = [
            inputs.neovim-nightly-overlay.overlays.default
          ];
        };
        extraSpecialArgs = {
          inherit inputs sources;
        };
        modules = [
          ./nix/home.nix
        ];
      };
    };
  };
}
