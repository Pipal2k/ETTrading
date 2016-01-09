//+------------------------------------------------------------------+
//|                                                      Trigger.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict
#include <EWDeluxe\CandleSTickPattern.mqh>
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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool checkTrigger(Buffers &buffers, 
                  TradeTrigger &foundTrigger[],
                  bool useTradingTime,
                  Configuration &config,
                  bool isKalibrating)
  {
   bool found=false;
   TradeTrigger tmpTrigger[];

   ArrayFree(foundTrigger);
// ArrayResize(patternsFound,0,0);
//(patternsFound);

  if(useTradingTime && (!isInTradingTime(buffers.TimeBuffer)))
    return false;
  
   int shift = iBarShift(Symbol(),Period(),buffers.TimeBuffer[0]);
    
   findPattern(buffers.HighBuffer,buffers.LowBuffer,buffers.OpenBuffer,buffers.CloseBuffer,buffers.VolumeBuffer,buffers.avgVolume,buffers.TimeBuffer,foundTrigger,config);
   
   if(config.TriggerADX)
   findADX(shift,foundTrigger,buffers);
   
   if(config.TriggerStochCrossing)
   findSTOCHCrossing(shift,foundTrigger,buffers);
   
   //checkStochiasticCrossing(buffers.STOCHBufferValue,buffers.STOCHBufferSignal)
//for(int i=0; i < ArraySize(patternsFound); i++)
//{

//ArrayResize(foundTrigger,ArraySize(foundTrigger)+1,0);
   if(ArraySize(tmpTrigger)>0)
   {
      addTrigger(tmpTrigger,foundTrigger);
      //Print("PAF: ",ArraySize(patternsFound));
      

     // if(checkStochiasticCrossing(patternsFound[0].position,STOCHBufferValue, STOCHBufferSignal))
         found=true;
   }
//foundTrigger[i] = tmpTrigger;
//}
    //foundTrigger=tmpTrigger;
   
  //;

//evauluateCandleStickPatternTrigger(patternsFound,foundTrigger);
if(!isKalibrating)
   drawTriggers(foundTrigger);

//foundTrigger=NULL;
   return found;
  }
  
  bool isInTradingTime(datetime &TimeBuffer[])
  {
      if(TimeHour(TimeBuffer[0]) > 8 && TimeHour(TimeBuffer[0]) < 22)
      return true;
      else
      return false;
  }
  
  
  void addTrigger(TradeTrigger &trigger[],TradeTrigger &triggerArray[])
  {
  
   int x = ArraySize(triggerArray);
   ArrayResize(triggerArray,x+ArraySize(trigger),0);
   ArrayCopy(triggerArray,trigger,x-1,0,WHOLE_ARRAY);
  // triggerArray[x]=trigger;
  }
  
  void addTrigger(TradeTrigger &trigger,TradeTrigger &triggerArray[])
  {
  int x = ArraySize(triggerArray);
   ArrayResize(triggerArray,x+1,0);
   triggerArray[x]=trigger;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool checkStochiasticCrossing(double &STOCHBufferValue[],double &STOCHBufferSignal[])
  {
  // if(pos==Buy)
   //  {
      if(STOCHBufferValue[1]>STOCHBufferSignal[1])
         return true;
    // }
   //else if(pos==Sell)
    // {
      //if(STOCHBufferValue[4]>STOCHBufferSignal[4] && STOCHBufferValue[3]<STOCHBufferSignal[3] && STOCHBufferValue[1]<STOCHBufferSignal[1])
       if(STOCHBufferValue[1]<STOCHBufferSignal[1])
         return true;
     //}

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void drawTriggers(TradeTrigger &triggerFound[])
  {
   for(int i=0; i<ArraySize(triggerFound); i++)
     {
      //Print("Pattern found: "+EnumToString(patternsFound[i].Type)+" PatternCOunt: "+ArraySize(patternsFound));

      if(triggerFound[i].pos==Buy)
         ObjectCreate("Arrow"+triggerFound[i].time,OBJ_ARROW_UP,0,triggerFound[i].time,triggerFound[i].drawPos);
      else if(triggerFound[i].pos==Sell)
         ObjectCreate("Arrow"+triggerFound[i].time,OBJ_ARROW_DOWN,0,triggerFound[i].time,triggerFound[i].drawPos);
         
       
           
      ObjectCreate("Perc"+triggerFound[i].time,OBJ_TEXT,WindowFind("DeluxeEWPercentage"),triggerFound[i].time,98); //Low[1]- (20*Point)
      ObjectSetText("Perc"+triggerFound[i].time,EnumToString(triggerFound[i].triggerType),2,"Verdana",Green);
      
//ObjectSet("ObjName", OBJPROP_YDISTANCE, i);   
     }
     
     
  }
//+------------------------------------------------------------------+

 void findADX(int shift, TradeTrigger &foundTrigger[],Buffers &buffers)
 {
   int cADXMainX = iADX(Symbol(),Period(),14,PRICE_CLOSE,MODE_MAIN,shift+1);
   int cADXMainY = iADX(Symbol(),Period(),14,PRICE_CLOSE,MODE_MAIN,shift+2);
   
   int cADXDiPlus = iADX(Symbol(),Period(),14,PRICE_CLOSE,MODE_PLUSDI,shift+1);
   int cADXDiMinus= iADX(Symbol(),Period(),14,PRICE_CLOSE,MODE_MINUSDI,shift+1);
   
   if(cADXMainX >= 30 && cADXMainY < 30)
   {
       TradeTrigger tmpTrigger;
      //tmpTrigger.triggerType=CandleStickPatternTrigger;
      if(cADXDiPlus > cADXDiMinus)
         tmpTrigger.pos=Buy;
      else
          tmpTrigger.pos = Sell;
             
      tmpTrigger.triggerType=ADX;   
          
      
       tmpTrigger.time=buffers.TimeBuffer[1];
       tmpTrigger.drawPos=buffers.LowBuffer[1];
       
       ArrayResize(foundTrigger,ArraySize(foundTrigger)+1,0);
       foundTrigger[ArraySize(foundTrigger)-1]= tmpTrigger;
   }
 }
 
  void findSTOCHCrossing(int shift, TradeTrigger &foundTrigger[],Buffers &buffers)
 {
   int stochX = iStochastic(Symbol(),Period(),9,6,6,MODE_SMA,0,MODE_MAIN,shift+1);
  int stochY = iStochastic(Symbol(),Period(),9,6,6,MODE_SMA,0,MODE_SIGNAL,shift+1);
  
  int stochX2 = iStochastic(Symbol(),Period(),9,6,6,MODE_SMA,0,MODE_MAIN,shift+2);
  int stochY2 = iStochastic(Symbol(),Period(),9,6,6,MODE_SMA,0,MODE_SIGNAL,shift+2);
   
   
   if(stochX < stochY && stochX2 >= stochY2)
   {
       TradeTrigger tmpTrigger;
      //tmpTrigger.triggerType=CandleStickPatternTrigger;
      
       tmpTrigger.pos = Sell;
             
        tmpTrigger.triggerType=STC;   
          
      
       tmpTrigger.time=buffers.TimeBuffer[1];
       tmpTrigger.drawPos=buffers.LowBuffer[1];
       
       ArrayResize(foundTrigger,ArraySize(foundTrigger)+1,0);
       foundTrigger[ArraySize(foundTrigger)-1]= tmpTrigger;
   }
   else if(stochX > stochY && stochX2 <= stochY2)
   {
      TradeTrigger tmpTrigger;
      
      
       tmpTrigger.pos = Buy;
             
        tmpTrigger.triggerType=STC;   
          
      
       tmpTrigger.time=buffers.TimeBuffer[1];
       tmpTrigger.drawPos=buffers.LowBuffer[1];
       
       ArrayResize(foundTrigger,ArraySize(foundTrigger)+1,0);
        foundTrigger[ArraySize(foundTrigger)-1]= tmpTrigger;
   }
   
 }