pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {

  id: root

  property var memory: ({
    total: 0.0,
    used: 0.0,
    free: 0.0,
    available: 0.0,
    shared: 0.0,
    cache: 0.0,
    swapTotal: 0.0,
    swapUsed: 0.0,
    swapFree: 0.0,
  })

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
      let memFreeKB = 0
      let memAvailableKB = 0
      let memSharedKB = 0
      let buffersKB = 0
      let cachedKB = 0
      let reclaimableKB = 0
      let swapTotalKB = 0
      let swapFreeKB = 0
      const lines = meminfoFile.text().split("\n")
      for (const line of lines) {
        const fields = line.split(/\s+/)
        if (fields.length < 2)
          continue

        const valueKB = parseInt(fields[1])
        switch (fields[0]) {
          case "MemTotal:":     memTotalKB     = valueKB; break
          case "MemFree:":      memFreeKB      = valueKB; break
          case "MemAvailable:": memAvailableKB = valueKB; break
          case "Shmem:":        memSharedKB    = valueKB; break
          case "Buffers:":      buffersKB      = valueKB; break
          case "Cached:":       cachedKB       = valueKB; break
          case "SReclaimable:": reclaimableKB  = valueKB; break
          case "SwapTotal:":    swapTotalKB    = valueKB; break
          case "SwapFree:":     swapFreeKB     = valueKB; break
        }
      }
      if (memTotalKB > 0) {
        root.memory = {
          total: memTotalKB / 1024.0,
          used: (memTotalKB - memAvailableKB) / 1024.0,
          free: memFreeKB / 1024.0,
          available: memAvailableKB / 1024.0,
          shared: memSharedKB / 1024.0,
          cache: (buffersKB + cachedKB + reclaimableKB) / 1024.0,
          swapTotal: swapTotalKB / 1024.0,
          swapUsed: (swapTotalKB - swapFreeKB) / 1024.0,
          swapFree: swapFreeKB / 1024.0,
        }
      }
    }
  }
  Timer {
    interval: 5000
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
    property var lastCoreStats: [] // [{total, idle}, ...]

    onLoaded: {
      const lines = statFile.text().split("\n");
      const numCores = lines.filter(line => line.startsWith("cpu")).length - 1; // exclude the aggregate "cpu" line
      const newCoreStats = [];
      const perCoreUsage = [];

      for (const line of lines) {
        if (line.startsWith("cpu ")) {
          const parts = line.split(/\s+/);
          const [user, nice, system, idle, iowait, irq, softirq, steal] = parts.slice(1, 9).map(s => parseInt(s));
          const totalIdle = idle + iowait;
          const total = user + nice + system + idle + iowait + irq + softirq + steal;

          const totalDiff = total - statFile.lastTotalTime;
          const idleDiff = totalIdle - statFile.lastIdleTime;

          root.cpuUsage = (totalDiff - idleDiff) / totalDiff * 100.0 * numCores;
          root.cpuCores = numCores;

          statFile.lastTotalTime = total
          statFile.lastIdleTime = totalIdle
        } else if (/^cpu\d/.test(line)) {
          const parts = line.split(/\s+/);
          const [user, nice, system, idle, iowait, irq, softirq, steal] = parts.slice(1, 9).map(s => parseInt(s));
          const totalIdle = idle + iowait;
          const total = user + nice + system + idle + iowait + irq + softirq + steal;
          const idx = newCoreStats.length;
          newCoreStats.push({total, idle: totalIdle});

          if (statFile.lastCoreStats.length > idx) {
            const prev = statFile.lastCoreStats[idx];
            const totalDiff = total - prev.total;
            const idleDiff = totalIdle - prev.idle;
            perCoreUsage.push(totalDiff > 0 ? (totalDiff - idleDiff) / totalDiff * 100.0 : 0.0);
          }
        }
      }

      statFile.lastCoreStats = newCoreStats;
      if (perCoreUsage.length > 0) root.cpuUsagePerCore = perCoreUsage;
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
