//+------------------------------------------------------------------+
//|                                                  initBuffers.mqh |
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

void initBuffers(Buffers &buffer,int shift, int timeframe)
{
   if(!ArrayIsSeries(buffer.LowBuffer))
      ArraySetAsSeries(buffer.LowBuffer,true);
   if(!ArrayIsSeries(buffer.HighBuffer))   
      ArraySetAsSeries(buffer.HighBuffer,true);
   if(!ArrayIsSeries(buffer.OpenBuffer))
      ArraySetAsSeries(buffer.OpenBuffer,true);
   if(!ArrayIsSeries(buffer.CloseBuffer))   
      ArraySetAsSeries(buffer.CloseBuffer,true);
   if(!ArrayIsSeries(buffer.TimeBuffer))   
      ArraySetAsSeries(buffer.TimeBuffer,true);
    if(!ArrayIsSeries(buffer.HighBandBuffer))
      ArraySetAsSeries(buffer.HighBandBuffer,true);
    if(!ArrayIsSeries(buffer.LowBandBuffer))
      ArraySetAsSeries(buffer.LowBandBuffer,true); 
    if(!ArrayIsSeries(buffer.VolumeBuffer))
      ArraySetAsSeries(buffer.VolumeBuffer,true); 
          
      
     MA200DifPeriods ma200p;
      
     ArrayFree(buffer.HighBuffer);
     ArrayFree(buffer.LowBuffer);
     ArrayFree(buffer.OpenBuffer);
     ArrayFree(buffer.CloseBuffer);
     ArrayFree(buffer.TimeBuffer);
     ArrayFree(buffer.RSIBuffer);
     ArrayFree(ma200p.CurrentMABuffer);
     ArrayFree(ma200p.OneAboveMABuffer);
     ArrayFree(ma200p.TwoAboveBuffer);
     ArrayFree(buffer.HighBandBuffer);
     ArrayFree(buffer.LowBandBuffer);
     ArrayFree(buffer.STOCHBuffer);
     ArrayFree(buffer.VolumeBuffer);
      
     initRSIBuffer(shift,buffer.RSIBuffer,timeframe);
     initHighBandBuffer(shift,buffer.HighBandBuffer,timeframe);
     initLowBandBuffer(shift,buffer.LowBandBuffer,timeframe);
     initSTOCHBuffer(shift,buffer.STOCHBuffer,timeframe);
     buffer.avgVolume= calculateVOLUMEAverage(shift);
     buffer.avgStdv = calculateSTDVAvg(shift);
     
     CopyHigh(NULL,timeframe,shift,5,buffer.HighBuffer);
     CopyLow(NULL,timeframe,shift,5,buffer.LowBuffer);
     CopyOpen(NULL,timeframe,shift,5,buffer.OpenBuffer);
     CopyClose(NULL,timeframe,shift,100,buffer.CloseBuffer);
     CopyTime(NULL,timeframe,shift,5,buffer.TimeBuffer);
     CopyTickVolume(NULL,timeframe,shift,5,buffer.VolumeBuffer);
     
     initMA200DifStruct(buffer.TimeBuffer[1],ma200p);
     
     ArrayCopy(buffer.CurrentMABuffer,ma200p.CurrentMABuffer);
     ArrayCopy(buffer.OneAboveMABuffer,ma200p.OneAboveMABuffer);
     ArrayCopy(buffer.TwoAboveBuffer,ma200p.TwoAboveBuffer);
     
     return;
}

int getNextTimeFrame(int timeframe)
  {
   switch(timeframe)
     {
      case PERIOD_M1:
         return PERIOD_M5;
         break;
      case PERIOD_M5:
         return PERIOD_M15;
         break;
      case PERIOD_M15:
         return PERIOD_M30;
         break;
      case PERIOD_M30:
         return PERIOD_H1;
         break;
      case PERIOD_H1:
         return PERIOD_H4;
         break;
      case PERIOD_H4:
         return PERIOD_D1;
         break;
      case PERIOD_D1:
         return PERIOD_W1;
         break;
      case PERIOD_W1:
         return PERIOD_MN1;
         break;
      default:
         return PERIOD_CURRENT;
     }
  }

void initRSIBuffer(int shift,double &RSIBufferParam[], int timeframe)
{
  double rsi;
 
   for(int i=0;i< 5;i++)
   {
      rsi = iRSI(NULL,timeframe,14,PRICE_CLOSE,i+shift);
      
      ArrayResize(RSIBufferParam,ArraySize(RSIBufferParam)+1,0);
      RSIBufferParam[i]=rsi;
      
   }
}

void initSTOCHBuffer(int shift,double &STOCHBufferParam[], int timeframe)
{
  double stoch;
 
   for(int i=0;i< 5;i++)
   {
      stoch = iStochastic(NULL,timeframe,9,6,6,MODE_SMA,0,MODE_MAIN,i+shift);
      
      ArrayResize(STOCHBufferParam,ArraySize(STOCHBufferParam)+1,0);
      STOCHBufferParam[i]=stoch;
      
   }
}

void initLowBandBuffer(int shift,double &LowBandBuffer[],int timeframe)
{
  double bandL;
  
   for(int i=0;i< 5;i++)
   {
      bandL = iBands(NULL,timeframe,20,2,0,PRICE_CLOSE,MODE_LOWER,shift+i);;
      
      ArrayResize(LowBandBuffer,ArraySize(LowBandBuffer)+1,0);
      LowBandBuffer[i]=bandL;
      
   }
}

void initHighBandBuffer(int shift,double &HighBandBuffer[], int timeframe)
{
  double bandH;
 
   for(int i=0;i< 5;i++)
   {
      bandH = iBands(NULL,timeframe,20,2,0,PRICE_CLOSE,MODE_UPPER,shift+i);;
      
      ArrayResize(HighBandBuffer,ArraySize(HighBandBuffer)+1,0);
      HighBandBuffer[i]=bandH;
      
   }
}

void initMA200Buffer(int shift,double &MA200Buffer[],int timeframe)
{
  double MA200;
 
   for(int i=0;i< 5;i++)
   {
      MA200=iMA(NULL,timeframe,200,0,MODE_EMA,PRICE_CLOSE,shift+i);
      
      ArrayResize(MA200Buffer,ArraySize(MA200Buffer)+1,0);
      MA200Buffer[i]=MA200;
      
   }
}

void initMA200DifStruct(datetime current_time,MA200DifPeriods &ma200p)
{
   int currentshift= iBarShift(Symbol(),Period(),current_time);
   int shiftOneAbove=iBarShift(Symbol(),getNextTimeFrame(Period()),current_time);
   int shiftTwoAbove=iBarShift(Symbol(),getNextTimeFrame(getNextTimeFrame(Period())),current_time);
   
   initMA200Buffer(currentshift,ma200p.CurrentMABuffer,Period());
   initMA200Buffer(shiftOneAbove,ma200p.OneAboveMABuffer,getNextTimeFrame(Period()));
   initMA200Buffer(shiftTwoAbove,ma200p.TwoAboveBuffer,getNextTimeFrame(getNextTimeFrame(Period())));  
}

double calculateSTDVAvg(int shift)
  {
   double val=0.0;
   double highestValue=0.0;

   for(int i=shift; i < (shift+250);i++)
     {
      val=iStdDev(Symbol(),Period(),20,0,MODE_SMA,PRICE_CLOSE,i);

       if(val>highestValue)
         highestValue=val;

     }

   return((highestValue/250))*125;

   //Print("lowest Value: ",lowestValue," highest Value: ",highestValue," StdvOpt: ",stdvOpt);
  }

  
  double calculateVOLUMEAverage(int shift)
  {
   double val=0.0;
   double lowestValue=Volume[shift];
   double highestValue=Volume[shift];

   for(int i=shift; i < (shift+100);i++)
     {
       if(Volume[i] > highestValue)
         highestValue = Volume[i];
       if(Volume[i] < lowestValue)
         lowestValue = Volume[i];
      //val+=Volume[i];
     }

   return ((lowestValue)) * 10.0;

   //Print("VolumeOpt: ",volumeOpt," Val: ",val);
  }
  
