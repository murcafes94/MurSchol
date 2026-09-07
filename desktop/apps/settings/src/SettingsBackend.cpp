#include "SettingsBackend.h"

#include <QDir>
#include <QFile>
#include <QProcess>
#include <QRegularExpression>
#include <QSettings>
#include <QStandardPaths>
#include <QStorageInfo>
#include <QSysInfo>
#include <QTextStream>
#include <QThread>

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

QString unquote(QString value)
{
    value = value.trimmed();
    if (value.size() >= 2 && value.startsWith('"') && value.endsWith('"'))
        value = value.mid(1, value.size() - 2);
    return value;
}

QString humanBytes(quint64 bytes)
{
    const double gib = double(bytes) / 1024.0 / 1024.0 / 1024.0;
    if (gib >= 1.0)
        return QStringLiteral("%1 GB").arg(gib, 0, 'f', gib >= 100.0 ? 0 : 1);
    const double mib = double(bytes) / 1024.0 / 1024.0;
    return QStringLiteral("%1 MB").arg(mib, 0, 'f', 0);
}
}

SettingsBackend::SettingsBackend(QObject *parent)
    : QObject(parent)
{
    ensureStorage();
    detectSystem();
    loadPreferences();
    detectTools();
}

void SettingsBackend::ensureStorage()
{
    QDir().mkpath(settingsDirectory());
}

void SettingsBackend::loadPreferences()
{
    QSettings settings(settingsPath(), QSettings::IniFormat);
    m_theme = settings.value(QStringLiteral("appearance/theme"), m_theme).toString();
    m_accentColor = settings.value(QStringLiteral("appearance/accent"), m_accentColor).toString();
    m_animationMode = settings.value(QStringLiteral("appearance/animations"), m_animationMode).toString();
    m_dockAutoHide = settings.value(QStringLiteral("dock/autoHide"), m_dockAutoHide).toBool();
    m_dockSize = qBound(54, settings.value(QStringLiteral("dock/size"), m_dockSize).toInt(), 84);
    m_dockMagnify = settings.value(QStringLiteral("dock/magnify"), m_dockMagnify).toBool();

    const QString savedProfile = settings.value(QStringLiteral("performance/profile")).toString();
    m_profile = savedProfile.isEmpty() ? m_recommendedProfile : savedProfile;
    if (savedProfile.isEmpty()) {
        settings.setValue(QStringLiteral("performance/profile"), m_profile);
        settings.sync();
    }
}

void SettingsBackend::detectSystem()
{
    m_kernelVersion = QSysInfo::kernelVersion();
    m_cpuThreads = qMax(1, QThread::idealThreadCount());

    QFile osRelease(QStringLiteral("/etc/os-release"));
    if (osRelease.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream in(&osRelease);
        QString fallback;
        while (!in.atEnd()) {
            const QString line = in.readLine();
            if (line.startsWith(QStringLiteral("PRETTY_NAME="))) {
                m_distroName = unquote(line.mid(QStringLiteral("PRETTY_NAME=").size()));
                break;
            }
            if (line.startsWith(QStringLiteral("NAME=")))
                fallback = unquote(line.mid(QStringLiteral("NAME=").size()));
        }
        if (m_distroName == QStringLiteral("Linux") && !fallback.isEmpty())
            m_distroName = fallback;
    }

    QFile cpuInfo(QStringLiteral("/proc/cpuinfo"));
    if (cpuInfo.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream in(&cpuInfo);
        while (!in.atEnd()) {
            const QString line = in.readLine();
            if (line.startsWith(QStringLiteral("model name"), Qt::CaseInsensitive)
                || line.startsWith(QStringLiteral("hardware"), Qt::CaseInsensitive)) {
                const int colon = line.indexOf(':');
                if (colon >= 0) {
                    const QString model = line.mid(colon + 1).trimmed();
                    if (!model.isEmpty())
                        m_cpuModel = model;
                }
                break;
            }
        }
    }

    QFile memInfo(QStringLiteral("/proc/meminfo"));
    if (memInfo.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream in(&memInfo);
        while (!in.atEnd()) {
            const QString line = in.readLine();
            if (!line.startsWith(QStringLiteral("MemTotal:")))
                continue;
            const QStringList parts = line.split(QRegularExpression(QStringLiteral("\\s+")), Qt::SkipEmptyParts);
            if (parts.size() >= 2)
                m_totalMemoryGb = double(parts.at(1).toULongLong()) / 1024.0 / 1024.0;
            break;
        }
    }

    if (m_totalMemoryGb > 0.0 && (m_totalMemoryGb < 3.5 || m_cpuThreads <= 2))
        m_recommendedProfile = QStringLiteral("Ligero");
    else if (m_totalMemoryGb > 0.0 && (m_totalMemoryGb < 8.0 || m_cpuThreads <= 4))
        m_recommendedProfile = QStringLiteral("Normal");
    else
        m_recommendedProfile = QStringLiteral("Rendimiento");

    const QStorageInfo storage = QStorageInfo::root();
    if (storage.bytesTotal() > 0) {
        const quint64 used = storage.bytesTotal() - storage.bytesAvailable();
        m_storageSummary = QStringLiteral("%1 usados de %2")
                               .arg(humanBytes(used), humanBytes(storage.bytesTotal()));
    } else {
        m_storageSummary = QStringLiteral("No disponible");
    }
}

void SettingsBackend::detectTools()
{
    m_networkSettingsAvailable = !QStandardPaths::findExecutable(QStringLiteral("nm-connection-editor")).isEmpty();
    m_audioSettingsAvailable = !QStandardPaths::findExecutable(QStringLiteral("pavucontrol")).isEmpty();
    m_bluetoothSettingsAvailable = !QStandardPaths::findExecutable(QStringLiteral("blueman-manager")).isEmpty();
}

void SettingsBackend::saveValue(const QString &key, const QVariant &value)
{
    QSettings settings(settingsPath(), QSettings::IniFormat);
    settings.setValue(key, value);
    settings.sync();
}

void SettingsBackend::setTheme(const QString &value)
{
    if (value != QStringLiteral("Automático")
        && value != QStringLiteral("Claro")
        && value != QStringLiteral("Oscuro"))
        return;
    if (m_theme == value)
        return;
    m_theme = value;
    saveValue(QStringLiteral("appearance/theme"), value);
    emit appearanceChanged();
    setStatus(QStringLiteral("Tema: %1").arg(value));
}

void SettingsBackend::setAccentColor(const QString &value)
{
    static const QRegularExpression colorPattern(QStringLiteral("^#[0-9A-Fa-f]{6}$"));
    if (!colorPattern.match(value).hasMatch() || m_accentColor == value)
        return;
    m_accentColor = value;
    saveValue(QStringLiteral("appearance/accent"), value);
    emit appearanceChanged();
    setStatus(QStringLiteral("Color de énfasis actualizado"));
}

void SettingsBackend::setAnimationMode(const QString &value)
{
    if (value != QStringLiteral("Normal")
        && value != QStringLiteral("Reducidas")
        && value != QStringLiteral("Desactivadas"))
        return;
    if (m_animationMode == value)
        return;
    m_animationMode = value;
    saveValue(QStringLiteral("appearance/animations"), value);
    emit appearanceChanged();
    setStatus(QStringLiteral("Animaciones: %1").arg(value));
}

void SettingsBackend::setDockAutoHide(bool value)
{
    if (m_dockAutoHide == value)
        return;
    m_dockAutoHide = value;
    saveValue(QStringLiteral("dock/autoHide"), value);
    emit dockChanged();
    setStatus(value ? QStringLiteral("Dock: ocultación automática activada")
                    : QStringLiteral("Dock: siempre visible"));
}

void SettingsBackend::setDockSize(int value)
{
    value = qBound(54, value, 84);
    if (m_dockSize == value)
        return;
    m_dockSize = value;
    saveValue(QStringLiteral("dock/size"), value);
    emit dockChanged();
    setStatus(QStringLiteral("Tamaño del dock: %1").arg(value));
}

void SettingsBackend::setDockMagnify(bool value)
{
    if (m_dockMagnify == value)
        return;
    m_dockMagnify = value;
    saveValue(QStringLiteral("dock/magnify"), value);
    emit dockChanged();
    setStatus(value ? QStringLiteral("Ampliación del dock activada")
                    : QStringLiteral("Ampliación del dock desactivada"));
}

void SettingsBackend::setProfile(const QString &value)
{
    if (value != QStringLiteral("Ligero")
        && value != QStringLiteral("Normal")
        && value != QStringLiteral("Rendimiento"))
        return;
    if (m_profile == value)
        return;
    m_profile = value;
    saveValue(QStringLiteral("performance/profile"), value);
    emit profileChanged();
    setStatus(QStringLiteral("Perfil cambiado a %1").arg(value));
}

bool SettingsBackend::startFirstAvailable(const QStringList &commands)
{
    for (const QString &command : commands) {
        const QString executable = QStandardPaths::findExecutable(command);
        if (!executable.isEmpty())
            return QProcess::startDetached(executable);
    }
    return false;
}

bool SettingsBackend::openNetworkSettings()
{
    const bool ok = startFirstAvailable({QStringLiteral("nm-connection-editor")});
    setStatus(ok ? QStringLiteral("Abriendo configuración de red")
                 : QStringLiteral("No se encontró el editor de NetworkManager"));
    return ok;
}

bool SettingsBackend::openAudioSettings()
{
    const bool ok = startFirstAvailable({QStringLiteral("pavucontrol")});
    setStatus(ok ? QStringLiteral("Abriendo configuración de sonido")
                 : QStringLiteral("No se encontró pavucontrol"));
    return ok;
}

bool SettingsBackend::openBluetoothSettings()
{
    const bool ok = startFirstAvailable({QStringLiteral("blueman-manager")});
    setStatus(ok ? QStringLiteral("Abriendo configuración de Bluetooth")
                 : QStringLiteral("No se encontró blueman-manager"));
    return ok;
}

QString SettingsBackend::settingsFilePath() const
{
    return settingsPath();
}

void SettingsBackend::setStatus(const QString &text)
{
    if (m_statusText == text)
        return;
    m_statusText = text;
    emit statusChanged();
}
