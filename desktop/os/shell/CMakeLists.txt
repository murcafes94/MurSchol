cmake_minimum_required(VERSION 3.21)
project(MurScholDesktop VERSION 0.2.2 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 6.4 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2)
qt_standard_project_setup(REQUIRES 6.4)

qt_add_executable(murschol-desktop
    src/main.cpp
    src/SystemBackend.cpp
    src/SystemBackend.h
    src/AppIndexModel.cpp
    src/AppIndexModel.h
    src/UniversalSearchModel.cpp
    src/UniversalSearchModel.h
)

qt_add_qml_module(murschol-desktop
    URI MurScholShell
    VERSION 1.0
    QML_FILES
        qml/Main.qml
        qml/components/TopBar.qml
        qml/components/Dock.qml
        qml/components/StartMenu.qml
        qml/components/SystemCenter.qml
        qml/components/WorkspacePanel.qml
        qml/components/StudyModePanel.qml
        qml/components/AdaptiveProfile.qml
)

target_include_directories(murschol-desktop PRIVATE src)
target_link_libraries(murschol-desktop PRIVATE
    Qt6::Core Qt6::Gui Qt6::Qml Qt6::Quick Qt6::QuickControls2
)

install(TARGETS murschol-desktop RUNTIME DESTINATION bin)

set(CPACK_PACKAGE_NAME "MurSchol-Desktop")
set(CPACK_PACKAGE_VERSION "${PROJECT_VERSION}")
set(CPACK_GENERATOR "TGZ")
include(CPack)
