#pragma once

#include <QObject>
#include <QString>

class CaptureBackend : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString lastCapture READ lastCapture NOTIFY lastCaptureChanged)
    Q_PROPERTY(QString message READ message NOTIFY messageChanged)
    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)

public:
    explicit CaptureBackend(QObject *parent = nullptr);

    QString lastCapture() const { return m_lastCapture; }
    QString message() const { return m_message; }
    bool busy() const { return m_busy; }

    Q_INVOKABLE void captureRegion(int delaySeconds = 0);
    Q_INVOKABLE void captureScreen(int delaySeconds = 0);
    Q_INVOKABLE bool editLast();
    Q_INVOKABLE bool openCaptureFolder();

signals:
    void lastCaptureChanged();
    void messageChanged();
    void busyChanged();
    void captureCompleted(bool success, const QString &path);

private:
    void scheduleCapture(bool region, int delaySeconds);
    void performCapture(bool region);
    QString captureDirectory() const;
    QString nextCapturePath() const;
    bool copyPngToClipboard(const QString &path);
    void notifySaved(const QString &path) const;
    void setBusy(bool busy);
    void setMessage(const QString &message);

    QString m_lastCapture;
    QString m_message;
    bool m_busy = false;
};
