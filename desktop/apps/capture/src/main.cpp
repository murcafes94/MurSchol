#include "CaptureBackend.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QTimer>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QGuiApplication::setApplicationName(QStringLiteral("MurSchol Capture"));
    QGuiApplication::setOrganizationName(QStringLiteral("MurSchol"));
    QQuickStyle::setStyle(QStringLiteral("Basic"));

    const QStringList args = QGuiApplication::arguments();
    const bool directRegion = args.contains(QStringLiteral("--region"));
    const bool directScreen = args.contains(QStringLiteral("--screen"));

    int delaySeconds = 0;
    const int delayIndex = args.indexOf(QStringLiteral("--delay"));
    if (delayIndex >= 0 && delayIndex + 1 < args.size())
        delaySeconds = qBound(0, args.at(delayIndex + 1).toInt(), 30);

    if (directRegion || directScreen) {
        CaptureBackend backend;
        QObject::connect(&backend, &CaptureBackend::captureCompleted, &app,
                         [&app](bool, const QString &) { app.quit(); });
        QTimer::singleShot(0, &backend, [&backend, directRegion, delaySeconds] {
            if (directRegion)
                backend.captureRegion(delaySeconds);
            else
                backend.captureScreen(delaySeconds);
        });
        return app.exec();
    }

    qmlRegisterType<CaptureBackend>("MurScholCapture", 1, 0, "CaptureBackend");

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/qt/qml/MurScholCapture/qml/Main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
