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
    QQuickStyle::setStyle(QStringLiteral("Basic"));

    qmlRegisterType<PhotoBackend>("MurScholPhotos", 1, 0, "PhotoBackend");

    QString initialSource;
    const QStringList arguments = QGuiApplication::arguments();
    if (arguments.size() > 1) {
        const QUrl url = QUrl::fromUserInput(arguments.at(1), QDir::currentPath(), QUrl::AssumeLocalFile);
        initialSource = url.toString();
    }

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty(QStringLiteral("initialSource"), initialSource);
    engine.load(QUrl(QStringLiteral("qrc:/qt/qml/MurScholPhotos/qml/Main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
