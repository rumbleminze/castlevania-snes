
infidelitys_scroll_handling:

  ; LDA $F1
  ; AND #$01
  LDA curr_ppu_ctrl_value
  PHA 
  AND #$80
  BNE :+
  LDA #$00
  BRA :++
: LDA #$80
: STA NMITIMEN
  PLA        
  PHA 
  AND #$04
  ; A now has the BG table address
  BNE :+
  LDA #$00
  BRA :++
: LDA #$01   
: STA VMAIN 
  PLA 
  AND #$03
  BEQ :+
  CMP #$01
  BEQ :++
  CMP #$02
  BEQ :+++
  CMP #$03
  BEQ :++++
: STZ HOFS_HB
  STZ VOFS_HB
  BRA :++++   ; RTL
: LDA #$01
  STA HOFS_HB
  STZ VOFS_HB
  BRA :+++    ; RTL
: STZ HOFS_HB
  LDA #$01
  ; STA VOFS_HB
  BRA :++     ; RTL
: LDA #$01
  STA HOFS_HB
  ; STA VOFS_HB

: RTL 


setup_hdma:
; TODO figure out when we don't have hud, migh tbe able to skip
  ; LDA $200
  ; CMP #$C5
  ; BEQ :+
  ;   JMP nohud
  ; :

  ; line count
  ;   HOFS_LB, HOFS_HB, VOFS_LB, VOFS_LB
  ; x3
  ; 00
  ; set up 47 lines of hud
  LDA #47
  STA SCROLL_HDMA_START
  STZ SCROLL_HDMA_START + 1
  STZ SCROLL_HDMA_START + 2
  STZ SCROLL_HDMA_START + 3
  STZ SCROLL_HDMA_START + 4

  LDA #1
  STA SCROLL_HDMA_START + 5
  LDA curr_hoff_low  
  STA SCROLL_HDMA_START + 6
  LDA curr_ppu_ctrl_value
  AND #$01
  STA SCROLL_HDMA_START + 7
  LDX curr_voff_low
  LDA $A0A180,X
  STA SCROLL_HDMA_START + 8
  LDX curr_ppu_ctrl_value
  LDA $A0A610,X
  STA SCROLL_HDMA_START + 9
  STZ SCROLL_HDMA_START + 10

  rtl


  LDX curr_voff_low
  LDA $A0A080,X
  STA SCROLL_HDMA_START + 0
  LDA $A0A180,X
  STA SCROLL_HDMA_START + 3
  LDA $A0A280,X

  STA SCROLL_HDMA_START + 5
  LDA $A0A380,X
  STA SCROLL_HDMA_START + 8
  
  LDA $A0A480,X
  STA SCROLL_HDMA_START + 10
  LDA $A0A560,X
  STA SCROLL_HDMA_START + 13

  LDA curr_hoff_low
  STA SCROLL_HDMA_START + 1
  STA SCROLL_HDMA_START + 6
  STA SCROLL_HDMA_START + 11
  
  ; lda $F1
  ; AND #$01
  ; lda #$00
  LDA curr_ppu_ctrl_value
  AND #$01
  STA SCROLL_HDMA_START + 2
  STA SCROLL_HDMA_START + 7
  STA SCROLL_HDMA_START + 12

  ; v-hi byte
  LDX curr_ppu_ctrl_value
  LDA $A0A610,X
  STA SCROLL_HDMA_START + 4
  STA SCROLL_HDMA_START + 9
  STA SCROLL_HDMA_START + 14

 
  LDY #$0A
  LDA SCROLL_HDMA_START
  STA LINES_COMPLETE


  LDA SCROLL_HDMA_START + 5
  CLC
  ADC LINES_COMPLETE
  STA LINES_COMPLETE
  SEC
  SBC #LINE_TO_START_HUD

  BMI :+
    ; hit the end on 2nd one, back it up
    STA LINES_COMPLETE
    LDA SCROLL_HDMA_START + 5
    SEC
    SBC LINES_COMPLETE
    STA SCROLL_HDMA_START + 5
    BRA write_hud_values
  :

  LDY #$0F
  LDA SCROLL_HDMA_START + 10
  CLC
  ADC LINES_COMPLETE
  STA LINES_COMPLETE
  SEC
  SBC #LINE_TO_START_HUD
  BMI :+
    ; hit the end on the 3rd one, back it up
    STA LINES_COMPLETE
    LDA SCROLL_HDMA_START + 10
    SEC
    SBC LINES_COMPLETE
    STA SCROLL_HDMA_START + 10
    BRA write_hud_values
  :
    ; didn't get to enough lines, we actually have to bump up the last one
    LDA #LINE_TO_START_HUD
    SBC LINES_COMPLETE
    ADC SCROLL_HDMA_START + 10
    STA SCROLL_HDMA_START + 10

write_hud_values:
  ; 1 line (last write)
  ;   HOFS_LB (always 0), HOFS_HB, VOFS_LB, VOFS_LB



  LDA $40 ; 00 = Horizontal LVL, 01 = Vertical
  Beq :+
    ; 8 pixels of empty tiles
    LDA #08
    STA SCROLL_HDMA_START, Y
    
    INY 
    LDA #$00
    STA SCROLL_HDMA_START, Y  
    
    INY
    LDA #$01
    STA SCROLL_HDMA_START, Y

    INY
    LDA #$3C
    STA SCROLL_HDMA_START, Y

    INY
    LDA #$00
    STA SCROLL_HDMA_START, Y

    ; now hud    
    LDA #01
    STA SCROLL_HDMA_START, Y
    
    INY 
    LDA #$00
    STA SCROLL_HDMA_START, Y  
    
    INY
    LDA #$01
    STA SCROLL_HDMA_START, Y
    INY 
    LDA #$30
    STA SCROLL_HDMA_START, Y  
    INY 
    LDA #$00
    STA SCROLL_HDMA_START, Y  

    BRA :++
  : 
    ; for horizontal levels. some of them need to be adjusted
    ; because for some god-forsaken reason
    ; they moved the hud around by 8 pixels.

    LDA #01
    STA SCROLL_HDMA_START, Y
    
    INY 
    LDA #$00
    STA SCROLL_HDMA_START, Y  
    
    INY
    LDA #$01
    STA SCROLL_HDMA_START, Y
    INY 
    LDA #$38
    STA SCROLL_HDMA_START, Y  
    INY 
    LDA #$00
    STA SCROLL_HDMA_START, Y  
    
  :



end_hdma:
  ; end hdma byte
  LDA #$00
  INY
  STA SCROLL_HDMA_START, Y


  RTL

adjust_previous_hdma_for_attributes:
    ; Y - 2 is the line count, change that to #08
    LDA #$08
    STA SCROLL_HDMA_START - 2, Y

    ; pull the other values from Y - 5 (previous set)
    LDA SCROLL_HDMA_START - 6, Y
    STA SCROLL_HDMA_START - 1, Y

    LDA SCROLL_HDMA_START - 5, Y
    STA SCROLL_HDMA_START, Y

    LDA SCROLL_HDMA_START - 4, Y
    STA SCROLL_HDMA_START + 1, Y

    LDA SCROLL_HDMA_START - 3, Y
    STA SCROLL_HDMA_START + 2, Y

    INY
    INY
    INY
    LDA #01
    STA SCROLL_HDMA_START, Y
    
    INY 
    LDA #$00
    STA SCROLL_HDMA_START, Y  
    
    INY
    LDA #$01
    STA SCROLL_HDMA_START, Y

    LDA VOFS_LB ;  #$00
    CLC
    ADC #$08
    RTS

nohud:

  LDX curr_voff_low
  LDA $A0A080,X
  STA SCROLL_HDMA_START + 0
  LDA $A0A180,X
  STA SCROLL_HDMA_START + 3

  LDA $A0A280,X
  STA SCROLL_HDMA_START + 5
  LDA $A0A380,X
  STA SCROLL_HDMA_START + 8
  
  LDA $A0A480,X
  STA SCROLL_HDMA_START + 10
  LDA $A0A560,X
  STA SCROLL_HDMA_START + 13

  LDA curr_hoff_low
  STA SCROLL_HDMA_START + 1
  STA SCROLL_HDMA_START + 6
  STA SCROLL_HDMA_START + 11

  LDA HOFS_HB
  STA SCROLL_HDMA_START + 2
  STA SCROLL_HDMA_START + 7
  STA SCROLL_HDMA_START + 12

  ; v-hi byte, always 0 for BM
  ; LDX VOFS_HB  
  ; LDA $A0A610,X
  STZ SCROLL_HDMA_START + 4
  STZ SCROLL_HDMA_START + 9
  STZ SCROLL_HDMA_START + 14

  STZ SCROLL_HDMA_START + 15

  RTL

default_scrolling_hdma_values:
.byte $6F, $00, $92, $00, $C9, $58, $00, $92, $00, $C9, $27, $00, $00, $00, $01, $00

set_scrolling_hdma_defaults:

  LDA $3D
  AND #$04
  BEQ :+
  LDA $3E
  AND #$01
  BEQ :+
  jmp simple_scrolling

: PHY
  PHB
  LDA #$A0
  PHA
  PLB
  LDY #$00
: LDA default_scrolling_hdma_values, Y
  CPY #$0f
  BEQ :+
  STA SCROLL_HDMA_START, Y
  INY
  BRA :-

: PLB
  PLY
  RTL

  ; used where we just want to set the scroll to 0,0 and not worry about 
; attributes, because they'll naturally be offscreen
simple_scrolling:
  LDA #$00
  STA BG1VOFS
  LDA #$00
  STA BG1VOFS
  STZ BG1HOFS
  STZ BG1HOFS
  STZ SCROLL_HDMA_START
  STZ SCROLL_HDMA_START + 1
  STZ SCROLL_HDMA_START + 2
: RTL

