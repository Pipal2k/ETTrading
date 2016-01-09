//+------------------------------------------------------------------+
//|                                              ETActionPattern.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include <ETrading/ETDataTypes.mqh>




//"[{SIG_BARBEARISH | SIG_SR_BREAKTHROUGHBEARISH} & { SIG_SR_BREAKTHROUGHBULLISH & SIG_BARBEARISH}] [SIG_SR_BREAKTHROUGHBEARISH]";




//InternalActionPattern intActionPattern[];

void parseActionExpression(ActionPattern &patterns[],CompiledActionPattern &intActionPattern[])
{
   for(int i =0; i < ArraySize(patterns); i++)
   {
      ArrayResize(intActionPattern,ArraySize(intActionPattern)+1,0);
      copyActionPattern(intActionPattern[ArraySize(intActionPattern)-1].actionPattern,patterns[i]);
      parseActionExpression(patterns[i].Expression,intActionPattern[ArraySize(intActionPattern)-1]);
   }
}


void parseActionExpression(string expression,CompiledActionPattern &intActionPattern)
{ 

  //int index,index2;
  uchar exp_chars[];
   
  expression=StringTrimRight(StringTrimLeft(expression));
  StringToCharArray(expression,exp_chars,0,WHOLE_ARRAY,CP_ACP);
  

  if(ArraySize(exp_chars)> 0)
  {
      BeginBar(exp_chars,intActionPattern,0);  
  }
  
  for(int i = 0; i < ArraySize(intActionPattern.ExpPerBar);i++)
  {
      ArrayResize(intActionPattern.compiledBarPatterns,ArraySize(intActionPattern.compiledBarPatterns)+1,0);
      if(startCompilingBar(intActionPattern.ExpPerBar[i],intActionPattern.compiledBarPatterns[i]) == -1)
      break;
      //GetCompiledBarPattern();
  }
  
  for(int x=0; x< ArraySize(intActionPattern.compiledBarPatterns);x++)
  {
     if(startReadFlags(intActionPattern.compiledBarPatterns[x])==-1)
     break;
  }
  
  parseWhereCondition(intActionPattern);
  //Print(intActionPattern.WhereConditionStr);
  
  //Print(intActionPattern.ExpPerBar[0]);
  //Print(intActionPattern.ExpPerBar[1]);
  
  return;
}

void parseWhereCondition(CompiledActionPattern &intActionPattern)
{
  if(StringLen(intActionPattern.WhereConditionStr) > 0)
  {
     int index = 0;
     uchar charBuffer[];
     uchar exp_chars[];
     string whereTermStr[]; 
      
     StringToCharArray(intActionPattern.WhereConditionStr,exp_chars,0,WHOLE_ARRAY,CP_ACP);
    
     
     while(index < ArraySize(exp_chars) )
     {
       ArrayResize(charBuffer,ArraySize(charBuffer)+1,0);
       charBuffer[ArraySize(charBuffer)-1]=exp_chars[index];
       
       if((exp_chars[index] == '&' || exp_chars[index] == '|') ||  exp_chars[index] == 0)
       {
           
           ArrayResize(whereTermStr, ArraySize(whereTermStr)+1,0);
           whereTermStr[ArraySize(whereTermStr)-1]= StringTrimRight(StringTrimLeft(CharArrayToString(charBuffer,0,ArraySize(charBuffer)-1,CP_ACP)));
           //Print(whereTermStr[ArraySize(whereTermStr)-1]);
           ArrayFree(charBuffer); 
                 
           if(exp_chars[index]=='&' && exp_chars[index+1] == '&')
           {
             
             ArrayResize(intActionPattern.whereCondOperator,ArraySize(intActionPattern.whereCondOperator)+1,0);
             intActionPattern.whereCondOperator[ArraySize(intActionPattern.whereCondOperator)-1]=AND;
             index++;
             index++;
           }
           else if(exp_chars[index]=='|' && exp_chars[index+1] == '|')
           {
             ArrayResize(intActionPattern.whereCondOperator,ArraySize(intActionPattern.whereCondOperator)+1,0);
             intActionPattern.whereCondOperator[ArraySize(intActionPattern.whereCondOperator)-1]=OR;
             index++;
             index++;
           }
                    
       }
       
       
      
          
       index++;
           
     }
     
     
     for(int x = 0; x < ArraySize(whereTermStr);x++)
     {
        index = 0;
        ArrayFree(exp_chars);
        StringToCharArray(whereTermStr[x],exp_chars,0,WHOLE_ARRAY,CP_ACP);
        
        ArrayResize(intActionPattern.whereCondition,ArraySize(intActionPattern.whereCondition)+1,0);
        
        parseWhereTerm(exp_chars,index,intActionPattern.whereCondition[ArraySize(intActionPattern.whereCondition)-1],1);
        
       // WhereCondition tmp1 = intActionPattern.whereCondition[ArraySize(intActionPattern.whereCondition)-1];
        
       
        
     }
     
  }
}

void parseWhereStr()
{

}

void parseWhereTerm(uchar &exp_chars[], int index, WhereCondition &wCond, int OperantCount)
{
    
    if(index >= ArraySize(exp_chars))
      return;
    
    while(exp_chars[index] == ' ')
      index++;
       
    
     if(exp_chars[index] == '[')
     {
          parseBarWhereOperant(exp_chars,index+1,wCond,OperantCount);
     }
     else if(exp_chars[index] == '<' || exp_chars[index]=='=' || exp_chars[index]=='>' || exp_chars[index]=='!')
     {
       wCond.Operator += CharArrayToString(exp_chars,index,1,CP_ACP);
       parseWhereTerm(exp_chars,index+1,wCond,OperantCount); 
     }
     else if(charIsNumber(exp_chars[index]))
     {
       parseValueWhereOperant(exp_chars,index,wCond,OperantCount);
     }
     else 
     {
         parseFuncWhereOperant(exp_chars,index,wCond,OperantCount);
         //wCond.Operator += CharArrayToString(exp_chars,index,1,CP_ACP);
         //parseWhereTerm(exp_chars,index+1,wCond,OperantCount); 
     }
}

void parseValueWhereOperant(uchar &exp_chars[], int index,WhereCondition &wCond,int OperantCount)
{
   uchar charBuffer[];
   //uchar charBuffer2[];
   ArrayFree(charBuffer);
   
   
   while(index < ArraySize(exp_chars) && exp_chars[index] != ' ' && exp_chars[index] != '<' && exp_chars[index]!='=' && exp_chars[index]!='>' && exp_chars[index]!='!' )
   {
      ArrayResize(charBuffer,ArraySize(charBuffer)+1,0);
      charBuffer[ArraySize(charBuffer)-1]=exp_chars[index];
      index++;
   }
   
  // ArrayResize(charBuffer,ArraySize(charBuffer)+1,0);
   //   charBuffer[ArraySize(charBuffer)-1]='0';
 //  ArrayCopy(charBuffer2,charBuffer,0,0,ArraySize(charBuffer));
   
   string tmpValue =  CharArrayToString(charBuffer,0,WHOLE_ARRAY,CP_ACP);
   
   
   double value = StringToDouble(tmpValue);
   
      
   if(OperantCount == 1)
   {
     wCond.Operant1Typ = VALUEOPERANT;
      wCond.Operant1Value = value;   
   }
   else
   {
      wCond.Operant2Typ = VALUEOPERANT;
      wCond.Operant2Value=value;
      }
   
    parseWhereTerm(exp_chars,index+1,wCond,OperantCount+1); 
}


bool charIsNumber(uchar charN)
{
  if(charN == '0' || charN == '1' || charN == '2' || charN == '3' || charN == '4' || charN == '5' || charN == '6' || charN == '7' || charN == '8' || charN == '9')
   return true;
  else
   return false;
 
}

void parseFuncWhereOperant(uchar &exp_chars[], int index,WhereCondition &wCond,int OperantCount)
{
   uchar charBuffer[];
   int OperantIndex;
   
   while(exp_chars[index] != ' ' && exp_chars[index] != '<' && exp_chars[index]!='=' && exp_chars[index]!='>' && exp_chars[index]!='!' )
   {
      ArrayResize(charBuffer,ArraySize(charBuffer)+1,0);
      charBuffer[ArraySize(charBuffer)-1]=exp_chars[index];
      index++;
   }
   
   if(exp_chars[index] == 0)
   {
      SetUserError(1);
         return;
   }
   
   string tmpFunc =  StringTrimRight(StringTrimLeft(CharArrayToString(charBuffer,0,WHOLE_ARRAY,CP_ACP)));
    StringToUpper(tmpFunc);
    
   if(OperantCount == 1)
   {
      wCond.Operant1Typ = FUNKTIONOPERANT;
      //wCond.OperantBarIndex1 = StringToInteger(StringTrimRight(StringTrimLeft(CharArrayToString(charBuffer,0,WHOLE_ARRAY,CP_ACP))))-1;
      //parseOperantFunc(exp_chars,index,wCond,OperantCount);
      mapOperantFunc(tmpFunc,wCond.Operant1Func,wCond.Operant1FuncAttr);
   }
   else
   {
      wCond.Operant2Typ = FUNKTIONOPERANT;
      //wCond.OperantBarIndex2 = StringToInteger(StringTrimRight(StringTrimLeft(CharArrayToString(charBuffer,0,WHOLE_ARRAY,CP_ACP))))-1;
      mapOperantFunc(tmpFunc,wCond.Operant2Func,wCond.Operant2FuncAttr);
     // parseOperantFunc(exp_chars,index,wCond,OperantCount);
   }
   
    parseWhereTerm(exp_chars,index+1,wCond,OperantCount+1); 
}

void parseBarWhereOperant(uchar &exp_chars[], int index,WhereCondition &wCond,int OperantCount)
{
   uchar charBuffer[];
   int OperantIndex;
   
   while(exp_chars[index] != ']')
   {
      ArrayResize(charBuffer,ArraySize(charBuffer)+1,0);
      charBuffer[ArraySize(charBuffer)-1]=exp_chars[index];
      index++;
   }
   
   if(exp_chars[index] == 0)
   {
      SetUserError(1);
         return;
   }
   
   if(OperantCount == 1)
   {
      wCond.Operant1Typ = BAROPERANT;
      wCond.OperantBarIndex1 = StringToInteger(StringTrimRight(StringTrimLeft(CharArrayToString(charBuffer,0,WHOLE_ARRAY,CP_ACP))))-1;
      parseOperantFunc(exp_chars,index,wCond,OperantCount);
   }
   else
   {
      wCond.Operant2Typ = BAROPERANT;
      wCond.OperantBarIndex2 = StringToInteger(StringTrimRight(StringTrimLeft(CharArrayToString(charBuffer,0,WHOLE_ARRAY,CP_ACP))))-1;
      parseOperantFunc(exp_chars,index,wCond,OperantCount);
   }
   
  // parseWhereTerm(exp_chars,index+1,wCond,OperantCount+1);
}

void parseOperantFunc(uchar &exp_chars[], int index,WhereCondition &wCond,int OperantCount)
{
   uchar charBuffer[];
   
   while(exp_chars[index] != '.')
      index++;
      
    index++;
    
    while(exp_chars[index] != ' ' && exp_chars[index] != '<' && exp_chars[index] != '>' && exp_chars[index] != '=' && exp_chars[index] != 0)
    {
      ArrayResize(charBuffer,ArraySize(charBuffer)+1,0);
      charBuffer[ArraySize(charBuffer)-1]=exp_chars[index];
      index++;
    }   
    
    string tmpFunc =  StringTrimRight(StringTrimLeft(CharArrayToString(charBuffer,0,WHOLE_ARRAY,CP_ACP)));
    StringToUpper(tmpFunc);
    if(OperantCount==1)
         mapOperantFunc(tmpFunc,wCond.Operant1Func,wCond.Operant1FuncAttr);
    else
         mapOperantFunc(tmpFunc,wCond.Operant2Func,wCond.Operant2FuncAttr);
      
     parseWhereTerm(exp_chars,index+1,wCond,OperantCount+1); 
}

void mapOperantFunc(string funcStr, WhereOperantFunc &func, WhereOperantFuncAttribute &funcAttr)
{
    
   string splitted[];
   string sep=".";                // A separator as a character
   ushort u_sep;
   u_sep=StringGetCharacter(sep,0);
   int k = StringSplit(funcStr,u_sep,splitted);
   
   funcStr = splitted[0];
   if(funcStr == "RSI")
     func = RSI;
   else if(funcStr == "CCI")
     func = RSI;
   else if(funcStr == "STOCH")
     func = STOCH;  
   else if(funcStr == "SIG_SR_BREAKTHROUGHBULLISH")
     func = iSIG_SR_BREAKTHROUGHBULLISH;  
   else if(funcStr == "SIG_SR_BREAKTHROUGHBEARISH")
     func = iSIG_SR_BREAKTHROUGHBEARISH;  
   else if(funcStr == "SIG_SR_TOUCHHIGHERBOUNDERY")
     func = iSIG_SR_TOUCHHIGHERBOUNDERY;
   else if(funcStr == "SIG_SR_TOUCHLOWERBOUNDERY")
     func = iSIG_SR_TOUCHLOWERBOUNDERY;
          
      if(k==2)
        mapOperantFuncAttribute(splitted[1],funcAttr);
     else
        mapOperantFuncAttribute("NONE",funcAttr);      
}

void mapOperantFuncAttribute(string funcAttrStr, WhereOperantFuncAttribute &funcAttr)
{
    

   if(funcAttrStr == "HIGHBORDER" || funcAttrStr == "HIGH")
     funcAttr = HIGHBORDER;
   if(funcAttrStr == "LOWBORDER" || funcAttrStr == "LOW")
     funcAttr = LOWBORDER;  
   else 
     funcAttr =NONE;
}

void BeginBar(uchar &exp_chars[],CompiledActionPattern &intActionPattern,int index)
{
   if(index < ArraySize(exp_chars)-1)
   {
      while(exp_chars[index] ==' ')
       index++;
       
      if(exp_chars[index] == '[')
      {
         ArrayResize(intActionPattern.ExpPerBar,ArraySize(intActionPattern.ExpPerBar)+1,0);
         readBarContent(exp_chars,intActionPattern,index+1);
      }
      else if(exp_chars[index] == 'W')
      {
         readWehreContent(exp_chars,intActionPattern,index);
      }
      else
      {
         SetUserError(1);
         return;
      }
   }
   else
      return;
}

void readBarContent(uchar &exp_chars[],CompiledActionPattern &intActionPattern,int index)
{
   uchar charBuffer[];
   
   uchar c =exp_chars[index];
  
   while(exp_chars[index] != ']')
   {
     ArrayResize(charBuffer,ArraySize(charBuffer)+1,0);
     charBuffer[ArraySize(charBuffer)-1]=exp_chars[index];
     index++;
   
     //c=exp_chars[index];
   }

    intActionPattern.ExpPerBar[ArraySize(intActionPattern.ExpPerBar)-1]= CharArrayToString(charBuffer,0,WHOLE_ARRAY,CP_ACP);
    BeginBar(exp_chars,intActionPattern,index+1);
}

void readWehreContent(uchar &exp_chars[],CompiledActionPattern &intActionPattern,int index)
{
   uchar charBuffer[];
   
   uchar c =exp_chars[index];
  
    while(exp_chars[index] != ' ')
       index++; 
  
   while(exp_chars[index] != 0)
   {
     ArrayResize(charBuffer,ArraySize(charBuffer)+1,0);
     charBuffer[ArraySize(charBuffer)-1]=exp_chars[index];
     index++;
     //c=exp_chars[index];
   }
   
   intActionPattern.WhereConditionStr=StringTrimRight(StringTrimLeft(CharArrayToString(charBuffer,0,WHOLE_ARRAY,CP_ACP)));
   
   //string whereClausel = StringTrimRight(StringTrimLeft(CharArrayToString(charBuffer,0,WHOLE_ARRAY,CP_ACP)));
   //Print(whereClausel);

}

int startCompilingBar(string ExpressionBar,CompiledBarActionPattern &compiledBarPatterns)
{
  uchar exp_chars[];
  int index = 0;
   
   
  ExpressionBar=StringTrimRight(StringTrimLeft(ExpressionBar));
  StringToCharArray(ExpressionBar,exp_chars,0,WHOLE_ARRAY,CP_ACP);
  
  uchar charBuffer[];
    //uchar charBuffer[];
   //ArrayResize(compiledBarPatterns.wildcats,ArraySize(compiledBarPatterns.wildcats)+1,0);   
   if(exp_chars[index] == '(')
   {
      //readWildcats(exp_chars,index+1,term.wildcats[ArraySize(term.wildcats)-1]);
      index++;
      while(exp_chars[index] != ')')
      {
            ArrayResize(charBuffer,ArraySize(charBuffer)+1,0);
            charBuffer[ArraySize(charBuffer)-1]=exp_chars[index];
            index++;   
      }  
      
      string wildcat = StringTrimRight(StringTrimLeft(CharArrayToString(charBuffer,0,WHOLE_ARRAY,CP_ACP)));
      
      int index2 =0;
      
      while(charBuffer[index2] !=0)
      {
         if(charBuffer[index2] == '*')
         {
            compiledBarPatterns.wildcatMinOcc=0;
            compiledBarPatterns.wildcatMaxOcc=0;
            break;
         }
         else if(charBuffer[index2] == '^')
         {
            compiledBarPatterns.wildcatMinOcc=1;
            compiledBarPatterns.wildcatMaxOcc=0;
            break;
         }
         else
         {
            string splitted[];
            string sep="-";                // A separator as a character
            ushort u_sep;
            u_sep=StringGetCharacter(sep,0);
            //string wildcat = StringTrimRight(StringTrimLeft(CharArrayToString(charBuffer,0,WHOLE_ARRAY,CP_ACP)));
            int k = StringSplit(wildcat,u_sep,splitted);
            
            if(k > 2 || k < 1)
            {
              SetUserError(1);
              return -1;
            }
            else
            { 
              if(k==2)
              {
               compiledBarPatterns.wildcatMinOcc=StrToInteger(splitted[0]);
               compiledBarPatterns.wildcatMaxOcc=StrToInteger(splitted[1]);
              }
              else if(k==1)
              {
               compiledBarPatterns.wildcatMinOcc=StrToInteger(splitted[0]);
               compiledBarPatterns.wildcatMaxOcc=StrToInteger(splitted[0]);
              }
              
            }
           
            
            break;
         }
         
         index2++;
      }
      //compiledBarPatterns.wildcats=StringTrimRight(StringTrimLeft(CharArrayToString(charBuffer,0,WHOLE_ARRAY,CP_ACP)));
      
      ArrayFree(charBuffer);
      index++;
   }
   else
   {
      compiledBarPatterns.wildcatMinOcc=1;
      compiledBarPatterns.wildcatMaxOcc=1;
   } 
  
   
   if(readTermBegin(exp_chars,index,compiledBarPatterns)==-1)
   {
     SetUserError(1);
     return -1;
   }


   
   return 1;
}

int readTermBegin(uchar &exp_chars[], int index, CompiledBarActionPattern &compiledBarPatterns)
{

   //if(index >=ArraySize(exp_chars))
   if(index >= ArraySize(exp_chars) || exp_chars[index]==0)
      return 1;
      
   while(exp_chars[index] ==' ')
      index++;
      
   if(exp_chars[index] == '{')
   {
      ArrayResize(compiledBarPatterns.compTerm,ArraySize(compiledBarPatterns.compTerm)+1,0);
      if(readNewTerm(exp_chars,index+1,compiledBarPatterns.compTerm[ArraySize(compiledBarPatterns.compTerm)-1],compiledBarPatterns,false) == -1)
      return -1;
   }
   else if(exp_chars[index] == 'S' || exp_chars[index]=='(')
   {
     ArrayResize(compiledBarPatterns.compTerm,ArraySize(compiledBarPatterns.compTerm)+1,0);
      if(readNewTerm(exp_chars,index,compiledBarPatterns.compTerm[ArraySize(compiledBarPatterns.compTerm)-1],compiledBarPatterns,true) == -1)
      return -1;
   }
   else if(exp_chars[index]=='&' && index !=0)
   {
      ArrayResize(compiledBarPatterns.fOperators,ArraySize(compiledBarPatterns.fOperators)+1,0);
      compiledBarPatterns.fOperators[ArraySize(compiledBarPatterns.fOperators)-1]=AND;
      readTermBegin(exp_chars,index+1,compiledBarPatterns);
   }
   else if(exp_chars[index]=='|' && index !=0)
   {
      ArrayResize(compiledBarPatterns.fOperators,ArraySize(compiledBarPatterns.fOperators)+1,0);
      compiledBarPatterns.fOperators[ArraySize(compiledBarPatterns.fOperators)-1]=OR;
      readTermBegin(exp_chars,index+1,compiledBarPatterns);
   }
   else
   {
      SetUserError(1);
     return -1;
   }
   
   return 1;
}



int readNewTerm(uchar &exp_chars[], int index, CompiledTerm &term,CompiledBarActionPattern &compiledBarPatterns, bool isSingleTerm)
{
  uchar charBuffer[];
   string flagS;
   int flag;
   
    while(exp_chars[index] ==' ')
      index++;
   
    
   
   if(exp_chars[index] == 'S')
   {
       
       
       if(!isSingleTerm)
       {
         while(exp_chars[index] != '}')
         {
               ArrayResize(charBuffer,ArraySize(charBuffer)+1,0);
               charBuffer[ArraySize(charBuffer)-1]=exp_chars[index];
               index++;   
         }
         
          term.sTerm=StringTrimRight(StringTrimLeft(CharArrayToString(charBuffer,0,WHOLE_ARRAY,CP_ACP)));
       } 
       else 
       {
         while( index < ArraySize(exp_chars) && exp_chars[index] != '|' && exp_chars[index] != '&')
         {
               ArrayResize(charBuffer,ArraySize(charBuffer)+1,0);
               charBuffer[ArraySize(charBuffer)-1]=exp_chars[index];
               index++;   
         }
         
          term.sTerm=StringTrimRight(StringTrimLeft(CharArrayToString(charBuffer,0,WHOLE_ARRAY,CP_ACP)));
       } 
       
       readTermBegin(exp_chars,index+1,compiledBarPatterns);
       
      
   }
   else
      return -1;
   
   return 1;
}

int startReadFlags(CompiledBarActionPattern &compiledBarPatterns)
{
   for(int i = 0; i< ArraySize(compiledBarPatterns.compTerm); i++)
   {
      uchar exp_chars[];
      int index = 0;
   
     compiledBarPatterns.compTerm[i].sTerm=StringTrimRight(StringTrimLeft(compiledBarPatterns.compTerm[i].sTerm));
     StringToCharArray(compiledBarPatterns.compTerm[i].sTerm,exp_chars,0,WHOLE_ARRAY,CP_ACP);
     readFlag(exp_chars,index,compiledBarPatterns.compTerm[i]);
 
     
   }
   
   return 1;
}

int readFlag(uchar &exp_chars[],int index,CompiledTerm &term)
{
   uchar charBuffer[];
   string flagS;
    
    if(index >= ArraySize(exp_chars))
     return 1;
    
    while(exp_chars[index] ==' ')
      index++;
     
     if(exp_chars[index]=='S')
     {
         while(index < ArraySize(exp_chars) && exp_chars[index] != '|' && exp_chars[index] != '&')
         {
            ArrayResize(charBuffer,ArraySize(charBuffer)+1,0);
            charBuffer[ArraySize(charBuffer)-1]=exp_chars[index];
            index++;   
         }
         
       flagS =StringTrimRight(StringTrimLeft(CharArrayToString(charBuffer,0,WHOLE_ARRAY,CP_ACP)));
       int flag = StringToBitFlag(flagS);
            
       if(flag == -1)
          return -1;
       
       ArrayResize(term.flags,ArraySize(term.flags)+1,0);
       term.flags[ArraySize(term.flags)-1]=flag;
       
       if(index < ArraySize(exp_chars))
       {
         if(exp_chars[index] == '|')
         {
             ArrayResize(term.fOperators,ArraySize(term.fOperators)+1,0);
            term.fOperators[ArraySize(term.fOperators)-1]=OR;
         }
         else if(exp_chars[index] == '&')
         {
             ArrayResize(term.fOperators,ArraySize(term.fOperators)+1,0);
            term.fOperators[ArraySize(term.fOperators)-1]=AND;
         }
        } 
       
       readFlag(exp_chars,index+1,term);
       
     }
     
     return 1;
}


int readWildcats(uchar &exp_chars[],int &index,string &wildCat)
{

  
return 1;
}



int StringToBitFlag(string flagS)
{
    if(flagS == "SIG_SR_BREAKTHROUGHBEARISH")
         return SIG_SR_BREAKTHROUGHBEARISH;
    else if(flagS == "SIG_SR_BREAKTHROUGHBULLISH")
         return SIG_SR_BREAKTHROUGHBULLISH;
    else if(flagS =="SIG_SR_TOUCHLOWERBOUNDERY")
         return SIG_SR_TOUCHLOWERBOUNDERY;
    else if(flagS == "SIG_SR_TOUCHHIGHERBOUNDERY")
         return SIG_SR_TOUCHHIGHERBOUNDERY;
    else if(flagS== "SIG_BEARISHCANDLESTICK")
         return SIG_BEARISHCANDLESTICK;
    else if(flagS== "SIG_BULLISHCADLESTICK")
         return SIG_BULLISHCADLESTICK;
    else if(flagS== "SIG_BARBULLISH")
         return SIG_BARBULLISH;
    else if(flagS== "SIG_BARBEARISH")
         return SIG_BARBEARISH;    
    else if(flagS== "SIG_SR_TOUCHBULLISH")
         return SIG_SR_TOUCHBULLISH;
    else if(flagS== "SIG_SR_TOUCHBEARISH")
         return SIG_SR_TOUCHBEARISH;
    else if(flagS== "SIG_ANY")
         return SIG_ANY;
                   
               
         
  return -1;            
}


