;DOSBLOK5 - copy
;(DOSBLOK4 is corrupt)
;Changing the wildcard scan
;by using (flags)
;11/2/96 - went thru doing
;a bit of optimization...
;18/2/96 - added filename
;printing to copy..
;7/3/96 - fixed the +3 > +D
;header set up..
;24/3 - sorted out the 0 files
;copied thing and added READ #
;31/3/96 added support for
;bad filename..
;22/4/96 sorted out a few probs
;with filenames when +D > +3
;also made POKE @ do some
;system variables
;2/5/96 did the call/ret optim
;7/12/97 Tidied up the routines to save some bytes

          
;READ # command -set +3 USER are
          
uread:    call  rout32  
          cp    '#'  
          jp    nz,nonerr  
          call  e32_1n  
          call  ckend  
          call  rom3  
          dw    fnint2  
          ld    a,b  
          and   a  
          jr    z,uread2  
uread1:   call  errorn  
          db    45 ;bad parameters  
uread2:   ld    a,c  
          cp    16  
          jr    nc,uread1  
          ld    iy,304  
          jp    dodos  
;      ret
;      jp   runexe
          
;Poke @ routine...compatibility
;Now does a bit...16 bit poke
;for page 7...
          
poke:     call  rout32  
          cp    '@'  
          jp    nz,nonerr  
          call  e32_1n  
          cp    ','  
          jp    nz,nonerr  
          call  e32_1n  
          call  ckend  
          call  rom3  
          dw    fnint2  
          push  bc  
          call  rom3  
          dw    fnint2  
          ld    h,b  
          ld    l,c  
          pop   bc  
          ld    a,h  
          and   a  
          ret  z
;          jr    z,poke2  
          ld    (hl),c  
          inc   hl  
          ld    a,b  
          and   a  
          jr    z,poke1  
          ld    (hl),b  
poke1:    ret   
;oke1  jp   runexe
;Printer pokes...
poke2:    ld    a,l  
          sub   5  
          jr    nz,poke3  
          ld    a,c  
          ld    (23396),a  
          jr    poke1  
poke3:    dec   a  
          ret  nz
;          jr    nz,poke1  
          ld    hl,23398  
          set   2,(hl)  
          dec   c  
          ret  nz
;          jr    nz,poke1  
          res   2,(hl)  
          ret   
          
;The long awaited format routine
;Added 13/2/96....
          
format:   call  rout32  
          and   223  
          cp    'D'  
          jp    nz,nonerr  
          call  rout32  
          call  gdrive  
          call  ckend  
;The format routine proper
;Check if we're certain...
          ld    a,0FDh  
          call  rom3  
          dw    5633  
          call  messag  
          db    22,1,0  
          defm  "ARE YOU SURE (Y/N)?"
          db    255  
          call  confim  
          
          
          ret   nz  
;      jp   nz,runexe
;Rest of format
          ld    hl,sector  
          ld    de,sector+1  
          ld    bc,511  
          ld    (hl),l  
          ldir  
          ld    b,160  
          ld    d,0  
form1:    push  bc  
          push  de  
          ld    ix,xdpb  
          call  setup  
          pop   de  
          push  de  
          ld    e,0  
;          ld    b,7  
;          ld    c,1  
          ld   bc,1793
          ld    hl,sector  
          ld    iy,364  
          call  dodos  
          pop   de  
          inc   d  
          pop   bc  
          djnz  form1  
          ret   
;      jp   runexe
          
          
setup:    push  bc  
          push  de  
          ld    b,(ix+19)  
          ld    c,0  
          ld    hl,sector  
setup1:   push  bc  
          push  de  
          ld    a,(ix+17)  
          ld    b,0  
          and   127  
          jr    z,setup3  
          dec   a  
          jr    nz,setup2  
          ld    a,d  
          rra   
          ld    d,a  
          ld    a,b  
          rla   
          ld    b,a  
          jr    setup3  
setup2:   ld    a,d  
          sub   (ix+18)  
          jr    c,setup3  
          sub   (ix+18)  
          cpl   
          ld    d,a  
          inc   b  
setup3:   ld    (hl),d  
          inc   hl  
          ld    (hl),b  
          inc   hl  
          pop   de  
          pop   bc  
          push  bc  
          xor   a  
          bit   0,c  
          jr    z,setup4  
          ld    a,(ix+19)  
          inc   a  
          srl   a  
setup4:   add   (ix+20)  
          srl   c  
          add   c  
          ld    (hl),a  
          pop   bc  
          inc   c  
          inc   hl  
          ld    a,(ix+15)  
          ld    (hl),a  
          inc   hl  
          djnz  setup1  
          pop   de  
          pop   bc  
          ret   
          
          
;Copy routine
;A nightmare!!!
;Think I've done +D > +D
;Think i've done +D > +3
;Need to add wildcards to +3 >+D
          
copy:     call  rout32  
          ld    (autoct),a  
          and   223  
          cp    'D'  
          jp    z,copy20  
          
;Okay copy +3 > +D here
          call  exptex  
          cp    204  
          jp    nz,nonerr  
          call  rout32  
          ld    (autoct),a  
          and   223  
          cp    'D'  
          jp    nz,nonerr  
          call  rout32  
          call  gdrive  
          call  syntax  
          jr    z,copy1  
          ld    hl,flags  
          set   3,(hl)  
copy1:    call  rom3  
          dw    24  
          call  ckenqu  
          jr    z,copy2  
          call  cksemi  
          call  exptex  
          call  syntax  
          jr    z,copy2  
          ld    hl,flags  
          res   3,(hl)  
          ld    hl,ufia+5  
          call  clfiln  
          call  getstr  
          jr    z,copy2  
          call  errorn  
          db    73 ;dest can't wild  
;Okay, now get the original
;name on +3
copy2:    call  ckend  
          ld    hl,flags  
          res   2,(hl)  
          ld    hl,namep3  
          ld    b,16  
          call  clfil1  
          ld    bc,16  
          call  getst0  
          ld    hl,flags  
          jr    z,cop2_3  
;Source (+3) is wild
          bit   3,(hl)  
          jr    nz,cop2_8  
          call  errorn  
          db    74 ;dest must be drv  
cop2_8:   
;          set   1,(hl)  
;      bit  3,(hl)
;      jr   nz,cop2_9
;      call errorn
;      db   73 ;dest can't wild
cop2_9:   ld    hl,namep3  
          ld    de,catnam  
          ld    bc,16  
          ldir  
;      call errorn
;      db   43
;Reset the variables etc...
cop2_3:   ld    hl,copied  
          ld    (hl),0  
          ld    a,2  
          call  rom3  
          dw    5633  
          ld    a,13  
          call  print  
copy3:    call  gp3drv  
          ld    hl,flags  
          bit   1,(hl)  
          jp    z,copy9  
;Okay have a wild source...
;So do the catalogue..
          push  hl  
          ld    hl,sector  
          ld    de,sector+1  
          ld    bc,32  
          ld    (hl),b ;b=0  
          ldir  
          pop   hl  
          bit   2,(hl)  
          jr    z,cop3_1  
;Copy the filename over..
          ld    hl,(gp3dr4)  
          ld    de,sector  
          ld    bc,8  
          ldir  
          inc   hl  
          ld    bc,3  
          ldir  
cop3_1:   ld    hl,catnam  
          ld    de,sector  
;          ld    b,3  
;          ld    c,1  
          ld   bc,769
          ld    iy,286  
          call  dodos  
          ld    hl,flags  
          ld    a,b  
          dec   a  
          jr    nz,cop3_2  
          bit   2,(hl)  
          jp    nz,copy6  
          call  errorn  
          db    47 ;file not found  
cop3_2:   ld    hl,sector+13  
          ld    de,(gp3dr4)  
          ld    b,8  
          call  cop3_3  
          ld    a,'.'  
          ld    (de),a  
          inc   de  
          ld    b,3  
          call  cop3_3  
          jr    cop3_4  
cop3_3:   ld    a,(hl)  
          and   127  
          ld    (de),a  
          inc   hl  
          inc   de  
          djnz  cop3_3  
          ret   
cop3_4:   
copy9:    ld    hl,flags  
          bit   3,(hl)  
          call  nz,pdconv  
;Open a +3 file and sort
;out the header crap
;Okay, print the names...
          call  prfiln  
          ld    de,ufia+5  
          call  prdfin  
          ld    hl,copied  
          inc   (hl)  
;Now, open the files..
          ld    bc,1  
          ld    d,b  
          ld    e,c  
          ld    hl,namep3  
          ld    iy,262  
          call  dodos  
          ld    b,0  
          ld    iy,271  
          call  dodos  
          jp    z,wfiltp  
;Copy the file header
          push  ix  
          pop   hl  
          ld    de,ufia+15  
          ld    bc,7  
          ldir  
          ld    hl,65535  
          ld    (ufia+22),hl  
          ld    a,(ufia+15)  
          inc   a  
          ld    (ufia+4),a  
          cp    4  
          jr    nz,screeh  
          ld    hl,16384  
          ld    de,(ufia+18)  
          and   a  
          sbc   hl,de  
          jr    nz,screeh  
          ld    hl,6912  
          ld    de,(ufia+16)  
          and   a  
          sbc   hl,de  
          jr    nz,screeh  
          ld    a,7  
          ld    (ufia+4),a  
screeh:   ld    a,(ufia+15) ;dhead  
          and   a  
          jr    nz,nobas  
          ld    de,(23635)  
          ld    hl,(ufia+18)  
          ld    (ufia+18),de  
          bit   7,h  
          jr    nz,nobas  
          ld    (ufia+22),hl  
;obas  ld   a,(ufia+15)
nobas:    cp    4  
          jr    c,nobas1  
wfiltp:   call  errorn  
          db    29 ;wrong file type  
;Now open the +D file
nobas1:   ld    ix,ufia  
          call  wropen  
          ld    bc,(ufia+16)  
copy5:    push  bc  
          ld    b,0  
          ld    iy,280  
          call  dodos  
          ld    a,c  
          call  wrbyte  
          pop   bc  
          dec   bc  
          ld    a,b  
          or    c  
          jr    nz,copy5  
          call  wrclos  
          ld    b,0  
          ld    iy,265  
          call  dodos  
          ld    hl,flags  
          set   2,(hl)  
          bit   1,(hl)  
          jp    nz,copy3  
copy6:    call  messag  
          db    13,13,32,255  
          ld    hl,(copied)  
          ld    h,0  
          ld    b,255  ;254  
          call  prhund  
          call  messag  
          defm  " file"
          db    255  
          ld    a,(copied)  
          dec   a  
          ld    a,'s'  
          call  nz,print  
          call  messag  
          defm  " copied."
          db    13,255  
          ret   
;      jp   runexe
          
          
;Original file is on +D
copy20:   call  rout32  
          call  gdrive  
          call  cksemi  
          call  exptex  
          cp    204  
          jp    nz,nonerr  
          call  rout32  
          and   223  
          cp    'D'  
          jp    z,copy30  
;Okay here we have copy to +3
          ld    (autoct),a  
          call  exptex  
          call  ckend  
;Set up the default drive
;      ld   a,255
;      ld   iy,301
;      call dodos
          ld    b,16  
          ld    hl,namep3  
          call  clfil1  
          ld    bc,16  
          call  getst0  
          jr    z,copy23  
;Wildcards so error
copy22:   call  errorn  
          db    43 ;bad filename  
copy23:   ld    hl,flags  
          res   2,(hl)  
          res   3,(hl)  
          res   4,(hl)  
          call  gp3drv  
          ld    hl,flags  
          bit   5,(hl)  
          jr    z,copy24  
          set   3,(hl)  
;Okay have indicated we have a
;only a drive and checked it
copy24:   ld    hl,filen  
          call  clfiln  
          call  getstr  
          jr    z,copy25  
          ld    hl,flags  
;      set  1,(hl)
          bit   3,(hl)  
          jr    nz,copy25  
;Okay source has wilds, but
;dest is a file...error!!!
          call  errorn  
          db    74 ;dest must be drv  
;Okay, have set up the +3 drive
;Copying the files
copy25:   ld    hl,copied  
          ld    (hl),0  
          ld    a,2  
          call  rom3  
          dw    5633  
          ld    a,13  
          call  print  
cop251:   ld    ix,ufia  
          ld    (ix+4),255  
;Scan the disc for the name
          call  disca0  
          jr    c,cop255  
          ld    hl,flags  
          bit   2,(hl)  
          jp    nz,copy6  
          call  errorn  
          db    34 ; no file  
cop255:   call  rdope1  
;Where does the filename go?
          ld    hl,ufia+15  
          ld    b,9  
copy26:   call  rdbyte  
          ld    (hl),a  
          inc   hl  
          djnz  copy26  
;Read in the header...
;Now convert the filename and
;open a +3 file...
          ld    hl,flags  
          bit   3,(hl)  
          jr    z,cop266  
          ld    hl,(gp3dr4)  
          ld    b,12  
          call  clfil1  
          ex    de,hl  
          call  nsort  
;Print the filenames
cop266:   ld    de,pdname  
          call  prdfin  
          call  prfiln  
          ld    a,13  
          call  print  
;Now open the +3 file
          ld    hl,namep3  
          ld    de,259  
          ld    bc,2  
          ld    iy,262  
          call  dodos  
          jr    c,cop267  
;Handle the error condition
;things..
;Got new filename
          jr    nz,cop266  
;Skip this file..
          jr    nobas3  
cop267:   ld    bc,(ufia+16)  
copy27:   push  bc  
          call  rdbyte  
          ld    b,0  
          ld    c,a  
          ld    iy,283  
          call  dodos  
          pop   bc  
          dec   bc  
          ld    a,b  
          or    c  
          jr    nz,copy27  
;Now close the +3 file and
;write the header
;Set up +3 disc header
          ld    ix,ufia  
          ld    a,(ix+15)  
          ld    (dhead),a  
          ld    l,(ix+16)  
          ld    h,(ix+17)  
          ld    (dhead+1),hl  
          ld    e,(ix+18)  
          ld    d,(ix+19)  
          ld    hl,65535  
          and   a  
          jr    nz,nobas2  
          ld    e,(ix+22)  
          ld    d,(ix+23)  
          ld    l,(ix+20)  
          ld    h,(ix+21)  
nobas2:   ld    (dhead+3),de  
          ld    (dhead+5),hl  
          ld    b,0  
          ld    iy,271  
          call  dodos  
          push  ix  
          pop   de  
          ld    hl,dhead  
          ld    bc,7  
          ldir  
          
          ld    b,0  
          ld    iy,265  
          call  dodos  
          ld    hl,copied  
          inc   (hl)  
nobas3:   ld    hl,flags  
          set   2,(hl)  
          set   4,(hl)  
          bit   1,(hl)  
          jp    nz,cop251  
          jp    copy6  
          
          
          
          
          
          
          
;Okay +D - +D copy - easy
;No wildcards
copy30:   call  rout32  
          call  gdrive  
          call  cksemi  
          call  exptex  
          call  ckend  
          ld    hl,ufia2+5  
          call  clfiln  
          call  getstr  
          jr    z,copy34  
copy31:   call  errorn  
          db    43 ;bad filename  
copy34:   ld    hl,ufia+5  
          call  clfiln  
          call  getstr  
          jr    nz,copy31  
;Okay, have our 2 files now....
;Open the original file
          ld    ix,ufia  
          call  rdopen  
          ld    a,(ix+4)  
          ld    (ufia2+4),a  
          ld    hl,ufia2+15  
          ld    b,9  
copy32:   call  rdbyte  
          ld    (hl),a  
          inc   hl  
          djnz  copy32  
          ld    ix,ufia2  
          call  wropen  
          ld    de,(rdfsec)  
          call  sros  
          ld    bc,(ufia2+16)  
copy33:   call  rdbyte  
          call  wrbyte  
          dec   bc  
          ld    a,b  
          or    c  
          jr    nz,copy33  
          jp    wrclos  
;      ret
;      jp   runexe
          
;Confirm for prompt...
          
confim:   set   5,(iy+2)  
          call  rom3  
          dw    15D4h ; wait key  
confi1:   ld    a,(23560)  
          and   223  
          cp    'Y'  
          ret   
          
;Get a +3 drive number...
gp3drv:   ld    b,16  
          ld    de,namep3  
          ld    (gp3dr4),de  
gp3dr1:   ld    a,(de)  
          inc   de  
          cp    ':'  
          jr    nz,gp3dr3  
          ld    (gp3dr4),de  
          dec   de  
          dec   de  
          ld    a,(de)  
          call  ckdrv  
          ld    (de),a  
          inc   de  ;15/2/96  
          inc   de  ;  
          ld    hl,flags  
          res   5,(hl)  
          ld    a,(de)  
          cp    32  
          ret   nz  
          set   5,(hl)  
          ret   
gp3dr3:   djnz  gp3dr1  
          ret   
gp3dr4:   dw    0  
          
ckdrv:    and   223  
          cp    'A'  
          ret   z  
          cp    'M'  
          ret   z  
          call  errorn  
          db    78 ;invalid drv  
          
prdfin:   push  de  
          ld    a,255  
          ld    (23692),a  
          call  messag  
          defm  "D*:"
          db    255  
          pop   de  
          ld    bc,10  
          call  string  
          ld    a,6  
          jp    print  
prfiln:   ld    a,255  
          ld    (23692),a  
          ld    bc,16  
          ld    de,namep3  
          jp    string  
          
          
;Plus3 filename and header
namep3:   ds    16,32  
          db    255  
dhead:    ds    7,0  
pdname:   ds    10,0  
catnam:   ds    16,32  
          db    255  
copied:   db    0  
          
          
;Second ufia
ufia2:    ds    24,0  
          
;Clear a filename space
;Entry: hl=address
          
clfiln:   ld    b,10  
clfil1:   push  hl  
clfil2:   ld    (hl),32  
          inc   hl  
          djnz  clfil2  
          pop   hl  
          ret   
          
          
          
          
          
;Convert filename +D > +3
;Adjust filename here
nsort:    ld    hl,pdname  
          ld    c,10  
          ld    b,8  
          call  nsort1  
          ex    de,hl  
          push  bc  
          ld    hl,(gp3dr4)  
          ld    bc,8  
          add   hl,bc  
          pop   bc  
          ld    (hl),'.'  
          inc   hl  
          ex    de,hl  
          ld    b,3  
nsort2:   jp    nsort1  
;      ret
          
;Sort out filename
          
nsort1:   ld    a,(hl)  
          cp    127  
          jr    nc,nsort7  
          cp    32  
          jr    nc,nsort3  
          dec   c  
          ret   z  
nsort7:   ld    a,' '  
nsort3:   inc   hl  
          cp    '.'  
          jr    z,nsort8  
          ld    (de),a  
          inc   de  
nsort9:   dec   c  
          ret   z  
          djnz  nsort1  
          ret   
nsort8:   ld    a,c  
          cp    2  
          ret   nz  
          jr    nsort9  
          
;Adjust name +3 > +D
          
pdconv:   ld    hl,(gp3dr4)  
          ld    de,ufia+5  
adjust:   ld    bc,2573  
lback:    ld    a,(hl)  
          dec   c  
          jr    z,adok  
          inc   hl  
          cp    32  
          jr    nz,lok  
          jr    lback  
lok:      ld    (de),a  
          inc   de  
          djnz  lback  
          jr    adout  
adok:     ld    a,32  
adok1:    ld    (de),a  
          inc   de  
          djnz  adok1  
adout:    ld    hl,ufia+5  
;Check to remove trailing '.'
          ld    b,10  
adout1:   ld    a,(hl)  
          cp    '.'  
          jr    nz,adout2  
          inc   hl  
          ld    a,(hl)  
          cp    32  
          ret   nz  
          dec   hl  
          ld    (hl),32  
          ret   
adout2:   inc   hl  
          djnz  adout1
          ret

