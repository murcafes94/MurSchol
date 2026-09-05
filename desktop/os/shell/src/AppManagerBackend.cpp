#include "AppManagerBackend.h"

#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QProcess>
#include <QStandardPaths>

AppManagerBackend::AppManagerBackend(QObject *parent)
    : QObject(parent)
{
}

bool AppManagerBackend::commandAvailable(const QString &command) const
{
    return !QStandardPaths::findExecutable(command).isEmpty();
}

bool AppManagerBackend::flatpakBottlesAvailable() const
{
    return QFileInfo::exists(QDir::homePath() + QStringLiteral("/.local/share/flatpak/app/com.usebottles.bottles"))
           || QFileInfo::exists(QStringLiteral("/var/lib/flatpak/app/com.usebottles.bottles"));
}

void AppManagerBackend::selectFile(const QUrl &url)
{
    const QString path = url.isLocalFile() ? url.toLocalFile() : url.toString();
    const QFileInfo info(path);
    if (!info.exists() || !info.isFile()) {
        updateStatus(QStringLiteral("El archivo seleccionado no existe"));
        return;
    }

    m_selectedFile = info.absoluteFilePath();
    m_fileName = info.fileName();
    inspectSelection();
    emit selectionChanged();
}

void AppManagerBackend::clear()
{
    m_selectedFile.clear();
    m_fileName.clear();
    m_ecosystem = QStringLiteral("—");
    m_engine = QStringLiteral("—");
    m_readiness = QStringLiteral("Selecciona un instalador");
    m_canInstall = false;
    updateStatus(QStringLiteral("Listo para elegir una aplicación"));
    emit selectionChanged();
}

void AppManagerBackend::inspectSelection()
{
    m_canInstall = false;
    const QString lower = m_fileName.toLower();

    if (lower.endsWith(QStringLiteral(".apk"))) {
        m_ecosystem = QStringLiteral("Android");
        m_engine = QStringLiteral("Waydroid");
        m_canInstall = commandAvailable(QStringLiteral("waydroid"));
        m_readiness = m_canInstall ? QStringLiteral("Compatible · listo para instalar")
                                   : QStringLiteral("Falta instalar Waydroid");
    } else if (lower.endsWith(QStringLiteral(".exe")) || lower.endsWith(QStringLiteral(".msi"))) {
        m_ecosystem = QStringLiteral("Windows");
        m_engine = QStringLiteral("Wine / Bottles");
        const bool wine = commandAvailable(QStringLiteral("wine"));
        const bool bottles = commandAvailable(QStringLiteral("bottles")) || flatpakBottlesAvailable();
        m_canInstall = wine || bottles;
        m_readiness = m_canInstall ? QStringLiteral("Compatible · se abrirá un entorno aislado")
                                   : QStringLiteral("Falta instalar Wine o Bottles");
    } else if (lower.endsWith(QStringLiteral(".deb"))) {
        m_ecosystem = QStringLiteral("Linux");
        m_engine = QStringLiteral("APT / Debian");
        m_canInstall = commandAvailable(QStringLiteral("apt")) && commandAvailable(QStringLiteral("pkexec"));
        m_readiness = m_canInstall ? QStringLiteral("Nativa · requiere autorización administrativa")
                                   : QStringLiteral("APT o pkexec no están disponibles");
    } else if (lower.endsWith(QStringLiteral(".appimage"))) {
        m_ecosystem = QStringLiteral("Linux");
        m_engine = QStringLiteral("AppImage");
        m_canInstall = true;
        m_readiness = QStringLiteral("Nativa · se ejecutará de forma portátil");
    } else if (lower.endsWith(QStringLiteral(".flatpakref"))) {
        m_ecosystem = QStringLiteral("Linux");
        m_engine = QStringLiteral("Flatpak");
        m_canInstall = commandAvailable(QStringLiteral("flatpak"));
        m_readiness = m_canInstall ? QStringLiteral("Nativa · instalación de usuario")
                                   : QStringLiteral("Flatpak no está instalado");
    } else {
        m_ecosystem = QStringLiteral("Desconocido");
        m_engine = QStringLiteral("—");
        m_readiness = QStringLiteral("Formato no soportado todavía");
    }

    updateStatus(QStringLiteral("Archivo detectado: %1").arg(m_fileName));
}

bool AppManagerBackend::installSelected()
{
    if (m_selectedFile.isEmpty() || !m_canInstall) {
        updateStatus(QStringLiteral("La aplicación no está lista para instalarse"));
        return false;
    }

    const QString lower = m_fileName.toLower();
    bool started = false;

    if (lower.endsWith(QStringLiteral(".apk"))) {
        started = QProcess::startDetached(QStringLiteral("waydroid"),
                                          {QStringLiteral("app"), QStringLiteral("install"), m_selectedFile});
        if (started)
            updateStatus(QStringLiteral("Instalando APK mediante Waydroid…"));
    } else if (lower.endsWith(QStringLiteral(".exe")) || lower.endsWith(QStringLiteral(".msi"))) {
        if (commandAvailable(QStringLiteral("wine"))) {
            QStringList args;
            if (lower.endsWith(QStringLiteral(".msi")))
                args = {QStringLiteral("msiexec"), QStringLiteral("/i"), m_selectedFile};
            else
                args = {m_selectedFile};
            started = QProcess::startDetached(QStringLiteral("wine"), args);
        } else if (commandAvailable(QStringLiteral("bottles"))) {
            started = QProcess::startDetached(QStringLiteral("bottles"), {m_selectedFile});
        } else if (flatpakBottlesAvailable() && commandAvailable(QStringLiteral("flatpak"))) {
            started = QProcess::startDetached(QStringLiteral("flatpak"),
                                              {QStringLiteral("run"), QStringLiteral("com.usebottles.bottles"), m_selectedFile});
        }
        if (started)
            updateStatus(QStringLiteral("Abriendo instalador Windows en la capa compatible…"));
    } else if (lower.endsWith(QStringLiteral(".deb"))) {
        started = QProcess::startDetached(QStringLiteral("pkexec"),
                                          {QStringLiteral("apt"), QStringLiteral("install"), QStringLiteral("-y"), m_selectedFile});
        if (started)
            updateStatus(QStringLiteral("Solicitando autorización para instalar el paquete Debian…"));
    } else if (lower.endsWith(QStringLiteral(".appimage"))) {
        QFile file(m_selectedFile);
        const auto permissions = file.permissions()
                                 | QFileDevice::ExeOwner
                                 | QFileDevice::ReadOwner
                                 | QFileDevice::WriteOwner;
        if (!file.setPermissions(permissions)) {
            updateStatus(QStringLiteral("No se pudo marcar AppImage como ejecutable"));
            return false;
        }
        started = QProcess::startDetached(m_selectedFile, {});
        if (started)
            updateStatus(QStringLiteral("AppImage iniciada"));
    } else if (lower.endsWith(QStringLiteral(".flatpakref"))) {
        started = QProcess::startDetached(QStringLiteral("flatpak"),
                                          {QStringLiteral("install"), QStringLiteral("--user"), QStringLiteral("--noninteractive"), m_selectedFile});
        if (started)
            updateStatus(QStringLiteral("Instalando aplicación Flatpak…"));
    }

    if (!started)
        updateStatus(QStringLiteral("No se pudo iniciar la instalación"));
    return started;
}

void AppManagerBackend::updateStatus(const QString &text)
{
    m_statusText = text;
    emit statusChanged();
}
