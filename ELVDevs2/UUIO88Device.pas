unit UUIO88Device;
//Thomas Dreßler (www.tdressler.net) 2009 - 2013
interface

uses sysutils,forms, windows,
     UIPSTypes, UIPSModuleTypes,UIPSDataTypes,UELV2Interface;
//Defines a record that holds all Instance Settings
//------------------------------------------------------------------------------

 type
 //Create a Interfaced Class that is derived from TIPSModuleObject and the custom defined IIPSRegVar
 TIPSUIO88 = class(TIPSModuleObject,
                        IIPSModule,
                          IIPSReceiveString,
                        IIPSUIO88)
  private
   //--- Basic Structures
   USBStatus        : Integer;
   USBcommand       : char;
   USBResult        : integer;
   //--- Custom Objects
   //--- Private Procedures/Functions
   function UIO88SendData(Data:String):boolean;
  function UIO88ReceiveData(Data:string):boolean;

   //--- Custom Objects
   //--- Private Procedures/Functions
   {
  function getin:integer; stdcall;
  function getOut:integer; stdcall;
  procedure Setin(v:integer); stdcall;
  procedure Setout(v:integer);stdcall;
  }
  //procedure syncparent;
   protected
   procedure ProcessInstanceStatusChange(InstanceID: TInstanceID; Status: Integer);override;
   //procedure ProcessKernelRunlevelChange(Runlevel: Integer); override;


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
  function GetInput():integer; stdcall;
  function SetOutput(States:integer): integer; stdcall;
  function GetOutput(): integer; stdcall;
  function SetOutputBit(Bit:integer; state: boolean): integer;stdcall;
  //--Data Point
  procedure SendText(Text:string); stdcall;
  procedure ReceiveText(Text:string); stdcall;

 end;



implementation
//commands
const cmdGetInput ='I'; //'I'  return p1=Byte (input states)
const cmdGetOutput ='O'; //'O' return p1=Byte (output states)
const cmdSetOutput ='o'; //'o' return p1=Byte (output states)
const cmdSetOutputBit ='s'; //'s' p1=Bit (0..7), p2=state (0/1) return p1=Byte (output states)

//------------------------------------------------------------------------------
class function TIPSUIO88.GetModuleID(): TStrGUID;
begin
 Result := GUIDToString(IIPSUIO88); //Will return Interface GUID
end;

//------------------------------------------------------------------------------
class function TIPSUIO88.GetModuleType(): TIPSModuleType;
begin
 Result := mtDevice;
end;

//------------------------------------------------------------------------------
class function TIPSUIO88.GetModuleName(): String;
begin
 Result := 'UIO88';
end;

//------------------------------------------------------------------------------
class function TIPSUIO88.GetParentRequirements(): TStrGUIDs;
begin

 SetLength(Result, 1);
 Result[0] := GUIDToString(IIPSSendString);

end;

//------------------------------------------------------------------------------
class function TIPSUIO88.GetImplemented(): TStrGUIDs;
begin
 SetLength(Result, 1);
 Result[0] := GUIDToString(IIPSReceiveString);
end;

//------------------------------------------------------------------------------
class function TIPSUIO88.GetVendor(): String;
begin
 Result := 'ELV';
end;

//------------------------------------------------------------------------------
class function TIPSUIO88.GetAliases(): TStringArray;
begin

 SetLength(Result, 2);
 Result[0] := 'UIO88';
 Result[1] := 'IO88';

end;

//------------------------------------------------------------------------------
constructor TIPSUIO88.Create(IKernel: IIPSKernel; InstanceID: TInstanceID);
begin

 inherited;

 //RegisterProperty('DeviceID','');
 RegisterProperty( 'Input',0);
 RegisterProperty( 'Output',0);
 RegisterVariable('InVariable','Input',vtInteger);
 RegisterVariable('OutVariable','Output',vtInteger);


 //Check Parent
 RequireParent(IIPSFTDI,false);

end;
{
//------------------------------------------------------------------------------
destructor  TIPSUIO88.Destroy;
begin

 inherited;

end;

//------------------------------------------------------------------------------
procedure TIPSUIO88.LoadSettings();
begin
 inherited;


end;

//------------------------------------------------------------------------------
procedure TIPSUIO88.SaveSettings();
begin
 inherited;
end;

//------------------------------------------------------------------------------
procedure TIPSUIO88.ResetChanges();
begin

 inherited;
end;
}
//------------------------------------------------------------------------------
procedure TIPSUIO88.ApplyChanges();
begin
 inherited;
 //syncparent;
end;
//--------------------------------------------------------
procedure TIPSUIO88.ProcessInstanceStatusChange(InstanceID: TInstanceID; Status: Integer);
begin

 if InstanceID = fKernel.DataHandlerEx.GetInstanceParentID(fInstanceID) then

  if Status = IS_ACTIVE then
  begin
   ForceParentConfiguration(IIPSSerialControl,
    [
      'BaudRate', '=', '9600',
      'StopBits', '=', '1',
      'DataBits', '=', '8',
      'Parity', '=', 'Even'
    ]);

  end;

 inherited;

end;
{
//------------------------------------------------------------------------------
procedure TIPSUIO88.SyncParent();
var
    DoUpdate: Boolean;
    parent:IIPSModule;
    //ftdi:IIPSFTDI;
    //sp:IIPSSerialPort;
    //spdevs:TStringArray;
    //ftdidev:TFTDIDevice;
    //ftdidevs:TFTDIDevices;
    desc,serial:string;
CONST ELV_STRING='ELV USB-I/O-Interface';
begin
if fKernel.DataHandlerex.GetInstanceParentID(fInstanceID) > 0 then
 parent:=getParent();
 if parent<>NIL then
 begin

  if supports(parent,IIPSFTDI) then
  begin

    desc:=(parent as IIPSModule).GetProperty('Port');
    serial:=GetProperty('DeviceID');
    if desc='' then
    begin
    //klammerauf
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


    //klammerzu
    if serial >'' then
       parent.SetProperty('Port',serial);
    end;//if getport


  end//supports ftdi
  else
  begin

    if supports(parent,IIPSSerialPort) then
    begin

      desc:=parent.GetProperty('Port');

      if desc='' then
      begin
       //klammerauf
      desc:=GetProperty('DeviceID');
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
      if serial >'' then
       parent.SetProperty('Port',serial);
    //klammerzu
      end;//if getport

    end;  //support sERIALPORT

  end;

 end; //parent




    if Supports(parent, IIPSSerialControl) then
     begin
      DoUpdate := False;

      if parent.GetProperty('BaudRate') <> '9600' then
       begin
        parent.SetProperty('BaudRate','9600');
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
{
//Get/Set
 //------------------------------------------------------------------------------
function TIPSUIO88.getIn:integer;
begin
Result:=fchangedsettings.SInput;
end;

//------------------------------------------------------------------------------
procedure  TIPSUIO88.setIn(v: Integer);
begin
   fchangedsettings.SInput:=v;

end;
 //------------------------------------------------------------------------------
function TIPSUIO88.getOut:integer;
begin
Result:=fchangedsettings.SInput;
end;

//------------------------------------------------------------------------------
procedure  TIPSUIO88.setOut(v: Integer);
begin
   fchangedsettings.SOutput:=v;
end;
}
//------------------------------------------------------------------------------
procedure TIPSUIO88.SendText(Text: String); stdcall;
begin
  SendData('Send',Text);
  if hasactiveparent then
    (GetParent() as IIPSSendString).SendText(Text)
  else
     SendData('Send','No Parent');

end;
//------------------------------------------------------------------------------
procedure TIPSUIO88.ReceiveText(Text: String); stdcall;
begin

 SendData('Receive',Text);
 UIO88ReceiveData(Text);

end;



 //------------------------------------------------------------------------------
function TIPSUIO88.UIO88ReceiveData(Data:String):boolean;
  //++++ start subfunc UIO88 specific
var index: integer;
var last:  integer;
var z,datalen: integer;
var c:char;

  Buffer:string;
begin

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

	if ((last - index) < 1) then   //if no payload (<STX><ETX>) == Error
    begin

    USBStatus:=USB_ERROR_RAHMEN;
    exit;
    end;

  //decode replacements and fill target puffer
  z:=index;
  while (z<last) do
  begin
    c:=Data[z];
    if (c=chr(ENQ)) then
    begin
      z:=z+1;
      c:=Data[z];
      case ord(c) of
        DC2:c:=chr(STX);
        DC3:c:=chr(ETX);
        NAK:c:=chr(ENQ);
      end;
    end;
    Buffer:=Buffer+c;
    z:=z+1;
  end;

  USBstatus:=USB_ERROR_UNBEKANNT;

          Result:=false;
          case USBcommand of
            cmdGetInput:begin
                if ((Buffer[1]=cmdGetInput) and (Buffer[3]=chr(ACK))) then
                begin
                USBResult:=ord(Buffer[2]);
                  SetProperty('Input',USBResult);
                  SendData('Proceed','Input Byte received:'+inttohex(USBResult,2));
                  fKernel.VariableManager.WriteVariableInteger(GetStatusVariableID('InVariable'), USBResult);
                  USBStatus:=USB_ACK;
                  Result:=true;
                end
                else USBStatus:=USB_ERROR_ANTWORT;
                end;
            cmdGetOutput: begin
              if ((Buffer[1]=cmdGetOutput) and (Buffer[3]=chr(ACK))) then
                begin
                USBResult:=ord(Buffer[2]);
                  SetProperty('Output',USBResult);
                  SendData('Proceed','Output Byte received:'+inttohex(USBResult,2));
                  fKernel.VariableManager.WriteVariableInteger(GetStatusVariableID('OutVariable'), USBResult);
                  USBStatus:=USB_ACK;
                  Result:=true;

                end
                else USBStatus:=USB_ERROR_ANTWORT;
              end;
            cmdSetOutput: begin
                if ((Buffer[1]=cmdSetOutput) and (Buffer[2]=chr(ACK))) then
                begin
                SendData('Proceed','Output Byte set:'+inttohex(USBResult,2));
                fKernel.VariableManager.WriteVariableInteger(GetStatusVariableID('OutVariable'), USBResult);
                USBStatus:=USB_ACK;
                Result:=true;
                end
                else USBStatus:=USB_ERROR_ANTWORT;
              end;
            cmdSetOutputBit: begin
                if (Buffer[2]=chr(ACK)) then
                begin
                USBResult:=ord(Buffer[1]);
                SetProperty('Output',USBResult);
                fKernel.VariableManager.WriteVariableInteger(GetStatusVariableID('OutVariable'), USBResult);
                SendData('Proceed','Output Bit set, new Byte received:'+inttohex(USBResult,2));
                  USBStatus:=USB_ACK;
                  Result:=true;
                end
                else USBStatus:=USB_ERROR_ANTWORT;
              end;
          end;
          SendData('Proceed', 'finished');

end;
 //------------------------------------------------------------------------------
function TIPSUIO88.UIO88SendData(Data:string):boolean;
{
//only to simulate, remove for Production

  procedure prepareTestResponse;

  var l:integer;
  var r,buffer:string;
  begin
    case USBCommand of
      cmdGetInput:r:=#02'I'#00#06#03;
      cmdGetOutput:r:=#02'O'#122#06#03;
      cmdSetOutput:r:=#02'o'#06#03;
      cmdSetOutputBit:r:=#02#85#06#03;
    end;

    UIO88ReceiveData(Buffer);
  end;
}
var Buffer,Text :String;
var i,datalen:integer;
var c:char;
begin

 datalen:=length(Data);
  Buffer:=chr(STX);
  Text:=inttohex(STX,2)+' ';

  for i:=1 to datalen do
    begin
    c:=Data[i];
    //Translate STX,ETX and ENQ from payload according table

    case ord(c) of
      STX:begin   //STX->ENQ DC2
            Buffer:=Buffer+chr(ENQ);
            c:=chr(DC2);

            Text:=Text+inttohex(ENQ,2)+' ';
          end;
      ETX:begin    //ETX->ENQ DC3
            Buffer:=Buffer+chr(ENQ);
            c:=chr(DC3);

            Text:=Text+inttohex(ENQ,2)+' ';
          end;
      ENQ:begin  //ENQ->ENQ NAK
            Buffer:=Buffer+chr(ENQ);
            c:=chr(NAK);

            Text:=Text+inttohex(ENQ,2)+' ';
          end;
    end; //case

    Buffer :=Buffer+c;
    Text:=Text+inttohex(ord(c),2)+' ';
  end; //for

  //add ETX

  Buffer:=Buffer+chr(ETX);
  Text:=Text+inttohex(ETX,2)+' ';


  SendData('TRansmit', Text+' Len:'+inttostr(length(Buffer)));

//send to FTDI
   SendText(Buffer);
   Result := false; //handled, default failed, wait for response
   USBstatus:=USB_PENDING;
   //only to simulate, remove for production!
   //prepareTestResponse;

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
      case USBstatus of
            USB_ACK: Buffer:=Buffer+'OK';
            USB_NAK: Buffer:=Buffer+'FAILED';
            USB_DATA: Buffer:=Buffer+' Data received';
            USB_PENDING: Buffer:=Buffer+' waiting';
            USB_ERROR_RAHMEN: Buffer:=Buffer+' Frame Error';
            USB_ERROR_TIMEOUT: Buffer:=Buffer+'TIMEOUT';
            USB_ERROR_ANTWORT: Buffer:=Buffer+'Answer Error or not expected';
            USB_ERROR_UNBEKANNT: Buffer:=Buffer+'Unknown Answer';
      else
          Buffer:=Buffer+inttostr(USBStatus);
      end;

      SendData('Transmit','Answer for sended data: '+ Buffer);

 end;
 //------------------------------------------------------------------------------
 function TIPSUIO88.GetInput(): integer;
var  Buffer:string;
begin
  //'I'
  SendData('GetInput', 'entered');
  //command and value
  USBCommand:=cmdGetInput;
  Buffer:=USBCommand;
  //call send routine
  if (UIO88SendData(buffer)) then
   Result := USBResult
    else
    Result := USBStatus;
  SendData('GetInput', 'Result:'+inttostr(Result));
end;
 //------------------------------------------------------------------------------
 function TIPSUIO88.GetOutput(): integer;

var  Buffer:string;

begin
  //'O'
  SendData('GetInput', 'entered');
  //command and value
  USBCommand:=cmdGetOutput;

Buffer:=USBCommand;
  //call send routine
  if UIO88SendData(buffer) then
   Result := USBResult
    else
    Result := USBStatus;
   SendData('GetOutput', 'Result:'+inttostr(Result));
end;
 //------------------------------------------------------------------------------
function TIPSUIO88.SetOutput(States: integer): integer;
var buffer:string;
begin
  //'o' p1=Output to set
   SendData('SetOutput', 'entered');
  //command and value
    USBCommand:=cmdSetOutput;
    Buffer:=USBCommand;
    Buffer:=Buffer+chr(States and 255);
  //call send routine
  if UIO88SendData(buffer) then
   Result := USBResult
    else
    Result := USBStatus;
   SendData('SetOutput', 'Result:'+inttostr(Result));
end;

 //------------------------------------------------------------------------------
  function TIPSUIO88.SetOutputBit(Bit:integer; state: boolean): integer;
 var buffer:string;
begin
  //'s' p1=Bit, p2=state
  SendData('SetOutputBit', 'entered');
      //command and value
    USBCommand:=cmdSetOutput;
    Buffer:=USBCommand;
    Buffer:=Buffer+chr(Bit and 7);
  if (state) then Buffer:=Buffer+chr(1) else Buffer:=Buffer+chr(0);

  //call send routine
  if (UIO88SendData(buffer)) then
   Result := USBResult
    else
    Result := USBStatus;
   SendData('SetOutputBit', 'Result:'+inttostr(Result));
end;


end.


