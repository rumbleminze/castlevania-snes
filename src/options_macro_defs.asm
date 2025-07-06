NUM_OPTIONS = 3


; Toggle current option
toggle_current_option:
    LDA #$01
    sta NEEDS_OAM_DMA
    LDA CURR_OPTION
    CMP #0
    BNE :+
    JMP increment_palette
:
    CMP #1
    BNE :+
    JMP increment_lives
:
    CMP #2
    BNE :+
    JMP increment_level
:
RTS


; Decrement current option
decrement_current_option:
    LDA #$01
    sta NEEDS_OAM_DMA
    LDA CURR_OPTION
    CMP #0
    BNE :+
    JMP decrement_palette
:
    CMP #1
    BNE :+
    JMP decrement_lives
:
    CMP #2
    BNE :+
    JMP decrement_level
:
RTS

initialize_options:
   jsr update_palette
   jsr update_lives
   jsr update_level
    rts

option_palette_choice_tiles:
.byte $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $27, $18, $1E, $18, $2C, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34
.byte $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $1F, $18, $1C, $18, $1E, $18, $2E, $18, $31, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34
.byte $18, $34, $18, $34, $18, $34, $18, $20, $18, $2B, $18, $1E, $18, $32, $18, $2C, $18, $1C, $18, $1A, $18, $25, $18, $1E, $18, $34, $18, $34, $18, $34, $18, $34
.byte $18, $27, $18, $1E, $18, $2C, $18, $34, $18, $1C, $18, $25, $18, $1A, $18, $2C, $18, $2C, $18, $22, $18, $1C, $18, $34, $18, $1F, $18, $1B, $18, $31, $18, $34
.byte $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $29, $18, $2F, $18, $26, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34
.byte $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $2B, $18, $1E, $18, $1A, $18, $25, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34
.byte $18, $34, $18, $2C, $18, $26, $18, $28, $18, $28, $18, $2D, $18, $21, $18, $34, $18, $32, $18, $12, $18, $34, $18, $1F, $18, $1B, $18, $31, $18, $34, $18, $34
.byte $18, $34, $18, $34, $18, $34, $18, $34, $18, $1A, $18, $29, $18, $29, $18, $25, $18, $1E, $18, $34, $18, $22, $18, $22, $18, $34, $18, $34, $18, $34, $18, $34

decrement_palette:
	dec $0860
	BPL :+
		LDA #8
		DEC A
		STA $0860
	:
	BRA update_palette

increment_palette:
	inc $0860
	lda $0860
 	CMP #8
	BNE :+	
		LDA #$00
	:
	STA $0860
	BRA update_palette

update_palette:
	LDA RDNMI
:	LDA RDNMI
	BPL :-

	LDA $0860
	ASL
	ASL
	ASL
	ASL
	ASL
	TAY
	LDA #$20
	STA VMADDH

	LDA #$6C
	STA VMADDL

	LDX #$00
:	LDA option_palette_choice_tiles, Y
	STA VMDATAH
	LDA option_palette_choice_tiles + 1, Y
	STA VMDATAL
	INX
	INY
	INY
	CPX #$10
	BNE :-

	jsr option_0_side_effects
	rts

option_lives_choice_tiles:
.byte $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $13, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34
.byte $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $11, $18, $10, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34
.byte $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $13, $18, $10, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34
.byte $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $19, $18, $19, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34

decrement_lives:
	dec $0861
	BPL :+
		LDA #4
		DEC A
		STA $0861
	:
	BRA update_lives

increment_lives:
	inc $0861
	lda $0861
 	CMP #4
	BNE :+	
		LDA #$00
	:
	STA $0861
	BRA update_lives

update_lives:
	LDA RDNMI
:	LDA RDNMI
	BPL :-

	LDA $0861
	ASL
	ASL
	ASL
	ASL
	ASL
	TAY
	LDA #$20
	STA VMADDH

	LDA #$8C
	STA VMADDL

	LDX #$00
:	LDA option_lives_choice_tiles, Y
	STA VMDATAH
	LDA option_lives_choice_tiles + 1, Y
	STA VMDATAL
	INX
	INY
	INY
	CPX #$10
	BNE :-

	jsr option_1_side_effects
	rts

option_level_choice_tiles:
.byte $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $11, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34
.byte $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $12, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34
.byte $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $13, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34
.byte $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $14, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34
.byte $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $15, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34
.byte $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $16, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34

decrement_level:
	dec $0862
	BPL :+
		LDA #6
		DEC A
		STA $0862
	:
	BRA update_level

increment_level:
	inc $0862
	lda $0862
 	CMP #6
	BNE :+	
		LDA #$00
	:
	STA $0862
	BRA update_level

update_level:
	LDA RDNMI
:	LDA RDNMI
	BPL :-

	LDA $0862
	ASL
	ASL
	ASL
	ASL
	ASL
	TAY
	LDA #$20
	STA VMADDH

	LDA #$AC
	STA VMADDL

	LDX #$00
:	LDA option_level_choice_tiles, Y
	STA VMDATAH
	LDA option_level_choice_tiles + 1, Y
	STA VMDATAL
	INX
	INY
	INY
	CPX #$10
	BNE :-

	jsr option_2_side_effects
	rts



; Which Option are we on sprites
option_sprite_y_pos:
.byte $17
.byte $1F
.byte $27
; X, Y, Tile, attributes
options_sprites:
.byte  $04, $17, $3B, $42   ; Option Selection

	.byte 120, 184, $B0, $40 ; tank sprite 1/6
	.byte 128, 184, $A0, $40 ; tank sprite 2/6
	.byte 136, 184, $A5, $20 ; tank sprite 3/6
	.byte 120, 192, $C0, $20 ; tank sprite 4/6
	.byte 128, 192, $E0, $20 ; tank sprite 5/6
	.byte 136, 192, $D0, $20 ; tank sprite 6/6

	.byte 104, 184, $e2, $22 ; Enemy Sprite x/4
	.byte  96, 184, $e1, $22 ; Enemy Sprite x/4
	.byte 104, 192, $e4, $22 ; Enemy Sprite x/4
	.byte  96, 192, $e3, $22 ; Enemy Sprite x/4
	.byte $FF
	