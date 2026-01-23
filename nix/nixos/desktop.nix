{ pkgs, lib, config, sources, ... }:

{
  imports =
    [
      ./base.nix
    ];

  # Bootloader.
  # boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.graphics = {
    enable = true;
  };

  # Enable networking
  networking = {
    networkmanager.enable = true;
    networkmanager.dhcp = "dhcpcd";
    networkmanager.plugins = with pkgs; [
      networkmanager-openvpn
    ];
    dhcpcd = {
      persistent = true;
    };
  };

  services.avahi.enable = true;
  services.avahi.openFirewall = true;
  services.avahi.nssmdns4 = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  security.pam.services.sddm-greeter.enableGnomeKeyring = true;

  environment.systemPackages = with pkgs; [

    steam-run

    # somewhy sddm.extraPackages doesn't work
    (pkgs.catppuccin-sddm.override {
      flavor = "macchiato";
      # background = "/etc/nixos/sddm-bg.png";
      background = "/etc/nixos/sddm-bg.png" + "\"'; true '"; # HACK: shell injection. waiting for NixOS/nixpkgs#442829
    })

  ];

  services = {

    xserver = {
      enable = true;

      # https://wiki.nixos.org/wiki/Fcitx5#Fcitx5_Doesn't_Start_When_Using_WM
      desktopManager.runXdgAutostartIfNone = true;
    };

    displayManager = {
      sddm = {
        enable = true;
        wayland.enable = true;
        package = pkgs.qt6Packages.sddm; # default to qt5. why?
        extraPackages = [ ];
        theme = "catppuccin-macchiato-mauve";
      };
      defaultSession = "niri";
    };

    # Enable CUPS to print documents.
    printing.enable = true;

    udev.packages = [
      pkgs.yubikey-personalization
      # allow users to access *ALL* USB devices
      (pkgs.writeTextFile {
        name = "udev-usb-rules";
        text = ''
          SUBSYSTEM=="usb", MODE="0660", TAG+="uaccess"
        '';
        # must be loaded before 73-seat-late.rules
        # https://github.com/systemd/systemd/issues/4288#issuecomment-348166161
        destination = "/etc/udev/rules.d/70-usb.rules";
      })
      (pkgs.writeTextFile {
        name = "yapicoprobe-udev-rules";
        text = ''
        # create COM port for target CDC
        ACTION=="add", SUBSYSTEMS=="usb", KERNEL=="ttyACM[0-9]*", ATTRS{interface}=="YAPicoprobe CDC-UART",    SYMLINK+="ttyPicoTarget"
        ACTION=="add", SUBSYSTEMS=="usb", KERNEL=="ttyACM[0-9]*", ATTRS{interface}=="YAPicoprobe CDC-DEBUG",   SYMLINK+="ttyPicoProbe"
        ACTION=="add", SUBSYSTEMS=="usb", KERNEL=="ttyACM[0-9]*", ATTRS{interface}=="YAPicoprobe CDC-SIGROK",  SYMLINK+="ttyPicoSigRok"
        ACTION=="add", SUBSYSTEMS=="usb", KERNEL=="ttyACM[0-9]*", ATTRS{interface}=="YAPicoprobe CDC-SysView", SYMLINK+="ttyPicoSysView"
        '';
        destination = "/etc/udev/rules.d/90-picoprobe.rules";
      })
      (pkgs.writeTextFile {
        name = "sipeed-udev-rules";
        text = ''
        ATTRS{idVendor}=="359f", ATTRS{idProduct}=="3101", ENV{ID_MM_DEVICE_IGNORE}="1"
        '';
        destination = "/etc/udev/rules.d/49-sipeed.rules";
      })

      (pkgs.writeTextFile {
        name = "xilinx-drivers";
        text = ''
        # 52-xilinx-digilent-usb.rules
        ATTRS{idVendor}=="1443", MODE:="666"
        ACTION=="add", ATTRS{idVendor}=="0403", ATTRS{manufacturer}=="Digilent", MODE:="666"

        # 52-xilinx-ftdi-usb.rules
        ACTION=="add", ATTRS{idVendor}=="0403", ATTRS{manufacturer}=="Xilinx", MODE:="666"

        # 52-xilinx-pcusb.rules
        ATTR{idVendor}=="03fd", ATTR{idProduct}=="0008", MODE="666"
        ATTR{idVendor}=="03fd", ATTR{idProduct}=="0007", MODE="666"
        ATTR{idVendor}=="03fd", ATTR{idProduct}=="0009", MODE="666"
        ATTR{idVendor}=="03fd", ATTR{idProduct}=="000d", MODE="666"
        ATTR{idVendor}=="03fd", ATTR{idProduct}=="000f", MODE="666"
        ATTR{idVendor}=="03fd", ATTR{idProduct}=="0013", MODE="666"
        ATTR{idVendor}=="03fd", ATTR{idProduct}=="0015", MODE="666"
        '';
        destination = "/etc/udev/rules.d/52-xilinx.rules";
      })
    ];


    pcscd.enable = true;
    playerctld.enable = true;
    udisks2.enable = true;
    fwupd.enable = true;
    upower.enable = true;
  };
  systemd.services.tailscaled.serviceConfig.LogLevelMax = lib.mkForce 5;

  programs = {
    sway = {
      enable = true;
      package = pkgs.swayfx;

      extraSessionCommands = "export XMODIFIERS=@im=fcitx";
      xwayland.enable = true;
    };
    xwayland = {
      enable = true;
    };
    niri.enable = true;
    niri.package = pkgs.niri.overrideAttrs (finalAttrs: prevAttrs: {
      # patch to enable blur effect
      # #1634 https://github.com/visualglitch91/niri/tree/feat/blur
      src = pkgs.fetchFromGitHub {
        owner = "visualglitch91";
        repo = "niri";
        rev = "d89bfc6c94aee3af14c35508e7c110c0ea8f1682";
        hash = "sha256-2EggcED68efzYJAG5VqGshh+hfQbQq5sRvrtT1NNPo8=";
      };
      cargoHash = "sha256-CXRI9LBmP2YXd2Kao9Z2jpON+98n2h7m0zQVVTuwqYQ=";
      cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
        inherit (finalAttrs) pname src version;
        hash = finalAttrs.cargoHash;
      };
    });

    obs-studio = {
      enable = true;
      enableVirtualCamera = true;
    };

    wireshark = {
      enable = true;
      package = pkgs.wireshark;
    };

    steam = {
      enable = true;
      package = pkgs.steam.override {
        extraPkgs = pkgs: with pkgs; [ migu ];
      };
    };
  };

  fonts = {
    packages = with pkgs; [
      noto-fonts-cjk-serif
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
    ];
    fontDir.enable = false;
    fontconfig = {
      defaultFonts = {
        serif = ["Noto Serif CJK JP" "Noto Color Emoji"];
        sansSerif = ["Noto Sans CJK JP" "Noto Color Emoji"];
        monospace = ["Noto Sans Mono CJK JP" "Noto Color Emoji"];
        emoji = ["Noto Color Emoji"];
      };
    };
  };

  # HACK: hook graphical-session.target
  # https://github-wiki-see.page/m/swaywm/sway/wiki/Systemd-integration
  systemd.user.targets."my-graphical-session" = {
    enable = true;
    description = "Hack to hook graphical-session.target manually";
    bindsTo = ["graphical-session.target"];
    wants = [ "graphical-session-pre.target" ];
    after = [ "graphical-session-pre.target" ];
  };
  environment.etc."sway/config.d/00-graphical-session-hook.conf" = {
    text = ''
      exec "systemctl --user import-environment {,WAYLAND_}DISPLAY SWAYSOCK; systemctl --user start my-graphical-session.target"
      # HACK: wait for sway exit
      exec swaymsg -mt subscribe '[]' || true && systemctl --user stop my-graphical-session.target
    '';
    mode = "0644";
  };

  # blacklist some kernel modules
  hardware.rtl-sdr.enable = true;

  xdg.portal = {
    enable = true;
    wlr.enable = true;
  };
}
