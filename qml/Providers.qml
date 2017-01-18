import QtQuick 2.0
import QtPositioning 5.2
import QtSensors 5.0
import harbour.bootyhunter 1.0

Item {
    property alias positionSource: positionSource
    property alias compass: compass
    property alias gpsDataSource: gpsDataSource
    PositionSource {
        id: positionSource
        updateInterval: 1000 //settings.updateInterval
        active: true
    }

    Compass {
        id: compass
        active: true
    }

    GPSDataSource {
        id: gpsDataSource
        updateInterval: 1000 //settings.updateInterval
        active: true
    }
}
