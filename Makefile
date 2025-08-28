# Rumbleminzie's SNES Castlevaina port

# Detecting executables
CC65 := $(shell command -v cc65 2>/dev/null)
CA65 := $(shell command -v ca65 2>/dev/null)
LD65 := $(shell command -v ld65 2>/dev/null)
GO    := $(shell command -v go 2>/dev/null)
EMU   := $(shell command -v Mesen-S 2>/dev/null || command -v higan 2>/dev/null || command -v snes9x 2>/dev/null)

# Check required tools
ifeq ($(CC65),)
$(error "cc65 not found in PATH")
endif
ifeq ($(CA65),)
$(error "ca65 not found in PATH")
endif
ifeq ($(LD65),)
$(error "ld65 not found in PATH")
endif
ifeq ($(GO),)
$(error "go not found in PATH")
endif

GAME := Castlevania
OUTDIR := out
SRCDIR := src

.PHONY: all clean run

all: $(OUTDIR)/$(GAME).sfc

# Create output directory if needed
$(OUTDIR):
	mkdir -p $(OUTDIR)

# Generate options.bin and macro defs
$(SRCDIR)/options.bin $(SRCDIR)/options_macro_defs.asm: 
	$(GO) run utilities/generate_options_asm.go
	mv options.bin $(SRCDIR)/options.bin
	mv options_macro_defs.asm $(SRCDIR)/options_macro_defs.asm

# Build main.o (depends on main.asm, options, and wram_routines.bin if it exists)
$(OUTDIR)/main.o: $(SRCDIR)/main.asm $(SRCDIR)/options.bin $(SRCDIR)/wram_routines.bin | $(OUTDIR)
	$(CA65) $(SRCDIR)/main.asm -o $(OUTDIR)/main.o -g

# Extract WRAM routines from ROM if missing or outdated
$(SRCDIR)/wram_routines.bin: $(OUTDIR)/$(GAME).sfc
	dd if=$(OUTDIR)/$(GAME).sfc of=$(SRCDIR)/wram_routines.bin bs=1 skip=$$((0x1800)) count=$$((0x800))

# Build ROM (depends on main.o and wram_routines.bin)
$(OUTDIR)/$(GAME).sfc: $(OUTDIR)/main.o $(SRCDIR)/wram_routines.bin | $(OUTDIR)
	$(LD65) -C $(SRCDIR)/hirom.cfg -o $(OUTDIR)/$(GAME).sfc $(OUTDIR)/main.o

# Run the ROM in the most accurate emulator available
run: $(OUTDIR)/$(GAME).sfc
ifneq ($(EMU),)
	@echo "Launching emulator: $(EMU)"
	$(EMU) $(OUTDIR)/$(GAME).sfc
else
	@echo "No supported SNES emulator found in PATH."
	@echo "Please install one of: Mesen-S (recommended), Higan, or Snes9x, and add it to PATH."
endif

clean:
	rm -rf $(OUTDIR)/*.o $(OUTDIR)/$(GAME).sfc $(SRCDIR)/options.bin $(SRCDIR)/options_macro_defs.asm $(SRCDIR)/wram_routines.bin