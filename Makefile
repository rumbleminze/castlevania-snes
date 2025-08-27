.PHONY: all clean archive relink check-tools

GAME := Castlevania
SRC_DIR := src
ASAR_DIR := $(SRC_DIR)/asar
OUT_DIR := out
UTIL_DIR := utilities
CFG := $(SRC_DIR)/hirom.cfg

# --- Tool detection ---
CA65 := $(shell command -v ca65 2>/dev/null)
LD65 := $(shell command -v ld65 2>/dev/null)
GO   := $(shell command -v go 2>/dev/null)
ASAR := $(shell command -v asar 2>/dev/null)

ifeq ($(CA65),)
  $(error "ca65 not found! Please install cc65 (https://cc65.github.io/cc65/)")
endif
ifeq ($(LD65),)
  $(error "ld65 not found! Please install cc65 (https://cc65.github.io/cc65/)")
endif
ifeq ($(GO),)
  $(error "go not found! Please install Go (https://go.dev/dl/)")
endif
ifeq ($(ASAR),)
  $(error "asar not found! Please install Asar (https://github.com/RPGHacker/asar)")
endif

# --- cc65 source files (recursive, excluding Asar dir) ---
ASM_SRCS := $(shell find $(SRC_DIR) -name '*.asm' -not -path "$(ASAR_DIR)/*")
ASM_OBJS := $(patsubst $(SRC_DIR)/%.asm,$(OUT_DIR)/%.o,$(ASM_SRCS))
ASM_DEPS := $(ASM_OBJS:.o=.d)

# --- Asar sources ---
ASAR_SRCS := $(shell find $(ASAR_DIR) -name '*.asm')
ASAR_BINS := $(patsubst $(SRC_DIR)/%.asm,$(OUT_DIR)/%.bin,$(ASAR_SRCS))

ROM := $(OUT_DIR)/$(GAME).sfc
WRAM_ROUTINES := $(SRC_DIR)/wram_routines.bin
OPTIONS_BIN := $(SRC_DIR)/options.bin
OPTIONS_MACROS := $(SRC_DIR)/options_macro_defs.asm
GO_OPTIONS_SRC := $(UTIL_DIR)/generate_options_asm.go

all: check-tools $(ROM) archive

check-tools:
	@echo "✔ All required tools found: ca65, ld65, go, asar"

# --- Step 1: Generate options screen files ---
$(OPTIONS_BIN) $(OPTIONS_MACROS): $(GO_OPTIONS_SRC)
	go run $<
	mv options.bin $(OPTIONS_BIN)
	mv options_macro_defs.asm $(OPTIONS_MACROS)

# --- Step 2a: Assemble cc65 sources ---
$(OUT_DIR)/%.o: $(SRC_DIR)/%.asm $(OPTIONS_BIN) $(OPTIONS_MACROS)
	@mkdir -p $(dir $@)
	ca65 $< -o $@ -g --create-dep $(@:.o=.d)

# --- Step 2b: Assemble Asar sources into raw binaries ---
$(OUT_DIR)/%.bin: $(SRC_DIR)/%.asm
	@mkdir -p $(dir $@)
	asar $< $@

# --- Step 3: Link + WRAM extraction ---
$(ROM): $(ASM_OBJS) $(ASAR_BINS) $(CFG)
	ld65 -C $(CFG) -o $@ $(ASM_OBJS)
	dd if=$@ of=$(WRAM_ROUTINES) bs=1 skip=$$((0x001800)) count=$$((0x800))
	$(MAKE) --no-print-directory relink

relink: $(ASM_OBJS) $(ASAR_BINS) $(CFG)
	ld65 -C $(CFG) -o $(ROM) $(ASM_OBJS)

# --- Step 4: Archive final ROM ---
archive: $(ROM)
	mkdir -p $(OUT_DIR)/buildarchive
	cp $(ROM) $(OUT_DIR)/buildarchive/$(GAME)-$$(date '+%Y%m%d%H%M%S').sfc

# --- Cleanup ---
clean:
	rm -rf $(OUT_DIR) $(OPTIONS_BIN) $(OPTIONS_MACROS) $(WRAM_ROUTINES)

# --- Include generated dependencies ---
-include $(ASM_DEPS)
