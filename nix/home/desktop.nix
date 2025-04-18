{
  pkgs,
  sources,
  lib,
  ...
}: let
  username = "fuwa";
  mypkgs = pkgs.callPackage ../packages { inherit sources; };
in {
  imports = [
    ./base.nix
  ];

  nixpkgs = {
    config = {
      permittedInsecurePackages = [
        "googleearth-pro-7.3.6.10201"
      ];
    };
  };

  home = {
    packages = with pkgs; [

      # libraries
      libnotify
      qt5.qtbase
      qt6.qtbase

      # tools
      pamixer
      pulseaudio
      pulseaudio-ctl
      swayidle
      swaylock-effects
      wayvnc
      wl-clipboard
      yubikey-manager

      # apps
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

      # fonts
      hackgen-font
      hackgen-nf-font
      mypkgs.sparks
      udev-gothic
      jetbrains-mono
      mplus-outline-fonts.githubRelease
      rounded-mgenplus
      material-design-icons
      migu

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
    firefox = {
      enable = true;
      package = pkgs.firefox-devedition;
      nativeMessagingHosts = [
        pkgs.kdePackages.plasma-browser-integration
      ];
      profiles.dev-edition-default = {
        isDefault = true;
        userChrome = builtins.readFile ../../etc/firefox/userChrome.css;
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

  };

  qt.enable = true;

  services = {
    copyq = {
      enable = true;
      forceXWayland = false;
    };
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

  home.sessionVariables.BROWSER = "firefox-devedition";

  fonts.fontconfig.enable = true;
  xdg.configFile."fontconfig/conf.d/99-local.conf".text = ''
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
    <fontconfig>
      <dir>/home/${username}/.fonts</dir>
    </fontconfig>
    '';

  xdg.configFile."fontconfig/conf.d/90-steam.conf".text = ''
     <?xml version="1.0"?>
     <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
     <fontconfig>
       <description>Change default fonts for Steam client</description>
       <match>
         <test name="prgname">
           <string>steamwebhelper</string>
         </test>
         <test name="family" qual="any">
           <string>sans-serif</string>
         </test>
         <edit mode="prepend" name="family">
           <string>Migu 1P</string>
         </edit>
       </match>
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
