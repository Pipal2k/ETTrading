
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

#include <ETrading/ETBarBuffer.mqh>

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
#define SIG_CS_BEARISHENGULFING 0x800
#define SIG_CS_BULLISHENGULFING 0x1000
#define SIG_CS_THREESOLDIERS 0x2000
#define SIG_CS_THREEDARKCLOUD 0x4000
#define SIG_CS_HAMMER 0x8000
#define SIG_CS_INVERTEDHAMMER 0x10000
#define SIG_SHORTTREND 0x20000
#define SIG_LONGTREND 0x40000
#define SIG_TREND_ADXI_CONFIRMED 0x80000
#define SIG_TREND_ADXI_LONG 0x100000
#define SIG_TREND_ADXI_SHORT 0x200000
#define SIG_TREND_MA200_LONG 0x400000
#define SIG_TREND_MA200_SHORT 0x800000
//#define SIG_TREND_ADXI_SHORT 0x200000

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
   /*TREND_ADXI = 0x08,
   TREND_ADXI_M1 = 0x10,
   TREND_ADXI_M5 = 0x20,
   TREND_ADXI_M15 = 0x40,
   TREND_ADXI_M30 = 0x80,
   TREND_ADXI_H1 = 0x100,
   TREND_ADXI_H4 = 0x200,
   TREND_ADXI_D1 = 0x400,
   TREND_ADXI_W1 = 0x800,
   TREND_ADXI_MN = 0x1000,
   TREND_ADXI_CONFIRMED = 0x2000*/
};

enum SignalSys_Options
{
   //PIVOT = 0x01,
   //FPIVOT = 0x02,
   //KEYLEVELS =0x04,
   DRAW_SR_ROWS= 0x01,
   DRAW_SR_MID_PIVOTS = 0x02,
   DEBUG_SIGNALS = 0x04,
   USE_MIDPIVOTS =0x08,
   //TREND_ADXI = 0x10
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







enum PivotKind
{
Standard,
Fibo
};

enum RowType
{
   DPivot =0x01,
   WPivot = 0x02,
   MR1 = 0x04,
   R1= 0x08,
   MR2= 0x10,
   R2=0x20,
   MR3=0x40,
   R3=0x80,
   MS1=0x100,
   S1=0x200,
   MS2=0x400,
   S2=0x800,
   MS3=0x1000,
   S3=0x2000,
   RESISTANCE = 0x4000,
   SUPPORT= 0x8000,
   MIDPIVOT=0x10000
};



struct SR_Row
{
  int type; //RowTypeFlags
  double Prize;
  
  
};



struct SR_Zone
{
 double HighBorder;
 double LowBorder;
 
 int SRType;
};

struct ProvidedData {
   SR_Zone zones[];
  // int TrendFlags;
   
};

struct MetaInfo
{
  //SR_Zone SR_BREAKS[];
  //SR_Zone SR_TOUCHED[];
  int barIndex;
  SR_Zone iSIG_SR_TOUCHLOWERBOUNDERY[];
  SR_Zone iSIG_SR_TOUCHHIGHERBOUNDERY[];
  SR_Zone iSIG_SR_BREAKTHROUGHBEARISH[];
  SR_Zone iSIG_SR_BREAKTHROUGHBULLISH[];
  
  double RSI;
  double STOCH;
  double CCI;
  
  double ADXI_MAIN;
  double ADXI_MINUS;
  double ADXI_PLUS;
  
  //double open;
  Buffers buffer;
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

enum PositionOption
{
   SingleTarget = 0x01,
   MultiTargets = 0x02,
   IncludeMidpivots = 0x04
};

enum PositionMethod
{
  ATR,
  SRZONES
};

enum PatternStatus
{
  Enabled,
  Disabled
};

enum ExecutionType
{
   Single,
   NotSingle
};

struct Positioning 
{
    Position pos;
    PositionMethod posMethod;
    int posOptions;
};

struct KorrPattern
{
 string name;
 string PatternNames[];
 Positioning position;
 PatternStatus status;
};


void copyKorrPatternArray(KorrPattern &dest[], KorrPattern &src[])
{
     for(int i = 0; i < ArraySize(src); i++)
     {
          ArrayResize(dest,ArraySize(dest)+1,0);
          copyKorrPattern(dest[ArraySize(dest)-1],src[i]);
     }
}

void copyKorrPattern(KorrPattern &dest, KorrPattern &src)
{
   for(int i = 0; i < ArraySize(src.PatternNames); i++)
   {
       ArrayResize(dest.PatternNames,ArraySize(dest.PatternNames)+1,0);
       dest.PatternNames[ArraySize(dest.PatternNames)-1]=src.PatternNames[i];
   }
   
   copyPositioning(dest.position,src.position);
   dest.status= src.status;
   dest.name = src.name;
}

void copyPositioning(Positioning &dest,Positioning &src)
{
     dest.pos = src.pos;
     dest.posMethod = src.posMethod;
     dest.posOptions = src.posOptions;
}


struct ActionPattern
{
  string name;
  string Symbol;
  int timeframe;
  
  string Expression;
  datetime matchingTimes[];
  Positioning position;
  /*Position pos;
  PositionMethod posMethod;
  int posOptions;*/
  
  PatternStatus status;
  ExecutionType execution;
  
  ETSignal matchingSignal[];
  ProvidedData prepData;
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

struct Operant
{
  double opDouble;
  int opInt;
  bool isIntFlag;
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
   HIGHBORDER,
   TYPE
};


enum WhereOperantFunc
{
   iRSI,
   iSTOCH,
   iCCI,
   iR1,
   iR2,
   iR3,
   iRESISTANCE,
   iDPivot,
   iWPivot,
   iS1,
   iS2,
   iS3,
   iSUPPORT,
   iSIG_SR_BREAKTHROUGHBEARISH,
   iSIG_SR_BREAKTHROUGHBULLISH,
   iSIG_SR_TOUCHHIGHERBOUNDERY,
   iSIG_SR_TOUCHLOWERBOUNDERY,
   iSIG_BEARISHCANDLESTICK,
   iSIG_BULLISHCADLESTICK,
   iSIG_CS_BEARSIHENGULFING,
   iSR_R1,
   iSIG_TREND_ADX_MAIN,
   iSIG_TREND_ADX_MINUS,
   iSIG_TREND_ADX_PLUS
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
    dst.barIndex = src.barIndex;
    dst.CCI = src.CCI;
    dst.RSI= src.RSI;
    dst.STOCH =src.STOCH;
    
    dst.ADXI_MAIN = src.ADXI_MAIN;
    dst.ADXI_MINUS = src.ADXI_MINUS;
    dst.ADXI_PLUS = src.ADXI_PLUS;
    //dst.open = src.open;
    
    CopyBuffer(dst.buffer,0,ArraySize(src.buffer.OpenBuffer),src.buffer,false);
    //copyProvidedData(dst.prepData,src.prepData);
}

void copySRZones(SR_Zone &src, SR_Zone &dst)
{
  dst.HighBorder=src.HighBorder;
  dst.LowBorder=src.LowBorder;
  dst.SRType = src.SRType;
  //ArrayCopy(dst.S,src.SR_BREAKS,0,0,WHOLE_ARRAY);
}

void copyETSignal(ETSignal &src[], ETSignal &dst[])
{
   ArrayFree(dst);
   for(int i = 0; i < ArraySize(src); i++)
   {
       ArrayResize(dst,ArraySize(dst)+1,0);
       copyETSignal(src[i],dst[ArraySize(dst)-1]);
   }

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
     dest.Symbol =source.Symbol;
     dest.timeframe = source.timeframe;
     
     
     dest.Expression = source.Expression;
     dest.name = source.name;
    
     /*dest.pos= source.pos;
     dest.posMethod= source.posMethod;
     dest.posOptions=source.posOptions;*/
     copyPositioning(dest.position,source.position);
     //dest.position.pos= source.position.pos;
     //dest.position.posMethod= source.position.posMethod;
     //dest.position.posOptions=source.position.posOptions;
     
     dest.execution = source.execution;
     
     dest.status = source.status;
     
     copyETSignal(source.matchingSignal,dest.matchingSignal);
     copyProvidedData(dest.prepData,source.prepData);
     
     for(int x=0; x < ArraySize(source.matchingTimes); x++)
     {
        ArrayResize(dest.matchingTimes,ArraySize(dest.matchingTimes)+1,0);
        dest.matchingTimes[ArraySize(dest.matchingTimes)-1]= source.matchingTimes[x];
     }
     
}

void copyProvidedData(ProvidedData &destData, ProvidedData &srcData)
{
   ArrayCopy(destData.zones,srcData.zones,0,0,WHOLE_ARRAY);
}

struct ETPosition
{
  double bid;
  double ask;
  
  double stopLoss;
  double stopLossUnits;
  
  double takeProfit;
  
  double targets[];
  int targetsHit;
  
  double size;
  double openSize;
  
  Position pos;
  
  int orderid;
  
  int posOptions;
};

struct DataByTimeFrame
{
  int timeframe;
  Buffers buffer;
  ProvidedData provdata;
  
  ETSignal CurrentSignals[];
  ETSignal lastSignal;
}; 