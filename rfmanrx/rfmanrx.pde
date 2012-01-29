#include <MANCHESTER.h>

#define RxPin 4

#define PowerClkPin 2
#define PowerDataPin 3

unsigned char current[3] = {0,0,0};
unsigned int avg[3] = {0x8000, 0x8000, 0x8000};
unsigned char numReadings[3] = {0,0,0};

unsigned char power = 60;


void setup()
{
 MANCHESTER.SetRxPin(RxPin); //user sets rx pin default 4
 MANCHESTER.SetTimeOut(200); //user sets timeout default blocks
 
 pinMode(PowerClkPin, OUTPUT);
 pinMode(PowerDataPin, OUTPUT);
 digitalWrite(PowerClkPin, LOW);
 
 Serial.begin(115200); // Debugging only
}//end of setup

void setPower(unsigned char power)
{
  Serial.print(" P=");
  Serial.println(power, DEC);
  
  digitalWrite(PowerClkPin, HIGH);
  delayMicroseconds(2);
  digitalWrite(PowerClkPin, LOW);

  for (int i = 0; i < 8; i++) 
  {
    digitalWrite(PowerDataPin, (power & (1<<i)) ? HIGH : LOW);
    delayMicroseconds(2);
    digitalWrite(PowerClkPin, HIGH);
    delayMicroseconds(2);
    digitalWrite(PowerClkPin, LOW);
  }    
}

void readReading(unsigned char axis, unsigned char reading)
{
  current[axis] = reading;
  unsigned long newAvg = ((unsigned long)avg[axis]) * ((unsigned long)numReadings[axis]) + ((unsigned long)reading << 8);
  numReadings[axis]++;
  avg[axis] = (unsigned int)(newAvg / numReadings[axis]);
  
  // Avoid overflow.
  if (numReadings[axis] > 20)
    numReadings[axis] = 20;
}

void loop()
{
  // Receive data from RF, encoded:
  // 4 bits: simple XOR checksum
  // 2 bits: axis: 0 = X, 1 = Y, 2 = Z
  // 10 bits: reading
  unsigned char data[4];
  unsigned char bytesRcvd = MANCHESTER.ReceiveBytes(4, data);
  
  if (bytesRcvd >= 2)
  {
    unsigned char check = 0;
    for (unsigned char i = 0; i < bytesRcvd; i++)
    {
      check ^= (data[i] & 0xF) ^ (data[i] >> 4);
    }
    
    if (check == 0x0)
    {
      // Checksum OK, extract data
      unsigned char idx = 1;
      if (data[0] & 0x4)
      {
        Serial.print(" X=");
        Serial.print(data[idx], DEC);
        readReading(0, data[idx]);
        Serial.print(",");
        Serial.print(avg[0] >> 8, DEC);
        idx++;
      }
      if (data[0] & 0x2)
      {
        Serial.print(" Y=");
        Serial.print(data[idx], DEC);
        readReading(1, data[idx]);
        Serial.print(",");
        Serial.print(avg[1] >> 8, DEC);
        idx++;
      }
      if (data[0] & 0x1)
      {
        Serial.print(" Z=");
        Serial.print(data[idx], DEC);
        readReading(2, data[idx]);
        Serial.print(",");
        Serial.print(avg[2] >> 8, DEC);
        idx++;
      }
    }
    else 
    {
      Serial.print("Bad ");
      Serial.println(check, HEX);
    }
  }

  unsigned char maxDiff = 0;
  for (unsigned char i = 0; i < 3; i++)
  {
    int diff = (int)current[i] - (int)(avg[i] >> 8);
    if (i == 2) diff >>= 1;
    unsigned char thisDiff = (unsigned char)abs(diff);
    if (thisDiff > maxDiff) maxDiff = thisDiff;
  }

  if (maxDiff < 5 && power < 240)
  {
    if (power < 120)
      power += 10;
    else
      power += 4;
  }
  else if (maxDiff > 20)
    power = 80;
  else if (maxDiff > 10 && power > 80)
    power -= 4;
  setPower(power);

}//end of loop
