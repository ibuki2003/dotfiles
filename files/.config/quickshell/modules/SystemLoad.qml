pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {

  id: root

  property real memoryUsage: 0.0
  property real memoryTotal: 0.0

  property real cpuUsage: 0.0
  property int cpuCores: 1
  property list<real> cpuUsagePerCore: []

  property real cpuTemperature: 0.0

  FileView {
    id: meminfoFile
    path: "/proc/meminfo"
    preload: true
    onLoaded: {
      let memTotalKB = 0
      let memAvailableKB = 0
      const lines = meminfoFile.text().split("\n")
      for (const line of lines) {
        if (line.startsWith("MemTotal:")) {
          memTotalKB = parseInt(line.split(/\s+/)[1])
        } else if (line.startsWith("MemAvailable:")) {
          memAvailableKB = parseInt(line.split(/\s+/)[1])
        }
      }
      if (memTotalKB > 0) {
        root.memoryTotal = memTotalKB / 1024.0
        root.memoryUsage = (memTotalKB - memAvailableKB) / 1024.0
      }
    }
  }
  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: meminfoFile.reload()
  }

  FileView {
    id: statFile
    path: "/proc/stat"
    preload: true

    property int lastTotalTime: 0
    property int lastIdleTime: 0

    onLoaded: {
      const lines = statFile.text().split("\n");
      const numCores = lines.filter(line => line.startsWith("cpu")).length;
      for (const line of lines) {
        if (line.startsWith("cpu ")) {
          const parts = line.split(/\s+/);
          const [user, nice, system, idle, iowait, irq, softirq, steal] = parts.slice(1, 9).map(s => parseInt(s));
          const totalIdle = idle + iowait;
          const total = user + nice + system + idle + iowait + irq + softirq + steal;

          const totalDiff = total - statFile.lastTotalTime;
          const idleDiff = totalIdle - statFile.lastIdleTime;
          // const usage = (totalDiff - idleDiff) / totalDiff * 100.0 * numCores;

          root.cpuUsage = (totalDiff - idleDiff) / totalDiff * 100.0 * numCores;
          root.cpuCores = numCores;

          statFile.lastTotalTime = total
          statFile.lastIdleTime = totalIdle
          break
        }
      }
    }
  }
  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: statFile.reload()
  }

  property string cpuHwmonPath: ""
  Process {
    running: true
    command: [Quickshell.shellPath("helpers/hwmon.sh")]
    stdout: StdioCollector {
      onStreamFinished: {
        const lines = this.text.split("\n");
        const entries = {};
        lines.forEach(e => {
          const a = e.split(":");
          if (a.length >= 2) {
            entries[a[1]] = a[0];
          }
        });
        root.cpuHwmonPath = (
          entries["k10temp"] ||
          entries["coretemp"] ||
          entries["cpu_thermal"] ||
          entries["acpitz"] ||
          ""
        );

        console.log("Detected cpuHwmonPath:", root.cpuHwmonPath);
      }
    }
  }
  FileView {
    id: cpuTempFile
    path: root.cpuHwmonPath !== "" ? root.cpuHwmonPath + "/temp1_input" : ""
    preload: true

    onLoaded: {
      const tempMilliC = parseInt(cpuTempFile.text());
      if (!isNaN(tempMilliC)) {
        root.cpuTemperature = tempMilliC / 1000.0;
      }
    }
  }
  Timer {
    interval: 3000
    running: true
    repeat: true
    onTriggered: {
      if (root.cpuHwmonPath !== "") {
        cpuTempFile.reload();
      }
    }
  }
}
