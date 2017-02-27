clear:						; Clears from HL to HL+BC
  xor    a
  ldi    (hl),a
  dec    bc
  ld     a,c
  or     b
  jr     nz,clear
  ret

screen_off:               	; Turns display off during v-blank
  call   wait_vbl
  xor    a
  ldh    ($40),a
  ret

do_jump:					; To simulate "call (hl)"
  jp     hl

;Inputs:
;     HL
;Outputs:
;     HL is the quotient
;     A is the remainder
;     BC is used
div10:
  ld     bc,$0D0A
  xor    a
  add    hl,hl				; AHL = HL * 8
  rla
  add    hl,hl
  rla
  add    hl,hl
  rla
-:
  add    hl,hl
  rla
  cp     c
  jr     c,+
  sub    c
  inc    l
+:
  dec    b
  jr     nz,-
  ret
