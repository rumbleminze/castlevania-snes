; lookup table for all of the NES colors
palette_adddresses:
.byte <palette_1_lookup, >palette_1_lookup
.byte <palette_2_lookup, >palette_2_lookup
.byte <palette_3_lookup, >palette_3_lookup
.byte <palette_4_lookup, >palette_4_lookup  
.byte <palette_5_lookup, >palette_5_lookup
.byte <palette_6_lookup, >palette_6_lookup  
.byte <palette_7_lookup, >palette_7_lookup
.byte <palette_8_lookup, >palette_8_lookup
.byte <palette_9_lookup, >palette_8_lookup
.byte <palette_10_lookup, >palette_10_lookup
.byte <palette_11_lookup, >palette_11_lookup
.byte <palette_12_lookup, >palette_12_lookup
.byte <palette_13_lookup, >palette_13_lookup
.byte <palette_14_lookup, >palette_14_lookup

palette_1_lookup:
.byte $8C, $31 ; $00 dark grey
.byte $A0, $44 ; $01 
.byte $42, $50 ; $02 dark blue
.byte $07, $50 ; $03 dark purple blue
.byte $0B, $3C ; $04 dark purple
.byte $0D, $20 ; $05 maroon
.byte $0D, $00 ; $06 burgandy
.byte $6A, $00 ; $07 dark brown
.byte $C6, $00 ; $08 mud green
.byte $21, $01 ; $09 green
.byte $40, $01 ; $0A dark green
.byte $20, $05 ; $0B another dark green
.byte $00, $25 ; $0C dark teal
.byte $00, $00 ; $0D Black
.byte $00, $00 ; $0E Black
.byte $00, $00 ; $0F Black

.byte $B5, $56 ; $10 light grey
.byte $62, $6D ; $11 blue
.byte $08, $7D ; $12 light dark blue
.byte $8E, $7C ; $13 purple
.byte $74, $64 ; $14 
.byte $76, $3C ; $15 dark pink
.byte $D6, $10 ; $16 red
.byte $33, $01 ; $17 Brown 0133
.byte $AD, $01 ; $18 yellow brown
.byte $07, $02 ; $19 
.byte $41, $02 ; $1A green
.byte $20, $1A ; $1B green
.byte $E0, $45 ; $1C teal
.byte $00, $00 ; $1D Black
.byte $00, $00 ; $1E Black
.byte $00, $00 ; $1F Black

.byte $FF, $7F ; $20 white
.byte $CC, $7E ; $21 sky blue
.byte $52, $7E ; $22 light purple
.byte $D8, $7D ; $23 
.byte $BE, $7D ; $24 pink
.byte $BF, $65 ; $25 
.byte $1F, $3A ; $26 peach
.byte $7D, $12 ; $27 orange
.byte $F7, $02 ; $28 
.byte $71, $03 ; $29 neon green
.byte $8B, $1B ; $2A bright green
.byte $88, $43 ; $2B bright teal green
.byte $29, $6F ; $2C bright light blue
.byte $29, $25 ; $2D dark grey
.byte $00, $00 ; $2E Black
.byte $00, $00 ; $2F Black

.byte $FF, $7F ; $30 white
.byte $78, $7F ; $31 light blue
.byte $5A, $7F ; $32 pink grey
.byte $3D, $7F ; $33 pink
.byte $1F, $7F ; $34 
.byte $1F, $77 ; $35 another pink
.byte $3F, $63 ; $36 
.byte $7E, $53 ; $37 
.byte $9C, $4B ; $38 nyi
.byte $B9, $4B ; $39 nyi
.byte $D7, $57 ; $3A nyi
.byte $D6, $67 ; $3B light greenish blue
.byte $B6, $7B ; $3C nyi
.byte $00, $00 ; $3D nyi
.byte $00, $00 ; $3E Black
.byte $00, $00 ; $3F Black


palette_2_lookup:
.byte $CE, $39
.byte $64, $44
.byte $00, $54
.byte $08, $4C
.byte $11, $38
.byte $15, $08
.byte $14, $00
.byte $2F, $00
.byte $A8, $00
.byte $00, $01
.byte $40, $01
.byte $E0, $08
.byte $E3, $2C
.byte $00, $00
.byte $00, $00
.byte $00, $00
.byte $F7, $5E
.byte $C0, $75
.byte $E4, $74
.byte $10, $78
.byte $17, $5C
.byte $1C, $2C
.byte $BB, $00
.byte $39, $05
.byte $D1, $01
.byte $40, $02
.byte $A0, $02
.byte $40, $1E
.byte $00, $46
.byte $00, $00
.byte $00, $00
.byte $00, $00
.byte $FF, $7F
.byte $E7, $7E
.byte $4B, $7E
.byte $39, $7E
.byte $FE, $7D
.byte $DF, $59
.byte $DF, $31
.byte $7F, $1E
.byte $FE, $1E
.byte $50, $0B
.byte $69, $27
.byte $EB, $4F
.byte $A0, $6F
.byte $EF, $3D
.byte $00, $00
.byte $00, $00
.byte $FF, $7F
.byte $95, $7F
.byte $58, $7F
.byte $3A, $7F
.byte $1F, $7F
.byte $1F, $6F
.byte $FF, $5A
.byte $7F, $57
.byte $9F, $53
.byte $FC, $53
.byte $D5, $5F
.byte $F6, $67
.byte $F3, $7B
.byte $18, $63
.byte $00, $00
.byte $00, $00

; greyscale
palette_12_lookup:
.byte $CE, $39, $E7, $1C, $C6, $18, $A5, $14, $E7, $1C, $C6, $18, $C6, $18, $42, $08
.byte $63, $0C, $E7, $1C, $08, $21, $E7, $1C, $E7, $1C, $00, $00, $21, $04, $21, $04
.byte $D6, $5A, $EF, $3D, $AD, $35, $8C, $31, $CE, $39, $AD, $35, $AD, $35, $8C, $31
.byte $CE, $39, $EF, $3D, $31, $46, $10, $42, $EF, $3D, $C6, $18, $21, $04, $21, $04
.byte $DE, $7B, $F7, $5E, $94, $52, $52, $4A, $94, $52, $73, $4E, $94, $52, $B5, $56
.byte $D6, $5A, $F7, $5E, $39, $67, $18, $63, $18, $63, $8C, $31, $21, $04, $21, $04
.byte $DE, $7B, $BD, $77, $7B, $6F, $39, $67, $39, $67, $39, $67, $39, $67, $5A, $6B
.byte $7B, $6F, $7B, $6F, $7B, $6F, $7B, $6F, $7B, $6F, $F7, $5E, $21, $04, $21, $04


;nes classic fbx
palette_5_lookup:
.byte $8C, $31, $00, $44, $23, $4C, $46, $3C, $4A, $30, $0B, $08, $2A, $00, $87, $04
.byte $C4, $04, $01, $05, $02, $09, $E0, $0C, $A0, $28, $00, $00, $00, $00, $00, $00
.byte $B5, $56, $21, $61, $89, $6C, $4D, $64, $52, $54, $73, $24, $D2, $00, $4E, $01
.byte $AB, $09, $E2, $09, $02, $06, $C2, $25, $83, $49, $00, $00, $00, $00, $00, $00
.byte $FF, $7F, $6C, $7E, $F1, $7D, $B6, $7D, $BB, $79, $DC, $55, $1C, $2E, $79, $12
.byte $D5, $02, $0E, $03, $2B, $27, $06, $47, $E9, $66, $08, $21, $00, $00, $00, $00
.byte $FF, $7F, $57, $7F, $39, $7F, $1B, $7F, $1D, $7F, $1F, $73, $3E, $63, $3C, $53
.byte $7B, $4F, $99, $4F, $97, $5F, $B6, $67, $96, $77, $B5, $56, $00, $00, $00, $00

; pvm
palette_8_lookup:
.byte $AD, $31, $40, $38, $03, $40, $06, $38, $0A, $28, $0B, $08, $6A, $00, $87, $00
.byte $C4, $00, $E0, $00, $E0, $00, $E0, $0C, $C0, $24, $00, $00, $00, $00, $00, $00
.byte $F7, $5A, $42, $5D, $A9, $6C, $6C, $6C, $73, $4C, $93, $20, $F4, $00, $51, $01
.byte $AC, $01, $E5, $01, $00, $02, $E0, $21, $E0, $45, $00, $00, $00, $00, $00, $00
.byte $FF, $7F, $AD, $7E, $52, $7E, $36, $7E, $FD, $7D, $FE, $61, $3E, $2E, $BC, $12
.byte $3A, $03, $72, $03, $8C, $1F, $88, $3F, $49, $6F, $49, $25, $00, $00, $00, $00
.byte $FF, $7F, $BA, $7F, $9C, $7F, $7D, $7F, $5E, $7F, $7F, $77, $7F, $5F, $BF, $4F
.byte $DE, $47, $FA, $4B, $F7, $57, $F5, $67, $D9, $7B, $17, $5F, $00, $00, $00, $00

; real
palette_9_lookup:
.byte $AD, $35, $80, $44, $00, $54, $08, $48, $0E, $38, $0F, $20, $0E, $00, $4C, $00
.byte $88, $00, $C6, $00, $40, $01, $00, $21, $00, $31, $00, $00, $42, $08, $42, $08
.byte $F7, $5E, $64, $6D, $E7, $7C, $90, $78, $18, $60, $5A, $38, $9A, $10, $15, $09
.byte $4F, $01, $8B, $01, $20, $02, $C0, $35, $C0, $4D, $84, $10, $42, $08, $42, $08
.byte $FF, $7F, $89, $7E, $31, $7E, $B8, $7D, $5F, $7D, $9F, $5D, $FF, $3D, $5F, $1E
.byte $BB, $02, $34, $13, $69, $27, $25, $53, $03, $77, $6B, $2D, $42, $08, $42, $08
.byte $FF, $7F, $56, $7F, $18, $7F, $FD, $7E, $DF, $7E, $FF, $76, $1F, $63, $5F, $57
.byte $BF, $4B, $DE, $53, $F8, $63, $D5, $7B, $B4, $7F, $18, $63, $84, $10, $42, $08

; smooth y2 FBX
palette_10_lookup:
.byte $AD, $35, $40, $44, $03, $4C, $07, $44, $0C, $30, $0C, $08, $2A, $00, $67, $00
.byte $C3, $00, $00, $01, $00, $01, $E0, $0C, $C0, $2C, $00, $00, $00, $00, $00, $00
.byte $F7, $5E, $21, $69, $A8, $74, $6D, $6C, $53, $54, $74, $24, $D3, $00, $2F, $01
.byte $8A, $01, $E3, $01, $E0, $01, $C0, $1D, $80, $45, $00, $00, $00, $00, $00, $00
.byte $FF, $7F, $8D, $7E, $71, $7E, $16, $7E, $DB, $7D, $DC, $5D, $3C, $36, $7A, $16
.byte $B6, $06, $0F, $0B, $2A, $23, $28, $43, $08, $63, $29, $25, $00, $00, $00, $00
.byte $FF, $7F, $B9, $7F, $7B, $7F, $7D, $7F, $5F, $7F, $5F, $7B, $7F, $67, $9F, $5B
.byte $DE, $57, $FB, $57, $F9, $5F, $F8, $6B, $D8, $7B, $F7, $5E, $00, $00, $00, $00

; GB 
palette_13_lookup:
.word $0180, $00A0, $0040, $0000, $0000, $0000, $0000, $0060
.word $00C0, $0120, $0140, $0120, $0100, $0000, $0000, $0000
.word $02A0, $0160, $0100, $0060, $0060, $0060, $00C0, $0120
.word $01A0, $0200, $0240, $0220, $01E0, $0000, $0000, $0000
.word $03E0, $02C0, $0240, $01C0, $01A0, $01A0, $0200, $0260
.word $02E0, $0360, $0380, $0380, $0320, $0120, $0000, $0000
.word $03E0, $0360, $0340, $0320, $0300, $0300, $0320, $0360
.word $0380, $03A0, $03C0, $03C0, $03A0, $0000, $0000, $0000

; Virtual Boy
palette_14_lookup:
.word $000C, $0005, $0002, $0000, $0000, $0000, $0000, $0003
.word $0006, $0009, $000A, $0009, $0008, $0000, $0000, $0000
.word $0015, $000B, $0008, $0003, $0003, $0003, $0006, $0009
.word $000D, $0010, $0012, $0011, $000F, $0000, $0000, $0000
.word $001F, $0016, $0012, $000E, $000D, $000D, $0010, $0013
.word $0017, $001B, $001C, $001C, $0019, $0009, $0000, $0000
.word $001F, $001B, $001A, $0019, $0018, $0018, $0019, $001B
.word $001C, $001D, $001E, $001E, $001D, $0000, $0000, $0000


; Kitrinx34 HS
palette_3_lookup:
.byte $6B, $2D, $40, $48, $01, $50, $06, $48, $0B, $2C, $0C, $0C, $0B, $00, $48, $00
.byte $A4, $00, $E0, $00, $00, $01, $E0, $08, $A0, $2C, $00, $00, $00, $00, $00, $00
.byte $B5, $56, $21, $75, $C6, $7C, $6D, $78, $34, $54, $56, $28, $B5, $00, $32, $01
.byte $8C, $01, $E5, $01, $20, $02, $00, $26, $A0, $55, $00, $00, $00, $00, $00, $00
.byte $FF, $7F, $8B, $7E, $31, $7E, $D8, $7D, $9E, $7D, $BF, $55, $1F, $26, $7D, $06
.byte $F8, $02, $50, $03, $89, $23, $67, $53, $08, $7F, $08, $21, $00, $00, $00, $00
.byte $FF, $7F, $78, $7F, $3A, $7F, $1D, $7F, $FF, $7E, $1F, $6F, $3F, $5F, $5E, $4F
.byte $9C, $47, $B9, $4B, $D6, $5B, $B5, $6F, $96, $7F, $D6, $5A, $00, $00, $00, $00

; Kitrininx34
palette_4_lookup:
.byte $8C, $31, $80, $3C, $43, $44, $27, $3C, $0A, $28, $0B, $10, $4A, $00, $88, $00
.byte $C5, $00, $01, $01, $00, $01, $00, $11, $C0, $28, $00, $00, $00, $00, $00, $00
.byte $B5, $56, $64, $65, $09, $6D, $CD, $64, $B2, $4C, $D4, $2C, $13, $0D, $51, $01
.byte $8D, $01, $E7, $01, $03, $0A, $E1, $29, $A2, $4D, $00, $00, $00, $00, $00, $00
.byte $FF, $7F, $AF, $7E, $53, $7E, $18, $7E, $FC, $75, $1E, $56, $5D, $36, $9B, $1E
.byte $F7, $12, $32, $1B, $4D, $33, $2B, $57, $EC, $76, $4A, $29, $00, $00, $00, $00
.byte $FF, $7F, $79, $7F, $5B, $7F, $3C, $7F, $3E, $7F, $3F, $6F, $5E, $63, $7D, $57
.byte $9C, $53, $BA, $57, $B8, $5F, $B7, $6F, $98, $7B, $F7, $5E, $00, $00, $00, $00

; VS Castlevania
palette_11_lookup:  
.word $35AD, $3C81, $5401, $5D2C, $2C2C, $304F, $04B0, $092E, $050B, $0000, $1563, $09E4, $2102, $0000, $0000, $0000
.word $5AD6, $5401, $6903, $684D, $6850, $4076, $0455, $0DB5, $09AF, $09E7, $09E7, $3666, $4205, $0000, $0000, $0000
.word $7FFF, $72B0, $7252, $71D7, $6C76, $6C76, $0E59, $12DB, $1339, $0F67, $09E4, $6B8F, $7789, $0000, $0000, $0000
.word $7FFF, $7757, $76D9, $76FC, $767B, $5ADC, $4F5D, $43DE, $43DE, $3ED8, $3FB4, $6B8F, $7734, $0000, $0000, $0000

; playchoice 10
palette_7_lookup:
.byte $AD, $35, $82, $3C, $01, $58, $4D, $61, $2D, $30, $50, $30, $B0, $04, $2E, $09
.byte $2B, $05, $05, $05, $83, $15, $04, $0A, $02, $21, $00, $00, $00, $00, $00, $00
.byte $D6, $5A, $84, $61, $23, $6D, $4E, $6C, $51, $6C, $76, $40, $56, $04, $D6, $0D
.byte $B0, $09, $07, $0A, $04, $0A, $86, $36, $05, $46, $00, $00, $00, $00, $00, $00
.byte $FF, $7F, $D0, $76, $52, $76, $F8, $75, $77, $70, $FB, $75, $5A, $12, $DB, $12
.byte $59, $13, $30, $13, $88, $0F, $AF, $6B, $A9, $77, $00, $00, $00, $00, $00, $00
.byte $FF, $7F, $78, $7B, $FA, $7A, $FD, $7A, $7C, $7A, $FD, $5E, $7E, $53, $FE, $37
.byte $FE, $43, $D8, $33, $D5, $43, $AF, $6B, $55, $7B, $00, $00, $00, $00, $00, $00


; Nesticle
palette_6_lookup:
.byte $8C, $31, $A0, $4C, $22, $60, $07, $5C, $0C, $44, $0F, $20, $0F, $00, $6C, $00
.byte $E6, $00, $21, $01, $60, $01, $40, $01, $00, $29, $00, $00, $00, $00, $00, $00
.byte $B5, $56, $80, $79, $E7, $7C, $6F, $7C, $35, $70, $59, $40, $B9, $08, $34, $01
.byte $CD, $01, $46, $02, $60, $02, $60, $16, $00, $4E, $00, $00, $00, $00, $00, $00
.byte $FF, $7F, $CA, $7E, $31, $7E, $B9, $7D, $7F, $7D, $9F, $69, $FF, $31, $7F, $02
.byte $18, $03, $90, $03, $C9, $0B, $A6, $3F, $46, $77, $29, $25, $00, $00, $00, $00
.byte $FF, $7F, $77, $7F, $5A, $7F, $1D, $7F, $FF, $7E, $FF, $76, $3F, $63, $5F, $4F
.byte $9D, $43, $D9, $43, $F6, $53, $F5, $67, $B5, $7B, $D6, $5A, $00, $00, $00, $00
