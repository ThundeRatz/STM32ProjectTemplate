# Name: CMakeLists file
# ThundeRatz Robotics Team
# Brief: This file contains the configuration of the CMake project
## and all the files that you should edit to configure your project
# 03/2025

cmake_minimum_required(VERSION 3.22)

###############################################################################
## Project Configuration
###############################################################################

set(CMAKE_PROJECT_NAME stm32_project_template)

# Set the board version to an empty string if your board doesn't have a version
set(BOARD_VERSION "")

if(BOARD_VERSION STREQUAL "")
    set(PROJECT_RELEASE ${CMAKE_PROJECT_NAME})
else()
    set(PROJECT_RELEASE ${CMAKE_PROJECT_NAME}_${BOARD_VERSION})
endif()

###############################################################################
## CMake Configuration
###############################################################################

set(CMAKE_C_STANDARD 17)
set(CMAKE_CXX_STANDARD 26)

set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS ON)

set(CMAKE_EXPORT_COMPILE_COMMANDS TRUE)

###############################################################################
## Global compilation config
###############################################################################

set(LAUNCH_JSON_PATH ${CMAKE_CURRENT_SOURCE_DIR}/.vscode/launch.json)
set(DEBUG_FILE_NAME ${CMAKE_PROJECT_NAME})

include(cmake/config_validation.cmake)

set(CMAKE_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/cube)
include(cube/cmake/gcc-arm-none-eabi.cmake)
set(CMAKE_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR})

project(${CMAKE_PROJECT_NAME} C CXX ASM)

include(cmake/targets.cmake)
include(cmake/utilities.cmake)

add_subdirectory(cube/cmake/stm32cubemx)

###############################################################################
## CubeMX Configuration
###############################################################################

get_target_property(CUBE_INCLUDE_DIRECTORIES stm32cubemx INTERFACE_INCLUDE_DIRECTORIES)
get_target_property(CUBE_SOURCES stm32cubemx INTERFACE_SOURCES)
get_target_property(CUBE_COMPILE_DEFINITIONS stm32cubemx INTERFACE_COMPILE_DEFINITIONS)

# Remove warnings from Cube sources
set_source_files_properties(
    ${CUBE_SOURCES}
    PROPERTIES
    COMPILE_FLAGS "-w"
)

add_compile_definitions(${CUBE_COMPILE_DEFINITIONS})

###############################################################################
## Input files
###############################################################################

file(GLOB_RECURSE FORMAT_SOURCES CONFIGURE_DEPENDS "src/*.cpp" "config/*.cpp" "tests/*.cpp")
file(GLOB_RECURSE FORMAT_HEADERS CONFIGURE_DEPENDS "include/*.hpp" "config/*.hpp" "tests/*.hpp")

generate_format_target(FORMAT_SOURCES FORMAT_HEADERS)

file(GLOB_RECURSE PROJECT_SOURCES CONFIGURE_DEPENDS "src/**.cpp")
file(GLOB_RECURSE PROJECT_TESTS CONFIGURE_DEPENDS "tests/src/**.cpp")

list(FILTER PROJECT_SOURCES EXCLUDE REGEX "main.cpp")

###############################################################################
## Project library
###############################################################################

add_library(${PROJECT_NAME}_static STATIC
    ${PROJECT_SOURCES}
)

target_include_directories(${PROJECT_NAME}_static SYSTEM PUBLIC
    ${CUBE_INCLUDE_DIRECTORIES}
)

target_include_directories(${PROJECT_NAME}_static PUBLIC
    include
    config
)

target_link_libraries(${PROJECT_NAME}_static PRIVATE
    stm32cubemx
)

add_library(${PROJECT_NAME}_lib INTERFACE)
target_link_libraries(${PROJECT_NAME}_lib INTERFACE
    "-Wl,--whole-archive" ${PROJECT_NAME}_static "-Wl,--no-whole-archive"
)

###############################################################################
## Main executable target
###############################################################################

add_executable(${PROJECT_NAME}
    "${CMAKE_SOURCE_DIR}/src/main.cpp"
)

target_link_libraries(${PROJECT_NAME} PRIVATE
    ${PROJECT_NAME}_lib
)

generate_hex_file(${PROJECT_NAME})
print_size_of_target(${PROJECT_NAME})

generate_helpme_text()
generate_vscode_tasks_json()
generate_debug_target(${PROJECT_NAME})
generate_flash_target(${PROJECT_NAME})

###############################################################################
## Generate test executables
###############################################################################

foreach(TEST_FILE ${PROJECT_TESTS})
    get_filename_component(TEST_NAME ${TEST_FILE} NAME_WLE)

    add_executable(${TEST_NAME} EXCLUDE_FROM_ALL
        ${TEST_FILE}
    )

    target_link_libraries(${TEST_NAME} PRIVATE
        ${PROJECT_NAME}_lib
    )

    target_include_directories(${TEST_NAME} PUBLIC
        tests/include
    )

    generate_hex_file(${TEST_NAME})
    print_size_of_target(${TEST_NAME})

    generate_debug_target(${TEST_NAME})
    generate_flash_target(${TEST_NAME})
endforeach()

generate_test_all_target(${PROJECT_TESTS})
