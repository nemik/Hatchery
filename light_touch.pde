#include "Tlc5940.h"
#include "tlc_fades.h"

#define TLC_FADE_BUFFER_LENGTH    64

int channel = 0;

boolean debug;

int ambient;
int touch;
long start;

long tstart;
long tlength = 100;
int threshold = 35;
int d_len = 30;

int default_duration = 230;
int duration = 230;
int duration_factor = 1;
int cycle = 0;

boolean touched = false;

uint32_t updates;

void setup()                    
{
  Serial.begin(9600);
  Tlc.init();
  //debug = true;
  
  randomSeed(analogRead(4));
}

void loop()                    
{ 
  start = millis();
  touch = map((1023 - analogRead(0)), 0, 1023, 0, 255);
  ambient = map((1023 - analogRead(1)), 0, 1023, 0, 255);
  
  if(abs(ambient - touch) > threshold)
  {
    if(tstart == 0)
    {
      tstart = millis();
    }
    if(millis() - tstart > tlength)
    {
      if(!touched)
      {       
        tlc_removeFades(4);
        tlc_removeFades(4);        
        tlc_updateFades();
        tlc_removeFades(5);
        tlc_removeFades(5);        
        tlc_updateFades();
        tlc_removeFades(6);
        tlc_removeFades(6);
        tlc_updateFades();
        tlc_removeFades(7);
         tlc_removeFades(7);
        tlc_updateFades();
        tlc_removeFades(8);
         tlc_removeFades(8);
        tlc_updateFades();        
        Tlc.clear();
        Tlc.update();
        channel = 0;
        duration_factor = 1;
        duration = default_duration;
        
        //first touch, send serial to logger
        Serial.println("touched");
      }
      touched = true;
    }
  }
  else
  {
    tstart = 0;
    touched = false;
  }
  
  updates = tlc_updateFades();
  
  if(touched)
  {   
    if (updates == 0)
    {
      if(cycle == 0 && channel == 3)
      {
        duration = (duration*2)/duration_factor;
      }
      else
      {
        duration = default_duration/duration_factor;
      }
      
      uint32_t startMillis = millis() + 50;
      uint32_t endMillis = startMillis + duration;
      tlc_addFade(channel, 0, 4095, startMillis, endMillis);
      tlc_addFade(channel, 4095, 0, endMillis, endMillis+duration);
      if(channel > 3)
      {
        tlc_addFade(8, 0, 4095, startMillis, endMillis);
        tlc_addFade(8, 4095, 0, endMillis, endMillis+duration);
      }
      
      if(cycle == 8 && channel == 7)
      {
        startMillis = millis();
        endMillis = startMillis + 1500;
        tlc_addFade(4, 0, 4095, startMillis, endMillis);
        tlc_addFade(4, 4095, 0, endMillis, endMillis+1500);
        tlc_addFade(5, 0, 4095, startMillis, endMillis);
        tlc_addFade(5, 4095, 0, endMillis, endMillis+1500);
        tlc_addFade(6, 0, 4095, startMillis, endMillis);
        tlc_addFade(6, 4095, 0, endMillis, endMillis+1500);
        tlc_addFade(7, 0, 4095, startMillis, endMillis);
        tlc_addFade(7, 4095, 0, endMillis, endMillis+1500);
        tlc_addFade(8, 0, 4095, startMillis, endMillis);
        tlc_addFade(8, 4095, 0, endMillis, endMillis+1500);
      }
    }
  }
  else
  {
    if (updates == 0)
    {
      uint32_t startMillis = millis()+3500;
      uint32_t endMillis = startMillis + 3500;
      tlc_addFade(4, 0, 4095, startMillis, endMillis);
      tlc_addFade(4, 4095, 0, endMillis, endMillis+3500);
      tlc_addFade(5, 0, 4095, startMillis, endMillis);
      tlc_addFade(5, 4095, 0, endMillis, endMillis+3500);
      tlc_addFade(6, 0, 4095, startMillis, endMillis);
      tlc_addFade(6, 4095, 0, endMillis, endMillis+3500);
      tlc_addFade(7, 0, 4095, startMillis, endMillis);
      tlc_addFade(7, 4095, 0, endMillis, endMillis+3500);
      tlc_addFade(8, 0, 4095, startMillis, endMillis);
      tlc_addFade(8, 4095, 0, endMillis, endMillis+3500);
    }
  }
  
  if(debug && millis() % 100 == 0)
  {
    //threshold = 1;
    Serial.print(cycle);
    Serial.print(" : ");
    Serial.print(duration);
    Serial.print(" : ");
    Serial.print(duration_factor);
    if(touched)
    {
      Serial.print(" touching!!!!");
    }
    Serial.print("\n");                    // tab character for debug windown spacing
  }
  
  if(updates == 0)
  {
    if(touched)
    {
      channel++;
      if(channel > 7)
      {
        cycle++;
        channel = 0;
        if(cycle < 7)
        {
          duration_factor = duration_factor+1.3;
        }
        //turn on relay for last one which goes nuts
      }
      if(cycle == 9)
      {
        cycle = 0;
        duration_factor = 1;
      }
    }
    else
    {
      Tlc.clear();
      Tlc.update();
      channel = 0;
      duration_factor = 1;
      duration = default_duration;
      //turn off relay
    }
  }
}

