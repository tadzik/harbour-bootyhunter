import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: settingsPage

    ListModel {
        id: model
        ListElement { service_id: "opencaching.pl"; authorized: false }
        ListElement { service_id: "opencaching.de"; authorized: false }
        ListElement { service_id: "opencaching.us"; authorized: false }
        ListElement { service_id: "opencaching.nl"; authorized: false }
        ListElement { service_id: "opencaching.ro"; authorized: false }
        ListElement { service_id: "opencache.uk";   authorized: false }
    }

    SilicaListView {
        id: listView
        header: PageHeader {
            title: qsTr("Settings")
        }
        model: model
        anchors.fill: parent
        delegate: Item {
            width: ListView.view.width
            height: Theme.itemSizeSmall
            Column {
                anchors.centerIn: parent
                Button {
                    visible: !authorized
                    text: qsTr("Authorize with ") + service_id
                    onClicked: {
                        var service = app.geocaching.get_service_for(service_id)
                        if (!service) {
                            pageStack.push(Qt.resolvedUrl("ErrorPage.qml"), {
                                message: "Looks like this service is there in the UI, " +
                                         "but not yet wired in the backend. Sorry for that!"
                            })
                            return
                        }

                        pageStack.push(Qt.resolvedUrl("OAuthPage.qml"), {
                            service: service,
                            cb: function(tokenKey, tokenSecret) {
                                app.geocaching.store_keys(service_id, tokenKey, tokenSecret)
                                settingsPage.reload()
                                if (pageStack.previousPage(settingsPage).refresh) {
                                    pageStack.previousPage(settingsPage).refresh()
                                }
                            }
                        })
                    }
                }

                Label {
                    visible: authorized
                    text: qsTr("Authorized with ") + service_id
                }
            }
        }
    }

    Component.onCompleted: {
        settingsPage.reload()
    }

    function reload() {
        for (var i = 0; i < model.count; i++) {
            var service = model.get(i)
            var authorized = app.geocaching.is_service_authorized(service.service_id)
            model.set(i, { authorized: authorized })
        }
    }
}

