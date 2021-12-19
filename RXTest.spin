CON

    _clkmode = xtal1+pll16x
    _xinfreq = 5_000_000

VAR

    long _rxcnt

OBJ

    com : "com.serial.terminal"                 ' remote device
    ser : "com.serial.terminal.ansi"            ' debug/terminal output
    time: "time"

PUB Main{} | rx, s, e, emax

    ser.startrxtx(31, 30, 0, 115_200)
    com.startrxtx(23, 22, 0, 19200)             ' 19200 max SPIN, 115.2k+ PASM
    time.msleep(30)
    ser.clear
    _subpsz := 1024
    longfill(@_f_sz, 0, 6)

    ser.strln(string("Waiting for transfer..."))
    repeat until (zgethdr{} == ZRQINIT)

    zmtx_hexheader(ZRINIT, CANFC32 << 24)

    if (getfileinfo{} == ZFILE)
        ser.printf1(string("Filename: %s\n"), @_f_name)
        ser.printf1(string("Size    : %u\n"), _f_sz)
    else
        ser.strln(string("error: wrong frame type or bad CRC"))
        repeat 8
            char(CAN)
        repeat                                  ' halt

    ser.printf1(string("frame type: %x\n"), zmrx_frameend{})

    zmtx_hexheader(ZRPOS, 0)

    repeat until (zgethdr == ZDATA)

    _rxcnt := 0
    repeat
        _crc32 := $ffff_ffff
        bytefill(@_rxbuff, 0, 2048)
        repeat
            s := cnt
            rx := zdlread
            e := cnt-s
            emax := emax #> e
            if (rx == GOTCAN)
                ser.strln(string("TRANSFER CANCELLED - HALTING"))
                repeat
            elseif (rx & GOTOR)
                updcrc32(rx & $ff)
                quit
            else
                _rxcnt++
                updcrc32(rx)
        ser.position(0, 9)
        ser.printf2(string("Received: %d / %d bytes\n"), _rxcnt, _f_sz)
        ser.printf2(string("zdlread() last call %dus, worst %dus\n"), e/80, emax/80)
        if checkcrc == ERROR
            ser.strln(string("bad subpacket CRC"))
'            zmtx_hexheader(ZNAK, _rxcnt)        ' XXX what to do here?
'            ser.hex(zgethdr, 8)
    until (rx & $ff) == ZCRCE                   ' last frame received

    repeat until zgethdr == ZEOF
    zmtx_hexheader(ZRINIT, CANFC32 << 24)

    repeat until zgethdr == ZFIN
    zmtx_hexheader(ZFIN, 0)
    repeat 2
        repeat until charin == "O"              ' Over and Out

    ser.strln(string("Transfer complete"))

    repeat

PUB Char(ch)

    com.char(ch)

PUB CharIn{}: ch

    return com.charin{}

#include "common.zmodem.spinh"
#include "protocol.file-xfer.zmodem.spinh"

