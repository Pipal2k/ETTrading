//+------------------------------------------------------------------+
//|                                                   ETradingEA.mq4 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict


#include <ETrading/SignalSystem/ETSignalSystem.mqh>

#include <ETrading/PositionSystem/ETPositionSystem.mqh>
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
  
  int ETDPOption = ( PIVOT );
  int ETSSoption = ( DRAW_SR_ROWS ) ;
 
  //Define ActionPattern
  ActionPattern actionPatterns[4];
  
  actionPatterns[0].timeframe=PERIOD_M30;
  actionPatterns[0].name="TEST PATTERN";
  actionPatterns[0].Expression = "[SIG_BARBULLISH] WHERE RSI > 80";
  actionPatterns[0].status=Enabled;
  actionPatterns[0].position.pos= Sell;
  actionPatterns[0].position.posOptions = SingleTarget;
  actionPatterns[0].position.posMethod=ATR;
  
  
  actionPatterns[1].timeframe=PERIOD_D1;
  actionPatterns[1].position.pos= Buy;
  actionPatterns[1].name="TEST PATTERN2";
  actionPatterns[1].position.posMethod=SRZONES;
  actionPatterns[1].position.posOptions = MultiTargets;
  actionPatterns[1].status=Enabled;
 //actionPatterns[1].posOptions = SingleTarget;
  
  actionPatterns[2].position.pos= Sell;
  actionPatterns[2].name="TEST PATTERN";
  actionPatterns[2].position.posMethod=SRZONES;
  actionPatterns[2].position.posOptions = MultiTargets;
  actionPatterns[2].status=Disabled;
  
   actionPatterns[3].position.pos= Buy;
  actionPatterns[3].name="TEST PATTERN";
  actionPatterns[3].position.posMethod=ATR;
  actionPatterns[3].position.posOptions = SingleTarget;
  actionPatterns[3].status=Disabled;
  
 // ArrayResize(actionPatterns[0].signals,1,0);
 // actionPatterns[0].signals[0] = SIG_SR_BREAKTHROUGHBEARISH;
  
  //actionPatterns[0].Expression= "[{(1)SIG_BARBEARISH | (*)SIG_SR_BREAKTHROUGHBEARISH} & { SIG_SR_BREAKTHROUGHBULLISH & SIG_BARBEARISH}] [SIG_SR_BREAKTHROUGHBEARISH]";
  
   //actionPatterns[0].Expression= "[ { (*)SIG_BARBULLISH | SIG_SR_BREAKTHROUGHBEARISH | SIG_BARBEARISH } | (^)SIG_BARBEARISH | SIG_BARBULLISH ]";
   //actionPatterns[0].Expression= "[{SIG_BARBULLISH}][{SIG_BARBEARISH}][{SIG_BARBEARISH}]";
   
   //TestCase 1 --> true
   //actionPatterns[0].Expression= "[{SIG_BARBULLISH}][{SIG_BARBULLISH & SIG_SR_BREAKTHROUGHBULLISH}][{SIG_BARBEARISH}]";
   
   //actionPatterns[0].Expression = "[{SIG_BARBULLISH}][{SIG_SR_TOUCHBULLISH}][SIG_BARBEARISH]";
   // actionPatterns[0].Expression = "[(^)SIG_ANY][(1-5)SIG_SR_BREAKTHROUGHBULLISH & SIG_ANY]";
   
   //SIG_SR_TOUCHLOWERBOUNDERY //Ccheck 8.6 falsches Ergebnis
   
   
                                 
   //actionPatterns[0].Expression = "[SIG_SR_BREAKTHROUGHBEARISH] [(^)SIG_ANY] [SIG_SR_TOUCHLOWERBOUNDERY][(^)SIG_ANY][SIG_BEARISHCANDLESTICK] "
   //                              +"WHERE [3].SIG_SR_TOUCHLOWERBOUNDERY.LOWBORDER = [1].SIG_SR_BREAKTHROUGHBEARISH.LOWBORDER && [1].SIG_SR_BREAKTHROUGHBEARISH.TYPE = RESISTANCE";
                                 
   actionPatterns[1].Expression = "[SIG_SR_BREAKTHROUGHBULLISH] [(^)SIG_ANY] [SIG_SR_TOUCHHIGHERBOUNDERY] [(^)SIG_ANY] [SIG_BULLISHCANDLESTICK] "
                                 +"WHERE [3].SIG_SR_TOUCHHIGHERBOUNDERY.HIGHBORDER = [1].SIG_SR_BREAKTHROUGHBULLISH.HIGHBORDER  && [1].SIG_SR_BREAKTHROUGHBULLISH.TYPE = SUPPORT && RSI < 30";   
    
    actionPatterns[2].Expression = "[SIG_SR_BREAKTHROUGHBEARISH][(^)SIG_ANY][SIG_SR_BREAKTHROUGHBEARISH][(^)SIG_ANY][SIG_SR_BREAKTHROUGHBEARISH] "
                                 +"WHERE [1].LOWBORDER > [3].LOWBORDER && [5].LOWBORDER < [3].LOWBORDER && [1].SIG_SR_BREAKTHROUGHBEARISH.TYPE = RESISTANCE "
                                 +"&& [3].SIG_SR_BREAKTHROUGHBEARISH.LOWBORDER < [1].SIG_SR_BREAKTHROUGHBEARISH.LOWBORDER && [5].SIG_SR_BREAKTHROUGHBEARISH.LOWBORDER < [3].SIG_SR_BREAKTHROUGHBEARISH.LOWBORDER"
                                 +"&& RSI > 35";  
                                 
    //actionPatterns[3].Expression = "[SIG_SR_BREAKTHROUGHBULLISH] WHERE ATR < 30"; 
    
    actionPatterns[3].Expression = "[SIG_BARBULLISH]";                                                                                            
   
    //actionPatterns[0].Expression = "[SIG_SR_BREAKTHROUGHBULLISH] [(^)SIG_ANY] [SIG_SR_BREAKTHROUGHBEARISH][(^)SIG_ANY][SIG_SR_BREAKTHROUGHBULLISH]"
     //                             +"WHERE [3].SIG_SR_BREAKTHROUGHBEARISH.LOWBORDER = [1].SIG_SR_BREAKTHROUGHBULLISH.LOWBORDER && [3].SIG_SR_BREAKTHROUGHBEARISH.LOWBORDER = [5].SIG_SR_BREAKTHROUGHBULLISH.LOWBORDER";                                  
                                  
   //actionPatterns[0].Expression = "[SIG_CS_BEARISHENGULFING]";
                               // +  "WHERE RSI > 10 ";
                                  //&& RSI < 30.5";
   //actionPatterns[0].Expression = "[SIG_SR_BREAKTHROUGHBEARISH][(^) SIG_ANY][SIG_SR_TOUCHLOWERBOUNDERY] WHERE RSI < 30.5";
   //TestCase 2 --> false
   //actionPatterns[0].Expression= "[{SIG_BARBULLISH}][{SIG_BARBEARISH}][{SIG_BARBEARISH}][{SIG_BARBULLISH}]";
   
   //actionPatterns[0].Expression= "[{SIG_BARBEARISH}][{SIG_BARBULLISH}][{SIG_BARBEARISH}][{SIG_BARBEARISH}]";
  //actionPatterns[0].signals[1] 
  
  initETSignalSystem(actionPatterns,ETDPOption,ETSSoption);
  
  
  
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
     // DoSignalProcessing(15);
     ActionPattern matchingPattern[];
     getMatchingActionPatterns(matchingPattern,false);
      
      //ActionPattern tmpActionPattern;
     //copyActionPattern(tmpActionPattern,matchingPattern[0]);
     //Print(tmpActionPattern.posMethod);
     
     ETSignal sig;
     //copyETSignal(matchingPattern[0].matchingSignal[0],sig);
     //processPositioning(matchingPattern);
     
     // Print(sig.time+" "+sig.metaInfo.buffer.RSIBuffer[0]);
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
   ActionPattern matchingPattern[];
   processPositioning(matchingPattern);
   if(Volume[0]>1)
        return;
    //ActionPattern matchingPatterns[];
  
    if(DoSignalProcessing(15))
    {
      getMatchingActionPatterns(matchingPattern,true);
      processPositioning(matchingPattern);
      
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

