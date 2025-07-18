#!/usr/bin/env sh
export PATH=$PATH:../cc65-snapshot-win32/bin
export GAME=Castlevania
set -e

# Use generate_options_asm.go to create the options screen
go run utilities/generate_options_asm.go
mv options.bin ./src/options.bin
go run utilities/generate_music_credits.go
mv msu1-credits.bin ./src/msu1-credits.bin
mv options_macro_defs.asm ./src/options_macro_defs.asm
``
cd "$(dirname "$0")"

./resources/asar.exe src/spc/spc.asm src/spc/spc.bin
mkdir -p out
ca65 ./src/main.asm -o ./out/main.o -g
ld65 -C ./src/hirom.cfg -o ./out/$GAME.sfc ./out/main.o
# Copy the bytes from a specific section of the output file and save them as another file
dd if=./out/$GAME.sfc of=./src/wram_routines.bin bs=1 skip=$((0x001800)) count=$((0x800))
# rebuild the file now with the updated wram routines
ca65 ./src/main.asm -o ./out/main.o -g
ld65 -C ./src/hirom.cfg -o ./out/$GAME.sfc ./out/main.o

timestamp=`date '+%Y%m%d%H%M%S'`
cp ./out/$GAME.sfc ./out/buildarchive/$GAME-$timestamp.sfc

