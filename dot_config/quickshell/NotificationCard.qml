import Quickshell
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    Theme { id: theme }

    required property var notification

    // Quickshell 0.2.x exposes the D-Bus timeout in milliseconds.
    // A negative value means the server default; zero means never expire.
    readonly property int timeoutMs: {
        const timeout = Number(notification.expireTimeout)
        if (!isFinite(timeout) || timeout < 0) {
            return 5000
        }

        return Math.max(0, Math.round(timeout))
    }

    implicitWidth: 360
    implicitHeight: card.implicitHeight

    Timer {
        interval: root.timeoutMs
        running: !notification.resident && root.timeoutMs > 0
        repeat: false
        onTriggered: notification.expire()
    }

    Rectangle {
        id: card
        width: parent.implicitWidth
        implicitHeight: content.implicitHeight + 18
        radius: 12
        color: theme.base
        border.width: 1
        border.color: notification.urgency === NotificationUrgency.Critical ? theme.red : theme.surface0

        MouseArea {
            anchors.fill: parent
            onClicked: notification.dismiss()
        }

        RowLayout {
            id: content
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10

            Rectangle {
                width: 40
                height: 40
                radius: 10
                color: theme.mantle

                Image {
                    anchors.fill: parent
                    anchors.margins: 6
                    source: notification.image && notification.image.length > 0 ? notification.image : Quickshell.iconPath(notification.appIcon, true)
                    sourceSize: Qt.size(40, 40)
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    smooth: true
                }
            }

            Column {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                spacing: 6

                Text {
                    width: parent.width
                    text: notification.appName && notification.appName.length > 0 ? notification.appName : "Notification"
                    textFormat: Text.PlainText
                    color: theme.text
                    font.family: "Monaspace Neon NF"
                    font.pixelSize: 18
                    font.bold: true
                    elide: Text.ElideRight
                }

                Text {
                    width: parent.width
                    text: notification.summary
                    textFormat: Text.PlainText
                    color: theme.rosewater
                    font.family: "Monaspace Neon NF"
                    font.pixelSize: 18
                    font.bold: true
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                }

                Text {
                    width: parent.width
                    text: notification.body
                    textFormat: Text.AutoText
                    color: theme.text
                    font.family: "Monaspace Neon NF"
                    font.pixelSize: 18
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    maximumLineCount: 4
                    elide: Text.ElideRight
                    visible: notification.body && notification.body.length > 0

                    onLinkActivated: link => {
                        const url = String(link)
                        if (/^(https?|mailto):/i.test(url)) {
                            Qt.openUrlExternally(url)
                        }
                    }
                }

                Flow {
                    id: actions
                    width: parent.width
                    height: childrenRect.height
                    spacing: 6

                    Repeater {
                        model: notification.actions || []

                        delegate: Rectangle {
                            required property var modelData
                            radius: 8
                            color: theme.surface0
                            implicitHeight: 24
                            implicitWidth: actionLabel.implicitWidth + 18

                            MouseArea {
                                anchors.fill: parent
                                onClicked: modelData.invoke()
                            }

                            Text {
                                id: actionLabel
                                anchors.centerIn: parent
                                text: modelData.text || "Action"
                                textFormat: Text.PlainText
                                color: theme.text
                                font.family: "Monaspace Neon NF"
                                font.pixelSize: 18
                            }
                        }
                    }

                    Rectangle {
                        radius: 8
                        color: theme.surface1
                        implicitHeight: 24
                        implicitWidth: closeLabel.implicitWidth + 18

                        MouseArea {
                            anchors.fill: parent
                            onClicked: notification.dismiss()
                        }

                        Text {
                            id: closeLabel
                            anchors.centerIn: parent
                            text: "Close"
                            textFormat: Text.PlainText
                            color: theme.text
                            font.family: "Monaspace Neon NF"
                            font.pixelSize: 18
                        }
                    }
                }
            }
        }
    }
}
