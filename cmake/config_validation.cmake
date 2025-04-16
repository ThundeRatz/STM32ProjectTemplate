###############################################################################
## Existence checks
###############################################################################

# Check if CMake build type is correctly configured
if(NOT (BUILD_TYPE STREQUAL "Release"        OR BUILD_TYPE STREQUAL "Debug" OR
        BUILD_TYPE STREQUAL "RelWithDebInfo" OR BUILD_TYPE STREQUAL "MinSizeRel"))
    set(BUILD_TYPE "RelWithDebInfo")
endif()

set(CMAKE_BUILD_TYPE ${BUILD_TYPE})
message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")

# Check if host system is Linux
if(NOT CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
    message(FATAL_ERROR "${CMAKE_HOST_SYSTEM_NAME} is not supported")
endif()

# Detect if running inside WSL
if(DEFINED ENV{WSL_DISTRO_NAME})
    message(STATUS "WSL detected")
    set(CUBE_DEFAULT_PATH "/mnt/c/Program Files/STMicroelectronics/STM32Cube/STM32CubeMX")
    set(CUBE_PROGRAM "STM32CubeMX.exe")
    set(PROGRAMMER_CMD "STM32_Programmer_CLI.exe")
    set(JLINK_CMD "JLink.exe")
    set(OPENOCD_CMD "openocd.exe")
else()
    message(STATUS "Linux detected")
    set(CUBE_DEFAULT_PATH "/usr/local/STMicroelectronics/STM32Cube/STM32CubeMX")
    set(CUBE_PROGRAM "STM32CubeMX")
    set(PROGRAMMER_CMD "STM32_Programmer_CLI")
    set(JLINK_CMD "JLinkExe")
    set(OPENOCD_CMD "openocd")
endif()

# Set STM32CubeMX command
if(DEFINED ENV{CUBE_CMD})
    set(CUBE_CMD $ENV{CUBE_CMD})
    message(STATUS "Using STM32CubeMX from environment: ${CUBE_CMD}")
else()
    message(STATUS "CUBE_CMD not defined, trying to run from PATH")
    find_program(CUBE_CMD ${CUBE_PROGRAM})

    if(CUBE_CMD)
        message(STATUS "STM32CubeMX found at: ${CUBE_CMD}")
    else()
        message(STATUS "${CUBE_PROGRAM} not found on PATH, trying default path")
        set(CUBE_CMD "${CUBE_DEFAULT_PATH}/${CUBE_PROGRAM}")

        if(NOT EXISTS ${CUBE_CMD})
            message(FATAL_ERROR
                "STM32CubeMX program not found at expected path: ${CUBE_CMD}\n"
                "Define the CUBE_CMD environment variable or add the binary folder to the PATH"
            )
        endif()
    endif()
endif()

if(CUBE_CMD MATCHES "\.exe$" )
    set(CUBE_SOURCE_DIR "\\\\wsl.localhost/$ENV{WSL_DISTRO_NAME}${CMAKE_CURRENT_SOURCE_DIR}/cube")
else()
    set(CUBE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/cube")
endif()

# Set STM32 Programmer command
if(DEFINED ENV{PROGRAMMER_CMD})
    set(PROGRAMMER_CMD $ENV{PROGRAMMER_CMD})
endif()

# Set J-Link command
if(DEFINED ENV{JLINK_CMD})
    set(JLINK_CMD $ENV{JLINK_CMD})
endif()

# Set OpenOCD command
if(DEFINED ENV{OPENOCD_CMD})
    set(OPENOCD_CMD $ENV{OPENOCD_CMD})
endif()

# Check if OpenOCD variables are properly defined
if (DEFINED ENV{OPENOCD_SCRIPTS_PATH})
    set(OPENOCD_SCRIPTS_PATH $ENV{OPENOCD_SCRIPTS_PATH})
    message(STATUS "OPENOCD_SCRIPTS_PATH defined as $ENV{OPENOCD_SCRIPTS_PATH}")
else()
    set(OPENOCD_SCRIPTS_PATH "/usr/share/openocd/scripts")
    message(STATUS "OPENOCD_SCRIPTS_PATH not defined. Using default path ${OPENOCD_SCRIPTS_PATH}")
endif()

# Check if STM32CubeMX project is correctly configured
set(CUBE_CMAKE_TOOLCHAIN_CONFIG "ProjectManager.TargetToolchain=CMake")
set(IOC_FILE "cube/${PROJECT_RELEASE}.ioc")
file(READ ${IOC_FILE} IOC_CONTENTS)
string(FIND ${IOC_CONTENTS} ${CUBE_CMAKE_TOOLCHAIN_CONFIG} CUBE_CMAKE_TOOLCHAIN_CONFIG_POS)

if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${IOC_FILE}")
    message(FATAL_ERROR "CubeMX ${IOC_FILE} project file not found")
elseif(CUBE_CMAKE_TOOLCHAIN_CONFIG_POS EQUAL -1)
    message(FATAL_ERROR "CMake toolchain not selected in CubeMX project")
else()
    message(STATUS "CMake toolchain selected in CubeMX project")
endif()

# Set DEVICE variable based on cube configuration
string(REGEX MATCH "ProjectManager\.DeviceId=[^\n]+" DEVICE_LINE ${IOC_CONTENTS})
string(SUBSTRING ${DEVICE_LINE} 24 11 DEVICE)
string(TOLOWER ${DEVICE} LOWERCASE_DEVICE)
string(SUBSTRING ${LOWERCASE_DEVICE} 0 7 TARGET_CFG)
message(STATUS "Device is ${DEVICE}")

# Check cube directory for files
# If it's empty, generate the files
file(GLOB_RECURSE CUBE_SOURCES_CHECK "${CMAKE_CURRENT_SOURCE_DIR}/cube/**/*.c")
list(LENGTH CUBE_SOURCES_CHECK CUBE_LENGTH)

if(CUBE_LENGTH EQUAL 0)
    message(STATUS "Cube directory is empty. Generating cube files...")
    file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/cube_script.txt"
        "config load ${CUBE_SOURCE_DIR}/${PROJECT_RELEASE}.ioc\n"
        "project generate\n"
        "exit\n"
    )

    execute_process(COMMAND ${CUBE_CMD} -q ${CMAKE_CURRENT_BINARY_DIR}/cube_script.txt)
endif()

# Check linter configuration
if(LINTER_MODE STREQUAL "ON")
    set(CMAKE_CXX_CLANG_TIDY "clang-tidy")
    add_compile_options(-fms-extensions)
    message(STATUS "Enabling clang-tidy, hex files will not be generated")
elseif(LINTER_MODE STREQUAL "FIX")
    set(CMAKE_CXX_CLANG_TIDY "clang-tidy;--fix")
    add_compile_options(-fms-extensions)
    message(STATUS "Enabling clang-tidy with fix, hex files will not be generated")
else()
    set(LINTER_MODE "OFF")
    message(STATUS "Linter is disabled")
endif()
