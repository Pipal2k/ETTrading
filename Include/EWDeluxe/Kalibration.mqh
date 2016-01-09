//+------------------------------------------------------------------+
//|                                                  Kalibration.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict
#include <EWDeluxe\initBuffers.mqh>
#include <EWDeluxe\Enums.mqh>
#include <EWDeluxe\Trigger.mqh>
#include <EWDeluxe\ValidateTrigger.mqh>
#include <EWDeluxe\DoTheMagic.mqh>
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
void startKalibrationMultiCriteria(datetime old_time,datetime young_time,double stdv,ValidationCriteria &criteriaArray[],bool doKalibration,TriggersValidationCriteria &triggerCriterias,bool useTradingTime,Configuration &config)
{
    int oldShift=iBarShift(Symbol(),Period(),old_time);
    int youngShift=iBarShift(Symbol(),Period(),young_time);
    startKalibrationMultiCriteria(oldShift,youngShift,stdv,criteriaArray,doKalibration,triggerCriterias,useTradingTime,config);
}


//FakePosition fPositions[];
 void startKalibrationMultiCriteria(int oldShift,int youngShift,double stdv,ValidationCriteria &criteriaArray[],bool doKalibration,TriggersValidationCriteria &triggerCriterias,bool useTradingTime,Configuration &config)
  {
  
    double stdvAvg=calculateSTDVAvg(youngShift);
    
    ValidationCriteria defaultC;
    defaultC.ValidSchwelle=100;
    defaultC.GewichtungMA200Trend=0.0;
    defaultC.GewichtungBand=0.0;
    defaultC.GewichtungRSIRange=0.0;
    defaultC.GewichtungSmallTrend=0.0;
    defaultC.GewichtungStoch=0.0;
  
    
    TradeTrigger triggers[];
    getTriggers(oldShift,youngShift,triggers,useTradingTime,config,true);
    
    TradeTrigger candleStickBearishEngulfings[];
    TradeTrigger candleStickBullishEngulfings[];
    TradeTrigger candleStickHammers[];
    TradeTrigger candleStickThreeSoldiers[];
    TradeTrigger candleStickDarkCloud[];
    TradeTrigger candleStickInvertedHammer[];
    TradeTrigger ADXTrigger[];
    TradeTrigger STOCHTrigger[];
    
    
     KalibrationResult ADXBestOption[];
     KalibrationResult ADXSecurestOption[]; 
     if(config.TriggerADX)
     { 
      getTriggersFromType(triggers,ADX,ADXTrigger);
      checkCriterias(oldShift,youngShift,ADXTrigger,criteriaArray,stdvAvg,doKalibration,ADXBestOption,ADXSecurestOption,config);
     }
    
     KalibrationResult STOCHBestOption[];
     KalibrationResult STOCHSecurestOption[];     
     if(config.TriggerStochCrossing)
     {
      getTriggersFromType(triggers,STC,STOCHTrigger);
      checkCriterias(oldShift,youngShift,STOCHTrigger,criteriaArray,stdvAvg,doKalibration,STOCHBestOption,STOCHSecurestOption,config);
     }
    
     KalibrationResult bearishEngulfingBestOption[];
     KalibrationResult bearishEngulfingSecurestOption[];     
     if(config.TriggerBearishEngulfing)
     {
     getTriggersFromType(triggers,CBEE,candleStickBearishEngulfings);
     checkCriterias(oldShift,youngShift,candleStickBearishEngulfings,criteriaArray,stdvAvg,doKalibration,bearishEngulfingBestOption,bearishEngulfingSecurestOption,config);
     }
    
    KalibrationResult bullishEngulfingBestOption[];
    KalibrationResult bullishEngulfingSecurestOption[];     
    if(config.TriggerBullishEngulfing)
    {
    getTriggersFromType(triggers,CBUE,candleStickBullishEngulfings);
    checkCriterias(oldShift,youngShift,candleStickBullishEngulfings,criteriaArray,stdvAvg,doKalibration,bullishEngulfingBestOption,bullishEngulfingSecurestOption,config);
    }

     KalibrationResult HammerBestOption[];
     KalibrationResult HammerSecurestOption[];
     if(config.TriggerHammer)
     {
    getTriggersFromType(triggers,CH,candleStickHammers);
    checkCriterias(oldShift,youngShift,candleStickHammers,criteriaArray,stdvAvg,doKalibration,HammerBestOption,HammerSecurestOption,config);
    }
    
     KalibrationResult threeSoldiersBestOption[];
     KalibrationResult threeSoldiersSecurestOption[]; 
     if(config.TriggerThreeWhiteSoldiers)
     {
      getTriggersFromType(triggers,CTS,candleStickThreeSoldiers);
      checkCriterias(oldShift,youngShift,candleStickThreeSoldiers,criteriaArray,stdvAvg,doKalibration,threeSoldiersBestOption,threeSoldiersSecurestOption,config);
     }
    
    KalibrationResult DarkCloudBestOption[];
    KalibrationResult DarkCouldSecurestOption[]; 
    if(config.TriggerDarkClouds)
    {
    getTriggersFromType(triggers,CDC,candleStickDarkCloud);
    checkCriterias(oldShift,youngShift,candleStickDarkCloud,criteriaArray,stdvAvg,doKalibration,DarkCloudBestOption,DarkCouldSecurestOption,config);
    }
    
    KalibrationResult InvertedHammerBestOption[];
    KalibrationResult InvertedHammerSecurestOption[]; 
    if(config.TriggerInvertedHammer)
    {
    getTriggersFromType(triggers,CIH,candleStickInvertedHammer);
    checkCriterias(oldShift,youngShift,candleStickInvertedHammer,criteriaArray,stdvAvg,doKalibration,InvertedHammerBestOption,InvertedHammerSecurestOption,config);
    }
    
    
    
    ////////////////////////////////i = oldShift;
    if(config.ProfitOption)
    {
     PrintOptionResult("=== Profit Oprion Bearish Engulfing ===",bearishEngulfingBestOption);
      if(ArraySize(bearishEngulfingBestOption) > 0)
         triggerCriterias.CandleStickBearishEngulfingCriteria = bearishEngulfingBestOption[ArraySize(bearishEngulfingBestOption)-1].criteria;
      else
         triggerCriterias.CandleStickBearishEngulfingCriteria = defaultC;   
    }
    else
    {
      PrintOptionResult("=== Securest Oprion Bearish Engulfing ===",bearishEngulfingSecurestOption);
     
     if(ArraySize(bearishEngulfingSecurestOption) > 0 && bearishEngulfingSecurestOption[ArraySize(bearishEngulfingSecurestOption)-1].Lost == 0)
       triggerCriterias.CandleStickBearishEngulfingCriteria = bearishEngulfingSecurestOption[ArraySize(bearishEngulfingSecurestOption)-1].criteria;
     else
      triggerCriterias.CandleStickBearishEngulfingCriteria = defaultC;
     }
     
    ///////////////////////////////////////////////////////////
     if(config.ProfitOption)
     {
      PrintOptionResult("=== Profit Option Bullish Engulfing ===",bullishEngulfingBestOption);
      if(ArraySize(bullishEngulfingBestOption) > 0)
         triggerCriterias.CandleStickBullishEngulfingCriteria = bullishEngulfingBestOption[ArraySize(bullishEngulfingBestOption)-1].criteria;
      else
         triggerCriterias.CandleStickBullishEngulfingCriteria = defaultC;   
     }
     else
     {
     PrintOptionResult("=== Securest Option Bullish Engulfing ===",bullishEngulfingSecurestOption);
     if(ArraySize(bullishEngulfingSecurestOption) > 0 && bullishEngulfingSecurestOption[ArraySize(bullishEngulfingSecurestOption)-1].Lost ==0)
      triggerCriterias.CandleStickBullishEngulfingCriteria = bullishEngulfingSecurestOption[ArraySize(bullishEngulfingSecurestOption)-1].criteria;
     else
      triggerCriterias.CandleStickBullishEngulfingCriteria = defaultC;
    }
    
    //////////////////////////////////////////////////////////
    if(config.ProfitOption)
    {
      PrintOptionResult("=== Profit Option Hammer ===",HammerBestOption);
       if(ArraySize(HammerBestOption) > 0)
         triggerCriterias.CandleStickHammerCriteria = HammerBestOption[ArraySize(HammerBestOption)-1].criteria;
       else
         triggerCriterias.CandleStickHammerCriteria = defaultC;  
    }
    else
    {
      PrintOptionResult("=== Securest Option Hammer ===",HammerSecurestOption);
   // PrintOptionResult("=== Profit Option Hammer ===",HammerBestOption);
    
      if(ArraySize(HammerSecurestOption) > 0 && HammerSecurestOption[ArraySize(HammerSecurestOption)-1].Lost==0)
         triggerCriterias.CandleStickHammerCriteria = HammerSecurestOption[ArraySize(HammerSecurestOption)-1].criteria;
      else
         triggerCriterias.CandleStickHammerCriteria = defaultC;
    }
     
     //////////////////////////////////////////////////////////
     if(config.ProfitOption)
     {
      PrintOptionResult("=== Profit Option Three Soldiers ===",threeSoldiersBestOption);
       if(ArraySize(threeSoldiersBestOption) > 0)
         triggerCriterias.CandleStickThreeSoldiersCriteria = threeSoldiersBestOption[ArraySize(threeSoldiersBestOption)-1].criteria;
       else
        triggerCriterias.CandleStickThreeSoldiersCriteria = defaultC;
     } 
     else
     {
      PrintOptionResult("=== Securest Option Three Soldiers ===",threeSoldiersSecurestOption);
   // PrintOptionResult("=== Profit Option Three Soldiers ===",threeSoldiersBestOption);
    
      if(ArraySize(threeSoldiersSecurestOption) > 0 && threeSoldiersSecurestOption[ArraySize(threeSoldiersSecurestOption)-1].Lost==0)
         triggerCriterias.CandleStickThreeSoldiersCriteria = threeSoldiersSecurestOption[ArraySize(threeSoldiersSecurestOption)-1].criteria;
      else
         triggerCriterias.CandleStickThreeSoldiersCriteria = defaultC;
     }
    
     ////////////////////////////////////////////////////////////
     if(config.ProfitOption)
     {
      PrintOptionResult("=== Profit Option Dark Cloud ===",DarkCloudBestOption);
       if(ArraySize(DarkCloudBestOption) > 0)
         triggerCriterias.CandleStickDarkCloudsCriteria = DarkCloudBestOption[ArraySize(DarkCloudBestOption)-1].criteria;
       else
         triggerCriterias.CandleStickDarkCloudsCriteria = defaultC;
     }
     else
     {
     PrintOptionResult("=== Securest Option Dark Cloud ===",DarkCouldSecurestOption);
    //PrintOptionResult("=== Profit Option Dark Cloud ===",DarkCloudBestOption);
    
      if(ArraySize(DarkCouldSecurestOption) > 0 && DarkCouldSecurestOption[ArraySize(DarkCouldSecurestOption)-1].Lost==0)
         triggerCriterias.CandleStickDarkCloudsCriteria = DarkCouldSecurestOption[ArraySize(DarkCouldSecurestOption)-1].criteria;
      else
         triggerCriterias.CandleStickDarkCloudsCriteria = defaultC;
      }
    
     //////////////////////////////////////////////////////////////
     if(config.ProfitOption)
     {
      PrintOptionResult("=== Profit Option Inverted Hammer===",InvertedHammerBestOption);
      if(ArraySize(InvertedHammerBestOption) > 0)
         triggerCriterias.CandleStickInvertedHammerCriteria = InvertedHammerBestOption[ArraySize(InvertedHammerBestOption)-1].criteria;
      else
           triggerCriterias.CandleStickInvertedHammerCriteria = defaultC;
     }
     else
     {
      PrintOptionResult("=== Securest Option Inverted Hammer ===",InvertedHammerSecurestOption);
    //PrintOptionResult("=== Profit Option Inverted Hammer===",InvertedHammerBestOption);
    
      if(ArraySize(InvertedHammerSecurestOption) > 0 && InvertedHammerSecurestOption[ArraySize(InvertedHammerSecurestOption)-1].Lost==0)
         triggerCriterias.CandleStickInvertedHammerCriteria = InvertedHammerSecurestOption[ArraySize(InvertedHammerSecurestOption)-1].criteria;
      else
         triggerCriterias.CandleStickInvertedHammerCriteria = defaultC;
     }
      
     ////////////////////////////////////////////////////////////// 
     if(config.ProfitOption)
     {
      PrintOptionResult("=== Profit Option ADX ===",ADXBestOption);
      if(ArraySize(ADXBestOption) > 0)
         triggerCriterias.ADXCriteria= ADXBestOption[ArraySize(ADXBestOption)-1].criteria;
       else
        triggerCriterias.ADXCriteria=defaultC;
     }
     else
     {
      PrintOptionResult("=== Securest Option ADX ===",ADXSecurestOption);
    //PrintOptionResult("=== Profit Option ADX ===",ADXBestOption);
    
      if(ArraySize(ADXSecurestOption) > 0 && ADXSecurestOption[ArraySize(ADXSecurestOption)-1].Lost ==0)
         triggerCriterias.ADXCriteria= ADXSecurestOption[ArraySize(ADXSecurestOption)-1].criteria;
      else
         triggerCriterias.ADXCriteria = defaultC;
     }
    
     //////////////////////////////////////////////////////////////
     if(config.ProfitOption)
     {
      PrintOptionResult("=== Profit Option STOCHCrossing ===",STOCHBestOption);
      if(ArraySize(STOCHBestOption) > 0)
         triggerCriterias.STOCHCROSSCriteria= STOCHBestOption[ArraySize(STOCHBestOption)-1].criteria;
      else
         triggerCriterias.STOCHCROSSCriteria=defaultC;   
     }
     else
     {
      PrintOptionResult("=== Securest Option STOCHCrossing ===",STOCHSecurestOption);
    //PrintOptionResult("=== Profit Option STOCHCrossing ===",STOCHBestOption);
    
      if(ArraySize(STOCHSecurestOption) > 0 && STOCHSecurestOption[ArraySize(STOCHSecurestOption)-1].Lost==0)
         triggerCriterias.STOCHCROSSCriteria= STOCHSecurestOption[ArraySize(STOCHSecurestOption)-1].criteria;
      else
         triggerCriterias.STOCHCROSSCriteria = defaultC;
      }
    
   return;
    
    //DrawPositions(fPosition);
   
  }



void getTriggers(int oldShift, int youngShift, TradeTrigger &triggers[], bool useTradingTime, Configuration &config,bool isKalibrating)
{
      //TradeTrigger trigger;
    int i =oldShift;
    int x = 0;
    //TradeTrigger triggers[];
    while(i > youngShift)
    {
      Buffers buffers;
      initBuffers(buffers,i,Period());
      TradeTrigger tmpTrigger[];
      ArrayFree(tmpTrigger);
      bool triggerFound = checkTrigger(buffers,tmpTrigger,useTradingTime,config,isKalibrating);
      
      if(ArraySize(tmpTrigger)>0)
      {
        int size = ArraySize(tmpTrigger);
        ArrayResize(triggers,ArraySize(triggers)+size,0);
        ArrayCopy(triggers,tmpTrigger,ArraySize(triggers)-size,0,WHOLE_ARRAY);
      }
      //if(triggerFound)
      //{
      // ArrayResize(triggers,ArraySize(triggers)+1,0);
      // triggers[x]=tmpTrigger;
      // x++;
      // }
     i--;
    
    }
}

void getTriggersFromType(TradeTrigger &triggersAll[],TriggerType tType,TradeTrigger &resultT[])
{
  for(int i = 0; i < ArraySize(triggersAll);i++)
  {
     if(triggersAll[i].triggerType == tType)
     {
       ArrayResize(resultT,ArraySize(resultT)+1,0);
       resultT[ArraySize(resultT)-1]=triggersAll[i];
     }
  }
   
}

void checkCriterias(int oldShift, int youngShift, TradeTrigger &triggers[],ValidationCriteria &criteriaArray[],double stdAvg, bool doKalibration, KalibrationResult &kalibResultBestOption[],KalibrationResult &KalibResultSecurestAndProfitOption[],Configuration &config)
{
  KalibrationResult kalibResult[];
  
  ArrayFree(kalibResult);
 for(int y = 0; y < ArraySize(criteriaArray);y++)
    {
     
     
     
     TradeTrigger tmpTriggers[];
     ArrayCopy(tmpTriggers,triggers,0,0,WHOLE_ARRAY);
     
    FakePosition fPosition[];
    for(int z = 0; z < ArraySize(tmpTriggers);z++)
    { 
      Buffers tmpBuffers;
      Buffers tmpBuffers2;
     
     //Print(tmpTriggers[z].triggerType);
      initBuffers(tmpBuffers,iBarShift(Symbol(),Period(),tmpTriggers[z].time)-1,Period());        
      bool valid = validateTrigger(tmpBuffers,tmpTriggers[z],criteriaArray[y],config,true);
      
       double atr=iATR(NULL,0,14,iBarShift(Symbol(),Period(),tmpTriggers[z].time)-1);
     // double stdvCurrent=iStdDev(NULL,0,20,0,MODE_SMA,PRICE_CLOSE,iBarShift(Symbol(),Period(),tmpTriggers[z].time)-1);
      
      if(valid) ///&& tmpBuffers.VolumeBuffer[1] > tmpBuffers.avgVolume )
     {
       double stopLoss;
       double stpl = calculateStopLossPrize(tmpTriggers[z].pos,atr,stopLoss);
      
      //double atr2=iATR(NULL,0,14,0);
       //double stopLoss=atr*2.0;
       
       double positionGr = calculatePositionGroesse(stopLoss,1000);

       double takeprofit=(atr/100.0) *100.0;
       
       if(tmpTriggers[z].pos==Buy)
          takeprofit+=(Ask-Bid);
        else if(tmpTriggers[z].pos==Sell)
          takeprofit-=(Ask-Bid);    

       //initBuffers(tmpBuffers2,iBarShift(Symbol(),Period(),triggers[z].time)-1,Period());   
       OpenFakePosition(tmpTriggers[z],positionGr,stopLoss,takeprofit,tmpBuffers.OpenBuffer,tmpBuffers.TimeBuffer,fPosition,true);
     }
      
    
      //i--;
    }
    
    i = oldShift;
    
    while(i > youngShift)
    {
       Buffers tmpBuffers3;
     
      initBuffers(tmpBuffers3,i,Period());  
      CheckFakePositions2(tmpBuffers3.HighBuffer,tmpBuffers3.LowBuffer,tmpBuffers3.TimeBuffer,fPosition);
      i--;
     }
      
      
      DrawPositions(fPosition,true);
      ProcessResult(fPosition,criteriaArray[y],kalibResult);
      //PrintResult(kalibResult);
      
      //if(doKalibration)
      //  ObjectsDeleteAll();
       
    }
    
   GetProfitOption(kalibResult,kalibResultBestOption);
  
//Printn(kalibResultBestOption);
  
    KalibrationResult kalibResultSecureOption[];
   GetSecurestOption(kalibResult,kalibResultSecureOption);
   
   
   GetProfitOption(kalibResultSecureOption,KalibResultSecurestAndProfitOption);
   
  
}


void checkCriterias2(int oldShift, int youngShift, TradeTrigger &triggers[],ValidationCriteria &criteriaArray[],double stdv, bool doKalibration, KalibrationResult &kalibResultBestOption[],KalibrationResult &KalibResultSecurestAndProfitOption[])
{
  
    
   
}

  
  
  void simulateCriterias(datetime old_time,datetime young_time,TriggersValidationCriteria &triggerCriterias, double stdv, bool useTradingTime,Configuration &config)
  {
    
   
    KalibrationResult kalibResult[];
    KalibrationResult kalibResultBestOption[];
    int oldShift=iBarShift(Symbol(),Period(),old_time);
    int youngShift=iBarShift(Symbol(),Period(),young_time);
    
    
    
    //TradeTrigger trigger;
    int i =oldShift;
    int x = 0;
    TradeTrigger triggers[];
    while(i > youngShift)
    {
      Buffers buffers;
      initBuffers(buffers,i,Period());
      TradeTrigger tmpTrigger[];
      ArrayFree(tmpTrigger);
      bool triggerFound = checkTrigger(buffers,tmpTrigger,useTradingTime,config,false);
      
      if(ArraySize(tmpTrigger)>0)
      {
        int size = ArraySize(tmpTrigger);
        ArrayResize(triggers,ArraySize(triggers)+size,0);
        ArrayCopy(triggers,tmpTrigger,ArraySize(triggers)-size,0,WHOLE_ARRAY);
      }
      //if(triggerFound)
      //{
      // ArrayResize(triggers,ArraySize(triggers)+1,0);
      // triggers[x]=tmpTrigger;
      // x++;
      // }
     i--;
    
    }
    
    
    
    //i = oldShift;
   // for(int y = 0; y < ArraySize(criteriaArray);y++)
    //{
     
     TradeTrigger tmpTriggers[];
     ArrayCopy(tmpTriggers,triggers,0,0,WHOLE_ARRAY);
     
    FakePosition fPosition[];
    for(int z = 0; z < ArraySize(tmpTriggers);z++)
    { 
      Buffers tmpBuffers;
      Buffers tmpBuffers2;
      ValidationCriteria criteria;
     //Print(tmpTriggers[z].triggerType);
      initBuffers(tmpBuffers,iBarShift(Symbol(),Period(),tmpTriggers[z].time)-1,Period());  
      
      
      getCriteria(tmpTriggers[z],criteria,triggerCriterias);      
      bool valid = validateTrigger(tmpBuffers,tmpTriggers[z],criteria,config,false);
      
      double atr=iATR(Symbol(),Period(),14,iBarShift(Symbol(),Period(),tmpTriggers[z].time));
      double stdvCurrent=iStdDev(NULL,0,20,0,MODE_SMA,PRICE_CLOSE,iBarShift(Symbol(),Period(),tmpTriggers[z].time)-1);
      
      Print("ATR ",DoubleToStr(atr));
      
      //drawATR(tmpBuffers.TimeBuffer,atr);
      if(valid) // && stdvCurrent < stdv && tmpBuffers.VolumeBuffer[1] > tmpBuffers.avgVolume )
     {
       double stopLoss;
       double stpl = calculateStopLossPrize(tmpTriggers[z].pos,atr,stopLoss);
      
      //double atr2=iATR(NULL,0,14,0);
      // =(atr*2.0)-0.00050;
       
       double positionGr = calculatePositionGroesse(stopLoss,1000);

       double takeprofit=(atr/100.0) *90.0;
       
        //if(tmpTriggers[z].pos==Buy)
        //  takeprofit+=(Ask-Bid);
        //else if(tmpTriggers[z].pos==Sell)
        //  takeprofit-=(Ask-Bid); 

       //initBuffers(tmpBuffers2,iBarShift(Symbol(),Period(),triggers[z].time)-1,Period());   
       OpenFakePosition(tmpTriggers[z],positionGr,stopLoss,takeprofit,tmpBuffers.OpenBuffer,tmpBuffers.TimeBuffer,fPosition,false);
     }
      
    
      //i--;
    }
    
    i = oldShift;
    
    while(i > youngShift)
    {
       Buffers tmpBuffers3;
     
      initBuffers(tmpBuffers3,i,Period());  
      CheckFakePositions2(tmpBuffers3.HighBuffer,tmpBuffers3.LowBuffer,tmpBuffers3.TimeBuffer,fPosition);
      i--;
     }
      
      ValidationCriteria criteriaFake;
      DrawPositions(fPosition,false);
      ProcessResult(fPosition,criteriaFake,kalibResult);
      PrintResult(kalibResult);
      
      //if(doKalibration)
      //  ObjectsDeleteAll();
       
   
    
   GetProfitOption(kalibResult,kalibResultBestOption);
   PrintOptionResult("=== Profit Oprion ===",kalibResultBestOption);
//Printn(kalibResultBestOption);
  
    KalibrationResult kalibResultSecureOption[];
   GetSecurestOption(kalibResult,kalibResultSecureOption);
   
   KalibrationResult KalibResultSecurestAndProfitOption[];
   GetProfitOption(kalibResultSecureOption,KalibResultSecurestAndProfitOption);
   
   PrintOptionResult("=== Securest Oprion ===",KalibResultSecurestAndProfitOption);
   
  
   
   return;
    
    //DrawPositions(fPosition);
   
  }
  
  double calculateStopLossPrize2(Position pos, double atr, double &stopLossUnits)
  {
  
     stopLossUnits=((atr*2.0)/100)*90;
     if(pos == Buy)
      {
        return (Ask-stopLossUnits);
      }
      else
         return (Bid+stopLossUnits);
      //double stopLossPipe=stopLoss/Point;
  
  }
  
  void drawATR(datetime &timeBuffer[],double atr)
{
   //ObjectCreate("ATR"+timeBuffer[1],OBJ_TEXT,WindowFind("DeluxeEWPercentage"),timeBuffer[1],12); //Low[1]- (20*Point)
   //ObjectSetText("ATR"+timeBuffer[1],DoubleToString(atr),5,"Verdana",Green);
}
  

  
  

void startKalibration(datetime old_time,datetime young_time,ValidationCriteria &criteria,double stdv)
  {
   KalibrationResult kalibResult[];
   KalibrationResult kalibResultBestOption[];
   int oldShift=iBarShift(Symbol(),Period(),old_time);
   int youngShift=iBarShift(Symbol(),Period(),young_time);
   
   
   
   startKalibrationX(oldShift,youngShift,criteria,kalibResult,stdv);
   GetProfitOption(kalibResult,kalibResultBestOption);
   PrintOptionResult("=== Profit Oprion ===",kalibResultBestOption);
   
   
   KalibrationResult kalibResultSecureOption[];
   GetSecurestOption(kalibResult,kalibResultSecureOption);
   
   KalibrationResult KalibResultSecurestAndProfitOption[];
   GetProfitOption(kalibResultSecureOption,KalibResultSecurestAndProfitOption);
   
   PrintOptionResult("=== Securest Oprion ===",KalibResultSecurestAndProfitOption);
   
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void startKalibration(datetime old_time,datetime young_time,double stdv)
  {
   KalibrationResult kalibResult[];
   KalibrationResult kalibResultBestOption[];
   ArrayFree(kalibResult);
   ValidationCriteria KaliCriteriaArray[];
   int oldShift=iBarShift(Symbol(),Period(),old_time);
   int youngShift=iBarShift(Symbol(),Period(),young_time);

//BuildKalibCriteriaArray(KaliCriteriaArray);
   //readKalibFile(KaliCriteriaArray);
   for(int i=0; i<ArraySize(KaliCriteriaArray); i++)
     {
      double criteria[];
      //ArrayCopy(criteria,KaliCriteriaArray[i],0,0,WHOLE_ARRAY);
      //criteria = KaliCriteriaArray[i];
      startKalibrationX(oldShift,youngShift,KaliCriteriaArray[i],kalibResult,stdv);
     }
   GetProfitOption(kalibResult,kalibResultBestOption);
   PrintOptionResult("=== Profit Oprion ===",kalibResultBestOption);
//Printn(kalibResultBestOption);
  
    KalibrationResult kalibResultSecureOption[];
   GetSecurestOption(kalibResult,kalibResultSecureOption);
   
   KalibrationResult KalibResultSecurestAndProfitOption[];
   GetProfitOption(kalibResultSecureOption,KalibResultSecurestAndProfitOption);
   
   PrintOptionResult("=== Securest Oprion ===",KalibResultSecurestAndProfitOption);
   
   return;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GetProfitOption(KalibrationResult &kalibResult[],KalibrationResult &kalibResultBestOption[])
  {
   KalibrationResult tmpVergleichOption;
   tmpVergleichOption.Won=0;
   tmpVergleichOption.Lost=100000.0;
   tmpVergleichOption.Profit=-100000.0;
   ArrayFree(kalibResultBestOption);

   for(int i=0; i<ArraySize(kalibResult); i++)
     {
      if(kalibResult[i].Profit>tmpVergleichOption.Profit)
        {

         tmpVergleichOption.Profit=kalibResult[i].Profit;
        }
      //if(kalibResult[i].
     }

// for(int i=0; i < ArraySize(kalibResult); i++)
//{ 
//   if(kalibResult[i].Lost < tmpVergleichOption.Lost)
//   {

//    tmpVergleichOption.Lost= kalibResult[i].Lost;
// }

//}


   for(int x=0; x<ArraySize(kalibResult); x++)
     {
      if(kalibResult[x].Profit==tmpVergleichOption.Profit)
        {
         ArrayResize(kalibResultBestOption,ArraySize(kalibResultBestOption)+1,0);
         kalibResultBestOption[ArraySize(kalibResultBestOption)-1]=kalibResult[x];
        }
     }

//for(int x=0; x < ArraySize(kalibResult); x++)
//{
//   if(kalibResult[x].Lost==tmpVergleichOption.Lost)
//  {
//    ArrayResize(kalibResultBestOption,ArraySize(kalibResultBestOption)+1,0);
//    kalibResultBestOption[ArraySize(kalibResultBestOption)-1]=kalibResult[x];
// }
//} 
}

void GetSecurestOption(KalibrationResult &kalibResult[],KalibrationResult &kalibSecurestOption[])
  {
   KalibrationResult tmpVergleichOption;
   tmpVergleichOption.Won=0;
   tmpVergleichOption.Lost=1000;
   tmpVergleichOption.Profit=-100000.0;
  
  // KalibrationResult tmpKalibSec[];
  
    
   ArrayFree(kalibSecurestOption);
  
   for(int i=0; i<ArraySize(kalibResult); i++)
   {
      if(kalibResult[i].Lost < tmpVergleichOption.Lost && kalibResult[i].Won > 0 && kalibResult[i].Profit > 0.0)
      {
          
         tmpVergleichOption.Lost=kalibResult[i].Lost;
      } 
    }
    
   for(int i=0; i<ArraySize(kalibResult); i++)
   {
      if(kalibResult[i].Lost == tmpVergleichOption.Lost && kalibResult[i].Won > 0 && kalibResult[i].Profit > 0.0)
      {
         ArrayResize(kalibSecurestOption,ArraySize(kalibSecurestOption)+1,0);
         kalibSecurestOption[ArraySize(kalibSecurestOption)-1]=kalibResult[i];
      }
   }
     
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void readKalibFile(ValidationCriteria &KaliCriteriaArray[],string InpFileName)
  {
    // file name
   string InpDirectoryName="Data";
   ResetLastError();
   int file_handle=FileOpen(InpDirectoryName+"//"+InpFileName,FILE_READ|FILE_CSV,';');
   if(file_handle!=INVALID_HANDLE)
     {
      PrintFormat("%s file is available for reading",InpFileName);
      PrintFormat("File path: %s\\Files\\",TerminalInfoString(TERMINAL_DATA_PATH));
      //--- additional variables
      int    str_size;
      string str;
      int d1;
      int d2;
      int d3;
      int d4;
      int d5;

      int x=0;
      //--- read data from the file
      while(!FileIsEnding(file_handle))
        {
         //--- find out how many symbols are used for writing the time
         //str_size=FileReadInteger(file_handle,INT_VALUE);
         //str_size=(file_handle,INT_VALUE);
         // str_size=FileReadInteger(file_handle,INT_VALUE);
         //--- read the string
         d1= FileReadNumber(file_handle);
         d2= FileReadNumber(file_handle);
         d3= FileReadNumber(file_handle);
         d4= FileReadNumber(file_handle);
         d5= FileReadNumber(file_handle);

         ArrayResize(KaliCriteriaArray,x+1,0);

         

         KaliCriteriaArray[x].GewichtungRSIRange=d1*0.01;
         KaliCriteriaArray[x].GewichtungBand=d2*0.01;
         KaliCriteriaArray[x].GewichtungMA200Trend=0.0;//d3*0.01;
         KaliCriteriaArray[x].GewichtungStoch=d4*0.01;

         KaliCriteriaArray[x].ValidSchwelle=d5;

         //--- print the string
         // PrintFormat(IntegerToString(d1)+";"+IntegerToString(d2)+";"+IntegerToString(d3)+";"+IntegerToString(d4)+";"+IntegerToString(d5));
         x++;
         // if(x==100)
         //  break;
        }
      //--- close the file
      FileClose(file_handle);

      //PrintFormat("Data is read, %s file is closed",InpFileName);
     }
   else
      PrintFormat("Failed to open %s file, Error code = %d %s",InpFileName,GetLastError(),TerminalInfoString(TERMINAL_DATA_PATH));

  }
  
  void readLastCriteriaFile(ValidationCriteria &KaliCriteriaArray[],string InpFileName)
  {
    // file name
   string InpDirectoryName="Data";
   ResetLastError();
   int file_handle=FileOpen(InpDirectoryName+"//"+InpFileName,FILE_READ|FILE_BIN);
   if(file_handle!=INVALID_HANDLE)
     {
      PrintFormat("%s file is available for reading",InpFileName);
      PrintFormat("File path: %s\\Files\\",TerminalInfoString(TERMINAL_DATA_PATH));
      //--- additional variables
      int    str_size;
      string str;
      double d1;
      double d2;
      double d3;
      double d4;
      double d5;
      //double d6;

      int x=0;
      //--- read data from the file
      while(!FileIsEnding(file_handle))
        {
        d1=0.0;
        d2=0.0;
        d3=0.0;
        d4=0.0;
        d5=50.0;
         //--- find out how many symbols are used for writing the time
         //str_size=FileReadInteger(file_handle,INT_VALUE);
         //str_size=(file_handle,INT_VALUE);
         // str_size=FileReadInteger(file_handle,INT_VALUE);
         //--- read the string
         d1= FileReadDouble(file_handle,DOUBLE_VALUE);
         d2= FileReadDouble(file_handle,DOUBLE_VALUE);
         d3= FileReadDouble(file_handle,DOUBLE_VALUE);
         d4= FileReadDouble(file_handle,DOUBLE_VALUE);
         d5= FileReadDouble(file_handle,DOUBLE_VALUE);
         //d6 = FileReadDouble(file_handle,DOUBLE_VALUE);

         ArrayResize(KaliCriteriaArray,x+1,0);

      

         KaliCriteriaArray[x].GewichtungRSIRange=d1;
         KaliCriteriaArray[x].GewichtungBand=d2;
         KaliCriteriaArray[x].GewichtungMA200Trend=0.0;
         KaliCriteriaArray[x].GewichtungStoch=d4;

         KaliCriteriaArray[x].ValidSchwelle=d5;
        // KaliCriteriaArray[x].stdAvg=d6;

         //--- print the string
         // PrintFormat(IntegerToString(d1)+";"+IntegerToString(d2)+";"+IntegerToString(d3)+";"+IntegerToString(d4)+";"+IntegerToString(d5));
         x++;
         // if(x==100)
         //  break;
        }
      //--- close the file
      FileClose(file_handle);

      //PrintFormat("Data is read, %s file is closed",InpFileName);
     }
   else
      PrintFormat("Failed to open %s file, Error code = %d %s",InpFileName,GetLastError(),TerminalInfoString(TERMINAL_DATA_PATH));

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void startKalibrationX(int shiftOld,int shiftYoung,ValidationCriteria &criteria,KalibrationResult &kalibResult[],double stdv)
  {
   FakePosition fPositions[];
  
  // int i=shiftOld;

   ArrayFree(fPositions);
   Buffers buffersK;
   while(shiftOld>shiftYoung)
   {
      
      initBuffers(buffersK,shiftOld,Period());   
    
      double atr=iATR(NULL,0,14,shiftOld);
      double stdvCurrent=iStdDev(NULL,0,20,0,MODE_SMA,PRICE_CLOSE,shiftOld);


      CheckFakePositions(buffersK.HighBuffer,buffersK.LowBuffer,buffersK.TimeBuffer,fPositions);

      //doTheMagic(buffersK,criteria,atr,true,fPositions,10000.0,stdvCurrent,stdv);

      shiftOld--;
    }

   ProcessResult(fPositions,criteria,kalibResult);
   PrintResult(kalibResult);

   DrawPositions(fPositions,true);

   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ProcessResult(FakePosition &fPositions[],ValidationCriteria &criteria,KalibrationResult &kalibResult[])
  {
   KalibrationResult result;
   int won=0;
   int lost = 0;
   int open = 0;
   int unclear=0;
   double Profit=0.0;

   for(int i=0; i<ArraySize(fPositions); i++)
     {
      if(fPositions[i].status==Won)
         won++;
      else if(fPositions[i].status==Lost)
         lost++;
      else if(fPositions[i].status==SOpen)
         open++;
      else if(fPositions[i].status==Unclear)
         unclear++;

      Profit+=fPositions[i].Profit;
     }

   result.Won=won;
   result.Lost=lost;
   result.criteria=criteria;
   result.Profit=Profit/(10000/100);

   ArrayResize(kalibResult,ArraySize(kalibResult)+1,0);
   kalibResult[ArraySize(kalibResult)-1]=result;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PrintResult(KalibrationResult &kalibResult[])
  {

   for(int i=0; i<ArraySize(kalibResult); i++)
     {
      //Print("WON: ",kalibResult[i].Won," LOST: ",kalibResult[i].Lost, " Profit: ",kalibResult[i].Profit, " Unclear: ", unclear, " RISIGew: ", criteria.GewichtungRSIRange, " STOCHgew: "+criteria.GewichtungStoch, " Schwelle: "+criteria.ValidSchwelle);
      Print("WON: ",kalibResult[i].Won," LOST: ",kalibResult[i].Lost," Profit: ",kalibResult[i].Profit);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PrintOptionResult(string Header,KalibrationResult &kalibResultM[])
  {

   for(int i=0; i<ArraySize(kalibResultM); i++)
     {
      ValidationCriteria criteria=kalibResultM[i].criteria;
      //Print("WON: ",kalibResult[i].Won," LOST: ",kalibResult[i].Lost, " Profit: ",kalibResult[i].Profit, " Unclear: ", unclear, " RISIGew: ", criteria.GewichtungRSIRange, " STOCHgew: "+criteria.GewichtungStoch, " Schwelle: "+criteria.ValidSchwelle);
      Print(Header+" WON: ",kalibResultM[i].Won," LOST: ",kalibResultM[i].Lost,"| RSIGew: ",criteria.GewichtungRSIRange," BandGew: ",criteria.GewichtungBand," MA200: ",criteria.GewichtungMA200Trend," STOCH:",criteria.GewichtungStoch," Schwelle: ",criteria.ValidSchwelle," | Profit: ",kalibResultM[i].Profit);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  CheckFakePositions(double &HighBufferH[],double &LowBufferH[],datetime &TimeBuffer[],FakePosition &fPositions[])
  {
   if(ArraySize(fPositions)>0)
     {
      for(int i=0; i<ArraySize(fPositions); i++)
        {
         if(fPositions[i].status==SOpen)
           {
            if(fPositions[i].pos==Buy && fPositions[i].takeprofit<HighBufferH[0] && fPositions[i].stpl>LowBufferH[0])
              {
               LookDeeper(fPositions[i],TimeBuffer[0]);
               fPositions[i].endtime=TimeBuffer[0];
               CalclulateWinLost(fPositions[i]);

              }
            //TODO: in minuten chart nachschauen welcher zuert gehitet hat low oder high
            else if(fPositions[i].pos==Buy && fPositions[i].takeprofit<HighBufferH[0] && fPositions[i].stpl<LowBufferH[0])
              {
               fPositions[i].status=Won;
               fPositions[i].endtime=TimeBuffer[0];
               CalclulateWinLost(fPositions[i]);
               //ObjectCreate("PositionWON"+TimeBuffer[0]+i, OBJ_TREND, 0, fPositions[i].time, fPositions[i].ask, TimeBuffer[0], fPositions[i].takeprofit );
               //ObjectSet("PositionWON"+TimeBuffer[0]+i, OBJPROP_COLOR, Blue);
               //ObjectSet("PositionWON"+TimeBuffer[0]+i, OBJPROP_STYLE, STYLE_DASHDOTDOT );
               //ObjectSet("PositionWON"+TimeBuffer[0]+i, OBJPROP_WIDTH, 2);
               //ObjectSet("PositionWON"+TimeBuffer[0]+i, OBJPROP_RAY, False); 

              }
            else if(fPositions[i].pos==Sell && fPositions[i].takeprofit>LowBufferH[0] && fPositions[i].stpl<HighBufferH[0])
              {
               LookDeeper(fPositions[i],TimeBuffer[0]);
               fPositions[i].endtime=TimeBuffer[0];
               CalclulateWinLost(fPositions[i]);
              }
            else if(fPositions[i].pos==Sell && fPositions[i].takeprofit>LowBufferH[0] && fPositions[i].stpl>HighBufferH[0])
              {
               fPositions[i].status=Won;
               fPositions[i].endtime=TimeBuffer[0];

               CalclulateWinLost(fPositions[i]);
               //ObjectCreate("PositionWON"+TimeBuffer[0]+i, OBJ_TREND, 0, fPositions[i].time, fPositions[i].bid, TimeBuffer[0], fPositions[i].takeprofit );
               //ObjectSet("PositionWON"+TimeBuffer[0]+i, OBJPROP_COLOR, Blue);
               //ObjectSet("PositionWON"+TimeBuffer[0]+i, OBJPROP_STYLE, STYLE_DASHDOTDOT );
               //ObjectSet("PositionWON"+TimeBuffer[0]+i, OBJPROP_WIDTH, 2);
               //ObjectSet("PositionWON"+TimeBuffer[0]+i, OBJPROP_RAY, False); 
              }
            else if(fPositions[i].pos==Buy && fPositions[i].stpl>LowBufferH[0] && fPositions[i].takeprofit<HighBufferH[0])
              {
               LookDeeper(fPositions[i],TimeBuffer[0]);
               fPositions[i].endtime=TimeBuffer[0];
               CalclulateWinLost(fPositions[i]);
              }
            else if(fPositions[i].pos==Buy && fPositions[i].stpl>LowBufferH[0] && fPositions[i].takeprofit>HighBufferH[0])
              {
               fPositions[i].status=Lost;
               fPositions[i].endtime=TimeBuffer[0];
               CalclulateWinLost(fPositions[i]);
               // ObjectCreate("PositionWON"+TimeBuffer[0]+i, OBJ_TREND, 0, fPositions[i].time, fPositions[i].ask, TimeBuffer[0], fPositions[i].stpl );
               //ObjectSet("PositionWON"+TimeBuffer[0]+i, OBJPROP_COLOR, Orange);
               //ObjectSet("PositionWON"+TimeBuffer[0]+i, OBJPROP_STYLE, STYLE_DASHDOTDOT );
               //ObjectSet("PositionWON"+TimeBuffer[0]+i, OBJPROP_WIDTH, 2);
               //ObjectSet("PositionWON"+TimeBuffer[0]+i, OBJPROP_RAY, False); 
              }
            else if(fPositions[i].pos==Sell && fPositions[i].stpl<HighBufferH[0] && fPositions[i].takeprofit>LowBufferH[0])
              {
               LookDeeper(fPositions[i],TimeBuffer[0]);
               fPositions[i].endtime=TimeBuffer[0];
               CalclulateWinLost(fPositions[i]);
              }
            else if(fPositions[i].pos==Sell && fPositions[i].stpl<HighBufferH[0] && fPositions[i].takeprofit<LowBufferH[0])
              {
               fPositions[i].status=Lost;
               fPositions[i].endtime=TimeBuffer[0];
               CalclulateWinLost(fPositions[i]);
               //ObjectCreate("PositionWON"+TimeBuffer[0]+i, OBJ_TREND, 0, fPositions[i].time, fPositions[i].bid, TimeBuffer[0], fPositions[i].stpl );
               //ObjectSet("PositionWON"+TimeBuffer[0]+i, OBJPROP_COLOR, Orange);
               //ObjectSet("PositionWON"+TimeBuffer[0]+i, OBJPROP_STYLE, STYLE_DASHDOTDOT );
               //ObjectSet("PositionWON"+TimeBuffer[0]+i, OBJPROP_WIDTH, 2);
               //ObjectSet("PositionWON"+TimeBuffer[0]+i, OBJPROP_RAY, False); 
              }

           }
        }
     }

  }
  
  void  CheckFakePositions2(double &HighBufferH[],double &LowBufferH[],datetime &TimeBuffer[],FakePosition &fPositions[])
  {
   if(ArraySize(fPositions)>0)
     {
      for(int i=0; i<ArraySize(fPositions); i++)
        {
          if(TimeBuffer[0] >= fPositions[i].time)
          {
             if(fPositions[i].status==SOpen)
             {
                LookDeeper(fPositions[i],fPositions[i].time);
                //fPositions[i].endtime=TimeBuffer[0];
                CalclulateWinLost(fPositions[i]);

             }
        }
       }
     }

  }
  
  void  CheckFakePositions222(double &HighBufferH[],double &LowBufferH[],datetime &TimeBuffer[],FakePosition &fPositions[])
  {
   if(ArraySize(fPositions)>0)
     {
      for(int i=0; i<ArraySize(fPositions); i++)
        {
          if(TimeBuffer[0] >= fPositions[i].time)
          {
         if(fPositions[i].status==SOpen)
           {
            if(fPositions[i].pos==Buy && fPositions[i].takeprofit<HighBufferH[0] && fPositions[i].stpl>LowBufferH[0] )
              {
               LookDeeper(fPositions[i],TimeBuffer[0]);
               fPositions[i].endtime=TimeBuffer[0];
               CalclulateWinLost(fPositions[i]);

              }
            //TODO: in minuten chart nachschauen welcher zuert gehitet hat low oder high
            else if(fPositions[i].pos==Buy && fPositions[i].takeprofit<HighBufferH[0] && fPositions[i].stpl<LowBufferH[0])
              {
               fPositions[i].status=Won;
               fPositions[i].endtime=TimeBuffer[0];
               CalclulateWinLost(fPositions[i]);
               //ObjectCreate("PositionWON"+TimeBuffer[0]+i, OBJ_TREND, 0, fPositions[i].time, fPositions[i].ask, TimeBuffer[0], fPositions[i].takeprofit );
               //ObjectSet("PositionWON"+TimeBuffer[0]+i, OBJPROP_COLOR, Blue);
               //ObjectSet("PositionWON"+TimeBuffer[0]+i, OBJPROP_STYLE, STYLE_DASHDOTDOT );
               //ObjectSet("PositionWON"+TimeBuffer[0]+i, OBJPROP_WIDTH, 2);
               //ObjectSet("PositionWON"+TimeBuffer[0]+i, OBJPROP_RAY, False); 

              }
            else if(fPositions[i].pos==Sell && fPositions[i].takeprofit>LowBufferH[0] && (fPositions[i].stpl) < HighBufferH[0])
              {
               LookDeeper(fPositions[i],TimeBuffer[0]);
               fPositions[i].endtime=TimeBuffer[0];
               CalclulateWinLost(fPositions[i]);
              }
            else if(fPositions[i].pos==Sell && fPositions[i].takeprofit>LowBufferH[0] && fPositions[i].stpl > HighBufferH[0])
              {
               fPositions[i].status=Won;
               fPositions[i].endtime=TimeBuffer[0];

               CalclulateWinLost(fPositions[i]);
               //ObjectCreate("PositionWON"+TimeBuffer[0]+i, OBJ_TREND, 0, fPositions[i].time, fPositions[i].bid, TimeBuffer[0], fPositions[i].takeprofit );
               //ObjectSet("PositionWON"+TimeBuffer[0]+i, OBJPROP_COLOR, Blue);
               //ObjectSet("PositionWON"+TimeBuffer[0]+i, OBJPROP_STYLE, STYLE_DASHDOTDOT );
               //ObjectSet("PositionWON"+TimeBuffer[0]+i, OBJPROP_WIDTH, 2);
               //ObjectSet("PositionWON"+TimeBuffer[0]+i, OBJPROP_RAY, False); 
              }
            else if(fPositions[i].pos==Buy && fPositions[i].stpl>LowBufferH[0] && fPositions[i].takeprofit<HighBufferH[0])
              {
               LookDeeper(fPositions[i],TimeBuffer[0]);
               fPositions[i].endtime=TimeBuffer[0];
               CalclulateWinLost(fPositions[i]);
              }
            else if(fPositions[i].pos==Buy && fPositions[i].stpl>LowBufferH[0] && fPositions[i].takeprofit>HighBufferH[0])
              {
               fPositions[i].status=Lost;
               fPositions[i].endtime=TimeBuffer[0];
               CalclulateWinLost(fPositions[i]);
               // ObjectCreate("PositionWON"+TimeBuffer[0]+i, OBJ_TREND, 0, fPositions[i].time, fPositions[i].ask, TimeBuffer[0], fPositions[i].stpl );
               //ObjectSet("PositionWON"+TimeBuffer[0]+i, OBJPROP_COLOR, Orange);
               //ObjectSet("PositionWON"+TimeBuffer[0]+i, OBJPROP_STYLE, STYLE_DASHDOTDOT );
               //ObjectSet("PositionWON"+TimeBuffer[0]+i, OBJPROP_WIDTH, 2);
               //ObjectSet("PositionWON"+TimeBuffer[0]+i, OBJPROP_RAY, False); 
              }
            else if(fPositions[i].pos==Sell && fPositions[i].stpl < HighBufferH[0] && fPositions[i].takeprofit > LowBufferH[0])
              {
               LookDeeper(fPositions[i],TimeBuffer[0]);
               fPositions[i].endtime=TimeBuffer[0];
               CalclulateWinLost(fPositions[i]);
              }
            else if(fPositions[i].pos==Sell && (fPositions[i].stpl - (Ask-Bid)) <HighBufferH[0] && fPositions[i].takeprofit<LowBufferH[0])
              {
               fPositions[i].status=Lost;
               fPositions[i].endtime=TimeBuffer[0];
               CalclulateWinLost(fPositions[i]);
               //ObjectCreate("PositionWON"+TimeBuffer[0]+i, OBJ_TREND, 0, fPositions[i].time, fPositions[i].bid, TimeBuffer[0], fPositions[i].stpl );
               //ObjectSet("PositionWON"+TimeBuffer[0]+i, OBJPROP_COLOR, Orange);
               //ObjectSet("PositionWON"+TimeBuffer[0]+i, OBJPROP_STYLE, STYLE_DASHDOTDOT );
               //ObjectSet("PositionWON"+TimeBuffer[0]+i, OBJPROP_WIDTH, 2);
               //ObjectSet("PositionWON"+TimeBuffer[0]+i, OBJPROP_RAY, False); 
              }

           }
        }
        }
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalclulateWinLost(FakePosition &fPosition)
  {
   double PV=MarketInfo(Symbol(),MODE_TICKVALUE);
   double profit;
   double pips;
   datetime time;

   double exit;
   double entry;

   if(fPosition.pos==Buy && fPosition.status==Won)
     {
      time=fPosition.time;
      //(exit - entry) * 0.1 * (1 / MarketInfo(Symbol(), MODE_POINT)) * MarketInfo(Symbol(), MODE_TICKVALUE);
      exit=fPosition.takeprofit;
      entry=fPosition.ask;
      profit=(exit-entry)*fPosition.positionGr *(1/MarketInfo(Symbol(),MODE_POINT))*MarketInfo(Symbol(),MODE_TICKVALUE);
      fPosition.Profit=profit;
      //profit = MarketInfo(Symbol(), MODE_TICKVALUE) * 0.1 * pips;
      //fPosition.Gewinn = (fPosition.takeprofit-fPosition.ask)*PV; 
     }
   if(fPosition.pos==Buy && fPosition.status==Lost)
     {

      exit=fPosition.stpl;
      entry=fPosition.ask;

      profit=(exit-entry)*fPosition.positionGr *(1/MarketInfo(Symbol(),MODE_POINT))*MarketInfo(Symbol(),MODE_TICKVALUE);
      fPosition.Profit=profit;
      //fPosition.Gewinn = (fPosition.takeprofit-fPosition.ask)*PV; 
     }
   if(fPosition.pos==Sell && fPosition.status==Won)
     {
      //(exit - entry) * 0.1 * (1 / MarketInfo(Symbol(), MODE_POINT)) * MarketInfo(Symbol(), MODE_TICKVALUE);
      exit=fPosition.takeprofit;
      entry=fPosition.bid;
      profit=(entry-exit)*fPosition.positionGr *(1/MarketInfo(Symbol(),MODE_POINT))*MarketInfo(Symbol(),MODE_TICKVALUE);
      fPosition.Profit=profit;
      //profit = MarketInfo(Symbol(), MODE_TICKVALUE) * 0.1 * pips;
      //fPosition.Gewinn = (fPosition.takeprofit-fPosition.ask)*PV; 
     }
   if(fPosition.pos==Sell && fPosition.status==Lost)
     {

      exit=fPosition.stpl;
      entry=fPosition.bid;

      profit=(entry-exit)*fPosition.positionGr *(1/MarketInfo(Symbol(),MODE_POINT))*MarketInfo(Symbol(),MODE_TICKVALUE);
      fPosition.Profit=profit;
      //fPosition.Gewinn = (fPosition.takeprofit-fPosition.ask)*PV; 
     }

   return;

  }
  
  
  void LookDeeper(FakePosition &fPosition,datetime time)
  {
   double HighBufferD[];
   double LowBufferD[];
   datetime TimeBufferD[];

   int index=iBarShift(Symbol(),PERIOD_M1,time);
   //int young=iBarShift(Symbol(),PERIOD_M1,time+(PERIOD_M15*60));

   //while(fPosition.status==SOpen && index != 0)
   //  {

      //ArrayFree(HighBufferD);
      //ArrayFree(LowBufferD);
      //ArrayFree(TimeBufferD);
   
      ArraySetAsSeries(HighBufferD,true);
      ArraySetAsSeries(LowBufferD,true);
      ArraySetAsSeries(TimeBufferD,true);
      
      CopyHigh(Symbol(),PERIOD_M1,0,index,HighBufferD);
      CopyLow(Symbol(),PERIOD_M1,0,index,LowBufferD);
      CopyTime(Symbol(),PERIOD_M1,0,index,TimeBufferD);

     while((index-1) > 0 && fPosition.status==SOpen)
     {
      if(fPosition.status==SOpen)
        {
         if(fPosition.pos==Buy && fPosition.takeprofit<HighBufferD[index-1] && fPosition.stpl>LowBufferD[index-1])
           {

            fPosition.status=Unclear;

           }
         //TODO: in minuten chart nachschauen welcher zuert gehitet hat low oder high
         else if(fPosition.pos==Buy && (fPosition.takeprofit +(Ask-Bid)) < HighBufferD[index-1] && (fPosition.stpl+(Ask-Bid)) <LowBufferD[index-1])
           {
            fPosition.status=Won;
            fPosition.endtime=TimeBufferD[index-1];
            //ObjectCreate("PositionWON"+TimeBufferD[0], OBJ_TREND, 0, fPosition.time,fPosition.ask,time, fPosition.takeprofit );
            //ObjectSet("PositionWON"+TimeBufferD[0], OBJPROP_COLOR, Red);
            //ObjectSet("PositionWON"+TimeBufferD[0], OBJPROP_STYLE, STYLE_DASHDOTDOT );
            //ObjectSet("PositionWON"+TimeBufferD[0], OBJPROP_WIDTH, 2);
            //ObjectSet("PositionWON"+TimeBufferD[0], OBJPROP_RAY, False);      
           }
         else if(fPosition.pos==Sell && (fPosition.takeprofit - (Ask-Bid)) > LowBufferD[index-1] && (fPosition.stpl -(Ask-Bid))  <HighBufferD[index-1])
           {
            fPosition.status=Unclear;
           }
         else if(fPosition.pos==Sell && fPosition.takeprofit >LowBufferD[index-1] && fPosition.stpl>HighBufferD[index-1])
           {
            fPosition.status=Won;
            fPosition.endtime=TimeBufferD[index-1];

           }
         else if(fPosition.pos==Buy && (fPosition.stpl+(Ask-Bid)) > LowBufferD[index-1] && (fPosition.takeprofit +(Ask-Bid))<HighBufferD[index-1])
           {
            fPosition.status=Unclear;
            fPosition.endtime=TimeBufferD[index-1];
           }
         else if(fPosition.pos==Buy && (fPosition.stpl+(Ask-Bid)) >LowBufferD[index-1] && (fPosition.takeprofit+(Ask-Bid)) >HighBufferD[index-1])
           {
            fPosition.status=Lost;
            fPosition.endtime=TimeBufferD[index-1];
           }
         else if(fPosition.pos==Sell && (fPosition.stpl - (Ask-Bid)) <HighBufferD[index-1] && (fPosition.takeprofit - (Ask-Bid))>LowBufferD[index-1])
           {
            fPosition.status=Unclear;
           }
         else if(fPosition.pos==Sell && (fPosition.stpl - (Ask-Bid))<=HighBufferD[index-1] && (fPosition.takeprofit - (Ask-Bid))<LowBufferD[index-1])
           {
            fPosition.status=Lost;
            fPosition.endtime=TimeBufferD[index-1];
           }

        }
        
        index --;
      }
     

  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LookDeeper2(FakePosition &fPosition,datetime time)
  {
   double HighBufferD[];
   double LowBufferD[];
   datetime TimeBufferD[];

   int old=iBarShift(Symbol(),PERIOD_M1,time);
   int young=iBarShift(Symbol(),PERIOD_M1,time+(PERIOD_M15*60));

   while(old>young)
     {

      ArrayFree(HighBufferD);
      ArrayFree(LowBufferD);
      ArrayFree(TimeBufferD);

      CopyHigh(Symbol(),PERIOD_M1,old,5,HighBufferD);
      CopyLow(Symbol(),PERIOD_M1,old,5,LowBufferD);
      CopyTime(Symbol(),PERIOD_M1,old,5,TimeBufferD);

      if(fPosition.status==SOpen)
        {
         if(fPosition.pos==Buy && fPosition.takeprofit<HighBufferD[0] && fPosition.stpl>LowBufferD[0])
           {

            fPosition.status=Unclear;

           }
         //TODO: in minuten chart nachschauen welcher zuert gehitet hat low oder high
         else if(fPosition.pos==Buy && fPosition.takeprofit<HighBufferD[0] && fPosition.stpl<LowBufferD[0])
           {
            fPosition.status=Won;
            //ObjectCreate("PositionWON"+TimeBufferD[0], OBJ_TREND, 0, fPosition.time,fPosition.ask,time, fPosition.takeprofit );
            //ObjectSet("PositionWON"+TimeBufferD[0], OBJPROP_COLOR, Red);
            //ObjectSet("PositionWON"+TimeBufferD[0], OBJPROP_STYLE, STYLE_DASHDOTDOT );
            //ObjectSet("PositionWON"+TimeBufferD[0], OBJPROP_WIDTH, 2);
            //ObjectSet("PositionWON"+TimeBufferD[0], OBJPROP_RAY, False);      
           }
         else if(fPosition.pos==Sell && fPosition.takeprofit>LowBufferD[0] && fPosition.stpl<HighBufferD[0])
           {
            fPosition.status=Unclear;
           }
         else if(fPosition.pos==Sell && fPosition.takeprofit>LowBufferD[0] && fPosition.stpl>HighBufferD[0])
           {
            fPosition.status=Won;

           }
         else if(fPosition.pos==Buy && fPosition.stpl>LowBufferD[0] && fPosition.takeprofit<HighBufferD[0])
           {
            fPosition.status=Unclear;
           }
         else if(fPosition.pos==Buy && fPosition.stpl>LowBufferD[0] && fPosition.takeprofit>HighBufferD[0])
           {
            fPosition.status=Lost;
           }
         else if(fPosition.pos==Sell && fPosition.stpl<HighBufferD[0] && fPosition.takeprofit>LowBufferD[0])
           {
            fPosition.status=Unclear;
           }
         else if(fPosition.pos==Sell && fPosition.stpl<HighBufferD[0] && fPosition.takeprofit<LowBufferD[0])
           {
            fPosition.status=Lost;
           }

        }
      old--;
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawPositions(FakePosition &fakePosition[],bool isKalibration)
  {
  
   if(!isKalibration)
   {
   for(int i=0; i<ArraySize(fakePosition);i++)
     {
      if(fakePosition[i].status==Won)
        {
         if(fakePosition[i].pos==Buy)
           {
            ObjectCreate("PositionWON"+fakePosition[i].endtime+fakePosition[i].ask,OBJ_TREND,0,fakePosition[i].time,fakePosition[i].ask,fakePosition[i].endtime,fakePosition[i].takeprofit);
            ObjectSet("PositionWON"+fakePosition[i].endtime+fakePosition[i].ask, OBJPROP_COLOR, Blue);
            ObjectSet("PositionWON"+fakePosition[i].endtime+fakePosition[i].ask, OBJPROP_STYLE, STYLE_DASHDOTDOT );
            ObjectSet("PositionWON"+fakePosition[i].endtime+fakePosition[i].ask, OBJPROP_WIDTH, 2);
            ObjectSet("PositionWON"+fakePosition[i].endtime+fakePosition[i].ask, OBJPROP_RAY, False);
           }
         else if(fakePosition[i].pos==Sell)
           {
            ObjectCreate("PositionWON"+fakePosition[i].endtime+fakePosition[i].bid,OBJ_TREND,0,fakePosition[i].time,fakePosition[i].bid,fakePosition[i].endtime,fakePosition[i].takeprofit);
            ObjectSet("PositionWON"+fakePosition[i].endtime+fakePosition[i].bid, OBJPROP_COLOR, Blue);
            ObjectSet("PositionWON"+fakePosition[i].endtime+fakePosition[i].bid, OBJPROP_STYLE, STYLE_DASHDOTDOT );
            ObjectSet("PositionWON"+fakePosition[i].endtime+fakePosition[i].bid, OBJPROP_WIDTH, 2);
            ObjectSet("PositionWON"+fakePosition[i].endtime+fakePosition[i].bid, OBJPROP_RAY, False);
           }
        }
      else if(fakePosition[i].status==Lost)
        {
         if(fakePosition[i].pos==Buy)
           {
            ObjectCreate("PositionLOST"+fakePosition[i].endtime+fakePosition[i].ask,OBJ_TREND,0,fakePosition[i].time,fakePosition[i].ask,fakePosition[i].endtime,fakePosition[i].stpl);
            ObjectSet("PositionLOST"+fakePosition[i].endtime+fakePosition[i].ask, OBJPROP_COLOR, Orange);
            ObjectSet("PositionLOST"+fakePosition[i].endtime+fakePosition[i].ask, OBJPROP_STYLE, STYLE_DASHDOTDOT );
            ObjectSet("PositionLOST"+fakePosition[i].endtime+fakePosition[i].ask, OBJPROP_WIDTH, 2);
            ObjectSet("PositionLOST"+fakePosition[i].endtime+fakePosition[i].ask, OBJPROP_RAY, False);
           }
         else if(fakePosition[i].pos==Sell)
           {
            ObjectCreate("PositionLOST"+fakePosition[i].endtime+fakePosition[i].bid,OBJ_TREND,0,fakePosition[i].time,fakePosition[i].bid,fakePosition[i].endtime,fakePosition[i].stpl);
            ObjectSet("PositionLOST"+fakePosition[i].endtime+fakePosition[i].bid, OBJPROP_COLOR, Orange);
            ObjectSet("PositionLOST"+fakePosition[i].endtime+fakePosition[i].bid, OBJPROP_STYLE, STYLE_DASHDOTDOT );
            ObjectSet("PositionLOST"+fakePosition[i].endtime+fakePosition[i].bid, OBJPROP_WIDTH, 2);
            ObjectSet("PositionLOST"+fakePosition[i].endtime+fakePosition[i].bid, OBJPROP_RAY, False);
           }
        }
     }
   }
  }
//+------------------------------------------------------------------+
