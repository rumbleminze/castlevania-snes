; bank 0 - this houses our init routine and setup stuff
.segment "PRGA0"
init_routine:
  PHK 
  PLB 
  BRA initialize_registers

initialize_registers:
  setAXY16
  setA8

  LDA #$8F
  STA INIDISP
  STA INIDISP_STATE
  STZ OBSEL
  STZ OAMADDL
  STZ OAMADDH
  STZ BGMODE  
  STZ MOSAIC  
  STZ BG1SC   
  STZ BG2SC   
  STZ BG3SC   
  STZ BG4SC   
  STZ BG12NBA 
  STZ BG34NBA 
  STZ BG1HOFS 
  STZ BG1HOFS
  STZ BG1VOFS
  STZ BG1VOFS
  STZ BG2HOFS
  STZ BG2HOFS
  STZ BG2VOFS
  STZ BG2VOFS
  STZ BG3HOFS
  STZ BG3HOFS
  STZ BG3VOFS
  STZ BG3VOFS
  STZ BG4HOFS
  STZ BG4HOFS
  STZ BG4VOFS
  STZ BG4VOFS

  LDA #$80
  STA VMAIN
  STZ VMADDL
  STZ VMADDH
  STZ M7SEL
  STZ M7A

  LDA #$01
  STA M7A
  STA MEMSEL
  STZ M7B
  STZ M7B
  STZ M7C
  STZ M7C
  STZ M7D
  STA M7D
  STZ M7X
  STZ M7X
  STZ M7Y
  STZ M7Y
  STZ CGADD
  STZ W12SEL
  STZ W34SEL
  STZ WOBJSEL
  STZ WH0
  STZ WH1     
  STZ WH2     
  STZ WH3     
  STZ WBGLOG  
  STZ WOBJLOG 
  STZ TM      
  STZ TS      
  STZ TMW     

  LDA #$30
  STA CGWSEL
  STZ CGADSUB

  ; STZ SETINI
  LDA #$00 
  ; LDA #$01 ; uncomment this to use auto-joypoll
  STA NMITIMEN
  STA NMITIMEN_STATE
  STZ VMAIN_STATE
  
  STZ SNES_OAM_TRANSLATE_NEEDED

  LDA #$FF
  STA WRIO   
  STZ WRMPYA 
  STZ WRMPYB 
  STZ WRDIVL 
  STZ WRDIVH 
  STZ WRDIVB 
  STZ HTIMEL 
  STZ HTIMEH 
  STZ VTIMEL 
  STZ VTIMEH 
  STZ MDMAEN 
  STZ HDMAEN 
  STZ MEMSEL 

  STZ EXTRA_VRAM_UPDATE
  STZ LEVEL_SELECT_INDEX
  
  setAXY8
  LDA #$00
  LDY #$0F
: STA ATTRIBUTE_DMA, Y
  DEY
  BNE :-

  LDY #$40
: DEY
  STA $0900, y
  BNE :-
  
  JSR clear_zp 
  JSR clear_buffers
  
  LDA #$20
  STA $00
  JSR clear_bg
  LDA #$24
  STA $00
  JSR clear_bg
  JSR clearvm
  LDA #$E0
  STA COLDATA
  LDA #$0F
  STA INIDISP_STATE

  JSR zero_oam  
  JSR dma_oam_table
  JSR zero_all_palette

  STA OBSEL
  LDA #$11
  STA BG12NBA
  LDA #$77
  STA BG34NBA
  LDA #$01
  STA BGMODE
  LDA #$21
  STA BG1SC
;   LDA #$32
;   STA BG2SC
;   LDA #$28
;   STA BG3SC
;   LDA #$7C
;   STA BG4SC
  LDA #$80
  STA OAMADDH
  LDA #$11
  STA TMW
  LDA #$02
  STA W12SEL
  STA WOBJSEL
  
  lda #%00010001
  STA TM
  LDA #$01
  STA MEMSEL
; Use #$04 to enable overscan if we can.
  LDA #$04
  LDA #$00
  STA SETINI


  lda #%0000000
  sta OBSEL

  STZ ATTR_NES_HAS_VALUES
  STZ ATTR_NES_VM_ADDR_HB
  STZ ATTR_NES_VM_ADDR_LB
  STZ ATTR_NES_VM_ATTR_START
  STZ ATTRIBUTE2_DMA
  STZ ATTRIBUTE_DMA
  LDA #$00
  ; LDA #$01 ; uncomment this to use auto-poll joypad
  STA NMITIMEN_STATE
  
  ; jsl spc_init_dpcm
  jsl spc_init_driver
  jsr write_sound_wram_routines
  STZ MSU_SELECTED
  jslb check_if_msu_is_available, $b2
  LDA MSU_AVAILABLE
  beq :+
    LDA #$01
    STA MSU_SELECTED
    jslb check_for_all_tracks_present, $b2
  :
  jslb do_intro, $b1
  
  PHK
  PLB

intro_done:
  STZ TM      
  STZ TS      
  STZ TMW   
  LDA #$30
  STA CGWSEL
  STZ CGADSUB
  
  JSR setup_hide_left_8_pixel_window
  JSL disable_hide_left_8_pixel_window
  JSR clearvm_to_12
  JSR write_default_palettes
  LDA #$FF
  STA PALETTE_FILTER

  ; JSR write_stack_adjustment_routine_to_ram
  ; JSR write_sound_hijack_routine_to_ram

  LDA #$00
  STA ACTIVE_NES_BANK

  LDA #$A1
  PHA
  PLB 
  JML $A1C008


  snes_nmi:
    LDA RDNMI 

    ; jsr make_the_game_easier
    ; jslb update_values_for_ppu_mask, $a0
    jslb infidelitys_scroll_handling, $a0
    jslb setup_hdma, $a0
    ; jslb calculate_hdma_l, $a0

    JSR check_and_copy_nes_attributes_to_buffer
    jsr check_for_palette_swap
    
    ; JSR dma_oam_table
    RTL

store_current_hdma_values:

    LDX #$1F
  : LDA SCROLL_HDMA_START, X
    STA SCROLL_HDMA_SAVED, X
    DEX
    BPL :-

    LDA #$7E
    STA A1B3
    LDA #$09
    STA A1T3H
    LDA #$20
    STA A1T3L
    
    LDA #<(BG1HOFS)
    STA BBAD3
    LDA #$03
    STA DMAP3

    LDA #%00001000
    jsr disable_sprites_under_hud
    STA HDMAEN
    rtl

disable_sprites_under_hud:

  PHA
  LDA $200
  CMP #$C5
  BNE :+
  LDA #^sprite_disable_hud
  STA A1B4
  LDA #>sprite_disable_hud
  STA A1T4H
  LDA #<sprite_disable_hud
  STA A1T4L

  LDA #<(TM)
  STA BBAD4
  lda #$00
  STZ DMAP4

  PLA
  ORA #%00010000
  PHA
:
  PLA
  rts

; sprite 0 is always either 
; C5 (vertical stages) or
; F4 (hud off off) 
; 197 total lines of everything on
; then 
sprite_disable_hud:
.byte $80, $11  ; 0x80 lines of 11
.byte $46, $11  ; 0x46 lines of 11
.byte $01, $01  ; 0x01 line  of 01 (disable sprites)
.byte $00       ; end hdma


clear_bg_jsl:
  LDA $00
  PHA
  LDA #$20
  STA $00
  jsr clear_bg
  LDA #$24
  STA $00
  jsr clear_bg
  PLA
  STA $00
  rtl
clear_bg:

  LDA #$80
  STA VMAIN

  ; fixed A value, increment B
  
  LDA #$09
  sta DMAP0
  
  LDA $00
  STA VMADDH
  STZ VMADDL

  LDA #$18
  STA BBAD0

  LDA #$A0
  STA A1B0

  LDA #>dma_values
  STA A1T0H
  LDA #<dma_values
  STA A1T0L

  LDA #$08
  STA DAS0H  
  STZ DAS0L

  LDA #$01
  STA MDMAEN

  LDA VMAIN_STATE
  STA VMAIN
  RTS


clearvm_jsl:
  jsr clearvm
  rtl
clearvm:
  LDA #$80
  STA VMAIN

  ; fixed A value, increment B
  setAXY16

  LDA #$0009
  sta DMAP0

  LDA #$0000
  STZ VMADDL

  LDA #$18
  STA BBAD0

  LDA #$A0
  STA A1B0

  setAXY8
  LDA #>dma_values
  STA A1T0H
  LDA #<dma_values
  STA A1T0L
  setAXY16

  STZ DAS0L

  LDA #$0001
  STA MDMAEN

  setAXY8
  LDA VMAIN_STATE
  STA VMAIN
  RTS

clearvm_to_12_long:
  JSR clearvm_to_12
  RTL

clearvm_to_12:

: LDA RDNMI
  BPL :-

  LDA #$00
  STA NMITIMEN
  jslb force_blank_no_store, $a0 
  setAXY16
  ldx #$2000
  stx VMADDL 
	
	lda #$0000
	
	LDY #$0000
	:
		sta VMDATAL
		iny
		CPY #(32*64)
		BNE :-
  
  setAXY8
  jslb reset_inidisp, $a0 

  RTS

clear_zp:
  LDA #$00
  LDY #$00

: STA $00, Y
  INY
  BNE :-
  RTS

clear_buffers:
  LDA #$00
  LDY #$00
  LDX #$FF

: LDA #$00
  STA $0800, Y
  STA $0900, Y
  STA $0A00, Y
  STA $0B00, Y
  STA $0C00, Y
  STA $0D00, Y
  STA $0E00, Y
  STA $0F00, Y
  
  STA $1000, Y
  STA $1100, Y
  STA $1200, Y
  STA $1300, Y
  STA $1400, Y
  STA $1500, Y
  STA $1600, Y
  STA $1700, Y
  
  STA $1800, Y
  STA $1900, Y
  STA $1A00, Y
  STA $1B00, Y
  STA $1C00, Y
  STA $1D00, Y
  STA $1E00, Y
  STA $1F00, Y

  LDA #$FF
  STA $6500, y
  STA $6600, y
  DEY
  BNE :-
  RTS

msu_movie_rti:
  REP #$30
  PLY
  PLX
  PLA
  SEP #$30
  PLP
  RTI

check_for_palette_swap:
  LDA $22 ; check that we're paused
  BEQ :+

  LDA $F5
  AND #$20
  BEQ :+

  STZ NMITIMEN

  jsr wait_for_vblank

  INC OPTIONS_PALETTE
  LDA OPTIONS_PALETTE
  AND #$07
  STA OPTIONS_PALETTE
  LDA #$80
  STA VMAIN
  jslb write_palette_data, $a0
  LDA VMAIN_STATE
  STA VMAIN
  LDA RDNMI
  LDA NMITIMEN_STATE
  STA NMITIMEN
: rts

wait_for_vblank:
  LDA RDNMI
  AND #$80
  BEQ wait_for_vblank
  RTS

make_the_game_easier:

  LDA #$02
  STA $76
  LDA #99
  STA $34
  LDA #$02
  STA $86


  rts 

  ; LDA #$01
  ; ; STA $91
  ; ; STA $93
  ; ; STA $90
  ; ; STA $86

  ; LDA #$03
  ; STA $80
  ; STA $34
  ; rts

dma_values:
  .byte $00, $12

  .include "scrolling.asm"
  .include "input.asm"  
  .include "tiles.asm"
  .include "windows.asm"
  .include "hardware-status-switches.asm"
  .include "castlevania_rewrites.asm"

  .include "hdma_scroll_lookups.asm"

.if OLD_2A03 = 0
  .include "2a03_conversion.asm"
.else
  .include "2a03_conversion_v0.asm"
.endif

  .include "attributes.asm"
  .include "palette_updates.asm"
  .include "palette_lookup.asm"
  .include "sprites.asm"


write_sound_wram_routines:
LDY #$00
:
LDA wram_routines, Y
STA $1C00, Y
LDA wram_routines + $100, Y
STA $1D00, Y
LDA wram_routines + $200, Y
STA $1E00, Y
LDA wram_routines + $300, Y
STA $1F00, Y

INY
BNE :-
RTS

wram_routines:
.if OLD_2A03 = 0
  .incbin "wram_routines.bin"
.else
  .incbin "wram_routines_v0.bin"
.endif

; .segment "PRGA0C"
; fixeda0:
; .include "bank7.asm"
; fixeda0_end: