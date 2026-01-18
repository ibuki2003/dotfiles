import QtQuick
import Quickshell
import Quickshell.Wayland

import QtQuick.Layouts
import Quickshell.Services.Pipewire

import qs
import qs.components

Scope {
  id: root

  PwObjectTracker {
    objects: [ Pipewire.defaultAudioSink ]
  }

  Connections {
    target: Pipewire.defaultAudioSink?.audio

    function onVolumeChanged() {
      root.shouldShowOsd = true;
      hideTimer.restart();
    }
  }

  property bool shouldShowOsd: false

  Timer {
    id: hideTimer
    interval: 1000
    onTriggered: root.shouldShowOsd = false
  }

  // The OSD window will be created and destroyed based on shouldShowOsd.
  // PanelWindow.visible could be set instead of using a loader, but using
  // a loader will reduce the memory overhead when the window isn't open.
  LazyLoader {
    active: root.shouldShowOsd

    PanelWindow {
      WlrLayershell.layer: WlrLayershell.Overlay
      // Since the panel's screen is unset, it will be picked by the compositor
      // when the window is created. Most compositors pick the current active monitor.

      anchors.bottom: true
      margins.bottom: screen.height / 5
      exclusiveZone: 0

      implicitWidth: 400
      implicitHeight: 50
      color: "transparent"

      // An empty click mask prevents the window from blocking mouse events.
      mask: Region {}

      Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: Style.popupBackground

        RowLayout {
          anchors {
            fill: parent
            leftMargin: 10
            rightMargin: 15
          }

          MyText {
            text: {
              const audio = Pipewire.defaultAudioSink.audio;
              if (audio.muted) {
                return "󰝟"
              } else if (audio.volume <= 1/3) {
                return "󰕿"
              } else if (audio.volume <= 2/3) {
                return "󰖀"
              } else {
                return "󰕾"
              }
            }
            font.family: Style.iconFontFamily
            color: Style.foreground
            font.pixelSize: 30
          }

          Rectangle {
            // Stretches to fill all left-over space
            Layout.fillWidth: true

            implicitHeight: 10
            radius: 20
            color: Style.themeComment

            Rectangle {
              anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
              }

              implicitWidth: parent.width * (Pipewire.defaultAudioSink?.audio.volume ?? 0)
              radius: parent.radius
            }
          }
        }
      }
    }
  }
}
