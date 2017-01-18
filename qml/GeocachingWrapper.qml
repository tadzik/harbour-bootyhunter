import QtQuick 2.0
import QtQuick.LocalStorage 2.0
import harbour.bootyhunter 1.0
import "harbour-bootyhunter.js" as Geocaching

Item {
    id: me
    property var geocaching

    Providers {
        id: providers
    }

    OAuthSucks {
        id: oas
    }

    Component.onCompleted: {
        me.geocaching = new Geocaching.Geocaching(providers, oas)
    }
}
