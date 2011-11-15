#include "Tlc5940.h"
#include "tlc_fades.h"

int channel = 0;

boolean debug;

int ambient;
int touch;
long start;

long tstart;
long tlength = 100;
int threshold = 30;
int d_len = 30;

int duration = 300;

boolean touched = false;

void setup()                    
{
  Serial.begin(9600);
  Tlc.init();
  debug = true;
}

void loop()                    
{ 
  start = millis();
  touch = map((1023 - analogRead(0)), 0, 1023, 0, 255)/1.6;
  ambient = map((1023 - analogRead(1)), 0, 1023, 0, 255);
  
  if(abs(ambient - touch) > threshold)
  {
    if(tstart == 0)
    {
      tstart = millis();
    }
    if(millis() - tstart > tlength)
    {
      touched = true;
    }
  }
  else
  {
    tstart = 0;
    touched = false;
  }
  
  if(touched)
  {
    if (!tlc_isFading(channel))
    {
      uint32_t startMillis = millis() + 50;
      uint32_t endMillis = startMillis + duration;
      tlc_addFade(channel, 0, 4095, startMillis, endMillis);
      tlc_addFade(channel, 4095, 0, endMillis, endMillis+duration);
    }
  }
  
  if(debug && millis() % 100 == 0)
  {
    Serial.print(touch);
    Serial.print(" : ");
    Serial.print(ambient);
    //Serial.print(" : ");
    //Serial.print(tlc_fadeBufferSize);
    if(touched)
    {
      Serial.print(" touching!!!!");
    }
    Serial.print("\n");                    // tab character for debug windown spacing
  }
  
  if(tlc_updateFades() == 0)
  {
    if(touched)
    {
      channel++;
      if(channel == 8)
      {
        channel = 0;
        //turn on relay for last one which goes nuts
      }
    }
    else
    {
      Tlc.clear();
      Tlc.update();
      channel = 0;
      //turn off relay
      serial.println("touched");
    }
  }
}

