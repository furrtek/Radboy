irq_vblank:
  push   af
  ld     a,1
  ld     (VBL_FLAG),a
  pop    af
  reti

irq_stat:
  push   af
  ld     a,(GRAPH_X)
  ldh    ($43),a			; Set BG X scroll
  pop    af
  reti
