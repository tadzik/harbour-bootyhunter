import QtQuick 2.0
import QtPositioning 5.2
import Sailfish.Silica 1.0
import ".."
Page {
    id: page
    property var caches
    property string error

    function refresh() {
        app.geocaching.get_nearest_booties(function (caches) {
            if (caches.length === 1 && caches[0].error) {
                page.error = "No services authorized. Make sure to login to some in the Settings"
                return
            } else {
                page.error = ""
            }

            page.caches = caches
            cacheListModel.clear()
            for (var i = 0; i < caches.length; i++) {
                cacheListModel.append(caches[i])
            }
        })
    }

    SilicaListView {
        id: listview
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: qsTr("Settings")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
                }
            }
            MenuItem {
                text: qsTr("Refresh")
                onClicked: page.refresh()
            }
            MenuItem {
                text: qsTr("Show map")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("MapPage.qml"), { caches: caches })
                }
            }
        }

        header: PageHeader {
            id: header
            title: qsTr("Nearest geocaches")
        }

        model: ListModel {
            id: cacheListModel
        }

        Label {
            visible: error
            width: parent.width - Theme.paddingLarge * 2
            anchors.centerIn: parent
            wrapMode: Text.WordWrap
            text: error
        }

        delegate: Item {
            id: item
            width: ListView.view.width
            height: Theme.itemSizeMedium
            Column {
                id: itemcol
                spacing: Theme.paddingSmall
                Label {
                    text: "<b>" + name + "</b>"
                }
                Row {
                    spacing: Theme.paddingLarge
                    Label {
                        text: code
                    }
                    Label {
                        text: type
                    }
                    Label {
                        text: meta.distance_str
                    }
                }
            }
            MouseArea {
                anchors.fill: item
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("CachePage.qml"), { cache: cacheListModel.get(index) })
                }
            }
        }
    }


    Connections {
        target: app.geocaching.nav_providers.positionSource
        onPositionChanged: {
            console.log("Signal caught, reloading the model")
            if (!page.caches) return
            for (var i = 0; i < page.caches.length; i++) {
                var cache = page.caches[i]
                cacheListModel.set(i, { meta: cache.meta })
            }
        }
    }

    Component.onCompleted: {
        refresh()
    }
}
