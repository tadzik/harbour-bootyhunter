import QtQuick 2.0
import Sailfish.Silica 1.0
import ".."

Page {
    id: page
    property var cache

    SilicaFlickable {
        id: flickable
        anchors.fill: parent
        contentHeight: column.height

        PullDownMenu {
            MenuItem {
                text: qsTr("Show on map")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("MapPage.qml"), {
                        caches: [cache],
                        popOnClick: true
                    })
                }
            }
            MenuItem {
                id: hintButton
                text: qsTr("Show hint")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("HintPage.qml"), {
                        hint: cache.meta.hint2
                    })
                }
            }
        }

        Column {
            id: column
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width

            spacing: Theme.paddingLarge

            PageHeader {
                title: "Navigation"
            }

            Rectangle {
                color: Theme.highlightBackgroundColor
                height: width
                width: parent.width - Theme.paddingLarge * 2
                radius: width
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    id: needle
                    color: Theme.primaryColor
                    height: parent.height / 2
                    width: height / 10
                    radius: width / 2
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: false

                    transform: Rotation {
                        id: needleRotation
                        origin.x: needle.width / 2
                        origin.y: needle.height
                        angle: 0
                    }
                }

                Rectangle {
                    id: directionUnknown
                    color: Theme.primaryColor
                    anchors.centerIn: parent
                    width: parent.width / 5
                    height: width
                    radius: width
                }
            }

            Label {
                id: distanceLabel
                property string distance_str
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: Theme.fontSizeHuge
                text: "Distance: " + distance_str
            }

            Label {
                id: debugInfo
                wrapMode: Text.WordWrap
                text: ""
            }
        }

        Connections {
            target: app.geocaching.nav_providers.positionSource
            onPositionChanged: {
                var direction = app.geocaching.nav_providers.gpsDataSource.movementDirection
                var coords =    app.geocaching.nav_providers.positionSource.position.coordinate
                if (isNaN(direction)) {
                    directionUnknown.visible = true
                    needle.visible = false
                } else {
                    needle.visible = true
                    directionUnknown.visible = false
                    cache.calculate_bearing(coords.latitude, coords.longitude)
                    var bearing   = cache.meta.bearing
                    needleRotation.angle = bearing - direction
                    debugInfo.text = "Our direction: " + direction + "\n" +
                                     "Bearing to cache: " + bearing + "\n" +
                                     "Our position: " + coords.latitude + "|" + coords.longitude + "\n" +
                                     "Cache position: " + cache.lat + "|" + cache.lon + "\n"
                }
                cache.calculate_distance(coords.latitude, coords.longitude)
                distanceLabel.distance_str = cache.meta.distance_str
            }
        }
    }
}
