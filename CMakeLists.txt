# Name: CMakeLists file
# ThundeRatz Robotics Team
# Brief: This file contains the configuration of the CMake project
## and all the files that you should edit to configure your project
# 03/2025

cmake_minimum_required(VERSION 3.22)

###############################################################################
## CMake Configuration
###############################################################################

set(CMAKE_C_STANDARD 17)
set(CMAKE_CXX_STANDARD 20)

set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS ON)

set(CMAKE_EXPORT_COMPILE_COMMANDS TRUE)

# Debug, Release, RelWithDebInfo and MinSizeRel
# @see: https://cmake.org/cmake/help/latest/variable/CMAKE_BUILD_TYPE.html
set(CMAKE_BUILD_TYPE Debug)

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
include(cmake/linter.cmake)

add_subdirectory(cube/cmake/stm32cubemx)

###############################################################################
## CubeMX Configuration
###############################################################################

get_target_property(CUBE_INCLUDE_DIRECTORIES stm32cubemx INTERFACE_INCLUDE_DIRECTORIES)
get_target_property(CUBE_SOURCES stm32cubemx INTERFACE_SOURCES)
get_target_property(CUBE_COMPILE_DEFINITIONS stm32cubemx INTERFACE_COMPILE_DEFINITIONS)

# Remove warnings from Cube sources
set_source_files_properties(
    SYSTEM ${CUBE_SOURCES}
    PROPERTIES
    COMPILE_FLAGS "-w"
)

add_compile_definitions(${CUBE_COMPILE_DEFINITIONS})

###############################################################################
## Input files
###############################################################################

file(GLOB_RECURSE FORMAT_SOURCES CONFIGURE_DEPENDS "lib/*.cpp" "src/*.cpp" "config/*.cpp" "tests/*.cpp" "thunder_*/include/*.cpp*")
file(GLOB_RECURSE FORMAT_HEADERS CONFIGURE_DEPENDS "lib/*.hpp" "include/*.hpp" "config/*.hpp" "tests/*.hpp" "thunder_*/include/*.hpp*")

targets_generate_format_target(FORMAT_SOURCES FORMAT_HEADERS)

file(GLOB_RECURSE PROJECT_SOURCES CONFIGURE_DEPENDS "src/*.cpp")
file(GLOB_RECURSE PROJECT_TESTS CONFIGURE_DEPENDS "tests/src/**.cpp")

###############################################################################
## Main executable target
###############################################################################

add_executable(${PROJECT_NAME}
    ${PROJECT_SOURCES}
)

target_include_directories(${PROJECT_NAME} PUBLIC
    SYSTEM ${CUBE_INCLUDE_DIRECTORIES}
    include
    config
)

stm32_print_size_of_target(${PROJECT_NAME})
stm32_generate_hex_file(${PROJECT_NAME})

targets_generate_vsfiles_target(${PROJECT_NAME})
targets_generate_flash_target(${PROJECT_NAME})
targets_generate_helpme_target()

###############################################################################
## Generate test executables
###############################################################################

foreach(TEST_FILE ${PROJECT_TESTS})
    get_filename_component(TEST_NAME ${TEST_FILE} NAME_WLE)

    add_executable(${TEST_NAME} EXCLUDE_FROM_ALL
        ${TEST_FILE}
        ${PROJECT_TESTS_SOURCES}
    )

    target_include_directories(${TEST_NAME} PUBLIC
        SYSTEM ${CUBE_INCLUDE_DIRECTORIES}
        include
        tests/include
        config
    )

    stm32_generate_hex_file(${TEST_NAME})

    targets_generate_vsfiles_target(${TEST_NAME})
    targets_generate_flash_target(${TEST_NAME})

endforeach()

targets_generate_test_all_target(${PROJECT_TESTS})
