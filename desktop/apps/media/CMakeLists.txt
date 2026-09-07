cmake_minimum_required(VERSION 3.21)
project(MurScholMedia VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 6.4 REQUIRED COMPONENTS Core Gui OpenGL Qml Quick QuickControls2)
find_package(PkgConfig REQUIRED)
pkg_check_modules(MPV REQUIRED IMPORTED_TARGET mpv)
qt_standard_project_setup(REQUIRES 6.4)

qt_add_executable(murschol-media
    src/main.cpp
    src/MpvPlayer.cpp
    src/MpvPlayer.h
)

qt_add_qml_module(murschol-media
    URI MurScholMedia
    VERSION 1.0
    QML_FILES
        qml/Main.qml
)

target_include_directories(murschol-media PRIVATE src)
target_link_libraries(murschol-media PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::OpenGL
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
    PkgConfig::MPV
)

install(TARGETS murschol-media RUNTIME DESTINATION bin)
