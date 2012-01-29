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

unsigned long lastMillis = 0;

void setup()
{
  MANCHESTER.SetTxPin(TxPin); // sets the digital pin as output default 4
}//end of setup

void encodeAndSend()
{
  // Send data, encoded:
  // 4 bits: simple XOR checksum
  // 1 bit: 0
  // 1 bit: X reading present
  // 1 bit: Y reading present
  // 1 bit: Z reading present
  // 8 bits: X reading, if present
  // 8 bits: Y reading, if present
  // 8 bits: Z reading, if present
  unsigned char data[4] = {0,0,0,0};
  unsigned char idx = 1;
  
  for (unsigned char axis = 0; axis < 3; axis++)
  {
    if (resends[axis] > 0)
    {
      resends[axis]--;
      data[idx] = (unsigned char)(old[axis] >> 2);
      data[0] |= (1 << (2 - axis));
      idx++;
    }
  }
  
  if (idx == 1)
  {
    // Nothing to transmit
    return;
  }
  
  for (unsigned char i = 0; i < idx; i++)
    data[0] ^= (data[i] & 0xF0) ^ (data[i] << 4);

  MANCHESTER.TransmitBytes(idx, data);
}

void readReading(int pin, unsigned int axis)
{
  unsigned int reading = analogRead(pin);
  int diff = (int)reading - (int)old[axis];
  if (abs(diff) > 7)
  {
    resends[axis] = 3;
    old[axis] = reading;
  }
}

void loop()
{
  readReading(XPin, 0);
  readReading(YPin, 1);
  readReading(ZPin, 2);
  
  if (millis() > lastMillis + 8000)
  {
    resends[0]++;
    resends[1]++;
    resends[2]++;
    lastMillis = millis();
  }
  
  encodeAndSend();
}//end of loop
