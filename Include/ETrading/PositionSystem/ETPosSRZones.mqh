//+------------------------------------------------------------------+
//|                                                 ETPosSRZones.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include  <ETrading/ETDataTypes.mqh>
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


void calcSRZonesTargets(double currentPrize,double ATR,SR_Zone &zones[], ETPosition &posit,bool useMidPivots)
{ 
  Print("ATR:"+ATR);
  ArrayFree(posit.targets);
   SR_Zone foundZones[];
   if(posit.pos == Sell)
   {
        startFindingSRZones(currentPrize,zones,foundZones,Sell,useMidPivots);
   }
   else if(posit.pos == Buy)
   {
       startFindingSRZones(currentPrize,zones,foundZones,Buy,useMidPivots);
   }
   
   double tmpTarget;
   for(int i = 0; i< ArraySize(foundZones)-1; i++)
   {
      Print("Target Zone "+i+": "+foundZones[i].LowBorder);
      
      if(posit.pos == Sell)
      {
         if(MathAbs(currentPrize-foundZones[i].HighBorder) < ATR)
           tmpTarget = currentPrize-(ATR+(20*Point));
         else
           tmpTarget = foundZones[i].HighBorder +(20*Point);
             
      }
      else if(posit.pos == Buy)
      {
         if(MathAbs(currentPrize-foundZones[i].LowBorder) < ATR)
           tmpTarget = currentPrize + (ATR-(20*Point));
         else
           tmpTarget = foundZones[i].LowBorder - (20*Point);
      }  
      
      ArrayResize(posit.targets,ArraySize(posit.targets)+1,0);
      posit.targets[ArraySize(posit.targets)-1]=tmpTarget;
   }
   
   if(ArraySize(foundZones) > 0)
   {
      if(posit.pos == Sell)
         posit.takeProfit = foundZones[ArraySize(foundZones)-1].HighBorder + (20*Point);
      else
         posit.takeProfit = foundZones[ArraySize(foundZones)-1].LowBorder - (20*Point);
   }
   else
   {
      if(posit.pos == Sell)
         posit.takeProfit = 1.5*ATR + (20*Point);
      else
         posit.takeProfit = 1.5*ATR - (20*Point);
   }
           
      
}

void calcSRZonesStopLoss(double currentPrize,double ATR,SR_Zone &zones[], ETPosition &posit,bool useMidPivots)
{

    Print("Use MidPivots: "+useMidPivots);
    SR_Zone foundZones[];
   if(posit.pos == Sell)
   {
        startFindingSRZones(currentPrize,zones,foundZones,Buy,useMidPivots);
   }
   else if(posit.pos == Buy)
   {
       startFindingSRZones(currentPrize,zones,foundZones,Sell,useMidPivots);
   }
   
   double tmpTarget;
    //Print("StopLoss Zone "+i+": "+foundZones[i].LowBorder);
   
   if(ArraySize(foundZones) > 0)
   {
      Print("StopLoss: "+foundZones[0].LowBorder);  
      int i =0;
      while(i < ArraySize(foundZones) && MathAbs(currentPrize-foundZones[i].LowBorder) < 2*ATR  )
      {
           i++; 
      }
      Print("i: "+i);  
      
          
      if(posit.pos == Sell && i < ArraySize(foundZones))
      {
          if(MathAbs(currentPrize-foundZones[i].LowBorder) < 2*ATR)
            tmpTarget = currentPrize+((2*ATR)+(20*Point));
         else
            tmpTarget = foundZones[i].LowBorder + (20*Point);
             
      }
      else if(posit.pos == Buy && i < ArraySize(foundZones))
      {
         if(MathAbs(currentPrize-foundZones[i].HighBorder) < 2*ATR)
            tmpTarget = currentPrize - ((2*ATR)-(20*Point));
         else
            tmpTarget = foundZones[i].HighBorder-(20*Point);
      }
      else
      {
            if(posit.pos == Sell)
            {
               tmpTarget = currentPrize+((2*ATR)+(20*Point));
            }
            else if(posit.pos == Buy)
            {
               tmpTarget = currentPrize - ((2*ATR)-(20*Point));
            }
      }
      
   }
   else
   {
      if(posit.pos == Sell)
      {
         tmpTarget = currentPrize+((3*ATR)+(20*Point));
      }
      else if(posit.pos == Buy)
      {
         tmpTarget = currentPrize - ((3*ATR)-(20*Point));
      }
   }
     

   posit.stopLoss = tmpTarget;
   posit.stopLossUnits = MathAbs(currentPrize-tmpTarget);
       
   
   
}

void startFindingSRZones(double prize,SR_Zone &zones[],SR_Zone &foundZones[],Position pos,bool useMidPivots)
{
    SR_Zone tmpZone;
    while(findNextSRZone(prize,tmpZone,zones,useMidPivots,pos))
    {
       ArrayResize(foundZones,ArraySize(foundZones)+1,0);
       copySRZones(tmpZone,foundZones[ArraySize(foundZones)-1]);
       
       if(pos == Sell)
         prize = tmpZone.LowBorder;
       else
         prize = tmpZone.HighBorder;  
       
       
    }
}




bool findNextSRZone(double prize,SR_Zone &nextZone,SR_Zone &zones[],bool useMidPivots, Position direction)
{
   SR_Zone resultZone;
   bool started = true;
   if(direction == Buy)
   {
         for(int i= 0; i < ArraySize(zones); i++)
         {
           if( ((zones[i].SRType & MIDPIVOT) && (useMidPivots)) || (!(zones[i].SRType & MIDPIVOT)))
             {   
               if(zones[i].LowBorder > prize && (zones[i].LowBorder < resultZone.LowBorder || started ))
               {
                 //Print("Find next SRZone: "+ zones[i].HighBorder); 
                 copySRZones(zones[i],resultZone);
                 started = false;
                 
               }
             }    
         }
   }
   else if(direction == Sell)
   {
         for(int i= 0; i < ArraySize(zones); i++)
         {
           if( ((zones[i].SRType & MIDPIVOT) && (useMidPivots)) || (!(zones[i].SRType & MIDPIVOT)))
           {   
               if(zones[i].HighBorder < prize && (zones[i].HighBorder > resultZone.HighBorder || started ))
               {
                  copySRZones(zones[i],resultZone);
                  started = false;
               }
           }   
         }
   }
   
   if(started)
      return false;
    else
    {
      copySRZones(resultZone,nextZone);
      return true;  
    }
}