import qs
import qs.components
import qs.modules.dnd
import Quickshell.Widgets
import QtQuick

WrapperMouseArea {
  id: root

  implicitHeight: parent.height
  implicitWidth: parent.height
  // margin: 6

  onClicked: DndState.toggleDnd()
  MyText {
    id: text
    color: Style.foreground
    anchors.centerIn: root
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    font.pixelSize: height * 0.6
    font.family: Style.iconFontFamily

    text: DndState.dndEnabled ? "󰂛" : "󰂚"
  }
}

