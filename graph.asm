; Graph display is 128*40 pixels = 16*5 (80) tiles, starting at tile 128
; Xmax=127 Ymax=39
; 80 81 82
; 90 91
; A0 ...
; $8800+1+(X/8*16)+(Y/8*16*16)+Y&7
; 10001YYY XXXXyyy1

; Input: A=X, C=Y
; Output: HL=VRAM address, E=Bitmap to write
graph_plot:
  ld     b,a				; X
  and    7
  ld     hl,lut_bit			; Position to bit position
  rst    0
  ld     e,a

  ld     a,c				; Y
  sla    a
  and    $0E
  or     1
  ld     l,a
  ld     a,b				; X
  sla    a
  and    $F0
  or     l
  ld     l,a
  ld     a,c
  srl    a
  srl    a
  srl    a
  and    7
  or     $88
  ld     h,a
  ret

lut_bit:
  .db $80, $40, $20, $10
  .db $08, $04, $02, $01
