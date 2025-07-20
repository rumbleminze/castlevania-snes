send_rumble:
  LDA OPTIONS_DISABLE_RUMBLE
  BEQ :+
    ; rumble is off
    RTS
:
  PHX

  LDX #$01
  STX JOYSER0
  NOP
  NOP
  DEX
  STX JOYSER0
  NOP
  NOP

  LDY #$0F
: LDA JOYSER0
  DEY
  BPL :-

  LDX #$40

  STZ WRIO
  BIT JOYSER0
  STX WRIO
  BIT JOYSER0
  BIT JOYSER0
  BIT JOYSER0
  STZ WRIO
  BIT JOYSER0
  BIT JOYSER0
  STX WRIO
  BIT JOYSER0
  STZ WRIO
  BIT JOYSER0

  LDA RUMBLE_P1
  LSR
  STA WRIO
  BIT JOYSER0
  ROL
  STA WRIO
  BIT JOYSER0
  ASL
  STA WRIO
  BIT JOYSER0
  ASL
  STA WRIO
  BIT JOYSER0
  ASL
  STA WRIO
  BIT JOYSER0
  ASL
  STA WRIO
  BIT JOYSER0
  ASL
  STA WRIO
  BIT JOYSER0
  ASL
  STA WRIO
  BIT JOYSER0

  LDA #$FF
  STA WRIO
  PLX
  rts


rumble_lookup_table:
.word $0000
.addr rumble_hit
.addr rumble_whip_right
.addr rumble_whip_left
.addr orb_pickup

play_rumble_wave:
    LDA RUMBLE_WAVE_FORM_PLAYING
    BEQ exit_rumble_wave

      PHB
      PHK
      PLB

      ASL
      TAY
      LDA $00
      PHA
      LDA $01
      PHA

      LDA rumble_lookup_table, Y
      STA $00
      LDA rumble_lookup_table + 1, Y
      STA $01

      LDY RUMBLE_WAVE_FORM_IDX  
      LDA ($00), Y
      STA RUMBLE_P1

      BNE :+
            ; we're done with this rumble wave
            STZ RUMBLE_WAVE_FORM_PLAYING
            STZ RUMBLE_WAVE_FORM_IDX
            STZ RUMBLE_WAVE_FORM_CTR
            BRA :++
      :

      INC RUMBLE_WAVE_FORM_CTR
      INY
      LDA ($00), Y
      CMP RUMBLE_WAVE_FORM_CTR
      BNE :+
        STZ RUMBLE_WAVE_FORM_CTR
        ; next value in rumble wave
        INC RUMBLE_WAVE_FORM_IDX
        INC RUMBLE_WAVE_FORM_IDX
      :

      PLA
      STA $01
      PLA
      STA $00

      PLB
exit_rumble_wave:
    rts



  rumble_waves:
  rumble_hit:
  .byte $22, $10, $00

  rumble_whip_right:
  .byte $20, $06, $11, $03, $01, $03, $02, $04, $00

  rumble_whip_left:
  .byte $02, $06, $11, $03, $10, $03, $20, $04, $00

  orb_pickup:
  .byte $11, $04, $22, $08, $44, $10, $66, $10, $AA, $40, $66, $10, $11, $20, $00

check_for_rumble:
    PHA
    ; disabling whip for now.
    ; CMP #$09
    ; BNE :++
    ;     LDA $450
    ;     ; $450 tracks if the player sprite is mirrored
    ;     ; so if we're mirrored, rumble left
    ;     BEQ :+
    ;         LDA #$03
    ;         STA RUMBLE_WAVE_FORM_PLAYING
    ;         BRA exit_rumble_check
    ;     :
    ;     LDA #$02
    ;     STA RUMBLE_WAVE_FORM_PLAYING
    ;     BRA exit_rumble_check
    ; :

    ; orb
    CMP #$48
    BNE :+
        LDA #$04
        STA RUMBLE_WAVE_FORM_PLAYING
        BRA exit_rumble_check
    :

exit_rumble_check:
    PLA
    rtl