init_sound:
  ld     a,$80				; Enable APU
  ldh    ($26),a

  ld     a,$A6				; CH1
  ldh    ($10),a
  ld     a,$BF
  ldh    ($11),a
  ld     a,$F0
  ldh    ($12),a
  xor    a
  ldh    ($14),a

  ld     a,$B8				; CH2
  ldh    ($16),a
  ld     a,$71
  ldh    ($17),a
  xor    a
  ldh    ($19),a

  ld     a,$77				; Route
  ldh    ($24),a
  ld     a,$33
  ldh    ($25),a
  ret

tick_sfx:
  ld     a,$B0				; Trigger CH1
  ldh    ($13),a
  ld     a,$BF
  ldh    ($14),a
  ld     a,$B0				; Trigger CH2
  ldh    ($18),a
  ld     a,$BF
  ldh    ($19),a
  ret
