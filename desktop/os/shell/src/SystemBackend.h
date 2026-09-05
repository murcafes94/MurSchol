#pragma once

#include <QObject>
#include <QTimer>

class SystemBackend final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int cpuUsage READ cpuUsage NOTIFY statsChanged)
    Q_PROPERTY(int memoryUsage READ memoryUsage NOTIFY statsChanged)
    Q_PROPERTY(double totalMemoryGb READ totalMemoryGb NOTIFY statsChanged)
    Q_PROPERTY(int diskUsage READ diskUsage NOTIFY statsChanged)
    Q_PROPERTY(QString profile READ profile WRITE setProfile NOTIFY profileChanged)
    Q_PROPERTY(bool waydroidAvailable READ waydroidAvailable CONSTANT)
    Q_PROPERTY(bool wineAvailable READ wineAvailable CONSTANT)
    Q_PROPERTY(bool bottlesAvailable READ bottlesAvailable CONSTANT)
    Q_PROPERTY(bool flatpakAvailable READ flatpakAvailable CONSTANT)
    Q_PROPERTY(QString statusText READ statusText NOTIFY statusChanged)

public:
    explicit SystemBackend(QObject *parent = nullptr);

    int cpuUsage() const { return m_cpuUsage; }
    int memoryUsage() const { return m_memoryUsage; }
    double totalMemoryGb() const { return m_totalMemoryGb; }
    int diskUsage() const { return m_diskUsage; }
    QString profile() const { return m_profile; }
    QString statusText() const { return m_statusText; }

    bool waydroidAvailable() const { return m_waydroidAvailable; }
    bool wineAvailable() const { return m_wineAvailable; }
    bool bottlesAvailable() const { return m_bottlesAvailable; }
    bool flatpakAvailable() const { return m_flatpakAvailable; }

    Q_INVOKABLE void setProfile(const QString &profile);
    Q_INVOKABLE void openFiles();
    Q_INVOKABLE void openTerminal();
    Q_INVOKABLE void openAndroid();
    Q_INVOKABLE void openWindowsManager();
    Q_INVOKABLE void powerOff();
    Q_INVOKABLE void reboot();

signals:
    void statsChanged();
    void profileChanged();
    void statusChanged();

private slots:
    void refreshStats();

private:
    void detectCapabilities();
    void updateStatus(const QString &text);
    static bool startFirstAvailable(const QStringList &commands, const QStringList &arguments = {});

    QTimer m_timer;
    int m_cpuUsage = 0;
    int m_memoryUsage = 0;
    double m_totalMemoryGb = 0.0;
    int m_diskUsage = 0;
    QString m_profile;
    QString m_statusText = QStringLiteral("MurSchol listo");
    bool m_waydroidAvailable = false;
    bool m_wineAvailable = false;
    bool m_bottlesAvailable = false;
    bool m_flatpakAvailable = false;
    quint64 m_lastCpuTotal = 0;
    quint64 m_lastCpuIdle = 0;
};
