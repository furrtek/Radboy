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
