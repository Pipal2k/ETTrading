//+------------------------------------------------------------------+
//|                                             ETIndikatorInfos.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

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
void setIndikatorInfos(MetaInfo &info)
{
   setRSI(info.RSI);
   setSTOCH(info.STOCH);
}

void setRSI(double result)
{
   result = iRSI(NULL,Period(),14,PRICE_CLOSE,0);
}

void setSTOCH(double result)
{
   result  = iStochastic(NULL,Period(),9,6,6,MODE_SMA,0,MODE_MAIN,0);
}