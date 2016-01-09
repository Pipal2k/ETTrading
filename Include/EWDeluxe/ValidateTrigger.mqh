//+------------------------------------------------------------------+
//|                                              ValidateTrigger.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include <EWDeluxe\Trigger.mqh>
#include <EWDeluxe\initBuffers.mqh>
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



int i=0;


bool validateTrigger(Buffers &buffers,TradeTrigger &trigger,ValidationCriteria &criteria,Configuration &config,bool isKalibrating)
{

  // Print(buffers.TimeBuffer[1]);
   double RSIRangePossibilityBuy=getRSIRange(Buy,buffers.RSIBuffer[1]);
   //RSIBorderPossibilityBuy=getRSIPossibility2(Buy);
   double STOCHPossibilityBuy=getSTOCHPossibility(Buy,buffers.STOCHBuffer[1]);
   //STOCHBorderPossibilityBuy=getSTOCHPossibility2(Buy);
   //CROSSINGPossibilityBuy=getCrossingPossibility(Buy);
   double TRENDPossibilityBuy=getTrendPossibility(Buy,buffers.CurrentMABuffer,buffers.OneAboveMABuffer,buffers.TwoAboveBuffer,buffers.CloseBuffer);
   //SMALLTRENDPossibilityBuy=getSmallTrendPossibility(Buy);
   double BANDPossibilityBuy=getBollingerBandBossibility(Buy,buffers.LowBuffer,buffers.HighBuffer,buffers.LowBandBuffer[1],buffers.HighBandBuffer[1]);
   //ONMA200LineBuy=getONMA200TrendPossibility(Buy);
   //CandleSTickPatternBuy=CandleSTickPattern(Buy);

  //Print(buffers.TimeBuffer[1]+" "+buffers.CloseBuffer[1]);
   double RSIRangeGewichtetBuy=RSIRangePossibilityBuy * criteria.GewichtungRSIRange;
   //double RSIBorderGewichtetBuy=RSIBorderPossibilityBuy*GewichtungRSIBorder;
   double STOCHGewichtetBuy=STOCHPossibilityBuy*criteria.GewichtungStoch;
   //double STOCHBorderGewichtetBuy=STOCHBorderPossibilityBuy*GewichtungStochBorder;
   //double CROSSINGGewichtetBuy=CROSSINGPossibilityBuy*GewichtungCrossing;
   double TRENDGewichtetBuy=TRENDPossibilityBuy*criteria.GewichtungMA200Trend;
   //double SMALLTRENDGewichtetBuy=SMALLTRENDPossibilityBuy*GewichtungSmallTrend;
   double BANDGewichtetBuy=BANDPossibilityBuy*criteria.GewichtungBand;
   //double ONMA200LineGewichtetBuy=ONMA200LineBuy*GewichtungONMA200Line;
   //double CandleSTickPatternGewichtetBuy=CandleSTickPatternBuy*GewichtungCandleStickPattern;

    double GesamtBuyGewichtung=RSIRangeGewichtetBuy+BANDGewichtetBuy+TRENDGewichtetBuy+STOCHGewichtetBuy;
   //double GesamtBuyGewichtung=CandleSTickPatternGewichtetBuy+RSIGewichtetBuy+RSIBorderGewichtetBuy+STOCHGewichtetBuy+STOCHBorderGewichtetBuy+CROSSINGGewichtetBuy+TRENDGewichtetBuy+SMALLTRENDGewichtetBuy+BANDGewichtetBuy+ONMA200LineGewichtetBuy;
//Print("RSIPossibilityBuy: ", RSIPossibilityBuy, " STOCHPossibilityBuy: ", STOCHPossibilityBuy, " GesamBUYPossibility. ", GesamtBuyGewichtung);

//Keine by poition also ausrechen wie wahrscheinlich ein sell ist
   double RSIRangePossibilitySell=getRSIRange(Sell,buffers.RSIBuffer[1]);
  // RSIBorderPossibilitySell=getRSIPossibility2(Sell);
   double STOCHPossibilitySell=getSTOCHPossibility(Sell,buffers.STOCHBuffer[1]);
   //double STOCHBorderPossibilitySell=getSTOCHPossibility2(Sell);
  // CROSSINGPossibilitySell=getCrossingPossibility(Sell);
     double TRENDPossibilitySell=getTrendPossibility(Sell,buffers.CurrentMABuffer,buffers.OneAboveMABuffer,buffers.TwoAboveBuffer,buffers.CloseBuffer);
  // SMALLTRENDPossibilitySell=getSmallTrendPossibility(Sell);
    double BANDPossibilitySell=getBollingerBandBossibility(Sell,buffers.LowBuffer,buffers.HighBuffer,buffers.LowBandBuffer[1],buffers.HighBandBuffer[1]);
   //ONMA200LineSell=getONMA200TrendPossibility(Sell);
   //CandleSTickPatternSell=CandleSTickPattern(Sell);
//  Print("BDANSell: "+ BANDPossibilitySell);

   double RSIRangeGewichtetSell=RSIRangePossibilitySell*criteria.GewichtungRSIRange;
   //double RSIBorderGewichtetSell=RSIBorderPossibilitySell*GewichtungRSIBorder;
   double STOCHGewichtetSell=STOCHPossibilitySell*criteria.GewichtungStoch;
   //double STOCHBorderGewichtetSell=STOCHBorderPossibilitySell*GewichtungStochBorder;
   //double CROSSINGGewichtetSell=CROSSINGPossibilitySell*GewichtungCrossing;
   double TRENDGewichtetSell=TRENDPossibilitySell*criteria.GewichtungMA200Trend;
   //double SMALLTRENDGewichtetSell=SMALLTRENDPossibilitySell*GewichtungSmallTrend;
    double BANDGewichtetSell=BANDPossibilitySell*criteria.GewichtungBand;
   //double ONMA200LineGewichtetSell=ONMA200LineSell*GewichtungONMA200Line;
   //double CandleSTickPatternGewichtetSell=CandleSTickPatternSell*GewichtungCandleStickPattern;

   //Print("CandlestickGewichtet: ",CandleSTickPatternGewichtetSell);
   double GesamtSellGewichtung=RSIRangeGewichtetSell+BANDGewichtetSell+TRENDGewichtetSell+STOCHGewichtetSell;
   //double GesamtSellGewichtung=CandleSTickPatternGewichtetSell+RSIGewichtetSell+RSIBorderGewichtetSell+STOCHGewichtetSell+CROSSINGGewichtetSell+TRENDGewichtetSell+STOCHBorderGewichtetSell+SMALLTRENDGewichtetSell+BANDGewichtetSell+ONMA200LineGewichtetSell;
   
   if(!isKalibrating)
   DrawPercents(GesamtBuyGewichtung, GesamtSellGewichtung,buffers.TimeBuffer);
   
  // Print(DoubleToString(GesamtBuyGewichtung));
  
   double stdvCurrent=iStdDev(NULL,0,20,0,MODE_SMA,PRICE_CLOSE,iBarShift(Symbol(),Period(),buffers.TimeBuffer[0]));
   
   if(trigger.pos == Buy && GesamtBuyGewichtung >= criteria.ValidSchwelle && triggerInTrend(trigger.time,config,Buy) && stdvCurrent < buffers.avgStdv )
   {
      if(!isKalibrating)
      drawValidSign(buffers.TimeBuffer);
      
      return true;
   }
   else if(trigger.pos == Sell && GesamtSellGewichtung >= criteria.ValidSchwelle && triggerInTrend(trigger.time,config,Sell) && stdvCurrent < buffers.avgStdv )
   { 
      if(!isKalibrating)
      drawValidSign(buffers.TimeBuffer);
      
      return true;   
   }
      
   return false;
}

void drawValidSign(datetime &timeBuffer[])
{
   ObjectCreate("Valid"+timeBuffer[1],OBJ_TEXT,WindowFind("DeluxeEWPercentage"),timeBuffer[1],50); //Low[1]- (20*Point)
   ObjectSetText("Valid"+timeBuffer[1],"--",5,"Verdana",Green);
}

void DrawPercents(double GesamtBuyGewichtung, double GesamtSellGewichtung,datetime &timeBuffer[])
  {
   ObjectCreate("ObjName",OBJ_LABEL,WindowFind("DeluxeEWPercentage"),0,0);
   ObjectSetText("ObjName","Test",7,"Verdana",Red);
   ObjectSet("ObjName",OBJPROP_CORNER,0);
   ObjectSet("ObjName",OBJPROP_XDISTANCE,20);
   ObjectSet("ObjName",OBJPROP_YDISTANCE,20);

   i++;
   ObjectCreate("Perc"+i,OBJ_TEXT,WindowFind("DeluxeEWPercentage"),timeBuffer[1],90); //Low[1]- (20*Point)
   ObjectSetText("Perc"+i,DoubleToStr(round(GesamtBuyGewichtung),0),5,"Verdana",Green);
   // ObjectSetInteger(WindowFind("DeluxeEWPercentage"),"Perc"+i,OBJPROP_ANCHOR,ANCHOR_TOP);
   //ObjectSetInteger("Perc"+i,,OBJPROP_ANCHOR,anchor);
   //ObjectSet("Perc"+i,OBJPROP_YDISTANCE,20);
//ObjectSet("ObjName", OBJPROP_YDISTANCE, i);

   i++;
   ObjectCreate("Perc"+i,OBJ_TEXT,WindowFind("DeluxeEWPercentage"),timeBuffer[1],85);
   ObjectSetText("Perc"+i,DoubleToStr(round(GesamtSellGewichtung),0),5,"Verdana",Red);
   //ObjectSetInteger(WindowFind("DeluxeEWPercentage"),"Perc"+i,OBJPROP_ANCHOR,ANCHOR_TOP);

//ChartRedraw(ChartID());
  }

//double getRSIPossibility(Position pos)
 // {
   
   // double crossPossibility = 0.4;
  //  double rangePossibility= 0.2;
   // double RSIBorderPossibility =0.4;
   
   // double crossingFactor = CrossingBorder(rsi2,rsi1,70.0,30.0,pos); 
   // double rangeFactor = getRSIRange(pos);
  //  double getRSIBorder = getRSIPossibility2(pos);
   
   // return ((crossingFactor * crossPossibility) + (rangeFactor * rangePossibility) + (getRSIBorder*RSIBorderPossibility));

  // }
bool triggerInTrend(datetime currentTime,Configuration &config,Position pos) {

 if(!config.doOnlyTradesOnTrend)
   return true;
 else
 {
    int shift = iBarShift(Symbol(),Period(),currentTime);
   int cADXDiPlus = iADX(Symbol(),Period(),14,PRICE_CLOSE,MODE_PLUSDI,shift);
   int cADXDiMinus= iADX(Symbol(),Period(),14,PRICE_CLOSE,MODE_MINUSDI,shift);
 
   int shiftOneAbove = iBarShift(Symbol(),getNextTimeFrame(Period()),currentTime)+1;
   int cADXDiPlusOneAbove = iADX(Symbol(),getNextTimeFrame(Period()),14,PRICE_CLOSE,MODE_PLUSDI,shiftOneAbove);
   int cADXDiMinusOneAbove= iADX(Symbol(),getNextTimeFrame(Period()),14,PRICE_CLOSE,MODE_MINUSDI,shiftOneAbove);
  
  // Print("Time "+currentTime,"ADXPlus ",cADXDiPlus, "ADXMinus ", cADXDiMinus);
  // Print("ADXPlus OneABove "+currentTime,cADXDiPlusOneAbove, "ADXMinus OneAbove ", cADXDiMinusOneAbove, "ShiftOneAbove ",shiftOneAbove);
  
   if(cADXDiPlusOneAbove > cADXDiMinusOneAbove && cADXDiPlus > cADXDiMinus && pos == Buy)
      return true;
    if(cADXDiPlusOneAbove < cADXDiMinusOneAbove && cADXDiPlus < cADXDiMinus && pos == Sell)
       return true;  
   
   return false;
 }  
   
}

double getRSIRange(Position pos,double rsi)
{
  double x=MathAbs(50.0-rsi)*5.0;

   if(rsi>=50.0)
     {
       if(pos==Buy)
        {
         return -x;
        }
      if(pos==Sell)
        {
         return x;
        }
     }
   else if(rsi<50.0)
     {
      if(pos==Buy)
        {
         return x;
        }
      if(pos==Sell)
        {
         return -x;
        }

     }

   return 0.0; 
}

double getBollingerBandBossibility(Position pos,double &LowBuffer[], double &HighBuffer[],double bandL, double bandH)
  {
//Print("BandL: "+ bandL, " BandH: "+bandH);

   if(LowBuffer[1]<=bandL)
     {
      if(pos==Buy)
        {
         return 100.0;
        }
      else
        {
         return -100.0;
        }
     }

   if(HighBuffer[1]>=bandH)
     {
      if(pos==Sell)
        {
         return 100.0;
        }
      else
         return -100.0;
     }

   return 0.00;

  }
  
  double getTrendPossibility(Position pos,double &CurrentMABuffer[],double &OneAboveMABuffer[],double &TwoAboveBuffer[],double &CloseBuffer[])
  {

   double GewichtungCurrentTimeframe=0.7;
   double  GewichtungOneTimeframeAbove =0.25;
   double  GewichtungTwoTimeframeAbove = 0.05;

   double CurrentTimeFrame=   getTimeFrameTRENDPossibility(pos,CurrentMABuffer,CloseBuffer)*  GewichtungCurrentTimeframe;
   double OneTimeframeAbove = getTimeFrameTRENDPossibility(pos,OneAboveMABuffer,CloseBuffer) * GewichtungOneTimeframeAbove;
   double TwoTimeframeAbove = getTimeFrameTRENDPossibility(pos,TwoAboveBuffer,CloseBuffer) * GewichtungTwoTimeframeAbove;

   double y=CurrentTimeFrame+OneTimeframeAbove+TwoTimeframeAbove;

   return CurrentTimeFrame+OneTimeframeAbove+TwoTimeframeAbove;

  }
  
  double getTimeFrameTRENDPossibility(Position pos,double &MA200Buffer[],double &CloseBuffer[])
  {
   
   if(pos==Buy)
     {
      if(MA200Buffer[1]<CloseBuffer[1])
        {
         return 100.0;
        }
      else
        {
         return 0.0;
        }
     }
   else if(pos==Sell)
     {
      if(MA200Buffer[1]>CloseBuffer[1])
        {
         return 100.0;
        }
      else
        {
         return 0.0;
        }
     }

   return 0.0;

  }
  
  double getSTOCHPossibility(Position pos,double stoch1)
  {

   double x=MathAbs(50-stoch1)*(100.0/30.0);

   if(stoch1>=50)
     {
      if(pos==Buy)
         return -x;
      else
         return x;
     }
   else if(stoch1<50)
     {
      if(pos==Sell)
         return -x;
      else
         return x;
     }
   return 0;
  }