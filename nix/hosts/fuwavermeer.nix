{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      ./common.nix
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [
    "amdgpu"
  ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];
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

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/fc84e8bb-6a86-4ac9-b125-bc6d8430c473";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/A32E-EB63";
      fsType = "vfat";
      # options = [ "fmask=0077" "dmask=0077" ];
    };

  fileSystems."/tmp" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "size=32G" "mode=1777" ];
  };

  swapDevices = [ ];

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


  fileSystems."/mnt/arch" = {
    device = "/dev/disk/by-uuid/5acb5921-b991-4127-86a1-bc569995651c";
    fsType = "ext4";
    options = [ "defaults" ];
  };

  fileSystems."/windows" = {
    device = "/dev/disk/by-uuid/BA0A01020A00BD7F";
    fsType = "ntfs";
    options = [ "defaults" ];
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  networking.hostName = "fuwavermeer-nix"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

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
