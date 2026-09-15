# ========================================================================
# Rumbleminzie's SNES Castlevania Port - Optimized Makefile
# Supports: Linux, macOS, Termux, MSYS2
# ========================================================================

# ---- Verbosity ----
# make V=1 for full command echo
V ?= 0
ifeq ($(V),0)
Q := @
else
Q :=
endif

# ---- Platform Detection & Configuration ----
UNAME_S := $(shell uname -s)
EXE := $(if $(filter MINGW%,$(UNAME_S)),.exe)
TIMESTAMP := $(shell date '+%Y%m%d%H%M%S')

# ---- Project Layout ----
GAME    ?= Castlevania
SRCDIR  ?= src
OUTDIR  ?= out
ARCHDIR := $(OUTDIR)/buildarchive
DEPDIR  := $(OUTDIR)/deps

# ---- Tool Paths (override with `make CA65=/path/to/ca65` etc.) ----
CA65 ?= ca65$(EXE)
LD65 ?= ld65$(EXE)
GO   ?= go$(EXE)
ASAR ?= asar$(EXE)

# Point this at a local cc65 build/snapshot dir (e.g. a fresh MSYS2 build)
# to fall back to it when the tool isn't already on PATH, same as
# build.sh's `export PATH=$PATH:../cc65-snapshot-win32/bin`.
#   make CC65_DIR=../cc65-snapshot-win32/bin
CC65_DIR ?=
ifneq ($(strip $(CC65_DIR)),)
export PATH := $(PATH):$(CC65_DIR)
endif

# Assembler flags (append DEBUG=0 to drop -g)
DEBUG ?= 1
CA65FLAGS := $(if $(filter 1,$(DEBUG)),-g)

# build.sh generates the options screen only when that block is
# uncommented - it's optional there, so mirror that: off by default,
# turn on with `make BUILD_OPTIONS=1`.
BUILD_OPTIONS ?= 0

# build.sh always does a build -> extract WRAM -> rebuild two-pass link
# so the WRAM routines baked into the ROM are current. Keep that as the
# default here too; `make AUTO_WRAM=0` skips the second pass for a
# faster single-pass build during iteration.
AUTO_WRAM ?= 1

# ---- Emulator discovery ----
# Deferred with `=` (not `:=`) so the three `command -v` subprocess calls
# only ever run if something actually expands $(EMU) - i.e. the `run`
# target - instead of on every invocation of make (clean, help, etc).
EMU = $(or $(shell command -v Mesen-S$(EXE) 2>/dev/null),\
           $(shell command -v higan$(EXE) 2>/dev/null),\
           $(shell command -v snes9x$(EXE) 2>/dev/null))

# ---- Generated Files ----
OPTIONS_FILES  := $(SRCDIR)/options.bin $(SRCDIR)/options_macro_defs.asm
TILEMAP_FILES  := $(SRCDIR)/pause-bg2.bin $(SRCDIR)/msu1-credits.bin
GEN_FILES      := $(TILEMAP_FILES) $(if $(filter 1,$(BUILD_OPTIONS)),$(OPTIONS_FILES))

SPC_BIN  := $(SRCDIR)/spc/spc.bin
WRAM_BIN := $(SRCDIR)/wram_routines.bin

# ---- Build Targets ----
ROM := $(OUTDIR)/$(GAME).sfc
OBJ := $(OUTDIR)/main.o
DEP := $(DEPDIR)/main.d

# ---- Safety / hygiene ----
.SUFFIXES:
.DELETE_ON_ERROR:
MAKEFLAGS += --no-print-directory

.PHONY: all clean run archive extract_wram rebuild_wram spc check-tools help info

ifeq ($(AUTO_WRAM),1)
all: check-tools rebuild_wram archive
else
all: check-tools $(ROM) archive
endif
	@echo "[OK] Build complete: $(ROM)"

help:
	@echo "Available targets:"
	@echo "  all              - Build ROM and archive (default)"
	@echo "  spc              - Build SPC audio binary"
	@echo "  run              - Build and launch in emulator"
	@echo "  extract_wram     - Extract WRAM routines from ROM"
	@echo "  rebuild_wram     - Rebuild with extracted WRAM"
	@echo "  archive          - Archive current ROM"
	@echo "  check-tools      - Verify required tools"
	@echo "  clean            - Remove all generated files"
	@echo ""
	@echo "Useful flags:"
	@echo "  make V=1              - verbose command output"
	@echo "  make DEBUG=0          - build without ca65 -g debug info"
	@echo "  make CA65=path        - override a tool path (also LD65/GO/ASAR)"
	@echo "  make CC65_DIR=path    - append a local cc65 build/snapshot dir to PATH"
	@echo "  make BUILD_OPTIONS=1  - also generate the options screen (off by default)"
	@echo "  make AUTO_WRAM=0      - skip the automatic build->extract->rebuild WRAM pass"

check-tools:
	@command -v $(CA65) >/dev/null || (echo "ERROR: ca65 not found" && exit 1)
	@command -v $(LD65) >/dev/null || (echo "ERROR: ld65 not found" && exit 1)
	@command -v $(GO)   >/dev/null || (echo "ERROR: go not found" && exit 1)
	@echo "[OK] All required tools found"

# ---- Directory Setup ----
$(OUTDIR) $(ARCHDIR) $(DEPDIR):
	$(Q)mkdir -p $@

# ---- Generate Files ----
# Grouped targets (&:) tell make these two outputs come from ONE recipe
# invocation, so `make -j` can't race and run the generator twice.
$(OPTIONS_FILES) &: | $(OUTDIR)
	@echo "Generating options..."
	$(Q)$(GO) run utilities/generate_options_asm.go
	$(Q)mv -f options.bin $(SRCDIR)/ && mv -f options_macro_defs.asm $(SRCDIR)/

$(TILEMAP_FILES) &: | $(OUTDIR)
	@echo "Generating tilemaps..."
	$(Q)$(GO) run utilities/generate_tilemaps.go
	$(Q)mv -f pause-bg2.bin $(SRCDIR)/ && mv -f msu1-credits.bin $(SRCDIR)/

# ---- SPC Binary ----
spc: $(SPC_BIN)

$(SPC_BIN): $(SRCDIR)/spc/spc.asm
	$(Q)if command -v $(ASAR) >/dev/null 2>&1; then \
		echo "Building SPC..."; \
		$(ASAR) $< $@; \
		echo "[OK] Built: $@"; \
	else \
		echo "[SKIP] asar not found, skipping SPC build"; \
		touch $@; \
	fi

# ---- WRAM Initialization ----
$(WRAM_BIN):
	@echo "Creating placeholder WRAM binary..."
	$(Q)touch $@

# ---- Main Assembly & Linking ----
# --create-dep emits a Makefile-format dependency file listing every
# .inc/.asm the source pulls in, so editing an included file now
# correctly triggers a reassembly (previously untracked).
$(OBJ): $(SRCDIR)/main.asm $(GEN_FILES) $(WRAM_BIN) $(SPC_BIN) | $(OUTDIR) $(DEPDIR)
	@echo "Assembling..."
	$(Q)$(CA65) $< -o $@ $(CA65FLAGS) --create-dep $(DEP)

$(ROM): $(OBJ) | $(OUTDIR)
	@echo "Linking..."
	$(Q)$(LD65) -C $(SRCDIR)/hirom.cfg -o $@ $<
	@echo "[OK] ROM generated: $@"

-include $(DEP)

# ---- WRAM Extraction & Rebuild ----
extract_wram: $(ROM)
	@echo "Extracting WRAM routines..."
	$(Q)if command -v xxd >/dev/null 2>&1; then \
		xxd -s 0x1800 -l 0x800 -r $(ROM) $(WRAM_BIN); \
	else \
		dd if=$(ROM) of=$(WRAM_BIN) bs=1 skip=6144 count=2048 2>/dev/null; \
	fi
	@echo "[OK] Extracted: $(WRAM_BIN)"

rebuild_wram: extract_wram $(OBJ)
	@echo "Rebuilding ROM with WRAM..."
	$(Q)$(LD65) -C $(SRCDIR)/hirom.cfg -o $(ROM) $(OBJ)
	@echo "[OK] Rebuild complete: $(ROM)"

# ---- Archiving ----
archive: $(ROM) | $(ARCHDIR)
	$(Q)cp $(ROM) $(ARCHDIR)/$(GAME)-$(TIMESTAMP).sfc
	@echo "[OK] Archived to: $(ARCHDIR)/$(GAME)-$(TIMESTAMP).sfc"

# ---- Run in Emulator ----
run: all
	$(Q)if [ -n "$(EMU)" ]; then \
		echo "Launching: $(EMU)"; \
		"$(EMU)" $(ROM) & \
	else \
		echo "Error: No SNES emulator found in PATH"; \
		echo "Install one of: Mesen-S (recommended), Higan, or Snes9x"; \
		exit 1; \
	fi

# ---- Cleanup ----
clean:
	@echo "Cleaning..."
	$(Q)rm -rf $(OUTDIR) $(GEN_FILES) $(WRAM_BIN) $(SPC_BIN)
	@echo "[OK] Clean complete"

# ========================================================================
# Debug Targets (Optional - Remove if not needed)
# ========================================================================

info:
	@echo "Platform: $(UNAME_S)"
	@echo "CA65: $$(command -v $(CA65) 2>/dev/null || echo 'not found')"
	@echo "LD65: $$(command -v $(LD65) 2>/dev/null || echo 'not found')"
	@echo "GO: $$(command -v $(GO) 2>/dev/null || echo 'not found')"
	@echo "ASAR: $$(command -v $(ASAR) 2>/dev/null || echo 'not found')"
	@echo "EMU: $$(echo $(EMU) | grep -o '[^/]*$$' || echo 'not found')"
	@echo "Timestamp: $(TIMESTAMP)"
