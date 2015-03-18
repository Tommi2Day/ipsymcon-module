unit UM232Device;
//Thomas Dreßler (www.tdressler.net) 2009 - 2013
interface

uses Windows, SysUtils, Forms,
     UIPSTypes,UELV2interface,UIPSModuleTypes, UIPSDataTypes;


type
 //Create a Interfaced Class that is derived from TIPSModuleObject and the custom defined IIPSRegVar
 TIPSM232 = class(TIPSModuleObject,
                        IIPSModule,
                         IIPSReceiveString,
                        IIPSM232)
  private
   //--- Basic Structures
 M232Status        : Integer;
   M232Command       : char;
   M232Result        : integer;
   M232Channel       :  Integer;
   //--- Custom Objects
   //--- Private Procedures/Functions
   function M232SendData(Data:string):boolean; stdcall;
  function M232ReceiveData(Data:string):boolean;stdcall;
  //procedure SyncParent;

  //get/set
  {
  procedure SetDeviceID(DeviceID: String); stdcall;
   function GetDeviceID: String; stdcall;

  //function getio:integer;
  //function getCounter:integer;
  //function getAnalog(i:integer);
  //procedure Setio(v:integer);
  //procedure SetCounter(v:integer);
  //procedure SetAnalog(i:integer;v:integer);
   }
  protected
   procedure ProcessInstanceStatusChange(InstanceID: TInstanceID; Status: Integer); override;
   procedure ProcessKernelRunlevelChange(Runlevel: Integer); override;
  public

   //--- IIPSModule implementation
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

   //--- IIPS implementation
  function GetIOByte():integer; stdcall;
  function SetIOByte(States:integer): integer;stdcall;
  function GetIOBit(Bit:integer): integer;stdcall;
  function SetIOBit(Bit:integer; state: boolean): integer;stdcall;
  function SetCounterState(state: boolean): integer; stdcall;
  function GetCounterValue():integer; stdcall;
  function StartAnalog(command: integer): integer;stdcall;
  function GetAnalogValue(channel:integer):integer;stdcall;
  //--Data Point
  procedure SendText(Text:string); stdcall;
  procedure ReceiveText(Text:string); stdcall;

 end;

implementation
//commands
const cmdGetCounter ='z'; //'z'  return 4Byte (0000-FFFF)
const cmdSetCounter ='Z'; //'Z'  p1=0(Counter off),1(Counter on/reset)
const cmdGetIOByte ='w'; //'w'  return p1=Byte (IO states 00-FF)
const cmdSetIOByte ='W'; //'W' p1=Byte (IO states 00-FF)
const cmdSetIOBit ='D'; //'s' p1=Bit (0..7), p2=state (0/1)
const cmdGetIOBit ='d'; //'s' p1=Bit (0..7) return p1=(0/1) (IO state)
const cmdGetAnalog ='a'; //'a' p1=Byte (Kanal 0..5) 4Byte (000-3FF)+1(aktuell),0(schon gelesen)
const cmdStartAnalog ='M'; //'Z'  p1=Byte(0=manuell, 1-6=anzahl Kanäle(0..5) automatisch)

//------------------------------------------------------------------------------
class function TIPSM232.GetModuleID(): TStrGUID;
begin
 Result := GUIDToString(IIPSM232); //Will return Interface GUID
end;

//------------------------------------------------------------------------------
class function TIPSM232.GetModuleType(): TIPSModuleType;
begin
 Result := mtDevice;
end;

//------------------------------------------------------------------------------
class function TIPSM232.GetModuleName(): String;
begin
 Result := 'M232';
end;

//------------------------------------------------------------------------------
class function TIPSM232.GetParentRequirements(): TStrGUIDs;
begin

 SetLength(Result, 1);
 Result[0] := GUIDToString(IIPSSendString);

end;

//------------------------------------------------------------------------------
class function TIPSM232.GetImplemented(): TStrGUIDs;
begin
 SetLength(Result, 1);
 Result[0] := GUIDToString(IIPSReceiveString);
end;

//------------------------------------------------------------------------------
class function TIPSM232.GetVendor(): String;
begin
 Result := 'ELV';
end;

//------------------------------------------------------------------------------
class function TIPSM232.GetAliases(): TStringArray;
begin

 SetLength(Result, 1);
 Result[0] := 'M232';

end;

//------------------------------------------------------------------------------
constructor TIPSM232.Create(IKernel: IIPSKernel; InstanceID: TInstanceID);
var i:integer;
    z:string;
begin

 inherited;

 //RegisterProperty('DeviceID', '');
 RegisterVariable('IOVariable','IO',vtInteger);
 RegisterVariable('CounterVariable','Counter',vtInteger);
 for i:=0 to 5 do
   begin
      z:=inttostr(i);
      RegisterVariable('AnalogVariable'+z,'Analog\Channel '+z,vtInteger);
   end;

 //Check Parent
 RequireParent(IIPSSerialPort,false);

end;
 {
//------------------------------------------------------------------------------
destructor  TIPSM232.Destroy;
begin

 inherited;

end;

//------------------------------------------------------------------------------
procedure TIPSM232.LoadSettings();
begin
 inherited;

end;

//------------------------------------------------------------------------------
procedure TIPSM232.SaveSettings();
begin
 inherited;
end;

//------------------------------------------------------------------------------
procedure TIPSM232.ResetChanges();
begin
 inherited;
end;
}
//------------------------------------------------------------------------------
procedure TIPSM232.ApplyChanges();
begin

 inherited;
end;
 //--------------------------------------------------------
procedure TIPSM232.ProcessKernelRunlevelChange(Runlevel: Integer);
 var i:integer;
    z:string;
begin
 inherited;
 case Runlevel of
  KR_READY:begin
            ///syncparent;
            fKernel.VariableManager.WriteVariableInteger(GetStatusVariableID('IOVariable'), 0);
            fKernel.VariableManager.WriteVariableInteger(GetStatusVariableID('CounterVariable'), 0);
            for i:=0 to 5 do
            begin
              z:=inttostr(i);
              fKernel.VariableManager.WriteVariableInteger(GetStatusVariableID('AnalogVariable'+z), 0);
              //setAnalog(i,0);
            end;
        end;
 end;
end;
  //--------------------------------------------------------
procedure TIPSM232.ProcessInstanceStatusChange(InstanceID: TInstanceID; Status: Integer);
begin
 if InstanceID = fKernel.DataHandlerEx.GetInstanceParentID(fInstanceID) then

  if Status = IS_ACTIVE then
  begin
   ForceParentConfiguration(IIPSSerialControl,
    [
      'BaudRate', '=', '2400',
      'StopBits', '=', '1',
      'DataBits', '=', '8',
      'Parity', '=', 'None'
    ]);

  end;

  inherited;
end;


//------------------------------------------------------------------------------
procedure TIPSM232.SendText(Text: String); stdcall;
begin

 (GetParent() as IIPSSendString).SendText(Text);

end;
{
//--------------------------------------------------------
procedure TIPSM232.SyncParent();
var     DoUpdate: Boolean;
 parent:IIPSModule;
   // sp:IIPSSerialPort;
   // spdevs:TStringArray;
    desc,serial:string;

begin
if fKernel.DataHandlerex.GetInstanceParentID(fInstanceID) > 0 then
 parent:=getParent();

 if parent<>NIL then
 begin
  if supports(parent,IIPSSerialPort) then
  begin

    desc:=parent.GetProperty('Port');
    serial:=GetProperty('DeviceID');
    if desc='' then
    begin

    //klammer auf
      desc:=serial;
      spdevs:=sp.GetDevices();
      for serial in  spdevs do
      begin

        if desc='' then
        begin
          desc:=serial;
          SetProperty('DeviceID',serial);
        end;
        if desc=serial then break;
      end; //for
      //sp.SetPort(serial);
      //sp.SetOpen(true);
     //klammer zu
    if serial >'' then
       parent.SetProperty('Port',serial);
    end;//if getport
  end;  //support
 end; //parent



    if Supports(parent, IIPSSerialControl) then
     begin
      DoUpdate := False;

      if parent.GetProperty('BaudRate') <> '2400' then
       begin
        parent.SetProperty('BaudRate','2400');
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
      if parent.GetProperty('Parity') <> 'None' then
       begin
        parent.SetProperty('Parity','None');
        DoUpdate := True;
       end;
      if DoUpdate then
       begin
        parent.ApplyChanges;
       end;
    end; //if kernel
end;
}
{
//get/set
//------------------------------------------------------------------------------
procedure TIPSM232.SetDeviceID(DeviceID: String); stdcall;
begin

 if fChangedSettings.DeviceID = DeviceID then
  exit;
 fChangedSettings.DeviceID := DeviceID;
 SettingsChanged;

end;

//------------------------------------------------------------------------------
function TIPSM232.GetDeviceID: string; stdcall;
var id:String;
begin
 id:=fchangedSettings.DeviceID;
 Result := id;

end;
}
//DataPoint
//------------------------------------------------------------------------------
procedure TIPSM232.ReceiveText(Text:string);
begin
 SendData('Received', Text);
 M232ReceiveData(Text);

end;

 //------------------------------------------------------------------------------
function TIPSM232.M232ReceiveData(Data:string):boolean;
  //++++ start subfunc M232 specific
  function proceedM232Data(Data:string):boolean;
  //test without leading STX
  var Buffer,z: string;
  var state:boolean;

  begin
          Buffer:='';
          Result:=false;
          case M232command of
            cmdGetIOByte:begin
                if (Data[3]=chr(ACK)) then
                begin
                Buffer:='0x'+copy(Data,1,2);
                M232Result:=strtoint(Buffer);
                  //setIO(M232Result);
                  fKernel.VariableManager.WriteVariableInteger(GetStatusVariableID('IOVariable'), M232Result);
                  Buffer:='IO Byte received:'+Buffer+'('+inttostr(M232Result)+')';
                  M232Status:=USB_ACK;
                  Result:=true;
                end
                else M232Status:=USB_ERROR_ANTWORT;
                end;
            cmdGetIOBit: begin
              if (Data[2]=chr(ACK)) then
                begin
                M232Result:=ord(Data[1])-48;
                  //state:=bool(M232Result and 1);
                  //fSettings.SOutput:=USBResult;
                  //vVariableManager.WriteVarInteger(fsettings.VOutput, fSettings.SOutput);
                  Buffer:='IO Bit '+inttostr(M232Channel)+' received:'+inttohex(M232Result,2);
                  M232Status:=USB_ACK;
                  Result:=true;
                end
                else M232Status:=USB_ERROR_ANTWORT;
              end;
            cmdSetIOByte: begin
                if (Data[1]=chr(ACK)) then
                begin
                Buffer:='IO Byte set successfully';
                M232Status:=USB_ACK;
                  Result:=true;
                end
                else M232Status:=USB_ERROR_ANTWORT;
              end;
            cmdSetIOBit: begin
                if (Data[1]=chr(ACK)) then
                begin
                Buffer:='IO Bit '+inttostr(M232Channel)+' set';
                M232Status:=USB_ACK;
                  Result:=true;
                end
                else M232Status:=USB_ERROR_ANTWORT;
              end;
              cmdSetCounter: begin
                if (Data[1]=chr(ACK)) then
                begin
                Buffer:='Counter Command set successfully';
                M232Status:=USB_ACK;
                  Result:=true;
                end
                else M232Status:=USB_ERROR_ANTWORT;
              end;
              cmdStartAnalog: begin
                if Data[1]=chr(ACK) then
                begin
                Buffer:='Analog Command set successfully';
                M232Status:=USB_ACK;
                  Result:=true;
                end
                else M232Status:=USB_ERROR_ANTWORT;
              end;
              cmdGetCounter:begin
                if (Data[5]=chr(ACK)) then
                begin
                Buffer:='0x'+copy(Data,1,4);
                M232Result:=strtoint(Buffer);
                  fKernel.VariableManager.WriteVariableInteger(GetStatusVariableID('CounterVariable'), M232Result);
                  Buffer:='Counter Value received:'+Buffer;
                  M232Status:=USB_ACK;
                  Result:=true;
                end
                else M232Status:=USB_ERROR_ANTWORT;
                end;
              cmdGetAnalog:begin
                if (Data[5]=chr(ACK)) then
                begin
                Buffer:='0x'+copy(Data,1,3);
                M232Result:=strtoint(Buffer);
                if (Data[4]='1') then
                  state:=true
                else
                begin
                  state:=false;
                  M232Result:=M232Result+65536;
                end;

                  z:=inttostr(M232Channel);
                  fKernel.VariableManager.WriteVariableInteger(GetStatusVariableID('AnalogVariable'+z), M232Result);

                  Buffer:='Analog Value received:'+Buffer;
                  if (state) then
                    Buffer:=Buffer+' :new Value'
                  else
                    Buffer:=Buffer+' :old Value';

                  M232Status:=USB_ACK;
                  Result:=true;
                end
                else M232Status:=USB_ERROR_ANTWORT;
                end;

          end;
          SendData('Process Data', Buffer);


end;
  //+++++++ End subfunc

var index: integer;
begin
 {protocol <STH> (payload)<CR> without checksum
 answer:
 <DATA><ACK> OK
 <NAK> Error
}
index := length(Data);

   if (ord(data[index])=NAK ) then		//NACK==Error
  begin
    M232Status:=USB_NAK;
    Result:=false;
    exit;
  end;
	// look for ACK
	while ((index >= 0) and (ord(Data[index]) <> ACK))
		do
    begin
    index:=index-1;
    end;

	if (index < 0) then		//no terminating ACK==Error
  begin
    M232Status:=USB_ERROR_RAHMEN;
    Result:=false;
    exit;
  end;

  M232status:=USB_DATA;
  result:=(proceedM232Data(Data));

end;
 //------------------------------------------------------------------------------
function TIPSM232.M232SendData(Data:string):boolean;
{
//only to simulate, remove for Production

  procedure prepareTestResponse;
  var BufStr: TM232Data;
  var pBufStr:PM232Data;
  var l:integer;
  var r:string;
  begin
    for l:=0 to sizeof(BufStr)-1 do BufStr[l]:=chr(0);
    pBufStr:=@BufStr;
    case USBCommand of
      cmdGetInput:r:=#02'I'#00#06#03;
      cmdGetOutput:r:=#02'O'#122#06#03;
      cmdSetOutput:r:=#02'o'#06#03;
      cmdSetOutputBit:r:=#02#85#06#03;
    end;
    l:=Length(r);
    move(r,pBufStr,l);
    M232ReceiveData(pBufStr,l);
  end;
}
var Buffer,Text :String;
var i,datalen:integer;

begin

  datalen:=length(data);
  Buffer:=chr(STH);
  Text:=inttohex(STH,2)+' ';
  Buffer:=Buffer+Data;
  for i:=1 to datalen do
    begin
    Text:=Text+inttohex(ord(data[i]),2)+' ';
  end; //for

  //add CR
  Buffer:=Buffer+chr(CR);
  Text:=Text+inttohex(CR,2)+' ';

  SendData('Transmit', Text+' Len:'+inttostr(datalen+2));


  //send to FTDI
   sendText(Buffer);
   Result := false; //handled, default failed, wait for response
   M232status:=USB_PENDING;
   M232Result:=M232Status;

   //only to simulate, remove for production!
   //prepareTestResponse;

   //wait for response
   for i:=1 to 50 do
   begin
      if (M232status=USB_PENDING) then
      begin
          If GetCurrentThreadID = MainThreadID then
                      Application.ProcessMessages;
          sleep(10); //20*10 => max 200ms
          end
          else
            break;

   end; //for
      case M232status of
          USB_ACK: Result := true;
          USB_PENDING:M232status:=USB_ERROR_TIMEOUT;
      end;

      Buffer:='';
      case M232status of
            USB_ACK: Buffer:=Buffer+'OK';
            USB_NAK: Buffer:=Buffer+'FAILED';
            USB_DATA: Buffer:=Buffer+' Data received';
            USB_PENDING: Buffer:=Buffer+' waiting';
            USB_ERROR_RAHMEN: Buffer:=Buffer+' Frame Error';
            USB_ERROR_TIMEOUT: Buffer:=Buffer+'TIMEOUT';
            USB_ERROR_ANTWORT: Buffer:=Buffer+'Answer Error or not expected';
            USB_ERROR_UNBEKANNT: Buffer:=Buffer+'Unknown Answer';
      else
          Buffer:=Buffer+inttostr(M232Status);
      end;
      SendData('Answer', Buffer);

 end;
 //------------------------------------------------------------------------------
 function TIPSM232.GetIOByte(): integer;

var
  Buffer:string;
begin
  //'w'
  //command and value
  M232Command:=cmdGetIOByte;
  Buffer:=M232Command;

  //call send routine
  if (M232SendData(Buffer)) then
   Result := M232Result
    else
    Result := M232Status;

end;
 //------------------------------------------------------------------------------
 function TIPSM232.GetIOBit(Bit:integer): integer;

var Buffer:string;

begin
  //'d'
  //command and value
  M232Command:=cmdGetIOBit;
  M232Channel:=Bit;
  Buffer:=M232Command;
  Bit:=Bit and 7;
  Buffer:=Buffer+chr(ord('0')+ Bit);


  //call send routine
  if M232SendData(Buffer) then
   Result := M232Result
    else
    Result := M232Status;

end;
 //------------------------------------------------------------------------------
function TIPSM232.SetIOByte(States: integer): integer;

var Buffer,value:string;
begin
  //'o' p1=Output to set
  //command and value
    M232Command:=cmdSetIOByte;
    Buffer:=M232Command;
    value:=(inttohex((States and 255),2));
    buffer:=Buffer+copy(value,1,2);
  //call send routine

    if M232SendData(Buffer) then
   Result := M232Result
    else
    Result := M232Status;

end;

 //------------------------------------------------------------------------------
  function TIPSM232.SetIOBit(Bit:integer; state: boolean): integer;
var
  Buffer:string;

begin
  //'s' p1=Bit, p2=state
  //command and values
  M232Command:=cmdSetIOBit;
  M232Channel:=Bit;
  Buffer:=M232Command;
  Bit:=Bit and 7;
  Buffer:=Buffer+chr(ord('0')+ Bit);

  if (state) then Buffer:=Buffer+'1' else Buffer:=Buffer+'0';
  //call send routine
  if M232SendData(Buffer) then
   Result := M232Result
    else
    Result := M232Status;

end;

//------------------------------------------------------------------------------
 function TIPSM232.GetCounterValue(): integer;

var Buffer:string;

begin
  //'z'
  //command and value
  M232Command:=cmdGetCounter;
  Buffer:=M232Command;

  //call send routine
  if M232SendData(Buffer) then
   Result := M232Result
    else
    Result := M232Status;

end;

 //------------------------------------------------------------------------------
function TIPSM232.SetCounterState(state: boolean): integer;

var Buffer: string;


begin
  //'Z' p1=Output to set
  //command and value
    M232Command:=cmdSetCounter;
    Buffer:=M232Command;
    if (state) then Buffer:=Buffer+'1' else Buffer:=Buffer+'0';

  //call send routine

    if M232SendData(Buffer) then
   Result := M232Result
    else
    Result := M232Status;

end;

//------------------------------------------------------------------------------
 function TIPSM232.GetAnalogValue(channel:integer): integer;

var Buffer:string;

begin

  //'a'
  //command and value
  M232Command:=cmdGetAnalog;
  Buffer:=M232Command;
  if ((channel>5) or (channel<0)) then
  begin
    M232Status:=-1;
    Result:=M232Status;
    exit;
  end;
  M232Channel:=channel;
  Buffer:=Buffer+chr(ord('0')+ channel);
  //call send routine

  if M232SendData(Buffer) then
   Result := M232Result
    else
    Result := M232Status;

end;

 //------------------------------------------------------------------------------
function TIPSM232.StartAnalog(Command: integer): integer;

var Buffer:string;

begin
  //'Z' p1=Output to set
      //command and value
    M232Command:=cmdStartAnalog;
    Buffer:=M232Command;
    if ((Command>6) or (Command<0)) then
    begin
      M232Status:=-1;
      Result:=M232Status;
      exit;
    end;
    Buffer:=Buffer+chr(ord('0')+ Command);


  //call send routine

    if M232SendData(Buffer) then
   Result := M232Result
    else
    Result := M232Status;

end;

end.

