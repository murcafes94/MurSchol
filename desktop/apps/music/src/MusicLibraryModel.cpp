#include "MusicLibraryModel.h"

#include <QDesktopServices>
#include <QDir>
#include <QDirIterator>
#include <QFile>
#include <QFileInfo>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QProcess>
#include <QRegularExpression>
#include <QSaveFile>
#include <QStandardPaths>
#include <QUrl>
#include <QUrlQuery>
#include <QtConcurrent>

#ifdef MURSCHOL_HAVE_TAGLIB
#include <taglib/audioproperties.h>
#include <taglib/fileref.h>
#include <taglib/tag.h>
#endif

#include <algorithm>

namespace {
QString unknownArtist()
{
    return QStringLiteral("Artista desconocido");
}

QString cleanTagString(const QString &value)
{
    return value.trimmed();
}

QNetworkRequest lyricsRequest(const QUrl &url)
{
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::UserAgentHeader,
                      QStringLiteral("MurScholMusic/0.2 (+https://github.com/murcafes94/MurSchol)"));
    request.setRawHeader("Accept", "application/json");
    return request;
}
}

MusicLibraryModel::MusicLibraryModel(QObject *parent)
    : QAbstractListModel(parent)
{
    loadState();

    connect(&m_watcher, &QFutureWatcher<QVector<Track>>::finished, this, [this] {
        m_allTracks = m_watcher.result();
        m_scanning = false;
        emit scanningChanged();
        rebuildVisible();
        emit queueChanged();
        emit playlistItemsChanged();
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
    case YearRole: return track.year;
    case GenreRole: return track.genre;
    case DurationRole: return track.durationSeconds;
    case DurationTextRole: return durationText(track.durationSeconds);
    case TrackNumberRole: return track.trackNumber;
    case CoverUrlRole: return track.coverUrl;
    case FavoriteRole: return m_favorites.contains(track.path);
    case HasLocalLyricsRole: return !track.localLyricsPath.isEmpty();
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
        { FormatRole, "format" },
        { YearRole, "year" },
        { GenreRole, "genre" },
        { DurationRole, "duration" },
        { DurationTextRole, "durationText" },
        { TrackNumberRole, "trackNumber" },
        { CoverUrlRole, "coverUrl" },
        { FavoriteRole, "favorite" },
        { HasLocalLyricsRole, "hasLocalLyrics" }
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

void MusicLibraryModel::setFavoritesOnly(bool value)
{
    if (m_favoritesOnly == value)
        return;
    m_favoritesOnly = value;
    emit favoritesOnlyChanged();
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

    const Track &track = m_visibleTracks.at(index);
    setCurrentTrack(track);
    return launchTrack(track);
}

bool MusicLibraryModel::playPath(const QString &path)
{
    if (const Track *track = trackByPath(path)) {
        setCurrentTrack(*track);
        return launchTrack(*track);
    }

    const QFileInfo info(path);
    if (!info.exists() || !info.isFile() || !supportedAudio(path)) {
        emit errorOccurred(QStringLiteral("La canción ya no está disponible"));
        return false;
    }

    const Track track = trackFromFile(path);
    setCurrentTrack(track);
    return launchTrack(track);
}

void MusicLibraryModel::selectTrack(int index)
{
    if (index < 0 || index >= m_visibleTracks.size())
        return;
    setCurrentTrack(m_visibleTracks.at(index));
}

void MusicLibraryModel::toggleFavorite(int index)
{
    if (index < 0 || index >= m_visibleTracks.size())
        return;

    const QString path = m_visibleTracks.at(index).path;
    if (m_favorites.contains(path))
        m_favorites.remove(path);
    else
        m_favorites.insert(path);

    saveState();
    emit favoritesChanged();

    if (m_favoritesOnly) {
        rebuildVisible();
    } else {
        const QModelIndex changed = this->index(index, 0);
        emit dataChanged(changed, changed, { FavoriteRole });
    }
}

void MusicLibraryModel::addToQueue(int index)
{
    if (index < 0 || index >= m_visibleTracks.size())
        return;

    m_queue.append(m_visibleTracks.at(index).path);
    saveState();
    emit queueChanged();
    emit statusChanged(QStringLiteral("Añadida a la cola"));
}

bool MusicLibraryModel::playQueueItem(int queueIndex)
{
    if (queueIndex < 0 || queueIndex >= m_queue.size())
        return false;
    return playPath(m_queue.at(queueIndex));
}

void MusicLibraryModel::removeQueueItem(int queueIndex)
{
    if (queueIndex < 0 || queueIndex >= m_queue.size())
        return;
    m_queue.removeAt(queueIndex);
    saveState();
    emit queueChanged();
}

void MusicLibraryModel::clearQueue()
{
    if (m_queue.isEmpty())
        return;
    m_queue.clear();
    saveState();
    emit queueChanged();
}

QVariantList MusicLibraryModel::queueItems() const
{
    QVariantList items;
    items.reserve(m_queue.size());
    for (const QString &path : m_queue) {
        if (const Track *track = trackByPath(path)) {
            items.append(trackToVariant(*track));
        } else {
            QVariantMap item;
            item.insert(QStringLiteral("title"), QFileInfo(path).completeBaseName());
            item.insert(QStringLiteral("artist"), unknownArtist());
            item.insert(QStringLiteral("album"), QString());
            item.insert(QStringLiteral("path"), path);
            item.insert(QStringLiteral("coverUrl"), QString());
            item.insert(QStringLiteral("durationText"), QStringLiteral("--:--"));
            item.insert(QStringLiteral("missing"), true);
            items.append(item);
        }
    }
    return items;
}

QStringList MusicLibraryModel::playlists() const
{
    QStringList names = m_playlists.keys();
    names.sort(Qt::CaseInsensitive);
    return names;
}

void MusicLibraryModel::setSelectedPlaylist(const QString &name)
{
    const QString normalized = name.trimmed();
    if (!normalized.isEmpty() && !m_playlists.contains(normalized))
        return;
    if (m_selectedPlaylist == normalized)
        return;

    m_selectedPlaylist = normalized;
    emit selectedPlaylistChanged();
    emit playlistItemsChanged();
}

QVariantList MusicLibraryModel::selectedPlaylistItems() const
{
    QVariantList items;
    const QStringList paths = m_playlists.value(m_selectedPlaylist);
    items.reserve(paths.size());
    for (const QString &path : paths) {
        if (const Track *track = trackByPath(path)) {
            items.append(trackToVariant(*track));
        } else {
            QVariantMap item;
            item.insert(QStringLiteral("title"), QFileInfo(path).completeBaseName());
            item.insert(QStringLiteral("artist"), unknownArtist());
            item.insert(QStringLiteral("album"), QString());
            item.insert(QStringLiteral("path"), path);
            item.insert(QStringLiteral("coverUrl"), QString());
            item.insert(QStringLiteral("durationText"), QStringLiteral("--:--"));
            item.insert(QStringLiteral("missing"), true);
            items.append(item);
        }
    }
    return items;
}

bool MusicLibraryModel::createPlaylist(const QString &name)
{
    QString normalized = name.trimmed();
    if (normalized.size() > 80)
        normalized = normalized.left(80).trimmed();
    if (normalized.isEmpty() || m_playlists.contains(normalized))
        return false;

    m_playlists.insert(normalized, {});
    m_selectedPlaylist = normalized;
    saveState();
    emit playlistsChanged();
    emit selectedPlaylistChanged();
    emit playlistItemsChanged();
    emit statusChanged(QStringLiteral("Lista creada: %1").arg(normalized));
    return true;
}

void MusicLibraryModel::deletePlaylist(const QString &name)
{
    if (!m_playlists.remove(name))
        return;

    if (m_selectedPlaylist == name)
        m_selectedPlaylist = playlists().value(0);

    saveState();
    emit playlistsChanged();
    emit selectedPlaylistChanged();
    emit playlistItemsChanged();
}

bool MusicLibraryModel::addToSelectedPlaylist(int index)
{
    if (index < 0 || index >= m_visibleTracks.size() || m_selectedPlaylist.isEmpty())
        return false;
    if (!m_playlists.contains(m_selectedPlaylist))
        return false;

    QStringList &items = m_playlists[m_selectedPlaylist];
    const QString path = m_visibleTracks.at(index).path;
    if (items.contains(path)) {
        emit statusChanged(QStringLiteral("La canción ya está en %1").arg(m_selectedPlaylist));
        return false;
    }

    items.append(path);
    saveState();
    emit playlistItemsChanged();
    emit statusChanged(QStringLiteral("Añadida a %1").arg(m_selectedPlaylist));
    return true;
}

void MusicLibraryModel::removeSelectedPlaylistItem(int itemIndex)
{
    if (!m_playlists.contains(m_selectedPlaylist))
        return;
    QStringList &items = m_playlists[m_selectedPlaylist];
    if (itemIndex < 0 || itemIndex >= items.size())
        return;

    items.removeAt(itemIndex);
    saveState();
    emit playlistItemsChanged();
}

void MusicLibraryModel::requestLyrics(int index)
{
    if (index < 0 || index >= m_visibleTracks.size())
        return;

    const Track track = m_visibleTracks.at(index);
    setCurrentTrack(track);
    if (!loadLocalLyrics(track))
        fetchExactLyrics(track);
}

void MusicLibraryModel::requestCurrentLyrics()
{
    const Track *track = trackByPath(m_currentPath);
    if (!track) {
        if (m_currentPath.isEmpty())
            setLyricsResult(QStringLiteral("Selecciona una canción para ver sus letras."),
                            QStringLiteral("Sin canción seleccionada"), false);
        else
            setLyricsResult(QStringLiteral("La canción seleccionada ya no está en la biblioteca."),
                            QStringLiteral("Archivo no disponible"), false);
        return;
    }

    if (!loadLocalLyrics(*track))
        fetchExactLyrics(*track);
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
        const int albumOrder = QString::localeAwareCompare(a.album, b.album);
        if (albumOrder != 0)
            return albumOrder < 0;
        if (a.trackNumber > 0 && b.trackNumber > 0 && a.trackNumber != b.trackNumber)
            return a.trackNumber < b.trackNumber;
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
    track.coverUrl = coverForFile(path);
    track.localLyricsPath = localLyricsForFile(path);

#ifdef MURSCHOL_HAVE_TAGLIB
    const QByteArray encodedPath = QFile::encodeName(track.path);
    TagLib::FileRef file(encodedPath.constData(), true, TagLib::AudioProperties::Fast);
    if (!file.isNull()) {
        if (const TagLib::Tag *tag = file.tag()) {
            const auto fromTag = [](const TagLib::String &value) {
                const std::string utf8 = value.to8Bit(true);
                return cleanTagString(QString::fromUtf8(utf8.data(), int(utf8.size())));
            };
            track.title = fromTag(tag->title());
            track.artist = fromTag(tag->artist());
            const QString taggedAlbum = fromTag(tag->album());
            if (!taggedAlbum.isEmpty())
                track.album = taggedAlbum;
            track.genre = fromTag(tag->genre());
            track.year = int(tag->year());
            track.trackNumber = int(tag->track());
        }
        if (const TagLib::AudioProperties *properties = file.audioProperties())
            track.durationSeconds = properties->lengthInSeconds();
    }
#endif

    const QString baseName = info.completeBaseName();
    const int separator = baseName.indexOf(QStringLiteral(" - "));
    if (track.title.isEmpty()) {
        if (separator > 0)
            track.title = baseName.mid(separator + 3).trimmed();
        else
            track.title = baseName;
    }
    if (track.artist.isEmpty()) {
        if (separator > 0)
            track.artist = baseName.left(separator).trimmed();
        else
            track.artist = unknownArtist();
    }

    return track;
}

QString MusicLibraryModel::coverForFile(const QString &path)
{
    const QFileInfo info(path);
    const QDir dir = info.dir();
    const QStringList candidates {
        QStringLiteral("cover.jpg"), QStringLiteral("cover.jpeg"), QStringLiteral("cover.png"), QStringLiteral("cover.webp"),
        QStringLiteral("folder.jpg"), QStringLiteral("folder.jpeg"), QStringLiteral("folder.png"),
        QStringLiteral("front.jpg"), QStringLiteral("front.jpeg"), QStringLiteral("front.png"),
        QStringLiteral("album.jpg"), QStringLiteral("album.png")
    };

    for (const QString &candidate : candidates) {
        const QString candidatePath = dir.filePath(candidate);
        if (QFileInfo::exists(candidatePath))
            return QUrl::fromLocalFile(candidatePath).toString();
    }

    return {};
}

QString MusicLibraryModel::localLyricsForFile(const QString &path)
{
    const QFileInfo info(path);
    const QString lower = info.dir().filePath(info.completeBaseName() + QStringLiteral(".lrc"));
    if (QFileInfo::exists(lower))
        return lower;
    const QString upper = info.dir().filePath(info.completeBaseName() + QStringLiteral(".LRC"));
    return QFileInfo::exists(upper) ? upper : QString();
}

QString MusicLibraryModel::durationText(int seconds)
{
    if (seconds <= 0)
        return QStringLiteral("--:--");
    const int minutes = seconds / 60;
    const int remainder = seconds % 60;
    return QStringLiteral("%1:%2").arg(minutes).arg(remainder, 2, 10, QLatin1Char('0'));
}

QString MusicLibraryModel::formatLrcForDisplay(const QString &raw)
{
    static const QRegularExpression timeTag(QStringLiteral("\\[(\\d{1,2}:\\d{2}(?:[\\.:]\\d{1,3})?)\\]"));
    static const QRegularExpression anyTimeTag(QStringLiteral("\\[\\d{1,2}:\\d{2}(?:[\\.:]\\d{1,3})?\\]"));
    static const QRegularExpression metadataTag(QStringLiteral("^\\[[A-Za-z]{1,12}:.*\\]$"));

    QStringList output;
    const QStringList lines = raw.split(QRegularExpression(QStringLiteral("\\r?\\n")));
    output.reserve(lines.size());

    for (QString line : lines) {
        line = line.trimmed();
        if (line.isEmpty() || metadataTag.match(line).hasMatch())
            continue;

        const QRegularExpressionMatch match = timeTag.match(line);
        QString timestamp;
        if (match.hasMatch())
            timestamp = match.captured(1).replace(QLatin1Char('.'), QLatin1Char(':'));

        line.remove(anyTimeTag);
        line = line.trimmed();
        if (line.isEmpty())
            continue;

        output.append(timestamp.isEmpty() ? line : QStringLiteral("%1  %2").arg(timestamp, line));
    }

    return output.join(QLatin1Char('\n'));
}

void MusicLibraryModel::rebuildVisible()
{
    beginResetModel();
    m_visibleTracks.clear();

    const QString needle = m_query.trimmed();
    for (const Track &track : std::as_const(m_allTracks)) {
        if (m_favoritesOnly && !m_favorites.contains(track.path))
            continue;

        if (needle.isEmpty()
            || track.title.contains(needle, Qt::CaseInsensitive)
            || track.artist.contains(needle, Qt::CaseInsensitive)
            || track.album.contains(needle, Qt::CaseInsensitive)
            || track.genre.contains(needle, Qt::CaseInsensitive)) {
            m_visibleTracks.append(track);
        }
    }

    endResetModel();
    emit countChanged();
}

QString MusicLibraryModel::stateFilePath() const
{
    const QString directory = QStandardPaths::writableLocation(QStandardPaths::ConfigLocation)
                              + QStringLiteral("/murschol");
    QDir().mkpath(directory);
    return directory + QStringLiteral("/music-state.json");
}

void MusicLibraryModel::loadState()
{
    QFile file(stateFilePath());
    if (!file.open(QIODevice::ReadOnly))
        return;

    QJsonParseError error;
    const QJsonDocument document = QJsonDocument::fromJson(file.readAll(), &error);
    if (error.error != QJsonParseError::NoError || !document.isObject())
        return;

    const QJsonObject root = document.object();
    for (const QJsonValue &value : root.value(QStringLiteral("favorites")).toArray()) {
        if (value.isString() && !value.toString().isEmpty())
            m_favorites.insert(value.toString());
    }
    for (const QJsonValue &value : root.value(QStringLiteral("queue")).toArray()) {
        if (value.isString() && !value.toString().isEmpty())
            m_queue.append(value.toString());
    }

    const QJsonObject playlistsObject = root.value(QStringLiteral("playlists")).toObject();
    for (auto it = playlistsObject.constBegin(); it != playlistsObject.constEnd(); ++it) {
        QStringList paths;
        for (const QJsonValue &value : it.value().toArray()) {
            if (value.isString() && !value.toString().isEmpty())
                paths.append(value.toString());
        }
        m_playlists.insert(it.key(), paths);
    }

    m_selectedPlaylist = root.value(QStringLiteral("selectedPlaylist")).toString();
    if (!m_selectedPlaylist.isEmpty() && !m_playlists.contains(m_selectedPlaylist))
        m_selectedPlaylist.clear();
    if (m_selectedPlaylist.isEmpty() && !m_playlists.isEmpty())
        m_selectedPlaylist = playlists().constFirst();
}

void MusicLibraryModel::saveState() const
{
    QJsonObject root;
    QJsonArray favorites;
    QStringList favoritePaths = m_favorites.values();
    favoritePaths.sort(Qt::CaseInsensitive);
    for (const QString &path : favoritePaths)
        favorites.append(path);
    root.insert(QStringLiteral("favorites"), favorites);

    QJsonArray queue;
    for (const QString &path : m_queue)
        queue.append(path);
    root.insert(QStringLiteral("queue"), queue);

    QJsonObject playlistsObject;
    for (auto it = m_playlists.constBegin(); it != m_playlists.constEnd(); ++it) {
        QJsonArray paths;
        for (const QString &path : it.value())
            paths.append(path);
        playlistsObject.insert(it.key(), paths);
    }
    root.insert(QStringLiteral("playlists"), playlistsObject);
    root.insert(QStringLiteral("selectedPlaylist"), m_selectedPlaylist);

    QSaveFile file(stateFilePath());
    if (!file.open(QIODevice::WriteOnly))
        return;
    file.write(QJsonDocument(root).toJson(QJsonDocument::Indented));
    file.commit();
}

const MusicLibraryModel::Track *MusicLibraryModel::trackByPath(const QString &path) const
{
    for (const Track &track : m_allTracks) {
        if (track.path == path)
            return &track;
    }
    return nullptr;
}

QVariantMap MusicLibraryModel::trackToVariant(const Track &track) const
{
    QVariantMap item;
    item.insert(QStringLiteral("title"), track.title);
    item.insert(QStringLiteral("artist"), track.artist);
    item.insert(QStringLiteral("album"), track.album);
    item.insert(QStringLiteral("path"), track.path);
    item.insert(QStringLiteral("format"), track.format);
    item.insert(QStringLiteral("genre"), track.genre);
    item.insert(QStringLiteral("year"), track.year);
    item.insert(QStringLiteral("duration"), track.durationSeconds);
    item.insert(QStringLiteral("durationText"), durationText(track.durationSeconds));
    item.insert(QStringLiteral("trackNumber"), track.trackNumber);
    item.insert(QStringLiteral("coverUrl"), track.coverUrl);
    item.insert(QStringLiteral("favorite"), m_favorites.contains(track.path));
    item.insert(QStringLiteral("hasLocalLyrics"), !track.localLyricsPath.isEmpty());
    item.insert(QStringLiteral("missing"), false);
    return item;
}

void MusicLibraryModel::setCurrentTrack(const Track &track)
{
    const bool changed = m_currentPath != track.path
                         || m_currentTitle != track.title
                         || m_currentArtist != track.artist
                         || m_currentAlbum != track.album
                         || m_currentCoverUrl != track.coverUrl;

    m_currentTitle = track.title;
    m_currentArtist = track.artist;
    m_currentAlbum = track.album;
    m_currentPath = track.path;
    m_currentCoverUrl = track.coverUrl;

    if (changed) {
        if (!track.localLyricsPath.isEmpty())
            loadLocalLyrics(track);
        else
            setLyricsResult(QStringLiteral("Pulsa “Buscar letras” para consultar LRCLIB."),
                            QStringLiteral("Sin archivo .lrc local"), false);
        emit currentTrackChanged();
    }
}

bool MusicLibraryModel::launchTrack(const Track &track)
{
    const QString mediaExecutable = QStandardPaths::findExecutable(QStringLiteral("murschol-media"));
    if (!mediaExecutable.isEmpty() && QProcess::startDetached(mediaExecutable, { track.path })) {
        emit statusChanged(QStringLiteral("Reproduciendo en MurSchol Media"));
        return true;
    }

    const bool opened = QDesktopServices::openUrl(QUrl::fromLocalFile(track.path));
    if (!opened)
        emit errorOccurred(QStringLiteral("No se pudo abrir la canción"));
    return opened;
}

bool MusicLibraryModel::loadLocalLyrics(const Track &track)
{
    if (track.localLyricsPath.isEmpty())
        return false;

    QFile file(track.localLyricsPath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return false;

    const QString raw = QString::fromUtf8(file.readAll());
    const QString formatted = formatLrcForDisplay(raw);
    setLyricsResult(formatted.isEmpty() ? raw.trimmed() : formatted,
                    QStringLiteral("Archivo .lrc local"), true);
    return true;
}

void MusicLibraryModel::fetchExactLyrics(const Track &track)
{
    if (track.title.isEmpty())
        return;

    if (track.durationSeconds <= 0 || track.artist == unknownArtist()) {
        fetchSearchLyrics(track);
        return;
    }

    setLyricsLoading(true);
    setLyricsResult(QStringLiteral("Buscando letras…"), QStringLiteral("LRCLIB"), false);

    QUrl url(QStringLiteral("https://lrclib.net/api/get"));
    QUrlQuery query;
    query.addQueryItem(QStringLiteral("track_name"), track.title);
    query.addQueryItem(QStringLiteral("artist_name"), track.artist);
    if (!track.album.isEmpty())
        query.addQueryItem(QStringLiteral("album_name"), track.album);
    query.addQueryItem(QStringLiteral("duration"), QString::number(track.durationSeconds));
    url.setQuery(query);

    QNetworkReply *reply = m_network.get(lyricsRequest(url));
    connect(reply, &QNetworkReply::finished, this, [this, reply, track] {
        const int status = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
        const QByteArray body = reply->readAll();
        reply->deleteLater();

        if (m_currentPath != track.path)
            return;

        if (status == 200) {
            const QJsonDocument document = QJsonDocument::fromJson(body);
            if (document.isObject()) {
                setLyricsLoading(false);
                applyLyricsObject(document.object().toVariantMap(), track, QStringLiteral("LRCLIB"));
                return;
            }
        }

        if (status == 404 || status == 400) {
            setLyricsLoading(false);
            fetchSearchLyrics(track);
            return;
        }

        setLyricsLoading(false);
        setLyricsResult(QStringLiteral("No se pudieron consultar las letras. Comprueba la conexión e inténtalo de nuevo."),
                        QStringLiteral("LRCLIB no disponible"), false);
    });
}

void MusicLibraryModel::fetchSearchLyrics(const Track &track)
{
    setLyricsLoading(true);
    setLyricsResult(QStringLiteral("Buscando letras…"), QStringLiteral("LRCLIB"), false);

    QUrl url(QStringLiteral("https://lrclib.net/api/search"));
    QUrlQuery query;
    if (track.artist != unknownArtist()) {
        query.addQueryItem(QStringLiteral("track_name"), track.title);
        query.addQueryItem(QStringLiteral("artist_name"), track.artist);
    } else {
        query.addQueryItem(QStringLiteral("q"), track.title);
    }
    url.setQuery(query);

    QNetworkReply *reply = m_network.get(lyricsRequest(url));
    connect(reply, &QNetworkReply::finished, this, [this, reply, track] {
        const int status = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
        const QByteArray body = reply->readAll();
        reply->deleteLater();

        if (m_currentPath != track.path)
            return;

        setLyricsLoading(false);
        if (status != 200) {
            setLyricsResult(QStringLiteral("No se pudieron consultar las letras."),
                            QStringLiteral("LRCLIB no disponible"), false);
            return;
        }

        const QJsonDocument document = QJsonDocument::fromJson(body);
        if (!document.isArray() || document.array().isEmpty()) {
            setLyricsResult(QStringLiteral("No encontramos letras para esta canción."),
                            QStringLiteral("Sin coincidencias en LRCLIB"), false);
            return;
        }

        for (const QJsonValue &value : document.array()) {
            if (!value.isObject())
                continue;
            const QVariantMap object = value.toObject().toVariantMap();
            if (!object.value(QStringLiteral("syncedLyrics")).toString().trimmed().isEmpty()
                || !object.value(QStringLiteral("plainLyrics")).toString().trimmed().isEmpty()
                || object.value(QStringLiteral("instrumental")).toBool()) {
                applyLyricsObject(object, track, QStringLiteral("LRCLIB · búsqueda"));
                return;
            }
        }

        setLyricsResult(QStringLiteral("No encontramos letras utilizables para esta canción."),
                        QStringLiteral("Sin coincidencias en LRCLIB"), false);
    });
}

void MusicLibraryModel::applyLyricsObject(const QVariantMap &object, const Track &track, const QString &sourcePrefix)
{
    if (m_currentPath != track.path)
        return;

    if (object.value(QStringLiteral("instrumental")).toBool()) {
        setLyricsResult(QStringLiteral("Pista instrumental"), sourcePrefix, false);
        return;
    }

    const QString synced = object.value(QStringLiteral("syncedLyrics")).toString().trimmed();
    if (!synced.isEmpty()) {
        setLyricsResult(formatLrcForDisplay(synced), sourcePrefix + QStringLiteral(" · LRC sincronizado"), true);
        return;
    }

    const QString plain = object.value(QStringLiteral("plainLyrics")).toString().trimmed();
    if (!plain.isEmpty()) {
        setLyricsResult(plain, sourcePrefix, false);
        return;
    }

    setLyricsResult(QStringLiteral("No encontramos letras para esta canción."),
                    QStringLiteral("Sin letras"), false);
}

void MusicLibraryModel::setLyricsLoading(bool value)
{
    if (m_lyricsLoading == value)
        return;
    m_lyricsLoading = value;
    emit lyricsLoadingChanged();
}

void MusicLibraryModel::setLyricsResult(const QString &text, const QString &source, bool synchronized)
{
    m_lyricsText = text;
    m_lyricsSource = source;
    m_lyricsSynchronized = synchronized;
    emit lyricsChanged();
}
