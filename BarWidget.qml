import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "io.github.sette7blo.omaxbar"

  readonly property string pluginDir: (Quickshell.env("HOME") || "") + "/.config/omarchy/plugins/io.github.sette7blo.omaxbar"
  readonly property string toggleBin: root.pluginDir + "/bin/omaxbar-toggle"
  // Mirrors Hyprland, never set from a click: the popover can also be closed
  // by keybinds, workspace switches, or evict.
  property bool popoverVisible: false
  property bool statusStale: false

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  function refreshState() {
    if (statusProc.running) root.statusStale = true
    else statusProc.running = true
  }

  // The bar is assigned after the widget completes, so bootstrap once it lands.
  property bool bootstrapped: false
  function bootstrap() {
    if (root.bootstrapped || !root.bar) return
    root.bootstrapped = true
    root.bar.run(root.pluginDir + "/install.sh --if-needed")
  }
  onBarChanged: root.bootstrap()

  Component.onCompleted: {
    root.bootstrap()
    root.refreshState()
  }

  Process {
    id: statusProc
    command: [root.toggleBin, "status"]
    stdout: StdioCollector {
      onStreamFinished: root.popoverVisible = text.trim() === "1"
    }
    onExited: {
      if (!root.statusStale) return
      root.statusStale = false
      // Deferred: the process still reports running while it signals exit.
      Qt.callLater(root.refreshState)
    }
  }

  Connections {
    target: Hyprland
    function onRawEvent(event) {
      var name = event ? String(event.name) : ""
      if (name === "activespecial" || name === "activespecialv2" || name === "configreloaded") {
        root.refreshState()
      } else if (name === "openwindow" && root.bar) {
        // data: address,workspace,class,title
        var fields = String(event.data).split(",")
        if (fields.length > 1 && fields[1].indexOf("special:") === 0)
          root.bar.run(root.toggleBin + " evict " + fields[0])
      }
    }
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "𝕏"
    slotSize: Style.bar.statusSlot
    active: root.popoverVisible
    tooltipText: "Omaxbar"
    onPressed: function(b) {
      if (!root.bar) return
      if (b === Qt.LeftButton) root.bar.run(root.toggleBin)
      else if (b === Qt.RightButton) root.bar.run(root.pluginDir + "/bin/omaxbar-config")
    }
  }
}
