//+------------------------------------------------------------------+
//|                                                        enums.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict
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
enum Position
{
   Buy,
   Sell,
   None
};

enum TriggerType 
  {
   CPT,
   CBEE,
   CBUE,
   CH,
   CTS,
   CDC,
   CIH,
   ADX,
   STC
  };
  
struct TradeTrigger 
  {
   TriggerType       triggerType;
   Position          pos;
   datetime          time;
   double            possibleStopLoss;
   double drawPos;
   double triggerHigh;
   double triggerLow;
   bool TriggerOnPivot;
   int PivotCount;
   double PivotMatchPrice;
   double triggerClosePrice; 
 };


struct Configuration
{
   //bool doKalibration;
   //bool useDatesForKalibration;
   //bool useTradingTime;
   //datetime KalibarationStartDate;
   //datetime KalibrationEndDate;
   //string InpFileName;

   bool TriggerBearishEngulfing;
   bool TriggerBullishEngulfing;
   bool TriggerHammer;
   bool TriggerInvertedHammer;
   bool TriggerDarkClouds;
   bool TriggerThreeWhiteSoldiers;
   bool TriggerADX;
   bool TriggerStochCrossing;
   
   //bool simulate;
   //bool ProfitOption;
   //double stdv;
  
   
   //bool doOnlyTradesOnTrend;
};