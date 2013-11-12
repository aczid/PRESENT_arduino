#include "PRESENT_size_optimized.h"
#define highByte(w) ((uint8_t) ((w) >> 8))
#define lowByte(w) ((uint8_t) ((w) & 0xff))

static unsigned char encryption[24], key[10] = {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
char print_buf[18];
void setup() {
        Serial.begin(9600);
        Serial.println("PRESENT encrypter");
	memset(encryption, 0x0, 8);
	test_print();
}

// Manual prologue/epilog
void do_encryption(void){
		memcpy(encryption+8, key, 16);
		asm("push r31");
		asm("push r30");
		asm("push r29");
		asm("push r28");
		asm("push r27");
		asm("push r26");
		asm("push r25");
		asm("push r24");
		asm("push r23");
		asm("push r22");
		asm("push r21");
		asm("push r20");
		asm("push r19");
		asm("push r18");
		asm("push r17");
		asm("push r16");
		asm("push r15");
		asm("push r14");
		asm("push r13");
		asm("push r12");
		asm("push r11");
		asm("push r10");
		asm("push r9");
		asm("push r8");
		asm("push r7");
		asm("push r6");
		asm("push r5");
		asm("push r4");
		asm("push r3");
		asm("push r2");
		asm("push r1");
		asm("push r0");
		asm("mov r26, %0":: "l" (lowByte((unsigned int)encryption)));
		asm("mov r27, %0":: "l" (highByte((unsigned int)encryption)));
		encrypt();
		asm("pop r0");
		asm("pop r1");
		asm("pop r2");
		asm("pop r3");
		asm("pop r4");
		asm("pop r5");
		asm("pop r6");
		asm("pop r7");
		asm("pop r8");
		asm("pop r9");
		asm("pop r10");
		asm("pop r11");
		asm("pop r12");
		asm("pop r13");
		asm("pop r14");
		asm("pop r15");
		asm("pop r16");
		asm("pop r17");
		asm("pop r18");
		asm("pop r19");
		asm("pop r20");
		asm("pop r21");
		asm("pop r22");
		asm("pop r23");
		asm("pop r24");
		asm("pop r25");
		asm("pop r26");
		asm("pop r27");
		asm("pop r28");
		asm("pop r29");
		asm("pop r30");
		asm("pop r31");
}

void test_print(void){
		Serial.println("Plaintext:");
		sprintf(print_buf, "%02x%02x%02x%02x %02x%02x%02x%02x", encryption[0], encryption[1], encryption[2], encryption[3], encryption[4], encryption[5], encryption[6], encryption[7]);
		Serial.println(print_buf);

		do_encryption();

		Serial.println("Ciphertext:");
		sprintf(print_buf, "%02x%02x%02x%02x %02x%02x%02x%02x", encryption[0], encryption[1], encryption[2], encryption[3], encryption[4], encryption[5], encryption[6], encryption[7]);
		Serial.println(print_buf);
}

void loop() {
        while (Serial.available() > 0) {
		Serial.readBytesUntil('\n', (char*) encryption, 8);
		test_print();
        }
}

