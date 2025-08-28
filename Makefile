# Makefile for Castlevania SNES port

GAME := Castlevania
OUTDIR := out
SRCDIR := src
CFG := $(SRCDIR)/hirom.cfg

# Detect required tools
CA65 := $(shell which ca65)
LD65 := $(shell which ld65)
GO   := $(shell which go)

# Ensure required tools are in PATH
ifeq ($(CA65),)
  $(error ca65 not found in PATH, please install cc65)
endif
ifeq ($(LD65),)
  $(error ld65 not found in PATH, please install cc65)
endif
ifeq ($(GO),)
  $(error go not found in PATH, please install Go)
endif

all: $(OUTDIR)/$(GAME).sfc

# Generate options assets
$(SRCDIR)/options.bin $(SRCDIR)/options_macro_defs.asm: utilities/generate_options_asm.go
	$(GO) run $<
	mv options.bin $(SRCDIR)/
	mv options_macro_defs.asm $(SRCDIR)/

# First compile pass
$(OUTDIR)/main.o: $(SRCDIR)/main.asm $(SRCDIR)/options.bin $(SRCDIR)/options_macro_defs.asm
	mkdir -p $(OUTDIR)
	$(CA65) $< -o $@ -g

# Link and rebuild once with WRAM routines
$(OUTDIR)/$(GAME).sfc: $(OUTDIR)/main.o $(CFG)
	$(LD65) -C $(CFG) -o $@ $(OUTDIR)/main.o
	# Extract WRAM routines
	dd if=$@ of=$(SRCDIR)/wram_routines.bin bs=1 skip=$$((0x001800)) count=$$((0x800))
	# Rebuild with updated WRAM
	$(CA65) $(SRCDIR)/main.asm -o $(OUTDIR)/main.o -g
	$(LD65) -C $(CFG) -o $@ $(OUTDIR)/main.o

clean:
	rm -rf $(OUTDIR) \
	       $(SRCDIR)/options.bin \
	       $(SRCDIR)/options_macro_defs.asm \
	       $(SRCDIR)/wram_routines.bin
