void setup()
{
}

void loop()
{
  for (int j = 0; j < 64; j++)
  {
    for (int k = 0; k < 100; k++)
    {
      for (int i = 0; i < 6; i++)
      {
        if (j & (1 << i))
        {
          pinMode(5, (i < 4) ? OUTPUT : INPUT);
          pinMode(6, ((i < 2) || (i >= 4)) ? OUTPUT : INPUT);
          pinMode(7, (i >= 2) ? OUTPUT : INPUT);
          digitalWrite(5, (i & 1) ? HIGH : LOW);
          digitalWrite(6, (i & 1) ? LOW : HIGH);
          digitalWrite(7, (((i & 4) >> 2) ^ (i & 1)) ? LOW : HIGH);
        }
        else
        {
          pinMode(5, INPUT);
          pinMode(7, INPUT);
          pinMode(6, INPUT);
        }
        delay(1);
      }
    }
  }
}
