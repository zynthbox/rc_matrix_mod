cmake_minimum_required(VERSION 3.16)
project(AudioControlModTest VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

find_package(Qt5 5.15 REQUIRED COMPONENTS
    Core
    Gui
    Qml
    Quick
    WebEngine
    WebEngineCore
    WebChannel)

find_package(PkgConfig REQUIRED)
pkg_check_modules(RTMIDI REQUIRED rtmidi)

add_executable(audiocontrol_mod_test
    main.cpp
    MidiTransport.h
    MidiTransport.cpp
    resource.qrc)

target_include_directories(audiocontrol_mod_test PRIVATE ${RTMIDI_INCLUDE_DIRS})

target_link_libraries(audiocontrol_mod_test
    PRIVATE
    Qt5::Core
    Qt5::Gui
    Qt5::Qml
    Qt5::Quick
    Qt5::WebEngine
    Qt5::WebEngineCore
    Qt5::WebChannel
    ${RTMIDI_LIBRARIES})
