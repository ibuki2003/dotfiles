pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Mpris

import qs
import qs.components

WrapperMouseArea {
  id: root

  margin: 2

  implicitWidth: inner.implicitWidth
  implicitHeight: parent.height

  property int playerIndex: 0
  readonly property int playerCount: Mpris.players.values.length

  readonly property var player: Mpris.players.values[root.playerIndex]

  acceptedButtons: Qt.LeftButton
  hoverEnabled: true
  cursorShape: Qt.PointingHandCursor

  function isIgnoredPlayer(player) {
    if (player.dbusName.endsWith(".playerctld")) return true
    if (player.dbusName.includes("firefox.instance")) return true
    return false
  }

  onWheel: (wheel) => {
    function scroll(delta) {
      if (root.playerCount === 0) return;
      let limit = root.playerCount;
      do {
        playerIndex = (playerIndex + (delta > 0 ? 1 : -1) + playerCount) % playerCount
        if (--limit <= 0) break;
      } while (isIgnoredPlayer(Mpris.players.values[playerIndex]))
    }
    if (wheel.angleDelta.y > 0) scroll(1)
    else if (wheel.angleDelta.y < 0) scroll(-1)
  }

  onClicked: (mouse) => {
    if (!root.player) return
    if (mouse.button === Qt.LeftButton) {
      root.player.togglePlaying()
    }
  }

  property real expandProgress: root.containsMouse ? 1.0 : 0.0

  Behavior on expandProgress {
    NumberAnimation {
      duration: 500
      easing.type: Easing.InOutQuad
    }
  }


  Item {
    id: inner
    anchors.left: root.left

    readonly property real gap: 4

    readonly property real expandedWidth: text.paintedWidth + playingIcon.paintedWidth + inner.gap * 2
    readonly property real shrinkedWidth: Math.min(200, expandedWidth)

    implicitWidth: shrinkedWidth + (expandedWidth - shrinkedWidth) * root.expandProgress
    implicitHeight: root.height
    clip: true

    MyText {
      id: playingIcon
      anchors.verticalCenter: parent.verticalCenter
      anchors.left: parent.left

      text: root.player?.isPlaying ? "󰏤" : "󰐊"
      font.family: Style.iconFontFamily
      font.pixelSize: parent.height * 0.8
    }
    MyText {
      id: text
      anchors.verticalCenter: parent.verticalCenter
      anchors.left: playingIcon.right
      anchors.leftMargin: inner.gap

      text: root.player?.trackTitle || "Unknown"
      // font.pixelSize: parent.height * 0.6
    }
  }


  property bool tooltipVisible: false
  property bool tooltipHovered: false

  onEntered: {
    root.tooltipVisible = true
  }

  Timer {
    interval: 200
    running: !root.containsMouse && !root.tooltipHovered
    repeat: false
    onTriggered: {
      root.tooltipVisible = false
    }
  }

  LazyLoader {
    active: root.tooltipVisible
    Tooltip {
      id: popup
      anchor.item: root

      implicitWidth: child.childrenRect.width + 10 + trackArtWrapper.width
      implicitHeight: child.childrenRect.height + progressBar.implicitHeight + 20
      visible: root.tooltipVisible

      MouseArea {
        anchors.fill: parent

        hoverEnabled: true
        onEntered: {
          root.tooltipHovered = true
        }
        onExited: {
          root.tooltipHovered = false
        }

        WrapperItem {
          id: trackArtWrapper
          anchors.left: parent.left
          anchors.top: parent.top

          implicitHeight: 100
          implicitWidth: 100
          margin: 5
          Image {
            source: root.player?.trackArtUrl
            mipmap: true
            fillMode: Image.PreserveAspectFit
          }
        }

        ColumnLayout {
          id: child

          Layout.fillWidth: true
          Layout.fillHeight: true

          anchors.top: parent.top
          anchors.left: trackArtWrapper.right

          spacing: 10
          MyText {
            text: `Player: ${root.player?.identity || "Unknown"}`
          }
          MyText {
            text: `Artist: ${root.player?.trackArtist || "Unknown"}`
          }
          MyText {
            text: `Album: ${root.player?.trackAlbum || "Unknown"}`
          }
          MyText {
            function formatTime(sec) {
              function pad2(num) {
                return num.toString().padStart(2, '0')
              }

              if (isNaN(sec) || !isFinite(sec)) return "0:00"
              if (sec < 0) sec = 0
              if (sec > 3600) {
                const hours = Math.floor(sec / 3600)
                const minutes = Math.floor((sec % 3600) / 60)
                const seconds = Math.floor(sec % 60)
                return `${hours}:${pad2(minutes)}:${pad2(seconds)}`
              } else {
                const minutes = Math.floor(sec / 60)
                const seconds = Math.floor(sec % 60)
                return `${minutes}:${pad2(seconds)}`
              }
            }
            text: `${formatTime(root.player?.position)} / ${formatTime(root.player?.length)}`
          }
        }

        ProgressBar {
          id: progressBar
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.bottom: parent.bottom
          anchors.top: child.bottom

          anchors.margins: 9

          implicitHeight: 5
          value: root.player.position / root.player.length
        }
        FrameAnimation {
          running: root.player.playbackState == MprisPlaybackState.Playing
          onTriggered: root.player.positionChanged()
        }
      }
    }
  }

  // watch for player changes
  // focus on changes in isPlaying and trackTitle

  property var _prevStates: ({})

  function selectPlayerIfChanged(idx) {
    const p = Mpris.players.values[idx]
    if (!p) return
    if (isIgnoredPlayer(p)) return;

    if (root._prevStates[idx] === undefined) {
      root.playerIndex = idx
    } else {
      const prev = root._prevStates[idx]
      if (prev.isPlaying !== p.isPlaying || prev.trackTitle !== p.trackTitle) {
        root.playerIndex = idx
      }
    }
    root._prevStates[idx] = { isPlaying: p.isPlaying, trackTitle: p.trackTitle }
  }

  Connections {
    target: Mpris.players
    function onObjectInsertedPost(_, idx) {
      selectPlayerIfChanged(idx)
    }
    function onObjectRemovedPre(_, idx) {
      if (root.playerIndex === idx) {
        root.playerIndex = 0
      }
    }
  }

  Instantiator {
    id: playerWatcher
    model: Array.from({length: Mpris.players.values.length}).map((_, i) => ({index: i, player: Mpris.players.values[i]}))

    delegate: QtObject {
      id: watcheritem
      // visible: false
      required property var modelData

      property bool isPlaying: modelData?.player?.isPlaying
      onIsPlayingChanged: {
        selectPlayerIfChanged(modelData.index)
      }

      property var conn: Connections {
        target: modelData.player
        function onTrackChanged() {
          selectPlayerIfChanged(modelData.index)
        }
      }
    }
  }
}
