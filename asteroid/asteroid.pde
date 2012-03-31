// Simple game related very slightly to asteroids.

#include <Wire.h>
#include "wiichuck.h"

void writeSprite(int sprite_id, int x, int y, int sprite_addr);
void setupEnemy(int i);
void setupShip();

#define SCREEN_X 1024
#define SCREEN_Y 768
#define GAME_MULT 10
#define GAME_X (SCREEN_X * GAME_MULT)
#define GAME_Y (SCREEN_Y * GAME_MULT)

#define SHIP_SIZE (16*GAME_MULT)
#define ENEMY_SIZE (15*GAME_MULT)
#define NUM_BULLETS 4
#define NUM_ENEMIES 10

#define OFF_SCREEN (800*GAME_MULT)

#define MAX_SHIP_SPEED (10 * GAME_MULT)
#define MAX_ENEMY_SPEED (8 * GAME_MULT)
#define BULLET_SPEED (40 * GAME_MULT)

class Object
{
public:
  int oldx, oldy;
  int x, y;
  int vel_x, vel_y;
  int id, addr;
  int destroy_on_edge;
  int object_size;
  
  Object(int x = 0, int y = OFF_SCREEN, int id = 0, int addr = 0, 
         int destroy_on_edge = 0, int object_size = SHIP_SIZE);
  
  int moveAndWrite();
  int getSpeed();
  int collide(Object &other);
};

Object ship(GAME_X / 2, GAME_Y / 2, 0, 0, 0, SHIP_SIZE);
Object enemy[NUM_ENEMIES];
Object bullet[NUM_BULLETS];
int next_bullet = 0;
int fired = 0;

int maxscore = 0;
int score = 0;
int oldscore = -1;

int next_enemy = 0;

Object::Object(int x, int y, int id, int addr, int destroy_on_edge, int object_size)
: oldx(-1), oldy(-1), x(x), y(y), vel_x(0), vel_y(0), id(id), addr(addr), 
  destroy_on_edge(destroy_on_edge), object_size(object_size)
{
}

int Object::moveAndWrite()
{
  x += vel_x / GAME_MULT;
  y += vel_y / GAME_MULT;
  
  int hit_edge = 0;
  
  if (x < 0)
  {
    x = 0;
    vel_x = -vel_x;
    hit_edge = 1;
  }
  else if (x >= GAME_X - object_size)
  {
    x = GAME_X - object_size - 1;
    vel_x = -vel_x;
    hit_edge = 1;
  }
  
  if (y < 0)
  {
    y = 0;
    vel_y = -vel_y;
    hit_edge = 1;
  }
  else if (y >= GAME_Y - object_size)
  {
    y = GAME_Y - object_size - 1;
    vel_y = -vel_y;
    hit_edge = 1;
  }

  if (hit_edge && destroy_on_edge)
  {
    x = 0;
    y = OFF_SCREEN;
  } 

  int screenx = x / GAME_MULT;
  int screeny = y / GAME_MULT;
  if (screenx != oldx || screeny != oldy)
  {
    writeSprite(id, x / GAME_MULT, y / GAME_MULT, addr);  
    oldx = screenx;
    oldy = screeny;
  }
  
  return hit_edge;
}

int Object::getSpeed()
{
  // Yes, we live in the 1-metric.
  return abs(vel_x) + abs(vel_y);
}

int Object::collide(Object &other)
{
  int sizediff = object_size / 2 - other.object_size / 2;
  int diffx = x - other.x + sizediff;
  int diffy = y - other.y + sizediff;
  int size_total = (object_size + other.object_size) / 2;
  if (abs(diffx) + abs(diffy) < size_total)
  {
    return 1;
  }
  else
  {
    return 0;
  }
}

void writeScore()
{
  if (oldscore != score)
  {
    writeSprite(100, SCREEN_X - 80, 20, 36+4*(score/10));
    writeSprite(101, SCREEN_X - 72, 20, 36+4*(score%10));
    oldscore = score;
  }
}
void writeMaxScore()
{
  writeSprite(102, SCREEN_X - 80, 30, 36+4*(maxscore/10));
  writeSprite(103, SCREEN_X - 72, 30, 36+4*(maxscore%10));
}

void setup()
{
    Serial.begin(57600);
    randomSeed(analogRead(0));
    nunchuck_setpowerpins();
    nunchuck_init(); // send the initilization handshake
    
  for (int i = 0; i < NUM_BULLETS; i++)
  {
    bullet[i].id = i+1;
    bullet[i].addr = 32;
    bullet[i].destroy_on_edge = 1;
    bullet[i].object_size = 8;
  }
  for (int i = 0; i < NUM_ENEMIES; i++)
  {
    enemy[i].id = i+1+NUM_BULLETS;
    enemy[i].addr = 16;
    enemy[i].object_size = ENEMY_SIZE;
    setupEnemy(i);
  }
  
  for (int i = 0; i < 128; i++)
    writeSprite(i, 0, OFF_SCREEN / GAME_MULT, 0);
}

void loop()
{
  nunchuck_get_data();
  int joyx = nunchuck_joyx();
  int joyy = nunchuck_joyy();
  
  if (joyx < 48)
  {
    ship.vel_x -= 2;
  }
  else if (joyx < 103)
  {
    ship.vel_x -= 1;
  }
  else if (joyx > 208)
  {
    ship.vel_x += 2;
  }
  else if (joyx > 153)
  {
    ship.vel_x += 1;
  }
    
  if (joyy < 48)
  {
    ship.vel_y += 2;
  }
  else if (joyy < 103)
  {
    ship.vel_y += 1;
  }
  else if (joyy > 208)
  {
    ship.vel_y -= 2;
  }
  else if (joyy > 153)
  {
    ship.vel_y -= 1;
  }
  
  int ship_speed = ship.getSpeed();
  
  if (ship_speed > MAX_SHIP_SPEED)
  {
    if (ship.vel_x < 0)
      ship.vel_x += 1;
    else
      ship.vel_x -= 1;
    if (ship.vel_y < 0)
      ship.vel_y += 1;
    else
      ship.vel_y -= 1;
    if (abs(ship.vel_x) > abs(ship.vel_y))
    {
      if (ship.vel_x < 0)
        ship.vel_x += 1;
      else
        ship.vel_x -= 1;
    }
    else
    {
      if (ship.vel_y < 0)
        ship.vel_y += 1;
      else
        ship.vel_y -= 1;
    }
    ship_speed = ship.getSpeed();
  }

  int zbutton = nunchuck_zbutton();

  if (zbutton && !fired && bullet[next_bullet].y == OFF_SCREEN && ship_speed != 0)
  {
    bullet[next_bullet].x = ship.x + ship.object_size / 2;
    bullet[next_bullet].y = ship.y + ship.object_size / 2;
    bullet[next_bullet].vel_x = ship.vel_x * (BULLET_SPEED / ship_speed);
    bullet[next_bullet].vel_y = ship.vel_y * (BULLET_SPEED / ship_speed);
    fired = 1;
    next_bullet += 1;
    if (next_bullet == NUM_BULLETS)
      next_bullet = 0;
  }
  else if (!zbutton)
  {
    fired = 0;
  }
  
  ship.moveAndWrite();
  for (int i = 0; i < NUM_BULLETS; i++)
  {
    bullet[i].moveAndWrite();
    
    for (int j = 0; j < NUM_ENEMIES; j++)
    {
      if (enemy[j].collide(bullet[i]))
      {
        setupEnemy(j);
        bullet[i].y = OFF_SCREEN;
        score += 1;
        if (score > 99) score = 99;
      }
    }
  }
  
  for (int i = 0; i < NUM_ENEMIES; i++)
  {
    if (ship.collide(enemy[i]))
    {
      setupShip();
      for (i = 0; i < NUM_ENEMIES; i++)
        setupEnemy(i);
      if (score > maxscore)
      {
        maxscore = score;
        writeMaxScore();
      }
      score = 0;
      break;
    }
    
    if (i == next_enemy)
    {
      if (enemy[i].x < ship.x - enemy[i].object_size)
        enemy[i].vel_x += 2;
      else if (enemy[i].x > ship.x + enemy[i].object_size)
        enemy[i].vel_x -= 2;
      if (enemy[i].y < ship.y - enemy[i].object_size)
        enemy[i].vel_y += 2;
      else if (enemy[i].y > ship.y + enemy[i].object_size)
        enemy[i].vel_y -= 2; 
    }
    
    enemy[i].moveAndWrite();
  }
  next_enemy += 1;
  if (next_enemy == NUM_ENEMIES)
    next_enemy = 0;
  
  writeScore();
    
  //delay(1);
}

void setupShip()
{
  ship.x = GAME_X / 2;
  ship.y = GAME_Y / 2;
  ship.vel_x = 0;
  ship.vel_y = 0;
}

void setupEnemy(int i)
{
  enemy[i].x = random(GAME_X - enemy[i].object_size);
  enemy[i].y = random(GAME_Y - enemy[i].object_size);
  enemy[i].vel_x = random(-MAX_ENEMY_SPEED + 1, MAX_ENEMY_SPEED);   
  enemy[i].vel_y = random(-MAX_ENEMY_SPEED + 1, MAX_ENEMY_SPEED);  
}
