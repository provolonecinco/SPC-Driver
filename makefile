.PHONY: all clean dir run

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

all: dir $(SPC_ROM_NAME) $(ROM_NAME)

clean:
	@rmdir /s /q output

dir:
	@mkdir output
	@mkdir output\obj

run: $(ROM_NAME)
	@start "C:\Programs\Mesen\Mesen.exe" $(ROM_NAME)

# Link output files into ROM
$(ROM_NAME): $(PRG_OBJ_FILES)
	@ld65 --dbgfile $(DBG_NAME) -o $@ -C lorom256k.cfg $^

# Assemble 65816 code
$(OBJ_DIR)/%.o: $(SRCDIR)/%.s
	@ca65 --cpu 65816 -s -g $< -o $@

# Make SPC Binary
$(SPC_ROM_NAME): $(SPC_OBJ_FILES)
	@ld65 --dbgfile $(SPC_DBG_NAME) -o $@ --obj-path output/obj -C spc700.cfg spc.o comm.o player.o opcode.o

# Assemble SPC700 code
$(OBJ_DIR)/%.o: $(SPCDIR)/%.s
	@ca65 -s -g spc/spc.s -o $@
	@ca65 -s -g spc/comm.s -o $@
	@ca65 -s -g spc/player.s -o $@
	@ca65 -s -g spc/opcode.s -o $@