#include "CaptureBackend.h"

#include <QDateTime>
#include <QDesktopServices>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QProcess>
#include <QStandardPaths>
#include <QTimer>
#include <QUrl>

CaptureBackend::CaptureBackend(QObject *parent)
    : QObject(parent)
{
}

void CaptureBackend::captureRegion(int delaySeconds)
{
    scheduleCapture(true, delaySeconds);
}

void CaptureBackend::captureScreen(int delaySeconds)
{
    scheduleCapture(false, delaySeconds);
}

void CaptureBackend::scheduleCapture(bool region, int delaySeconds)
{
    if (m_busy)
        return;

    setBusy(true);
    const int delay = qBound(0, delaySeconds, 30);
    if (delay > 0)
        setMessage(QStringLiteral("Capturando en %1 s…").arg(delay));
    else
        setMessage(region ? QStringLiteral("Selecciona el área a capturar")
                          : QStringLiteral("Capturando pantalla…"));

    QTimer::singleShot(delay * 1000, this, [this, region] { performCapture(region); });
}

void CaptureBackend::performCapture(bool region)
{
    const QString grim = QStandardPaths::findExecutable(QStringLiteral("grim"));
    if (grim.isEmpty()) {
        setMessage(QStringLiteral("No se encontró grim"));
        setBusy(false);
        emit captureCompleted(false, {});
        return;
    }

    QString geometry;
    if (region) {
        const QString slurp = QStandardPaths::findExecutable(QStringLiteral("slurp"));
        if (slurp.isEmpty()) {
            setMessage(QStringLiteral("No se encontró slurp"));
            setBusy(false);
            emit captureCompleted(false, {});
            return;
        }

        QProcess selector;
        selector.start(slurp, {});
        if (!selector.waitForStarted(3000) || !selector.waitForFinished(-1)
            || selector.exitStatus() != QProcess::NormalExit || selector.exitCode() != 0) {
            setMessage(QStringLiteral("Captura cancelada"));
            setBusy(false);
            emit captureCompleted(false, {});
            return;
        }
        geometry = QString::fromUtf8(selector.readAllStandardOutput()).trimmed();
        if (geometry.isEmpty()) {
            setMessage(QStringLiteral("Captura cancelada"));
            setBusy(false);
            emit captureCompleted(false, {});
            return;
        }
    }

    const QString path = nextCapturePath();
    QStringList arguments;
    if (region)
        arguments << QStringLiteral("-g") << geometry;
    arguments << path;

    const int result = QProcess::execute(grim, arguments);
    if (result != 0 || !QFileInfo::exists(path)) {
        setMessage(QStringLiteral("No se pudo guardar la captura"));
        setBusy(false);
        emit captureCompleted(false, {});
        return;
    }

    m_lastCapture = path;
    emit lastCaptureChanged();

    const bool copied = copyPngToClipboard(path);
    setMessage(copied ? QStringLiteral("Captura guardada y copiada al portapapeles")
                      : QStringLiteral("Captura guardada"));
    notifySaved(path);
    setBusy(false);
    emit captureCompleted(true, path);
}

QString CaptureBackend::captureDirectory() const
{
    QString pictures = QStandardPaths::writableLocation(QStandardPaths::PicturesLocation);
    if (pictures.isEmpty())
        pictures = QDir::homePath() + QStringLiteral("/Pictures");

    QDir dir(pictures);
    dir.mkpath(QStringLiteral("Capturas de pantalla"));
    return dir.filePath(QStringLiteral("Capturas de pantalla"));
}

QString CaptureBackend::nextCapturePath() const
{
    const QString stamp = QDateTime::currentDateTime().toString(QStringLiteral("yyyy-MM-dd_HH-mm-ss-zzz"));
    return QDir(captureDirectory()).filePath(QStringLiteral("Captura_%1.png").arg(stamp));
}

bool CaptureBackend::copyPngToClipboard(const QString &path)
{
    const QString wlCopy = QStandardPaths::findExecutable(QStringLiteral("wl-copy"));
    if (wlCopy.isEmpty())
        return false;

    QFile file(path);
    if (!file.open(QIODevice::ReadOnly))
        return false;

    QProcess copy;
    copy.start(wlCopy, {QStringLiteral("--type"), QStringLiteral("image/png")});
    if (!copy.waitForStarted(2000))
        return false;

    copy.write(file.readAll());
    copy.closeWriteChannel();
    return copy.waitForFinished(5000) && copy.exitStatus() == QProcess::NormalExit && copy.exitCode() == 0;
}

void CaptureBackend::notifySaved(const QString &path) const
{
    const QString notifySend = QStandardPaths::findExecutable(QStringLiteral("notify-send"));
    if (notifySend.isEmpty())
        return;

    QProcess::startDetached(notifySend,
                            {QStringLiteral("MurSchol Capture"),
                             QStringLiteral("Captura guardada en %1").arg(path)});
}

bool CaptureBackend::editLast()
{
    if (m_lastCapture.isEmpty() || !QFileInfo::exists(m_lastCapture))
        return false;

    const QString photos = QStandardPaths::findExecutable(QStringLiteral("murschol-photos"));
    if (!photos.isEmpty())
        return QProcess::startDetached(photos, {QStringLiteral("--annotate"), m_lastCapture});

    return QDesktopServices::openUrl(QUrl::fromLocalFile(m_lastCapture));
}

bool CaptureBackend::openCaptureFolder()
{
    return QDesktopServices::openUrl(QUrl::fromLocalFile(captureDirectory()));
}

void CaptureBackend::setBusy(bool busy)
{
    if (m_busy == busy)
        return;
    m_busy = busy;
    emit busyChanged();
}

void CaptureBackend::setMessage(const QString &message)
{
    if (m_message == message)
        return;
    m_message = message;
    emit messageChanged();
}
