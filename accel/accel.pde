#define XPin A0
#define YPin A1
#define ZPin A2

void setup()
{
  Serial.begin(9600);
}

void loop()
{
  unsigned int X = analogRead(XPin);
  unsigned int Y = analogRead(YPin);
  unsigned int Z = analogRead(ZPin);
  
  Serial.print(X, DEC);
  Serial.print(" ");
  Serial.print(Y, DEC);
  Serial.print(" ");
  Serial.println(Z, DEC);
  
  delay(100);
}
