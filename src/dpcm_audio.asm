.segment "PRGB3"
; Waits for SPC to finish booting. Call before first
; using SPC or after bootrom has been re-run.
; Preserved: X, Y
spc_wait_boot:
    lda #$AA
@wait:  
   cmp $2140
    bne @wait

    ; Clear in case it already has $CC in it
    ; (this actually occurred in testing)
    sta $2140

    lda #$BB
@wait2: 
    cmp $2141
    bne @wait2
rts

; Starts upload to SPC addr Y and sets Y to
; 0 for use as index with spc_upload_byte.
; Preserved: X
spc_begin_upload:
    sty $2142

    ; Send command
    lda $2140
    clc
    adc #$22
    bne skip       ; special case fully verified
    inc
skip:  
    sta $2141
    sta $2140

    ; Wait for acknowledgement
waitUploadStartAck:  
    cmp $2140
    bne waitUploadStartAck

    ; Initialize index
    .byte $A0, $00, $00 ; ldy #$0000
rts

; Uploads byte A to SPC and increments Y. The low byte
; of Y must not changed between calls.
; Preserved: X
spc_upload_byte:
    sta $2141

    ; Signal that it's ready
    tya
    sta $2140
    iny

    ; Wait for acknowledgement
waitUploadByteAck:
    cmp $2140
    bne waitUploadByteAck
rts

spc_init_driver:
    pha
    phx
    phy
    phb
    php
    
    setAXY16
    ldy #.loword(spc_driver)

    phk
    plb
    jsr send_apu_data

    plp
    plb
    ply
    plx
    pla
    rtl

;;; SPC Upload Code Borrowed from Super Metroid ;;;
;;; $8059: Send APU data ;;;
send_apu_data:
;; Parameters:
;;     Y: Address of data
;;     DB: Bank of data

; Data format:
;     ssss dddd [xx xx...] (data block 0)
;     ssss dddd [xx xx...] (data block 1)
;     ...
;     0000 aaaa
; Where:
;     s = data block size in bytes
;     d = destination address
;     x = data
;     a = entry address. Ignored by SPC engine after first APU transfer

; The xx data can cross bank boundaries, but the data block entries otherwise can't (i.e. s, d, a and 0000) unless they're word-aligned

; Wait until APU sets APU IO 0..1 = AAh BBh
; Kick = CCh
; For each data block:
;    APU IO 2..3 = destination address
;    APU IO 1 = 1 (arbitrary non-zero value)
;    APU IO 0 = kick
;    Wait until APU echoes kick back through APU IO 0
;    Index = 0
;    For each data byte
;       APU IO 1 = data byte
;       APU IO 0 = index
;       Wait until APU echoes index back through APU IO 0
;       Increment index
;    Increment index (and again if resulting in 0)
;    Kick = index
; Send entry address through APU IO 2..3
; APU IO 1 = 0
; APU IO 0 = kick
; (Optionally wait until APU echoes kick back through APU IO 0)

        PHP
        REP #$30
        LDA #$3000             ;\
        STA $000641               ;|
                                  ;|
apuWait:
        LDA #$BBAA                ;|
        CMP $002140               ;|
        BEQ apuReady                   ;} Wait until [APU IO 0..1] = AAh BBh
        LDA $000641               ;|
        DEC A                     ;|
        STA $000641               ;|
        BNE apuWait                   ;/
crash:
        BRA crash                   ; If exceeded 3000h attempts: crash

apuReady:
        SEP #$20
        LDA #$CC                  ; Kick = CCh
        BRA processDataBlock     ; Go to BRANCH_PROCESS_DATA_BLOCK

; BRANCH_UPLOAD_DATA_BLOCK
uploadDataBlock:
        LDA $0000,y               ;\
        JSR incY                 ;} Data = [[Y++]]
        XBA                       ;/
        LDA #$00                  ; Index = 0
        BRA uploadData           ; Go to BRANCH_UPLOAD_DATA

; LOOP_NEXT_DATA
loopNextData:
        XBA                       ;\
        LDA $0000,y               ;|
        JSR incY                 ;} Data = [[Y++]]
        XBA
:                                 ;/
        CMP $002140               ;\
        BNE :-                     ;} Wait until APU IO 0 echoes
        INC A                     ; Increment index

; BRANCH_UPLOAD_DAT             
uploadData:
        REP #$20
        STA $002140               ; APU IO 0..1 = [index] [data]
        SEP #$20
        DEX                       ; Decrement X (block size)
        BNE loopNextData                   ; If [X] != 0: go to LOOP_NEXT_DATA
:
        CMP $002140               ;\
        BNE :-                     ;} Wait until APU IO 0 echoes

ensureKick:
        ADC #$03                  ; Kick = [index] + 4
        BEQ ensureKick                     ; Ensure kick != 0

; BRANCH_PROCESS_DATA_BLOCK
processDataBlock:
        PHA
        REP #$20
        LDA $0000,y               ;\
        JSR incY2                ;} X = [[Y]] (block size)
        TAX                       ;} Y += 2
        LDA $0000,y               ;\
        JSR incY2                 ;} APU IO 2..3 = [[Y]] (destination address)
        STA $002142               ;} Y += 2
        SEP #$20
        CPX #$0001                ;\
        LDA #$00                  ;|
        ROL A                     ;} If block size = 0: APU IO 1 = 0 (EOF), else APU IO 1 = 1 (arbitrary non-zero value)
        STA $002141               ;/
        ADC #$7F               ; Set overflow if block size != 0, else clear overflow
        PLA                    ;\
        STA $002140               ;} APU IO 0 = kick
        PHX
        LDX #$1000                ;\

:                                  ;|
        DEX                       ;} Wait until APU IO 0 echoes
        BEQ ret                  ;} If exceeded 1000h attempts: return
        CMP $002140               ;|
        BNE :-                     ;/
        
        PLX
        BVS uploadDataBlock      ; If block size != 0: go to BRANCH_UPLOAD_DATA_BLOCK
        SEP #$20
        STZ $2141               
        STZ $2142               
        STZ $2143               
        PLP
        RTS
ret:
        SEP #$20
        STZ $2141
        STZ $2142
        STZ $2143
        PLX
        PLP
        RTS

;;; $8100: Increment Y twice, bank overflow check ;;;
incY2:
; Only increments Y once if overflows bank first time (which is a bug scenario)
        INY
        BEQ next


;;; $8103: Increment Y, bank overflow check ;;;
incY:
        INY
        BEQ next                 
        RTS
next:
        INC $02                   ; Increment $02
        PEI ($01)                 ;\
        PLB                    ;} DB = [$02]
        PLB                    ;/
        LDY #$8000             ; Y = 8000h
        RTS

dmc_lookup_start_pos = $4060
spc_init_dpcm:
    pha
    phx
    phy
    phb
    php

    PHK
    PLB
    setAXY16
    setA8
;     sep #$20    ; 8-bit A

    jsr spc_wait_boot

    ;  $4000-$400f:  dmc address bytes (see ../nes-spc/spc.asm:267)
    ldy #$4000  ;  Start an upload at $4000 aram
    jsr spc_begin_upload

    lda #$16
    jsr spc_upload_byte

    lda #$18
    jsr spc_upload_byte

    lda #$19
    jsr spc_upload_byte

    lda #$17
    jsr spc_upload_byte

    lda #$23
    jsr spc_upload_byte

    lda #$1D
    jsr spc_upload_byte

    ;  $4010-$401f:  frequency cutoff values (see ../nes-spc/spc.asm:268)
    ldy #$4010  ;  Start an upload at $4010 aram
    jsr spc_begin_upload

    lda #$0f
    jsr spc_upload_byte
    lda #$0f
    jsr spc_upload_byte
    lda #$0f
    jsr spc_upload_byte
    lda #$0f
    jsr spc_upload_byte
    lda #$0f
    jsr spc_upload_byte
    lda #$0F
    jsr spc_upload_byte

    ;  $4020-$405f: SRCN lookup entries (see ../nes-spc/spc.asm:271)
    ldy #$4020  ;  Start an upload at $4020 aram
    jsr spc_begin_upload

;     upload entry for knee
    rep #$30    ; 16-bit load
    lda #dmc_lookup_start_pos
    sep #$20    ; 8-bit A
    jsr spc_upload_byte
    xba
    jsr spc_upload_byte

    rep #$30    ; 16-bit load
    lda #dmc_lookup_start_pos
    sep #$20    ; 8-bit A
    jsr spc_upload_byte
    xba
    jsr spc_upload_byte

    rep #$30    ; 16-bit load
    lda #(dmc_lookup_start_pos + item_pickup_end - item_pickup)
    sep #$20    ; 8-bit A
    jsr spc_upload_byte
    xba
    jsr spc_upload_byte

    rep #$30    ; 16-bit load
    lda #(dmc_lookup_start_pos + item_pickup_end - item_pickup)
    sep #$20    ; 8-bit A
    jsr spc_upload_byte
    xba
    jsr spc_upload_byte        

    rep #$30    ; 16-bit load
    lda #(dmc_lookup_start_pos + whip_18_pickup_end - item_pickup)
    sep #$20    ; 8-bit A
    jsr spc_upload_byte
    xba
    jsr spc_upload_byte

    rep #$30    ; 16-bit load
    lda #(dmc_lookup_start_pos + whip_18_pickup_end - item_pickup)
    sep #$20    ; 8-bit A
    jsr spc_upload_byte
    xba
    jsr spc_upload_byte    

    rep #$30    ; 16-bit load
    lda #(dmc_lookup_start_pos + money_pickup - item_pickup)
    sep #$20    ; 8-bit A
    jsr spc_upload_byte
    xba
    jsr spc_upload_byte

    rep #$30    ; 16-bit load
    lda #(dmc_lookup_start_pos + money_pickup - item_pickup)
    sep #$20    ; 8-bit A
    jsr spc_upload_byte
    xba
    jsr spc_upload_byte    

    rep #$30    ; 16-bit load
    lda #(dmc_lookup_start_pos + money_pickup_end - item_pickup)
    sep #$20    ; 8-bit A
    jsr spc_upload_byte
    xba
    jsr spc_upload_byte   

    rep #$30    ; 16-bit load
    lda #(dmc_lookup_start_pos + money_pickup_end - item_pickup)
    sep #$20    ; 8-bit A
    jsr spc_upload_byte
    xba
    jsr spc_upload_byte 

; door
    rep #$30    ; 16-bit load
    lda #((dmc_lookup_start_pos + (money_pickup_end - item_pickup)) + (treasure_end - treasure))
    sep #$20    ; 8-bit A
    jsr spc_upload_byte
    xba
    jsr spc_upload_byte   

    rep #$30    ; 16-bit load
    lda #((dmc_lookup_start_pos + (money_pickup_end - item_pickup)) + (treasure_end - treasure))
    sep #$20    ; 8-bit A
    jsr spc_upload_byte
    xba
    jsr spc_upload_byte 


    ldy #$4060  ;  Start an upload at $4060 aram
    jsr spc_begin_upload
    ldx #$0000

:
    lda f:item_pickup,x
    jsr spc_upload_byte
    inx
    cpx #(item_pickup_end-item_pickup)
    bne :-

    ldx #$0000

:
    lda f:whip_18_pickup,x
    jsr spc_upload_byte
    inx
    cpx #(whip_18_pickup_end-whip_18_pickup)
    bne :-
    
    ldx #$0000

:
    lda f:entry_19,x
    jsr spc_upload_byte
    inx
    cpx #(entry_19_end-entry_19)
    bne :-

   ldx #$0000

:
    lda f:money_pickup,x
    jsr spc_upload_byte
    inx
    cpx #(money_pickup_end-money_pickup)
    bne :-

   ldx #$0000

:
    lda f:treasure,x
    jsr spc_upload_byte
    inx
    cpx #(treasure_end-treasure)
    bne :-

   ldx #$0000

:
    lda f:door,x
    jsr spc_upload_byte
    inx
    cpx #(door_end-door)
    bne :-

    jsr reset_to_ipc_rom

    plp 
    plb
    ply
    plx
    pla
rtl

;  Execute spc starting at location in Destination (the IPC rom at $ffc0)
reset_to_ipc_rom:
  Destination = $ffc0 ; Program's address in SPC700 RAM
  lda #Destination & $00ff
  sta $2142
  lda #Destination>>8
  sta $2143

  stz $2141          ; Zero = start the program that was sent over

  lda $2140          ; Must be at least 2 higher than the previous APUIO0 value.
  inc
  inc
  sta $2140          ; Tell the SPC700 to start running the new program.

wait:                 ; Wait for the SPC700 to acknowledge this.
  cmp $2140
  bne wait

rts
spc_driver:
.incbin "./spc/spc.bin"
spc_driver_end:

.SEGMENT "PRGB4"
brr:
item_pickup:
 .incbin "sfx/16-item-pickup-16khz.brr"
item_pickup_end:

whip_18_pickup:
 .incbin "sfx/18-whip-pickup-16khz.brr"
whip_18_pickup_end:

entry_19:
.incbin "sfx/19-enter-castle-16khz.brr"
entry_19_end:

money_pickup:
  .incbin "sfx/17-money-pickup-16khz.brr"
money_pickup_end:

.SEGMENT "PRGB5"
treasure:
  .incbin "sfx/23-treasure-11khz.brr"
treasure_end:

door:
.incbin "sfx/1d-door-open.brr"
door_end: