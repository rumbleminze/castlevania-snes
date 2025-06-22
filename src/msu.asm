.segment "PRGB2"

; Audio Tracks for <game>
; NES value - track

.DEFINE NUM_TRACKS        $14

; Read Flags
.DEFINE MSU_STATUS      $2000
.DEFINE MSU_READ        $2001
.DEFINE MSU_ID          $2002   ; 2002 - 2007

; Write flags
.DEFINE MSU_SEEK        $2000
.DEFINE MSU_TRACK       $2004   ; 2004 - 2005
.DEFINE MSU_VOLUME      $2006
.DEFINE MSU_CONTROL     $2007

; game specific flags, needs to be updated
.DEFINE NSF_STOP        #$00
.DEFINE NSF_PAUSE       #$FF ; 
.DEFINE NSF_RESUME      #$FF ; 
.DEFINE NSF_MUTE        #$00

; this duplicates the logic that we normally execute when
; 0 is set as the song to play.
; this logic is an example, and would be different per game
double_dragon_2_mute_nsf_copy:
  LDA #$8D
  STA $07F0
  LDA #$40
  STA $07F2
  LDA #$60
  STA $07F3

  LDA MSU_PLAYING
  ORA $07FE
  STA $07FE

  RTL

fade_if_needed:
  LDA MSU_FADE_IN_PROGRESS
  BEQ :+
    DEC MSU_CURR_VOLUME
    LDA MSU_CURR_VOLUME
    STA MSU_VOLUME

    ; exit if we're not at 0
    BNE :+
    ; if we are at 0, then start the next track
    LDA MSU_FADE_TO_TRACK
    jslb play_track_hijack, $b2
    STZ MSU_FADE_IN_PROGRESS
    STZ MSU_FADE_TO_TRACK
  :
  RTS

queue_fade_to_next_track:
  PHA
  LDA MSU_SELECTED
  bne :+
    PLA
    rtl
  :
  PLA
  STA MSU_FADE_TO_TRACK
  LDA #$01
  STA MSU_FADE_IN_PROGRESS
  LDA #$00
  rtl


play_track_hijack:

    PHA
    jsl msu_check
    CMP NSF_MUTE
    BEQ :+
    ; non-0 value returned from MSU-check, we're not playing MSU
    ; either it's not a music track or we don't have it.
    ; return the original value
    PLA
    rtl

:   
;   00 returned from msu_check, mute nsf and return the mute value
    PLA
    LDA NSF_MUTE
    rtl


wait_a_frame:
  LDA RDNMI
: LDA RDNMI
  BPL :-
  rts


check_for_all_tracks_present:
  PHB
  LDA #$B2
  PHA
  PLB
  LDA MSU_ID		; load first byte of msu-1 identification string
  CMP #$53		    ; is it "M" present from "MSU-1" string?
  BEQ :+
  PLB
  RTL ; no MSU exit early

: STZ MSU_VOLUME
  LDY #NUM_TRACKS
  INY
: 
  jsr wait_a_frame
  STZ MSU_CONTROL

  DEY
  BMI :+
  
  LDA #$00
  STA TRACKS_AVAILABLE, Y
  STA TRACKS_ENABLED, Y

  TYA
  STA MSU_TRACK
  STZ MSU_TRACK + 1 

  msu_status_check:
    LDA MSU_STATUS
    AND #$40
    BNE msu_status_check

  LDA MSU_STATUS ; load track STAtus
  AND #$08		; isolate PCM track present byte
        		; is PCM track present after attempting to play using STA $2004?
  
  BNE :-
  LDA #$01
  STA TRACKS_AVAILABLE, Y  
  STA TRACKS_ENABLED, Y
  BRA :-
: 
  LDA #$01
  STA MSU_SELECTED
  PLB
  RTL

; Checks for MSU track for audio track in Accumulator
msu_check:
  PHB
  PHK
  PLB
  PHY
  PHX
  PHA  

  LDA MSU_SELECTED
  BEQ fall_through


  LDA MSU_ID		; load first byte of msu-1 identification string
  CMP #$53		    ; is it "M" present from "MSU-1" string?
  BNE fall_through  ; No MSU-1 support, fall back to NSF
  
  ; check if we have a track for this value

  PLA
  PHA
      ; CMP NSF_STOP
      ; BEQ stop_msu

      CMP NSF_PAUSE
      BEQ pause_msu

      CMP NSF_RESUME
      BEQ resume_msu
  TAY
  LDA msu_track_lookup, Y
  CMP #$FF
  BEQ fall_through
  
  TAY
  LDA TRACKS_ENABLED, Y
  BEQ fall_back_to_nsf

  PLA
  CMP CURRENT_NSF
  BEQ already_playing
  STA CURRENT_NSF		; store current nsf track-id for later retrieval
  PHA

  TYA

  ; non-FF value means we have an MSU track
  BRA msu_available

fall_back_to_nsf:
  bra stop_msu

stop_msu:
; is msu playing?  if not, just exit
    LDA MSU_PLAYING
    BEQ fall_through
    STZ MSU_CONTROL
    STZ MSU_CURR_CTRL    
    STZ MSU_PLAYING
    BRA fall_through

pause_msu:
    LDA MSU_PLAYING
    BEQ fall_through
    STZ MSU_CONTROL
    STZ MSU_CURR_CTRL
    BRA fall_through

resume_msu:
    LDA MSU_PLAYING
    BEQ fall_through
    LDA MSU_TRACK_IDX
    TAY
    LDA TRACKS_ENABLED, y
    beq fall_through
    LDA msu_track_loops, Y
    STA MSU_CONTROL
    STA MSU_CURR_CTRL

  ; fall through to default
fall_through:
  PLA
  PLX
  PLY
  PLB
  RTL

already_playing:
  PLX
  PLY
  PLB
  LDA NSF_MUTE ; set nsf music to mute since we are playing msu  
  rtl

pause_msu_only:
  PHB
  PHK
  PLB
  PHY
  PHX
  PHA  

  LDA MSU_SELECTED
  BEQ fall_through


  LDA MSU_ID		; load first byte of msu-1 identification string
  CMP #$53		    ; is it "M" present from "MSU-1" string?
  BNE fall_through  ; No MSU-1 support, fall back to NSF
  BRA pause_msu


resume_msu_only:
  PHB
  PHK
  PLB
  PHY
  PHX
  PHA  

  LDA MSU_SELECTED
  BEQ fall_through

  LDA MSU_ID		; load first byte of msu-1 identification string
  CMP #$53		    ; is it "M" present from "MSU-1" string?
  BNE fall_through  ; No MSU-1 support, fall back to NSF
  BRA resume_msu

stop_msu_only:
  PHB
  PHK
  PLB
  PHY
  PHX
  PHA  

  LDA MSU_SELECTED
  BEQ fall_through

  LDA MSU_ID		; load first byte of msu-1 identification string
  CMP #$53		    ; is it "M" present from "MSU-1" string?
  BNE fall_through  ; No MSU-1 support, fall back to NSF
  BRA stop_msu

  ; if msu is present, process msu routine
msu_available:
  TAY
  PLA
  PHY                   ; push the MSU-1 track 
  PHA                   ; repush the NSF track

  LDA #$00		        ; clear disable/enable nsf music flag
  STA MSU_PLAYING		; clear disable/enable nsf music flag

  PLA
  STA CURRENT_NSF		; store current nsf track-id for later retrieval

  LDA #$01
  STA MSU_TRIGGER
  LDA #$02          ; use #$02 for convience so we can ORA with it for "song playing" in DD2 sound engine		       
  STA MSU_PLAYING		; set mute NSF flag (writing 02 in RAM location)

  pla

  STA MSU_TRACK_IDX		; store current re-mapped nsf track-id for later retrieval
  LDA OPTIONS_MSU_PLAYLIST
  ASL
  ASL
  ASL
  ASL
  ORA MSU_TRACK_IDX
  STA MSU_TRACK		    ; store current valid NSF track-ID
  stz MSU_TRACK + 1	    ; must zero out high byte or current msu-1 track will not play !!!

  ; jsl msu_nmi_check
  PLX
  PLY
  PLB
  LDA NSF_MUTE ; set nsf music to mute since we are playing msu  

  RTL

:
  LDA MSU_CURR_VOLUME
  STA MSU_VOLUME
  RTL

msu_nmi_check:

  ; no timers in LifeForce, so we can skip that logic
  ; jsr decrement_timer_if_needed
  jsr fade_if_needed
  
  LDA MSU_TRIGGER
  BEQ :-
  LDA MSU_STATUS
  AND #$40
  BNE :-
  LDA MSU_STATUS

  PHB
  PHK
  PLB
  STZ MSU_TRIGGER

  LDA MSU_TRACK_IDX ; pull the current MSU-1 Track
  TAY
  LDA msu_track_loops, Y
  STA MSU_CONTROL		; write current loop value
  STA MSU_CURR_CTRL
  LDA msu_track_volume, Y
  STA MSU_VOLUME		; write max volume value
  STA MSU_CURR_VOLUME
  
  ; jsr set_timer_if_needed

  PLB
  RTL


check_if_msu_is_available:
  STZ MSU_AVAILABLE
  LDA MSU_ID
  CMP #$53
  BNE :+
    LDA #$01
    STA MSU_AVAILABLE
  : 
  rtl

  
set_timer_if_needed:  
  PHB
  PHK
  PLB
  LDA $00
  PHA
  LDA $01
  PHA

  LDA MSU_TRACK_IDX
  ASL a
  TAY

  LDA track_timers, Y
  STA $00
  INY 
  LDA track_timers, y
  STA $01
  
  LDY #$01
  ; the high bit of the timer is always != 0
  LDA ($00),Y
  BEQ :+

    STA MSU_TIMER_HB
    DEY
    LDA ($00),Y
    STA MSU_TIMER_LB
    STZ MSU_TIMER_INDX
    INC MSU_TIMER_ON
    
  :

  PLA
  STA $01
  PLA
  STA $00
  PLB
  rts

decrement_timer_if_needed:
  LDA MSU_TIMER_ON
  BEQ :++

  setAXY16
  DEC MSU_TIMER_LB
  setAXY8

  BNE :++

  PHB
  PHK
  PLB

  LDA $00
  PHA
  LDA $01
  PHA

  STZ MSU_TIMER_ON
  LDA $07FE
  AND #$BD
  STA $07FE

  ; LDA #$01
  ; STA $E0
  ; INC MSU_TIMER_INDX

  LDA MSU_TRACK_IDX
  ASL
  TAY
  LDA track_timers, Y
  STA $00
  INY 
  LDA track_timers, y
  STA $01

  LDA MSU_TIMER_INDX
  ASL
  INC A
  TAY
  LDA ($00),Y
  beq :+

    STA MSU_TIMER_HB
    DEY
    LDA ($00),Y
    STA MSU_TIMER_LB
    INC MSU_TIMER_ON
  :
  
  PLA
  STA $01
  PLA
  STA $00
  PLB
: 
  rts
; this 0x100 byte lookup table maps the NSF track to the MSU-1 track
; MSU Index - NES value - track
; 
;  1 - 25 - Level 1
;  2 - 28 - Level 2
;  3 - 2B - Level 3
;  4 - 2E - Level 4
;  5 - 31 - Level 5
;  6 - 37 - Level 6
;  7 - 3A - Boss
;  8 - 3D - Death
;  9 - 40 - Ending
; 10 - 22 - Level 5 Mini Boss
; 11 - 34 - Level 5b

msu_track_lookup:
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $0A, $FF, $FF, $01, $FF, $FF, $02, $FF, $FF, $03, $FF, $FF, $04, $FF
.byte $FF, $05, $FF, $FF, $0B, $FF, $FF, $06, $FF, $FF, $07, $FF, $FF, $08, $FF, $FF
.byte $09, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF

; this 0x100 byte lookup table maps the NSF track to the if it loops ($03) or no ($01)
msu_track_loops:
.byte $00, $03, $03, $03, $03, $03, $03, $03, $01, $03, $03, $03, $00, $00, $00, $00
.byte $00, $03, $03, $03, $03, $03, $03, $03, $01, $03, $03, $03, $00, $00, $00, $00
.byte $00, $03, $03, $03, $03, $03, $03, $03, $01, $03, $03, $03, $00, $00, $00, $00
.byte $00, $03, $03, $03, $03, $03, $03, $03, $01, $03, $03, $03, $00, $00, $00, $00
.byte $00, $03, $03, $03, $03, $03, $03, $03, $01, $03, $03, $03, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

; this 0x100 byte lookup table maps the NSF track to the MSU-1 volume ($FF is max, $4F is half)
msu_track_volume:
.byte $4F, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $4F, $4F, $4F, $4F
.byte $4F, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $4F, $4F, $4F, $4F
.byte $4F, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $4F, $4F, $4F, $4F
.byte $4F, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $4F, $4F, $4F, $4F
.byte $4F, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $4F, $4F, $4F, $4F
.byte $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F
.byte $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F
.byte $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F
.byte $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F
.byte $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F
.byte $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F
.byte $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F
.byte $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F
.byte $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F
.byte $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F
.byte $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F, $4F


msu_track_e0_delay_options:
.word $0100, $068B, $0f4a

track_timers:
.addr no_timer            ; 
.addr no_timer            ; 
.addr no_timer            ; 
.addr no_timer            ; 
.addr no_timer  ; 04 - Level Clear
.addr no_timer            ; 
.addr no_timer            ; 
.addr no_timer            ; 
.addr no_timer            ; 
.addr no_timer            ; 
.addr no_timer            ; 
.addr no_timer            ; 
.addr no_timer            ; 
.addr no_timer            ; 
.addr no_timer            ; 
.addr no_timer            ; 

.addr no_timer            ; 
.addr no_timer            ; 
.addr no_timer     ; 

no_timer:
.word $0000               ; 
end_of_level_timer:
.word $014A, $0000        ; End of Level         - 0D
game_over_timer:
.word $0100, $0000