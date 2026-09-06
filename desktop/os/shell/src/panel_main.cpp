#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QQuickWindow>
#include <QWindow>

#include <LayerShellQt/Shell>
#include <LayerShellQt/Window>

#include "SystemBackend.h"
#include "AppIndexModel.h"
#include "UniversalSearchModel.h"
#include "AppManagerBackend.h"
#include "ThemeIconProvider.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationName("MurSchol Panel");
    app.setOrganizationName("MurSchol");
    QQuickStyle::setStyle("Basic");

    // LayerShellQt solo necesita configurarse antes de crear la primera
    // superficie Wayland. Hacerlo tras QGuiApplication sigue el patrón de uso
    // habitual y evita inicialización gráfica antes de tiempo.
    LayerShellQt::Shell::useLayerShell();
    QQuickWindow::setDefaultAlphaBuffer(true);

    qmlRegisterType<SystemBackend>("MurScholShell", 1, 0, "SystemBackend");
    qmlRegisterType<AppIndexModel>("MurScholShell", 1, 0, "AppIndexModel");
    qmlRegisterType<UniversalSearchModel>("MurScholShell", 1, 0, "UniversalSearchModel");
    qmlRegisterType<AppManagerBackend>("MurScholShell", 1, 0, "AppManagerBackend");

    QQmlApplicationEngine engine;
    engine.addImageProvider(QStringLiteral("theme"), new ThemeIconProvider);
    engine.load(QUrl(QStringLiteral("qrc:/qml/Panel.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    auto *window = qobject_cast<QWindow *>(engine.rootObjects().constFirst());
    if (!window)
        return -2;

    auto *layerWindow = LayerShellQt::Window::get(window);
    layerWindow->setAnchors(LayerShellQt::Window::AnchorBottom);
    layerWindow->setLayer(LayerShellQt::Window::LayerOverlay);
    layerWindow->setKeyboardInteractivity(LayerShellQt::Window::KeyboardInteractivityOnDemand);
    layerWindow->setExclusiveZone(0);
    layerWindow->setScope(QStringLiteral("murschol-panel"));
    layerWindow->setScreenConfiguration(LayerShellQt::Window::ScreenFromCompositor);

    window->show();
    return app.exec();
}
