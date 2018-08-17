//+------------------------------------------------------------------+
//|                                                 MonkeySignal.mqh |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property strict

#include <Signals\MonkeySignalBase.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MonkeySignal : public MonkeySignalBase
  {
private:
   datetime          _lastTrigger;
public:
                     MonkeySignal(int period,ENUM_TIMEFRAMES timeframe,double minimumSpreadsTpSl,color indicatorColor,AbstractSignal *aSubSignal=NULL);
   SignalResult     *Analyzer(string symbol,int shift);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MonkeySignal::MonkeySignal(int period,ENUM_TIMEFRAMES timeframe,double minimumSpreadsTpSl,color indicatorColor,AbstractSignal *aSubSignal=NULL):MonkeySignalBase(period,timeframe,0,minimumSpreadsTpSl,indicatorColor,aSubSignal)
  {
   this._lastTrigger=TimeCurrent();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SignalResult *MonkeySignal::Analyzer(string symbol,int shift)
  {
   MqlTick tick;
   bool gotTick=SymbolInfoTick(symbol,tick);
   CandleMetrics *candle=this.GetCandleMetrics(symbol,shift);
   if(candle.IsSet && 0<OrderManager::PairOpenPositionCount(symbol))
   {
      this._lastTrigger=candle.Time;
   }

   if(gotTick && candle.IsSet && candle.Time!=this._lastTrigger)
     {
      double atr=this.GetAtr(symbol,shift);
      PriceRange trigger;
      trigger.high=candle.Open+atr;
      trigger.low=candle.Open-atr;
      
      this.DrawIndicatorRectangle(symbol,shift,trigger.high,trigger.low,NULL,1);
      
      double rsi=this.GetRsi(symbol,shift,14,PRICE_CLOSE);
      double atrFast=this.GetAtr(symbol,shift,14);
      
      bool sellSignal=(candle.High>=(trigger.high)) && rsi>65;
      bool buySignal=(candle.Low<=(trigger.low)) && rsi<35;

      if(_compare.Xor(sellSignal,buySignal))
        {
         if(sellSignal)
           {
            this.SetSellSignal(symbol,shift,tick,true);
           }

         if(buySignal)
           {
            this.SetBuySignal(symbol,shift,tick,true);
           }

         // signal confirmation
         if(!this.DoesSubsignalConfirm(symbol,shift))
           {
            this.Signal.Reset();
           }
         else
           {
            this._lastTrigger=candle.Time;
           }
        }
      else
        {
         this.Signal.Reset();
        }

      // if there is an order open...
      if(1<=OrderManager::PairOpenPositionCount(symbol,TimeCurrent()))
        {
         this.SetExits(symbol,shift,tick);
        }

     }

   delete candle;
   return this.Signal;
  }
//+------------------------------------------------------------------+
