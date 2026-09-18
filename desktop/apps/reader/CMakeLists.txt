cmake_minimum_required(VERSION 3.21)
project(MurScholReader VERSION 1.0.1 LANGUAGES CXX)

include(GNUInstallDirs)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 6.4 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2 Pdf)
qt_standard_project_setup(REQUIRES 6.4)

qt_add_executable(murschol-reader
    src/main.cpp
    src/ReadingStore.cpp
    src/ReadingStore.h
)

qt_add_qml_module(murschol-reader
    URI MurScholReader
    VERSION 1.0
    QML_FILES
        qml/Main.qml
        qml/components/ReaderTopBar.qml
        qml/components/ContentsDrawer.qml
        qml/components/MarksDrawer.qml
        qml/components/LibraryHome.qml
)

target_link_libraries(murschol-reader PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Pdf
)

install(TARGETS murschol-reader RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
install(FILES packaging/murschol-reader.desktop
    DESTINATION ${CMAKE_INSTALL_DATADIR}/applications)

set(CPACK_PACKAGE_NAME "murschol-reader")
set(CPACK_PACKAGE_VENDOR "MurSchol")
set(CPACK_PACKAGE_CONTACT "MurSchol")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Lector PDF de escritorio para Linux")
set(CPACK_PACKAGE_VERSION ${PROJECT_VERSION})
set(CPACK_DEBIAN_PACKAGE_SECTION "office")
set(CPACK_DEBIAN_PACKAGE_SHLIBDEPS ON)
set(CPACK_DEBIAN_PACKAGE_DEPENDS "qt6-qpa-plugins, qml6-module-qtquick, qml6-module-qtquick-controls, qml6-module-qtquick-layouts, qml6-module-qtqml-workerscript, qml6-module-qtquick-window, qml6-module-qtquick-templates, qml6-module-qtqml, qml6-module-qtquick-dialogs, qml6-module-qtquick-pdf")
set(CPACK_DEBIAN_PACKAGE_RECOMMENDS "qt6-wayland, qt6-gtk-platformtheme")
set(CPACK_DEBIAN_FILE_NAME DEB-DEFAULT)
set(CPACK_PACKAGING_INSTALL_PREFIX "/usr")
set(CPACK_GENERATOR "DEB")
include(CPack)

include(CTest)
if(BUILD_TESTING)
    find_package(Qt6 REQUIRED COMPONENTS Test)
    qt_add_executable(reader-test tests/reader_test.cpp src/ReadingStore.cpp src/ReadingStore.h)
    target_include_directories(reader-test PRIVATE src)
    target_link_libraries(reader-test PRIVATE Qt6::Test Qt6::Gui Qt6::Qml Qt6::Quick Qt6::QuickControls2 Qt6::Pdf)
    qt_add_qml_module(reader-test
        URI MurScholReader
        VERSION 1.0
        OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/test-qml/MurScholReader"
        QML_FILES
        qml/Main.qml
        qml/components/ReaderTopBar.qml
        qml/components/ContentsDrawer.qml
        qml/components/MarksDrawer.qml
        qml/components/LibraryHome.qml
        RESOURCES
        tests/fixtures/outline.pdf.b64
        tests/fixtures/protected.pdf.b64)
    add_test(NAME reader-flow COMMAND reader-test)
    set_tests_properties(reader-flow PROPERTIES ENVIRONMENT "QT_QPA_PLATFORM=offscreen;QT_QUICK_BACKEND=software" TIMEOUT 30)
endif()
