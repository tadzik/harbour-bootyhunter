#ifndef _OAUTH_SUCKS_H_
#define _OAUTH_SUCKS_H_

#include <QNetworkAccessManager>
#include <QObject>
#include <QString>
#include <QVariantMap>
#include <QtWebView>

class OAuthSucks : public QObject {
    Q_OBJECT;

    QString baseUrl;
    QString consumerKey;
    QString consumerSecret;
    QString tokenKey;
    QString tokenSecret;
    QNetworkAccessManager* nam;
    QObject* webView;

    QString sign_args(QString, QMap<QString, QString>&);

public:
    OAuthSucks();
    Q_INVOKABLE QString do_shit(QObject*);

private slots:
    void onRequestTokenFinished();
};

#endif
