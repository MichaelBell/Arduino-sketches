#include <MANCHESTER.h>

#define RxPin 4

#define PowerClkPin 2
#define PowerDataPin 3

unsigned int X = 0;
unsigned int Y = 0;
unsigned int Z = 0;
unsigned int oldX = 0;
unsigned int oldY = 0;
unsigned int oldZ = 0;

unsigned char power = 0;


void setup()
{
 MANCHESTER.SetRxPin(RxPin); //user sets rx pin default 4
 MANCHESTER.SetTimeOut(100); //user sets timeout default blocks
 
 pinMode(PowerClkPin, OUTPUT);
 pinMode(PowerDataPin, OUTPUT);
 digitalWrite(PowerClkPin, LOW);
 
 Serial.begin(115200); // Debugging only
}//end of setup

void setPower(unsigned char power)
{
  Serial.print("Power: ");
  Serial.println(power, DEC);
  
  digitalWrite(PowerClkPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(PowerClkPin, LOW);

  for (int i = 0; i < 8; i++) 
  {
    digitalWrite(PowerDataPin, (power & (1<<i)) ? HIGH : LOW);
    delayMicroseconds(10);
    digitalWrite(PowerClkPin, HIGH);
    delayMicroseconds(10);
    digitalWrite(PowerClkPin, LOW);
  }    
}

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
    int diff = 0;
    if (axis == 0)
    {
      diff = X - reading;
      X = reading;
      Serial.print("X");
    }
    else if (axis == 1)
    {
      diff = Y - reading;
      Y = reading;
      Serial.print("Y");
    }
    else if (axis == 2)
    {
      diff = Z - reading;
      Z = reading;
      Serial.print("Z");
    }
    diff = abs(diff);
    if (diff != 0)
    {
      Serial.print(X, DEC);
      Serial.print(" ");
      Serial.print(Y, DEC);
      Serial.print(" ");
      Serial.println(Z, DEC);  
      oldX = X;
      oldY = Y;
      oldZ = Z;
      if (power > (diff / 10))
      {
        power-=(diff/10);
      }
      else
        power = 0;
      setPower(power);
    }
  }
  else if (data != 0)
  {
    Serial.println("Bad reading");
  }
  else
  {
      power+=5;
      setPower(power);
//    Serial.println("Nothing");
  }
}//end of loop
