#include "ReadingStore.h"
#include <QGuiApplication>
#include <QPainter>
#include <QPdfDocument>
#include <QPdfWriter>
#include <QPdfSelection>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQmlExpression>
#include <QQuickStyle>
#include <QTemporaryDir>
#include <QtTest>

class ReaderTest : public QObject {
    Q_OBJECT
private slots:
    void readingFlow() {
        QTemporaryDir dir;
        QVERIFY(dir.isValid());
        QSettings::setDefaultFormat(QSettings::IniFormat);
        QSettings::setPath(QSettings::IniFormat, QSettings::UserScope, dir.path());
        const auto path = dir.filePath(QString::fromUtf8("Lectura ñ con espacios.pdf"));
        {
            QPdfWriter writer(path);
            QPainter painter(&writer);
            painter.drawText(200, 200, "Reader searchable first page");
            writer.newPage();
            painter.drawText(200, 200, "Reader searchable second page");
            writer.newPage();
            painter.drawText(200, 200, "Reader final page");
        }
        const auto url = QUrl::fromLocalFile(path);
        QPdfDocument document;
        QCOMPARE(document.load(path), QPdfDocument::Error::None);
        QCOMPARE(document.pageCount(), 3);
        QVERIFY(!document.render(0, QSize(200, 280)).isNull());
        QVERIFY(document.getAllText(1).text().contains("second"));

        ReadingStore store;
        QCOMPARE(store.localDocument(url), url);
        QVERIFY(store.localDocument(QUrl("https://example.org/document.pdf")).isEmpty());
        store.remember(url, 1, 1.4);
        store.toggleBookmark(url, 2);
        {
            ReadingStore reopened;
            QCOMPARE(reopened.state(url).value("page").toInt(), 1);
            QCOMPARE(reopened.bookmarks(url), QVariantList{2});
        }
        QQmlApplicationEngine engine;
        QStringList warnings;
        connect(&engine, &QQmlEngine::warnings, this, [&](const QList<QQmlError> &errors) {
            for (const auto &e : errors) warnings.append(e.toString());
        });
        engine.rootContext()->setContextProperty("readingStore", &store);
        engine.rootContext()->setContextProperty("murscholStartupDocument", url);
        engine.load(QUrl("qrc:/MurScholReader/qml/Main.qml"));
        QVERIFY2(!engine.rootObjects().isEmpty(), qPrintable(warnings.join('\n')));
        QObject *root = engine.rootObjects().first();
        auto eval = [&](const QString &code) {
            QQmlExpression expression(QQmlEngine::contextForObject(root), root, code);
            auto value = expression.evaluate();
            if (expression.hasError()) warnings.append(expression.error().toString());
            return value;
        };
        QTRY_VERIFY_WITH_TIMEOUT(!root->property("restoring").toBool(), 5000);
        QCOMPARE(eval("pdfDocument.pageCount").toInt(), 3);
        QCOMPARE(eval("pdfView.currentPage").toInt(), 1);
        QCOMPARE(eval("pdfView.renderScale").toDouble(), 1.4);
        eval("pdfView.goToPage(2)");
        QTRY_COMPARE(eval("pdfView.currentPage").toInt(), 2);
        eval("searchField.text = 'searchable'");
        QTRY_VERIFY(eval("pdfView.searchModel.count").toInt() >= 2);
        eval("pdfView.searchForward()");
        eval("contentsDrawer.open(); marksDrawer.open()");
        QTest::qWait(100);
        eval("contentsDrawer.close(); marksDrawer.close(); window.savePosition()");
        eval("window.closeDocument()");
        QVERIFY(!root->property("reading").toBool());
        // Reopening must restore metadata, not modify or delete the source PDF.
        QVERIFY(QFileInfo::exists(path));
        store.forget(url);
        QVERIFY(store.recentDocuments().isEmpty());
        QCOMPARE(store.bookmarks(url), QVariantList{2});
        store.toggleBookmark(url, 2);
        QVERIFY(store.bookmarks(url).isEmpty());
        eval("window.messageText = 'Test'; messageDialog.open(); passwordDialog.open()");
        QTest::qWait(100);
        eval("passwordDialog.close(); messageDialog.close()");
        QVERIFY2(warnings.isEmpty(), qPrintable(warnings.join('\n')));
    }
};

int main(int argc, char **argv) {
    QGuiApplication app(argc, argv);
    app.setOrganizationName("MurScholTests");
    app.setApplicationName("ReaderTests");
    QQuickStyle::setStyle("Basic");
    ReaderTest test;
    return QTest::qExec(&test, argc, argv);
}
#include "reader_test.moc"
