Program XQT2MSG;

{ This program converts GIGO outgoing spool files to MDaemon spool files
to enable GIGO to be used with a Win 32 based TCP/IP feed.  It requires
MDaemon for Win95/NT4 (V2.0 tested) and a BAGS directive in GIGO's
config file. }

uses dos,crt,misc;

Type
  AddrStr = String [255];

Const
  LF1 : Byte = 10;
  CR1 : Byte = 13;
  ToAddrHdr = 'X-MDaemon-Deliver-To:';

Var
  sr:searchrec;
  LF : Char Absolute LF1;
  CR : Char Absolute CR1;
  Mail2News, MDDir, ToAddr, TmpStr, TmpStr2 : AddrStr;
  MDFile : AddrStr;
  LockFile, XQTFile, MSGFile, DATFile : Text;
  MDSpool, LockName : String[80];
  LineLen, ByteCount, NewsCount, Count : Integer;
  ChArray : Array[0..255] of Char Absolute TmpStr;
  ChNum : Array[0..1] of Byte Absolute TmpStr;
  NNTPActive, Mail, News, FileEnd, LineEnd, Done : Boolean;
  MailName : String[63];
  Error : Byte;
  Finished : Boolean;

Procedure ReadLF(Var Inp : Text; Var Str : AddrStr);

Var
  Count : Integer;
  Tmp : AddrStr;
  TmpArray : Array[0..255] of Char Absolute Tmp;
  TmpNum : Array[0..255] of Byte Absolute Tmp;
  CH : Char;
  CHNum : Byte Absolute CH;

Begin
  Tmp := '';
  Count := 0;
  Repeat
    LineEnd := False;
    Count := Count + 1;
    Read(Inp,CH);
    LineEnd := CHNum=10;
    Finished := LineEnd OR (CHNum=26) OR (Count = 255) OR (EOF(Inp));
    TmpArray[Count] := CH;
  Until Finished;
  TmpNum[0] := Count-1 ; LineLen := Count;
  Str := Tmp;

End;

Procedure Initialise;

Var
  NameSeed : Integer;
  ParamLen : Byte;
  Finished : Boolean;

Begin
  Count := 0;
  Done := False; Mail := False; News := False;
  NNTPActive := Paramcount >= 3;
  If ParamCount < 2 Then
  Begin
    Writeln('Usage:  MDOUT <UUCP Spool Directory> <MDaemon spool dir> [<mail2news account>].');
    Halt(254);
  End;
  MailName := ParamStr(1);
  MDDir := ParamStr(2);
  If NNTPActive Then Mail2News := ParamStr(3);
  bslash(TRUE,MailName);
  bslash(TRUE,MDDir);
End;



Procedure GetNextWord(Var Result: AddrStr);

Var
  CH : Char;
  CH1 : String[1];
  StrEnd : Byte Absolute TmpStr2;
  Finished : Boolean;

Begin
  TmpStr := '';
  ChNum[0] := 0;
  Finished := False;
  Repeat
    CH := CHArray[Count];
    Finished := (CH = ' ') OR (Count = StrEnd+1) ;
    If Not Finished Then
      Begin
        ChNum[0] := ChNum[0] + 1;
        ChArray[ChNum[0]] := CH;
      End;
    Count := Count + 1;
  Until Finished;
  Result := TmpStr;
  If Count >= StrEnd Then Done := True;

End;

Procedure WriteMSG(Var DATFile : Text ; Var Address : AddrStr);

Var
  Tmp, Tmp2 : AddrStr;
  NameSeed : Integer;
  Error : Byte;
  CheckArray : Array [0..255] of Byte Absolute Tmp2;

Begin
  ByteCount := 0;
{  Close(DATFile);
  If Mail Then Reset(DATFile); }
  Randomize;
  NameSeed := Random(9900);
  Repeat
    Str(NameSeed,MDFile);
    NameSeed := NameSeed + 1;
    MDFile := MDDir + 'MD' + MDFile;
    LockName := MDFile + '.LCK';
    MDFile := MDFile + '.MSG';
    Assign(MSGFile,MDFile); {$I-}Reset(MSGFile);{$I+}
    Error := IOResult;
    If Error = 0 Then Close(MSGFile);
  Until Error <> 0;
  Assign(Lockfile,LockName); {$I-}Rewrite(Lockfile);{$I+}
  Error := IOResult;
  If Error <> 0 Then
  Begin
    Writeln('Unable to create lockfile:  Errorcode: ',Error);
    Halt(Error);
  End;
  Assign(MSGFile,MDFile); {$I-}ReWrite(MSGFile);{$I+}
  Error := IOResult;
  If Error <> 0 Then
  Begin
    Writeln('Unable to open *.MSG output file:  Errorcode: ',Error);
    Erase(LockFile);
    Close(lockfile);
    Halt(Error);
  End;
  Repeat
    ReadLF(DATFile,Tmp);
    ByteCount := ByteCount + LineLen;
    Tmp2 := Tmp;
    CheckArray[0] := 5;
    If Tmp2 <> 'Path:' Then
    Begin
      If Tmp = '' Then
        Writeln(MSGFile,ToAddrHdr,' ',Address);
      Tmp2 := Tmp;
      CheckArray[0] := 21;
      If Tmp2 <> ToAddrHdr Then
      Begin
        If LineEnd Then
          Writeln(MSGFile,Tmp)
      Else Write(MSGFile,Tmp);
      End;
    End;
  Until Tmp = '';
  Repeat
    ReadLF(DATFile,Tmp);
    ByteCount := ByteCount + LineLen;
    Tmp2 := Tmp;
    CheckArray[0] := 21;
    If Tmp2 <> ToAddrHdr Then
    Begin
      If LineEnd Then
        Writeln(MSGFile,Tmp)
      Else Write(MSGFile,Tmp);
    End;
  FileEnd := EOF(DATFile);
  Until (FileEnd) OR ((ByteCount >= NewsCount) AND News);
{  Writeln('Expected: ',NewsCount);
  Writeln('Found:    ',ByteCount);
 }
  Close(MSGFile);
  Close(LockFile);
  Erase(LockFile);
End;

Procedure ScanForEnvelope(Var Inp : Text ; Var ToAddress : AddrStr);

Var
  TmpStr1 : AddrStr;
  Finished : Boolean;

Begin
  Finished := False;
  GetNextWord (TmpStr1);
  Mail := TmpStr1 = 'rmail';
  News := TmpStr1 = 'rnews';
  If (NOT Mail) AND (NOT News) Then
  Begin
    Writeln('XQT is not a valid mail or news file!');
    Close(XQTFile);
    Close(DATFile);
{    Close(LockFile);
    Erase(LockFile);}
    Halt(25);
  End;
  If Mail Then
  Begin
    Repeat
    GetNextWord(TmpStr1);
    WriteMSG(DATFile, TmpStr1);
    If TmpStr1 = '' Then
      Finished := True;
    Writeln('Mail To: ',TmpStr1);
    Until Done;
  End;
  If News then
  Begin
    If NNTPActive Then
    Begin
    Repeat
      ReadLF(DATFile,TmpStr);
      TmpStr2 := TmpStr;
      Count := 10;
      GetNextWord(TmpStr1);
      Writeln('News: ',TmpStr1,' Bytes');
      Val(TmpStr1,NewsCount,Count);
      TmpStr1 := 'news@enigma.apana.org.au';
      WriteMSG(DATFile, TmpStr1);
      If NewsCount = 0 Then Finished := True;
    Until FileEnd;
    End
    Else
    Begin
      Writeln('Mail2News Gateway not defined, skipping news batch.');
      Halt(20);
    End;
  End

End;

Begin
  Writeln('XQT2MSG v0.99.01-alpha * (c) Copyright George A. Roberts IV.');
  Writeln('All rights reserved.  For use with Nexus Bulletin Board System');
  Writeln;
  Writeln;
  Initialise;
  findfirst(MailName+'*.XQT',anyfile,sr);
  while (doserror=0) do begin
  Writeln(MailName+sr.name);
  Assign(XQTFile,MailName+sr.name);
  {$I-}Reset(XQTFile);{$I+}
  Error := IOResult;
  If (Error <> 0) Then Begin
    Writeln('Unable to open .XQT file:  Errorcode: ',Error);
    Halt(Error);
  End;
  Writeln(MailName+(copy(sr.name,1,pos('.',sr.name)-1))+'.DAT');
  Assign(DATFile,MailName+(copy(sr.name,1,pos('.',sr.name)-1))+'.DAT');
  {$I-}Reset(DATFile);{$I+}
  Error := IOResult;
  If (Error <> 0) Then Begin
    Writeln('Unable to open *.DAT file:  Errorcode: ',Error);
    Halt(Error);
  End;
  Finished:=FALSE;
  Repeat
    ReadLF(XQTFile,TmpStr);
    Finished := ChArray[1] = 'C';
    If NOT Finished Then TmpStr := '';
  Until Finished;
  Count := 3;
  TmpStr2 := TmpStr;

  writeln('Processing ...');

  ScanForEnvelope(XQTFile,ToAddr);

  writeln('Closing ...');

  Close(XQTFile);
  Close(DATFile);
  Erase(XQTFile);
  Erase(DATFile);
  findnext(sr);
  end;
  Halt(0);

End.
