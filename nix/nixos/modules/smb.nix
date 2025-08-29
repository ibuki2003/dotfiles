# management of nas mounting
{ config, lib, ... }:
let
  inherit (lib) mkIf mkOption types;
  inherit (types) listOf;
  cfg = config.services.fuwanas;
in {
  options.services.fuwanas = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable fuwanas";
    };
    host = mkOption {
      type = types.str;
      default = "fuwapve-gw"; # via Tailscale
      description = "Hostname of the NAS";
    };
    target = mkOption {
      type = types.str;
      default = "/fuwanas";
      description = "Mount point for the NAS";
    };
    credentialFile = mkOption {
      type = types.str;
      default = "/etc/nixos/fuwanas.cred";
      description = "Path to the credentials file";
    };
    shares = mkOption {
      type = listOf types.str;
      default = [ "fuwa" "fuwa2" "home" ];
      description = "List of shares to mount";
    };
    extraMountOptions = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Extra mount options";
    };
  };

  config = mkIf cfg.enable {
    fileSystems = lib.attrsets.mapAttrs' (name: value: {
      name = "${cfg.target}/${name}";
      inherit value;
    }) (lib.attrsets.genAttrs cfg.shares (share: {
      device = "//${cfg.host}/${share}";
      fsType = "cifs";
      options = [
        "x-systemd.automount"
        "noauto"
        "x-systemd.idle-timeout=1min"
        "x-systemd.device-timeout=5s"
        "x-systemd.mount-timeout=10s"
        "credentials=${cfg.credentialFile}"
        "uid=${toString config.users.users.fuwa.uid}"
        "gid=100"
        "file_mode=0644"
        "dir_mode=0775"
      ] ++ cfg.extraMountOptions;
    }));

  };
}

