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

ETPosition currentPos;  
void processPositioning(ActionPattern &matchingPattern[])
{
      
      if(CalculateCurrentOrders(Symbol())==0)
      {
        //Keine Position offen...neue Position aufmachen?
        if(ArraySize(matchingPattern) > 0)
        {
           if(!checkParadoxumPatterns(matchingPattern))
           {
               
               calculatePosition(matchingPattern[0],currentPos);
               OpenPosition(currentPos,matchingPattern[0].pos);
               
           }
        }
        
        return;
      
      }
      else
      {
      
          if(currentPos.targetsHit < ArraySize(currentPos.targets))
          {
              if(currentPos.pos == Buy)
              {
                    if(Bid >= currentPos.targets[currentPos.targetsHit])
                    {
                      double lotSizeToClose = NormalizeDouble(currentPos.size / 2.0,1);
                      OrderModify(OrderTicket(), OrderOpenPrice(), Bid-(currentPos.stopLossUnits*1.5), OrderTakeProfit(), Red);
                      OrderClose(OrderTicket(),lotSizeToClose,Bid,3,Red);
                      
                      
                      currentPos.targetsHit +=1;
                      currentPos.size = currentPos.size-lotSizeToClose;
                    }
              }
               if(currentPos.pos == Sell)
              {
                    if(Bid <= currentPos.targets[currentPos.targetsHit])
                    {
                      double lotSizeToClose = NormalizeDouble(currentPos.size / 2.0,1);
                      OrderModify(OrderTicket(), OrderOpenPrice(), Bid+(currentPos.stopLossUnits*1.5), OrderTakeProfit(), Red);
                      OrderClose(OrderTicket(),lotSizeToClose,Ask,3,Red);
                      
                      
                      currentPos.targetsHit +=1;
                      currentPos.size = currentPos.size-lotSizeToClose;
                    }
              }
          }
        //Position bereits offen eventuell schließen und next target
        /*if( (currentPos.pos == Buy && ((Bid >= currentPos.targets[0] && currentPos.targetsHit == 0) ||  (Bid >= currentPos.targets[1] && currentPos.targetsHit == 1))) )
        {
           double lotSizeToClose = NormalizeDouble(currentPos.size / 2.0,1);
           
           
           int Ticket=OrderTicket(); 
           
          
           
            
            if ((Bid >= currentPos.targets[0]) &&currentPos.targetsHit==0)
            {
               OrderModify(Ticket, OrderOpenPrice(), OrderOpenPrice(), OrderTakeProfit(), Red);
               OrderClose(Ticket,lotSizeToClose,Bid,3,Red);
                

               currentPos.targetsHit +=1;
               currentPos.size = currentPos.size-lotSizeToClose;
            }
            else if ((Bid >= currentPos.targets[1]) && currentPos.targetsHit==1)
            {
                 //OrderModify(Ticket, OrderOpenPrice(), currentPos.targets[0], OrderTakeProfit(), Red);
                 OrderClose(Ticket,lotSizeToClose,Bid,3,Red);
                 currentPos.targetsHit +=1;
                 currentPos.size = currentPos.size-lotSizeToClose;
            }
                 
           
          // currentPos.orderid+=2;
           
        }
        else if(currentPos.pos == Sell && ((Bid <= currentPos.targets[0] && currentPos.targetsHit == 0) || (Bid <= currentPos.targets[1] && currentPos.targetsHit == 1)))
        {
          double lotSizeToClose = NormalizeDouble(currentPos.size / 2.0,1);
           
           
           int Ticket=OrderTicket(); 
           
           if(Bid <= currentPos.targets[0] && currentPos.targetsHit == 0)
           {
              
               OrderClose(Ticket,lotSizeToClose,Ask,3,Red);
               OrderModify(Ticket, OrderOpenPrice(), OrderOpenPrice(), OrderTakeProfit(), Red);  

               currentPos.targetsHit +=1;
               currentPos.size = currentPos.size-lotSizeToClose;
            
           }
            else if (Bid <= currentPos.targets[1] && currentPos.targetsHit == 1)
            {
                //OrderModify(Ticket, OrderOpenPrice(), currentPos.targets[0], OrderTakeProfit(), Red);
                 OrderClose(Ticket,lotSizeToClose,Ask,3,Red);
                 currentPos.targetsHit +=1;
                 currentPos.size = currentPos.size-lotSizeToClose;
            }
           
          //currentPos.openSize -= lotSizeToClose;
          // OrderClose(currentPos.orderid,lotSizeToClose,Bid,3,Red);
        } */
        
      }
}

void calculatePosition(ActionPattern &matchingPattern,ETPosition &etPos)
{
   
   if(matchingPattern.posMethod == ATR)
   {  
      calcPosATR(matchingPattern.matchingSignal[0].metaInfo.buffer.ATRBuffer[0],etPos,matchingPattern.pos,(matchingPattern.posOptions & SingleTarget));
      etPos.size = calculatePositionGroesse(etPos.stopLossUnits,AccountEquity());
      
   }
   else if(matchingPattern.posMethod == SRZONES)
   {
        Print("Prepared Data Zones Count: "+ ArraySize(matchingPattern.prepData.zones));
   }
}

double calculatePositionGroesse(double stopLossUnits, double Amount)
{
      
      double stopLossPipe=stopLossUnits/Point;
      double PV=MarketInfo(Symbol(),MODE_TICKVALUE);
      double positionGr=(Amount *(2.0/100.0))/(stopLossPipe*PV);
      //Print("Positionsgroeße: ",NormalizeDouble(positionGr,1));
      
      if(positionGr < 0.1)
        positionGr = 0.1;
      else
        positionGr= NormalizeDouble(positionGr,1);  
      
      return positionGr;
}



void calcPosATR(double ATR,ETPosition &etPos, Position pos, bool singleTarget)
{
   //Print("ATR :" +ATR);
       etPos.stopLossUnits = ATR*2.0;
   //etPos.stopLossUnits= stopLossUnits;
     
      if(pos == Buy)
      {
        etPos.pos = Buy;
        etPos.stopLoss = (Ask-etPos.stopLossUnits);
        
        
        if(singleTarget)
         etPos.takeProfit = (Ask)+(1*ATR)-(Ask-Bid);
        else
        {
            ArrayResize(etPos.targets, 6,0); 
            etPos.targets[0] = (Ask)+(1*ATR)-(Ask-Bid);
            etPos.targets[1] = (Ask)+(2*ATR)-(Ask-Bid);
            etPos.targets[2] = (Ask)+(3*ATR)-(Ask-Bid);
            etPos.targets[3] = (Ask)+(4*ATR)-(Ask-Bid);
            etPos.targets[4] = (Ask)+(5*ATR)-(Ask-Bid);
            etPos.targets[5] = (Ask)+(6*ATR)-(Ask-Bid);
            etPos.targetsHit=0;
            etPos.takeProfit = (Ask)+(7*ATR)-(Ask-Bid);
        }
      }
      else
      {
         
         
        etPos.pos = Sell;
        etPos.stopLoss = (Bid+etPos.stopLossUnits);
        if(singleTarget)
              etPos.takeProfit = (Bid)-(1*ATR)+(Ask-Bid);
        else
        {
        
              ArrayResize(etPos.targets, 6,0);
              etPos.targetsHit=0;
              etPos.targets[0] = (Bid)-(1*ATR)+(Ask-Bid);
              etPos.targets[1] = (Bid)-(2*ATR)+(Ask-Bid);
              etPos.targets[2] = (Bid)-(3*ATR)+(Ask-Bid);
              etPos.targets[3] = (Bid)-(4*ATR)+(Ask-Bid);
              etPos.targets[4] = (Bid)-(5*ATR)+(Ask-Bid);
              etPos.targets[5] = (Bid)-(6*ATR)+(Ask-Bid);
              etPos.takeProfit = (Bid)-(7*ATR)+(Ask-Bid);
         }
      }
       
   
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
 

  
void OpenPosition(ETPosition &etPos,Position pos)
{

       Print("TakeProfit: "+etPos.takeProfit);
        if(pos==Sell)
        {
            
        
        //int res=OrderSend(Symbol(),OP_SELL,positionGr,Bid,3,stpl,Bid-takeprofit,"",MAGICMA,0,Red);
        etPos.orderid=OrderSend(Symbol(),OP_SELL,etPos.size,Bid,3,etPos.stopLoss,etPos.takeProfit,"",MAGICMA,0,Red);
         if(etPos.orderid<0)
           {
            Print("OrderSend failed with error #",GetLastError());
           }
         else
         {
            
            Print("OrderSend placed successfully");
          }

         return;

        }
      else if(pos==Buy)
        {
         //openLong();
         //int res=OrderSend(Symbol(),OP_BUY,positionGr,Ask,3,stpl,Ask+takeprofit,"",MAGICMA,0,Blue);
          etPos.orderid=OrderSend(Symbol(),OP_BUY,etPos.size,Ask,3,etPos.stopLoss,etPos.takeProfit,"",MAGICMA,0,Blue);
         if(etPos.orderid<0)
           {
            Print("OrderSend failed with error #",GetLastError());
           }
         else
            Print("OrderSend placed successfully");

         return;

        }
     
} 
