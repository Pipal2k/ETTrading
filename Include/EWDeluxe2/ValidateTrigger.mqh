//+------------------------------------------------------------------+
//|                                              ValidateTrigger.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict
#include <EWDeluxe2/enums.mqh>
#include <EWDeluxe2/Pivot.mqh>
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

bool validateTrigger(TradeTrigger &trigger[],PivotRow &rows[])
{
   bool valid=false;
   
   if(TriggerOnPivot(trigger,rows) && RSIValid(trigger) && isInTradingTime(Time[0]) && nextPivotDistanceEnough(trigger,rows) )
     valid = true;
     
   return valid;
}

bool RSIValid(TradeTrigger &trigger[])
{
 bool valid = false;
 int rsi = iRSI(Symbol(),Period(),14,PRICE_CLOSE,1);
 
 for(int i = 0; i < ArraySize(trigger); i++)
 {
    if(trigger[i].pos == Buy && rsi < 65)
      valid= true;
     else if(trigger[i].pos == Sell && rsi > 35)
       valid=true;
}
    
  return valid;    
}

bool isInTradingTime(datetime CTime)
  {
      if(TimeHour(CTime) > 8 && TimeHour(CTime) < 22)
      return true;
      else
      return false;
  }

bool TriggerOnPivot(TradeTrigger &trigger[],PivotRow &rows[])
  {
     bool found = false;
       for(int i = 0; i < ArraySize(trigger); i++)
       {
          
          for(int x = 0; x < ArraySize(rows);x++)
          {
            if(rows[x].type!= MS1 && rows[x].type!= MS2 && rows[x].type!= MS3 && rows[x].type!= MR1 && rows[x].type!= MR2 && rows[x].type!= MR3)
            {
               if( rows[x].PivotPrize <= (trigger[i].triggerHigh+(Point*0)) && rows[x].PivotPrize >= (trigger[i].triggerLow-(Point*0)) )
                {
         
                  
                  if((trigger[i].pos==Buy && rows[x].PivotPrize < trigger[i].PivotMatchPrice) || trigger[i].PivotCount==0 )
                    trigger[i].PivotMatchPrice= rows[x].PivotPrize;
                   else if (trigger[i].pos==Sell && rows[x].PivotPrize > trigger[i].PivotMatchPrice)
                    trigger[i].PivotMatchPrice= rows[x].PivotPrize;
                    
                  trigger[i].TriggerOnPivot=true;
                  trigger[i].PivotCount+=1;
                  found=true;
                }
             }
          }
           
       }   
    
    return found;
  
  }
  
  bool nextPivotDistanceEnough(TradeTrigger &trigger[],PivotRow &rows[])
  { 
    bool valid = false;
    double nextPivot;
    double Spread =Ask-Bid; //MarketInfo(Symbol(), MODE_SPREAD);
    Print("Spread: "+Spread);
    for(int i =0; i < ArraySize(trigger); i++)
    {
      nextPivot=findNextPivot(rows,trigger[i].triggerClosePrice,trigger[i].pos,true);
      Print("NextPivot: "+nextPivot);
      if(trigger[i].pos == Sell)
      {
         
         if( nextPivot < trigger[i].triggerClosePrice-(Spread*1.5))
           valid=true;
      }
      else if(trigger[i].pos == Buy)
      {
         
         if( nextPivot > trigger[i].triggerClosePrice+(Spread*1.5))
           valid=true;
      }
    
    }
    
    return valid;
   
  }