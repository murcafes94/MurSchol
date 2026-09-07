cmake_minimum_required(VERSION 3.21)
project(MurScholCalendar VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 6.4 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2 Sql)
qt_standard_project_setup(REQUIRES 6.4)

qt_add_executable(murschol-calendar
    src/main.cpp
    src/EventModel.cpp
    src/EventModel.h
)

qt_add_qml_module(murschol-calendar
    URI MurScholCalendar
    VERSION 1.0
    QML_FILES
        qml/Main.qml
)

target_include_directories(murschol-calendar PRIVATE src)
target_link_libraries(murschol-calendar PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Sql
)

install(TARGETS murschol-calendar RUNTIME DESTINATION bin)
