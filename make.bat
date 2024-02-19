ca65 -g src/spc/spc.asm -o output/spc.o
ld65 -C spc.cfg --dbgfile output/spc.dbg output/spc.o -o src/spc/driver.bin

ca65 --cpu 65816 -g header.asm -o output/sound.o
ld65 -m map.txt -C lorom256k.cfg --dbgfile output/sound.dbg output/sound.o -o output/sound.sfc

pause