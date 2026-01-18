import Quickshell
import QtQuick
import qs.components
import qs.modules.niri

MouseArea {
  id: root

  implicitHeight: parent.height
  implicitWidth: appIcon.width + windowTitle.paintedWidth + 4
  clip: true

  hoverEnabled: true

  readonly property bool shouldShow: NiriIpc.focusedWindowTitle !== ""

  Image {
    id: appIcon
    mipmap: true
    height: parent.height
    width: parent.height
    anchors.left: parent.left

    fillMode: Image.PreserveAspectFit
    source: Quickshell.iconPath(NiriIpc.focusedWindowAppId, true)
    visible: source !== ""
  }

  MyText {
    id: windowTitle
    anchors.left: appIcon.right
    anchors.verticalCenter: parent.verticalCenter
    anchors.leftMargin: 4

    // text: NiriIpc.focusedWindowTitle
    text: {
      // clip if too long
      const limit = 100
      if (NiriIpc.focusedWindowTitle.length > limit) {
        return NiriIpc.focusedWindowTitle.slice(0, limit - 3) + "..."
      } else {
        return NiriIpc.focusedWindowTitle
      }
    }
  }

  Tooltip {
    anchor.item: root
    implicitWidth: tooltipText.paintedWidth + 20
    implicitHeight: tooltipText.paintedHeight + 20
    visible: root.containsMouse && root.shouldShow
    MyText {
      id: tooltipText
      anchors.centerIn: parent
      text: `${NiriIpc.focusedWindowTitle}\n(${JSON.stringify(NiriIpc.focusedWindowAppId)})`
    }
  }
}
