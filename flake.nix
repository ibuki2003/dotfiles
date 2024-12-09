{
  description = "fuwa dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
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
      myNixOS = inputs.nixpkgs.lib.nixosSystem {
        system = system;
        modules = [
          ./configuration.nix
        ];
      };
    };
  };
}
