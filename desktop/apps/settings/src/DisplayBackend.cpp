#include "DisplayBackend.h"

#include <QDir>
#include <QGuiApplication>
#include <QProcess>
#include <QScreen>
#include <QSettings>
#include <QStandardPaths>
#include <QVariantMap>

namespace {
QString settingsDirectory()
{
    return QStandardPaths::writableLocation(QStandardPaths::ConfigLocation)
           + QStringLiteral("/murschol");
}

QString settingsPath()
{
    return settingsDirectory() + QStringLiteral("/settings.ini");
}
}

DisplayBackend::DisplayBackend(QObject *parent)
    : QObject(parent)
{
    QDir().mkpath(settingsDirectory());
    m_gammastepPath = QStandardPaths::findExecutable(QStringLiteral("gammastep"));
    m_nightLightAvailable = !m_gammastepPath.isEmpty();
    loadPreferences();
    refreshScreens();

    if (qGuiApp) {
        connect(qGuiApp, &QGuiApplication::screenAdded, this,
                [this](QScreen *) { refreshScreens(); });
        connect(qGuiApp, &QGuiApplication::screenRemoved, this,
                [this](QScreen *) { refreshScreens(); });
    }

    if (m_nightLightEnabled && m_nightLightAvailable) {
        if (!applyNightLight(m_nightLightTemperature))
            m_nightLightEnabled = false;
    }
}

void DisplayBackend::refresh()
{
    m_gammastepPath = QStandardPaths::findExecutable(QStringLiteral("gammastep"));
    m_nightLightAvailable = !m_gammastepPath.isEmpty();
    refreshScreens();
    emit nightLightChanged();
}

void DisplayBackend::refreshScreens()
{
    QVariantList result;
    QScreen *primary = QGuiApplication::primaryScreen();
    for (QScreen *screen : QGuiApplication::screens()) {
        if (!screen)
            continue;

        const QRect geometry = screen->geometry();
        const QSizeF physical = screen->physicalSize();
        QVariantMap item;
        item.insert(QStringLiteral("name"), screen->name().isEmpty()
                                           ? QStringLiteral("Pantalla") : screen->name());
        item.insert(QStringLiteral("width"), geometry.width());
        item.insert(QStringLiteral("height"), geometry.height());
        item.insert(QStringLiteral("x"), geometry.x());
        item.insert(QStringLiteral("y"), geometry.y());
        item.insert(QStringLiteral("refreshRate"), qRound(screen->refreshRate()));
        item.insert(QStringLiteral("scale"), screen->devicePixelRatio());
        item.insert(QStringLiteral("primary"), screen == primary);
        item.insert(QStringLiteral("physicalWidthMm"), qRound(physical.width()));
        item.insert(QStringLiteral("physicalHeightMm"), qRound(physical.height()));
        result.append(item);
    }

    m_screens = result;
    emit displayChanged();
}

void DisplayBackend::loadPreferences()
{
    QSettings settings(settingsPath(), QSettings::IniFormat);
    m_nightLightTemperature = qBound(3000,
                                     settings.value(QStringLiteral("display/nightLightTemperature"),
                                                    m_nightLightTemperature).toInt(),
                                     6500);
    m_nightLightEnabled = settings.value(QStringLiteral("display/nightLightEnabled"), false).toBool();
}

void DisplayBackend::savePreference(const QString &key, const QVariant &value)
{
    QSettings settings(settingsPath(), QSettings::IniFormat);
    settings.setValue(key, value);
    settings.sync();
}

bool DisplayBackend::applyNightLight(int kelvin)
{
    if (!m_nightLightAvailable || m_gammastepPath.isEmpty()) {
        setStatus(QStringLiteral("Luz nocturna no está disponible en este equipo"));
        return false;
    }

    QProcess process;
    process.start(m_gammastepPath,
                  {QStringLiteral("-m"), QStringLiteral("wayland"),
                   QStringLiteral("-P"), QStringLiteral("-O"), QString::number(kelvin)});
    const bool finished = process.waitForFinished(2500);
    const bool ok = finished && process.exitStatus() == QProcess::NormalExit
                    && process.exitCode() == 0;
    if (!ok) {
        const QString error = QString::fromUtf8(process.readAllStandardError()).trimmed();
        setStatus(error.isEmpty()
                      ? QStringLiteral("El compositor no aceptó el filtro de luz nocturna")
                      : QStringLiteral("Luz nocturna no compatible con esta salida"));
    }
    return ok;
}

bool DisplayBackend::resetNightLight()
{
    if (!m_nightLightAvailable || m_gammastepPath.isEmpty())
        return false;

    QProcess process;
    process.start(m_gammastepPath,
                  {QStringLiteral("-m"), QStringLiteral("wayland"), QStringLiteral("-x")});
    const bool finished = process.waitForFinished(2500);
    return finished && process.exitStatus() == QProcess::NormalExit && process.exitCode() == 0;
}

bool DisplayBackend::setNightLightEnabled(bool enabled)
{
    if (enabled == m_nightLightEnabled)
        return true;

    if (enabled) {
        if (!applyNightLight(m_nightLightTemperature))
            return false;
    } else if (!resetNightLight()) {
        setStatus(QStringLiteral("No se pudo restablecer la temperatura de color"));
        return false;
    }

    m_nightLightEnabled = enabled;
    savePreference(QStringLiteral("display/nightLightEnabled"), enabled);
    emit nightLightChanged();
    setStatus(enabled ? QStringLiteral("Luz nocturna activada")
                      : QStringLiteral("Luz nocturna desactivada"));
    return true;
}

bool DisplayBackend::setNightLightTemperature(int kelvin)
{
    kelvin = qBound(3000, kelvin, 6500);
    if (m_nightLightTemperature == kelvin)
        return true;

    if (m_nightLightEnabled && !applyNightLight(kelvin))
        return false;

    m_nightLightTemperature = kelvin;
    savePreference(QStringLiteral("display/nightLightTemperature"), kelvin);
    emit nightLightChanged();
    setStatus(QStringLiteral("Temperatura de color: %1 K").arg(kelvin));
    return true;
}

bool DisplayBackend::applyNightLightPreset(const QString &preset)
{
    if (preset.compare(QStringLiteral("Suave"), Qt::CaseInsensitive) == 0)
        return setNightLightTemperature(5000);
    if (preset.compare(QStringLiteral("Nocturno"), Qt::CaseInsensitive) == 0)
        return setNightLightTemperature(3600);
    return false;
}

void DisplayBackend::setStatus(const QString &text)
{
    if (m_statusText == text)
        return;
    m_statusText = text;
    emit statusChanged();
}
