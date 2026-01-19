import qs
import qs.components
import qs.modules
import Quickshell.Widgets
import Quickshell.Services.UPower

WrapperMouseArea {
  id: root

  visible: UPower.displayDevice.isPresent

  implicitHeight: parent.height
  implicitWidth: parent.height
  hoverEnabled: true
  margin: 0
  CircularChart {
    size: parent.height
    icon: {
      const levelIcon = icons => {
        const arr = [...icons];
        const idx = Math.round(UPower.displayDevice.percentage * arr.length);
        return arr[Math.min(arr.length - 1, Math.max(0, idx))];
      };

      switch (UPower.displayDevice.state) {
        case UPowerDeviceState.Unknown: return "󰂑";
        case UPowerDeviceState.Empty: return "󰂎";
        case UPowerDeviceState.FullyCharged: return "󰁹";
        case UPowerDeviceState.Charging: return levelIcon("󰢟󰢜󰂆󰂇󰂈󰢝󰂉󰢞󰂊󰂋󰂅");
        case UPowerDeviceState.PendingCharge: return "󱧦";
        case UPowerDeviceState.Discharging: return levelIcon("󰂎󰁺󰁻󰁼󰁽󰁾󰁿󰂀󰂁󰂂󰁹");
        case UPowerDeviceState.PendingDischarge: return "󱧦";
      }
    }
    percentage: UPower.displayDevice.percentage
    color: percentage < 0.2 ? Style.themeRed : Style.foreground
  }

  Tooltip {
    anchor.item: root

    visible: root.containsMouse
    implicitWidth: text.paintedWidth + 20
    implicitHeight: text.paintedHeight + 20
    MyText {
      id: text
      anchors.centerIn: parent
      text: [
          `${(UPower.displayDevice.percentage * 100).toFixed(1)}%`,
          UPower.displayDevice.timeToEmpty > 0
            ? (UPower.displayDevice.timeToEmpty / 3600).toFixed(1) + 'h remaining'
            : (UPower.displayDevice.timeToFull / 3600).toFixed(1) + 'h to full',
          `${UPower.displayDevice.energy} Wh / ${UPower.displayDevice.energyCapacity} Wh`,
          `${UPower.displayDevice.changeRate} W`
        ].join("\n")
    }

  }

}

