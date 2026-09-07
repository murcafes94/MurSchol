#include "EventModel.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QUrl>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QGuiApplication::setApplicationName(QStringLiteral("MurSchol Calendar"));
    QGuiApplication::setOrganizationName(QStringLiteral("MurSchol"));
    QQuickStyle::setStyle(QStringLiteral("Basic"));

    qmlRegisterType<EventModel>("MurScholCalendar", 1, 0, "EventModel");

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/qt/qml/MurScholCalendar/qml/Main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
