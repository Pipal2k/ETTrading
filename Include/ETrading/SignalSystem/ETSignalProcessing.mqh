//+------------------------------------------------------------------+
//|                                           ETSignalProcessing.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict
#include <ETrading/ETBarBuffer.mqh>
#include <ETrading/ETDataTypes.mqh>
#include <ETrading/DataProviderSystem/ETDataProviderSystem.mqh>
#include <ETrading/SignalSystem/ETSignalCandleStick.mqh>
//#include <ETrading/DataProviderSystem/ETIndikatorInfos.mqh>
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

void process(Buffers &buffer, ETSignal &currentSIgnals[],ProvidedData &provData,ETSignal &lastSignal, int SignalSystemOptions)
{
   ArrayFree(currentSIgnals);
   
   
   
   for(int i = 0; i < ArraySize(buffer.TimeBuffer); i++)
   {
     
      MetaInfo mInfo;
      MetaInfo lastMetaInfo;
      int sig=0;
      
      
      //Buffers tmpBufferONE;
      Buffers tmpBufferThree;
      CopyBuffer(mInfo.buffer,i,1,buffer,false);
      //CopyBuffer(tmpBufferThree,i,3,buffer,true);
      initBuffers(tmpBufferThree,buffer.TimeBuffer[i],3,Period(),true);
      
      
      if(ArraySize(currentSIgnals) > 0)
      {
        copyMetaInfo(currentSIgnals[i-1].metaInfo,lastMetaInfo);
      }
      else
         copyMetaInfo(lastSignal.metaInfo,lastMetaInfo); 
         
      
      if(checkSIG_BARBULLISH(tmpBufferThree))
         sig |= SIG_BARBULLISH;
       
       if(checkSIG_BARBEARSIH(tmpBufferThree))
         sig |= SIG_BARBEARISH; 
       

       if(checkSIG_SR_TOUCHLOWERBOUNDERY(tmpBufferThree,provData.zones,sig,mInfo,lastMetaInfo,SignalSystemOptions))
           sig |= SIG_SR_TOUCHLOWERBOUNDERY;
         
        if(checkSIG_SR_TOUCHHIGHERBOUNDERY(tmpBufferThree,provData.zones,sig,mInfo,lastMetaInfo,SignalSystemOptions))
           sig |= SIG_SR_TOUCHHIGHERBOUNDERY;
             
       if(checkSIG_SR_BREAKTHROUGHBEARISH(tmpBufferThree,provData.zones,sig,mInfo,lastMetaInfo,SignalSystemOptions))
         sig |= SIG_SR_BREAKTHROUGHBEARISH;
       //}    
         
       if(checkSIG_SR_TOUCHBEARISH(tmpBufferThree,provData.zones,sig,SignalSystemOptions))
         sig |= SIG_SR_TOUCHBEARISH;
         
       if(checkSIG_SR_BREAKTHROUGHBULLISH(tmpBufferThree,provData.zones,sig,mInfo,lastMetaInfo,SignalSystemOptions))
         sig |= SIG_SR_BREAKTHROUGHBULLISH; 
         
       if(checkSIG_SR_TOUCHBULLISH(tmpBufferThree,provData.zones,sig,SignalSystemOptions))
         sig |= SIG_SR_TOUCHBULLISH;   
         
         
        CandleStickPattern cPatterns[]; 
        findCandleStickPattern(tmpBufferThree,cPatterns);
        setCandleStickSignal(cPatterns,sig);
           
         
           
      sig |= SIG_ANY;
      
      
      
      
      if(sig > 0)
      {
         ArrayResize(currentSIgnals,ArraySize(currentSIgnals)+1,0);
         currentSIgnals[ArraySize(currentSIgnals)-1].sig_flags=sig;
         currentSIgnals[ArraySize(currentSIgnals)-1].time=buffer.TimeBuffer[i];
         
         mInfo.RSI=buffer.RSIBuffer[i];
         //mInfo.open=buffer.OpenBuffer[i];
         //Print(buffer.TimeBuffer[i] +" "+tmpBufferThree.OpenBuffer[0]);
         //Print(tmpBufferThree.TimeBuffer[i] +" "+tmpBufferThree.OpenBuffer[2]);
         CopyBuffer(mInfo.buffer,i,1,tmpBufferThree,false);
        
         copyMetaInfo(mInfo,  currentSIgnals[ArraySize(currentSIgnals)-1].metaInfo);
         
         
         //currentSIgnals[ArraySize(currentSIgnals)-1].metaInfo=mIn;
      }
   }
   
}


void setCandleStickSignal(CandleStickPattern &cPatterns[],int &signal)
{


bool bearishSig = false;
bool bullishSig = false;

  for(int i=0; i < ArraySize(cPatterns); i++)
  {
      if(cPatterns[i].Type == BearishEngulfing)
      {
         signal |= SIG_CS_BEARISHENGULFING;
         bearishSig = true;
      }
      else if(cPatterns[i].Type == BullishEngulfing)
      {
         signal |= SIG_CS_BULLISHENGULFING;
         bullishSig = true;
      }
      else if(cPatterns[i].Type == ThreeSoldiers)
      {
         signal |= SIG_CS_THREESOLDIERS; 
         bullishSig = true;
      }
       else if(cPatterns[i].Type == ThreeDarkCloud)
      {
         signal |= SIG_CS_THREEDARKCLOUD;
         bearishSig = true;
      }
       else if(cPatterns[i].Type == Hammer)
      {
         signal |= SIG_CS_HAMMER;
         bullishSig = true;
      }
       else if(cPatterns[i].Type == InvertedHammer)
      {
        signal |= SIG_CS_INVERTEDHAMMER;
         bearishSig = true;
      }
      
  }
  
  if(bearishSig)
   signal |= SIG_BEARISHCANDLESTICK;
  
  if(bullishSig)
   signal |= SIG_BULLISHCADLESTICK; 
   
}


// SIG_BARBULLISH
bool checkSIG_BARBULLISH(Buffers &buffer)
{
   bool result= false;
     
   if(buffer.OpenBuffer[0] < buffer.CloseBuffer[0])
     result=true;
     
   return result;   
}

// SIG_BARBEARISH
bool checkSIG_BARBEARSIH(Buffers &buffer)
{
   bool result= false;
   
   if(buffer.OpenBuffer[0] > buffer.CloseBuffer[0])
     result=true;
     
   return result;   
}

bool checkSIG_SR_TOUCHLOWERBOUNDERY(Buffers &buffer,SR_Zone &zones[],int sig, MetaInfo &Info, MetaInfo &lastInfo,int SignalSystemOptions)
{
  bool result = false;
  
   for(int i = 0; i < ArraySize(zones); i++)
   {
     
     if( (sig & SIG_BARBEARISH && buffer.CloseBuffer[0] > zones[i].LowBorder - (25*Point) && buffer.CloseBuffer[0] < zones[i].LowBorder + (25*Point)) 
         || (sig & SIG_BARBULLISH && buffer.CloseBuffer[0] < zones[i].LowBorder +(25*Point) && buffer.CloseBuffer[0] > zones[i].LowBorder-(25*Point) )) 
      {
         ArrayResize(Info.iSIG_SR_TOUCHLOWERBOUNDERY,ArraySize(Info.iSIG_SR_TOUCHLOWERBOUNDERY)+1,0);
         //copySRZones(zones[i],Info.SR_BREAKS[ArraySize(Info.SR_BREAKS)-1]);
         Info.iSIG_SR_TOUCHLOWERBOUNDERY[ArraySize(Info.iSIG_SR_TOUCHLOWERBOUNDERY)-1]= zones[i];
         
         result=true;
       break;
      }
  
   }
  
  
  return result;
}

bool checkSIG_SR_TOUCHHIGHERBOUNDERY(Buffers &buffer,SR_Zone &zones[],int sig, MetaInfo &Info, MetaInfo &lastInfo,int SignalSystemOptions)
{
  bool result = false;
  
   for(int i = 0; i < ArraySize(zones); i++)
   {
     
     if( (sig & SIG_BARBEARISH && buffer.CloseBuffer[0] > zones[i].HighBorder - (20*Point) && buffer.CloseBuffer[0] < zones[i].HighBorder + (20*Point)) 
         || (sig & SIG_BARBULLISH && buffer.CloseBuffer[0] < zones[i].HighBorder +(20*Point) && buffer.CloseBuffer[0] > zones[i].HighBorder-(20*Point) )) 
      {
         ArrayResize(Info.iSIG_SR_TOUCHHIGHERBOUNDERY,ArraySize(Info.iSIG_SR_TOUCHHIGHERBOUNDERY)+1,0);
         //copySRZones(zones[i],Info.SR_BREAKS[ArraySize(Info.SR_BREAKS)-1]);
         Info.iSIG_SR_TOUCHHIGHERBOUNDERY[ArraySize(Info.iSIG_SR_TOUCHHIGHERBOUNDERY)-1]= zones[i];
         
         result=true;
       break;
      } 
   }
  return result;
}

bool checkSIG_SR_BREAKTHROUGHBEARISH(Buffers &buffer,SR_Zone &zones[],int sig, MetaInfo &Info, MetaInfo &lastInfo,int SignalSystemOptions)
{
  bool result = false;
  
  if(sig & SIG_BARBEARISH)
  {
   for(int i = 0; i < ArraySize(zones); i++)
   {
     if( ((zones[i].SRType & MIDPIVOT) && (SignalSystemOptions & USE_MIDPIVOTS)) || (!(zones[i].SRType & MIDPIVOT)))
     {   
        
        if( ((buffer.OpenBuffer[1] > zones[i].LowBorder && buffer.CloseBuffer[0] < zones[i].LowBorder -(20*Point))
           || (buffer.OpenBuffer[0] > zones[i].LowBorder && buffer.CloseBuffer[0] < zones[i].LowBorder -(20*Point)))
           && !notHitSRLastTime(zones[i],lastInfo.iSIG_SR_BREAKTHROUGHBEARISH))
         {
           
            ArrayResize(Info.iSIG_SR_BREAKTHROUGHBEARISH,ArraySize(Info.iSIG_SR_BREAKTHROUGHBEARISH)+1,0);
            //copySRZones(zones[i],Info.SR_BREAKS[ArraySize(Info.SR_BREAKS)-1]);
            Info.iSIG_SR_BREAKTHROUGHBEARISH[ArraySize(Info.iSIG_SR_BREAKTHROUGHBEARISH)-1]= zones[i];
            
            result=true;
            break;
         }
     }
     
   
  
   }
  }
  
  return result;

}

/*bool checkSIG_SR_BREAKTHROUGHBEARISH(Buffers &buffer,SR_Zone &zones[],int sig, MetaInfo &Info, MetaInfo &lastInfo,int SignalSystemOptions)
{
  bool result = false;
  
  if(sig & SIG_BARBEARISH)
  {
   for(int i = 0; i < ArraySize(zones); i++)
   {
     
        
        if( ((buffer.OpenBuffer[1] > zones[i].LowBorder && buffer.CloseBuffer[0] < zones[i].LowBorder -(20*Point))
           || (buffer.OpenBuffer[0] > zones[i].LowBorder && buffer.CloseBuffer[0] < zones[i].LowBorder -(20*Point)))
           && !notHitSRLastTime(zones[i],lastInfo.iSIG_SR_BREAKTHROUGHBEARISH))
         {
           
            ArrayResize(Info.iSIG_SR_BREAKTHROUGHBEARISH,ArraySize(Info.iSIG_SR_BREAKTHROUGHBEARISH)+1,0);
            //copySRZones(zones[i],Info.SR_BREAKS[ArraySize(Info.SR_BREAKS)-1]);
            Info.iSIG_SR_BREAKTHROUGHBEARISH[ArraySize(Info.iSIG_SR_BREAKTHROUGHBEARISH)-1]= zones[i];
            
            result=true;
            break;
         }
     
     
  
   }
   }
  
  
  return result;

}*/

bool notHitSRLastTime(SR_Zone &hit, SR_Zone &lastZones[])
{
 
  
   for(int i=0; i < ArraySize(lastZones); i++)
   {
           if(hit.HighBorder == lastZones[i].HighBorder && hit.LowBorder == lastZones[i].LowBorder)
           return true;
   }
   
   return false;
   
  
}

bool checkSIG_SR_TOUCHBEARISH(Buffers &buffer,SR_Zone &zones[],int sig,int SignalSystemOptions)
{
  bool result = false;
  
  if(sig & SIG_BARBEARISH)
  {
      for(int i = 0; i < ArraySize(zones); i++)
      {
        if(buffer.LowBuffer[0] > zones[i].HighBorder && buffer.LowBuffer[0] < zones[i].HighBorder + (10*Point))
        {
         result=true;
         break;
        }
  
      }
   }  
  
  return result;

}

bool checkSIG_SR_BREAKTHROUGHBULLISH(Buffers &buffer,SR_Zone &zones[],int sig,MetaInfo &Info, MetaInfo &lastInfo,int SignalSystemOptions)
{
  bool result = false;
  
  if(sig & SIG_BARBULLISH)
  {
   for(int i = 0; i < ArraySize(zones); i++)
   {
     if(((buffer.OpenBuffer[0] < zones[i].HighBorder && buffer.CloseBuffer[0] > zones[i].HighBorder + (20*Point))
         || (buffer.OpenBuffer[1] < zones[i].HighBorder && buffer.CloseBuffer[0] > zones[i].HighBorder + (20*Point)))
         && !notHitSRLastTime(zones[i],lastInfo.iSIG_SR_BREAKTHROUGHBULLISH))
     {
       ArrayResize(Info.iSIG_SR_BREAKTHROUGHBULLISH,ArraySize(Info.iSIG_SR_BREAKTHROUGHBULLISH)+1,0);
         //copySRZones(zones[i],Info.SR_BREAKS[ArraySize(Info.SR_BREAKS)-1]);
         Info.iSIG_SR_BREAKTHROUGHBULLISH[ArraySize(Info.iSIG_SR_BREAKTHROUGHBULLISH)-1]= zones[i];
       result=true;
       break;
     }
  
   }
  }
  
  return result;

}

bool checkSIG_SR_TOUCHBULLISH(Buffers &buffer,SR_Zone &zones[],int sig,int SignalSystemOptions)
{
  bool result = false;
  
  if(sig & SIG_BARBULLISH)
  {
   for(int i = 0; i < ArraySize(zones); i++)
   {
      if(buffer.HighBuffer[0] < zones[i].LowBorder && buffer.HighBuffer[0] > zones[i].LowBorder - (10*Point))
      {
          result=true;
          break;
      }
  
   }
  }
  
  return result;

}
