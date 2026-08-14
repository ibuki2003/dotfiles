import qs
import qs.components
import qs.modules
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

WrapperMouseArea {
  id: root

  implicitHeight: parent.height
  implicitWidth: parent.height
  hoverEnabled: true
  margin: 0

  readonly property real memoryPercentage: SystemLoad.memory.total > 0
    ? SystemLoad.memory.used / SystemLoad.memory.total : 0
  readonly property real cachePercentage: SystemLoad.memory.total > 0
    ? (SystemLoad.memory.available - SystemLoad.memory.free) / SystemLoad.memory.total : 0
  readonly property real swapPercentage: SystemLoad.memory.swapTotal > 0
    ? SystemLoad.memory.swapUsed / SystemLoad.memory.swapTotal : 0

  CircularChart {
    size: parent.height
    icon: ''
    percentage: root.memoryPercentage
    secondaryPercentage: Math.max(0, root.cachePercentage)
    secondaryColor: Style.themeComment
    innerPercentage: root.swapPercentage
    innerColor: Style.themePurple
  }

  Tooltip {
    anchor.item: root
    visible: root.containsMouse
    implicitWidth: table.implicitWidth + 20
    implicitHeight: table.implicitHeight + 20

    GridLayout {
      id: table
      anchors.centerIn: parent
      columns: 7
      columnSpacing: 10
      rowSpacing: 2

      function humanReadable(sizeInMB) {
        if (sizeInMB >= 1024)
          return (sizeInMB / 1024).toFixed(1) + "Gi"
        return sizeInMB.toFixed(0) + "Mi"
      }

      Repeater {
        model: [
          "", "total", "used", "free", "shared", "buff", "avail",
          "Mem:",
          table.humanReadable(SystemLoad.memory.total),
          table.humanReadable(SystemLoad.memory.used),
          table.humanReadable(SystemLoad.memory.free),
          table.humanReadable(SystemLoad.memory.shared),
          table.humanReadable(SystemLoad.memory.cache),
          table.humanReadable(SystemLoad.memory.available),
          "Swap:",
          table.humanReadable(SystemLoad.memory.swapTotal),
          table.humanReadable(SystemLoad.memory.swapUsed),
          table.humanReadable(SystemLoad.memory.swapFree),
          "", "", ""
        ]

        MyText {
          required property string modelData
          required property int index
          text: modelData
          font: Style.monospaceFont
          horizontalAlignment: index % table.columns === 0 ? Text.AlignLeft : Text.AlignRight
          Layout.fillWidth: true
        }
      }
    }
  }
}
