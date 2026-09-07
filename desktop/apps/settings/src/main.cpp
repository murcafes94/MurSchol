#include "SettingsBackend.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QGuiApplication::setApplicationName(QStringLiteral("MurSchol Settings"));
    QGuiApplication::setOrganizationName(QStringLiteral("MurSchol"));
    QQuickStyle::setStyle(QStringLiteral("Basic"));

    QString initialPage = QStringLiteral("appearance");
    const QStringList arguments = QGuiApplication::arguments();
    for (int i = 1; i < arguments.size(); ++i) {
        if (arguments.at(i) == QStringLiteral("--page") && i + 1 < arguments.size()) {
            initialPage = arguments.at(i + 1);
            ++i;
        }
    }

    qmlRegisterType<SettingsBackend>("MurScholSettings", 1, 0, "SettingsBackend");

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty(QStringLiteral("initialPage"), initialPage);
    engine.load(QUrl(QStringLiteral("qrc:/MurScholSettings/qml/Main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
