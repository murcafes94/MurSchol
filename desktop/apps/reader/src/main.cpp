#include "ReadingStore.h"
#include <QCommandLineParser>
#include <QDir>
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
    QGuiApplication::setApplicationVersion(QStringLiteral("1.0.1"));
    QGuiApplication::setDesktopFileName(QStringLiteral("murschol-reader"));
    QQuickStyle::setStyle(QStringLiteral("Basic"));

    QCommandLineParser parser;
    parser.setApplicationDescription(QStringLiteral("MurSchol Reader — lector PDF"));
    parser.addHelpOption();
    parser.addVersionOption();
    parser.addPositionalArgument(QStringLiteral("documento"), QStringLiteral("Ruta o URL local de un PDF"), QStringLiteral("[documento]"));
    parser.process(app);
    if (parser.positionalArguments().size() > 1) parser.showHelp(2);
    QUrl startupDocument;
    if (!parser.positionalArguments().isEmpty())
        startupDocument = QUrl::fromUserInput(parser.positionalArguments().first(), QDir::currentPath(), QUrl::AssumeLocalFile);

    ReadingStore readingStore;
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty(QStringLiteral("readingStore"), &readingStore);
    engine.rootContext()->setContextProperty(QStringLiteral("murscholStartupDocument"), startupDocument);
    engine.load(QUrl(QStringLiteral("qrc:/MurScholReader/qml/Main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
