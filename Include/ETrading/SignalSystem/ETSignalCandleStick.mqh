//+------------------------------------------------------------------+
//|                                           CandleStickPattern.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict
//+------------------------------------------------------------------+
//|                                                 PositionEnum.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+


//#include <EWDeluxe2\Enums.mqh>
#include <ETrading/ETDataTypes.mqh>
#include <ETrading/ETBarBuffer.mqh>
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

enum CandleStickType {
BearishEngulfing,
BullishEngulfing,
ThreeSoldiers,
ThreeDarkCloud,
Hammer,
InvertedHammer
};

struct CandleStickPattern {
   CandleStickType Type;
   Position position;
   datetime time;
   double patternHigh;
   double patternLow;
   double triggerClosePrice; //for finding next Pivot
   double drawPos;  
};


void findCandleStickPattern(Buffers &buffer,CandleStickPattern &foundPatterns[])
{
 
 
 ArrayFree(foundPatterns);
 
 
  fBullishEngulfing(buffer.HighBuffer,buffer.LowBuffer,buffer.OpenBuffer,buffer.CloseBuffer,buffer.TimeBuffer,foundPatterns);
 
  fBearishEngulfing(buffer.HighBuffer,buffer.LowBuffer,buffer.OpenBuffer,buffer.CloseBuffer,buffer.TimeBuffer,foundPatterns);
 
  threeSoldiers(buffer.OpenBuffer,buffer.CloseBuffer,buffer.TimeBuffer,buffer.LowBuffer,buffer.HighBuffer,foundPatterns);
 
  threeDarkCloud(buffer.OpenBuffer,buffer.CloseBuffer,buffer.TimeBuffer,buffer.LowBuffer,buffer.HighBuffer,foundPatterns);
 
  Hammer(buffer.OpenBuffer,buffer.CloseBuffer,buffer.TimeBuffer,buffer.LowBuffer,buffer.HighBuffer,foundPatterns);
  
  InvertedHammer(buffer.OpenBuffer,buffer.CloseBuffer,buffer.TimeBuffer,buffer.LowBuffer,buffer.HighBuffer,foundPatterns);
 
  
       

  
 return;
}

void  fBullishEngulfing(double &highBuffer[],double &lowBuffer[], double &openBuffer[], double &closeBuffer[],datetime &timeBuffer[],CandleStickPattern &foundPatterns[])
{
    CandleStickPattern tmpPattern;    
   if(   closeBuffer[1]>=openBuffer[0] && openBuffer[1]<=closeBuffer[0] 
      && closeBuffer[1]<closeBuffer[0] && openBuffer[1]>openBuffer[0]
      && ((openBuffer[1]-closeBuffer[1])>=((closeBuffer[0]-openBuffer[0])/2))
      && ((openBuffer[1]-closeBuffer[1]) > (highBuffer[1] - openBuffer[1]))
      && ((closeBuffer[0]- openBuffer[0]) > (highBuffer[0] - closeBuffer[0])))
     // && (VolumeBuffer[1] > avgVolume && VolumeBuffer[2] > avgVolume))
     {
       tmpPattern.Type=BullishEngulfing;
       tmpPattern.position=Buy; 
       tmpPattern.drawPos =lowBuffer[0];
       tmpPattern.time = timeBuffer[1];
       tmpPattern.patternLow = lowBuffer[0];
       tmpPattern.patternHigh= highBuffer[0];
       tmpPattern.triggerClosePrice=closeBuffer[0];
       
       ArrayResize(foundPatterns,ArraySize(foundPatterns)+1,0);
       foundPatterns[ArraySize(foundPatterns)-1]=tmpPattern;
     }
     
    return;
}


void  fBearishEngulfing(double &highBuffer[],double &lowBuffer[], double &openBuffer[], double &closeBuffer[],datetime &timeBuffer[], CandleStickPattern &foundPatterns[])
{
    CandleStickPattern tmpPattern; 
       
    if((closeBuffer[1]<=openBuffer[0] && closeBuffer[0]<=openBuffer[1]) 
        && closeBuffer[1]>closeBuffer[0] && openBuffer[1]<openBuffer[0]
        && ((closeBuffer[1]-openBuffer[1])>=((openBuffer[0]-closeBuffer[0])/2))
        && (closeBuffer[1]-openBuffer[1] >  openBuffer[1] - lowBuffer[1])
        && (openBuffer[0]-closeBuffer[0] > closeBuffer[0] - lowBuffer[0]))
       //&& (VolumeBuffer[1] > avgVolume && VolumeBuffer[2] > avgVolume))
     {
       tmpPattern.Type=BearishEngulfing;
       tmpPattern.position=Sell;
       tmpPattern.drawPos =lowBuffer[0];
       tmpPattern.time = timeBuffer[1];
       tmpPattern.patternLow = lowBuffer[0];
       tmpPattern.patternHigh= highBuffer[0];
       tmpPattern.triggerClosePrice=closeBuffer[0];
       
       ArrayResize(foundPatterns,ArraySize(foundPatterns)+1,0);
       foundPatterns[ArraySize(foundPatterns)-1]=tmpPattern;
      // Print("closeBuffer2: ",closeBuffer[1], " Open1: ",openBuffer[0]," Open2: ",openBuffer[1]," closeBuffer1: ",closeBuffer[0]);
     }
     
    return;
}

void threeSoldiers(double &openBuffer[],double &closeBuffer[],datetime &timeBuffer[],double &lowBuffer[],double &highBuffer[],CandleStickPattern &foundPatterns[])
{
CandleStickPattern tmpPattern;
 
if((openBuffer[2]<closeBuffer[2] && openBuffer[1]<closeBuffer[1] && openBuffer[0]<closeBuffer[0])
      && (openBuffer[1]>openBuffer[2] && openBuffer[0]>openBuffer[1])
      && (closeBuffer[1]>closeBuffer[2] && closeBuffer[0]>closeBuffer[1])
      &&  (closeBuffer[2] - openBuffer[2] > highBuffer[2]-closeBuffer[2] )
      &&  (closeBuffer[1] - openBuffer[1] > highBuffer[1]-closeBuffer[1] ) 
      && (closeBuffer[0] - openBuffer[0] > highBuffer[0]-closeBuffer[0] ))
      //&& (VolumeBuffer[1] > avgVolume && VolumeBuffer[2] > avgVolume && VolumeBuffer[3] > avgVolume))
     {
         tmpPattern.Type=ThreeSoldiers;
       tmpPattern.position=Buy;
       tmpPattern.drawPos =lowBuffer[0];
       tmpPattern.time = timeBuffer[1];
       tmpPattern.patternLow = lowBuffer[2];
       tmpPattern.patternHigh= highBuffer[0];
       tmpPattern.triggerClosePrice=closeBuffer[0];
       
       ArrayResize(foundPatterns,ArraySize(foundPatterns)+1,0);
       foundPatterns[ArraySize(foundPatterns)-1]=tmpPattern;
    
     }

}

void threeDarkCloud(double &openBuffer[],double &closeBuffer[],datetime &timeBuffer[],double &lowBuffer[],double &highBuffer[],CandleStickPattern &foundPatterns[])
{
CandleStickPattern tmpPattern;

   if((closeBuffer[2]<openBuffer[2] && closeBuffer[1]<openBuffer[1] && closeBuffer[0]< openBuffer[0])
      && (openBuffer[1]<openBuffer[2] && openBuffer[0]<openBuffer[1])
      && (closeBuffer[1]<closeBuffer[2] && closeBuffer[0]<closeBuffer[1])
      && (openBuffer[2]-closeBuffer[2]> closeBuffer[2] - lowBuffer[2])
      && (openBuffer[1]-closeBuffer[1]> closeBuffer[1] - lowBuffer[1])
      && (openBuffer[0]-closeBuffer[0]> closeBuffer[0] - lowBuffer[0]) )
      //&& (VolumeBuffer[1] > avgVolume && VolumeBuffer[2] > avgVolume && VolumeBuffer[3] > avgVolume))
     {
       tmpPattern.Type=ThreeDarkCloud;
       tmpPattern.position=Sell;
       tmpPattern.drawPos =lowBuffer[0];
       tmpPattern.time = timeBuffer[1];
       tmpPattern.patternLow = lowBuffer[2];
       tmpPattern.patternHigh= highBuffer[0];
       tmpPattern.triggerClosePrice=closeBuffer[0];
       
       ArrayResize(foundPatterns,ArraySize(foundPatterns)+1,0);
       foundPatterns[ArraySize(foundPatterns)-1]=tmpPattern;
     }

}

void Hammer(double &openBuffer[],double &closeBuffer[],datetime &timeBuffer[],double &lowBuffer[],double &highBuffer[],CandleStickPattern &foundPatterns[])
{
CandleStickPattern tmpPattern;

if((lowBuffer[0]< openBuffer[0]  && closeBuffer[0] > openBuffer[0] 
   &&  (((closeBuffer[0]-openBuffer[0])*2) < (openBuffer[0] - lowBuffer[0])) 
   && ((highBuffer[0]-closeBuffer[0]) < ((closeBuffer[0]-openBuffer[0])/2) ))
   ||
   ( lowBuffer[0]< closeBuffer[0]  && closeBuffer[0] < openBuffer[0]) 
   &&(((openBuffer[0]-closeBuffer[0])*2) < (closeBuffer[0] - lowBuffer[0]))
   && ((highBuffer[0]-openBuffer[0]) < ((openBuffer[0]-closeBuffer[0])/2) )  )
{
    tmpPattern.Type=Hammer;
       tmpPattern.position=Buy;
       tmpPattern.drawPos =lowBuffer[0];
       tmpPattern.time = timeBuffer[1];
       tmpPattern.patternLow = lowBuffer[0];
       tmpPattern.patternHigh= highBuffer[0];
       
       if(closeBuffer[0] > openBuffer[0])
         tmpPattern.triggerClosePrice=closeBuffer[0];
       else
         tmpPattern.triggerClosePrice=openBuffer[0];  
       
       ArrayResize(foundPatterns,ArraySize(foundPatterns)+1,0);
       foundPatterns[ArraySize(foundPatterns)-1]=tmpPattern;
}

}

void InvertedHammer(double &openBuffer[],double &closeBuffer[],datetime &timeBuffer[],double &lowBuffer[],double &highBuffer[],CandleStickPattern &foundPatterns[])
{
CandleStickPattern tmpPattern;

if((highBuffer[0]> openBuffer[0]  && openBuffer[0] > closeBuffer[0] 
   &&  (((openBuffer[0]-closeBuffer[0])*2) < (highBuffer[0] - openBuffer[0])) 
   && ((closeBuffer[0]-lowBuffer[0]) < ((openBuffer[0]-closeBuffer[0])/2) ))
   ||
   ( highBuffer[0] > closeBuffer[0]  && closeBuffer[0] > openBuffer[0]) 
   &&(((closeBuffer[0]-openBuffer[0])*2) < (highBuffer[0] - closeBuffer[0]))
   && ((openBuffer[0]-lowBuffer[0]) < ((closeBuffer[0]-openBuffer[0])/2) )  
   )
{
       tmpPattern.Type=InvertedHammer;
       tmpPattern.position=Sell;
       tmpPattern.drawPos =lowBuffer[0];
       tmpPattern.time = timeBuffer[1];
       tmpPattern.patternLow = lowBuffer[0];
       tmpPattern.patternHigh= highBuffer[0];
       
       if(closeBuffer[0] > openBuffer[0])
         tmpPattern.triggerClosePrice=openBuffer[0];
       else
         tmpPattern.triggerClosePrice=closeBuffer[0];  
       
       ArrayResize(foundPatterns,ArraySize(foundPatterns)+1,0);
       foundPatterns[ArraySize(foundPatterns)-1]=tmpPattern;
}

}