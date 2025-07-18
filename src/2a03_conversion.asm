totals_audio:

SoundEmulateLengthCounters:
    setAXY8
    lda SNDCHANSW4015
    ora #$04
    tay

    bit #$01
    beq sq1

    lda SNDSQR1CTRL4000
    and #$20
    bne :++
    ldx APUSq0Length
    bne :+
    tya
    and #$fe
    tay
    bra sq1
:
    dex
    stx APUSq0Length
:
    tya

sq1:
    bit #$02
    beq noise

    lda SNDSQR2CTRL4004
    and #$20
    bne :++
    ldx APUSq1Length
    bne :+
    tya
    and #$fd
    tay
    bra sq1
:
    dex
    stx APUSq1Length
:
    tya

noise:
    bit #$08
    beq tri

    lda SNDNOISESHM400C
    and #$20
    bne :++
    ldx APUNoiLength
    bne :+
    tya
    and #$f7
    tay
    bra sq1
:
    dex
    stx APUNoiLength
:
    tya

tri:
    ldx SNDTRIACTRL4008
    bpl :++

    ldx APUTriLength
    bne :+
    and #$fb
    bra end
:
    dex
    stx APUTriLength
:
end:
    sta SNDCHANSW4015
    rts

SnesUpdateAudio:
    PHX
    PHY
    PHA
    PHP
    setAXY8


    ; This isn't great but fixes some SFX
    ; but makes the triangle channel never stop
    ; LDA $A08
    ; ORA #$80
    ; STA $A08

    JSR SoundEmulateLengthCounters

    ; hack for death animation, 
    LDA CURRENT_NSF
    CMP #$4E
    BNE :+
        ; if death animation, don't play sound
        stz SNDCHANSW4015
    :

    LDA SNDCHANSW4015
    BNE :++
    ; Silence everything
    LDX #$00
:
    STZ SOUND_EMULATOR_BUFFER_START, x
    INX
    CPX #$17
    BNE :-
:
    LDA APUIO0
    CMP #$7D
    BEQ :+
    JMP End
:
    
    LDA #$D7
    STA APUIO0

:
    LDA APUIO0
    CMP #$D7
    BNE :-

    LDX #$00

:
    LDA SOUND_EMULATOR_BUFFER_START, X
    STA APUIO1
    STX APUIO0

    INX

:   CPX APUIO1
    BNE :-

    CPX #$17
    BNE :--

    LDA #$0F
    STA $A15

    stz $0A10
    stz $0A11
    stz $0A12
    stz $0A13
    stz $0A16

End:
    PLP
    PLA
    PLY
    PLX
    RTL
