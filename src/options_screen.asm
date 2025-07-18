; Options Screen
;
; Palette           > NES      FCEUX    ????
; Continue          > Yes         No
;                 Area: X
;
;   [graphic]

; layout:
; address, # tiles, tile values.  


option_tiles:

.byte $2B, $20, $08, P6, $28, P6, $29, P6, $2d, P6, $22, P6, $28, P6, $27, P6, $2C, P6, $36    ; Options-

.incbin "options.bin"


; PRESS START
.byte $64, $21, $0B, P6, $29, P6, $2b, P6, $1e, P6, $2c, P6, $2c, P6, $34, P6, $2c, P6, $2d, P6, $1a, P6, $2b, P6, $2d

; PRESS SELECT FOR MSU-1 OPTIONS
.addr $2277
.byte $05, P6, $29, P6, $2b, P6, $1e, P6, $2c, P6, $2c; PRESS 

.addr $2297
.byte $06, P6, $2c, P6, $1e, P6, $25, P6, $1e, P6, $1c, P6, $2d ; SELECT

.addr $22B7
.byte $08, P6, $1f, P6, $28, P6, $2b, P6, $34, P6, $26, P6, $2c, P6, $2e, P6, $11 ; FOR MSU1       

.addr $22D7
.byte $07, P6, $1c, P6, $2b, P6, $1e, P6, $1d, P6, $22, P6, $2d, P6, $2c ; CREDITS

P0 = $00
P1 = $04
P2 = $08
P3 = $0C
P4 = $10
P5 = $14
P6 = $18
P7 = $1C

P0_3 = $12
P1_3 = $16
P2_3 = $1A
P3_3 = $1E

; fun 8 x 8 BG
.byte $6C, $22, $08, P0, $9A, P0, $6D, P0, $6D, P0, $6D, P0, $6D, P0, $6D, P0, $6D, P0, $6A
.byte $8C, $22, $08, P0, $8D, P0, $9D, P0, $6A, P0, $7A, P0, $8A, P0, $6D, P0, $6D, P0, $7D
.byte $AC, $22, $08, P0, $8E, P0, $9E, P0, $6B, P0, $7B, P0, $8B, P0, $9B, P0, $6E, P0, $7E
.byte $CC, $22, $08, P0, $8F, P0, $9F, P0, $6C, P0, $7C, P0, $8C, P0, $9C, P0, $6F, P0, $7F
.byte $EC, $22, $08, P0, $40, P0, $40, P0, $40, P0, $40, P0, $40, P0, $40, P0, $40, P0, $40
.byte $0C, $23, $08, P0, $40, P0, $40, P0, $40, P0, $40, P0, $40, P0, $40, P0, $40, P0, $40

.byte $2C, $23, $08, P3, $42, P3, $51, P3, $51, P3, $51, P3, $51, P3, $51, P3, $51, P3, $52 
.byte $4C, $23, $08, P3, $46, P3, $56, P3, $46, P3, $56, P3, $46, P3, $56, P3, $46, P3, $56

; full palette preview
.byte $A3, $21, $10, P0_3, $00, P0_3, $01, P0_3, $02, P0_3, $03, P0_3, $04, P0_3, $05, P0_3, $06, P0_3, $07, P0_3, $08, P0_3, $09, P0_3, $0A, P0_3, $0B, P0_3, $0C, P0_3, $0D, P0_3, $0E, P0_3, $0F
.byte $C3, $21, $10, P1_3, $00, P1_3, $01, P1_3, $02, P1_3, $03, P1_3, $04, P1_3, $05, P1_3, $06, P1_3, $07, P1_3, $08, P1_3, $09, P1_3, $0A, P1_3, $0B, P1_3, $0C, P1_3, $0D, P1_3, $0E, P1_3, $0F
.byte $E3, $21, $10, P2_3, $00, P2_3, $01, P2_3, $02, P2_3, $03, P2_3, $04, P2_3, $05, P2_3, $06, P2_3, $07, P2_3, $08, P2_3, $09, P2_3, $0A, P2_3, $0B, P2_3, $0C, P2_3, $0D, P2_3, $0E, P2_3, $0F
.byte $03, $22, $10, P3_3, $00, P3_3, $01, P3_3, $02, P3_3, $03, P3_3, $04, P3_3, $05, P3_3, $06, P3_3, $07, P3_3, $08, P3_3, $09, P3_3, $0A, P3_3, $0B, P3_3, $0C, P3_3, $0D, P3_3, $0E, P3_3, $0F

.byte $FF


show_options_screen:
    
    LDX #$20
    LDA RDNMI
    : LDA RDNMI
    BPL :-
    DEX
    BPL :-
    
    jsr read_input
    LDA MSU_AVAILABLE
    BNE :+
        jsr decrement_msu1
    :

    LDA #$11
    STA TM

    STZ CURR_OPTION

    LDA VMAIN_STATE
    AND #$0F
    STA VMAIN
    LDA #$80
    STA INIDISP
    jslb clearvm_jsl, $a0

    LDA #$00
    STA CHR_BANK_BANK_TO_LOAD
    LDA #$00
    STA CHR_BANK_TARGET_BANK
    JSL load_chr_table_to_vm

    LDA #$00
    STA CHR_BANK_BANK_TO_LOAD
    LDA #$01
    STA CHR_BANK_TARGET_BANK
    JSL load_chr_table_to_vm

;     ; if MSU starts here at 0 then it's not available at all
;     LDA MSU_SELECTED
;     BNE :+
;     INC MSU_UNAVAILABLE
; :   
    JSR write_option_tiles
    jslb write_option_palette, $a0
    jslb write_option_palette_from_indexes, $a0
        PHK
    PLB
    JSR load_options_sprites
    jsr write_single_color_tiles_to_3000

    
    LDA $20
    AND #$07
    ; scale down to 0 - 5
    CMP #$05
    BCC:+
        SEC
        SBC #$05
    :
    STA OPTIONS_MSU_PLAYLIST

    jsr initialize_options
    jslb dma_oam_table_long, $a0
    LDA #$0F
    STA INIDISP
    LDX #$FF


    ; check for input
NEEDS_OAM_DMA = $11
input_loop:
    LDA RDNMI
:   LDA RDNMI
    BPL :-

    jslb msu_nmi_check, $b2
    ; we gotta waste some time here
    LDX #$00
:   DEX
    BNE :-

    jsr read_input
    LDA NEEDS_OAM_DMA
    BEQ :+
        jslb dma_oam_table_long, $a0
        
        STZ NEEDS_OAM_DMA
:   
    LDA JOYTRIGGER1

    CMP #DOWN_BUTTON
    BNE :+
    jsr next_option
    bra input_loop

:   CMP #UP_BUTTON
    BNE :+
    jsr prev_option
    bra input_loop

:   CMP #RIGHT_BUTTON
    BNE :+
    jsr toggle_current_option
    bra input_loop

:   CMP #LEFT_BUTTON
    BNE :+
    jsr decrement_current_option
    bra input_loop

:   CMP #START_BUTTON
    BNE:+
    bra exit_options
    
:   CMP #SELECT_BUTTON
    BNE input_loop
    
   jmp show_credits
   BRA input_loop

exit_options:
    ; stop msu1
    LDA RDNMI
    : LDA RDNMI
    BPL :-
    STZ $2007
    STZ MSU_CURR_CTRL    
    STZ MSU_PLAYING
    STZ CURRENT_NSF
    jslb msu_nmi_check, $b2

    jsr clear_extra_palattes
    LDA #$FF
    LDY #$00

:   STA CHR_BANK_LOADED_TABLE, Y
    INY
    CPY #$08
    BNE :-

    STZ CURR_OPTION

    ; ; for now go to MSU- would like this to happen when we hit SELECT or something
    ; jsr show_msu_track_screen

    LDA INIDISP_STATE
    STA INIDISP

    RTS

clear_sprites:
    LDA #$F0
    LDY #$00
:   STA SNES_OAM_START+1, Y
    INY
    INY
    INY
    INY
    BNE :-
    rts


clear_extra_palattes:
    LDA RDNMI
:   LDA RDNMI
    BPL :-
    LDA #$40
    STA CGADD
:   STZ CGDATA
    DEC
    BNE :-
    rts

CURR_OPTION = $10
; MSU_UNAVAILABLE = $12

next_option:
    LDA CURR_OPTION
    INC
    STA CURR_OPTION
    CMP #NUM_OPTIONS
    BNE :+
    STZ CURR_OPTION
:   jsr update_option_pos
    RTS

prev_option:
    LDA CURR_OPTION
    BNE :+
    LDA #NUM_OPTIONS    
:   DEC 
    STA CURR_OPTION
    jsr update_option_pos
    RTS

update_option_pos:
    LDA CURR_OPTION
    TAY
    LDA option_sprite_y_pos, Y
    STA SNES_OAM_START + 1
    LDA #$01
    sta NEEDS_OAM_DMA
    rts

.include "options_macro_defs.asm"


write_option_tiles:
    setXY16
    LDY #$0000

next_option_bg_line:
    ; get starting address
    LDA option_tiles, Y
    CMP #$FF
    BEQ exit_options_write

    PHA
    INY    
    LDA option_tiles, Y
    STA VMADDH
    PLA
    STA VMADDL
    INY
    LDA option_tiles, Y
    TAX
    INY

:   LDA option_tiles, Y
    STA VMDATAH
    INY
    LDA option_tiles, Y
    STA VMDATAL
    INY
    DEX
    BEQ next_option_bg_line
    BRA :-

exit_options_write:
    setAXY8
    RTS



load_options_sprites:
    LDY #$00
:   LDA options_sprites, Y
    CMP #$FF
    BEQ :+
    STA SNES_OAM_START, Y
    INY
    BRA :-
    RTS

read_input:
 
    LDA JOY1H
    STA buttons


    lda buttons
    ldy JOYPAD1
    sta JOYPAD1
    tya
    eor JOYPAD1
    and JOYPAD1
    sta JOYTRIGGER1
    beq :+ 

    tya
    and JOYPAD1
    sta JOYHELD1
:   rts


write_single_color_tiles_to_3000:
    LDA #$30
    STA VMADDH
    LDA #$00
    STA VMADDL

    LDY #$00
    LDX #$02

:   
    LDA single_color_tiles + 1, Y
    STA VMDATAH
    LDA single_color_tiles, Y
    STA VMDATAL
    INY
    INY

    BNE :-

:   LDA single_color_tiles + $100 + 1, Y
    STA VMDATAH
    LDA single_color_tiles + $100, Y
    STA VMDATAL
    INY
    INY
    
    BNE :-

    rts

; override these if changing an option needs to have side efffects
option_0_side_effects:
    jslb write_option_palette_from_indexes, $a0
    jslb write_option_palette, $a0
        PHK
    PLB
    rts


option_4_side_effects:
    ; prevent turning on msu if it's unavailable
    LDA MSU_AVAILABLE
    BNE :++
        LDA OPTIONS_MSU_SELECTED
        BNE :+
            jsr decrement_msu1
        :
        rts
    :

    LDA OPTIONS_MSU_SELECTED
    EOR #$01
    STA MSU_SELECTED

    ; fall through to option 5 side effects

option_5_side_effects:

    LDA RDNMI
    : LDA RDNMI
    BPL :-
    STZ $2007
    STZ MSU_CURR_CTRL    
    STZ MSU_PLAYING
    STZ CURRENT_NSF
    jslb msu_nmi_check, $b2

    
    LDA RDNMI
    : LDA RDNMI
    BPL :-
    LDA #$F0
    jslb msu_check, $B2
    rts

option_1_side_effects:
option_2_side_effects: 
option_3_side_effects:
option_6_side_effects:
option_7_side_effects:
option_8_side_effects:
option_9_side_effects:
    rts


; 16 4bpp tiles that use all of a single color
; used to show the full NES palette we're currently using
single_color_tiles:
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
.byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
.byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
.byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
.byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00

.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
.byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
.byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
.byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
.byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF

.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF

.include "msu1-credits.asm"