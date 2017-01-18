import QtQuick 2.0
import QtWebView 1.1
import harbour.bootyhunter 1.0

Rectangle {
    OAuthSucks {
        id: oas
    }

    WebView {
        id: webView
        width: 800
        height: 600
        url: "http://google.com"

        onLoadingChanged: {
            console.log('Request URL: ' + request.url)
        }
    }

    Component.onCompleted: {
        oas.do_shit(webView)
    }
}
