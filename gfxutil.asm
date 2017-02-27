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

; HL = data address
; DE = VRAM address
load_tiles:
; BP0
  push   de
  call   decompress
  pop    de
  inc    de
; BP1
  jr     decompress			; call + ret

decompress:
  ldi    a,(hl)
  or     a
  ret    z					; End of data
  bit    7,a            	; "Compressed" flag
  jr     nz,compressed
  and    $7F				; Clear flag
  ld     b,a
-:
  ldi    a,(hl)
  ld     (de),a
  inc    de             	; Skip a bitplane (loaded later)
  inc    de
  dec    b
  jr     nz,-
  jr     decompress
compressed:
  and    $7F				; Clear flag
  ld     b,a
  ldi    a,(hl)
-:
  ld     (de),a
  inc    de             	; Skip a bitplane (loaded later)
  inc    de
  dec    b
  jr     nz,-
  jr     decompress

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
  ldh    a,($40)			; Screen disabled ?
  rlca
  ret    nc
-:
  ldh    a,($44)			; Wait for v-blank end
  cp     144
  jr     nc,-
-:
  ldh    a,($44)			; Wait for v-blank start
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
