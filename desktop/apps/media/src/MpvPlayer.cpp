#include "MpvPlayer.h"

#include <QCryptographicHash>
#include <QDir>
#include <QFileInfo>
#include <QMetaObject>
#include <QOpenGLContext>
#include <QOpenGLFramebufferObject>
#include <QOpenGLFramebufferObjectFormat>
#include <QSettings>
#include <QUrl>

#include <mpv/client.h>
#include <mpv/render_gl.h>

namespace {
void *getProcAddress(void *, const char *name)
{
    QOpenGLContext *context = QOpenGLContext::currentContext();
    if (!context)
        return nullptr;
    return reinterpret_cast<void *>(context->getProcAddress(QByteArray(name)));
}

double readDouble(mpv_handle *mpv, const char *name, double fallback)
{
    double value = fallback;
    if (mpv && mpv_get_property(mpv, name, MPV_FORMAT_DOUBLE, &value) >= 0)
        return value;
    return fallback;
}

bool readFlag(mpv_handle *mpv, const char *name, bool fallback)
{
    int value = fallback ? 1 : 0;
    if (mpv && mpv_get_property(mpv, name, MPV_FORMAT_FLAG, &value) >= 0)
        return value != 0;
    return fallback;
}

QString resumeKey(const QString &path)
{
    const QByteArray digest = QCryptographicHash::hash(path.toUtf8(), QCryptographicHash::Sha256).toHex();
    return QStringLiteral("media/resume/") + QString::fromLatin1(digest);
}

class MpvRenderer final : public QQuickFramebufferObject::Renderer
{
public:
    explicit MpvRenderer(MpvPlayer *player)
        : m_player(player)
    {
        if (!m_player || !m_player->mpvHandle())
            return;

        mpv_opengl_init_params glInit { getProcAddress, nullptr };
        mpv_render_param params[] = {
            { MPV_RENDER_PARAM_API_TYPE, const_cast<char *>(MPV_RENDER_API_TYPE_OPENGL) },
            { MPV_RENDER_PARAM_OPENGL_INIT_PARAMS, &glInit },
            { MPV_RENDER_PARAM_INVALID, nullptr }
        };

        if (mpv_render_context_create(&m_context, m_player->mpvHandle(), params) < 0) {
            m_context = nullptr;
            return;
        }

        mpv_render_context_set_update_callback(
            m_context,
            [](void *ctx) {
                auto *player = static_cast<MpvPlayer *>(ctx);
                if (!player)
                    return;
                QMetaObject::invokeMethod(player, [player] { player->update(); }, Qt::QueuedConnection);
            },
            m_player);
    }

    ~MpvRenderer() override
    {
        if (m_context)
            mpv_render_context_free(m_context);
    }

    QOpenGLFramebufferObject *createFramebufferObject(const QSize &size) override
    {
        QOpenGLFramebufferObjectFormat format;
        format.setAttachment(QOpenGLFramebufferObject::CombinedDepthStencil);
        return new QOpenGLFramebufferObject(size, format);
    }

    void render() override
    {
        if (!m_context || !framebufferObject())
            return;

        const auto *fboObject = framebufferObject();
        mpv_opengl_fbo fbo {
            static_cast<int>(fboObject->handle()),
            fboObject->width(),
            fboObject->height(),
            0
        };
        int flipY = 1;
        mpv_render_param params[] = {
            { MPV_RENDER_PARAM_OPENGL_FBO, &fbo },
            { MPV_RENDER_PARAM_FLIP_Y, &flipY },
            { MPV_RENDER_PARAM_INVALID, nullptr }
        };
        mpv_render_context_render(m_context, params);
    }

private:
    MpvPlayer *m_player = nullptr;
    mpv_render_context *m_context = nullptr;
};
} // namespace

MpvPlayer::MpvPlayer(QQuickItem *parent)
    : QQuickFramebufferObject(parent)
{
    m_mpv = mpv_create();
    if (!m_mpv) {
        QMetaObject::invokeMethod(this, [this] { emit errorOccurred(QStringLiteral("No se pudo iniciar el motor multimedia")); }, Qt::QueuedConnection);
        return;
    }

    mpv_set_option_string(m_mpv, "vo", "libmpv");
    mpv_set_option_string(m_mpv, "hwdec", "auto-safe");
    mpv_set_option_string(m_mpv, "idle", "yes");
    mpv_set_option_string(m_mpv, "keep-open", "yes");
    mpv_set_option_string(m_mpv, "terminal", "no");
    mpv_set_option_string(m_mpv, "osc", "no");
    mpv_set_option_string(m_mpv, "input-default-bindings", "no");

    if (mpv_initialize(m_mpv) < 0) {
        mpv_destroy(m_mpv);
        m_mpv = nullptr;
        QMetaObject::invokeMethod(this, [this] { emit errorOccurred(QStringLiteral("libmpv no pudo inicializarse")); }, Qt::QueuedConnection);
        return;
    }

    m_pollTimer.setInterval(250);
    connect(&m_pollTimer, &QTimer::timeout, this, &MpvPlayer::refreshPlaybackState);
    m_pollTimer.start();
}

MpvPlayer::~MpvPlayer()
{
    saveResumePosition();
    if (m_mpv)
        mpv_terminate_destroy(m_mpv);
}

QQuickFramebufferObject::Renderer *MpvPlayer::createRenderer() const
{
    return new MpvRenderer(const_cast<MpvPlayer *>(this));
}

bool MpvPlayer::isSupportedMedia(const QString &path)
{
    static const QStringList extensions {
        QStringLiteral("mp4"), QStringLiteral("mkv"), QStringLiteral("webm"), QStringLiteral("mov"),
        QStringLiteral("avi"), QStringLiteral("m4v"), QStringLiteral("mpeg"), QStringLiteral("mpg"),
        QStringLiteral("ts"), QStringLiteral("m2ts"), QStringLiteral("mp3"), QStringLiteral("flac"),
        QStringLiteral("wav"), QStringLiteral("ogg"), QStringLiteral("oga"), QStringLiteral("opus"),
        QStringLiteral("m4a"), QStringLiteral("aac"), QStringLiteral("wma")
    };
    return extensions.contains(QFileInfo(path).suffix().toLower());
}

bool MpvPlayer::isAudioFile(const QString &path)
{
    static const QStringList extensions {
        QStringLiteral("mp3"), QStringLiteral("flac"), QStringLiteral("wav"), QStringLiteral("ogg"),
        QStringLiteral("oga"), QStringLiteral("opus"), QStringLiteral("m4a"), QStringLiteral("aac"),
        QStringLiteral("wma")
    };
    return extensions.contains(QFileInfo(path).suffix().toLower());
}

bool MpvPlayer::openFile(const QString &pathOrUrl)
{
    QString path = pathOrUrl.trimmed();
    const QUrl url(path);
    if (url.isLocalFile())
        path = url.toLocalFile();

    return loadPath(path, true);
}

bool MpvPlayer::loadPath(const QString &path, bool rebuildPlaylist)
{
    if (!m_mpv)
        return false;

    QFileInfo info(path);
    if (!info.exists() || !info.isFile() || !isSupportedMedia(info.absoluteFilePath())) {
        emit errorOccurred(QStringLiteral("Formato multimedia no compatible o archivo inexistente"));
        return false;
    }

    saveResumePosition();

    m_filePath = info.canonicalFilePath();
    if (m_filePath.isEmpty())
        m_filePath = info.absoluteFilePath();
    m_mediaTitle = info.completeBaseName();
    m_audioOnly = isAudioFile(m_filePath);
    m_duration = 0.0;
    m_position = 0.0;

    if (rebuildPlaylist)
        rebuildFolderPlaylist();

    const double resume = savedResumePosition(m_filePath);
    const QByteArray fileUtf8 = m_filePath.toUtf8();
    QByteArray startOption;
    int result = 0;
    if (resume > 3.0) {
        startOption = QByteArray("start=") + QByteArray::number(resume, 'f', 3);
        const char *command[] = { "loadfile", fileUtf8.constData(), "replace", startOption.constData(), nullptr };
        result = mpv_command(m_mpv, command);
    } else {
        const char *command[] = { "loadfile", fileUtf8.constData(), "replace", nullptr };
        result = mpv_command(m_mpv, command);
    }

    if (result < 0) {
        emit errorOccurred(QStringLiteral("No se pudo reproducir el archivo"));
        return false;
    }

    m_paused = false;
    emit mediaChanged();
    emit playbackChanged();
    return true;
}

void MpvPlayer::rebuildFolderPlaylist()
{
    m_folderPlaylist.clear();
    m_playlistIndex = -1;

    QFileInfo current(m_filePath);
    QDir dir(current.absolutePath());
    const QFileInfoList entries = dir.entryInfoList(QDir::Files | QDir::Readable, QDir::Name | QDir::IgnoreCase);
    for (const QFileInfo &entry : entries) {
        if (isSupportedMedia(entry.absoluteFilePath()))
            m_folderPlaylist.append(entry.absoluteFilePath());
    }

    for (int i = 0; i < m_folderPlaylist.size(); ++i) {
        if (QFileInfo(m_folderPlaylist.at(i)).canonicalFilePath() == current.canonicalFilePath()) {
            m_playlistIndex = i;
            break;
        }
    }
}

bool MpvPlayer::hasNext() const
{
    return m_playlistIndex >= 0 && m_playlistIndex + 1 < m_folderPlaylist.size();
}

bool MpvPlayer::hasPrevious() const
{
    return m_playlistIndex > 0 && m_playlistIndex < m_folderPlaylist.size();
}

void MpvPlayer::openPlaylistIndex(int index)
{
    if (index < 0 || index >= m_folderPlaylist.size())
        return;
    m_playlistIndex = index;
    loadPath(m_folderPlaylist.at(index), false);
    emit mediaChanged();
}

void MpvPlayer::next()
{
    if (hasNext())
        openPlaylistIndex(m_playlistIndex + 1);
}

void MpvPlayer::previous()
{
    if (hasPrevious())
        openPlaylistIndex(m_playlistIndex - 1);
}

void MpvPlayer::togglePause()
{
    if (!m_mpv)
        return;
    int value = m_paused ? 0 : 1;
    if (mpv_set_property(m_mpv, "pause", MPV_FORMAT_FLAG, &value) >= 0) {
        m_paused = value != 0;
        emit playbackChanged();
    }
}

void MpvPlayer::seekRelative(double seconds)
{
    if (!m_mpv)
        return;
    const QByteArray value = QByteArray::number(seconds, 'f', 3);
    const char *command[] = { "seek", value.constData(), "relative", "exact", nullptr };
    mpv_command(m_mpv, command);
}

void MpvPlayer::seekAbsolute(double seconds)
{
    if (!m_mpv)
        return;
    const QByteArray value = QByteArray::number(qMax(0.0, seconds), 'f', 3);
    const char *command[] = { "seek", value.constData(), "absolute", "exact", nullptr };
    mpv_command(m_mpv, command);
}

void MpvPlayer::setVolume(double value)
{
    if (!m_mpv)
        return;
    value = qBound(0.0, value, 130.0);
    if (mpv_set_property(m_mpv, "volume", MPV_FORMAT_DOUBLE, &value) >= 0) {
        m_volume = value;
        emit playbackChanged();
    }
}

void MpvPlayer::setSpeed(double value)
{
    if (!m_mpv)
        return;
    value = qBound(0.25, value, 4.0);
    if (mpv_set_property(m_mpv, "speed", MPV_FORMAT_DOUBLE, &value) >= 0) {
        m_speed = value;
        emit playbackChanged();
    }
}

void MpvPlayer::cycleSubtitles()
{
    if (!m_mpv)
        return;
    const char *command[] = { "cycle", "sid", nullptr };
    mpv_command(m_mpv, command);
}

void MpvPlayer::cycleAudioTrack()
{
    if (!m_mpv)
        return;
    const char *command[] = { "cycle", "aid", nullptr };
    mpv_command(m_mpv, command);
}

void MpvPlayer::refreshPlaybackState()
{
    if (!m_mpv || m_filePath.isEmpty())
        return;

    const double duration = readDouble(m_mpv, "duration", m_duration);
    const double position = readDouble(m_mpv, "time-pos", m_position);
    const double volume = readDouble(m_mpv, "volume", m_volume);
    const double speed = readDouble(m_mpv, "speed", m_speed);
    const bool paused = readFlag(m_mpv, "pause", m_paused);

    const bool changed = !qFuzzyCompare(duration + 1.0, m_duration + 1.0)
                         || !qFuzzyCompare(position + 1.0, m_position + 1.0)
                         || !qFuzzyCompare(volume + 1.0, m_volume + 1.0)
                         || !qFuzzyCompare(speed + 1.0, m_speed + 1.0)
                         || paused != m_paused;

    m_duration = qMax(0.0, duration);
    m_position = qMax(0.0, position);
    m_volume = volume;
    m_speed = speed;
    m_paused = paused;

    if (changed)
        emit playbackChanged();
}

void MpvPlayer::saveResumePosition()
{
    if (m_filePath.isEmpty() || m_duration <= 0.0)
        return;

    QSettings settings;
    const QString key = resumeKey(m_filePath);
    if (m_position > 5.0 && m_position < m_duration - 5.0)
        settings.setValue(key, m_position);
    else if (m_position >= m_duration - 5.0)
        settings.remove(key);
}

double MpvPlayer::savedResumePosition(const QString &path) const
{
    return QSettings().value(resumeKey(path), 0.0).toDouble();
}
