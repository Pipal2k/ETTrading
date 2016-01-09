//+------------------------------------------------------------------+
//|                                                   DoTheMagic.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#define MAGICMA  20131111

#include <EWDeluxe\ValidateTrigger.mqh>
#include <EWDeluxe\Kalibration.mqh>
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
  void doTheMagic(Buffers &buffers,
                  //int timeframe,
                  TriggersValidationCriteria &triggerCriterias,
                  //ValidationCriteria &criteriaM, 
                  double atr, 
                  bool isKalibration, 
                  FakePosition &fPosition[],
                  double Amount,
                  double stdvCurrent,
                  double stdv,
                  bool useTradingTime,
                  Configuration &config)
  {
    
      
     bool valide=false;
          
     TradeTrigger triggers[];
     TradeTrigger trigger;
     ArrayFree(triggers);
     ArrayResize(triggers,0,0);
     bool triggerFound = checkTrigger(buffers,triggers,useTradingTime,config,false);
     
     //OpenFakePosition(trigger,0,0,0.0,OpenBufferM);
     
     //if(triggerFound)
     
     if(ArraySize(triggers)> 0)
     { 
        for(int i= 0; i < ArraySize(triggers); i++)
        {
          ValidationCriteria criteria;
          trigger= triggers[i];
          getCriteria(trigger,criteria,triggerCriterias);
          valide = validateTrigger(buffers,triggers[i],criteria,config,false);
            if(valide) 
            break;
         }
      }
 
    
    
     
    if(((CalculateCurrentOrders(Symbol())==0 && valide) || (isKalibration == true && valide)))// && stdvCurrent < stdv && buffers.VolumeBuffer[1] > buffers.avgVolume)
     {
     
       
       double atr2=iATR(Symbol(),Period(),14,1);
       drawATR2(buffers.TimeBuffer,atr2);
      
       double stopLoss;
       double stpl = calculateStopLossPrize(trigger.pos,atr2,stopLoss);
      
      //double atr2=iATR(NULL,0,14,0);
     //  double stopLoss=atr*2.0;
       
       double positionGr = calculatePositionGroesse(stopLoss,Amount);

       double takeprofit=(atr2/100.0) *90.0;
       
        //if(trigger.pos=Buy)
         // takeprofit+=(Ask-Bid);
        //else if(trigger.pos=Sell)
         // takeprofit-=(Ask-Bid); 
       
       //if(isKalibration == false)
       //checkDistanceToLastHighLow(trigger.pos,buffers.CloseBuffer);
          OpenPosition(trigger,positionGr,stpl,takeprofit);
       //else
       //   OpenFakePosition(trigger,positionGr,stopLoss,takeprofit,buffers.OpenBuffer,buffers.TimeBuffer,fPosition,false);
     }

     
}

 bool checkDistanceToLastHighLow(Position pos,double &CloseBuffer[])
 {
    double lastLow=0.0;
    double lastHigh=0.0;
    
    return true;
 }

 void drawATR2(datetime &timeBuffer[],double atr)
{
   ObjectCreate("ATR2"+timeBuffer[1],OBJ_TEXT,WindowFind("DeluxeEWPercentage"),timeBuffer[0],12); //Low[1]- (20*Point)
   ObjectSetText("ATR2"+timeBuffer[1],DoubleToStr(atr),5,"Verdana",Green);
}

void getCriteria(TradeTrigger &trigger, ValidationCriteria &criteria,TriggersValidationCriteria &triggerCriteria )
{
    switch(trigger.triggerType)
    {
      case CBEE:
        criteria = triggerCriteria.CandleStickBearishEngulfingCriteria;
        break;
      case CBUE:
        criteria = triggerCriteria.CandleStickBullishEngulfingCriteria;
        break;  
      case CH:
        criteria = triggerCriteria.CandleStickHammerCriteria;
        break;
      case CTS:
        criteria = triggerCriteria.CandleStickThreeSoldiersCriteria;
        break;
       case CDC:
        criteria = triggerCriteria.CandleStickDarkCloudsCriteria;
        break;
       case CIH:
        criteria = triggerCriteria.CandleStickInvertedHammerCriteria;
        break; 
       case ADX:
        criteria = triggerCriteria.ADXCriteria;
        break;
       case STC:
        criteria = triggerCriteria.STOCHCROSSCriteria;         
        break;
    }
}

  double calculateStopLossPrize(Position pos, double atr, double &stopLossUnits)
  {
     //double atr=iATR(NULL,0,14,0);
     stopLossUnits=atr*2.0;
     if(pos == Buy)
      {
        return (Ask-stopLossUnits);
      }
      else
         return (Bid+stopLossUnits);
      //double stopLossPipe=stopLoss/Point;
  
  }
  
  double calculatePositionGroesse(double stopLoss, double Amount)
  {
      
      double stopLossPipe=stopLoss/Point;
      double PV=MarketInfo(Symbol(),MODE_TICKVALUE);
      double positionGr=(Amount *(2.0/100.0))/(stopLossPipe*PV);
      //Print("Positionsgroeﬂe: ",NormalizeDouble(positionGr,1));
      
      return positionGr;
  }
  
  int CalculateCurrentOrders(string symbol)
  {
   int buys=0,sells=0;
//---
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)
         break;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA)
        {
         if(OrderType()==OP_BUY)  buys++;
         if(OrderType()==OP_SELL) sells++;
        }
     }
//--- return orders volume
   if(buys>0) return(buys);
   else       return(-sells);
  }
  
  void OpenFakePosition(TradeTrigger &trigger,double positionGrF, double stplF, double takeprofitF,double &OpenBufferF[], datetime &TimeBufferF[], FakePosition &fPositions[], bool isKalibration)
{
   double ask;
   double bid;
   
   FakePosition tmpP;
      
   bid = OpenBufferF[0];
   ask = bid + (MarketInfo(Symbol(),MODE_SPREAD)*Point);
   if(trigger.pos == Buy)
   {
     tmpP.pos = trigger.pos;
     tmpP.ask = ask;
     tmpP.bid = bid;
     tmpP.stpl= ask-stplF;
     tmpP.positionGr=positionGrF;
     tmpP.takeprofit= ask+takeprofitF;
     tmpP.status = SOpen;
     tmpP.time=TimeBufferF[0];
     ArrayResize(fPositions,ArraySize(fPositions)+1,0);  
     fPositions[ArraySize(fPositions)-1] =tmpP; 
    
     if(!isKalibration)
     {
      ObjectCreate("PRICE"+TimeBufferF[0], OBJ_TREND, 0, TimeBufferF[0], ask, TimeBufferF[1], ask );
      ObjectSet("PRICE"+TimeBufferF[0], OBJPROP_COLOR, Red);
      ObjectSet("PRICE"+TimeBufferF[0], OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet("PRICE"+TimeBufferF[0], OBJPROP_WIDTH, 2);
      ObjectSet("PRICE"+TimeBufferF[0], OBJPROP_RAY, False); 
     }
   }
   else if(trigger.pos == Sell)
   {
     tmpP.pos = trigger.pos;
     tmpP.ask = ask;
     tmpP.bid = bid;
     tmpP.stpl=bid+ stplF;
     tmpP.positionGr = positionGrF;
     tmpP.takeprofit= bid-takeprofitF;
     tmpP.status = SOpen;
     tmpP.time=TimeBufferF[0];
     ArrayResize(fPositions,ArraySize(fPositions)+1,0);  
     fPositions[ArraySize(fPositions)-1] =tmpP; 
      
      if(!isKalibration)
     { 
      ObjectCreate("PRICE"+TimeBufferF[0], OBJ_TREND, 0, TimeBufferF[0], bid, TimeBufferF[1], bid );
      ObjectSet("PRICE"+TimeBufferF[0], OBJPROP_COLOR, Red);
      ObjectSet("PRICE"+TimeBufferF[0], OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet("PRICE"+TimeBufferF[0], OBJPROP_WIDTH, 2);
      ObjectSet("PRICE"+TimeBufferF[0], OBJPROP_RAY, False); 
     }
     
   }
    
     if(!isKalibration)
     {
    ObjectCreate("Buy"+TimeBufferF[0], OBJ_TREND, 0, TimeBufferF[0], tmpP.takeprofit, TimeBufferF[1], tmpP.takeprofit );
     ObjectSet("Buy"+TimeBufferF[0], OBJPROP_COLOR, Orange);
     ObjectSet("Buy"+TimeBufferF[0], OBJPROP_STYLE, STYLE_SOLID);
     ObjectSet("Buy"+TimeBufferF[0], OBJPROP_WIDTH, 2);
     ObjectSet("Buy"+TimeBufferF[0], OBJPROP_RAY, False); 
      ObjectCreate("STPL"+TimeBufferF[0], OBJ_TREND, 0, TimeBufferF[0], tmpP.stpl, TimeBufferF[1], tmpP.stpl );
     ObjectSet("STPL"+TimeBufferF[0], OBJPROP_COLOR, Red);
     ObjectSet("STPL"+TimeBufferF[0], OBJPROP_STYLE, STYLE_SOLID);
     ObjectSet("STPL"+TimeBufferF[0], OBJPROP_WIDTH, 2);
     ObjectSet("STPL"+TimeBufferF[0], OBJPROP_RAY, False); 
     }
   
 
   //double bid=1.13575;
   //double ask = bid + (18.0*Point);
   return;  
} 

void OpenPosition(TradeTrigger &trigger,double positionGr, double stpl, double takeprofit)
{
        if(trigger.pos==Sell)
        {
            
        
        //int res=OrderSend(Symbol(),OP_SELL,positionGr,Bid,3,stpl,Bid-takeprofit,"",MAGICMA,0,Red);
        int res=OrderSend(Symbol(),OP_SELL,positionGr,Bid,3,stpl,Bid-takeprofit,"",MAGICMA,0,Red);
         if(res<0)
           {
            Print("OrderSend failed with error #",GetLastError());
           }
         else
            Print("OrderSend placed successfully");

         return;

        }
      else if(trigger.pos==Buy)
        {
         //openLong();
         //int res=OrderSend(Symbol(),OP_BUY,positionGr,Ask,3,stpl,Ask+takeprofit,"",MAGICMA,0,Blue);
         int res=OrderSend(Symbol(),OP_BUY,positionGr,Ask,3,stpl,Ask+takeprofit,"",MAGICMA,0,Blue);
         if(res<0)
           {
            Print("OrderSend failed with error #",GetLastError());
           }
         else
            Print("OrderSend placed successfully");

         return;

        }
     
} 

