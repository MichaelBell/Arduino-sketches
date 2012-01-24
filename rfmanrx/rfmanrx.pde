#include <MANCHESTER.h>

#define RxPin 4

unsigned int X = 0;
unsigned int Y = 0;
unsigned int Z = 0;
unsigned int oldX = 0;
unsigned int oldY = 0;
unsigned int oldZ = 0;

void setup()
{
 MANCHESTER.SetRxPin(RxPin); //user sets rx pin default 4
 MANCHESTER.SetTimeOut(1000); //user sets timeout default blocks
 Serial.begin(115200); // Debugging only
}//end of setup

void loop()
{
  // Receive data from RF, encoded:
  // 4 bits: simple XOR checksum
  // 2 bits: axis: 0 = X, 1 = Y, 2 = Z
  // 10 bits: reading
  unsigned int data = MANCHESTER.Receive();

  // Confirm checksum
  unsigned int check = (data & 0xF) ^ ((data >> 4) & 0xF) ^ ((data >> 8) & 0xF) ^ (data >> 12);
  if (check == 0xF)
  {
    // Checksum OK, extract data
    unsigned int axis = (data >> 10) & 0x3;
    unsigned int reading = data & 0x3FF;
    if (axis == 0)
    {
      X = reading;
      Serial.print("X");
    }
    else if (axis == 1)
    {
      Y = reading;
      Serial.print("Y");
    }
    else if (axis == 2)
    {
      Z = reading;
      Serial.print("Z");
    }
    if (oldX != X || oldY != Y || oldZ != Z)
    {
      Serial.print(X, DEC);
      Serial.print(" ");
      Serial.print(Y, DEC);
      Serial.print(" ");
      Serial.println(Z, DEC);  
      oldX = X;
      oldY = Y;
      oldZ = Z;
    }
  }
  else if (data != 0)
  {
    Serial.println("Bad reading");
  }
}//end of loop
