# Name: Makefile_STM
# Author: Daniel Nery Silva de Oliveira
# ThundeRatz Robotics Team
# 08/2018

# Modify this values according to the project

# This variables tell the compiler which settings use according to
# the respective device

DEVICE_FAMILY := STM32F3xx
DEVICE_TYPE   := STM32F303xx
DEVICE        := STM32F303RE
DEVICE_LD     := STM32F303RETx
DEVICE_DEF    := STM32F303xE

SUBMODULE_DIR := lib
SUBMODULES    := STMSensors/LSM6DS3 STMSensors/VL53L0X

TARGET = main

# Default values, can be set on the command line or here
DEBUG   ?= 1
VERBOSE ?= 0

# 	If DEBUG=0 ...
# 	If VERBOSE=1 all comands shall be displayed along the
# Makefile messages. Otherwise, command calls will be hidden

######################################################################

include ./Makefile.include
include ./Makefile.targets
