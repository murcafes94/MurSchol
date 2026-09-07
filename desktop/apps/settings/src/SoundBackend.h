#pragma once

#include <QObject>
#include <QTimer>
#include <QVariantList>

class SoundBackend : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool available READ available NOTIFY soundChanged)
    Q_PROPERTY(int outputVolume READ outputVolume NOTIFY soundChanged)
    Q_PROPERTY(bool outputMuted READ outputMuted NOTIFY soundChanged)
    Q_PROPERTY(int inputVolume READ inputVolume NOTIFY soundChanged)
    Q_PROPERTY(bool inputMuted READ inputMuted NOTIFY soundChanged)
    Q_PROPERTY(QString outputName READ outputName NOTIFY soundChanged)
    Q_PROPERTY(QString inputName READ inputName NOTIFY soundChanged)
    Q_PROPERTY(QVariantList outputs READ outputs NOTIFY soundChanged)
    Q_PROPERTY(QVariantList inputs READ inputs NOTIFY soundChanged)
    Q_PROPERTY(QString statusText READ statusText NOTIFY statusChanged)

public:
    explicit SoundBackend(QObject *parent = nullptr);

    bool available() const { return m_available; }
    int outputVolume() const { return m_outputVolume; }
    bool outputMuted() const { return m_outputMuted; }
    int inputVolume() const { return m_inputVolume; }
    bool inputMuted() const { return m_inputMuted; }
    QString outputName() const { return m_outputName; }
    QString inputName() const { return m_inputName; }
    QVariantList outputs() const { return m_outputs; }
    QVariantList inputs() const { return m_inputs; }
    QString statusText() const { return m_statusText; }

    Q_INVOKABLE void refresh();
    Q_INVOKABLE void setOutputVolume(int percent);
    Q_INVOKABLE void setInputVolume(int percent);
    Q_INVOKABLE void setOutputMuted(bool muted);
    Q_INVOKABLE void setInputMuted(bool muted);
    Q_INVOKABLE bool setDefaultOutput(int id);
    Q_INVOKABLE bool setDefaultInput(int id);

signals:
    void soundChanged();
    void statusChanged();

private:
    struct VolumeState {
        int percent = 0;
        bool muted = false;
        bool valid = false;
    };

    QString runWpctl(const QStringList &arguments, int timeoutMs = 1200) const;
    bool runWpctlDetached(const QStringList &arguments) const;
    VolumeState readVolume(const QString &target) const;
    void parseStatus(const QString &text);
    void setStatus(const QString &text);

    QTimer m_refreshTimer;
    bool m_available = false;
    int m_outputVolume = 0;
    bool m_outputMuted = false;
    int m_inputVolume = 0;
    bool m_inputMuted = false;
    QString m_outputName = QStringLiteral("Salida predeterminada");
    QString m_inputName = QStringLiteral("Entrada predeterminada");
    QVariantList m_outputs;
    QVariantList m_inputs;
    QString m_statusText = QStringLiteral("Sonido listo");
};
