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

  property var workspaces: ({})
  property var activeWorkspaces: ({}) // output -> workspace id

  readonly property var workspacesByOutput: {
    let result = {}
    for (const wsId in root.workspaces) {
      const ws = root.workspaces[wsId]
      if (!result[ws.output]) {
        result[ws.output] = []
      }
      result[ws.output].push(ws.id)
    }
    for (const output in result) {
      result[output].sort((a, b) => {
        return root.workspaces[a].idx - root.workspaces[b].idx
      })
    }
    return result
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

          for (const key in msg) {
            const value = msg[key];

            switch (key) {
              // windows
              case "WindowsChanged": {
                root.windows = {}
                for (const win of value.windows) {
                  registerWindow(win)
                }
                root.windows = Object.assign({}, root.windows)
                break;
              }
              case "WindowFocusChanged": {
                root.focusedWindow = (value.id && root.windows[value.id]) ?? {}
                break;
              }
              case "WindowOpenedOrChanged": {
                registerWindow(value.window)
                root.windows = Object.assign({}, root.windows)
                break;
              }
              case "WindowClosed": {
                delete root.windows[value.id]
                root.windows = Object.assign({}, root.windows)
                break;
              }

              // workspaces
              case "WorkspacesChanged": {
                const workspaces = {}
                const actives = {}
                for (const ws of value.workspaces) {
                  workspaces[ws.id] = ws
                  if (ws.is_active) {
                    actives[ws.output] = ws.id
                  }
                }
                root.workspaces = workspaces
                root.activeWorkspaces = actives

                break;
              }
              case "WorkspaceActivated": {
                if (!value.id) break;
                const output = root.workspaces[value.id]?.output
                const oldActive = root.activeWorkspaces[output]

                if (oldActive) root.workspaces[oldActive].is_active = false
                root.workspaces[value.id].is_active = true

                root.activeWorkspaces[output] = value.id

                // force notify activeWorkspaces change
                root.activeWorkspaces = Object.assign({}, root.activeWorkspaces)

                break;
              }
              case "WorkspaceUrgencyChanged": {
                if (!value.id) break;
                if (root.workspaces[value.id]) {
                  root.workspaces[value.id].is_urgent = value.urgent
                  root.workspaces = Object.assign({}, root.workspaces)
                }
                break;
              }

              case "WorkspaceActiveWindowChanged": {
                if (root.workspaces[value.workspace_id]) {
                  root.workspaces[value.workspace_id].active_window_id = value.active_window_id
                  root.workspaces = Object.assign({}, root.workspaces)
                }
                break;
              }
              case "WindowUrgencyChanged": {
                if (root.windows[value.id]) {
                  root.windows[value.id].is_urgent = value.urgent
                  root.windows = Object.assign({}, root.windows)
                }
                break;
              }
              case "WindowLayoutsChanged": {
                for (const change of value.changes) {
                  if (root.windows[change[0]]) root.windows[change[0]].layout = change[1]
                }
                root.windows = Object.assign({}, root.windows)
                break;
              }
              case "WindowFocusTimestampChanged": {
                // nothing to do
                break;
              }

              default: {
                // console.log("NiriIpc.qml: Unknown message:", key)
              }
            }
          }
        } catch (e) {
          console.log("NiriIpc.qml: Failed to parse JSON:", e)
        }
      }
    }

  }
}
