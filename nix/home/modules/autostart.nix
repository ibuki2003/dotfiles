{ config, lib, ... }:

let
  inherit (lib) mkOption types;
  cfg = config.services.autostart;
in
{
  options.services.autostart = mkOption {
    type = types.attrsOf (
      types.submodule {
        options.exec = mkOption {
          type = types.str;
          description = "Command to start with the graphical session. Note that this is not a shell command, but a string for ExecStart= in systemd.";
        };
      }
    );
    default = { };
    description = "Applications to start with the graphical session.";
  };

  config.systemd.user.services = lib.mapAttrs' (
    name: app:
    lib.nameValuePair "autostart-${name}" {
      Unit = {
        Description = "Autostart ${name}";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        Type = "exec";
        ExitType = "cgroup";
        ExecStart = app.exec;
        Restart = "no";
        TimeoutStopSec = "5s";
        Slice = "app.slice";
        StandardOutput = "null";
        StandardError = "null";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    }
  ) cfg;
}
