clear_sprites:
  call   wait_vbl
  ld     hl,$FE00			; Empties OAM
  ld     b,40*4
-:
  ld     (hl),$00
  inc    l					; Avoids hardware bug
  dec    b
  jr     nz,-
  ret

load_tiles:
  ldi    a,(hl)
  ld     b,a
  ldi    a,(hl)
  ld     c,a
-:
  ldh    a,($41)
  and    3
  cp     2
  jr     nc,-
  ldi    a,(hl)
  ld    (de),a
  inc    de
  dec    bc
  ld     a,b
  or     c
  jr     nz,-
  ret

; A = First tile
; BC = Width/Height
; HL = VRAM address
map_inc:
  ld     d,a
  ldh    a,($FF)
  push   af
  xor    a
  ldh    ($FF),a
  push   de
  push   hl
  ld     a,d
--:
  ld     d,b
-:
  ldi    (hl),a
  inc    a
  dec    d
  jr     nz,-
  pop    hl
  ld     de,32
  add    hl,de
  push   hl
  dec    c
  jr     nz,--
  pop    hl
  pop    de
  pop    af
  ldh    ($FF),a
  ret

wait_vbl:
  ldh    a,($40)
  rlca
  ret    nc
-:
  ldh    a,($44)                ;Attend d'etre dans le active display
  cp     144
  jr     nc,-
-:
  ldh    a,($44)                ;Attend le début d'un VBL (première ligne hors de l'écran, Y=144)
  cp     144
  jr     c,-
  ret

wait_write:
  push   af
-:
  ldh    a,($41)
  bit    1,a
  jr     nz,-
  pop    af
  ret
  
wait_hblank:
  push   af
  ldh    a,($40)
  rlca
  jr     c,+
  pop    af
  ret
+:
-:
  ldh    a,($41)
  and    3
  jr     z,-
-:
  ldh    a,($41)
  and    3
  jr     nz,-
  pop    af
  ret
