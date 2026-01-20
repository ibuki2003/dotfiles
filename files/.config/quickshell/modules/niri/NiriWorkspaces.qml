pragma ComponentBehavior: Bound
import Quickshell
import QtQuick
import qs.components
import qs.modules.niri
import qs

Item {
  id: root

  required property string outputId

  implicitHeight: parent.height
  implicitWidth: row.implicitWidth

  readonly property bool shouldShow: NiriIpc.focusedWindowTitle !== ""

  Row {
    id: row
    spacing: 4
    anchors.verticalCenter: parent.verticalCenter

    Repeater {
      model: NiriIpc.workspacesByOutput[root.outputId] || []

      delegate: Rectangle {
        required property int modelData

        readonly property bool isActive: NiriIpc.activeWorkspaces[root.outputId] === modelData
        implicitHeight: root.height / 4
        implicitWidth: isActive ? implicitHeight * 2 : implicitHeight
        anchors.verticalCenter: parent.verticalCenter
        radius: height / 2

        color: isActive ? Style.themeForeground : Style.themeComment
      }
    }
  }
}
