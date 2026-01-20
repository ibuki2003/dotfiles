import Quickshell
import Quickshell.Widgets
import QtQuick
import qs.components
import qs.modules.niri
import Quickshell.Networking

WrapperMouseArea {
  id: root

  margin: 1

  implicitWidth: container.implicitWidth + margin * 2
  implicitHeight: parent.height
  clip: true

  hoverEnabled: true

  readonly property bool shouldShow: NiriIpc.focusedWindowTitle !== ""

  Item {
    id: container
    implicitWidth: appIcon.width + windowTitle.paintedWidth + 4
    anchors.centerIn: parent

    Image {
      id: appIcon
      mipmap: true
      height: root.height * 0.6
      width: root.height * 0.6
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter

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
}
