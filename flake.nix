{
  description = "fuwa dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    neovim-nightly-overlay.url ="github:nix-community/neovim-nightly-overlay";
    home-manager = {
      url = "github:nix-community/home-manager";
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
      pkgs = import nixpkgs { inherit system; };
    in
  {

    apps.${system} = {
      update = {
        type = "app";
        program = toString (pkgs.writeShellScript "update-script" ''
          set -e
          nix flake update
          nix run 'nixpkgs#home-manager' -- switch --flake '.#myHomeConfig'
        '');
      };

      install = {
        type = "app";
        program = toString (pkgs.writeShellScript "update-script" ''
          set -e
          nix run 'nixpkgs#home-manager' -- switch --flake '.#myHomeConfig'
        '');
      };
    };

    homeConfigurations = {
      myHomeConfig = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgs;
        extraSpecialArgs = {
          inherit inputs;
        };
        modules = [
          ./home.nix
        ];
      };
    };
  };
}
