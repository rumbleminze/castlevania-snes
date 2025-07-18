check_for_palette_updates:
  PHA
  LDA PALETTE_NEEDS_UPDATING
  BNE :+
  PLA
  rtl
: pla
  stz PALETTE_NEEDS_UPDATING

write_palette_data:
  PHX
  PHY
  PHA

  setAXY8
  PHK
  PLB

  LDA $00
  PHA
  LDA $01
  PHA

  LDA OPTIONS_PALETTE
  ASL
  TAY
  LDA palette_adddresses, Y
  STA $00
  LDA palette_adddresses + 1, Y
  STA $01

  LDX #$00
  STZ CURR_PALETTE_ADDR
  STZ CGADD

  ; lookup our 2 byte color from palette_lookup, color * 2
  ; Our palettes are written by writing to CGDATA
  ; PALETTE_UPDATE_START contains the first byte of palette data to update.
palette_entry:

  LDA PALETTE_UPDATE_START, X
  AND PALETTE_FILTER
  ASL A
  TAY
  LDA ($00), Y
  STA CGDATA
  INY
  LDA ($00), Y
  STA CGDATA

  LDA PALETTE_UPDATE_START + 1, X
  AND PALETTE_FILTER
  ASL A
  TAY 

  LDA ($00), Y
  STA CGDATA
  INY
  LDA ($00), Y
  STA CGDATA

  LDA PALETTE_UPDATE_START + 2, X
  AND PALETTE_FILTER
  ASL A
  TAY 

  LDA ($00), Y
  STA CGDATA
  INY
  LDA ($00), Y
  STA CGDATA

  LDA PALETTE_UPDATE_START + 3, X
  AND PALETTE_FILTER
  ASL A
  TAY 

  LDA ($00), Y
  STA CGDATA
  INY
  LDA ($00), Y
  STA CGDATA

  LDA CURR_PALETTE_ADDR
  CLC
  ADC #$10
  STA CGADD
  STA CURR_PALETTE_ADDR

  INX
  INX
  INX
  INX
  ; CPY #$10
  ; BNE palette_entry

  TXA
  AND #$0F
  CMP #$00
  BNE skip_writing_four_empties

  ; after 16 entries we write an empty set of palettes
  CLC
  LDA CURR_PALETTE_ADDR
  ADC #$40
  STA CGADD
  STA CURR_PALETTE_ADDR 

skip_writing_four_empties:
  CPX #$20
  BEQ :+
  jmp palette_entry
:


  LDA ACTIVE_NES_BANK
  INC A
  ORA #$A0
  PHA
  PLB
  
  PLA
  STA $01
  PLA 
  STA $00

  PLA
  PLY  
  PLX
  ; done after $20
  RTL
  
zero_all_palette_long:
  jsr zero_all_palette
  rtl

zero_all_palette:
  LDY #$00
  LDX #$02

  STZ CGADD

: STZ CGDATA
  DEY
  BNE :-
  DEX
  BNE :-

  RTS

snes_default_bg_palette:
.byte $00, $00, $FF, $7F, $7D, $12, $D6, $10, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $FF, $7F, $B5, $56, $29, $25, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $FF, $7F, $B5, $56, $29, $25, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $FF, $7F, $B5, $56, $29, $25, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

snes_sprite_palatte:
.byte $00, $00, $FF, $7F, $7D, $12, $D6, $10, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $FF, $7F, $B5, $56, $29, $25, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $FF, $7F, $B5, $56, $29, $25, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $FF, $7F, $B5, $56, $29, $25, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

write_default_palettes_jsl:
  jsr write_default_palettes
  rtl

write_default_palettes:
  STZ CGADD
  sta CGADD
  LDY #$00
: LDA snes_sprite_palatte, y
  STA CGDATA
  INY
  CMP #$40
  BNE :-


  LDA #$80
  sta CGADD
  LDY #$00
: LDA snes_sprite_palatte, y
  STA CGDATA
  INY
  CMP #$40
  BNE :-
  rts

; assumes CGADD is already set
; nes color is in A
store_nes_color_in_palette:
  PHX
  ASL A
  TAX
  LDA $A086E0, X ; palette_lookup, X
  STA CGDATA
  LDA $A086E1, X ; palette_lookup + 1, X
  STA CGDATA

  PLX
  RTL



write_option_palette:
    PHK
    PLB
    LDA RDNMI
:   LDA RDNMI
    BPL :-

    LDA OPTIONS_PALETTE
    ASL
    TAY
    LDA palette_adddresses, Y
    STA $00
    INY
    LDA palette_adddresses, Y
    STA $01
    
    LDY #$00

    LDA #$41
    STA CGADD
    LDX #$80
    LDY #$00

:   LDA ($00), Y
    STA CGDATA
    INY
    DEX
    BNE :-

    RTL

write_option_palette_from_indexes:
    PHK
    PLB
    LDA RDNMI
:   LDA RDNMI
    BPL :-

    STZ CGADD
    LDY #$00
    LDX #$00

    LDA OPTIONS_PALETTE
    ASL
    TAY
    LDA palette_adddresses, Y
    STA $00
    INY
    LDA palette_adddresses, Y
    STA $01
    
    LDY #$00
    
option_palette_loop:
    LDA default_options_bg_palette_indexes, X
    ASL A
    TAY

    LDA ($00), Y
    STA CGDATA
    INY

    LDA ($00), Y
    STA CGDATA    
    INY

    ; every 4 we need to write a bunch of empty palette entries
    INX
    TXA
    AND #$03
    BNE :+

    CLC
    LDA CURR_PALETTE_ADDR
    ADC #$10
    STA CGADD
    STA CURR_PALETTE_ADDR

:
    TXA
    AND #$0F
    CMP #$00
    BNE :+
    ; after 16 entries we write an empty set of palettes
    CLC
    LDA CURR_PALETTE_ADDR
    ADC #$40
    STA CGADD
    STA CURR_PALETTE_ADDR 

:
    CPX #$20
    BNE option_palette_loop
    rtl    

    
default_options_bg_palette_indexes:
.byte $0F, $07, $00, $01, $0F, $02, $01, $1C, $0F, $0A, $18, $28, $0F, $17, $19, $10

default_options_sprite_palette_indexes:
.byte $0F, $30, $15, $0F, $0F, $30, $00, $0F, $0F, $3B, $1B, $0F, $0F, $06, $16, $38

default_options_palette:
.byte $00, $00, $FF, $7F, $74, $64, $42, $50, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $F7, $02, $33, $01, $6A, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $29, $6F, $07, $02, $A0, $44, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $BF, $65, $8C, $31, $76, $3C, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

options_sprite_palette:
.byte $00, $00, $FF, $7F, $1F, $3A, $6A, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $78, $7F, $42, $50, $76, $3C, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $08, $7D, $D8, $7D, $78, $7F, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $0D, $00, $D6, $10, $9C, $4B, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

