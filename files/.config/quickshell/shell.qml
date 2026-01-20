//@ pragma UseQApplication
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.modules


Scope {
  id: root

  Variants {
    model: Quickshell.screens;
    delegate: Bar {
      required property ShellScreen modelData
      screen: modelData
    }
  }

  VolumeOsd {}

}
