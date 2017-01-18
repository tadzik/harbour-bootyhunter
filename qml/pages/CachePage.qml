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
                id: mapButton
                visible: false
                text: qsTr("Show on map")
            }

            MenuItem {
                id: navigateButton
                text: qsTr("Loading the cache...")
            }
        }

        Column {
            id: column
            anchors.fill: parent

            PageHeader {
                id: cacheHeader
                title: page.cache.code
            }

            Label {
                width: parent.width
                id: cacheDetails
                text: "Loading cache details..."
                wrapMode: Text.WordWrap
            }

            BusyIndicator {
                width: parent.width
                id: loadingIndicator
                size: BusyIndicatorSize.Large
                running: true
            }

            Component.onCompleted: {
                app.geocaching.get_booty_details(page.cache, function (cache) {
                    loadingIndicator.running = false
                    loadingIndicator.visible = false
                    cacheHeader.title = cache.name
                    cacheDetails.text = "<b> Type: </b>" + cache.meta.type
                    cacheDetails.text += "<br /> <b> Size: </b>" + cache.meta.size2
                    cacheDetails.text += "<br /> <b> Difficulty: </b>" + cache.meta.difficulty
                    cacheDetails.text += "<br /> <b> Terrain: </b>" + cache.meta.terrain
                    cacheDetails.text += "<br /> <b> Hidden: </b>" + formatDate(cache.meta.date_hidden)
                    cacheDetails.text += "<br /> <b> Last found: </b>" + formatDate(cache.meta.last_found)
                    cacheDetails.text += "<br /> <b> Status: </b>" + cache.meta.status
                    cacheDetails.text += "<br /> <b> Owner: </b>" + cache.meta.owner.username
                    var visits = cache.meta.founds + cache.meta.notfounds
                    var successrate = cache.meta.founds / visits
                    successrate = (successrate * 100).toPrecision(3);
                    cacheDetails.text += "<br /> <b> Success rate: </b>" + successrate + "%"
                    cacheDetails.text += "<br /> <b> Description: </b> <p>"
                            + cache.meta.description + "</p>"
                    flickable.contentHeight = column.height = cacheDetails.contentHeight + cacheHeader.height
                    navigateButton.text = qsTr("Navigate")
                    navigateButton.clicked.connect(function() {
                        pageStack.push(Qt.resolvedUrl("NavigatePage.qml"), { cache: cache })
                    })
                    mapButton.clicked.connect(function() {
                        pageStack.push(Qt.resolvedUrl("MapPage.qml"), {
                            caches: [cache], popOnClick: true
                        })
                    })
                    mapButton.visible = true
                })
            }

            function formatDate(date) {
                if (date) {
                    return date.replace(/T/, ' ').replace(/\+.*$/, '')
                } else {
                    return "unknown"
                }
            }
        }
    }
}
