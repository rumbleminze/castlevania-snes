start:
SEI
CLC
XCE

setXY16
LDX #$01FF
TXS
LDA #$A0
PHA
PLB
JSL $A08000

nmi:
    ; PHP
    PHA
    PHX
    PHY
    setAXY8
    ; sometimes the NES doesn't RTI, so we're going to set defaults for when it does that here
    ; jslb set_scrolling_hdma_defaults, $a0
    jslb store_current_hdma_values, $a0
    jslb dma_oam_table_long, $a0
    jslb check_for_palette_updates, $a0
    jslb check_and_copy_attribute_buffer_l, $a0
    ; jump to NES NMI
    CLC
    LDA ACTIVE_NES_BANK
    INC
    ADC #$A0
    STA BANK_SWITCH_DB    
    PHA
    PLB

    ; Castlevania NMI is at C052
    LDA #$c0
    STA BANK_SWITCH_HB
    LDA #$52
    STA BANK_SWITCH_LB
    PLY
    PLX
    PLA
    ; eat one more stack variable
    XBA
    PLA
    XBA
    JML [BANK_SWITCH_LB]

return_from_nes_nmi:
    PHP
    PHA
    PHX
    PHY

    LDA NMITIMEN_STATE 
    AND #$7F
    STA NMITIMEN

    jslb SnesUpdateAudio, $a0
    
    ; handle sprite traslation last, since if that bleeds out of vblank it's ok
    jslb snes_nmi, $a0

    jslb msu_nmi_check, $b2
    jslb translate_8_by_16_sprites, $a0

    LDA RDNMI    
    LDA NMITIMEN_STATE 
    STA NMITIMEN

    PLY
    PLX
    PLA
    PLP
    RTI

; this is used by the MSU video player, ignore it if you don't use it.
_rti:
    JML $C7FF14 
    LDA $01B0
    BEQ :+
    LDA $E6
    BEQ :+
    JSR $D000
:   LDA #$A1
    PHA
    PLB
    JMP start

    rti