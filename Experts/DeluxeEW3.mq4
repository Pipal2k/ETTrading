//+------------------------------------------------------------------+
//|                                                    DeluxeEW3.mq4 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#define MAGICMA  20131111

#include <EWDeluxe2/WendePunkt.mqh>
#include <EWDeluxe2/TrendLinien.mqh>
#include <EWDeluxe2/SupportResistance.mqh>
#include <EWDeluxe2/Pivot.mqh>
#include <EWDeluxe2/enums.mqh>
#include <EWDeluxe2/CandleStickPattern.mqh>
#include <EWDeluxe2/ValidateTrigger.mqh>



//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
input bool TriggerBearishEngulfing = true;
input bool TriggerBullishEngulfing = true;
input bool TriggerHammer = true;
input bool TriggerInvertedHammer = true;
input bool TriggerDarkClouds = true;
input bool TriggerThreeWhiteSoldiers = true;
int barCount = 0;
Configuration config;
TradeTrigger triggersAll[];

void getSR()
{
     ObjectsDeleteAll();
   TrendChange tChanges[];
   TrendChange tChanges3[];
   TrendChange tChanges2[];
   
   TrendChange latestChanges[];
   
   
   findCAT1TrendChange(200,tChanges);
   //Print("changes:"+ArraySize(tChanges));
   
   getTrendChanges(tChanges,11,tChanges3,None);
   //getTrendChanges(tChanges,1,tChanges2,None);
   
   
   getLatestTrendChanges(tChanges,3,latestChanges);
   
    
   //ZoneSR zones[];
   //findSupportResistance(tChanges3,tChanges2,zones);
   
  //Print("changes:"+ArraySize(tChanges3));
  DrawTrendChanges(tChanges3,3);
  //DrawSupportResistance(zones,Time[0],None);
}


int OnInit()
  {
//--- create timer
   EventSetTimer(60);
   
   Print("Init");
   
    //Print(test());
   config.TriggerBearishEngulfing= TriggerBearishEngulfing;
   config.TriggerBullishEngulfing= TriggerBullishEngulfing;
   config.TriggerDarkClouds = TriggerDarkClouds;
   config.TriggerThreeWhiteSoldiers = TriggerThreeWhiteSoldiers;
   config.TriggerHammer = TriggerHammer;
   config.TriggerInvertedHammer = TriggerInvertedHammer;
  
   
   PivotRow pivRows[];
   PivotRow pivRowsF[];
   calculatePivot(pivRows,PERIOD_D1,Standard);
  // calculatePivot(pivRowsF,PERIOD_D1,Fibo);
   DrawPivot(pivRows,false);
   //DrawPivot(pivRowsF,false);
   
   barCount=0;
   
    //getSR();
    
    //int val_index=iHighest(NULL,0,MODE_HIGH,10,0);
    
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
      
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
      if(Volume[0]>1)
        return;
        
      barCount++;
      ObjectsDeleteAll();
      //Print("hgahah"+Point);
      //if(barCount%2==0){
      PivotRow pivRows[];
      PivotRow pivRowsF[];
      calculatePivot(pivRows,PERIOD_D1,Standard);
      //calculatePivot(pivRowsF,PERIOD_D1,Fibo);
      
      DrawPivot(pivRows,false);
      //DrawPivot(pivRowsF,false);
      
      Buffers buffers;
      initBuffers(buffers,Time[0],5,Period(),true);
      
      TradeTrigger foundTrigger[];
      findPattern(buffers.HighBuffer,buffers.LowBuffer,buffers.OpenBuffer,buffers.CloseBuffer,buffers.VolumeBuffer,buffers.TimeBuffer,foundTrigger,config);
      
      //ArrayResize(pivRows,ArraySize(pivRows)+ArraySize(pivRowsF),0);
      //ArrayCopy(pivRows,pivRowsF,ArraySize(pivRowsF),0,WHOLE_ARRAY);
      
      TradeTrigger trigger;
      
      bool valid=validateTrigger(foundTrigger,pivRows);
      if(valid && ArraySize(foundTrigger)> 0)
      trigger = foundTrigger[0];
      //TriggerOnPivot(foundTrigger,pivRows);
      //TriggerOnPivot(foundTrigger,pivRowsF);
      
      
      ArrayResize(triggersAll,ArraySize(triggersAll)+ArraySize(foundTrigger),0);
      ArrayCopy(triggersAll,foundTrigger,ArraySize(triggersAll),0,WHOLE_ARRAY);
      
      drawTriggers(triggersAll);
     
     if(CalculateCurrentOrders(Symbol())==0 && valid && ArraySize(foundTrigger)> 0)
     {
     
        double atr2=iATR(Symbol(),Period(),14,1);
        double stpLRange=atr2*2.0;
        double pStl;
       
       Print("Pivot Match Price:"+ trigger.PivotMatchPrice);
       Print("blabla "+ findStopPivot(pivRows,trigger.PivotMatchPrice,trigger.pos,true));
       
       if((pStl=findStopPivot(pivRows,trigger.PivotMatchPrice,trigger.pos,true))!=0.0)
       {
        Print("ATR: "+atr2+" Diff PMTOPSTL:"+MathAbs(pStl-trigger.PivotMatchPrice));
         while(MathAbs(pStl-trigger.PivotMatchPrice) < (atr2*2))
         {
           pStl=findStopPivot(pivRows,pStl,trigger.pos,true);
         } 
         
         Print("pStpl found");
         stpLRange = MathAbs(Open[0]-pStl);
        // Print("Stop pivot: "+ DoubleToStr(pStl)+" Range: "+stpLRange);
       }
       
       double stopLoss;
      if(trigger.pos == Buy)
      {
        stopLoss= (Ask-stpLRange);
      }
      else
         stopLoss= (Bid+stpLRange);
      
       
       
    
       //drawATR2(buffers.TimeBuffer,atr2);
      
       //double stopLoss;
       //double stpl = calculateStopLossPrize(trigger.pos,stpLRange,stopLoss);
      
      //double atr2=iATR(NULL,0,14,0);
     //  double stopLoss=atr*2.0;
       
       double positionGr = calculatePositionGroesse(stpLRange,AccountEquity());
       
       Print("PositionsGroesse: "+ DoubleToStr(positionGr));
       //double positionGr = calculatePositionGroesse(stpLRange,AccountEquity());
       
       
       //double takeprofit=(atr2/100.0) *90.0;
       
        //if(trigger.pos=Buy)
         // takeprofit+=(Ask-Bid);
        //else if(trigger.pos=Sell)
         // takeprofit-=(Ask-Bid); 
       
       //if(isKalibration == false)
       //checkDistanceToLastHighLow(trigger.pos,buffers.CloseBuffer);
       double takeprofit=findNextPivot(pivRows,Open[0],trigger.pos,false);
       
       Print("TAKEPROFIT: "+takeprofit);
       
       if(takeprofit !=0.0)
       {
        if(trigger.pos == Sell)
        {
          stopLoss+=(Point*20);
          takeprofit=findNextPivot(pivRows,Open[0],trigger.pos,false)+(Point*20);
        }
        else
        { 
          stopLoss-=(Point*20);  
          takeprofit=findNextPivot(pivRows,Open[0],trigger.pos,false)-(Point*20);
        }
       }
       else
       {
         if(trigger.pos == Sell)
         {
             takeprofit=Bid-atr2;         
         }
         else
         {
             takeprofit=Ask+atr2; 
         }
       }
         
       
       
          Print("StopLoss: "+stopLoss+" TakeProfit: "+takeprofit);
          OpenPosition(trigger,positionGr,stopLoss,takeprofit);
       //else
       //   OpenFakePosition(trigger,positionGr,stopLoss,takeprofit,buffers.OpenBuffer,buffers.TimeBuffer,fPosition,false);
     }
      
      
   
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=0.0;
//---

//---
   return(ret);
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
      if(id>CHARTEVENT_CUSTOM)
      {
         
         Print("Handle the user event with the ID = ",id);
      
      }
  }
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
         
       
      
         ObjectCreate("Perc"+triggerFound[i].time,OBJ_TEXT,WindowFind("DeluxeEWPercentage"),triggerFound[i].time,10); //Low[1]- (20*Point)
          if(triggerFound[i].TriggerOnPivot)    
            ObjectSetText("Perc"+triggerFound[i].time,EnumToString(triggerFound[i].triggerType),2,"Verdana",Green);
         else
            ObjectSetText("Perc"+triggerFound[i].time,EnumToString(triggerFound[i].triggerType),2,"Verdana",Red);
       
      
//ObjectSet("ObjName", OBJPROP_YDISTANCE, i);   
     }
     
     
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
  
   
  
  double calculateStopLossPrize(Position pos, double atr, double &stopLossUnits)
  {
     //double atr=iATR(NULL,0,14,0);
     stopLossUnits=atr;//atr*2.0;
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
  
  void OpenPosition(TradeTrigger &trigger,double positionGr, double stpl, double takeprofit)
{
        if(trigger.pos==Sell)
        {
            
        
        //int res=OrderSend(Symbol(),OP_SELL,positionGr,Bid,3,stpl,Bid-takeprofit,"",MAGICMA,0,Red);
        int res=OrderSend(Symbol(),OP_SELL,positionGr,Bid,3,stpl,takeprofit,"",MAGICMA,0,Red);
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
         int res=OrderSend(Symbol(),OP_BUY,positionGr,Ask,3,stpl,takeprofit,"",MAGICMA,0,Blue);
         if(res<0)
           {
            Print("OrderSend failed with error #",GetLastError());
           }
         else
            Print("OrderSend placed successfully");

         return;

        }
     
} 

