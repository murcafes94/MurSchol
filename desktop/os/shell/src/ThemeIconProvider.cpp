#include "ThemeIconProvider.h"

#include <QFileInfo>
#include <QIcon>
#include <QPixmap>
#include <QUrl>

ThemeIconProvider::ThemeIconProvider()
    : QQuickImageProvider(QQuickImageProvider::Pixmap)
{
}

QPixmap ThemeIconProvider::requestPixmap(const QString &id, QSize *size, const QSize &requestedSize)
{
    QSize target = requestedSize.isValid() ? requestedSize : QSize(48, 48);
    if (target.width() <= 0 || target.height() <= 0)
        target = QSize(48, 48);

    QString iconId = QUrl::fromPercentEncoding(id.toUtf8());
    QIcon icon;

    // Algunos archivos .desktop entregan un nombre de tema y otros una ruta
    // absoluta a PNG/SVG. MurSchol acepta ambos para no degradar aplicaciones
    // instaladas fuera de los repositorios Debian.
    if (QFileInfo::exists(iconId))
        icon = QIcon(iconId);
    else
        icon = QIcon::fromTheme(iconId);

    if (icon.isNull())
        icon = QIcon::fromTheme(QStringLiteral("application-x-executable"));

    QPixmap pixmap = icon.pixmap(target);
    if (size)
        *size = pixmap.size();
    return pixmap;
}
