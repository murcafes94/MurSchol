#include "SystemBackend.h"

#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QProcess>
#include <QRegularExpression>
#include <QSettings>
#include <QStandardPaths>
#include <QStorageInfo>
#include <QSysInfo>
#include <QTextStream>
#include <QThread>

namespace {
QString readTrimmedFile(const QString &path)
{
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return {};
    return QString::fromUtf8(file.readAll()).trimmed();
}

QString unquote(QString value)
{
    value = value.trimmed();
    if (value.size() >= 2 && value.startsWith('"') && value.endsWith('"'))
        value = value.mid(1, value.size() - 2);
    return value;
}

int statsIntervalForProfile(const QString &profile)
{
    if (profile == QStringLiteral("Ligero"))
        return 3500;
    if (profile == QStringLiteral("Rendimiento"))
        return 900;
    return 1600;
}

QString sharedSettingsDirectory()
{
    return QStandardPaths::writableLocation(QStandardPaths::ConfigLocation)
           + QStringLiteral("/murschol");
}

QString sharedSettingsPath()
{
    return sharedSettingsDirectory() + QStringLiteral("/settings.ini");
}
}

SystemBackend::SystemBackend(QObject *parent) : QObject(parent)
{
    m_externalPanel = qEnvironmentVariableIsSet("MURSCHOL_EXTERNAL_PANEL");
    detectStaticSystemInfo();
    detectCapabilities();

    QDir().mkpath(sharedSettingsDirectory());
    m_settingsPath = sharedSettingsPath();

    // Migración silenciosa desde la configuración anterior de MurSchol Desktop.
    // Así Settings puede centralizar preferencias sin perder el perfil o el espacio
    // que el usuario ya tenía guardados.
    QSettings shared(m_settingsPath, QSettings::IniFormat);
    QSettings legacy;
    const QStringList migratableKeys = {
        QStringLiteral("performance/profile"),
        QStringLiteral("workspace/active"),
        QStringLiteral("study/layout")
    };
    for (const QString &key : migratableKeys) {
        if (!shared.contains(key) && legacy.contains(key))
            shared.setValue(key, legacy.value(key));
    }
    shared.sync();

    m_profile = shared.value(QStringLiteral("performance/profile")).toString();
    m_workspace = shared.value(QStringLiteral("workspace/active"), QStringLiteral("Estudio")).toString();
    m_studyLayout = shared.value(QStringLiteral("study/layout"), QStringLiteral("PDF + NotCan")).toString();
    m_theme = shared.value(QStringLiteral("appearance/theme"), m_theme).toString();
    m_accentColor = shared.value(QStringLiteral("appearance/accent"), m_accentColor).toString();
    m_animationMode = shared.value(QStringLiteral("appearance/animations"), m_animationMode).toString();
    m_dockAutoHide = shared.value(QStringLiteral("dock/autoHide"), m_dockAutoHide).toBool();
    m_dockSize = qBound(54, shared.value(QStringLiteral("dock/size"), m_dockSize).toInt(), 84);
    m_dockMagnify = shared.value(QStringLiteral("dock/magnify"), m_dockMagnify).toBool();

    refreshStats();
    if (m_profile.isEmpty()) {
        m_profile = recommendedProfile();
        shared.setValue(QStringLiteral("performance/profile"), m_profile);
        shared.sync();
    }

    connect(&m_timer, &QTimer::timeout, this, &SystemBackend::refreshStats);
    m_timer.start(statsIntervalForProfile(m_profile));

    m_settingsWatcher.addPath(sharedSettingsDirectory());
    connect(&m_settingsWatcher, &QFileSystemWatcher::directoryChanged,
            this, &SystemBackend::reloadSharedSettings);
}

void SystemBackend::detectStaticSystemInfo()
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
}

void SystemBackend::detectCapabilities()
{
    m_waydroidAvailable = !QStandardPaths::findExecutable(QStringLiteral("waydroid")).isEmpty();
    m_wineAvailable = !QStandardPaths::findExecutable(QStringLiteral("wine")).isEmpty();
    m_flatpakAvailable = !QStandardPaths::findExecutable(QStringLiteral("flatpak")).isEmpty();

    const bool nativeBottles = !QStandardPaths::findExecutable(QStringLiteral("bottles")).isEmpty();
    const bool userFlatpakBottles = QFileInfo::exists(QDir::homePath() + QStringLiteral("/.local/share/flatpak/app/com.usebottles.bottles"));
    const bool systemFlatpakBottles = QFileInfo::exists(QStringLiteral("/var/lib/flatpak/app/com.usebottles.bottles"));
    m_bottlesAvailable = nativeBottles || userFlatpakBottles || systemFlatpakBottles;
}

QString SystemBackend::recommendedProfile() const
{
    if (m_totalMemoryGb > 0.0 && (m_totalMemoryGb < 3.5 || m_cpuThreads <= 2))
        return QStringLiteral("Ligero");
    if (m_totalMemoryGb > 0.0 && (m_totalMemoryGb < 8.0 || m_cpuThreads <= 4))
        return QStringLiteral("Normal");
    return QStringLiteral("Rendimiento");
}

void SystemBackend::refreshStats()
{
    QFile cpuFile(QStringLiteral("/proc/stat"));
    if (cpuFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        const QString line = QString::fromUtf8(cpuFile.readLine());
        const QStringList values = line.simplified().split(' ');
        if (values.size() >= 8 && values.first() == QStringLiteral("cpu")) {
            quint64 total = 0;
            for (int i = 1; i < values.size(); ++i)
                total += values.at(i).toULongLong();
            const quint64 idle = values.at(4).toULongLong() + values.at(5).toULongLong();
            const quint64 totalDelta = total - m_lastCpuTotal;
            const quint64 idleDelta = idle - m_lastCpuIdle;
            if (m_lastCpuTotal && totalDelta)
                m_cpuUsage = qBound(0, int(100.0 * double(totalDelta - idleDelta) / double(totalDelta)), 100);
            m_lastCpuTotal = total;
            m_lastCpuIdle = idle;
        }
    }

    QFile memFile(QStringLiteral("/proc/meminfo"));
    if (memFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        quint64 totalKb = 0, availableKb = 0;
        QTextStream in(&memFile);
        while (!in.atEnd()) {
            const QString line = in.readLine();
            if (line.startsWith(QStringLiteral("MemTotal:")))
                totalKb = line.split(QRegularExpression(QStringLiteral("\\s+")), Qt::SkipEmptyParts).value(1).toULongLong();
            else if (line.startsWith(QStringLiteral("MemAvailable:")))
                availableKb = line.split(QRegularExpression(QStringLiteral("\\s+")), Qt::SkipEmptyParts).value(1).toULongLong();
        }
        if (totalKb) {
            m_totalMemoryGb = double(totalKb) / 1024.0 / 1024.0;
            m_memoryUsage = qBound(0, int(100.0 * double(totalKb - availableKb) / double(totalKb)), 100);
        }
    }

    const QStorageInfo root = QStorageInfo::root();
    if (root.bytesTotal() > 0)
        m_diskUsage = qBound(0, int(100.0 * double(root.bytesTotal() - root.bytesAvailable()) / double(root.bytesTotal())), 100);

    refreshBattery();
    emit statsChanged();
}

void SystemBackend::refreshBattery()
{
    m_batteryAvailable = false;
    m_batteryPercent = -1;
    m_charging = false;

    const QDir powerDir(QStringLiteral("/sys/class/power_supply"));
    const QStringList entries = powerDir.entryList(QDir::Dirs | QDir::NoDotAndDotDot);
    for (const QString &entry : entries) {
        const QString base = powerDir.filePath(entry);
        if (readTrimmedFile(base + QStringLiteral("/type")) != QStringLiteral("Battery"))
            continue;

        m_batteryAvailable = true;
        bool ok = false;
        const int capacity = readTrimmedFile(base + QStringLiteral("/capacity")).toInt(&ok);
        if (ok)
            m_batteryPercent = qBound(0, capacity, 100);

        const QString status = readTrimmedFile(base + QStringLiteral("/status"));
        m_charging = status.compare(QStringLiteral("Charging"), Qt::CaseInsensitive) == 0
                     || status.compare(QStringLiteral("Full"), Qt::CaseInsensitive) == 0;
        break;
    }
}

void SystemBackend::reloadSharedSettings()
{
    QSettings settings(m_settingsPath, QSettings::IniFormat);

    const QString newProfile = settings.value(QStringLiteral("performance/profile"), m_profile).toString();
    if ((newProfile == QStringLiteral("Ligero")
         || newProfile == QStringLiteral("Normal")
         || newProfile == QStringLiteral("Rendimiento"))
        && newProfile != m_profile) {
        m_profile = newProfile;
        m_timer.setInterval(statsIntervalForProfile(m_profile));
        emit profileChanged();
    }

    const QString newWorkspace = settings.value(QStringLiteral("workspace/active"), m_workspace).toString();
    if (newWorkspace != m_workspace) {
        m_workspace = newWorkspace;
        emit workspaceChanged();
    }

    const QString newStudyLayout = settings.value(QStringLiteral("study/layout"), m_studyLayout).toString();
    if (newStudyLayout != m_studyLayout) {
        m_studyLayout = newStudyLayout;
        emit studyLayoutChanged();
    }

    const QString newTheme = settings.value(QStringLiteral("appearance/theme"), m_theme).toString();
    const QString newAccent = settings.value(QStringLiteral("appearance/accent"), m_accentColor).toString();
    const QString newAnimations = settings.value(QStringLiteral("appearance/animations"), m_animationMode).toString();
    if (newTheme != m_theme || newAccent != m_accentColor || newAnimations != m_animationMode) {
        m_theme = newTheme;
        m_accentColor = newAccent;
        m_animationMode = newAnimations;
        emit appearanceChanged();
    }

    const bool newAutoHide = settings.value(QStringLiteral("dock/autoHide"), m_dockAutoHide).toBool();
    const int newDockSize = qBound(54, settings.value(QStringLiteral("dock/size"), m_dockSize).toInt(), 84);
    const bool newMagnify = settings.value(QStringLiteral("dock/magnify"), m_dockMagnify).toBool();
    if (newAutoHide != m_dockAutoHide || newDockSize != m_dockSize || newMagnify != m_dockMagnify) {
        m_dockAutoHide = newAutoHide;
        m_dockSize = newDockSize;
        m_dockMagnify = newMagnify;
        emit dockSettingsChanged();
    }
}

void SystemBackend::setProfile(const QString &profile)
{
    if (profile != QStringLiteral("Ligero")
        && profile != QStringLiteral("Normal")
        && profile != QStringLiteral("Rendimiento"))
        return;
    if (profile == m_profile)
        return;

    m_profile = profile;
    QSettings settings(m_settingsPath, QSettings::IniFormat);
    settings.setValue(QStringLiteral("performance/profile"), profile);
    settings.sync();
    m_timer.setInterval(statsIntervalForProfile(profile));
    emit profileChanged();
    updateStatus(QStringLiteral("Perfil cambiado a %1").arg(profile));
}

void SystemBackend::applyRecommendedProfile()
{
    setProfile(recommendedProfile());
}

void SystemBackend::setWorkspace(const QString &workspace)
{
    if (workspace != QStringLiteral("Estudio")
        && workspace != QStringLiteral("Trabajos")
        && workspace != QStringLiteral("Personal"))
        return;
    if (workspace == m_workspace)
        return;

    m_workspace = workspace;
    QSettings settings(m_settingsPath, QSettings::IniFormat);
    settings.setValue(QStringLiteral("workspace/active"), workspace);
    settings.sync();
    emit workspaceChanged();
    updateStatus(QStringLiteral("Espacio activo: %1").arg(workspace));
}

void SystemBackend::setStudyLayout(const QString &layout)
{
    if (layout != QStringLiteral("PDF + NotCan")
        && layout != QStringLiteral("Moodle + Apuntes")
        && layout != QStringLiteral("Lectura"))
        return;
    if (layout == m_studyLayout)
        return;

    m_studyLayout = layout;
    QSettings settings(m_settingsPath, QSettings::IniFormat);
    settings.setValue(QStringLiteral("study/layout"), layout);
    settings.sync();
    emit studyLayoutChanged();
    updateStatus(QStringLiteral("Modo estudio: %1").arg(layout));
}

bool SystemBackend::startFirstAvailable(const QStringList &commands, const QStringList &arguments)
{
    for (const QString &command : commands) {
        const QString executable = QStandardPaths::findExecutable(command);
        if (!executable.isEmpty())
            return QProcess::startDetached(executable, arguments);
    }
    return false;
}

void SystemBackend::openFiles()
{
    // Abrimos primero el gestor propio. Thunar queda como respaldo durante la alpha.
    if (startFirstAvailable({QStringLiteral("murschol-files"), QStringLiteral("thunar")}))
        return;

    if (!QProcess::startDetached(QStringLiteral("xdg-open"), { QDir::homePath() }))
        updateStatus(QStringLiteral("No se pudo abrir Archivos"));
}

void SystemBackend::openBrowser()
{
    // Edge es la primera opción cuando el usuario lo instala; Firefox ESR sigue
    // disponible como navegador libre y como respaldo de la Live ISO.
    if (!startFirstAvailable({
            QStringLiteral("microsoft-edge-stable"),
            QStringLiteral("microsoft-edge"),
            QStringLiteral("firefox-esr"),
            QStringLiteral("firefox"),
            QStringLiteral("chromium"),
            QStringLiteral("google-chrome"),
            QStringLiteral("brave-browser")
        }))
        updateStatus(QStringLiteral("No se encontró un navegador"));
}

void SystemBackend::openTerminal()
{
    if (!startFirstAvailable({QStringLiteral("foot"), QStringLiteral("kgx"), QStringLiteral("konsole"), QStringLiteral("gnome-terminal"), QStringLiteral("xfce4-terminal"), QStringLiteral("xterm")}))
        updateStatus(QStringLiteral("No se encontró una terminal"));
}

void SystemBackend::openSettings(const QString &page)
{
    const QString executable = QStandardPaths::findExecutable(QStringLiteral("murschol-settings"));
    if (executable.isEmpty()) {
        updateStatus(QStringLiteral("MurSchol Settings todavía no está instalado"));
        return;
    }

    QStringList arguments;
    if (!page.trimmed().isEmpty())
        arguments << QStringLiteral("--page") << page.trimmed();

    if (QProcess::startDetached(executable, arguments))
        updateStatus(QStringLiteral("Abriendo Configuración"));
    else
        updateStatus(QStringLiteral("No se pudo abrir Configuración"));
}

void SystemBackend::openAndroid()
{
    if (!m_waydroidAvailable) {
        updateStatus(QStringLiteral("Android todavía no está instalado"));
        return;
    }
    if (QProcess::startDetached(QStringLiteral("waydroid"), { QStringLiteral("show-full-ui") }))
        updateStatus(QStringLiteral("Iniciando Android bajo demanda"));
}

void SystemBackend::openWindowsManager()
{
    if (!QStandardPaths::findExecutable(QStringLiteral("bottles")).isEmpty()) {
        QProcess::startDetached(QStringLiteral("bottles"));
        updateStatus(QStringLiteral("Abriendo entorno Windows"));
        return;
    }
    if (m_bottlesAvailable && m_flatpakAvailable) {
        QProcess::startDetached(QStringLiteral("flatpak"), { QStringLiteral("run"), QStringLiteral("com.usebottles.bottles") });
        updateStatus(QStringLiteral("Abriendo entorno Windows"));
        return;
    }
    if (m_wineAvailable) {
        updateStatus(QStringLiteral("Wine está disponible; el gestor gráfico se añadirá en App Manager"));
        return;
    }
    updateStatus(QStringLiteral("Bottles/Wine todavía no está preparado"));
}

void SystemBackend::powerOff()
{
    QProcess::startDetached(QStringLiteral("systemctl"), { QStringLiteral("poweroff") });
}

void SystemBackend::reboot()
{
    QProcess::startDetached(QStringLiteral("systemctl"), { QStringLiteral("reboot") });
}

void SystemBackend::updateStatus(const QString &text)
{
    m_statusText = text;
    emit statusChanged();
}
