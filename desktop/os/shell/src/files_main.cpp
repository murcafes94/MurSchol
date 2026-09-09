#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QQuickWindow>

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

    // MurSchol Files es una ventana de aplicación normal. Qt Quick no siempre
    // anuncia todos los hints de gestión de ventana de forma suficientemente
    // explícita bajo Wayland/labwc, y en la ISO de prueba el gestor quedó sin
    // los controles visibles. Pedimos de forma expresa el marco del sistema y
    // los botones minimizar, maximizar/restaurar y cerrar.
    if (auto *window = qobject_cast<QQuickWindow *>(engine.rootObjects().constFirst())) {
        const Qt::WindowFlags windowFlags = Qt::Window
            | Qt::WindowTitleHint
            | Qt::WindowSystemMenuHint
            | Qt::WindowMinimizeButtonHint
            | Qt::WindowMaximizeButtonHint
            | Qt::WindowCloseButtonHint;

        window->setFlags(windowFlags);
        window->show();
    }

    return app.exec();
}
