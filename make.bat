ca65 -g src/spc/spc.asm -o output/debug/spc.o
ld65 -C spc700.cfg --dbgfile output/debug/spc.dbg output/debug/spc.o -o output/spcdriver.bin

ca65 --cpu 65816 -g header.asm -o output/debug/sound.o
ld65 -C lorom256k.cfg --dbgfile output/debug/sound.dbg output/debug/sound.o -o output/sound.sfc

pause