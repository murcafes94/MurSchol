#include "SoundBackend.h"

#include <QProcess>
#include <QRegularExpression>
#include <QStandardPaths>
#include <QtMath>

namespace {
QString cleanDeviceName(QString value)
{
    value = value.trimmed();
    const int bracket = value.indexOf(QStringLiteral(" ["));
    if (bracket > 0)
        value = value.left(bracket).trimmed();
    return value;
}
}

SoundBackend::SoundBackend(QObject *parent)
    : QObject(parent)
{
    m_available = !QStandardPaths::findExecutable(QStringLiteral("wpctl")).isEmpty();
    refresh();

    m_refreshTimer.setInterval(5000);
    connect(&m_refreshTimer, &QTimer::timeout, this, &SoundBackend::refresh);
    m_refreshTimer.start();
}

QString SoundBackend::runWpctl(const QStringList &arguments, int timeoutMs) const
{
    if (!m_available)
        return {};

    QProcess process;
    process.start(QStringLiteral("wpctl"), arguments);
    if (!process.waitForStarted(300))
        return {};
    if (!process.waitForFinished(timeoutMs)) {
        process.kill();
        process.waitForFinished(200);
        return {};
    }
    if (process.exitStatus() != QProcess::NormalExit || process.exitCode() != 0)
        return {};
    return QString::fromUtf8(process.readAllStandardOutput());
}

bool SoundBackend::runWpctlDetached(const QStringList &arguments) const
{
    if (!m_available)
        return false;
    return QProcess::startDetached(QStringLiteral("wpctl"), arguments);
}

SoundBackend::VolumeState SoundBackend::readVolume(const QString &target) const
{
    VolumeState state;
    const QString output = runWpctl({QStringLiteral("get-volume"), target});
    if (output.isEmpty())
        return state;

    static const QRegularExpression volumeRx(QStringLiteral("Volume:\\s*([0-9]+(?:\\.[0-9]+)?)"));
    const QRegularExpressionMatch match = volumeRx.match(output);
    if (!match.hasMatch())
        return state;

    bool ok = false;
    const double volume = match.captured(1).toDouble(&ok);
    if (!ok)
        return state;

    state.percent = qBound(0, qRound(volume * 100.0), 150);
    state.muted = output.contains(QStringLiteral("[MUTED]"), Qt::CaseInsensitive);
    state.valid = true;
    return state;
}

void SoundBackend::parseStatus(const QString &text)
{
    QVariantList outputs;
    QVariantList inputs;
    QString outputName;
    QString inputName;
    bool inOutputs = false;
    bool inInputs = false;

    const QStringList lines = text.split('\n');
    static const QRegularExpression itemRx(QStringLiteral("(?:^|\\s)(\\*)?\\s*(\\d+)\\.\\s+(.+)$"));

    for (const QString &line : lines) {
        if (line.contains(QStringLiteral("Sinks:"))) {
            inOutputs = true;
            inInputs = false;
            continue;
        }
        if (line.contains(QStringLiteral("Sources:"))) {
            inOutputs = false;
            inInputs = true;
            continue;
        }

        if ((inOutputs || inInputs)
            && (line.contains(QStringLiteral("Sink endpoints:"), Qt::CaseInsensitive)
                || line.contains(QStringLiteral("Source endpoints:"), Qt::CaseInsensitive)
                || line.contains(QStringLiteral("Filters:"), Qt::CaseInsensitive)
                || line.contains(QStringLiteral("Streams:"), Qt::CaseInsensitive)
                || line.contains(QStringLiteral("Video"), Qt::CaseInsensitive)
                || line.contains(QStringLiteral("Settings"), Qt::CaseInsensitive))) {
            inOutputs = false;
            inInputs = false;
            continue;
        }

        if (!inOutputs && !inInputs)
            continue;

        const QRegularExpressionMatch match = itemRx.match(line);
        if (!match.hasMatch())
            continue;

        bool ok = false;
        const int id = match.captured(2).toInt(&ok);
        if (!ok)
            continue;

        const bool isDefault = !match.captured(1).isEmpty();
        const QString name = cleanDeviceName(match.captured(3));
        if (name.isEmpty())
            continue;

        QVariantMap item;
        item.insert(QStringLiteral("id"), id);
        item.insert(QStringLiteral("name"), name);
        item.insert(QStringLiteral("active"), isDefault);

        if (inOutputs) {
            outputs.append(item);
            if (isDefault)
                outputName = name;
        } else {
            inputs.append(item);
            if (isDefault)
                inputName = name;
        }
    }

    m_outputs = outputs;
    m_inputs = inputs;
    if (!outputName.isEmpty())
        m_outputName = outputName;
    else if (!outputs.isEmpty())
        m_outputName = outputs.constFirst().toMap().value(QStringLiteral("name")).toString();

    if (!inputName.isEmpty())
        m_inputName = inputName;
    else if (!inputs.isEmpty())
        m_inputName = inputs.constFirst().toMap().value(QStringLiteral("name")).toString();
}

void SoundBackend::refresh()
{
    const bool availableNow = !QStandardPaths::findExecutable(QStringLiteral("wpctl")).isEmpty();
    m_available = availableNow;
    if (!m_available) {
        m_outputs.clear();
        m_inputs.clear();
        setStatus(QStringLiteral("WirePlumber no está disponible"));
        emit soundChanged();
        return;
    }

    const QString status = runWpctl({QStringLiteral("status")}, 1600);
    if (!status.isEmpty())
        parseStatus(status);

    const VolumeState output = readVolume(QStringLiteral("@DEFAULT_AUDIO_SINK@"));
    if (output.valid) {
        m_outputVolume = output.percent;
        m_outputMuted = output.muted;
    }

    const VolumeState input = readVolume(QStringLiteral("@DEFAULT_AUDIO_SOURCE@"));
    if (input.valid) {
        m_inputVolume = input.percent;
        m_inputMuted = input.muted;
    }

    emit soundChanged();
}

void SoundBackend::setOutputVolume(int percent)
{
    percent = qBound(0, percent, 100);
    const double value = double(percent) / 100.0;
    if (runWpctlDetached({QStringLiteral("set-volume"), QStringLiteral("@DEFAULT_AUDIO_SINK@"), QString::number(value, 'f', 2)})) {
        m_outputVolume = percent;
        emit soundChanged();
        setStatus(QStringLiteral("Volumen de salida: %1%").arg(percent));
    } else {
        setStatus(QStringLiteral("No se pudo cambiar el volumen de salida"));
    }
}

void SoundBackend::setInputVolume(int percent)
{
    percent = qBound(0, percent, 100);
    const double value = double(percent) / 100.0;
    if (runWpctlDetached({QStringLiteral("set-volume"), QStringLiteral("@DEFAULT_AUDIO_SOURCE@"), QString::number(value, 'f', 2)})) {
        m_inputVolume = percent;
        emit soundChanged();
        setStatus(QStringLiteral("Volumen de entrada: %1%").arg(percent));
    } else {
        setStatus(QStringLiteral("No se pudo cambiar el volumen de entrada"));
    }
}

void SoundBackend::setOutputMuted(bool muted)
{
    if (runWpctlDetached({QStringLiteral("set-mute"), QStringLiteral("@DEFAULT_AUDIO_SINK@"), muted ? QStringLiteral("1") : QStringLiteral("0")})) {
        m_outputMuted = muted;
        emit soundChanged();
        setStatus(muted ? QStringLiteral("Salida silenciada") : QStringLiteral("Salida activada"));
    } else {
        setStatus(QStringLiteral("No se pudo cambiar el silencio de salida"));
    }
}

void SoundBackend::setInputMuted(bool muted)
{
    if (runWpctlDetached({QStringLiteral("set-mute"), QStringLiteral("@DEFAULT_AUDIO_SOURCE@"), muted ? QStringLiteral("1") : QStringLiteral("0")})) {
        m_inputMuted = muted;
        emit soundChanged();
        setStatus(muted ? QStringLiteral("Micrófono silenciado") : QStringLiteral("Micrófono activado"));
    } else {
        setStatus(QStringLiteral("No se pudo cambiar el silencio del micrófono"));
    }
}

bool SoundBackend::setDefaultOutput(int id)
{
    if (id <= 0)
        return false;
    const bool ok = runWpctlDetached({QStringLiteral("set-default"), QString::number(id)});
    setStatus(ok ? QStringLiteral("Salida de audio actualizada")
                 : QStringLiteral("No se pudo cambiar la salida de audio"));
    if (ok)
        QTimer::singleShot(250, this, &SoundBackend::refresh);
    return ok;
}

bool SoundBackend::setDefaultInput(int id)
{
    if (id <= 0)
        return false;
    const bool ok = runWpctlDetached({QStringLiteral("set-default"), QString::number(id)});
    setStatus(ok ? QStringLiteral("Entrada de audio actualizada")
                 : QStringLiteral("No se pudo cambiar la entrada de audio"));
    if (ok)
        QTimer::singleShot(250, this, &SoundBackend::refresh);
    return ok;
}

void SoundBackend::setStatus(const QString &text)
{
    if (m_statusText == text)
        return;
    m_statusText = text;
    emit statusChanged();
}
