{
  pkgs,
  sources,
  lib,
  # inputs,
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
      ];
    };
    overlays = [
      # https://github.com/NixOS/nixpkgs/issues/493679#issuecomment-3959962976
      # failure of jetbrains-mono
      (final: prev: {
        pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
          (python-final: python-prev: {
            picosvg = python-prev.picosvg.overridePythonAttrs (oldAttrs: {
              doCheck = false;
            });
          })
        ];
      })
    ];
  };

  home = {
    packages = with pkgs; [

      # libraries
      libnotify
      qt5.qtbase
      qt6.qtbase

      # desktop tools
      brightnessctl
      dmenu-wayland
      grim
      mako
      rofi
      waybar
      wob
      sway-contrib.grimshot
      swaybg
      nirius

      # tools
      appimage-run
      libsecret
      pamixer
      pulseaudio
      pulseaudio-ctl
      qrencode
      swayidle
      hyprlock
      swaylock-effects
      wayvnc
      wl-clipboard
      yt-dlp
      yubikey-manager
      zbar

      # apps
      aider-chat
      alacritty
      albert
      audacity
      chromium
      codex
      (cutter.withPlugins (ps: with ps; [
        rz-ghidra
        jsdec
      ]))
      mypkgs.discord
      drawio
      font-manager
      gimp-with-plugins
      httpie-desktop
      # imhex
      imv
      inkscape
      kicad
      kitty
      lan-mouse
      libreoffice-fresh
      mpv
      networkmanagerapplet
      # nwg-displays
      obs-studio
      pavucontrol
      prismlauncher
      (quickshell.overrideAttrs (oldAttrs: {
        src = sources.quickshell.src;
        buildInputs = oldAttrs.buildInputs ++ [ pkgs.polkit ];
      }))
      ranger
      remmina
      ripdrag
      # sdrpp
      seahorse
      skktools
      slack
      spotify
      tdf
      timg
      thunderbird-latest
      viu
      vlc libaacs
      wdisplays
      zathura
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


      # niri deps
      xdg-desktop-portal
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
      xwayland-satellite


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
            url = "https://fuwa.dev/Downloads/wikipedia_with_descripts_sorted.utf8.txt";
            hash = "sha256-P2kfibj4AOZrmsU04qwSsXR/zTXooovlyL5P7ODOrtM=";
          })
          "${sources.skkemoji.src}/SKK-JISYO.emoji.utf8"
          "${../../etc/skk/symbols.sorted.utf8.txt}"
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
    mpris-proxy = {
      enable = true;
    };
  };

  services.kdeconnect.enable = true;
  systemd.user.services.kdeconnect.Service.Restart = lib.mkForce "always";

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
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
