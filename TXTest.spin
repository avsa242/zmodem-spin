{
    --------------------------------------------
    Filename: TXTest.spin
    Author: Jesse Burt
    Description: ZModem transmit from Propeller test
        Send a file 'p1rom.bin' containing the
        Propeller's ROM to the remote device
    Copyright (c) 2021
    Started Nov 28, 2021
    Updated Dec 19, 2021
    See end of file for terms of use.
    --------------------------------------------
}
CON

    _clkmode = xtal1+pll16x
    _xinfreq = 5_000_000

OBJ

    com : "com.serial.terminal"                 ' remote device
    ser : "com.serial.terminal.ansi"            ' debug/terminal output
    time: "time"

pub main | ptr_data, st_pos, frm_end, xfer, pos

    ser.startrxtx(31, 30, 0, 115_200)
    com.startrxtx(23, 22, 0, 115200)
    time.msleep(30)
    ser.clear
    _subpsz := 1024

    bytemove(@_f_name, string("p1rom.bin"), 9)
    _f_sz := 32768
    ptr_data := $8000                           ' P1 ROM start
    st_pos := 0

    ser.printf1(string("Filename: %s\n"), @_f_name)
    ser.printf1(string("Size    : %u\n"), _f_sz)
    zmtx_hexheader(ZRQINIT, 0)
    repeat until (zgethdr{} == ZRINIT)
        ser.strln(string("got ZRINIT"))

    _txflags[ZF0] := 0
    _txflags[ZF1] := 0
    _txflags[ZF2] := 0
    _txflags[ZF3] := 0
    zmtx_binheader(ZBIN32, ZFILE, @_txflags)
    zmtx_fileinfo

    repeat until (zgethdr{} == ZRPOS)
        ser.strln(string("got ZRPOS"))

    zmtx_binheader(ZBIN32, ZDATA, @st_pos)      ' start position

    repeat pos from st_pos to (_f_sz-1) step _subpsz
        if pos < (_f_sz-_subpsz)                ' before last subpacket?
            frm_end := ZCRCQ                    ' Q: ACK, G: no ACK
        else
            frm_end := ZCRCE                    ' frame ends
        xfer += zmtx_datasubpkt(ptr_data, pos, _subpsz, frm_end)
        if (frm_end == ZCRCQ)
            if zgethdr{} <> ZACK
                ser.fgcolor(ser#red)
                ser.strln(string("error from receiver - aborting"))
                ser.fgcolor(ser#white)
                repeat
        ser.position(0, 3)
        ser.printf2(string("transferred %d/%d bytes\n"), xfer, _f_sz)
 
    zmtx_binheader(ZBIN32, ZEOF, @_f_sz)

    repeat until (zgethdr{} == ZRINIT)

    zmtx_hexheader(ZFIN, 0)

    repeat until (zgethdr{} == ZFIN)

    ser.strln(string("Transfer complete"))
    char("O")                                   ' over and out
    char("O")
    repeat

PUB Char(ch)

    com.char(ch)

PUB CharIn: ch

    return com.charin

#include "core.con.zmodem.spinh"
#include "protocol.file-xfer.zmodem.spinh"

