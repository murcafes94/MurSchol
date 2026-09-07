#pragma once

#include <QObject>
#include <QString>
#include <QVariantList>

class DisplayBackend : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList screens READ screens NOTIFY displayChanged)
    Q_PROPERTY(bool nightLightAvailable READ nightLightAvailable NOTIFY nightLightChanged)
    Q_PROPERTY(bool nightLightEnabled READ nightLightEnabled NOTIFY nightLightChanged)
    Q_PROPERTY(int nightLightTemperature READ nightLightTemperature NOTIFY nightLightChanged)
    Q_PROPERTY(QString statusText READ statusText NOTIFY statusChanged)

public:
    explicit DisplayBackend(QObject *parent = nullptr);

    QVariantList screens() const { return m_screens; }
    bool nightLightAvailable() const { return m_nightLightAvailable; }
    bool nightLightEnabled() const { return m_nightLightEnabled; }
    int nightLightTemperature() const { return m_nightLightTemperature; }
    QString statusText() const { return m_statusText; }

    Q_INVOKABLE void refresh();
    Q_INVOKABLE bool setNightLightEnabled(bool enabled);
    Q_INVOKABLE bool setNightLightTemperature(int kelvin);
    Q_INVOKABLE bool applyNightLightPreset(const QString &preset);

signals:
    void displayChanged();
    void nightLightChanged();
    void statusChanged();

private:
    void refreshScreens();
    void loadPreferences();
    void savePreference(const QString &key, const QVariant &value);
    bool applyNightLight(int kelvin);
    bool resetNightLight();
    void setStatus(const QString &text);

    QVariantList m_screens;
    bool m_nightLightAvailable = false;
    bool m_nightLightEnabled = false;
    int m_nightLightTemperature = 4500;
    QString m_gammastepPath;
    QString m_statusText = QStringLiteral("Pantalla lista");
};
