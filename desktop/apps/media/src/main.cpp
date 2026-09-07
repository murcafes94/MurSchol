#include "MpvPlayer.h"

#include <QFileInfo>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QQuickWindow>
#include <QSGRendererInterface>
#include <QUrl>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QGuiApplication::setApplicationName(QStringLiteral("MurSchol Media"));
    QGuiApplication::setOrganizationName(QStringLiteral("MurSchol"));
    QQuickStyle::setStyle(QStringLiteral("Basic"));

    // QQuickFramebufferObject y libmpv usan la ruta OpenGL. La aceleración de
    // decodificación sigue siendo elegida por mpv mediante hwdec=auto-safe.
    QQuickWindow::setGraphicsApi(QSGRendererInterface::OpenGL);

    qmlRegisterType<MpvPlayer>("MurScholMedia", 1, 0, "MpvPlayer");

    QString initialMediaFile;
    const QStringList args = QGuiApplication::arguments();
    for (int i = 1; i < args.size(); ++i) {
        const QFileInfo info(args.at(i));
        if (info.exists() && info.isFile()) {
            initialMediaFile = QUrl::fromLocalFile(info.absoluteFilePath()).toString();
            break;
        }
    }

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty(QStringLiteral("initialMediaFile"), initialMediaFile);
    engine.load(QUrl(QStringLiteral("qrc:/qt/qml/MurScholMedia/qml/Main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
