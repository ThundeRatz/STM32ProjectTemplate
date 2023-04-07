# Name: PreLoad.cmake
# ThundeRatz Robotics Team
# Brief: This file sets the CMAKE_GENERATOR to MSYS Makefiles if a Windows OS is being used
# @see: https://stackoverflow.com/questions/11269833/cmake-selecting-a-generator-within-cmakelists-txt
# 04/2023

if(CMAKE_HOST_WIN32)
    set(CMAKE_GENERATOR "MSYS Makefiles" CACHE INTERNAL "" FORCE)
    message(STATUS "Windows Host - CMAKE_GENERATOR set to: ${CMAKE_GENERATOR}")
endif()
