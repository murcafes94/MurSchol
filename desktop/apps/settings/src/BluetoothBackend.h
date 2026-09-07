#pragma once

#include <QObject>
#include <QTimer>
#include <QVariantList>

class BluetoothBackend : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool available READ available NOTIFY bluetoothChanged)
    Q_PROPERTY(bool powered READ powered NOTIFY bluetoothChanged)
    Q_PROPERTY(bool discovering READ discovering NOTIFY bluetoothChanged)
    Q_PROPERTY(QString adapterName READ adapterName NOTIFY bluetoothChanged)
    Q_PROPERTY(QVariantList devices READ devices NOTIFY bluetoothChanged)
    Q_PROPERTY(QString statusText READ statusText NOTIFY statusChanged)

public:
    explicit BluetoothBackend(QObject *parent = nullptr);

    bool available() const { return m_available; }
    bool powered() const { return m_powered; }
    bool discovering() const { return m_discovering; }
    QString adapterName() const { return m_adapterName; }
    QVariantList devices() const { return m_devices; }
    QString statusText() const { return m_statusText; }

    Q_INVOKABLE void refresh();
    Q_INVOKABLE void setPowered(bool powered);
    Q_INVOKABLE void startDiscovery();
    Q_INVOKABLE void stopDiscovery();
    Q_INVOKABLE bool connectDevice(const QString &path);
    Q_INVOKABLE bool disconnectDevice(const QString &path);
    Q_INVOKABLE bool setTrusted(const QString &path, bool trusted);

signals:
    void bluetoothChanged();
    void statusChanged();

private:
    QString introspect(const QString &path) const;
    QStringList childNodes(const QString &path) const;
    QVariantMap getAllProperties(const QString &path, const QString &interfaceName) const;
    bool setProperty(const QString &path, const QString &interfaceName,
                     const QString &name, const QVariant &value) const;
    bool callDeviceMethod(const QString &path, const QString &method) const;
    void setStatus(const QString &text);

    QTimer m_refreshTimer;
    bool m_available = false;
    bool m_powered = false;
    bool m_discovering = false;
    QString m_adapterPath;
    QString m_adapterName = QStringLiteral("Bluetooth");
    QVariantList m_devices;
    QString m_statusText = QStringLiteral("Bluetooth listo");
};
