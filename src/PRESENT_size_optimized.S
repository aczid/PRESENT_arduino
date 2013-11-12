# This version was mostly converted from Atmel to GNU syntax using a very ugly
# one-off Python script (https://gist.github.com/aczid/7423399)
# which also strips comments.
# For the original version with comments and documentation see:
# https://github.com/aczid/ru_crypto_engineering

# Copyright (c) 2013 Aram Verstegen

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

.global encrypt
.set ENCRYPTION, 1
#.global decrypt
#.set DECRYPTION, 1
.set RELOCATABLE_SBOXES, 1
# Must align this section to a 256-byte address for this to work
#.ifdef DECRYPTION
#.set PACKED_SBOXES, 1
#.endif
#.ifdef PACKED_SBOXES
#.set QUANTIZE_TIMING, 1
#.endif
ROUNDS = 31
.ifdef PACKED_SBOXES
.ifndef RELOCATABLE_SBOXES
.org 256
.endif
SBOX:   .byte 0xc5,0x6b,0x90,0xad,0x3e,0xf8,0x47,0x12
.ifdef DECRYPTION
.ifndef RELOCATABLE_SBOXES
.org 512
.endif
INVSBOX:.byte 0x5e,0xf8,0xc1,0x2d,0xb4,0x63,0x07,0x9a
.endif
.else
.ifndef RELOCATABLE_SBOXES
.org 256
.endif
SBOX:   .byte 0xc,0x5,0x6,0xb,0x9,0x0,0xa,0xd,0x3,0xe,0xf,0x8,0x4,0x7,0x1,0x2
.ifdef DECRYPTION
.ifndef RELOCATABLE_SBOXES
.org 512
.endif
INVSBOX:.byte 0x5,0xe,0xf,0x8,0xc,0x1,0x2,0xd,0xb,0x4,0x6,0x3,0x0,0x7,0x9,0xa
.endif
.endif
.macro schedule_key_macro
inc r20
ldi r24, 6
rcall rotate_left_i
eor r4, r20
ldi r24, 55
rcall rotate_left_i
mov r24, r0
.ifdef PRESENT_128
rcall sBoxByte
.else
rcall sBoxHighNibble
.endif
mov r0, r24
cpi r20, ROUNDS
.endm
.macro addRoundKey_macro
clr r28
addRoundKey_byte:
ld r24, X
ld r22, Y+
eor r24, r22
st X+, r24
cpi r28, 8
brne addRoundKey_byte
subi r26, 8
.endm
rotate_left_i:
.ifdef FAST_ROTATE
.ifdef PRESENT_128
lsl r15
rol r14
rol r13
rol r12
rol r11
rol r10
rol r9
.else
lsl r9
.endif
rol r8
rol r7
rol r6
rol r5
rol r4
rol r3
rol r2
rol r1
rol r0
.else
.ifdef PRESENT_128
ldi r28, 16
.else
ldi r28, 10
.endif
clc
rotate_left_i_bit:
ld r25, -Y
rol r25
st Y, r25
cpse r28, r29
rjmp rotate_left_i_bit
.endif
.ifdef PRESENT_128
adc r15, r29
.else
adc r9, r29
.endif
dec r24
brne rotate_left_i
ret
sBoxByte:
rcall sBoxLowNibbleAndSwap
rjmp sBoxLowNibbleAndSwap
sBoxHighNibble:
swap r24
sBoxLowNibbleAndSwap:
mov r30, r24
cbr r30, 0xf0
.ifdef RELOCATABLE_SBOXES
add r30, r23
.endif
.ifdef PACKED_SBOXES
asr r30
.endif
lpm r21, Z
.ifdef PACKED_SBOXES
brcs odd_unpack
even_unpack:
swap r21
.ifdef QUANTIZE_TIMING
rjmp unpack
.endif
odd_unpack:
.ifdef QUANTIZE_TIMING
nop
nop
.endif
unpack:
cbr r21, 0xf0
.endif
cbr r24, 0xf
or r24, r21
swap r24
ret
.macro sBoxLayer_macro
ldi r22, 8
sBoxLayer_byte:
ld r24, X
rcall sBoxByte
st X+, r24
dec r22
brne sBoxLayer_byte
subi r26, 8
.endm
pLayerNibble:
ror r24
ror r16
ror r24
ror r17
ror r24
ror r18
ror r24
ror r19
ret
.macro pLayer_macro
set
adiw r26, 8
continue_pLayerHalf:
ldi r22, 4
pLayerHalf_byte:
ld r24, -X
rcall pLayerNibble
rcall pLayerNibble
dec r22
brne pLayerHalf_byte
push r19
push r18
push r17
push r16
brtc pLayerOutput
clt
rjmp continue_pLayerHalf
pLayerOutput:
adiw r26, 7
continue_pLayerOutput:
ldi r22, 4
pLayerOutput_byte:
pop r24
st -X, r24
dec r26
dec r22
brne pLayerOutput_byte
brts pLayer_done
set
adiw r26, 9
rjmp continue_pLayerOutput
pLayer_done:
.endm
.macro setup_macro
clr r20
ldi r31, hi8(pm(SBOX))
.ifdef RELOCATABLE_SBOXES
.ifdef PACKED_SBOXES
ldi r23, lo8(pm(SBOX))
lsl r23
lsl r23
.else
ldi r23, lo8(pm(SBOX))
lsl r23
.endif
.endif
adiw r26, 8
clr r29
clr r28
load_key:
.ifdef rZERO_KEY
ld r24, X
st X+, r29
.else
ld r24, X+
.endif
st Y+, r24
.ifdef PRESENT_128
cpi r28, 16
.else
cpi r28, 10
.endif
brne load_key
.ifdef PRESENT_128
subi r26, 24
.else
subi r26, 18
.endif
.endm
.ifdef ENCRYPTION 
.ifdef DECRYPTION
schedule_key:
schedule_key_macro
ret
sBoxLayer:
sBoxLayer_macro
ret
setup:
setup_macro
ret
.endif
.endif
.ifdef ENCRYPTION
encrypt:
.ifndef DECRYPTION
setup_macro
.else
rcall setup
.endif
encrypt_update:
rcall addRoundKey
.ifndef DECRYPTION
sBoxLayer_macro
pLayer_macro
schedule_key_macro
.else
rcall sBoxLayer
rcall pLayer
rcall schedule_key
.endif
brne encrypt_update
addRoundKey:
addRoundKey_macro
ret
.endif
.ifdef DECRYPTION
pLayer:
pLayer_macro
ret
decrypt:
.ifndef ENCRYPTION
setup_macro
.else
rcall setup
.endif
schedule_last_key:
.ifndef ENCRYPTION
schedule_key_macro
.else
rcall schedule_key
.endif
brne schedule_last_key
ldi r31, hi8(pm(INVSBOX))
.ifdef RELOCATABLE_SBOXES
.ifdef PACKED_SBOXES
ldi r23, lo8(pm(INVSBOX))
lsl r23
lsl r23
.else
ldi r23, lo8(pm(INVSBOX))
lsl r23
.endif
.endif
decrypt_update:
rcall addRoundKey
rcall pLayer
rcall pLayer
.ifndef ENCRYPTION
sBoxLayer_macro
.else
rcall sBoxLayer
.endif
inv_schedule_key:
mov r24, r0
.ifdef PRESENT_128
rcall sBoxByte
.else
rcall sBoxHighNibble
.endif
mov r0, r24
.ifdef PRESENT_128
ldi r24, 1
rcall rotate_left_i
eor r13, r20
ldi r24, 66
rcall rotate_left_i
.else
ldi r24, 17
rcall rotate_left_i
eor r5, r20
ldi r24, 2
rcall rotate_left_i
.endif
dec r20
brne decrypt_update
.ifndef ENCRYPTION
addRoundKey:
addRoundKey_macro
ret
.else
rjmp addRoundKey
.endif
.endif
