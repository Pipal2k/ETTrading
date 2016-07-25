// _advanced expert advisor template.mq4
// Copyright © 2009, TradingSystemForex
// http://www.tradingsystemforex.com/

#property copyright "Copyright © 2009, TradingSystemForex"
#property link "http://www.tradingsystemforex.com/"

extern string comment="TCS";              // comment to display in the order
extern int magicbuy=1234;                 // magic number required for buy orders if you use different settings on a same pair, same timeframe
extern int magicsell=4321;                // magic number required for sell orders if you use different settings on a same pair, same timeframe

extern string moneymanagement="Money Management";

extern double lots=0.1;                  // lots size
extern bool lotsoptimized=false;         // enable risk management
extern double risk=1;                    // risk in percentage of the account
extern bool martingale=false;            // enable the martingale
extern double multiplier=2.0;            // multiplier used for the martingale
extern double minlot=0.01;               // minimum lot allowed by the expert
extern double maxlot=10;                 // maximum lot allowed by the expert
extern double lotdigits=2;               // 1 for minilot, 2 for microlot
extern bool basketpercent=false;         // enable the basket percent
extern double profit=10;                 // close all orders if a profit of 10 percents has been reached
extern double loss=30;                   // close all orders if a loss of 30 percents has been reached

extern string ordersmanagement="Order Management";

extern bool oppositeclose=false;         // close the orders on an opposite signal
extern bool reversesignals=false;        // reverse the signals, long if short, short if long
extern int maxtrades=1;                  // maximum trades allowed by the traders
extern int tradesperbar=100;             // maximum trades per bar allowed by the expert
extern bool hidestop=false;              // hide stop loss
extern bool hidetarget=false;            // hide take profit
extern double buystop=55;                // buy stop loss
extern double buytarget=4;               // buy take profit
extern double sellstop=45;               // sell stop loss
extern double selltarget=4;              // buy take profit
extern double trailingstart=16;          // profit in pips required to enable the trailing stop
extern double trailingstop=5;            // trailing stop
extern double trailingstep=1;            // margin allowed to the market to enable the trailing stop
extern double breakevengain=0;           // gain in pips required to enable the break even
extern double breakeven=0;               // break even
int expiration=225;                      // expiration in minutes for pending orders
extern double slippage=2;                // maximum difference in pips between signal and order
extern double maxspread=3;               // maximum spread allowed by the expert

extern string entrylogics="Entry Logics";

extern int channeltf=15;                 // timeframe of the ma channel
extern int uppermamethod=3;              // method of the upper ma
extern int uppermaperiod=3;              // period of the upper ma
extern int uppermaprice=2;               // price of the upper ma
extern double uppermargin=0;             // margin to add or substract on the upper ma
extern int lowermamethod=0;              // method of the lower ma
extern int lowermaperiod=2;              // period of the lower ma
extern int lowermaprice=3;               // price of the lower ma
extern double lowermargin=0;             // margin to add or substract on the lower ma
extern double longmargin=0;              // margin to add or substract to the market for long signal
extern double shortmargin=-0.5;          // margin to add or substract to the market for short signal
extern int shift=1;                      // bar in the past to take in consideration for the signal

extern string timefilter="Time Filter";

extern int gmtshift=2;                   // gmt offset of the broker
extern bool filter=true;                 // enable time filter
extern int starthour=17;                 // start to trade after this hour
extern int startminute=0;                // start to trade after this minute of the starthour
extern int endhour=4;                    // stop to trade after this hour
extern int endminute=0;                  // stop to trade after this minute of the endhour
extern bool tradesunday=true;            // trade on sunday
extern bool fridayfilter=true;           // enable special time filter on friday
extern int fridayend=20;                 // stop to trade after this hour

datetime t0,t1,lastbuyopentime,lastsellopentime;
double cb=0,lastbuyopenprice=0,lastsellopenprice=0
,lastbuystoploss=0,lastsellstoploss=0
,lastbuytakeprofit=0,lastselltakeprofit=0;
int lastbuyticket=0,lastsellticket=0;
double sl,tp,pt,mt,min,max,lastprofit;
int i,j,k,l,dg,bc=-1,tpb=0,tps=0,total,ticket;
int buyopenposition=0,sellopenposition=0;
int totalopenposition=0,buyorderprofit=0;
int sellorderprofit=0,cnt=0;
double lotsfactor=1,ilots;
double initiallotsfactor=1;
int istart,iend;

int init(){
   t0=Time[0];t1=Time[0];dg=Digits;
   if(dg==3 || dg==5){pt=Point*10;mt=10;}else{pt=Point;mt=1;}

   //|---------martingale initialization
   int tempfactor,total=OrdersTotal();
   if(tempfactor==0 && total>0){
      for(int cnt=0;cnt<total;cnt++){
         if(OrderSelect(cnt,SELECT_BY_POS)){
            if(OrderSymbol()==Symbol() && (OrderMagicNumber()==magicbuy||OrderMagicNumber()==magicsell)){
               tempfactor=NormalizeDouble(OrderLots()/lots,1+(MarketInfo(Symbol(),MODE_MINLOT)==0.01));
               break;
            }
         }
      }
   }
   int histotal=OrdersHistoryTotal();
   if(tempfactor==0&&histotal>0){
      for(cnt=0;cnt<histotal;cnt++){
         if(OrderSelect(cnt,SELECT_BY_POS,MODE_HISTORY)){
            if(OrderSymbol()==Symbol() && (OrderMagicNumber()==magicbuy||OrderMagicNumber()==magicsell)){
               tempfactor=NormalizeDouble(OrderLots()/lots,1+(MarketInfo(Symbol(),MODE_MINLOT)==0.01));
               break;
            }
         }
      }
   }
   if(tempfactor>0)
   lotsfactor=tempfactor;

   return(0);
}

int start(){

   Comment("\n Developed by WWW.TRADINGSYSTEMFOREX.COM");
   
   /*GlobalVariableSet("vGrafBalance",AccountBalance());
   GlobalVariableSet("vGrafEquity",AccountEquity());*/
   
   total=OrdersTotal();
   
   if(breakevengain>0){
      for(int b=0;b<total;b++){
         OrderSelect(b,SELECT_BY_POS,MODE_TRADES);
         if(OrderType()<=OP_SELL && OrderSymbol()==Symbol() && (OrderMagicNumber()==magicbuy||OrderMagicNumber()==magicsell)){
            if(OrderType()==OP_BUY){
               if(NormalizeDouble((Bid-OrderOpenPrice()),dg)>=NormalizeDouble(breakevengain*pt,dg)){
                  if(NormalizeDouble((OrderStopLoss()-OrderOpenPrice()),dg)<NormalizeDouble(breakeven*pt,dg)){
                     OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(OrderOpenPrice()+breakeven*pt,dg),OrderTakeProfit(),0,Blue);
                     return(0);
                  }
               }
            }
            else{
               if(NormalizeDouble((OrderOpenPrice()-Ask),dg)>=NormalizeDouble(breakevengain*pt,dg)){
                  if(NormalizeDouble((OrderOpenPrice()-OrderStopLoss()),dg)<NormalizeDouble(breakeven*pt,dg)){
                     OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(OrderOpenPrice()-breakeven*pt,dg),OrderTakeProfit(),0,Red);
                     return(0);
                  }
               }
            }
         }
      }
   }
   if(trailingstop>0 && maxtrades>1){
      for(int a=0;a<total;a++){
         OrderSelect(a,SELECT_BY_POS,MODE_TRADES);
         if(OrderType()<=OP_SELL && OrderSymbol()==Symbol() && (OrderMagicNumber()==magicbuy||OrderMagicNumber()==magicsell)){
            if(OrderType()==OP_BUY){
               if(NormalizeDouble(Ask,dg)>NormalizeDouble(OrderOpenPrice()+trailingstart*pt,dg)
               && (NormalizeDouble(OrderStopLoss(),dg)<NormalizeDouble(Bid-(trailingstop+trailingstep)*pt,dg))||(OrderStopLoss()==0)){
                  OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Bid-trailingstop*pt,dg),OrderTakeProfit(),0,Blue);
                  return(0);
               }
            }
            else{
               if(NormalizeDouble(Bid,dg)<NormalizeDouble(OrderOpenPrice()-trailingstart*pt,dg)
               && (NormalizeDouble(OrderStopLoss(),dg)>(NormalizeDouble(Ask+(trailingstop+trailingstep)*pt,dg)))||(OrderStopLoss()==0)){                 
                  OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Ask+trailingstop*pt,dg),OrderTakeProfit(),0,Red);
                  return(0);
               }
            }
         }
      }
   }
   if(trailingstop>0 && maxtrades==1){
   
      totalopenposition=0;
      buyopenposition=0;
      sellopenposition=0;
   
      for(cnt=0;cnt<total;cnt++){
         OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
         if(OrderSymbol()==Symbol() && (OrderMagicNumber()==magicbuy||OrderMagicNumber()==magicsell) && OrderCloseTime()==0){
            totalopenposition++;
            lastprofit=OrderProfit();
            if(OrderType()==OP_BUY){
               lastbuyticket=OrderTicket();
               lastbuyopenprice=OrderOpenPrice();
               lastbuyopentime=OrderOpenTime();
               lastbuystoploss=OrderStopLoss();
               lastbuytakeprofit=OrderTakeProfit();
               buyorderprofit=OrderProfit();
               buyopenposition++;
            }
            if(OrderType()==OP_SELL){
               lastsellticket=OrderTicket();
               lastsellopenprice=OrderOpenPrice();
               lastsellopentime=OrderOpenTime();
               lastsellstoploss=OrderStopLoss();
               lastselltakeprofit=OrderTakeProfit();
               sellorderprofit=OrderProfit();
               sellopenposition++;
            }
         }
      }
      if((NormalizeDouble(lastbuytakeprofit-Bid,dg)>trailingstart*pt) && buyopenposition>0){
         OrderModify(lastbuyticket,lastbuyopenprice,lastbuystoploss,NormalizeDouble(lastbuytakeprofit-trailingstop*pt,dg),0,Blue);
      }
      if((NormalizeDouble(Bid-lastselltakeprofit,dg)>trailingstart*pt) && sellopenposition>0){
         OrderModify(lastsellticket,lastsellopenprice,lastsellstoploss,NormalizeDouble(lastselltakeprofit+trailingstop*pt,dg),0,Red);
      }
   }
   if(basketpercent){
      double ipf=profit*(0.01*AccountBalance());double ilo=loss*(0.01*AccountBalance());
      cb=AccountEquity()-AccountBalance();
      if(cb>=ipf||cb<=(ilo*(-1))){
         for(i=total-1;i>=0;i--){
            OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
            if(OrderSymbol()==Symbol() && OrderMagicNumber()==magicbuy && OrderType()==OP_BUY){
               OrderClose(OrderTicket(),OrderLots(),Bid,slippage*pt);
            }
            if(OrderSymbol()==Symbol() && OrderMagicNumber()==magicsell && OrderType()==OP_SELL){
               OrderClose(OrderTicket(),OrderLots(),Ask,slippage*pt);
            }
         }
         return(0);
      }
   }
   
   double upperma=iMA(Symbol(),channeltf,uppermaperiod,0,uppermamethod,uppermaprice,shift);
   double lowerma=iMA(Symbol(),channeltf,lowermaperiod,0,lowermamethod,lowermaprice,shift);

   bool openbuy=true;bool opensell=true;
   bool closebuy=false;bool closesell=false;

   //if()
   //{openbuy=false;opensell=false;}
   
   if(lotsoptimized && (martingale==false || (martingale && lastprofit>=0)))lots=NormalizeDouble((AccountBalance()/1000)*minlot*risk,lotdigits);
   if(lots<minlot)lots=minlot;if(lots>maxlot)lots=maxlot;
   
   if(tradesperbar==1 && (((TimeCurrent()-lastbuyopentime)<Period()) || ((TimeCurrent()-lastsellopentime)<Period()))){tpb=1;tps=1;}
   
   bool buy=false;bool sell=false;

   if((Bid+longmargin*pt)<(lowerma+lowermargin*pt)
   && openbuy)if(reversesignals)sell=true;else buy=true;
   
   if((Bid+shortmargin*pt)>(upperma+uppermargin*pt)
   && opensell)if(reversesignals)buy=true;else sell=true;

   if(bc!=Bars){tpb=0;tps=0;bc=Bars;}
   /*Comment("\nSEFCU1  =  " + DoubleToStr(SEFCU1,4),"\nSEFCD1  =  " + DoubleToStr(SEFCD1,4));*/

   if((oppositeclose && sell)||(closebuy)){
      for(i=total-1;i>=0;i--){
         OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==magicbuy && OrderType()==OP_BUY){
            OrderClose(OrderTicket(),OrderLots(),Bid,slippage*pt);
         }
      }
   }
   if((oppositeclose && buy)||(closesell)){
      for(j=total-1;j>=0;j--){
         OrderSelect(j,SELECT_BY_POS,MODE_TRADES);
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==magicsell && OrderType()==OP_SELL){
            OrderClose(OrderTicket(),OrderLots(),Ask,slippage*pt);
         }
      }
   }
   if(hidestop){
      for(k=total-1;k>=0;k--){
         OrderSelect(k,SELECT_BY_POS,MODE_TRADES);
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==magicbuy && OrderType()==OP_BUY && buystop>0 && Bid<(OrderOpenPrice()-buystop*pt)){
            OrderClose(OrderTicket(),OrderLots(),Bid,slippage*pt);
         }
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==magicsell && OrderType()==OP_SELL && sellstop>0 && Ask>(OrderOpenPrice()+sellstop*pt)){
            OrderClose(OrderTicket(),OrderLots(),Ask,slippage*pt);
         }
      }
   }
   if(hidetarget){
      for(l=total-1;l>=0;l--){
         OrderSelect(l,SELECT_BY_POS,MODE_TRADES);
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==magicbuy && OrderType()==OP_BUY && buytarget>0 && Bid>(OrderOpenPrice()+buytarget*pt)){
            OrderClose(OrderTicket(),OrderLots(),Bid,slippage*pt);
         }
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==magicsell && OrderType()==OP_SELL && selltarget>0 && Ask<(OrderOpenPrice()-selltarget*pt)){
           OrderClose(OrderTicket(),OrderLots(),Ask,slippage*pt);
         }
      }
   }
   
   if((filter && ((Hour()==starthour+gmtshift && Minute()<startminute) || (Hour()<(starthour+gmtshift) && Hour()>(endhour+gmtshift))
   || ((Hour()==endhour+gmtshift && Minute()>endminute)))) || (fridayfilter && DayOfWeek()==5 && !(Hour()<(fridayend+gmtshift)))
   || (tradesunday==false && DayOfWeek()==0))return(0);
   
   if((Ask-Bid)>maxspread*pt)return(0);
   
   int expire=0;
   /*if(expiration>0)expire=TimeCurrent()+(expiration*60)-5;*/
   
   if((buyopenposition+sellopenposition)<maxtrades){
      if(buy && tps<tradesperbar && IsTradeAllowed()){
         while(IsTradeContextBusy())Sleep(3000);
         if(hidestop==false&&buystop>0){sl=Ask-buystop*pt;}else{sl=0;}
         if(hidetarget==false&&buytarget>0){tp=Ask+buytarget*pt;}else{tp=0;}
         if(martingale)ilots=NormalizeDouble(lots*martingalefactor(),2);else ilots=lots;
         if(ilots<minlot)ilots=minlot;if(ilots>maxlot)ilots=maxlot;
         RefreshRates();ticket=OrderSend(Symbol(),OP_BUY,ilots,Ask,slippage*mt,sl,tp,comment+". Magic: "+DoubleToStr(magicbuy,0),magicbuy,expire,Blue);
         if(ticket<=0){Print("Error Occured : "+errordescription(GetLastError()));}
         else{tps++;Print("Order opened : "+Symbol()+" Buy @ "+Ask+" SL @ "+sl+" TP @"+tp+" ticket ="+ticket);}
      }
      if(sell && tpb<tradesperbar && IsTradeAllowed()){
         while(IsTradeContextBusy())Sleep(3000);
         if(hidestop==false&&sellstop>0){sl=Bid+sellstop*pt;}else{sl=0;}
         if(hidetarget==false&&selltarget>0){tp=Bid-selltarget*pt;}else{tp=0;}
         if(martingale)ilots=NormalizeDouble(lots*martingalefactor(),2);else ilots=lots;
         if(ilots<minlot)ilots=minlot;if(ilots>maxlot)ilots=maxlot;
         RefreshRates();ticket=OrderSend(Symbol(),OP_SELL,ilots,Bid,slippage*mt,sl,tp,comment+". Magic: "+DoubleToStr(magicsell,0),magicsell,expire,Red);
         if(ticket<=0){Print("Error Occured : "+errordescription(GetLastError()));}
         else{tpb++;Print("Order opened : "+Symbol()+" Sell @ "+Bid+" SL @ "+sl+" TP @"+tp+" ticket ="+ticket);}
      }
   }
   
   return(0);
}

//|---------martingale

int martingalefactor(){
   int histotal=OrdersHistoryTotal();
   if (histotal>0){
      for(int cnt=histotal-1;cnt>=0;cnt--){
         if(OrderSelect(cnt,SELECT_BY_POS,MODE_HISTORY)){
            if(OrderSymbol()==Symbol() && (OrderMagicNumber()==magicbuy||OrderMagicNumber()==magicsell)){
               if(OrderProfit()<0){
                  lotsfactor=lotsfactor*multiplier;
                  return(lotsfactor);
               }
               else{
                  lotsfactor=initiallotsfactor;
                  if(lotsfactor<=0){
                     lotsfactor=1;
                  }
                  return(lotsfactor);
               }
            }
         }
      }
   }
   return(lotsfactor);
}

string errordescription(int code){
   string error;
   switch(code){
      case 0:
      case 1:error="no error";break;
      case 2:error="common error";break;
      case 3:error="invalid trade parameters";break;
      case 4:error="trade server is busy";break;
      case 5:error="old version of the client terminal";break;
      case 6:error="no connection with trade server";break;
      case 7:error="not enough rights";break;
      case 8:error="too frequent requests";break;
      case 9:error="malfunctional trade operation";break;
      case 64:error="account disabled";break;
      case 65:error="invalid account";break;
      case 128:error="trade timeout";break;
      case 129:error="invalid price";break;
      case 130:error="invalid stops";break;
      case 131:error="invalid trade volume";break;
      case 132:error="market is closed";break;
      case 133:error="trade is disabled";break;
      case 134:error="not enough money";break;
      case 135:error="price changed";break;
      case 136:error="off quotes";break;
      case 137:error="broker is busy";break;
      case 138:error="requote";break;
      case 139:error="order is locked";break;
      case 140:error="long positions only allowed";break;
      case 141:error="too many requests";break;
      case 145:error="modification denied because order too close to market";break;
      case 146:error="trade context is busy";break;
      case 4000:error="no error";break;
      case 4001:error="wrong function pointer";break;
      case 4002:error="array index is out of range";break;
      case 4003:error="no memory for function call stack";break;
      case 4004:error="recursive stack overflow";break;
      case 4005:error="not enough stack for parameter";break;
      case 4006:error="no memory for parameter string";break;
      case 4007:error="no memory for temp string";break;
      case 4008:error="not initialized string";break;
      case 4009:error="not initialized string in array";break;
      case 4010:error="no memory for array\' string";break;
      case 4011:error="too long string";break;
      case 4012:error="remainder from zero divide";break;
      case 4013:error="zero divide";break;
      case 4014:error="unknown command";break;
      case 4015:error="wrong jump (never generated error)";break;
      case 4016:error="not initialized array";break;
      case 4017:error="dll calls are not allowed";break;
      case 4018:error="cannot load library";break;
      case 4019:error="cannot call function";break;
      case 4020:error="expert function calls are not allowed";break;
      case 4021:error="not enough memory for temp string returned from function";break;
      case 4022:error="system is busy (never generated error)";break;
      case 4050:error="invalid function parameters count";break;
      case 4051:error="invalid function parameter value";break;
      case 4052:error="string function internal error";break;
      case 4053:error="some array error";break;
      case 4054:error="incorrect series array using";break;
      case 4055:error="custom indicator error";break;
      case 4056:error="arrays are incompatible";break;
      case 4057:error="global variables processing error";break;
      case 4058:error="global variable not found";break;
      case 4059:error="function is not allowed in testing mode";break;
      case 4060:error="function is not confirmed";break;
      case 4061:error="send mail error";break;
      case 4062:error="string parameter expected";break;
      case 4063:error="integer parameter expected";break;
      case 4064:error="double parameter expected";break;
      case 4065:error="array as parameter expected";break;
      case 4066:error="requested history data in update state";break;
      case 4099:error="end of file";break;
      case 4100:error="some file error";break;
      case 4101:error="wrong file name";break;
      case 4102:error="too many opened files";break;
      case 4103:error="cannot open file";break;
      case 4104:error="incompatible access to a file";break;
      case 4105:error="no order selected";break;
      case 4106:error="unknown symbol";break;
      case 4107:error="invalid price parameter for trade function";break;
      case 4108:error="invalid ticket";break;
      case 4109:error="trade is not allowed";break;
      case 4110:error="longs are not allowed";break;
      case 4111:error="shorts are not allowed";break;
      case 4200:error="object is already exist";break;
      case 4201:error="unknown object property";break;
      case 4202:error="object is not exist";break;
      case 4203:error="unknown object type";break;
      case 4204:error="no object name";break;
      case 4205:error="object coordinates error";break;
      case 4206:error="no specified subwindow";break;
      default:error="unknown error";
   }
   return(error);
}