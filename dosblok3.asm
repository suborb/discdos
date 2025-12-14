;DOSBLOK3 - cls + cat  +erase
;+system stuff
;Changing the wildcard scan
;by using (flags)
;11/2/96 - checked for bit 6
;in erases ie writ protected
;16/2/96 - added a shortened
;catalogue thing...
;17/2/96 - rewritten getstr
;routine to use wrcopy routs
;And changed output of CAT 1!
;20/2/96
;Changed getstr routine so
;checking for wildcards is not
;integrated...
;Changed the sector load/save
;so as to respect pages...
;21/2/96
;Added a patch to the CAT
;routine so to stop double
;repetition of FP forms
;6/3/96
;Fixed cat display so doesn't
;crash on file nos > 11, also
;sorted out sector number pr..
;24/3/96
;Changed cat so can handle the
;hook code
;25/3/96
;Changed error handling so hook
;code errors exit without crash
;31/3/96
;Added the error support for
;bad filenames whilst copying
;2/5/96
;Optimizing the jp stuff...
;28/7/97
;Optimizing some of the code
;To save abt 8 bytes...

;Clear routine

clear:
    call    rout32
    cp      '#'
    jp      nz, nonerr
    call    rout32
    call    ckend
    ret


;Move routine

move:
    call    rout32
    and     223
    cp      'D'
    jp      nz, nonerr
    call    rout32
    call    gdrive
    call    cksemi
    call    exptex
    cp      204                         ;TO
    jp      nz, nonerr
    call    rout32
    cp      '#'
    jp      nz, nonerr
    call    e32_1n
    call    ckend
    call    rom3
    defw    fnint2
    ld      a, b
    and     a
    jr      nz, move1
    set     7, c
move1:
    ld      a, c
    ld      (chanel), a
    ld      ix, ufia
    push    ix
    pop     hl
    ld      bc, 5
    add     hl, bc
    ld      (ix+4), 255
    push    hl
    ld      b, 10
move7:
    ld      (hl), 32
    inc     hl
    djnz    move7
    pop     hl
    call    getstr
    call    rdopen
    ld      hl, temphd
    ld      b, 9
move4:
    call    rdbyte
    ld      (hl), a
    inc     hl
    djnz    move4
    ld      a, (chanel)
    call    rom3
    defw    5633
    ld      bc, (temphd+1)
move2:
    call    rdbyte
    cp      13
    jr      z, move8
    cp      32
    jr      nc, move8
    ld      a, 32
move8:
    call    rom3
    defw    16
move3:
    dec     bc
    ld      a, b
    or      c
    jr      nz, move2
    ret
;      jp   runexe


;Erase routine
;Adding in wildcard select for
;delete

erase:
    call    rout32
    ld      (autoct), a
    and     223
    cp      'D'
    jp      nz, nonerr
    call    rout32
    call    gdrive
    call    cksemi
    call    exptex
    call    ckenqu
    jp      z, erase6
    cp      204                         ;TO
    jp      nz, nonerr
;Renaming a file here
;No wildcards permitted
    call    rout32
    call    cksemi
    call    exptex
    call    ckend
    ld      hl, filen
    ld      de, fildes
    ld      b, 10
    ld      a, 32
erase1:
    ld      (hl), a
    ld      (de), a
    inc     hl
    inc     de
    djnz    erase1
    ld      hl, fildes
    call    getstr
    jr      z, eras15
eras14:
    call    errorn
    defb    43                          ;bad filename
eras15:
    ld      hl, filen
    call    getstr
    jr      nz, eras14
;Scan the disc for original
;filename
    call    discan
    jr      c, erase0
    call    errorn
    defb    34                          ;file no exist
erase0:
    ld      hl, sector
    ld      de, wrisec
    ld      bc, 512
    ldir
    ld      b, a
    call    locate
    push    de
    ld      hl, wrisec
    jr      nc, erase2
    inc     h
erase2:
    bit     6, (hl)
    jr      z, eras25
    call    errorn
    defb    52                          ;read only
eras25:
    inc     hl
    push    hl
    call    clfiln
    ld      hl, fildes
    pop     de
    push    hl
    ld      bc, 10
    ldir
    pop     hl
    ld      de, filen
    ld      bc, 10
    ldir
    call    discan
    jr      nc, erase4
    call    errorn
    defb    32                          ;file exists
erase4:
    pop     de
    jp      swos
;      ret
;      jp   runexe
;Right...erase a file...
erase6:
    call    ckend
;      ld   hl,flags
;      res  2,(hl)
    ld      hl, filen
    call    clfiln
    call    getstr
;      jp   en_ers
;      ret
;      jp   runexe
en_ers:
    ld      hl, flags
    res     2, (hl)
    res     4, (hl)
eras64:
    call    disca0
    jr      c, erase8
    ld      hl, flags
    bit     1, (hl)
    jr      z, erase7
    bit     2, (hl)
    ret     nz
erase7:
    call    errorn
    defb    34                          ;file not exist
erase8:
    ld      b, a
    call    locate
    push    de
    ld      hl, sector
    jr      nc, erase9
    inc     h
erase9:
    bit     6, (hl)
    jr      z, eras10
    call    errorn
    defb    52                          ;read only file
eras10:
    ld      (hl), 0
    ld      hl, sector
    ld      de, wrisec
    ld      bc, 512
    ldir
    pop     de
    call    swos
    ld      hl, flags
    set     2, (hl)
    bit     1, (hl)
    jp      nz, eras64
    ret



getstr:
    ld      bc, 10
getst0:
    push    hl
    push    bc
    call    rom3
    defw    11249
    call    wrinit
    pop     hl
    and     a
    sbc     hl, bc
    jp      c, bfnerr
    pop     hl
    ld      b, c
    ld      a, b
    and     a
    jr      nz, gets15
    call    errorn
    defb    43
gets15:
    ld      (getst5), a
    push    bc
    push    hl
getst1:
    push    hl
    call    wrcopy
    pop     hl
    ld      (hl), a
    inc     hl
    inc     de
    djnz    getst1
    pop     hl
    pop     bc
    call    ckwil0
getst4:
    push    hl
    ld      hl, flags
    bit     1, (hl)
    pop     hl
    ret

ckwild:
    ld      b, 10
ckwil0:
    push    hl
    ld      hl, flags
    res     1, (hl)
    pop     hl
ckwil1:
    ld      a, (hl)
    cp      '*'
    jr      z, getst2
    cp      '?'
    jr      z, getst2
getst3:
    inc     hl
    djnz    ckwil1
    ret
getst2:
    push    hl
    ld      hl, flags
    set     1, (hl)
    pop     hl
    jr      getst3
getst5:
    defb    0

fildes:
    ds      10, 0





;Fun cls routine

cls:
    call    rout32
    cp      '#'
    jp      nz, nonerr
    call    rout32
    call    ckend
    ld      hl, 56
    ld      (23693), hl
    ld      (23695), hl
    ld      (iy+14), l
    ld      (iy+87), h
    ld      a, 2
    call    rom3
    defw    5633
    call    rom3
    defw    3435
    ld      a, 7
    out     (254), a
    ret
;      jp   runexe


;Display a +D disc directory..
;onto the screen

;May have to change the ckend..

cat:
    call    syntax
    jr      z, cat0
    ld      a, 2
    ld      (chanel), a
    ld      b, 9
    ld      hl, filen
    ld      (hl), '*'
cfnca1:
    inc     hl
    ld      (hl), 32
    djnz    cfnca1
    ld      hl, flags
    res     5, (hl)

cat0:
    call    rout32
    set     7, (iy+1)
    cp      '#'
    jr      nz, ncatcd
    call    e32_1n
    cp      ','
    jr      z, catcom
    cp      ';'
    jp      nz, nonerr
    call    syntax
    jr      nz, catcom
    res     7, (iy+1)
catcom:
    call    rout32
    call    syntax
    jr      z, ncatcd
    call    rom3
    defw    fnint2
    ld      a, b
    and     a
    jr      nz, stinra
    set     7, c
stinra:
    ld      a, c
    ld      (chanel), a
;Okay, have checked for channel
;shit, now get drive...
ncatcd:
    call    rom3
    defw    24
    call    gdrive
ncats1:
    call    rom3
    defw    24
    cp      '!'
    jr      nz, ncatsh
    call    syntax
    jr      z, ncats2
    ld      hl, flags
    set     5, (hl)
ncats2:
    call    rout32
;Get the filename (ignoring
;short form....)
ncatsh:
    call    rom3
    defw    24
    call    ckenqu
    jr      z, ncatc1
    cp      ';'
    jp      nz, nonerr
    call    rout32
    call    exptex
    call    ckend
    ld      hl, filen
    call    getstr
    jr      ncats3
ncatc1:
    call    ckend
ncats3:
;cats3 call ncatc2
;      ret
;      jp   runexe
;End of syntax checking...

;Actual catalogue routine..also
;called by the hook code...
ncatc2:
    xor     a
    ld      (fileno), a
    ld      (prica2+1), a
    ld      hl, 0
    ld      (taken), hl
    ld      a, (chanel)
    call    rom3
    defw    5633
    ld      hl, flags
    bit     5, (hl)
    jr      nz, ncatc3
    call    rom3
    defw    3503
    ld      a, (chanel)
    call    rom3
    defw    5633
    call    messag
    defm    "+3 DOS DISCiPLE DISK "
    defb    255
    ld      a, (curdrv)
    add     48
    call    print
    call    messag
    defm    " DIRECTORY"
    defb    13, 13, 255
ncatc3:
    ld      hl, 1
    ld      (dirsec+1), hl
    ld      b, 40
cat1:
    push    bc
    call    dirsec
    ld      hl, sector
    call    chdpr
    call    nc, catck
    call    chdpr
    call    nc, catck
    pop     bc
    djnz    cat1
;      push bc
catend:
;atend pop  bc
;      ld   a,13
    ld      hl, flags
    bit     5, (hl)
    ret     nz
;      call nz,print
    call    messag
    defb    13
    defm    "No of free K-bytes ="
    defb    255
    ld      hl, 1560
    ld      bc, (taken)
    and     a
    sbc     hl, bc
    srl     h
    rr      l
    ld      b, 255
    jp      prthou
;      ret
catck:
    ret     nz
    pop     bc
    pop     bc
    jr      catend

    defm    "DOM"

;Scan a disk for the filename
;stored in filen
;Entry: none
;Exit: nc=file not found
;       a=file no in dir
;    +  c if found

disca0:
    ld      hl, flags
    bit     4, (hl)
    jr      z, discan
    set     4, (hl)
    ld      de, (dirsol)
    call    sros
    ld      hl, sector
    ld      de, (disret)
    ld      a, (discou)
    ld      b, a
    push    de
    ret

discan:
    call    clsmap
    xor     a
    ld      (frepos), a
    ld      hl, 1
    ld      (dirsec+1), hl
    ld      a, h
    ld      (fileno), a
    ld      b, 40
disca1:
    push    bc
    call    dirsec
    jr      z, disca4
    ld      hl, sector
    call    chffil
    ld      de, disca3
    jr      z, disca2
    pop     bc
disca3:
    push    bc
    inc     h
    call    chffil
    ld      de, disca1
    jr      z, disca2
    pop     bc
    djnz    disca1
    push    bc
disca4:
    pop     bc
disca5:
    and     a
    ret
disca2:
    pop     bc
    jr      nc, disca5
    ld      (disret), de
    ld      a, b
    ld      (discou), a
    ld      a, (fileno)
    scf
    ret
disret:
    defw    0
discou:
    defb    0

dirsec:
    ld      de, 0
    push    de
    call    sros
    pop     de
    ld      (dirsol), de
    ld      a, d
    add     e
    dec     a
    jr      nz, dirsc1
    ld      a, (sector+511)
    and     a
    jr      z, dirsc1
    call    errorn
    defb    67                          ;unrecog disc
dirsc1:
    ld      a, 11
    inc     e
    cp      e
    jr      nz, dirsc2
    inc     d
    ld      e, 1
dirsc2:
    ld      (dirsec+1), de
    ret
dirsol:
    defw    0


;Check to see if a dir entry
;is to be printed then do it..

chdpr:
    push    hl
    call    chffil
    jr      nc, chdpr1
    call    nz, nocama
    call    z, pricae
    scf
chdpr1:
    pop     hl
    push    af
    inc     h
    pop     af
    ret

;Clear the directory map

clsmap:
    ld      hl, map
    ld      de, map+1
    ld      bc, 256
    ld      (hl), 0
    ldir
    ret


;Check the current dir sector
;for a file
;Exit: c=file at entry
;      z=file is match
;     nz=file no match
;  nz+nc=no file present
;   z+nc=end of directory


;Check if entry in catalogue
chkide:
    ld      a, '*'
    ld      (filen), a
;Check if matches filename
chffil:
    ld      a, (fileno)
    inc     a
    ld      (fileno), a
    ld      a, (hl)
    and     a
    jr      z, chffi2
    bit     7, a
    jr      nz, chffi1
;Hidden file here...
;Put more in eg change cols &c
    and     127
chffi1:
    cp      12
    jr      c, chffi3
    ld      a, 12
chffi3:
    ld      (ftype), a
    push    hl
    inc     hl
    call    cfilen
;Map out the sectors used
    pop     hl
    push    hl
    push    af
;Map out the used sectors
map0:
    push    de
    ld      bc, 15
    add     hl, bc
    ld      b, 195
    ld      de, map
map1:
    ld      a, (de)
    or      (hl)
    ld      (de), a
    inc     hl
    inc     de
    djnz    map1
    pop     de
    pop     af
    pop     hl
    scf
    ret
;No file name exit
chffi2:
    ld      a, (frepos)
    and     a
;      ret  nz  ;nz+nc
    jr      nz, chff21
    ld      a, (fileno)
    ld      (frepos), a
;Check for end of dir..
chff21:
    ld      a, (hl)
    inc     hl
    or      (hl)
    dec     hl
    and     a
    ld      a, (frepos)
    ret                                 ;z+nc/nz+nc
;hff21 inc  a      ;ld a,1
;      and  a
;      ret

;Even if the filename doesn't
;match do the length thing...

nocama:
    push    hl
    ld      bc, 11
    add     hl, bc
nocam0:
    ld      b, (hl)
    inc     hl
    ld      c, (hl)
    ex      de, hl
    ld      hl, (taken)
    add     hl, bc
    ld      (taken), hl
    pop     hl
    ret
nocam1:
    push    hl
    jr      nocam0

;Okay to print the filename...
pricae:
    push    hl
    ld      hl, flags
    bit     5, (hl)
    jr      nz, prica1
    ld      hl, (fileno)
    ld      h, 0
    ld      b, 255
    call    prtens
    ld      a, 3
    call    tab
prica1:
    pop     de
    inc     de
    ld      bc, 10
    call    string
    ex      de, hl
    call    nocam1
    push    hl
    ld      hl, flags
    bit     5, (hl)
    jr      z, prica6
;Handling the shortened form
;here...
prica2:
    ld      a, 0
    ld      b, 32
    inc     a
    cp      3
    jr      nz, prica3
    xor     a
    ld      b, 13
prica3:
    ld      (prica2+1), a
    ld      a, b
    call    print
    pop     hl
    ret

prica6:
    push    bc
    ld      a, 13                       ;tens
    call    tab
    pop     hl
    ld      b, 255
    call    prhund                      ;prtens
    ld      a, 17
    call    tab
    ld      a, (ftype)
    dec     a
    ld      c, a
    ld      hl, types
gtype1:
    ld      a, (hl)
    inc     hl
    ld      b, (hl)
    inc     hl
    cp      c
    jr      z, gtype3
gtype2:
    inc     hl
    djnz    gtype2
    inc     hl
    inc     hl
    jr      gtype1
gtype3:
    ld      a, (hl)
    call    print
    inc     hl
    djnz    gtype3
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    pop     hl
    ld      bc, 200
    add     hl, bc
    ex      de, hl
    ld      a, h
    or      l
    jr      z, gtype4
    ld      a, 21
    call    tab
    call    cjump+1                     ;de=headinfo
gtype4:
    ld      a, 13
    jp      print
;      ret

bascat:
    ex      de, hl
    ld      bc, 7
    add     hl, bc
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ld      a, e
    cp      255
    jr      nz, basca1
    ld      a, d
    cp      255
    ret     z
basca1:
    ex      de, hl
    ld      b, 255
    jp      prttho
;      ret

codcat:
    ex      de, hl
    inc     hl
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    push    de
    inc     hl
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    ld      b, 255
    call    prttho
    ld      a, ','
    call    print
    pop     hl
    ld      b, 254
    jp      prttho
;      ret


tab:
    ld      b, a
    ld      a, 23
    call    print
    ld      a, b
    call    print
    xor     a
    jp      print
;      ret

;Compare the filename at
;address hl, with that in mem..
;Entry: hl=file name to check
;Exit:   z=match

cfilen:
    ld      de, filen
    ld      b, 10
cfile1:
    ld      a, (de)
    cp      '*'
    ret     z
    cp      '?'
    jr      z, cfile2
    xor     (hl)
    and     223
    ret     nz
cfile2:
    inc     de
    inc     hl
    djnz    cfile1
    ret
filen:
    ds      10, 0



types:
    defb    0, 3
    defm    "BAS"
    defw    bascat
    defb    1, 7
    defm    "D.ARRAY"
    defw    0
    defb    2, 7
    defm    "$.ARRAY"
    defw    0
    defb    3, 3
    defm    "CDE"
    defw    codcat
    defb    4, 7
    defm    "SNA 48k"
    defw    0
    defb    5, 7
    defm    "MD.FILE"
    defw    0
    defb    6, 7
    defm    "SCREEN$"
    defw    0
    defb    7, 7
    defm    "SPECIAL"
    defw    0
    defb    8, 9
    defm    "SNAP 128k"
    defw    0
    defb    9, 8
    defm    "OPENTYPE"
    defw    0
    defb    10, 7
    defm    "EXECUTE"
    defw    0
    defb    11, 5
    defm    "WHAT?"
    defw    0


;Check to make sure we have a
;";" or "," before a variable
;filename, or if we go direct
;into a filename, done so
;that compat is retained...

cksemi:
    cp      ','
    jp      z, rout32
    cp      ';'
    jp      z, rout32
    cp      '"'
    ret     z
    jr      nonerr

;Get the drive - from basic

gdrive:
    cp      '*'
    jr      z, chadd
    call    expt1n
    call    rom3
    defw    24
    call    syntax
    ret     z
    push    af
    call    rom3
    defw    fnint2
    ld      a, b
    and     a
    jr      nz, idveer
    ld      a, c
    cp      3
    jr      nc, idveer
    and     a
    jr      z, idveer
    ld      (curdrv), a
    pop     af
    ret
chadd:
    call    rom3
    defw    74h                         ;chadd
    ret

idveer:
    call    errorn
    defb    36                          ;invalid device
nonerr:
    call    errorn
    defb    11
varerr:
    call    errorn
    defb    1
bfnerr:
    call    errorn
    defb    33
parerr:
    call    errorn
    defb    45

;Check for end of line & also
;for syntax

ckend:
    call    rom3
    defw    24
    call    ckenqu
    jr      z, ckend1
;      pop  bc
    jr      nonerr
ckend1:
    ld      (iy+0), 255
    set     7, (iy+1)
    call    syntax
    ret     nz
    res     7, (iy+1)
    pop     bc
    jp      synexe

ckenqu:
    cp      13
    ret     z
    cp      58
;      ret  z
    ret

syntax:
    bit     7, (iy+48)
    ret

usezer:
    call    syntax
    ret     z
    ld      bc, 0
    call    rom3
    defw    11563
    ret


errorn:
    pop     hl
    ld      a, (hl)
    ld      (iy+0), a
    ld      hl, flags
    bit     6, (hl)
    jp      z, scan1
    cp      28
    jp      c, scan1
    sub     28
    ld      (iy+0), 255
    ld      l, a
    ld      h, 0
    ld      de, pdtab
    add     hl, de
    ld      a, (hl)
    scf
    jp      hkexis


rout32:
    call    rom3
    defw    32
    ret

e32_1n:
    call    rout32
expt1n:
    call    rom3
    defw    9467
    bit     6, (iy+1)
    ret     nz
    pop     bc
    call    errorn
    defb    11

exptex:
    call    rom3
    defw    9467
    bit     6, (iy+1)
    ret     z
    pop     bc
    call    errorn
    defb    11

prttho:
    ld      de, 10000
    call    numcal
prthou:
    ld      de, 1000
    call    numcal
prhund:
    ld      de, 100
    call    numcal
prtens:
    ld      de, 10
    call    numcal
prunit:
    ld      de, 1
    ld      b, 0


;b=0 print norm, b=255 do space
;b=254 don't print

numcal:
    ld      a, 255
numca1:
    inc     a
    and     a
    sbc     hl, de
    jr      nc, numca1
    add     hl, de
    and     a
    jr      z, numca2
    ld      b, 0
numca2:
    add     48
    ld      c, a
    ld      a, b
    and     a
    jr      z, numca3
    inc     a
    ret     nz
    ld      c, 32
numca3:
    ld      a, c
;      jp   print
;      ret

print:
    call    rom3
    defw    16
    ret

sros:
    ld      b, 7
    ld      hl, sector
    jr      ros0
;Maybe store page?
ros:
    ld      a, (page)
    and     7
    ld      b, a
ros0:
    ld      c, 1
    bit     7, d
    jr      z, ros1
    res     7, d
    ld      a, 159
    sub     d
    ld      d, a
ros1:
    ld      (ros2+2), ix
    ld      ix, xdpb
    ld      iy, 355
ros3:
    dec     e
    call    dodos
ros2:
    ld      ix, 0
    ret

swos:
    ld      b, 7
    ld      hl, wrisec
    jr      wos0
;Maybe store page?
wos:
    ld      a, (page)
    and     7
    ld      b, a
wos0:
    ld      c, 1
    bit     7, d
    jr      z, wos1
    res     7, d
    ld      a, 159
    sub     d
    ld      d, a
;was (wos2+2),ix
wos1:
    ld      (ros2+2), ix
    ld      ix, xdpb
    ld      iy, 358
    jr      ros3
;      dec  e
;      call dodos
;      jr   ros2
;os2   ld   ix,0
;      ret

messag:
    pop     hl
messa1:
    ld      a, (hl)
    inc     hl
    cp      255
    jp      z, cjump+1
    call    print
    jr      messa1

string:
    ld      a, b
    or      c
    ret     z
    ld      a, (de)
    call    print
    inc     de
    dec     bc
    jr      string



;+3 DOS call routine

dodos:
    di
    push    af
    push    bc
    ld      a, 7
    ld      bc, 32765
    out     (c), a
    ld      (23388), a
    pop     bc
    pop     af
    ei
    call    cjump
    di
    push    af
    push    bc
    ld      bc, 32765
    ld      a, 23
    out     (c), a
    ld      (23388), a
    pop     bc
    pop     af
    ld      iy, 23610
    ei
dcheat:
    ret     c

;Converter for +3 errors

errou:
    cp      20
    jr      z, bfilen
errou2:
    ld      c, a
    ld      b, 0
    ld      hl, contab
    add     hl, bc
    ld      a, (hl)
    ld      (errou1), a
;      pop  bc
    pop     bc
    call    errorn
errou1:
    defb    0

cjump:
    jp      (iy)

;Change the filename:
;Exit: if nc then try to
;resave filename
bfilen:
    ld      a, 1
    call    rom3
    defw    5633
    call    rom3
    defw    0D6Eh
    call    messag
    defb    22, 0, 0
    defm    "Bad filename - R,I,C?"
    defb    255
    call    confim
    cp      'R'
    jr      z, badf0
    cp      'I'
    jr      z, badf1
    cp      'C'
    jr      nz, bfilen
;Normal error exit...
    ld      a, 20
    jr      errou2
;Skip copying this file
badf1:
    ld      a, 2
    call    rom3
    defw    5633
    xor     a
    and     a
    ret

;Enter a new filename
badf0:
    ld      (iy+49), 1
    set     7, (iy+55)
    set     5, (iy+55)
    res     6, (iy+1)
    call    rom3
    defw    16BFh
    call    messag
    defb    22, 1, 0
    defm    "New filename: "
    defb    255
    ld      (iy+0), 255
    ld      bc, 1
    call    rom3
    defw    30h
    ld      (hl), 13
    ld      (23643), hl
    call    rom3
    defw    0F2Ch
;Now have to copy filename
;to correct place...
    call    rom3
    defw    0D6Eh
    ld      a, 2
    call    rom3
    defw    5633
    ld      hl, (gp3dr4)
    ld      b, 12
    call    clfil1
    ex      de, hl
    ld      hl, (23649)
    ld      b, 12
badf4:
    call    rom3
    defw    123
    cp      13
    jr      z, badf5
    ld      (de), a
    inc     hl
    inc     de
    djnz    badf4
badf5:
    and     a
    ret


fileno:
    defb    0
taken:
    defw    0
spstor:
    defw    0
flags:
    defb    0

xdpb:
    defb    40, 0, 5, 31, 3, 197, 0
    defb    255, 0, 192, 0, 64, 0, 0, 0
    defb    2, 3, 130, 80, 10, 1, 0, 2
    defb    12, 23, 96, 255

;dpb   defb 36,0,4,15,0,100,1
;      defb 127,0,192,0,32,0,1,0
;      defb 2,3,130,80,10,1,0,2
;      defb 42,82,96,0

;Table to convert +3 DOS errors
;(values 0-9 & 20-36) into rst 8
;codes

contab:
    defb    61, 62, 63, 64, 65, 66
    defb    67, 68, 69, 70
    defb    0, 0, 0, 0, 0
    defb    0, 0, 0, 0, 0
    defb    44, 45, 46, 47, 48, 49
    defb    50, 51, 52, 53, 54
    defb    55, 56, 57, 58, 59, 60



;Conversion of +3 errors into
;+D errors

pdtab:
    defb    0Eh, 0Dh, 0Fh, 0, 0, 0
    defb    1Ah, 1Ah, 0, 0, 0, 0, 0
    defb    0, 0, 0, 0, 0, 0, 1Ah, 1Ch
    defb    1Bh, 18h, 19h, 13h, 0, 0
    defb    0, 0, 0, 0, 0, 0, 6h, 17h
    defb    0, 4, 5, 5, 6, 0, 0, 6
    defb    0, 0, 0, 0, 0, 0, 0

