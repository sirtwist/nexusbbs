{ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป}
{บ      -- THIS FILE IS PART OF THE LIVESYSTEMS COMPRESSOR TOOLBOX. --      บ}
{บ          ALL RIGHTS RESERVED  (C) COPYRIGHTED G. HOOGTERP 1994           บ}
{บ                                                                          บ}
{บ             See the documentation for details on the license.            บ}
{บ                                                                          บ}
{ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ}

Unit IBM_SQZ;
Interface
Uses BSC;

Type SQZObject = Object(BasicCompressorObject)
       Constructor SQZInit;
       Procedure FindFirstEntry;   Virtual;
       Procedure FindNextEntry;    Virtual;
       Procedure CheckProtection;  Virtual;
       Function IsThisTypeFile(Var B ;Size : Word):Boolean; Virtual;
     End; {Object}

     SQZPtr = ^SQZObject;

Implementation

Type  Buffer     = Array[0..255] Of Char;
      MainHeader = Record
        ID       : Array[0..4] Of Char;
        Version  : Byte;
        OS       : Byte;
        Flag     : Byte;
        Fill     : Array[1..248] Of Char;
      End;

      LocalHeader  =  Record
        HeaderSize : Byte;
        AlgSum     : Byte;
        Methode    : Byte;
        CompSize   : LongInt;
        RealSize   : LongInt;
        Time       : LongInt;
        Attr       : Byte;
        CRCLo      : Word;
        CRCHi      : Word;
        Name       : Array[0..235] Of Char;
      End;

Const SQZMethodes : Array[0..4] Of String[7] =
       (
       'Stored ',
       'Meth. 1',
       'Meth. 2',
       'Meth. 3',
       'Meth. 4'
       );


Var  F           : File;
     Buf         : Buffer;


Constructor SQZObject.SQZInit;
Begin
Init;
Platform:=ID_IBM;
CompressorType:='SQZ';
CompressorName:='Squeeze';
Magic:=SQZ_Type;
End;



Procedure SQZObject.FindFirstEntry;
Var  RR       : Word;
     Stop     : Boolean;
     Step     : Record
                 Tag : Byte;
                 Add : Word;
                End;

Begin
SetFileMode(ReadOnly+ShareDenyNone);
Assign(F,FileName);
Reset(F,1);
Seek(F,WhereInFile);

BlockRead(F,Buf,SizeOf(Buf),RR);
ProtectedFile:=IsBitSet(MainHeader(Buf).Flag,$0004);
HasPassword:=IsBitSet(MainHeader(Buf).Flag,$0008);
WhereInFile:=WhereInFile+8;

Stop:=False;
Repeat
 Seek(F,WhereInFile);
 BlockRead(F,Buf,SizeOf(Buf),RR);
 Case LocalHeader(Buf).HeaderSize Of
  0     : Begin
          LastEntry:=True;
          Stop:=True;
          End;
  1..18 : Begin
          Move(Buf,Step,3);
          WhereInFile:=WhereInFile+Step.Add+3;
          Case Step.Tag Of
           5 : Begin
               Move(Buf[12],FileExtra[1],Step.Add-9);
               FileExtra[0]:=Chr(Step.Add-9);
               FileExtra:='Vol. Label: '+FileExtra;
               End;
          End;{Case}
          End;
  Else    Begin
          Stop:=True;
          If Not BeQuick
             Then Begin
                  With LocalHeader(Buf),IBM(Entry) Do
                   Begin
                   FileName       := Name;
                   FileName[0]    := Chr(HeaderSize-18);
                   OriginalSize   := RealSize;
                   CompressedSize := CompSize;
                   FileCRC        := HexWord(CRCHi)+HexWord(CRClo);
                   FileDate       := TimeStamp(Time);
                   CompressionName:= SQZMethodes[Methode];
                   ContainsPaths  := Pos('\',Filename)>0;
                   If ProtectedFile
                      Then SaveID         := '-SE'
                      Else SaveID         := '';
                   End; {With}
                  End;
           With LocalHeader(Buf) Do
             WhereInFile:=WhereInFile+HeaderSize+CompSize+2;
             { 2 for the headersize and checksum }
          End;
 End; {Case}
Until Stop;

Close(F);
ResetFileMode;
End;

Procedure SQZObject.FindNextEntry;
Var Stop     : Boolean;
    RR       : Word;
     Step     : Record
                 Tag : Byte;
                 Add : Word;
                End;

Begin
SetFileMode(ReadOnly+ShareDenyNone);
Assign(F,FileName);
Reset(F,1);
Seek(F,WhereInFile);

Stop:=False;
Repeat
 Seek(F,WhereInFile);
 BlockRead(F,Buf,SizeOf(Buf),RR);
 Case LocalHeader(Buf).HeaderSize Of
  0     : Begin
          LastEntry:=True;
          Stop:=True;
          End;
  1..18 : Begin
          Move(Buf,Step,3);
           WhereInFile:=WhereInFile+Step.Add+3;
          Seek(F,WhereInFile);
          Case Step.Tag Of
           5 : Begin
               Move(Buf[12],FileExtra[1],Step.Add-9);
               FileExtra[0]:=Chr(Step.Add-9);
               FileExtra:='Vol. Label: '+FileExtra;
               End;
          End;{Case}


          End;
  Else    Begin
          Stop:=True;
          If Not BeQuick
             Then Begin
                  With LocalHeader(Buf),IBM(Entry) Do
                   Begin
                   FileName       := Name;
                   FileName[0]    := Chr(HeaderSize-18);
                   OriginalSize   := RealSize;
                   CompressedSize := CompSize;
                   FileCRC        := HexWord(CRCHi)+HexWord(CRClo);
                   FileDate       := TimeStamp(Time);
                   ContainsPaths  := Pos('\',Filename)>0;
                   CompressionName:= SQZMethodes[Methode];
                   If ProtectedFile
                      Then SaveID         := '-SE'
                      Else SaveID         := '';
                   End; {With}
                  End;
           With LocalHeader(Buf) Do
             WhereInFile:=WhereInFile+HeaderSize+CompSize+2;
          End;
 End; {Case}
Until Stop;

Close(F);
ResetFileMode;
End;

Procedure SQZObject.CheckProtection;
Var Old : LongInt;
Begin
Old:=WhereInFile;
BeQuick:=True;

FindFirstEntry;
While Not LastEntry Do
 FindNextEntry;

BeQuick:=False;
WhereInFile:=Old;
LastEntry:=False;
End;

Function SQZObject.IsThisTypeFile(Var B ;Size : Word):Boolean;
Type Check = Array[0..4] Of Char;
Begin
SQZInit;
IsThisTypeFile:=True;

If IsExeFile(B)
   Then Begin
        SelfExtractor:=True;
        If SearchBuffer(B,Size,20550,25000,'HLSQZ',WhereInFile) Then Exit;
        End;
WhereInFile:=0;


If Check(B) = 'HLSQZ'
   Then Exit;
IsThisTypeFile:=False;
End;


Var CO          : SQZPtr;

Begin
New(CO,SQZInit);
AddToList(CO);
End.

