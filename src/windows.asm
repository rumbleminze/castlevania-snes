; sets up a black window on the left column of the screen
setup_hide_left_8_pixel_window:
    LDA #$11
    STA TMW

    ; Window 1 Left
    LDA #$00
    STA WH0

    LDA #$10
    STA WH1

    ; window 2 left/right
    LDA #48
    STA WH2

    LDA #216
    STA WH3

    LDA #%00000000
    STA WBGLOG

    LDA #%00000000
    STA WOBJLOG

    LDA #$C8
    STA W12SEL
    STA W12SEL_STATE

    LDA #$08
    STA WOBJSEL
    


    jslb disable_hide_left_8_pixel_window, $a0
    rts

enable_hide_left_8_pixel_window:
    LDA W12SEL_STATE
    ORA #%00000010
    STA W12SEL
    STA W12SEL_STATE

    RTL

disable_hide_left_8_pixel_window:
    LDA W12SEL_STATE
    AND #%11111101
    STA W12SEL
    STA W12SEL_STATE
    RTL
