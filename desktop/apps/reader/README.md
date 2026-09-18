# MurSchol Reader for Linux

Native Qt 6 / QML PDF reader. The Debian package targets **Linux Mint 22.x / Ubuntu 24.04, amd64**. Mint 21.x is not a supported package target. Interactive desktop validation on the user's Mint installation is still required even when CI passes.

## Install and remove

Download the Reader artifact from a successful `Build MurSchol Desktop` run for the latest commit on `main`, extract it, and install the `.deb` from that directory:

```sh
sudo apt install ./murschol-reader_1.0.0_amd64.deb
```

Open Reader from the application menu, choose **Open with → MurSchol Reader** on a PDF, drag a PDF into its window, or run `murschol-reader '/path/to/document.pdf'`. Local `file://` URLs and filenames containing spaces are supported. For paths beginning with `-`, use `murschol-reader -- './-document.pdf'`.

```sh
sudo apt remove murschol-reader
# Alternatively, remove package-level configuration too:
sudo apt purge murschol-reader
```

The package does not install removal scripts and does not delete personal documents. Reading history, page, zoom and bookmarks are stored separately by QSettings in `~/.config/MurSchol/MurSchol Reader.conf`; APT removal and purge leave this per-user file intact. Passwords are never saved. Removing an entry from recent documents preserves its reading position and bookmarks.

## Reader controls

- Open: Ctrl+O, file picker, command argument, file manager or drag and drop.
- Navigation: page number, previous/next page, scrolling and nested PDF outline.
- Search: Ctrl+F, Enter and previous/next match buttons; requires a PDF text layer (no OCR).
- Zoom: toolbar or Ctrl++ / Ctrl+-; restored per document.
- Bookmarks: star button, add/remove current page, jump to a saved page.
- Focus mode: F11; Esc closes search or exits focus mode.
- Protected PDFs: password dialog with retry and cancellation.

Recent documents are limited to 20 entries. Moved or unavailable documents are reported without deleting their metadata. Bookmarks are personal page markers, not PDF annotations; Reader does not edit source PDFs.

## Build and verify

Install the Qt6 development packages and QML modules listed in `.github/workflows/build-desktop.yml`, then from the repository root:

```sh
cmake -S desktop/apps/reader -B build/reader -G Ninja \
  -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr
cmake --build build/reader --parallel 2
ctest --test-dir build/reader --output-on-failure
DESTDIR="$PWD/build/reader/stage" cmake --install build/reader
(cd build/reader && cpack -G DEB)
dpkg-deb --info build/reader/*.deb
dpkg-deb --contents build/reader/*.deb
```

Tests use an isolated temporary settings directory and generated test documents. Base64 fixtures are synthetic PDFs with a nested outline and an encrypted copy (test password: `reader-test`). They contain no user data and are included only in the test executable, not the installed application. Test fixture encryption is for password handling coverage, not a recommended security setting for real documents.

CI validates QML syntax, compiles C++ and QML, runs the PDF integration test, checks the staging tree and desktop entry, starts Reader headlessly, builds and inspects the DEB, and installs/removes/purges it in a clean Ubuntu runtime container. All existing desktop application and Debian panel jobs remain enabled.

## Physical Mint acceptance check

After CI passes, verify on a real desktop: file picker, opening through the file manager, drag and drop, large/scanned PDFs, nested outline, search and zoom, protected PDF retry/cancel, window resize/HiDPI, and reopening after exit to restore reading position and bookmarks. CI/offscreen success alone does not establish that these desktop interactions work on a particular machine.
