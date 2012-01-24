#include <MANCHESTER.h>

// ATTiny85:
// u
// Reset (1) (8) VCC
// P3 (A3) (2) (7) P2 (A1)
// P4 (A2) (3) (6) P1 (PWM)
// GND (4) (5) P0 (PWM)

#define TxPin 1 //the digital pin to use to transmit data
#define XPin A1
#define YPin A2
#define ZPin A3

unsigned int old[3] = {0, 0, 0};

byte resends[3] = {0, 0, 0};

void setup()
{
  MANCHESTER.SetTxPin(TxPin); // sets the digital pin as output default 4
}//end of setup

void encodeAndSend(unsigned int axis, unsigned int reading)
{
  // Send data, encoded:
  // 4 bits: simple XOR checksum
  // 2 bits: axis: 0 = X, 1 = Y, 2 = Z
  // 10 bits: reading
  unsigned int data = 0xF000 | ((axis << 10) & 0xC00) | (reading & 0x3FF);
  data ^= (data << 4) & 0xF000;
  data ^= (data << 8) & 0xF000;
  data ^= (data << 12) & 0xF000;
  MANCHESTER.Transmit(data);
}

void readAndSend(int pin, unsigned int axis)
{
  unsigned int reading = analogRead(pin);
  int diff = (int)reading - (int)old[axis];
  if (abs(diff) > 9)
  {
    resends[axis] = 3;
    old[axis] = reading;
  }
  if (resends[axis] > 0)
  {
    encodeAndSend(axis, old[axis]);
    resends[axis]--;
  }
}

void loop()
{
  readAndSend(XPin, 0);
  readAndSend(YPin, 1);
  readAndSend(ZPin, 2);
}//end of loop
