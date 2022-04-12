Program MSG2BAG;

{ This program converts bad message files from MDaemon to *.BAG files
to enable GIGO to be used with a Win 32 based TCP/IP feed.  It requires
MDaemon for Win95/NT4 (V2.0 tested) and a BAGS directive in GIGO's
config file. }

uses dos,crt,misc;

Type
  AddrStr = String [255];

Const
  LF1 : Byte = 10;
  CR1 : Byte = 13;
  ToAddrHdr  = 'X-MDRcpt-To:';

{  ToAddrHdr = 'X-MDaemon-Deliver-To:'; }

Var
  LF : Char Absolute LF1;
  CR : Char Absolute CR1;
  sr : searchrec;
  ToAddr, TmpStr, TmpStr2 : AddrStr;
  BAGS : AddrStr;
  MailBox, BagFile : Text;
  RootName : AddrStr;
  NameSeed : Integer;
  MailName : String[63];
  BagsDir  : String[63];
  Error : Byte;

Procedure Initialise;

Var
  Count : Integer;

Begin
  If ParamCount < 2 Then
  Begin
    Writeln('Usage:  MSG2BAG <MDaemon Bad Message Path> <BAG dir>');
    Halt(254);
  End;
  Randomize;
  MailName := bslash(true,allcaps(ParamStr(1)));
  BagsDir  := bslash(true,allcaps(ParamStr(2)));
End;

Procedure ReadFirstWord(Var Inp : Text ; Var Result, Addr : AddrStr);

Var
  CH : Char;
  CH1 : String[1];
  ChArray : Array[0..255] of Char Absolute TmpStr;
  ChNum : Array[0..1] of Byte Absolute TmpStr;
  Finished : Boolean;

Begin
  TmpStr := '';
  ChNum[0] := 0;
  Finished := False;
  Repeat
    {$I-}Read(Inp,CH);{$I+}
    If EOF(Inp) Then
    Begin
      Writeln('File is not a valid message!');
      Close(Inp);
      RootName := RootName + '.BAD';
      Rename(Inp,RootName);
      Close(Bagfile);
      Erase(BagFile);
      Halt(2);
    End;
    Finished := (CH = ' ') OR (ChNum[0] = 255);
    If Not Finished Then
      Begin
        ChNum[0] := ChNum[0] + 1;
        ChArray[ChNum[0]] := CH;
      End;
  Until Finished;
  Result := TmpStr;
  Readln(Inp,TmpStr);
  Addr := TmpStr;

End;

Procedure ScanForEnvelope(Var Inp : Text ; Var ToAddress : AddrStr);

Var
  TmpStr : AddrStr;
  Finished : Boolean;

Begin
  Finished := False;
  Repeat
    ReadFirstWord (Inp, TmpStr, ToAddress);
    If TmpStr = '' Then ReadLn(Inp,TmpStr);
    If TmpStr = ToAddrHdr Then
      Begin
      Finished := True;
      Read (Inp, TmpStr);
    End;
  Until Finished;
  Writeln('To: ', ToAddress);

End;

Procedure WriteBag(Var Inp, Out : Text; Var ToAddress : AddrStr);

Var
  CH : Char;

Begin
  Reset(Inp);
  Write(Out, '#! rmail 0 ',ToAddress); Write(Out, LF);
  While (EOF(Inp) = False) do
  Begin
    Read(Inp, CH);
    If CH <> CR Then
      Write(Out, CH);
  End;
  Close(Inp);
  Close(Out);

End;

Begin
  Writeln('MSG2BAG v0.99.02 - RFC-822 MSG to BAG converter');
  Writeln('(c) Copyright 2001 George A. Roberts IV. All rights reserved.');
  Writeln;
  Initialise;

  findfirst(MailName+'*.MSG',anyfile,sr);
  writeln('Searching path: '+mailname);
  while (doserror=0) do begin
  Writeln(MailName+sr.name);

  NameSeed := Random(32767);
  Str(NameSeed,BAGS);
  Repeat
    Str(NameSeed,BAGS);
    RootName := BAGS;
    NameSeed := NameSeed + 1;
    BAGS := BagsDir + BAGS + '.BAG';
    Assign(BAGFile,BAGS); {$I-}Reset(BAGFile);{$I+}
    Error := IOResult;
    If Error = 0 Then Close(BAGFile);
  Until Error <> 0;
  Assign(MailBox,MailName+sr.name); {$I-}Reset(MailBox);{$I+}
  Error := IOResult;
  If Error <> 0 Then
  Begin
    Writeln('Unable to open MDaemon message file:  Errorcode: ',Error);
    Halt(Error);
  End;
  {$I-}ReWrite(BagFile);{$I+}
  Error := IOResult;
  If Error <> 0 Then
  Begin
    Writeln('Unable to open *.BAG output file:  Errorcode: ',Error);
    Halt(Error);
  End;

  ScanForEnvelope(MailBox,ToAddr);
  WriteBag(MailBox,BagFile,ToAddr);
  Erase(MailBox);
  findnext(sr);
  end;


  Halt(0);

End.
