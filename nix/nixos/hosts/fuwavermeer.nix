{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      ../desktop.nix
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  networking.hostName = "fuwavermeer-nix"; # Define your hostname.

  hardware.cpu.amd.updateMicrocode = true;
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 3;

    extraEntries = {
      "grub.conf" = ''
        title   Arch Linux (GRUB)
        efi    /EFI/archlinux/grubx64.efi
        '';
    };
  };

  fileSystems = {

    "/" = {
      device = "/dev/pool/nixos-root";
      fsType = "btrfs";
      options = [ "defaults" "discard=async" "subvol=@" ];
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/A32E-EB63";
      fsType = "vfat";
      options = [ "defaults" ];
    };

    "/windows" = {
      device = "/dev/disk/by-uuid/BA0A01020A00BD7F";
      fsType = "ntfs";
      options = [ "defaults" ];
    };

    "/data" = {
      device = "/dev/disk/by-uuid/9b548a2f-89db-42a8-b5c4-cecd7db12b2a";
      fsType = "btrfs";
      options = [ "defaults" "discard=async" "compress=zstd" "subvol=@data" ];
    };

  };

  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/" "/data" ];
  };

  services.fuwanas = {
    enable = true;
    host = "192.168.0.64"; # connect directly
    target = "/fuwanas";
    extraMountOptions = [
      "vers=3.11"
      "multichannel"
    ];
  };

  boot.tmp.tmpfsSize = "32G";

  swapDevices = [ ];

  hardware = {
    graphics.extraPackages = with pkgs; [
      rocmPackages.clr.icd
    ];
    amdgpu.opencl.enable = true;
  };
  environment.variables.HSA_OVERRIDE_GFX_VERSION = "10.3.0";
  environment.variables.UV_TORCH_BACKEND = "rocm6.4";
  environment.variables.UV_AMD_GPU_ARCHITECTURE = "gfx1030";

  environment.systemPackages = with pkgs; [
    vulkan-validation-layers
    radeontop
    amdgpu_top
    rocmPackages.rocm-smi

    btrfs-progs
  ];

  networking = {

    firewall.enable = false; # this machine is behind a router

    networkmanager = {
      dhcp = "dhcpcd";
      ensureProfiles = {
        profiles = {
          # auto configuration cannot use dhcpv6 and static ipv4 at the same time?
          enp5s0 = {
            connection = {
              id = "enp5s0";
              type = "ethernet";
              autoconnect-priority = 0;
              interface-name = "enp5s0";
            };
            ethernet.auto-negotiate = true;
            ipv4 = {
              address1 = "192.168.0.12/24,192.168.0.1";
              address2 = "192.168.1.12/24";
              dns = "192.168.0.1";
              method = "manual";
            };
            ipv6 = {
              addr-gen-mode = "stable-privacy";
              method = "auto";
            };
          };
        };
      };
    };

  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    package = pkgs.bluez;
  };
  services.blueman.enable = true;

  services.printing = {
    drivers = lib.mkDefault [
      (pkgs.cnijfilter2.overrideAttrs (oldAttrs: {
        env.NIX_CFLAGS_COMPILE = (oldAttrs.env.NIX_CFLAGS_COMPILE or "") + " -std=gnu17";
      }))
    ];
  };
  hardware.sane = {
    enable = true;
    drivers.scanSnap.enable = true;
    extraBackends = [
      pkgs.sane-airscan
    ];
  };

  services.udev.extraRules = lib.concatStringsSep "\n"
    [
      # c270 usb reset workaround
      ''
        ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="0825", TEST=="power/control", ATTR{power/control}="on"
        ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="0825", TEST=="power/autosuspend", ATTR{power/autosuspend}="123"
    '' ];

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
}
