#include "oauthsucks.h"
#include <QDateTime>
#include <QDebug>
#include <QMessageAuthenticationCode>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QUrl>
#include <QUrlQuery>

OAuthSucks::OAuthSucks()
{
    baseUrl        = "http://opencaching.pl/okapi/services/oauth/";
    consumerKey    = "mhJwjrKxkk5eUyhKj2qw";
    consumerSecret = "4FPgUVQzccvpm4JvjkSvwMzfaHRkA6FuBmBm7gK9";
    tokenKey       = "";
    tokenSecret    = "";
    nam            = new QNetworkAccessManager(this);
}

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

QString OAuthSucks::do_shit(QObject *webView)
{
    this->webView = webView;

    QMap<QString, QString> args = QMap<QString, QString>();
    args["oauth_callback"] = QUrl::toPercentEncoding("bootyhunter://oauth_callback");
    QString signed_args = sign_args("request_token", args);

    QNetworkRequest req;
    req.setUrl(baseUrl + "request_token" + "?" + signed_args);
    qDebug() << req.url();
    QNetworkReply *rep = 0;
    rep = nam->get(req);
    connect(rep, SIGNAL(finished()), this, SLOT(onRequestTokenFinished()));

    return "chuj";
}

QString OAuthSucks::sign_args(QString path, QMap<QString, QString>& args)
{
    quint64 epoch = QDateTime::currentMSecsSinceEpoch();

    args["oauth_consumer_key"]     = consumerKey;
    args["oauth_timestamp"]        = QString::number(epoch / 1000);
    args["oauth_nonce"]            = QCryptographicHash::hash(QString::number(epoch).toUtf8(), QCryptographicHash::Md5).toHex();
    args["oauth_signature_method"] = "HMAC-SHA1";
    args["oauth_version"]          = "1.0";
    args["oauth_token"]            = tokenKey;

    QString baseString = QString("GET") + "&"
                       + QUrl::toPercentEncoding(baseUrl + path) + "&" 
                       + QUrl::toPercentEncoding(stringify_args(args));
    QByteArray keysPacked = QUrl::toPercentEncoding(consumerSecret) + "&" + QUrl::toPercentEncoding(tokenSecret);
    QString signature = QMessageAuthenticationCode::hash(baseString.toUtf8(), keysPacked, QCryptographicHash::Sha1).toBase64();
    args["oauth_signature"] = QUrl::toPercentEncoding(signature);
    return stringify_args(args);
}

void OAuthSucks::onRequestTokenFinished()
{
    qDebug() << "REERERER";
    QNetworkReply *reply = static_cast<QNetworkReply*>(sender());
    QByteArray resp = reply->readAll();
    reply->deleteLater();

    // oauth_token=euKHNcBn6gyETjxPN7UP&oauth_token_secret=qmHCSnr2GJ3L3CkGELTBSh6Bsug6s3LFdj9VwrM4&oauth_callback_confirmed=true
    QUrlQuery query(resp);
    tokenKey    = query.queryItemValue("oauth_token");
    tokenSecret = query.queryItemValue("oauth_token_secret");

    qDebug() << baseUrl + "authorize?oauth_token=" + tokenKey;
    webView->setProperty("url", baseUrl + "authorize?oauth_token=" + tokenKey);
}
