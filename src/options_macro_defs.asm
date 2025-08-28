NUM_OPTIONS = 8


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
    JMP increment_difficulty
:
    CMP #2
    BNE :+
    JMP increment_loop
:
    CMP #3
    BNE :+
    JMP increment_weaponswap
:
    CMP #4
    BNE :+
    JMP increment_msu1
:
    CMP #5
    BNE :+
    JMP increment_playlist
:
    CMP #6
    BNE :+
    JMP increment_rumble
:
    CMP #7
    BNE :+
    JMP increment_controls
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
    JMP decrement_difficulty
:
    CMP #2
    BNE :+
    JMP decrement_loop
:
    CMP #3
    BNE :+
    JMP decrement_weaponswap
:
    CMP #4
    BNE :+
    JMP decrement_msu1
:
    CMP #5
    BNE :+
    JMP decrement_playlist
:
    CMP #6
    BNE :+
    JMP decrement_rumble
:
    CMP #7
    BNE :+
    JMP decrement_controls
:
RTS

initialize_options:
   jsr update_palette
   jsr update_difficulty
   jsr update_loop
   jsr update_weaponswap
   jsr update_msu1
   jsr update_playlist
   jsr update_rumble
   jsr update_controls
    rts

option_palette_choice_tiles:
.byte $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $27, $18, $1E, $18, $2C, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34
.byte $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $1F, $18, $1C, $18, $1E, $18, $2E, $18, $31, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34
.byte $18, $34, $18, $34, $18, $24, $18, $22, $18, $2D, $18, $2B, $18, $22, $18, $27, $18, $31, $18, $13, $18, $14, $18, $34, $18, $21, $18, $2C, $18, $34, $18, $34
.byte $18, $34, $18, $34, $18, $34, $18, $24, $18, $22, $18, $2D, $18, $2B, $18, $22, $18, $27, $18, $31, $18, $13, $18, $14, $18, $34, $18, $34, $18, $34, $18, $34
.byte $18, $27, $18, $1E, $18, $2C, $18, $34, $18, $1C, $18, $25, $18, $1A, $18, $2C, $18, $2C, $18, $22, $18, $1C, $18, $34, $18, $1F, $18, $1B, $18, $31, $18, $34
.byte $18, $34, $18, $27, $18, $22, $18, $27, $18, $2D, $18, $1E, $18, $27, $18, $1D, $18, $2E, $18, $25, $18, $1A, $18, $2D, $18, $28, $18, $2B, $18, $34, $18, $34
.byte $18, $34, $18, $29, $18, $25, $18, $1A, $18, $32, $18, $1C, $18, $21, $18, $28, $18, $22, $18, $1C, $18, $1E, $18, $34, $18, $11, $18, $10, $18, $34, $18, $34
.byte $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $29, $18, $2F, $18, $26, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34
.byte $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $2B, $18, $1E, $18, $1A, $18, $25, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34
.byte $18, $34, $18, $2C, $18, $26, $18, $28, $18, $28, $18, $2D, $18, $21, $18, $34, $18, $32, $18, $12, $18, $34, $18, $1F, $18, $1B, $18, $31, $18, $34, $18, $34
.byte $18, $34, $18, $2F, $18, $2C, $18, $34, $18, $1C, $18, $1A, $18, $2C, $18, $2D, $18, $25, $18, $1E, $18, $2F, $18, $1A, $18, $27, $18, $22, $18, $1A, $18, $34
.byte $18, $34, $18, $34, $18, $34, $18, $20, $18, $2B, $18, $1E, $18, $32, $18, $2C, $18, $1C, $18, $1A, $18, $25, $18, $1E, $18, $34, $18, $34, $18, $34, $18, $34
.byte $18, $34, $18, $34, $18, $34, $18, $34, $18, $1A, $18, $29, $18, $29, $18, $25, $18, $1E, $18, $34, $18, $22, $18, $22, $18, $34, $18, $34, $18, $34, $18, $34
.byte $18, $34, $18, $34, $18, $2F, $18, $22, $18, $2B, $18, $2D, $18, $2E, $18, $1A, $18, $25, $18, $34, $18, $1B, $18, $28, $18, $32, $18, $34, $18, $34, $18, $34

decrement_palette:
	dec $0860
	BPL :+
		LDA #14
		DEC A
		STA $0860
	:
	BRA update_palette

increment_palette:
	inc $0860
	lda $0860
 	CMP #14
	BNE :+	
		LDA #$00
	:
	STA $0860
	BRA update_palette

update_palette:
	LDA RDNMI
:	LDA RDNMI
	BPL :-

	setAXY16
	LDA $0860
	AND #$00FF

	ASL
	ASL
	ASL
	ASL
	ASL
	TAY

	LDA #$20
	XBA
	ORA #$6C
	STA VMADDL
	setA8

	LDX #$0000
:	LDA option_palette_choice_tiles, Y
	STA VMDATAH
	LDA option_palette_choice_tiles + 1, Y
	STA VMDATAL
	INX
	INY
	INY
	CPX #$0010
	BNE :-
	setAXY8
	jsr option_0_side_effects
	rts

option_difficulty_choice_tiles:
.byte $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $27, $18, $28, $18, $2B, $18, $26, $18, $1A, $18, $25, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34
.byte $18, $34, $18, $34, $18, $34, $18, $34, $18, $2F, $18, $2C, $18, $35, $18, $34, $18, $21, $18, $1A, $18, $2B, $18, $1D, $18, $34, $18, $34, $18, $34, $18, $34
.byte $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $1E, $18, $1A, $18, $2C, $18, $32, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34

decrement_difficulty:
	dec $0861
	BPL :+
		LDA #3
		DEC A
		STA $0861
	:
	BRA update_difficulty

increment_difficulty:
	inc $0861
	lda $0861
 	CMP #3
	BNE :+	
		LDA #$00
	:
	STA $0861
	BRA update_difficulty

update_difficulty:
	LDA RDNMI
:	LDA RDNMI
	BPL :-

	setAXY16
	LDA $0861
	AND #$00FF

	ASL
	ASL
	ASL
	ASL
	ASL
	TAY

	LDA #$20
	XBA
	ORA #$8C
	STA VMADDL
	setA8

	LDX #$0000
:	LDA option_difficulty_choice_tiles, Y
	STA VMDATAH
	LDA option_difficulty_choice_tiles + 1, Y
	STA VMDATAL
	INX
	INY
	INY
	CPX #$0010
	BNE :-
	setAXY8
	jsr option_1_side_effects
	rts

option_loop_choice_tiles:
.byte $18, $34, $18, $34, $18, $34, $18, $34, $18, $11, $18, $2C, $18, $2D, $18, $34, $18, $25, $18, $28, $18, $28, $18, $29, $18, $34, $18, $34, $18, $34, $18, $34
.byte $18, $34, $18, $34, $18, $34, $18, $34, $18, $12, $18, $27, $18, $1D, $18, $34, $18, $25, $18, $28, $18, $28, $18, $29, $18, $34, $18, $34, $18, $34, $18, $34

decrement_loop:
	dec $0862
	BPL :+
		LDA #2
		DEC A
		STA $0862
	:
	BRA update_loop

increment_loop:
	inc $0862
	lda $0862
 	CMP #2
	BNE :+	
		LDA #$00
	:
	STA $0862
	BRA update_loop

update_loop:
	LDA RDNMI
:	LDA RDNMI
	BPL :-

	setAXY16
	LDA $0862
	AND #$00FF

	ASL
	ASL
	ASL
	ASL
	ASL
	TAY

	LDA #$20
	XBA
	ORA #$AC
	STA VMADDL
	setA8

	LDX #$0000
:	LDA option_loop_choice_tiles, Y
	STA VMDATAH
	LDA option_loop_choice_tiles + 1, Y
	STA VMDATAL
	INX
	INY
	INY
	CPX #$0010
	BNE :-
	setAXY8
	jsr option_2_side_effects
	rts

option_weaponswap_choice_tiles:
.byte $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $28, $18, $27, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34
.byte $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $28, $18, $1F, $18, $1F, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34

decrement_weaponswap:
	dec $0863
	BPL :+
		LDA #2
		DEC A
		STA $0863
	:
	BRA update_weaponswap

increment_weaponswap:
	inc $0863
	lda $0863
 	CMP #2
	BNE :+	
		LDA #$00
	:
	STA $0863
	BRA update_weaponswap

update_weaponswap:
	LDA RDNMI
:	LDA RDNMI
	BPL :-

	setAXY16
	LDA $0863
	AND #$00FF

	ASL
	ASL
	ASL
	ASL
	ASL
	TAY

	LDA #$20
	XBA
	ORA #$CC
	STA VMADDL
	setA8

	LDX #$0000
:	LDA option_weaponswap_choice_tiles, Y
	STA VMDATAH
	LDA option_weaponswap_choice_tiles + 1, Y
	STA VMDATAL
	INX
	INY
	INY
	CPX #$0010
	BNE :-
	setAXY8
	jsr option_3_side_effects
	rts

option_msu1_choice_tiles:
.byte $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $28, $18, $27, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34
.byte $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $28, $18, $1F, $18, $1F, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34

decrement_msu1:
	dec $0864
	BPL :+
		LDA #2
		DEC A
		STA $0864
	:
	BRA update_msu1

increment_msu1:
	inc $0864
	lda $0864
 	CMP #2
	BNE :+	
		LDA #$00
	:
	STA $0864
	BRA update_msu1

update_msu1:
	LDA RDNMI
:	LDA RDNMI
	BPL :-

	setAXY16
	LDA $0864
	AND #$00FF

	ASL
	ASL
	ASL
	ASL
	ASL
	TAY

	LDA #$20
	XBA
	ORA #$EC
	STA VMADDL
	setA8

	LDX #$0000
:	LDA option_msu1_choice_tiles, Y
	STA VMDATAH
	LDA option_msu1_choice_tiles + 1, Y
	STA VMDATAL
	INX
	INY
	INY
	CPX #$0010
	BNE :-
	setAXY8
	jsr option_4_side_effects
	rts

option_playlist_choice_tiles:
.byte $18, $34, $18, $34, $18, $34, $18, $28, $18, $2B, $18, $1C, $18, $21, $18, $1E, $18, $2C, $18, $2D, $18, $2B, $18, $1A, $18, $25, $18, $34, $18, $34, $18, $34
.byte $18, $34, $18, $34, $18, $34, $18, $29, $18, $2B, $18, $28, $18, $20, $18, $34, $18, $26, $18, $1E, $18, $2D, $18, $1A, $18, $25, $18, $34, $18, $34, $18, $34
.byte $18, $34, $18, $34, $18, $34, $18, $1C, $18, $21, $18, $2B, $18, $28, $18, $27, $18, $22, $18, $1C, $18, $25, $18, $1E, $18, $2C, $18, $34, $18, $34, $18, $34
.byte $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $2F, $18, $2B, $18, $1C, $18, $16, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34
.byte $18, $34, $18, $34, $18, $34, $18, $34, $18, $26, $18, $2C, $18, $31, $18, $34, $18, $2C, $18, $1C, $18, $1C, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34
.byte $18, $34, $18, $34, $18, $34, $18, $1A, $18, $1D, $18, $25, $18, $22, $18, $1B, $18, $34, $18, $28, $18, $29, $18, $25, $18, $12, $18, $34, $18, $34, $18, $34

decrement_playlist:
	dec $0865
	BPL :+
		LDA #6
		DEC A
		STA $0865
	:
	BRA update_playlist

increment_playlist:
	inc $0865
	lda $0865
 	CMP #6
	BNE :+	
		LDA #$00
	:
	STA $0865
	BRA update_playlist

update_playlist:
	LDA RDNMI
:	LDA RDNMI
	BPL :-

	setAXY16
	LDA $0865
	AND #$00FF

	ASL
	ASL
	ASL
	ASL
	ASL
	TAY

	LDA #$21
	XBA
	ORA #$0C
	STA VMADDL
	setA8

	LDX #$0000
:	LDA option_playlist_choice_tiles, Y
	STA VMDATAH
	LDA option_playlist_choice_tiles + 1, Y
	STA VMDATAL
	INX
	INY
	INY
	CPX #$0010
	BNE :-
	setAXY8
	jsr option_5_side_effects
	rts

option_rumble_choice_tiles:
.byte $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $28, $18, $27, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34
.byte $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $28, $18, $1F, $18, $1F, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34, $18, $34

decrement_rumble:
	dec $0866
	BPL :+
		LDA #2
		DEC A
		STA $0866
	:
	BRA update_rumble

increment_rumble:
	inc $0866
	lda $0866
 	CMP #2
	BNE :+	
		LDA #$00
	:
	STA $0866
	BRA update_rumble

update_rumble:
	LDA RDNMI
:	LDA RDNMI
	BPL :-

	setAXY16
	LDA $0866
	AND #$00FF

	ASL
	ASL
	ASL
	ASL
	ASL
	TAY

	LDA #$21
	XBA
	ORA #$2C
	STA VMADDL
	setA8

	LDX #$0000
:	LDA option_rumble_choice_tiles, Y
	STA VMDATAH
	LDA option_rumble_choice_tiles + 1, Y
	STA VMDATAL
	INX
	INY
	INY
	CPX #$0010
	BNE :-
	setAXY8
	jsr option_6_side_effects
	rts

option_controls_choice_tiles:
.byte $18, $34, $18, $34, $18, $2B, $18, $36, $18, $2C, $18, $30, $18, $1A, $18, $29, $18, $34, $18, $31, $18, $36, $18, $2E, $18, $2C, $18, $1E, $18, $34, $18, $34
.byte $18, $34, $18, $34, $18, $2B, $18, $36, $18, $2E, $18, $2C, $18, $1E, $18, $34, $18, $31, $18, $36, $18, $2C, $18, $30, $18, $1A, $18, $29, $18, $34, $18, $34

decrement_controls:
	dec $0867
	BPL :+
		LDA #2
		DEC A
		STA $0867
	:
	BRA update_controls

increment_controls:
	inc $0867
	lda $0867
 	CMP #2
	BNE :+	
		LDA #$00
	:
	STA $0867
	BRA update_controls

update_controls:
	LDA RDNMI
:	LDA RDNMI
	BPL :-

	setAXY16
	LDA $0867
	AND #$00FF

	ASL
	ASL
	ASL
	ASL
	ASL
	TAY

	LDA #$21
	XBA
	ORA #$4C
	STA VMADDL
	setA8

	LDX #$0000
:	LDA option_controls_choice_tiles, Y
	STA VMDATAH
	LDA option_controls_choice_tiles + 1, Y
	STA VMDATAL
	INX
	INY
	INY
	CPX #$0010
	BNE :-
	setAXY8
	jsr option_7_side_effects
	rts



; Which Option are we on sprites
option_sprite_y_pos:
.byte $17
.byte $1F
.byte $27
.byte $2F
.byte $37
.byte $3F
.byte $47
.byte $4F
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
	