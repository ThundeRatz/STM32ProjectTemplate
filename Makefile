# Name: Makefile_STM
# Author: Daniel Nery Silva de Oliveira
# ThundeRatz Robotics Team
# 08/2018

DEVICE_FAMILY := STM32F3xx
DEVICE_TYPE   := STM32F303xx
DEVICE        := STM32F303RE
DEVICE_LD     := STM32F303RETx
DEVICE_DEF    := STM32F303xE

TARGET = main

DEBUG   ?= 1
VERBOSE ?= 0

######################################################################

# Tune the lines below only if you know what you are doing:

# Verbosity
ifeq ($(VERBOSE), 0)
AT := @
else
AT :=
endif

# Optmization
ifeq ($(DEBUG), 1)
OPT := -Og
else
OPT := -Os
endif

# Build Directory
BUILD_DIR := build

# Source Files
CUBE_SOURCES := $(wildcard cube/*/*.c) $(wildcard cube/*/*/*/*.c)
ASM_SOURCES  := $(wildcard cube/*.s)

C_SOURCES    := $(wildcard src/*.c)

# Executables
CC      := arm-none-eabi-gcc
OBJCOPY := arm-none-eabi-objcopy
SIZE    := arm-none-eabi-size
GDB     := arm-none-eabi-gdb
HEX     := $(OBJCOPY) -O ihex
BIN     := $(OBJCOPY) -O binary -S

# Defines
AS_DEFS :=
C_DEFS  := -DUSE_HAL_DRIVER -D$(DEVICE_DEF)

# Include Paths
AS_INCLUDES :=
C_INCLUDES  :=                                              \
	-Icube/Drivers/CMSIS/Device/ST/$(DEVICE_FAMILY)/Include \
	-Icube/Drivers/CMSIS/Include                            \
	-Icube/Drivers/$(DEVICE_FAMILY)_HAL_Driver/Inc          \
	-Icube/Drivers/$(DEVICE_FAMILY)_HAL_Driver/Inc/Legacy   \
	-Icube/Inc                                              \
	-Iinc                                                   \

# Compile Flags
FLAGS := -mthumb
ifeq ($(DEVICE_FAMILY), $(filter $(DEVICE_FAMILY),STM32F0xx STM32L0xx))
FLAGS += -mcpu=cortex-m0
else ifeq ($(DEVICE_FAMILY), $(filter $(DEVICE_FAMILY),STM32F1xx STM32L1xx STM32F2xx STM32L2xx))
FLAGS += -mcpu=cortex-m3
else ifeq ($(DEVICE_FAMILY), $(filter $(DEVICE_FAMILY),STM32F3xx STM32L3xx STM32F4xx STM32L4xx))
FLAGS += -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=hard
else ifeq ($(DEVICE_FAMILY), $(filter $(DEVICE_FAMILY),STM32F7xx STM32L7xx))
FLAGS += -mcpu=cortex-m7 -mfpu=fpv4-sp-d16 -mfloat-abi=hard
else
$(error Unknown Device Family $(DEVICE_FAMILY))
endif

ASFLAGS := $(FLAGS) $(AS_DEFS) $(AS_INCLUDES) -Wall -Wextra -fdata-sections -ffunction-sections $(OPT)
CFLAGS  :=                                 \
	$(FLAGS) $(C_DEFS) $(C_INCLUDES)       \
	-Wall -Wextra -fdata-sections          \
	-ffunction-sections -fmessage-length=0 \
	$(OPT) -std=c11 -MMD -MP               \

ifeq ($(DEBUG), 1)
CFLAGS += -g3
endif

# Linker Flags
LDSCRIPT := cube/$(DEVICE_LD)_FLASH.ld

LIBS     := -lc -lm -lnosys
LIBDIR   :=
LDFLAGS  :=                                            \
	$(FLAGS) -specs=nano.specs -T$(LDSCRIPT) $(LIBDIR) \
	$(LIBS) -Wl,-Map=$(BUILD_DIR)/$(TARGET).map,--cref \
	-Wl,--gc-sections                                  \

# Object Files
CUBE_OBJECTS := $(addprefix $(BUILD_DIR)/,$(notdir $(CUBE_SOURCES:.c=.o)))
CUBE_OBJECTS += $(addprefix $(BUILD_DIR)/,$(notdir $(ASM_SOURCES:.s=.o)))
OBJECTS      := $(addprefix $(BUILD_DIR)/,$(notdir $(C_SOURCES:.c=.o)))

vpath %.c $(sort $(dir $(CUBE_SOURCES)))
vpath %.c $(sort $(dir $(C_SOURCES)))
vpath %.s $(sort $(dir $(ASM_SOURCES)))

######################################################################
## Build Targets
######################################################################

all: $(BUILD_DIR)/$(TARGET).elf $(BUILD_DIR)/$(TARGET).hex $(BUILD_DIR)/$(TARGET).bin

$(BUILD_DIR)/%.o: %.c Makefile | $(BUILD_DIR)
	@echo "CC $<"
	$(AT)$(CC) -c $(CFLAGS) -Wa,-a,-ad,-alms=$(BUILD_DIR)/$(notdir $(<:.c=.lst)) -MF"$(@:.o=.d)" $< -o $@

$(BUILD_DIR)/%.o: %.s Makefile | $(BUILD_DIR)
	@echo "CC $<"
	$(AT)$(CC) -x assembler-with-cpp -c $(CFLAGS) -MF"$(@:%.o=%.d)" $< -o $@

$(BUILD_DIR)/$(TARGET).elf: $(OBJECTS) $(CUBE_OBJECTS) Makefile
	@echo "CC $@"
	$(AT)$(CC) $(OBJECTS) $(CUBE_OBJECTS) $(LDFLAGS) -o $@
	@$(SIZE) $@

$(BUILD_DIR)/%.hex: $(BUILD_DIR)/%.elf | $(BUILD_DIR)
	@echo "Creating $@"
	$(AT)$(HEX) $< $@

$(BUILD_DIR)/%.bin: $(BUILD_DIR)/%.elf | $(BUILD_DIR)
	@echo "Creating $@"
	$(AT)$(BIN) $< $@

$(BUILD_DIR):
	@echo "Creating build directory"
	@mkdir -p $@

######################################################################
## Auxiliary Targets
######################################################################

ifndef CUBE_PATH
$(error 'CUBE_PATH not defined')
endif

# Generate Cube Files
cube:
ifeq ($(OS),Windows_NT)
	@java -jar "$(CUBE_PATH)\STM32CubeMX.exe" -q .cube
else
	@java -jar "$(CUBE_PATH)/STM32CubeMX" -q .cube
endif

# Prepare for compilation
# - Erases useless Makefile and duplicate main.c
prepare:
	@echo "Preparing cube files"
	@-rm -f cube/Src/main.c cube/Makefile

# Flashes Built files with st-flash
flash load:
	@echo "Flashing $(TARGET).bin"
	@st-flash --reset write $(BUILD_DIR)/$(TARGET).bin 0x08000000

# Flashes Built files with j-link
jflash:
	@echo "Flashing $(TARGET).hex with J-Link"
	@echo "device $(DEVICE)\nsi SWD\nspeed 4000\nconnect\nr\nh\nloadfile $(BUILD_DIR)/$(TARGET).hex\nr\ng\nexit" > .jlink-flash
ifeq ($(OS),Windows_NT)
	@JLink.exe .jlink-flash
else
	@JLinkExe .jlink-flash
endif

info:
	@st-info --probe

reset:
	@echo "Reseting device"
	@st-flash reset

# Clean cube generated files
clean_cube:
	@echo "Cleaning cube files"
	@-rm -rf cube/Src cube/Inc cube/Drivers cube/.mxproject cube/Makefile cube/*.s cube/*.ld

# Clean build files
# - Ignores cube-related build files (ST and CMSIS libraries)
clean:
	@echo "Cleaning build files"
	@-rm -rf $(OBJECTS) $(OBJECTS:.o=.d) $(OBJECTS:.o=.lst)

# Clean all build files
clean_all:
	@echo "Cleaning all build files"
	@-rm -rf $(BUILD_DIR)

# Format source code
format:
	@echo "Formatting files"
	@clang-format -i $(C_SOURCES) $(wildcard */*.h)
	@echo "Done"

# Display help
help:
	@echo "----------------------- ThunderMakefile ------------------------------"
	@echo "   Bem-vindo(a) ao Makefile da ThundeRatz, cheque as configuracoes    "
	@echo "                atuais e mude o arquivo se necessario                 "
	@echo
	@echo "Opcoes:"
	@echo "	help:       mostra essa ajuda;"
	@echo "	cube:       gera arquivos do cube;"
	@echo "	prepare:    prepara para compilação inicial apagando arquivos do cube;"
	@echo "	all:        compila todos os arquivos;"
	@echo "	info:       mostra informações sobre o uC conectado;"
	@echo "	flash:      carrega os arquivos compilados no microcontrolador via st-link"
	@echo "	jflash:     carrega os arquivos compilados no microcontrolador via j-link"
	@echo "	format:     formata os arquivos .c/.h;"
	@echo "	clean:      limpa os arquivos compilados;"
	@echo "	clean_all:  limpa os arquivos compilados, inclusive bibliotecas da ST;"
	@echo "	clean_cube: limpa os arquivos gerados pelo Cube."
	@echo
	@echo "Configuracoes atuais:"
	@echo "	DEVICE_FAMILY := $(DEVICE_FAMILY)"
	@echo "	DEVICE_TYPE   := $(DEVICE_TYPE)"
	@echo "	DEVICE        := $(DEVICE)"
	@echo "	DEVICE_LD     := $(DEVICE_LD)"
	@echo "	DEVICE_DEF    := $(DEVICE_DEF)"
	@echo "	TARGET = $(TARGET)"
	@echo "	DEBUG = $(DEBUG)"

# Include dependecy files for .h dependency detection
-include $(wildcard $(BUILD_DIR)/*.d)

.PHONY: clean all flash jflash help reset \
		format clean_all prepare cube info
