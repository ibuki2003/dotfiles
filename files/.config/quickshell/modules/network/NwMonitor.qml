pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
  id: root

  property string primaryInterface: ""
  property var previousUsage: ({})
  property var speeds: ({})
  property var devices: ({})
  property var wirelessInfo: ({})

  readonly property var primaryDevice: ({
    device: root.devices[root.primaryInterface] || null,
    speed: root.speeds[root.primaryInterface] || { rxSpeed: 0, txSpeed: 0 },
    wireless: root.wirelessInfo[root.primaryInterface] || null
  })

  function iconForDevice(name) {
    if (!root.devices[name]) {
      return '';
    }
    const device = root.devices[name];

    switch (device.type) {
      case "loopback":
      case "ethernet":
        return '󰌗';

      case "bridge": return '󰘘';
      case "tun": return '󱠾';
      case "wifi": {
        const strength = root.wirelessInfo[name]?.signal || 0.0;
        return ['󰤯', '󰤟', '󰤢', '󰤥', '󰤨'][Math.min(Math.floor(strength * 5), 4)]
      }
      default: return '󰛵';
    }
  }

  function formatSpeed(speed) {
    const Kibi = 1024;
    const Mebi = 1048576;
    const Gibi = 1_073_741_824;

    if (speed < Mebi)      return (speed / Kibi).toFixed(0) + " K";
    else if (speed < Gibi) return (speed / Mebi).toFixed(0) + " M";
    else                   return (speed / Gibi).toFixed(0) + " G";
  }

  function statusTextFor(iface) {
    const lines = [];
    const device = root.devices[iface];
    const speed = root.speeds[iface] || { rxSpeed: 0, txSpeed: 0 };
    // if (device.type == "bridge" || device.type == "tun") {
    //   continue;
    // }
    device.addresses?.forEach(addr => {
      lines.push(`${addr}`);
    });
    if (device.type == "wifi") {
      lines.push("");
      lines.push(root.wirelessInfo[iface]?.details ?? "")
    }

    return lines.join("\n");
  }


  FileView {
    id: usageFile
    path: "/proc/net/dev"
    preload: true

    property int lastTotalTime: 0
    property int lastIdleTime: 0

    onLoaded: {
      const lines = usageFile.text().split("\n").slice(2);
      const usages = {};
      const speeds = {};
      const deltaTime = usageTimer.interval / 1000;
      for (const line of lines) {
        const parts = line.trim().split(/:?\s+/);
        const iface = parts[0];
        if (!iface) continue;
        const rxBytes = parseInt(parts[1]);
        const txBytes = parseInt(parts[9]);

        usages[iface] = { rxBytes: rxBytes, txBytes: txBytes };
        if (root.previousUsage[iface]) {
          const deltaRx = rxBytes - root.previousUsage[iface].rxBytes;
          const deltaTx = txBytes - root.previousUsage[iface].txBytes;
          speeds[iface] = { rxSpeed: deltaRx, txSpeed: deltaTx };
        } else {
          speeds[iface] = { rxSpeed: 0, txSpeed: 0 };
        }
      }
      root.previousUsage = usages;
      root.speeds = speeds;
    }
  }
  Timer {
    id: usageTimer
    interval: 1000
    running: true
    repeat: true
    onTriggered: usageFile.reload()
  }

  Process {
    id: nmcliDevices
    running: true
    command: ["nmcli", "-t", "device", "show"]
    stdout: StdioCollector {
      onStreamFinished: {
        const devices = {};
        let defaultDevice = null;

        const entries = this.text.split("\n\n");
        for (const entry of entries) {
          const lines = entry.split("\n");
          const device = {};
          for (const line of lines) {
            const colonIndex = line.indexOf(":");
            const key = line.slice(0, colonIndex);
            const value = line.slice(colonIndex + 1);

            if (key == 'GENERAL.DEVICE') {
              device.name = value;
            } else if (key == 'GENERAL.TYPE') {
              device.type = value;
            } else if (key == 'GENERAL.CONNECTION') {
              device.connection = value;
            } else if (/IP[4|6]\.ADDRESS\[\d+\]/.test(key)) {
              if (device.addresses === undefined) {
                device.addresses = [];
              }
              device.addresses.push(value);
            } else if (key.startsWith("IP4.ROUTE[")) {
              if (value.indexOf("dst = 0.0.0.0/0") !== -1) {
                defaultDevice = device.name;
              }
            }
          }
          devices[device.name] = device;
        }

        root.primaryInterface = defaultDevice ?? "";
        root.devices = devices;
      }
    }
  }

  property bool iwconfigAvailable: true
  Process {
    id: iwconfig
    running: true
    command: ["iwconfig"]
    stdout: StdioCollector {
      onStreamFinished: {
        const wirelessInfo = {};

        // { signal: number, details: string }

        for (const entry of this.text.split("\n\n")) {
          const dev = {};
          const link_qualityMatch = entry.match(/Link Quality=(\d+)\/(\d+)/);
          if (link_qualityMatch) {
            dev.signal = parseInt(link_qualityMatch[1]) / parseInt(link_qualityMatch[2]);
          }

          dev.details = entry.replace(/^\s+/gm, "").trim();

          const name = dev.details.substring(0, dev.details.indexOf(" "));
          wirelessInfo[name] = dev;
        }
        root.wirelessInfo = wirelessInfo;
      }
    }
    onExited: (code, _status) => {
      if (code !== 0) {
        root.iwconfigAvailable = false;
        iwconfig.running = false;
      }
    }
  }
  Timer {
    id: iwconfigTimer
    interval: 10_000
    running: root.iwconfigAvailable
    repeat: true
    onTriggered: { iwconfig.running = true; }
  }

  Process {
    id: nmcliMonitor
    running: true
    command: ["nmcli", "monitor"]
    stdout: SplitParser {
      // function onRead(data) {
      onRead: function(_data) {
        nmcliDevices.running = true
      }
    }
  }
}
