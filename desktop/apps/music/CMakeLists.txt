cmake_minimum_required(VERSION 3.21)
project(MurScholMusic VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 6.4 REQUIRED COMPONENTS Core Gui Concurrent Qml Quick QuickControls2)
qt_standard_project_setup(REQUIRES 6.4)

qt_add_executable(murschol-music
    src/main.cpp
    src/MusicLibraryModel.cpp
    src/MusicLibraryModel.h
)

qt_add_qml_module(murschol-music
    URI MurScholMusic
    VERSION 1.0
    QML_FILES
        qml/Main.qml
)

target_include_directories(murschol-music PRIVATE src)
target_link_libraries(murschol-music PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Concurrent
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
)

install(TARGETS murschol-music RUNTIME DESTINATION bin)
