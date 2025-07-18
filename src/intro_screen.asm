.segment "PRGB1"

intro_screen_data:
.byte $20, $20
.byte $e6, $e7, $e6, $e7, $e6, $e7, $e6, $e7 
.byte $e6, $e7, $e6, $e7, $e6, $e7, $e6, $e7 
.byte $e6, $e7, $e6, $e7, $e6, $e7, $e6, $e7 
.byte $e6, $e7, $e6, $e7, $e6, $e7, $e6, $e7 
.byte $e8, $e9, $e8, $e9, $e8, $e9, $e8, $e9 
.byte $e8, $e9, $e8, $e9, $e8, $e9, $e8, $e9
.byte $e8, $e9, $e8, $e9, $e8, $e9, $e8, $e9 
.byte $e8, $e9, $e8, $e9, $e8, $e9, $e8, $e9
.byte $ff

.byte $e2, $20, $29, $28, $2b, $2d, $1e, $1d, $00                       ; Ported 
.byte $1b, $32, $00                                                     ; by 
.byte $2b, $2e, $26, $1b, $25, $1e, $26, $22, $27, $33, $1e, $00        ; Rumbleminze, 
.byte $12, $10, $12, $15, $ff                                           ; 2025

; always credit the people that help you
; MSU1 Arrangements By Batty and Relikk
; .byte $82, $22, $26, $2c, $2e, $11, $34
; .byte $1a, $2b, $2b, $1a, $27, $20, $1e, $26, $1e, $27, $2d, $2c, $FF

; .byte $A6, $22, $1b, $32, $34
; .byte $1b, $1a, $2d, $2d, $32, $34
; .byte $1A, $27, $1D, $34
; .byte $2B, $1E, $25, $22, $24, $24,  $ff

.byte $E1, $22, $12, $1a, $10, $13, $00                                 ; 2A03
.byte $2c, $28, $2e, $27, $1d, $00                                      ; SOUND 
.byte $1e, $26, $2e, $25, $1a, $2d, $28, $2b, $00                       ; EMULATOR
.byte $1b, $32, $00                                                     ; BY
.byte $26, $1e, $26, $1b, $25, $1e, $2b, $2c, $ff                       ; MEMBLERS

.byte $58, $23, $2b, $1e, $2f, $10, $ff ; Version (REV0)

; bad ass skulls
.byte $60, $23
.byte $e6, $e7, $e6, $e7, $e6, $e7, $e6, $e7 
.byte $e6, $e7, $e6, $e7, $e6, $e7, $e6, $e7 
.byte $e6, $e7, $e6, $e7, $e6, $e7, $e6, $e7 
.byte $e6, $e7, $e6, $e7, $e6, $e7, $e6, $e7 
.byte $e8, $e9, $e8, $e9, $e8, $e9, $e8, $e9 
.byte $e8, $e9, $e8, $e9, $e8, $e9, $e8, $e9
.byte $e8, $e9, $e8, $e9, $e8, $e9, $e8, $e9 
.byte $e8, $e9, $e8, $e9, $e8, $e9, $e8, $e9
.byte $ff
.byte $ff, $ff

write_intro_palette:
    STZ CGADD    
    LDA #$00
    STA CGDATA
    STA CGDATA

    LDA #$FF
    STA CGDATA
    STA CGDATA

    LDA #$1f
    STA CGDATA
    LDA #$3a
    STA CGDATA
    
    LDA #$d6
    STA CGDATA
    LDA #$10
    STA CGDATA

; sprite default colors
    LDA #$80
    STA CGADD
    LDA #$D0
    STA CGDATA
    LDA #$00
    STA CGDATA
    
    LDA #$b5
    STA CGDATA
    LDA #$56
    STA CGDATA

    LDA #$d0
    STA CGDATA
    LDA #$00
    STA CGDATA
    
    LDA #$00
    STA CGDATA
    LDA #$00
    STA CGDATA

    
    LDA #$90
    STA CGADD
    LDA #$D0
    STA CGDATA
    LDA #$00
    STA CGDATA
    
    LDA #$00
    STA CGDATA
    LDA #$00
    STA CGDATA

    LDA #$d6
    STA CGDATA
    LDA #$10
    STA CGDATA
    
    LDA #$41
    STA CGDATA
    LDA #$02
    STA CGDATA

    
    LDA #$A0
    STA CGADD
    LDA #$D0
    STA CGDATA
    LDA #$00
    STA CGDATA
    
    LDA #$00
    STA CGDATA
    LDA #$00
    STA CGDATA

    LDA #$33
    STA CGDATA
    LDA #$01
    STA CGDATA

    LDA #$D0
    STA CGDATA
    LDA #$00
    STA CGDATA

    
    LDA #$B0
    STA CGADD
    LDA #$D0
    STA CGDATA
    LDA #$00
    STA CGDATA
    
    LDA #$33
    STA CGDATA
    LDA #$01
    STA CGDATA

    LDA #$33
    STA CGDATA
    LDA #$01
    STA CGDATA
    
    LDA #$6a
    STA CGDATA
    LDA #$00
    STA CGDATA

    RTS

write_intro_tiles:
    LDY #$00

next_line:
    ; get starting address
    LDA intro_screen_data, Y
    CMP #$FF
    BEQ exit_intro_write

    PHA
    INY    
    LDA intro_screen_data, Y
    STA VMADDH
    PLA
    STA VMADDL
    INY

next_tile:
    LDA intro_screen_data, Y
    INY

    CMP #$FF
    BEQ next_line

    STA VMDATAL
    BRA next_tile

exit_intro_write:
    RTS

do_intro:
    JSR load_intro_tilesets
    JSL write_default_palettes_jsl
    
    PHK
    PLB
    JSR write_intro_tiles
    ; JSR write_intro_sprites

    LDA #$0F
    STA INIDISP
    LDX #$FF


:
    LDA RDNMI
    BPL :-
    INC $20
    jsr check_for_code_input
    ; jsr check_for_sprite_swap
    ; jsr check_for_msu

    ; check for "start"
    LDA JOYTRIGGER1
    AND #$10
    CMP #$10
    BNE :-

    LDA INIDISP_STATE
    ORA #$8F
    STA INIDISP_STATE
    STA INIDISP

    

:   
    
    LDA NMITIMEN_STATE
    STA NMITIMEN
    JSR show_options_screen
    RTL
check_for_sprite_swap:

    LDA JOYTRIGGER1
    AND #$20
    CMP #$20
    BNE :-
    jsr load_intro_tilesets
    LDA #$0F
    STA INIDISP
:   rts
check_for_msu:
    LDA JOYTRIGGER1
    AND #$01
    CMP #$01
    BEQ :+
    LDA JOYTRIGGER1
    AND #$02
    CMP #$02
    BNE :-
:   LDA MSU_SELECTED
    EOR #$01
    STA MSU_SELECTED

    LDA SNES_OAM_START + (4*9 - 1)
    EOR #$40
    STA SNES_OAM_START + (4*9 - 1)
    JSR dma_oam_table
    RTS

; if a sprite wants to be on the intro screen,
; can put the data here    
intro_sprite_info:
    ; x, y, sprite
    .byte $80, $30, $00, $00
    .byte $80, $38, $01, $00
    .byte $88, $30, $02, $00
    .byte $88, $38, $03, $00
    .byte $80, $40, $08, $00
    .byte $80, $48, $09, $00
    .byte $88, $40, $0a, $00
    .byte $88, $48, $0B, $00
    .byte $80, $78, $54, $40
    .byte $ff

write_intro_sprites:
    LDY #$00
    LDX #$09

:   LDA intro_sprite_info, y
    STA SNES_OAM_START, y
    INY
    LDA intro_sprite_info, y
    STA SNES_OAM_START, y
    INY
    LDA intro_sprite_info, y
    STA SNES_OAM_START, y
    INY
    LDA intro_sprite_info, y
    STA SNES_OAM_START, y
    INY
    DEX
    BNE :-

    JSR dma_oam_table

    rts

; loads up the tileset that has the tiles for the intro
load_intro_tilesets:
    lda #$01
    sta NMITIMEN
    LDA VMAIN_STATE
    AND #$0F
    STA VMAIN
    LDA #$8F
    STA INIDISP
    STA INIDISP_STATE

    ; load index 20 bank into both sets of tiles
    ; 20 is our custom intro screen tiles
    LDA #$00
    STA CHR_BANK_BANK_TO_LOAD
    LDA #$01
    STA CHR_BANK_TARGET_BANK
    JSL load_chr_table_to_vm

    LDA #$00
    STA CHR_BANK_BANK_TO_LOAD
    LDA #$00
    STA CHR_BANK_TARGET_BANK
    JSL load_chr_table_to_vm

    LDA #$01
    STA CHR_BANK_BANK_TO_LOAD
    LDA #$04
    STA CHR_BANK_TARGET_BANK
    JSL load_chr_table_to_vm
    
    LDA #$02
    STA CHR_BANK_BANK_TO_LOAD
    LDA #$05
    STA CHR_BANK_TARGET_BANK
    JSL load_chr_table_to_vm

    rts

.include "options_screen.asm"
.include "qol.asm"
.include "konamicode.asm"