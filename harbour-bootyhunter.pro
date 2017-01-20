TARGET = harbour-bootyhunter
QMAKE_CXXFLAGS = -std=c++11

CONFIG += sailfishapp

QT += positioning

SOURCES += src/harbour-bootyhunter.cpp \
    src/gpsdatasource.cpp \
    src/oauthsucks.cpp

HEADERS += src/gpsdatasource.h \
           src/oauthsucks.h \
    src/oauthkeys.h

OTHER_FILES += qml/harbour-bootyhunter.qml \
    qml/cover/CoverPage.qml \
    rpm/harbour-bootyhunter.spec \
    rpm/harbour-bootyhunter.yaml \
    translations/*.ts \
    harbour-bootyhunter.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 256x256

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
#TRANSLATIONS += translations/geocaching-de.ts

DISTFILES += \
    qml/harbour-bootyhunter.js \
    qml/harbour-bootyhunter.qml \
    qml/GPSWrapper.qml \
    qml/GeocachingWrapper.qml \
    qml/Providers.qml \
    qml/pages/NearestCachesPage.qml \
    qml/pages/NavigatePage.qml \
    qml/pages/HintPage.qml \
    qml/pages/CachePage.qml \
    qml/pages/MapPage.qml \
    qml/pages/SettingsPage.qml \
    qml/pages/OAuthPage.qml \
    harbour-bootyhunter-logo.png \
    qml/img/cache-icon.png \
    qml/pages/ErrorPage.qml \
    rpm/harbour-bootyhunter.changes
