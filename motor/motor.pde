#define Wire1 3
#define Wire2 2
#define Wire3 4
#define Wire4 5

#define MIN_INTERVAL 5

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

  delay(MIN_INTERVAL);  
  off();
  delay(interval - MIN_INTERVAL);
  
  digitalWrite(Wire1, LOW);
  digitalWrite(Wire2, HIGH);
  digitalWrite(Wire3, HIGH);
  digitalWrite(Wire4, LOW);

  delay(MIN_INTERVAL);  
  off();
  delay(interval - MIN_INTERVAL);
  
  digitalWrite(Wire1, LOW);
  digitalWrite(Wire2, HIGH);
  digitalWrite(Wire3, LOW);
  digitalWrite(Wire4, HIGH);

  delay(MIN_INTERVAL);  
  off();
  delay(interval - MIN_INTERVAL);
  
  digitalWrite(Wire1, HIGH);
  digitalWrite(Wire2, LOW);
  digitalWrite(Wire3, LOW);
  digitalWrite(Wire4, HIGH);

  delay(MIN_INTERVAL);  
  off();
  delay(interval - MIN_INTERVAL);
}

void right(byte interval)
{
  digitalWrite(Wire1, HIGH);
  digitalWrite(Wire2, LOW);
  digitalWrite(Wire3, HIGH);
  digitalWrite(Wire4, LOW);

  delay(MIN_INTERVAL);  
  off();
  delay(interval - MIN_INTERVAL);
  
  digitalWrite(Wire1, HIGH);
  digitalWrite(Wire2, LOW);
  digitalWrite(Wire3, LOW);
  digitalWrite(Wire4, HIGH);

  delay(MIN_INTERVAL);  
  off();
  delay(interval - MIN_INTERVAL);
  
  digitalWrite(Wire1, LOW);
  digitalWrite(Wire2, HIGH);
  digitalWrite(Wire3, LOW);
  digitalWrite(Wire4, HIGH);

  delay(MIN_INTERVAL);  
  off();
  delay(interval - MIN_INTERVAL);
  
  digitalWrite(Wire1, LOW);
  digitalWrite(Wire2, HIGH);
  digitalWrite(Wire3, HIGH);
  digitalWrite(Wire4, LOW);

  delay(MIN_INTERVAL);  
  off();
  delay(interval - MIN_INTERVAL);
}

void off()
{
  digitalWrite(Wire1, LOW);
  digitalWrite(Wire2, LOW);
  digitalWrite(Wire3, LOW);
  digitalWrite(Wire4, LOW);
}

void loop()
{
  byte i;
  for (i = 0; i < 6; i++)
    left(100);
  delay(10000);

//  for (i = 0; i < 8; i++)
//    right(25);
//  delay(500);
}
