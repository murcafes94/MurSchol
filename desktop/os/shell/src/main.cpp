#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>

#include "SystemBackend.h"
#include "AppIndexModel.h"
#include "UniversalSearchModel.h"
#include "AppManagerBackend.h"
#include "ThemeIconProvider.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationName("MurSchol Desktop");
    app.setOrganizationName("MurSchol");
    app.setDesktopFileName("murschol-desktop");
    QQuickStyle::setStyle("Basic");

    qmlRegisterType<SystemBackend>("MurScholShell", 1, 0, "SystemBackend");
    qmlRegisterType<AppIndexModel>("MurScholShell", 1, 0, "AppIndexModel");
    qmlRegisterType<UniversalSearchModel>("MurScholShell", 1, 0, "UniversalSearchModel");
    qmlRegisterType<AppManagerBackend>("MurScholShell", 1, 0, "AppManagerBackend");

    QQmlApplicationEngine engine;
    engine.addImageProvider(QStringLiteral("theme"), new ThemeIconProvider);

    // Con Qt 6.4 mantenemos QTP0001 en su comportamiento antiguo, por lo que
    // qt_add_qml_module() incrusta el módulo bajo :/MurScholShell/... y no bajo
    // :/qt/qml/MurScholShell/.... Cargar la ruta real evita que la sesión Live
    // falle con "No such file or directory" al iniciar Main.qml.
    engine.load(QUrl(QStringLiteral("qrc:/MurScholShell/qml/Main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
