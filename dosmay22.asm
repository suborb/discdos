;DOSBLOK2 load + save routines
;and merge too..
;11/2/96 - LOAD @ bit now
;supports a drive parameter...
;Optimizing a bit...
;17/2/96 - rdbyte/wrbyte now
;respects page...
;21/2/96 - optimized a bit
;more...abt 15 bytes...
;7/3/96 - fixed a little bit
;of the savnew code - not a
;really bad error really..
;24/3/96 - moved (chanel) into
;the ufia (as per +D) and added
;a check of eof in reading
;also ask if want to overwrite
;made hidden/protected files
;load correctly
;2/5/96 - corrected major bug
;in overwrite bit...
;Optimized by making call/ret
;into a jp
;9/8/96 - 7:35pm
;Added 48k snapshot loading -
;hope it works!!
;22/8/96 - 7:30pm
;Sorted out where registers go
;and also the loadp stuff - was
;badly wrong!!!
;28/7/97
;Sorted out a bug in the SAVE
;CODE routine (due to astart)
;also added 3rd parameter to sav
;6/9/97 - dosmay22
;Resorted the loadp stuff weird
;things happen...
;6/12/97
;Sorted out the snapshot routine..weird!!


snpsafe:        equ wrisec
          
;chadd dw   0
;hanel db   2
;urdrv db   1
ftype:    db    0  
sect:     db    0  
track:    db    0  
lodadd:   dw    0  
secadd:   dw    0  
sectgo:   dw    0  
secpos:   dw    0  
cursec:   dw    0  
noofse:   dw    0  
comtyp:   db    0  
rdfsec:   dw    0  
wrtogo:   dw    0  
wrnosc:   dw    0  
wrsepo:   dw    0  
wdirad:   dw    0  
wrcsec:   dw    0  
wrdsec:   dw    0  
frepos:   db    0  
autoct:   db    0  
          
;Standard +D header...
          
curdrv:   
ufia:     db    1     ;drive  
          db    0     ;prog no  
chanel:   db    0     ;stream  
          db    'd'   ;device  
uddesc:   db    1     ;ddesc  
uname:    ds    10,32 ;filen  
dhtype:   db    0     ;ftype  
          dw    0     ;length  
          dw    0     ;start add  
          dw    0     ;length  
          dw    0     ;astart  
          
temphd:   ds    9,0  ;header on disc  
          
;The beefy load routine...
          
load:     ld    a,1  
          ld    (comtyp),a  
load0:    call  rout32  
          cp    '@'  
          jp    z,seclod  
          ld    (autoct),a  
load1:    and   223  
          cp    'D'  
          jr    z,loadud  
          cp    'P'  
          jp    z,loadp  
          jp    nonerr  
          
;And the merge routine
          
merge:    ld    a,3  
          ld    (comtyp),a  
merge1:   call  rout32  
          jr    load1  
          
save:     xor   a  
          ld    (comtyp),a  
          jr    load0  
          
verify:   ld    a,2  
          ld    (comtyp),a  
          jr    merge1  
          
          
;Upper case load...
          
loadud:   call  rout32  
          call  gdrive  
          call  cksemi  
          
;Copy of tape loading save &c
;routine - entered after sorting
;out d1/* syntax
;0=save, 1=load,2=verify,3=merge
savetc:   ld    ix,ufia  
          call  exptex  
          call  syntax  
          jr    z,sadata  
;Blank out the filename in UFIA
          push  ix  
          pop   hl  
          ld    bc,5  
          add   hl,bc  
          ld    b,10  
savet1:   ld    (hl),32  
          inc   hl  
          djnz  savet1  
saname:   push  ix  
          pop   hl  
          inc   hl  
          inc   hl  
          inc   hl  
          inc   hl  
          inc   hl  
          call  getstr  
;Come here if syntax
sadata:   call  rom3  
          dw    24  
          cp    228     ;data  
          jr    nz,sascr  
;Dealing with data...
          ld    a,(comtyp)  
          cp    3  
          jp    z,nonerr  
          call  rout32  
          call  rom3  
          dw    28B2h ; look vars  
          set   7,c  
          jr    nc,savold  
          ld    hl,0  
          ld    a,(comtyp)  
          dec   a  
          jr    z,savnew  
          call  errorn  
          db    1   ;var not found  
savold:   jp    nz,nonerr  
          call  syntax  
          jr    z,sadat1  
          inc   hl  
;Copy the length...
          ld    a,(hl)  
          ld    (ix+16),a  
          inc   hl  
          ld    a,(hl)  
          ld    (ix+17),a  
          inc   hl  
;Variable name...
savnew:   call  syntax  
          jr    z,sadat1  
          ld    (ix+18),c  
          ld    a,1  
          bit   6,c  
          jr    z,savtyp  
          inc   a  
;Save the file type...
savtyp:   ld    (ix+15),a  
          inc   a  
;Directory description
          ld    (ix+4),a  
sadat1:   ex    de,hl  
          call  rout32  
          cp    ')'  
          jr    nz,savold  ;nonerr  
          call  rout32  
          call  ckend  
          ex    de,hl  
          jp    saall  
;Now check for screen$
sascr:    cp    170  
          jr    nz,sacod  
          ld    a,(comtyp)  
          cp    3  
          jp    z,nonerr  
          call  rout32  
          call  ckend  
          ld    (ix+16),0  
          ld    (ix+17),27  
          ld    hl,16384  
          ld    (ix+18),l  
          ld    (ix+19),h  
          ld    a,7  
          jr    satyp3  
sacod:    cp    175  
          jr    nz,saline  
          ld    a,(comtyp)  
          cp    3  
          jp    z,nonerr  
          call  rout32  
          call  ckenqu  
          jr    nz,sacod1  
;No extra params...
          ld    a,(comtyp)  
          and   a  
          jp    z,nonerr  
          call  usezer  
          jr    sacod2  
sacod1:   call  expt1n  
          call  rom3  
          dw    24  
          cp    ','  
          jr    z,sacod3  
          ld    a,(comtyp)  
          and   a  
          jp    z,nonerr  
sacod2:   call  usezer  
          jr    sacod6  
sacod3:   call  e32_1n  
          call  rom3  
          dw    24  
          cp    ','  
          jr    nz,sacod6  
          call  e32_1n  
          jr    sacod4  
sacod6:   call  usezer  
sacod4:   call  ckend  
          call  rom3  
          dw    fnint2  
          ld    (ix+22),c  
          ld    (ix+23),b  
          call  rom3  
          dw    fnint2  
          ld    (ix+16),c  
          ld    (ix+17),b  
          call  rom3  
          dw    fnint2  
          ld    (ix+18),c  
          ld    (ix+19),b  
          ld    h,b  
          ld    l,c  
;Code +scr$ types...
          ld    a,4  
satyp3:   ld    (ix+4),a ;ddesc  
          ld    (ix+15),3  
          jr    saall  
;Snapshot
saline:   and   223  
          cp    'S'  
          jr    nz,salin1  
          call  rout32  
          call  ckend  
          ld    a,(comtyp)  
          dec   a  
          jp    nz,nonerr  
          ld    (ix+4),5  
          jr    saall  
;Basic
salin1:   cp    202 ;line  
          jr    z,salin0  
          call  ckend  
          ld    (ix+22),255  
          ld    (ix+23),255  
          jr    satyp0  
salin0:   ld    a,(comtyp)  
          and   a  
          jp    nz,nonerr  
          call  e32_1n  
          call  ckend  
          call  rom3  
          dw    fnint2  
          ld    (ix+22),c  
          ld    (ix+23),b  
satyp0:   ld    (ix+4),1  
          ld    (ix+15),0  
          ld    hl,(23641)  
          ld    de,(23635)  
          scf   
          sbc   hl,de  
;Length of program
          ld    (ix+16),l  
          ld    (ix+17),h  
          ld    (ix+18),e  
          ld    (ix+19),d  
          ld    hl,(23627)  
          sbc   hl,de  
;Length of prog-vars
          ld    (ix+20),l  
          ld    (ix+21),h  
          ex    de,hl  
saall:    ld    a,(comtyp)  
          and   a  
          jp    z,sacntl  
          cp    2   ;verify  
          ret   z  
;      jp   z,runexe
          ld    (saall2+1),hl  
;OK, LOAD,VERIFY,MERGE here
          ld    (autoct),a  
          call  rdopen  
;File is open now...
;Read in header now
;If not a basic file type now
;is the time to check for it!!
;File is open at first sector
;ix=header info in memory
saall0:   ld    a,(ix+4)  
          cp    5  
          jp    z,snpcnt  
          ld    hl,temphd  
          ld    b,9  
saall1:   call  rdbyte  
          ld    (hl),a  
          inc   hl  
          djnz  saall1  
saall2:   ld    hl,0  
          ld    a,(ix+15)  
          cp    3  
          jr    z,vrcntl  
          ld    a,(comtyp)  
          dec   a  
          jr    z,ldcntl  
          cp    2  
          jp    z,mecntl  
;Verify & also for CODE + SCR$
vrcntl:   push  hl  
          ld    l,(ix+16)  
          ld    h,(ix+17)  
          ld    bc,(temphd+1)  
          ld    a,l  
          or    h  
          jr    z,vrcnt1  
          sbc   hl,bc  
          jr    c,repotr  
          jr    z,vrcnt1  
          ld    a,(ix+15)  
          cp    3  
          jr    nz,repotr  
vrcnt1:   pop   hl  
          ld    a,h  
          or    l  
          jr    nz,vrcnt2  
          ld    hl,(temphd+3)  
vrcnt2:   ex    de,hl  
ldblok:   jp    rdblok  
;      ret
;      jp   runexe
          
;epotr pop  hl
repotr:   call  errorn  
          db    79   ;code length  
          
;For basic progs +arrays
ldcntl:   ld    de,(temphd+1)  
          push  hl  
          ld    a,h  
          or    l  
          jr    nz,ldcnt1  
          inc   de  
          inc   de  
          inc   de  
          ex    de,hl  
          jr    ldcnt2  
ldcnt1:   ld    l,(ix+16)  
          ld    h,(ix+17)  
          ex    de,hl  
          scf   
          sbc   hl,de  
          jr    c,lddata  
ldcnt2:   ld    de,5  
          add   hl,de  
          ld    b,h  
          ld    c,l  
          call  rom3  
          dw    1F05h  ; test room  
lddata:   pop   hl  
          ld    a,(ix+15)  
          and   a  
          jr    z,ldprog  
          ld    a,h  
          or    l  
          jr    z,lddat1  
          dec   hl  
          ld    b,(hl)  
          dec   hl  
          ld    c,(hl)  
          dec   hl  
          inc   bc  
          inc   bc  
          inc   bc  
          ld    (23647),ix  ; xptr  
          call  rom3  
          dw    19E8h ; reclaim 2  
          ld    ix,(23647)  
lddat1:   ld    hl,(23641)  
          dec   hl  
          ld    bc,(temphd+1)  
          push  bc  
          inc   bc  
          inc   bc  
          inc   bc  
          ld    a,(ix+18) ;variable  
          push  af  
          call  rom3  
          dw    1655h  ;make room  
          inc   hl  
          pop   af  
          ld    (hl),a  
          pop   de  
          inc   hl  
          ld    (hl),e  
          inc   hl  
          ld    (hl),d  
          inc   hl  
          ex    de,hl  
          push  hl  
          pop   bc  
          jp    ldblok  
          
ldprog:   ex    de,hl  
          ld    hl,(23641)  
          dec   hl  
          ld    (23647),ix  
          ld    bc,(temphd+1)  
          push  bc  
          call  rom3  
          dw    19E5h ; reclaim 1  
          pop   bc  
          push  hl  
          push  bc  
          call  rom3  
          dw    1655h ; make room  
          ld    ix,(23647)  
          inc   hl  
          ld    bc,(temphd+5) ;n len  
          add   hl,bc  
          ld    (23627),hl  
          ld    hl,(temphd+7)  
          ld    a,h  
          and   11000000b  
          jr    nz,ldprg1  
          ld    (23618),hl  
          ld    (iy+10),0  
ldprg1:   pop   bc  
          pop   de  
          jp    ldblok  
          
;Loading 48k snapshots
          
snpcnt:   ld    de,16384  
          ld    bc,6912  
          call  rdblok  
          ld    a,23  
          ld    (page),a  
          ld    de,wrisec+256  
          ld    bc,256  
          call  rdblok  
          ld    a,16  
          ld    (page),a  
          ld    de,23296+256  
          ld    bc,41984  
          call  rdblok  
          di
          ld    hl,wrisec+256  
          ld    de,23296  
          ld    bc,256  
          ldir  
          im    1  
          ld    sp,snpsafe
          pop   iy  
          pop   ix  
          pop   de  
          pop   bc  
          pop   hl  
          pop   af  
          exx   
          ex    af,af'  
          pop   de  
          pop   bc  
          pop   hl  
          pop   af  
          ld    i,a  
;New im2 26/10/98
          and   a
          jr    z,noim2
          cp    63
          jr    z,noim2
;          ld    a,(snpsafe+18)  
;          bit   0,a  
;          jr    z,noim2  
          im    2  
noim2:    ld    (snppa1+1),bc  
          push  hl  
          push  de  
          ld    hl,snppag  
          ld    de,16384  
          ld    bc,23  
          ldir  
          pop   de  
          pop   hl  
          ld    sp,(snpsafe+20)  
          jp    16384  
          
snppag:   ld    bc,32765  
          ld    a,16  
          out   (c),a  
          ld    a,48  
          out   (c),a  
snppa1:   ld    bc,0  
          pop   af  
          ld    r,a  
          jp    po,2DE1h  
          jp    80  
          
          
;Program number load, can also
;be used for load + verify..
          
loadp:    ld    a,(comtyp)  
          and   a  
          jp    z,nonerr  
          call  e32_1n  
          call  ckend  
          call  loadp0  
          cp    7  
          jr    z,loadp4  
;Altered 5 -> 6 here...
          cp    6  
          jr    c,loadp4  
loadp6:   call  errorn  
          db    29  ;wrong file type  
;Okay, at this point have a
;normal basic type file..+snap
loadp4:   ld    ix,ufia  
;Check that we are merging a
;BASIC file
          ex    af,af'  
          ld    a,(comtyp)  
          cp    3  
          jr    nz,loadpc  
          ex    af,af'  
          dec   a  
          jr    nz,loadp6  
;Why is loadp5 a subroutine?
;Not called elsewher...6/9/97
loadpc:   call  loadp5  
;Reset file pointers
          ld    l,(ix+18)  
          ld    h,(ix+19)  
          ld    (saall2+1),hl  
          jp    saall0  
          
;Exits with a=directory type
          
loadp0:   call  rom3  
          dw    fnint1  
          and   a  
          jr    z,loadpa  
          cp    81  
          jr    c,loadp1  
loadpa:   call  errorn  
          db    45 ;bad param  
loadp1:   ld    b,a  
          ld    a,(comtyp)  
          cp    2  
          ret   z  
          call  locate  
          push  af  
          call  sros  
          ld    hl,sector  
          pop   af  
          jr    nc,loadp2  
          inc   h  
loadp2:   ld    (secadd),hl  
          ld    a,(hl)  
          and   127  
          ld    (ftype),a  
          ret   nz  
          call  errorn  
          db    34  ;file not exist  
          
loadp5:   push  hl  
          ld    bc,211  
          add   hl,bc  
          ld    de,dhtype  
          ld    bc,9  
          ldir  
          pop   hl  
          call  rdope3  
          ret   
          
          
;Merge control routine
          
mecntl:   ld    bc,(temphd+1)  
          push  bc  
          inc   bc  
          call  rom3  
          dw    48 ;bc spaces  
          ld    (hl),128  
          pop   bc  
          push  de  
          call  rdblok  
          pop   hl  
          ld    de,(23635)  
          call  rom3  
          dw    08D2h ; me-new-lp  
          ret   
;      jp   runexe
          
;Save control routine
          
sacntl:   push  hl  
          call  wropen  
          pop   de  
          ld    c,(ix+16)  
          ld    b,(ix+17)  
          call  wrblok  
          jp    wrclos  
;      ret
;      jp   runexe
          
          
;Open a file to read..
;Entry: ix=addy of UFIA
          
;Copy the filename
rdopen:   push  ix  
          pop   hl  
          ld    bc,5  
          add   hl,bc  
          ld    de,filen  
          ld    bc,10  
          ldir  
;Scan for the file existing..
          call  discan  
          ld    (secadd),hl  
          jr    c,rdope1  
;      pop  bc
          call  errorn  
          db    34  
;Okay the filename exists..
;ATP hl=addy of dir entry in
;memory...
;Check that the file types
;match (easier than dir types)
;but should use dir types
;in later version (other dir
;types have no file type)
rdope1:   push  hl  
;      push hl
;Okay storing the filename
;for use in copy routines...
          inc   hl  
          ld    de,pdname  
          ld    bc,10  
          ldir  
;      ld   hl,flags  ;for hook
;      bit  6,(hl)    ;codes
          pop   hl  
;Directory type matching...
          ld    a,(hl)  
          and   63  
          cp    7  
          jr    nz,rdop15  
          ld    a,4  
rdop15:   ld    b,a  
          ld    a,(ix+4)  
          cp    7  
          jr    nz,rdop16  
          ld    a,4  
rdop16:   cp    255  
          jr    z,rdop25  
          
;      ld   bc,211
;      add  hl,bc
;      ld   a,(ix+15)
;      cp   255
;      ld   b,a
;      jr   z,rdop25
;      ld   a,(hl)
;      and  63
          
          cp    b  
;dop25 pop  hl
rdop25:   
          jr    z,rdope3  
;      pop  bc
rdope2:   call  errorn  
          db    29 ;wrong file type  
;At this point it's ok to load..
;so get our first sector +no/sec
;Copy the dirtype over
rdope3:   ld    a,(hl)  
          ld    (ix+4),a  
          ld    bc,11  
          add   hl,bc  
          ld    d,(hl)  
          inc   hl  
          ld    e,(hl)  
          inc   hl  
          ld    (noofse),de  
          ld    d,(hl)  
          inc   hl  
          ld    e,(hl)  
          ld    (cursec),de  
          ld    (rdfsec),de  
          ld    hl,(secadd)  
          ld    bc,220  
          add   hl,bc  
          ld    de,snpsafe
          ld    bc,25  
          ldir  
;Read in the first sector of
;the file + reset pointers...
rnfsec:   ld    de,(cursec)  
          ld    a,d  
          or    e  
          jr    nz,rnfse1  
          call  errorn  
          db    49 ;eof found  
rnfse1:   call  sros  
          ld    de,(sector+510)  
          ld    a,e  
          ld    e,d  
          ld    d,a  
          ld    (cursec),de  
          ld    hl,(noofse)  
          dec   hl  
          ld    (noofse),hl  
          ld    hl,510  
          ld    (sectgo),hl  
          ld    hl,sector  
          ld    (secpos),hl  
          ret   
          
          
;Read a string of bytes
;Entry: de=ld addr
;       bc=length..
          
rdinit:   ld    hl,rdcopr  
          jp    wrini1  
;      ret
rdblok:   call  rdinit  
rdblo1:   ld    a,b  
          or    c  
          ret   z  
          call  rdbyte  
          call  rdcopy  
          inc   de  
          dec   bc  
          jr    rdblo1  
          
rdcopy:   di    
          push  bc  
          ld    b,a  
          ld    a,(page)  
          ld    l,a  
          ld    a,b  
          ld    bc,32765  
          ld    h,23  
          jp    23420  
rdcop1:   pop   bc  
          ei    
          ret   
          
rdcopr:   out   (c),l  
          ld    (de),a  
          out   (c),h  
          jp    rdcop1  
          
          
;Read a byte from the file
;
;Entry: none
;Exit:   a=code
;(all else preserved)
          
rdbyte:   push  de  
          push  bc  
          push  hl  
          ld    hl,(sectgo)  
          ld    a,h  
          or    l  
          jr    nz,rdbyt1  
;Maybe insert a check for
;number of sectors here?
          call  rnfsec  
rdbyt1:   ld    hl,(secpos)  
          ld    a,(hl)  
          inc   hl  
          ld    (secpos),hl  
          ld    hl,(sectgo)  
          dec   hl  
          ld    (sectgo),hl  
          pop   hl  
          pop   bc  
          pop   de  
          ret   
          
          
          
;Sector load routine..
;Also works for save..what a
;star!!!
;Rewritten to support being
;given a drive...
          
seclod:   call  rout32  
          call  gdrive  
          call  rom3  
          dw    24  
          cp    ','  
          jp    nz,nonerr  
          call  e32_1n  
          cp    ','  
          jp    nz,nonerr  
          call  e32_1n  
          cp    ','  
          jp    nz,nonerr  
          call  e32_1n  
seclo0:   call  ckend  
          call  rom3  
          dw    fnint2  
          ld    (lodadd),bc  
          call  rom3  
          dw    fnint2  
          ld    a,b  
          and   a  
          jp    nz,parerr  
          ld    a,c  
          ld    (sect),a  
          call  rom3  
          dw    fnint2  
          ld    a,b  
          and   a  
          jp    nz,parerr  
          ld    a,c  
          ld    (track),a  
seclo3:   ld    de,(sect)  
          ld    hl,(lodadd)  
          ld    a,(comtyp)  
          and   a  
          jr    z,seclo1  
          jp    ros  
;      ret
;      jp   runexe
seclo1:   jp    wos  
;      ret
;      jp   runexe
          
;Locate a directory entry
;Entry: b=file number (1=nase)
;Exit:  d=track
;       e=sector
;carry if in second half of sec
          
locate:   ld    c,0  
          ld    de,2  
locat1:   ld    a,b  
          dec   a  
          jr    z,locout  
          ld    a,c  
          xor   1  
          ld    c,a  
          inc   e  
          ld    a,e  
          cp    22  
          jr    c,locat2  
          inc   d  
          ld    e,2  
locat2:   dec   b  
          jr    locat1  
locout:   srl   e  
          srl   c  
          ret   
          
          
          
          
          
          
;Save command
          
          
;Open a file to be write
;Entry: ix=ufia
          
wropen:   push  ix  
          pop   hl  
          ld    bc,5  
          add   hl,bc  
          ld    de,filen  
          ld    bc,10  
          ldir  
wropes:   call  discan  
          jr    nc,wrope1  
;Filename exists check....
          ld    (frepos),a  
;Should check if write protected
          bit   6,(hl)  
          jr    z,wrope0  
          call  errorn  
          db    52 ;file rd only  
wrope0:   ld    a,0FDh  
          call  rom3  
          dw    5633  
          call  messag  
          db    22,1,0  
          defm  "OVERWRITE? (Y/N)?"
          db    255  
          call  confim  
          jr    nz,fiexis  
;Okay, have to remap here...
;And actually erase the file
          ld    hl,flags  
          ld    a,(hl)  
          res   1,(hl)  
          push  af  
          ld    a,(frepos)  
          call  erase8  
          pop   af  
          ld    (flags),a  
          jr    wropes  
fiexis:   call  errorn  
          db    32  
;Okay have mapped the disc
;now find a free dir entry
wrope1:   ld    a,(frepos)  
          and   a  
          jr    nz,wrope2  
;No space in directory
          call  errorn  
          db    51  
;a=file number
wrope2:   ld    b,a  
          call  locate  
;OK, got track+sector+carry
          ld    (wrdsec),de  
          push  af  
          call  sros  
;      ld   hl,sector
;      ld   de,dirmse
;      ld   bc,512
;      ldir
          ld    hl,wrisec  
          pop   af  
          jr    nc,wrope3  
          inc   h  
wrope3:   ld    (wdirad),hl  
;Clear the sector + dirmsetor
          ld    hl,dirmse  
          push  hl  
          push  hl  
          pop   de  
          inc   de  
          ld    bc,255  
          ld    (hl),0  
          ldir  
          ld    hl,wrisec  
          ld    de,wrisec+1  
          ld    bc,511  
          ld    (hl),0  
          ldir  
;Copy the filename to dirmse
;And copy ufia to start of
;file
          pop   de  
          push  ix  
          pop   hl  
          ld    bc,4  
          add   hl,bc  
          ld    bc,11  
          ldir  
          push  de  
          push  hl  
          ex    de,hl  
          ld    hl,dirmse+211  
;      ld   bc,211
;      add  hl,bc
          ex    de,hl  
          ld    bc,9  
          ldir  
          pop   hl  
          ld    de,wrisec  
          ld    bc,9  
          ldir  
;Okay get number of sectors the
;file requires
          ld    l,(ix+16)  
          ld    h,(ix+17)  
          ld    bc,9  
          add   hl,bc  
          ld    bc,510  
          ld    de,0  
save3:    and   a  
          sbc   hl,bc  
          inc   de  
          jr    nc,save3  
          pop   hl  
          ld    (hl),d  
          inc   hl  
          ld    (hl),e  
          ld    (wrnosc),de  
          inc   hl  
          push  hl  
;Now get the first free sector
          call  findse  
          call  locimp  
          pop   hl  
          ld    (hl),d  
          inc   hl  
          ld    (hl),e  
          ld    (wrcsec),de  
          ld    hl,wrisec+9  
          ld    (wrsepo),hl  
          ld    hl,510-9  
          ld    (wrtogo),hl  
          ret   
          
;Write a string of bytes
;Entry: de=addr
;       bc=length
          
          
wrblok:   call  wrinit  
wrblo1:   ld    a,b  
          or    c  
          ret   z  
          call  wrcopy  
          call  wrbyte  
          inc   de  
          dec   bc  
          jr    wrblo1  
          
wrinit:   ld    hl,wrcopr  
wrini1:   push  de  
          push  bc  
          ld    de,23420  
          ld    bc,10  
          ldir  
          pop   bc  
          pop   de  
          ret   
          
wrcopy:   di    
          push  bc  
          ld    bc,32765  
          ld    a,(page)  
          ld    l,a  
          ld    h,23  
          jp    23420  
wrcop1:   pop   bc  
          ei    
          ret   
          
wrcopr:   out   (c),l  
          ld    a,(de)  
          out   (c),h  
          jp    wrcop1  
          
;Write a byte to the file
;Entry: a=byte
          
wrbyte:   push  de  
          push  bc  
          push  hl  
          push  af  
          ld    hl,(wrtogo)  
          ld    a,h  
          or    l  
          jr    nz,wrbyt1  
;Okay, RAM sector is full
;so write it and find another
          call  findse  
          push  de  
          ld    a,d  
          ld    (wrisec+510),a  
          ld    a,e  
          ld    (wrisec+511),a  
          ld    de,(wrcsec)  
          call  swos  
          pop   de  
          call  locimp  
          ld    (wrcsec),de  
          ld    hl,510  
          ld    (wrtogo),hl  
          ld    hl,(wrnosc)  
          dec   hl  
          ld    (wrnosc),hl  
          ld    hl,wrisec  
          ld    (wrsepo),hl  
          ld    de,wrisec+1  
          ld    bc,511  
          ld    (hl),0  
          ldir  
;Okay, now write the byte
wrbyt1:   pop   af  
          ld    hl,(wrsepo)  
          ld    (hl),a  
          inc   hl  
          ld    (wrsepo),hl  
          ld    hl,(wrtogo)  
          dec   hl  
          ld    (wrtogo),hl  
          pop   hl  
          pop   bc  
          pop   de  
          ret   
          
;Lock both the main map and
;the dir map
          
locimp:   push  de  
          push  de  
          ld    hl,map  
          call  loctr  
          pop   de  
;      ld   de,(wrcsec)
          ld    hl,dirmse+15  
;      ld   bc,15
;      add  hl,bc
          call  loctr  
          pop   de  
          ret   
          
;Close a file being written
          
wrclos:   ld    de,(wrcsec)  
;      call locimp
          call  swos  
          ld    de,(wrdsec)  
          call  sros  
          ld    hl,sector  
          ld    de,wrisec  
          ld    bc,512  
          ldir  
          ld    hl,dirmse  
          ld    de,(wdirad)  
          ld    bc,256  
          ldir  
          ld    de,(wrdsec)  
          jp    swos  
;      ret
          
          
;Find position in directory data
;Entry:      d=track,e=sector
;Exit        c=postion
;            b=bit number(8-1)
          
find:     ld    a,d  
          bit   7,a  
          jr    z,finok  
          res   7,a  
          add   80  
finok:    sub   3  
          ld    d,a  
          ld    c,0  
find1:    ld    b,8  
find2:    dec   e  
          jr    nz,find3  
          ld    e,10  
          dec   d  
          jr    z,find4  
find3:    djnz  find2  
          inc   c  
          jr    find1  
find4:    ld    a,9  
          sub   b  
          ld    b,a  
          ret   
          
;Find a free sector
;Exit: d=track, e=sector
          
findse:   ld    hl,map  
          ld    d,4  
          ld    e,1  
          ld    c,195  
finds1:   ld    b,8  
          ld    a,(hl)  
finds2:   rrca  
          ret   nc  
          ex    af,af'  
          inc   e  
          ld    a,e  
          cp    11  
          jr    nz,finds4  
          ld    e,1  
          inc   d  
          ld    a,d  
          res   7,a  
          cp    80  
          jr    nz,finds4  
          bit   7,d  
          jr    nz,finds5  
          ld    d,128  
finds4:   ex    af,af'  
          djnz  finds2  
          inc   hl  
          dec   c  
          jr    nz,finds1  
;No free sectors
finds5:   call  errorn  
          db    50  
          
          
;Lock off trk/sec in a +D map
;Entry: d=track,e=sector
;      hl=map addy
          
loctr:    push  bc  
          push  de  
          push  af  
          call  find  
          ld    a,b  
          ld    b,0  
          add   hl,bc  
          ld    b,a  
          ld    a,128  
loctr1:   rlca  
          djnz  loctr1  
          or    (hl)  
          ld    (hl),a  
          pop   af  
          pop   de  
          pop   bc  
          ret

