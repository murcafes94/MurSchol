#pragma once

#include <QObject>
#include <QString>
#include <QTimer>

class PowerBackend : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool batteryAvailable READ batteryAvailable NOTIFY powerChanged)
    Q_PROPERTY(int batteryPercent READ batteryPercent NOTIFY powerChanged)
    Q_PROPERTY(QString batteryState READ batteryState NOTIFY powerChanged)
    Q_PROPERTY(QString batteryTimeText READ batteryTimeText NOTIFY powerChanged)
    Q_PROPERTY(bool onBattery READ onBattery NOTIFY powerChanged)
    Q_PROPERTY(bool brightnessAvailable READ brightnessAvailable NOTIFY powerChanged)
    Q_PROPERTY(int brightnessPercent READ brightnessPercent NOTIFY powerChanged)
    Q_PROPERTY(QString brightnessDevice READ brightnessDevice NOTIFY powerChanged)
    Q_PROPERTY(QString statusText READ statusText NOTIFY statusChanged)

public:
    explicit PowerBackend(QObject *parent = nullptr);

    bool batteryAvailable() const { return m_batteryAvailable; }
    int batteryPercent() const { return m_batteryPercent; }
    QString batteryState() const { return m_batteryState; }
    QString batteryTimeText() const { return m_batteryTimeText; }
    bool onBattery() const { return m_onBattery; }
    bool brightnessAvailable() const { return m_brightnessAvailable; }
    int brightnessPercent() const { return m_brightnessPercent; }
    QString brightnessDevice() const { return m_brightnessDevice; }
    QString statusText() const { return m_statusText; }

    Q_INVOKABLE void refresh();
    Q_INVOKABLE bool setBrightness(int percent);
    Q_INVOKABLE bool suspendNow();

signals:
    void powerChanged();
    void statusChanged();

private:
    void refreshBattery();
    void refreshBrightness();
    void setStatus(const QString &text);
    static QString formatDuration(qint64 seconds);

    QTimer m_refreshTimer;
    bool m_batteryAvailable = false;
    int m_batteryPercent = 0;
    QString m_batteryState = QStringLiteral("No disponible");
    QString m_batteryTimeText;
    bool m_onBattery = false;

    bool m_brightnessAvailable = false;
    int m_brightnessPercent = 0;
    QString m_brightnessDevice;
    QString m_brightnessctlPath;

    QString m_statusText = QStringLiteral("Energía lista");
};
