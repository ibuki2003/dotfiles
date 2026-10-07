pragma ComponentBehavior: Bound
import QtQuick
import qs
import qs.components
import qs.modules.niri

Item {
  id: root

  required property string outputId
  required property real columnWidthScale

  readonly property real columnHeight: 14
  readonly property int maxDetailedWindows: 4
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
      })
    }

    return Object.keys(byPosition)
        .map(position => ({
          position: Number(position),
          windows: byPosition[position].sort((a, b) => a.position - b.position),
          tileWidth: Math.max(...byPosition[position].map(win => win.tileWidth)),
        }))
        .sort((a, b) => a.position - b.position)
  }

  function columnWidth(column) {
    if (column.tileWidth <= 0) return 7
    return Math.max(3, column.tileWidth * root.columnWidthScale)
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

        readonly property color indicatorColor: modelData.windows.some(win => win.isUrgent)
            ? Style.themeRed
            : modelData.windows.some(win => win.id === root.activeWindowId)
              ? Style.themeForeground
              : Style.themeComment

        Column {
          visible: column.modelData.windows.length <= root.maxDetailedWindows
          spacing: 2
          anchors.fill: parent

          Repeater {
            model: column.modelData.windows.length <= root.maxDetailedWindows
                ? column.modelData.windows : []

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

        Rectangle {
          visible: column.modelData.windows.length > root.maxDetailedWindows
          anchors.fill: parent
          radius: 3
          color: "transparent"
          border.width: 1
          // border.color: column.indicatorColor

          MyText {
            anchors.centerIn: parent
            text: column.modelData.windows.length.toString(36).toUpperCase() // ensure single character for up to 35 windows (!)
            color: column.indicatorColor
            font: {
              const f = Qt.font(Style.monospaceFont)
              f.pixelSize = 12
              f.bold = true
              return f
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
