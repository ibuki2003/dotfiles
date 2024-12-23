{ config, lib, pkgs, modulesPath, inputs, ... }:

{
  imports =
    [
      ./common.nix
      (modulesPath + "/installer/scan/not-detected.nix")
      inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x1-10th-gen
    ];

  networking.hostName = "fuwathink10-nix"; # Define your hostname.

  hardware.cpu.intel.updateMicrocode = true;

  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
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

    "/mnt/arch" = {
      device = "/dev/disk/by-uuid/43c411b5-b0d3-4bed-b6f4-0d22a0a088c5";
      fsType = "ext4";
      options = [ "defaults" ];
    };

    "/windows" = {
      device = "/dev/disk/by-uuid/C4349D48349D3DFC";
      fsType = "ntfs";
      options = [ "defaults" ];
    };
  };

  swapDevices = [ ];

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
    };
  };

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


}
