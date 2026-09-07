#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>

#include "FileListModel.h"
#include "ThemeIconProvider.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationName("MurSchol Files");
    app.setOrganizationName("MurSchol");
    app.setDesktopFileName("murschol-files");
    QQuickStyle::setStyle("Basic");

    qmlRegisterType<FileListModel>("MurScholFiles", 1, 0, "FileListModel");

    QQmlApplicationEngine engine;
    engine.addImageProvider(QStringLiteral("theme"), new ThemeIconProvider);
    engine.load(QUrl(QStringLiteral("qrc:/qml/Files.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
