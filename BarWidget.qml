import QtQuick
import Quickshell
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "x-notifications"

  readonly property string pluginDir: (Quickshell.env("HOME") || "") + "/.config/omarchy/plugins/x-notifications"

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "𝕏"
    slotSize: Style.bar.statusSlot
    tooltipText: "X popover"
    onPressed: if (root.bar) root.bar.run(root.pluginDir + "/bin/x-notifications-toggle")
  }
}
