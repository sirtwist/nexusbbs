{ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป}
{บ      -- THIS FILE IS PART OF THE LIVESYSTEMS COMPRESSOR TOOLBOX. --      บ}
{บ          ALL RIGHTS RESERVED  (C) COPYRIGHTED G. HOOGTERP 1994           บ}
{บ                                                                          บ}
{บ             See the documentation for details on the license.            บ}
{บ                                                                          บ}
{ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ}

Unit IBM_ARC;
Interface
Uses BSC;

Type ARCObject = Object(BasicCompressorObject)
       Constructor ARCInit;
       Procedure FindFirstEntry;   Virtual;
       Procedure FindNextEntry;    Virtual;
       Procedure CheckProtection;  Virtual;
       Function IsThisTypeFile(Var B ;Size : Word):Boolean; Virtual;
     End; {Object}

     ARCPtr = ^ARCObject;

Implementation

Type LocalHeader = Record
       Mark      : Byte;
       Version   : Byte;
       Name      : Array[1..13] Of Char;
       CompSize  : LongInt;
       Date      : Word;
       Time      : Word;
       Crc       : Word;
       RealSize  : LongInt;
     End;

Const ArcMethodes  : Array[1..11] Of String[7] =
                    ('Stored ',
                     'Stored ',
                     'Packed ',
                     'Squeeze',
                     'Crunch ',
                     'Crunch ',
                     'Crunch ',
                     'Crunch ',
                     'Squash ',
                     'Crushed',
                     'Distill'
                     );


Var  F           : File;
     Buf         : LocalHeader;

Constructor ARCObject.ARCInit;
Begin
Init;
Platform:=ID_IBM;
CompressorType:='ARC';
CompressorName:='ARC/PAK/ARC7';
Magic:=ARC_Type; { Unique number }
End;



Procedure ARCObject.FindFirstEntry;
Var  RR       : Word;
Begin
SetFileMode(ReadOnly+ShareDenyNone);
Assign(F,FileName);
Reset(F,1);
Seek(F,WhereInFile);

BlockRead(F,Buf,SizeOf(Buf),RR);

If Buf.Mark=0
   Then Begin
        LastEntry:=True;
        Close(F);
        ResetFileMode;
        Exit;
        End;

If Not BeQuick
   Then Begin
        With IBM(Entry),Buf Do
         Begin
         FileName       := Asciiz2String(Name);
         CompressedSize := CompSize;
         OriginalSize   := RealSize;
         If Version<=11
            Then CompressionName:= ArcMethodes[Version]
            Else CompressionName:= 'Unknown';
         FileCRC        := HexWord(CRC)+'    ';
         FileDate       := TimeStamp((LongInt(Date) Shl 16)+LongInt(Time));
         SaveID         := '';
         End; {With}
        End;

Case Buf.Version of
 10 : begin
        CompressorName:='PAK';    { Cannot be trusted! }
        CompressorType:='PAK';
      end;
 11 : CompressorName:='ARC7';
End; {Case}
WhereInFile:=WhereInFile+SizeOf(Buf)+Buf.CompSize;
Close(F);
ResetFileMode;
End;

Procedure ARCObject.FindNextEntry;
Var HeaderID : LongInt;
    ExtraTag : Word;
    RR       : Word;
Begin
SetFileMode(ReadOnly+ShareDenyNone);
Assign(F,FileName);
Reset(F,1);
Seek(F,WhereInFile);

BlockRead(F,Buf,SizeOf(Buf),RR);
If Buf.Version=0
   Then Begin
        LastEntry:=True;
        Close(F);
        ResetFileMode;
        Exit;
        End;

If Not BeQuick
   Then Begin
        With IBM(Entry),Buf Do
         Begin
         FileName       := Asciiz2String(Name);
         CompressedSize := CompSize;
         OriginalSize   := RealSize;
         If Version<=11
            Then CompressionName:= ArcMethodes[Version]
            Else CompressionName:= 'Unknown   ';
         FileCRC        := HexWord(CRC)+'    ';
         FileDate       := TimeStamp((LongInt(Date) Shl 16)+LongInt(Time));
         SaveID         := '';
         End; {With}
        End;

Case Buf.Version of
 10 : CompressorName:='PAK';    { Cannot be trusted! }
 11 : CompressorName:='ARC7';
End; {Case}

WhereInFile:=WhereInFile+SizeOf(Buf)+Buf.CompSize;

Close(F);
ResetFileMode;
End;

Procedure ARCObject.CheckProtection;
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

Function ARCObject.IsThisTypeFile(Var B ;Size : Word):Boolean;
Type Check = Array[0..2] Of Char;
Var Temp:longint;
Begin
ARCInit;
IsThisTypeFile:=True;

If IsExeFile(B) and
   SearchBuffer(B,Size,8400,9000,'it?'#00#$1A,WhereInFile)
   Then Begin
        SelfExtractor:=True;
        Inc(WhereInFile,4);
        temp:=whereinfile;
        FindFirstEntry;
        WhereinFile:=temp;
        Exit;
        End;
WhereInFile:=0;

If (Byte(B)=$1A) And
   (Check(B) <> #$1A'HP') And   { Check HYPER! }
   (Check(B) <> #$1A'ST')
   Then begin
        FindFirstEntry;
        WhereInFile:=0;
        Exit;
   end;
IsThisTypeFile:=False;
End;

Var CO          : ArcPtr;

Begin
New(CO,ArcInit);
AddToList(CO);
End.

