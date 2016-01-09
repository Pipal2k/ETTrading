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
#include <ETrading/ETIndikatorInfos.mqh>
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

void process(Buffers &buffer, ETSignal &currentSIgnals[],SR_Zone &zones[],ETSignal &lastSignal)
{
   ArrayFree(currentSIgnals);
   
   for(int i = 0; i < ArraySize(buffer.TimeBuffer); i++)
   {
     
      MetaInfo mInfo;
      MetaInfo lastMetaInfo;
      int sig=0;
      
      
      Buffers tmpBufferONE;
      Buffers tmpBufferThree;
      CopyBuffer(tmpBufferONE,i,1,buffer,false);
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
       

       if(checkSIG_SR_TOUCHLOWERBOUNDERY(tmpBufferThree,zones,sig,mInfo,lastMetaInfo))
           sig |= SIG_SR_TOUCHLOWERBOUNDERY;
         
        if(checkSIG_SR_TOUCHHIGHERBOUNDERY(tmpBufferThree,zones,sig,mInfo,lastMetaInfo))
           sig |= SIG_SR_TOUCHHIGHERBOUNDERY;
             
       if(checkSIG_SR_BREAKTHROUGHBEARISH(tmpBufferThree,zones,sig,mInfo,lastMetaInfo))
         sig |= SIG_SR_BREAKTHROUGHBEARISH;
       //}    
         
       if(checkSIG_SR_TOUCHBEARISH(tmpBufferThree,zones,sig))
         sig |= SIG_SR_TOUCHBEARISH;
         
       if(checkSIG_SR_BREAKTHROUGHBULLISH(tmpBufferThree,zones,sig,mInfo,lastMetaInfo))
         sig |= SIG_SR_BREAKTHROUGHBULLISH; 
         
        if(checkSIG_SR_TOUCHBULLISH(tmpBufferThree,zones,sig))
         sig |= SIG_SR_TOUCHBULLISH;   
           
      sig |= SIG_ANY;
      
      
      
      
      if(sig > 0)
      {
         ArrayResize(currentSIgnals,ArraySize(currentSIgnals)+1,0);
         currentSIgnals[ArraySize(currentSIgnals)-1].sig_flags=sig;
         currentSIgnals[ArraySize(currentSIgnals)-1].time=buffer.TimeBuffer[i];
         
         mInfo.RSI=buffer.RSIBuffer[i];
        
         copyMetaInfo(mInfo,currentSIgnals[ArraySize(currentSIgnals)-1].metaInfo);
         
         
         //currentSIgnals[ArraySize(currentSIgnals)-1].metaInfo=mIn;
      }
   }
   
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

bool checkSIG_SR_TOUCHLOWERBOUNDERY(Buffers &buffer,SR_Zone &zones[],int sig, MetaInfo &Info, MetaInfo &lastInfo)
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

bool checkSIG_SR_TOUCHHIGHERBOUNDERY(Buffers &buffer,SR_Zone &zones[],int sig, MetaInfo &Info, MetaInfo &lastInfo)
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

bool checkSIG_SR_BREAKTHROUGHBEARISH(Buffers &buffer,SR_Zone &zones[],int sig, MetaInfo &Info, MetaInfo &lastInfo)
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
     
    
     //if(buffer.OpenBuffer[0] > zones[i].LowBorder && buffer.CloseBuffer[0] < zones[i].LowBorder)
     //{
     //  result=true;
     //  break;
     //}
  
   }
  }
  
  return result;

}

bool notHitSRLastTime(SR_Zone &hit, SR_Zone &lastZones[])
{
 
  
   for(int i=0; i < ArraySize(lastZones); i++)
   {
           if(hit.HighBorder == lastZones[i].HighBorder && hit.LowBorder == lastZones[i].LowBorder)
           return true;
   }
   
   return false;
   
  
}

bool checkSIG_SR_TOUCHBEARISH(Buffers &buffer,SR_Zone &zones[],int sig)
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

bool checkSIG_SR_BREAKTHROUGHBULLISH(Buffers &buffer,SR_Zone &zones[],int sig,MetaInfo &Info, MetaInfo &lastInfo)
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

bool checkSIG_SR_TOUCHBULLISH(Buffers &buffer,SR_Zone &zones[],int sig)
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