# Name: config.mk
# Author: Daniel Nery Silva de Oliveira
# ThundeRatz Robotics Team
# 06/2019

# Cube file name without .ioc extension
PROJECT_NAME = stm32_project_template
VERSION := v1

PROJECT_RELEASE := $(PROJECT_NAME)_$(VERSION)

TARGET_BOARD := target_$(PROJECT_RELEASE)

DEVICE_FAMILY  := STM32F3xx
DEVICE_TYPE    := STM32F303xx
DEVICE_DEF     := STM32F303xE
DEVICE         := STM32F303RE

# Linker script file without .ld extension
# Find it on cube folder after code generation
DEVICE_LD_FILE := STM32F303RETx_FLASH

# Lib dir
LIB_DIR  := lib

# Cube Directory
CUBE_DIR := cube

# Config Files Directory
CFG_DIR :=

# Tests Directory
TEST_DIR := tests

# Default values, can be set on the command line or here
DEBUG   ?= 1
VERBOSE ?= 0

TEST_NAME ?=
