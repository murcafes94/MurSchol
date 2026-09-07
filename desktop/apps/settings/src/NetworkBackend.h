#pragma once

#include <QObject>
#include <QHash>
#include <QString>
#include <QTimer>
#include <QVariantList>

class NetworkBackend : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool managerAvailable READ managerAvailable NOTIFY networkChanged)
    Q_PROPERTY(bool networkingEnabled READ networkingEnabled NOTIFY networkChanged)
    Q_PROPERTY(bool wifiHardwareAvailable READ wifiHardwareAvailable NOTIFY networkChanged)
    Q_PROPERTY(bool wifiEnabled READ wifiEnabled NOTIFY networkChanged)
    Q_PROPERTY(QString activeSsid READ activeSsid NOTIFY networkChanged)
    Q_PROPERTY(QString activeInterface READ activeInterface NOTIFY networkChanged)
    Q_PROPERTY(QString ipv4Address READ ipv4Address NOTIFY networkChanged)
    Q_PROPERTY(QString connectivityText READ connectivityText NOTIFY networkChanged)
    Q_PROPERTY(QVariantList accessPoints READ accessPoints NOTIFY networkChanged)
    Q_PROPERTY(bool scanning READ scanning NOTIFY scanningChanged)
    Q_PROPERTY(QString statusText READ statusText NOTIFY statusChanged)

public:
    explicit NetworkBackend(QObject *parent = nullptr);

    bool managerAvailable() const { return m_managerAvailable; }
    bool networkingEnabled() const { return m_networkingEnabled; }
    bool wifiHardwareAvailable() const { return m_wifiHardwareAvailable; }
    bool wifiEnabled() const { return m_wifiEnabled; }
    QString activeSsid() const { return m_activeSsid; }
    QString activeInterface() const { return m_activeInterface; }
    QString ipv4Address() const { return m_ipv4Address; }
    QString connectivityText() const { return m_connectivityText; }
    QVariantList accessPoints() const { return m_accessPoints; }
    bool scanning() const { return m_scanning; }
    QString statusText() const { return m_statusText; }

    Q_INVOKABLE void refresh();
    Q_INVOKABLE void setWifiEnabled(bool enabled);
    Q_INVOKABLE void requestScan();
    Q_INVOKABLE void disconnectWifi();
    Q_INVOKABLE bool connectSavedNetwork(const QString &ssid);
    Q_INVOKABLE bool isSavedNetwork(const QString &ssid) const;

signals:
    void networkChanged();
    void scanningChanged();
    void statusChanged();

private:
    void readSavedConnections();
    void refreshAddress();
    void setScanning(bool value);
    void setStatus(const QString &text);

    QTimer m_refreshTimer;
    bool m_managerAvailable = false;
    bool m_networkingEnabled = false;
    bool m_wifiHardwareAvailable = false;
    bool m_wifiEnabled = false;
    bool m_scanning = false;
    QString m_wifiDevicePath;
    QString m_activeAccessPointPath;
    QString m_activeSsid;
    QString m_activeInterface;
    QString m_ipv4Address;
    QString m_connectivityText = QStringLiteral("Sin información");
    QVariantList m_accessPoints;
    QHash<QString, QString> m_savedConnections;
    QString m_statusText = QStringLiteral("Red lista");
};
