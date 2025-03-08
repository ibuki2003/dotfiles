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
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [
        "googleearth-pro-7.3.6.10201"
      ];
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
      android-tools
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
      edir
      exiftool
      eza
      fd
      ffmpeg
      file
      fzf
      gh
      ghq
      gnumake
      gnupg
      gnuplot_qt
      googleearth-pro
      httpie
      htop
      imagemagick
      jq
      libqalculate
      minicom
      mold
      moreutils
      ncdu
      nodejs
      openssl
      p7zip
      pamixer
      pciutils
      picotool
      pnpm
      pulseaudio
      procs
      pulseaudio-ctl
      ranger
      ripgrep
      rustup
      sheldon
      skktools
      socat
      swayidle
      swaylock-effects
      pdftk
      tig
      tmux
      typst
      unzipNLS
      usbutils
      vim
      wayvnc
      wl-clipboard
      xxd
      yubikey-manager
      zathura

      # cargo tools
      cargo-binutils
      cargo-bloat
      cargo-edit
      cargo-expand
      probe-rs-tools

      # desktop apps
      alacritty
      albert
      audacity
      chromium
      (cutter.withPlugins (ps: with ps; [
        rz-ghidra
        jsdec
      ]))
      mypkgs.discord
      drawio
      font-manager
      gimp-with-plugins
      httpie-desktop
      imhex
      imv
      inkscape
      kicad
      libreoffice-fresh
      mpv
      networkmanagerapplet
      nwg-displays
      obs-studio
      pavucontrol
      prismlauncher
      remmina
      sdrpp
      slack
      thunderbird-latest
      spotify
      vlc libaacs
      wdisplays
      zoom-us

      # lsp servers
      efm-langserver
      emmet-ls
      lua-language-server
      nil # nix lsp
      tinymist
      typescript-language-server
      vscode-langservers-extracted
      pyright
      verible
      intelephense

      # python
      (python312.withPackages (ps: with ps; [
        pip
        numpy
        (matplotlib.override { enableQt = true; })
        scipy
        python-lsp-server
      ]))

      # fonts
      hackgen-font
      hackgen-nf-font
      mypkgs.sparks
      udev-gothic
      jetbrains-mono
      mplus-outline-fonts.githubRelease
      rounded-mgenplus
      material-design-icons
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
      package = pkgs.neovim;
      enable = true;
      defaultEditor = true;
    };
    firefox = {
      enable = true;
      package = pkgs.firefox-devedition;
      nativeMessagingHosts = [
        pkgs.kdePackages.plasma-browser-integration
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
          "security.mixed_content.block_active_content" = false;
          "network.security.ports.banned.override" = "1-65535";
          # "browser.uiCustomization.state" = ""; # TODO
        };
      };
    };

    fcitx5skk = {
      dictionaries = (
        with pkgs.skkDictionaries; [ l geo station jis2 jis3_4 assoc ] ++
        [
          (pkgs.fetchurl {
            url = "https://github.com/ibuki2003/skk_dics/releases/download/untagged-b135c1c0e0d8fb30f981/wikipedia_with_descripts_sorted.utf8.txt";
            hash = "sha256-6a6Wh256nozUC62jMQWrPONet3TOKTpYgMAg93BahH0=";
          })
          "${sources.skkemoji.src}/SKK-JISYO.emoji.utf8"
        ]
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

  services.kdeconnect.enable = true;
  systemd.user.services.kdeconnect.Service.Restart = lib.mkForce "always";

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
