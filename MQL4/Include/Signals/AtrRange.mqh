//+------------------------------------------------------------------+
//|                                                     AtrRange.mqh |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property strict

#include <Signals\AtrBase.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class AtrRange : public AtrBase
  {
public:
                     AtrRange(int period,double atrMultiplier,ENUM_TIMEFRAMES timeframe,int shift=0,double minimumSpreadsTpSl=1,color indicatorColor=clrAquamarine);
   SignalResult     *Analyzer(string symbol,int shift);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
AtrRange::AtrRange(int period,double atrMultiplier,ENUM_TIMEFRAMES timeframe,int shift=0,double minimumSpreadsTpSl=1,color indicatorColor=clrAquamarine):AtrBase(period,atrMultiplier,timeframe,shift,minimumSpreadsTpSl,indicatorColor)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SignalResult *AtrRange::Analyzer(string symbol,int shift)
  {
   double atr=iATR(symbol,this.Timeframe(),this.Period(),shift);

   double low=(iLow(symbol, this.Timeframe(), iLowest(symbol,this.Timeframe(),MODE_LOW,this.Period(),shift)));
   double high=(iHigh(symbol, this.Timeframe(), iHighest(symbol,this.Timeframe(),MODE_HIGH,this.Period(),shift)));

   double mid=((low+high)/2);

   low=(mid -(atr*this._atrMultiplier));
   high=(mid+(atr*this._atrMultiplier));

   this.DrawIndicatorRectangle(symbol,shift,high,low);

   MqlTick tick;
   bool gotTick=SymbolInfoTick(symbol,tick);

   if(gotTick)
     {
      if(tick.bid>=mid)
        {
         this.Signal.isSet=true;
         this.Signal.time=tick.time;
         this.Signal.symbol=symbol;
         this.Signal.orderType=OP_SELL;
         this.Signal.price=tick.bid;
         this.Signal.stopLoss=(tick.bid+MathAbs(high-tick.bid));
         this.Signal.takeProfit=low;
        }
      if(tick.ask<=mid)
        {
         this.Signal.isSet=true;
         this.Signal.orderType=OP_BUY;
         this.Signal.price=tick.ask;
         this.Signal.symbol=symbol;
         this.Signal.time=tick.time;
         this.Signal.stopLoss=(tick.ask-MathAbs(tick.ask-low));
         this.Signal.takeProfit=high;
        }
     }
   return this.Signal;
  }
//+------------------------------------------------------------------+
