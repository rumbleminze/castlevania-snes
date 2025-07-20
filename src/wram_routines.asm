.SEGMENT "WRAM_ROUTINES"

; APU Update routines
routines_start:
LoadSFXRegisters:
    lda $e0
    cmp #$00
    beq sq1_r
    cmp #$04
    beq sq2_r
    cmp #$08
    beq tri_r
noise_r:
    lda ($e2), y
    jsr WriteAPUNoiseCtrl0
    iny
    lda ($e2), y
    jsr WriteAPUNoiseCtrl1
    iny
    lda ($e2), y
    jsr WriteAPUNoiseCtrl2
    iny
    lda ($e2), y
    jsr WriteAPUNoiseCtrl3
    iny
    bra end_r
sq1_r:
    lda ($e2), y
    jsr WriteAPUSq0Ctrl0
    iny
    lda ($e2), y
    jsr WriteAPUSq0Ctrl1
    iny
    lda ($e2), y
    jsr WriteAPUSq0Ctrl2
    iny
    lda ($e2), y
    jsr WriteAPUSq0Ctrl3
    iny
    bra end_r
sq2_r:
    lda ($e2), y
    jsr WriteAPUSq1Ctrl0
    iny
    lda ($e2), y
    jsr WriteAPUSq1Ctrl1
    iny
    lda ($e2), y
    jsr WriteAPUSq1Ctrl2
    iny
    lda ($e2), y
    jsr WriteAPUSq1Ctrl3
    iny
    bra end_r
tri_r:
    lda ($e2), y
    jsr WriteAPUTriCtrl0
    iny
    lda ($e2), y
    jsr WriteAPUTriCtrl1
    iny
    lda ($e2), y
    jsr WriteAPUTriCtrl2
    iny
    lda ($e2), y
    jsr WriteAPUTriCtrl3
    iny
    bra end_r
end_r:
    lda #$00
    rts

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
    xba
    lda #$40
    tsb APUBase+$16
    xba
    sta APUBase+$01
    rts

WriteAPUSq0Ctrl1_Y:
    xba
    lda #$40
    tsb APUBase+$16
    xba
    sty APUBase+$01
    rts    

WriteAPUSq0Ctrl1_I_Y:
    cpy #$00
    bne :+
    jsr WriteAPUSq0Ctrl1
    rts
:
    cpy #$04
    bne :+
    jsr WriteAPUSq1Ctrl1
    rts
:
    sta APUBase+$01, y
    rts

WriteAPUSq0Ctrl1_I_X:
    cpx #$00
    bne :+
    jsr WriteAPUSq0Ctrl1
    rts
:
    cpx #$04
    bne :+
    jsr WriteAPUSq1Ctrl1
    rts
:
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
    phx
    sta APUBase+$03
    tax
    lda Sound__EmulateLengthCounter_length_d3_mixed, x
    sta APUSq0Length
    xba
    lda #$01
    tsb APUBase+$15
    tsb APUExtraControl
    plx
    xba
    rts

WriteAPUSq0Ctrl3_X:
    pha
    stx APUBase+$03
    lda Sound__EmulateLengthCounter_length_d3_mixed, x
    sta APUSq0Length
    lda #$01
    tsb APUBase+$15
    tsb APUExtraControl   
    pla
    rts

WriteAPUSq0Ctrl3_I_Y:
    cpy #$00
    bne :+
    jsr WriteAPUSq0Ctrl3
    rts
:
    cpy #$04
    bne :+
    jsr WriteAPUSq1Ctrl3
    rts
:
    cpy #$08
    bne :+
    jsr WriteAPUTriCtrl3
    rts
:
    jsr WriteAPUNoiseCtrl3    
    rts

WriteAPUSq0Ctrl3_I_X:
    cpx #$00
    bne :+
    jsr WriteAPUSq0Ctrl3
    rts
:
    cpx #$04
    bne :+
    jsr WriteAPUSq1Ctrl3
    rts
:
    cpx #$08
    bne :+
    jsr WriteAPUTriCtrl3
    rts
:
    jsr WriteAPUNoiseCtrl3    
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
    xba
    lda #$80
    tsb APUBase+$16
    xba
    sta APUBase+$05
    rts

WriteAPUSq1Ctrl1_X:
    xba
    lda #$80
    tsb APUBase+$16
    xba
    stx APUBase+$05
    rts   

WriteAPUSq1Ctrl1_Y:
    xba
    lda #$80
    tsb APUBase+$16
    xba
    sty APUBase+$05
    rts   

WriteAPUSq1Ctrl2:
    sta APUBase+$06
    rts

WriteAPUSq1Ctrl2_X:
    stx APUBase+$06
    rts

WriteAPUSq1Ctrl3:
    phx
    sta APUBase+$07
    tax
    lda Sound__EmulateLengthCounter_length_d3_mixed, x
    sta APUSq1Length
    xba
    lda #$02
    tsb APUBase+$15
    tsb APUExtraControl
    plx
    xba
    rts

WriteAPUSq1Ctrl3_X:
    pha
    stx APUBase+$07
    lda Sound__EmulateLengthCounter_length_d3_mixed, x
    sta APUSq1Length
    lda #$02
    tsb APUBase+$15
    tsb APUExtraControl   
    pla
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
    phx
    sta APUBase+$0B
    tax
    lda #$04
    tsb APUExtraControl
    tsb APUBase+$15
    lda Sound__EmulateLengthCounter_length_d3_mixed, x
    sta APUTriLength
    txa
    plx
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
    phx
    sta APUBase+$0F
    tax
    lda #$08
    tsb APUExtraControl
    tsb APUBase+$15
    lda Sound__EmulateLengthCounter_length_d3_mixed, x
    sta APUNoiLength
    txa
    plx
    rts

WriteAPUDMCCounter:
    stx DmcCounter_4011
rts

WriteAPUDMCFreq:
    sta DmcFreq_4010
rts

WriteAPUDMCAddr:
    sta DmcAddress_4012
rts

WriteAPUDMCLength:
    sta DmcLength_4013
rts

WriteAPUDMCPlay:
    sta ApuStatus_4015
    and #%00010000
    sta APUExtraControl
rts

WriteAPUControl:
    sta APUIOTemp
    xba
    lda APUIOTemp
    eor #$ff
    and #$1f
    trb APUBase+$15
    trb APUExtraControl
    lsr APUIOTemp
    bcs :+
        stz APUBase+$03
        stz APUSq0Length
:
    lsr APUIOTemp
    bcs :+
        stz APUBase+$07
        stz APUSq1Length
:
    lsr APUIOTemp
    bcs :+
        stz APUBase+$0B
        stz APUTriLength
:
    lsr APUIOTemp
    bcs :+
        stz APUBase+$0F
        stz APUNoiLength
:
    lsr APUIOTemp
    bcc :+
        lda #$10
        tsb APUBase+$15
        bne :+
            tsb APUExtraControl
:
    xba
    rts

Sound__EmulateLengthCounter_length_d3_mixed:
.byte $06,$06,$06,$06,$06,$06,$06,$06,$80,$80,$80,$80,$80,$80,$80,$80
.byte $0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$02,$02,$02,$02,$02,$02,$02,$02
.byte $15,$15,$15,$15,$15,$15,$15,$15,$03,$03,$03,$03,$03,$03,$03,$03
.byte $29,$29,$29,$29,$29,$29,$29,$29,$04,$04,$04,$04,$04,$04,$04,$04
.byte $51,$51,$51,$51,$51,$51,$51,$51,$05,$05,$05,$05,$05,$05,$05,$05
.byte $1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$06,$06,$06,$06,$06,$06,$06,$06
.byte $08,$08,$08,$08,$08,$08,$08,$08,$07,$07,$07,$07,$07,$07,$07,$07
.byte $0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$08,$08,$08,$08,$08,$08,$08,$08
.byte $07,$07,$07,$07,$07,$07,$07,$07,$09,$09,$09,$09,$09,$09,$09,$09
.byte $0D,$0D,$0D,$0D,$0D,$0D,$0D,$0D,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
.byte $19,$19,$19,$19,$19,$19,$19,$19,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B
.byte $31,$31,$31,$31,$31,$31,$31,$31,$0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C
.byte $61,$61,$61,$61,$61,$61,$61,$61,$0D,$0D,$0D,$0D,$0D,$0D,$0D,$0D
.byte $25,$25,$25,$25,$25,$25,$25,$25,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E
.byte $09,$09,$09,$09,$09,$09,$09,$09,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F
.byte $11,$11,$11,$11,$11,$11,$11,$11,$10,$10,$10,$10,$10,$10,$10,$10

play_queued_track:
  LDA #$00
  STA $E2
  LDA $60

  jslb play_track_hijack, $b2
  rts

queue_boss_music:
  LDA MSU_SELECTED
  BEQ :+
    ; don't so this on stage 18 / 36
    LDA $28
    CMP #$12
    BEQ :+
    CMP #$24
    BEQ :+
    LDA #$01
    STA MSU_FADE_IN_PROGRESS
    LDA #$F5
    STA $95
:
  LDA #$3F
  STA $60

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

.define BRR_PLAYING $FF
sound_hijack:
  jslb check_for_rumble, $a0
  JSR check_for_brr
  CMP #BRR_PLAYING
  ; if brr is playing pretend sfx are muted and just rts
  BNE :+
    LDA #$00
    RTS    
: ; handle as normal
  
  jslb play_track_hijack, $b2
  STA $07F6
  LDA CURRENT_NSF
  CMP #$4E
  BNE :+
    sta $07F6
 :
  STY $07F5
  LDA #$01
  STA $7F
  LDY #$00
  JSR $C1D8
  LDA $07F6
  JSR $8187
  JSR $C1CF
  LDY $07F5
  LDA #$00
  STA $7F
  RTS


.define BRR_ITEM_PICKUP         $16
.define BRR_MONEY_PICKUP        $17
.define BRR_WHIP_PICKUP         $18
.define BRR_ENTER_CASTLE        $19
.define STOPWATCH               $1A
.define BRR_INVINC_PICKUP       $1B
.define BRR_INVINCE_WEAR_OFF    $1C
.define BRR_DOOR_OPEN           $1D
.define BRR_TREASURE_PICKUP     $23
.define BRR_SIMON_HIT           $FD

; set brr attenuation to be > 20 if we should halve the volume
brr_attenuation:
; 16-17
.byte $21 ; item pickup
.byte $10 ; money pickup
; 18 - 1F
.byte $21 ; whip pickup
.byte $10 ; enter castle
.byte $00 ; stopwatch - n/a
.byte $10 ; invinc pickup
.byte $10 ; invinc wear off
.byte $21 ; door open
.byte $00 ; not used
.byte $00 ; not used
; 20 - 23
.byte $00   ; not used
.byte $00   ; not used
.byte $00   ; not used
.byte $10   ; tresure

check_for_brr:
  CMP #BRR_ITEM_PICKUP
  BEQ :+
  CMP #BRR_MONEY_PICKUP
  BEQ :+
  CMP #BRR_WHIP_PICKUP
  BEQ :+
  CMP #BRR_ENTER_CASTLE
  BEQ :+
  CMP #BRR_TREASURE_PICKUP
  BEQ :+
  CMP #BRR_DOOR_OPEN
  BEQ :+
  CMP #BRR_INVINCE_WEAR_OFF
  BEQ :+
  CMP #BRR_INVINC_PICKUP
  BEQ :+
  ; special case for stopwatch playing
  CMP #STOPWATCH
  BEQ stopwatch_pause_music
  BRA :++

    ; we found our BRR!  YAY
 :  
    ; which sample to play
    STA DmcAddress_4012    

    ; set this to be > $20 to cut volume in half
    SEC
    SBC #$16
    TAY
    LDA brr_attenuation, Y
    ; LDA #$08
    STA DmcCounter_4011

    LDA #$08
    STA DmcFreq_4010
    
    LDA #$10
    ORA APUExtraControl
    STA APUExtraControl
    LDA #BRR_PLAYING 
  :
  RTS
stopwatch_pause_music:
    jslb pause_msu_for_stopwatch, $b2
    RTS

lives_options:
.byte $03, $03, $09

set_starting_lives:
  PHY
  LDY OPTIONS_DIFFICULTY
  LDA lives_options, Y
  STA $2A
  PLY
  RTS

set_subweapon_pickup_vars:

  LDA OPTIONS_SUB_WEAPON_SWAP
  BNE :+

  LDA CURRENT_SUB_WEAPON
  BEQ :+
    STA OTHER_SUB_WEAPON_HELD    
    LDA $64
    STA OTHER_SUB_WEAPON_MULTIPLIER
  :
  
  LDA OPTIONS_DIFFICULTY
  CMP #DIFFICULTY_EASY
  BEQ:+
    ; remove the double/triple if we're not on easy
    STZ $79
    STZ $64
  :
  RTS

set_subweapon_on_death:
  LDA OPTIONS_DIFFICULTY
  CMP #DIFFICULTY_EASY
  BEQ :+
  LDA #$00
  STA $015B
  STA $64
  STA OTHER_SUB_WEAPON_HELD
  STA OTHER_SUB_WEAPON_MULTIPLIER
: RTS

starting_hearts:
.byte 5, 0, 30

set_starting_hearts:
  PHY
  LDY OPTIONS_DIFFICULTY
  LDA starting_hearts, Y
  STA $71
  PLY
  RTS

handle_damage:
  LDA $45
  BMI :++
  PHA
  LDA OPTIONS_DIFFICULTY
  CMP #DIFFICULTY_EASY
  BNE :+
    ;   half the damage
    LDA $4B
    LSR
    STA $4B
: 
  LDA OPTIONS_DIFFICULTY
  CMP #DIFFICULTY_HARD
  BNE :+
    ;  double damage
    LDA $4B
    ASL 
    STA $4B
  :
  
  PLA
  SEC
  SBC $4B
  STA $45

: RTS

handle_boss_damage:
  LDA OPTIONS_DIFFICULTY
  CMP #DIFFICULTY_EASY
  BNE :+
    ; double the damage, which is stored in $0D
    ASL $0D
  :

  LDA $01A8
  SEC
  SBC $0C
  STA $01A8
  LDA $01A9
  SBC $0D
  BPL :+
  LDA #$00
: STA $01A9
  RTS

is_easy:
  LDA OPTIONS_DIFFICULTY
  CMP #DIFFICULTY_EASY
  RTS

set_non_knockback_values:
  LDA #$10
  STA $47
  LDA #$30
  STA $5B

  rts


vs_mode_timers:
; levels 1-3 are all 170
.byte $01, $01, $01, $01, $01, $01, $01, $01, $01
; level 4-6 are 370, 470, 670 
.byte $03, $03, $03, $04, $04, $04, $06, $06, $06

set_timer:
  LDA #$00
  STA $42
  LDX $28
  LDA $C9F6,X
  STA $43
  
  LDA OPTIONS_DIFFICULTY
  CMP #DIFFICULTY_HARD
  BNE :+ 
    LDA vs_mode_timers, X
    STA $43
    LDA #$70
    STA $42
  :
  RTS

set_starting_loop:
  PHA
  LDA OPTIONS_LOOP
  STA $2B
  PLA
  STZ $28    
  STZ $0434
  STZ $70
  LDX #$01
  STX $2C
  rts

get_hit_side_effects:
  LDA #$01
  STA RUMBLE_WAVE_FORM_PLAYING
  STZ RUMBLE_WAVE_FORM_IDX
  rts

routines_end: