.SEGMENT "WRAM_ROUTINES"

; APU Update routines (much more simplistic than current version)
routines_start:
WriteAPUSq0Ctrl0:
    sta   APUBase
    rts

WriteAPUSq0Ctrl0_I_Y:
    sta   APUBase, y
    rts

WriteAPUSq0Ctrl0_I_X:
    sta   APUBase, x
    rts

WriteAPUSq0Ctrl0_Y:
    sty   APUBase
    rts

WriteAPUSq0Ctrl0_X:
    stx   APUBase
    rts

WriteAPUSq0Ctrl1:
    sta APUBase+$01
    rts

WriteAPUSq0Ctrl1_Y:
    sty APUBase+$01
    rts    

WriteAPUSq0Ctrl1_I_Y:
    sta APUBase+$01, y
    rts

WriteAPUSq0Ctrl1_I_X:
    sta APUBase+$01, x
    rts

WriteAPUSq0Ctrl2:
    sta APUBase+$02
    rts

WriteAPUSq0Ctrl2_X:
    stx APUBase+$02
    rts

WriteAPUSq0Ctrl2_I_Y:
    sta APUBase+$02, y
    rts

WriteAPUSq0Ctrl2_I_X:
    sta APUBase+$02, x
    rts


WriteAPUSq0Ctrl3:
    sta APUSq0Length
    rts

WriteAPUSq0Ctrl3_X:
    stx APUBase+$03
    rts

WriteAPUSq0Ctrl3_I_Y:
    sta APUBase+$03, y
    rts

WriteAPUSq0Ctrl3_I_X:
    sta APUBase+$03, x
    rts

WriteAPUSq1Ctrl0:
    sta APUBase+$04
    rts

WriteAPUSq1Ctrl0_X:
    stx APUBase+$04
    rts

WriteAPUSq1Ctrl0_Y:
    sty APUBase+$04
    rts

WriteAPUSq1Ctrl1:
    sta APUBase+$05
    rts

WriteAPUSq1Ctrl1_X:
    stx APUBase+$05
    rts   

WriteAPUSq1Ctrl1_Y:
    sty APUBase+$05
    rts   

WriteAPUSq1Ctrl2:
    sta APUBase+$06
    rts

WriteAPUSq1Ctrl2_X:
    stx APUBase+$06
    rts

WriteAPUSq1Ctrl3:
    sta APUBase+$07
    rts

WriteAPUSq1Ctrl3_X:
    stx APUBase+$07
    rts

WriteAPUTriCtrl0:
    sta APUBase+$08
    rts

WriteAPUTriCtrl1:
    sta APUBase+$09
    rts

WriteAPUTriCtrl2:
    sta APUBase+$0A
    rts

WriteAPUTriCtrl2_X:
    stx APUBase+$0A
    rts

WriteAPUTriCtrl3:
    sta APUBase+$0B
    rts

WriteAPUNoiseCtrl0:
    sta APUBase+$0C
    rts

WriteAPUNoiseCtrl1:
    sta APUBase+$0D
    rts

WriteAPUNoiseCtrl2:
    sta APUBase+$0E
    rts

WriteAPUNoiseCtrl2_X:
    stx APUBase+$0E
    rts

WriteAPUNoiseCtrl3:
    sta APUBase+$0F
    rts

WriteAPUControl:
    sta APUBase + $15
    rts

bank_switch_rewrite:
  LDA NMITIMEN_STATE
  AND #$7F
  STA NMITIMEN  

  TYA
  INC
  ORA #$A0
  STA BANK_SWITCH_DB
  PHA

  LDA #<bank_switch_jump
  STA BANK_SWITCH_LB
  LDA #>bank_switch_jump
  STA BANK_SWITCH_HB
  JML (BANK_SWITCH_LB)
bank_switch_jump:
  PLB
  TYA
  jslb reset_nmi_status, $a0
  RTS

set_ppu_mask:
  jslb set_ppu_mask_to_accumulator, $a0
  RTS

set_ppu_control:
  jslb update_ppu_control_from_a, $a0
  RTS

c0c0_rewrite:
  LDA PPU_MASK_STATE
  LDX $1F
  BEQ :+
  LDA #$00
: jslb set_ppu_mask_to_accumulator_without_store, $a0
  rts

routines_end: