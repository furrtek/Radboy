; A = digit
; DE = VRAM address
draw_digit:
  bit    6,a
  jr     nz,clear_digit		; "Clear digit" flag ?

  and    $F                 ; Compute digits_map table index
  sla    a                  ; *8
  sla    a
  sla    a
  ld     b,a
  sla    a					; *16
  add    b					; = *24

  ld     h,0
  ld     l,a
  ld     bc,digits_map
  add    hl,bc
  ld     c,6				; Height
--:
  ld     b,4				; Width
-:
  ldi    a,(hl)
  ld     (de),a
  inc    de
  dec    b
  jr     nz,-
  ld     a,e
  add    28					; DE+=(32-4) Next tile line
  ld     e,a
  jr     nc,+
  inc    d
+:
  dec    c
  jr     nz,--
  ret
  
clear_digit:
  ld     c,6				; Height
--:
  xor    a
  ld     b,4				; Width
-:
  ld     (de),a
  inc    de
  dec    b
  jr     nz,-
  ld     a,e
  add    28					; DE+=(32-4) Next tile line
  ld     e,a
  jr     nc,+
  inc    d
+:
  dec    c
  jr     nz,--
  ret
  
state_0:
  ld     hl,STATE			; Inc state
  inc    (hl)
  ld     a,(DIGIT_3)
  bit    7,a
  jr     nz,state_1			; Skip flag
  ld     de,$9800+(32*6)+1
  call   draw_digit
  ret
  
state_1:
  ld     hl,STATE			; Inc state
  inc    (hl)
  ld     a,(DIGIT_2)
  bit    7,a
  jr     nz,state_2			; Skip flag
  ld     de,$9800+(32*6)+5
  call   draw_digit
  ret
  
state_2:
  ld     hl,STATE			; Inc state
  inc    (hl)
  ld     a,(DIGIT_1)
  bit    7,a
  jr     nz,state_3			; Skip flag
  ld     de,$9800+(32*6)+9
  call   draw_digit
  ret

state_3:
  ld     hl,STATE			; Inc state
  inc    (hl)
  ld     a,(DIGIT_0)		; Can't skip units
  ld     de,$9800+(32*6)+13
  call   draw_digit
  ret
  
state_4:
  ld     hl,STATE			; Inc state
  inc    (hl)
  ;ld     a,(HV_ENABLE)
  ;bit    7,a
  ;jr     z,state_5			; Skip flag
  ;res    7,a
  ;ld     (HV_ENABLE),a
  ;rrca                      ; HV flag in carry
  ;ld     a,28               ; "OFF"
  ;jr     nc,+
  ;ld     a,22				; "ON"
+:
  ;ld     bc,$0302
  ;ld     hl,$9800+(32*4)+9
  ;call   map_inc
  ret

state_5:
  ld     hl,STATE			; Inc state
  inc    (hl)

  ld     a,(GRAPH_UPDATE)	; Need an update ?
  or     a
  jp     z,state_reset
  
  xor    a
  ld     (GRAPH_UPDATE),a	; Clear update request

  ; Draw new vertical line in graph
  ld     a,(GRAPH_V)
  cpl
  add    40+1
  ld     c,a				; Y=41-GRAPH_V
  ld     a,(GRAPH_X)
  add    $77
  and    $7F
  call   graph_plot

  ld     a,(GRAPH_V)		; Total number of pixels to plot
  ld     b,a

-:
  ld     a,(hl)				; Plot
  or     e
  ld     c,l
  ldi    (hl),a
  ld     a,l
  xor    c					; Detect tile boundary
  bit    4,a
  jr     nz,+				; Jump if got out of tile
  inc    hl					; Skip bitplane
  dec    b
  jr     nz,-
+:
  dec    hl					; Cancel inc of previous LDI
  ld     a,l				; Restart at beginning of tile
  and    $F0
  ld     l,a
  inc    h					; Jump 16 tiles (256 bytes)
  inc    l					; Skip first bitplane
  dec    b
  jr     nz,-

  ld     a,(GRAPH_X)		; Scroll value in pixels
  ld     d,a
  and    7
  jp     nz,+++				; Did a whole tile column go by ?

  ; Clear tiles of column
  srl    d					; /8
  srl    d
  srl    d
  ld     a,d				; D = column number
  dec    a
  swap   a					; *16
  and    $F0
  ld     l,a
  ld     h,$88				; HL=$88x0
  ld     b,5
--:
  dec    hl					; Hack

-:
  ldh    a,($41)			; Wait for the right VRAM mode
  and    3
  cp     3
  jr     nz,-
-:
  ldh    a,($41)
  and    3
  cp     3
  jr     z,-

  xor    a					; Clear one tile data
  inc    hl
  ldi    (hl),a
  ldi    (hl),a
  ldi    (hl),a
  ldi    (hl),a
  ldi    (hl),a
  ldi    (hl),a
  ldi    (hl),a
  ldi    (hl),a
  ldi    (hl),a
  ldi    (hl),a
  ldi    (hl),a
  ldi    (hl),a
  ldi    (hl),a
  ldi    (hl),a
  ldi    (hl),a
  ld     (hl),a				; Hack
  inc    h
  ld     a,l
  sub    15					; Hack
  ld     l,a
  dec    b
  jr     nz,--

  ; Remap new column
  ld     hl,$998F
  ld     a,d				; Column number
  and    $1F
  add    l
  and    %10011111			; Mask out eventual carry to wrap on $1F and keep $80
  ld     l,a
  push   hl
  ld     a,d				; Column number
  dec    a
  and    $F
  or     $80
  ld     c,a
  ld     de,32
  ld     b,5

-:
  ldh    a,($41)			; Wait for the right VRAM mode
  and    3
  cp     3
  jr     nz,-
-:
  ldh    a,($41)
  and    3
  cp     3
  jr     z,-

  ld     a,c
-:
  ld     (hl),a
  add    16
  add    hl,de				; HL+=32
  dec    b
  jr     nz,-

  ; Clear old column map
  pop    hl
  ld     a,5
  add    l
  and    %10011111
  ld     l,a
  ld     de,32
  ld     b,5

-:
  ldh    a,($41)			; Wait for the right VRAM mode
  and    3
  cp     3
  jr     nz,-
-:
  ldh    a,($41)
  and    3
  cp     3
  jr     z,-

  xor    a
-:
  ld     (hl),a
  add    hl,de				; HL+=32
  dec    b
  jr     nz,-
  
+++:
  ld     a,(GRAPH_X)
  inc    a
  ld     (GRAPH_X),a

  ret

state_reset:
  xor    a					; Reset cycle
  ld     (STATE),a
  ret
