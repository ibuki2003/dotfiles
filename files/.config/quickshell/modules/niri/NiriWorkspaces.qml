pragma ComponentBehavior: Bound
import QtQuick
import qs
import qs.modules.niri

Item {
  id: root

  required property string outputId

  readonly property real columnHeight: 14
  readonly property real columnWidthScale: 0.75
  readonly property bool shouldShow: NiriIpc.focusedWindowTitle !== ""
  readonly property var workspaceIds: NiriIpc.workspacesByOutput[root.outputId] || []
  readonly property int activeWorkspaceId: NiriIpc.activeWorkspaces[root.outputId] ?? -1
  readonly property int activeWorkspaceIndex: root.workspaceIds.indexOf(root.activeWorkspaceId)
  readonly property var aboveWorkspaces: root.activeWorkspaceIndex < 0 ? []
      : root.workspaceIds.slice(0, root.activeWorkspaceIndex).map(id => NiriIpc.workspaces[id])
  readonly property var belowWorkspaces: root.activeWorkspaceIndex < 0 ? []
      : root.workspaceIds.slice(root.activeWorkspaceIndex + 1, -1).map(id => NiriIpc.workspaces[id])
  readonly property int activeWindowId: {
    const workspaceWindowId = NiriIpc.workspaces[root.activeWorkspaceId]?.active_window_id
    if (workspaceWindowId !== undefined && workspaceWindowId !== null) return workspaceWindowId
    return NiriIpc.focusedWindow.workspace_id === root.activeWorkspaceId
        ? NiriIpc.focusedWindow.id : -1
  }
  readonly property var columns: {
    const byPosition = {}
    for (const windowId in NiriIpc.windows) {
      const win = NiriIpc.windows[windowId]
      const position = win.layout?.pos_in_scrolling_layout
      if (win.workspace_id !== root.activeWorkspaceId || !position) continue

      const columnPosition = position[0]
      if (!byPosition[columnPosition]) byPosition[columnPosition] = []
      byPosition[columnPosition].push({
        id: win.id,
        position: position[1],
        isUrgent: win.is_urgent,
        tileWidth: win.layout.tile_size?.[0] ?? win.layout.window_size?.[0] ?? 0,
        tileHeight: win.layout.tile_size?.[1] ?? win.layout.window_size?.[1] ?? 0,
      })
    }

    return Object.keys(byPosition)
        .map(position => ({
          position: Number(position),
          windows: byPosition[position].sort((a, b) => a.position - b.position),
          tileWidth: Math.max(...byPosition[position].map(win => win.tileWidth)),
          tileHeight: byPosition[position].reduce((sum, win) => sum + win.tileHeight, 0),
        }))
        .sort((a, b) => a.position - b.position)
  }

  function columnWidth(column) {
    if (column.tileHeight <= 0) return 7
    return Math.max(3,
        root.columnHeight * column.tileWidth / column.tileHeight * root.columnWidthScale)
  }

  implicitHeight: parent.height
  implicitWidth: Math.max(columnRow.implicitWidth, above.implicitWidth, below.implicitWidth)

  Row {
    id: above
    spacing: 1
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter
    anchors.verticalCenterOffset: -12

    Repeater {
      model: root.aboveWorkspaces

      Rectangle {
        required property var modelData
        required property int index

        width: 3
        height: 3
        radius: 1.5
        color: modelData.is_urgent ? Style.themeRed : Style.themeComment
      }
    }
  }

  Row {
    id: columnRow
    spacing: 2
    anchors.centerIn: parent

    Repeater {
      model: root.columns

      delegate: Item {
        id: column

        required property var modelData
        required property int index

        width: root.columnWidth(modelData)
        height: root.columnHeight

        Column {
          spacing: 2
          anchors.fill: parent

          Repeater {
            model: column.modelData.windows

            Rectangle {
              required property var modelData
              required property int index

              width: column.width
              height: (column.height - 2 * Math.max(0, column.modelData.windows.length - 1))
                  / column.modelData.windows.length
              radius: 1
              color: modelData.isUrgent ? Style.themeRed
                  : modelData.id === root.activeWindowId ? Style.themeForeground
                  : Style.themeComment
            }
          }
        }
      }
    }
  }

  Row {
    id: below
    spacing: 1
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter
    anchors.verticalCenterOffset: 12

    Repeater {
      model: root.belowWorkspaces

      Rectangle {
        required property var modelData
        required property int index

        width: 3
        height: 3
        radius: 1.5
        color: modelData.is_urgent ? Style.themeRed : Style.themeComment
      }
    }
  }
}
