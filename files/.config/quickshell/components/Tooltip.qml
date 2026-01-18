import Quickshell
import QtQuick
import qs

PopupWindow {
  id: root

  default property alias child: container.data

  color: "transparent"

  // visible: root.containsMouse
  Rectangle {
    id: container

    radius: 5

    anchors.fill: parent
    color: Style.popupBackground
    border.color: Style.foreground
    border.width: 1
  }
}
