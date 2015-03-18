unit UIPSHelper;

interface

uses UIPSTypes, UIPSModuleTypes;

function GenericSwitch(Kernel: IIPSKernel; InstanceID: TInstanceID; Status: Boolean): Boolean;

implementation

function GenericSwitch(Kernel: IIPSKernel; InstanceID: TInstanceID; Status: Boolean): Boolean;
var Instance: TIPSInstance;
    ModuleID: String;
begin

 Result := True;

 Instance := Kernel.InstanceManager.GetInstance(InstanceID);
 try
  ModuleID := Instance.ModuleInfo.ModuleID;

  if ModuleID = '{D805EC4C-7D17-4E84-98D3-A441AA71ACA3}' then //AllUniversal
   (Instance.InstanceInterface as IIPSALLUniversal).SwitchMode(Status)
  else if ModuleID = '{E19C2E41-7347-4A3B-B7D9-A9A88E0D133E}' then //DMXOUT
   begin
    if Status then
     (Instance.InstanceInterface as IIPSDMXOutput).SetValue(0, 255)
    else
     (Instance.InstanceInterface as IIPSDMXOutput).SetValue(0, 0);
   end
  else if ModuleID = '{48FCFDC1-11A5-4309-BB0B-A0DB8042A969}' then //FS20
   (Instance.InstanceInterface as IIPSFS20).SwitchMode(Status)
  else if ModuleID = '{EE4A81C6-5C90-4DB7-AD2F-F6BBD521412E}' then //HomeMatic Device
   begin
    try
     Kernel.ObjectManager.GetObjectIDByIdent('STATE', InstanceID);
    (Instance.InstanceInterface as IIPSHMDevice).WriteValueBoolean('STATE', Status)
    except
     try
      Kernel.ObjectManager.GetObjectIDByIdent('LEVEL', InstanceID);  
      if Status then
       (Instance.InstanceInterface as IIPSHMDevice).WriteValueFloat('LEVEL', 1)
      else
       (Instance.InstanceInterface as IIPSHMDevice).WriteValueFloat('LEVEL', 0);
     except
      //
     end;
    end;
   end
  else if ModuleID = '{9317CC5B-4E1D-4440-AF3A-5CC7FB42CCAA}' then //OneWire
   begin
    //
   end
  else if ModuleID = '{2D871359-14D8-493F-9B01-26432E3A710F}' then //LCN Unit
   begin
    case TLCNUnit(Instance.InstanceInterface.GetProperty('Unit')) of
     luOutput:
      if Status then
       (Instance.InstanceInterface as IIPSLCNUnit).SetIntensity(255, 0)
      else
       (Instance.InstanceInterface as IIPSLCNUnit).SetIntensity(0, 0); 
     luRelay:
      (Instance.InstanceInterface as IIPSLCNUnit).SwitchRelay(Status)
    end;
   end
  else if ModuleID = '{27DD9788-802E-45B7-BA54-FB97141398F7}' then //xComfort Switch
   (Instance.InstanceInterface as IIPSxComfortSwitch).SwitchMode(Status)
  else if ModuleID = '{8050FEEC-C875-4BDD-9143-D15134B89D35}' then //xComfort Dimmer
   (Instance.InstanceInterface as IIPSxComfortDimmer).SwitchMode(Status)
  else if ModuleID = '{CB197E50-273D-4535-8C91-BB35273E3CA5}' then //ModBus Address
   (Instance.InstanceInterface as IIPSModBusAddress).WriteCoil(Status)
  else if ModuleID = '{932076B1-B18E-4AB6-AB6D-275ED30B62DB}' then //Siemens Address
   (Instance.InstanceInterface as IIPSSiemensAddress).WriteBit(Status)
  else if ModuleID = '{8492CEAF-ED62-4634-8A2F-B09A7CEDDE5B}' then //EnOcean RCM100
   (Instance.InstanceInterface as IIPSEnOceanRCM100).SwitchMode(Status)
  else if ModuleID = '{9B1F32CD-CD74-409A-9820-E5FFF064449A}' then //EnOcean Opus
   (Instance.InstanceInterface as IIPSEnOceanOpus).SwitchMode(Status)
  else if ModuleID = '{D62B95D3-0C5E-406E-B1D9-8D102E50F64B}' then //EIB Group
   (Instance.InstanceInterface as IIPSEIBGroup).Switch(Status)
  else if ModuleID = '{101352E1-88C7-4F16-998B-E20D50779AF6}' then //Z-Wave Module
   (Instance.InstanceInterface as IIPSZWaveModule).SwitchMode(Status)   
  else
   Result := False;  
 finally
  Instance.Free;
 end;  

end;

end.
