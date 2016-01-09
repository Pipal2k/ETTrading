//+------------------------------------------------------------------+
//|                                                   WendePunkt.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include <EWDeluxe2/Buffers.mqh>
#include <EWDeluxe2/enums.mqh>
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



struct TrendChange{
  datetime time;
  int barCount;
  int Category;
  double drawPos;
  double changePrice;
  double lhPrice; 
  Position pos;
};



void findCAT1TrendChange(int barCount,TrendChange &tChange[])
{
     //Buffers buffer;
     //initBuffers(buffer,0,shift+20,Period(),false);
     
     //Print(ArraySize(buffer.CloseBuffer));
    // int startShift=iBarShift(Symbol(),Period(),Time[0],true);
     //Print("StartShift",startShift);
      Buffers barBuffer;
     initBuffers(barBuffer,Time[0],barCount,Period(),true);
     findTrendChanges(barCount,barBuffer,tChange);
     normalizeTrendWende(tChange);
    
}

void getTrendChanges(TrendChange &tChanges[],int Category, TrendChange &destTrendChanges[])
{
   getTrendChanges(tChanges,Category,destTrendChanges,None);
}

void getTrendChanges(TrendChange &tChanges[],int Category, TrendChange &destTrendChanges[], Position pos)
{
   for(int x= 0; x< ArraySize(tChanges);x++)
   {
      if(tChanges[x].Category >= Category && (tChanges[x].pos == pos || pos == None))
      {
       ArrayResize(destTrendChanges,ArraySize(destTrendChanges)+1,0);
       destTrendChanges[ArraySize(destTrendChanges)-1]= tChanges[x];
      }
   }
}


void getLatestTrendChanges(TrendChange &tChanges[],int Category, TrendChange &destTrendChanges[])
{

   int x = ArraySize(tChanges)-1;
   bool foundBuy = false;
   bool foundSell = false;
   
   while(x > 0)
   {
     if(tChanges[x].Category >= Category)
     { 
        if(tChanges[x].pos == Sell && foundSell == false)
        {
         ArrayResize(destTrendChanges,ArraySize(destTrendChanges)+1,0);
         destTrendChanges[ArraySize(destTrendChanges)-1]= tChanges[x];
         foundSell = true;
        }
        else if(tChanges[x].pos == Buy && foundBuy ==false)
        {
          ArrayResize(destTrendChanges,ArraySize(destTrendChanges)+1,0);
          destTrendChanges[ArraySize(destTrendChanges)-1]= tChanges[x];
          foundBuy = true;
        }
        
     }
     if(foundSell && foundBuy)
       break;
     x--; 
   }
   return;
}



void findTrendChanges(int barCount,Buffers &barBufferAll,TrendChange &tChanges[])
{
     Buffers barBuffer; 
    
     for(int i = barCount; i > 0; i--)
     {
      TrendChange tempC;
      CopyBuffer(barBuffer,i,3,barBufferAll);
      //ArrayCopy(barBuffer
      //initBuffers(barBuffer,i+startShift,3,Period(),true);
      if(ArraySize(barBuffer.CloseBuffer) > 2)
      {
            if(barBuffer.HighBuffer[2] <  barBuffer.HighBuffer[1] && barBuffer.HighBuffer[0] < barBuffer.HighBuffer[1])
            {
              tempC.time= barBuffer.TimeBuffer[1];
              tempC.drawPos = barBuffer.LowBuffer[1];
              tempC.changePrice=barBuffer.HighBuffer[1];
              
              if(barBuffer.CloseBuffer[1] >= barBuffer.OpenBuffer[1])
                 tempC.lhPrice=barBuffer.CloseBuffer[1];
              else   
                 tempC.lhPrice=barBuffer.OpenBuffer[1];
                 
              tempC.pos= Sell;
              ArrayResize(tChanges,ArraySize(tChanges)+1,0);
              tChanges[ArraySize(tChanges)-1]=tempC;
            }
            else if(barBuffer.LowBuffer[2] >  barBuffer.LowBuffer[1] && barBuffer.LowBuffer[0] > barBuffer.LowBuffer[1])
            {
              tempC.time= barBuffer.TimeBuffer[1];
              tempC.drawPos = barBuffer.LowBuffer[1];
              tempC.changePrice=barBuffer.LowBuffer[1];
              
               if(barBuffer.CloseBuffer[1] <= barBuffer.OpenBuffer[1])
                 tempC.lhPrice=barBuffer.CloseBuffer[1];
              else   
                 tempC.lhPrice=barBuffer.OpenBuffer[1];
              
              tempC.pos=Buy;
              ArrayResize(tChanges,ArraySize(tChanges)+1,0);
              tChanges[ArraySize(tChanges)-1]=tempC;
            }
       }
    }
}



void lookForHigh(int shift,Buffers &buffers,int count,TrendChange &tChanges[])
{
      double cH=buffers.CloseBuffer[shift];
      datetime time;
      double drawPos;
      int x=0;
       TrendChange tempC;
      
      for(int i = shift; i<shift+count;i++)
      {
        if(buffers.CloseBuffer[i] > cH)
        {
           cH= buffers.CloseBuffer[i];
           time= buffers.TimeBuffer[i];
           drawPos = buffers.LowBuffer[i];
           x=count-(i-shift);
        }
      }
      
      tempC.time=time;
      tempC.barCount= x;
      tempC.drawPos = drawPos;
      //tempC.Category= normalizeTrendWende(x);
      
      AddTrendWende(tempC,tChanges);

}

void lookForLow(int shift,Buffers &buffers,int count,TrendChange &tChanges[])
{
      double cL=buffers.CloseBuffer[shift];
      datetime time;
      TrendChange tempC;
       double drawPos;
       int x=0;
       
      for(int i = shift; i< shift+count;i++)
      {
        if(buffers.CloseBuffer[i] < cL)
        {
           cL= buffers.CloseBuffer[i];
           time= buffers.TimeBuffer[i];
           drawPos = buffers.LowBuffer[i];
           x=count -(i-shift);
        }
      }
      
      tempC.time=time;
       tempC.barCount= x;
       tempC.drawPos = drawPos;
      // tempC.Category= normalizeTrendWende(x);
      
      AddTrendWende(tempC,tChanges);
      
      
}

void AddTrendWende(TrendChange &c,TrendChange &tChanges[])
{
  bool exist = false;
  for(int i = 0;i < ArraySize(tChanges);i++)
  {
    if(tChanges[i].time==c.time && tChanges[i].Category == c.Category)
    {
      exist = true;
      break;
    }
  }
   
   if(exist == false)
   {
      ArrayResize(tChanges,ArraySize(tChanges)+1,0);
      tChanges[ArraySize(tChanges)-1]=c;
   }
   
}

void normalizeTrendWende(TrendChange &tChanges[])
{
  
  Buffers buffer;
   
  for(int i = 0; i < ArraySize(tChanges); i++)
  {
     initBuffers(buffer,tChanges[i].time,110,Period(),true);
     //Print(buffer.TimeBuffer[1]);
     
     int x;
     for(x = 1; x < 110; x++)
     {
         if(tChanges[i].pos == Sell)
         {
              if(buffer.HighBuffer[x] >=tChanges[i].changePrice)
              break;       
         }
         else if(tChanges[i].pos == Buy)
         {
            if(buffer.LowBuffer[x] <=tChanges[i].changePrice)
            break;
         }
     }
     
     int sec=PeriodSeconds();
     int shiftC;// = ( Time[0]-tChanges[i].time) / PeriodSeconds();
     shiftC=iBarShift(Symbol(),Period(),tChanges[i].time,true);
    
    Buffers buffer2;
    initBuffers(buffer2,Time[0],shiftC+1,Period(),false);
     
   // Print(tChanges[i].time); 
   // Print(buffer2.TimeBuffer[1]);
    
      //Print(buffer2.TimeBuffer[]);
     
     int y;
     for(y = 1; y < shiftC; y++)
     {
         if(tChanges[i].pos == Sell)
         {
              if(buffer2.HighBuffer[y] >=tChanges[i].changePrice)
              break;       
         }
         else if(tChanges[i].pos == Buy)
         {
            if(buffer2.LowBuffer[y] <=tChanges[i].changePrice)
            break;
         }
         
     }
     
     if(y > x) //&& (y!=(shiftC-1)))
       x=y;
     
     if(x <=5)
      tChanges[i].Category=1;
     else if(x <=10)
       tChanges[i].Category=2;
     else if(x <=15)
      tChanges[i].Category=3;
     else if(x <=20)
       tChanges[i].Category=4;
     else if(x <=25)
       tChanges[i].Category=5;
       else if(x <=30)
       tChanges[i].Category=6;
       else if(x <=35)
       tChanges[i].Category=7;
       else if(x <=40)
       tChanges[i].Category=8;
       else if(x <=45)
       tChanges[i].Category=9;
       else if(x <=50)
       tChanges[i].Category=10;                 
     else
      tChanges[i].Category=11; 
     
  }
}

void normalizeTrendWendeXXX(TrendChange &tChanges[])
{
   
   
  for(int i = 0; i < ArraySize(tChanges); i++)
  {
  
   Buffers buffer;
   
   int wendePunktIndex=iBarShift(Symbol(),Period(),tChanges[i].time);
   Print("shif:"+wendePunktIndex+" date:"+tChanges[i].time);
   
    
    initBuffers(buffer,tChanges[i].time,wendePunktIndex,Period(),true);
    
    
    double closeP= tChanges[i].changePrice;
    
    //Buffers buffer;
    //initBuffers(buffer,0,index,Period(),false);
    int index = wendePunktIndex-1;
    int index2 = wendePunktIndex-1;
    int countX = 1;
    int countY = 1;
    
    if(tChanges[i].pos == Sell)
    {
      
      while(index > 0)
      {
         if(buffer.HighBuffer[index] > closeP)
         break;
         
         index--;
         countX++;
      }
     // while(index2 < ArraySize(buffer.HighBuffer))
     // {
       //  if(buffer.HighBuffer[index2] > closeP)
      //   break;
         
       //  index2++;
      //   countY++;
     // }
      
    }
    else if(tChanges[i].pos == Buy)
    {
      
     while(index > 0)
      {
         if(buffer.LowBuffer[index] < closeP)
         break;
         
         index--;
         countX++;
    
      }
      // while(index2 < ArraySize(buffer.LowBuffer))
     // {
      //   if(buffer.LowBuffer[index2] < closeP)
      //   break;
         
     //    index2++;
     //    countY++;
     // }
      
    }
    
    
     if(countX <=10)
      tChanges[i].Category=1;
     else if(countX <=25)
       tChanges[i].Category=2;
     else if(countX <=50)
      tChanges[i].Category=3;
     else if(countX <=100)
       tChanges[i].Category=4;   
     else
      tChanges[i].Category=4; 
      
  }

 
   
}


int normalizeTrendWendeXX(int count)
{
  if(count <=10)
   return 1;
  else if(count <=50)
   return 2;
  else if(count <=100)
    return 3;
  else if(count <=200)
    return 5;   
  else
    return 5; 
   
}

void DrawTrendChanges(TrendChange &tChanges[],int Category)
{

   for(int i = 0; i < ArraySize(tChanges);i++)
   {
     //if(tChanges[i].Category >= Category)
     //{
      if(tChanges[i].pos == Buy)
      {
         ObjectCreate("Arrow"+tChanges[i].time,OBJ_ARROW_UP,0,tChanges[i].time,tChanges[i].drawPos);
         ObjectCreate("HL"+tChanges[i].time, OBJ_HLINE, 0, Time[0], tChanges[i].changePrice, 0, 0);
      }
      else
      {
        ObjectCreate("Arrow"+tChanges[i].time,OBJ_ARROW_DOWN,0,tChanges[i].time,tChanges[i].drawPos);
         ObjectCreate("HL"+tChanges[i].time, OBJ_HLINE, 0, Time[0], tChanges[i].changePrice, 0, 0);
      }
     //}
   }
   

}