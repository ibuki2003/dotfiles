import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets

import qs
import qs.modules
import qs.modules.niri
import qs.modules.network

PanelWindow {
  id: root

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

    Item {
      id: leftContainer

      implicitWidth: leftCapsule1.width + leftCapsule2.width + root.capsuleGap + root.capsuleGap
      height: parent.height

      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      anchors.leftMargin: root.capsuleGap

      Rectangle {
        id: leftCapsule1
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left

        color: Style.themeBackground
        height: root.panelHeight

        radius: height / 2
        width: leftItems.width + 32

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

          NwIndicator { }

        }
      }

      // second capsule for workspaces
      WrapperRectangle {
        id: leftCapsule2
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: leftCapsule1.right
        anchors.leftMargin: root.capsuleGap

        leftMargin: 12
        rightMargin: 12
        topMargin: 0
        bottomMargin: 0

        color: Style.themeBackground
        height: root.panelHeight
        radius: height / 2

        NiriWorkspaces {
          outputId: root.screen.name
        }
      }
    }

    Rectangle {
      id: centerContainer
      visible: niriFocused.shouldShow
      color: Style.themeBackground
      anchors.verticalCenter: parent.verticalCenter
      height: root.panelHeight
      radius: height / 2
      width: Math.min(
        centerItem.width + 16,
        parent.width - leftContainer.width - rightItem.width - root.capsuleGap * 4
      )

      x: Math.min(
        Math.max(
          (parent.width - width) / 2,
          leftContainer.x + leftContainer.width + root.capsuleGap
        ),
        rightItem.x - width - root.capsuleGap
      )

      clip: true


      RowLayout {
        id: centerItem
        height: parent.height
        anchors.verticalCenter: parent.verticalCenter
        // anchors.horizontalCenter: parent.horizontalCenter
        anchors.left: parent.left
        anchors.leftMargin: parent.radius / 2

        NiriFocused {
          id: niriFocused
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
