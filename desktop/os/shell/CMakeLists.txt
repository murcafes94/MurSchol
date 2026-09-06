cmake_minimum_required(VERSION 3.21)
project(MurScholDesktop VERSION 0.3.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 6.4 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2)
find_package(LayerShellQt 6 QUIET)
qt_standard_project_setup(REQUIRES 6.4)

set(MURSCHOL_COMMON_SOURCES
    src/SystemBackend.cpp
    src/SystemBackend.h
    src/AppIndexModel.cpp
    src/AppIndexModel.h
    src/UniversalSearchModel.cpp
    src/UniversalSearchModel.h
    src/AppManagerBackend.cpp
    src/AppManagerBackend.h
    src/ThemeIconProvider.cpp
    src/ThemeIconProvider.h
)

qt_add_executable(murschol-desktop
    src/main.cpp
    ${MURSCHOL_COMMON_SOURCES}
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
        qml/components/AppManagerPanel.qml
)

target_include_directories(murschol-desktop PRIVATE src)
target_link_libraries(murschol-desktop PRIVATE
    Qt6::Core Qt6::Gui Qt6::Qml Qt6::Quick Qt6::QuickControls2
)

install(TARGETS murschol-desktop RUNTIME DESTINATION bin)

# En Debian 13 la sesión Live incorpora LayerShellQt 6. Cuando está disponible
# construimos el dock como un proceso independiente wlr-layer-shell para que
# aparezca sobre aplicaciones maximizadas y pueda reducirse a una franja de 8 px.
if(LayerShellQt_FOUND)
    qt_add_executable(murschol-panel
        src/panel_main.cpp
        ${MURSCHOL_COMMON_SOURCES}
    )

    qt_add_resources(murschol-panel "panel_resources"
        PREFIX "/"
        FILES
            qml/Panel.qml
            qml/components/Dock.qml
            qml/components/StartMenu.qml
            qml/components/AppManagerPanel.qml
    )

    target_include_directories(murschol-panel PRIVATE src)
    target_link_libraries(murschol-panel PRIVATE
        Qt6::Core Qt6::Gui Qt6::Qml Qt6::Quick Qt6::QuickControls2
        LayerShellQt::Interface
    )

    install(TARGETS murschol-panel RUNTIME DESTINATION bin)
endif()

set(CPACK_PACKAGE_NAME "MurSchol-Desktop")
set(CPACK_PACKAGE_VERSION "${PROJECT_VERSION}")
set(CPACK_GENERATOR "TGZ")
include(CPack)
