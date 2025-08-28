write_vm_data_from_700:


next_data_set:
  LDX $0700,Y
  BEQ done
  LDA $FF
  AND #$18
  ORA $8007,X
  JSR set_ppu_control ; STA PpuControl_2000
  INY
  LDA RDNMI

  LDA $0700,Y  
  STA VMADDH
  INY
  LDA $0700,Y
  STA VMADDL ; PpuAddr_2006
  INY

  LDA $06FE, Y
  CMP #$3F

  BEQ handle_palette_start

  AND #$23
  CMP #$23
  BNE start_writes

  LDA $06FF, Y
  AND #$C0
  CMP #$C0
  BNE start_writes
  
  ; attributes
  jmp vm_write_attributes


done:
  LDA #$00
  STA $0700
  STA $20
  LDA $FF
  JSR set_ppu_control ; STA PpuControl_2000
  RTL

close:
  LDA #$FF
data_write:
  STA VMDATAL
start_writes:
  LDA $0700,Y
  INY
  CMP #$FF
  BNE data_write
  LDA $0700,Y
  CMP #$03
  BCS close
  BCC next_data_set



handle_palette_start:  
  LDA $06FF, Y
  TAX
  BRA handle_palette

close_palette:
  LDA #$FF
palette_write:
  STA PALETTE_UPDATE_START, X
  INX
handle_palette:
  LDA $0700,Y
  INY
  CMP #$FF
  BNE palette_write

  LDA $0700,Y
  CMP #$03
  BCS close_palette
  
  LDA #$01
  STA PALETTE_NEEDS_UPDATING
  BCC next_data_set

vm_write_attributes:
  PHX
  LDX #$00
  LDA $06FE, Y
  STA ATTR_NES_VM_ADDR_HB
  LDA $06FF, Y
  STA ATTR_NES_VM_ADDR_LB
  STZ ATTR_NES_VM_COUNT

  LDA $0700, Y
  INY
: STA ATTR_NES_VM_ATTR_START, X
  INC ATTR_NES_VM_COUNT
  INX

  LDA $0700, Y
  INY
  CMP #$FF
  BNE :-
  LDA #$00
  STA ATTR_NES_VM_ATTR_START, X
  LDA #$01
  STA ATTR_NES_HAS_VALUES
  jslb convert_nes_attributes_and_immediately_dma_them, $a0

  PLX
  jmp next_data_set

write_tiles:
    ; our tile source depends on 2 things
    ; 1 - the current NES bank:  all tiles
    ;       are in NES banks 1, 2, and 3
    ;    
    LDA #$80
    STA VMAIN

    LDA PREV_NES_BANK
    CLC
    ADC #$A8
    STA A1B6

    ; address needs to be:
    ; (nes address - $8008) * 2 + $8000
    ; do it this way so it doesn't overflow 16 bit
    setA16
    LDA PREV_NES_BANK
    AND #$00FF
    BNE :+
        ; for bank 8 we substract a different number
        
        LDA $00
        SEC
        SBC #$B501
        BRA :+++        
    :
    CMP #$06
    BNE :+
        
        LDA $00
        SEC
        SBC #$B117
        BRA :++
    :
        
        LDA $00
        SEC
        SBC #$8008
    :
    ASL
    CLC
    ADC #$8000
    STA $08

    LDA $04
    XBA
    ASL
    STA $04
    setAXY8

    LDA $08
    STA A1T6L

    LDA $09
    STA A1T6H

    LDA $03
    STA VMADDH
    LDA $02
    STA VMADDL

    LDA $04
    STA DAS6L

    LDA $05
    STA DAS6H

    LDA #$01
    STA DMAP6
    LDA #$18
    STA BBAD6
    
    LDA #$40
    STA MDMAEN

    LDA VMAIN_STATE
    STA VMAIN

    rtl

; rewrite of CB83 - draws a full screen scene
curr_vm_add = $06
in_attr     = $08

full_screen_draw:
    JSR original_full_screen
    JSR read_attributes_and_convert
    RTL

read_attributes_and_convert:
    STZ VMAIN

    LDA #$23
    STA ATTR_NES_VM_ADDR_HB
    STA VMADDH

    LDA #$C0
    STA VMADDL
    STA ATTR_NES_VM_ADDR_LB

    LDX #$00
    LDA VMDATALREAD
:   LDA VMDATALREAD
    STA ATTR_NES_VM_ATTR_START, X
    INX
    CPX #$20
    BNE :-

    STX ATTR_NES_VM_COUNT

    LDA #$00
    STA ATTR_NES_VM_ATTR_START, X

    LDA #01
    STA ATTR_NES_HAS_VALUES
    jslb convert_nes_attributes_and_immediately_dma_them, $a0

    STZ VMAIN
    LDA #$23
    STA ATTR_NES_VM_ADDR_HB
    STA VMADDH

    LDA #$E0
    STA VMADDL
    STA ATTR_NES_VM_ADDR_LB

    LDX #$00
    LDA VMDATALREAD
:   LDA VMDATALREAD
    STA ATTR_NES_VM_ATTR_START, X
    INX
    CPX #$20
    BNE :-

    STX ATTR_NES_VM_COUNT

    LDA #$00
    STA ATTR_NES_VM_ATTR_START, X

    LDA #01
    STA ATTR_NES_HAS_VALUES


    jslb convert_nes_attributes_and_immediately_dma_them, $a0
    STZ VMAIN
    rts


original_full_screen:
  ; move all sprites off screen
  LDY #$2C
  LDA #$F8
: STA $0214,Y
  DEY
  DEY
  DEY
  DEY
  BPL :-

  LDA $CBF1,X
  STA $03
  LDA $CBF2,X
  STA $04
;   JSR $C132
  jslb set_ppu_control_and_mask_to_0, $a0
  LDA #$00

  STA $20
  STA $FC
  STA $FD
  LDX #$20
  LDY #$00

  LDA RDNMI ; PpuStatus_2002
  STX VMADDH ; PpuAddr_2006
  STX $07
  STY VMADDL ; PpuAddr_2006
  STY $06

  LDA #$00
  STA $00
CBB4:
  LDY $00
  CPY #$08
  BEQ done_full_screen_draw

  LDA ($03),Y
  STA $01
  INY

  LDA ($03),Y
  STA $02
  INY

  STY $00

  JSR full_screen_write_data
  JMP CBB4
done_full_screen_draw:
  RTS ; JMP C102


full_screen_write_data:
  LDY #$00
: LDA ($01),Y
  CMP #$D4
  BEQ :++
  CMP #$D9
  BEQ :+
  STA VMDATAL ; PpuData_2007
cbde:
  INY
  BNE :-
: RTS
:
  INY
  LDA ($01),Y
  INY
  TAX
  LDA ($01),Y
: STA VMDATAL
  DEX
  BNE :-
  BEQ cbde

R_BUTTON = $10

button_configs_fire_subweapon:
.byte $C0, $10

button_configs_swap:
.byte $10, $C0

input_additions:
    ; treat X and A as pushing up and attack
    PHB
    PHK
    PLB
    LDA P1_SNES_BUTTONS
    TAY
    EOR P1_SNES_BUTTONS_HELD
    AND P1_SNES_BUTTONS
    STA P1_SNES_BUTTONS_TRIGGER
    STY P1_SNES_BUTTONS_HELD

    PHA
    LDY OPTIONS_CONTROLS
    AND button_configs_fire_subweapon, Y
    BEQ :+
        LDA $04
        ORA #$48
        STA $04
    :

    PLA
    AND button_configs_swap, Y
    BEQ :+
        LDA OTHER_SUB_WEAPON_HELD
        BEQ :+
            PHA
            LDA $015B
            STA OTHER_SUB_WEAPON_HELD
            PLA
            STA $015B

            LDA $64
            PHA
            LDA OTHER_SUB_WEAPON_MULTIPLIER
            STA $64
            PLA
            STA OTHER_SUB_WEAPON_MULTIPLIER

            LDA #$01
            STA MULTIPLIER_NEEDS_REDRAW
    :
    jsr play_rumble_wave
    jsr send_rumble
    PLB
    rtl

multiplier_tiles:
.word $207A
.word $209A

redraw_multiplier:
  LDA MULTIPLIER_NEEDS_REDRAW
  BEQ :+
    LDA $18
    CMP #$0E  ; we're in the 1 falling cutscene, don't do any drawing
    BEQ :+
    STZ MULTIPLIER_NEEDS_REDRAW
    LDA CURRENT_SUB_WEAPON_MULT
    BEQ :++
    CMP #$B0    ; special value for stopwatch
    BEQ :++
    setAXY16
    LDA #$207A
    STA VMADDL

    LDA CURRENT_SUB_WEAPON_MULT
    AND #$00FF
    ASL
    ASL
    ORA #$0CA0
    STA VMDATAL
    INC
    INC
    STA VMDATAL
    DEC
    PHA
    
    LDA #$209A
    STA VMADDL

    PLA
    STA VMDATAL
    INC
    INC
    STA VMDATAL
    setAXY8
:   rtl
:   
    setAXY16
    LDA #$207A
    STA VMADDL
    LDA #$0C00
    STA VMDATAL
    STA VMDATAL
    LDA #$209A
    STA VMADDL
    LDA #$0C00
    STA VMDATAL
    STA VMDATAL
    setAXY8
    rtl
