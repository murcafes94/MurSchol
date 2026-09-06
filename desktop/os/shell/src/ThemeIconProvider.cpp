#include "ThemeIconProvider.h"

#include <QIcon>
#include <QPixmap>

ThemeIconProvider::ThemeIconProvider()
    : QQuickImageProvider(QQuickImageProvider::Pixmap)
{
}

QPixmap ThemeIconProvider::requestPixmap(const QString &id, QSize *size, const QSize &requestedSize)
{
    QSize target = requestedSize.isValid() ? requestedSize : QSize(48, 48);
    if (target.width() <= 0 || target.height() <= 0)
        target = QSize(48, 48);

    QIcon icon = QIcon::fromTheme(id);
    if (icon.isNull())
        icon = QIcon::fromTheme(QStringLiteral("application-x-executable"));

    QPixmap pixmap = icon.pixmap(target);
    if (size)
        *size = pixmap.size();
    return pixmap;
}
