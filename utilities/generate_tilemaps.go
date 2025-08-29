package main

import (
    "strings"
	"os"
)



const startingAddress = 0x3001
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
	// skulls
	'^': 0xE6, '&': 0xE7, '*': 0xE8, '(': 0xE9,
}

func formatStringTo32Chars(input string) string {
    // Convert the string to uppercase
    upper := strings.ToUpper(input)

    // Calculate padding needed
    totalLength := 32
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


func main() {
	var msu1CreditsOutFile, _ = os.Create("msu1-credits.bin")
	defer msu1CreditsOutFile.Close()
	var bg2OutFile, _ = os.Create("pause-bg2.bin")
	defer bg2OutFile.Close()

	musicCreditLines := []string{
		"CASTLEVANIA MSU1 MUSIC CREDITS ",
		" ",
		" ",
		" ",
		"ORCHESTRAL - VG MUSIC REVISITED",
		"                EVELYN LARK",
		" ",
		"PROG METAL - AARON LEHNEN",
		" ",
		"CHRONICLES - KONAMI",
		" ",
		"VRC6 - YONE2008",
		" ",
		"MSX SCC - JAN VAN VALBURG",
		"            SL3DZ",
		" ",
		"ADLIB OPL2 - MELONADEM",
		" ",
		" ",
		" ",
		"ARRANGED BY - BATTY",
		" ",
		"PRESS START TO RETURN",
	}

	pauseBg2Lines := []string{
		 "^&    PROG METAL   ^&",
		 "^&    ORCHESTRAL   ^&",
		 "^&    CHRONICLES   ^&",
		 "^&       VRC6      ^&",
		 "^&      MSX SCC    ^&",
		 "^&     ADLIB OPL2  ^&",
		 "^&      MSU OFF    ^&",
		// palettes
		 "*(       NES       *(",	  				
		 "*(      FCEUX      *(", 
		 "*(   KITRINX34 HS  *(",
		 "*(     KITRINX34   *(",
		 "*( NES CLASSIC FBX *(", 
		 "*(  NINTENDULATOR  *(",
		 "*(  PLAYCHOICE 10  *(",
		 "*(       PVM       *(", 
		 "*(      REAL       *(", 
		 "*(  SMOOTH Y2 FBX  *(", 
		 "*(  VS CASTLEVANIA *(",
		 "*(    GREYSCALE    *(",
		 "*(     APPLE II    *(",
		 "*(    VIRTUAL BOY  *(",
	}


	for i, line := range musicCreditLines {
		formattedLine := formatStringTo32Chars(line)
		tiles := convertStringToTiles(formattedLine)

		address := startingAddress + (i * 32)
		msu1CreditsOutFile.Write([]byte{byte(address & 0xFF), byte((address >> 8) & 0xFF)})
		msu1CreditsOutFile.Write(tiles)
		
	}

	msu1CreditsOutFile.Write([]byte{0xFF, 0xFF}) // End of credits marker

	
	for i, line := range pauseBg2Lines {
		formattedLine := formatStringTo32Chars(line)
		tiles := convertStringToTiles(formattedLine)

		address := startingAddress + (i * 32)
		bg2OutFile.Write([]byte{byte(address & 0xFF), byte((address >> 8) & 0xFF)})
		bg2OutFile.Write(tiles)
		
	}

	bg2OutFile.Write([]byte{0xFF, 0xFF}) // End of credits marker
}