## Castlevania SNES Port - V 1.0

This is a 1:1 port of the NES version of Castlevania, running on the SNES. It is utilizing FastROM/HiROM.

This has been tested in Mesen2, MiSTer, on original hardware via FxPak Pro, as well as a physical cart using a MouseBite Labs HiRom board.

NES sytle music is provided via Memblers 2A03 Emulator.

## Additional Features

MSU-1 Audio music is supported.  If your platform supports MSU-1 Audio, there are 6 included packs available.

Additionally, the following Quality of Life options are available:
1. Difficulty Levels
  a. Normal - This is the standard NES game difficulty
  b. Easy - Easy mode from the FC Cartridge version:
        i. 9 lives
       ii. 30 hearts to start
      iii. no knockback
       iv. Keep your weapons / multiplier on pick of a new weapon and on death
        v. Less damage taken from bosses and enemies
       vi. Bosses take double damage from you
  c. Hard - Hard mode from the VS. Castlevania arcade cabinet
        i. you take more damage
       ii. timers are much shorter
      iii. good luck
2. Ability to start on the 2nd loop of the game
3. 14 different palettes to choose from.  you can select it on the intro options, or while paused you can press SELECT to cylce through them.
4. 6 MSU-1 Soundtracks - If you're on a platform that supports MSU-1 (MiSTer, FxPakPro, etc).  You can choose the soundtrack on the intro options or while paused with the L button.
5. A & X buttons will fire your subweapons
6. You can now hold a 2nd subweapon and swap with the R button.  Upon pickup up a subweapon, your current weapon (with it's multipler) will swap out.  Press R to swap back and forth between them.
7. Initial Rumble support.  If you have access to a rumble controller, various events in the game will provide tactile feedback!

## MSU-1 Track List
Track Indexes:
00 - Prologue
01 - Vampire Killier (Stage 1)
02 - Stalker (Stage 2 & 4-2)
03 - Wicked Child (Stage 3)
04 - Walking the Edge (Stage 4)
05 - Heart of Fire (Stage 5)
06 - Out of Time (Stage 6)
07 - Nothing to Lose (Stage 7)
08 - Poison Mind (Boss)
09 - Black Night (Last Boss)
10 - All Clear (no looping)
11 - Voyager (Ending)
12 - Stage Clear (no looping)
13 - Game Over (no looping)
14 - Lose Life (no looping)
15 - Underground (menu theme)

Additionally, this romhack supports 6 playlists.  For each playlist after the first, add 16 to each track number for the next playlist (1-15, 16-31, 32-47, etc)

Included are 6 sets of PCMs for Life Force:
Orchestral Cover - Video Game Music Revisited, Evelyn Lark
Prog Metal - Aaron Lehnen "MnG"
Chronicles Arrange - Konami
Famicom VRC6 - Yone2008
MSX SCC - Jan Van Valburg, sl3DZ
Adlib OPL2 - MelonadeM

PCM Packs have been arranged and leveled by Batty

## Prerequisites

* [cc65](https://www.cc65.org/) - the 65c816 compiler and linker
* [Go](https://go.dev/) - Go is used for a few useful scripts/tools


## Other Userful Tools I've used for this project

* [Mesen2](https://github.com/SourMesen/Mesen2) - A fantastic emulator for development on a bunch of platforms
* [HxD](https://mh-nexus.de/en/hxd/) - A Hex Editor
* [Visual Studio Code](https://code.visualstudio.com/) - Used as the development environment

## Structure of the Project

* `bankX.asm` - The NES memory PRG banks, there are 8 of them.  This code is heavily edited/altered for the port  
* `chrom-tiles-X.asm` - The NES CHR ROM banks, also 8 of them. These are untouched aside from converting them to the SNES tile format that we use.  The go script takes care of that for you.
* `2a03_xxxxx.asm` - Sound emulation related code
* `bank-snes.asm` - All the code that runs in the `A0` bank, this is where we put most of our routines and logic that we need that is SNES specific.  Also includes various included asm files:

  * `attributes.asm` - dealing with tile and sprite attributes
  * `hardware-status-switches.asm` - various useful methods to handle differences in hardware registers
  * `hud-hdma.asm` - HDMA logic for the player health bars and names to be shown
  * `intro_screen.asm` - Title card that is shown at the start of the game
  * `palette_lookup.asm` and `palette_updates.asm` - palette logic
  * `sprites.asm` - sprite conversion and DMA'ing
* `msu.asm` - MSU-1 Support Code
* `main.asm` - the main file, root for the project
* `options_xxxx.asm` - Options screen related code.  Parts of this are genearted by generate_options_asm.go in the utilities directory
* `qol.asm` - various Quality of Life routines are here
* `vars.inc`, `registers.inc`, `macros.inc` - helpful includes
* `resetvector.asm` - the reset vector code
* `hirom.cfg` - defines how our ROM is laid out, where each bank lives and how large they are
* `windows.asm` - used for managing the windows that sometimes hide the left side of the screen.
* `wram_routines.bin` - binary copy of audio routines that we put in work ram to make them available to all banks.

## Building

* Update the `build.sh` file with the location of your cc65 install
* make sure you've extracted and copied the rom banks to `/src`
* port all the changes you need to port! (magic)
* run `build.sh`
* The output will be in `out/`

## Special Thanks

Limited Run Games and Randy Linden for providing a rumble controller and generally doing one of the coolest retro projects out there

Infidelity for paving the way to these ports

Memblers, with whom these games would have no sound

Batty for enthusiastically handling so much of the music balancing and sourcing.

Finally, Betty, Nina, and Magnus;  my family, for supporting my weird nerdy hobbies.