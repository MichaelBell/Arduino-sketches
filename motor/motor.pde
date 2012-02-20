#define Wire1 3
#define Wire2 2
#define Wire3 4
#define Wire4 5

void setup()
{
  pinMode(Wire1, OUTPUT);
  pinMode(Wire2, OUTPUT);
  pinMode(Wire3, OUTPUT);
  pinMode(Wire4, OUTPUT);
}

void left(byte interval)
{
  digitalWrite(Wire1, HIGH);
  digitalWrite(Wire2, LOW);
  digitalWrite(Wire3, HIGH);
  digitalWrite(Wire4, LOW);
  delay(interval);
  
  digitalWrite(Wire1, LOW);
  digitalWrite(Wire2, HIGH);
  digitalWrite(Wire3, HIGH);
  digitalWrite(Wire4, LOW);
  delay(interval);
  
  digitalWrite(Wire1, LOW);
  digitalWrite(Wire2, HIGH);
  digitalWrite(Wire3, LOW);
  digitalWrite(Wire4, HIGH);
  delay(interval);
  
  digitalWrite(Wire1, HIGH);
  digitalWrite(Wire2, LOW);
  digitalWrite(Wire3, LOW);
  digitalWrite(Wire4, HIGH);
  delay(interval);
}

void right(byte interval)
{
  digitalWrite(Wire1, HIGH);
  digitalWrite(Wire2, LOW);
  digitalWrite(Wire3, HIGH);
  digitalWrite(Wire4, LOW);
  delay(interval);
  
  digitalWrite(Wire1, HIGH);
  digitalWrite(Wire2, LOW);
  digitalWrite(Wire3, LOW);
  digitalWrite(Wire4, HIGH);
  delay(interval);
  
  digitalWrite(Wire1, LOW);
  digitalWrite(Wire2, HIGH);
  digitalWrite(Wire3, LOW);
  digitalWrite(Wire4, HIGH);
  delay(interval);
  
  digitalWrite(Wire1, LOW);
  digitalWrite(Wire2, HIGH);
  digitalWrite(Wire3, HIGH);
  digitalWrite(Wire4, LOW);
  delay(interval);
}

void loop()
{
  left(25);
  left(25);
  right(100);
}
