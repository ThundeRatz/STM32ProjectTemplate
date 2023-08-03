# Name: config_validation.cmake file
# ThundeRatz Robotics Team
# Brief: This file contains the existence checks of the declared variables
# 04/2023

###############################################################################
## Auxiliary Sets
###############################################################################

# This variable is used by the stm32-cmake lib to find the STM32CubeMX files
# @see: https://github.com/ObKo/stm32-cmake#configuration
set(STM32_CUBE_${DEVICE_CORTEX}_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cube)

# This set contains all the variables that must be defined by the user
# It is used to check if all of them are properly defined
set(USER_INPUT_VARIABLES
    DEVICE_CORTEX
    DEVICE_FAMILY
    DEVICE_TYPE
    DEVICE_DEF
    DEVICE_FAMILY_COMPACT
    DEVICE
    BOARD_VERSION
    TARGET_BOARD
)

###############################################################################
## Existence checks
###############################################################################

## Check if STM32CubeMX variables are properly defined
if(DEFINED ENV{CUBE_PATH})
    message(STATUS "CUBE_PATH defined as $ENV{CUBE_PATH}")
else()
    message(FATAL_ERROR "CUBE_PATH not defined")
endif()

if(CMAKE_HOST_WIN32)
    set(JAVA_EXE "$ENV{CUBE_PATH}\\STM32CubeMX.exe")
    set(CUBE_JAR "$ENV{CUBE_PATH}\\jre\\bin\\java.exe")
    set(JLINK_EXE JLink.exe)
else()
    set(JAVA_EXE $ENV{CUBE_PATH}/jre/bin/java)
    set(CUBE_JAR $ENV{CUBE_PATH}/STM32CubeMX)
    set(JLINK_EXE JLinkExe)
endif()

# Check if necessary variables are defined:
foreach(VARIABLE ${USER_INPUT_VARIABLES})
    if(NOT DEFINED ${VARIABLE})
        message(FATAL_ERROR "${VARIABLE} not defined")
    endif()
endforeach()
message(STATUS "All necessary variables defined!")

# Check cube directory for files
# If it's empty, generate the files
# It's important to do it before find_package(CMSIS)
file(GLOB_RECURSE CUBE_SOURCES_CHECK "${CMAKE_CURRENT_SOURCE_DIR}/cube/Src/*.c")
list(LENGTH CUBE_SOURCES_CHECK CUBE_LENGHT)
if(CUBE_LENGHT EQUAL 0)
    message(STATUS "Cube directory is empty. Generating cube files...")

    file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/.cube
        "config load ${CMAKE_CURRENT_SOURCE_DIR}/cube/${PROJECT_RELEASE}.ioc\n"
        "project generate\n"
        "exit\n"
    )

    execute_process(COMMAND ${JAVA_EXE} -jar ${CUBE_JAR} -q ${CMAKE_CURRENT_BINARY_DIR}/.cube)
endif()
