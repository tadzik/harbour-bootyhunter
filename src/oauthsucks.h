#ifndef _OAUTH_SUCKS_H_
#define _OAUTH_SUCKS_H_

#include <QNetworkAccessManager>
#include <QObject>
#include <QString>
#include <QVariantMap>

class OAuthedService : public QObject {
    Q_OBJECT;

private:
    QString baseUrl;
    QString oauthUrl;
    QString consumerKey;
    QString consumerSecret;
    QString tokenKey;
    QString tokenSecret;
    QNetworkAccessManager* nam;
    QObject* webView;

    QString sign_args(QString, QMap<QString, QString>&);

public:
    OAuthedService(QString, QString, QString);
    Q_INVOKABLE void authorize(QObject*);
    Q_INVOKABLE void onRedirect(QString);
    Q_INVOKABLE QString get_base_url();
    Q_INVOKABLE QString get_consumer_key();

signals:
    void accessTokenAcquired(const QString& tokenKey, const QString& tokenSecret);

private slots:
    void onRequestTokenFinished();
    void onAccessTokenFinished();
};

class OAuthSucks : public QObject {
    Q_OBJECT;

private:
    QMap<QString, QList<QString>*>* services;

public:
    OAuthSucks();
    Q_INVOKABLE QObject* get_service_for(QString);

};

#endif
