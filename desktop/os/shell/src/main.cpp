#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>

#include "SystemBackend.h"
#include "AppIndexModel.h"
#include "UniversalSearchModel.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationName("MurSchol Desktop");
    app.setOrganizationName("MurSchol");
    QQuickStyle::setStyle("Basic");

    qmlRegisterType<SystemBackend>("MurScholShell", 1, 0, "SystemBackend");
    qmlRegisterType<AppIndexModel>("MurScholShell", 1, 0, "AppIndexModel");
    qmlRegisterType<UniversalSearchModel>("MurScholShell", 1, 0, "UniversalSearchModel");

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/qt/qml/MurScholShell/qml/Main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
