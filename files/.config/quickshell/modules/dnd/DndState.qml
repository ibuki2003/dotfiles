pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
  id: root

  property bool dndEnabled: false

  function toggleDnd() {
    root.dndEnabled = !root.dndEnabled;
    const flag = root.dndEnabled ? "-a" : "-r";
    Quickshell.execDetached(["makoctl", "mode", flag, "do-not-disturb"]);
  }

  Process {
    id: proc
    running: true
    command: ["makoctl", "mode"]
    stdout: StdioCollector {
      onStreamFinished: {
        const modes = this.text.trim().split("\n");
        root.dndEnabled = modes.includes("do-not-disturb");
      }
    }
  }
  Timer {
    id: timer
    interval: 60_000
    running: true
    repeat: true
    onTriggered: { proc.running = true; }
  }
}
