pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import qs.modules
import qs.components

WrapperMouseArea {
  id: root
  implicitWidth: text.paintedWidth
  implicitHeight: parent.height

  hoverEnabled: true

  readonly property int frameCount: 5
  property int currentFrame: 0
  Timer {
    interval: 200
    running: true
    repeat: true
    onTriggered: {
      root.currentFrame = (root.currentFrame + 1) % root.frameCount
      interval = 1000 / framerate
    }

    property real framerate: SystemLoad.cpuUsage < 200.0
      ? (5.0 + 5.0 * SystemLoad.cpuUsage / 200.0)
      : (10.0 + 20.0 * (SystemLoad.cpuUsage / 100.0 - 2.0) / Math.max(1.0, SystemLoad.cpuCores - 2.0))
    Behavior on framerate {
      NumberAnimation {
        duration: 500
        easing.type: Easing.OutQuad
      }
    }
  }

  FontLoader {
    id: fontLoader
    // source: Qt.resolvedUrl(Quickshell.shellPath("assets/runcat.ttf"))
    source: Quickshell.shellPath("assets/runcat.ttf")
  }

  MyText {
    id: text
    text: ["\ue900", "\ue901", "\ue902", "\ue903", "\ue904"][root.currentFrame]
    font.family: fontLoader.name
    font.pixelSize: root.implicitHeight

    readonly property real cpuTempColorFactor: Math.min(Math.max((SystemLoad.cpuTemperature - 50.0) / 20.0, 0.0), 1.0)
    color: Qt.rgba(
      1.0,
      1.0 - cpuTempColorFactor,
      1.0 - cpuTempColorFactor,
    )
  }


  LazyLoader {
    active: true

    Tooltip {
      // visible: true
      visible: root.containsMouse
      anchor.item: root

      implicitWidth: grid.implicitWidth + 12
      implicitHeight: grid.implicitHeight + 12

      ColumnLayout {
        anchors.centerIn: parent
        id: grid
        spacing: 2

        // per-core bar chart
        // target total bar area ~160px at 32 cores
        Row {
          readonly property int barSpacing: 1
          readonly property int barWidth: SystemLoad.cpuCores > 0
            ? Math.max(1, Math.floor((160 - (SystemLoad.cpuCores - 1) * barSpacing) / SystemLoad.cpuCores))
            : 4
          spacing: barSpacing
          Layout.alignment: Qt.AlignHCenter

          Repeater {
            model: SystemLoad.cpuUsagePerCore
            delegate: Rectangle {
              required property real modelData
              width: parent.barWidth
              height: 40
              color: "transparent"

              Rectangle {
                width: parent.width
                height: Math.round(parent.height * modelData / 100.0)
                anchors.bottom: parent.bottom
                color: Qt.rgba(1.0, 1.0 - Math.min(Math.max((modelData - 50.0) / 50.0, 0.0), 1.0), 0.2, 1.0)
              }
            }
          }
        }

        RowLayout {
          spacing: 6
          Layout.alignment: Qt.AlignHCenter

          MyText {
            text: "󰔏"
            font.family: "Material Design Icons"
          }
          MyText {
            text: Math.round(SystemLoad.cpuTemperature) + " ℃"
          }

          MyText {
            text: "󰍛"
            font.family: "Material Design Icons"
          }
          MyText {
            text: Math.round(SystemLoad.cpuUsage) + " %"
          }
        }
      }

    }
  }
}
