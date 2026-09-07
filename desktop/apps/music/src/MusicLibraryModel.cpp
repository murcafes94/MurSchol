#include "MusicLibraryModel.h"

#include <QDesktopServices>
#include <QDirIterator>
#include <QFileInfo>
#include <QProcess>
#include <QStandardPaths>
#include <QtConcurrent>

#include <algorithm>

MusicLibraryModel::MusicLibraryModel(QObject *parent)
    : QAbstractListModel(parent)
{
    connect(&m_watcher, &QFutureWatcher<QVector<Track>>::finished, this, [this] {
        m_allTracks = m_watcher.result();
        m_scanning = false;
        emit scanningChanged();
        rebuildVisible();
    });

    refresh();
}

int MusicLibraryModel::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : m_visibleTracks.size();
}

QVariant MusicLibraryModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_visibleTracks.size())
        return {};

    const Track &track = m_visibleTracks.at(index.row());
    switch (role) {
    case TitleRole: return track.title;
    case ArtistRole: return track.artist;
    case AlbumRole: return track.album;
    case PathRole: return track.path;
    case FormatRole: return track.format;
    default: return {};
    }
}

QHash<int, QByteArray> MusicLibraryModel::roleNames() const
{
    return {
        { TitleRole, "title" },
        { ArtistRole, "artist" },
        { AlbumRole, "album" },
        { PathRole, "path" },
        { FormatRole, "format" }
    };
}

void MusicLibraryModel::setQuery(const QString &query)
{
    if (m_query == query)
        return;
    m_query = query;
    emit queryChanged();
    rebuildVisible();
}

void MusicLibraryModel::refresh()
{
    if (m_scanning)
        return;

    m_scanning = true;
    emit scanningChanged();
    m_watcher.setFuture(QtConcurrent::run(&MusicLibraryModel::scanMusicFolder));
}

bool MusicLibraryModel::play(int index)
{
    if (index < 0 || index >= m_visibleTracks.size())
        return false;

    const QString path = m_visibleTracks.at(index).path;
    if (QProcess::startDetached(QStringLiteral("murschol-media"), { path }))
        return true;

    const bool opened = QDesktopServices::openUrl(QUrl::fromLocalFile(path));
    if (!opened)
        emit errorOccurred(QStringLiteral("No se pudo abrir la canción"));
    return opened;
}

QVector<MusicLibraryModel::Track> MusicLibraryModel::scanMusicFolder()
{
    QVector<Track> tracks;
    const QString musicPath = QStandardPaths::writableLocation(QStandardPaths::MusicLocation);
    if (musicPath.isEmpty())
        return tracks;

    QDirIterator iterator(musicPath, QDir::Files | QDir::Readable, QDirIterator::Subdirectories);
    while (iterator.hasNext()) {
        const QString path = iterator.next();
        if (supportedAudio(path))
            tracks.append(trackFromFile(path));
    }

    std::sort(tracks.begin(), tracks.end(), [](const Track &a, const Track &b) {
        const int artistOrder = QString::localeAwareCompare(a.artist, b.artist);
        if (artistOrder != 0)
            return artistOrder < 0;
        return QString::localeAwareCompare(a.title, b.title) < 0;
    });

    return tracks;
}

bool MusicLibraryModel::supportedAudio(const QString &path)
{
    static const QStringList extensions {
        QStringLiteral("mp3"), QStringLiteral("flac"), QStringLiteral("wav"),
        QStringLiteral("ogg"), QStringLiteral("oga"), QStringLiteral("opus"),
        QStringLiteral("m4a"), QStringLiteral("aac"), QStringLiteral("wma")
    };
    return extensions.contains(QFileInfo(path).suffix().toLower());
}

MusicLibraryModel::Track MusicLibraryModel::trackFromFile(const QString &path)
{
    QFileInfo info(path);
    Track track;
    track.path = info.absoluteFilePath();
    track.format = info.suffix().toUpper();
    track.album = info.dir().dirName();

    const QString baseName = info.completeBaseName();
    const int separator = baseName.indexOf(QStringLiteral(" - "));
    if (separator > 0) {
        track.artist = baseName.left(separator).trimmed();
        track.title = baseName.mid(separator + 3).trimmed();
    } else {
        track.artist = QStringLiteral("Artista desconocido");
        track.title = baseName;
    }

    return track;
}

void MusicLibraryModel::rebuildVisible()
{
    beginResetModel();
    m_visibleTracks.clear();

    const QString needle = m_query.trimmed();
    for (const Track &track : std::as_const(m_allTracks)) {
        if (needle.isEmpty()
            || track.title.contains(needle, Qt::CaseInsensitive)
            || track.artist.contains(needle, Qt::CaseInsensitive)
            || track.album.contains(needle, Qt::CaseInsensitive)) {
            m_visibleTracks.append(track);
        }
    }

    endResetModel();
    emit countChanged();
}
