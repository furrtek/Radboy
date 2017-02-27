compute_cpm:
  ; Shift AVG_BUFFER
  ld     b,(30-1)*2
  ld     de,AVG_BUFFER+(30*2)-1
  ld     h,d
  ld     l,e
  dec    hl
  dec    hl
-:
  ldd    a,(hl)
  ld     (de),a
  dec    de
  dec    b
  jr     nz,-

  ld     hl,COUNT_ACC
  rst    $10
  xor    a
  ldd    (hl),a
  ld     (hl),a
  ld     hl,AVG_BUFFER
  rst    $18
  
  ; Compute average
  ld     b,30*2
  ld     de,0
  ld     hl,AVG_BUFFER
-:
  ld     a,e
  add    (hl)
  ld     e,a
  inc    hl
  ld     a,d
  adc    (hl)
  ld     d,a
  inc    hl
  dec    b
  jr     nz,-

  push   de

  sla    e					; *2
  rl     d
  
  ld     h,d
  ld     l,e

  ;ld     hl,0				; *60 = *4 + *8 + *16 + *32
  ;sla    e					; *4
  ;rl     d
  ;sla    e
  ;rl     d
  ;add    hl,de
  ;sla    e                  ; *8
  ;rl     d
  ;add    hl,de
  ;sla    e                  ; *16
  ;rl     d
  ;add    hl,de
  ;sla    e                  ; *32
  ;rl     d
  ;add    hl,de

  ; Hex to BCD
  ld     a,(DIGIT_0)
  ld     d,a
  call   div10				; Don't call remzero on units to keep at least one zero displayed
  cp     d
  jr     nz,+
  ld     a,%10000000		; Skip if same
+:
  ld     (DIGIT_0),a
  
  ld     a,(DIGIT_1)
  ld     d,a
  call   div10
  call   remzero
  cp     d
  jr     nz,+
  ld     a,%10000000		; Skip if same
+:
  ld     (DIGIT_1),a

  ld     a,(DIGIT_2)
  ld     d,a
  call   div10
  call   remzero
  cp     d
  jr     nz,+
  ld     a,%10000000		; Skip if same
+:
  ld     (DIGIT_2),a

  ld     a,(DIGIT_3)
  ld     d,a
  call   div10
  call   remzero
  cp     d
  jr     nz,+
  ld     a,%10000000		; Skip if same
+:
  ld     (DIGIT_3),a
  
  pop    de
  
  srl    d 					; /32
  rr     e
  srl    d
  rr     e
  srl    d
  rr     e
  srl    d
  rr     e
  srl    d
  rr     e
  
  ld     a,e
  ;srl    a					; /4 + 1
  ;srl    a
  inc    a
  ld     (GRAPH_V),a
  ret

remzero:
  or     a
  ret    nz
  ld     b,a
  ld     a,l
  or     h
  ld     a,b
  ret    nz
  ld     a,%01000000		; Set "Clear digit" flag
  ret
