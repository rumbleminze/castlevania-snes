
; This is a file that can be included to implement the Konami Code in the port
; where in the code the user correctly is
CODE_INDEX  = $0820
JOYPAD1     = $0822
JOYTRIGGER1 = $0824
JOYHELD1    = $0826
buttons     = $0828
KONAMI_CODE_ENABLED = $082A

UP_BUTTON       = $08
DOWN_BUTTON     = $04
LEFT_BUTTON     = $02
RIGHT_BUTTON    = $01

A_BUTTON        = $80
B_BUTTON        = $40
START_BUTTON    = $10
SELECT_BUTTON   = $20

code_values:
.byte UP_BUTTON, UP_BUTTON, DOWN_BUTTON, DOWN_BUTTON
.byte LEFT_BUTTON, RIGHT_BUTTON, LEFT_BUTTON, RIGHT_BUTTON
.byte B_BUTTON, A_BUTTON
.byte $FF


check_for_code_input:
PHA
readjoy:
;     lda #$01
;     STA JOYSER0
;     STA buttons
;     LSR A
;     sta JOYSER0
; loop:
;     lda JOYSER0
;     lsr a
;     rol buttons
;     bcc loop

    LDA JOY1H
    STA buttons

    lda buttons
    ldy JOYPAD1
    sta JOYPAD1
    tya
    eor JOYPAD1
    and JOYPAD1
    sta JOYTRIGGER1
    beq :++ 

    tya
    and JOYPAD1
    sta JOYHELD1

    lda CODE_INDEX
    tay

    lda code_values, y
    cmp JOYTRIGGER1
    beq :+
    stz CODE_INDEX
    bra :++
    ; correct input
:   INY
    INC CODE_INDEX
    LDA code_values, y
    CMP #$FF
    BNE :+
    jsr code_effect

:   
    PLA
    rts

code_effect:
    LDA RDNMI
    : LDA RDNMI
    BEQ :-

    AND #$80
    STZ CGADD    
    LDA #$00
    STA CGDATA
    STA CGDATA

    LDA #$D6
    STA CGDATA
    LDA #$10
    STA CGDATA

    INC KONAMI_CODE_ENABLED
    rts