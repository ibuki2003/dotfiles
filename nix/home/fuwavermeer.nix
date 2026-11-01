{ pkgs, lib, ... }:
{
  systemd.user =
    let
      jobs = {
        "00:50" = ''
          ${pkgs.libnotify}/bin/notify-send -u critical "あと10分で寝る時間です"
        '';
        "01:00" = ''
          ${pkgs.libnotify}/bin/notify-send -u critical "寝る時間です。ブラウザを閉じます"
          ${pkgs.procps}/bin/pkill -f firefox-devedition || true
        '';
        "01:15" = ''
          ${pkgs.libnotify}/bin/notify-send -u critical "はよ寝ろ"
          ${pkgs.procps}/bin/pkill -f firefox-devedition || true
          sleep 5
          ${pkgs.hyprlock}/bin/hyprlock || true
        '';
        "01:30" = ''
          ${pkgs.libnotify}/bin/notify-send -u critical "はよ寝ろ"
          ${pkgs.procps}/bin/pkill -f firefox-devedition || true
          sleep 5
          ${pkgs.hyprlock}/bin/hyprlock || true
        '';
      };
      mkName = time: "sleep-nudge-${builtins.replaceStrings [ ":" ] [ "-" ] time}";

      mkUnit =
        time: script:
        let
          name = mkName time;
        in
        {
          timers.${name} = {
            Unit.Description = "Sleep nudge at ${time}";
            Timer = {
              OnCalendar = "*-*-* ${time}:00";
              Persistent = false;
            };
            Install.WantedBy = [ "timers.target" ];
          };
          services.${name} = {
            Unit.Description = "Sleep nudge at ${time}";
            Service = {
              Type = "oneshot";
              # ExecStart = toString (pkgs.writeShellScript name script);
              ExecStart = toString (
                pkgs.writeShellScript name ''
                  # skip running if the time is in the past (ex. the computer was suspended)
                  [[ "${time}" == $(date +%H:%M | cut -c-4)* ]] || exit 0
                  ${script}
                ''
              );
            };
          };
        };
    in
    lib.mkMerge (lib.mapAttrsToList mkUnit jobs);
}
