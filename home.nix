{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: let
  username = "fuwa";
in {
  nixpkgs = {
    overlays = [
      inputs.neovim-nightly-overlay.overlays.default
    ];
    config = {
      allowUnfree = true;
    };
  };

  home = {
    username = username;
    homeDirectory = "/home/${username}";

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "24.05";

    packages = with pkgs; [
      neovim
      clang-tools
      sheldon
    ];
  };

  programs.home-manager.enable = true;
}
