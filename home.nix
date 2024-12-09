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

    # avoid warning
    enableNixpkgsReleaseCheck = false;

    packages = with pkgs; [
      clang-tools
      deno
      alacritty
      sheldon
      albert
      ripgrep
      fd
      eza
      nodejs
      nil # nix lsp
      tmux
      bat
      python3
      rustup
      zsh # use my .zshrc

      sway
      brightnessctl
      grim
      rofi
      mako
      waybar
    ];
  };

  programs = {
    git = {
      enable = true;
    };
    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };
    firefox = {
      enable = true;
      package = pkgs.firefox-devedition;
      profiles.dev-edition-default = {
        isDefault = true;
        userChrome = builtins.readFile ./etc/firefox/userChrome.css;
      };
    };
  };

  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5 = {
      # waylandFrontend = true;
      addons = [pkgs.fcitx5-skk];
    };
  };


  programs.home-manager.enable = true;
}
