# Name: Makefile_STM
# Author: Daniel Nery Silva de Oliveira
# ThundeRatz Robotics Team
# 08/2018

PROJECT_NAME = stm32_project_template

DEVICE_FAMILY := STM32F3xx
DEVICE_TYPE   := STM32F303xx
DEVICE        := STM32F303RE
DEVICE_LD     := STM32F303RETx
DEVICE_DEF    := STM32F303xE

SUBMODULE_DIR := lib

# Default values, can be set on the command line or here
DEBUG   ?= 1
VERBOSE ?= 0

###############################################################################

# Tune the lines below only if you know what you are doing:

###############################################################################
## Output configuration
###############################################################################

# Verbosity
ifeq ($(VERBOSE),0)
AT := @
else
AT :=
endif

# Optmization
ifeq ($(DEBUG),1)
OPT := -Og
else
OPT := -Os
endif

###############################################################################
## Input files
###############################################################################

# Cube Directory
CUBE_DIR := cube

# Build Directory
BUILD_DIR := build

# Source Files
CUBE_SOURCES := $(shell find $(CUBE_DIR) -name "*.c")
ASM_SOURCES  := $(shell find $(CUBE_DIR) -name "*.s")
C_SOURCES    := $(shell find src -name "*.c")
SUBM_SOURCES :=

# Object Files
CUBE_OBJECTS := $(addprefix $(BUILD_DIR)/cube/,$(notdir $(CUBE_SOURCES:.c=.o)))
CUBE_OBJECTS += $(addprefix $(BUILD_DIR)/cube/,$(notdir $(ASM_SOURCES:.s=.o)))
OBJECTS      := $(addprefix $(BUILD_DIR)/obj/,$(notdir $(C_SOURCES:.c=.o)))

vpath %.c $(sort $(dir $(CUBE_SOURCES)))

vpath %.c $(sort $(dir $(C_SOURCES)))
vpath %.s $(sort $(dir $(ASM_SOURCES)))

###############################################################################
## Compiler settings
###############################################################################

# Executables
CC      := arm-none-eabi-gcc
OBJCOPY := arm-none-eabi-objcopy
SIZE    := arm-none-eabi-size
GDB     := arm-none-eabi-gdb
HEX     := $(OBJCOPY) -O ihex
BIN     := $(OBJCOPY) -O binary -S

# Defines
AS_DEFS :=
C_DEFS  :=            \
	-DUSE_HAL_DRIVER  \
	-D$(DEVICE_DEF)   \

# Include Paths
AS_INCLUDES :=
C_INCLUDES  :=                                                         \
	-I$(CUBE_DIR)/Drivers/CMSIS/Device/ST/$(DEVICE_FAMILY)/Include     \
	-I$(CUBE_DIR)/Drivers/CMSIS/Include                                \
	-I$(CUBE_DIR)/Drivers/$(DEVICE_FAMILY)_HAL_Driver/Inc              \
	-I$(CUBE_DIR)/Drivers/$(DEVICE_FAMILY)_HAL_Driver/Inc/Legacy       \
	-I$(CUBE_DIR)/Inc                                                  \
	-Iinc                                                              \

# Adds Submodule sources and include directories
-include $(shell find $(SUBMODULE_DIR) -name "sources.mk")

# Submodule objects
SUBM_OBJECTS := $(addprefix $(BUILD_DIR)/submodules/,$(notdir $(SUBM_SOURCES:.c=.o)))

ifneq ($(strip $(SUBM_SOURCES)),)
vpath %.c $(sort $(dir $(SUBM_SOURCES)))
endif

# Compile Flags
MCUFLAGS := -mthumb
ifeq ($(DEVICE_FAMILY), $(filter $(DEVICE_FAMILY),STM32F0xx STM32L0xx))
MCUFLAGS += -mcpu=cortex-m0
else ifeq ($(DEVICE_FAMILY), $(filter $(DEVICE_FAMILY),STM32F1xx STM32L1xx STM32F2xx STM32L2xx))
MCUFLAGS += -mcpu=cortex-m3
else ifeq ($(DEVICE_FAMILY), $(filter $(DEVICE_FAMILY),STM32F3xx STM32L3xx STM32F4xx STM32L4xx))
MCUFLAGS += -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=hard
else ifeq ($(DEVICE_FAMILY), $(filter $(DEVICE_FAMILY),STM32F7xx STM32L7xx))
MCUFLAGS += -mcpu=cortex-m7 -mfpu=fpv4-sp-d16 -mfloat-abi=hard
else
$(error Unknown Device Family $(DEVICE_FAMILY))
endif

# Generic flags
ASFLAGS :=                                 \
	$(MCUFLAGS) $(AS_DEFS) $(AS_INCLUDES)  \
	-Wall -Wextra -fdata-sections          \
	-ffunction-sections $(OPT)             \

CFLAGS  :=                                  \
	$(MCUFLAGS) $(C_DEFS) $(C_INCLUDES)     \
	-Wall -Wextra -fdata-sections           \
	-ffunction-sections -fmessage-length=0  \
	$(OPT) -std=c11 -MMD -MP                \

ifeq ($(DEBUG),1)
ASFLAGS += -g
CFLAGS  += -g3
endif

# Linker Flags
LDSCRIPT := $(CUBE_DIR)/$(DEVICE_LD)_FLASH.ld

LIBS     := -lc -lm -lnosys
LIBDIR   :=
LDFLAGS  :=                                                   \
	$(MCUFLAGS) -specs=nano.specs -T$(LDSCRIPT) $(LIBDIR)     \
	$(LIBS) -Wl,-Map=$(BUILD_DIR)/$(PROJECT_NAME).map,--cref  \
	-Wl,--gc-sections                                         \

###############################################################################
## Build Targets
###############################################################################

all: $(BUILD_DIR)/$(PROJECT_NAME).elf $(BUILD_DIR)/$(PROJECT_NAME).hex $(BUILD_DIR)/$(PROJECT_NAME).bin

# All .o file depend on respective .c file, the Makefile
# and build directory existence
$(BUILD_DIR)/cube/%.o: %.c Makefile | $(BUILD_DIR)
	@echo "CC $<"
	$(AT)$(CC) -c $(CFLAGS) -Wa,-a,-ad,-alms=$(BUILD_DIR)/cube/$(notdir $(<:.c=.lst)) -MF"$(@:.o=.d)" $< -o $@

$(BUILD_DIR)/submodules/%.o: %.c Makefile | $(BUILD_DIR)
	@echo "CC $<"
	$(AT)$(CC) -c $(CFLAGS) -Wa,-a,-ad,-alms=$(BUILD_DIR)/submodules/$(notdir $(<:.c=.lst)) -MF"$(@:.o=.d)" $< -o $@

$(BUILD_DIR)/obj/%.o: %.c Makefile | $(BUILD_DIR)
	@echo "CC $<"
	$(AT)$(CC) -c $(CFLAGS) -Wa,-a,-ad,-alms=$(BUILD_DIR)/obj/$(notdir $(<:.c=.lst)) -MF"$(@:.o=.d)" $< -o $@

$(BUILD_DIR)/cube/%.o: %.s Makefile | $(BUILD_DIR)
	@echo "CC $<"
	$(AT)$(CC) -x assembler-with-cpp -c $(CFLAGS) -MF"$(@:%.o=%.d)" $< -o $@

# The .elf file depend on all object files and the Makefile
$(BUILD_DIR)/$(PROJECT_NAME).elf: $(OBJECTS) $(CUBE_OBJECTS) $(SUBM_OBJECTS) Makefile | $(BUILD_DIR)
	@echo "CC $@"
	$(AT)$(CC) $(OBJECTS) $(CUBE_OBJECTS) $(SUBM_OBJECTS) $(LDFLAGS) -o $@
	$(AT)$(SIZE) $@

# The .hex file depend on the .elf file and build directory existence
$(BUILD_DIR)/%.hex: $(BUILD_DIR)/%.elf | $(BUILD_DIR)
	@echo "Creating $@"
	$(AT)$(HEX) $< $@

# The .bin file depend on the .elf file and build directory existence
$(BUILD_DIR)/%.bin: $(BUILD_DIR)/%.elf | $(BUILD_DIR)
	@echo "Creating $@"
	$(AT)$(BIN) $< $@

# Create the build_dir
$(BUILD_DIR):
	@echo "Creating build directory"
	$(AT)mkdir -p $@
	$(AT)mkdir -p $@/obj
	$(AT)mkdir -p $@/submodules
	$(AT)mkdir -p $@/cube

###############################################################################
## OS dependent commands
###############################################################################

ifeq ($(OS),Windows_NT)
CUBE_JAR  := "$(CUBE_PATH)\STM32CubeMX.exe"
JLINK_EXE := JLink.exe
else
CUBE_JAR  := "$(CUBE_PATH)/STM32CubeMX"
JLINK_EXE := JLinkExe
endif

ifndef CUBE_PATH
$(error 'CUBE_PATH not defined')
endif

###############################################################################
## Auxiliary Targets
###############################################################################

# Create cube script
.cube: Makefile
	@echo "Creating Cube script"
	@echo "config load "$(CUBE_DIR)"/"$(PROJECT_NAME)".ioc" >> $@
	@echo "project generate" >> $@
	@echo "exit" >> $@

# Generate Cube Files
cube: .cube
	$(AT)java -jar $(CUBE_JAR) -q $<

# Prepare workspace
# - Erases useless Makefile, renames cube's main.c and links githooks
prepare:
	@echo "Linking githooks"
	$(AT)git config core.hooksPath .githooks
	@echo "Preparing cube files"
	$(AT)-mv -f $(CUBE_DIR)/Src/main.c $(CUBE_DIR)/Src/cube_main.c
	$(AT)-rm -f $(CUBE_DIR)/Makefile

# Flash Built files with st-flash
flash load:
	@echo "Flashing $(PROJECT_NAME).bin with STM32_Programmer_CLI"
	$(AT)STM32_Programmer_CLI -c port=SWD -w $(BUILD_DIR)/$(PROJECT_NAME).bin \
		0x08000000 -v -rst

# Create J-Link flash script
.jlink-flash: Makefile
	@echo "Creating J-Link flash script"
	@echo device $(DEVICE) > $@
	@echo si SWD >> $@
	@echo speed 4000 >> $@
	@echo connect >> $@
	@echo r >> $@
	@echo h >> $@
	@echo loadfile $(BUILD_DIR)/$(PROJECT_NAME).hex >> $@
	@echo r >> $@
	@echo g >> $@
	@echo exit >> $@

# Flash Built files with j-link
jflash: .jlink-flash
	@echo "Flashing $(PROJECT_NAME).hex with J-Link"
	$(AT)$(JLINK_EXE) $<

# Show MCU info
info:
	$(AT)STM32_Programmer_CLI -c port=SWD

# Reset MCU
reset:
	@echo "Reseting device"
	$(AT)STM32_Programmer_CLI -c port=SWD -rst

# Clean cube generated files
clean_cube:
	@echo "Cleaning cube files"
	$(AT)-mv $(CUBE_DIR)/$(PROJECT_NAME).ioc .
	$(AT)-rm -rf $(CUBE_DIR)
	$(AT)-mkdir $(CUBE_DIR)
	$(AT)-mv $(PROJECT_NAME).ioc $(CUBE_DIR)/

# Clean build files
# - Ignores cube-related build files (ST and CMSIS libraries)
clean:
	@echo "Cleaning build files"
	$(AT)-rm -rf $(OBJECTS) $(OBJECTS:.o=.d) $(OBJECTS:.o=.lst)

# Clean all build files
clean_all:
	@echo "Cleaning all build files"
	$(AT)-rm -rf $(BUILD_DIR)

# Format source code
format:
	@echo "Formatting files"
	$(AT)clang-format -i $(C_SOURCES) $(wildcard */*.h)
	@echo "Done"

# Display help
help:
	@echo "----------------------- ThunderMakefile ------------------------------"
	@echo "   Bem-vindo(a) ao Makefile da ThundeRatz, cheque as configuracoes    "
	@echo "                atuais e mude o arquivo se necessario                 "
	@echo
	@echo "Opcoes:"
	@echo "	help:       mostra essa ajuda"
	@echo "	cube:       gera arquivos do cube"
	@echo "	prepare:    prepara para compilação inicial apagando arquivos do cube"
	@echo "	all:        compila todos os arquivos"
	@echo "	info:       mostra informações sobre o uC conectado"
	@echo "	flash:      carrega os arquivos compilados no microcontrolador via st-link"
	@echo "	jflash:     carrega os arquivos compilados no microcontrolador via j-link"
	@echo "	format:     formata os arquivos .c/.h"
	@echo "	clean:      limpa os arquivos compilados"
	@echo "	clean_all:  limpa os arquivos compilados, inclusive bibliotecas da ST"
	@echo "	clean_cube: limpa os arquivos gerados pelo Cube"
	@echo
	@echo "Configuracoes atuais:"
	@echo "	DEVICE_FAMILY := "$(DEVICE_FAMILY)
	@echo "	DEVICE_TYPE   := "$(DEVICE_TYPE)
	@echo "	DEVICE        := "$(DEVICE)
	@echo "	DEVICE_LD     := "$(DEVICE_LD)
	@echo "	DEVICE_DEF    := "$(DEVICE_DEF)

# Include dependecy files for .h dependency detection
-include $(wildcard $(BUILD_DIR)/**/*.d)

.PHONY: all cube prepare flash load jflash info reset clean_cube clean clean_all format help
