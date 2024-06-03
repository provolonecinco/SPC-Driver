.PHONY: all clean dir run spc

OUTPUT := output

SRCDIR	:= src
ROM_NAME := $(OUTPUT)/sound.sfc
DBG_NAME := $(OUTPUT)/sound.dbg
OBJ_DIR := $(OUTPUT)/obj

# Specify files to build the ROM
SRC_FILES := $(wildcard $(SRCDIR)/*.s)
OBJ_FILES := $(patsubst $(SRCDIR)/%.s, $(OBJ_DIR)/%.o, $(SRC_FILES))

all: dir $(ROM_NAME)

clean:
	@rmdir /s /q output

dir:
	@mkdir output
	@mkdir output\obj

run: $(ROM_NAME)
	@start "C:\Programs\Mesen\Mesen.exe" $(ROM_NAME)

# Link output files into ROM
$(ROM_NAME): $(OBJ_FILES)
	ld65 --dbgfile $(DBG_NAME) -o $@ -C lorom256k.cfg $^

# Assemble 65816 code
$(OBJ_DIR)/%.o: $(SRCDIR)/%.s
	ca65 -s -g $< -o $@