import Quickshell
import Quickshell.Io
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Layouts

Scope {
    id: root

    Theme { id: theme }

    readonly property color bg: theme.base
    readonly property color panel: theme.mantle
    readonly property color text: theme.text
    readonly property color muted: theme.overlay0
    readonly property color blue: theme.blue
    readonly property color green: theme.green
    readonly property color yellow: theme.yellow
    readonly property color peach: theme.peach
    readonly property color red: theme.red
    readonly property color mauve: theme.mauve
    readonly property int fontSize: 16

    property string volumeText: ""
    property string brightnessText: ""
    property string networkText: ""
    property string batteryText: ""
    property string bluetoothText: ""
    property string memoryText: ""
    property string cpuText: ""
    property real cpuLastIdle: 0
    property real cpuLastTotal: 0

    function setVolume(output) {
        const line = String(output).trim()
        const match = line.match(/([0-9]+(?:\.[0-9]+)?)/)
        const percent = match ? Math.round(parseFloat(match[1]) * 100) : 0
        const muted = /muted/i.test(line)

        volumeText = muted ? "󰝟 muted" : `󰕾 ${percent}%`
    }

    function setBrightness(output) {
        const line = String(output).trim()
        const parts = line.split(",")
        const percent = parts.length >= 4 ? parseInt(parts[3].replace("%", "")) || 0 : 0

        brightnessText = `󰃟 ${percent}%`
    }

    function setNetwork(output) {
        const line = String(output).trim()
        if (!line) {
            networkText = "󰤭 offline"
            return
        }

        const parts = line.split(/\s+/)
        const kind = parts.shift() || ""
        const name = parts.join(" ") || kind

        networkText = kind === "ethernet" ? `󰈀 ${name}` : `󰖩 ${name}`
    }

    function setBattery(output) {
        const line = String(output).trim()
        if (!line) {
            batteryText = "󰂎 n/a"
            return
        }

        const parts = line.split(/\s+/)
        const percent = parseInt(parts[0]) || 0
        const status = (parts.slice(1).join(" ") || "").toLowerCase()
        const charging = status.includes("charging") || status.includes("full")

        let icon = "󰁺"
        if (charging) {
            icon = "󰂄"
        } else if (percent >= 95) {
            icon = "󰁹"
        } else if (percent >= 80) {
            icon = "󰂂"
        } else if (percent >= 60) {
            icon = "󰂀"
        } else if (percent >= 40) {
            icon = "󰁾"
        } else if (percent >= 20) {
            icon = "󰁼"
        }

        batteryText = `${icon} ${percent}%`
    }

    function setBluetooth(output) {
        const line = String(output).trim().toLowerCase()
        if (!line) {
            bluetoothText = "󰂲 off"
            return
        }

        bluetoothText = line === "yes" ? "󰂯 on" : "󰂲 off"
    }

    function setMemory(output) {
        const line = String(output).trim()
        const parts = line.split(/\s+/)
        const used = parseInt(parts[0]) || 0
        const total = parseInt(parts[1]) || 1
        const percent = Math.round((used / total) * 100)

        memoryText = ` ${percent}%`
    }

    function setCpu(output) {
        const line = String(output).trim()
        const parts = line.split(/\s+/).map(v => parseInt(v) || 0)
        if (parts.length < 8) {
            return
        }

        const idle = parts[3] + parts[4]
        const total = parts.reduce((a, b) => a + b, 0)

        if (cpuLastTotal <= 0 || total <= cpuLastTotal) {
            cpuText = " --%"
            cpuLastIdle = idle
            cpuLastTotal = total
            return
        }

        const idleDelta = idle - cpuLastIdle
        const totalDelta = total - cpuLastTotal
        const usage = Math.max(0, Math.min(100, Math.round(100 * (1 - idleDelta / totalDelta))))
        cpuText = ` ${usage}%`

        cpuLastIdle = idle
        cpuLastTotal = total
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    Process {
        id: volumeProc
        command: ["bash", "-lc", "wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || true"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.setVolume(this.text)
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: volumeProc.running = true
    }

    Process {
        id: brightnessProc
        command: ["bash", "-lc", "brightnessctl -m 2>/dev/null || true"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.setBrightness(this.text)
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: brightnessProc.running = true
    }

    Process {
        id: networkProc
        command: ["bash", "-lc", "nmcli -t -f TYPE,STATE,CONNECTION dev 2>/dev/null | while IFS=: read -r type state name; do if [ \"$type\" = wifi ] && [ \"$state\" = connected ]; then printf 'wifi %s\\n' \"$name\"; exit 0; fi; if [ \"$type\" = ethernet ] && [ \"$state\" = connected ]; then printf 'ethernet %s\\n' \"$name\"; exit 0; fi; done"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.setNetwork(this.text)
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: networkProc.running = true
    }

    Process {
        id: batteryProc
        command: ["bash", "-lc", "for b in /sys/class/power_supply/BAT*; do [ -d \"$b\" ] || continue; cap=$(cat \"$b/capacity\" 2>/dev/null || true); status=$(cat \"$b/status\" 2>/dev/null || true); [ -n \"$cap\" ] && { printf '%s %s\n' \"$cap\" \"$status\"; exit 0; }; done"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.setBattery(this.text)
        }
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: batteryProc.running = true
    }

    Process {
        id: bluetoothProc
        command: ["bash", "-lc", "bluetoothctl show 2>/dev/null | awk -F': ' '/Powered/ {print $2; exit}' || true"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.setBluetooth(this.text)
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: bluetoothProc.running = true
    }

    Process {
        id: memoryProc
        command: ["bash", "-lc", "free -m | awk '/^Mem:/ {print $3, $2}'"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.setMemory(this.text)
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: memoryProc.running = true
    }

    Process {
        id: cpuProc
        command: ["bash", "-lc", "awk '/^cpu / {for (i = 2; i <= 9; i++) printf \"%s \", $i; print \"\"}' /proc/stat"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.setCpu(this.text)
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: cpuProc.running = true
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panelWindow
            required property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: 36
            color: root.bg
            focusable: false

            Item {
                anchors.fill: parent
                anchors.margins: 8

                RowLayout {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 6

                    Rectangle {
                        radius: 8
                        color: root.panel
                        implicitHeight: 24
                        implicitWidth: brightText.implicitWidth + 20
                        visible: root.brightnessText.length > 0

                        Text {
                            id: brightText
                            anchors.centerIn: parent
                            text: root.brightnessText
                            color: root.yellow
                            font.family: "Iosevka Nerd Font"
                            font.pixelSize: root.fontSize
                        }
                    }

                    Rectangle {
                        radius: 8
                        color: root.panel
                        implicitHeight: 24
                        implicitWidth: netText.implicitWidth + 20
                        visible: root.networkText.length > 0

                        Text {
                            id: netText
                            anchors.centerIn: parent
                            text: root.networkText
                            color: root.green
                            font.family: "Iosevka Nerd Font"
                            font.pixelSize: root.fontSize
                        }
                    }

                    Rectangle {
                        radius: 8
                        color: root.panel
                        implicitHeight: 24
                        implicitWidth: btText.implicitWidth + 20
                        visible: root.bluetoothText.length > 0

                        Text {
                            id: btText
                            anchors.centerIn: parent
                            text: root.bluetoothText
                            color: root.mauve
                            font.family: "Iosevka Nerd Font"
                            font.pixelSize: root.fontSize
                        }
                    }

                    Rectangle {
                        radius: 8
                        color: root.panel
                        implicitHeight: 24
                        implicitWidth: memText.implicitWidth + 20
                        visible: root.memoryText.length > 0

                        Text {
                            id: memText
                            anchors.centerIn: parent
                            text: root.memoryText
                            color: root.peach
                            font.family: "Iosevka Nerd Font"
                            font.pixelSize: root.fontSize
                        }
                    }

                    Rectangle {
                        radius: 8
                        color: root.panel
                        implicitHeight: 24
                        implicitWidth: cpuText.implicitWidth + 20
                        visible: root.cpuText.length > 0

                        Text {
                            id: cpuText
                            anchors.centerIn: parent
                            text: root.cpuText
                            color: root.red
                            font.family: "Iosevka Nerd Font"
                            font.pixelSize: root.fontSize
                        }
                    }

                    Rectangle {
                        radius: 8
                        color: root.panel
                        implicitHeight: 24
                        implicitWidth: batText.implicitWidth + 20
                        visible: root.batteryText.length > 0

                        Text {
                            id: batText
                            anchors.centerIn: parent
                            text: root.batteryText
                            color: root.text
                            font.family: "Iosevka Nerd Font"
                            font.pixelSize: root.fontSize
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: Qt.formatDateTime(clock.date, "ddd MMM d HH:mm")
                    color: root.text
                    font.family: "Iosevka Nerd Font"
                    font.pixelSize: root.fontSize
                    font.bold: true
                }

                RowLayout {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4

                    Rectangle {
                        radius: 8
                        color: root.panel
                        implicitHeight: 24
                        implicitWidth: volText.implicitWidth + 20
                        visible: root.volumeText.length > 0

                        Text {
                            id: volText
                            anchors.centerIn: parent
                            text: root.volumeText
                            color: root.blue
                            font.family: "Iosevka Nerd Font"
                            font.pixelSize: root.fontSize
                        }
                    }

                    Repeater {
                        model: SystemTray.items ? SystemTray.items.values : []

                        delegate: Item {
                            id: trayItem
                            required property var modelData
                            width: 22
                            height: 22

                            Image {
                                anchors.fill: parent
                                source: modelData.id === "niri-shadow-guard"
                                    ? "file://" + Quickshell.env("HOME") + "/.local/share/icons/niri-shadow-guard.png"
                                    : modelData.icon
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                            }

                            MouseArea {
                                anchors.fill: parent
                                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: mouse => {
                                    if (mouse.button === Qt.LeftButton) {
                                        if (modelData.onlyMenu && modelData.hasMenu) {
                                            const p = trayItem.mapToItem(panelWindow.contentItem, mouse.x, mouse.y)
                                            modelData.display(panelWindow, p.x, p.y)
                                        } else {
                                            modelData.activate()
                                        }
                                    } else if (mouse.button === Qt.MiddleButton) {
                                        modelData.secondaryActivate()
                                    } else if (mouse.button === Qt.RightButton && modelData.hasMenu) {
                                        const p = trayItem.mapToItem(panelWindow.contentItem, mouse.x, mouse.y)
                                        modelData.display(panelWindow, p.x, p.y)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
