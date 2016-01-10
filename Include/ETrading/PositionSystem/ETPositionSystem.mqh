//+------------------------------------------------------------------+
//|                                             ETPositionSystem.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#define MAGICMA  20131111

#include  <ETrading/ETDataTypes.mqh>
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

void processPositioning(ActionPattern &matchingPattern[])
{
      
      if(CalculateCurrentOrders(Symbol())==0)
      {
        //Keine Position offen...neue Position aufmachen?
        if(ArraySize(matchingPattern) > 0)
        {
           if(!checkParadoxumPatterns(matchingPattern))
           {
               Position pos;
               calculatePosition(matchingPattern[0],pos);
               
               
           }
        }
        
        return;
      
      }
      else
      {
        //Position bereits offen eventuell schlie�en und next target
        
        
      }
}

void calculatePosition(ActionPattern &matchingPattern,Position &pos)
{
   
   if(matchingPattern.posMethod == ATR)
   {
      //Print("MatchinSignal Count: "+ matchingPattern.matchingSignal[0].metaInfo.buffer.ATRBuffer[0]);
      calcPosATR(matchingPattern.matchingSignal[0].metaInfo.buffer.ATRBuffer[0] ,pos);
   }
}

void calcPosATR(double ATR,Position &pos)
{
   //Print("ATR :" +ATR);
   
}

bool checkParadoxumPatterns(ActionPattern &matchingPattern[])
{
    bool buy = false;
    bool sell = false;
    
    for(int i = 0; i < ArraySize(matchingPattern);i++)
    {
        if(matchingPattern[i].pos == Buy)
         buy = true;
        
        if(matchingPattern[i].pos == Sell)
        sell = true;   
    }
    
    if(buy && sell)
      return true;
    else
      return false;  
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
  
  
void OpenPosition(ActionPattern &pattern,double positionGr, double stpl, double takeprofit)
{
        if(pattern.pos==Sell)
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
      else if(pattern.pos==Buy)
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
