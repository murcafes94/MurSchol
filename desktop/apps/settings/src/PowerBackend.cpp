#include "PowerBackend.h"

#include <QDBusConnection>
#include <QDBusConnectionInterface>
#include <QDBusInterface>
#include <QDBusMessage>
#include <QDBusObjectPath>
#include <QDBusReply>
#include <QProcess>
#include <QRegularExpression>
#include <QStandardPaths>
#include <QVariantMap>

namespace {
constexpr auto UPowerService = "org.freedesktop.UPower";
constexpr auto UPowerPath = "/org/freedesktop/UPower";
constexpr auto UPowerInterface = "org.freedesktop.UPower";
constexpr auto UPowerDeviceInterface = "org.freedesktop.UPower.Device";
constexpr auto PropertiesInterface = "org.freedesktop.DBus.Properties";
constexpr auto LogindService = "org.freedesktop.login1";
constexpr auto LogindPath = "/org/freedesktop/login1";
constexpr auto LogindInterface = "org.freedesktop.login1.Manager";

QVariantMap propertiesFor(const QString &service,
                          const QString &path,
                          const QString &interfaceName)
{
    QDBusInterface properties(service, path, QString::fromLatin1(PropertiesInterface),
                              QDBusConnection::systemBus());
    if (!properties.isValid())
        return {};

    const QDBusReply<QVariantMap> reply = properties.call(QStringLiteral("GetAll"), interfaceName);
    return reply.isValid() ? reply.value() : QVariantMap();
}
}

PowerBackend::PowerBackend(QObject *parent)
    : QObject(parent)
{
    refresh();
    m_refreshTimer.setInterval(5000);
    connect(&m_refreshTimer, &QTimer::timeout, this, &PowerBackend::refresh);
    m_refreshTimer.start();
}

void PowerBackend::refresh()
{
    refreshBattery();
    refreshBrightness();
    emit powerChanged();
}

void PowerBackend::refreshBattery()
{
    m_batteryAvailable = false;
    m_batteryPercent = 0;
    m_batteryState = QStringLiteral("No disponible");
    m_batteryTimeText.clear();
    m_onBattery = false;

    QDBusConnection bus = QDBusConnection::systemBus();
    QDBusConnectionInterface *busInterface = bus.interface();
    if (!busInterface || !busInterface->isServiceRegistered(QString::fromLatin1(UPowerService)))
        return;

    const QVariantMap rootProperties = propertiesFor(QString::fromLatin1(UPowerService),
                                                      QString::fromLatin1(UPowerPath),
                                                      QString::fromLatin1(UPowerInterface));
    m_onBattery = rootProperties.value(QStringLiteral("OnBattery"), false).toBool();

    QDBusInterface upower(QString::fromLatin1(UPowerService), QString::fromLatin1(UPowerPath),
                          QString::fromLatin1(UPowerInterface), bus);
    if (!upower.isValid())
        return;

    QString batteryPath;
    const QDBusReply<QDBusObjectPath> displayReply = upower.call(QStringLiteral("GetDisplayDevice"));
    if (displayReply.isValid() && displayReply.value().path() != QStringLiteral("/")) {
        const QVariantMap displayProperties = propertiesFor(QString::fromLatin1(UPowerService),
                                                            displayReply.value().path(),
                                                            QString::fromLatin1(UPowerDeviceInterface));
        if (displayProperties.value(QStringLiteral("Type")).toUInt() == 2
            && displayProperties.value(QStringLiteral("IsPresent"), true).toBool()) {
            batteryPath = displayReply.value().path();
        }
    }

    if (batteryPath.isEmpty()) {
        const QDBusReply<QList<QDBusObjectPath>> devicesReply = upower.call(QStringLiteral("EnumerateDevices"));
        if (devicesReply.isValid()) {
            for (const QDBusObjectPath &objectPath : devicesReply.value()) {
                const QVariantMap deviceProperties = propertiesFor(QString::fromLatin1(UPowerService),
                                                                   objectPath.path(),
                                                                   QString::fromLatin1(UPowerDeviceInterface));
                if (deviceProperties.value(QStringLiteral("Type")).toUInt() == 2
                    && deviceProperties.value(QStringLiteral("IsPresent"), true).toBool()) {
                    batteryPath = objectPath.path();
                    break;
                }
            }
        }
    }

    if (batteryPath.isEmpty())
        return;

    const QVariantMap battery = propertiesFor(QString::fromLatin1(UPowerService), batteryPath,
                                               QString::fromLatin1(UPowerDeviceInterface));
    if (battery.isEmpty())
        return;

    m_batteryAvailable = true;
    m_batteryPercent = qBound(0, qRound(battery.value(QStringLiteral("Percentage")).toDouble()), 100);

    const uint state = battery.value(QStringLiteral("State")).toUInt();
    const qint64 timeToEmpty = battery.value(QStringLiteral("TimeToEmpty")).toLongLong();
    const qint64 timeToFull = battery.value(QStringLiteral("TimeToFull")).toLongLong();

    switch (state) {
    case 1:
        m_batteryState = QStringLiteral("Cargando");
        m_batteryTimeText = timeToFull > 0 ? QStringLiteral("%1 para completar").arg(formatDuration(timeToFull))
                                           : QString();
        break;
    case 2:
        m_batteryState = QStringLiteral("Usando batería");
        m_batteryTimeText = timeToEmpty > 0 ? QStringLiteral("%1 restantes").arg(formatDuration(timeToEmpty))
                                            : QString();
        break;
    case 3:
        m_batteryState = QStringLiteral("Vacía");
        break;
    case 4:
        m_batteryState = QStringLiteral("Carga completa");
        break;
    case 5:
        m_batteryState = QStringLiteral("Pendiente de carga");
        break;
    case 6:
        m_batteryState = QStringLiteral("Pendiente de descarga");
        break;
    default:
        m_batteryState = m_onBattery ? QStringLiteral("Usando batería")
                                     : QStringLiteral("Conectada a corriente");
        break;
    }
}

void PowerBackend::refreshBrightness()
{
    m_brightnessAvailable = false;
    m_brightnessPercent = 0;
    m_brightnessDevice.clear();
    m_brightnessctlPath = QStandardPaths::findExecutable(QStringLiteral("brightnessctl"));
    if (m_brightnessctlPath.isEmpty())
        return;

    QProcess process;
    process.start(m_brightnessctlPath, {QStringLiteral("-m")});
    if (!process.waitForFinished(1200) || process.exitStatus() != QProcess::NormalExit
        || process.exitCode() != 0) {
        return;
    }

    const QString output = QString::fromUtf8(process.readAllStandardOutput()).trimmed();
    const QString firstLine = output.section('\n', 0, 0).trimmed();
    const QStringList parts = firstLine.split(',');
    if (parts.size() < 4)
        return;

    QString percent = parts.at(3).trimmed();
    percent.remove('%');
    bool ok = false;
    const int value = percent.toInt(&ok);
    if (!ok)
        return;

    m_brightnessAvailable = true;
    m_brightnessPercent = qBound(0, value, 100);
    m_brightnessDevice = parts.at(0).trimmed();
}

bool PowerBackend::setBrightness(int percent)
{
    percent = qBound(1, percent, 100);
    if (m_brightnessctlPath.isEmpty())
        m_brightnessctlPath = QStandardPaths::findExecutable(QStringLiteral("brightnessctl"));
    if (m_brightnessctlPath.isEmpty()) {
        setStatus(QStringLiteral("Este equipo no expone un control de brillo compatible"));
        return false;
    }

    QProcess process;
    process.start(m_brightnessctlPath,
                  {QStringLiteral("set"), QStringLiteral("%1%").arg(percent)});
    const bool finished = process.waitForFinished(1800);
    const bool ok = finished && process.exitStatus() == QProcess::NormalExit
                    && process.exitCode() == 0;
    if (!ok) {
        setStatus(QStringLiteral("No se pudo cambiar el brillo; revisa permisos del dispositivo"));
        return false;
    }

    m_brightnessPercent = percent;
    emit powerChanged();
    setStatus(QStringLiteral("Brillo: %1%").arg(percent));
    QTimer::singleShot(250, this, &PowerBackend::refresh);
    return true;
}

bool PowerBackend::suspendNow()
{
    QDBusInterface manager(QString::fromLatin1(LogindService), QString::fromLatin1(LogindPath),
                           QString::fromLatin1(LogindInterface), QDBusConnection::systemBus());
    if (!manager.isValid()) {
        setStatus(QStringLiteral("systemd-logind no está disponible"));
        return false;
    }

    const QDBusMessage reply = manager.call(QStringLiteral("Suspend"), true);
    const bool ok = reply.type() != QDBusMessage::ErrorMessage;
    setStatus(ok ? QStringLiteral("Solicitando suspensión…")
                 : QStringLiteral("No se pudo suspender el equipo"));
    return ok;
}

QString PowerBackend::formatDuration(qint64 seconds)
{
    if (seconds <= 0)
        return {};
    const qint64 hours = seconds / 3600;
    const qint64 minutes = (seconds % 3600) / 60;
    if (hours > 0 && minutes > 0)
        return QStringLiteral("%1 h %2 min").arg(hours).arg(minutes);
    if (hours > 0)
        return QStringLiteral("%1 h").arg(hours);
    return QStringLiteral("%1 min").arg(qMax<qint64>(1, minutes));
}

void PowerBackend::setStatus(const QString &text)
{
    if (m_statusText == text)
        return;
    m_statusText = text;
    emit statusChanged();
}
