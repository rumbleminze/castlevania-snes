show_credits:
:  LDA RDNMI
   LDA RDNMI
   BPL :-

    LDA VMAIN_STATE
    AND #$0F
    STA VMAIN
    LDA #$80
    STA INIDISP
    jslb clear_bg_jsl, $a0
    jsr write_credits_tiles
    
    LDA #$01
    STA TM

    LDA #$0F
    STA INIDISP

credits_input_loop:
    LDA RDNMI
:   LDA RDNMI
    BPL :-

    jslb msu_nmi_check, $b2
    ; we gotta waste some time here
    LDX #$00
:   DEX
    BNE :-
    jsr read_input

    LDA JOYTRIGGER1
    CMP #START_BUTTON
    BNE credits_input_loop
    jmp show_options_screen

write_credits_tiles:
    setXY16
    LDY #$0000

next_credit_line:
    ; get starting address
    LDA credits_tiles, Y
    CMP #$FF
    BEQ exit_credits_write

    PHA
    INY    
    LDA credits_tiles, Y
    STA VMADDH
    PLA
    STA VMADDL
    INY
    LDX #$20

:   LDA credits_tiles, Y
    STA VMDATAH
    INY
    LDA credits_tiles, Y
    STA VMDATAL
    INY
    DEX
    BEQ next_credit_line
    BRA :-

exit_credits_write:
    setAXY8
    RTS

credits_tiles:
.incbin "msu1-credits.bin"
