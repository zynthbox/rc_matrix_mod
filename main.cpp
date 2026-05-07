#include "MidiTransport.h"
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QtWebEngine/QtWebEngine>
#include <QByteArray>
#include <QtWebEngineCore/QWebEngineUrlScheme>
#include <QtGlobal>
#include <QDebug>
#include <QUrl>
#include <QString>
#include <QLibraryInfo>

static void registerUrlSchemes()
{
    for (const QByteArray &schemeName : {"https", "http", "qrc"}) {
        QWebEngineUrlScheme scheme = QWebEngineUrlScheme::schemeByName(schemeName);
        scheme.setFlags(scheme.flags()
                        | QWebEngineUrlScheme::ContentSecurityPolicyIgnored
                        | QWebEngineUrlScheme::CorsEnabled
                        | QWebEngineUrlScheme::SecureScheme);
        QWebEngineUrlScheme::registerScheme(scheme);
    }
}

int main(int argc, char *argv[])
{
    qputenv("QTWEBENGINE_CHROMIUM_FLAGS",
            "--no-sandbox"
            " --disable-web-security"
            " --allow-running-insecure-content"
            " --enable-web-midi"
            " --enable-features=WebMIDI"
            " --disable-features=PermissionsPolicy"
            " --ignore-certificate-errors"
            " --ignore-ssl-errors"
            " --ignore-urlfetcher-cert-requests");

    registerUrlSchemes();
    QtWebEngine::initialize();

    QGuiApplication app(argc, argv);
    app.setOrganizationName("audiocontrol_mod");
    app.setApplicationName("AudioControlMod");

    // MidiTransport is the RtMidi hardware interface exposed via QWebChannel.
    // MidiChannelTransport.qml registers it on the channel as "midiTransport"
    // and injects the JZZ.js engine that uses it.
    MidiTransport midiTransport;

    QQmlApplicationEngine engine;
    engine.addImportPath(QLibraryInfo::location(QLibraryInfo::Qml2ImportsPath));
    engine.rootContext()->setContextProperty(QStringLiteral("midiTransport"), &midiTransport);

    engine.load(QUrl(QStringLiteral("qrc:/AudioControlMod/AudioControlMod/contents/main.qml")));

    if (engine.rootObjects().isEmpty()) {
        qCritical("Failed to load main.qml from resources");
        return 1;
    }

    return app.exec();
}
