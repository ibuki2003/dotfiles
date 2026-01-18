pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray

import qs.components

RowLayout {
  id: trayContainer

  spacing: 1

  Repeater {
    model: SystemTray.items

    MouseArea {
      id: trayItem

      acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
      hoverEnabled: true

      implicitWidth: parent.height
      implicitHeight: parent.height

      onClicked: (mouse) => {
        switch (mouse.button) {
          case Qt.LeftButton:
            trayItem.modelData.activate()
            break
          case Qt.RightButton:
            trayMenuAnchor.menu = trayItem.modelData.menu
            console.log("trayMenuAnchor.menu:", trayMenuAnchor.menu)
            console.log("trayMenuAnchor.menu:", JSON.stringify(trayMenuAnchor.menu))
            trayMenuAnchor.open()
            break
          case Qt.MiddleButton:
            trayItem.modelData.secondaryActivate()
            break
        }
      }

      onEntered: {
        if (trayItem.modelData.tooltipTitle.length === 0 && trayItem.modelData.tooltipDescription.length === 0)
          return
        trayTooltip.id_for = trayItem.modelData.id
        const textParts = []
        if (trayItem.modelData.tooltipTitle) {
          textParts.push("<b>" + trayItem.modelData.tooltipTitle + "</b>");
        }
        if (trayItem.modelData.tooltipDescription) {
          textParts.push(trayItem.modelData.tooltipDescription);
        }
        trayTooltip.text = textParts.join("<br/>");
        trayTooltip.anchorItem = trayItem;
        trayTooltip.visible = true;
      }
      onExited: {
        if (trayTooltip.id_for === trayItem.modelData.id)
          trayTooltip.visible = false;
      }

      required property SystemTrayItem modelData
      IconImage {
        source: trayItem.modelData.icon.replace("xdg:", "")
        implicitSize: parent.height * 0.8
        anchors.centerIn: parent
      }

    }
  }

  QsMenuAnchor {
    id: trayMenuAnchor
    anchor.item: trayContainer
  }

  Tooltip {
    id: trayTooltip
    visible: false

    property string id_for: ""
    property string text: ""
    property Item anchorItem: null

    anchor.item: anchorItem

    implicitWidth: tooltipText.width + 10
    implicitHeight: tooltipText.height + 10

    MyText {
      id: tooltipText
      anchors.centerIn: parent
      text: trayTooltip.text
      textFormat: Text.StyledText
    }
  }
}
