//+------------------------------------------------------------------+
//|                                                SpreadMonitor.mqh |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property strict

#include <Common\CsvFileWriter.mqh>
#include <MarketWatch\MarketWatch.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class SpreadMonitor : private CsvFileWriter
  {
public:
   void SpreadMonitor(string fileName="Spreads.csv",bool appendReport=true):CsvFileWriter(fileName,appendReport)
     {
      string columnNames[]={"Date","Time","Symbol","Spread"};
      this.SetColumnNames(columnNames);
     };

   bool RecordData(string symbol)
     {
      MqlTick tick;
      if(MarketWatch::GetTick(symbol,tick))
        {
         this.SetPendingDataItem("Date",StringFormat("%i/%i/%i",Year(),Month(),Day()));
         this.SetPendingDataItem("Time",StringFormat("%i:%i:%i",Hour(),Minute(),Seconds()));
         this.SetPendingDataItem("Symbol",symbol);
         this.SetPendingDataItem("Spread",((string)MarketWatch::GetSpread(symbol)));
         return (this.WritePendingDataRow()>0);
        }
      return false;
     };
  };
//+------------------------------------------------------------------+
