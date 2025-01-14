{
  inputs,
  pkgs,
  sources,
  lib,
  ...
}: let
  username = "fuwa";
  mypkgs = pkgs.callPackage ./packages { inherit sources; };
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
      plasma-browser-integration

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
      exiftool
      eza
      fd
      ffmpeg
      file
      fzf
      ghq
      gnumake
      gnupg
      gnuplot_qt
      httpie
      htop
      imagemagick
      jq
      plasma5Packages.kdeconnect-kde
      libqalculate
      mold
      moreutils
      ncdu
      nodejs
      openssl
      pamixer
      pciutils
      picotool
      pnpm
      probe-rs-tools
      pulseaudio-ctl
      ripgrep
      rustup
      sheldon
      skktools
      socat
      swayidle
      swaylock-effects
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
      chromium
      mypkgs.discord
      drawio
      gimp-with-plugins
      httpie-desktop
      imv
      inkscape
      kicad
      networkmanagerapplet
      pavucontrol
      remmina
      sdrpp
      slack
      thunderbird-latest
      spotify
      vlc libaacs
      zoom-us

      # lsp servers
      efm-langserver
      emmet-ls
      lua-language-server
      mypkgs.nil # nix lsp
      tinymist
      typescript-language-server
      vscode-langservers-extracted

      # python
      (python312.withPackages (ps: [
        ps.pip
        ps.pipx
        ps.numpy
        ps.matplotlib
      ]))

      # fonts
      hackgen-font
      hackgen-nf-font
      mypkgs.sparks
      udev-gothic
      jetbrains-mono
      mplus-outline-fonts.githubRelease
      rounded-mgenplus

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
      lfs.enable = true;
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
      nativeMessagingHosts = [
        pkgs.plasma-browser-integration
      ];
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

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };


  };

  services = {
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
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "/run/current-system/sw/bin/mkdir -p /tmp/tmp/";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "default.target" ];
  };


  xdg.mimeApps = {
    enable = true;
    defaultApplications = builtins.listToAttrs (
      pkgs.lib.lists.flatten (
        pkgs.lib.attrsets.mapAttrsToList
          (
            k:
            builtins.map (v: {
              name = v;
              value = k;
            })
          )
          {
            "firefox-devedition.desktop" = [
              "text/html"
              "x-scheme-handler/http"
              "x-scheme-handler/https"
            ];
            "imv.desktop" = [
              "image/jpeg"
              "image/png"
              "image/gif"
              "image/bmp"
              "image/webp"
            ];
            "org.pwmt.zathura.desktop" = [
              "application/pdf"
            ];
            "vlc.desktop" = [
              "video/mp4"
              "video/mpeg"
              "video/quicktime"
              "audio/mpeg"
              "audio/x-wav"
            ];
            "thunderbird.desktop" = [
              "x-scheme-handler/mailto"
            ];
          }
        ));
  };

  xdg.autostart.files = [
    (pkgs.makeDesktopItem {
      name = "slack-autostart";
      desktopName = "Slack";
      exec = "slack -u"; # minimize to tray
    })
    (pkgs.makeDesktopItem {
      name = "discord";
      desktopName = "Discord";
      exec = "Discord --start-minimized";
    })
    (pkgs.makeDesktopItem {
      name = "remmina-applet";
      desktopName = "Remmina Applet";
      exec = "remmina -i";
    })
  ];

  programs.home-manager.enable = true;
}
