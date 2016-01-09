//+------------------------------------------------------------------+
//|                                                 PositionEnum.mqh |
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
   Sell
};

struct Buffers
{
double LowBuffer[];
double HighBuffer[];
double OpenBuffer[];
double CloseBuffer[];
datetime TimeBuffer[];
long VolumeBuffer[];

double RSIBuffer[];
double LowBandBuffer[];
double HighBandBuffer[];
double STOCHBuffer[];
double STOCHBufferSignal[];
double STOCHBufferValue[];

double CurrentMABuffer[];
double OneAboveMABuffer[];
double TwoAboveBuffer[];

long avgVolume;

double avgStdv;
};

enum CandleStickType {
None,
BearishEngulfing,
BullishEngulfing,
ThreeSoldiers,
ThreeDarkCloud,
Hammer,
InvertedHammer
};

enum FakePositionStatus
{
SOpen,
Unclear,
Won,
Lost
};

struct FakePosition
{
 Position pos;
 datetime time;
 double ask;
 double bid;
 double stpl;
 double takeprofit;
 double positionGr;
 FakePositionStatus status;
 datetime endtime;
 double Profit;
};

struct ValidationCriteria
{
 
 double GewichtungMA200Trend;
 double GewichtungRSIRange;
 double GewichtungStoch;
 double GewichtungBand;
 double GewichtungSmallTrend;
 
 double ValidSchwelle;
// double stdAvg;
};

struct TriggersValidationCriteria
{
ValidationCriteria CandleStickBearishEngulfingCriteria;
ValidationCriteria CandleStickBullishEngulfingCriteria;
ValidationCriteria CandleStickHammerCriteria;
ValidationCriteria CandleStickThreeSoldiersCriteria;
ValidationCriteria CandleStickDarkCloudsCriteria;
ValidationCriteria CandleStickInvertedHammerCriteria;
ValidationCriteria ADXCriteria;;
ValidationCriteria STOCHCROSSCriteria;

};


struct KalibrationResult
{
  int Won;
  int Lost;
  double Profit;
  ValidationCriteria criteria;
};

struct MA200DifPeriods
{
  double CurrentMABuffer[];
  double OneAboveMABuffer[];
  double TwoAboveBuffer[];
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
  };

struct Configuration
{
   bool doKalibration;
   bool useDatesForKalibration;
   bool useTradingTime;
   datetime KalibarationStartDate;
   datetime KalibrationEndDate;
   string InpFileName;

   bool TriggerBearishEngulfing;
   bool TriggerBullishEngulfing;
   bool TriggerHammer;
   bool TriggerInvertedHammer;
   bool TriggerDarkClouds;
   bool TriggerThreeWhiteSoldiers;
   bool TriggerADX;
   bool TriggerStochCrossing;
   
   bool simulate;
   bool ProfitOption;
   double stdv;
  
   
   bool doOnlyTradesOnTrend;
};
