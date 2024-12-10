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

      # libraries
      libnotify

      # tools
      alacritty
      albert
      bat
      bottom
      clang-tools
      cmake
      deno
      dex
      dig
      discord
      dogdns
      eza
      fd
      ffmpeg
      fzf
      ghq
      gimp-with-plugins
      htop
      imagemagick
      imv
      inkscape
      jq
      networkmanagerapplet
      nil # nix lsp
      nodejs
      pamixer
      pavucontrol
      pciutils
      pnpm
      pulseaudio-ctl
      ripgrep
      rustup
      sheldon
      skktools
      slack
      tig
      tmux
      usbutils
      wl-clipboard
      yubikey-manager
      zathura

      # lsp servers
      efm-langserver
      emmet-ls
      lua-language-server
      tinymist

      # python
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
          "browser.tabs.inTitlebar" = 0;
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
      addons = [
        pkgs.fcitx5-skk
        pkgs.skk-dicts
      ];
    };
  };


  programs.home-manager.enable = true;
}
