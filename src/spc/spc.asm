print "spc-driver = ", pc
spc_driver:
arch spc700-inline
org $1000
startpos start

;========================================
;       NES Registers
;----------------------------------------

sq4000     = $40 ; $4000 - Pulse/square 0 channel
sq4001     = $41 ; $4001
sq4002     = $42 ; $4002
sq4003     = $43 ; $4003
sq4004     = $44 ; $4004 - Pulse/square 1 channel
sq4005     = $45 ; $4005
sq4006     = $46 ; $4006
sq4007     = $47 ; $4007
tr4008     = $48 ; $4008 - Triangle channel
tr4009     = $49 ; $4009
tr400A     = $4A ; $400A
tr400B     = $4b ; $400B
no400C     = $4C ; $400C - Noise channel
no400D     = $4D ; $400D
no400E     = $4E ; $400E
no400F     = $4F ; $400F
pcm_freq   = $50 ; $4010 - DMC channel
pcm_raw    = $51 ; $4011
pcm_addr   = $52 ; $4012
pcm_length = $53 ; $4013

sound_ctrl = $55 ; $4015

no4016     = $56 ; $4016
; Bit flags for no4016:
; 0x01 = Reset square 0
; 0x02 = Reset square 1
; 0x04 = Reset triangle
; 0x08 = Reset noise
; 0x10 = Initiate dmc playback
; 0x20 = Mono
; 0x40 = Square 0 sweep
; 0x80 = Square 1 sweep


;=====================
;     SPC Memory
;---------------------

pulse0duty       = $60
pulse0dutyold    = $61
pulse1duty       = $62
pulse1dutyold    = $63
puls0_sample     = $64
puls1_sample     = $65
puls0_sample_old = $66
puls1_sample_old = $67
temp1            = $68
temp2            = $69
temp3            = $6A
temp4            = $6B
temp5            = $6C
temp6            = $6D
temp7            = $6E
temp8            = $6F
old4003          = $70

sweeptemp1    = $78
sweeptemp2    = $79
sweep_freq_lo = $7A
sweep_freq_hi = $7B

linear_count_lo = $7D
linear_count_hi = $7E
timer3count_lo  = $7F
timer3count_hi  = $80
sweep1          = $81
sweep2          = $82
sweep_freq_lo2  = $83
sweep_freq_hi2  = $84
timer3val       = $85 ; Captures up counter for Timer 3. Value only ever 0, 1, or 2
decay1volume    = $86
decay1rate      = $87 ; Square 0 channel
decay_status    = $88 ; Voice bit flags indicating which have currently decrementing length counters
decay2volume    = $89
decay2rate      = $8A ; Square 1 channel
decay3volume    = $8B
decay3rate      = $8C ; Noise channel
tri_sample      = $8E
voicesPlaying   = $8f ; Voice bit flags tracking which are currently playing


;=====================
;     Constants
;---------------------

;  Voice flags
!Square0Flag  = #%00000001
!Square1Flag  = #%00000010
!TriangleFlag = #%00000100
!NoiseFlag    = #%00001000
!DmcFlag      = #%00010000

;  SPC dsp registers
!Square0VolumeL  = #$00
!Square0VolumeR  = #$01
!Square1VolumeL  = #$10
!Square1VolumeR  = #$11
!TriangleVolumeL = #$20
!TriangleVolumeR = #$21
!NoiseVolumeL    = #$30
!NoiseVolumeR    = #$31
!DmcVolumeL      = #$40
!DmcVolumeR      = #$41

!Square0PitchL  = #$02
!Square0PitchH  = #$03
!Square1PitchL  = #$12
!Square1PitchH  = #$13
!TrianglePitchL = #$22
!TrianglePitchH = #$23
!NoisePitchL    = #$32
!NoisePitchH    = #$33
!DmcPitchL      = #$42
!DmcPitchH      = #$43

!Square0SRCN  = #$04
!Square1SRCN  = #$14
!TriangleSRCN = #$24
!NoiseSRCN    = #$34
!DmcSRCN      = #$44

!KON          = #$4c
!KOFF         = #$5c


;  To enable dmc audio, preload a lookup table in aram at address $4000 as follows:
;  $4000-$400f:  (Up to) 16 one-byte dmc address bytes that appear in NES register $4012 (pcm_addr)
;  $4010-$401f:  (Up to) 16 one-byte frequency cutoff value that dictates the playback speed to be used.
;                        Values less than these bytes will trigger the .slowspeed playback rate.
;                        Appears in NES register $4010 (pcm_freq)
;  $4020-$405f:  (Up to) 16 directory entries for the brr samples in audio ram.
;                        This data is appended directly after the static directory lookup data at aram $0200
;  One byte value below indicating volume attenuation cutoff as it appears in NES register $4011 (pcm_raw)
;  (this is very game specific, and most games do not use this trickery (Zelda 1 does)):
dmc_attenuation_cutoff: db $20

;  Example dmc table (for Zelda 1):
;  $4000-$400f:  $00,$1d,$20,$4c,$80
;  $4010-$401f:  $0f,$0f,$0f,$0f,$0d
;  $4020-$405f:  $4014,$4014,$5631,$5631,$58b0,$58b0,$7cc2,$7cc2,$9e28,$9e28
;                (little endian, as it appears in aram: 14 40 14 40 31 56 31 56 B0 58 B0 58 C2 7C C2 7C 28 9E 28 9E)
;========================================


start:
        clrp                    ; clear direct page flag (DP = $0000-$00FF)
        mov x,#$F0
        mov SP,x

        mov a,#%00110000
        mov $F1,a               ; clear all ports, disable timers

        call reset_dsp         ; clear DSP registers
        call set_directory     ; set sample directory

        mov $F2,#$5D           ; directory offset
        mov $F3,#$02           ; $200

        ;  Voices:
        ;   0: Square Wave 0
        ;   1: Square Wave 1
        ;   2: Triangle Wave
        ;   3: Noise
        ;   4: dmc

        mov $F2,#$05            ; ADSR off, GAIN enabled
        mov $F3,#0
        mov $F2,#$15            ; ADSR off, GAIN enabled
        mov $F3,#0
        mov $F2,#$25
        mov $F3,#0
        mov $F2,#$35
        mov $F3,#0
        mov $F2,#$45
        mov $F3,#0

        mov $F2,#$07            ; infinite gain
        mov $F3,#$1F
        mov $F2,#$17            ; infinite gain
        mov $F3,#$1F
        mov $F2,#$27
        mov $F3,#$1F
        mov $F2,#$37
        mov $F3,#$5F
        mov $F2,#$47
        mov $F3,#$7F

        ;  Init triangle voice
        mov $F2,!TriangleSRCN            ; sample # for triangle
        mov $F3,#triangle_sample_num
        mov $F2,!TriangleVolumeL
        mov $F3,#$7F    ; max vol L
        mov $F2,!TriangleVolumeR
        mov $F3,#$7F    ; max vol R

        mov $F2,!NoiseSRCN
        mov $F3,#$00            ; sample # for noise


        mov $F2,!KON
        mov $F3,#%00001111      ;  KON sq0, sq1, tri, and noise


        mov $F2,#$0C            ; main vol L
        mov $F3,#$7F
        mov $F2,#$1C            ; main vol R
        mov $F3,#$7F

        mov $F2,#$6C
        mov $F3,#%00100000      ; soft reset, mute, and echo disabled

        mov $F2,#$6D            ; Echo buffer address
        mov $F3,#$7d

        mov $F2,#$3D            ; noise on voice 3
        mov $F3,!NoiseFlag

        call enable_timer3

        ; Zero port 4 for CPU-side optimization
        mov $F7,#0

next_xfer:
        mov $F4,#$7D            ; move $7D to port 0 (SPC ready)
wait:
        
        call check_timer3
        call check_timers
        call check_timers2

wait2:
        mov a,$F4
        cmp	a,$F4
        bne	wait2

        cmp a,#$F5              ; wait for port 0 to be $F5 (Reset)
        beq to_reset
        cmp a,#$D7              ; wait for port 0 to be $D7 (CPU ready)
        bne wait
        mov $F4,a               ; reply to CPU with $D7 (begin transfer)
        mov $F5, #$ff

        ; 63.613 cycles per scanline
        ; Transfer via HDMA must take no more than 66 cycles per byte
        ; Cycles used during transfer: 25 = 3+2 + 3+5+4 + 2+2+4

        mov x,#0
xfer:
        cmp x,$F4               ; wait for port 0 to have current byte #
        bne xfer

        mov a,$F5               ; load data on port 1
        mov $40+x,a             ; store data at $40 - $55

        inc x
        mov a, x
        mov $F5, a
        cmp x,#$17
        bne xfer

        jmp square0

to_reset:
        mov     $F2,!KOFF
        mov     $F3,#$FF        ;  KOFF all notes

        mov	$F1,#$B0
        jmp $ffc0

;=====================================


;-------------------------------------
square0:

        mov a,sound_ctrl
        and a,!Square0Flag
        bne sq0_enabled
silence:
        mov x,!Square0Flag        ; Square 0 voice
        call stopVoiceInX

        jmp square1

sq0_enabled:

;-------------------------------------
                                ; emulate duty cycle (select sample #)
                                ; check first the octave sample to be played

        mov a,sq4000            ; emulate duty cycle
        and a,#%11000000
		xcn	a

		and	puls0_sample,#$03
		or	a,puls0_sample
        mov puls0_sample,a
        cmp a,puls0_sample_old
        beq sq1_no_change

sq1_sample_change:
        mov $F2,!Square0SRCN            ; sample # reg
        mov $F3,puls0_sample

sq1_no_change:
        mov puls0_sample_old,puls0_sample
                
;-------------------------------------

        ; check if sweeps are enabled
        mov a,$41
        and a,#%10000000
        beq skip00
        mov a,$41
        and a,#%00000111
        beq skip00

        call check_timers
        bra nextsq0

skip00:
        mov a,sq4003            ; check if freq is 0 or too high
        and a,#%00000111
        bne ok1
        mov a,sq4002
        ;cmp a,#8
        ;bcc silence

ok1:
        and $43,#%00000111

        mov a,$42
        clrc
        rol a
        push p
        clrc
        adc a,#freqtable&255
        rol temp3
        mov temp1,a
        pop p
        mov a,$43
        rol a
        ror temp3
        adc a,#(freqtable/256)&255
        mov temp2,a

        mov	x,#$02
        call change_pulse

;-----------------------------------------------

nextsq0:
        mov a,no4016
        and a,!Square0Flag
        beq .afterResetCheck

        ;  A "reset sq0" in no4016 inidicates a nes apu write just happened to $4003
        ;  KOFF the channel and KON again required to emulate what the NES APU does
        mov x,!Square0Flag
        call stopVoiceInX
        call playVoiceInX

.afterResetCheck
        mov a,sq4000            ; check volume decay disable
        and a,#%00010000
        bne decay_disabled

        call check_timer3

        mov a,no4016
        and a,!Square0Flag
        beq no_reset

;        mov a,sq4000
;        and a,#%00001111
;        mov x,a
;        mov a,volume_decay_rates+X
;        mov decay1rate,a
        bra no_reset            ;  TODO: opt


volume_decay_rates:
        db 3
        db 6
        db 9
        db 12
        db 15
        db 18
        db 21
        db 24
        db 27
        db 30
        db 33
        db 36
        db 40
        db 44
        db 48
        db 52
        db 56

;        mov a,sq4000
;        and a,#%00001111
;        mov x,a
;        mov a,volume_decay_table+X
;        mov $F2,#$07
;        mov $F3,a
;
;        mov $F2,#$08             ; envx
;        mov $F3,#%01111000
;
;
;        mov $F2,#$04
;        mov $F3,puls0_sample
;        mov $F2,!KON
;        mov $F3,!Square0Flag
;
;        mov a,#$1F
;        mov $F2,#$08
;        mov $F3,a
;
;        bra write_volume

decay_disabled:
        mov a,no4016
        and a,#$20
        beq mono

        mov a,sq4000
        and a,#%00001111
        asl a
        asl a
        asl a
;        asl a

        mov $F2,!Square0VolumeL
        mov $F3,a
        mov $F2,!Square0VolumeR
        mov $F3,a
        bra no_reset

mono:
        mov a,sq4000            ; emulate volume, square 0
        and a,#%00001111
        asl a
        asl a
        asl a

write_volume:
        mov $F2,!Square0VolumeL              ; write volume
        mov $F3,a
        mov $F2,!Square0VolumeR
        mov $F3,a

no_reset:
        mov x,!Square0Flag
        call playVoiceInX

;=====================================

;-------------------------------------
square1:

        mov a,sound_ctrl
        and a,!Square1Flag
        bne sq1_enabled
silence2:
        mov x,!Square1Flag
        call stopVoiceInX

        jmp triangle

sq1_enabled:


;-------------------------------------
                                ; emulate duty cycle (select sample #)
                                ; check first the octave sample to be played

        mov a,sq4004            ; emulate duty cycle
        and a,#%11000000
		xcn	a

		and	puls1_sample,#$03
		or	a,puls1_sample
        mov puls1_sample,a
        cmp a,puls1_sample_old
        beq sq2_no_change

sq2_sample_change:
        mov $F2,!Square1SRCN
        mov $F3,puls1_sample

        mov $F2,!KON
        mov $F3,!Square1Flag

sq2_no_change:
        mov puls1_sample_old,puls1_sample

;        mov puls0_sample,#0
;
;        mov y,a
;
;        mov a,sq4003
;        and a,#%00000111
;        mov x,a
;        mov a,y
;;        cmp x,#%00000101
;;        beq pitch0
;        cmp x,#%00000110
;        beq pitch0
;        cmp x,#%00000111
;        beq pitch0
;
;        clrc
;        adc a,#4
;        mov puls0_sample,#1
;
;pitch0:
;        mov $F2,#$04            ; sample #
;        mov $F3,a
;
;        mov $F2,!KON            ; key on
;        mov $F3,!Square0Flag          
;no_change:
;        mov pulse0dutyold,pulse0duty
;        mov puls0_sample_old,puls0_sample
;-------------------------------------

         ; check if sweeps are enabled
        mov a,$45
        and a,#%10000000
        beq skip01
        mov a,$45
        and a,#%00000111
        beq skip01

        call check_timers2
        bra nextsq1

skip01:
        mov a,sq4007            ; check if freq is 0 or too high
        and a,#%00000111
        bne ok2
        mov a,sq4006
        ;cmp a,#8
        ;bcc silence2

ok2:
        and $47,#%00000111

        mov a,$46
        clrc
        rol a
        push p
        clrc
        adc a,#freqtable&255
        rol temp3
        mov temp1,a
        pop p
        mov a,$47
        rol a
        ror temp3
        adc a,#(freqtable/256)&255
        mov temp2,a

        mov	x,#$12
        call change_pulse


;--------------------------------------
nextsq1:
        mov a,no4016
        and a,!Square1Flag
        beq .afterResetCheck

        ;  A "reset sq1" in no4016 inidicates a nes apu write just happened to $4007
        ;  KOFF the channel and KON again required to emulate what the NES APU does
        mov x,!Square1Flag
        call stopVoiceInX
        call playVoiceInX

.afterResetCheck
        mov a,sq4004            ; check decay disabled
        and a,#%00010000
        bne decay_disabled2

        mov a,no4016
        and a,!Square1Flag
        beq no_reset2
        bra no_reset2   ;  TODO: opt

;        mov a,sq4004
;        and a,#%00001111
;        mov x,a
;        mov a,volume_decay_table+X
;        mov $F2,#$17
;        mov $F3,a
;
;        mov $F2,#$18             ; envx
;        mov $F3,#%01111000
;
;
;        mov $F2,#$14
;        mov $F3,puls0_sample
;        mov $F2,!KON
;        mov $F3,!Square1Flag
;
;        mov a,#$1F
;        mov $F2,#$18
;        mov $F3,a
;
;        bra write_volume2

decay_disabled2:
        mov $F2,#$17
        mov $F3,#$1F

        mov a,no4016
        and a,#$20
        beq mono2

        mov a,sq4004
        and a,#%00001111
        asl a
        asl a
        asl a
;        asl a

        mov $F2,!Square1VolumeL
        mov $F3,a
        mov $F2,!Square1VolumeR
        mov $F3,a
        bra no_reset2

mono2:
        mov a,sq4004            ; emulate volume, square 0
        and a,#%00001111
        asl a
        asl a
        asl a

write_volume2:
        mov $F2,!Square1VolumeL
        mov $F3,a
        mov $F2,!Square1VolumeR
        mov $F3,a

no_reset2:
        mov x,!Square1Flag
        call playVoiceInX

;=====================================

;-------------------------------------
triangle:
        mov a,sound_ctrl
        and a,!TriangleFlag        ; check triangle bit of $4015
        bne tri_enabled

silence3:
        mov x,!TriangleFlag
        call stopVoiceInX
        jmp noise

tri_enabled:
        mov a,tr4008
        beq silence3
        and a,#%10000000        ;  Get Halt length counter / linear counter control flag
        beq tri_length_enabled
        mov a,tr4008            
        and a,#%01111111        ;  Get linear counter load (R)
        beq silence3


        mov x,!TriangleFlag
        call playVoiceInX

        bra notimer

tri_length_enabled:
        mov a,no4016
        and a,!TriangleFlag
        beq notimer

        mov a,tr4008
        and a,#%01111111        ;  Get linear counter load (R)
        mov y,#3
        mul ya
        mov linear_count_hi,y
        mov linear_count_lo,a

        mov a,$FF                ; clear counter

        mov x,!TriangleFlag
        call playVoiceInX

notimer:	  
        call check_timer3

        and tr400B,#%00000111   ;  Get triangle timer high bits

        mov a,tr400A    ;  Triangle timer low bits
        clrc
        rol a
        push p
        clrc
        adc a,#tritable&255
        rol temp3
        mov temp1,a
        pop p
        mov a,tr400B
        rol a
        ror temp3
        adc a,#(tritable/256)&255
        mov temp2,a

        mov y,#0
        mov a,(temp1)+y
        mov $F2,!TrianglePitchL

        mov $F3,a
        inc y
        mov a,(temp1)+y
        and a,#$1f
        mov $F2,!TrianglePitchH
        mov $F3,a

        ; Change sample
        mov a,(temp1)+y
        and a,#$e0
        xcn a
        lsr a
        adc a,#triangle_sample_num&255	; Assume carry clear from LSR
        cmp a,tri_sample
        beq triangle_skip1
                mov tri_sample,a
                mov $F2,!TriangleSRCN   ; Sample # reg
                mov $F3,a


triangle_skip1:


;-------------------------------------
noise:
        mov a,sound_ctrl
        and a,!NoiseFlag
        bne noise_enabled

        mov x,!NoiseFlag
        call stopVoiceInX

        bra noise_off

noise_enabled:
        mov a,no400C            ; check decay disable
        and a,#%00010000
        bne decay_disabled3

        bra no_reset3

;        mov a,$56
;        and a,!NoiseFlag
;        beq no_reset3
;
;        mov a,no400C
;        and a,#%00001111
;        mov x,a
;        mov a,volume_decay_table+X
;        mov $F2,#$37
;        mov $F3,a
;
;        mov $F2,#$38
;        mov $F3,#%01111000
;
;        mov $F2,#$34
;        mov $F3,#0        ;puls0_sample
;        mov $F2,!KON
;        mov $F3,!NoiseFlag
;
;        mov a,#$08
;        mov $F2,#$38
;        mov $F3,a
;
;        bra write_volume3

decay_disabled3:
        mov a,no4016
        and a,#$20
        beq mono4

        mov a,no400C
        and a,#%00001111
        bra write_volume3

mono4:
        mov a,no400C            ; write noise volume
        and a,#%00001111
        asl a
        mov x,a


        ;  TODO: impelement no400f length counter.
        ;  Length lookup table for bits 7-3 of $400f: llll l---
;      |  0   1   2   3   4   5   6   7    8   9   A   B   C   D   E   F
; -----+----------------------------------------------------------------
; 00-0F  10,254, 20,  2, 40,  4, 80,  6, 160,  8, 60, 10, 14, 12, 26, 14,
; 10-1F  12, 16, 24, 18, 48, 20, 96, 22, 192, 24, 72, 26, 16, 28, 32, 30

        ;  See https://www.nesdev.org/wiki/APU_Frame_Counter for what these length numbers mean.
        ;  Per Zelda 1's $4017 value of $ff, the frame counter runs in 5-step mode and clocks length
        ;  counters (half frame) on 7456.5 apu frames and 18640.5 apu frames
        ;  Metroid 1 has a $4017 value of $c0, which makes it functionally identical to z1: a 5-step mode.
        ;  First is ~120Hz, next is ~48hz, but the sequence together is ~96.0Hz (2 or more ticks will be at 96.0Hz)

        ;  So, for z1:  10.415 ms per uneven tick.  So value $03 from noise length lookup table of "2"
        ;  is a definite 20.83 ms.
        ;  Longest supported length value would be 254 * 10.415 = 2.6454 s



        ;  Why is noise channel referencing pcm_raw??
        ;  A likely bug.  removing block below
        ; ----------------------------------------------
        ; mov a,pcm_raw
        ; lsr a
        ; lsr a
        ; mov temp_add,a
        ; mov a,x
        ; setc
        ; sbc a,temp_add
        ; bcs just_fine
        ; mov a,#0
        ; ----------------------------------------------

just_fine:
;        mov $F2,#$30
;        mov $F3,a
;        mov $F2,#$31
;        mov $F3,a

;        asl a
;        asl a
;        asl a

write_volume3:
        mov $F2,!NoiseVolumeL
        mov $F3,a
        mov $F2,!NoiseVolumeR
        mov $F3,a

no_reset3:
;---------------------------------------
; write noise frequency
        mov a,no400E
        and a,#%00001111        ;  Look only at nes noise timer period (TODO: check if games ever use mode flag #$80)
        mov x,a
        mov a,noise_freq_table+X

        mov $F2,#$6C
        mov $F3,a


;        mov $F2,#$6C
;        mov a,no400E
;        eor a,#$FF
;        and a,#%00001111
;        asl a
;        or  a,#%00100000        ; set echo disable
;        mov $F3,a               ; write noise frequency
enable_noise:
        mov x,!NoiseFlag
        call playVoiceInX

noise_off:



dmc:
        mov a,no4016
        and a,!DmcFlag        ; check for toggle on of dmc bit of $4015
        bne dmc_play

        mov $f2,#$7c
        mov a,$f3   ; check if dmc voice is finished playing

        and a,!DmcFlag
        bne dmc_silence
        jmp dmc_continue_playing

dmc_silence:

        mov x,!DmcFlag
        call stopVoiceInX

.noAction:
        jmp next_xfer

dmc_play:
        mov x,#$00
.selectSample:
        mov a,$4000+x
        cmp a,pcm_addr
        beq .setSample
        inc x
        cmp x,#$10
        beq dmc_silence ;  Sample not found
        jmp .selectSample

        ;  X now contains the index of the chosen sample
.setSample:
        mov a,x
        clrc : adc a,#srcn_base&$ff  ;  Calculate the SRCN

        mov $F2,!DmcSRCN
        mov $F3,a       ;  Set srcn with the selected sample from pcm_addr

.selectPlaybackSpeed:
        mov a,pcm_freq
        cmp a,$4010+x
        bcc .slowspeed        ;  If pcm_freq < threshold value in a, slow speed

.normalspeed:                 ;  Otherwise, normal speed

        mov $F2,!DmcPitchL
        mov $F3,#$5C
        mov $F2,!DmcPitchH
        mov $F3,#$08
        jmp .selectPlaybackVolume
.slowspeed:                     
        mov $F2,!DmcPitchL
        mov $F3,#$70
        mov $F2,!DmcPitchH
        mov $F3,#$05

.selectPlaybackVolume:
        mov a,dmc_attenuation_cutoff
        cmp a,pcm_raw
        bcc .halfvolume         ;  If pcm_raw > threshold value in dmc_attenuation_cutoff, half volume

.fullvolume:                    ;  Otherwise, full volume

        mov $F2,!DmcVolumeL
        mov $F3,#$7f    ;  Full volume
        mov $F2,!DmcVolumeR
        mov $F3,#$7f    ;  Full volume
        jmp .turnOn
.halfvolume:
        mov $F2,!DmcVolumeL
        mov $F3,#$3f    ;  Half volume
        mov $F2,!DmcVolumeR
        mov $F3,#$3f    ;  Half volume

.turnOn:
        mov x,!DmcFlag
        call playVoiceInX

dmc_continue_playing:
        jmp next_xfer
;  END processing loop



;==========~ Subroutines ~========
;  Subroutines to support the main
;  processing loop begin below.
;=================================


;  Initiates playback of the voice(s) indicated
;  by the flag value in [X], but only if the
;  voice is not already playing.  Does not affect
;  other voices.
playVoiceInX:
        mov a,x
        and a,voicesPlaying     ;  Check if selected voice is playing
        bne .alreadyPlaying
        
        mov a,x
        or  a,voicesPlaying
        mov voicesPlaying,a      ;  Set voice as playing in voicesPlaying var

        mov $F2,!KON
        mov $F3,x       ;  KON selected voice only
        mov $F2,!KOFF
        mov a,x
        eor a,#$ff     ;  invert [A]
        and a,$F3       ;  xor with current KOFF'ed voices
        mov $F3,a      ;  disable KOFF for selected voice only
.alreadyPlaying:
ret

;  Stops playback for the voice indicated
;  by the flag value in [X].  Does not affect
;  other voices.
stopVoiceInX:
        mov a,x
        eor a,#$ff     ;  invert [A]
        and a,voicesPlaying       ;  AND voicesPlaying with [X']
        mov voicesPlaying,a      ;  to reset playing flag for selected voice only

        mov $F2,!KOFF
        mov $F3,x      ;  Update selected voice only
ret

;======================================
; timer notes (original):
;               linear counter
;               267.094 Timer2 units (15.6ms) for 1/240hz [ATS - what??]
;               267.094 / 3 = 89.031 (timer value)
;               4-bit counter / 3 is number of .25-frames passed
;                       maxmimum time allowed between checks
;                       before 4-bit overflow: 22.2 milliseconds!

;======================================
;  Timer notes (ATS 2024):
;  Example calculation for 15ms: 120 (0x78) to FA (15/(1000/8000) = 15*8 = 120)
;  $FA timer:  22/8 = 2.75 ms
;  $FB timer:  22/8 = 2.75 ms
;  $FC timer:  89/64 = 1.3906 ms

;  Timer0 ($fa) is used for the Square 0 channel frequency sweeps
;  Timer1 ($fb) is used for the Square 1 channel frequency sweeps
;  Timer2 ($fc) is used for length counters for *all* four sound channels at once

enable_timer3:
        mov $F1,#0                              ; disable timers
        mov $FC,#89				; 89 * 3 = 267
        mov $FB,#22                             ; 22.2222 * 3 = 66.66666
        mov $FA,#22
        mov a,$FF                               ; clear counters
        mov a,$FE
        mov a,$FD
        mov $F1,#%00000111              ; enable timers
        ret


check_timer3:
        mov a,$FF               ; timer's 4-bit counter
        mov timer3val,a

        mov a,sq4000
        and a,#%00010000
        beq decay1
        jmp no_decay1
decay1:

        mov a,no4016
        and a,!Square0Flag
        beq no_decay_reset

        mov a,#%00001111        ; reset decay
        mov decay1volume,a
        mov a,#0
        mov decay1rate,a

        mov a,decay_status
        or a,!Square0Flag
        mov decay_status,a

        bra write_decay_volume

no_decay_reset:

        mov a,decay_status
        and a,!Square0Flag
        bne no_decay1x
        jmp no_decay1
no_decay1x:

        mov a,sq4000
        and a,#%00001111
        mov x,a

        mov a,timer3val
        clrc
        adc a,decay1rate
        mov decay1rate,a

        cmp a,volume_decay_rates+X
        bcc no_decay1

        mov a,#0
        mov decay1rate,a

        mov a,decay1volume
        bne no_decay_end

        mov a,sq4000
        and a,#%00100000        ; decay looping enabled?
        beq decay1_end
        mov a,#%00010000        ; looped, reset volume
        mov decay1volume,a
        bra no_decay1

decay1_end:
        mov a,decay_status      ; disabled!
        and a,#%11111110
        mov decay_status,a
        bra no_decay1

no_decay_end:
        dec decay1volume

write_decay_volume:
        mov a,decay1volume
        asl a
        asl a
        asl a
        mov x,a

        mov a,sound_ctrl
        and a,!Square0Flag
        beq silenced1

        mov a,sq4001
        and a,#%10000000
        beq okd1y
        mov a,sq4001
        and a,#%00000111
        beq okd1y
        bra ooykd

okd1y:
        mov a,sq4003
        and a,#%00000111
        bne okd1                ; check if freq is 0 or too high
        mov a,sq4002
        ;cmp a,#8
        ;bcc silenced1
        bra okd1
        
ooykd:
        mov a,sweep_freq_lo
        and a,#%00000111
        bne okd1                ; check if freq is 0 or too high
        mov a,sweep_freq_hi
        ;cmp a,#8
        ;bcc silenced1
        bra okd1

silenced1:
        mov x,!Square0Flag        ; Square 0 voice
        call stopVoiceInX
        bra no_decay1
okd1:
        mov a,no4016
        and a,#$20
        beq monod1

        mov $F2,!Square0VolumeL
        mov $F3,x
        mov $F2,!Square0VolumeR
        mov $F3,x
        bra no_decay1

monod1:
        mov $F2,!Square0VolumeL              ; write volume
        mov $F3,x
        mov $F2,!Square0VolumeR
        mov $F3,x

no_decay1:
        mov a,sq4004
        and a,#%00010000
        beq decay2
        jmp no_decay2

decay2:
        mov a,no4016
        and a,!Square1Flag
        beq no_decay_reset2

        mov a,#%00001111        ; reset decay
        mov decay2volume,a
        mov a,#0
        mov decay2rate,a

        mov a,decay_status
        or a,!Square1Flag
        mov decay_status,a

        bra write_decay_volume2

no_decay_reset2:
        mov a,decay_status
        and a,!Square1Flag
        bne no_decay2x
        jmp no_decay2

no_decay2x:
        mov a,sq4004
        and a,#%00001111
        mov x,a

        mov a,timer3val
        clrc
        adc a,decay2rate
        mov decay2rate,a

        cmp a,volume_decay_rates+X
        bcc no_decay2

        mov a,#0
        mov decay2rate,a

        mov a,decay2volume
        bne no_decay_end2

        mov a,sq4004
        and a,#%00100000        ; decay looping enabled?
        beq decay2_end
        mov a,#%00010000        ; looped, reset volume
        mov decay2volume,a
        bra no_decay2

decay2_end:
        mov a,decay_status      ; disabled!
        and a,#%11111101
        mov decay_status,a
        bra no_decay2

no_decay_end2:
        dec decay2volume

write_decay_volume2:
        mov a,decay2volume
        asl a
        asl a
        asl a
        mov x,a

        mov a,sound_ctrl
        and a,!Square1Flag
        beq silenced2

        mov a,sq4005
        and a,#%10000000
        beq okd2y
        mov a,sq4005
        and a,#%00000111
        beq okd2y
        bra ooykd2

okd2y:
        mov a,sq4007
        and a,#%00000111
        bne okd2                ; check if freq is 0 or too high
        mov a,sq4006
        ;cmp a,#8
        ;bcc silenced2
        bra okd2

ooykd2:
        mov a,sweep_freq_lo2
        and a,#%00000111
        bne okd2                ; check if freq is 0 or too high
        mov a,sweep_freq_hi2
        ;cmp a,#8
        ;bcc silenced2
        bra okd2

silenced2:
        mov x,!Square1Flag        ; Square 1 voice
        call stopVoiceInX
        bra no_decay2

okd2:
        mov a,no4016
        and a,#$20
        beq monod2

        mov $F2,!Square1VolumeL
        mov $F3,x
        mov $F2,!Square1VolumeR
        mov $F3,x
        bra no_decay2

monod2:
        mov $F2,!Square1VolumeL              ; write volume
        mov $F3,x
        mov $F2,!Square1VolumeR
        mov $F3,x

;  Noise channel timer processing [~$14fa]
no_decay2:      ; TODO: rename labels in this section
        mov a,no400C
        and a,#%00010000        ; Get constant volume flag (0: use volume from envelope; 1: use constant volume)
        bne no_decay3           ; If constant volume, skip further noise voice processing

        mov a,sound_ctrl
        and a,!NoiseFlag
        beq no_decay3           ;  If noise channel disabled in $4015, skip further noise voice processing

        mov a,no4016
        and a,!NoiseFlag        ;  Check "reset noise" flag
        beq no_decay_reset3     ;  If not reset, goto no_decay_reset3

        mov a,#%00001111        ;  otherwise, reset decay to $0f (full volume)
        mov decay3volume,a
        mov a,#0                
        mov decay3rate,a        ;  and reset the decay rate (TODO: opt)

        mov a,decay_status
        or a,!NoiseFlag
        mov decay_status,a      ;  Set noise voice as actively decaying in decay_status

        bra write_decay_volume3

no_decay_reset3:
        mov a,decay_status
        and a,!NoiseFlag
        beq no_decay3           ;  If noise flag not enabled in decay_status, skip further noise voice processing

        mov a,no400C
        and a,#%00001111        ;  Get the reload value for the envelope's divider (the period becomes V + 1 quarter frames).
        mov x,a

        mov a,timer3val         ;  Timer 3's captured up counter value
        clrc : adc a,decay3rate 
        mov decay3rate,a        ;  Add the captured time to the noise channel's decay rate (so, 0 + (0, 1, or 2)..)

        cmp a,volume_decay_rates+X      ;  Use envelope value in [X] to index into decay rate table
                                ; table:  3 6 9 12 15 18 21 24 27 30 33 36 40 44 48 52 56
        bcc no_decay3           ;  If [A] < decay table lookup value, skip further noise voice processing

        mov a,#0
        mov decay3rate,a        ;  reset the decay rate (TODO: opt)

        mov a,decay3volume
        bne no_decay_end3       ;  If decay3volume > 0, goto no_decay_end3

        mov a,no400C
        and a,#%00100000        ;  decay looping enabled?  Get APU Length Counter halt flag/envelope loop flag
        beq decay3_end          ;  Not looped; disable noise in decay_status and skip further processing
        mov a,#%00010000        ;  looped, reset volume
        mov decay3volume,a      ;  Reset to $10 (..why $10?)
        bra no_decay3           ;  Done processing

decay3_end:
        mov a,decay_status      ; disabled!
        and a,#%11110111
        mov decay_status,a
        bra no_decay3

no_decay_end3:
        dec decay3volume

        mov a,sound_ctrl
        and a,!NoiseFlag
        bne write_decay_volume3 ;  goto write_decay_volume3 if noise channel is enabled
        mov x,#0
        bra noise_decayed       ;  Otherwise, disable noise volume (TODO: fix)

write_decay_volume3:
        mov a,decay3volume      ;  
        asl a
;        asl a
;        asl a
        mov x,a                 ;  Write asl'ed decay3volume (range $0f to $00; becomes $1e to $00)
                                ;  Given the commented out asl a lines, this seems to serve as
                                ;  a type of adjustment from the NES range to something appropriate for spc channel volume.
                                ;  TODO: a lookup table seems like a more accurate solution if needed.

noise_decayed:
        mov $F2,!NoiseVolumeL              ; write volume
        mov $F3,x
        mov $F2,!NoiseVolumeR
        mov $F3,x

;  Triangle channel timer processing []
no_decay3:
        mov a,sound_ctrl
        and a,!TriangleFlag
        beq timer3_complete

        mov a,linear_count_hi
        bne needed
        mov a,linear_count_lo
        beq not_needed
needed:        
        mov a,timer3val

        clrc
        adc a,timer3count_lo
        mov timer3count_lo,a
        mov a,#0
        adc a,timer3count_hi
        mov timer3count_hi,a

        cmp a,linear_count_hi
        bcc timer3_ongoing

        mov a,timer3count_lo
        cmp a,linear_count_lo
        bcs timer3_complete
timer3_ongoing:        

not_needed:
        ret

timer3_complete:
        mov x,!TriangleFlag
        call stopVoiceInX

        mov linear_count_lo,#0
        mov linear_count_hi,#0

        mov timer3count_lo,#0
        mov timer3count_hi,#0
        ret


        mov a,tr4008
        and a,#0
        ret

silencex1:
        mov x,!Square0Flag
        call stopVoiceInX

nonsweep:
ret


;-----------------------------------------
;  Check timers subroutine
check_timers:
        mov a,sq4001
        and a,#%10000000
        beq nonsweep
        mov a,sq4001
        and a,#%00000111
        beq nonsweep

        mov a,no4016
        and a,#%01000000
        beq nofreqchange

        and no4016,#%10111111   ; disable!
        mov a,$FD               ; clear counter

        mov a,sq4002
        mov sweep_freq_lo,a
        mov a,sq4003
        and a,#%00000111
        mov sweep_freq_hi,a

        bne ok1x                ; check if freq is 0 or too high
        mov a,sweep_freq_lo
        ;cmp a,#8
        ;bcc silencex1

ok1x:
        mov a,sweep_freq_hi
        and a,#%11111000
        bne silencex1

        mov a,sweep_freq_lo
        clrc
        rol a
        push p
        clrc
        adc a,#freqtable&255
        rol temp3
        mov temp1,a
        pop p
        mov a,sweep_freq_hi
        rol a
        ror temp3
        adc a,#(freqtable/256)&255
        mov temp2,a

        mov	x,#$02
        call change_pulse

nofreqchange:
        mov a,sq4001
        and a,#%01110000
        lsr a
        lsr a
        lsr a
        lsr a
        mov x,a

        mov a,$FD
        clrc
        adc a,sweep1
        mov sweep1,a

        cmp a,sweeptimes+x

        bcc nonsweep

        mov a,#0
        mov sweep1,a
        
        mov a,sweep_freq_lo
        mov sweeptemp1,a
        mov a,sweep_freq_hi
        mov sweeptemp2,a

        mov a,sq4001
        and a,#%00000111
        bne swcont
        ret

swcont:
        clrc
        ror sweeptemp2
        ror sweeptemp1
        dec a
        bne swcont

        mov a,sweeptemp1        ; decrease by 1 (sweep channel difference)
        setc
        sbc a,#1
        mov sweeptemp1,a
        mov a,sweeptemp2
        sbc a,#0
        mov sweeptemp2,a


        mov a,sweep_freq_hi
        bne ok3x                ; check if freq is 0 or too high
        mov a,sweep_freq_lo
        ;cmp a,#8
        ;bcc silencex2
ok3x:

        mov a,sweep_freq_hi
        and a,#%11111000
        bne silencex2

        
        mov a,sq4001
        and a,#%00001000
        bne decrease

        mov a,sweep_freq_lo
        clrc
        adc a,sweeptemp1
        mov sweep_freq_lo,a

        mov a,sweep_freq_hi
        adc a,sweeptemp2
        mov sweep_freq_hi,a
        bra swupdate

decrease:
        mov a,sweep_freq_lo
        setc
        sbc a,sweeptemp1
        mov sweep_freq_lo,a

        mov a,sweep_freq_hi
        sbc a,sweeptemp2
        mov sweep_freq_hi,a

swupdate:
        mov a,sweep_freq_hi
        bne ok2x                ; check if freq is 0 or too high
        mov a,sweep_freq_lo
        ;cmp a,#8
        ;bcc silencex2

ok2x:
        mov a,sweep_freq_hi
        and a,#%11111000
        bne silencex2

        mov a,sweep_freq_lo
        clrc
        rol a
        push p
        clrc
        adc a,#freqtable&255
        rol temp3
        mov temp1,a
        pop p
        mov a,sweep_freq_hi
        rol a
        ror temp3
        adc a,#(freqtable/256)&255
        mov temp2,a

        mov	x,#$02
        call change_pulse

swzero:
        ret

silencex2:
        mov x,!Square0Flag        ; Square 0 voice
        call stopVoiceInX
ret



sweeptimes:
        db 3,6,9,12,15,18,21,24


silencex12:
        mov x,!Square1Flag        ; Square 1 voice
        call stopVoiceInX

nonsweepx:
ret


;-----------------------------------------
;  Check timers 2 subroutine
check_timers2:
        ; call check_brr_playing
        ; beq nonsweepx

        mov a,sq4005
        and a,#%10000000
        beq nonsweepx
        mov a,sq4005
        and a,#%00000111
        beq nonsweepx

        mov a,no4016
        and a,#%10000000
        beq nofreqchangex

        and no4016,#%01111111   ; disable!
        mov a,$FE               ; clear counter

        mov a,sq4006
        mov sweep_freq_lo2,a
        mov a,sq4007
        and a,#%00000111
        mov sweep_freq_hi2,a

        bne ok1x2               ; check if freq is 0 or too high
        mov a,sweep_freq_lo2
        ;cmp a,#8
        ;bcc silencex12

ok1x2:
        mov a,sweep_freq_hi2
        and a,#%11111000
        bne silencex12

        mov a,sweep_freq_lo2
        clrc
        rol a
        push p
        clrc
        adc a,#freqtable&255
        rol temp3
        mov temp1,a
        pop p
        mov a,sweep_freq_hi2
        rol a
        ror temp3
        adc a,#(freqtable/256)&255
        mov temp2,a

        mov	x,#$12
        call change_pulse

nofreqchangex:
        mov a,sq4005
        and a,#%01110000
        lsr a
        lsr a
        lsr a
        lsr a
        mov x,a

        mov a,$FE
        clrc
        adc a,sweep2
        mov sweep2,a

        cmp a,sweeptimes+x

        bcc nonsweepx

        mov a,#0
        mov sweep2,a
        
        mov a,sweep_freq_lo2
        mov sweeptemp1,a
        mov a,sweep_freq_hi2
        mov sweeptemp2,a

        mov a,sq4005
        and a,#%00000111
        beq swzero2

swcont2:
        clrc
        ror sweeptemp2
        ror sweeptemp1
        dec a
        bne swcont2

        mov a,sweep_freq_hi2
        bne ok3x2               ; check if freq is 0 or too high
        mov a,sweep_freq_lo2
        ;cmp a,#8
        ;bcc silencex22

ok3x2:
        mov a,sweep_freq_hi2
        and a,#%11111000
        bne silencex22

        
        mov a,sq4005
        and a,#%00001000
        bne decrease2

        mov a,sweep_freq_lo2
        clrc
        adc a,sweeptemp1
        mov sweep_freq_lo2,a

        mov a,sweep_freq_hi2
        adc a,sweeptemp2
        mov sweep_freq_hi2,a
        bra swupdate2

decrease2:
        mov a,sweep_freq_lo2
        setc
        sbc a,sweeptemp1
        mov sweep_freq_lo2,a

        mov a,sweep_freq_hi2
        sbc a,sweeptemp2
        mov sweep_freq_hi2,a

swupdate2:
        mov a,sweep_freq_hi2
        bne ok2x2               ; check if freq is 0 or too high
        mov a,sweep_freq_lo2
        ;cmp a,#8
        ;bcc silencex22

ok2x2:
        mov a,sweep_freq_hi2
        and a,#%11111000
        bne silencex22

        mov a,sweep_freq_lo2
        clrc
        rol a
        push p
        clrc
        adc a,#freqtable&255
        rol temp3
        mov temp1,a
        pop p
        mov a,sweep_freq_hi2
        rol a
        ror temp3
        adc a,#(freqtable/256)&255
        mov temp2,a

        mov	x,#$12
        call change_pulse

swzero2:
        ret

silencex22:
        mov x,!Square1Flag        ; Square 1 voice
        call stopVoiceInX
ret



;======================================
;  Reset DSP subroutine
reset_dsp:
        mov y,#0
        mov x,#0
clear:
        mov $F2,x
        mov $F3,y
        inc x
        mov a,x
        and a,#%00001111
        cmp a,#$0A
        bne clear
        mov a,x
        and a,#%11110000
        clrc
        adc a,#$10
        mov x,a
        cmp x,#$80
        bne clear

        mov a,#$0C
clear2:
        mov $F2,a
        mov $F3,y
        clrc
        adc a,#$10
        cmp a,#$6C
        bne clear2

        mov a,#$0D
clear3:
        mov $F2,a
        mov $F3,y
        clrc
        adc a,#$10
        cmp a,#$8D
        bne clear3

        mov a,#$0F
clear4:
        mov $F2,a
        mov $F3,y
        clrc
        adc a,#$10
        cmp a,#$8F
        bne clear4

        ; clear zero-page
        mov a,#0
        mov x,#$EF
clear5:
        mov $00+x,a
        dec x
        bne clear5
        mov $00,a
ret


;======================================
set_directory:
        mov x, #(end_directory_lut-set_directory_lut-1)

set_directory_loop:
        mov	a,set_directory_lut+x
        mov	$0200+x,a
        dec	x
        bpl	set_directory_loop

        ;  Append dynamic dmc entries from $4020 (see spc.asm:270)
        mov x, #0

add_dynamic_entries:
        mov a,$4020+x
        mov ($200+end_directory_lut-set_directory_lut)+x,a
        inc x
        cmp x,#$40
        bne add_dynamic_entries
ret


set_directory_lut:
		dw	pulse0,pulse0, pulse0d,pulse0d, pulse0c,pulse0c, pulse0b,pulse0b
		dw	pulse1,pulse1, pulse1d,pulse1d, pulse1c,pulse1c, pulse1b,pulse1b
		dw	pulse2,pulse2, pulse2d,pulse2d, pulse2c,pulse2c, pulse2b,pulse2b
		dw	pulse3,pulse3, pulse3d,pulse3d, pulse3c,pulse3c, pulse3b,pulse3b
                dw      tri_samp0,tri_samp0, tri_samp1, tri_samp1, tri_samp2, tri_samp2, tri_samp3, tri_samp3
                dw      tri_samp4,tri_samp4, tri_samp5, tri_samp5, tri_samp6, tri_samp6, tri_samp7, tri_samp7
end_directory_lut:


        triangle_sample_num = $10
        srcn_base           = $18


;======================================
;  Change Pulse subroutine
change_pulse:
        ; Read frequency
        mov y,#0
        mov a,(temp1)+y
		mov	temp4,a
		mov	$F5,a
        inc y
        mov a,(temp1)+y
		mov	temp5,a
		
		mov	$F5,temp1
		mov	$F6,temp2

		; Which sample are we using?
		mov	a,#$00
		mov	y,#$1f
		cmp	y,temp5
		bcc	change_pulse_1
			inc	a
			asl	temp4
			rol	temp5
			cmp	y,temp5
			bcc	change_pulse_1
				inc	a
				asl	temp4
				rol	temp5
				cmp	y,temp5
				bcc	change_pulse_1
					inc	a
					asl	temp4
					rol	temp5

change_pulse_1:
		; Which pulse channel?
		cmp	x,#$10
		bcs	change_pulse_pulse1
			; Apply sample change
			and	puls0_sample,#$0c
			or	a,puls0_sample
			mov puls0_sample,a
			cmp a,puls0_sample_old
			beq	change_pulse_rtn
			mov puls0_sample_old,puls0_sample

			mov $F2,!Square0SRCN            ; sample # reg
			mov $F3,puls0_sample


			; Apply frequency
			mov $F2,x
			mov $F3,temp4
			inc	x
			mov $F2,x
			mov $F3,temp5

			ret

change_pulse_pulse1:
			; Apply sample change
			and	puls1_sample,#$0c
			or	a,puls1_sample
			mov puls1_sample,a
			cmp a,puls1_sample_old
			beq	change_pulse_rtn
			mov puls1_sample_old,puls1_sample

			mov $F2,!Square1SRCN            ; sample # reg
			mov $F3,puls1_sample


change_pulse_rtn:
        ; Apply frequency
        mov $F2,x
        mov $F3,temp4
        inc	x
        mov $F2,x
        mov $F3,temp5
ret

;======================================================================
;       DSP value            NES reg    NES decay       SPC decay       
;----------------------------------------------------------------------
;volume_decay_table:    ( no longer used )
;        db $8D                 ; $00   240Hz .25 sec   260 msec
;        db $8A                 ; $01   120Hz .5 sec    510 msec
;        db $88                 ; $02   80Hz .75 sec    770 msec
;        db $87                 ; $03   60Hz 1 sec      1 second
;        db $86                 ; $04   48Hz 1.25 sec   1.3 seconds
;        db $85                 ; $05   40Hz 1.5 sec    1.5 seconds
;        db $85                 ; $06   34Hz 1.764 sec  1.5 seconds
;        db $84                 ; $07   30Hz 2 sec      2.0 seconds
;        db $83                 ; $08   26Hz 2.307 sec  2.6 seconds
;        db $83                 ; $09   24Hz 2.5 sec    2.6 seconds
;        db $83                 ; $0A   21Hz 2.857 sec  2.6 seconds
;        db $82                 ; $0B   20Hz 3 sec      3.1 seconds
;        db $82                 ; $0C   18Hz 3.333 sec  3.1 seconds
;        db $82                 ; $0D   17Hz 3.529 sec  3.1 seconds
;        db $81                 ; $0E   16Hz 3.75 sec   4.1 seconds
;        db $81                 ; $0F   15Hz 4 sec      4.1 seconds

;======================================================================
;       DSP value     old val           NES reg         NES noise freq
;----------------------------------------------------------------------
noise_freq_table:     ;  Added $20 to all values to keep bit 5 always set
        db #$3f       ;%00111111        $0              447kHz  
        db #$3f       ;%00111111        $1              224kHz  
        db #$3f       ;%00111111        $2              112kHz  
        db #$3f       ;%00111111        $3              55,930Hz
        db #$3f       ;%00111111        $4              27,965Hz
        db #$3e       ;%00111111        $5              18,643Hz
        db #$3e       ;%00111110        $6              13,983Hz
        db #$3d       ;%00111110        $7              11,186Hz
        db #$3c       ;%00111110        $8              8,860Hz 
        db #$3b       ;%00111110        $9              7,046Hz 
        db #$3a       ;%00111100        $A              4,710Hz 
        db #$38       ;%00111011        $B              3,523Hz 
        db #$36       ;%00111001        $C              2,349Hz 
        db #$35       ;%00111000        $D              1,762Hz 
        db #$32       ;%00110101        $E              880Hz   
        db #$2f       ;%00110010        $F              440Hz   
;======================================================================

; 1 sample
pulse0: incsrc "pl1a-0.asm"
pulse1: incsrc "pl1a-1.asm"
pulse2: incsrc "pl1a-2.asm"
pulse3: incsrc "pl1a-3.asm"

; 2 samples
pulse0d: incsrc "pl1-0.asm"
pulse1d: incsrc "pl1-1.asm"
pulse2d: incsrc "pl1-2.asm"
pulse3d: incsrc "pl1-3.asm"

; 4 samples
pulse0c: incsrc "pl2-0.asm"
pulse1c: incsrc "pl2-1.asm"
pulse2c: incsrc "pl2-2.asm"
pulse3c: incsrc "pl2-3.asm"

; 8 samples
pulse0b: incsrc "pl3-0.asm"
pulse1b: incsrc "pl3-1.asm"
pulse2b: incsrc "pl3-2.asm"
pulse3b: incsrc "pl3-3.asm"

; 2 samples (again?)
pulse0e: incsrc "pl1-0.asm"
pulse1e: incsrc "pl1-1.asm"
pulse2e: incsrc "pl1-2.asm"
pulse3e: incsrc "pl1-3.asm"

freqtable: incsrc "snestabl.asm"
tritable: incsrc "tritabl3.asm"

tri_samp0: incsrc "tri6_sl3.asm"
tri_samp1: incsrc "tri6_sl2.asm"
tri_samp2: incsrc "tri6_sl1.asm"
tri_samp3: incsrc "tri6.asm"
tri_samp4: incsrc "tri6_sr1.asm"
tri_samp5: incsrc "tri6_sr2.asm"
tri_samp6: incsrc "tri6_sr3.asm"
tri_samp7: incsrc "tri6_sr4.asm"


; infidelity's "play a brr routine"
check_brr_playing:
  MOV $F2,#$60
  MOV $F3,#$7F
  MOV $F2,#$61
  MOV $F3,#$7F
  MOV $F2,#$62
  MOV $F3,#$00
  MOV $F2,#$63
  MOV $F3,#$10
  MOV $F2,#$67
  MOV $F3,#$4F
  MOV A,$F6
  
  CMP A,#$1E
  BEQ brr_flying_knee
  
  CMP A,#$1D
  BEQ brr_contra_file

  RET

brr_flying_knee:
  MOV $F2,#$64
  MOV $F3,#$18
  MOV $F2,#$4C
  MOV $F3,#$40
  RET
brr_contra_file:
  MOV $F2,#$64
  MOV $F3,#$19
  MOV $F2,#$4C
  MOV $F3,#$40
  RET

spc_driver_end:
print "spc driver end = ", pc