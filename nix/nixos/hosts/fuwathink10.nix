{ config, lib, pkgs, modulesPath, inputs, ... }:

{
  imports =
    [
      ../desktop.nix
      (modulesPath + "/installer/scan/not-detected.nix")
      inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x1-10th-gen
    ];

  networking.hostName = "fuwathink10-nix"; # Define your hostname.

  hardware.cpu.intel.updateMicrocode = true;

  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.kernelParams = [
    # power save
    "i915.enable_dc=4"
    "i915.enable_fbc=1"
    "i915.enable_guc=1"
  ];

  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 3;

    extraEntries = {
      "grub.conf" = ''
        title   Arch Linux
        efi    /EFI/archlinux/grubx64.efi
        '';
    };
  };

  fileSystems = {
    "/" =
      { device = "/dev/disk/by-uuid/b5fe4aa7-3d1e-421b-b468-05b07bc4abdc";
        fsType = "ext4";
      };

    "/boot" =
      { device = "/dev/disk/by-uuid/D09B-2897";
        fsType = "vfat";
        #options = [ "fmask=0077" "dmask=0077" ];
      };

    "/tmp" = {
      device = "none";
      fsType = "tmpfs";
      options = [ "size=32G" "mode=1777" ];
    };

    "/windows" = {
      device = "/dev/disk/by-uuid/C4349D48349D3DFC";
      fsType = "ntfs";
      options = [ "defaults" ];
    };
  };

  services.fuwanas = {
    enable = true;
    target = "/fuwanas";
    extraMountOptions = [
      "vers=3.11"
    ];
  };


  swapDevices = [ {
    device = "/swapfile";
    size = 8 * 1024; # [MiB] = 8 GiB
    priority = 10;
    discardPolicy = "both";
  } ];

  zramSwap = {
    enable = true;
    priority = 100;
  };
  boot.kernel.sysctl."vm.swappiness" = 30;


  hardware.graphics = {
    extraPackages = with pkgs; [
      intel-media-driver
    ];
  };
  environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; };

  networking = {
    firewall.enable = false; # this machine is behind a router
    networkmanager = {
      dhcp = "dhcpcd";
      wifi.powersave = true;
    };
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    package = pkgs.bluez;
  };
  services.blueman.enable = true;

  fonts = {
    fontconfig.localConf = ''
      <?xml version="1.0"?>
      <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
      <fontconfig>
        <dir>/windows/Windows/Fonts</dir>
      </fontconfig>
    '';
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

  services.asd = {
    enable = true;
    synclist = [ "/opt/batlog/log" ];
  };
  systemd.services."batlog" = {
    enable = true;
    description = "battery logger";
    serviceConfig = {
      Type = "simple";
      # TODO: manage this script with nix
      ExecStart = "/opt/batlog/logger";
      Restart = "always";
    };
    wantedBy = [ "multi-user.target" ];
  };

  # start on boot
  systemd.services.fprintd = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "simple";
  };
  services.fprintd = {
    enable = true;
  };
  security.pam.services.login.fprintAuth = false;
  security.pam.services.sudo.fprintAuth = true;
  security.pam.services.swaylock.fprintAuth = true;

  services.tlp.enable = true;
  services.tlp.settings = {

    CPU_SCALING_GOVERNOR_ON_AC = "performance";
    CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    CPU_BOOST_ON_AC = "1";
    CPU_BOOST_ON_BAT = "0";
    CPU_HWP_DYN_BOOST_ON_AC = "1";
    CPU_HWP_DYN_BOOST_ON_BAT = "0";

    PLATFORM_PROFILE_ON_AC = "performance";
    PLATFORM_PROFILE_ON_BAT = "balanced";

    START_CHARGE_THRESH_BAT0 = "90";
    STOP_CHARGE_THRESH_BAT0 = "95";
    RESTORE_THRESHOLDS_ON_BAT = "1";
  };


}
