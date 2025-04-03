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

  boot.tmp.useTmpfs = true;

  # Enable networking
  networking = {
    nftables.enable = true;
    firewall = {
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
  };

  networking.nameservers = lib.mkDefault [ "1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one" ];
  services.resolved = {
    enable = true;
    # dnssec = "allow-downgrade";
    fallbackDns = [ "1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one" ];
    dnsovertls = "opportunistic";
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
  ];

  environment.wordlist.enable = true;

  services = {
    fstrim.enable = true;
    gnome.gnome-keyring.enable = true;
    openssh.enable = true;
    tailscale.enable = true;
  };
  systemd.services.tailscaled.serviceConfig.LogLevelMax = lib.mkForce 5;

  programs = {
    zsh = {
      # just for `users.users.fuwa.shell`
      enable = true;
      # I will configure zsh with my .zshrc
      setOptions = [];
    };

    nix-ld.enable = true;

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    mtr.enable = true;

    java = {
      enable = true;
    };

  };

  virtualisation.docker = {
    enable = true;
  };


  # List services that you want to enable:

  # per-user setting doesn't work for now?
  environment.sessionVariables.NIX_PROFILES =
        builtins.concatStringsSep " " (lib.lists.reverseList config.environment.profiles);

}
