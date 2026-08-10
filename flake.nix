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
    deferred-apps.url = "github:WitteShadovv/deferred-apps";
    deferred-apps.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    skk-zenz.url = "github:ibuki2003/skk_zenz";
    skk-zenz.inputs.nixpkgs.follows = "nixpkgs";

  };

  outputs =
    {
      nixpkgs,
      ...
    }@inputs:
    let
      defaultSystem = "x86_64-linux";

      sources = pkgs.callPackage ./nix/_sources/generated.nix { };
      mkPkgs =
        {
          system ? defaultSystem,
          rocmSupport ? false,
        }:
        import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            inherit rocmSupport;
          };
          overlays = [
            inputs.neovim-nightly-overlay.overlays.default
            (import ./nix/overlay.nix { inherit inputs sources; })
          ];
        };
      pkgs = mkPkgs { }; # deafult pkgs
    in
    {

      nixosConfigurations =
        let
          makeNixOSConfig =
            {
              system ? defaultSystem,
              rocmSupport ? false,
              modules ? [ ],
            }:
            let
              pkgs = mkPkgs { inherit system rocmSupport; };
            in
            inputs.nixpkgs.lib.nixosSystem {
              inherit system;
              modules = [
                (_: { nixpkgs.pkgs = pkgs; })
              ]
              ++ modules;
              specialArgs = {
                inherit inputs sources;
              };
            };
        in
        {
          fuwavermeer-nix = makeNixOSConfig {
            modules = [ ./nix/nixos/hosts/fuwavermeer.nix ];
            rocmSupport = true;
          };
          fuwathink10-nix = makeNixOSConfig { modules = [ ./nix/nixos/hosts/fuwathink10.nix ]; };
        };

      homeConfigurations =
        let
          makeHomeConfig =
            {
              system ? defaultSystem,
              rocmSupport ? false,
              modules ? [ ],
            }:
            let
              pkgs = mkPkgs { inherit system rocmSupport; };
            in
            inputs.home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              extraSpecialArgs = {
                inherit inputs sources;
              };
              modules = [
                inputs.nix-index-database.homeModules.nix-index
                ./nix/home/base.nix
              ]
              ++ modules;
            };
        in
        {
          fuwa = makeHomeConfig { modules = [ ./nix/home/desktop.nix ]; };
          "fuwa@fuwavermeer-nix" = makeHomeConfig {
            modules = [ ./nix/home/desktop.nix ];
            rocmSupport = true;
          };
          headless = makeHomeConfig { };
        };

      apps.${defaultSystem} = {
        nvfetcher = {
          type = "app";
          program = toString (
            pkgs.writeShellScript "nvfetcher" ''
              ${pkgs.nvfetcher}/bin/nvfetcher \
                -c ./nix/nvfetcher.toml \
                -o ./nix/_sources \
                "$@"
            ''
          );
        };
      };
    };
}
