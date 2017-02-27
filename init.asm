init:
  xor    a
  ldh    ($26),a			; Disable APU

  ld     hl,$C000			; Clear WRAM
  ld     bc,$1FFF
  call   clear

  call	 screen_off

  xor    a					; Reset BG scroll
  ldh    ($43),a
  ldh    ($42),a

  ld     hl,$9800 			; Clear BG map
  ld     bc,32*32
  call   clear
  ld     hl,$9C00 			; Clear window map
  ld     bc,32*32
  call   clear
  call   clear_sprites		; Clear OAM

  ld     hl,$8000			; White tile
  ld     bc,16
  call   clear

  ld     hl,tiles_font
  ld     de,$8000+(16*1)
  call   load_tiles

  ld     hl,tiles_cpm
  ld     de,$8000+(16*8)
  call   load_tiles

  ld     hl,tiles_hv
  ld     de,$8000+(16*16)
  call   load_tiles
  ld     hl,tiles_on
  ld     de,$8000+(16*22)
  call   load_tiles
  ld     hl,tiles_off
  ld     de,$8000+(16*28)
  call   load_tiles

  ld     hl,tiles_abg
  ld     de,$8000+(16*48)
  call   load_tiles
  ld     hl,tiles_title
  ld     de,$8000+(16*73)
  call   load_tiles
  
  ; Map ABG symbol
  ld     a,48
  ld     bc,$0505
  ld     hl,$9800+(32*1)+1
  call   map_inc

  ; Map title
  ld     a,73
  ld     bc,$0C04
  ld     hl,$9800+(32*1)+7
  call   map_inc

  ; Map "CPM"
  ld     a,8
  ld     bc,$0302
  ld     hl,$9800+(32*10)+17
  call   map_inc

  ; Map "HV:"
  ;ld     a,16
  ;ld     bc,$0302
  ;ld     hl,$9800+(32*4)+6
  ;call   map_inc
  
  call   compute_cpm

  call   init_sound

  ld     a,%11100100		; BG palette
  ldh    ($47),a
  ld     a,%11100100		; SPR0 palette
  ldh    ($48),a
  ld     a,96				; LYC match at line 96
  ldh    ($45),a
  ld     a,%01000000		; LYC match STAT interrupt
  ldh    ($41),a
  ld     a,%00000011		; V-blank and STAT interrupt
  ldh    ($FF),a
  ld     a,%10010001		; Display on, window off, tiles @ 8000, sprites off, background on
  ldh    ($40),a

  xor    a
  ldh    ($0F),a			; Clear pending interrupts
  ei

  ret
