#pragma once

#include <QObject>

class QuickControlsBackend : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool networkAvailable READ networkAvailable CONSTANT)
    Q_PROPERTY(bool audioAvailable READ audioAvailable CONSTANT)
    Q_PROPERTY(bool bluetoothAvailable READ bluetoothAvailable CONSTANT)

public:
    explicit QuickControlsBackend(QObject *parent = nullptr);

    bool networkAvailable() const { return m_networkAvailable; }
    bool audioAvailable() const { return m_audioAvailable; }
    bool bluetoothAvailable() const { return m_bluetoothAvailable; }

    Q_INVOKABLE bool openNetworkSettings();
    Q_INVOKABLE bool openAudioSettings();
    Q_INVOKABLE bool openBluetoothSettings();

private:
    bool m_networkAvailable = false;
    bool m_audioAvailable = false;
    bool m_bluetoothAvailable = false;
};
