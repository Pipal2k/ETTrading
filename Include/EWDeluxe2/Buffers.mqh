//+------------------------------------------------------------------+
//|                                                      Buffers.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict
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
struct Buffers
{
double LowBuffer[];
double HighBuffer[];
double OpenBuffer[];
double CloseBuffer[];
datetime TimeBuffer[];

long VolumeBuffer[];

/*double RSIBuffer[];
double LowBandBuffer[];
double HighBandBuffer[];
double STOCHBuffer[];
double STOCHBufferSignal[];
double STOCHBufferValue[];

double CurrentMABuffer[];
double OneAboveMABuffer[];
double TwoAboveBuffer[];

long avgVolume;

double avgStdv;*/
};

void initBuffers(Buffers &buffer,datetime startDate,int count,int timeframe, bool asSerie)
{
  // if(!ArrayIsSeries(buffer.LowBuffer) && asSerie)
      ArraySetAsSeries(buffer.LowBuffer,asSerie);
   //if(!ArrayIsSeries(buffer.HighBuffer) && asSerie)   
      ArraySetAsSeries(buffer.HighBuffer,asSerie);
   //if(!ArrayIsSeries(buffer.OpenBuffer) && asSerie)
      ArraySetAsSeries(buffer.OpenBuffer,asSerie);
   //if(!ArrayIsSeries(buffer.CloseBuffer) && asSerie)   
      ArraySetAsSeries(buffer.CloseBuffer,asSerie);
   //if(!ArrayIsSeries(buffer.TimeBuffer) && asSerie)   
      ArraySetAsSeries(buffer.TimeBuffer,asSerie);
    /*if(!ArrayIsSeries(buffer.HighBandBuffer))
      ArraySetAsSeries(buffer.HighBandBuffer,true);
    if(!ArrayIsSeries(buffer.LowBandBuffer))
      ArraySetAsSeries(buffer.LowBandBuffer,true); */
    //if(!ArrayIsSeries(buffer.VolumeBuffer))
      ArraySetAsSeries(buffer.VolumeBuffer,asSerie); 
          
      
     //MA200DifPeriods ma200p;
      
     ArrayFree(buffer.HighBuffer);
     ArrayFree(buffer.LowBuffer);
     ArrayFree(buffer.OpenBuffer);
     ArrayFree(buffer.CloseBuffer);
     ArrayFree(buffer.TimeBuffer);
     //ArrayFree(buffer.RSIBuffer);
     //ArrayFree(ma200p.CurrentMABuffer);
    // ArrayFree(ma200p.OneAboveMABuffer);
     //ArrayFree(ma200p.TwoAboveBuffer);
     //ArrayFree(buffer.HighBandBuffer);
     //ArrayFree(buffer.LowBandBuffer);
     //ArrayFree(buffer.STOCHBuffer);
     ArrayFree(buffer.VolumeBuffer);
      
     //initRSIBuffer(shift,buffer.RSIBuffer,timeframe);
     //initHighBandBuffer(shift,buffer.HighBandBuffer,timeframe);
     //initLowBandBuffer(shift,buffer.LowBandBuffer,timeframe);
     //initSTOCHBuffer(shift,buffer.STOCHBuffer,timeframe);
     //buffer.avgVolume= calculateVOLUMEAverage(shift);
     //buffer.avgStdv = calculateSTDVAvg(shift);
     
     CopyHigh(Symbol(),timeframe,startDate,count,buffer.HighBuffer);
     CopyLow(Symbol(),timeframe,startDate,count,buffer.LowBuffer);
     CopyOpen(Symbol(),timeframe,startDate,count,buffer.OpenBuffer);
     CopyClose(Symbol(),timeframe,startDate,count,buffer.CloseBuffer);
     CopyTime(Symbol(),timeframe,startDate,count,buffer.TimeBuffer);
     
     //Print("TimeBuffer:"+ buffer.TimeBuffer[0]); 
     CopyTickVolume(NULL,timeframe,startDate,count,buffer.VolumeBuffer);
     
     //initMA200DifStruct(buffer.TimeBuffer[1],ma200p);
     
     //ArrayCopy(buffer.CurrentMABuffer,ma200p.CurrentMABuffer);
     //ArrayCopy(buffer.OneAboveMABuffer,ma200p.OneAboveMABuffer);
     //ArrayCopy(buffer.TwoAboveBuffer,ma200p.TwoAboveBuffer);
     
     return;
}

void CopyBuffer(Buffers &destBuffer,int start,int count,Buffers &srcBuffer)
{
   ArrayCopy(destBuffer.CloseBuffer,srcBuffer.CloseBuffer,0,start,count);
   ArrayCopy(destBuffer.HighBuffer,srcBuffer.HighBuffer,0,start,count);
   ArrayCopy(destBuffer.LowBuffer,srcBuffer.LowBuffer,0,start,count);
   ArrayCopy(destBuffer.OpenBuffer,srcBuffer.OpenBuffer,0,start,count);
   ArrayCopy(destBuffer.TimeBuffer,srcBuffer.TimeBuffer,0,start,count);
}
