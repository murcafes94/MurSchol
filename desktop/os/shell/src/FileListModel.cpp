#include "FileListModel.h"

#include <algorithm>
#include <utility>

#include <QClipboard>
#include <QDateTime>
#include <QDesktopServices>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QGuiApplication>
#include <QMimeData>
#include <QProcess>
#include <QStorageInfo>
#include <QUrl>
#include <QVariantMap>

FileListModel::FileListModel(QObject *parent)
    : QAbstractListModel(parent)
{
    goHome();
    refreshVolumes();
    refreshClipboardState();

    if (QClipboard *clipboard = QGuiApplication::clipboard()) {
        connect(clipboard, &QClipboard::dataChanged,
                this, &FileListModel::refreshClipboardState);
    }

    m_volumeTimer.setInterval(2500);
    connect(&m_volumeTimer, &QTimer::timeout,
            this, &FileListModel::refreshVolumes);
    m_volumeTimer.start();
}

int FileListModel::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : m_visible.size();
}

QVariant FileListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_visible.size())
        return {};

    const auto &entry = m_visible.at(index.row());
    switch (role) {
    case NameRole: return entry.name;
    case PathRole: return entry.path;
    case IsDirectoryRole: return entry.directory;
    case SizeTextRole: return entry.sizeText;
    case ModifiedTextRole: return entry.modifiedText;
    case IconNameRole: return entry.iconName;
    default: return {};
    }
}

QHash<int, QByteArray> FileListModel::roleNames() const
{
    return {
        {NameRole, "fileName"},
        {PathRole, "filePath"},
        {IsDirectoryRole, "isDirectory"},
        {SizeTextRole, "sizeText"},
        {ModifiedTextRole, "modifiedText"},
        {IconNameRole, "iconName"}
    };
}

bool FileListModel::canGoUp() const
{
    if (m_currentPath.isEmpty())
        return false;
    QDir dir(m_currentPath);
    return dir.cdUp();
}

void FileListModel::setFilter(const QString &filter)
{
    if (m_filter == filter)
        return;
    m_filter = filter;
    emit filterChanged();
    rebuildVisible();
}

QString FileListModel::standardLocation(QStandardPaths::StandardLocation location)
{
    const QString path = QStandardPaths::writableLocation(location);
    return path.isEmpty() ? QDir::homePath() : path;
}

void FileListModel::setPath(const QString &path)
{
    QString resolved = path.trimmed();
    if (resolved.startsWith(QStringLiteral("~")))
        resolved.replace(0, 1, QDir::homePath());

    QFileInfo info(resolved);
    if (!info.exists() || !info.isDir()) {
        emit errorOccurred(QStringLiteral("La carpeta no existe: %1").arg(resolved));
        return;
    }

    const QString canonical = info.canonicalFilePath();
    if (canonical.isEmpty()) {
        emit errorOccurred(QStringLiteral("No se pudo abrir la carpeta"));
        return;
    }

    m_currentPath = canonical;
    m_filter.clear();
    emit currentPathChanged();
    emit filterChanged();
    refresh();
}

void FileListModel::goHome()
{
    setPath(QDir::homePath());
}

void FileListModel::goDocuments()
{
    setPath(standardLocation(QStandardPaths::DocumentsLocation));
}

void FileListModel::goDownloads()
{
    setPath(standardLocation(QStandardPaths::DownloadLocation));
}

void FileListModel::goPictures()
{
    setPath(standardLocation(QStandardPaths::PicturesLocation));
}

void FileListModel::goMusic()
{
    setPath(standardLocation(QStandardPaths::MusicLocation));
}

void FileListModel::goVideos()
{
    setPath(standardLocation(QStandardPaths::MoviesLocation));
}

void FileListModel::goComputer()
{
    setPath(QStringLiteral("/"));
}

void FileListModel::goUp()
{
    QDir dir(m_currentPath);
    if (dir.cdUp())
        setPath(dir.absolutePath());
}

bool FileListModel::activate(int row)
{
    if (row < 0 || row >= m_visible.size())
        return false;

    const auto &entry = m_visible.at(row);
    if (entry.directory) {
        setPath(entry.path);
        return true;
    }

    const bool ok = QDesktopServices::openUrl(QUrl::fromLocalFile(entry.path));
    if (!ok)
        emit errorOccurred(QStringLiteral("No se pudo abrir %1").arg(entry.name));
    return ok;
}

bool FileListModel::validName(const QString &name) const
{
    const QString trimmed = name.trimmed();
    return !trimmed.isEmpty()
           && trimmed != QStringLiteral(".")
           && trimmed != QStringLiteral("..")
           && !trimmed.contains('/');
}

bool FileListModel::createFolder()
{
    QDir dir(m_currentPath);
    if (!dir.exists())
        return false;

    QString base = QStringLiteral("Nueva carpeta");
    QString candidate = base;
    int suffix = 2;
    while (dir.exists(candidate))
        candidate = base + QStringLiteral(" %1").arg(suffix++);
    return createFolderNamed(candidate);
}

bool FileListModel::createFolderNamed(const QString &name)
{
    const QString cleanName = name.trimmed();
    if (!validName(cleanName)) {
        emit errorOccurred(QStringLiteral("El nombre de la carpeta no es válido"));
        return false;
    }

    QDir dir(m_currentPath);
    if (!dir.exists()) {
        emit errorOccurred(QStringLiteral("La carpeta actual ya no existe"));
        return false;
    }
    if (dir.exists(cleanName)) {
        emit errorOccurred(QStringLiteral("Ya existe un elemento llamado %1").arg(cleanName));
        return false;
    }
    if (!dir.mkdir(cleanName)) {
        emit errorOccurred(QStringLiteral("No se pudo crear la carpeta"));
        return false;
    }

    setStatus(QStringLiteral("Carpeta creada"));
    refresh();
    return true;
}

QString FileListModel::entryName(int row) const
{
    if (row < 0 || row >= m_visible.size())
        return {};
    return m_visible.at(row).name;
}

bool FileListModel::renameEntry(int row, const QString &newName)
{
    if (row < 0 || row >= m_visible.size())
        return false;

    const QString cleanName = newName.trimmed();
    if (!validName(cleanName)) {
        emit errorOccurred(QStringLiteral("El nuevo nombre no es válido"));
        return false;
    }

    const auto entry = m_visible.at(row);
    if (entry.name == cleanName)
        return true;

    QDir dir(m_currentPath);
    if (dir.exists(cleanName)) {
        emit errorOccurred(QStringLiteral("Ya existe un elemento llamado %1").arg(cleanName));
        return false;
    }

    if (!dir.rename(entry.name, cleanName)) {
        emit errorOccurred(QStringLiteral("No se pudo renombrar %1").arg(entry.name));
        return false;
    }

    setStatus(QStringLiteral("Elemento renombrado"));
    refresh();
    return true;
}

bool FileListModel::moveToTrash(int row)
{
    if (row < 0 || row >= m_visible.size())
        return false;

    const auto entry = m_visible.at(row);
    QString pathInTrash;
    if (!QFile::moveToTrash(entry.path, &pathInTrash)) {
        emit errorOccurred(QStringLiteral("No se pudo mover %1 a la papelera").arg(entry.name));
        return false;
    }

    setStatus(QStringLiteral("Movido a la papelera"));
    refresh();
    return true;
}

bool FileListModel::copyEntry(int row)
{
    return putEntryOnClipboard(row, false);
}

bool FileListModel::cutEntry(int row)
{
    return putEntryOnClipboard(row, true);
}

bool FileListModel::putEntryOnClipboard(int row, bool move)
{
    if (row < 0 || row >= m_visible.size())
        return false;

    QClipboard *clipboard = QGuiApplication::clipboard();
    if (!clipboard) {
        emit errorOccurred(QStringLiteral("El portapapeles no está disponible"));
        return false;
    }

    const QUrl url = QUrl::fromLocalFile(m_visible.at(row).path);
    auto *mime = new QMimeData;
    mime->setUrls({url});
    mime->setText(m_visible.at(row).path);

    QByteArray gnomeMarker = move ? QByteArrayLiteral("cut\n") : QByteArrayLiteral("copy\n");
    gnomeMarker.append(url.toEncoded());
    mime->setData(QByteArrayLiteral("x-special/gnome-copied-files"), gnomeMarker);
    mime->setData(QByteArrayLiteral("application/x-kde-cutselection"),
                  move ? QByteArrayLiteral("1") : QByteArrayLiteral("0"));

    clipboard->setMimeData(mime, QClipboard::Clipboard);
    setStatus(move ? QStringLiteral("Listo para mover")
                   : QStringLiteral("Copiado al portapapeles"));
    return true;
}

void FileListModel::refreshClipboardState()
{
    bool available = false;
    if (const QClipboard *clipboard = QGuiApplication::clipboard()) {
        const QMimeData *mime = clipboard->mimeData(QClipboard::Clipboard);
        if (mime && mime->hasUrls()) {
            for (const QUrl &url : mime->urls()) {
                if (url.isLocalFile()) {
                    available = true;
                    break;
                }
            }
        }
    }

    if (available == m_canPaste)
        return;
    m_canPaste = available;
    emit clipboardStateChanged();
}

QString FileListModel::uniqueDestinationPath(const QString &sourcePath) const
{
    const QFileInfo sourceInfo(sourcePath);
    QDir destination(m_currentPath);
    QString candidate = destination.filePath(sourceInfo.fileName());
    if (!QFileInfo::exists(candidate))
        return candidate;

    const QString suffix = sourceInfo.isDir() ? QString() : sourceInfo.completeSuffix();
    QString stem;
    if (sourceInfo.isDir() || suffix.isEmpty())
        stem = sourceInfo.fileName();
    else
        stem = sourceInfo.fileName().left(sourceInfo.fileName().size() - suffix.size() - 1);

    for (int number = 2; number < 10000; ++number) {
        const QString fileName = suffix.isEmpty()
            ? QStringLiteral("%1 (%2)").arg(stem).arg(number)
            : QStringLiteral("%1 (%2).%3").arg(stem).arg(number).arg(suffix);
        candidate = destination.filePath(fileName);
        if (!QFileInfo::exists(candidate))
            return candidate;
    }

    return {};
}

bool FileListModel::pasteClipboard()
{
    if (m_fileOperationBusy) {
        emit errorOccurred(QStringLiteral("Ya hay una operación de archivos en curso"));
        return false;
    }

    QClipboard *clipboard = QGuiApplication::clipboard();
    const QMimeData *mime = clipboard ? clipboard->mimeData(QClipboard::Clipboard) : nullptr;
    if (!mime || !mime->hasUrls()) {
        emit errorOccurred(QStringLiteral("No hay archivos para pegar"));
        return false;
    }

    QList<QUrl> localUrls;
    for (const QUrl &url : mime->urls()) {
        if (url.isLocalFile())
            localUrls.append(url);
    }

    if (localUrls.isEmpty()) {
        emit errorOccurred(QStringLiteral("El portapapeles no contiene archivos locales"));
        return false;
    }
    if (localUrls.size() > 1) {
        emit errorOccurred(QStringLiteral("Por seguridad, MurSchol Files pega un elemento por operación"));
        return false;
    }

    const QString sourcePath = QFileInfo(localUrls.constFirst().toLocalFile()).absoluteFilePath();
    const QFileInfo sourceInfo(sourcePath);
    if (!sourceInfo.exists()) {
        emit errorOccurred(QStringLiteral("El elemento del portapapeles ya no existe"));
        return false;
    }

    bool move = mime->data(QByteArrayLiteral("x-special/gnome-copied-files"))
                    .startsWith(QByteArrayLiteral("cut\n"));
    if (!move) {
        move = mime->data(QByteArrayLiteral("application/x-kde-cutselection")).trimmed()
               == QByteArrayLiteral("1");
    }

    const QString currentCanonical = QFileInfo(m_currentPath).canonicalFilePath();
    const QString sourceParentCanonical = sourceInfo.dir().canonicalPath();
    if (move && !currentCanonical.isEmpty() && currentCanonical == sourceParentCanonical) {
        setStatus(QStringLiteral("El elemento ya está en esta carpeta"));
        return true;
    }

    if (sourceInfo.isDir()) {
        const QString sourceCanonical = sourceInfo.canonicalFilePath();
        if (!sourceCanonical.isEmpty()
            && (currentCanonical == sourceCanonical
                || currentCanonical.startsWith(sourceCanonical + QLatin1Char('/')))) {
            emit errorOccurred(QStringLiteral("No se puede copiar una carpeta dentro de sí misma"));
            return false;
        }
    }

    const QString destinationPath = uniqueDestinationPath(sourcePath);
    if (destinationPath.isEmpty()) {
        emit errorOccurred(QStringLiteral("No se pudo elegir un nombre de destino seguro"));
        return false;
    }

    const QString command = move ? QStringLiteral("mv") : QStringLiteral("cp");
    const QString executable = QStandardPaths::findExecutable(command);
    if (executable.isEmpty()) {
        emit errorOccurred(QStringLiteral("Falta la herramienta del sistema para %1 archivos")
                               .arg(move ? QStringLiteral("mover") : QStringLiteral("copiar")));
        return false;
    }

    QStringList arguments;
    if (move) {
        arguments << QStringLiteral("--") << sourcePath << destinationPath;
        setStatus(QStringLiteral("Moviendo…"));
    } else {
        arguments << QStringLiteral("-a") << QStringLiteral("--reflink=auto")
                  << QStringLiteral("--") << sourcePath << destinationPath;
        setStatus(QStringLiteral("Copiando…"));
    }

    return startFileOperation(executable, arguments,
                              move ? QStringLiteral("Elemento movido")
                                   : QStringLiteral("Copia completada"),
                              move);
}

bool FileListModel::startFileOperation(const QString &program,
                                       const QStringList &arguments,
                                       const QString &successMessage,
                                       bool clearClipboardOnSuccess)
{
    if (m_fileOperationBusy)
        return false;

    m_fileOperationBusy = true;
    emit fileOperationBusyChanged();

    auto *process = new QProcess(this);
    connect(process, &QProcess::finished, this,
            [this, process, successMessage, clearClipboardOnSuccess]
            (int exitCode, QProcess::ExitStatus exitStatus) {
        m_fileOperationBusy = false;
        emit fileOperationBusyChanged();

        if (exitStatus == QProcess::NormalExit && exitCode == 0) {
            if (clearClipboardOnSuccess) {
                if (QClipboard *clipboard = QGuiApplication::clipboard())
                    clipboard->clear(QClipboard::Clipboard);
            }
            setStatus(successMessage);
            refresh();
            refreshClipboardState();
        } else {
            QString error = QString::fromUtf8(process->readAllStandardError()).trimmed();
            if (error.isEmpty())
                error = QStringLiteral("La operación de archivos no pudo completarse");
            emit errorOccurred(error.left(260));
        }
        process->deleteLater();
    });

    connect(process, &QProcess::errorOccurred, this,
            [this, process](QProcess::ProcessError error) {
        if (error != QProcess::FailedToStart)
            return;
        m_fileOperationBusy = false;
        emit fileOperationBusyChanged();
        emit errorOccurred(QStringLiteral("No se pudo iniciar la operación de archivos"));
        process->deleteLater();
    });

    process->start(program, arguments);
    return true;
}

void FileListModel::refreshVolumes()
{
    QVariantList result;

    const auto mounted = QStorageInfo::mountedVolumes();
    for (const QStorageInfo &storage : mounted) {
        if (!storage.isValid() || !storage.isReady())
            continue;

        const QString rootPath = QDir::cleanPath(storage.rootPath());
        if (rootPath.isEmpty() || rootPath == QStringLiteral("/"))
            continue;

        const bool userMount = rootPath.startsWith(QStringLiteral("/media/"))
                               || rootPath.startsWith(QStringLiteral("/run/media/"))
                               || rootPath.startsWith(QStringLiteral("/mnt/"))
                               || rootPath.contains(QStringLiteral("/gvfs/"));
        if (!userMount)
            continue;

        const QByteArray fileSystem = storage.fileSystemType().toLower();
        if (fileSystem == QByteArrayLiteral("tmpfs")
            || fileSystem == QByteArrayLiteral("devtmpfs")
            || fileSystem == QByteArrayLiteral("proc")
            || fileSystem == QByteArrayLiteral("sysfs")
            || fileSystem == QByteArrayLiteral("overlay")
            || fileSystem == QByteArrayLiteral("squashfs")) {
            continue;
        }

        const QString device = QString::fromLocal8Bit(storage.device());
        QString name = storage.displayName().trimmed();
        if (name.isEmpty())
            name = QFileInfo(rootPath).fileName();
        if (name.isEmpty())
            name = device.isEmpty() ? QStringLiteral("Unidad") : QFileInfo(device).fileName();

        QVariantMap item;
        item.insert(QStringLiteral("name"), name);
        item.insert(QStringLiteral("path"), rootPath);
        item.insert(QStringLiteral("device"), device);
        item.insert(QStringLiteral("fileSystem"), QString::fromLocal8Bit(fileSystem));
        item.insert(QStringLiteral("sizeText"),
                    storage.bytesAvailable() >= 0
                        ? QStringLiteral("%1 libres").arg(formatBytes(storage.bytesAvailable()))
                        : QStringLiteral("Unidad montada"));
        item.insert(QStringLiteral("canUnmount"),
                    device.startsWith(QStringLiteral("/dev/"))
                        && (rootPath.startsWith(QStringLiteral("/media/"))
                            || rootPath.startsWith(QStringLiteral("/run/media/"))
                            || rootPath.startsWith(QStringLiteral("/mnt/"))));
        result.append(item);
    }

    std::sort(result.begin(), result.end(), [](const QVariant &left, const QVariant &right) {
        return left.toMap().value(QStringLiteral("name")).toString()
                   .localeAwareCompare(right.toMap().value(QStringLiteral("name")).toString()) < 0;
    });

    if (result == m_volumes)
        return;
    m_volumes = result;
    emit volumesChanged();
}

bool FileListModel::openVolume(int index)
{
    if (index < 0 || index >= m_volumes.size())
        return false;

    const QString path = m_volumes.at(index).toMap().value(QStringLiteral("path")).toString();
    if (path.isEmpty())
        return false;
    setPath(path);
    return m_currentPath == QFileInfo(path).canonicalFilePath();
}

bool FileListModel::unmountVolume(int index)
{
    if (index < 0 || index >= m_volumes.size())
        return false;

    const QVariantMap volume = m_volumes.at(index).toMap();
    if (!volume.value(QStringLiteral("canUnmount")).toBool()) {
        emit errorOccurred(QStringLiteral("Esta unidad no se puede desmontar desde MurSchol Files"));
        return false;
    }

    const QString device = volume.value(QStringLiteral("device")).toString();
    const QString mountPath = volume.value(QStringLiteral("path")).toString();
    const QString executable = QStandardPaths::findExecutable(QStringLiteral("udisksctl"));
    if (device.isEmpty() || executable.isEmpty()) {
        emit errorOccurred(QStringLiteral("UDisks no está disponible para desmontar la unidad"));
        return false;
    }

    if (m_currentPath == mountPath || m_currentPath.startsWith(mountPath + QLatin1Char('/')))
        goHome();

    setStatus(QStringLiteral("Desmontando unidad…"));
    auto *process = new QProcess(this);
    connect(process, &QProcess::finished, this,
            [this, process](int exitCode, QProcess::ExitStatus exitStatus) {
        if (exitStatus == QProcess::NormalExit && exitCode == 0) {
            setStatus(QStringLiteral("Unidad desmontada de forma segura"));
            QTimer::singleShot(250, this, &FileListModel::refreshVolumes);
        } else {
            QString error = QString::fromUtf8(process->readAllStandardError()).trimmed();
            if (error.isEmpty())
                error = QStringLiteral("No se pudo desmontar la unidad");
            emit errorOccurred(error.left(260));
        }
        process->deleteLater();
    });
    connect(process, &QProcess::errorOccurred, this,
            [this, process](QProcess::ProcessError error) {
        if (error == QProcess::FailedToStart) {
            emit errorOccurred(QStringLiteral("No se pudo iniciar UDisks"));
            process->deleteLater();
        }
    });
    process->start(executable,
                   {QStringLiteral("unmount"), QStringLiteral("-b"), device});
    return true;
}

QString FileListModel::formatBytes(qint64 bytes)
{
    if (bytes < 0)
        return {};
    if (bytes < 1024)
        return QStringLiteral("%1 B").arg(bytes);
    if (bytes < 1024 * 1024)
        return QStringLiteral("%1 KB").arg(QString::number(double(bytes) / 1024.0, 'f', 1));
    if (bytes < qint64(1024) * 1024 * 1024)
        return QStringLiteral("%1 MB").arg(QString::number(double(bytes) / (1024.0 * 1024.0), 'f', 1));
    return QStringLiteral("%1 GB").arg(QString::number(double(bytes) / (1024.0 * 1024.0 * 1024.0), 'f', 1));
}

QString FileListModel::iconForFile(const QString &path, bool directory)
{
    if (directory)
        return QStringLiteral("folder");

    const QString suffix = QFileInfo(path).suffix().toLower();
    if (suffix == QStringLiteral("pdf"))
        return QStringLiteral("application-pdf");
    if (QStringList{QStringLiteral("png"), QStringLiteral("jpg"), QStringLiteral("jpeg"), QStringLiteral("webp"), QStringLiteral("svg"), QStringLiteral("gif")}.contains(suffix))
        return QStringLiteral("image-x-generic");
    if (QStringList{QStringLiteral("mp3"), QStringLiteral("wav"), QStringLiteral("ogg"), QStringLiteral("flac"), QStringLiteral("m4a")}.contains(suffix))
        return QStringLiteral("audio-x-generic");
    if (QStringList{QStringLiteral("mp4"), QStringLiteral("mkv"), QStringLiteral("webm"), QStringLiteral("avi"), QStringLiteral("mov")}.contains(suffix))
        return QStringLiteral("video-x-generic");
    if (QStringList{QStringLiteral("zip"), QStringLiteral("7z"), QStringLiteral("tar"), QStringLiteral("gz"), QStringLiteral("xz"), QStringLiteral("rar")}.contains(suffix))
        return QStringLiteral("package-x-generic");
    if (QStringList{QStringLiteral("doc"), QStringLiteral("docx"), QStringLiteral("odt")}.contains(suffix))
        return QStringLiteral("x-office-document");
    if (QStringList{QStringLiteral("xls"), QStringLiteral("xlsx"), QStringLiteral("ods")}.contains(suffix))
        return QStringLiteral("x-office-spreadsheet");
    if (QStringList{QStringLiteral("ppt"), QStringLiteral("pptx"), QStringLiteral("odp")}.contains(suffix))
        return QStringLiteral("x-office-presentation");
    return QStringLiteral("text-x-generic");
}

void FileListModel::refresh()
{
    QList<MurScholFileEntry> entries;
    QDir dir(m_currentPath);
    if (!dir.exists()) {
        if (m_currentPath != QDir::homePath())
            goHome();
        return;
    }

    dir.setFilter(QDir::AllEntries | QDir::NoDotAndDotDot | QDir::Readable);
    dir.setSorting(QDir::DirsFirst | QDir::IgnoreCase | QDir::Name);

    const QFileInfoList infos = dir.entryInfoList();
    entries.reserve(infos.size());
    for (const QFileInfo &info : infos) {
        MurScholFileEntry entry;
        entry.name = info.fileName();
        entry.path = info.absoluteFilePath();
        entry.directory = info.isDir();
        entry.sizeText = info.isDir() ? QStringLiteral("Carpeta") : formatBytes(info.size());
        entry.modifiedText = info.lastModified().toString(QStringLiteral("dd MMM yyyy, HH:mm"));
        entry.iconName = iconForFile(entry.path, entry.directory);
        entries.append(entry);
    }

    m_all = entries;
    rebuildVisible();
}

void FileListModel::rebuildVisible()
{
    beginResetModel();
    m_visible.clear();
    for (const auto &entry : std::as_const(m_all)) {
        if (m_filter.isEmpty() || entry.name.contains(m_filter, Qt::CaseInsensitive))
            m_visible.append(entry);
    }
    endResetModel();
    emit countChanged();
}

void FileListModel::setStatus(const QString &text)
{
    if (m_statusText == text)
        return;
    m_statusText = text;
    emit statusChanged();
}
