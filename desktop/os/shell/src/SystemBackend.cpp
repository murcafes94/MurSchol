#include "SystemBackend.h"

#include <QDir>
#include <QFile>
#include <QProcess>
#include <QSettings>
#include <QStandardPaths>
#include <QStorageInfo>
#include <QTextStream>

SystemBackend::SystemBackend(QObject *parent) : QObject(parent)
{
    detectCapabilities();

    QSettings settings;
    m_profile = settings.value(QStringLiteral("performance/profile")).toString();

    refreshStats();
    if (m_profile.isEmpty()) {
        if (m_totalMemoryGb < 3.5)
            m_profile = QStringLiteral("Ligero");
        else if (m_totalMemoryGb < 8.0)
            m_profile = QStringLiteral("Normal");
        else
            m_profile = QStringLiteral("Rendimiento");
    }

    connect(&m_timer, &QTimer::timeout, this, &SystemBackend::refreshStats);
    m_timer.start(1500);
}

void SystemBackend::detectCapabilities()
{
    m_waydroidAvailable = !QStandardPaths::findExecutable(QStringLiteral("waydroid")).isEmpty();
    m_wineAvailable = !QStandardPaths::findExecutable(QStringLiteral("wine")).isEmpty();
    m_flatpakAvailable = !QStandardPaths::findExecutable(QStringLiteral("flatpak")).isEmpty();
    m_bottlesAvailable = !QStandardPaths::findExecutable(QStringLiteral("bottles")).isEmpty();
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

    emit statsChanged();
}

void SystemBackend::setProfile(const QString &profile)
{
    if (profile == m_profile)
        return;
    m_profile = profile;
    QSettings().setValue(QStringLiteral("performance/profile"), profile);
    emit profileChanged();
    updateStatus(QStringLiteral("Perfil cambiado a %1").arg(profile));
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
    QProcess::startDetached(QStringLiteral("waydroid"), { QStringLiteral("show-full-ui") });
}

void SystemBackend::openWindowsManager()
{
    if (m_bottlesAvailable) {
        QProcess::startDetached(QStringLiteral("bottles"));
        return;
    }
    if (m_flatpakAvailable) {
        QProcess::startDetached(QStringLiteral("flatpak"), { QStringLiteral("run"), QStringLiteral("com.usebottles.bottles") });
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
