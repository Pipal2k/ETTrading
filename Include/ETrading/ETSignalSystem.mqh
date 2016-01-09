//+------------------------------------------------------------------+
//|                                               ETSignalSystem.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include <ETrading/ETdataTypes.mqh>
#include <ETrading/ETPivot.mqh>
#include <ETrading/ETBarBuffer.mqh>
#include <ETrading/ETSignalProcessing.mqh>
#include <ETrading/ETActionPattern.mqh>
#include <ETrading/ETActionPatternMatch.mqh>

//#define PIVOT 

int SignalSystemOptions=0;
SR_Zone zones[];
//ActionPattern actionPatterns[];
Buffers barBuffers;
ETSignal CurrentSignals[];
ETSignal lastSignal;
SR_Row sr_rows[];

CompiledActionPattern compActionPatterns[];


void initETSignalSystem(int SignalSystemOptions_Flags, ActionPattern &input_actionPatterns[]) export
{  
   SignalSystemOptions = SignalSystemOptions_Flags;
   PrintOptions();
  // copyActionPattern(actionPatterns,input_actionPatterns);
   
   parseActionExpression(input_actionPatterns, compActionPatterns);
   
  //actionPatterns=input_actionPatterns;  
   //ArrayResize(actionPatterns,ArraySize(input_actionPatterns),0);
   //ArrayCopy(actionPatterns,input_actionPatterns,0,0,WHOLE_ARRAY);
   
   //Print(actionPatterns[0].pos);
   // Print(input_actionPatterns[0].pos);
   //actionPatterns = *input_actionPatterns; 
   
}



bool DoSignalProcessing(int count) export
{
   // if(Volume[0]>1)
    //    return false;
    
    
   // ArrayFree(zones);
    //Support Resistance Lineien
    findSRZones(zones);
    
    initBuffers(barBuffers,Time[0],count,Period(),false); 
    //Print("Debug: "+barBuffers.TimeBuffer[0]);
    
   // for(int i = 0; i< ArraySize(barBuffers.RSIBuffer); i++)
   // {
   //  Print("RSI AT: "+barBuffers.TimeBuffer[i]+" "+barBuffers.RSIBuffer[i]);
   // }
    
    process(barBuffers,CurrentSignals,zones,lastSignal);
    
    if(ArraySize(CurrentSignals) > 0)
       copyETSignal(CurrentSignals[ArraySize(CurrentSignals)-1],lastSignal);
     //lastSignal = CurrentSignals[ArraySize(CurrentSignals)-1];
    
    
    if(SignalSystemOptions & DEBUG_SIGNALS)
     PrintSignalForDebug();
    
    
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
        patternMatch(compActionPatterns[i],CurrentSignals,onTime);
     
       if(ArraySize(compActionPatterns[i].actionPattern.matchingTimes) > 0)
       {
         
         ArrayResize(matchingPatterns,ArraySize(matchingPatterns)+1,0);
         copyActionPattern(matchingPatterns[ArraySize(matchingPatterns)-1],compActionPatterns[i].actionPattern);
       }  
     
   }
   
  // Print(ArraySize(matchingPatterns));
}


void findSRZones(SR_Zone &zoens[]) export
{
  
  ArrayFree(sr_rows);
  ArrayFree(zones);
  
  if(SignalSystemOptions & PIVOT)
   calculatePivot(sr_rows,PERIOD_D1,Standard);
  
  if(SignalSystemOptions & FPIVOT)
   calculatePivot(sr_rows,PERIOD_D1,Fibo);
   

   
   RowsToZones(zones,sr_rows);
}

void RowsToZones(SR_Zone &destZones[], SR_Row &rows[])
{
   ArrayFree(destZones);
   
   for(int i; i < ArraySize(rows); i++)
   {
     ArrayResize(destZones, ArraySize(destZones)+1,0);
     destZones[ArraySize(destZones)-1].HighBorder= rows[i].Prize;
     destZones[ArraySize(destZones)-1].LowBorder= rows[i].Prize;
   }

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
  
  if(pivotRow[i].type != MR1 && pivotRow[i].type != MR2 && pivotRow[i].type != MR3 && pivotRow[i].type != MS1 && pivotRow[i].type != MS2 && pivotRow[i].type != MS3 )
   ObjectCreate(EnumToString(pivotRow[i].type)+DoubleToString(pivotRow[i].Prize), OBJ_HLINE, 0, Time[0],pivotRow[i].Prize, 0, 0);
   
   if(drawMidPivots && (pivotRow[i].type == MR1 || pivotRow[i].type == MR2 || pivotRow[i].type == MR3 || pivotRow[i].type == MS1 || pivotRow[i].type == MS2 || pivotRow[i].type == MS3 ))
   ObjectCreate(EnumToString(pivotRow[i].type)+DoubleToString(pivotRow[i].Prize), OBJ_HLINE, 0, Time[0],pivotRow[i].Prize, 0, 0);
   
   if(pivotRow[i].type == DPivot)
   ObjectSetInteger(0,EnumToString(pivotRow[i].type)+DoubleToString(pivotRow[i].Prize),OBJPROP_COLOR,Blue);
   
    if(pivotRow[i].type == WPivot)
   ObjectSetInteger(0,EnumToString(pivotRow[i].type)+DoubleToString(pivotRow[i].Prize),OBJPROP_COLOR,Black);
  
  if(pivotRow[i].type == R1 || pivotRow[i].type == R2 || pivotRow[i].type == R3)
  ObjectSetInteger(0,EnumToString(pivotRow[i].type)+DoubleToString(pivotRow[i].Prize),OBJPROP_COLOR,Red);
  
  if(pivotRow[i].type == S1 || pivotRow[i].type == S2 || pivotRow[i].type == S3)
  ObjectSetInteger(0,EnumToString(pivotRow[i].type)+DoubleToString(pivotRow[i].Prize),OBJPROP_COLOR,Green);
  
  if(drawMidPivots && (pivotRow[i].type == MR1 || pivotRow[i].type == MR2 || pivotRow[i].type == MR3 || pivotRow[i].type == MS1 || pivotRow[i].type == MS2 || pivotRow[i].type == MS3 ))
  ObjectSetInteger(0,EnumToString(pivotRow[i].type)+DoubleToString(pivotRow[i].Prize),OBJPROP_COLOR,Gray);
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
        
        }  
        
        Print(SignalDescr);   
     }
}