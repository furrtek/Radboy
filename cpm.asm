compute_cpm:
  ld     hl,VALUE			; DE = (VALUE)
  ldi    a,(hl)
  ld     e,a
  ld     d,(hl)

  push   de

  jr  +						; DEBUG: Disabled
  ld     hl,0				; *60
  sla    e
  rl     d
  sla    e
  rl     d
  add    hl,de
  sla    e
  rl     d
  add    hl,de
  sla    e
  rl     d
  add    hl,de
  sla    e
  rl     d
  add    hl,de
+:
  push   de					; DE -> HL
  pop    hl

  ; Hex to BCD
  call   div10				; Don't call remzero on units to keep at least one zero displayed
  ld     (DIGIT_0),a
  call   div10
  call   remzero
  ld     (DIGIT_1),a
  call   div10
  call   remzero
  ld     (DIGIT_2),a
  call   div10
  call   remzero
  ld     (DIGIT_3),a
  
  pop    de
  
  ld     a,e
  srl    a					; /8 + 1
  srl    a
  srl    a
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
  ld     a,$40				; Set "Clear digit" flag
  ret
