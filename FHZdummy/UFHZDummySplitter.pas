unit UFHZDummySplitter;
//Thomas Dreßler (www.tdressler.net) 2011-2013
interface


uses
     Classes,Dateutils, SysUtils,strutils,windows,
     UIPSTypes, UIPSModuleTypes, UIPSDataTypes,
     ufhztypes,UFHZDummyinterface;

type


 TIPSFHZDummy = class(TIPSModuleObject,
                          IIPSModule,
                          IIPSSendString,
                          IIPSReceiveString,
                          IIPSSendFHZ,
                          IIPSReceiveFHZ,
                          IIPSFHZDummy
                          )
  private
   //--- Basic Structures
   FLock: TRTLCriticalSection;
   procedure outlog(data:string);

  public
   constructor Create(IKernel: IIPSKernel; InstanceID: TInstanceID); override;
   destructor  Destroy; override;
   //--- IIPSModule implementation
   procedure LoadSettings(); override;
   procedure SaveSettings(); override;
   procedure ResetChanges(); override;
   procedure ApplyChanges(); override;

   //Actions

  //IIPSFHZ-Functions ,ab 2.7 ohne Queue
//  function GetFHTQueue(): TFHZQueueItems; stdcall;
//  function GetDataQueue(): TFHZQueueItems; stdcall;
  function GetFreeBuffer(): Integer; stdcall;

   { Data Points }
    procedure SendText(Text: String); stdcall;
   procedure ReceiveText(Text: String); stdcall;
   procedure SendFHZData(Data: TFHZDataTX; NumBytes: Byte); stdcall;
  procedure ReceiveFHZData(Data: TFHZDataRX); stdcall;
   { Class Functions }
   class function GetModuleID(): TStrGUID; override;
   class function GetModuleType(): TIPSModuleType; override;
   class function GetModuleName(): String; override;
   class function GetImplemented(): TStrGUIDs; override;
   class function GetVendor(): String; override;
   class function GetAliases(): TStringArray; override;
   class function GetParentRequirements(): TStrGUIDs; override;
   class function GetChildRequirements(): TStrGUIDs; override;
 end;
implementation
 //---Module standard
//------------------------------------------------------------------------------
class function TIPSFHZDummy.GetModuleID(): TStrGUID;
begin
 Result := GUIDToString(IIPSFHZDummy); //Will return Interface GUID
end;

//------------------------------------------------------------------------------
class function TIPSFHZDummy.GetModuleType(): TIPSModuleType;
begin
 Result := mtSplitter;
end;

//------------------------------------------------------------------------------
class function TIPSFHZDummy.GetModuleName(): String;
begin
 Result := 'FHZDummy';
end;

//------------------------------------------------------------------------------
class function TIPSFHZDummy.GetParentRequirements(): TStrGUIDs;
begin

 SetLength(Result, 1);
 Result[0] := GUIDToString(IIPSSendFHZ);
 //Result[1] := GUIDToString(IIPSFHZ);

end;

//------------------------------------------------------------------------------
class function TIPSFHZDummy.GetChildRequirements(): TStrGUIDs;
begin

 SetLength(Result, 2);
 Result[0] := GUIDToString(IIPSFHZ);
 Result[1] := GUIDToString(IIPSReceiveFHZ);
end;

//------------------------------------------------------------------------------
class function TIPSFHZDummy.GetImplemented(): TStrGUIDs;
begin
 SetLength(Result, 5);
 Result[0] := GUIDToString(IIPSFHZ);
 Result[1] := GUIDToString(IIPSSendString);
 Result[2] := GUIDToString(IIPSReceiveString);
 Result[3] := GUIDToString(IIPSSendFHZ);
 Result[4] := GUIDToString(IIPSReceiveFHZ);
end;

//------------------------------------------------------------------------------
class function TIPSFHZDummy.GetVendor(): String;
begin
 Result := 'ELV';
end;

//------------------------------------------------------------------------------
class function TIPSFHZDummy.GetAliases(): TStringArray;
begin

 SetLength(Result, 1);
 Result[0] := 'FHZDummy';


end;

// object Implementation
//------------------------------------------------------------------------------
constructor TIPSFHZDummy.Create(IKernel: IIPSKernel; InstanceID: TInstanceID);
begin


 inherited;
 RegisterProperty('LogFile', '');

 //Logfile Section lock
 InitializeCriticalSection(FLock);

end;

//------------------------------------------------------------------------------
destructor  TIPSFHZDummy.Destroy;
begin

 //Save Settings
 try
 inherited;

 finally
 LeaveCriticalSection(FLock);
 DeleteCriticalSection(FLock);
 end;
end;

//------------------------------------------------------------------------------
procedure TIPSFHZDummy.LoadSettings();
begin
 inherited;
end;

//------------------------------------------------------------------------------
procedure TIPSFHZDummy.SaveSettings();
begin
 inherited;
end;

//------------------------------------------------------------------------------
procedure TIPSFHZDummy.ResetChanges();
begin
 inherited;
end;

//------------------------------------------------------------------------------
procedure TIPSFHZDummy.ApplyChanges();
begin
 inherited;

end;

//--------------------------------------------------------
//IIPSFHZ Implementation
{    IIPSFHZ. GetDataQueue() gibt es nicht mehr
function TIPSFHZDummy.GetFHTQueue(): TFHZQueueItems; stdcall;
var qis:TFHZQueueItems;
    qi:TFHZQueueItem;
    //t,e:TDateTime;
  id,c,i:integer;
  s,text:string;
  //text,prot,dest,db,desth,dbh:string;
  Intf: IInterface;
begin
  SendData('GetFHZQueue','invoked');
  if hasactiveparent then
    begin
      intf:=GetParent();
      if supports(intf,IIPSFHZ) then
      begin
        id:=(intf as IIPSmodule).GetInstanceID;
        text:=Format('Query Parent (ID: %d)',[id]);
        SendData('GetFHZQueue',text);
        outlog('GetFHZQueue:'+text);
        qis:=(intf as IIPSFHZ).GetDataQueue();
        c:=length(qis);
        text:=Format('Parent (ID:%d) returned %d entries)',[id,c]);
        SendData('GetFHZQueue',text);
        outlog('GetFHZQueue:'+text);
        i:=0;
        for qi in qis do
          begin
      //      t:=qi.QueueTime;
      //      e:=qi.ExecTime;
            s:=FHZQueueStatus[ord(qi.Status)];
            inc(i);
            text:=Format('Entry %d: Status %s)',[i,s]);
            SendData('GetFHZQueue',text);
            outlog('GetFHZQueue:'+text);
          end;
      end;
    end;
   Result:=qis;
end;
//------------------------------------------------------------------------------
function TIPSFHZDummy.GetDataQueue(): TFHZQueueItems; stdcall;
var qis:TFHZQueueItems;
    qi:TFHZQueueItem;
    //t,e:TDateTime;
  id,c,i:integer;
  s,text:string;
  //text,prot,dest,db,desth,dbh:string;
  Intf: IInterface;
begin
  SendData('GetDataQueue','invoked');
  if hasactiveparent then
    begin
      intf:=GetParent();
      if supports(intf,IIPSFHZ) then
      begin
        id:=(intf as IIPSmodule).GetInstanceID;
        SendData('GetDataQueue',Format('Query Parent (ID: %d)',[id]));
        qis:=(intf as IIPSFHZ).GetDataQueue();
        c:=length(qis);
        text:=Format('Parent (ID:%d) returned %d entries)',[id,c]);
        SendData('GetDataQueue',text);
        outlog('GetDataQueue:'+text);
        i:=0;
        for qi in qis do
          begin
      //      t:=qi.QueueTime;
      //      e:=qi.ExecTime;
            s:=FHZQueueStatus[ord(qi.Status)];
            inc(i);
            text:=Format('Entry %d: Status %s)',[i,s]);
            SendData('GetDataQueue',text);
            outlog('GetDataQueue:'+text);
          end;
      end;
    end;
    Result:=qis;
end;
}
//------------------------------------------------------------------------------
function TIPSFHZDummy.GetFreeBuffer(): Integer; stdcall;
var i,id:integer;
  Intf: IInterface;
  text:string;
begin
    i:=1;
    SendData('GetFreeBuffer','invoked');
    if hasactiveparent then
    begin
      intf:=GetParent();
      if supports(intf,IIPSFHZ) then
      begin
        id:=(intf as IIPSmodule).GetInstanceID;
        text:=Format('Query Parent (ID: %d)',[id]);
        SendData('GetFreeBuffer',text);
        outlog('GetFreeBuffer:'+text);
        i:=(intf as IIPSFHZ).GetFreeBuffer();
        text:=Format('Parent (ID:%d) returned: %d)',[id,i]);
        SendData('GetFreeBuffer',text);
        outlog('GetFreeBuffer:'+text);
      end;
    end;
    Result:=i;
end;
 //data points
//------------------------------------------------------------------------------
procedure TIPSFHZDummy.SendText(Text: String); stdcall;

begin
//forward to anywhere
SendData('TextSend',Text);
outlog ('TextSend:'+string2hex(Text)+' RAW:'+Text);
end;
//------------------------------------------------------------------------------
procedure TIPSFHZDummy.ReceiveText(Text: String); stdcall;


begin
  //entry point for data from parent
  //entry for data from parent
  sendData('TextReceive',Text);
  outlog ('TextReceive:'+string2hex(Text)+' RAW:'+Text);
end;
//------------------------------------------------------------------------------
procedure TIPSFHZDummy.SendFHZData(Data: TFHZDataTX; NumBytes: Byte); stdcall;
var text,prot,dest,db,action:string;
id:integer;
Intf: IInterface;
begin
    action:='';
    prot:=FHZProtocol[ord(data.protocol)];
    dest:=chr(data.DestByte1)+chr(data.DestByte2)+chr(data.DestByte3);
    db:=chr(data.DataByte1)+chr(data.DataByte2)+chr(data.DataByte3);
    case data.Protocol of
    fhzpFS20:
      begin
        action:='(Action='+fs20_codes.Values[btohex(data.databyte1)];
        if data.databyte1>31 then
          action:=action+' Timer:'+fs20_times[data.databyte2];
         action:=action +') ';
        text:=Format('NumB=%d,Prot=%s,Dest=%s(HC:%s),Data=%s %s',
      [NumBytes,prot,string2hex(dest), bin2four(leftstr(dest,3)),
        string2hex(db),action]);
      end;
     fhzpFHT:
      begin
       text:=Format('NumB=%d,Prot=%s,Dest=%s(HC:%02d %02d),Data=%s',
      [NumBytes,prot,string2hex(dest), data.DestByte1,data.DestByte2,
        string2hex(db)]);
      end;
      fhzpHMS:
      begin
       text:=Format('NumB=%d,Prot=%s,Dest=%s(DeviceID:%02x%02x),Data=%s',
      [NumBytes,prot,string2hex(dest), data.DestByte1,data.DestByte2,
        string2hex(db)]);
      end;
      else
      begin
       text:=Format('NumB=%d,Prot=%s,Dest=%s,Data=%s',
        [NumBytes,prot,string2hex(dest), string2hex(db)]);
      end;
    end;

    senddata('FHZSend',text);
    outlog(' FHZSend:'+text);

    if hasactiveparent then
    begin
      intf:=GetParent();
      if supports(intf,IIPSSendFHZ) then
      begin
        id:=(intf as IIPSmodule).GetInstanceID;
        text:=Format('Forward to Parent ID %d',[id]);
        SendData('FHZSend',text);
        outlog('FHZSend:'+text);
        (intf as IIPSSendFHZ).SendFHZData(Data,NumBytes);
      end;
    end;

end;
//------------------------------------------------------------------------------
  procedure TIPSFHZDummy.ReceiveFHZData(Data: TFHZDataRX); stdcall;
  var text,prot,dev,src,db,action:string;
    //id,
    a,b:integer;
    Intfs: TInterfaceList;
    Intf: IInterface;


  begin
     prot:=FHZProtocol[ord(data.protocol)];
     dev:=FHZDevice[ord(data.Device)];
    src:=chr(data.SrcsByte1)+chr(data.SrcsByte2)+chr(data.SrcsByte3)+chr(data.SrcsByte4);
    db:=chr(data.DataByte1)+chr(data.DataByte2)+chr(data.DataByte3)+chr(data.DataByte4);
      action:='';
      case data.Device of
        fhzdFS20:
        begin
          action:='(Action='+fs20_codes.Values[btohex(data.databyte1)];
		  if data.databyte1>31 then
			action:=action+' Timer:'+fs20_times[data.databyte2];
          action:=action +') ';
          text:=Format('Prot=%s,Dev=%s,DevB=%d,HC:%s(Src=%s),Data=%s %s',
            [prot,dev,ord(data.DeviceByte),bin2four(leftstr(src,3)),string2hex(src),
            string2hex(db),action]);
        end;
        fhzdFHT:
        begin
        case data.SrcsByte3 of
        0:action:=format('(Pos:%02x)',[data.DataByte2]);
        $42:action:=format('(Temp:%02.1f)',[data.DataByte2/10]);
        else
          action:='(Code:'+fht_codes.Values[btohex(data.SrcsByte3)]+')';
        end;
          text:=Format('Prot=%s,Dev=%s,DevB=%d,HC: %02d %02d(Src=%s),Data=%s %s',
            [prot,dev,ord(data.DeviceByte),
            data.SrcsByte1,data.SrcsByte2,
          string2hex(src),string2hex(db),action]);
        end;
        fhzdHMSTF,
        fhzdHMST:
        begin
          text:=string2hex(db);
          a:=(data.DataByte3 and $0f)*100;     //100er in Byte3 lower
          b:=(data.DataByte2 shr 4)*10;        //10er in Byte2 upper
          a:=a+b;
          b:=data.DataByte2 and $0F;           //1er in Byte2 lower
          a:=a+b;
          if (data.DataByte1 and $80)>0 then a:=-a;  //VZ in byte1 Bit7
          action:=Format('(Temp: %0.1f)',[a/10]);
          if data.Device=fhzdHMSTF then
          begin
            a:=(data.DataByte3 shr 4);     //1er in Byte3 upper
            b:=(data.DataByte4 shr 4)*100;        //100er in Byte4 upper
            a:=a+b;
            b:=(data.DataByte4 and $0F)*10;           //10er in Byte4 lower
            a:=a+b;
            action:=action + Format('(Hum: %0.1f)',[a/10]);
          end;
          text:=Format('Prot=%s,Dev=%s,DevB=%d,DeviceID: %02x %02x(Src=%s),Data=%s %s',
            [prot,dev,ord(data.DeviceByte),
            data.SrcsByte1,data.SrcsByte2,
          string2hex(src),string2hex(db),action]);
        end;

        fhzdHMSW ,
        fhzdHMS100RM,
        fhzdGasSensor1,
        fhzdGasSensor2,
        fhzdCOSensor:
        begin
          if (data.DataByte1=0) then
            action:='(OK)' else action:='(WARN)';
          text:=Format('Prot=%s,Dev=%s,DevB=%d,DeviceID: %02x %02x(Src=%s),Data=%s %s',
            [prot,dev,ord(data.DeviceByte),
            data.SrcsByte1,data.SrcsByte2,
          string2hex(src),string2hex(db),action]);
        end;
        fhzdHMS100TFK,
        fhzdSwitchIN:

        begin
          if (data.DataByte1=0) then
            action:='(OFF)' else action:='(ON)';
          text:=Format('Prot=%s,Dev=%s,DevB=%d,DeviceID: %02x %02x(Src=%s),Data=%s %s',
            [prot,dev,ord(data.DeviceByte),
            data.SrcsByte1,data.SrcsByte2,
          string2hex(src),string2hex(db),action]);
        end;
        {
        fhzdKS300: ;
        fhzdFIT: ;
        fhzdALW: ;
        }
      else
      begin
        text:=Format('Prot=%s,Dev=%s,DevB=%d,Src=%s Data=%s',
        [prot,dev,ord(data.DeviceByte),string2hex(src),
        string2hex(db)]);
      end;
    end;
    senddata('FHZReceive',text);
    outlog('FHZReceive:'+text);
    //try
      Intfs := GetChildren();
      if Intfs.Count>0 then
      begin
        for Intf in Intfs do begin
          if Supports(Intf, IIPSReceiveFHZ) then
          begin
            {
            id:=(intf as IIPSmodule).GetInstanceID;
            text:=Format('Forward to Child ID %d',[id]);
            SendData('FHZReceive',text);
            outlog('FHZReceive:'+text);
            }
            (Intf as IIPSReceiveFHZ).ReceiveFHZData(Data);
          end; //if
        end; //for
      end; //if
    //finally
      if assigned(Intfs) then
        Intfs.Free;
    //end; //try
  end; //function

//------------------------------------------------------------------------------
procedure TIPSFHZDummy.outlog(data:string);
var f:textfile;
  logfile,datum:string;
begin
  try
  DateTimetostring(datum,'yyyy-mm-dd hh:nn:ss',now);
  logfile:=GetProperty('LogFile');
  if logfile='' then exit;
  //save log writing
  EnterCriticalSection(FLock);
  assignfile(f,logfile);
 if fileexists(logfile) then
    append(f)
 else
      rewrite(f);
  writeln(f,datum,' ',data);
  flush(f);
  closefile(f);

  finally
  LeaveCriticalSection(FLock);
  end;

end;

end.
