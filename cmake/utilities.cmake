###############################################################################
## Utilities Functions
###############################################################################

# This function adds a target with name '${TARGET}_always_display_size'. The new
# target builds a TARGET and then calls the program defined in CMAKE_SIZE to
# display the size of the final ELF.
function(print_size_of_target TARGET)
    add_custom_command(
        TARGET ${TARGET}
        POST_BUILD
        COMMAND ${CMAKE_SIZE} "$<TARGET_FILE:${TARGET}>"
        COMMENT "Target Sizes: "
    )
endfunction()

# This function calls the objcopy program defined in CMAKE_OBJCOPY to generate
# file with object format specified in OBJCOPY_BFD_OUTPUT.
# The generated file has the name of the target output but with extension
# corresponding to the OUTPUT_EXTENSION argument value.
# The generated file will be placed in the same directory as the target output file.
function(_generate_file TARGET OUTPUT_EXTENSION OBJCOPY_BFD_OUTPUT)
    # If linter is enabled, do not generate files
    if(LINTER_MODE STREQUAL "ON" OR LINTER_MODE STREQUAL "FIX")
        return()
    endif()

    set(OUTPUT_FILE_NAME "${TARGET}.${OUTPUT_EXTENSION}")

    add_custom_command(
        TARGET ${TARGET}
        POST_BUILD
        COMMAND ${CMAKE_OBJCOPY} -O ${OBJCOPY_BFD_OUTPUT} "$<TARGET_FILE:${TARGET}>" ${OUTPUT_FILE_NAME}
        BYPRODUCTS ${OUTPUT_FILE_NAME}
        COMMENT "Generating ${OBJCOPY_BFD_OUTPUT} file ${OUTPUT_FILE_NAME}"
    )
endfunction()

# This function adds post-build generation of the binary file from the target ELF.
# The generated file will be placed in the same directory as the ELF file.
function(generate_binary_file TARGET)
    _generate_file(${TARGET} "bin" "binary")
endfunction()

# This function adds post-build generation of the Motorola S-record file from the target ELF.
# The generated file will be placed in the same directory as the ELF file.
function(generate_srec_file TARGET)
    _generate_file(${TARGET} "srec" "srec")
endfunction()

# This function adds post-build generation of the Intel hex file from the target ELF.
# The generated file will be placed in the same directory as the ELF file.
function(generate_hex_file TARGET)
    _generate_file(${TARGET} "hex" "ihex")
endfunction()

function(generate_helpme_text)
    set(input_file "${CMAKE_CURRENT_SOURCE_DIR}/cmake/templates/helpme.in")
    set(output_save_file "${CMAKE_CURRENT_BINARY_DIR}/helpme")
    configure_file(${input_file} ${output_save_file})
endfunction()

function(generate_vscode_tasks_json)
    set(input_file "${CMAKE_CURRENT_SOURCE_DIR}/cmake/templates/tasks.json.in")
    set(output_save_file "${CMAKE_CURRENT_SOURCE_DIR}/.vscode/tasks.json")
    configure_file(${input_file} ${output_save_file})
endfunction()
