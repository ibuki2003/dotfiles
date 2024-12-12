{ pkgs, lib, inputs, ... }:

{
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

  imports =
    [
      ../cachix.nix
    ];

  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
      trusted-users = ["fuwa"];
    };
  };

  # Bootloader.
  # boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  networking.nftables.enable = true;
  networking.firewall = {
    enable = lib.mkDefault true;
    allowedTCPPorts = [ 22 ];
    logRefusedConnections = false;

    trustedInterfaces = [ "tailscale0" ];
  };

  networking.nameservers = lib.mkDefault [ "1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one" ];
  services.resolved = {
    enable = true;
    dnssec = "true";
    fallbackDns = [ "1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one" ];
    dnsovertls = "true";
  };

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
  hardware.pulseaudio.enable = false;
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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.fuwa = {
    isNormalUser = true;
    description = "fuwa";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
    gcc
    clang
    python312
    python312Packages.pip
    python312Packages.pipx
    cachix
    udisks
  ];

  services = {

    xserver = {
      enable = true;
      displayManager = {
        gdm = {
          enable = true;
          wayland = true;
        };
      };
    };

    displayManager = {
      defaultSession = "sway";

      # sddm = {
      #   enable = true;
      #   wayland.enable = true;
      # };
    };

    gnome.gnome-keyring.enable = true;
    playerctld.enable = true;

    # Enable CUPS to print documents.
    printing.enable = true;

    tailscale = {
      enable = true;
    };

    fstrim.enable = true;

    udev.packages = [
      pkgs.yubikey-personalization
    ];

    udisks2.enable = true;

    openssh.enable = true;
  };

  programs = {
    zsh = {
      enable = true;
      # I will configure zsh with my .zshrc
      setOptions = [];
    };
    sway = {
      enable = true;
      # package = pkgs.swayfx;
      # TODO: how to use nvfetcher...?
      # package = (pkgs.swayfx.override(attrs: {
      #   swayfx-unwrapped = (pkgs.swayfx.overrideAttrs (final: prev: {
      #     src = sources.swayfx.src;
      #     version = sources.swayfx.version;
      #   }));
      # }));
      package = inputs.swayfx.packages.${pkgs.system}.default;

      extraPackages = with pkgs; [
        brightnessctl
        dmenu-wayland
        grim
        mako
        rofi
        waybar
        wob
        sway-contrib.grimshot
      ];
      extraSessionCommands = "export XMODIFIERS=@im=fcitx";
    };

    nix-ld.enable = true;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  fonts = {
    packages = with pkgs; [
      noto-fonts-cjk-serif
      noto-fonts-cjk-sans
      noto-fonts-emoji
      hackgen-font
      hackgen-nf-font
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
      exec swaymsg -t subscribe '["shutdown"]' && systemctl --user stop my-graphical-session.target
    '';
    mode = "0644";
  };

}
