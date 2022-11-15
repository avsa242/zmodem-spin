{
    --------------------------------------------
    Filename: RXTest.spin2
    Author: Jesse Burt
    Description: ZModem receive to Propeller test
        (file data only received; not saved)
    Copyright (c) 2022
    Started Nov 28, 2021
    Updated Nov 15, 2022
    See end of file for terms of use.
    --------------------------------------------
}

CON

    _clkmode    = xtal1+pll16x
    _xinfreq    = 5_000_000

VAR

    long _rxcnt

OBJ

    com : "com.serial.terminal"                 ' remote device
    ser : "com.serial.terminal.ansi"            ' debug/terminal output
    time: "time"

PUB main{} | rx, s, e, emax, t2us

    t2us := clkfreq / 1_000_000
    ser.startrxtx(31, 30, 0, 115_200)
    com.startrxtx(23, 22, 0, 115_200)           ' 19200 max SPIN, 115.2k+ PASM
    time.msleep(30)
    ser.clear
    _subpsz := 1024
    longfill(@_f_sz, 0, 6)

    ser.strln(string("Waiting for transfer..."))
    repeat until (zget_hdr{} == ZRQINIT)

    zmtx_hex_header(ZRINIT, CANFC32 << 24)

    if (get_file_info{} == ZFILE)
        ser.printf1(string("Filename: %s\n"), @_f_name)
        ser.printf1(string("Size    : %u\n"), _f_sz)
    else
        ser.strln(string("error: wrong frame type or bad CRC"))
        repeat 8
            putchar(CAN)
        repeat                                  ' halt

    ser.printf1(string("frame type: %x\n"), zmrx_frame_end{})

    zmtx_hex_header(ZRPOS, 0)

    repeat until (zget_hdr{} == ZDATA)

    _rxcnt := 0
    repeat
        _crc32 := $ffff_ffff
        bytefill(@_rxbuff, 0, 2048)
        repeat
            s := cnt
            rx := zdl_read{}
            e := cnt-s
            emax := emax #> e
            if (rx == GOTCAN)
                ser.strln(string("TRANSFER CANCELLED - HALTING"))
                repeat
            elseif (rx & GOTOR)
                upd_crc32(rx & $ff)
                quit
            else
                _rxcnt++
                upd_crc32(rx)
        ser.pos_xy(0, 9)
        ser.printf2(string("Received: %d / %d bytes\n\r"), _rxcnt, _f_sz)
        ser.printf2(string("zdlread() last call %dus, worst %dus\n\r"), e/t2us, emax/t2us)
        if (check_crc{} == ERROR)
            ser.strln(string("bad subpacket CRC"))
    until ((rx & $ff) == ZCRCE)                 ' last frame received

    repeat until (zget_hdr{} == ZEOF)
    zmtx_hex_header(ZRINIT, CANFC32 << 24)

    repeat until (zget_hdr{} == ZFIN)
    zmtx_hex_header(ZFIN, 0)
    repeat 2
        repeat until (getchar{} == "O")         ' over and out

    ser.strln(string("Transfer complete"))

    repeat

PUB putchar(ch)

    com.putchar(ch)

PUB getchar{}: ch

    return com.getchar{}

#include "zmodem.common.spinh"
#include "protocol.file-xfer.zmodem.spinh"

DAT
{
Copyright 2022 Jesse Burt

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute,
sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or
substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT
OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
}

