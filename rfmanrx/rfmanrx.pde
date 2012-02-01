#include <MANCHESTER.h>

#define RxPin 4

#define PowerClkPin 2
#define PowerDataPin 3

//#define ACCEL_DBG
//#define POWER_DBG

unsigned char current[3] = {0,0,0};
unsigned int avg[3] = {0x8000, 0x8000, 0x8000};
unsigned char numReadings[3] = {0,0,0};

unsigned char power = 40;


void setup()
{
  delay(1000);  // Try to avoid sending debug when being reprogrammed.
 MANCHESTER.SetRxPin(RxPin); //user sets rx pin default 4
 MANCHESTER.SetTimeOut(200); //user sets timeout default blocks
 
 pinMode(PowerClkPin, OUTPUT);
 pinMode(PowerDataPin, OUTPUT);
 digitalWrite(PowerClkPin, LOW);
 
 Serial.begin(57600); // Debugging only
}//end of setup

void writeByte(unsigned char data)
{
  // Note that the Arduino functions are slow enough
  // that they introduce enough delay for the FPGA
  // to pick up the changes (even with debounce)
  // with no delays here.  
  digitalWrite(PowerClkPin, HIGH);
  digitalWrite(PowerClkPin, LOW);

  for (int i = 0; i < 8; i++) 
  {
    digitalWrite(PowerDataPin, (data & (1<<i)) ? HIGH : LOW);
    digitalWrite(PowerClkPin, HIGH);
    digitalWrite(PowerClkPin, LOW);
  }      
}

void sendData()
{
#ifdef POWER_DBG
  Serial.print(" P=");
  Serial.println(power, DEC);
#endif

  writeByte(power);
  for (byte i = 0; i < 3; i++)
    writeByte(current[i]);
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
#ifdef ACCEL_DBG
        Serial.print(" X=");
        Serial.print(data[idx], DEC);
#endif
        readReading(0, data[idx]);
#ifdef ACCEL_DBG
        Serial.print(",");
        Serial.print(avg[0] >> 8, DEC);
#endif
        idx++;
      }
      if (data[0] & 0x2)
      {
#ifdef ACCEL_DBG
        Serial.print(" Y=");
        Serial.print(data[idx], DEC);
#endif
        readReading(1, data[idx]);
#ifdef ACCEL_DBG
        Serial.print(",");
        Serial.print(avg[1] >> 8, DEC);
#endif
        idx++;
      }
      if (data[0] & 0x1)
      {
#ifdef ACCEL_DBG
        Serial.print(" Z=");
        Serial.print(data[idx], DEC);
#endif
        readReading(2, data[idx]);
#ifdef ACCEL_DBG
        Serial.print(",");
        Serial.print(avg[2] >> 8, DEC);
#endif
        idx++;
      }
#ifdef ACCEL_DBG
#ifndef POWER_DBG
        Serial.println("");
#endif
#endif
    }
    else 
    {
      Serial.print("Bad ");
      Serial.println(check, HEX);
    }
  }
  else if (bytesRcvd == 1) 
    Serial.println(data[0], HEX);

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
    if (power < 40)
      power += 10;
    else
      power += 4;
  }
  else if (maxDiff > 20)
    power = 40;
  else if (maxDiff > 10 && power > 80)
    power -= 4;
  sendData();

}//end of loop
