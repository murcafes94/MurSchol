#include "PhotoBackend.h"

#include <QDir>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QUrl>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QGuiApplication::setApplicationName(QStringLiteral("MurSchol Photos"));
    QGuiApplication::setOrganizationName(QStringLiteral("MurSchol"));
    QGuiApplication::setDesktopFileName(QStringLiteral("murschol-photos"));
    QQuickStyle::setStyle(QStringLiteral("Basic"));

    qmlRegisterType<PhotoBackend>("MurScholPhotos", 1, 0, "PhotoBackend");

    QString initialSource;
    bool initialAnnotationMode = false;
    const QStringList arguments = QGuiApplication::arguments();
    for (int i = 1; i < arguments.size(); ++i) {
        const QString argument = arguments.at(i);
        if (argument == QStringLiteral("--annotate")) {
            initialAnnotationMode = true;
            continue;
        }

        if (initialSource.isEmpty()) {
            const QUrl url = QUrl::fromUserInput(argument, QDir::currentPath(), QUrl::AssumeLocalFile);
            if (url.isValid())
                initialSource = url.toString();
        }
    }

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty(QStringLiteral("initialSource"), initialSource);
    engine.rootContext()->setContextProperty(QStringLiteral("initialAnnotationMode"), initialAnnotationMode);

    // MurSchol Desktop y la Live Debian cargan los módulos Qt 6.4 desde el
    // prefijo de recurso antiguo (:/<URI>/...). Mantener la misma ruta aquí
    // evita que Photos termine inmediatamente con "No such file or directory".
    engine.load(QUrl(QStringLiteral("qrc:/MurScholPhotos/qml/Main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
