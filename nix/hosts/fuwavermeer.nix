{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      ./common.nix
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    useOSProber = true;
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

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking = {
    interfaces = {
      enp5s0 = {
        ipv4 = {
          addresses = [
            { address = "192.168.0.12"; prefixLength = 24; }
            { address = "192.168.1.12"; prefixLength = 24; } # for NAS multipath
          ];
        };
        wakeOnLan.enable = false;
      };
    };
    defaultGateway = {
      address= "192.168.0.1";
      interface = "enp5s0";
    };
  };
  # networking.interfaces.enp5s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp6s0.useDHCP = lib.mkDefault true;


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

  environment.systemPackages = with pkgs; [
    gcc
    clang
    cachix
  ];

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
