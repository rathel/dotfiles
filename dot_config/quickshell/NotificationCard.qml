import Quickshell
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts

Item {
    Theme { id: theme }

    required property var notification

    implicitWidth: 360
    implicitHeight: card.implicitHeight

    Timer {
        interval: notification.expireTimeout > 0 ? notification.expireTimeout * 1000 : 5000
        running: !notification.resident
        repeat: false
        onTriggered: notification.dismiss()
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
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                }
            }

            Column {
                Layout.fillWidth: true
                spacing: 6

                Text {
                    width: 280
                    text: notification.appName && notification.appName.length > 0 ? notification.appName : "Notification"
                    color: theme.text
                    font.family: "Iosevka Nerd Font"
                    font.pixelSize: 16
                    font.bold: true
                    elide: Text.ElideRight
                }

                Text {
                    width: 280
                    text: notification.summary
                    color: theme.rosewater
                    font.family: "Iosevka Nerd Font"
                    font.pixelSize: 16
                    font.bold: true
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                }

                Text {
                    width: 280
                    text: notification.body
                    color: theme.subtext0
                    font.family: "Iosevka Nerd Font"
                    font.pixelSize: 16
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    maximumLineCount: 4
                    elide: Text.ElideRight
                    visible: notification.body && notification.body.length > 0
                }

                RowLayout {
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
                                color: theme.text
                                font.family: "Iosevka Nerd Font"
                                font.pixelSize: 16
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
                            color: theme.text
                            font.family: "Iosevka Nerd Font"
                            font.pixelSize: 16
                        }
                    }
                }
            }
        }
    }
}
