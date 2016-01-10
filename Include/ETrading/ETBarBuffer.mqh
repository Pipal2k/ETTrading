//+------------------------------------------------------------------+
//|                                                  ETBarBuffer.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict


struct Buffers
{
double LowBuffer[];
double HighBuffer[];
double OpenBuffer[];
double CloseBuffer[];
datetime TimeBuffer[];

long VolumeBuffer[];

double RSIBuffer[];
double ATRBuffer[];

/*double LowBandBuffer[];
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
      ArraySetAsSeries(buffer.RSIBuffer,asSerie);
      ArraySetAsSeries(buffer.ATRBuffer,asSerie); 
          
      
     //MA200DifPeriods ma200p;
      
     ArrayFree(buffer.HighBuffer);
     ArrayFree(buffer.LowBuffer);
     ArrayFree(buffer.OpenBuffer);
     ArrayFree(buffer.CloseBuffer);
     ArrayFree(buffer.TimeBuffer);
     ArrayFree(buffer.RSIBuffer);
       ArrayFree(buffer.ATRBuffer);
     //ArrayFree(ma200p.CurrentMABuffer);
    // ArrayFree(ma200p.OneAboveMABuffer);
     //ArrayFree(ma200p.TwoAboveBuffer);
     //ArrayFree(buffer.HighBandBuffer);
     //ArrayFree(buffer.LowBandBuffer);
     //ArrayFree(buffer.STOCHBuffer);
     ArrayFree(buffer.VolumeBuffer);
      
     initRSIBuffer(buffer.RSIBuffer,timeframe,count,asSerie);
     initATRBuffer(buffer.ATRBuffer,timeframe,count,asSerie);
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

void CopyBuffer(Buffers &destBuffer,int start,int count,Buffers &srcBuffer, bool asSerie)
{
   
     
   
   ArrayCopy(destBuffer.CloseBuffer,srcBuffer.CloseBuffer,0,start,count);
   ArrayCopy(destBuffer.HighBuffer,srcBuffer.HighBuffer,0,start,count);
   ArrayCopy(destBuffer.LowBuffer,srcBuffer.LowBuffer,0,start,count);
   ArrayCopy(destBuffer.OpenBuffer,srcBuffer.OpenBuffer,0,start,count);
   ArrayCopy(destBuffer.TimeBuffer,srcBuffer.TimeBuffer,0,start,count);
   ArrayCopy(destBuffer.RSIBuffer,srcBuffer.RSIBuffer,0,start,count);
   ArrayCopy(destBuffer.ATRBuffer,srcBuffer.ATRBuffer,0,start,count);
}

void initRSIBuffer(double &RSIBufferParam[], int timeframe,int count, bool asSerie)
{
  double rsi;
 
   for(int i=0;i < count;i++)
   {
      if(asSerie)
         rsi = iRSI(NULL,timeframe,14,PRICE_CLOSE,i);
       if(!asSerie)
         rsi =  iRSI(NULL,timeframe,14,PRICE_CLOSE,count-(i+1)); 
      
      ArrayResize(RSIBufferParam,ArraySize(RSIBufferParam)+1,0);
      RSIBufferParam[i]=rsi;
      
   }
}

void initATRBuffer(double &ARTRBufferParam[], int timeframe,int count, bool asSerie)
{
  double atr;
 
   for(int i=0;i < count;i++)
   {
      if(asSerie)
         atr = iATR(NULL,timeframe,14,i);
       if(!asSerie)
         atr =  iATR(NULL,timeframe,14,count-(i+1));
      
      ArrayResize(ARTRBufferParam,ArraySize(ARTRBufferParam)+1,0);
      ARTRBufferParam[i]=atr;
      
   }
}

