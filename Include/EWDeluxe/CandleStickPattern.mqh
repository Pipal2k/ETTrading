//+------------------------------------------------------------------+
//|                                                 PositionEnum.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include <EWDeluxe\Enums.mqh>
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+

struct CandleStickPattern {
   CandleStickType Type;
   Position position;
   datetime time;
   double patternHigh;
   double patternLow;
   
   
   double drawPos;  
};


void findPattern(double &highBuffer[], double &lowBuffer[], double &openBuffer[], double &closeBuffer[],long &VolumeBuffer[],long avgVolume,datetime &timeBuffer[],TradeTrigger &triggers[],Configuration &config)
{
 
 CandleStickPattern foundPatterns[];
 ArrayFree(foundPatterns);
 
  if(config.TriggerBullishEngulfing)
  fBullishEngulfing(highBuffer,lowBuffer,openBuffer,closeBuffer,timeBuffer,VolumeBuffer,avgVolume,foundPatterns);
  if(config.TriggerBearishEngulfing)
  fBearishEngulfing(highBuffer,lowBuffer,openBuffer,closeBuffer,timeBuffer,VolumeBuffer,avgVolume,foundPatterns);
  if(config.TriggerThreeWhiteSoldiers)
  threeSoldiers(openBuffer,closeBuffer,timeBuffer,lowBuffer,highBuffer,VolumeBuffer,avgVolume,foundPatterns);
  if(config.TriggerDarkClouds)
  threeDarkCloud(openBuffer,closeBuffer,timeBuffer,lowBuffer,highBuffer,VolumeBuffer,avgVolume,foundPatterns);
  if(config.TriggerHammer)
  Hammer(openBuffer,closeBuffer,timeBuffer,lowBuffer,highBuffer,VolumeBuffer,avgVolume,foundPatterns);
  if(config.TriggerInvertedHammer)
  InvertedHammer(openBuffer,closeBuffer,timeBuffer,lowBuffer,highBuffer,VolumeBuffer,avgVolume,foundPatterns);
 
  for(int i = 0; i < ArraySize(foundPatterns); i++)
  {
      TradeTrigger tmpTrigger;
      //tmpTrigger.triggerType=CandleStickPatternTrigger;
      tmpTrigger.pos=foundPatterns[i].position;

      if(foundPatterns[i].position==Buy)
        {
         tmpTrigger.possibleStopLoss=foundPatterns[i].patternLow;
        }
      else
         tmpTrigger.possibleStopLoss=foundPatterns[i].patternHigh;
       
       switch(foundPatterns[i].Type)
       {
         case BearishEngulfing:
            tmpTrigger.triggerType=CBEE;
            break;
         case BullishEngulfing:
            tmpTrigger.triggerType=CBUE;
            break;
         case ThreeSoldiers:
            tmpTrigger.triggerType=CTS;
            break;
         case ThreeDarkCloud:
            tmpTrigger.triggerType=CDC;
            break;
         case Hammer:
            tmpTrigger.triggerType=CH; 
            break;
         case InvertedHammer:
            tmpTrigger.triggerType=CIH;
            break;   
         
          
          
       }
       tmpTrigger.time=foundPatterns[i].time;
       tmpTrigger.drawPos=foundPatterns[i].drawPos;
       ArrayResize(triggers,ArraySize(triggers)+1,0);
       triggers[ArraySize(triggers)-1]= tmpTrigger;
       
  }
  
 return;
}

void  fBullishEngulfing(double &highBuffer[],double &lowBuffer[], double &openBuffer[], double &closeBuffer[],datetime &timeBuffer[],long &VolumeBuffer[],long avgVolume, CandleStickPattern &foundPatterns[])
{
    CandleStickPattern tmpPattern;    
   if(   closeBuffer[2]>=openBuffer[1] && openBuffer[2]<=closeBuffer[1] 
      && closeBuffer[2]<closeBuffer[1] && openBuffer[2]>openBuffer[1]
      && ((openBuffer[2]-closeBuffer[2])>=((closeBuffer[1]-openBuffer[1])/2))
      && ((openBuffer[2]-closeBuffer[2]) > (highBuffer[2] - openBuffer[2]))
      && ((closeBuffer[1]- openBuffer[1]) > (highBuffer[1] - closeBuffer[1])))
     // && (VolumeBuffer[1] > avgVolume && VolumeBuffer[2] > avgVolume))
     {
       tmpPattern.Type=BullishEngulfing;
       tmpPattern.position=Buy; 
       tmpPattern.drawPos =lowBuffer[1];
       tmpPattern.time = timeBuffer[1];
       tmpPattern.patternLow = lowBuffer[1];
       tmpPattern.patternHigh= highBuffer[1];
       
       ArrayResize(foundPatterns,ArraySize(foundPatterns)+1,0);
       foundPatterns[ArraySize(foundPatterns)-1]=tmpPattern;
     }
     
    return;
}


void  fBearishEngulfing(double &highBuffer[],double &lowBuffer[], double &openBuffer[], double &closeBuffer[],datetime &timeBuffer[],long &VolumeBuffer[],long avgVolume, CandleStickPattern &foundPatterns[])
{
    CandleStickPattern tmpPattern; 
       
    if((closeBuffer[2]<=openBuffer[1] && closeBuffer[1]<=openBuffer[2]) 
        && closeBuffer[2]>closeBuffer[1] && openBuffer[2]<openBuffer[1]
        && ((closeBuffer[2]-openBuffer[2])>=((openBuffer[1]-closeBuffer[1])/2))
        && (closeBuffer[2]-openBuffer[2] >  openBuffer[2] - lowBuffer[2])
        && (openBuffer[1]-closeBuffer[1] > closeBuffer[1] - lowBuffer[1]))
       //&& (VolumeBuffer[1] > avgVolume && VolumeBuffer[2] > avgVolume))
     {
       tmpPattern.Type=BearishEngulfing;
       tmpPattern.position=Sell;
       tmpPattern.drawPos =lowBuffer[1];
       tmpPattern.time = timeBuffer[1];
       tmpPattern.patternLow = lowBuffer[1];
       tmpPattern.patternHigh= highBuffer[1];
       
       ArrayResize(foundPatterns,ArraySize(foundPatterns)+1,0);
       foundPatterns[ArraySize(foundPatterns)-1]=tmpPattern;
      // Print("closeBuffer2: ",closeBuffer[2], " Open1: ",openBuffer[1]," Open2: ",openBuffer[2]," closeBuffer1: ",closeBuffer[1]);
     }
     
    return;
}

void threeSoldiers(double &openBuffer[],double &closeBuffer[],datetime &timeBuffer[],double &lowBuffer[],double &highBuffer[],long &VolumeBuffer[],long avgVolume,CandleStickPattern &foundPatterns[])
{
CandleStickPattern tmpPattern;
 
if((openBuffer[3]<closeBuffer[3] && openBuffer[2]<closeBuffer[2] && openBuffer[1]<closeBuffer[1])
      && (openBuffer[2]>openBuffer[3] && openBuffer[1]>openBuffer[2])
      && (closeBuffer[2]>closeBuffer[3] && closeBuffer[1]>closeBuffer[2])
      &&  (closeBuffer[3] - openBuffer[3] > highBuffer[3]-closeBuffer[3] )
      &&  (closeBuffer[2] - openBuffer[2] > highBuffer[2]-closeBuffer[2] ) 
      && (closeBuffer[1] - openBuffer[1] > highBuffer[1]-closeBuffer[1] ))
      //&& (VolumeBuffer[1] > avgVolume && VolumeBuffer[2] > avgVolume && VolumeBuffer[3] > avgVolume))
     {
         tmpPattern.Type=ThreeSoldiers;
       tmpPattern.position=Buy;
       tmpPattern.drawPos =lowBuffer[1];
       tmpPattern.time = timeBuffer[1];
       tmpPattern.patternLow = lowBuffer[3];
       tmpPattern.patternHigh= highBuffer[1];
       
       ArrayResize(foundPatterns,ArraySize(foundPatterns)+1,0);
       foundPatterns[ArraySize(foundPatterns)-1]=tmpPattern;
    
     }

}

void threeDarkCloud(double &openBuffer[],double &closeBuffer[],datetime &timeBuffer[],double &lowBuffer[],double &highBuffer[],long &VolumeBuffer[],long avgVolume,CandleStickPattern &foundPatterns[])
{
CandleStickPattern tmpPattern;

   if((closeBuffer[3]<openBuffer[3] && closeBuffer[2]<openBuffer[2] && closeBuffer[1]< openBuffer[1])
      && (openBuffer[2]<openBuffer[3] && openBuffer[1]<openBuffer[2])
      && (closeBuffer[2]<closeBuffer[3] && closeBuffer[1]<closeBuffer[2])
      && (openBuffer[3]-closeBuffer[3]> closeBuffer[3] - lowBuffer[3])
      && (openBuffer[2]-closeBuffer[2]> closeBuffer[2] - lowBuffer[2])
      && (openBuffer[1]-closeBuffer[1]> closeBuffer[1] - lowBuffer[1]) )
      //&& (VolumeBuffer[1] > avgVolume && VolumeBuffer[2] > avgVolume && VolumeBuffer[3] > avgVolume))
     {
       tmpPattern.Type=ThreeDarkCloud;
       tmpPattern.position=Sell;
       tmpPattern.drawPos =lowBuffer[1];
       tmpPattern.time = timeBuffer[1];
       tmpPattern.patternLow = lowBuffer[3];
       tmpPattern.patternHigh= highBuffer[1];
       
       ArrayResize(foundPatterns,ArraySize(foundPatterns)+1,0);
       foundPatterns[ArraySize(foundPatterns)-1]=tmpPattern;
     }

}

void Hammer(double &openBuffer[],double &closeBuffer[],datetime &timeBuffer[],double &lowBuffer[],double &highBuffer[],long &VolumeBuffer[],long avgVolume,CandleStickPattern &foundPatterns[])
{
CandleStickPattern tmpPattern;

if((lowBuffer[1]< openBuffer[1]  && closeBuffer[1] > openBuffer[1] 
   &&  (((closeBuffer[1]-openBuffer[1])*2) < (openBuffer[1] - lowBuffer[1])) 
   && ((highBuffer[1]-closeBuffer[1]) < ((closeBuffer[1]-openBuffer[1])/2) ))
   ||
   ( lowBuffer[1]< closeBuffer[1]  && closeBuffer[1] < openBuffer[1]) 
   &&(((openBuffer[1]-closeBuffer[1])*2) < (closeBuffer[1] - lowBuffer[1]))
   && ((highBuffer[1]-openBuffer[1]) < ((openBuffer[1]-closeBuffer[1])/2) )  )
{
    tmpPattern.Type=Hammer;
       tmpPattern.position=Buy;
       tmpPattern.drawPos =lowBuffer[1];
       tmpPattern.time = timeBuffer[1];
       tmpPattern.patternLow = lowBuffer[1];
       tmpPattern.patternHigh= highBuffer[1];
       
       ArrayResize(foundPatterns,ArraySize(foundPatterns)+1,0);
       foundPatterns[ArraySize(foundPatterns)-1]=tmpPattern;
}

}

void InvertedHammer(double &openBuffer[],double &closeBuffer[],datetime &timeBuffer[],double &lowBuffer[],double &highBuffer[],long &VolumeBuffer[],long avgVolume,CandleStickPattern &foundPatterns[])
{
CandleStickPattern tmpPattern;

if((highBuffer[1]> openBuffer[1]  && openBuffer[1] > closeBuffer[1] 
   &&  (((openBuffer[1]-closeBuffer[1])*2) < (highBuffer[1] - openBuffer[1])) 
   && ((closeBuffer[1]-lowBuffer[1]) < ((openBuffer[1]-closeBuffer[1])/2) ))
   ||
   ( highBuffer[1] > closeBuffer[1]  && closeBuffer[1] > openBuffer[1]) 
   &&(((closeBuffer[1]-openBuffer[1])*2) < (highBuffer[1] - closeBuffer[1]))
   && ((openBuffer[1]-lowBuffer[1]) < ((closeBuffer[1]-openBuffer[1])/2) )  
   )
{
       tmpPattern.Type=InvertedHammer;
       tmpPattern.position=Sell;
       tmpPattern.drawPos =lowBuffer[1];
       tmpPattern.time = timeBuffer[1];
       tmpPattern.patternLow = lowBuffer[1];
       tmpPattern.patternHigh= highBuffer[1];
       
       ArrayResize(foundPatterns,ArraySize(foundPatterns)+1,0);
       foundPatterns[ArraySize(foundPatterns)-1]=tmpPattern;
}

}