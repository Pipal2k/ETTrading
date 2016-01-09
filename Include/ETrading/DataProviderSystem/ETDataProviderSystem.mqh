//+------------------------------------------------------------------+
//|                                         ETDataProviderSystem.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include <ETrading/ETdataTypes.mqh>
#include <ETrading/DataProviderSystem/ETPivot.mqh>
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

SR_Row sr_rows[];
int DataProviderOptions;

struct ProvidedData {
   SR_Zone zones[];
   
};

void initDataProviderSys(int dpOptions)
{
   DataProviderOptions = dpOptions;
}

void provideData(ProvidedData &data)
{
   findSRZones(data.zones);
}

void findSRZones(SR_Zone &zones[])
{
  
  ArrayFree(sr_rows);
  ArrayFree(zones);
  
  if(DataProviderOptions & PIVOT)
   calculatePivot(sr_rows,PERIOD_D1,Standard);
  
  if(DataProviderOptions & FPIVOT)
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