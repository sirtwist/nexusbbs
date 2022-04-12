{ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป}
{บ      -- THIS FILE IS PART OF THE LIVESYSTEMS COMPRESSOR TOOLBOX. --      บ}
{บ          ALL RIGHTS RESERVED  (C) COPYRIGHTED G. HOOGTERP 1994           บ}
{บ                                                                          บ}
{บ             See the documentation for details on the license.            บ}
{บ                                                                          บ}
{ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ}

Unit IBM_ARJ;
Interface
Uses BSC;

Type ARJObject = Object(BasicCompressorObject)
       Constructor ARJInit;
       Procedure FindFirstEntry;   Virtual;
       Procedure FindNextEntry;    Virtual;
       Procedure CheckProtection;  Virtual;
       Function IsThisTypeFile(Var B ;Size : Word):Boolean; Virtual;
     End; {Object}

     ArjPtr = ^ArjObject;

Implementation

Const BufferSize    = 34;

Type Buffer         = Array[1..34] Of Byte;
     NameBuffer     = Array[1..255] Of Char;
     MainHeaderType = Record
        ID           : Word;
        BasSize      : Word;
        FirstSize    : Byte;
        Version      : Byte;
        MinExtr      : Byte;
        HostOS       : Byte;
        ARJflags     : Byte;
        Res1         : Byte;
        FileType     : Byte; { 2=Comment }
        Res2         : Byte;
        Time         : Word;
        Date         : Word;
        Res3         : LongInt;
        Res4         : LongInt;
        Res5         : LongInt;
        SpecPos      : Word;
        NotUsed1     : Word;
        NotUsed2     : Word;
      End;
      LocalHeaderType  = Record
        ID             : Word;
        BasSize        : Word;
        FirstSize      : Byte;
        Version        : Byte;
        MinExtr        : Byte;
        HostOS         : Byte;
        ARJflags       : Byte;
        Methode        : Byte;
        FileType       : Byte; { 2=Comment }
        Res2           : Byte;
        Time           : Longint;
        CompSize       : LongInt;
        RealSize       : LongInt;
        CRCLo          : Word;
        CRCHi          : Word;
        SpecPos        : Word;
        AccMode        : Word;
        HostData       : Word;
      End;

Const ARJMethodes : Array[0..4] Of String[10] =
                    (
                    'Stored ',
                    'ARJ 1  ',
                    'ARJ 2  ',
                    'ARJ 3  ',
                    'ARJ 4  '
                    );

Var F     : File;
    Buf   : Buffer;
    AName : NameBuffer;


Constructor ArjObject.ARJInit;
Begin
Init;
Platform:=ID_IBM;
CompressorType:='ARJ';
CompressorName:='ARJ';
Magic:=ARJ_Type;
End;


Procedure ARJObject.FindFirstEntry;
Var RR     : Word;
    Extend : Word;
    Dum    : LongInt;
Begin
SetFileMode(ReadOnly+ShareDenyNone);
Assign(F,FileName);
Reset(F,1);
Seek(F,WhereInFile);

BlockRead(F,Buf,BufferSize,RR);
If RR<>BufferSize
   Then Begin
        Close(F);
        ResetFileMode;
        Exit;
        End;

With MainHeaderType(Buf) Do
 Begin
 ProtectedFile := IsBitSet(ARJFlags,$02) Or
                  IsBitSet(ARJFlags,$40);

 WhereInFile:=WhereInFile+BasSize+10;
 Seek(F,WhereInFile);
 End;

BlockRead(F,Buf,BufferSize,RR);
If RR<>BufferSize
   Then Begin
        Close(F);
        ResetFileMode;
        Exit;
        End;

If LocalHeaderType(Buf).BasSize=0
   Then Begin
        LastEntry:=True;
        ResetFileMode;
        Close(F);
        Exit;
        End;

If Not BeQuick
   Then Begin
        With IBM(Entry),LocalHeaderType(Buf) Do
         Begin
         Fillchar(AName,SizeOf(AName),#00);
         BlockRead(F,AName,BasSize-FirstSize,RR);
         FileName       := Asciiz2String(AName);
         ContainsPaths  := Pos('/',AName)>0;
         OriginalSize   := RealSize;
         CompressedSize := CompSize;
         CompressionName:= ARJMethodes[Methode];
         FileCRC        := HexWord(CRCHi) + HexWord(CRCLo);
         FileDate       := TimeStamp(Time);
         If ProtectedFile
            Then SaveID := '-SE'
            Else SaveID := '';
         End; {With}
         End;

Seek(F,WhereInFile+LocalHeaderType(Buf).BasSize+4);

BlockRead(F,Dum,4,RR);

BlockRead(F,Extend,2,RR);
If Extend>0
   Then WhereInFile:=WhereInFile+Extend;

WhereInFile:=FilePos(F)+LocalHeaderType(Buf).CompSize;

Close(F);
ResetFileMode;
End;


Procedure ARJObject.FindNextEntry;
Var RR     : Word;
    Extend : Word;
    Dum    : LongInt;
Begin
SetFileMode(ReadOnly+ShareDenyNone);
Assign(F,FileName);
Reset(F,1);
Seek(F,WhereInFile);

BlockRead(F,Buf,BufferSize,RR);
If (RR<>BufferSize) Or
   (LocalHeaderType(Buf).BasSize=0)
   Then Begin
        LastEntry:=True;
        Close(F);
        ResetFileMode;
        Exit;
        End;

If Not BeQuick
   Then Begin
        With IBM(Entry),LocalHeaderType(Buf) Do
         Begin
         Fillchar(AName,SizeOf(AName),#00);
         BlockRead(F,AName,BasSize-FirstSize,RR);
         FileName       := Asciiz2String(AName);
         ContainsPaths  := Pos('/',AName)>0;
         OriginalSize   := RealSize;
         CompressedSize := CompSize;
         CompressionName:= ARJMethodes[Methode];
         FileCRC        := HexWord(CRCHi) + HexWord(CRCLo);
         FileDate       := TimeStamp(Time);
         If ProtectedFile
            Then SaveID := '-SE'
            Else SaveID := '';
         End; {With}
         End;

Seek(F,WhereInFile+LocalHeaderType(Buf).BasSize+4);

BlockRead(F,Dum,4,RR);

BlockRead(F,Extend,2,RR);
If Extend>0
   Then WhereInFile:=WhereInFile+Extend;

WhereInFile:=FilePos(F)+LocalHeaderType(Buf).CompSize;

Close(F);
ResetFileMode;
End;


Procedure ARJObject.CheckProtection;
Var Old : LongInt;
Begin
Old:=WhereInFile;
BeQuick:=True;
FindFirstEntry;
BeQuick:=False;
WhereInFile:=Old;
LastEntry:=False;
End;

Function ARJObject.IsThisTypeFile(Var B ;Size : Word):Boolean;
Type TC = Array[0..$FFF0] of Byte;
Var  Test : LongInt;
Begin
ARJInit;
IsThisTypeFile:=True;

If IsExeFile(B)
   Then Begin
        SelfExtractor:=True;
        If Not SearchBuffer(B,Size,6000,6300,#$60#$EA,WhereInFile)
           Then Begin
                If Not SearchBuffer(B,Size,14000,15000,#$60#$EA,WhereInFile)
                   Then Begin
                        If Not SearchBuffer(B,Size,10950,17000,#$60#$EA,WhereInFile)
                           Then ;
                        End;
                End;
        If WhereInFile>0
           Then Begin
                Move(TC(B)[WhereInFile],Test,4);
                IF (((Test And $FFFF0000) Shr 16) <2900)
                   Then Exit;
                End;
        End;
WhereInFile:=0;


If (Word(B) = $EA60) And
   (((LongInt(B) And $FFFF0000) Shr 16) <2900)
   Then Exit;

IsThisTypeFile:=False;
End;

Var CO          : ARJPtr;

Begin
New(CO,ARJInit);
AddToList(CO);
End.

