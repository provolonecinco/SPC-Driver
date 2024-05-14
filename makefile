.PHONY: all clean run dir spc rom

OUTPUT := output

SRCDIR	:= src
ROM_NAME := $(OUTPUT)/sound.sfc
DBG_NAME := $(OUTPUT)/sound.dbg

SPCDIR	:= spc
SPC_ROM_NAME := $(OUTPUT)/spcdriver.bin
SPC_DBG_NAME := $(OUTPUT)/spc.dbg

OBJ_DIR := $(OUTPUT)/obj

# Specify files to build the ROM
PRG_FILES := $(wildcard $(SRCDIR)/*.s)
PRG_OBJ_FILES := $(patsubst $(SRCDIR)/%.s, $(OBJ_DIR)/%.o, $(PRG_FILES))
SPC_FILES := $(wildcard $(SPCDIR)/*.s)
SPC_OBJ_FILES := $(patsubst $(SPCDIR)/%.s, $(OBJ_DIR)/%.o, $(SPC_FILES))

all: $(SPC_ROM_NAME) $(ROM_NAME)

spc: $(SPC_ROM_NAME)

rom: $(ROM_NAME)

clean:
	@rmdir /s output

run: $(ROM_NAME)
	@Mesen.exe $(ROM_NAME)

dir:
	@md output
	@md output\obj

# Link output files into ROM
$(ROM_NAME): $(PRG_OBJ_FILES)
	ld65 --dbgfile $(DBG_NAME) -o $@ -C lorom256k.cfg $^

# Assemble 65816 code
$(OBJ_DIR)/%.o: $(SRCDIR)/%.s
	ca65 --cpu 65816 -s -g $< -o $@

# Build SPC Binary
$(SPC_ROM_NAME): $(SPC_OBJ_FILES)
	ld65 --dbgfile $(SPC_DBG_NAME) -o $@ -C spc700.cfg $^

# Assemble SPC700 code
$(OBJ_DIR)/%.o: $(SPCDIR)/%.s
	ca65 -s -g $< -o $@