import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Pipewire
import QtQuick

import qs
import qs.components

WrapperMouseArea {
  id: root

  implicitHeight: parent.height
  implicitWidth: parent.height
  margin: 0

  PwObjectTracker {
    objects: [ Pipewire.defaultAudioSink, Pipewire.defaultAudioSource ]
  }

  CircularChart {
    size: parent.height
    icon: {
      const audio = Pipewire.defaultAudioSink?.audio;
      if (!audio) return "󰝟"
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
    percentage: Pipewire.defaultAudioSink?.audio?.volume ?? 0.0
    color: Pipewire.defaultAudioSink?.audio?.muted ? Style.themeSelection : Style.themeForeground
  }

  acceptedButtons: Qt.LeftButton | Qt.RightButton
  onClicked: (mouse) => {
    switch (mouse.button) {
      case Qt.LeftButton:
        // Pipewire.toggleMuteDefaultAudioSink()
        if (Pipewire.defaultAudioSink?.audio)
          Pipewire.defaultAudioSink.audio.muted = !Pipewire.defaultAudioSink.audio.muted
        break
      case Qt.RightButton:
        // Quickshell.execDetached("pavucontrol")
        Quickshell.execDetached(["nirius", "focus-or-spawn", "-a", "org.pulseaudio.pavucontrol", "pavucontrol"])
        break
    }
  }

  onWheel: (mouse) => {
    const step = 0.01
    const audio = Pipewire.defaultAudioSink?.audio
    if (!audio) return;

    if (mouse.angleDelta.y > 0) {
      audio.volume += step
    } else if (mouse.angleDelta.y < 0) {
      audio.volume = Math.max(0.0, audio.volume - step)
    }
  }

  hoverEnabled: true
  Tooltip {
    anchor.item: root
    visible: root.containsMouse

    implicitWidth: tooltipText.paintedWidth + 16
    implicitHeight: tooltipText.paintedHeight + 16

    MyText {
      id: tooltipText
      anchors.centerIn: parent
      text: {
        const lines = [];

        const sink = Pipewire.defaultAudioSink;
        if (!sink) {
          lines.push("No audio sink available");
        } else {
          lines.push(`Output: ${sink.description}: ${Math.round(sink.audio.volume * 100)}% ${sink.audio.muted ? "(Muted)" : ""}`);
        }

        const source = Pipewire.defaultAudioSource;
        if (!source) {
          lines.push("No audio source available");
        } else {
          lines.push(`Input: ${source.description}: ${Math.round(source.audio.volume * 100)}% ${source.audio.muted ? "(Muted)" : ""}`);
        }

        return lines.join("\n");
      }
    }
  }


}
