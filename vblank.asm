update:
  xor    a					; Reset BG scroll
  ldh    ($42),a
  ldh    ($43),a

  ld     hl,jt_draw
  ld     a,(STATE)			; Rendering is done in a max. 6-frame cycle
  rst    $30
  
  call   read_inputs

  ld     a,(INPUTS_PREV)	; DEBUG: Up
  bit    6,a
  jr     z,+
  ld     a,(VALUE)
  cp     255
  jr     z,+
  inc    a
  ld     (VALUE),a
  call   compute_cpm
+:

  ld     a,(INPUTS_PREV)	; DEBUG: Down
  bit    7,a
  jr     z,+
  ld     a,(VALUE)
  dec    a
  jr     z,+
  ld     (VALUE),a
  call   compute_cpm
+:

  ld     a,(INPUTS_ACTIVE)	; A: Toggle HV generator
  bit    0,a
  jr     z,+
  ld     a,(HV_ENABLE)
  xor    1
  set    7,a				; Set update request flag
  ld     (HV_ENABLE),a
+:


  ld     a,(SECOND)			; Frame counter
  cp     60					; 61 frames =~ 1s.
  jr     z,+
  inc    a
  ld     (SECOND),a
  jr     ++
+:
  xor    a
  ld     (SECOND),a			; Reset counter

  ; Read tick counter
  ld     a,(HV_ENABLE)
  and    1
  ld     ($0000),a			; Latch counter in PISO and set HV on/off
  nop
  ld     ($4000),a			; Reset counter and PISO shift

  ld     b,8				; Read 8-bit tick counter
  ld     c,0
-:
  ld     a,($A000)			; Read bit (D0)
  srl    a					; Shift D0 in carry
  rr     c					; Shift carry in C
  dec    b
  jr     nz,-
  ld     a,c
  ld     (COUNT_READ),a
  ld     (VALUE),a			; DEBUG
  call   compute_cpm
  
  ld     a,($A000)          ; Read OVF bit
  and    1
  ld     (OVF_FLAG),a

  ld     a,($A000)          ; Read HV status bit
  and    1
  ld     (CHARGED_FLAG),a

++:

  ; 0.2s ? = 12.2 frames : 256 / 12.2 = 21
  ld     a,(GRAPH_TIMER)
  add    21
  jr     nc,+
  ld     hl,GRAPH_UPDATE
  inc    (hl)
+:
  ld     (GRAPH_TIMER),a

  ret
