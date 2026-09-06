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
}

SystemBackend::SystemBackend(QObject *parent) : QObject(parent)
{
    detectStaticSystemInfo();
    detectCapabilities();

    QSettings settings;
    m_profile = settings.value(QStringLiteral("performance/profile")).toString();
    m_workspace = settings.value(QStringLiteral("workspace/active"), QStringLiteral("Estudio")).toString();
    m_studyLayout = settings.value(QStringLiteral("study/layout"), QStringLiteral("PDF + NotCan")).toString();

    refreshStats();
    if (m_profile.isEmpty())
        m_profile = recommendedProfile();

    connect(&m_timer, &QTimer::timeout, this, &SystemBackend::refreshStats);
    m_timer.start(1500);
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

void SystemBackend::setProfile(const QString &profile)
{
    if (profile != QStringLiteral("Ligero")
        && profile != QStringLiteral("Normal")
        && profile != QStringLiteral("Rendimiento"))
        return;
    if (profile == m_profile)
        return;

    m_profile = profile;
    QSettings().setValue(QStringLiteral("performance/profile"), profile);
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
    QSettings().setValue(QStringLiteral("workspace/active"), workspace);
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
    QSettings().setValue(QStringLiteral("study/layout"), layout);
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
    if (!QProcess::startDetached(QStringLiteral("xdg-open"), { QDir::homePath() }))
        updateStatus(QStringLiteral("No se pudo abrir Archivos"));
}

void SystemBackend::openBrowser()
{
    if (!startFirstAvailable({QStringLiteral("firefox-esr"), QStringLiteral("firefox"), QStringLiteral("chromium"), QStringLiteral("google-chrome"), QStringLiteral("brave-browser")}))
        updateStatus(QStringLiteral("No se encontró un navegador"));
}

void SystemBackend::openTerminal()
{
    if (!startFirstAvailable({QStringLiteral("foot"), QStringLiteral("kgx"), QStringLiteral("konsole"), QStringLiteral("gnome-terminal"), QStringLiteral("xfce4-terminal"), QStringLiteral("xterm")}))
        updateStatus(QStringLiteral("No se encontró una terminal"));
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
