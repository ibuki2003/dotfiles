{
  description = "fuwa dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    swayfx.url = "github:WillPower3309/swayfx";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
  {

    nixosConfigurations = {
      vermeer = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./nix/hosts/fuwavermeer.nix
        ];
        specialArgs = {
          inherit inputs sources;
        };

      };
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
          ./home.nix
        ];
      };
    };
  };
}
