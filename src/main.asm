.p816
.smart


.include "macros.inc"
.include "registers.inc"
.include "vars.inc"
.include "2a03_variables.inc"

.if OLD_2A03 = 0
    .include "wram_routines.asm"
.else
    .include "wram_routines_v0.asm"
.endif

.include "hiromheader.asm"  

.segment "CODE"
.include "resetvector.asm"

.segment "EMPTY_SPACE"

.include "bank-snes.asm"
; these would need to be created from the original ROM using 
; the /utilities/parseNesFileToBanks.go file
.include "bank0.asm"
.include "bank1.asm"
.include "bank2.asm"
.include "bank3.asm"
.include "bank4.asm"
.include "bank5.asm"
.include "bank6.asm"

; these are pre-converted banks of tiles that we can use instead of converting
; the NES tiles on the fly
.include "tile_bank0.asm"
.include "tile_bank1.asm"
.include "tile_bank2.asm"
.include "tile_bank3.asm"

.include "tile_bank6.asm"

; these are tiles I use for intro/menu screens
.include "chrom-basic-intro-tiles.asm"

.include "msu.asm"
; .include "chrom-tiles-msu-intro.asm"
; .include "msu_video_player.asm"
  .include "intro_screen.asm"

.if OLD_2A03 = 0
    .include "dpcm_audio.asm"
.else 
    .include "2a03_emulator_first_8000.asm"
.endif

