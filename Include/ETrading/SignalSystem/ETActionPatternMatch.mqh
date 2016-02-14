//+------------------------------------------------------------------+
//|                                         ETActionPatternMatch.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include <ETrading/ETDataTypes.mqh>
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

bool patternMatch(CompiledActionPattern &cAPattern, ETSignal &cSignals[],bool onTime)
{
    int index = 0;
    int signalIndex =0;
    int barIndex =0;
    bool condition = true;
    
    //while(index < ArraySize(cAPattern.compiledBarPatterns))
    //{
         
     //   condition = startCheckCondition(cAPattern.compiledBarPatterns[index],cSignals,0);
     //   index++;
   // }
   
   ArrayFree(cAPattern.actionPattern.matchingTimes);
   
   for(int i =0; i < ArraySize(cSignals);i++) 
   {
     datetime matchingDate;
     ETSignal matchingSignal;
     
     for(int x=0;x < ArraySize(cAPattern.compiledBarPatterns);x++)
     {
      cAPattern.compiledBarPatterns[x].occ=0;
      ArrayFree(cAPattern.compiledBarPatterns[x].matchingSignals);
     }
     
     
     if(condition = rekursivePatternMatch(i,0,cSignals,cAPattern,matchingDate))
     {
       if(onTime && matchingDate == Time[1] && checkWhereConditions(cAPattern))
       {
        //cAPattern.
         ArrayResize(cAPattern.actionPattern.matchingTimes,ArraySize(cAPattern.actionPattern.matchingTimes)+1,0);
         cAPattern.actionPattern.matchingTimes[ArraySize(cAPattern.actionPattern.matchingTimes)-1]= matchingDate;
         
         
         copyETSignal(cAPattern.compiledBarPatterns[ArraySize(cAPattern.compiledBarPatterns)-1].matchingSignals,cAPattern.actionPattern.matchingSignal);
        
       }
       else if(!onTime  && checkWhereConditions(cAPattern))
       {
         ArrayResize(cAPattern.actionPattern.matchingTimes,ArraySize(cAPattern.actionPattern.matchingTimes)+1,0);
         cAPattern.actionPattern.matchingTimes[ArraySize(cAPattern.actionPattern.matchingTimes)-1]= matchingDate;
         
         
         copyETSignal(cAPattern.compiledBarPatterns[ArraySize(cAPattern.compiledBarPatterns)-1].matchingSignals,cAPattern.actionPattern.matchingSignal);
       }
       
     }
   }
   
   //Print(ArraySize(cAPattern.actionPattern.matchingTimes));
   
   for(int x=0;x < ArraySize(cAPattern.actionPattern.matchingTimes);x++)
   {
    Print("Match: "+cAPattern.actionPattern.matchingTimes[x]); 
   }
   
   /*while(signalIndex < ArraySize(cSignals))
   {
       condition = startCheckCondition(cAPattern.compiledBarPatterns[barIndex],cSignals[signalIndex]);
       
       if(condition)
       {
         if(barIndex < (ArraySize(cAPattern.compiledBarPatterns)-1))
            barIndex++;
         else
         { 
            if(cSignals[signalIndex].time == cSignals[ArraySize(cSignals)-1].time)
            {
              barIndex++;
              break;
            }
           
            barIndex=0;
         }
         
       }
       else
       {
         
         barIndex = 0;
         
       }
       
       signalIndex++;
       
       
   }
   
   //for(int i = 0; i < ArraySize(cSignals); i++)
   //{
   //  condition = startCheckCondition(cAPattern.compiledBarPatterns[barIndex],cSignals[signalIndex]);
   //}
   if(condition == true && barIndex == ArraySize(cAPattern.compiledBarPatterns))
     condition = true;
   else
     condition = false;*/   
    
  return condition;
}

bool rekursivePatternMatch(int signalIndex, int barIndex, ETSignal &signals[],CompiledActionPattern &cAPattern, datetime &matchingDate)
{
    //if(signalIndex == ArraySize(signals))
    
    //if( (ArraySize(signals) - signalIndex) < ArraySize(cAPattern.compiledBarPatterns))
     // return false;
    //Print(cAPattern.compiledBarPatterns[barIndex].wildcatMinOcc +"-"+cAPattern.compiledBarPatterns[barIndex].wildcatMaxOcc);
    
     bool condition = startCheckCondition(cAPattern.compiledBarPatterns[barIndex],signals[signalIndex]);
     
     if(condition == true)
     {
      matchingDate = signals[signalIndex].time;
      cAPattern.compiledBarPatterns[barIndex].occ+=1;
      
      ArrayResize(cAPattern.compiledBarPatterns[barIndex].matchingSignals,ArraySize(cAPattern.compiledBarPatterns[barIndex].matchingSignals)+1,0);
      //cAPattern.compiledBarPatterns[barIndex].matchingSignals[ArraySize(cAPattern.compiledBarPatterns[barIndex].matchingSignals)-1]= signals[signalIndex];
      copyETSignal(signals[signalIndex],cAPattern.compiledBarPatterns[barIndex].matchingSignals[ArraySize(cAPattern.compiledBarPatterns[barIndex].matchingSignals)-1]);
      // while(cAPattern.compiledBarPatterns[barIndex].occ < cAPattern.compiledBarPatterns[barIndex].wildcatMaxOcc)
      // {
       
      // }
      //if(cAPattern.compiledBarPatterns[barIndex].wildcats == "1")
      
        if(!(cAPattern.compiledBarPatterns[barIndex].occ < cAPattern.compiledBarPatterns[barIndex].wildcatMinOcc))
         barIndex++;  
     }
     else
     {
         if(barIndex > 0 
            && ((cAPattern.compiledBarPatterns[barIndex-1].wildcatMaxOcc > cAPattern.compiledBarPatterns[barIndex-1].occ) || cAPattern.compiledBarPatterns[barIndex-1].wildcatMaxOcc==0)
            && startCheckCondition(cAPattern.compiledBarPatterns[barIndex-1],signals[signalIndex])
            )
          {
             cAPattern.compiledBarPatterns[barIndex-1].occ+=1;
              ArrayResize(cAPattern.compiledBarPatterns[barIndex-1].matchingSignals,ArraySize(cAPattern.compiledBarPatterns[barIndex-1].matchingSignals)+1,0);
              copyETSignal(signals[signalIndex],cAPattern.compiledBarPatterns[barIndex-1].matchingSignals[ArraySize(cAPattern.compiledBarPatterns[barIndex-1].matchingSignals)-1]);
          }
          else
      //barIndex = 0;
      //condition = rekursivePatternMatch(signalIndex,barIndex,signals,cAPattern);
       return false;
     }
     
     signalIndex++;
     
     if(signalIndex < ArraySize(signals) && barIndex < ArraySize(cAPattern.compiledBarPatterns))
      condition = rekursivePatternMatch(signalIndex,barIndex,signals,cAPattern,matchingDate);
     else if(condition == true && barIndex != ArraySize(cAPattern.compiledBarPatterns))
      condition = false;
     
     return condition;
}

//Backup
/*bool rekursivePatternMatch(int signalIndex, int barIndex, ETSignal &signals[],CompiledActionPattern &cAPattern, datetime &matchingDate)
{
    //if(signalIndex == ArraySize(signals))
    
    //if( (ArraySize(signals) - signalIndex) < ArraySize(cAPattern.compiledBarPatterns))
     // return false;
    //Print(cAPattern.compiledBarPatterns[barIndex].wildcats);
    
     bool condition = startCheckCondition(cAPattern.compiledBarPatterns[barIndex],signals[signalIndex]);
     
     if(condition == true)
     {
      matchingDate = signals[signalIndex].time;
      barIndex++;  
     }
     else
     {
      //barIndex = 0;
      //condition = rekursivePatternMatch(signalIndex,barIndex,signals,cAPattern);
       return false;
     }
     
     signalIndex++;
     
     if(signalIndex < ArraySize(signals) && barIndex < ArraySize(cAPattern.compiledBarPatterns))
      condition = rekursivePatternMatch(signalIndex,barIndex,signals,cAPattern,matchingDate);
     else if(condition == true && barIndex != ArraySize(cAPattern.compiledBarPatterns))
      condition = false;
     
     return condition;
}*/


bool startCheckCondition(CompiledBarActionPattern &cBarPattern, ETSignal &cSignal)
{
  bool conditionArr[];
   
  //bool result = false;
   
  for(int i = 0; i < ArraySize(cBarPattern.compTerm);i++)
  {
      ArrayResize(conditionArr,ArraySize(conditionArr)+1,0);
     if(checkTerm(cBarPattern.compTerm[i],cSignal))
      conditionArr[ArraySize(conditionArr)-1]= true;
     else
       conditionArr[ArraySize(conditionArr)-1]= false; 
  }

    return evaluateOperators(conditionArr,cBarPattern.fOperators);
   
  return false;
}



bool checkTerm(CompiledTerm &term, ETSignal &signal)
{
  //while(int i = 0; term.flags
  //int index = 0;
  //bool condition = false;
  
  bool conditionArr[];
  
  for(int i = 0; i < ArraySize(term.flags);i++)
  {
      ArrayResize(conditionArr,ArraySize(conditionArr)+1,0);
      if(signal.sig_flags & term.flags[i])
      {
        conditionArr[ArraySize(conditionArr)-1]= true;
      }
      else
         conditionArr[ArraySize(conditionArr)-1]= false;
  }
     
    return evaluateOperators(conditionArr,term.fOperators);
   
}

bool evaluateOperators(bool &conditions[],FlagOperator &fOperators[])
{
  bool result = false;
  
  if(ArraySize(fOperators) == 0 && conditions[0] == true)
   return true;
  
  for(int i = 0; i < ArraySize(fOperators); i++)
  {
      
      if(fOperators[i] == OR && (conditions[i] == true || conditions[i+1] == true))
      {
      conditions[i+1]=true;
       result =true;
      }
      else  if(fOperators[i] == AND && (conditions[i] == true && conditions[i+1] == true))
      {
       conditions[i+1]=true;
       result = true;
       }
      else
      {
        conditions[i+1]=false;
        result = false;
      }

        
        if(result == false)
        return false;
   }
  
  
  return result;
}

bool checkWhereConditions(CompiledActionPattern &cAPattern)
{
   bool conditions[];
   
   for(int x=0; x < ArraySize(cAPattern.whereCondition); x++)
   {
       /*
       double op1[];
       int op1Int[];
       double op2[];
       int op2Int[];*/
       
       Operant op1[];
       Operant op2[];
       
       if(cAPattern.whereCondition[x].Operant1Typ == BAROPERANT )
       {
            for(int i =0; i < ArraySize(cAPattern.compiledBarPatterns[cAPattern.whereCondition[x].OperantBarIndex1].matchingSignals);i++)
            {
                  //getFuncValue(cAPattern.whereCondition[x].Operant1Func,cAPattern.whereCondition[x].Operant1FuncAttr,cAPattern.compiledBarPatterns[cAPattern.whereCondition[x].OperantBarIndex1].matchingSignals[i].metaInfo,op1,op1Int); 
                  getFuncValue(cAPattern.whereCondition[x].Operant1Func,cAPattern.whereCondition[x].Operant1FuncAttr,cAPattern.compiledBarPatterns[cAPattern.whereCondition[x].OperantBarIndex1].matchingSignals[i].metaInfo,op1); 
            }      
       } 
       
       if(cAPattern.whereCondition[x].Operant1Typ == FUNKTIONOPERANT)
       {
            for(int i =0; i < ArraySize(cAPattern.compiledBarPatterns[cAPattern.whereCondition[x].OperantBarIndex1].matchingSignals);i++)
            {
                  //getFuncValue(cAPattern.whereCondition[x].Operant1Func,cAPattern.whereCondition[x].Operant1FuncAttr,cAPattern.compiledBarPatterns[ArraySize(cAPattern.compiledBarPatterns)-1].matchingSignals[0].metaInfo,op1,op1Int); 
                  getFuncValue(cAPattern.whereCondition[x].Operant1Func,cAPattern.whereCondition[x].Operant1FuncAttr,cAPattern.compiledBarPatterns[ArraySize(cAPattern.compiledBarPatterns)-1].matchingSignals[0].metaInfo,op1); 
            }      
       } 

       if(cAPattern.whereCondition[x].Operant2Typ == BAROPERANT)
       {
            for(int i =0; i < ArraySize(cAPattern.compiledBarPatterns[cAPattern.whereCondition[x].OperantBarIndex2].matchingSignals);i++)
            {
                  //getFuncValue(cAPattern.whereCondition[x].Operant2Func,cAPattern.whereCondition[x].Operant2FuncAttr,cAPattern.compiledBarPatterns[cAPattern.whereCondition[x].OperantBarIndex2].matchingSignals[i].metaInfo,op2,op2Int); 
                  getFuncValue(cAPattern.whereCondition[x].Operant2Func,cAPattern.whereCondition[x].Operant2FuncAttr,cAPattern.compiledBarPatterns[cAPattern.whereCondition[x].OperantBarIndex2].matchingSignals[i].metaInfo,op2); 
            }      
       }
       
       if(cAPattern.whereCondition[x].Operant2Typ == FUNKTIONOPERANT)
       {
            for(int i =0; i < ArraySize(cAPattern.compiledBarPatterns[cAPattern.whereCondition[x].OperantBarIndex2].matchingSignals);i++)
            {
                  //getFuncValue(cAPattern.whereCondition[x].Operant2Func,cAPattern.whereCondition[x].Operant2FuncAttr,cAPattern.compiledBarPatterns[ArraySize(cAPattern.compiledBarPatterns)-1].matchingSignals[i].metaInfo,op2,op2Int); 
                  getFuncValue(cAPattern.whereCondition[x].Operant2Func,cAPattern.whereCondition[x].Operant2FuncAttr,cAPattern.compiledBarPatterns[ArraySize(cAPattern.compiledBarPatterns)-1].matchingSignals[i].metaInfo,op2); 
            }      
       }
       
       
       if(cAPattern.whereCondition[x].Operant1Typ == VALUEOPERANT)
       {
             ArrayResize(op1,1,0);
             op1[0].opDouble = cAPattern.whereCondition[x].Operant1Value;
       }
       
      if(cAPattern.whereCondition[x].Operant2Typ == VALUEOPERANT)
      {
           ArrayResize(op2,1,0);
           op2[0].opDouble = cAPattern.whereCondition[x].Operant2Value;
      }
       
       
       
      if(isWhereCondTrue(op1,op2,cAPattern.whereCondition[x].Operator))
      {
         ArrayResize(conditions,ArraySize(conditions)+1,0);
         conditions[ArraySize(conditions)-1]=true;
      }
      else
      {
         ArrayResize(conditions,ArraySize(conditions)+1,0);
         conditions[ArraySize(conditions)-1]=false;
      }
       
     
   }
   
   if(ArraySize(conditions)==0)
     return true;
   
   return evaluateOperators(conditions,cAPattern.whereCondOperator);
}

/*bool isWhereCondTrue(double &op1[], double &op2[], string Operator)
{
    bool condition = false;
    
      
          for(int i = 0; i < ArraySize(op1); i++)
          {
              for(int x = 0; x < ArraySize(op2); x++)
              {
                
                 if( Operator == "=")
                 {
                     if(op1[i]== op2[x])
                     {
                        
                        condition = true;
                        break;
                     }
                 }
                 if( Operator == "<")
                 {
                     if(op1[i]< op2[x])
                     {
                        condition = true;
                        break;
                     }
                 }
                 if( Operator == ">")
                 {
                     if(op1[i] > op2[x])
                     {
                        condition = true;
                        break;
                     }
                 }
                 
              }
              
              if(condition)
              break;
          }
      
      
      return condition;
}*/

bool isWhereCondTrue(Operant &op1[], Operant &op2[], string Operator)
{
    bool condition = false;
    
      
          for(int i = 0; i < ArraySize(op1); i++)
          {
              for(int x = 0; x < ArraySize(op2); x++)
              {
                
                 if( (Operator == "=" || Operator == "==") && (op1[i].isIntFlag == false && op2[x].isIntFlag == false) )
                 {
                     //Print("OP1: "+op1[i].isIntFlag+ "OP2: "+op2[x].isIntFlag);
                     if(op1[i].opDouble == op2[x].opDouble)
                     {
                        
                        condition = true;
                        break;
                     }
                 }
                 if((Operator == "=" || Operator == "==") && (op1[i].isIntFlag == true && op2[x].isIntFlag == true) )
                 {
                     
                     Print("OP1: "+op1[i].opInt+ "OP2: "+op2[x].opInt);
                     if(op1[i].opInt & op2[x].opInt)
                     {
                        condition = true;
                        break;
                     }
                 }
                 if( Operator == "<")
                 {
                     if(op1[i].opDouble< op2[x].opDouble)
                     {
                        condition = true;
                        break;
                     }
                 }
                 if( Operator == "<=" || Operator == "=<")
                 {
                     if(op1[i].opDouble <= op2[x].opDouble)
                     {
                        condition = true;
                        break;
                     }
                 }
               
                 if( Operator == ">")
                 {
                     if(op1[i].opDouble > op2[x].opDouble)
                     {
                        condition = true;
                        break;
                     }
                 }
                   if( Operator == ">=" || Operator == "=>")
                 {
                     if(op1[i].opDouble >= op2[x].opDouble)
                     {
                        condition = true;
                        break;
                     }
                 }
                 
                
          
              }
              
              if(condition)
              break;
          }
      
      
      return condition;
}

int getFuncValue(WhereOperantFunc &func,WhereOperantFuncAttribute &funcAtrr,MetaInfo &metaInfo,Operant &results[])
{
    
    ArrayFree(results);
    
   
    if(func == iRSI)
    {
       ArrayResize(results,1,0);
       results[0].opDouble = metaInfo.RSI;
       return 1;
    }
    else if(func == iCCI)
    {
       ArrayResize(results,1,0);
       results[0].opDouble = metaInfo.CCI;
       return 1;
    }
    else if(func == iSTOCH)
    {
       ArrayResize(results,1,0);
       results[0].opDouble = metaInfo.STOCH;
       return 1;
    }
    else if(func == iR1)
    {
       ArrayResize(results,1,0);
       results[0].isIntFlag=true;
       results[0].opInt |= R1;
       return 1;
    }
    else if(func == iR2)
    {
       ArrayResize(results,1,0);
       results[0].isIntFlag=true;
       results[0].opInt |= R2;
       return 1;
    }
    else if(func == iR3)
    {
       ArrayResize(results,1,0);
       results[0].isIntFlag=true;
       results[0].opInt |= R3;
       return 1;
    }
    else if(func == iRESISTANCE)
    {
       ArrayResize(results,1,0);
       results[0].isIntFlag=true;
       results[0].opInt |= RESISTANCE;
       return 1;
    }
    else if(func == iS1)
    {
       ArrayResize(results,1,0);
       results[0].isIntFlag=true;
       results[0].opInt |= S1;
       return 1;
    }
    else if(func == iS2)
    {
       ArrayResize(results,1,0);
       results[0].isIntFlag=true;
       results[0].opInt |= S2;
       return 1;
    }
    else if(func == iS3)
    {
       ArrayResize(results,1,0);
       results[0].isIntFlag=true;
       results[0].opInt |= S3;
       return 1;
    }
    else if(func == iSUPPORT)
    {
       ArrayResize(results,1,0);
       results[0].isIntFlag=true;
       results[0].opInt |= SUPPORT;
       return 1;
    }                    
    else if(func == iSIG_SR_BREAKTHROUGHBEARISH)
    {
      
         for(int x=0; x < ArraySize(metaInfo.iSIG_SR_BREAKTHROUGHBEARISH); x++)
         {
              if(funcAtrr == LOWBORDER)
              {
                 ArrayResize(results,ArraySize(results)+1,0);
                 results[ArraySize(results)-1].opDouble = metaInfo.iSIG_SR_BREAKTHROUGHBEARISH[x].LowBorder;
              }
              else if(funcAtrr == HIGHBORDER)
              {
                 ArrayResize(results,ArraySize(results)+1,0);
                 results[ArraySize(results)-1].opDouble = metaInfo.iSIG_SR_BREAKTHROUGHBEARISH[x].HighBorder;
              }
               else if(funcAtrr == TYPE)
              {
                 ArrayResize(results,ArraySize(results)+1,0);
                 results[ArraySize(results)-1].isIntFlag=true;
                 results[ArraySize(results)-1].opInt = metaInfo.iSIG_SR_BREAKTHROUGHBEARISH[x].SRType;
              }
              else if(funcAtrr == NONE)
              {
                 ArrayResize(results,ArraySize(results)+2,0);
                 results[ArraySize(results)-1].opDouble = metaInfo.iSIG_SR_BREAKTHROUGHBEARISH[x].HighBorder;
                 results[ArraySize(results)-2].opDouble = metaInfo.iSIG_SR_BREAKTHROUGHBEARISH[x].LowBorder;
              }
         }
       
      
       return 1;
    }  
    else if(func == iSIG_SR_BREAKTHROUGHBULLISH)
    {
      
         for(int x=0; x < ArraySize(metaInfo.iSIG_SR_BREAKTHROUGHBULLISH); x++)
         {
              if(funcAtrr == LOWBORDER)
              {
                 ArrayResize(results,ArraySize(results)+1,0);
                 results[ArraySize(results)-1].opDouble = metaInfo.iSIG_SR_BREAKTHROUGHBULLISH[x].LowBorder;
              }
              else if(funcAtrr == HIGHBORDER)
              {
                 ArrayResize(results,ArraySize(results)+1,0);
                 results[ArraySize(results)-1].opDouble = metaInfo.iSIG_SR_BREAKTHROUGHBULLISH[x].HighBorder;
              }
              else if(funcAtrr == TYPE)
              {
                 ArrayResize(results,ArraySize(results)+1,0);
                 results[ArraySize(results)-1].isIntFlag=true;
                 results[ArraySize(results)-1].opInt = metaInfo.iSIG_SR_BREAKTHROUGHBULLISH[x].SRType;
              }
              else if(funcAtrr == NONE)
              {
                 ArrayResize(results,ArraySize(results)+2,0);
                 results[ArraySize(results)-1].opDouble = metaInfo.iSIG_SR_BREAKTHROUGHBULLISH[x].HighBorder;
                 results[ArraySize(results)-2].opDouble = metaInfo.iSIG_SR_BREAKTHROUGHBULLISH[x].LowBorder;
              }
         }
            
       return 1;
    }    
    else if(func == iSIG_SR_TOUCHLOWERBOUNDERY)
    {
         for(int x=0; x < ArraySize(metaInfo. iSIG_SR_TOUCHLOWERBOUNDERY); x++)
         {
              if(funcAtrr == LOWBORDER)
              {
                 ArrayResize(results,ArraySize(results)+1,0);
                 results[ArraySize(results)-1].opDouble = metaInfo. iSIG_SR_TOUCHLOWERBOUNDERY[x].LowBorder;
              }
              else if(funcAtrr == HIGHBORDER)
              {
                 ArrayResize(results,ArraySize(results)+1,0);
                 results[ArraySize(results)-1].opDouble = metaInfo. iSIG_SR_TOUCHLOWERBOUNDERY[x].HighBorder;
              }
              else if(funcAtrr == TYPE)
              {
                 ArrayResize(results,ArraySize(results)+1,0);
                 results[ArraySize(results)-1].isIntFlag=true;
                 results[ArraySize(results)-1].opInt = metaInfo.iSIG_SR_TOUCHLOWERBOUNDERY[x].SRType;
              }
              else if(funcAtrr == NONE)
              {
                 ArrayResize(results,ArraySize(results)+2,0);
                 results[ArraySize(results)-1].opDouble = metaInfo.iSIG_SR_TOUCHLOWERBOUNDERY[x].HighBorder;
                 results[ArraySize(results)-2].opDouble = metaInfo.iSIG_SR_TOUCHLOWERBOUNDERY[x].LowBorder;
              }
         }
       return 1;
    }
    else if(func == iSIG_SR_TOUCHHIGHERBOUNDERY)
    {
         for(int x=0; x < ArraySize(metaInfo. iSIG_SR_TOUCHHIGHERBOUNDERY); x++)
         {
              if(funcAtrr == LOWBORDER)
              {
                 ArrayResize(results,ArraySize(results)+1,0);
                 results[ArraySize(results)-1].opDouble = metaInfo. iSIG_SR_TOUCHHIGHERBOUNDERY[x].LowBorder;
              }
              else if(funcAtrr == HIGHBORDER)
              {
                 ArrayResize(results,ArraySize(results)+1,0);
                 results[ArraySize(results)-1].opDouble = metaInfo. iSIG_SR_TOUCHHIGHERBOUNDERY[x].HighBorder;
              }
              else if(funcAtrr == TYPE)
              {
                 ArrayResize(results,ArraySize(results)+1,0);
                 results[ArraySize(results)-1].isIntFlag=true;
                 results[ArraySize(results)-1].opInt = metaInfo.iSIG_SR_TOUCHHIGHERBOUNDERY[x].SRType;
              }
              else if(funcAtrr == NONE)
              {
                 ArrayResize(results,ArraySize(results)+2,0);
                 results[ArraySize(results)-1].opDouble = metaInfo.iSIG_SR_TOUCHHIGHERBOUNDERY[x].HighBorder;
                 results[ArraySize(results)-2].opDouble = metaInfo.iSIG_SR_TOUCHHIGHERBOUNDERY[x].LowBorder;
              }
         }
       return 1;
    }
  
    
    
    return -1;       
}


/*int getFuncValue(WhereOperantFunc &func,WhereOperantFuncAttribute &funcAtrr,MetaInfo &metaInfo,double &results[], int &resultsInt[])
{
    
    ArrayFree(results);

    if(func == iRSI)
    {
       ArrayResize(results,1,0);
       results[0] = metaInfo.RSI;
       return 1;
    }
    else if(func == iCCI)
    {
       ArrayResize(results,1,0);
       results[0] = metaInfo.CCI;
       return 1;
    }
    else if(func == iSTOCH)
    {
       ArrayResize(results,1,0);
       results[0] = metaInfo.STOCH;
       return 1;
    }     
    else if(func == iSIG_SR_BREAKTHROUGHBEARISH)
    {
      
         for(int x=0; x < ArraySize(metaInfo.iSIG_SR_BREAKTHROUGHBEARISH); x++)
         {
              if(funcAtrr == LOWBORDER)
              {
                 ArrayResize(results,ArraySize(results)+1,0);
                 results[ArraySize(results)-1] = metaInfo.iSIG_SR_BREAKTHROUGHBEARISH[x].LowBorder;
              }
              else if(funcAtrr == HIGHBORDER)
              {
                 ArrayResize(results,ArraySize(results)+1,0);
                 results[ArraySize(results)-1] = metaInfo.iSIG_SR_BREAKTHROUGHBEARISH[x].HighBorder;
              }
               else if(funcAtrr == TYPE)
              {
                 ArrayResize(resultsInt,ArraySize(resultsInt)+1,0);
                 resultsInt[ArraySize(resultsInt)-1] = metaInfo.iSIG_SR_BREAKTHROUGHBEARISH[x].SRType;
              }
              else if(funcAtrr == NONE)
              {
                 ArrayResize(results,ArraySize(results)+2,0);
                 results[ArraySize(results)-1] = metaInfo.iSIG_SR_BREAKTHROUGHBEARISH[x].HighBorder;
                 results[ArraySize(results)-2] = metaInfo.iSIG_SR_BREAKTHROUGHBEARISH[x].LowBorder;
              }
         }
       
      
       return 1;
    }  
    else if(func == iSIG_SR_BREAKTHROUGHBULLISH)
    {
      
         for(int x=0; x < ArraySize(metaInfo.iSIG_SR_BREAKTHROUGHBULLISH); x++)
         {
              if(funcAtrr == LOWBORDER)
              {
                 ArrayResize(results,ArraySize(results)+1,0);
                 results[ArraySize(results)-1] = metaInfo.iSIG_SR_BREAKTHROUGHBULLISH[x].LowBorder;
              }
              else if(funcAtrr == HIGHBORDER)
              {
                 ArrayResize(results,ArraySize(results)+1,0);
                 results[ArraySize(results)-1] = metaInfo.iSIG_SR_BREAKTHROUGHBULLISH[x].HighBorder;
              }
              else if(funcAtrr == TYPE)
              {
                 ArrayResize(resultsInt,ArraySize(resultsInt)+1,0);
                 resultsInt[ArraySize(resultsInt)-1] = metaInfo.iSIG_SR_BREAKTHROUGHBULLISH[x].SRType;
              }
              else if(funcAtrr == NONE)
              {
                 ArrayResize(results,ArraySize(results)+2,0);
                 results[ArraySize(results)-1] = metaInfo.iSIG_SR_BREAKTHROUGHBULLISH[x].HighBorder;
                 results[ArraySize(results)-2] = metaInfo.iSIG_SR_BREAKTHROUGHBULLISH[x].LowBorder;
              }
         }
            
       return 1;
    }    
    else if(func == iSIG_SR_TOUCHLOWERBOUNDERY)
    {
         for(int x=0; x < ArraySize(metaInfo. iSIG_SR_TOUCHLOWERBOUNDERY); x++)
         {
              if(funcAtrr == LOWBORDER)
              {
                 ArrayResize(results,ArraySize(results)+1,0);
                 results[ArraySize(results)-1] = metaInfo. iSIG_SR_TOUCHLOWERBOUNDERY[x].LowBorder;
              }
              else if(funcAtrr == HIGHBORDER)
              {
                 ArrayResize(results,ArraySize(results)+1,0);
                 results[ArraySize(results)-1] = metaInfo. iSIG_SR_TOUCHLOWERBOUNDERY[x].HighBorder;
              }
              else if(funcAtrr == TYPE)
              {
                 ArrayResize(resultsInt,ArraySize(resultsInt)+1,0);
                 resultsInt[ArraySize(resultsInt)-1] = metaInfo.iSIG_SR_TOUCHLOWERBOUNDERY[x].SRType;
              }
              else if(funcAtrr == NONE)
              {
                 ArrayResize(results,ArraySize(results)+2,0);
                 results[ArraySize(results)-1] = metaInfo.iSIG_SR_TOUCHLOWERBOUNDERY[x].HighBorder;
                 results[ArraySize(results)-2] = metaInfo.iSIG_SR_TOUCHLOWERBOUNDERY[x].LowBorder;
              }
         }
       return 1;
    }
    else if(func == iSIG_SR_TOUCHHIGHERBOUNDERY)
    {
         for(int x=0; x < ArraySize(metaInfo. iSIG_SR_TOUCHHIGHERBOUNDERY); x++)
         {
              if(funcAtrr == LOWBORDER)
              {
                 ArrayResize(results,ArraySize(results)+1,0);
                 results[ArraySize(results)-1] = metaInfo. iSIG_SR_TOUCHHIGHERBOUNDERY[x].LowBorder;
              }
              else if(funcAtrr == HIGHBORDER)
              {
                 ArrayResize(results,ArraySize(results)+1,0);
                 results[ArraySize(results)-1] = metaInfo. iSIG_SR_TOUCHHIGHERBOUNDERY[x].HighBorder;
              }
              else if(funcAtrr == TYPE)
              {
                 ArrayResize(resultsInt,ArraySize(resultsInt)+1,0);
                 resultsInt[ArraySize(resultsInt)-1] = metaInfo.iSIG_SR_TOUCHHIGHERBOUNDERY[x].SRType;
              }
              else if(funcAtrr == NONE)
              {
                 ArrayResize(results,ArraySize(results)+2,0);
                 results[ArraySize(results)-1] = metaInfo.iSIG_SR_TOUCHHIGHERBOUNDERY[x].HighBorder;
                 results[ArraySize(results)-2] = metaInfo.iSIG_SR_TOUCHHIGHERBOUNDERY[x].LowBorder;
              }
         }
       return 1;
    }
    else if(func==iSR_R1)
    {
    
    }
    
    
    return -1;       
}*/



//bool checkBarWhereCond(WhereCondition &wCond, cAPattern)