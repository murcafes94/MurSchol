#pragma once

#include <QObject>
#include <QString>
#include <QStringList>
#include <QVariant>

class SettingsBackend : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString theme READ theme WRITE setTheme NOTIFY appearanceChanged)
    Q_PROPERTY(QString accentColor READ accentColor WRITE setAccentColor NOTIFY appearanceChanged)
    Q_PROPERTY(QString animationMode READ animationMode WRITE setAnimationMode NOTIFY appearanceChanged)
    Q_PROPERTY(bool dockAutoHide READ dockAutoHide WRITE setDockAutoHide NOTIFY dockChanged)
    Q_PROPERTY(int dockSize READ dockSize WRITE setDockSize NOTIFY dockChanged)
    Q_PROPERTY(bool dockMagnify READ dockMagnify WRITE setDockMagnify NOTIFY dockChanged)
    Q_PROPERTY(QString profile READ profile WRITE setProfile NOTIFY profileChanged)
    Q_PROPERTY(QString recommendedProfile READ recommendedProfile CONSTANT)
    Q_PROPERTY(QString distroName READ distroName CONSTANT)
    Q_PROPERTY(QString kernelVersion READ kernelVersion CONSTANT)
    Q_PROPERTY(QString cpuModel READ cpuModel CONSTANT)
    Q_PROPERTY(int cpuThreads READ cpuThreads CONSTANT)
    Q_PROPERTY(double totalMemoryGb READ totalMemoryGb CONSTANT)
    Q_PROPERTY(QString storageSummary READ storageSummary CONSTANT)
    Q_PROPERTY(bool networkSettingsAvailable READ networkSettingsAvailable CONSTANT)
    Q_PROPERTY(bool audioSettingsAvailable READ audioSettingsAvailable CONSTANT)
    Q_PROPERTY(bool bluetoothSettingsAvailable READ bluetoothSettingsAvailable CONSTANT)
    Q_PROPERTY(QString statusText READ statusText NOTIFY statusChanged)

public:
    explicit SettingsBackend(QObject *parent = nullptr);

    QString theme() const { return m_theme; }
    QString accentColor() const { return m_accentColor; }
    QString animationMode() const { return m_animationMode; }
    bool dockAutoHide() const { return m_dockAutoHide; }
    int dockSize() const { return m_dockSize; }
    bool dockMagnify() const { return m_dockMagnify; }
    QString profile() const { return m_profile; }
    QString recommendedProfile() const { return m_recommendedProfile; }

    QString distroName() const { return m_distroName; }
    QString kernelVersion() const { return m_kernelVersion; }
    QString cpuModel() const { return m_cpuModel; }
    int cpuThreads() const { return m_cpuThreads; }
    double totalMemoryGb() const { return m_totalMemoryGb; }
    QString storageSummary() const { return m_storageSummary; }

    bool networkSettingsAvailable() const { return m_networkSettingsAvailable; }
    bool audioSettingsAvailable() const { return m_audioSettingsAvailable; }
    bool bluetoothSettingsAvailable() const { return m_bluetoothSettingsAvailable; }
    QString statusText() const { return m_statusText; }

    Q_INVOKABLE void setTheme(const QString &value);
    Q_INVOKABLE void setAccentColor(const QString &value);
    Q_INVOKABLE void setAnimationMode(const QString &value);
    Q_INVOKABLE void setDockAutoHide(bool value);
    Q_INVOKABLE void setDockSize(int value);
    Q_INVOKABLE void setDockMagnify(bool value);
    Q_INVOKABLE void setProfile(const QString &value);

    Q_INVOKABLE bool openNetworkSettings();
    Q_INVOKABLE bool openAudioSettings();
    Q_INVOKABLE bool openBluetoothSettings();
    Q_INVOKABLE QString settingsFilePath() const;

signals:
    void appearanceChanged();
    void dockChanged();
    void profileChanged();
    void statusChanged();

private:
    void ensureStorage();
    void loadPreferences();
    void detectSystem();
    void detectTools();
    void saveValue(const QString &key, const QVariant &value);
    void setStatus(const QString &text);
    static bool startFirstAvailable(const QStringList &commands);

    QString m_theme = QStringLiteral("Automático");
    QString m_accentColor = QStringLiteral("#22d6cf");
    QString m_animationMode = QStringLiteral("Normal");
    bool m_dockAutoHide = true;
    int m_dockSize = 66;
    bool m_dockMagnify = true;
    QString m_profile = QStringLiteral("Normal");
    QString m_recommendedProfile = QStringLiteral("Normal");

    QString m_distroName = QStringLiteral("Linux");
    QString m_kernelVersion;
    QString m_cpuModel = QStringLiteral("CPU desconocida");
    int m_cpuThreads = 1;
    double m_totalMemoryGb = 0.0;
    QString m_storageSummary;

    bool m_networkSettingsAvailable = false;
    bool m_audioSettingsAvailable = false;
    bool m_bluetoothSettingsAvailable = false;
    QString m_statusText = QStringLiteral("Configuración lista");
};
