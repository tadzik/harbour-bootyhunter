import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    Column {
        anchors.fill: parent

        PageHeader {
            title: "Map unavailable"
        }

        Label {
            // poor man's padding
            width: parent.width - Theme.paddingLarge * 2
            anchors.horizontalCenter: parent.horizontalCenter
            wrapMode: Text.WordWrap
            text: "Unfortunately, due to Jolla's restrictions on certain QML libraries," +
                  "the map feature is not available in the Jolla Store release. Sorry for that!\n" +
                  "If you want to make full use of Bootyhunter and have the map available " +
                  "as it was intended, check out openrepos.net and install Bootyhunter " +
                  " from the Warehouse app instead."
        }
    }
}
