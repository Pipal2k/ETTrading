
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

#define SIG_SR_BREAKTHROUGHBEARISH 0x01
#define SIG_SR_BREAKTHROUGHBULLISH 0x02
#define SIG_SR_TOUCHLOWERBOUNDERY 0x04
#define SIG_SR_TOUCHHIGHERBOUNDERY 0x08
#define SIG_BEARISHCANDLESTICK 0x10
#define SIG_BULLISHCADLESTICK 0x20
#define SIG_BARBULLISH 0x40
#define SIG_BARBEARISH 0x80
#define SIG_SR_TOUCHBEARISH 0x100
#define SIG_SR_TOUCHBULLISH 0x200
#define SIG_ANY 0x400


enum Position
{
   Buy,
   Sell,
   None
};

enum DataProviderSys_Options
{
   PIVOT = 0x01,
   FPIVOT = 0x02,
   KEYLEVELS =0x04,
};

enum SR_Find_Options
{
   //PIVOT = 0x01,
   //FPIVOT = 0x02,
   //KEYLEVELS =0x04,
   DRAW_SR_ROWS= 0x08,
   DRAW_SR_MID_PIVOTS = 0x10,
   DEBUG_SIGNALS = 0x20
};

enum FlagOperator
{
 OR,
 AND
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

enum PivotKind
{
Standard,
Fibo
};

enum RowType
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

struct SR_Row
{
  RowType type;
  double Prize;
};

struct SR_Zone
{
 double HighBorder;
 double LowBorder;
};

struct MetaInfo
{
  //SR_Zone SR_BREAKS[];
  //SR_Zone SR_TOUCHED[];
  
  SR_Zone iSIG_SR_TOUCHLOWERBOUNDERY[];
  SR_Zone iSIG_SR_TOUCHHIGHERBOUNDERY[];
  SR_Zone iSIG_SR_BREAKTHROUGHBEARISH[];
  SR_Zone iSIG_SR_BREAKTHROUGHBULLISH[];
  
  double RSI;
  double STOCH;
  double CCI;
};

struct ETSignal
{
   datetime time;
   int sig_flags;
   MetaInfo metaInfo;
};

struct CompiledTerm
{
   int flags[];
   FlagOperator fOperators[];
   //string wildcats[];
   string sTerm;
   
};

struct ActionPattern
{
  string name;
  string Expression;
  Position pos;
  
  datetime matchingTimes[];
  
  //int signals[]; //Flags 
  
};

struct CompiledBarActionPattern
{
   //int flags[];
   CompiledTerm compTerm[]; //Oder verknüpft 
   FlagOperator fOperators[];
   int wildcatMinOcc;
   int wildcatMaxOcc;
   int occ;
   string flagsString[];
   
   
   ETSignal matchingSignals[];
   
};

enum WhereOperantTyp
{
   BAROPERANT,
   FUNKTIONOPERANT,
   VALUEOPERANT
};

enum WhereOperantFuncAttribute
{
   NONE,
   LOWBORDER,
   HIGHBORDER
};


enum WhereOperantFunc
{
   RSI,
   STOCH,
   CCI,
   iSIG_SR_BREAKTHROUGHBEARISH,
   iSIG_SR_BREAKTHROUGHBULLISH,
   iSIG_SR_TOUCHHIGHERBOUNDERY,
   iSIG_SR_TOUCHLOWERBOUNDERY
};

struct WhereCondition
{
 int OperantBarIndex1;
 WhereOperantFunc Operant1Func;
 WhereOperantFuncAttribute Operant1FuncAttr;
 WhereOperantTyp Operant1Typ;
 double Operant1Value;
 
 string Operator;
 
 int OperantBarIndex2;
 WhereOperantFunc Operant2Func;
 WhereOperantFuncAttribute Operant2FuncAttr;
 WhereOperantTyp Operant2Typ;
 double Operant2Value;
};

struct CompiledActionPattern {
   string fullExpression;
   string ExpPerBar[];
   string WhereConditionStr;
   ActionPattern actionPattern; 
   //Compiled Patterns
   CompiledBarActionPattern compiledBarPatterns[];
   
   WhereCondition whereCondition[];
   FlagOperator whereCondOperator[];
   
};


void copyMetaInfo(MetaInfo &src, MetaInfo &dst)
{

  ArrayCopy(dst.iSIG_SR_BREAKTHROUGHBEARISH,src.iSIG_SR_BREAKTHROUGHBEARISH,0,0,WHOLE_ARRAY);
   ArrayCopy(dst.iSIG_SR_BREAKTHROUGHBULLISH,src.iSIG_SR_BREAKTHROUGHBULLISH,0,0,WHOLE_ARRAY);
   //ArrayCopy(dst.SR_TOUCHED,src.SR_TOUCHED,0,0,WHOLE_ARRAY);
   ArrayCopy(dst.iSIG_SR_TOUCHLOWERBOUNDERY,src.iSIG_SR_TOUCHLOWERBOUNDERY,0,0,WHOLE_ARRAY);
    ArrayCopy(dst.iSIG_SR_TOUCHHIGHERBOUNDERY,src.iSIG_SR_TOUCHHIGHERBOUNDERY,0,0,WHOLE_ARRAY);
    
    dst.CCI = src.CCI;
    dst.RSI= src.RSI;
    dst.STOCH =src.STOCH;
}

void copySRZones(SR_Zone &src, SR_Zone &dst)
{
  dst.HighBorder=src.HighBorder;
  dst.LowBorder=src.LowBorder;
  //ArrayCopy(dst.S,src.SR_BREAKS,0,0,WHOLE_ARRAY);
}

void copyETSignal(ETSignal &src, ETSignal &dst)
{
   dst.sig_flags = src.sig_flags;
  dst.time=src.time;
  
  copyMetaInfo(src.metaInfo,dst.metaInfo);
  //ArrayCopy(dst.S,src.SR_BREAKS,0,0,WHOLE_ARRAY);
}

void copyActionPattern(ActionPattern &dest[], ActionPattern &source[])
{
   ArrayResize(dest,ArraySize(source),0);
   for(int i = 0; i < ArraySize(source); i++)
   {
     copyActionPattern(dest[i],source[i]);
     //dest[i].pos= source[i].pos;
     //dest[i].Expression = source[i].Expression;
     //dest[i].name = source[i].name;
     
     //ArrayResize(dest[i].signals,ArraySize(source[i].signals),0);
     //for(int x=0; x < ArraySize(source[i].signals);x++)
     //{
     //  dest[i].signals[x]=source[i].signals[x];
    // }
       
   }
}
void copyActionPattern(ActionPattern &dest, ActionPattern &source)
{
     dest.pos= source.pos;
     dest.Expression = source.Expression;
     dest.name = source.name;
}


 