:: build SPC driver binary
ca65 --debug-info spc/spc.asm -o output/obj/spc.o
ld65 -C spc700.cfg --dbgfile output/debug/spc.dbg output/obj/spc.o -o output/spcdriver.bin

:: build SNES ROM
ca65 --cpu 65816 -s -g src/header.asm -o output/obj/header.o
ca65 --cpu 65816 -s -g src/init.asm -o output/obj/init.o
ca65 --cpu 65816 -s -g src/main.asm -o output/obj/main.o
ca65 --cpu 65816 -s -g src/gfx.asm -o output/obj/gfx.o
ca65 --cpu 65816 -s -g src/nmi.asm -o output/obj/nmi.o
ca65 --cpu 65816 -s -g src/spc_comm.asm -o output/obj/spc_comm.o

ld65 -C lorom256k.cfg --dbgfile output/debug/sound.dbg --obj-path output/obj header.o init.o main.o gfx.o nmi.o spc_comm.o -o output/sound.sfc

start mesen.exe output/sound.sfc