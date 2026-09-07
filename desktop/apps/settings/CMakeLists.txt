cmake_minimum_required(VERSION 3.21)
project(MurScholSettings VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 6.4 REQUIRED COMPONENTS Core Gui Network DBus Qml Quick QuickControls2)
qt_standard_project_setup(REQUIRES 6.4)

qt_add_executable(murschol-settings
    src/main.cpp
    src/SettingsBackend.cpp
    src/SettingsBackend.h
    src/NetworkBackend.cpp
    src/NetworkBackend.h
)

qt_add_qml_module(murschol-settings
    URI MurScholSettings
    VERSION 1.0
    QML_FILES
        qml/Main.qml
        qml/AppearancePage.qml
        qml/DockPage.qml
        qml/PerformancePage.qml
        qml/SystemPage.qml
        qml/NetworkPage.qml
        qml/ExternalPage.qml
        qml/PlaceholderPage.qml
)

target_include_directories(murschol-settings PRIVATE src)
target_link_libraries(murschol-settings PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Network
    Qt6::DBus
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
)

install(TARGETS murschol-settings RUNTIME DESTINATION bin)
