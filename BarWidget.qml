import QtQuick
import Quickshell
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "io.github.sette7blo.omaxbar"

  readonly property string pluginDir: (Quickshell.env("HOME") || "") + "/.config/omarchy/plugins/io.github.sette7blo.omaxbar"
  property bool popoverVisible: false

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  Component.onCompleted: {
    if (root.bar) root.bar.run(root.pluginDir + "/install.sh --if-needed")
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "𝕏"
    slotSize: Style.bar.statusSlot
    active: root.popoverVisible
    tooltipText: "X Bar"
    onPressed: function(b) {
      if (b === Qt.LeftButton) {
        root.popoverVisible = !root.popoverVisible
        if (root.bar) root.bar.run(root.pluginDir + "/bin/omaxbar-toggle " + (root.popoverVisible ? "show" : "hide"))
      } else if (b === Qt.RightButton) {
        if (root.bar) root.bar.run(root.pluginDir + "/bin/omaxbar-config")
      }
    }
  }
}
