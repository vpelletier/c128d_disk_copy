bs$ = chr$(157)
bs3$ = bs$ + bs$ + bs$
rem up to track xx (inclusive), max sector is yy
data 17, 20
data 24, 18
data 30, 17
data 35, 16
data 52, 20
data 59, 18
data 65, 17
data 70, 16
data  0, 0 : rem end marker
rem copy 256 bytes from logical file 1 to logical file 2
cp = 4096 : rem locate at $1000
data 162,   1      : rem 1000 a2 01    ldx #$01
data  32, 198, 255 : rem 1002 20 c6 ff jsr $ffc6 - chkin
data 162,   2      : rem 1005 a2 02    ldx #$02
data  32, 201, 255 : rem 1007 20 c9 ff jsr $ffc9 - ckout
data 160,   0      : rem 100a a0 00    ldy #$00
data  32, 207, 255 : rem 100c 20 cf ff jsr $ffcf - basin
data  32, 210, 255 : rem 100f 20 d2 ff jsr $ffd2 - bsout
data 200           : rem 1012 c8       iny
data 208, 247      : rem 1013 d0 f7    bne $100c
data  32, 204, 255 : rem 1015 20 cc ff jsr $ffcc - clrch
data  96           : rem 1018 60       rts
data  -1           : rem end marker
do : read a, b : loop while a : rem skip sector-per-track data
wp = cp
do
: read a
: if a < 0 then exit
: poke wp, a
: wp = wp + 1
loop
print "copy from   8" + bs3$;: input sd
print "       to   9" + bs3$;: input dd
open 3, sd, 15
open 4, dd, 15
print#4, "u9" : rem partial reset to read identifier string
input#4, a, a$, b, c
si = instr(a$, "sd2iec") or instr(a$, "uiec")
open 1, sd, 5, "#"
input#3, a, a$, b, c
if a then stop
open 2, dd, 6, "#"
input#4, a, a$, b, c
if a then stop
do
: print#3, "u1:5 0 36 0" : rem try reading second side first track
: input#3, a, a$, b, c
: if a = 0 then begin
:   ft = 70
:   print "double-sided input."
: bend: else begin
:   ft = 35
:   print "single-sided input."
: bend
: if si then begin
:   print "output image name": input dxx$
:   print#4, "cd" + dxx$
: bend
: do
:   print#4, "u1:6 0"; ft; 0
:   input#4, a, a$, b, c
:   if a = 0 then exit
:   print "not enough space. retry   y" + bs3$;: input a$
:   if a$ <> "y" then stop
: loop
: restore
: tr = 1
: print#4, "b-p 6 0"
: do while tr < ft
:   read mt, ms
:   if mt = 0 then exit
:   for tr = tr to mt
:     for se = 0 to ms
:       print ".";
:       print#3, "u1:5 0" + str$(tr) + str$(se)
:       input#3, a, a$, b, c
:       if a = 0 then begin
:         sys cp
:         print#4, "u2:6 0" + str$(tr) + str$(se)
:         input#4, a, a$, b, c
:         if a <> 0 then begin
:           print chr$(13) + "write error at"; tr; se; ":"; a
:           stop
:         bend
:       bend: else begin
:         print chr$(13) + "read error at"; tr; se; ":"; a
:       bend
:     next se
:   next tr
: loop
: if si then print#4, "cd_"
: print chr$(10) + chr$(13) + "again   y" + bs3$;: input a$
loop while a$ = "y"
close 4
close 3
