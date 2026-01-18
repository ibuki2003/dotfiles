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
    interval: 200 / (1.0 + SystemLoad.cpuUsage / 100.0 * 0.3)
    running: true
    repeat: true
    onTriggered: {
      root.currentFrame = (root.currentFrame + 1) % root.frameCount
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

      implicitWidth: grid.implicitWidth + 20
      implicitHeight: grid.implicitHeight + 20

      GridLayout {
        anchors.centerIn: parent
        id: grid
        columns: 2

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
