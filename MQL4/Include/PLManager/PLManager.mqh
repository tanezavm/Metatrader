//+------------------------------------------------------------------+
//|                                                    PLManager.mqh |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property strict

#include <Common\OrderManager.mqh>
// Closes all positions on watched pairs when net profit or loss hits the target.
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class PLManager
  {
private:
   OrderManager      orderManager;
   SimpleParsers     simpleParsers;
   bool              ValidateWatchedPairsExist();
public:
   string            WatchedPairs;// Currency basket
   double            ProfitTarget; // Profit target in account currency
   double            MaxLoss; // Maximum allowed loss in account currency
   int               Slippage; // Allowed slippage when closing orders
   int               MinAge; // Minimum age of order in seconds
   BaseLogger        Logger;
                     PLManager();
                    ~PLManager();
   bool              Validate(ValidationResult *validationResult);
   bool              Validate();
   bool              CanTrade();
   void              Execute();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
PLManager::PLManager()
  {
   this.ProfitTarget=0;
   this.MaxLoss=0;
   this.WatchedPairs="";
   this.Slippage=10;
   this.MinAge=60;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
PLManager::~PLManager()
  {
  }
//+------------------------------------------------------------------+
//| Validate that watched pairs exist and are in the market watch.   |
//+------------------------------------------------------------------+
bool PLManager::ValidateWatchedPairsExist()
  {
   ValidationResult *validationResult=new ValidationResult();
   this.orderManager.DoSymbolsExist(this.WatchedPairs,validationResult);

   if(validationResult.Result==false)
     {
      this.Logger.Error(validationResult.Messages);
     }
   bool out=validationResult.Result;
   delete validationResult;
   return out;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool PLManager::Validate()
  {
   ValidationResult *v=new ValidationResult();
   bool out=this.Validate(v);
   delete v;
   return out;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool PLManager::Validate(ValidationResult *validationResult)
  {
   validationResult.Result=true;

   if(this.WatchedPairs=="")
     {
      validationResult.AddMessage("Your watched pairs is empty, using current symbol only.");
      this.WatchedPairs=Symbol();
     }
   if(!this.ValidateWatchedPairsExist())
     {
      validationResult.AddMessage("One of your watched symbols could not be found on the server.");
      validationResult.Result=false;
     }
   if(this.ProfitTarget<0)
     {
      validationResult.AddMessage("The ProfitTarget must be greater than or equal to zero.");
      validationResult.Result=false;
     }
   if(this.MaxLoss<0)
     {
      validationResult.AddMessage("The MaxLoss must be greater than or equal to zero.");
      validationResult.Result=false;
     }
   if(Slippage<0)
     {
      validationResult.AddMessage("The Slippage must be greater than or equal to zero.");
      validationResult.Result=false;
     }
   if(this.MinAge<0)
     {
      validationResult.AddMessage("The MinAge must be greater than or equal to zero.");
      validationResult.Result=false;
     }

   return validationResult.Result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool PLManager::CanTrade()
  {
   string result[];
   int k=this.simpleParsers.ParseCsvLine(this.WatchedPairs,result);
   string symbol;
   if(k>0)
     {
      for(int i=0;i<k;i++)
        {
         symbol=result[i];

         if(!(this.orderManager.CanTrade(symbol,TimeCurrent())))
           {
            return false;
           }
        }
     }

   return true;
  }
//+------------------------------------------------------------------+
//| Executes the Profit and Loss management.                         |
//+------------------------------------------------------------------+
void PLManager::Execute()
  {
   if(!(this.Validate() && this.CanTrade()))
     {
      return;
     }

   string result[];
   int k=this.simpleParsers.ParseCsvLine(WatchedPairs,result);

   string comment="";
   string symbol="";
   double p=0;
   double netProfit=0;
   if(k>0)
     {
      for(int i=0;i<k;i++)
        {
         symbol=result[i];
         p=orderManager.PairProfit(symbol);
         netProfit+=p;
         comment+=StringFormat("%s : %f\r\n",symbol,p);
         p=0;
         symbol="";
        }
     }
   comment+=StringFormat("Net : %f\r\n",netProfit);
   this.Logger.Comment(comment);
   if(this.ProfitTarget>0 && netProfit>=this.ProfitTarget)
     {
      this.Logger.Log("Profit target reached, closing orders.");
      for(int j=0;j<k;j++)
        {
         symbol=result[j];
         this.orderManager.CloseOrders(symbol,((datetime)TimeCurrent()-this.MinAge));
        }
     }
   if(this.MaxLoss>0 && netProfit<=(this.MaxLoss*-1))
     {
      this.Logger.Warn("Maximum loss reached, closing orders.");
      for(int j=0;j<k;j++)
        {
         symbol=result[j];
         this.orderManager.CloseOrders(symbol,((datetime)TimeCurrent()-this.MinAge));
        }
     }
  }
//+------------------------------------------------------------------+
