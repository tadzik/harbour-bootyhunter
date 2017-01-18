import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
    property var closest

    Column {
        width: parent.width
        spacing: Theme.paddingMedium

        Column {
            width: parent.width
            spacing: Theme.paddingSmall

            Label {
                id: nearest_label
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("<b>Nearest cache:<b>")
            }

            Label {
                id: nearest_distance
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("(unknown)")
            }
        }

        Rectangle {
            width: nearest_label.width
            height: nearest_label.height / 5
            anchors.horizontalCenter: parent.horizontalCenter

            color: Theme.primaryColor
            radius: height / 2
        }

        Column {
            width: parent.width
            spacing: Theme.paddingSmall

            Label {
                id: nearest_stats_howmany
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("(unknown)")
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("caches within")
            }

            Label {
                id: nearest_stats_where
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("(unknown)")
            }
        }
    }

    Component.onCompleted: {
        console.log("CoverPage connecting")
        app.geocaching.nav_providers.positionSource.positionChanged.connect(function() {
            console.log("Handling the signal in the coverpage")
            closest = app.geocaching.get_nearest_booty()
            if (closest) {
                nearest_distance.text = "<b>" + closest.meta.distance_str + "</b>"
            }
            var stats = app.geocaching.get_nearest_stats()
            nearest_stats_howmany.text = "<b> " + stats[0] + "</b>"
            nearest_stats_where.text   = "<b> " + stats[1] + "</b>"
        })
    }

    CoverActionList {
        id: coverAction

        CoverAction {
            iconSource: "image://theme/icon-cover-next"
            onTriggered: {
                if (!closest) return
                pageStack.push(Qt.resolvedUrl("../pages/CachePage.qml"), { cache: closest })
                app.activate()
            }
        }
    }
}


