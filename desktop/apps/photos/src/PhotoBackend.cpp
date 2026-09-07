#include "PhotoBackend.h"

#include <QDateTime>
#include <QDir>
#include <QFileInfo>
#include <QImageReader>
#include <QUrl>

namespace {
const QStringList kSupportedExtensions = {
    QStringLiteral("*.jpg"), QStringLiteral("*.jpeg"),
    QStringLiteral("*.png"), QStringLiteral("*.gif"),
    QStringLiteral("*.svg"), QStringLiteral("*.webp")
};
}

PhotoBackend::PhotoBackend(QObject *parent)
    : QObject(parent)
{
}

QString PhotoBackend::humanSize(qint64 bytes)
{
    if (bytes < 1024)
        return QStringLiteral("%1 B").arg(bytes);
    if (bytes < 1024 * 1024)
        return QStringLiteral("%1 KB").arg(QString::number(double(bytes) / 1024.0, 'f', 1));
    if (bytes < qint64(1024) * 1024 * 1024)
        return QStringLiteral("%1 MB").arg(QString::number(double(bytes) / (1024.0 * 1024.0), 'f', 1));
    return QStringLiteral("%1 GB").arg(QString::number(double(bytes) / (1024.0 * 1024.0 * 1024.0), 'f', 2));
}

void PhotoBackend::setError(const QString &text)
{
    if (m_errorText == text)
        return;
    m_errorText = text;
    emit errorChanged();
}

bool PhotoBackend::openFile(const QString &pathOrUrl)
{
    QUrl url(pathOrUrl);
    QString path;

    if (url.isLocalFile())
        path = url.toLocalFile();
    else if (url.scheme().isEmpty())
        path = pathOrUrl;

    QFileInfo info(path);
    if (!info.exists() || !info.isFile()) {
        setError(QStringLiteral("No se pudo abrir la imagen."));
        return false;
    }

    QImageReader reader(info.absoluteFilePath());
    const QSize size = reader.size();
    const QByteArray detectedFormat = reader.format();

    m_filePath = info.absoluteFilePath();
    m_sourceUrl = QUrl::fromLocalFile(m_filePath).toString();
    m_fileName = info.fileName();
    m_format = detectedFormat.isEmpty()
        ? info.suffix().toUpper()
        : QString::fromLatin1(detectedFormat).toUpper();
    m_dimensions = size.isValid()
        ? QStringLiteral("%1 × %2 px").arg(size.width()).arg(size.height())
        : QStringLiteral("Vectorial / sin tamaño raster fijo");
    m_fileSizeText = humanSize(info.size());
    m_modifiedText = info.lastModified().toString(QStringLiteral("dd MMM yyyy, HH:mm"));
    m_animated = info.suffix().compare(QStringLiteral("gif"), Qt::CaseInsensitive) == 0;
    m_rotation = 0;
    setError({});
    rebuildFolderList();
    emit photoChanged();
    emit rotationChanged();
    return true;
}

void PhotoBackend::rebuildFolderList()
{
    m_folderImages.clear();
    if (m_filePath.isEmpty())
        return;

    const QFileInfo current(m_filePath);
    QDir dir(current.absolutePath());
    const QFileInfoList entries = dir.entryInfoList(
        kSupportedExtensions,
        QDir::Files | QDir::Readable,
        QDir::Name | QDir::IgnoreCase);

    for (const QFileInfo &entry : entries)
        m_folderImages.append(entry.absoluteFilePath());
}

bool PhotoBackend::openNext()
{
    if (m_folderImages.isEmpty())
        return false;
    int index = m_folderImages.indexOf(m_filePath);
    if (index < 0)
        index = 0;
    else
        index = (index + 1) % m_folderImages.size();
    return openFile(m_folderImages.at(index));
}

bool PhotoBackend::openPrevious()
{
    if (m_folderImages.isEmpty())
        return false;
    int index = m_folderImages.indexOf(m_filePath);
    if (index < 0)
        index = 0;
    else
        index = (index - 1 + m_folderImages.size()) % m_folderImages.size();
    return openFile(m_folderImages.at(index));
}

void PhotoBackend::rotateLeft()
{
    m_rotation = (m_rotation - 90) % 360;
    emit rotationChanged();
}

void PhotoBackend::rotateRight()
{
    m_rotation = (m_rotation + 90) % 360;
    emit rotationChanged();
}

void PhotoBackend::resetRotation()
{
    if (m_rotation == 0)
        return;
    m_rotation = 0;
    emit rotationChanged();
}
