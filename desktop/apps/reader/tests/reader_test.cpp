#include "ReadingStore.h"
#include <QGuiApplication>
#include <QDragEnterEvent>
#include <QDropEvent>
#include <QMimeData>
#include <QQuickWindow>
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
        QCOMPARE(eval("pdfDocument.status").toInt(), int(QPdfDocument::Status::Ready));
        QVERIFY2(!eval("documentErrorPanel.visible").toBool(), "A loaded PDF must not display the error overlay");
        QCOMPARE(eval("pdfView.currentPage").toInt(), 1);
        QCOMPARE(eval("pdfView.renderScale").toDouble(), 1.4);
        eval("pdfView.goToPage(2)");
        QTRY_COMPARE(eval("pdfView.currentPage").toInt(), 2);
        eval("searchField.text = 'searchable'");
        QTRY_VERIFY(eval("pdfView.searchModel.rowCount()").toInt() >= 2);
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
        auto fixture = [&](const QString &name) {
            QFile input(":/MurScholReader/tests/fixtures/" + name + ".pdf.b64");
            if (!input.open(QIODevice::ReadOnly)) return QUrl();
            const QString destination = dir.filePath(name + ".pdf");
            QFile output(destination);
            if (!output.open(QIODevice::WriteOnly)) return QUrl();
            output.write(QByteArray::fromBase64(input.readAll()));
            output.close();
            return QUrl::fromLocalFile(destination);
        };
        auto open = [&](const QUrl &source) {
            engine.rootContext()->setContextProperty("testDocument", source);
            eval("window.openDocument(testDocument)");
        };
        open(fixture("outline"));
        QTRY_VERIFY_WITH_TIMEOUT(!root->property("restoring").toBool(), 5000);
        QCOMPARE(eval("bookmarkModel.rowCount()").toInt(), 2);
        eval("contentsDrawer.open()");
        QTest::qWait(200);
        eval("contentsDrawer.close()");
        open(fixture("protected"));
        QTRY_VERIFY(eval("passwordDialog.visible").toBool());
        eval("passwordField.text = 'wrong'; passwordDialog.accept()");
        QTRY_VERIFY(eval("passwordDialog.visible").toBool());
        eval("passwordField.text = 'reader-test'; passwordDialog.accept()");
        QTRY_VERIFY_WITH_TIMEOUT(eval("pdfDocument.status === PdfDocument.Status.Ready").toBool(), 5000);
        QTRY_VERIFY(!root->property("restoring").toBool());
        QCOMPARE(eval("pdfDocument.pageCount").toInt(), 3);
        QCOMPARE(eval("pdfDocument.status").toInt(), int(QPdfDocument::Status::Ready));
        QVERIFY2(!eval("documentErrorPanel.visible").toBool(), "A loaded PDF must not display the error overlay");
        QVERIFY(!eval("passwordDialog.visible").toBool());
        eval("window.closeDocument()");
        open(fixture("protected"));
        QTRY_VERIFY(eval("passwordDialog.visible").toBool());
        eval("passwordDialog.reject()");
        QVERIFY(!root->property("reading").toBool());
        // The file chooser and drag/drop must route to the same real PDF loader.
        engine.rootContext()->setContextProperty("testDocument", url);
        eval("openDialog.selectedFile = testDocument; openDialog.accepted()");
        QTRY_VERIFY(root->property("reading").toBool());
        QTRY_VERIFY(!root->property("restoring").toBool());
        QCOMPARE(eval("pdfDocument.pageCount").toInt(), 3);
        QCOMPARE(eval("pdfDocument.status").toInt(), int(QPdfDocument::Status::Ready));
        QVERIFY2(!eval("documentErrorPanel.visible").toBool(), "A loaded PDF must not display the error overlay");
        auto *window = qobject_cast<QQuickWindow *>(root);
        QVERIFY(window);
        QTest::qWait(100);
        QVERIFY(window->grabWindow().save("reader-preview.png"));
        eval("window.closeDocument()");
        QMimeData mime;
        mime.setUrls({url});
        QDragEnterEvent enter(QPoint(200, 200), Qt::CopyAction, &mime, Qt::LeftButton, Qt::NoModifier);
        QGuiApplication::sendEvent(window, &enter);
        QVERIFY(enter.isAccepted());
        QDropEvent drop(QPointF(200, 200), Qt::CopyAction, &mime, Qt::LeftButton, Qt::NoModifier);
        QGuiApplication::sendEvent(window, &drop);
        QVERIFY(drop.isAccepted());
        QTRY_VERIFY(root->property("reading").toBool());
        QTRY_VERIFY(!root->property("restoring").toBool());
        QCOMPARE(eval("pdfDocument.pageCount").toInt(), 3);
        QCOMPARE(eval("pdfDocument.status").toInt(), int(QPdfDocument::Status::Ready));
        QVERIFY2(!eval("documentErrorPanel.visible").toBool(), "A loaded PDF must not display the error overlay");
        // A deleted recent entry must report an error without discarding an open PDF.
        open(url);
        QTRY_VERIFY(!root->property("restoring").toBool());
        open(QUrl::fromLocalFile(dir.filePath("missing.pdf")));
        QVERIFY(eval("messageDialog.visible").toBool());
        QVERIFY(root->property("reading").toBool());
        eval("messageDialog.close(); window.closeDocument()");
        // Invalid input must still show the real error; do not just hide the panel.
        QFile invalid(dir.filePath("invalid.pdf"));
        QVERIFY(invalid.open(QIODevice::WriteOnly));
        invalid.write("This is not a PDF.");
        invalid.close();
        open(QUrl::fromLocalFile(invalid.fileName()));
        QTRY_COMPARE(eval("pdfDocument.status").toInt(), int(QPdfDocument::Status::Error));
        QVERIFY(eval("documentErrorPanel.visible").toBool());
        QVERIFY(eval("pdfDocument.error").toString() != "no error");
        open(url);
        QTRY_COMPARE(eval("pdfDocument.status").toInt(), int(QPdfDocument::Status::Ready));
        QVERIFY(!eval("documentErrorPanel.visible").toBool());
        eval("window.closeDocument()");
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
