import Quickshell
import Quickshell.Services.Notifications
import QtQuick

Scope {
    NotificationServer {
        id: server
        actionsSupported: true
        bodySupported: true
        bodyImagesSupported: true
        bodyMarkupSupported: true
        bodyHyperlinksSupported: true
        imageSupported: true
        persistenceSupported: true
        keepOnReload: true

        onNotification: notification => {
            notification.tracked = true
        }
    }

    PanelWindow {
        anchors {
            top: true
            right: true
        }

        margins {
            top: 44
            right: 12
        }
        aboveWindows: true
        focusable: false
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"
        implicitWidth: 380
        implicitHeight: stack.implicitHeight

        Column {
            id: stack
            spacing: 8

            Repeater {
                model: server.trackedNotifications ? server.trackedNotifications.values : []

                delegate: NotificationCard {
                    required property var modelData
                    notification: modelData
                }
            }
        }
    }
}
