#pragma once

#include <QObject>
#include <QString>
#include <QUrl>

class AppManagerBackend : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString selectedFile READ selectedFile NOTIFY selectionChanged)
    Q_PROPERTY(QString fileName READ fileName NOTIFY selectionChanged)
    Q_PROPERTY(QString ecosystem READ ecosystem NOTIFY selectionChanged)
    Q_PROPERTY(QString engine READ engine NOTIFY selectionChanged)
    Q_PROPERTY(QString readiness READ readiness NOTIFY selectionChanged)
    Q_PROPERTY(bool canInstall READ canInstall NOTIFY selectionChanged)
    Q_PROPERTY(QString statusText READ statusText NOTIFY statusChanged)

public:
    explicit AppManagerBackend(QObject *parent = nullptr);

    QString selectedFile() const { return m_selectedFile; }
    QString fileName() const { return m_fileName; }
    QString ecosystem() const { return m_ecosystem; }
    QString engine() const { return m_engine; }
    QString readiness() const { return m_readiness; }
    bool canInstall() const { return m_canInstall; }
    QString statusText() const { return m_statusText; }

    Q_INVOKABLE void selectFile(const QUrl &url);
    Q_INVOKABLE void clear();
    Q_INVOKABLE bool installSelected();

signals:
    void selectionChanged();
    void statusChanged();

private:
    void inspectSelection();
    void updateStatus(const QString &text);
    bool commandAvailable(const QString &command) const;
    bool flatpakBottlesAvailable() const;

    QString m_selectedFile;
    QString m_fileName;
    QString m_ecosystem = QStringLiteral("—");
    QString m_engine = QStringLiteral("—");
    QString m_readiness = QStringLiteral("Selecciona un instalador");
    bool m_canInstall = false;
    QString m_statusText = QStringLiteral("Listo para elegir una aplicación");
};
