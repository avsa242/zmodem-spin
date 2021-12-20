# zmodem-spin
-------------

This is a P8X32A/Propeller, P2X8C4M64P/Propeller 2 object for the ZModem file transfer protocol

**IMPORTANT**: This software is meant to be used with the [spin-standard-library](https://github.com/avsa242/spin-standard-library) (P8X32A) or [p2-spin-standard-library](https://github.com/avsa242/p2-spin-standard-library) (P2X8C4M64P). Please install the applicable library first before attempting to use this code, otherwise you will be missing several files required to build the project.

## Salient Features

* Transmit/send files from Propeller to remote device
* Integration with any terminal I/O driver that provides Char() and CharIn()

## Requirements

P1/SPIN1:
* spin-standard-library
* A terminal I/O driver that provides transmit (Char()) and receive (CharIn()) methods

P2/SPIN2:
* p2-spin-standard-library

## Compiler Compatibility

* P1/SPIN1 OpenSpin (bytecode): OK, tested with 1.00.81 (build only)
* P1/SPIN1 FlexSpin (bytecode): OK, tested with 5.9.4-beta
* P1/SPIN1 FlexSpin (native): OK, tested with 5.9.4-beta
* ~~P2/SPIN2 FlexSpin (bytecode): FTBFS, tested with 5.9.4-beta~~
* ~~P2/SPIN2 FlexSpin (native): OK, tested with 5.9.4-beta~~
* ~~BST~~ (incompatible - no preprocessor)
* ~~Propeller Tool~~ (incompatible - no preprocessor)
* ~~PNut~~ (incompatible - no preprocessor)

## Limitations

* Very early in development - may malfunction, or outright fail to build
* API not finalized
* Currently only supports a subset of ZModem's features; doesn't support frame types ZSINIT, ZSKIP, ZNAK, ZABORT, ZFERR, ZCRC, ZCHALLENGE, ZCOMPL, ZCAN, ZFREECNT, ZCOMMAND, ZSTDERR
* Doesn't handle Telenet-specific command escape
* Nothing is timeout-protected (yet), so if expected data isn't received, it __will wait forever__.
* ZFILE frames: All file information besides filename and size are effectively ignored
* Not optimized:

P1:
|Link Rate	|Thruput (bytecode)	| Thruput (native)	|
|---------------|-----------------------|-----------------------|
| 19200		| 18.9kbps (RX)		| 18.9kbps (RX)   	|
|		| 16.8kbps (TX)		| 16.8kbps (TX)	  	|
|               |                       |                 	|
| 38400		| N/A (RX - fail (1))	| 37.5kbps (RX)	  	|
|		| 18.8kbps (TX)		| 32.7kbps (TX)	  	|
|               |                       |                 	|
| 115200	| N/A (RX - fail (1))	| 110.95kbps (RX) 	|
|		| 18.8kbps (TX)		| 8.7kbps (TX)    	|
|---------------|-----------------------|-----------------------|
(1): The sender keeps streaming, regardless, and the Prop can't keep up at this speed or faster when built to bytecode, so misses frames

P2:
|Link Rate      |Thruput (bytecode)     | Thruput (native)	|
|---------------|-----------------------|-----------------------|
| 19200         | 00.0kbps (RX)         | 18.9kbps (RX)   	|
|               | 00.0kbps (TX)         | 17.7kbps (TX)   	|
|               |                       |                 	|
| 38400         | N/A (RX - fail (1))   | 37.6kbps (RX)   	|
|               | 18.8kbps (TX)         | 00.0kbps (TX)   	|
|               |                       |                 	|
| 115200        | N/A (RX - fail (1))   | N/A (RX - fail	|
|               | 00.0kbps (TX)         | 0.0kbps (TX)    	|
|---------------|-----------------------|-----------------------|

