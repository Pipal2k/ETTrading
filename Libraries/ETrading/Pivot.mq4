//+------------------------------------------------------------------+
//|                                                        Pivot.mq4 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "2005-2015, MetaQuotes Software Corp."
#property link      "http://www.mql4.com"
#property library
#property strict

#include <ETrading/ETDataTypes.mqh>
//+------------------------------------------------------------------+
//| My function                                                      |
//+------------------------------------------------------------------+
// int MyCalculator(int value,int value2) export
//   {
//    return(value+value2);
//   }
//+------------------------------------------------------------------+
struct Pivot
{
   double R3;
   double MR3;
   double R2;
   double MR2;
   double R1;
   double MR1;
   double DPivot;
   double WPivot;
   double MS1;
   double S1;
   double MS2;
   double S2;
   double MS3;
   double S3;
};





//struct PivotRow
//{
//  PivotType type;
//  double Prize;
//};



void calculatePivot(SR_Row &rows[], int timeframe, PivotKind kind) export
{
  Pivot pivot;
  
  if(kind == Standard)
     calculateStandardPivot(pivot,timeframe);
  else if(kind == Fibo)
     calculateFibonacciPivot(pivot,timeframe);
  
  
  ArrayResize(rows,ArraySize(rows)+14,0);
  
  rows[0].type=DPivot;
  rows[0].Prize=pivot.DPivot;
  rows[1].type=R1;
  rows[1].Prize=pivot.R1;
  rows[2].type=R2;
  rows[2].Prize=pivot.R2;
  rows[3].type=R3;
  rows[3].Prize=pivot.R3;
  rows[4].type=MR1;
  rows[4].Prize=pivot.MR1;
  rows[5].type=MR2;
  rows[5].Prize=pivot.MR2;
  rows[6].type=MR3;  
  rows[6].Prize=pivot.MR3; 
  rows[7].type=S1;
  rows[7].Prize=pivot.S1;
  rows[8].type=S2;
  rows[8].Prize=pivot.S2;
  rows[9].type=S3;
  rows[9].Prize=pivot.S3;
  rows[10].type=MS1;
  rows[10].Prize=pivot.MS1;
  rows[11].type=MS2;
  rows[11].Prize=pivot.MS2;
  rows[12].type=MS3;
  rows[12].Prize=pivot.MS3; 
  rows[13].type=WPivot;
  rows[13].Prize=pivot.WPivot; 
 
  
}



void calculateStandardPivot(Pivot &pivot, int timeframe) 
{
   double lDHigh = iHigh(Symbol(), timeframe, 1);
   double lDLow = iLow(Symbol(), timeframe, 1);
   double lDClose = iClose(Symbol(), timeframe, 1);
   
     double lDHighW = iHigh(Symbol(), PERIOD_W1, 1);
   double lDLowW = iLow(Symbol(), PERIOD_W1, 1);
   double lDCloseW = iClose(Symbol(), PERIOD_W1, 1);

   pivot.DPivot = (lDHigh+lDLow+lDClose)/3;
    pivot.WPivot = (lDHighW+lDLowW+lDCloseW)/3;
   pivot.R1= (2*pivot.DPivot)-lDLow;
   pivot.R2 = pivot.DPivot+(lDHigh-lDLow);
   pivot.R3 = lDHigh+2*(pivot.DPivot-lDLow);
   pivot.S1 = (2 * pivot.DPivot)- lDHigh;
   pivot.S2 = pivot.DPivot-(lDHigh-lDLow);
   pivot.S3 = lDLow - 2*(lDHigh-pivot.DPivot); 
  
   pivot.MR1 = pivot.DPivot + ((pivot.R1-pivot.DPivot)/2);
   pivot.MR2 = pivot.R1 + ((pivot.R2-pivot.R1)/2); 
   pivot.MR3 = pivot.R2 + ((pivot.R3-pivot.R2)/2);
   
   pivot.MS1 = pivot.DPivot - ((pivot.DPivot-pivot.S1)/2);
   pivot.MS2 = pivot.S1 - ((pivot.S1-pivot.S2)/2);
   pivot.MS3 = pivot.S2 - ((pivot.S2-pivot.S3)/2);
}

void calculateFibonacciPivot(Pivot &pivot, int timeframe)
{
   double lDHigh = iHigh(Symbol(), timeframe, 1);
   double lDLow = iLow(Symbol(), timeframe, 1);
   double lDClose = iClose(Symbol(), timeframe, 1);
   
     double lDHighW = iHigh(Symbol(), PERIOD_W1, 1);
   double lDLowW = iLow(Symbol(), PERIOD_W1, 1);
   double lDCloseW = iClose(Symbol(), PERIOD_W1, 1);

   pivot.DPivot = (lDHigh+lDLow+lDClose)/3;
    pivot.WPivot = (lDHighW+lDLowW+lDCloseW)/3;
   pivot.R1= pivot.DPivot + 0.382 * (lDHigh-lDLow);
   pivot.R2 = pivot.DPivot + 0.618 * (lDHigh-lDLow);
   pivot.R3 = pivot.DPivot+1.000 * (lDHigh-lDLow);
   pivot.S1 = pivot.DPivot - 0.382 * (lDHigh-lDLow);
   pivot.S2 = pivot.DPivot - 0.618 * (lDHigh-lDLow);
   pivot.S3 = pivot.DPivot - 1.000 * (lDHigh-lDLow); 
  
   pivot.MR1 = pivot.DPivot + ((pivot.R1-pivot.DPivot)/2);
   pivot.MR2 = pivot.R1 + ((pivot.R2-pivot.R1)/2); 
   pivot.MR3 = pivot.R2 + ((pivot.R3-pivot.R2)/2);
   
   pivot.MS1 = pivot.DPivot - ((pivot.DPivot-pivot.S1)/2);
   pivot.MS2 = pivot.S1 - ((pivot.S1-pivot.S2)/2);
   pivot.MS3 = pivot.S2 - ((pivot.S2-pivot.S3)/2);
}


void DrawPivot(Pivot &pivot)
{
  ObjectCreate("DP"+pivot.DPivot, OBJ_HLINE, 0, Time[0],pivot.DPivot, 0, 0);
   ObjectSetInteger(0,"DP"+pivot.DPivot,OBJPROP_COLOR,Blue);
  
  ObjectCreate("RP"+pivot.R1, OBJ_HLINE, 0, Time[0],pivot.R1, 0, 0);
  ObjectSetInteger(0,"RP"+pivot.R1,OBJPROP_COLOR,Red);
  ObjectCreate("RP"+pivot.R2, OBJ_HLINE, 0, Time[0],pivot.R2, 0, 0);
  ObjectSetInteger(0,"RP"+pivot.R2,OBJPROP_COLOR,Red);
  ObjectCreate("RP"+pivot.R3, OBJ_HLINE, 0, Time[0],pivot.R3, 0, 0);
  ObjectSetInteger(0,"RP"+pivot.R3,OBJPROP_COLOR,Red);
   
  ObjectCreate("SP"+pivot.S1, OBJ_HLINE, 0, Time[0],pivot.S1, 0, 0);
  ObjectSetInteger(0,"SP"+pivot.S1,OBJPROP_COLOR,Green);
  ObjectCreate("SP"+pivot.S2, OBJ_HLINE, 0, Time[0],pivot.S2, 0, 0);
  ObjectSetInteger(0,"SP"+pivot.S2,OBJPROP_COLOR,Green);
  ObjectCreate("SP"+pivot.S3, OBJ_HLINE, 0, Time[0],pivot.S3, 0, 0);   
  ObjectSetInteger(0,"SP"+pivot.S3,OBJPROP_COLOR,Green);
  
}



double findStopPivot(SR_Row &rows[],double matchingPivot,Position pos, bool includeMids)
{
   double result=0.0;
   for(int i = 0; i < ArraySize(rows); i++)
   {
      //if(includeMids == false && rows[i].type!= MS1 && rows[i].type!= MS2 && rows[i].type!= MS3 && rows[i].type!= MR1 && rows[i].type!= MR2 && rows[i].type!= MR3)
      //{
       if(pos==Sell && rows[i].Prize > matchingPivot && (rows[i].Prize < result || result==0.0)  )
       {
         result = rows[i].Prize;
         //Print(DoubleToStr(result));
        
       }
       else if(pos==Buy && rows[i].Prize < matchingPivot && (rows[i].Prize > result || result==0.0) )
       {
         result = rows[i].Prize;
          //Print(DoubleToStr(result));
         
       }
      //}
   }
   
   return result*1.0;
}

double findNextPivot(SR_Row &rows[],double price,Position pos,bool includeMids)
{
   double result=0.0;
   for(int i = 0; i < ArraySize(rows); i++)
   {
     if( includeMids ==false && rows[i].type!= MS1 && rows[i].type!= MS2 && rows[i].type!= MS3 && rows[i].type!= MR1 && rows[i].type!= MR2 && rows[i].type!= MR3)
     {
       if(pos==Sell && rows[i].Prize < price && (rows[i].Prize > result || result==0.0)  )
       {
         result = rows[i].Prize;
         //Print(DoubleToStr(result));
        
       }
       else if(pos==Buy && rows[i].Prize > price && (rows[i].Prize < result || result==0.0) )
       {
         result = rows[i].Prize;
          //Print(DoubleToStr(result));
         
       }
      }
   }
   
   return result*1.0;
}