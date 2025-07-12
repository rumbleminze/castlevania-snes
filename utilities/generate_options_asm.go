package main

import (
    "strings"
	"fmt"
	"os"
)



const startingAddress = 0x2062
const startingOptionAddress = 0x0860
var charToTile = map[rune]byte{
    '0': 0x10, '1': 0x11, '2': 0x12, '3': 0x13, '4': 0x14,
    '5': 0x15, '6': 0x16, '7': 0x17, '8': 0x18, '9': 0x19,
    'A': 0x1A, 'B': 0x1B, 'C': 0x1C, 'D': 0x1D, 'E': 0x1E,
    'F': 0x1F, 'G': 0x20, 'H': 0x21, 'I': 0x22, 'J': 0x23,
    'K': 0x24, 'L': 0x25, 'M': 0x26, 'N': 0x27, 'O': 0x28,
    'P': 0x29, 'Q': 0x2A, 'R': 0x2B, 'S': 0x2C, 'T': 0x2D,
    'U': 0x2E, 'V': 0x2F, 'W': 0x30, 'X': 0x31, 'Y': 0x32,
    'Z': 0x33, ' ': 0x34, '.': 0x35, '-': 0x36, '=': 0x37, 
	'?': 0x38, '!': 0x39,
}

type Option struct {
    Index  int
    Name   string
    Values []string
}

const update_option_asm_template =`
decrement_{option_name_lower}:
	dec {wram_address}
	BPL :+
		LDA #{num_values}
		DEC A
		STA {wram_address}
	:
	BRA update_{option_name_lower}

increment_{option_name_lower}:
	inc {wram_address}
	lda {wram_address}
 	CMP #{num_values}
	BNE :+	
		LDA #$00
	:
	STA {wram_address}
	BRA update_{option_name_lower}

update_{option_name_lower}:
	LDA RDNMI
:	LDA RDNMI
	BPL :-

	LDA {wram_address}
	ASL
	ASL
	ASL
	ASL
	ASL
	TAY
	LDA #{option_vmaddh}
	STA VMADDH

	LDA #{option_vmaddl}
	STA VMADDL

	LDX #$00
:	LDA option_{option_name_lower}_choice_tiles, Y
	STA VMDATAH
	LDA option_{option_name_lower}_choice_tiles + 1, Y
	STA VMDATAL
	INX
	INY
	INY
	CPX #$10
	BNE :-

	jsr option_{index}_side_effects
	rts

`


func generate_options(index int, name string, values []string, outFile *os.File, outAsmFile *os.File) {
	generate_options_tiles(index, name, values, outFile, outAsmFile)
 	// outAsmFile.WriteString(fmt.Sprintf("update_option \"%s\", %d, $%04X, %d\n", strings.ToLower(name), index, startingOptionAddress + index, len(values)))

	option_asm :=  strings.ReplaceAll(update_option_asm_template, "{wram_address}", fmt.Sprintf("$%04X", startingOptionAddress + index))
 	option_asm = strings.ReplaceAll(option_asm, "{num_values}", fmt.Sprintf("%d", len(values)))
  	option_asm = strings.ReplaceAll(option_asm, "{index}", fmt.Sprintf("%d", index))	
	option_asm = strings.ReplaceAll(option_asm, "{option_name}", name)
	option_asm = strings.ReplaceAll(option_asm, "{option_name_lower}", strings.ToLower(name))

	option_vm_add := startingAddress + index * 0x20 + 0x0A
	option_asm = strings.ReplaceAll(option_asm, "{option_vmaddh}", fmt.Sprintf("$%02X", byte(option_vm_add >> 8 & 0xFF)))
 	option_asm = strings.ReplaceAll(option_asm, "{option_vmaddl}", fmt.Sprintf("$%02X", byte(option_vm_add & 0xFF)))
  	outAsmFile.WriteString(option_asm)
}

func generate_options_tiles(index int, name string, values []string, outFile *os.File, outAsmFile *os.File) {

	// .word $2000 ; address on screen
	// .byte $03  ; length of option name
	// .byte $18, $1A, $1B ; tiles for option name
	// each option will be 16 tiles long, we'll pad with spaces

	// option_x:
	// $2080, 3, MSU
	// option_x_choice_tiles:
	// _______ABC________ ; 16 tiles
	// _______DEF________ ; 16 tiles
	// FFFFFFFFFFFFFFFFFF ; end of coices	
	optionAddress := startingAddress + index * 0x20
	outFile.Write([]byte{byte(optionAddress & 0xFF), byte(optionAddress >> 8 & 0xFF)})
	outFile.Write([]byte{byte(len(name))})
	outFile.Write(convertStringToTiles(name))
	outAsmFile.WriteString(fmt.Sprintf("option_%s_choice_tiles:\n", strings.ToLower(name)))

	for _, value := range values {

		valueBytes := convertStringToTiles(formatStringTo16Chars(value))
		outAsmFile.WriteString(".byte ")
		for i, b := range valueBytes {
   			outAsmFile.WriteString(fmt.Sprintf("$%02X", b))
	   		if i != len(valueBytes) - 1 {
	 			outAsmFile.WriteString(", ")
			}
		  }
		outAsmFile.WriteString("\n")
	}	
	

	return
}

func formatStringTo16Chars(input string) string {
    // Convert the string to uppercase
    upper := strings.ToUpper(input)

    // Calculate padding needed
    totalLength := 16
    padding := totalLength - len(upper)
    leftPadding := padding / 2
    rightPadding := padding - leftPadding

    // Add spaces to the left and right
    return strings.Repeat(" ", leftPadding) + upper + strings.Repeat(" ", rightPadding)
}

func convertStringToTiles(name string) []byte {
	var tiles []byte = make([]byte, len(name) * 2)
	for i := 0; i < len(name) * 2; i += 2 {
		tiles[i] = 0x18
		tiles[i + 1] =  charToTile[rune(name[i/2])]
	}

	return tiles
}

func write_options_sprites(options []Option, outAsmFile *os.File) {

outAsmFile.WriteString("\n\n; Which Option are we on sprites\n")
 outAsmFile.WriteString("option_sprite_y_pos:\n")
 for i := 0; i < len(options); i++ {
  outAsmFile.WriteString(fmt.Sprintf(".byte $%02X\n", 0x17 + i * 0x08))	
}
 outAsmFile.WriteString("; X, Y, Tile, attributes\n")
 outAsmFile.WriteString("options_sprites:\n")
 outAsmFile.WriteString(".byte  $04, $17, $3B, $42   ; Option Selection\n") 

	//  we also have some sprites for the palette previews
	palette_preview_sprites := `
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
	`
	outAsmFile.WriteString(palette_preview_sprites)
}

func write_toggle_current_option(options []Option, outAsmFile *os.File) {
	outAsmFile.WriteString("\n\n; Toggle current option\n")
	outAsmFile.WriteString(
`toggle_current_option:
    LDA #$01
    sta NEEDS_OAM_DMA
    LDA CURR_OPTION
`)	
	for _, option := range options {
	outAsmFile.WriteString(fmt.Sprintf("    CMP #%d\n", option.Index))
	outAsmFile.WriteString(fmt.Sprintf("    BNE :+\n"))
	outAsmFile.WriteString(fmt.Sprintf("    JMP increment_%s\n", strings.ToLower(option.Name)))
	outAsmFile.WriteString(":\n")
	}
	outAsmFile.WriteString("RTS\n")
}

func write_decrement_current_option(options []Option, outAsmFile *os.File) {
	outAsmFile.WriteString("\n\n; Decrement current option\n")
	outAsmFile.WriteString(
`decrement_current_option:
    LDA #$01
    sta NEEDS_OAM_DMA
    LDA CURR_OPTION
`)	
	for _, option := range options {
	outAsmFile.WriteString(fmt.Sprintf("    CMP #%d\n", option.Index))
	outAsmFile.WriteString(fmt.Sprintf("    BNE :+\n"))
	outAsmFile.WriteString(fmt.Sprintf("    JMP decrement_%s\n", strings.ToLower(option.Name)))
	outAsmFile.WriteString(":\n")
	}
	outAsmFile.WriteString("RTS\n")

	
	outAsmFile.WriteString("\n")
	outAsmFile.WriteString("initialize_options:\n")
	for _, option := range options {
		 outAsmFile.WriteString(fmt.Sprintf("   jsr update_%s\n", strings.ToLower(option.Name)))
	}
	outAsmFile.WriteString("    rts\n\n")
}

func main() {
	var outFile, _ = os.Create("options.bin")
	defer outFile.Close()

	var outAsmFile, _ = os.Create("options_macro_defs.asm")
 	defer outAsmFile.Close()

	// These are the options that will be available
	// I'm leaving the LifeForce here as an example
	options := []Option{
		{Index: 0, Name: "PALETTE", Values: []string{"NES", "FCEUX", "GREYSCALE", "NES CLASSIC FBX", "PVM", "REAL", "SMOOTH Y2 FBX", "APPLE II"}},
		{Index: 1, Name: "DIFICULTY", Values: []string{"NORMAL", "HARD", "EASY"}},
		{Index: 2, Name: "MSU1", Values: []string{"ON","OFF"}},
		{Index: 3, Name: "PLAYLIST", Values: []string{"PLAYLIST 1","PLAYLIST 2","PLAYLIST 3","PLAYLIST 4","PLAYLIST 5"}},
		// {Index: 4, Name: "KNOCKBACK", Values: []string{"ON", "OFF"}},
		// {Index: 5, Name: "HEARTS", Values: []string{"05", "30"}},
		// {Index: 2, Name: "LEVEL", Values: []string{"1", "2", "3", "4", "5", "6", "7"}},		

	}

	outAsmFile.WriteString(fmt.Sprintf("NUM_OPTIONS = %d\n", len(options)))
	write_toggle_current_option(options, outAsmFile)
	write_decrement_current_option(options, outAsmFile)
	for _, option := range options {
        generate_options(option.Index, option.Name, option.Values, outFile, outAsmFile)
    }

	write_options_sprites(options, outAsmFile)
}