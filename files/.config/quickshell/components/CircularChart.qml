import qs

import QtQuick
import QtQuick.Shapes

Item {
  id: root

  required property real size
  required property real percentage
  property color color: Style.foreground

  property alias icon: text.text

  readonly property real centerX: width / 2
  readonly property real centerY: height / 2
  readonly property real arcRadius: Math.min(width, height) / 2 - 4
  readonly property real startAngle: -90
  readonly property real degree: percentage * 360.

  Shape {
    anchors.fill: parent
    preferredRendererType: Shape.CurveRenderer

    ShapePath {
      id: primaryPath
      pathHints: ShapePath.PathSolid & ShapePath.PathNonIntersecting
      capStyle: ShapePath.RoundCap

      strokeColor: root.color
      strokeWidth: 2
      fillColor: 'transparent'
      joinStyle: ShapePath.RoundCap

      startX: root.centerX
      startY: root.centerY - root.arcRadius

      PathAngleArc {
        moveToStart: false
        centerX: root.centerX
        centerY: root.centerY
        radiusX: root.arcRadius
        radiusY: root.arcRadius
        startAngle: root.startAngle
        sweepAngle: root.degree
      }
    }
  }

  MyText {
    id: text
    color: root.color
    anchors.centerIn: parent
    font.pixelSize: parent.size * 0.5
    font.family: Style.iconFontFamily
  }
}
