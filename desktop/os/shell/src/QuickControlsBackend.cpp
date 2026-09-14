#include "QuickControlsBackend.h"

#include <QProcess>
#include <QRegularExpression>
#include <QStandardPaths>

namespace {
QString runOutput(const QString &program, const QStringList &arguments, int timeoutMs = 1400)
{
    const QString executable = QStandardPaths::findExecutable(program);
    if (executable.isEmpty())
        return {};

    QProcess process;
    process.start(executable, arguments);
    if (!process.waitForFinished(timeoutMs)
        || process.exitStatus() != QProcess::NormalExit
        || process.exitCode() != 0) {
        return {};
    }
    return QString::fromUtf8(process.readAllStandardOutput()).trimmed();
}

bool runCommand(const QString &program, const QStringList &arguments, int timeoutMs = 2200)
{
    const QString executable = QStandardPaths::findExecutable(program);
    if (executable.isEmpty())
        return false;

    QProcess process;
    process.start(executable, arguments);
    return process.waitForFinished(timeoutMs)
           && process.exitStatus() == QProcess::NormalExit
           && process.exitCode() == 0;
}

bool startDetachedFirst(const QStringList &programs)
{
    for (const QString &program : programs) {
        const QString executable = QStandardPaths::findExecutable(program);
        if (!executable.isEmpty())
            return QProcess::startDetached(executable);
    }
    return false;
}
}

QuickControlsBackend::QuickControlsBackend(QObject *parent)
    : QObject(parent)
{
    refresh();
    m_refreshTimer.setInterval(2500);
    connect(&m_refreshTimer, &QTimer::timeout, this, &QuickControlsBackend::refresh);
    m_refreshTimer.start();
}

void QuickControlsBackend::refresh()
{
    const bool oldNetworkAvailable = m_networkAvailable;
    const bool oldWifiEnabled = m_wifiEnabled;
    const QString oldWifiStatus = m_wifiStatus;
    const bool oldAudioAvailable = m_audioAvailable;
    const int oldVolume = m_volume;
    const bool oldMuted = m_muted;
    const bool oldBluetoothAvailable = m_bluetoothAvailable;
    const bool oldBluetoothEnabled = m_bluetoothEnabled;

    m_networkAvailable = !QStandardPaths::findExecutable(QStringLiteral("nmcli")).isEmpty();
    if (m_networkAvailable) {
        const QString wifiState = runOutput(QStringLiteral("nmcli"),
                                            {QStringLiteral("-t"), QStringLiteral("-f"),
                                             QStringLiteral("WIFI"), QStringLiteral("general")});
        m_wifiEnabled = wifiState.compare(QStringLiteral("enabled"), Qt::CaseInsensitive) == 0;
        m_wifiStatus = m_wifiEnabled ? QStringLiteral("Activado") : QStringLiteral("Desactivado");
    } else {
        m_wifiEnabled = false;
        m_wifiStatus = QStringLiteral("No disponible");
    }

    m_audioAvailable = !QStandardPaths::findExecutable(QStringLiteral("wpctl")).isEmpty();
    if (m_audioAvailable) {
        const QString audio = runOutput(QStringLiteral("wpctl"),
                                        {QStringLiteral("get-volume"),
                                         QStringLiteral("@DEFAULT_AUDIO_SINK@")});
        static const QRegularExpression volumePattern(QStringLiteral("Volume:\\s*([0-9.]+)"));
        const QRegularExpressionMatch match = volumePattern.match(audio);
        if (match.hasMatch()) {
            bool ok = false;
            const double raw = match.captured(1).toDouble(&ok);
            if (ok)
                m_volume = qBound(0, qRound(raw * 100.0), 100);
        }
        m_muted = audio.contains(QStringLiteral("[MUTED]"), Qt::CaseInsensitive);
    } else {
        m_volume = 0;
        m_muted = false;
    }

    const QString bluetoothctl = QStandardPaths::findExecutable(QStringLiteral("bluetoothctl"));
    m_bluetoothAvailable = !bluetoothctl.isEmpty();
    if (m_bluetoothAvailable) {
        const QString show = runOutput(QStringLiteral("bluetoothctl"), {QStringLiteral("show")});
        // bluetoothctl existe incluso en equipos sin adaptador. Solo exponemos
        // el control si BlueZ devuelve realmente un controlador local.
        m_bluetoothAvailable = show.contains(QStringLiteral("Controller "))
                               || show.contains(QStringLiteral("Powered:"));
        m_bluetoothEnabled = m_bluetoothAvailable
                             && show.contains(QStringLiteral("Powered: yes"), Qt::CaseInsensitive);
    } else {
        m_bluetoothEnabled = false;
    }

    if (oldNetworkAvailable != m_networkAvailable
        || oldWifiEnabled != m_wifiEnabled
        || oldWifiStatus != m_wifiStatus
        || oldAudioAvailable != m_audioAvailable
        || oldVolume != m_volume
        || oldMuted != m_muted
        || oldBluetoothAvailable != m_bluetoothAvailable
        || oldBluetoothEnabled != m_bluetoothEnabled) {
        emit controlsChanged();
    }
}

bool QuickControlsBackend::setWifiEnabled(bool enabled)
{
    if (!m_networkAvailable) {
        setStatus(QStringLiteral("NetworkManager no está disponible"));
        return false;
    }

    const bool ok = runCommand(QStringLiteral("nmcli"),
                               {QStringLiteral("radio"), QStringLiteral("wifi"),
                                enabled ? QStringLiteral("on") : QStringLiteral("off")});
    setStatus(ok ? (enabled ? QStringLiteral("Wi-Fi activado")
                            : QStringLiteral("Wi-Fi desactivado"))
                 : QStringLiteral("No se pudo cambiar el estado del Wi-Fi"));
    if (ok)
        QTimer::singleShot(250, this, &QuickControlsBackend::refresh);
    return ok;
}

bool QuickControlsBackend::setVolume(int percent)
{
    if (!m_audioAvailable) {
        setStatus(QStringLiteral("PipeWire/WirePlumber no está disponible"));
        return false;
    }

    percent = qBound(0, percent, 100);
    const bool ok = runCommand(QStringLiteral("wpctl"),
                               {QStringLiteral("set-volume"), QStringLiteral("-l"),
                                QStringLiteral("1.0"), QStringLiteral("@DEFAULT_AUDIO_SINK@"),
                                QStringLiteral("%1%").arg(percent)});
    setStatus(ok ? QStringLiteral("Volumen: %1%").arg(percent)
                 : QStringLiteral("No se pudo cambiar el volumen"));
    if (ok) {
        m_volume = percent;
        emit controlsChanged();
        QTimer::singleShot(150, this, &QuickControlsBackend::refresh);
    }
    return ok;
}

bool QuickControlsBackend::toggleMute()
{
    if (!m_audioAvailable) {
        setStatus(QStringLiteral("PipeWire/WirePlumber no está disponible"));
        return false;
    }

    const bool ok = runCommand(QStringLiteral("wpctl"),
                               {QStringLiteral("set-mute"),
                                QStringLiteral("@DEFAULT_AUDIO_SINK@"),
                                QStringLiteral("toggle")});
    setStatus(ok ? QStringLiteral("Silencio alternado")
                 : QStringLiteral("No se pudo cambiar el silencio"));
    if (ok)
        QTimer::singleShot(120, this, &QuickControlsBackend::refresh);
    return ok;
}

bool QuickControlsBackend::setBluetoothEnabled(bool enabled)
{
    if (!m_bluetoothAvailable) {
        setStatus(QStringLiteral("No se detectó un adaptador Bluetooth"));
        return false;
    }

    const bool ok = runCommand(QStringLiteral("bluetoothctl"),
                               {QStringLiteral("power"),
                                enabled ? QStringLiteral("on") : QStringLiteral("off")});
    setStatus(ok ? (enabled ? QStringLiteral("Bluetooth activado")
                            : QStringLiteral("Bluetooth desactivado"))
                 : QStringLiteral("No se pudo cambiar Bluetooth"));
    if (ok)
        QTimer::singleShot(250, this, &QuickControlsBackend::refresh);
    return ok;
}

bool QuickControlsBackend::openNetworkSettings()
{
    const bool ok = startDetachedFirst({QStringLiteral("nm-connection-editor")});
    if (!ok)
        setStatus(QStringLiteral("No se encontró el editor de red"));
    return ok;
}

bool QuickControlsBackend::openAudioSettings()
{
    const bool ok = startDetachedFirst({QStringLiteral("pavucontrol")});
    if (!ok)
        setStatus(QStringLiteral("No se encontró el panel de sonido"));
    return ok;
}

bool QuickControlsBackend::openBluetoothSettings()
{
    const bool ok = startDetachedFirst({QStringLiteral("blueman-manager")});
    if (!ok)
        setStatus(QStringLiteral("No se encontró el gestor Bluetooth"));
    return ok;
}

void QuickControlsBackend::setStatus(const QString &text)
{
    if (m_statusText == text)
        return;
    m_statusText = text;
    emit statusChanged();
}
