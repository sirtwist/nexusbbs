{ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป}
{บ      -- THIS FILE IS PART OF THE LIVESYSTEMS COMPRESSOR TOOLBOX. --      บ}
{บ          ALL RIGHTS RESERVED  (C) COPYRIGHTED G. HOOGTERP 1994           บ}
{บ                                                                          บ}
{บ             See the documentation for details on the license.            บ}
{บ                                                                          บ}
{ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ}

Unit IBM_LHA;
Interface
Uses BSC;

Type LHAObject = Object(BasicCompressorObject)
       Constructor LHAInit;
       Procedure FindFirstEntry;   Virtual;
       Procedure FindNextEntry;    Virtual;
       Procedure CheckProtection;  Virtual;
       Function IsThisTypeFile(Var B ;Size : Word):Boolean; Virtual;
     End; {Object}

     LHAPtr = ^LHAObject;

Implementation

Type
     LZHName       = String[120];
     LZHHeader     = Record
       Unk1        : Byte;
       Unk2        : Byte;
       Methode     : Array[1..5] Of Char;
       CompSize    : LongInt;
       RealSize    : LongInt;
       Time        : LongInt;
       Attr        : Byte;
       Update      : Byte;
       Name        : LZHName;
       Crc         : Word;
     End;


Var  F           : File;
     Buf         : LZHHeader;

Constructor LHAObject.LHAInit;
Begin
Init;
Platform:=ID_IBM;
CompressorType:='LHA';
CompressorName:='LHArc/LA';
Magic:=LHA_Type;
End;


Procedure LHAObject.FindFirstEntry;
Var RR       : Word;
Begin
SetFileMode(ReadOnly+ShareDenyNone);
Assign(F,FileName);
Reset(F,1);
Seek(F,WhereInFile);

BlockRead(F,Buf,22,RR);
If RR<>22
   Then Begin
        Close(F);
        LastEntry:=True;
        ResetFileMode;
        Exit;
        End;

BlockRead(F,Buf.Name[1],Ord(Buf.Name[0]),RR);
BlockRead(F,Buf.CRC,2,RR);

If Not BeQuick
   Then Begin
        With Buf,IBM(Entry) Do
         Begin
         FileName        := Name;
         CompressedSize  := CompSize;
         OriginalSize    := RealSize;
         CompressionName := Methode;
         FileCRC         := HexWord(CRC)+'    ';
         FileDate        := TimeStamp(Time);
         ProtectedFile   := False;
         ContainsPaths   := (Pos('\',Name)>0) Or (Pos('/',Name)>0);
         SaveID          := '';
         End;
        End;

If Buf.Update>0
   Then Begin
        Inc(WhereInFile,3);
        CompressorName:='LHA';
        End;

WhereInFile:=WhereInFile+Buf.CompSize+(SizeOf(Buf)-120)+Length(Buf.Name);
Close(F);
ResetFileMode;
End;

Procedure LHAObject.FindNextEntry;
Var RR       : Word;
Begin
SetFileMode(ReadOnly+ShareDenyNone);
Assign(F,FileName);
Reset(F,1);
Seek(F,WhereInFile);

BlockRead(F,Buf,22,RR);
If RR<>22
   Then Begin
        Close(F);
        LastEntry:=True;
        ResetFileMode;
        Exit;
        End;

BlockRead(F,Buf.Name[1],Ord(Buf.Name[0]),RR);
BlockRead(F,Buf.CRC,2,RR);

If not BeQuick
   Then Begin
        With Buf,IBM(Entry) Do
         Begin
         FileName        := Name;
         CompressedSize  := CompSize;
         OriginalSize    := RealSize;
         CompressionName := Methode;
         FileCRC         := HexWord(CRC)+'    ';
         FileDate        := TimeStamp(Time);
         ContainsPaths   := (Pos('\',Name)>0) Or (Pos('/',Name)>0);
         ProtectedFile   := False;
         End;
        End;

WhereInFile:=WhereInFile+Buf.CompSize+(SizeOf(Buf)-120)+Length(Buf.Name);

If Buf.Update>0
   Then Begin
        Inc(WhereInFile,3);
        CompressorName:='LHA';
        End;

Close(F);
ResetFileMode;
End;

Procedure LHAObject.CheckProtection;
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


Function LHAObject.IsThisTypeFile(Var B ;Size : Word):Boolean;
Var Tmp   : LzhHeader;
    Dum   : LongInt;
Begin
LHAInit;
IsThisTypeFile:=True;

If IsExeFile(B) or
   SearchBuffer(B,Size,0,1000,'LARC V',Dum)
   Then Begin
        SelfExtractor:=True;
        If SearchBuffer(B,Size,0,1000,'-lz',WhereInFile)
           Then Begin
                Dec(WhereInFile,2);
                Exit;
                End;
        If SearchBuffer(B,Size,0,2000,'-lh',WhereInFile)
           Then Begin
                Dec(WhereInFile,2);
                Exit;
                End;
        End;
WhereInFile:=0;

Move(LZHHeader(B),Tmp,SizeOf(Tmp));
Tmp.Methode[4]:='?';
Tmp.Methode[3]:='?';
If Tmp.Methode='-l??-'
   Then Exit;

IsThisTypeFile:=False;
End;

Var CO          : LHAPtr;

Begin
New(CO,LHAInit);
AddToList(CO);
End.

