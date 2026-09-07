#include "CalculatorBackend.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QUrl>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QGuiApplication::setApplicationName(QStringLiteral("MurSchol Calculator"));
    QGuiApplication::setOrganizationName(QStringLiteral("MurSchol"));
    QQuickStyle::setStyle(QStringLiteral("Basic"));

    CalculatorBackend backend;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty(QStringLiteral("calculatorBackend"), &backend);
    engine.load(QUrl(QStringLiteral("qrc:/qt/qml/MurScholCalculator/qml/Main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
