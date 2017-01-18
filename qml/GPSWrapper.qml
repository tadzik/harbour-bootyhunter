import QtQuick 2.0
import QtPositioning 5.2

PositionSource {
    id: me
    updateInterval: 1000
    active: true

    property double direction

    signal positionUpdated
}
