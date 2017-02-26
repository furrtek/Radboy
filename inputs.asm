read_inputs:				; DULRSsBA
  push   bc
  ld     a,%00010000		; Select buttons
  ldh    ($00),a
  nop
  nop
  nop
  ldh    a,($00)
  and    $0F
  xor    $0F
  ld     b,a
  ld     a,%00100000  		; Select directions
  ldh    ($00),a
  nop
  nop
  nop
  ldh    a,($00)
  and    $0F
  xor    $0F
  swap   a
  or     b
  ld     b,a
  ld     a,(INPUTS_PREV)
  xor    b
  and    b            		; Keep rising edges
  ld     (INPUTS_ACTIVE),a
  ld     a,b
  ld     (INPUTS_PREV),a
  pop    bc
  ret
