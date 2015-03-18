unit portinc;
{
Delphi Includes for PORT.DLL written by B.Kainka/Elektor
Description  is here: http://www.b-kainka.de/referenz.txt
Download: http://www.b-kainka.de/port.zip
(C)2006 Thomas Dreﬂler V0.2 01.09.2006
}
interface

type DWORD=LONGWORD;
Procedure DELAY(i:WORD); stdcall; external 'PORT.DLL';
Procedure TIMEINIT; stdcall; external 'PORT.DLL';
Function TIMEREAD: DWORD; stdcall; external 'PORT.DLL';
Procedure DELAYUS(i:DWORD); stdcall; external 'PORT.DLL';
Procedure TIMEINITUS; stdcall; external 'PORT.DLL';
Function TIMEREADUS: DWORD; stdcall; external 'PORT.DLL';
Procedure OUTPORT(PortAddr:Word; Data:byte); stdcall; external 'PORT.DLL';
Function INPORT(PortAddr:Word):Byte;stdcall; external 'PORT.DLL';
Function OPENCOM(S:PCHAR):Integer;stdcall; external 'PORT.DLL';
Procedure CLOSECOM; stdcall; external 'PORT.DLL';
Function READBYTE:Integer;stdcall; external 'PORT.DLL';
Procedure SENDBYTE(d:WORD);stdcall; external 'PORT.DLL';
Procedure DTR(d:WORD);stdcall; external 'PORT.DLL';
Procedure RTS(d:WORD);stdcall; external 'PORT.DLL';
Procedure TXD(d:WORD);stdcall; external 'PORT.DLL';
Function CTS:Integer;stdcall; external 'PORT.DLL';
Function DSR:Integer;stdcall; external 'PORT.DLL';
Function RI:Integer;stdcall; external 'PORT.DLL';
Function DCD:Integer;stdcall; external 'PORT.DLL';
Procedure TIMEOUT(Wert: WORD); stdcall; external 'PORT.DLL';
Procedure REALTIME(d:WORD);stdcall; external 'PORT.DLL';
Function SOUNDSETRATE(Rate:DWORD):DWORD; stdcall; external 'PORT.DLL';
Function SOUNDGETRATE:DWORD; stdcall; external 'PORT.DLL';
Function SOUNDBUSY:Boolean; stdcall; external 'PORT.DLL';
Function SOUNDIS:Boolean; stdcall; external 'PORT.DLL';
Procedure SOUNDIN(Puffer:Pchar;Size:DWORD); stdcall; external 'PORT.DLL';
Procedure SOUNDOUT(Puffer:Pchar;Size:DWORD); stdcall; external 'PORT.DLL';
Function SOUNDGETBYTES:DWORD; stdcall; external 'PORT.DLL';
Function SOUNDSETBYTES(B:DWORD):DWORD; stdcall; external 'PORT.DLL';
Procedure SOUNDCAPIN; stdcall; external 'PORT.DLL';
Procedure SOUNDCAPOUT; stdcall; external 'PORT.DLL';
Function JOYX:DWORD;stdcall; external 'PORT.DLL';
Function JOYY:DWORD;stdcall; external 'PORT.DLL';
Function JOYZ:DWORD;stdcall; external 'PORT.DLL';
Function JOYR:DWORD;stdcall; external 'PORT.DLL';
Function JOYU:DWORD;stdcall; external 'PORT.DLL';
Function JOYV:DWORD;stdcall; external 'PORT.DLL';
Function JOYBUTTON:DWORD;stdcall; external 'PORT.DLL';
Procedure JOYSTICK(VAR X,Y,Z,R,U,V,B:DWORD); stdcall; external 'PORT.DLL';


implementation

end.



