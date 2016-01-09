//+------------------------------------------------------------------+
//|                                                  TrendLinien.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include <EWDeluxe2/Buffers.mqh>
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

void findTrendLinien(int shift)
{
  Buffers buffer;
  
  
  initBuffers(buffer,shift,50,Period(),true);
  
  double low1= buffer.LowBuffer[0];
  datetime time1 = buffer.TimeBuffer[0];
  double low2 = buffer.LowBuffer[0];
  datetime time2 = buffer.TimeBuffer[0];
  
   double high1= buffer.LowBuffer[0];
  datetime timeH1 = buffer.TimeBuffer[0];
  double high2 = buffer.LowBuffer[0];
  datetime timeH2 = buffer.TimeBuffer[0];
  
  for(int i=0; i<50;i++)
  {
     if(buffer.HighBuffer[i] > high1)
     {
       high2 = high1;
       timeH2= timeH1;
       
       high1=buffer.HighBuffer[i];
       timeH1=buffer.TimeBuffer[i];
     }
  }
  
  for(int i=0; i<50;i++)
  {
     if(buffer.LowBuffer[i] < low1)
     {
       low2 = low1;
       time2= time1;
       
       low1=buffer.LowBuffer[i];
       time1=buffer.TimeBuffer[i];
     }
  }
  
  ObjectCreate( "trendLineL", OBJ_TREND,0, time1, low1, time2, low2);
  ObjectCreate( "trendLineH", OBJ_TREND,0, timeH1, high1, timeH2, high2);
  
}