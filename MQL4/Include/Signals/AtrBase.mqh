//+------------------------------------------------------------------+
//|                                                      AtrBase.mqh |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property strict

#include <Common\Comparators.mqh>
#include <Signals\AbstractSignal.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class AtrBase : public AbstractSignal
  {
protected:
   double            _skew;
   double            _atrMultiplier;
   virtual PriceRange CalculateRange(string symbol,int shift,double midPrice);
   virtual PriceRange CalculateRangeByPriceLowHighMidpoint(string symbol,int shift);

public:
                     AtrBase(int period,double atrMultiplier,ENUM_TIMEFRAMES timeframe,double skew,int shift=0,double minimumSpreadsTpSl=1,color indicatorColor=clrAquamarine);
   virtual bool      DoesSignalMeetRequirements();
   virtual bool      Validate(ValidationResult *v);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
AtrBase::AtrBase(int period,double atrMultiplier,ENUM_TIMEFRAMES timeframe,double skew,int shift=0,double minimumSpreadsTpSl=1,color indicatorColor=clrAquamarine):AbstractSignal(period,timeframe,shift,indicatorColor,minimumSpreadsTpSl)
  {
   this._atrMultiplier=atrMultiplier;
   this._skew=skew;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool AtrBase::Validate(ValidationResult *v)
  {
   AbstractSignal::Validate(v);

   if(!this._compare.IsGreaterThanOrEqualTo(this._atrMultiplier,1.0))
     {
      v.Result=false;
      v.AddMessage("Atr Multiplier must be 1 or greater.");
     }

   if(this._compare.IsNotBetween(this._skew,-0.49,0.49))
     {
      v.Result=false;
      v.AddMessage("Atr skew is out of range Min : - 0.49 max 0.49");
     }

   return v.Result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool AtrBase::DoesSignalMeetRequirements()
  {
   if(!(AbstractSignal::DoesSignalMeetRequirements()))
     {
      return false;
     }

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
PriceRange AtrBase::CalculateRange(string symbol,int shift,double midPrice)
  {
   PriceRange pr;
   pr.mid=midPrice;
   double atr=(this.GetAtr(symbol,shift)*this._atrMultiplier);
   pr.low=(pr.mid-atr);
   pr.high=(pr.mid+atr);
   return pr;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
PriceRange AtrBase::CalculateRangeByPriceLowHighMidpoint(string symbol,int shift)
  {
   PriceRange pr=this.CalculateRangeByPriceLowHigh(symbol,shift);
   return this.CalculateRange(symbol,shift,pr.mid);
  }
//+------------------------------------------------------------------+
