cmake_minimum_required(VERSION 3.21)
project(MurScholReader VERSION 1.0.0 LANGUAGES CXX)

include(GNUInstallDirs)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 6.4 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2 Pdf)
qt_standard_project_setup(REQUIRES 6.4)

qt_add_executable(murschol-reader
    src/main.cpp
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
set(CPACK_DEBIAN_FILE_NAME DEB-DEFAULT)
set(CPACK_PACKAGING_INSTALL_PREFIX "/usr")
set(CPACK_GENERATOR "DEB")
include(CPack)
