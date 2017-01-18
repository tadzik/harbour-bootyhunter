import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page
    property string hint

    Column {
        anchors.fill: parent

        PageHeader {
            title: qsTr("Hint")
        }

        Label {
            // poor man's padding
            width: parent.width - Theme.paddingLarge * 2
            anchors.horizontalCenter: parent.horizontalCenter
            wrapMode: Text.WordWrap
            text: hint
        }
    }
}
