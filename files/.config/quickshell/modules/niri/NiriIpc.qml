pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
  id: root

  property var focusedWindow: ({})
  readonly property string focusedWindowTitle: {
    return root.focusedWindow.title || ""
  }
  readonly property string focusedWindowAppId: {
    return root.focusedWindow.app_id || ""
  }

  property var windows: ({})

  Process {
    running: true
    command: ["niri", "msg", "-j", "event-stream"]
    stdout: SplitParser {
      // function onRead(data) {
      onRead: function(data) {
        function registerWindow(win) {
          root.windows[win.id] = win
          if (win.is_focused) {
            root.focusedWindow = win
          }
        }
        try {
          let msg = JSON.parse(data)
          // console.log(Object.keys(msg))
          if (msg.hasOwnProperty("WindowsChanged")) {
            const windows_list = msg.WindowsChanged.windows
            for (let i = 0; i < windows_list.length; i++) {
              registerWindow(windows_list[i])
            }
          } else if (msg.hasOwnProperty("WindowFocusChanged")) {
            const id = msg.WindowFocusChanged.id
            root.focusedWindow = (id && root.windows[id]) ?? {}
          } else if (msg.hasOwnProperty("WindowOpenedOrChanged")) {
            registerWindow(msg.WindowOpenedOrChanged.window)
          } else if (msg.hasOwnProperty("WindowClosed")) {
            const id = msg.WindowClosed.id
            delete root.windows[id]
          }
        } catch (e) {
          console.log("NiriIpc.qml: Failed to parse JSON:", e)
        }
      }
    }

  }
}
