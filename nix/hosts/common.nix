{ pkgs, lib, config, sources, ... }:

{
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.enableAllFirmware = true;

  imports =
    [
      ../modules
      ../cachix.nix
    ];

  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes" "pipe-operators"];
      trusted-users = ["fuwa"];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  # Bootloader.
  # boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.tmp.useTmpfs = true;

  hardware.graphics = {
    enable = true;
  };

  # Enable networking
  networking.networkmanager.enable = true;

  networking.nftables.enable = true;
  networking.firewall = {
    enable = lib.mkDefault true;
    allowedTCPPorts = [
      22
    ];
    allowedTCPPortRanges = [
      { from = 1714; to = 1764; } # KDE Connect
    ];
    allowedUDPPorts = [
      41641 # tailscale
    ];
    allowedUDPPortRanges = [
      { from = 1714; to = 1764; } # KDE Connect
    ];

    logRefusedConnections = false;

    trustedInterfaces = [ "tailscale0" ];
  };

  networking.nameservers = lib.mkDefault [ "1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one" ];
  services.resolved = {
    enable = true;
    # dnssec = "allow-downgrade";
    fallbackDns = [ "1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one" ];
    dnsovertls = "opportunistic";
  };
  services.avahi.enable = true;
  services.avahi.nssmdns = true;

  # Set your time zone.
  time.timeZone = "Asia/Tokyo";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.fuwa = {
    uid = 1000;
    isNormalUser = true;
    description = "fuwa";
    extraGroups = [
      "networkmanager"
      "wheel"
      "wireshark"

      "adm"
      "audio"
      "dialout"
      "disk"
      "docker"
      "plugdev"
      "tty"
      "uucp"
      "video"
    ];
    shell = pkgs.zsh;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    wget
    gcc
    clang
    python312
    python312Packages.pip
    python312Packages.pipx
    cachix
    udisks
    cifs-utils

    # somewhy sddm.extraPackages doesn't work
    (pkgs.catppuccin-sddm.override {
      flavor = "macchiato";
      background = "/etc/nixos/sddm-bg.png";
    })
  ];

  environment.wordlist.enable = true;

  services = {

    xserver = {
      enable = true;
    };

    displayManager = {
      sddm = {
        enable = true;
        wayland.enable = true;
        package = pkgs.qt6Packages.sddm; # default to qt5. why?
        extraPackages = [ ];
        theme = "catppuccin-macchiato";
      };
      defaultSession = "sway";
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
        ACTION=="add", SUBSYSTEMS=="usb", KERNEL=="ttyACM[0-9]*", ATTRS{interface}=="YAPicoprobe CDC-SIGROK",  SYMLINK+="ttyPicoSigRok
        ACTION=="add", SUBSYSTEMS=="usb", KERNEL=="ttyACM[0-9]*", ATTRS{interface}=="YAPicoprobe CDC-SysView", SYMLINK+="ttyPicoSysView"
        '';
        destination = "/etc/udev/rules.d/90-picoprobe.rules";
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


    fstrim.enable = true;
    gnome.gnome-keyring.enable = true;
    openssh.enable = true;
    pcscd.enable = true;
    playerctld.enable = true;
    tailscale.enable = true;
    udisks2.enable = true;
  };
  systemd.services.tailscaled.serviceConfig.LogLevelMax = lib.mkForce 5;

  programs = {
    zsh = {
      enable = true;
      # I will configure zsh with my .zshrc
      setOptions = [];
    };
    sway = {
      enable = true;
      package = pkgs.swayfx;

      extraPackages = with pkgs; [
        brightnessctl
        dmenu-wayland
        grim
        mako
        rofi
        waybar
        wob
        sway-contrib.grimshot
        swaybg
      ];
      extraSessionCommands = "export XMODIFIERS=@im=fcitx";
      xwayland.enable = true;
    };
    xwayland = {
      enable = true;
    };

    nix-ld.enable = true;

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    mtr.enable = true;

    obs-studio.enableVirtualCamera = true;

    java = {
      enable = true;
    };

    wireshark = {
      enable = true;
      package = pkgs.wireshark;
    };
  };

  virtualisation.docker = {
    enable = true;
  };


  # List services that you want to enable:

  fonts = {
    packages = with pkgs; [
      noto-fonts-cjk-serif
      noto-fonts-cjk-sans
      noto-fonts-emoji
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

  # per-user setting doesn't work for now?
  environment.sessionVariables.NIX_PROFILES =
        builtins.concatStringsSep " " (lib.lists.reverseList config.environment.profiles);

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
