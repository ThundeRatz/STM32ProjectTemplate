# Name: linter.cmake
# ThundeRatz Robotics Team
# Brief: This file checks if linter was enabled and sets the proper flags
# 03/2025

###############################################################################
## Linter Check
###############################################################################

if(LINTER_MODE STREQUAL "ON")
    set(CMAKE_CXX_CLANG_TIDY "clang-tidy")
    add_compile_options(-fms-extensions)
    message(STATUS "Enabling clang-tidy")

elseif(LINTER_MODE STREQUAL "FIX")
    set(CMAKE_CXX_CLANG_TIDY "clang-tidy;--fix")
    add_compile_options(-fms-extensions)
    message(STATUS "Enabling clang-tidy with fix")

else()
    set(LINTER_MODE "OFF")
    message(STATUS "Linter is disabled")

endif()
