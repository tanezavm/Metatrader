//+------------------------------------------------------------------+
//|                                               PortfolioStats.mqh |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property strict

#include <Stats\Stats.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class PortfolioStats
  {
public:
   static int        LossTradesCount(string symbol=NULL);
   static int        ProfitTradesCount(string symbol=NULL);
   static int        TotalTrades(string symbol=NULL);
   static double     WinRate(string symbol=NULL);
   static double     LossRate(string symbol=NULL);
   static double     NetProfit(string symbol=NULL);
   static double     ProfitPerTrade(string symbol=NULL);
   static double     TotalGain(string symbol=NULL);
   static double     TotalLoss(string symbol=NULL);
   static double     LargestGain(string symbol=NULL);
   static double     LargestLoss(string symbol=NULL);
   static double     MedianGain(string symbol=NULL);
   static double     MedianLoss(string symbol=NULL);
   static double     AverageGain(string symbol=NULL);
   static double     AverageLoss(string symbol=NULL);
   static double     SmallestGain(string symbol=NULL);
   static double     SmallestLoss(string symbol=NULL);
   static double     GainsStdDev(string symbol=NULL);
   static double     LossesStdDev(string symbol=NULL);
   static double     ReturnStdDev(string symbol=NULL);
   static void       GetReturnsArray(double &array[],string str);
   static void       GetGainsArray(double &array[],string str);
   static void       GetLossesArray(double &array[],string str);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PortfolioStats::GetGainsArray(double &array[],string symbol)
  {
   int total=OrdersHistoryTotal();
   int i=0;
   int found=0;
   for(i=0;i<total;i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
        {
         if(OrderProfit()>0 && (OrderType()==OP_BUY || OrderType()==OP_SELL) && (OrderSymbol()==symbol || symbol==NULL))
           {
            ArrayResize(array,found+1,0);
            array[found]=OrderProfit();
            found++;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PortfolioStats::GetLossesArray(double &array[],string symbol)
  {
   int total=OrdersHistoryTotal();
   int i=0;
   int found=0;
   for(i=0;i<total;i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
        {
         if(OrderProfit()<0 && (OrderType()==OP_BUY || OrderType()==OP_SELL) && (OrderSymbol()==symbol || symbol==NULL))
           {
            ArrayResize(array,found+1,0);
            array[found]=OrderProfit();
            found++;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PortfolioStats::GetReturnsArray(double &array[],string symbol)
  {
   int total=OrdersHistoryTotal();

   ArrayResize(array,total,0);

   int i=0;
   for(i=0;i<total;i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
        {
         if((OrderType()==OP_BUY || OrderType()==OP_SELL) && (OrderSymbol()==symbol || symbol==NULL))
           {
            array[i]=OrderProfit();
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PortfolioStats::ReturnStdDev(string symbol=NULL)
  {
   double returns[];
   PortfolioStats::GetReturnsArray(returns,symbol);
   double stdDev=Stats::StandardDeviation(returns);
   return stdDev;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PortfolioStats::GainsStdDev(string symbol=NULL)
  {
   double returns[];
   PortfolioStats::GetGainsArray(returns,symbol);
   double stdDev=Stats::StandardDeviation(returns);
   return stdDev;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PortfolioStats::LossesStdDev(string symbol=NULL)
  {
   double returns[];
   PortfolioStats::GetLossesArray(returns,symbol);
   double stdDev=Stats::StandardDeviation(returns);
   return stdDev;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PortfolioStats::LargestGain(string symbol=NULL)
  {
   double profits[];
   PortfolioStats::GetGainsArray(profits,symbol);
   if(Stats::Count(profits)<=0)
     {
      return 0;
     }
   return Stats::Max(profits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PortfolioStats::LargestLoss(string symbol=NULL)
  {
   double profits[];
   PortfolioStats::GetLossesArray(profits,symbol);
   if(Stats::Count(profits)<=0)
     {
      return 0;
     }
   return Stats::Min(profits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PortfolioStats::SmallestGain(string symbol=NULL)
  {
   double profits[];
   PortfolioStats::GetGainsArray(profits,symbol);
   if(Stats::Count(profits)<=0)
     {
      return 0;
     }
   return Stats::Min(profits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PortfolioStats::SmallestLoss(string symbol=NULL)
  {
   double profits[];
   PortfolioStats::GetLossesArray(profits,symbol);
   if(Stats::Count(profits)<=0)
     {
      return 0;
     }
   return Stats::Max(profits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PortfolioStats::MedianGain(string symbol=NULL)
  {
   double profits[];
   PortfolioStats::GetGainsArray(profits,symbol);
   if(Stats::Count(profits)<=0)
     {
      return 0;
     }
   return Stats::Median(profits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PortfolioStats::MedianLoss(string symbol=NULL)
  {
   double profits[];
   PortfolioStats::GetLossesArray(profits,symbol);
   if(Stats::Count(profits)<=0)
     {
      return 0;
     }
   return Stats::Median(profits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PortfolioStats::AverageGain(string symbol=NULL)
  {
   double profits[];
   PortfolioStats::GetGainsArray(profits,symbol);
   if(Stats::Count(profits)<=0)
     {
      return 0;
     }
   return Stats::Average(profits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PortfolioStats::AverageLoss(string symbol=NULL)
  {
   double profits[];
   PortfolioStats::GetLossesArray(profits,symbol);
   if(Stats::Count(profits)<=0)
     {
      return 0;
     }
   return Stats::Average(profits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PortfolioStats::ProfitPerTrade(string symbol=NULL)
  {
   int trades=PortfolioStats::TotalTrades(symbol);
   if(trades<=0)
     {
      return 0;
     }
   double profit=PortfolioStats::NetProfit(symbol);
   return profit/trades;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PortfolioStats::NetProfit(string symbol=NULL)
  {
   double profits[];
   PortfolioStats::GetReturnsArray(profits,symbol);
   if(Stats::Count(profits)<=0)
     {
      return 0;
     }
   return Stats::Sum(profits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PortfolioStats::TotalGain(string symbol=NULL)
  {
   double profits[];
   PortfolioStats::GetGainsArray(profits,symbol);
   if(Stats::Count(profits)<=0)
     {
      return 0;
     }
   return Stats::Sum(profits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PortfolioStats::TotalLoss(string symbol=NULL)
  {
   double profits[];
   PortfolioStats::GetLossesArray(profits,symbol);
   if(Stats::Count(profits)<=0)
     {
      return 0;
     }
   return Stats::Sum(profits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int PortfolioStats::LossTradesCount(string symbol=NULL)
  {
   double profits[];
   PortfolioStats::GetLossesArray(profits,symbol);
   if(Stats::Count(profits)<=0)
     {
      return 0;
     }
   return Stats::Count(profits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int PortfolioStats::ProfitTradesCount(string symbol=NULL)
  {
   double profits[];
   PortfolioStats::GetGainsArray(profits,symbol);
   if(Stats::Count(profits)<=0)
     {
      return 0;
     }
   return Stats::Count(profits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int PortfolioStats::TotalTrades(string symbol=NULL)
  {
   double profits[];
   PortfolioStats::GetReturnsArray(profits,symbol);
   if(Stats::Count(profits)<=0)
     {
      return 0;
     }
   return Stats::Count(profits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PortfolioStats::WinRate(string symbol=NULL)
  {
   int wins=PortfolioStats::ProfitTradesCount(symbol);
   if(wins<=0)
     {
      return 0;
     }

   int total=PortfolioStats::TotalTrades(symbol);
   if(total<=0)
     {
      return 0;
     }

   return (wins/total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PortfolioStats::LossRate(string symbol=NULL)
  {
   int losses=PortfolioStats::LossTradesCount(symbol);
   if(losses<=0)
     {
      return 0;
     }

   int total=PortfolioStats::TotalTrades(symbol);
   if(total<=0)
     {
      return 0;
     }

   return (losses/total);
  }
//+------------------------------------------------------------------+
