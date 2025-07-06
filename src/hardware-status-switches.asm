.define AUDIO_CODE_LOCATION $8000

sound_hijack_routine:
  PHP
  PHB
  PHK
  PLB
  JSR AUDIO_CODE_LOCATION
  jslb SnesUpdateAudio, $a0
  PLB
  PLP
  RTS
sound_hijack_routine_end:

write_sound_hijack_routine_to_ram:
  LDY #$00
: LDA sound_hijack_routine, y
  STA SOUND_HIJACK_ROUTINE_START, Y
  INY
  CPY #(sound_hijack_routine_end - sound_hijack_routine)
  BNE :-
  RTS  

; 17 bytes of code
stack_adjustment_routine:
  setAXY16          ; 2
  LDX #$01FF        ; 3
  TXS               ; 1
  setAXY8           ; 2
  PHB               ; 1
  PLA               ; 1
  STA STACK_ADJUSTMENT_ROUTINE_START + 16         ; 3
  ; JML back to where we came from
  .byte $5C, STACK_ADJUSTMENT_RETURN_LO, STACK_ADJUSTMENT_RETURN_HI, $A0
stack_adjustment_routine_end:

write_stack_adjustment_routine_to_ram:
  LDY #$00
: LDA stack_adjustment_routine, y
  STA STACK_ADJUSTMENT_ROUTINE_START, Y
  INY
  CPY #(stack_adjustment_routine_end - stack_adjustment_routine)
  BNE :-
  RTS

set_stack_pointer_to_01:
  PLA
  STA STACK_RETURN_LB
  PLA
  STA STACK_RETURN_HB
  PLA
  STA STACK_RETURN_DB
  LDA $01

  setAXY16
  ORA #$0100
  TAX
  TXS
  setAXY8

  LDA STACK_RETURN_DB
  PHA
  LDA STACK_RETURN_HB
  PHA
  LDA STACK_RETURN_LB
  PHA
  RTL

reset_sp_to_01ff:
  
  PLA
  STA STACK_RETURN_LB
  PLA
  STA STACK_RETURN_HB
  PLA
  STA STACK_RETURN_DB

  setAXY16
  LDX #$01FF
  TXS
  setAXY8

  LDA STACK_RETURN_DB
  PHA
  LDA STACK_RETURN_HB
  PHA
  LDA STACK_RETURN_LB
  PHA
  RTL

set_sp_to_1bf_reload_ppucontrol:
  PLA
  STA STACK_RETURN_LB
  PLA
  STA STACK_RETURN_HB
  PLA
  STA STACK_RETURN_DB   

  setXY16
  LDX #$01BF
  TXS
  setAXY8

  jslb reset_ppu_control_values, $a0

  LDA STACK_RETURN_DB
  PHA
  LDA STACK_RETURN_HB
  PHA
  LDA STACK_RETURN_LB
  PHA
  RTL 

prg_bank_swap_to_a:
  ; save off xya
  STX BANK_SWITCH_X
  STY BANK_SWITCH_Y
  STA BANK_SWITCH_A

  jslb disable_nmi_no_store, $a0
  ; pull the stack values off
  PLX
  PLY
  PLA

  ; replace the bank with the new one
  LDA BANK_SWITCH_A
  AND #$07
  INC A
  ORA #$A0

  ; push the values back on the stack
  PHA
  PLB
  PHA
  PHY
  PHX

  ; restore xya
  LDA BANK_SWITCH_A
  LDY BANK_SWITCH_Y
  LDX BANK_SWITCH_X
;   jslb reset_nmi_status, $a0
  
  ; rtl, to the new bank
  RTL

store_90_to_nmi_and_ppu_control_states:
  LDA #$90
  STA PPU_CONTROL_STATE

  LDA NMITIMEN_STATE
  ORA #$80
  STA NMITIMEN_STATE
  RTL

reset_ppu_control_values:
  LDA PPU_CONTROL_STATE
  BPL :+
  PHA
  LDA NMITIMEN_STATE
  ORA #$80
  STA NMITIMEN_STATE
  PLA
: jslb update_ppu_control_from_a, $a0 
  RTL

set_ppu_control_and_mask_to_0:
    LDA VMAIN_STATE
    AND #$FC
    STA VMAIN

    LDA NMITIMEN_STATE
    AND #$7F
    STA NMITIMEN

    LDA INIDISP_STATE
    ORA #$80
    STA INIDISP

    RTL

update_ppu_control_from_a:
    ; we only care about a few values for ppu control
    ; these bits Nxxx xIAA
    ; N = NMI enabled
    ; I = Increment mode 0 = H, 1 = V
    ; AA = Base Nametable
    ;   this controls which quadrant of the TileMap the NES shows
    ;   for us this controls what the HB of the the H/V Offset should be
    ; 00 = 2000 = 0 H 0 V
    ; 01 = 2400 = 1 H 0 V
    ; 10 = 2800 = 0 H 1 V
    ; 11 = 2C00 = 1 H 1 V
    STA curr_ppu_ctrl_value
    PHA
    AND #$80
    CMP #$80
    BNE :+
    jslb enable_nmi, $a0
    bra :++
:   jslb disable_nmi_no_store, $a0

:   PLA
    PHA
    AND #$04
    CMP #$04
    BNE :+
    jslb set_vram_increment_to_32_no_store, $a0
    bra :++
:   jslb set_vram_increment_to_1, $a0
:   bra update_offs_values  

update_ppu_control_from_a_store:
    ; we only care about a few values for ppu control
    ; these bits Nxxx xIAA
    ; N = NMI enabled
    ; I = Increment mode 0 = H, 1 = V
    ; AA = Base Nametable
    ;   this controls which quadrant of the TileMap the NES shows
    ;   for us this controls what the HB of the the H/V Offset should be
    ; 00 = 2000 = 0 H 0 V
    ; 01 = 2400 = 1 H 0 V
    ; 10 = 2800 = 0 H 1 V
    ; 11 = 2C00 = 1 H 1 V
    STA curr_ppu_ctrl_value
    PHA
    AND #$80
    CMP #$80
    BNE :+
    jslb enable_nmi_and_store, $a0
    bra :++
:   jslb disable_nmi_and_store, $a0

:   PLA
    PHA
    AND #$04
    CMP #$04
    BNE :+
    jslb set_vram_increment_to_32_and_store, $a0
    bra update_offs_values
:   jslb set_vram_increment_to_1_and_store, $a0

update_offs_values:
    STZ HOFS_HB
    STZ VOFS_HB
    PLA
    pha
    AND #$03
    CMP #$03
    BEQ hvoffset11
    CMP #$02
    BEQ hvoffset10
    CMP #$01
    BEQ hvoffset01

 hvoffset00:   
    bra ret_from_update_ppu_control_from_a

 hvoffset01:  
    INC HOFS_HB
    bra ret_from_update_ppu_control_from_a
 
 hvoffset10:  
    ; INC VOFS_HB
    bra ret_from_update_ppu_control_from_a
 
 hvoffset11:  
    INC HOFS_HB
    ; INC VOFS_HB
    

ret_from_update_ppu_control_from_a:
    ; LDA INIDISP_STATE
    ; STA INIDISP
    ; LDA $F1
    ; AND #$01
    ; STA HOFS_HB
    
    pla
    RTL

update_ppu_control_from_a_and_store:
    STA PPU_CONTROL_STATE
    jslb update_ppu_control_from_a_store, $a0

    rtl

set_ppu_control_to_0_and_store:
    LDA #$00
    STA PPU_CONTROL_STATE

    ; setting to 0 means increment by 1
    LDA VMAIN_STATE
    AND #$FC
    STA VMAIN
    STA VMAIN_STATE

    ; setting to 0 means disable NMI
    LDA NMITIMEN_STATE
    AND #$7F
    STA NMITIMEN
    STA NMITIMEN_STATE

    RTL

update_stored_ppu_mask_value_to_1E:
  LDA #$11
  STA TM_STATE
  LDA #$1E
  STA PPU_MASK_STATE
  rtl

update_ppu_control_store_to_10:
    LDA #$10
    STA PPU_CONTROL_STATE

    ; sets address increment to 1, we do that with vmain
    STZ VMAIN_STATE

    ; disables NMI
    STZ NMITIMEN_STATE
    RTL

set_ppu_mask_to_00:
    STZ TM
    jslb force_blank_no_store, $a0
    rtl

set_ppu_mask_to_stored_value:
    LDA TM_STATE
    STA TM
    BEQ :+
    LDA #$0F
    STA INIDISP
    RTL
:   jslb force_blank_and_store, $a0
    RTL


set_ppu_mask_to_accumulator_and_store:

    sta PPU_MASK_STATE

set_ppu_mask_to_accumulator_without_store:
    CMP #$00
    BNE set_ppu_mask_to_accumulator
    STZ TM_STATE
    BRA set_ppu_mask_to_00

set_ppu_mask_to_accumulator:
    PHA
    AND #$18
    CMP #$18
    BNE :+
        LDA #$11
        BRA :++++
:   CMP #$10
    BNE :+
        LDA #$10
        BRA :+++
:   CMP #$08
    BNE :+
        LDA #$01
        BRA :++
:   LDA #$00    
:    
    STA TM
    beq :+
        
        LDA #$0F
        STA INIDISP
        pla
        RTL
    :

    PLA
    RTL
    

update_vh_write_by_0b:
  LDA VMAIN_STATE
  AND #$FC
  LDX $0B
  BPL :+  
  ORA #$01
: STA $06
  STA VMAIN

  RTL

update_ppu_mask_store_to_1e:
    LDA #$1E
    STA PPU_MASK_STATE
    ; turns on BG and sprites
    jslb update_values_for_ppu_mask, $a0
    RTL

update_values_for_ppu_mask:
    STZ TM_STATE
    ; we only care about bits 10 (sprites and 08 bg)
    LDA PPU_MASK_STATE
    AND #$06
    BNE :+
    jslb enable_hide_left_8_pixel_window, $a0
    BRA :++
:   jslb disable_hide_left_8_pixel_window, $a0
:   LDA PPU_MASK_STATE
    AND #$10
    CMP #$10
    BNE :+
    STA TM_STATE
    : LDA PPU_MASK_STATE
    AND #$08
    CMP #$08
    BNE :+
    LDA #$01
    ORA TM_STATE
    STA TM_STATE
    : 
    
    LDA TM_STATE
    STA TM
    BEQ :+
    LDA #$0F
    STA INIDISP
    RTL

:   jslb force_blank_and_store, $a0
    RTL

enable_nmi_and_store:
    ; make sure any NMI flags are clear
    LDA RDNMI
    LDA NMITIMEN_STATE
    ORA #$80
    STA NMITIMEN_STATE
    STA NMITIMEN

    LDA PPU_CONTROL_STATE
    ORA #$80
    STA PPU_CONTROL_STATE

    ; not sure on this
    ; LDA PPU_MASK_STATE
    ; BEQ :+
    ; LDA INIDISP_STATE
    ; AND #$7F
    ; STA INIDISP
    ; STA INIDISP_STATE
    ; :
    RTL

enable_nmi:
    LDA RDNMI
    LDA NMITIMEN_STATE
    ORA #$80
    STA NMITIMEN

    RTL

reset_tm_state:
    LDA TM_STATE
    STA TM
    RTL
    
disable_nmi_and_store:
    LDA NMITIMEN_STATE
    AND #$7F
    STA NMITIMEN_STATE
    STA NMITIMEN

    LDA PPU_CONTROL_STATE
    AND #$7F
    STA PPU_CONTROL_STATE

    RTL

disable_nmi_no_store:
    LDA NMITIMEN_STATE
    AND #$7F
    STA NMITIMEN

    RTL

reset_nmi_status:
    ; make sure any NMI flags are clear
    LDA RDNMI
    LDA NMITIMEN_STATE
    STA NMITIMEN
    RTL

reset_nmi_and_inidisp_status:
    jslb reset_nmi_status, $a0
    jslb reset_inidisp, $a0
    RTL

set_vram_increment_to_1:
    LDA VMAIN_STATE
    AND #$FC
    STA VMAIN
    RTL

set_vram_increment_to_1_and_store:
    LDA PPU_CONTROL_STATE
    AND #$FB
    STA PPU_CONTROL_STATE

    LDA VMAIN_STATE
    AND #$FC
    STA VMAIN
    STA VMAIN_STATE
    RTL

set_vram_increment_to_32_and_store:
    LDA PPU_CONTROL_STATE
    ORA #$04
    STA PPU_CONTROL_STATE

    LDA VMAIN_STATE
    ORA #$01
    STA VMAIN
    STA VMAIN_STATE

    RTL

set_vram_increment_to_32_no_store:
    LDA VMAIN_STATE
    ORA #$01
    STA VMAIN

    RTL

reset_vmain_and_inidisp:
    jslb reset_vmain_to_stored_state, $a0
    jslb reset_inidisp, $a0
    RTL

reset_vmain_to_stored_state:
    LDA VMAIN_STATE
    STA VMAIN
    RTL

force_blank_and_store:
    LDA INIDISP_STATE
    ORA #$80
    STA INIDISP
    STA INIDISP_STATE
    RTL

force_blank_no_store:
    LDA INIDISP_STATE
    ORA #$80
    STA INIDISP
    RTL

turn_off_forced_blank_and_store:    
    LDA INIDISP_STATE
    AND #$7F
    STA INIDISP_STATE
    STA INIDISP
    RTL

reset_inidisp:
    LDA INIDISP_STATE
    STA INIDISP
    RTL

disable_nmi_and_fblank_no_store:
    jslb force_blank_no_store, $a0
    jslb disable_nmi_no_store, $a0
    RTL
    
handle_mmc1_control_register:
  STA BANK_SWITCH_CTRL_REGS
  AND #$03
  CMP #$03
  BNE :+
  LDA #$22
  BRA :++
: LDA #$21  
: STA BG1SC
  STZ $3B
  LDA PPU_CONTROL_STATE
  jslb update_ppu_control_from_a, $a0
  jslb set_scrolling_hdma_defaults, $a0
  rtl


vmaddh_range:
.byte $20, $21, $22, $23, $20, $21, $22, $23, $24, $25, $26, $27, $24, $25, $26, $27

convert_a_to_vmaddh_range:
  PHA
  LDA BANK_SWITCH_CTRL_REGS
  AND #$01
  BEQ store_vmaddh_for_vertical_mirroring

  PLA
  CMP #$28
  BMI :+
  AND #$23
  ORA #$04
  BRA store

: CMP #$24
  BMI store
  AND #$23

store:
  RTL

store_vmaddh_for_vertical_mirroring:
  PLA
  ; 20-23 = 20-23
  ; 24-27 = 24-27
  ; 28-2B = 20-23
  ; 2C-2F = 24-27
  AND #$27
  BRA store

store_vmaddh_to_proper_range:
    jslb convert_a_to_vmaddh_range, $a0
    STA VMADDH
    RTL