vblank:
  xor    a					; Reset BG scroll
  ldh    ($42),a
  ldh    ($43),a

  ld     hl,jt_draw			; Rendering is done in a max. 6-frame cycle
  ld     a,(STATE)
  rst    $30
  
  call   read_inputs

  ld     a,(INPUTS_ACTIVE)	; A: ???
  bit    0,a
  jr     z,+
+:


  ld     a,(SECOND)			; Frame counter
  cp     30					; 61 frames =~ 1s.
  jr     z,+
  inc    a
  ld     (SECOND),a
  jr     ++
+:
  xor    a
  ld     (SECOND),a			; Reset counter

  call   compute_cpm

++:



  ; Read tick counter
  ld     a,1
  ld     ($0000),a			; Latch counter in PISO and set HV on
  nop
  ld     ($4000),a			; Reset counter and PISO shift

  ld     b,6				; Read 6-bit tick counter
  ld     c,0
-:
  ld     a,($A000)			; Read bit (D0)
  srl    a					; Shift D0 in carry
  rr     c					; Shift carry in C
  dec    b
  jr     nz,-

  xor    a
  or     c
  jr     z,+
  call   tick_sfx
  ld     hl,COUNT_ACC
  rst    $10
  ld     h,0
  ld     l,c
  add    hl,de
  ld     d,h
  ld     e,l
  ld     hl,COUNT_ACC
  rst    $18
+:

  ld     a,($A000)          ; Read OVF bit
  and    1
  ld     (OVF_FLAG),a

  ld     a,($A000)          ; Read HV status bit
  and    1
  ld     (CHARGED_FLAG),a



  ; 0.2s ? = 12.2 frames : 256 / 12.2 = 21
  ld     a,(GRAPH_TIMER)
  add    21
  jr     nc,+
  ld     hl,GRAPH_UPDATE
  inc    (hl)
+:
  ld     (GRAPH_TIMER),a

  ret

jt_draw:
  .dw state_0				; Draw DIGIT_3
  .dw state_1				; Draw DIGIT_2
  .dw state_2				; Draw DIGIT_1
  .dw state_3				; Draw DIGIT_0
  .dw state_4				; Display HV state
  .dw state_5				; Update graph
  .dw state_reset
