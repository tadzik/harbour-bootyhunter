#include <QtQuick/QQuickView>
#include <QGuiApplication>
#include <QtWebView>
#include "oauthsucks.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QtWebView::initialize();
    qmlRegisterType<OAuthSucks>("harbour.bootyhunter", 1, 0, "OAuthSucks");

    QQuickView view;
    view.setSource(QUrl("./app.qml"));
    view.show();

    return app.exec();
}
