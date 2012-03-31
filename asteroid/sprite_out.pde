// Write output over the interface to the FPGA for displaying sprites
// The wire protocol is 4 10-bit words for:
// - sprite ID (valid range 0 - 127)
// - x coord (valid range 0 - 1023)
// - y coord (valid range 0 - 767)
// - sprite address (in the sprite data file on the FPGA, range 0 - 255) 

#define FpgaDataPin 3
#define FpgaClkPin 2

void writeData(int data)
{
  // Note that the Arduino functions are slow enough
  // that they introduce enough delay for the FPGA
  // to pick up the changes (even with debounce)
  // with no delays here.  
  digitalWrite(FpgaClkPin, HIGH);
  digitalWrite(FpgaClkPin, LOW);

  for (int i = 0; i < 10; i++) 
  {
    digitalWrite(FpgaDataPin, (data & (1<<i)) ? HIGH : LOW);
    digitalWrite(FpgaClkPin, HIGH);
    digitalWrite(FpgaClkPin, LOW);
  }      
}

// Write a sprite
void writeSprite(int sprite_id, int x, int y, int sprite_addr)
{
  writeData(sprite_id);
  writeData(x);
  writeData(y);
  writeData(sprite_addr);
}
