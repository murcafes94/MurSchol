#pragma once

#include <QObject>
#include <QString>
#include <QStringList>

class PhotoBackend : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString sourceUrl READ sourceUrl NOTIFY photoChanged)
    Q_PROPERTY(QString fileName READ fileName NOTIFY photoChanged)
    Q_PROPERTY(QString filePath READ filePath NOTIFY photoChanged)
    Q_PROPERTY(QString format READ format NOTIFY photoChanged)
    Q_PROPERTY(QString dimensions READ dimensions NOTIFY photoChanged)
    Q_PROPERTY(QString fileSizeText READ fileSizeText NOTIFY photoChanged)
    Q_PROPERTY(QString modifiedText READ modifiedText NOTIFY photoChanged)
    Q_PROPERTY(bool animated READ animated NOTIFY photoChanged)
    Q_PROPERTY(int rotation READ rotation NOTIFY rotationChanged)
    Q_PROPERTY(QString errorText READ errorText NOTIFY errorChanged)

public:
    explicit PhotoBackend(QObject *parent = nullptr);

    QString sourceUrl() const { return m_sourceUrl; }
    QString fileName() const { return m_fileName; }
    QString filePath() const { return m_filePath; }
    QString format() const { return m_format; }
    QString dimensions() const { return m_dimensions; }
    QString fileSizeText() const { return m_fileSizeText; }
    QString modifiedText() const { return m_modifiedText; }
    bool animated() const { return m_animated; }
    int rotation() const { return m_rotation; }
    QString errorText() const { return m_errorText; }

    Q_INVOKABLE bool openFile(const QString &pathOrUrl);
    Q_INVOKABLE bool openNext();
    Q_INVOKABLE bool openPrevious();
    Q_INVOKABLE void rotateLeft();
    Q_INVOKABLE void rotateRight();
    Q_INVOKABLE void resetRotation();

signals:
    void photoChanged();
    void rotationChanged();
    void errorChanged();

private:
    static QString humanSize(qint64 bytes);
    void rebuildFolderList();
    void setError(const QString &text);

    QString m_sourceUrl;
    QString m_fileName;
    QString m_filePath;
    QString m_format;
    QString m_dimensions;
    QString m_fileSizeText;
    QString m_modifiedText;
    QStringList m_folderImages;
    bool m_animated = false;
    int m_rotation = 0;
    QString m_errorText;
};
