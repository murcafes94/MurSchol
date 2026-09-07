#include "MusicLibraryModel.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QGuiApplication::setApplicationName(QStringLiteral("MurSchol Music"));
    QGuiApplication::setOrganizationName(QStringLiteral("MurSchol"));
    QQuickStyle::setStyle(QStringLiteral("Basic"));

    qmlRegisterType<MusicLibraryModel>("MurScholMusic", 1, 0, "MusicLibraryModel");

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/qt/qml/MurScholMusic/qml/Main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
