//+------------------------------------------------------------------+
//|                                                        Pivot.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

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

enum PivotType
{
   DPivot,
   WPivot,
   MR1,
   R1,
   MR2,
   R2,
   MR3,
   R3,
   MS1,
   S1,
   MS2,
   S2,
   MS3,
   S3
};

enum PivotKind
{
Standard,
Fibo
};

struct PivotRow
{
  PivotType type;
  double PivotPrize;
};




void calculatePivot(PivotRow &rows[],int timeframe,PivotKind kind)
{
  Pivot pivot;
  
  if(kind == Standard)
     calculateStandardPivot(pivot,timeframe);
  else if(kind == Fibo)
     calculateFibonacciPivot(pivot,timeframe);
  
  ArrayFree(rows);
  ArrayResize(rows,14,0);
  
  rows[0].type=DPivot;
  rows[0].PivotPrize=pivot.DPivot;
  rows[1].type=R1;
  rows[1].PivotPrize=pivot.R1;
  rows[2].type=R2;
  rows[2].PivotPrize=pivot.R2;
  rows[3].type=R3;
  rows[3].PivotPrize=pivot.R3;
  rows[4].type=MR1;
  rows[4].PivotPrize=pivot.MR1;
  rows[5].type=MR2;
  rows[5].PivotPrize=pivot.MR2;
  rows[6].type=MR3;  
  rows[6].PivotPrize=pivot.MR3; 
  rows[7].type=S1;
  rows[7].PivotPrize=pivot.S1;
  rows[8].type=S2;
  rows[8].PivotPrize=pivot.S2;
  rows[9].type=S3;
  rows[9].PivotPrize=pivot.S3;
  rows[10].type=MS1;
  rows[10].PivotPrize=pivot.MS1;
  rows[11].type=MS2;
  rows[11].PivotPrize=pivot.MS2;
  rows[12].type=MS3;
  rows[12].PivotPrize=pivot.MS3; 
  rows[13].type=WPivot;
  rows[13].PivotPrize=pivot.WPivot; 
 
  
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
   
   /*R3 = Pivot + 1.000 * (H - L)

R2 = Pivot + 0.618 * (H - L)

R1 = Pivot + 0.382 * (H - L)

Pivot = ( H + L + C ) / 3 

S1 = Pivot - 0.382 * (H - L)

S2 = Pivot - 0.618 * (H - L) 

S3 = Pivot - 1.000 * (H - L) 
*/

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

void DrawPivot(PivotRow &pivotRow[],bool drawMidPivots)
{
  for(int i = 0; i < ArraySize(pivotRow);i++)
  {
  
  if(pivotRow[i].type != MR1 && pivotRow[i].type != MR2 && pivotRow[i].type != MR3 && pivotRow[i].type != MS1 && pivotRow[i].type != MS2 && pivotRow[i].type != MS3 )
   ObjectCreate(EnumToString(pivotRow[i].type)+DoubleToString(pivotRow[i].PivotPrize), OBJ_HLINE, 0, Time[0],pivotRow[i].PivotPrize, 0, 0);
   
   if(drawMidPivots && (pivotRow[i].type == MR1 || pivotRow[i].type == MR2 || pivotRow[i].type == MR3 || pivotRow[i].type == MS1 || pivotRow[i].type == MS2 || pivotRow[i].type == MS3 ))
   ObjectCreate(EnumToString(pivotRow[i].type)+DoubleToString(pivotRow[i].PivotPrize), OBJ_HLINE, 0, Time[0],pivotRow[i].PivotPrize, 0, 0);
   
   if(pivotRow[i].type == DPivot)
   ObjectSetInteger(0,EnumToString(pivotRow[i].type)+DoubleToString(pivotRow[i].PivotPrize),OBJPROP_COLOR,Blue);
   
    if(pivotRow[i].type == WPivot)
   ObjectSetInteger(0,EnumToString(pivotRow[i].type)+DoubleToString(pivotRow[i].PivotPrize),OBJPROP_COLOR,Black);
  
  if(pivotRow[i].type == R1 || pivotRow[i].type == R2 || pivotRow[i].type == R3)
  ObjectSetInteger(0,EnumToString(pivotRow[i].type)+DoubleToString(pivotRow[i].PivotPrize),OBJPROP_COLOR,Red);
  
  if(pivotRow[i].type == S1 || pivotRow[i].type == S2 || pivotRow[i].type == S3)
  ObjectSetInteger(0,EnumToString(pivotRow[i].type)+DoubleToString(pivotRow[i].PivotPrize),OBJPROP_COLOR,Green);
  
  if(drawMidPivots && (pivotRow[i].type == MR1 || pivotRow[i].type == MR2 || pivotRow[i].type == MR3 || pivotRow[i].type == MS1 || pivotRow[i].type == MS2 || pivotRow[i].type == MS3 ))
  ObjectSetInteger(0,EnumToString(pivotRow[i].type)+DoubleToString(pivotRow[i].PivotPrize),OBJPROP_COLOR,Gray);
  }
}

double findStopPivot(PivotRow &rows[],double matchingPivot,Position pos, bool includeMids)
{
   double result=0.0;
   for(int i = 0; i < ArraySize(rows); i++)
   {
      //if(includeMids == false && rows[i].type!= MS1 && rows[i].type!= MS2 && rows[i].type!= MS3 && rows[i].type!= MR1 && rows[i].type!= MR2 && rows[i].type!= MR3)
      //{
       if(pos==Sell && rows[i].PivotPrize > matchingPivot && (rows[i].PivotPrize < result || result==0.0)  )
       {
         result = rows[i].PivotPrize;
         //Print(DoubleToStr(result));
        
       }
       else if(pos==Buy && rows[i].PivotPrize < matchingPivot && (rows[i].PivotPrize > result || result==0.0) )
       {
         result = rows[i].PivotPrize;
          //Print(DoubleToStr(result));
         
       }
      //}
   }
   
   return result*1.0;
}

double findNextPivot(PivotRow &rows[],double price,Position pos,bool includeMids)
{
   double result=0.0;
   for(int i = 0; i < ArraySize(rows); i++)
   {
     if( includeMids ==false && rows[i].type!= MS1 && rows[i].type!= MS2 && rows[i].type!= MS3 && rows[i].type!= MR1 && rows[i].type!= MR2 && rows[i].type!= MR3)
     {
       if(pos==Sell && rows[i].PivotPrize < price && (rows[i].PivotPrize > result || result==0.0)  )
       {
         result = rows[i].PivotPrize;
         //Print(DoubleToStr(result));
        
       }
       else if(pos==Buy && rows[i].PivotPrize > price && (rows[i].PivotPrize < result || result==0.0) )
       {
         result = rows[i].PivotPrize;
          //Print(DoubleToStr(result));
         
       }
      }
   }
   
   return result*1.0;
}