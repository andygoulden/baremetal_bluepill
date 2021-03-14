PROJECT_ROOT := $(shell pwd)

# Location of ARM GCC toolchain binaries
TOOLSPATH ?= /opt/gcc-arm-none-eabi-10-2020-q4-major/bin

# STM32 board specification
ARMCPU   := cortex-m3
STM32MCU := STM32F103x6
LINKERSCRIPT = scripts/STM32F103X6_FLASH.ld

# Project directories
SRCDIR   := src
INCDIR   := inc
ASMDIR   := startup
CMSISDIR := cmsis
BUILDDIR := build

# Set app name for output files
APP_NAME := blinky

# Source files (C and assembly)
SRC := $(wildcard $(SRCDIR)/*.c)
ASM := $(wildcard $(ASMDIR)/*.s)

# Header files
INCLUDE  = -I$(INCDIR)
INCLUDE += -I$(CMSISDIR)

# Compiler flags
CFLAGS  := -std=c99 
CFLAGS	+= -Wall 
CFLAGS	+= -fno-common 
CFLAGS	+= -mthumb 
CFLAGS	+= -mcpu=$(ARMCPU) 
CFLAGS	+= -D$(STM32MCU) 
CFLAGS	+= -Wa,-ahlms=$(addprefix $(BUILDDIR)/,$(notdir $(<:.c=.lst)))
CFLAGS	+= $(INCLUDE)
CFLAGS	+= -g

# Linker flags
LDFLAGS := -T$(LINKERSCRIPT)
LDFLAGS	+= -mthumb 
LDFLAGS	+= -mcpu=$(ARMCPU)
LDFLAGS += --specs=nosys.specs
LDFLAGS += --specs=nano.specs
LDFLAGS += -lc
LDFLAGS += -Wl,-Map=$(BUILDDIR)/$(APP_NAME).map

# Toolchain binaries
CC       := $(TOOLSPATH)/arm-none-eabi-gcc
AS       := $(TOOLSPATH)/arm-none-eabi-as
LD       := $(TOOLSPATH)/arm-none-eabi-ld
OBJCOPY  := $(TOOLSPATH)/arm-none-eabi-objcopy
SIZE     := $(TOOLSPATH)/arm-none-eabi-size
OBJDUMP  := $(TOOLSPATH)/arm-none-eabi-objdump
RM       := rm -rf

# Objects to build
OBJ := $(addprefix $(BUILDDIR)/,$(notdir $(SRC:.c=.o)))
OBJ += $(addprefix $(BUILDDIR)/,$(notdir $(ASM:.s=.o)))

.DEFAULT_GOAL := app

app: $(BUILDDIR)/$(APP_NAME).bin

# Rule to delete build artefacts
.PHONY: clean
clean:
	$(RM) $(BUILDDIR)

# Create object files from source files
$(BUILDDIR)/%.o: $(SRCDIR)/%.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILDDIR)/%.o: $(ASMDIR)/%.s
	@mkdir -p $(dir $@)
	$(AS) $(ASFLAGS) -o $@ $<

# Link binaries
$(BUILDDIR)/$(APP_NAME).hex: $(BUILDDIR)/$(APP_NAME).elf
	$(OBJCOPY) -R .stack -O ihex $(BUILDDIR)/$(APP_NAME).elf $(BUILDDIR)/$(APP_NAME).hex

$(BUILDDIR)/$(APP_NAME).bin: $(BUILDDIR)/$(APP_NAME).elf
	$(OBJCOPY) -R .stack -O binary $(BUILDDIR)/$(APP_NAME).elf $(BUILDDIR)/$(APP_NAME).bin

$(BUILDDIR)/$(APP_NAME).elf: $(OBJ)
	@mkdir -p $(dir $@)
	$(CC) $(OBJ) $(LDFLAGS) -o $(BUILDDIR)/$(APP_NAME).elf
	$(OBJDUMP) -D $(BUILDDIR)/$(APP_NAME).elf > $(BUILDDIR)/$(APP_NAME).lst
	$(SIZE) $(BUILDDIR)/$(APP_NAME).elf
