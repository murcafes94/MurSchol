#pragma once

#include <QAbstractListModel>
#include <QFutureWatcher>
#include <QString>
#include <QVector>

class MusicLibraryModel final : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(QString query READ query WRITE setQuery NOTIFY queryChanged)
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(bool scanning READ scanning NOTIFY scanningChanged)

public:
    enum Roles {
        TitleRole = Qt::UserRole + 1,
        ArtistRole,
        AlbumRole,
        PathRole,
        FormatRole
    };

    explicit MusicLibraryModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    QString query() const { return m_query; }
    void setQuery(const QString &query);
    int count() const { return m_visibleTracks.size(); }
    bool scanning() const { return m_scanning; }

    Q_INVOKABLE void refresh();
    Q_INVOKABLE bool play(int index);

signals:
    void queryChanged();
    void countChanged();
    void scanningChanged();
    void errorOccurred(const QString &message);

private:
    struct Track {
        QString title;
        QString artist;
        QString album;
        QString path;
        QString format;
    };

    static QVector<Track> scanMusicFolder();
    static bool supportedAudio(const QString &path);
    static Track trackFromFile(const QString &path);
    void rebuildVisible();

    QString m_query;
    QVector<Track> m_allTracks;
    QVector<Track> m_visibleTracks;
    QFutureWatcher<QVector<Track>> m_watcher;
    bool m_scanning = false;
};
