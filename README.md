# DiSCDOS 

A BASIC extension for the Spectrum +3 to support reading/writing +D/DiSCIPLE discs using
the same BASIC commands as the hardware interface.

Discdos was written on a +3 using a modified version of the OCP Editor/Assembler. 

The files here have only been lightly modified:

* Extracted from disc
* Converted from OCP format to text
* Reformated with z88dk-asmstyle
* Pseudo directives updated


## BASIC Extension commands

List of available commands: (All paremeters in brackets are optional)

* `a(n)` = 16 bit number 
* `ddd` = drive no 1,2,* 
* `f`   = filename
* `n`   = Program number (1-80)
* `u1`  = source filename
* `u2`  = destination filename
* `ss`  = stream number

`CAT [#ss,]ddd[;"f"]`

Catalogues a disc, to stream ss (default is the screen), the file name may be wild. An abbreviated catalogue (listing only   the file names and free space on the disc) can be obtained by following the drive number with a "!"                                                                                        

`LOAD Dddd"f"`

Loads a file from the disc, all the usual BASIC extenstions may be used ie CODE,DATA,SCREEN$

`LOAD Pn`

Loads a file from its program number, the file can be any of the BASIC file types

`SAVE Dddd"f"`

Saves a file to the disc, as with load all the usual BASIC extensions can be used.

`MERGE Dddd"f"`

Merge a BASIC file on the disc with the one in memory.

`MERGE Pn`

Merge the BASIC file on the disc with the program number n with the one in memory

`VERIFY Dddd"f"` & `VERIFY Pn`

These commands do nothing and are just provided for compatibility

`ERASE Dddd"f"`

Erases a file from the disc. Wildcards can be used.

`ERASE Dddd"f1" TO "f2"`

Renames the f1 giving it the name f2.

`MOVE Dddd"f" TO #ss`

Moves the file f to the stream ss, please note that file filtering takes place - all character codes below 32 except for 13(LF) are ignored.                                                                                                             


`COPY Dddd"f1" TO Dddd"f2"`

Copies the file f1 to the file f2 on the +D disc. Please note nowildcards can be used.                                                                                                          


`COPY Dddd"f1" TO "f2"`

Copies the file named f1 on the +D disc to the file named f2 on the default +3 drive. f2 can be a drive in which case the original filename is kept, 
please note that sometimes this maycome back with Bad Filename error report, this is simply because the +3 has fewer characters which can be used in 
a filename. If f2 is a drive then f1 can contain wildcards.                                                                                    

`COPY "f1" to Dddd["f2"]`

Copies the file f1 on the default +3 drive to the file f2 on the+D disc. If f1 is wild then simply leave f2 out.                                                                                

`CLS #`

Clears the screen and resets the colours to white paper and border and black ink.                                                                                                           

`POKE @a1,a2`

Does a 16bit poke for the entire memory configuration (ROM3, pages 5,2,7). This command is provided purely for compatibilty  though it can be usefully used on a +3, 
try a POKE @60431,col   or POKE @60431,col to change the editing colours in the top and bottom of the screens.

`LOAD @ddd,ttt,sss,aaa`
`SAVE @ddd,ttt,sss,aaa`

These ommands are used for reading/writing to a specific track  and sector on the disc from memory:   

* `ddd` = drive number
* `ttt` = track number - side 1 (tracks 0 - 79), side 2 (128-207)
* `sss` = sector number (1-10)
* `aaa` = the address of the memory location for the sector RAM configuration is pages 5,2,0

## Supported Hook Codes

In this version Command Codes are emulated to a certain extent, however any existing disc conversions probably won't work. Unfortunately due to the actual design of ROM3 an exact emulation  would be impossible. But it is easy to adapt programs to workusing DISCDOS - and +D programmers can do this too - it won't affect the operation of a +D/DISCiPLE.   

In order for Command Codes to work the register sp must be stored somewhere (if you disassemble the standard ROM3 rst 8 code you'll see that sp is lost), the address that I've chosen  to store it is at 23411 - in the system variables (the current line being renumbered store). This address must be kept up to date with the sp before every rst 8 call ie immediately before  (DISCDOS has to know where to return to in the code right? Well, this is the only way to do it). There's another limitation, the register hl is always corrupted (feature of the rst 8 routine again)

again....).                                                                                                                     The following command codes are supported:                      (descriptions are quoted from the +D manual)                                                                                    

`HXFER 51 33h`

Transfers the users file information area (UFIA) to the Disc File Channel Area (DFCA). IX must point to the first byte for your UFIA.


 `OFSM  52 34h`
 
 Opens a File Sector map using the information in the DFCA. Sets the disc buffer pointer (RPT) to the start of the sector buffer,after setting the header information in the first 9 bytes of    the file.


`HOFLE 53 35h`

Open a file to write. IX must point to the UFIA. This command   combines the functions of HXFER and OFSM.

 `SBYT  54 36h`
 
 Write a byte to the file sector buffer. If the sector is full   the sector is saved and the RPT reset.

`HSVBK 55 37h`

Save a block of data to the disc. DE points to the start of the block, and BC holds the length of the data. 

`FSM  56 38h`

Close a file. This routine empties the disc buffer and writes   the directory entry. 

`HGFLE 59 3Bh`

Open a file to read from the disc. IX must point to the start   of your UFIA. When returned the RPT points to the first byte    of the file (usually the header information) 

`LBYT  60 3Ch`

Load a byte from the sector buffer, and return it in the A      register. If the buffer is empty another sector is read from    the disc. 

`HLDBK 61 3Dh`

Load a block of data from disc to memory address DE with block  length BC.

`WSAD  62 3Eh `

Write the contents of the buffer to track D, sector E. And reset the RPT to the start of the disc buffer.

`RSAD  63 3Fh` 

As WSAD except reading. 

`HERAZ 65 41h`

Erase the file on the disc using the information in UFIA (as    ever pointed to by IX) 

`PCAT  67 32h`

Catalogue the disc using the information in the UFIA (transfer  this using the HXFER. Make sure the drive and stream are set up. Byte +0Fh contains the following values:                                                                                   * 02h  - equivalent to CAT ! 
* 04h  - equivalent to CAT                                        
* 12h  - equivalent to CAT ! with a filename                      
* 14h  - equivalent to CAT with a filename 

The filename should be placed in UFIA+5, and may be wild.

`HRSAD 68 44h`

Read Sector to address (the same as BASIC LOAD @ command)

* A  = Drive
* DE = Track/Sector
* IX = Address to load to

`WSAD 69 45h`

 As HRSAD but write. 
 
 `PATCH 71 47h`
 
 Simply tells you what system you are using, on a +D/DISCiPLE returns with the shadow ROM paged in, but obviously impossible  for DISCDOS). The hl value is set to 0 (+D), 1 (DISCIPLE)or in the case of DISCDOS - 2.
 
### Command code Notes:

You can return to BASIC after using command code however the return value in bc is ignored. Actually I cheat on the return,  in order to ensure a crash doesn't result, I scan the stack for 2D2Bh (the return address for USR no) and when I find it    it is replaced with 23354 so control will be restored. I only   search the previous 10 values on the stack, which if you want   to return to BASIC should give you enough stack to play with.

The alternate registers are corrupted on exit. And if an error arises then return is made with carry set and a +D error code in a.

The memory configuration used for loading bytes is the same as that indicated by the address (23388) - keep it up to date!

## History

To be populated.


