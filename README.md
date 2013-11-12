PRESENT cipher Arduino sketch
=============================

An Arduino sketch running my [size-optimized assembly implementation](https://github.com/aczid/ru_crypto_engineering) of the [PRESENT cipher](http://en.wikipedia.org/wiki/PRESENT_%28cipher%29).
Made for use with [Ino](http://inotool.org/).
Ino requires a patch to support .S files, which is included, after which you can run:

    ino build
    ino upload

Other ciphers on the Arduino
============================

If you want to play around with cryptography on your Arduino, you should know our PRESENT implementations are modelled after the [implementations of lightweight block ciphers](http://perso.uclouvain.be/fstandae/lightweight_ciphers/) done by researchers at the University of Louvain, and uses the same calling convention.
You should be able to use any of their implementations with this sketch after converting from Atmel to GNU syntax. (The [awfully lazy Atmel to GNU script](https://gist.github.com/aczid/7423399) I used here may help a bit.)

**If you just need some cryptography recipe without getting into the details, you are probably better off with [NaCl](http://cryptojedi.org/crypto/).**

Disclaimer
==========

This sketch is provided as a proof-of-concept, showing that the implementation works on hardware.
Don't take this as anything more than entertainment.

The configured key will end up in the compiled Arduino firmware file and is loaded into SRAM when the Arduino starts up.
It is then transfered from SRAM to the MCU registers for every encryption call.
Obviously a more secure implementation would never let the key exist anywhere besides MCU registers but these would have to be reserved, probably ruling out using libc or anything else from the Arduino framework.

