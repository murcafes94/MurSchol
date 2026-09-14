#pragma once

#include <QObject>
#include <QTimer>

class QuickControlsBackend : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool networkAvailable READ networkAvailable NOTIFY controlsChanged)
    Q_PROPERTY(bool wifiEnabled READ wifiEnabled NOTIFY controlsChanged)
    Q_PROPERTY(QString wifiStatus READ wifiStatus NOTIFY controlsChanged)
    Q_PROPERTY(bool audioAvailable READ audioAvailable NOTIFY controlsChanged)
    Q_PROPERTY(int volume READ volume NOTIFY controlsChanged)
    Q_PROPERTY(bool muted READ muted NOTIFY controlsChanged)
    Q_PROPERTY(bool bluetoothAvailable READ bluetoothAvailable NOTIFY controlsChanged)
    Q_PROPERTY(bool bluetoothEnabled READ bluetoothEnabled NOTIFY controlsChanged)
    Q_PROPERTY(QString statusText READ statusText NOTIFY statusChanged)

public:
    explicit QuickControlsBackend(QObject *parent = nullptr);

    bool networkAvailable() const { return m_networkAvailable; }
    bool wifiEnabled() const { return m_wifiEnabled; }
    QString wifiStatus() const { return m_wifiStatus; }
    bool audioAvailable() const { return m_audioAvailable; }
    int volume() const { return m_volume; }
    bool muted() const { return m_muted; }
    bool bluetoothAvailable() const { return m_bluetoothAvailable; }
    bool bluetoothEnabled() const { return m_bluetoothEnabled; }
    QString statusText() const { return m_statusText; }

    Q_INVOKABLE void refresh();
    Q_INVOKABLE bool setWifiEnabled(bool enabled);
    Q_INVOKABLE bool setVolume(int percent);
    Q_INVOKABLE bool toggleMute();
    Q_INVOKABLE bool setBluetoothEnabled(bool enabled);
    Q_INVOKABLE bool openNetworkSettings();
    Q_INVOKABLE bool openAudioSettings();
    Q_INVOKABLE bool openBluetoothSettings();

signals:
    void controlsChanged();
    void statusChanged();

private:
    void setStatus(const QString &text);

    QTimer m_refreshTimer;
    bool m_refreshing = false;
    bool m_networkAvailable = false;
    bool m_wifiEnabled = false;
    QString m_wifiStatus = QStringLiteral("No disponible");
    bool m_audioAvailable = false;
    int m_volume = 0;
    bool m_muted = false;
    bool m_bluetoothAvailable = false;
    bool m_bluetoothEnabled = false;
    QString m_statusText;
};
