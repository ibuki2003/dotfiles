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
      # inputs.neovim-nightly-overlay.overlays.default
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

      libnotify

      alacritty
      albert
      bat
      clang-tools
      cmake
      deno
      discord
      eza
      fd
      fzf
      ghq
      imv
      nil # nix lsp
      nodejs
      ripgrep
      rustup
      sheldon
      slack
      tig
      tmux
      wl-clipboard
      yubikey-manager
      zathura

      (python312.withPackages (ps: [
        ps.pip
        ps.pipx
      ]))
    ];

    pointerCursor = {
      name = "Adwaita";
      package = pkgs.gnome.adwaita-icon-theme;
      size = 16;
      x11 = {
        enable = true;
        defaultCursor = "Adwaita";
      };
    };
  };

  programs = {
    git = {
      enable = true;
    };
    neovim = {
      package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
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
        settings = {
          "browser.fullscreen.autohide" = false;
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          # "browser.uiCustomization.state" = ""; # TODO
        };
      };
    };
  };

  services = {
    kdeconnect = {
      enable = true;
      indicator = true;
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
