PRESENT cipher Arduino sketch
=============================

An Arduino sketch running my [size-optimized assembly implementation](https://github.com/aczid/ru_crypto_engineering) of the [PRESENT cipher](http://en.wikipedia.org/wiki/PRESENT_%28cipher%29).
Made for use with [Ino](http://inotool.org/).
Ino requires a patch to support .S files, which is included, after which you can run:

    ino build
    ino upload

Disclaimer
==========

This sketch is provided as a proof-of-concept, showing that the implementation works on hardware.
Don't take this as anything more than entertainment.

The configured key will end up in the compiled Arduino firmware file and is loaded into SRAM when the Arduino starts up.
It is then transfered from SRAM to the MCU registers for every encryption call.
Obviously a more secure implementation would never let the key exist anywhere besides MCU registers but these would have to be sacrificed, possibly ruling out using libc.

