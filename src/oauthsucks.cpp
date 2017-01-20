#include "oauthsucks.h"
#include "oauthkeys.h"
#include <QDateTime>
#include <QDebug>
#include <QMessageAuthenticationCode>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QUrl>
#include <QUrlQuery>

QString stringify_args(QMap<QString, QString>& args) {
    QString ret = "";

    QList<QString> keys = args.keys();
    qSort(keys);

    for (QList<QString>::iterator it = keys.begin(); it != keys.end(); it++) {
        if (it != keys.begin()) ret += "&";
        ret += QUrl::toPercentEncoding(*it) + "=" + args[*it];
    }

    return ret;
}

OAuthSucks::OAuthSucks()
{
    services = new QMap<QString, QList<QString>*>();
#ifdef OPENCACHING_PL_KEY
    services->insert("opencaching.pl", new QList<QString>());
    services->value("opencaching.pl")->append("http://opencaching.pl/okapi/services/");
    services->value("opencaching.pl")->append(OPENCACHING_PL_KEY);
    services->value("opencaching.pl")->append(OPENCACHING_PL_SEC);
#endif
#ifdef OPENCACHING_DE_KEY
    services->insert("opencaching.de", new QList<QString>());
    services->value("opencaching.de")->append("http://www.opencaching.de/okapi/services/");
    services->value("opencaching.de")->append(OPENCACHING_DE_KEY);
    services->value("opencaching.de")->append(OPENCACHING_DE_SEC);
#endif
#ifdef OPENCACHING_US_KEY
    services->insert("opencaching.us", new QList<QString>());
    services->value("opencaching.us")->append("http://opencaching.us/okapi/services/");
    services->value("opencaching.us")->append(OPENCACHING_US_KEY);
    services->value("opencaching.us")->append(OPENCACHING_US_SEC);
#endif
#ifdef OPENCACHING_NL_KEY
    services->insert("opencaching.nl", new QList<QString>());
    services->value("opencaching.nl")->append("http://opencaching.nl/okapi/services/");
    services->value("opencaching.nl")->append(OPENCACHING_NL_KEY);
    services->value("opencaching.nl")->append(OPENCACHING_NL_SEC);
#endif
#ifdef OPENCACHING_RO_KEY
    services->insert("opencaching.ro", new QList<QString>());
    services->value("opencaching.ro")->append("http://opencaching.ro/okapi/services/");
    services->value("opencaching.ro")->append(OPENCACHING_RO_KEY);
    services->value("opencaching.ro")->append(OPENCACHING_RO_SEC);
#endif
#ifdef OPENCACHE_UK_KEY
    services->insert("opencache.uk", new QList<QString>());
    services->value("opencache.uk")->append("http://opencache.uk/okapi/services/");
    services->value("opencache.uk")->append(OPENCACHE_UK_KEY);
    services->value("opencache.uk")->append(OPENCACHE_UK_SEC);
#endif
}

QObject* OAuthSucks::get_service_for(QString id)
{
    if (services->contains(id)) {
        auto args = services->value(id);
        return new OAuthedService(args->at(0), args->at(1), args->at(2));
    }
    return nullptr;
}

OAuthedService::OAuthedService(QString baseUrl, QString consumerKey, QString consumerSecret)
{
    this->baseUrl        = baseUrl;
    this->oauthUrl       = baseUrl + "oauth/";
    this->consumerKey    = consumerKey;
    this->consumerSecret = consumerSecret;
    this->tokenKey       = "";
    this->tokenSecret    = "";
    this->nam            = new QNetworkAccessManager(this);
}

void OAuthedService::authorize(QObject *webView)
{
    this->webView = webView;

    QMap<QString, QString> args = QMap<QString, QString>();
    args["oauth_callback"] = QUrl::toPercentEncoding("bootyhunter://oauth_callback");
    QString signed_args = sign_args("request_token", args);

    QNetworkRequest req;
    req.setUrl(oauthUrl + "request_token" + "?" + signed_args);
    qDebug() << req.url();
    QNetworkReply *rep = 0;
    rep = nam->get(req);
    connect(rep, SIGNAL(finished()), this, SLOT(onRequestTokenFinished()));
}

QString OAuthedService::sign_args(QString path, QMap<QString, QString>& args)
{
    quint64 epoch = QDateTime::currentMSecsSinceEpoch();

    args["oauth_consumer_key"]     = consumerKey;
    args["oauth_timestamp"]        = QString::number(epoch / 1000);
    args["oauth_nonce"]            = QCryptographicHash::hash(QString::number(epoch).toUtf8(), QCryptographicHash::Md5).toHex();
    args["oauth_signature_method"] = "HMAC-SHA1";
    args["oauth_version"]          = "1.0";
    args["oauth_token"]            = tokenKey;

    QString baseString = QString("GET") + "&"
                       + QUrl::toPercentEncoding(oauthUrl + path) + "&"
                       + QUrl::toPercentEncoding(stringify_args(args));
    QByteArray keysPacked = QUrl::toPercentEncoding(consumerSecret) + "&" + QUrl::toPercentEncoding(tokenSecret);
    QString signature = QMessageAuthenticationCode::hash(baseString.toUtf8(), keysPacked, QCryptographicHash::Sha1).toBase64();
    args["oauth_signature"] = QUrl::toPercentEncoding(signature);
    return stringify_args(args);
}

// this gives us temporary oauth_token pair
void OAuthedService::onRequestTokenFinished()
{
    QNetworkReply *reply = static_cast<QNetworkReply*>(sender());
    QByteArray resp = reply->readAll();
    reply->deleteLater();

    qDebug() << resp;
    QUrlQuery query(resp);
    tokenKey    = query.queryItemValue("oauth_token");
    tokenSecret = query.queryItemValue("oauth_token_secret");
    qDebug() << tokenKey << tokenSecret;

    webView->setProperty("url", oauthUrl + "authorize?oauth_token=" + tokenKey);
}

// this came from a webview and gave us a verifier to "bless" our tokens
void OAuthedService::onRedirect(QString url)
{
    qDebug() << url;
    if (url.startsWith("bootyhunter://oauth_callback")) {
        QUrl u(url);
        QUrlQuery uquery(u);
        QString verifier = uquery.queryItemValue("oauth_verifier");

        QMap<QString, QString> args = QMap<QString, QString>();
        args["oauth_verifier"] = uquery.queryItemValue("oauth_verifier");
        QString signed_args = sign_args("access_token", args);

        QNetworkRequest req;
        req.setUrl(oauthUrl + "access_token?" + signed_args);
        QNetworkReply *rep = 0;
        rep = nam->get(req);
        connect(rep, SIGNAL(finished()), this, SLOT(onAccessTokenFinished()));
    }
}

void OAuthedService::onAccessTokenFinished()
{
    QNetworkReply *reply = static_cast<QNetworkReply*>(sender());
    QByteArray resp = reply->readAll();
    reply->deleteLater();

    QUrlQuery query(resp);
    // TODO check for errors!
    tokenKey    = query.queryItemValue("oauth_token");
    tokenSecret = query.queryItemValue("oauth_token_secret");
    emit accessTokenAcquired(tokenKey, tokenSecret);
}

QString OAuthedService::get_base_url()
{
    return baseUrl;
}

QString OAuthedService::get_consumer_key()
{
    return consumerKey;
}
