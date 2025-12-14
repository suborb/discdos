;21/1/96 stripping down the
;load routines + cat
;Added merge routine
;19:25
;Split into blocks and added
;the save routine
;16/2/96 - hook1
;Hook code start file...
;17/2/96 18:03
;Hook codes work properly
;21/2/96
;Found a way for Hooks to return
;to BASIC correctly...replaces
;2D2Bh on stack with 23354 so
;return value lost but..WTF
;24/2/96
;Added the PCAT command code
;Added the READ # command


hkspst  equ 23411
hkhlst  equ 23728


;kend  equ  1BEEh
dirmse  equ 62720                       ;55552
wrisec  equ 63968
sector  equ 64960
map equ     55864                       ;55808
;ap    equ  dirmse+256

;xpt1n equ  1C82h
getin1  equ 11249
fnint1  equ 1E94h
fnint2  equ 1E99h

    jp      init
    di
    ld      bc, 32765
    ld      a, 16
    out     (c), a
    ld      (23388), a
    ld      bc, 8189
    xor     a
    out     (c), a
    ld      hl, 189
    ld      de, 23296
    ld      bc, 82
    ldir
    ld      bc, 8189
    ld      a, 4
    out     (c), a
    ld      (23399), a
    ei
    ret


init:
    ld      hl, errpat
    ld      de, 23354
    ld      bc, 24
    ldir
    ld      a, 201
    ld      (dcheat), a
    xor     a
    ld      iy, 334
    call    dodos
    ld      a, 216
    ld      (dcheat), a
    ret


errpat:
    di
    ex      af, af'
    exx
    ld      hl, 23354
    push    hl
    ld      a, 23
    ld      bc, 32765
    out     (c), a
    jp      intro
    out     (c), e                      ;+17
    exx
    ei
    jp      9530

page:
    defb    0
hksthl:
    defw    0

    defm    "DISCDOS v1.376"
    defm    "(C)26.10.98 D.J."
    defm    "MORRIS"

intro:
    ld      hl, 23388
    ld      b, (hl)
    ld      (hl), a
    ld      a, b
    ld      (page), a
    ld      (spstor), sp
    ld      sp, (23402)
    ld      hl, flags
    res     0, (hl)
;      res  6,(hl)
    ei
    call    scan
intro0:
    ld      (23354+22), hl
intro1:
    di
    xor     a
    ld      (23390), a
    ld      a, 0
    ld      bc, 8189
    out     (c), a
    ld      (23399), a
    set     4, a
    ld      bc, 32765
    ld      (23388), a
    ld      e, a
    ld      sp, (spstor)
    ld      hl, flags
    res     6, (hl)
    bit     0, (hl)
    jr      z, intro2
    pop     hl
intro2:
    jp      23354+17

hkexit:
    and     a
hkexis:
    di
    exx
    ex      af, af'
    call    wrinit
    ld      de, (hkspst)
    dec     de
    call    wrcopy
    ld      h, a
    dec     de
    push    hl
    call    wrcopy
    pop     hl
    ld      l, a
    inc     hl
    di
    ld      (23354+22), hl
;Search for 2D2Bh
    ld      b, 10
    ld      de, (hkspst)
hkexi0:
    call    wrcopy
    inc     de
    inc     de
    cp      2Bh
    jr      z, hkexi1
hkexi3:
    djnz    hkexi0
    jr      hkexi2
hkexi1:
    dec     de
    call    wrcopy
    inc     de
    cp      2Dh
    jr      nz, hkexi3
    dec     de
    call    rdinit
    ld      a, 91
    call    rdcopy
    dec     de
    ld      a, 58
    call    rdcopy

;OK, replaced it with 23354
hkexi2:
;      ld   hl,flags
;      res  6,(hl)
    ld      bc, 8189
    ld      a, 4
    out     (c), a
    ld      (23399), a
    ld      a, (page)
    ld      bc, 32765
    ld      (23388), a
    ld      e, a
    ld      hl, 10072
    ld      (iy+0), 255
    ld      sp, (hkspst)
    ex      af, af'
    jp      23354+17


;ROM 3 caller..
rom3:
    exx
    ex      af, af'
    ld      hl, routca
    ld      de, 23420
    ld      bc, 25
    ldir
    ld      hl, flags
    set     7, (hl)
    bit     6, (hl)
    pop     hl
    ld      a, (hl)
    inc     hl
    inc     hl
    ld      (retadd+1), hl
    dec     hl
    ld      h, (hl)
    ld      l, a
    ld      (23420+6), hl
    di
    ld      bc, 32765
    ld      a, 16
    ld      (23388), a
    ld      (dossp), sp
    ld      sp, (spstor)
    jp      z, 23420
    ld      sp, (23411)
    jp      23420
routi1:
    ld      sp, (dossp)
    ld      (23388), a
retadd:
    ld      hl, 0
    push    hl
    ld      hl, flags
    res     7, (hl)
    ex      af, af'
    exx
    ei
    ret

dossp:
    defw    23552

routca:
    out     (c), a
    ex      af, af'
    exx
    ei
    call    0
routc1:
    di
    exx
    ex      af, af'
    ld      a, 23
    ld      bc, 32765
    out     (c), a
    jp      routi1

scan:
    ld      hl, flags
    bit     7, (hl)
    jr      nz, scan0
    ld      a, (iy+0)
    cp      11
    jp      z, write
    cp      1
    jp      z, write
    ld      b, a
    ld      a, (23390)
    cp      b
    jr      nz, hook
scan0:
    ld      hl, flags
    bit     6, (hl)
    jr      z, scan01
    res     6, (hl)
    ld      (iy+0), 255
;      ld   a,(iy)
;      inc  a
;      jr   nz,scan01
;      call syntax
    jp      runexe                      ;nz
;      jp   synexe
scan01:
    ld      hl, flags
    res     7, (hl)
    set     0, (hl)
    ld      hl, 9530
    ret


;Okay, have trapped a hook
;code
hook:
    ld      a, b
;Code in a...
    cp      50
    jr      c, scan0
    cp      72
    jr      nc, scan0
    sub     51
    ld      (iy+0), 255
    add     a
    ld      hl, hkexit
    push    hl
    ld      l, a
    ld      h, 0
    ld      de, hktabl
    add     hl, de
    ld      a, (hl)
    inc     hl
    ld      h, (hl)
    ld      l, a
    push    hl
    ld      hl, flags
    set     6, (hl)
    exx
    ex      af, af'
    ret

;Hook code crap..

;Table of Hook code routines..

hktabl:
    defw    hxfer
    defw    ofsm
    defw    hofle
    defw    sbyt
    defw    hsvbk
    defw    cfsm
    defw    nohk                        ;pntp
    defw    nohk                        ;cops
    defw    hgfle
    defw    lbyt
    defw    hldbk
    defw    wsad
    defw    rsad
    defw    nohk                        ;rest
    defw    heraz
    defw    nohk                        ;cops2
    defw    pcat                        ;pcat
    defw    hrsad
    defw    hwsad
    defw    nohk                        ;otfoc
    defw    patch


;Transfer the user UFIA to
;system UFIA (DFCA)

hxfer:
    call    wrinit
    push    ix
    pop     hl
    ld      de, ufia
    ld      b, 24
    ex      de, hl
hxfer1:
    push    hl
    call    wrcopy
    pop     hl
    ld      (hl), a
    inc     hl
    inc     de
    djnz    hxfer1
    ld      hl, ufia+5
    ld      de, filen
    ld      bc, 10
    ldir
    ret

ofsm:
    call    discan
    pop     hl
    jp      hkexis                      ;nc
    ld      a, 20h
    jp      hkexis                      ;c

hofle:
    call    hxfer
    call    wropen
    ret

sbyt:
    call    wrbyte
    ret
hsvbk:
    call    wrblok
    ret

cfsm:
    call    wrclos
    ret

;Open a file to read

hgfle:
    call    hxfer
    ld      ix, ufia
    ld      (ix+15), 255
    call    rdopen
    ret

lbyt:
    call    rdbyte
    ret
hldbk:
    call    rdblok
    ret

nohk:
    ret

wsad:
    call    swos
    ld      hl, wrisec
    ld      (wrsepo), hl
    ld      hl, 510
    ld      (wrtogo), hl
    ret
rsad:
    call    sros
    ld      hl, sector
    ld      (secpos), hl
    ld      hl, 510
    ld      (sectgo), hl
    ret

heraz:
    call    hxfer
    ld      hl, filen
    call    ckwild
    call    en_ers
    ret


hrsad:
    ld      hl, ros
hrsa1:
    push    hl
    push    ix
    pop     hl
    ld      (curdrv), a
    ret
hwsad:
    ld      hl, wos
    jr      hrsa1

pcat:
    ld      a, (ufia+15)
    ld      hl, flags
    res     5, (hl)
    bit     1, a
    jr      z, pcat0
    set     5, (hl)
pcat0:
    bit     4, a
    jr      nz, pcat2
    ld      hl, filen                   ;filen
    ld      (hl), '*'
pcat2:
    call    ncatc2
    ret

patch:
    ld      hl, 2
    ret



;Error return

scan1:
    call    syntax
    jr      nz, scan12
    ld      hl, (23645)
    ld      (23647), hl
scan12:
    ld      hl, flags
    set     0, (hl)
    ld      hl, 9530
    jp      intro0

;Syntax exit

runexe:
    ld      hl, 4145
    ld      a, (autoct)
    cp      'D'
    ret     nz
    push    hl
    ld      a, 2
    ld      (chanel), a
    ld      (ufia+15), a
    call    pcat
    pop     hl
;unexe ld   hl,4145
    ret
synexe:
    ld      hl, 4280
;this pop needed to dump
;the return to runexe
    pop     bc
    ret

;Main syntax loop
write:
    set     7, (iy+48)
    bit     7, (iy+1)
    jr      nz, writ01
    res     7, (iy+48)
writ01:
    ld      hl, (23645)
write0:
    dec     hl
    call    rom3
    defw    123                         ; ld a,(hl),ret
    cp      206
    jr      c, write0
;      ld   (tchadd),hl
    ld      (23645), hl
    call    rom3
    defw    24
    ld      hl, runexe
    push    hl
    ld      (autoct), a
    cp      207
    jp      z, cat
    cp      208
    jp      z, format
    cp      209
    jp      z, move
    cp      210
    jp      z, erase
    cp      213
    jp      z, merge
    cp      214
    jp      z, verify
    cp      227                         ;read
    jp      z, uread
    cp      239
    jp      z, load
    cp      244
    jp      z, poke
    cp      248
    jp      z, save
    cp      251
    jp      z, cls
    cp      253
    jp      z, clear
    cp      255
    jp      z, copy
    pop     hl
    jp      scan1

