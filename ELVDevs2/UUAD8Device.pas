unit UUAD8Device;
//Thomas Dreßler (www.tdressler.net) 2009 -2013
interface

uses Windows, SysUtils, Forms, StrUtils,
     UIPSTypes, UIPSModuleTypes,UIPSDataTypes,UELV2Interface;

type
TIPSUAD8 = class(TIPSModuleObject,
                       IIPSModule,
                       IIPSReceiveString,
                        IIPSUAD8)
  private
   //--- Basic Structures
   USBStatus        : Integer;
   //ftimer:          TTimerID;
   UAD8channel      :Integer;
   UAD8value        :double;
   //--- Custom Objects
   //--- Private Procedures/Functions
{
   function getConfig:integer; stdcall;
   procedure setConfig(value:integer); stdcall;
   }
   function SendConfig: boolean; stdcall;
    function getChannel(channel:integer):boolean; stdcall;
   procedure setChannel(channel:integer;status:boolean);stdcall;
    function UAD8SendData(Data:string):boolean;
  function UAD8ReceiveData(Data:string):boolean;
//  procedure syncparent;
    protected
   procedure ProcessInstanceStatusChange(InstanceID: TInstanceID; Status: Integer);override;
   //procedure ProcessKernelRunlevelChange(Runlevel: Integer); override;

  public
  constructor Create(IKernel: IIPSKernel; InstanceID: TInstanceID); override;
  {
   destructor  Destroy; override;
   //--- IIPSModule implementation
   procedure LoadSettings(); override;
   procedure SaveSettings(); override;
   procedure ResetChanges(); override;
   }
   procedure ApplyChanges(); override;
   { Class Functions }
   class function GetModuleID(): TStrGUID; override;
   class function GetModuleType(): TIPSModuleType; override;
   class function GetModuleName(): String; override;
   class function GetParentRequirements(): TStrGUIDs; override;
   class function GetImplemented(): TStrGUIDs; override;
   class function GetVendor(): String; override;
   class function GetAliases(): TStringArray; override;

  function ActivateChannel(channel:integer;status:boolean):boolean; stdcall;
//  function UAD8_Calibrate:HRESULT; stdcall;
  function GetData(channel :integer): double; stdcall;
  function RunTest: boolean; stdcall;


  //--Data Point
  procedure SendText(Text:string); stdcall;
  procedure ReceiveText(Text:string);stdcall;

 end;

implementation


const UAD8MaxChannels=8;

//commands
const cmdConfig =$6b; //'k' 0x6b
const cmdMax =$6d; //'m' 0x6d
const cmdOffset =$6f; //'o' 0x6f
//------------------------------------------------------------------------------
class function TIPSUAD8.GetModuleID(): TStrGUID;
begin
 Result := GUIDToString(IIPSUAD8); //Will return Interface GUID
end;

//------------------------------------------------------------------------------
class function TIPSUAD8.GetModuleType(): TIPSModuleType;
begin
 Result := mtDevice;
end;

//------------------------------------------------------------------------------
class function TIPSUAD8.GetModuleName(): String;
begin
 Result := 'UAD8';
end;

//------------------------------------------------------------------------------
class function TIPSUAD8.GetParentRequirements(): TStrGUIDs;
begin

 SetLength(Result, 1);
 Result[0] := GUIDToString(IIPSSendString);

end;

//------------------------------------------------------------------------------
class function TIPSUAD8.GetImplemented(): TStrGUIDs;
begin
 SetLength(Result, 1);
 Result[0] := GUIDToString(IIPSReceiveString);
end;

//------------------------------------------------------------------------------
class function TIPSUAD8.GetVendor(): String;
begin
 Result := 'ELV';
end;

//------------------------------------------------------------------------------
class function TIPSUAD8.GetAliases(): TStringArray;
begin

 SetLength(Result, 1);
 Result[0] := 'UAD8';

end;

//------------------------------------------------------------------------------
constructor TIPSUAD8.Create(IKernel: IIPSKernel; InstanceID: TInstanceID);

var z:string;
  i:integer;
begin

 inherited;

 //RegisterProperty('DeviceID','');
 RegisterProperty( 'Channels',0);


 for i:=1 to UAD8MaxChannels do
 begin
   z:=inttostr(i);
   RegisterVariable('ChannelVariable'+z,'Channel_'+z,vtFloat);
 end;


 //Check Parent
 RequireParent(IIPSFTDI,true);

end;
{
//------------------------------------------------------------------------------
destructor  TIPSUAD8.Destroy;
begin

 inherited;

end;

//------------------------------------------------------------------------------
procedure TIPSUAD8.LoadSettings();
begin
 inherited;
end;

//------------------------------------------------------------------------------
procedure TIPSUAD8.SaveSettings();
begin
 inherited;
end;

//------------------------------------------------------------------------------
procedure TIPSUAD8.ResetChanges();
begin

 inherited;
end;
}
//------------------------------------------------------------------------------
procedure TIPSUAD8.ApplyChanges();
begin
 inherited;
 //syncparent;
end;
//--------------------------------------------------------
procedure TIPSUAD8.ProcessInstanceStatusChange(InstanceID: TInstanceID; Status: Integer);
begin

 if InstanceID = fKernel.DataHandlerEx.GetInstanceParentID(fInstanceID) then

  if Status = IS_ACTIVE then
  begin
   ForceParentConfiguration(IIPSSerialControl,
    [
      'BaudRate', '=', '38400',
      'StopBits', '=', '1',
      'DataBits', '=', '8',
      'Parity', '=', 'Even'
    ]);

  end;

 inherited;

end;
{
//------------------------------------------------------------------------------
procedure TIPSUAD8.SyncParent();
var
    DoUpdate: Boolean;
    parent:IIPSModule;
    //ftdi:IIPSFTDI;
    //ftdidev:TFTDIDevice;
    //ftdidevs:TFTDIDevices;
    desc,serial:string;
CONST ELV_STRING='ELV USB-AD-Wandler';
begin
if fKernel.DataHandlerex.GetInstanceParentID(fInstanceID) > 0 then
 parent:=getParent();

 if parent<>NIL then
 begin

  if supports(parent,IIPSFTDI) then
  begin

    desc:=parent.GetProperty('Port');
    serial:=GetProperty('DeviceID');
    if desc='' then
    begin
     //klammer auf
      ftdidevs:=ftdi.GetDevices();
      for ftdidev in  ftdidevs do
      begin
        desc:=ftdidev.Description;
        if (desc=ELV_STRING) then
        begin
         if not ftdidev.InUse then
         begin
           serial:=ftdidev.SerialNumber;
           if fchangedsettings.DeviceID='' then fchangedsettings.DeviceID:=serial;
           if fchangedsettings.DeviceID=serial then break;
          end;//in use
        end;

      end; //for
      ftdi.SetPort(serial);
      ftdi.SetOpen(true);
      //klammer zu
      if serial >'' then
       parent.SetProperty('Port',serial);
    end;//if getport

  end; //support
 end;//parent



    if Supports(parent, IIPSSerialControl) then
     begin
      DoUpdate := False;

      if parent.GetProperty('BaudRate') <> '38400' then
       begin
        parent.SetProperty('BaudRate','38400');
        DoUpdate := True;
       end;
      if parent.GetProperty('StopBits') <> '1' then
       begin
        parent.SetProperty('StopBits','1');
        DoUpdate := True;
       end;
      if parent.GetProperty('DataBits') <> '8' then
       begin
        parent.SetProperty('DataBits','8');
        DoUpdate := True;
       end;
      if parent.GetProperty('Parity') <> 'Even' then
       begin
        parent.SetProperty('Parity','Even');
        DoUpdate := True;
       end;
      if DoUpdate then
       begin
        parent.ApplyChanges;
       end;
    end;

end;
}
///Get/Set
//------------------------------------------------------------------------------
function TIPSUAD8.getChannel(channel:integer):boolean;
var b:integer;
begin
    b:=1 shl channel;
     result:=((GetProperty('Channels') and b)=b);
end;
{
//------------------------------------------------------------------------------
   function TIPSUAD8.getConfig:integer;stdcall;
   begin
    result:=fchangedsettings.channels;
   end;
   //------------------------------------------------------------------------------
   procedure TIPSUAD8.setConfig(value:integer);stdcall;
   begin
    fchangedsettings.channels:=value;
    settingschanged;
   end;
}
//------------------------------------------------------------------------------
procedure TIPSUAD8.setChannel(channel:integer;status:boolean);stdcall;
var v,b:integer;
begin
       v:=getProperty('Channels');
       b:=(not(1 shl channel));
       if status then v:=v or b else v:=(v and  b);
       setProperty('Channels',v);
end;

//Datapoint
//------------------------------------------------------------------------------
procedure TIPSUAD8.SendText(Text: String);stdcall;
begin

 (GetParent() as IIPSSendString).SendText(Text);

end;
//------------------------------------------------------------------------------
procedure TIPSUAD8.ReceiveText(Text:string); stdcall;
begin

 SendData('Received', Text);
 UAD8ReceiveData(Text);

end;

 //------------------------------------------------------------------------------
function TIPSUAD8.UAD8ReceiveData(Data:string):boolean;

var index: integer;
var last:  integer;
var z,datalen: integer;
var c:char;
Buffer:string;
begin
 {protocol <STX> (payload)<ETX> without checksum
 without usual replacing
  answer:
 <STX><ACK><ETX> OK
 <STX><NAK><ETX> Error
}


Result:=false;
datalen:=length(data);
index := datalen ;
	// look for ETX
	while ((index >= 0) and (ord(Data[index]) <> ETX))
		do
    begin
    index:=index-1;
    end;

	if (index < 1) then		//no terminating ETX==Error
  begin
    USBStatus:=USB_ERROR_RAHMEN;
    exit;
  end;

	last := index; //position of ETX == last message byte

	// look backwards for STX
	while ((index >= 0) and (ord(Data[index]) <> STX)) do
    begin
		index:=index-1;
    end;

	if (index < 1) then   //no STX found ==Error
  begin

    USBStatus:=USB_ERROR_RAHMEN;
    exit;
  end;
	index:=index+1; //index now on position of first payload byte
  z:=last-index;
	if (z < 1) then   //if no payload (<STX><ETX>) == Error
    begin

    USBStatus:=USB_ERROR_RAHMEN;
    exit;
    end;


  //no decodes needed for UAD8
  //fill target puffer
  Buffer:=copy(Data,index,z);
  Result := true; //handled
  c:=Buffer[1];
  case ord(c) of
    ACK: USBstatus:=USB_ACK;
    NAK: USBstatus:=USB_NAK;
    48..57:   if(length(Buffer)=4) then
              begin
                UAD8value:=strtoint(Buffer)/1000;
                fKernel.VariableManager.WriteVariableFloat(GetStatusVariableID('ChannelVariable'+c), UAD8Value);
              end else begin
                Result:=false;
              end; //if
    else
          begin
            USBstatus:=USB_ERROR_UNBEKANNT;
            Result := false;
         end
    end;

end;
 //------------------------------------------------------------------------------
function TIPSUAD8.UAD8SendData(data:string):boolean;
var Buffer,Text,c :String;
var i,datalen:integer;
//var c:char;
begin


 datalen:=length(Data);
  Buffer:=chr(STX);
  Text:=inttohex(STX,2)+' ';

  for i:=1 to datalen do
    begin
    // No Translation STX,ETX and ENQ needed
    Text:=Text+inttohex(ord(Data[i]),2)+' ';
  end; //for

  //add ETX
  Buffer:=Data;
  Buffer:=Buffer+chr(ETX);
  Text:=Text+inttohex(ETX,2)+' ';


  SendData('TRansmit', Text+' Len:'+inttostr(length(Buffer)));

  //send to FTDI
   SendText(Buffer);
   Result := false; //handled, default failed, wait for response
   USBstatus:=USB_PENDING;
   //wait for response
   for i:=1 to 50 do
      begin
        case USBstatus of
          USB_DATA,
          USB_ACK: begin
                Result := true;
                break;
                end;
          USB_NAK:break;
         else
         begin
          If GetCurrentThreadID = MainThreadID then
            Application.ProcessMessages;
            sleep(10); //50*10 => max 500ms
            end
        end; //case
      end; //for
      if (USBstatus=USB_PENDING) then USBstatus:=USB_ERROR_TIMEOUT;

      Buffer:='';
      Buffer:='';
      case USBstatus of
            USB_ACK: Buffer:=Buffer+'OK';
            USB_NAK: Buffer:=Buffer+'FAILED';
            USB_DATA: begin
                      c:=inttostr(UAD8channel);
                      Buffer:=Buffer+' Data received-->';
                      Buffer:=Buffer+'Channel='+c+' Value='+floattostr(UAD8Value);
                      //set variables
                      if  (getchannel(UAD8channel)) then
                        fKernel.VariableManager.WriteVariableFloat(GetStatusVariableID('ChannelVariable'+c), UAD8Value);
                          //variable;
                      end;
            USB_PENDING: Buffer:=Buffer+' waiting';
            USB_ERROR_RAHMEN: Buffer:=Buffer+' Frame Error';
            USB_ERROR_TIMEOUT: Buffer:=Buffer+'TIMEOUT';
            USB_ERROR_ANTWORT: Buffer:=Buffer+'Answer Error or not expected';
            USB_ERROR_UNBEKANNT: Buffer:=Buffer+'Unknown Answer';
      else
          Buffer:=Buffer+inttostr(USBStatus);
      end;
      SendData( 'Answer', Buffer);

 end;
 //------------------------------------------------------------------------------
 function TIPSUAD8.SendConfig:boolean;stdcall;

var Buffer :String;
var b:byte;
const addChar='0';
begin
  //0x6b 'k' prepare config byte

  b:=(getProperty('Channels') and $FF);
    //rotate active flags into config byte
//  for i:=1 to UAD8MaxChannels do
//      begin
//        if (getchannel(i)) then a:=1 else a:=0;
//        b:=b+(a shl (i-1));
//  end;
    //add '0' 0x30 as described into manual
    b:=b+ord(addChar);
  //command and config byte
    Buffer:=chr(cmdConfig);
    Buffer:=Buffer+chr(b);


    SendData('SendConfig',inttohex(b,2) );
    //call send routine
    Result:=(UAD8SendData(Buffer));
    if result then
      SendData('SendConfig','OK' ) else SendData('SendConfig','Failed' );

end;
 //------------------------------------------------------------------------------
function TIPSUAD8.ActivateChannel(channel:integer; status:boolean): boolean; stdcall;
begin


  if ((channel >0) and (channel <= UAD8MaxChannels)) then
  begin
    setChannel(channel,status);
    Result:=SendConfig;
  end
  else
  begin
    SendData( 'Activate','Wrong Channel requested:'+inttostr(channel));
    result:=false;
  end;
end;
 //------------------------------------------------------------------------------
 function TIPSUAD8.GetData(channel :integer): double; stdcall;
var c: string;
begin

  //command(ascii(channel)
  if ((channel>0) and (channel<=UAD8MaxChannels))  then
  begin
    UAD8Channel:=channel;
    c:=chr(channel+48);
    SendData('GetData','Channel '+inttostr(channel)+' data requested');

    //call send routine
    if (UAD8SendData(c)) then
    begin
    //data stored into settings
      Result:=UAD8value

    end
    else
      //return negative value as Error indicator
      Result:=USBstatus;

  end
  else
  begin
      SendData('GetData','Wrong Channel requested:'+c);
      Result:=USB_ERROR_CHANNEL;
   end;
   SendData('GetData','Channel '+c+' returned'+floattostr(Result));
end;
 //------------------------------------------------------------------------------
 {
 function TIPSUAD8.UAD8_Calibrate: HRESULT; stdcall;
begin
     Result:=E_NOTIMPL;
end;
}
//end;


//------------------------------------------------------------------------------
function TIPSUAD8.RunTest: boolean; stdcall;
var i: integer;
var value:double;
begin


 if (SendConfig) then
 begin
  for i:=1 to UAD8MaxChannels do
  begin

    if (getChannel(i)) then
    begin
      value:=GetData(i);
      if (value<0) then
        SendData('Test','Channel '+inttostr(i)+' returned Error: '+floattostr(value))
      else
         SendData('Test','Channel '+inttostr(i)+' returned '+floattostr(value)+' Volt');
    end
    else
      SendData('Test','Channel '+inttostr(i)+' not active, skipping...');


  end; //for
  end;//if config

 Result := true;
end;
end.

