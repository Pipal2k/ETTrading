//+------------------------------------------------------------------+
//|                                               ETSignalSystem.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include <ETrading/ETdataTypes.mqh>
#include <ETrading/DataProviderSystem/ETPivot.mqh>
#include <ETrading/DataProviderSystem/ETDataProviderSystem.mqh>
#include <ETrading/ETBarBuffer.mqh>
#include <ETrading/SignalSystem/ETSignalProcessing.mqh>
#include <ETrading/SignalSystem/ETActionPatternParser.mqh>
#include <ETrading/SignalSystem/ETActionPatternMatch.mqh>

//#define PIVOT 

int SignalSystemOptions = 0;

//SR_Zone zones[];
//ActionPattern actionPatterns[];
Buffers barBuffers;
ETSignal CurrentSignals[];
ETSignal lastSignal;
ProvidedData provData;


CompiledActionPattern compActionPatterns[];
int nec_periods[];


void initETSignalSystem( ActionPattern &input_actionPatterns[],  int DataProviderOptions_Flags, int SignalSystemOptions_Flags) export
{  
   
   SignalSystemOptions = SignalSystemOptions_Flags;
   initDataProviderSys(DataProviderOptions_Flags);
  //DataProviderOptions = DataProviderOptions_Flags;
   PrintOptions();
  // copyActionPattern(actionPatterns,input_actionPatterns);
  
   for(int i = 0; i < ArraySize(input_actionPatterns); i++)
   {
      if(input_actionPatterns[i].status == Enabled)
      {
         if(!periodArraySearch(nec_periods,input_actionPatterns[i].timeframe))
         {
            ArrayResize(nec_periods,ArraySize(nec_periods)+1,0);
            nec_periods[ArraySize(nec_periods)-1]=input_actionPatterns[i].timeframe;
         }
   
      }
   }
   
   parseActionExpression(input_actionPatterns, compActionPatterns);
   
  //actionPatterns=input_actionPatterns;  
   //ArrayResize(actionPatterns,ArraySize(input_actionPatterns),0);
   //ArrayCopy(actionPatterns,input_actionPatterns,0,0,WHOLE_ARRAY);
   
   //Print(actionPatterns[0].pos);
   // Print(input_actionPatterns[0].pos);
   //actionPatterns = *input_actionPatterns; 
   
}

bool periodArraySearch(int &inputArray[], int searchInt)
{
   bool result = false;
   
   for(int i = 0; i < ArraySize(inputArray); i++)
   {
       if(inputArray[i] == searchInt)
       {
         result = true;
         break;
       }
   }
  
  return result;
}



bool DoSignalProcessing(int count) export
{

   
  
   ProvidedData provData;
    /*if(Volume[0]>1)
        return false;*/
    
    
   // ArrayFree(zones);
    //Support Resistance Lineien
    //findSRZones(zones,DataProviderOptions);
   
   for(int i=0; i < ArraySize(nec_periods); i++)
   {
    Buffers barBuffers;
    ETSignal CurrentSignals[];
    ETSignal lastSignal;
    
    provideData(provData);
    
    initBuffers(barBuffers,Time[0],count,nec_periods[i],false);
    process(barBuffers,CurrentSignals,provData,lastSignal,NULL,SignalSystemOptions);
    
    if(ArraySize(CurrentSignals) > 0)
       copyETSignal(CurrentSignals[ArraySize(CurrentSignals)-1],lastSignal);
     //lastSignal = CurrentSignals[ArraySize(CurrentSignals)-1];
    
    
    if(SignalSystemOptions & DEBUG_SIGNALS)
     PrintSignalForDebug();
   }
    
   //Draw Objects
   ObjectsDeleteAll();
   if(SignalSystemOptions & DRAW_SR_ROWS)
   {
      if((SignalSystemOptions & DRAW_SR_MID_PIVOTS))
         DrawSRRows(sr_rows,true);
      else
        DrawSRRows(sr_rows,false);
   }
   
   return true;
}

void getMatchingActionPatterns(ActionPattern &matchingPatterns[],bool onTime)
{
   ArrayFree(matchingPatterns);
   for(int i = 0; i < ArraySize(compActionPatterns); i++)
   {
       if(compActionPatterns[i].actionPattern.status == Enabled)
       {
              patternMatch(compActionPatterns[i],CurrentSignals,onTime);
           
             if(ArraySize(compActionPatterns[i].actionPattern.matchingTimes) > 0)
             {
               ArrayResize(matchingPatterns,ArraySize(matchingPatterns)+1,0);
               copyActionPattern(matchingPatterns[ArraySize(matchingPatterns)-1],compActionPatterns[i].actionPattern);
               copyProvidedData(matchingPatterns[ArraySize(matchingPatterns)-1].prepData,provData);
               
             }
       }  
     
   }
   
  // Print(ArraySize(matchingPatterns));
}





void PrintOptions() export
{
   int b = 0;
   if(SignalSystemOptions & PIVOT)
      Print("Pivot Option Set");  
  if(SignalSystemOptions & FPIVOT) 
      Print("FPivot Option Set");
  if(SignalSystemOptions & KEYLEVELS) 
      Print("KeyLevels Option Set"); 
  if(SignalSystemOptions & DRAW_SR_MID_PIVOTS)
    Print("Draw Mid Pivots Option Set"); 
}

void DrawSRRows(SR_Row &pivotRow[],bool drawMidPivots) export
{
  for(int i = 0; i < ArraySize(pivotRow);i++)
  {
  
  if(!(pivotRow[i].type & MIDPIVOT) )
   ObjectCreate("SR"+DoubleToString(pivotRow[i].Prize), OBJ_HLINE, 0, Time[0],pivotRow[i].Prize, 0, 0);
   
   if(drawMidPivots && (pivotRow[i].type & MIDPIVOT))
   ObjectCreate("SR"+DoubleToString(pivotRow[i].Prize), OBJ_HLINE, 0, Time[0],pivotRow[i].Prize, 0, 0);
   
   if(pivotRow[i].type & DPivot)
   ObjectSetInteger(0,"SR"+DoubleToString(pivotRow[i].Prize),OBJPROP_COLOR,Blue);
   
    if(pivotRow[i].type & WPivot)
   ObjectSetInteger(0,"SR"+DoubleToString(pivotRow[i].Prize),OBJPROP_COLOR,Black);
  
  if(pivotRow[i].type & R1 || pivotRow[i].type & R2 || pivotRow[i].type & R3)
  ObjectSetInteger(0,"SR"+DoubleToString(pivotRow[i].Prize),OBJPROP_COLOR,Red);
  
  if(pivotRow[i].type & S1 || pivotRow[i].type & S2 || pivotRow[i].type & S3)
  ObjectSetInteger(0,"SR"+DoubleToString(pivotRow[i].Prize),OBJPROP_COLOR,Green);
  
  if(drawMidPivots && (pivotRow[i].type & MR1 || pivotRow[i].type & MR2 || pivotRow[i].type & MR3 || pivotRow[i].type & MS1 || pivotRow[i].type & MS2 || pivotRow[i].type & MS3 ))
  ObjectSetInteger(0,"SR"+DoubleToString(pivotRow[i].Prize),OBJPROP_COLOR,Gray);
  }
}


void PrintSignalForDebug()
{

     if(ArraySize(CurrentSignals) > 0)
     {
        string SignalDescr="";
        
        Print("========= SIGNALS AT "+CurrentSignals[ArraySize(CurrentSignals)-1].time+" ===========");
        for(int i = 0; i < ArraySize(CurrentSignals);i++)
        {
          
          SignalDescr +=" --> ";
          
          if(CurrentSignals[i].sig_flags & SIG_BARBEARISH)
           SignalDescr +="SIG_BARBEARISH ";
            
          if(CurrentSignals[i].sig_flags & SIG_BARBULLISH)
            SignalDescr+="SIG_BARBULLISH ";
            
          if(CurrentSignals[i].sig_flags & SIG_BEARISHCANDLESTICK)
            SignalDescr+="SIG_BEARISHCANDLESTICK ";
           
          if(CurrentSignals[i].sig_flags & SIG_BULLISHCADLESTICK)
            SignalDescr+="SIG_BULLISHCADLESTICK ";
            
          if(CurrentSignals[i].sig_flags & SIG_SR_BREAKTHROUGHBEARISH)
           SignalDescr+="SIG_SR_BREAKTHROUGHBEARISH ";
           
          if(CurrentSignals[i].sig_flags & SIG_SR_BREAKTHROUGHBULLISH)
            SignalDescr+="SIG_SR_BREAKTHROUGHBULLISH ";
            
          if(CurrentSignals[i].sig_flags & SIG_BEARISHCANDLESTICK)
            SignalDescr+="SIG_BEARISHCANDLESTICK ";
           
           if(CurrentSignals[i].sig_flags & SIG_BULLISHCADLESTICK)
            SignalDescr+="SIG_BULLISHCADLESTICK ";
            
           if(CurrentSignals[i].sig_flags & SIG_CS_BEARISHENGULFING)
            SignalDescr+="SIG_CS_BEARSIHENGULFING ";
           
        }  
        
        Print(SignalDescr);   
     }
}
