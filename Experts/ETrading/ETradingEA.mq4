//+------------------------------------------------------------------+
//|                                                   ETradingEA.mq4 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict


#include <ETrading/ETSignalSystem.mqh>
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
 
  string charStr = "30 ";
    uchar chars[];
  StringToCharArray(charStr,chars,0,WHOLE_ARRAY,CP_ACP);
  //uchar chars[3];
  //chars[0] = '3';
  //chars[1]= '0';
  
  string str = CharArrayToString(chars,0,WHOLE_ARRAY,CP_ACP);
  //Option for Trading Signal Subsystem
  //int ETSSoption = (PIVOT | FPIVOT | DRAW_SR_ROWS | DRAW_SR_MID_PIVOTS | DEBUG_SIGNALS) ;
  
  int ETSSoption = (PIVOT | DRAW_SR_ROWS   | DRAW_SR_MID_PIVOTS | DEBUG_SIGNALS ) ;
 
  //Define ActionPattern
  ActionPattern actionPatterns[1];
  actionPatterns[0].pos= Sell;
  actionPatterns[0].name="TEST PATTERN";
 // ArrayResize(actionPatterns[0].signals,1,0);
 // actionPatterns[0].signals[0] = SIG_SR_BREAKTHROUGHBEARISH;
  
  //actionPatterns[0].Expression= "[{(1)SIG_BARBEARISH | (*)SIG_SR_BREAKTHROUGHBEARISH} & { SIG_SR_BREAKTHROUGHBULLISH & SIG_BARBEARISH}] [SIG_SR_BREAKTHROUGHBEARISH]";
  
   //actionPatterns[0].Expression= "[ { (*)SIG_BARBULLISH | SIG_SR_BREAKTHROUGHBEARISH | SIG_BARBEARISH } | (^)SIG_BARBEARISH | SIG_BARBULLISH ]";
   //actionPatterns[0].Expression= "[{SIG_BARBULLISH}][{SIG_BARBEARISH}][{SIG_BARBEARISH}]";
   
   //TestCase 1 --> true
   //actionPatterns[0].Expression= "[{SIG_BARBULLISH}][{SIG_BARBULLISH & SIG_SR_BREAKTHROUGHBULLISH}][{SIG_BARBEARISH}]";
   
   //actionPatterns[0].Expression = "[{SIG_BARBULLISH}][{SIG_SR_TOUCHBULLISH}][SIG_BARBEARISH]";
   // actionPatterns[0].Expression = "[(^)SIG_ANY][(1-5)SIG_SR_BREAKTHROUGHBULLISH & SIG_ANY]";
   
   //SIG_SR_TOUCHLOWERBOUNDERY
   actionPatterns[0].Expression = "[SIG_SR_BREAKTHROUGHBEARISH] [(^)SIG_ANY] [SIG_SR_TOUCHLOWERBOUNDERY] [SIG_BARBEARISH]"
                                  +"WHERE [3].SIG_SR_TOUCHLOWERBOUNDERY.LOWBORDER = [1].SIG_SR_BREAKTHROUGHBEARISH.LOWBORDER"; 
   
    actionPatterns[0].Expression = "[SIG_SR_BREAKTHROUGHBULLISH] [(^)SIG_ANY] [SIG_SR_BREAKTHROUGHBEARISH][(^)SIG_ANY][SIG_SR_BREAKTHROUGHBULLISH]"
                                  +"WHERE [3].SIG_SR_BREAKTHROUGHBEARISH.LOWBORDER = [1].SIG_SR_BREAKTHROUGHBULLISH.LOWBORDER && [3].SIG_SR_BREAKTHROUGHBEARISH.LOWBORDER = [5].SIG_SR_BREAKTHROUGHBULLISH.LOWBORDER";                                  
                                  
   actionPatterns[0].Expression = "[SIG_SR_BREAKTHROUGHBULLISH]"
                                  +"WHERE RSI < 30 ";
                                  //&& RSI < 30.5";
   //actionPatterns[0].Expression = "[SIG_SR_BREAKTHROUGHBEARISH][(^) SIG_ANY][SIG_SR_TOUCHLOWERBOUNDERY] WHERE RSI < 30.5";
   //TestCase 2 --> false
   //actionPatterns[0].Expression= "[{SIG_BARBULLISH}][{SIG_BARBEARISH}][{SIG_BARBEARISH}][{SIG_BARBULLISH}]";
   
   //actionPatterns[0].Expression= "[{SIG_BARBEARISH}][{SIG_BARBULLISH}][{SIG_BARBEARISH}][{SIG_BARBEARISH}]";
  //actionPatterns[0].signals[1] 
  
  initETSignalSystem(ETSSoption,actionPatterns);
  
  int testflag;
   testflag |= SIG_BARBEARISH;
   testflag |= SIG_BARBULLISH;
  
  //if(testflag & SIG_BARBEARISH)
 // {
  //    Print("Test erfolgreich");
 // }
  
  int vergleichsflag;
  
  vergleichsflag = (SIG_BARBEARISH | SIG_BEARISHCANDLESTICK);
  if(testflag & vergleichsflag)
  {
    //  Print("Test erfolgreich");
  }
  
 // Print("Error: "+GetLastError());
  
  //DoSignalProcessing(15);
   //  test();
//---

   int error = GetLastError();
   
   
    
   if(error != 0)
      return(INIT_FAILED);
   else
   {
     ActionPattern matchingPatterns[];
      DoSignalProcessing(2000);
      ActionPattern matchingPattern[];
      getMatchingActionPatterns(matchingPattern,false);
      return(INIT_SUCCEEDED);
    }
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
   
  
   
      
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(Volume[0]>1)
        return;
    //ActionPattern matchingPatterns[];
    ActionPattern matchingPattern[];
    if(DoSignalProcessing(15))
    {
      
     
      getMatchingActionPatterns(matchingPattern,true);
    } 
    
    //Print(ArraySize(matchingPattern));
    //PrintOptions();
 
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=0.0;
//---

//---
   return(ret);
  }
  
  
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{

   
   
   
}
//+------------------------------------------------------------------+
