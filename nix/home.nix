{
  inputs,
  pkgs,
  sources,
  ...
}: let
  username = "fuwa";
in {
  imports = [
    ./home_modules
  ];

  nixpkgs = {
    overlays = [
      # inputs.neovim-nightly-overlay.overlays.default
    ];
    config = {
      allowUnfree = true;
    };
  };
  nix.package = pkgs.nix;

  home = {
    username = username;
    homeDirectory = "/home/${username}";

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "24.05";

    # avoid warning
    enableNixpkgsReleaseCheck = false;

    packages = with pkgs; [

      # nix tools
      nixfmt-rfc-style

      # libraries
      libnotify

      # tools
      atop
      bat
      bottom
      clang-tools
      cmake
      deno
      dex
      delta
      dig
      dogdns
      eza
      fd
      ffmpeg
      file
      fzf
      ghq
      gnupg
      gnuplot
      htop
      imagemagick
      jq
      libqalculate
      nodejs
      pamixer
      pciutils
      pnpm
      pulseaudio-ctl
      ripgrep
      rustup
      sheldon
      skktools
      tig
      tmux
      unzipNLS
      usbutils
      vim
      wl-clipboard
      xxd
      yubikey-manager
      zathura

      # desktop apps
      alacritty
      albert
      audacity
      # discord
      (pkgs.callPackage ./packages/discord_raw.nix {})
      gimp-with-plugins
      imv
      inkscape
      kicad
      networkmanagerapplet
      pavucontrol
      slack
      spotify
      zoom-us

      # lsp servers
      efm-langserver
      emmet-ls
      lua-language-server
      # nil # nix lsp
      (pkgs.callPackage ./packages/nil.nix { inherit sources; })
      tinymist

      # python
      (python312.withPackages (ps: [
        ps.pip
        ps.pipx
      ]))
    ];

    pointerCursor = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
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
      # TODO: using overlay doesn't seem to use binary cache?
      # package = pkgs.neovim;
      package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
      enable = true;
      defaultEditor = true;
    };
    firefox = {
      enable = true;
      package = pkgs.firefox-devedition;
      profiles.dev-edition-default = {
        isDefault = true;
        userChrome = builtins.readFile ../etc/firefox/userChrome.css;
        settings = {
          "browser.aboutConfig.showWarning" = false;
          "browser.fullscreen.autohide" = false;
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          "browser.tabs.inTitlebar" = 0;
          "browser.zoom.siteSpecific" = false;
          "findbar.highlightAll" = true;
          # "browser.uiCustomization.state" = ""; # TODO
        };
      };
    };

    fcitx5 = {
      dictionaries = (
        with pkgs.skkDictionaries; [ l geo station jis2 jis3_4 assoc ]
      );
    };

  };

  services = {
    kdeconnect = {
      enable = true;
      indicator = true;
    };
    syncthing = {
      enable = true;
    };
    gpg-agent = {
      enable = true;
      enableSshSupport = false;
      pinentryPackage = pkgs.pinentry-all;
      maxCacheTtl = 8640000; # 100 days
      defaultCacheTtl = 8640000; # 100 days
    };
    ssh-agent.enable = true;
  };

  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5 = {
      addons = [
        pkgs.fcitx5-skk
      ];
    };
  };
  # note: https://github.com/nix-community/home-manager/issues/1011
  home.sessionVariables.XMODIFIERS = "@im=fcitx";

  fonts.fontconfig.enable = true;
  xdg.configFile."fontconfig/conf.d/99-local.conf".text = ''
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
    <fontconfig>
      <dir>/home/${username}/.fonts</dir>
    </fontconfig>
    '';

  systemd.user.services.tmptmp = {
    Unit.Description = "mkdir /tmp/tmp/";
    Service = {
      ExecStart = "mkdir -p /tmp/tmp/";
      # Restart = ""; # TODO:
    };
    Install.WantedBy = [ "multi-user.target" ];
  };


  programs.home-manager.enable = true;
}
