//+------------------------------------------------------------------+
//|                                            SupportResistance.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include <EWDeluxe2/WendePunkt.mqh>
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

struct SRZone {
  double price;
  int resistanceCount;
  int supportCount;
  int gesamtCount;
  int count;
  int countBuy;
  int countSell;
};

struct ZoneSR {
  double highPrice;
  double lowPrice;
  datetime beginTime;
  //int resistanceCount;
  //int supportCount;
  //int gesamtCount;
  Position pos;
  int count;
   int countBuy;
  int countSell;
};

//struct Cluster
//{
//   int count;
   //TrendChange tChanges[];
//};

void findSupportResistance(TrendChange &tChanges[],TrendChange &alltChanges[], ZoneSR &zones[])
{
  
   //;
   
   
   
   TrendChange supportCh[];
   TrendChange supportChAll[];
   getTrendChanges(tChanges,0,supportCh,Buy);
   getTrendChanges(alltChanges,0,supportChAll,Buy);
   
   TrendChange resistenceCh[];
    TrendChange resistenceChAll[];
   getTrendChanges(tChanges,0,resistenceCh,Sell);
   getTrendChanges(alltChanges,0,resistenceChAll,Sell);
   
   //findCluster(supportCh,supportChAll,zones,Buy);
   //findCluster(resistenceCh,resistenceChAll,zones,Sell);
   
   findCluster(tChanges,alltChanges,zones);
   
   //double PV=MarketInfo(Symbol(),MODE_TICKVALUE);
  
}

void findCluster(TrendChange &tChanges[],TrendChange &alltChanges[],ZoneSR &zonesArray[])
{
   for(int x = 0; x < ArraySize(tChanges); x++)
   {
      ZoneSR tZone;
      tZone.highPrice= tChanges[x].changePrice;
      tZone.lowPrice = tChanges[x].changePrice;
      tZone.beginTime = tChanges[x].time;
      tZone.count = 0;
      tZone.countBuy = 0;
      tZone.countSell = 0;
      ///Print("Point:"+150*Point);
      for(int y=0; y < ArraySize(alltChanges); y++)
      {   
         if((alltChanges[y].changePrice <= tChanges[x].changePrice && alltChanges[y].changePrice >= (tChanges[x].changePrice-(25*Point))) //0.00001)) ///((1*Point))))
            || (alltChanges[y].changePrice >= tChanges[x].changePrice && alltChanges[y].changePrice <= (tChanges[x].changePrice+(25*Point)))) //+0.00001 )))//((1*Point))) ))
            {
               //ArrayResize(tCluster.tChanges,ArraySize(tCluster.tChanges)+1,0);
               //tCluster.tChanges[ArraySize(tCluster.tChanges)-1] = tChanges[y];
               tZone.count +=1; 
               
               if(alltChanges[y].pos==Buy)
               tZone.countBuy+=1;
               
               if(alltChanges[y].pos==Sell)
               tZone.countSell+=1;
                 
               
               if(alltChanges[y].time < tZone.beginTime)
                  tZone.beginTime= alltChanges[y].time;
               if(alltChanges[y].changePrice > tZone.highPrice)
                  tZone.highPrice = alltChanges[y].changePrice;
               if(alltChanges[y].lhPrice > tZone.highPrice)
                  tZone.highPrice = alltChanges[y].lhPrice;   
               if(alltChanges[y].changePrice < tZone.lowPrice)
                  tZone.lowPrice = alltChanges[y].changePrice;
               if(alltChanges[y].lhPrice < tZone.lowPrice)
                  tZone.lowPrice = alltChanges[y].lhPrice;
     
            }
      }
      
      if(tZone.count > 0)
      {
         ArrayResize(zonesArray,ArraySize(zonesArray)+1,0);
         zonesArray[ArraySize(zonesArray)-1]= tZone;
      }
   }  
}


void findSupportResistanceOLD(TrendChange &tChanges[], SRZone &zones[])
{
  
   double PV=MarketInfo(Symbol(),MODE_TICKVALUE);
   for(int x = 0; x < ArraySize(tChanges); x++)
   {
      bool found = false;
      for(int y = 0; y < ArraySize(zones);y++)
      {
         if((tChanges[x].changePrice <= zones[y].price && tChanges[x].changePrice >= (zones[y].price-((150*Point))))
            || (tChanges[x].changePrice >= zones[y].price && tChanges[x].changePrice <= (zones[y].price+((150*Point))) ))
         {
           if(tChanges[x].pos == Buy)
           {
              zones[y].supportCount+=1;
              if(tChanges[x].changePrice < zones[y].price)
              zones[y].price= tChanges[x].changePrice;
           }
            else
            {
              zones[y].resistanceCount +=1; 
              if(tChanges[x].changePrice > zones[y].price)
              zones[y].price= tChanges[x].changePrice;
            }     
              
            found = true;      
         }   
      }
      
      if(found==false)
      {
         ArrayResize(zones,ArraySize(zones)+1,0);
         
         
         zones[ArraySize(zones)-1].price=tChanges[x].changePrice; 
      }
         
   }
   
   
}

void findSupportResistanceXXX(TrendChange &tChanges[], SRZone &zones[])
{
  
    double PV=MarketInfo(Symbol(),MODE_TICKVALUE);
   for(int x = 0; x < ArraySize(tChanges); x++)
   {
      bool found = false;
      for(int y = 0; y < ArraySize(zones);y++)
      {
         if((tChanges[x].changePrice <= zones[y].price && tChanges[x].changePrice >= (zones[y].price-((1050*Point))))
            || (tChanges[x].changePrice >= zones[y].price && tChanges[x].changePrice <= (zones[y].price+((1050*Point))) ))
         {
           if(tChanges[x].pos == Buy)
           {
              zones[y].supportCount+=1;
              if(tChanges[x].changePrice < zones[y].price)
              zones[y].price= tChanges[x].changePrice;
           }
            else
            {
              zones[y].resistanceCount +=1; 
              if(tChanges[x].changePrice > zones[y].price)
              zones[y].price= tChanges[x].changePrice;
            }     
              
            found = true;      
         }   
      }
      
      if(found==false)
      {
         ArrayResize(zones,ArraySize(zones)+1,0);        
         zones[ArraySize(zones)-1].price=tChanges[x].changePrice; 
      }
         
   }
   
   
}

void DrawSupportResistance(SRZone &zones[])
{
  for(int x = 0; x < ArraySize(zones); x++)
   ObjectCreate("SR"+x, OBJ_HLINE, 0, Time[0],zones[x].price, 0, 0);
}

void DrawSupportResistance(ZoneSR &zonesAll[],datetime currentTime,Position pos)
{
  
   ZoneSR zones[];
   
   for(int i = 0; i < ArraySize(zonesAll);i++)
   {
       bool integrated = false;
       
       for(int y = 0; y < ArraySize(zones); y++)
       { 
          //if(zonesAll[i].lowPrice <= zones[y].lowPrice && zonesAll[i].highPrice >= zones[y].highPrice && zonesAll[i].pos == zones[y].pos)
          if(zonesAll[i].lowPrice <= zones[y].lowPrice && zonesAll[i].highPrice >= zones[y].highPrice)
          {
             zones[y].highPrice = zonesAll[i].highPrice;
             zones[y].lowPrice = zonesAll[i].lowPrice;
             integrated = true;
          }
          //else if(zonesAll[i].lowPrice >= zones[y].lowPrice && zonesAll[i].highPrice <= zones[y].highPrice && zonesAll[i].pos == zones[y].pos)
          else if(zonesAll[i].lowPrice >= zones[y].lowPrice && zonesAll[i].highPrice <= zones[y].highPrice)
          {
          //else
          //{
             integrated=true;  
          //}
          }
          else if(zonesAll[i].lowPrice <= zones[y].lowPrice && zonesAll[i].highPrice <= zones[y].highPrice 
                  && zonesAll[i].highPrice >= zones[y].lowPrice && zonesAll[i].highPrice <= zones[y].highPrice
                  && zonesAll[i].pos == zones[y].pos)
          {
             zones[y].lowPrice = zonesAll[i].lowPrice;
             integrated = true;
          }
           // else if(zones[y].lowPrice <= zonesAll[i].lowPrice && zones[y].highPrice <= zonesAll[i].highPrice 
           //       && zones[y].highPrice >= zonesAll[i].lowPrice && zones[y].highPrice <= zonesAll[i].highPrice
           //       && zonesAll[i].pos == zones[y].pos)
            else if(zones[y].lowPrice <= zonesAll[i].lowPrice && zones[y].highPrice <= zonesAll[i].highPrice 
                  && zones[y].highPrice >= zonesAll[i].lowPrice && zones[y].highPrice <= zonesAll[i].highPrice)
          {
             zones[y].highPrice = zonesAll[y].highPrice;
             //zones[y].lowPrice = zonesAll[i].lowPrice;
             integrated = true;
          }   
            
       }
       
       if(!integrated)
       {
         ArrayResize(zones,ArraySize(zones)+1,0);
         zones[ArraySize(zones)-1]=zonesAll[i];
       }
   
   }
   
  ArrayCopy(zones,zonesAll,0,0,WHOLE_ARRAY);

  for(int x = 0; x < ArraySize(zones); x++)
  {
 
   if((pos == zones[x].pos || pos == None))// && (zones[x].countBuy > 5 || zones[x].countSell > 5))
   {
      ObjectCreate("SR"+x,OBJ_RECTANGLE,0,zones[x].beginTime,zones[x].lowPrice,currentTime,zones[x].highPrice);
      
      if(zones[x].countBuy >zones[x].countSell)
         ObjectSetInteger(0,"SR"+x,OBJPROP_COLOR,Green);
      else
         ObjectSetInteger(0,"SR"+x,OBJPROP_COLOR,Red);
     }
     ObjectSetInteger(0,"SR"+x,OBJPROP_BACK,false);
   }
   
   ChartRedraw();
}