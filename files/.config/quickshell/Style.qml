pragma Singleton
import QtQuick
import Quickshell

Singleton {
  property color background: "#88202020" // argb

  property color popupBackground: "#DD282A36"
  property color foreground: themeForeground
  property font defaultFont: ({
    family: "Noto Sans CJK JP",
    pixelSize: 14,
  })
  property string iconFontFamily: "HackGen Console NF" // Nerd Font

  readonly property color barBackground: "#cc44475A"

  // dracula theme colors
  readonly property color themeBackground: "#282A36"
  readonly property color themeCurrentLine: "#6272A4"
  readonly property color themeSelection: "#44475A"
  readonly property color themeForeground: "#F8F8F2"
  readonly property color themeComment: "#6272A4"
  readonly property color themeRed: "#FF5555"
  readonly property color themeOrange: "#FFB86C"
  readonly property color themeYellow: "#F1FA8C"
  readonly property color themeGreen: "#50FA7B"
  readonly property color themeCyan: "#8BE9FD"
  readonly property color themePurple: "#BD93F9"
  readonly property color themePink: "#FF79C6"
}
