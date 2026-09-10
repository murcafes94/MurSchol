#pragma once

#include <QAbstractListModel>
#include <QFutureWatcher>
#include <QHash>
#include <QNetworkAccessManager>
#include <QSet>
#include <QString>
#include <QStringList>
#include <QVariantList>
#include <QVector>

class QNetworkReply;

class MusicLibraryModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(QString query READ query WRITE setQuery NOTIFY queryChanged)
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(bool scanning READ scanning NOTIFY scanningChanged)
    Q_PROPERTY(bool favoritesOnly READ favoritesOnly WRITE setFavoritesOnly NOTIFY favoritesOnlyChanged)
    Q_PROPERTY(int favoritesCount READ favoritesCount NOTIFY favoritesChanged)

    Q_PROPERTY(QString currentTitle READ currentTitle NOTIFY currentTrackChanged)
    Q_PROPERTY(QString currentArtist READ currentArtist NOTIFY currentTrackChanged)
    Q_PROPERTY(QString currentAlbum READ currentAlbum NOTIFY currentTrackChanged)
    Q_PROPERTY(QString currentPath READ currentPath NOTIFY currentTrackChanged)
    Q_PROPERTY(QString currentCoverUrl READ currentCoverUrl NOTIFY currentTrackChanged)

    Q_PROPERTY(int queueCount READ queueCount NOTIFY queueChanged)
    Q_PROPERTY(QVariantList queueItems READ queueItems NOTIFY queueChanged)

    Q_PROPERTY(QStringList playlists READ playlists NOTIFY playlistsChanged)
    Q_PROPERTY(QString selectedPlaylist READ selectedPlaylist WRITE setSelectedPlaylist NOTIFY selectedPlaylistChanged)
    Q_PROPERTY(QVariantList selectedPlaylistItems READ selectedPlaylistItems NOTIFY playlistItemsChanged)

    Q_PROPERTY(QString lyricsText READ lyricsText NOTIFY lyricsChanged)
    Q_PROPERTY(QString lyricsSource READ lyricsSource NOTIFY lyricsChanged)
    Q_PROPERTY(bool lyricsLoading READ lyricsLoading NOTIFY lyricsLoadingChanged)
    Q_PROPERTY(bool lyricsSynchronized READ lyricsSynchronized NOTIFY lyricsChanged)

public:
    enum Roles {
        TitleRole = Qt::UserRole + 1,
        ArtistRole,
        AlbumRole,
        PathRole,
        FormatRole,
        YearRole,
        GenreRole,
        DurationRole,
        DurationTextRole,
        TrackNumberRole,
        CoverUrlRole,
        FavoriteRole,
        HasLocalLyricsRole
    };

    explicit MusicLibraryModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    QString query() const { return m_query; }
    void setQuery(const QString &query);
    int count() const { return m_visibleTracks.size(); }
    bool scanning() const { return m_scanning; }
    bool favoritesOnly() const { return m_favoritesOnly; }
    void setFavoritesOnly(bool value);
    int favoritesCount() const { return m_favorites.size(); }

    QString currentTitle() const { return m_currentTitle; }
    QString currentArtist() const { return m_currentArtist; }
    QString currentAlbum() const { return m_currentAlbum; }
    QString currentPath() const { return m_currentPath; }
    QString currentCoverUrl() const { return m_currentCoverUrl; }

    int queueCount() const { return m_queue.size(); }
    QVariantList queueItems() const;

    QStringList playlists() const;
    QString selectedPlaylist() const { return m_selectedPlaylist; }
    void setSelectedPlaylist(const QString &name);
    QVariantList selectedPlaylistItems() const;

    QString lyricsText() const { return m_lyricsText; }
    QString lyricsSource() const { return m_lyricsSource; }
    bool lyricsLoading() const { return m_lyricsLoading; }
    bool lyricsSynchronized() const { return m_lyricsSynchronized; }

    Q_INVOKABLE void refresh();
    Q_INVOKABLE bool play(int index);
    Q_INVOKABLE bool playPath(const QString &path);
    Q_INVOKABLE void selectTrack(int index);
    Q_INVOKABLE void toggleFavorite(int index);
    Q_INVOKABLE void addToQueue(int index);
    Q_INVOKABLE bool playQueueItem(int queueIndex);
    Q_INVOKABLE void removeQueueItem(int queueIndex);
    Q_INVOKABLE void clearQueue();

    Q_INVOKABLE bool createPlaylist(const QString &name);
    Q_INVOKABLE void deletePlaylist(const QString &name);
    Q_INVOKABLE bool addToSelectedPlaylist(int index);
    Q_INVOKABLE void removeSelectedPlaylistItem(int itemIndex);

    Q_INVOKABLE void requestLyrics(int index);
    Q_INVOKABLE void requestCurrentLyrics();

signals:
    void queryChanged();
    void countChanged();
    void scanningChanged();
    void favoritesOnlyChanged();
    void favoritesChanged();
    void currentTrackChanged();
    void queueChanged();
    void playlistsChanged();
    void selectedPlaylistChanged();
    void playlistItemsChanged();
    void lyricsChanged();
    void lyricsLoadingChanged();
    void errorOccurred(const QString &message);
    void statusChanged(const QString &message);

private:
    struct Track {
        QString title;
        QString artist;
        QString album;
        QString path;
        QString format;
        QString genre;
        QString coverUrl;
        QString localLyricsPath;
        int year = 0;
        int durationSeconds = 0;
        int trackNumber = 0;
    };

    static QVector<Track> scanMusicFolder();
    static bool supportedAudio(const QString &path);
    static Track trackFromFile(const QString &path);
    static QString coverForFile(const QString &path);
    static QString localLyricsForFile(const QString &path);
    static QString durationText(int seconds);
    static QString formatLrcForDisplay(const QString &raw);

    void rebuildVisible();
    void loadState();
    void saveState() const;
    QString stateFilePath() const;
    const Track *trackByPath(const QString &path) const;
    QVariantMap trackToVariant(const Track &track) const;
    void setCurrentTrack(const Track &track);
    bool launchTrack(const Track &track);
    bool loadLocalLyrics(const Track &track);
    void fetchExactLyrics(const Track &track);
    void fetchSearchLyrics(const Track &track);
    void applyLyricsObject(const QVariantMap &object, const Track &track, const QString &sourcePrefix);
    void setLyricsLoading(bool value);
    void setLyricsResult(const QString &text, const QString &source, bool synchronized);

    QString m_query;
    QVector<Track> m_allTracks;
    QVector<Track> m_visibleTracks;
    QFutureWatcher<QVector<Track>> m_watcher;
    bool m_scanning = false;
    bool m_favoritesOnly = false;

    QSet<QString> m_favorites;
    QStringList m_queue;
    QHash<QString, QStringList> m_playlists;
    QString m_selectedPlaylist;

    QString m_currentTitle;
    QString m_currentArtist;
    QString m_currentAlbum;
    QString m_currentPath;
    QString m_currentCoverUrl;

    QNetworkAccessManager m_network;
    QString m_lyricsText;
    QString m_lyricsSource = QStringLiteral("Sin letras cargadas");
    bool m_lyricsLoading = false;
    bool m_lyricsSynchronized = false;
};
