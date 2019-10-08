# Name: Makefile_STM
# Author: Daniel Nery Silva de Oliveira
# ThundeRatz Robotics Team
# 08/2018

###############################################################################

# Tune the lines below only if you know what you are doing:

# Project specific configurations
include config.mk

###############################################################################
## Output configuration
###############################################################################

# Verbosity
ifeq ($(VERBOSE),0)
AT := @
else
AT :=
endif

###############################################################################
## Code Optimization
###############################################################################

ifeq ($(DEBUG),1)
OPT := -Og
else
OPT := -Os
endif

###############################################################################
## Input files
###############################################################################

# Build Directory
BUILD_DIR := build

# Source Files
CUBE_SOURCES := $(shell find $(CUBE_DIR) -name "*.c")
ASM_SOURCES  := $(shell find $(CUBE_DIR) -name "*.s")
C_SOURCES    := $(shell find src -name "*.c")
C_HEADERS    := $(shell find inc -name "*.h")
LIB_SOURCES  :=
TEST_HEADERS := $(shell find $(TEST_DIR)/inc -name "*.h")
TEST_SOURCES := $(shell find $(TEST_DIR)/src -name "*.c")

ifeq ($(TEST), 1)
C_SOURCES := $(filter-out $(shell find src -name "main.c"), $(C_SOURCES))
endif

# Object Files
CUBE_OBJECTS := $(addprefix $(BUILD_DIR)/$(CUBE_DIR)/,$(notdir $(CUBE_SOURCES:.c=.o)))
CUBE_OBJECTS += $(addprefix $(BUILD_DIR)/$(CUBE_DIR)/,$(notdir $(ASM_SOURCES:.s=.o)))
OBJECTS      := $(addprefix $(BUILD_DIR)/obj/,$(notdir $(C_SOURCES:.c=.o)))
TEST_OBJECTS := $(addprefix $(BUILD_DIR)/$(TEST_DIR)/,$(notdir $(TEST_SOURCES:.c=.o)))

vpath %.c $(sort $(dir $(CUBE_SOURCES)))
vpath %.c $(sort $(dir $(C_SOURCES)))
vpath %.s $(sort $(dir $(ASM_SOURCES)))
vpath %.c $(sort $(dir $(TEST_SOURCES)))

###############################################################################
## Compiler settings
###############################################################################

# Executables
CC      := arm-none-eabi-gcc
AS      := $(CC) -x assembler-with-cpp
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

ifeq ($(DEBUG),1)
C_DEFS += -DDEBUG
endif

# Include Paths
AS_INCLUDES :=
C_INCLUDES  := $(addprefix -I,                            \
	$(sort $(dir $(C_HEADERS)))                           \
	$(sort $(dir $(shell find $(CUBE_DIR) -name "*.h")))  \
)

C_TESTS_INCLUDES := $(addprefix -I,                       \
	$(sort $(dir $(TEST_HEADERS)))                        \
)

# Adds libs sources and include directories
ifneq ($(wildcard $(LIB_DIR)/.*),)
-include $(shell find -L $(LIB_DIR) -name "sources.mk")
endif

# Libs objects
LIB_OBJECTS := $(addprefix $(BUILD_DIR)/$(LIB_DIR)/,$(notdir $(LIB_SOURCES:.c=.o)))

ifneq ($(strip $(LIB_SOURCES)),)
vpath %.c $(sort $(dir $(LIB_SOURCES)))
endif

# Compile Flags
MCUFLAGS := -mthumb
ifeq ($(DEVICE_FAMILY), $(filter $(DEVICE_FAMILY),STM32F0xx))
MCUFLAGS += -mcpu=cortex-m0
else ifeq ($(DEVICE_FAMILY), $(filter $(DEVICE_FAMILY),STM32L0xx STM32G0xx))
MCUFLAGS += -mcpu=cortex-m0plus
else ifeq ($(DEVICE_FAMILY), $(filter $(DEVICE_FAMILY),STM32F1xx STM32L1xx STM32F2xx STM32L2xx))
MCUFLAGS += -mcpu=cortex-m3
else ifeq ($(DEVICE_FAMILY), $(filter $(DEVICE_FAMILY),STM32F3xx STM32L3xx STM32F4xx STM32L4xx STM32WBxx))
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

CFLAGS :=                                   \
	$(MCUFLAGS) $(C_DEFS) $(C_INCLUDES)     \
	-Wall -Wextra -fdata-sections           \
	-ffunction-sections -fmessage-length=0  \
	$(OPT) -std=c11 -MMD -MP                \

ifneq ($(CFG_DIR),)
CFLAGS += -include $(CFG_DIR)/board/$(TARGET_BOARD).h
endif

ifeq ($(DEBUG),1)
ASFLAGS += -g
CFLAGS  += -g3
endif

TEST_CFLAGS :=                              \
	$(CFLAGS) $(C_TESTS_INCLUDES)           \

# Build target base name definition
ifeq ($(TEST), 1)
BUILD_TARGET_BASE_NAME := test_$(PROJECT_NAME)
else
BUILD_TARGET_BASE_NAME := $(PROJECT_NAME)
endif

# Linker Flags
LDSCRIPT := $(CUBE_DIR)/$(DEVICE_LD_FILE).ld

LIBS     := -lc -lm -lnosys
LIBDIR   :=
LDFLAGS  :=                                                             \
	$(MCUFLAGS) -specs=nano.specs -T$(LDSCRIPT) $(LIBDIR)               \
	$(LIBS) -Wl,-Map=$(BUILD_DIR)/$(BUILD_TARGET_BASE_NAME).map,--cref  \
	-Wl,--gc-sections                                                   \

###############################################################################
## Build Targets
###############################################################################

all: $(BUILD_DIR)/$(BUILD_TARGET_BASE_NAME).elf $(BUILD_DIR)/$(BUILD_TARGET_BASE_NAME).hex $(BUILD_DIR)/$(BUILD_TARGET_BASE_NAME).bin

# All .o file depend on respective .c file, the Makefile
# and build directory existence
$(BUILD_DIR)/$(CUBE_DIR)/%.o: %.c config.mk Makefile | $(BUILD_DIR)
	@echo "CC $<"
	$(AT)$(CC) -c $(CFLAGS) -Wno-unused-parameter -Wa,-a,-ad,-alms=$(BUILD_DIR)/$(CUBE_DIR)/$(notdir $(<:.c=.lst)) \
		-MF"$(@:.o=.d)" $< -o $@

$(BUILD_DIR)/$(LIB_DIR)/%.o: %.c config.mk Makefile | $(BUILD_DIR)
	@echo "CC $<"
	$(AT)$(CC) -c $(CFLAGS) -Wa,-a,-ad,-alms=$(BUILD_DIR)/$(LIB_DIR)/$(notdir $(<:.c=.lst)) -MF"$(@:.o=.d)" $< -o $@

$(BUILD_DIR)/obj/%.o: %.c config.mk Makefile | $(BUILD_DIR)
	@echo "CC $<"
	$(AT)$(CC) -c $(CFLAGS) -Wa,-a,-ad,-alms=$(BUILD_DIR)/obj/$(notdir $(<:.c=.lst)) -MF"$(@:.o=.d)" $< -o $@

$(BUILD_DIR)/$(CUBE_DIR)/%.o: %.s config.mk Makefile | $(BUILD_DIR)
	@echo "AS $<"
	$(AT)$(AS) -c $(ASFLAGS) $< -o $@

$(BUILD_DIR)/$(TEST_DIR)/%.o: %.c config.mk Makefile | $(BUILD_DIR)
	@echo "CC $<"
	$(AT)$(CC) -c $(TEST_CFLAGS) -Wa,-a,-ad,-alms=$(BUILD_DIR)/$(TEST_DIR)/$(notdir $(<:.c=.lst)) -MF"$(@:.o=.d)" $< -o $@

# The .elf file depend on all object files and the Makefile
$(BUILD_DIR)/$(PROJECT_NAME).elf: $(OBJECTS) $(CUBE_OBJECTS) $(LIB_OBJECTS) config.mk Makefile | $(BUILD_DIR)
	@echo "CC $@"
	$(AT)$(CC) $(OBJECTS) $(CUBE_OBJECTS) $(LIB_OBJECTS) $(LDFLAGS) -o $@
	$(AT)$(SIZE) $@

# The .elf file depend on all object files and the Makefile
$(BUILD_DIR)/test_$(PROJECT_NAME).elf: $(OBJECTS) $(TEST_OBJECTS) $(CUBE_OBJECTS) $(LIB_OBJECTS) config.mk Makefile | $(BUILD_DIR)
	@echo "CC $@"
	$(AT)$(CC) $(OBJECTS) $(TEST_OBJECTS) $(CUBE_OBJECTS) $(LIB_OBJECTS) $(LDFLAGS) -o $@
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
	$(AT)mkdir -p $@/$(LIB_DIR)
	$(AT)mkdir -p $@/$(CUBE_DIR)
	$(AT)mkdir -p $@/$(TEST_DIR)

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
.cube: config.mk Makefile
	@echo "Creating Cube script"
	@echo "config load "$(CUBE_DIR)"/"$(PROJECT_NAME)".ioc" > $@
	@echo "project generate" >> $@
	@echo "exit" >> $@

# Generate Cube Files
cube:
	$(AT)java -jar $(CUBE_JAR) "$(CUBE_DIR)"/"$(PROJECT_NAME)".ioc

# Prepare workspace
# - Erases useless Makefile, renames cube's main.c and links githooks
prepare: $(VS_LAUNCH_FILE) $(VS_C_CPP_PROPERTIES_FILE)
	@echo "Preparing cube files"
	$(AT)-mv -f $(CUBE_DIR)/Src/main.c $(CUBE_DIR)/Src/cube_main.c
	$(AT)-rm -f $(CUBE_DIR)/Makefile
	@echo "Linking githooks"
	$(AT)git config core.hooksPath .githooks

# Flash Built files with STM32CubeProgrammer
flash load:
	@echo "Flashing $(BUILD_TARGET_BASE_NAME).hex with STM32_Programmer_CLI"
	$(AT)STM32_Programmer_CLI -c port=SWD -w $(BUILD_DIR)/$(BUILD_TARGET_BASE_NAME).hex -v -rst

# Create J-Link flash script
.jlink-flash: config.mk Makefile
	@echo "Creating J-Link flash script"
	@echo device $(DEVICE) > $@
	@echo si SWD >> $@
	@echo speed 4000 >> $@
	@echo connect >> $@
	@echo r >> $@
	@echo h >> $@
	@echo loadfile $(BUILD_DIR)/$(BUILD_TARGET_BASE_NAME).hex >> $@
	@echo r >> $@
	@echo g >> $@
	@echo exit >> $@

# Flash Built files with j-link
jflash: .jlink-flash
	@echo "Flashing $(BUILD_TARGET_BASE_NAME).hex with J-Link"
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
	$(AT)-mv $(CUBE_DIR)/*.ioc .
	$(AT)-rm -rf $(CUBE_DIR)
	$(AT)-mkdir $(CUBE_DIR)
	$(AT)-mv *.ioc $(CUBE_DIR)/

# Clean build files
# - Ignores cube-related build files (ST and CMSIS libraries)
clean:
ifeq ($(TEST), 0)
	@echo "Cleaning build files"
	$(AT)-rm -rf $(OBJECTS) $(OBJECTS:.o=.d) $(OBJECTS:.o=.lst)
else
# Clean test build files
	@echo "Cleaning test build files"
	$(AT)-rm -rf $(TEST_OBJECTS) $(TEST_OBJECTS:.o=.d) $(TEST_OBJECTS:.o=.lst)
endif

# Clean all build files
clean_all:
	@echo "Cleaning all build files"
	$(AT)-rm -rf $(BUILD_DIR)

# Format source code using uncrustify
format:
	$(AT)uncrustify -c uncrustify.cfg --replace --no-backup $(C_SOURCES) $(C_HEADERS) $(TEST_HEADERS) $(TEST_SOURCES)

# Display help
help:
	@echo "----------------------- ThunderMakefile ------------------------------"
	@echo "   Bem-vindo(a) ao Makefile da ThundeRatz, cheque as configuracoes    "
	@echo "                atuais e mude o arquivo se necessario                 "
	@echo
	@echo "Opcoes:"
	@echo "	help:       mostra essa ajuda"
	@echo "	cube:       gera arquivos do cube (não funciona no momento por limitações no cube)"
	@echo "	prepare:    prepara para compilação inicial apagando arquivos do cube"
	@echo "	all:        compila todos os arquivos"
	@echo "	info:       mostra informações sobre o uC conectado"
	@echo "	flash:      carrega os arquivos compilados no microcontrolador via st-link"
	@echo "	jflash:     carrega os arquivos compilados no microcontrolador via j-link"
	@echo "	format:     formata os arquivos .c/.h"
	@echo "	clean:      limpa os arquivos compilados"
	@echo "	clean_all:  limpa os arquivos compilados, inclusive bibliotecas da ST"
	@echo "	clean_cube: limpa os arquivos gerados pelo Cube"
	@echo "	vs_files:   gera arquivos de configuração do vs code"
	@echo "	reset:      reseta o microcontrolador"
	@echo
	@echo "Configuracoes atuais:"
	@echo "	DEVICE_FAMILY  := "$(DEVICE_FAMILY)
	@echo "	DEVICE_TYPE    := "$(DEVICE_TYPE)
	@echo "	DEVICE         := "$(DEVICE)
	@echo "	DEVICE_LD_FILE := "$(DEVICE_LD_FILE)
	@echo "	DEVICE_DEF     := "$(DEVICE_DEF)

###############################################################################
## VS Code files
###############################################################################

VSCODE_FOLDER            := .vscode
VS_LAUNCH_FILE           := $(VSCODE_FOLDER)/launch.json
VS_C_CPP_PROPERTIES_FILE := $(VSCODE_FOLDER)/c_cpp_properties.json

NULL  :=
SPACE := $(NULL) #
COMMA := ,

define VS_LAUNCH
{
    "version": "0.2.0",
    "configurations": [
        {
            "type": "cortex-debug",
            "request": "launch",
            "servertype": "stutil",
            "cwd": "$${workspaceRoot}",
            "executable": "./$(BUILD_DIR)/$(BUILD_TARGET_BASE_NAME).elf",
            "name": "Cortex Debug (ST-Util)",
            "device": "$(DEVICE)",
            "v1": false
        },
        {
            "type": "cortex-debug",
            "request": "launch",
            "servertype": "jlink",
            "cwd": "$${workspaceRoot}",
            "executable": "./$(BUILD_DIR)/$(BUILD_TARGET_BASE_NAME).elf",
            "name": "Cortex Debug (J-Link)",
            "device": "$(DEVICE)",
            "interface": "swd",
        }
    ]
}
endef

define VS_CPP_PROPERTIES
{
    "configurations": [
        {
            "name": "STM32_TR",
            "includePath": [
                $(subst -I,$(NULL),$(subst $(SPACE),$(COMMA),$(strip $(foreach inc,$(C_INCLUDES) $(C_TESTS_INCLUDES),"$(inc)"))))
            ],

            "defines": [
                $(subst -D,$(NULL),$(subst $(SPACE),$(COMMA),$(strip $(foreach def,$(C_DEFS),"$(def)"))))
            ],

            "compilerPath": "$${env:ARM_GCC_PATH}/arm-none-eabi-gcc",
            "cStandard": "c99",
            "cppStandard": "c++14",
            "intelliSenseMode": "clang-x64"
        }
    ],
    "version": 4
}
endef

export VS_LAUNCH
export VS_CPP_PROPERTIES

vs_files: $(VS_LAUNCH_FILE) $(VS_C_CPP_PROPERTIES_FILE)

$(VS_LAUNCH_FILE): config.mk Makefile | $(VSCODE_FOLDER)
	$(AT)echo "$$VS_LAUNCH" > $@

$(VS_C_CPP_PROPERTIES_FILE): config.mk Makefile | $(VSCODE_FOLDER)
	$(AT)echo "$$VS_CPP_PROPERTIES" > $@

$(VSCODE_FOLDER):
	$(AT)mkdir -p $@

###############################################################################

# Include dependecy files for .h dependency detection
-include $(wildcard $(BUILD_DIR)/**/*.d)

.PHONY:                                                       \
	all cube prepare flash load jflash info reset clean_cube  \
	clean clean_all format help vs_files rtt

.DEFAULT_GOAL := all
