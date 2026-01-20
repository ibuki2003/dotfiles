pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs
import qs.components
import Quickshell.Widgets
import qs.modules.network

WrapperMouseArea {
  id: root

  implicitHeight: parent.height
  implicitWidth: container.implicitWidth + margin * 2
  hoverEnabled: true
  margin: 0
  // CircularChart {
  //   size: parent.height
  //   icon: ''
  //   percentage: SystemLoad.memoryUsage / SystemLoad.memoryTotal
  // }

  Item {
    id: container
    anchors.centerIn: parent

    implicitWidth: icon.implicitWidth + speedText.paintedWidth + 4

    MyText {
      id: icon
      anchors.verticalCenter: parent.verticalCenter
      anchors.left: parent.left

      font.family: Style.iconFontFamily
      font.pixelSize: parent.height * 0.6
      text: {
        if (NwMonitor.primaryDevice.wireless) {
          return NwMonitor.iconForDevice(NwMonitor.primaryDevice.device?.name ?? '')
        } else {
          return '󰌗'
        }
      }
    }

    MyText {
      id: speedText
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter

      font.pixelSize: parent.height * 0.25
      lineHeight: 1.0
      font.family: 'JetBrains Mono'

      text: (
        `↑${NwMonitor.formatSpeed(NwMonitor.primaryDevice.speed.rxSpeed).padStart(5)} \n` +
        `↓${NwMonitor.formatSpeed(NwMonitor.primaryDevice.speed.txSpeed).padStart(5)}`
      )
    }
  }

  Tooltip {
    id: tooltip
    anchor.item: root

    visible: root.containsMouse
    implicitWidth: 500
    implicitHeight: deviceList.childrenRect.height + 1 // avoid crash

    ColumnLayout {
      id: deviceList

      anchors.fill: parent

      Repeater {
        model: {
          const devices = [];
          for (const name in NwMonitor.devices) {
            if (name.startsWith("br-")) {
              continue;
            }
            devices.push(name);
          }
          return devices;
        }

        delegate: Item {
          required property string modelData

          id: deviceItem
          implicitWidth: tooltip.implicitWidth
          implicitHeight: childrenRect.height + 20

          Item {
            id: leftColumn
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.margins: 10

            implicitWidth: 80
            implicitHeight: childrenRect.height

            clip: true


            MyText {
              id: deviceIcon
              anchors.horizontalCenter: parent.horizontalCenter
              anchors.top: parent.top
              text: NwMonitor.iconForDevice(deviceItem.modelData)
              font.family: Style.iconFontFamily
              font.pixelSize: 40
            }
            MyText {
              id: deviceName
              anchors.horizontalCenter: parent.horizontalCenter
              horizontalAlignment: Text.AlignHCenter
              anchors.top: deviceIcon.bottom
              text: {
                const lines = [];
                lines.push(deviceItem.modelData);
                if (NwMonitor.devices[deviceItem.modelData]?.type == "wifi") {
                  lines.push(NwMonitor.devices[deviceItem.modelData].connection);
                }

                lines.push(
                  `${NwMonitor.formatSpeed(NwMonitor.speeds[deviceItem.modelData]?.rxSpeed || 0)} / ` +
                  `${NwMonitor.formatSpeed(NwMonitor.speeds[deviceItem.modelData]?.txSpeed || 0)}`
                );

                return lines.join("\n");
              }
            }
          }

          MyText {
            id: rightColumn
            anchors.right: parent.right
            anchors.top: parent.top

            anchors.left: leftColumn.right
            anchors.leftMargin: 0

            anchors.margins: 10

            wrapMode: Text.Wrap
            text: NwMonitor.statusTextFor(deviceItem.modelData)
          }
        }
      }
    }
  }

}
