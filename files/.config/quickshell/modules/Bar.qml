import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets

import qs
import qs.modules
import qs.modules.niri

PanelWindow {
  id: root

  required property var modelData
  screen: modelData

  // niri overview feature renders windows on "overlay" layer with no scaling
  WlrLayershell.layer: WlrLayershell.Bottom

  anchors {
    top: true
    left: true
    right: true
  }

  readonly property int panelHeight: 32
  readonly property int panelMargin: 4
  readonly property int capsuleGap: 8

  implicitHeight: panelHeight + panelMargin * 2

  color: 'transparent'

  Rectangle {
    color: Style.barBackground
    anchors.fill: parent
    clip: true

    Rectangle {
      id: leftContainer
      color: Style.themeBackground
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      anchors.leftMargin: root.capsuleGap
      height: root.panelHeight

      radius: height / 2
      width: leftItems.width + 16

      RowLayout {
        id: leftItems
        height: parent.height

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        ClockWidget { }

        Volume { }

        MemoryPie { }

        Battery { }

        RunCat { }

      }
    }

    Rectangle {
      id: centerContainer
      visible: niriFocused.shouldShow
      color: Style.themeBackground
      anchors.verticalCenter: parent.verticalCenter
      height: root.panelHeight
      radius: height / 2
      width: centerItem.width + 16

      x: Math.min(
        Math.max(
          (parent.width - width) / 2,
          leftContainer.x + leftContainer.width + root.capsuleGap
        ),
        rightItem.x - width - root.capsuleGap
      )


      RowLayout {
        id: centerItem
        height: parent.height
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter

        WrapperItem {
          implicitHeight: parent.height
          margin: 2
          NiriFocused {
            id: niriFocused
          }
        }
      }
    }

    RowLayout {
      id: rightItem
      anchors.right: parent.right
      anchors.rightMargin: root.capsuleGap
      height: parent.height
      anchors.verticalCenter: parent.verticalCenter
      spacing: root.capsuleGap

      Rectangle {
        color: Style.themeBackground
        implicitHeight: root.panelHeight
        implicitWidth: mediaPlayer.width + 16
        radius: height / 2

        MediaPlayer {
          id: mediaPlayer
          anchors.centerIn: parent
        }
      }

      WrapperRectangle {
        color: Style.themeBackground
        implicitHeight: root.panelHeight
        radius: height / 2
        margin: 2
        rightMargin: 8
        leftMargin: 8
        Tray { }
      }
    }
  }

}
