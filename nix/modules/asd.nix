# Anything sync daemon
# https://github.com/graysky2/anything-sync-daemon
{ config, lib, pkgs, sources, ... }:
let
  inherit (lib) mkOption types;
  cfg = config.services.asd;
  asd = pkgs.stdenv.mkDerivation {
    pname = "anything-sync-daemon";
    inherit (sources.asd) src version;

    installPhase = ''
      sed -i '/^\s*sudo /d' Makefile
      sed -i '/^\s*systemctl /d' Makefile
      mkdir -p $out/etc
      make install-bin install-man DESTDIR="$out"
      mv $out/usr/* $out
      rmdir $out/usr
    '';
  };
  path = with pkgs; [
    asd
    rsync
    gawk
    kmod
    util-linux
    pv
    gnutar
    zstd
  ];
in {
  options.services.asd = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to enable asd";
    };

    synclist = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "List of directories to sync";
    };

  };

  config = lib.mkIf cfg.enable {
    systemd = {
      services = {
        asd = {
          enable = true;
          description = "Anything sync daemon";
          wants = [ "asd-resync.service" ];
          wantedBy = [ "multi-user.target" ];
          after = [ "winbindd.service" ];
          stopIfChanged = true; # stop before switching configurations

          inherit path;
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${asd}/bin/anything-sync-daemon sync";
            ExecStop = "${asd}/bin/anything-sync-daemon unsync";
            RemainAfterExit = "yes";
          };
        };
        asd-resync = {
          enable = true;
          description = "ASD timed resync";
          after = [ "asd.service" ];
          wants = [ "asd-resync.timer" ];
          partOf = [ "asd.service" ];
          wantedBy = [ "default.target" ];
          inherit path;
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${asd}/bin/anything-sync-daemon resync";
          };
        };
      };
      timers.asd-resync = {
        description = "ASD timed resync";
        partOf = [
          "asd-resync.service"
          "asd.service"
        ];
        timerConfig = {
          OnUnitActiveSec = "1h";
        };
      };

    };
    environment.etc."asd.conf" = let
      synclist = lib.concatStringsSep " " (map (s: "\"${s}\"") cfg.synclist);
    in {
      text = ''
        #
        # /etc/asd.conf
        #
        WHATTOSYNC=(${synclist})
        #VOLATILE="/tmp"
        ENABLE_HARDLINK_SAFETY_CHECK=1
        USE_OVERLAYFS="yes"
        #USE_BACKUPS="yes"
        #BACKUP_LIMIT=5
      '';
    };
  };
}


