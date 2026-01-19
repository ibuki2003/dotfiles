import qs.components
import qs.modules
import Quickshell.Widgets

WrapperMouseArea {
  id: root

  implicitHeight: parent.height
  implicitWidth: parent.height
  hoverEnabled: true
  margin: 0
  CircularChart {
    size: parent.height
    icon: ''
    percentage: SystemLoad.memoryUsage / SystemLoad.memoryTotal
  }

  Tooltip {
    anchor.item: root

    visible: root.containsMouse
    implicitWidth: text.paintedWidth + 20
    implicitHeight: text.paintedHeight + 20
    MyText {
      id: text
      anchors.centerIn: parent
      text: {
        function toFixedGB(sizeInMB) {
          return (sizeInMB / 1024).toFixed(1)
        }
        return `${toFixedGB(SystemLoad.memoryUsage)} / ${toFixedGB(SystemLoad.memoryTotal)} GB`
      }
    }
  }

}
