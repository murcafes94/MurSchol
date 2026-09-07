#include "NetworkBackend.h"

#include <QDBusConnection>
#include <QDBusConnectionInterface>
#include <QDBusInterface>
#include <QDBusMessage>
#include <QDBusMetaType>
#include <QDBusObjectPath>
#include <QDBusReply>
#include <QDBusVariant>
#include <QHostAddress>
#include <QMap>
#include <QNetworkAddressEntry>
#include <QNetworkInterface>
#include <QVariantMap>

#include <algorithm>

using NmSettingsMap = QMap<QString, QVariantMap>;
Q_DECLARE_METATYPE(NmSettingsMap)

namespace {
constexpr auto kService = "org.freedesktop.NetworkManager";
constexpr auto kManagerPath = "/org/freedesktop/NetworkManager";
constexpr auto kManagerInterface = "org.freedesktop.NetworkManager";
constexpr auto kDeviceInterface = "org.freedesktop.NetworkManager.Device";
constexpr auto kWirelessInterface = "org.freedesktop.NetworkManager.Device.Wireless";
constexpr auto kAccessPointInterface = "org.freedesktop.NetworkManager.AccessPoint";
constexpr auto kSettingsPath = "/org/freedesktop/NetworkManager/Settings";
constexpr auto kSettingsInterface = "org.freedesktop.NetworkManager.Settings";
constexpr auto kConnectionInterface = "org.freedesktop.NetworkManager.Settings.Connection";

QVariant unwrap(const QVariant &value)
{
    if (value.metaType().id() == qMetaTypeId<QDBusVariant>())
        return qvariant_cast<QDBusVariant>(value).variant();
    return value;
}

QString ssidFromVariant(const QVariant &raw)
{
    const QVariant value = unwrap(raw);
    if (value.canConvert<QByteArray>())
        return QString::fromUtf8(value.toByteArray()).trimmed();
    return value.toString().trimmed();
}

QString objectPathFromVariant(const QVariant &raw)
{
    const QVariant value = unwrap(raw);
    if (value.canConvert<QDBusObjectPath>())
        return qvariant_cast<QDBusObjectPath>(value).path();
    return {};
}

QString connectivityName(uint value)
{
    switch (value) {
    case 1: return QStringLiteral("Sin conexión");
    case 2: return QStringLiteral("Portal cautivo");
    case 3: return QStringLiteral("Conexión limitada");
    case 4: return QStringLiteral("Internet disponible");
    default: return QStringLiteral("Estado desconocido");
    }
}

QString bandName(uint frequency)
{
    if (frequency >= 5925)
        return QStringLiteral("6 GHz");
    if (frequency >= 4900)
        return QStringLiteral("5 GHz");
    if (frequency >= 2400)
        return QStringLiteral("2,4 GHz");
    return {};
}
}

NetworkBackend::NetworkBackend(QObject *parent)
    : QObject(parent)
{
    qDBusRegisterMetaType<NmSettingsMap>();

    connect(&m_refreshTimer, &QTimer::timeout, this, &NetworkBackend::refresh);
    m_refreshTimer.setInterval(6000);
    m_refreshTimer.start();

    refresh();
}

void NetworkBackend::refresh()
{
    QDBusConnection bus = QDBusConnection::systemBus();
    QDBusReply<bool> registered;
    if (bus.interface())
        registered = bus.interface()->isServiceRegistered(QString::fromLatin1(kService));

    m_managerAvailable = registered.isValid() && registered.value();
    m_networkingEnabled = false;
    m_wifiHardwareAvailable = false;
    m_wifiEnabled = false;
    m_wifiDevicePath.clear();
    m_activeAccessPointPath.clear();
    m_activeSsid.clear();
    m_activeInterface.clear();
    m_ipv4Address.clear();
    m_connectivityText = QStringLiteral("NetworkManager no disponible");
    m_accessPoints.clear();
    m_savedConnections.clear();

    if (!m_managerAvailable) {
        emit networkChanged();
        return;
    }

    QDBusInterface manager(QString::fromLatin1(kService),
                           QString::fromLatin1(kManagerPath),
                           QString::fromLatin1(kManagerInterface),
                           bus);
    if (!manager.isValid()) {
        m_managerAvailable = false;
        emit networkChanged();
        return;
    }

    m_networkingEnabled = unwrap(manager.property("NetworkingEnabled")).toBool();
    m_wifiEnabled = unwrap(manager.property("WirelessEnabled")).toBool();
    m_connectivityText = connectivityName(unwrap(manager.property("Connectivity")).toUInt());

    readSavedConnections();

    QDBusMessage devicesReply = manager.call(QStringLiteral("GetDevices"));
    if (devicesReply.type() != QDBusMessage::ReplyMessage || devicesReply.arguments().isEmpty()) {
        setStatus(QStringLiteral("No se pudieron leer los dispositivos de red"));
        emit networkChanged();
        return;
    }

    const QList<QDBusObjectPath> devices = qdbus_cast<QList<QDBusObjectPath>>(devicesReply.arguments().constFirst());
    for (const QDBusObjectPath &devicePath : devices) {
        QDBusInterface device(QString::fromLatin1(kService),
                              devicePath.path(),
                              QString::fromLatin1(kDeviceInterface),
                              bus);
        if (!device.isValid())
            continue;

        const uint deviceType = unwrap(device.property("DeviceType")).toUInt();
        if (deviceType != 2) // NM_DEVICE_TYPE_WIFI
            continue;

        m_wifiHardwareAvailable = true;
        m_wifiDevicePath = devicePath.path();
        m_activeInterface = unwrap(device.property("Interface")).toString();

        QDBusInterface wireless(QString::fromLatin1(kService),
                                devicePath.path(),
                                QString::fromLatin1(kWirelessInterface),
                                bus);
        if (!wireless.isValid())
            break;

        m_activeAccessPointPath = objectPathFromVariant(wireless.property("ActiveAccessPoint"));

        QDBusMessage apsReply = wireless.call(QStringLiteral("GetAllAccessPoints"));
        QList<QDBusObjectPath> apPaths;
        if (apsReply.type() == QDBusMessage::ReplyMessage && !apsReply.arguments().isEmpty())
            apPaths = qdbus_cast<QList<QDBusObjectPath>>(apsReply.arguments().constFirst());

        QHash<QString, QVariantMap> strongestBySsid;
        for (const QDBusObjectPath &apPath : apPaths) {
            QDBusInterface ap(QString::fromLatin1(kService),
                              apPath.path(),
                              QString::fromLatin1(kAccessPointInterface),
                              bus);
            if (!ap.isValid())
                continue;

            const QString ssid = ssidFromVariant(ap.property("Ssid"));
            if (ssid.isEmpty())
                continue;

            const int strength = unwrap(ap.property("Strength")).toInt();
            const uint flags = unwrap(ap.property("Flags")).toUInt();
            const uint wpaFlags = unwrap(ap.property("WpaFlags")).toUInt();
            const uint rsnFlags = unwrap(ap.property("RsnFlags")).toUInt();
            const uint frequency = unwrap(ap.property("Frequency")).toUInt();
            const bool secure = (flags & 0x1U) != 0 || wpaFlags != 0 || rsnFlags != 0;
            const bool active = apPath.path() == m_activeAccessPointPath;

            QVariantMap item;
            item.insert(QStringLiteral("ssid"), ssid);
            item.insert(QStringLiteral("strength"), strength);
            item.insert(QStringLiteral("security"), secure ? QStringLiteral("Protegida") : QStringLiteral("Abierta"));
            item.insert(QStringLiteral("secure"), secure);
            item.insert(QStringLiteral("active"), active);
            item.insert(QStringLiteral("saved"), m_savedConnections.contains(ssid));
            item.insert(QStringLiteral("band"), bandName(frequency));
            item.insert(QStringLiteral("path"), apPath.path());

            if (active)
                m_activeSsid = ssid;

            const auto existing = strongestBySsid.constFind(ssid);
            if (existing == strongestBySsid.constEnd()
                || existing.value().value(QStringLiteral("strength")).toInt() < strength
                || active) {
                strongestBySsid.insert(ssid, item);
            }
        }

        QList<QVariantMap> sorted;
        sorted.reserve(strongestBySsid.size());
        for (auto it = strongestBySsid.constBegin(); it != strongestBySsid.constEnd(); ++it)
            sorted.append(it.value());
        std::sort(sorted.begin(), sorted.end(), [](const QVariantMap &a, const QVariantMap &b) {
            if (a.value(QStringLiteral("active")).toBool() != b.value(QStringLiteral("active")).toBool())
                return a.value(QStringLiteral("active")).toBool();
            return a.value(QStringLiteral("strength")).toInt() > b.value(QStringLiteral("strength")).toInt();
        });
        for (const QVariantMap &item : sorted)
            m_accessPoints.append(item);

        break; // Primera interfaz Wi-Fi: suficiente para la fase 1.
    }

    refreshAddress();
    emit networkChanged();
}

void NetworkBackend::readSavedConnections()
{
    QDBusConnection bus = QDBusConnection::systemBus();
    QDBusInterface settings(QString::fromLatin1(kService),
                            QString::fromLatin1(kSettingsPath),
                            QString::fromLatin1(kSettingsInterface),
                            bus);
    if (!settings.isValid())
        return;

    QDBusMessage listReply = settings.call(QStringLiteral("ListConnections"));
    if (listReply.type() != QDBusMessage::ReplyMessage || listReply.arguments().isEmpty())
        return;

    const QList<QDBusObjectPath> connections = qdbus_cast<QList<QDBusObjectPath>>(listReply.arguments().constFirst());
    for (const QDBusObjectPath &path : connections) {
        QDBusInterface connection(QString::fromLatin1(kService),
                                  path.path(),
                                  QString::fromLatin1(kConnectionInterface),
                                  bus);
        if (!connection.isValid())
            continue;

        QDBusReply<NmSettingsMap> reply = connection.call(QStringLiteral("GetSettings"));
        if (!reply.isValid())
            continue;

        const NmSettingsMap values = reply.value();
        const QVariantMap connectionGroup = values.value(QStringLiteral("connection"));
        if (unwrap(connectionGroup.value(QStringLiteral("type"))).toString() != QStringLiteral("802-11-wireless"))
            continue;

        const QVariantMap wifiGroup = values.value(QStringLiteral("802-11-wireless"));
        const QString ssid = ssidFromVariant(wifiGroup.value(QStringLiteral("ssid")));
        if (!ssid.isEmpty())
            m_savedConnections.insert(ssid, path.path());
    }
}

void NetworkBackend::refreshAddress()
{
    m_ipv4Address.clear();
    if (m_activeInterface.isEmpty())
        return;

    const QNetworkInterface iface = QNetworkInterface::interfaceFromName(m_activeInterface);
    for (const QNetworkAddressEntry &entry : iface.addressEntries()) {
        if (entry.ip().protocol() != QAbstractSocket::IPv4Protocol)
            continue;
        if (entry.ip().isLoopback())
            continue;
        m_ipv4Address = entry.ip().toString();
        break;
    }
}

void NetworkBackend::setWifiEnabled(bool enabled)
{
    if (!m_managerAvailable) {
        setStatus(QStringLiteral("NetworkManager no está disponible"));
        return;
    }

    QDBusInterface manager(QString::fromLatin1(kService),
                           QString::fromLatin1(kManagerPath),
                           QString::fromLatin1(kManagerInterface),
                           QDBusConnection::systemBus());
    if (!manager.isValid() || !manager.setProperty("WirelessEnabled", enabled)) {
        setStatus(QStringLiteral("No se pudo cambiar el estado de Wi-Fi"));
        refresh();
        return;
    }

    setStatus(enabled ? QStringLiteral("Wi-Fi activado") : QStringLiteral("Wi-Fi desactivado"));
    QTimer::singleShot(250, this, &NetworkBackend::refresh);
}

void NetworkBackend::requestScan()
{
    if (!m_managerAvailable || m_wifiDevicePath.isEmpty() || !m_wifiEnabled) {
        setStatus(QStringLiteral("Activa Wi-Fi para buscar redes"));
        return;
    }

    QDBusInterface wireless(QString::fromLatin1(kService),
                            m_wifiDevicePath,
                            QString::fromLatin1(kWirelessInterface),
                            QDBusConnection::systemBus());
    QDBusMessage reply = wireless.call(QStringLiteral("RequestScan"), QVariantMap{});
    if (reply.type() == QDBusMessage::ErrorMessage) {
        setStatus(QStringLiteral("NetworkManager no aceptó un nuevo escaneo todavía"));
        return;
    }

    setScanning(true);
    setStatus(QStringLiteral("Buscando redes Wi-Fi…"));
    QTimer::singleShot(1800, this, [this] {
        setScanning(false);
        refresh();
        setStatus(QStringLiteral("Redes actualizadas"));
    });
}

void NetworkBackend::disconnectWifi()
{
    if (m_wifiDevicePath.isEmpty()) {
        setStatus(QStringLiteral("No hay interfaz Wi-Fi activa"));
        return;
    }

    QDBusInterface device(QString::fromLatin1(kService),
                          m_wifiDevicePath,
                          QString::fromLatin1(kDeviceInterface),
                          QDBusConnection::systemBus());
    QDBusMessage reply = device.call(QStringLiteral("Disconnect"));
    if (reply.type() == QDBusMessage::ErrorMessage) {
        setStatus(QStringLiteral("No se pudo desconectar la red"));
        return;
    }

    setStatus(QStringLiteral("Wi-Fi desconectado"));
    QTimer::singleShot(300, this, &NetworkBackend::refresh);
}

bool NetworkBackend::connectSavedNetwork(const QString &ssid)
{
    const QString connectionPath = m_savedConnections.value(ssid);
    if (connectionPath.isEmpty() || m_wifiDevicePath.isEmpty()) {
        setStatus(QStringLiteral("La red no tiene una conexión guardada"));
        return false;
    }

    QDBusInterface manager(QString::fromLatin1(kService),
                           QString::fromLatin1(kManagerPath),
                           QString::fromLatin1(kManagerInterface),
                           QDBusConnection::systemBus());
    QDBusMessage reply = manager.call(QStringLiteral("ActivateConnection"),
                                      QVariant::fromValue(QDBusObjectPath(connectionPath)),
                                      QVariant::fromValue(QDBusObjectPath(m_wifiDevicePath)),
                                      QVariant::fromValue(QDBusObjectPath(QStringLiteral("/"))));
    if (reply.type() == QDBusMessage::ErrorMessage) {
        setStatus(QStringLiteral("No se pudo activar %1").arg(ssid));
        return false;
    }

    setStatus(QStringLiteral("Conectando a %1…").arg(ssid));
    QTimer::singleShot(1200, this, &NetworkBackend::refresh);
    return true;
}

bool NetworkBackend::isSavedNetwork(const QString &ssid) const
{
    return m_savedConnections.contains(ssid);
}

void NetworkBackend::setScanning(bool value)
{
    if (m_scanning == value)
        return;
    m_scanning = value;
    emit scanningChanged();
}

void NetworkBackend::setStatus(const QString &text)
{
    if (m_statusText == text)
        return;
    m_statusText = text;
    emit statusChanged();
}
