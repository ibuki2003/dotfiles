pragma ComponentBehavior: Bound
import QtQml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs
import qs.components

WrapperMouseArea {
  id: root
  implicitWidth: clockText.paintedWidth
  margin: 2

  hoverEnabled: true


  MyText {
    id: clockText
    anchors.centerIn: parent
    text: Qt.formatDateTime(clock.date, "ddd dd MMM hh:mm:ss")

    SystemClock {
      id: clock
      precision: SystemClock.Seconds
    }
  }

  // property int calendarMonth: clock.date.getMonth() + 1
  // property int calendarYear: clock.date.getFullYear()
  property date calendarMonth: clock.date

  onEntered: {
    // initialize calendar month and year
    calendarMonth = clock.date
    // set zero except for year and month
    calendarMonth.setDate(1)
    calendarMonth.setHours(0, 0, 0, 0)
  }
  onWheel: (wheel) => {
    if (wheel.angleDelta.y > 0) {
      calendarMonth.setMonth(calendarMonth.getMonth() - 1)
    } else if (wheel.angleDelta.y < 0) {
      calendarMonth.setMonth(calendarMonth.getMonth() + 1)
    }
  }

  Tooltip {
    visible: root.containsMouse
    anchor.item: root

    implicitWidth: inner.childrenRect.width + 30
    implicitHeight: titleText.height + inner.childrenRect.height + 30

    color: Style.background

    MyText {
      id: titleText
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.top: parent.top
      anchors.topMargin: 10

      text: Qt.formatDate(root.calendarMonth, "MMMM yyyy")
      font.bold: true
      font.pixelSize: 16
    }

    GridLayout {
      id: inner
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.top: titleText.bottom
      columns: 2

      DayOfWeekRow {
        locale: grid.locale

        Layout.column: 1
        Layout.fillWidth: true

        delegate: MyText {
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
          text: model.shortName
          required property var model
        }
      }

      WeekNumberColumn {
        month: grid.month
        year: grid.year
        locale: grid.locale

        Layout.fillHeight: true

        delegate: MyText {
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
          text: model.weekNumber
          required property var model
          color: Style.themeComment
        }
      }

      MonthGrid {
        id: grid
        month: root.calendarMonth.getMonth()
        year: root.calendarMonth.getFullYear()
        locale: Qt.locale("en_US")

        Layout.fillWidth: true
        Layout.fillHeight: true
        delegate: MyText {
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
          opacity: model.month === grid.month ? 1.0 : 0.4
          text: model.day

          required property var model
        }
      }
    }
  }
}
