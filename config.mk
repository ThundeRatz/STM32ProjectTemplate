# Name: Makefile_STM
# Author: Daniel Nery Silva de Oliveira
# ThundeRatz Robotics Team
# 06/2019

# Cube file name without .ioc extension
PROJECT_NAME = stm32_project_template

DEVICE         := STM32F303RE
DEVICE_TYPE    := STM32F303xx
DEVICE_FAMILY  := STM32F3xx
DEVICE_DEF     := STM32F303xE

# Linker script file without .ld extension
# Find it on cube folder after code generation
DEVICE_LD_FILE := STM32F303RETx_FLASH

# Lib dir
LIB_DIR  := lib

# Cube Directory
CUBE_DIR := cube

# Default values, can be set on the command line or here
DEBUG   ?= 1
VERBOSE ?= 0
