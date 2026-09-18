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
            // Show new transient notifications, but do not carry them across a reload.
            notification.tracked = !notification.lastGeneration || !notification.transient
        }
    }

    PanelWindow {
        id: notificationWindow

        // Keep notifications on the primary output instead of relying on the
        // compositor's default when multiple monitors are connected.
        screen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null

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
        readonly property int maxHeight: screen ? Math.max(1, screen.height - 60) : 720
        implicitHeight: Math.min(stack.implicitHeight, maxHeight)

        Flickable {
            id: viewport
            anchors.fill: parent
            clip: true
            contentWidth: width
            contentHeight: stack.implicitHeight
            interactive: contentHeight > height
            flickableDirection: Flickable.VerticalFlick
            boundsBehavior: Flickable.StopAtBounds

            Column {
                id: stack
                width: viewport.width
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
}
