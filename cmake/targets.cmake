# Name: targets.cmake
# ThundeRatz Robotics Team
# Brief: This file contains auxiliary custom targets declarations
# 04/2023

###############################################################################
## Auxiliary Targets
###############################################################################

add_custom_target(helpme
    COMMAND echo " "
    COMMAND echo "----------------------- Thunder CMake ------------------------------"
    COMMAND echo "   Boas vindas ao CMakeLists da ThundeRatz, cheque as configuracoes    "
    COMMAND echo "                atuais e mude o arquivo se necessario                 "
    COMMAND echo " "
    COMMAND echo "Opcoes:"
    COMMAND echo "  helpme:             mostra essa ajuda"
    COMMAND echo "  cube:               gera arquivos do cube"
    COMMAND echo "  info:               mostra informações sobre o uC conectado"
    COMMAND echo "  flash:              carrega os arquivos compilados do programa principal no microcontrolador via st-link"
    COMMAND echo "  flash_[test_name]:  carrega os arquivos compilados de um teste no microcontrolador via st-link"
    COMMAND echo "  jflash:             carrega os arquivos compilados do programa principal no microcontrolador via j-link"
    COMMAND echo "  jflash_[test_name]: carrega os arquivos compilados de um teste no microcontrolador via j-link"
    COMMAND echo "  format:             formata os arquivos .c/.h"
    COMMAND echo "  clean:              limpa os arquivos compilados"
    COMMAND echo "  clean_all:          apaga todos os arquivos da pasta /build"
    COMMAND echo "  clean_cube:         limpa os arquivos gerados pelo Cube"
    COMMAND echo "  reset:              reseta o microcontrolador"
    COMMAND echo "  rebuild:            recompila os arquivos do /build"
    COMMAND echo "  rebuild_all:        recompila os arquivos do /build os arquivos gerados pelo Cube"
    COMMAND echo " "
    COMMAND echo "Configuracoes atuais:"
    COMMAND echo "  DEVICE_FAMILY  =  ${DEVICE_FAMILY}"
    COMMAND echo "  DEVICE_TYPE    =  ${DEVICE_TYPE}"
    COMMAND echo "  DEVICE         =  ${DEVICE}"
    COMMAND echo "  DEVICE_DEF     =  ${DEVICE_DEF}"
    COMMAND echo "	"
)

add_custom_target(cube
    COMMAND echo "Generating cube files..."

    COMMAND echo "config load ${CMAKE_CURRENT_SOURCE_DIR}/cube/${PROJECT_RELEASE}.ioc" > ${CMAKE_CURRENT_BINARY_DIR}/.cube
    COMMAND echo "project generate" >> ${CMAKE_CURRENT_BINARY_DIR}/.cube
    COMMAND echo "exit" >> ${CMAKE_CURRENT_BINARY_DIR}/.cube

    COMMAND ${JAVA_EXE} -jar ${CUBE_JAR} -q ${CMAKE_CURRENT_BINARY_DIR}/.cube
)

add_custom_target(info
    STM32_Programmer_CLI -c port=SWD
)

add_custom_target(reset
    COMMAND echo "Reseting device"
    COMMAND STM32_Programmer_CLI -c port=SWD -rst
)

add_custom_target(clean_all
    COMMAND echo "Cleaning all build files..."
    COMMAND rm -rf ${CMAKE_CURRENT_BINARY_DIR}/*
)

add_custom_target(clean_cube
    COMMAND echo "Cleaning cube files..."
    COMMAND mv ${CMAKE_CURRENT_SOURCE_DIR}/cube/*.ioc .
    COMMAND rm -rf ${CMAKE_CURRENT_SOURCE_DIR}/cube/*
    COMMAND mv *.ioc ${CMAKE_CURRENT_SOURCE_DIR}/cube/
)

add_custom_target(rebuild
    COMMAND ${CMAKE_MAKE_PROGRAM} clean_all
    COMMAND cmake ..
    COMMAND ${CMAKE_MAKE_PROGRAM}
)

add_custom_target(rebuild_all
    COMMAND ${CMAKE_MAKE_PROGRAM} clean_cube
    COMMAND ${CMAKE_MAKE_PROGRAM} clean_all
    COMMAND cmake ..
    COMMAND ${CMAKE_MAKE_PROGRAM}
)

function(thunder_generate_format_target)
    set(FILES_LIST "")
    foreach(FILE ${ARGV})
        list(APPEND FILES_LIST ${${FILE}})
    endforeach()
    add_custom_target(format
        COMMAND uncrustify -c ${CMAKE_CURRENT_SOURCE_DIR}/uncrustify.cfg --replace --no-backup ${FILES_LIST}
    )
endfunction()

# Flash via st-link or jlink
function(thunder_generate_flash_target TARGET)
    if("${TARGET}" STREQUAL "${PROJECT_NAME}")
        set(TARGET_SUFFIX "")
    else()
        set(TARGET_SUFFIX _${TARGET})
    endif()

    add_custom_target(flash${TARGET_SUFFIX}
        COMMAND echo "Flashing..."
        COMMAND STM32_Programmer_CLI -c port=SWD -w ${TARGET}.hex -v -rst
    )

    add_dependencies(flash${TARGET_SUFFIX} ${TARGET})

    file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/.jlink-flash${TARGET_SUFFIX}
        "device ${DEVICE}\n"
        "si SWD\n"
        "speed 4000\n"
        "connect\n"
        "r\n"
        "h\n"
        "loadfile ${CMAKE_CURRENT_BINARY_DIR}/${TARGET}.hex\n"
        "r\n"
        "g\n"
        "exit\n"
    )

    add_custom_target(jflash${TARGET_SUFFIX}
        COMMAND echo "Flashing ${PROJECT_NAME}.hex with J-Link"
        COMMAND ${JLINK_EXE} ${CMAKE_CURRENT_BINARY_DIR}/.jlink-flash${TARGET_SUFFIX}
    )

    add_dependencies(jflash${TARGET_SUFFIX} ${TARGET})
endfunction()
