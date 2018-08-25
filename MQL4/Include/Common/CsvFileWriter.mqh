//+------------------------------------------------------------------+
//|                                                CsvFileWriter.mqh |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property strict

#include<Files\FileTxt.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CsvFileWriter : public CFileTxt
  {
private:

   string CsvEscape(string const value)
     {
      string val=value;
      StringReplace(val,"\"","\"\"");
      if(StringFind(val,",")>-1 || StringFind(val,"\r")>-1 || StringFind(val,"\n")>-1)
        {
         val=StringFormat("\"%s\"",val);
        }
      val = StringTrimLeft(val);
      val = StringTrimRight(val);
      return val;
     };
   //+------------------------------------------------------------------+
   //| Open the file                                                    |
   //+------------------------------------------------------------------+
   int Open(const string file_name,int open_flags,const string delimiter,uint codepage=CP_UTF8)
     {
      //--- check handle
      if(m_handle!=INVALID_HANDLE)
         Close();
      //--- action
      if((open_flags &(FILE_BIN|FILE_CSV))==0)
         open_flags|=FILE_TXT;
      //--- open
      m_handle=FileOpen(file_name,open_flags|m_flags,delimiter,codepage);
      if(m_handle!=INVALID_HANDLE)
        {
         //--- store options of the opened file
         m_flags|=open_flags;
         m_name=file_name;
        }
      //--- result
      return(m_handle);
     }
public:
   void CsvFileWriter()
     {
     };

   void CsvFileWriter(string filename,bool append=true)
     {
      this.Open(filename,append);
     };

   int Open(string filename,bool append=true)
     {
      int handle;
      if(!append)
      {
         handle=this.Open(filename,FILE_WRITE|FILE_TXT,",",CP_UTF8);
      }
      handle=this.Open(filename,FILE_READ|FILE_SHARE_READ|FILE_SHARE_WRITE|FILE_WRITE|FILE_TXT,",",CP_UTF8);
      this.Seek(0,SEEK_END);
      return handle;
     };

   uint WriteRow(string &values[])
     {
      int ct=ArraySize(values);
      int i;
      string row;
      for(i=0;i<ct-1;i++)
        {
         row=StringConcatenate(row,(StringFormat("%s,",CsvEscape(values[i]))));
        }
      row=StringConcatenate(row,(StringFormat("%s\r\n",CsvEscape(values[i]))));

      this.Seek(0,SEEK_END);

      return this.WriteString(row);
     };
  };
//+------------------------------------------------------------------+
