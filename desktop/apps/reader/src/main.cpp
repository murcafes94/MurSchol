#include <QFileInfo>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QUrl>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QGuiApplication::setApplicationName(QStringLiteral("MurSchol Reader"));
    QGuiApplication::setOrganizationName(QStringLiteral("MurSchol"));
    QQuickStyle::setStyle(QStringLiteral("Basic"));

    QUrl startupDocument;
    const QStringList arguments = QCoreApplication::arguments();
    if (arguments.size() > 1) {
        const QFileInfo candidate(arguments.at(1));
        if (candidate.exists() && candidate.isFile())
            startupDocument = QUrl::fromLocalFile(candidate.absoluteFilePath());
    }

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty(QStringLiteral("murscholStartupDocument"), startupDocument);
    engine.load(QUrl(QStringLiteral("qrc:/MurScholReader/qml/Main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
