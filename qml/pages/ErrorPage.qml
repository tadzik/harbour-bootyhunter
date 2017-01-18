import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    property string message

    Column {
        anchors.fill: parent

        PageHeader {
            title: "Error"
        }

        Label {
            // poor man's padding
            width: parent.width - Theme.paddingLarge * 2
            anchors.horizontalCenter: parent.horizontalCenter
            wrapMode: Text.WordWrap
            text: message
        }
    }
}
