cmake_minimum_required(VERSION 3.21)
project(MurScholReader VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 6.4 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2)
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
)

install(TARGETS murschol-reader RUNTIME DESTINATION bin)
