#include "BluetoothBackend.h"

#include <QDBusConnection>
#include <QDBusConnectionInterface>
#include <QDBusInterface>
#include <QDBusMessage>
#include <QDBusReply>
#include <QDBusVariant>
#include <QRegularExpression>

namespace {
constexpr auto BluezService = "org.bluez";
}

BluetoothBackend::BluetoothBackend(QObject *parent)
    : QObject(parent)
{
    refresh();

    m_refreshTimer.setInterval(4000);
    connect(&m_refreshTimer, &QTimer::timeout, this, &BluetoothBackend::refresh);
    m_refreshTimer.start();
}

QString BluetoothBackend::introspect(const QString &path) const
{
    QDBusInterface iface(QString::fromLatin1(BluezService), path,
                         QStringLiteral("org.freedesktop.DBus.Introspectable"),
                         QDBusConnection::systemBus());
    if (!iface.isValid())
        return {};

    const QDBusReply<QString> reply = iface.call(QStringLiteral("Introspect"));
    return reply.isValid() ? reply.value() : QString();
}

QStringList BluetoothBackend::childNodes(const QString &path) const
{
    const QString xml = introspect(path);
    if (xml.isEmpty())
        return {};

    QStringList result;
    static const QRegularExpression nodeRx(QStringLiteral("<node\\s+name=\"([^\"]+)\""));
    QRegularExpressionMatchIterator it = nodeRx.globalMatch(xml);
    while (it.hasNext()) {
        const QString name = it.next().captured(1).trimmed();
        if (!name.isEmpty())
            result.append(name);
    }
    return result;
}

QVariantMap BluetoothBackend::getAllProperties(const QString &path,
                                               const QString &interfaceName) const
{
    QDBusInterface props(QString::fromLatin1(BluezService), path,
                         QStringLiteral("org.freedesktop.DBus.Properties"),
                         QDBusConnection::systemBus());
    if (!props.isValid())
        return {};

    const QDBusReply<QVariantMap> reply = props.call(QStringLiteral("GetAll"), interfaceName);
    return reply.isValid() ? reply.value() : QVariantMap();
}

bool BluetoothBackend::setProperty(const QString &path,
                                   const QString &interfaceName,
                                   const QString &name,
                                   const QVariant &value) const
{
    QDBusInterface props(QString::fromLatin1(BluezService), path,
                         QStringLiteral("org.freedesktop.DBus.Properties"),
                         QDBusConnection::systemBus());
    if (!props.isValid())
        return false;

    const QDBusMessage reply = props.call(QStringLiteral("Set"), interfaceName, name,
                                          QVariant::fromValue(QDBusVariant(value)));
    return reply.type() != QDBusMessage::ErrorMessage;
}

bool BluetoothBackend::callDeviceMethod(const QString &path, const QString &method) const
{
    QDBusInterface device(QString::fromLatin1(BluezService), path,
                          QStringLiteral("org.bluez.Device1"),
                          QDBusConnection::systemBus());
    if (!device.isValid())
        return false;

    const QDBusMessage reply = device.call(method);
    return reply.type() != QDBusMessage::ErrorMessage;
}

void BluetoothBackend::refresh()
{
    QDBusConnection bus = QDBusConnection::systemBus();
    QDBusConnectionInterface *busInterface = bus.interface();
    m_available = busInterface
                  && busInterface->isServiceRegistered(QString::fromLatin1(BluezService));

    m_adapterPath.clear();
    m_devices.clear();
    m_powered = false;
    m_discovering = false;
    m_adapterName = QStringLiteral("Bluetooth");

    if (!m_available) {
        setStatus(QStringLiteral("BlueZ no está disponible"));
        emit bluetoothChanged();
        return;
    }

    const QStringList adapters = childNodes(QStringLiteral("/org/bluez"));
    QString adapterNode;
    for (const QString &node : adapters) {
        if (node.startsWith(QStringLiteral("hci"))) {
            adapterNode = node;
            break;
        }
    }

    if (adapterNode.isEmpty()) {
        setStatus(QStringLiteral("No se detectó un adaptador Bluetooth"));
        emit bluetoothChanged();
        return;
    }

    m_adapterPath = QStringLiteral("/org/bluez/") + adapterNode;
    const QVariantMap adapterProps = getAllProperties(m_adapterPath, QStringLiteral("org.bluez.Adapter1"));
    if (adapterProps.isEmpty()) {
        setStatus(QStringLiteral("No se pudieron leer las propiedades del adaptador"));
        emit bluetoothChanged();
        return;
    }

    m_powered = adapterProps.value(QStringLiteral("Powered")).toBool();
    m_discovering = adapterProps.value(QStringLiteral("Discovering")).toBool();
    m_adapterName = adapterProps.value(QStringLiteral("Alias"),
                                       adapterProps.value(QStringLiteral("Name"), QStringLiteral("Bluetooth"))).toString();

    QVariantList devices;
    const QStringList children = childNodes(m_adapterPath);
    for (const QString &child : children) {
        if (!child.startsWith(QStringLiteral("dev_")))
            continue;

        const QString path = m_adapterPath + QStringLiteral("/") + child;
        const QVariantMap props = getAllProperties(path, QStringLiteral("org.bluez.Device1"));
        if (props.isEmpty())
            continue;

        QVariantMap item;
        const QString name = props.value(QStringLiteral("Alias"),
                                         props.value(QStringLiteral("Name"),
                                                     props.value(QStringLiteral("Address"), QStringLiteral("Dispositivo")))).toString();
        item.insert(QStringLiteral("path"), path);
        item.insert(QStringLiteral("name"), name);
        item.insert(QStringLiteral("address"), props.value(QStringLiteral("Address")).toString());
        item.insert(QStringLiteral("paired"), props.value(QStringLiteral("Paired")).toBool());
        item.insert(QStringLiteral("connected"), props.value(QStringLiteral("Connected")).toBool());
        item.insert(QStringLiteral("trusted"), props.value(QStringLiteral("Trusted")).toBool());
        item.insert(QStringLiteral("icon"), props.value(QStringLiteral("Icon")).toString());
        item.insert(QStringLiteral("rssi"), props.value(QStringLiteral("RSSI"), 0).toInt());
        devices.append(item);
    }

    std::sort(devices.begin(), devices.end(), [](const QVariant &a, const QVariant &b) {
        const QVariantMap left = a.toMap();
        const QVariantMap right = b.toMap();
        if (left.value(QStringLiteral("connected")).toBool() != right.value(QStringLiteral("connected")).toBool())
            return left.value(QStringLiteral("connected")).toBool();
        if (left.value(QStringLiteral("paired")).toBool() != right.value(QStringLiteral("paired")).toBool())
            return left.value(QStringLiteral("paired")).toBool();
        return left.value(QStringLiteral("name")).toString().localeAwareCompare(
                   right.value(QStringLiteral("name")).toString()) < 0;
    });

    m_devices = devices;
    emit bluetoothChanged();
}

void BluetoothBackend::setPowered(bool powered)
{
    if (m_adapterPath.isEmpty()) {
        setStatus(QStringLiteral("No hay adaptador Bluetooth disponible"));
        return;
    }

    if (setProperty(m_adapterPath, QStringLiteral("org.bluez.Adapter1"),
                    QStringLiteral("Powered"), powered)) {
        m_powered = powered;
        emit bluetoothChanged();
        setStatus(powered ? QStringLiteral("Bluetooth activado")
                          : QStringLiteral("Bluetooth desactivado"));
        QTimer::singleShot(250, this, &BluetoothBackend::refresh);
    } else {
        setStatus(QStringLiteral("No se pudo cambiar el estado de Bluetooth"));
    }
}

void BluetoothBackend::startDiscovery()
{
    if (m_adapterPath.isEmpty() || !m_powered) {
        setStatus(QStringLiteral("Activa Bluetooth antes de buscar dispositivos"));
        return;
    }

    QDBusInterface adapter(QString::fromLatin1(BluezService), m_adapterPath,
                           QStringLiteral("org.bluez.Adapter1"),
                           QDBusConnection::systemBus());
    const QDBusMessage reply = adapter.call(QStringLiteral("StartDiscovery"));
    if (reply.type() == QDBusMessage::ErrorMessage) {
        setStatus(QStringLiteral("No se pudo iniciar la búsqueda"));
        return;
    }

    m_discovering = true;
    emit bluetoothChanged();
    setStatus(QStringLiteral("Buscando dispositivos Bluetooth…"));
    QTimer::singleShot(1000, this, &BluetoothBackend::refresh);
}

void BluetoothBackend::stopDiscovery()
{
    if (m_adapterPath.isEmpty())
        return;

    QDBusInterface adapter(QString::fromLatin1(BluezService), m_adapterPath,
                           QStringLiteral("org.bluez.Adapter1"),
                           QDBusConnection::systemBus());
    const QDBusMessage reply = adapter.call(QStringLiteral("StopDiscovery"));
    if (reply.type() == QDBusMessage::ErrorMessage) {
        setStatus(QStringLiteral("No se pudo detener la búsqueda"));
        return;
    }

    m_discovering = false;
    emit bluetoothChanged();
    setStatus(QStringLiteral("Búsqueda detenida"));
}

bool BluetoothBackend::connectDevice(const QString &path)
{
    const bool ok = callDeviceMethod(path, QStringLiteral("Connect"));
    setStatus(ok ? QStringLiteral("Conectando dispositivo…")
                 : QStringLiteral("No se pudo conectar el dispositivo"));
    if (ok)
        QTimer::singleShot(500, this, &BluetoothBackend::refresh);
    return ok;
}

bool BluetoothBackend::disconnectDevice(const QString &path)
{
    const bool ok = callDeviceMethod(path, QStringLiteral("Disconnect"));
    setStatus(ok ? QStringLiteral("Dispositivo desconectado")
                 : QStringLiteral("No se pudo desconectar el dispositivo"));
    if (ok)
        QTimer::singleShot(350, this, &BluetoothBackend::refresh);
    return ok;
}

bool BluetoothBackend::setTrusted(const QString &path, bool trusted)
{
    const bool ok = setProperty(path, QStringLiteral("org.bluez.Device1"),
                                QStringLiteral("Trusted"), trusted);
    setStatus(ok ? (trusted ? QStringLiteral("Dispositivo marcado como confiable")
                             : QStringLiteral("Confianza retirada"))
                 : QStringLiteral("No se pudo cambiar la confianza del dispositivo"));
    if (ok)
        QTimer::singleShot(250, this, &BluetoothBackend::refresh);
    return ok;
}

void BluetoothBackend::setStatus(const QString &text)
{
    if (m_statusText == text)
        return;
    m_statusText = text;
    emit statusChanged();
}
