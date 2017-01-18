import QtQuick 2.0
import Sailfish.Silica 1.0
import QtPositioning 5.3
import QtLocation 5.0

Page {
    id: page
    backNavigation: false

    Plugin {
        id: osmPlugin
        name: "osm"
    }

    property var caches
    property bool showLabels
    property bool popOnClick

    ListModel {
        id: cacheModel
    }

    Component.onCompleted: {
        for (var i = 0; i < caches.length; i++) {
            cacheModel.append(caches[i])
        }
        map.zoomLevel = 15
        page.showLabels = false
        map.center = QtPositioning.coordinate(app.geocaching.current_lat, app.geocaching.current_lon, 0.0)
        map.gesture.pinchUpdated.connect(function(ev) {
            if (map.zoomLevel < 16) {
                page.showLabels = false
            } else {
                page.showLabels = true
            }
            //console.log("Map zoomLevel is now " + map.zoomLevel)
        })
    }

    Column {
        id: column
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width

        spacing: Theme.paddingSmall

        Map {
            id: map
            plugin: osmPlugin
            width: parent.width
            height: page.height// - backButton.height - column.spacing
            anchors.horizontalCenter: parent.horizontalCenter

            Behavior on center {
                CoordinateAnimation {
                    duration: 500
                    easing.type: Easing.InOutQuad
                }
            }

            MouseArea {
                anchors.fill: parent
                onDoubleClicked: {
                    map.center = youAreHere.coordinate
                }
            }

            MapQuickItem {
                id: youAreHere
                coordinate: QtPositioning.coordinate(app.geocaching.current_lat, app.geocaching.current_lon)
                anchorPoint.x: Theme.iconSizeExtraSmall * 0.5
                anchorPoint.y: Theme.iconSizeExtraSmall * 0.5

                sourceItem: Rectangle {
                    color: "red"
                    width: Theme.iconSizeSmall * 0.5
                    height: Theme.iconSizeSmall * 0.5
                    radius: Theme.iconSizeSmall
                }
            }

            Connections {
                target: app.geocaching.nav_providers.positionSource
                onPositionChanged: {
                    youAreHere.coordinate = app.geocaching.nav_providers.positionSource.position.coordinate
                }
            }

            MapItemView {
                model: cacheModel

                delegate: MapQuickItem {
                    coordinate: QtPositioning.coordinate(lat, lon)

                    anchorPoint.x: image.width * 0.5
                    anchorPoint.y: image.height * 0.5

                    sourceItem: Column {
                        Image {
                            id: image
                            width: Theme.iconSizeSmall * 1.5
                            height: Theme.iconSizeSmall * 1.5
                            source: "../img/cache-icon.png"
                            MouseArea {
                                anchors.fill: parent
                                onClicked: { page.showCache(cacheModel.get(index)) }
                            }
                        }
                        Text {
                            text: name
                            anchors.horizontalCenter: image.horizontalCenter
                            font.bold: true
                            visible: page.showLabels
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    if (parent.visible) page.showCache(cacheModel.get(index))
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                anchors.top: map.top
                anchors.left: map.left
                color: Theme.highlightBackgroundColor
                width: backButton.width
                height: backButton.height


                IconButton {
                    id: backButton
                    anchors.fill: parent
                    icon.source: "image://theme/icon-m-back"
                    onClicked: { pageStack.pop() }
                }
            }
        }
    }

    function showCache(cache) {
        if (page.popOnClick) {
            pageStack.pop()
        } else {
            pageStack.push(Qt.resolvedUrl("CachePage.qml"), { cache: cache })
        }
    }
}
