; Gammaboy
; TODO: Use skip flags

.ROMDMG
.NAME "RADBOY1"
.CARTRIDGETYPE 0			; ROM only
.RAMSIZE 0
.COMPUTEGBCHECKSUM
.COMPUTEGBCOMPLEMENTCHECK
.LICENSEECODENEW "00"
.EMPTYFILL $00

.MEMORYMAP
SLOTSIZE $4000
DEFAULTSLOT 0
SLOT 0 $0000
.ENDME

.ROMBANKSIZE $4000
.ROMBANKS 2

.BANK 0 SLOT 0

.INCLUDE "ram.asm"

.ORG $0000					; rst $00: A=(HL+A)
  add    l
  jr     nc,+
  inc    h
+:
  ld     l,a
  ld     a,(hl)
  ret

.ORG $0010					; rst $10: (HL)=DE
  ld     (hl),d
  inc    hl
  ld     (hl),e
  ret

.ORG $0030					; rst $30: Jumptable HL index A
  sla    a
  rst    0
  inc    hl
  ld     h,(hl)
  ld     l,a
  call   do_jump
  ret

.ORG $0040
  jp     irq_vblank

.ORG $0048
  jp     irq_stat

.ORG $0050
  reti

.ORG $0058
  reti

.ORG $0100
  nop
  jp     Start				; Entry point

.ORG $0104					; Nintendo logo
  .DB $CE,$ED,$66,$66,$CC,$0D,$00,$0B,$03,$73,$00,$83,$00,$0C
  .DB $00,$0D,$00,$08,$11,$1F,$88,$89,$00,$0E,$DC,$CC,$6E,$E6
  .DB $DD,$DD,$D9,$99,$BB,$BB,$67,$63,$6E,$0E,$EC,$CC,$DD,$DC
  .DB $99,$9F,$BB,$B9,$33,$3E

.ORG $014A
  .DB 1						; Non-Japanese

.ORG $0200

Start:
  di

  ld     sp,$FFF4			; SP in HRAM

  call   init

-:							; Main loop
  ld     a,(VBL_FLAG)
  or     a
  jr     z,-
  xor    a
  ld     (VBL_FLAG),a
  call   update
  jr     -

  .INCLUDE "util.asm"
  .INCLUDE "inputs.asm"
  .INCLUDE "interrupts.asm"
  .INCLUDE "gfxutil.asm"
  .INCLUDE "init.asm"
  .INCLUDE "vblank.asm"
  .INCLUDE "draw.asm"
  .INCLUDE "graph.asm"
  .INCLUDE "cpm.asm"

  .INCLUDE "digits.asm"

tiles_font:
  .INCBIN "gfx\font.bin"
tiles_cpm:
  .INCBIN "gfx\cpm.bin"
tiles_hv:
  .INCBIN "gfx\hv.bin"
tiles_on:
  .INCBIN "gfx\on.bin"
tiles_off:
  .INCBIN "gfx\off.bin"

tiles_abg:
  .INCBIN "gfx\abg.bin"
tiles_title:
  .INCBIN "gfx\radboy.bin"
