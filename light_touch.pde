#include "Tlc5940.h"
#include "tlc_fades.h"

//#define TLC_FADE_BUFFER_LENGTH    48

int channel = 0;

boolean debug;

int ambient;
int touch;
long start;

long tstart;
long tlength = 100;
int threshold = 43;
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
  debug = true;
  
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
  
  if(touched)
  {
    if(cycle == 0 && channel == 3)
    {
      duration = (duration*2)/duration_factor;
    }
   
    /*
    if(cycle == 0 && channel > 3)
    {
      duration = duration/1.8;
    }
    */
    else
    {
      duration = default_duration/duration_factor;
    }
    if (!tlc_isFading(channel))
    {
      uint32_t startMillis = millis() + 50;
      uint32_t endMillis = startMillis + duration;
      tlc_addFade(channel, 0, 4095, startMillis, endMillis);
      tlc_addFade(channel, 4095, 0, endMillis, endMillis+duration);
      if(cycle == 4 && channel == 7 && tlc_updateFades() < 5)
      {
        int end_add = 150;
        int c = random(4,7);
        startMillis = startMillis + random(20,200);
        endMillis = startMillis + end_add;
        tlc_addFade(c, 0, 4095, startMillis, endMillis);
        tlc_addFade(c, 4095, 0, endMillis, endMillis+end_add);
        
        c = random(4,7);
        startMillis = startMillis + random(20,200);
        endMillis = startMillis + end_add;
        tlc_addFade(c, 0, 4095, startMillis, endMillis);
        tlc_addFade(c, 4095, 0, endMillis, endMillis+end_add);
        
        c = random(4,7);
        startMillis = startMillis + random(20,200);
        endMillis = startMillis + end_add;
        tlc_addFade(c, 0, 4095, startMillis, endMillis);
        tlc_addFade(c, 4095, 0, endMillis, endMillis+end_add);
      }
    }
  }
  
  if(debug && millis() % 100 == 0)
  {
    threshold = 1;
    Serial.print(touch);
    Serial.print(" : ");
    Serial.print(ambient);
    
    Serial.print(" : ");
    Serial.print(cycle);
    //Serial.print(" : ");
    //Serial.print(tlc_fadeBufferSize);
    if(touched)
    {
      Serial.print(" touching!!!!");
    }
    Serial.print("\n");                    // tab character for debug windown spacing
  }
  
  if(updates = tlc_updateFades() == 0)
  {
    if(touched)
    {
      channel++;
      if(channel > 7)
      {
        cycle++;
        channel = 0;
        duration_factor = duration_factor*1.8;
        //turn on relay for last one which goes nuts
      }
      if(cycle == 5)
      {
        cycle = 0;
        duration_factor = 1;
        delay(3000);
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

