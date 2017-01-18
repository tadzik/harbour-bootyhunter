import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page
    property var service
    property var cb

    Component.onCompleted: {
        service.accessTokenAcquired.connect(function(tokenKey, tokenSecret) {
            console.log("We got shit: " + tokenKey + ", " + tokenSecret);
            pageStack.pop()
            cb(tokenKey, tokenSecret)
        })
        service.authorize(webView)
    }


    SilicaWebView {
        id: webView
        anchors.fill: parent
        onNavigationRequested: {
            service.onRedirect(request.url.toString())
        }
    }
}
