#include "QuickControlsBackend.h"

#include <QProcess>
#include <QProcessEnvironment>
#include <functional>
#include <memory>
#include <QRegularExpression>
#include <QStandardPaths>

namespace {
// CLI output is a machine interface here, independent of the desktop language.
// Each request has a deadline and runs without blocking the Qt GUI thread.
void readCommand(QObject *owner, const QString &program, const QStringList &arguments,
                 std::function<void(const QString &)> done)
{
    const QString executable = QStandardPaths::findExecutable(program);
    if (executable.isEmpty()) {
        done({});
        return;
    }
    auto *process = new QProcess(owner);
    auto environment = QProcessEnvironment::systemEnvironment();
    environment.insert(QStringLiteral("LC_ALL"), QStringLiteral("C"));
    process->setProcessEnvironment(environment);
    auto completed = std::make_shared<bool>(false);
    auto finish = [process, completed, done](const QString &output) {
        if (*completed)
            return;
        *completed = true;
        done(output);
        process->deleteLater();
    };
    QObject::connect(process, &QProcess::finished, owner,
                     [process, finish](int code, QProcess::ExitStatus status) {
        finish(code == 0 && status == QProcess::NormalExit
                   ? QString::fromUtf8(process->readAllStandardOutput()).trimmed()
                   : QString());
    });
    QObject::connect(process, &QProcess::errorOccurred, owner,
                     [finish](QProcess::ProcessError error) {
        if (error == QProcess::FailedToStart)
            finish({});
    });
    QTimer::singleShot(2000, process, [process] {
        if (process->state() != QProcess::NotRunning)
            process->kill();
    });
    process->start(executable, arguments);
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
    // Timer refreshes and action-triggered refreshes must not overlap.
    if (m_refreshing)
        return;
    m_refreshing = true;
    auto pending = std::make_shared<int>(3);
    auto finished = [this, pending] {
        if (--*pending == 0)
            m_refreshing = false;
    };

    readCommand(this, QStringLiteral("nmcli"),
                {QStringLiteral("-t"), QStringLiteral("-f"), QStringLiteral("WIFI"),
                 QStringLiteral("general")}, [this, finished](const QString &state) {
        const bool available = state == QStringLiteral("enabled") || state == QStringLiteral("disabled");
        const bool enabled = state == QStringLiteral("enabled");
        const QString status = !available ? QStringLiteral("No disponible")
                                         : enabled ? QStringLiteral("Activado") : QStringLiteral("Desactivado");
        if (m_networkAvailable != available || m_wifiEnabled != enabled || m_wifiStatus != status) {
            m_networkAvailable = available;
            m_wifiEnabled = enabled;
            m_wifiStatus = status;
            emit controlsChanged();
        }
        finished();
    });
    readCommand(this, QStringLiteral("wpctl"),
                {QStringLiteral("get-volume"), QStringLiteral("@DEFAULT_AUDIO_SINK@")},
                [this, finished](const QString &audio) {
        static const QRegularExpression pattern(QStringLiteral("Volume:\\s*([0-9.]+)"));
        const auto match = pattern.match(audio);
        bool valid = false;
        const double raw = match.captured(1).toDouble(&valid);
        const bool available = match.hasMatch() && valid;
        const int volume = available ? qBound(0, qRound(raw * 100.0), 100) : 0;
        const bool muted = available && audio.contains(QStringLiteral("[MUTED]"));
        if (m_audioAvailable != available || m_volume != volume || m_muted != muted) {
            m_audioAvailable = available;
            m_volume = volume;
            m_muted = muted;
            emit controlsChanged();
        }
        finished();
    });
    readCommand(this, QStringLiteral("bluetoothctl"), {QStringLiteral("show")},
                [this, finished](const QString &output) {
        const bool available = output.contains(QStringLiteral("Powered:"));
        const bool enabled = available && output.contains(QStringLiteral("Powered: yes"));
        if (m_bluetoothAvailable != available || m_bluetoothEnabled != enabled) {
            m_bluetoothAvailable = available;
            m_bluetoothEnabled = enabled;
            emit controlsChanged();
        }
        finished();
    });
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
