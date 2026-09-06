#pragma once

#include <QObject>
#include <QString>
#include <QStringList>
#include <QTimer>

class SystemBackend : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int cpuUsage READ cpuUsage NOTIFY statsChanged)
    Q_PROPERTY(int memoryUsage READ memoryUsage NOTIFY statsChanged)
    Q_PROPERTY(double totalMemoryGb READ totalMemoryGb NOTIFY statsChanged)
    Q_PROPERTY(int diskUsage READ diskUsage NOTIFY statsChanged)
    Q_PROPERTY(QString profile READ profile WRITE setProfile NOTIFY profileChanged)
    Q_PROPERTY(QString recommendedProfile READ recommendedProfile NOTIFY statsChanged)
    Q_PROPERTY(QString workspace READ workspace WRITE setWorkspace NOTIFY workspaceChanged)
    Q_PROPERTY(QString studyLayout READ studyLayout WRITE setStudyLayout NOTIFY studyLayoutChanged)
    Q_PROPERTY(bool waydroidAvailable READ waydroidAvailable CONSTANT)
    Q_PROPERTY(bool wineAvailable READ wineAvailable CONSTANT)
    Q_PROPERTY(bool bottlesAvailable READ bottlesAvailable CONSTANT)
    Q_PROPERTY(bool flatpakAvailable READ flatpakAvailable CONSTANT)
    Q_PROPERTY(bool externalPanel READ externalPanel CONSTANT)
    Q_PROPERTY(QString distroName READ distroName CONSTANT)
    Q_PROPERTY(QString kernelVersion READ kernelVersion CONSTANT)
    Q_PROPERTY(QString cpuModel READ cpuModel CONSTANT)
    Q_PROPERTY(int cpuThreads READ cpuThreads CONSTANT)
    Q_PROPERTY(bool batteryAvailable READ batteryAvailable NOTIFY statsChanged)
    Q_PROPERTY(int batteryPercent READ batteryPercent NOTIFY statsChanged)
    Q_PROPERTY(bool charging READ charging NOTIFY statsChanged)
    Q_PROPERTY(QString statusText READ statusText NOTIFY statusChanged)

public:
    explicit SystemBackend(QObject *parent = nullptr);

    int cpuUsage() const { return m_cpuUsage; }
    int memoryUsage() const { return m_memoryUsage; }
    double totalMemoryGb() const { return m_totalMemoryGb; }
    int diskUsage() const { return m_diskUsage; }
    QString profile() const { return m_profile; }
    QString recommendedProfile() const;
    QString workspace() const { return m_workspace; }
    QString studyLayout() const { return m_studyLayout; }
    QString statusText() const { return m_statusText; }

    bool waydroidAvailable() const { return m_waydroidAvailable; }
    bool wineAvailable() const { return m_wineAvailable; }
    bool bottlesAvailable() const { return m_bottlesAvailable; }
    bool flatpakAvailable() const { return m_flatpakAvailable; }
    bool externalPanel() const { return m_externalPanel; }

    QString distroName() const { return m_distroName; }
    QString kernelVersion() const { return m_kernelVersion; }
    QString cpuModel() const { return m_cpuModel; }
    int cpuThreads() const { return m_cpuThreads; }
    bool batteryAvailable() const { return m_batteryAvailable; }
    int batteryPercent() const { return m_batteryPercent; }
    bool charging() const { return m_charging; }

    Q_INVOKABLE void setProfile(const QString &profile);
    Q_INVOKABLE void applyRecommendedProfile();
    Q_INVOKABLE void setWorkspace(const QString &workspace);
    Q_INVOKABLE void setStudyLayout(const QString &layout);
    Q_INVOKABLE void openFiles();
    Q_INVOKABLE void openBrowser();
    Q_INVOKABLE void openTerminal();
    Q_INVOKABLE void openAndroid();
    Q_INVOKABLE void openWindowsManager();
    Q_INVOKABLE void powerOff();
    Q_INVOKABLE void reboot();

signals:
    void statsChanged();
    void profileChanged();
    void workspaceChanged();
    void studyLayoutChanged();
    void statusChanged();

private slots:
    void refreshStats();

private:
    void detectCapabilities();
    void detectStaticSystemInfo();
    void refreshBattery();
    void updateStatus(const QString &text);
    static bool startFirstAvailable(const QStringList &commands, const QStringList &arguments = {});

    QTimer m_timer;
    int m_cpuUsage = 0;
    int m_memoryUsage = 0;
    double m_totalMemoryGb = 0.0;
    int m_diskUsage = 0;
    QString m_profile;
    QString m_workspace = QStringLiteral("Estudio");
    QString m_studyLayout = QStringLiteral("PDF + NotCan");
    QString m_statusText = QStringLiteral("MurSchol listo");
    bool m_waydroidAvailable = false;
    bool m_wineAvailable = false;
    bool m_bottlesAvailable = false;
    bool m_flatpakAvailable = false;
    bool m_externalPanel = false;
    QString m_distroName = QStringLiteral("Linux");
    QString m_kernelVersion;
    QString m_cpuModel = QStringLiteral("CPU desconocida");
    int m_cpuThreads = 1;
    bool m_batteryAvailable = false;
    int m_batteryPercent = -1;
    bool m_charging = false;
    quint64 m_lastCpuTotal = 0;
    quint64 m_lastCpuIdle = 0;
};
