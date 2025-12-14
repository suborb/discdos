;       Simple booter for DiSCDOS
;
;
;       Rewritten 26/10/98 



        org     32768

        jp      bootin

;       Restore original block in printer buffer


        di
        ld      bc,32765
        push    bc
        ld      a,16
        out     (c),a
        xor     a
        ld      bc,8189
        push    bc
        out     (c),a
        ld      hl,189
        ld      de,23296
        ld      bc,82
        ldir
        ld      a,(23399)
        pop     bc
        out     (c),a
        pop     bc
        ld      a,(23388)
        out     (c),a
        ei
        ret

bootin:
        di
        ld      bc,32765
        ld      a,23
        ld      (23388),a
        out     (C),a
        ld      hl,discdos
        ld      de,49152
        ld      bc,6912
        ldir
        ei
        call    49152
        di
        ld      bc,32765
        ld      a,16
        ld      (23388),a
        out     (c),a
        ei
        ret

discdos:
	BINARY "dosblok.bin"


        


