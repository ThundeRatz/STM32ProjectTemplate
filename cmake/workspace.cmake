# Name: workspace.cmake
# ThundeRatz Robotics Team
# Brief: CMake file to generate VS Code files and link githooks
# 04/2023

###############################################################################
## VS Code files
###############################################################################

message(STATUS "Configuring VS Code files")
configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake/templates/launch.json.in ${LAUNCH_JSON_PATH}
)

###############################################################################
## Link Githooks
###############################################################################

message(STATUS "Linking githooks")
execute_process(
    COMMAND git config core.hooksPath ${CMAKE_CURRENT_SOURCE_DIR}/.githooks
)
