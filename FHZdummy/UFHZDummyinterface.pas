unit UFHZDummyinterface;
//Thomas Dreﬂler (www.tdressler.net) 2011-2013
interface
  uses UIPSTypes,UIPSModuleTypes;
type
 IIPSFHZDummy = interface(IInvokable)
  ['{D3D9FBB6-4739-418B-A910-9B98BAB13E04}']

  //--- IIPSDummy implementation
  //IIPSFHZ
 //  function GetFHTQueue(): TFHZQueueItems; stdcall;
 // function GetDataQueue(): TFHZQueueItems; stdcall;
  function GetFreeBuffer(): Integer; stdcall;
  //IIPSSend/ReceiveText
   procedure SendText(Text: String); stdcall;
   procedure ReceiveText(Text: String); stdcall;
   //IIPSSend/Receive FHZ
  procedure SendFHZData(Data: TFHZDataTX; NumBytes: Byte); stdcall;
  procedure ReceiveFHZData(Data: TFHZDataRX); stdcall;

 end;
implementation

end.
