#pragma once

#include <QQuickFramebufferObject>
#include <QStringList>
#include <QTimer>

struct mpv_handle;

class MpvPlayer : public QQuickFramebufferObject
{
    Q_OBJECT
    Q_PROPERTY(QString mediaTitle READ mediaTitle NOTIFY mediaChanged)
    Q_PROPERTY(QString filePath READ filePath NOTIFY mediaChanged)
    Q_PROPERTY(double duration READ duration NOTIFY playbackChanged)
    Q_PROPERTY(double position READ position NOTIFY playbackChanged)
    Q_PROPERTY(bool paused READ paused NOTIFY playbackChanged)
    Q_PROPERTY(double volume READ volume NOTIFY playbackChanged)
    Q_PROPERTY(double speed READ speed NOTIFY playbackChanged)
    Q_PROPERTY(bool audioOnly READ audioOnly NOTIFY mediaChanged)
    Q_PROPERTY(bool hasNext READ hasNext NOTIFY mediaChanged)
    Q_PROPERTY(bool hasPrevious READ hasPrevious NOTIFY mediaChanged)

public:
    explicit MpvPlayer(QQuickItem *parent = nullptr);
    ~MpvPlayer() override;

    Renderer *createRenderer() const override;

    QString mediaTitle() const { return m_mediaTitle; }
    QString filePath() const { return m_filePath; }
    double duration() const { return m_duration; }
    double position() const { return m_position; }
    bool paused() const { return m_paused; }
    double volume() const { return m_volume; }
    double speed() const { return m_speed; }
    bool audioOnly() const { return m_audioOnly; }
    bool hasNext() const;
    bool hasPrevious() const;

    mpv_handle *mpvHandle() const { return m_mpv; }

    Q_INVOKABLE bool openFile(const QString &pathOrUrl);
    Q_INVOKABLE void togglePause();
    Q_INVOKABLE void seekRelative(double seconds);
    Q_INVOKABLE void seekAbsolute(double seconds);
    Q_INVOKABLE void setVolume(double value);
    Q_INVOKABLE void setSpeed(double value);
    Q_INVOKABLE void next();
    Q_INVOKABLE void previous();
    Q_INVOKABLE void cycleSubtitles();
    Q_INVOKABLE void cycleAudioTrack();

signals:
    void mediaChanged();
    void playbackChanged();
    void errorOccurred(const QString &message);

private slots:
    void refreshPlaybackState();

private:
    static bool isSupportedMedia(const QString &path);
    static bool isAudioFile(const QString &path);
    bool loadPath(const QString &path, bool rebuildPlaylist);
    void rebuildFolderPlaylist();
    void openPlaylistIndex(int index);
    void saveResumePosition();
    double savedResumePosition(const QString &path) const;

    mpv_handle *m_mpv = nullptr;
    QTimer m_pollTimer;
    QString m_filePath;
    QString m_mediaTitle;
    QStringList m_folderPlaylist;
    int m_playlistIndex = -1;
    double m_duration = 0.0;
    double m_position = 0.0;
    double m_volume = 100.0;
    double m_speed = 1.0;
    bool m_paused = true;
    bool m_audioOnly = false;
};
