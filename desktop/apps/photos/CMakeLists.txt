cmake_minimum_required(VERSION 3.21)
project(MurScholPhotos VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 6.4 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2)
qt_standard_project_setup(REQUIRES 6.4)

qt_add_executable(murschol-photos
    src/main.cpp
    src/PhotoBackend.cpp
    src/PhotoBackend.h
)

qt_add_qml_module(murschol-photos
    URI MurScholPhotos
    VERSION 1.0
    QML_FILES
        qml/Main.qml
)

target_include_directories(murschol-photos PRIVATE src)
target_link_libraries(murschol-photos PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
)

install(TARGETS murschol-photos RUNTIME DESTINATION bin)
