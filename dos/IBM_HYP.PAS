{ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป}
{บ      -- THIS FILE IS PART OF THE LIVESYSTEMS COMPRESSOR TOOLBOX. --      บ}
{บ          ALL RIGHTS RESERVED  (C) COPYRIGHTED G. HOOGTERP 1994           บ}
{บ                                                                          บ}
{บ             See the documentation for details on the license.            บ}
{บ                                                                          บ}
{ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ}

Unit IBM_Hyp;
Interface
Uses BSC;

Type HYPObject = Object(BasicCompressorObject)
       Constructor HYPInit;
       Procedure FindFirstEntry;   Virtual;
       Procedure FindNextEntry;    Virtual;
       Procedure CheckProtection;  Virtual;
       Function IsThisTypeFile(Var B ;Size : Word):Boolean; Virtual;
     End; {Object}

     HYPPtr = ^HYPObject;

Implementation

Type LocalHeader = Record
       CtrlZ     : Char;
       Id        : Array[1..2] Of Char;
       Version   : Byte;
       CompSize  : LongInt;
       RealSize  : LongInt;
       Time      : Word;
       Date      : Word;
       CRCLo     : Word;
       CRCHi     : Word;
       FAttr     : Byte;
       Name      : String;
     End;


Var  F           : File;
     Buf         : LocalHeader;

Constructor HYPObject.HYPInit;
Begin
Init;
Platform:=ID_IBM;
CompressorType:='HYP';
CompressorName:='Hyper';
Magic:=HYP_Type;
End;


Procedure HYPObject.FindFirstEntry;
Var  RR       : Word;
Begin
SetFileMode(ReadOnly+ShareDenyNone);
Assign(F,FileName);
Reset(F,1);
Seek(F,WhereInFile);

BlockRead(F,Buf,SizeOf(Buf),RR);
If Not BeQuick
   Then Begin
        With Buf,IBM(Entry) Do
         Begin
         FileName       := Name;
         OriginalSize   := RealSize;
         CompressedSize := CompSize;
         ContainsPaths  := Pos('\',Name)>0;
         If ID='ST'
            Then CompressionName:= 'Stored '
            Else CompressionName:= 'Compres';
         FileCRC        := HexWord(CRCHi) + HexWord(CRCLo);
         FileDate       := TimeStamp((LongInt(Date) Shl 16)+LongInt(Time));
         SaveID         := '';
         Extra          := '';
         End;
        End;

CompressorName:='Hyper '+HexWord(Word(Buf.Version) Shl 8);
Dec(CompressorName[0],2);
Insert('.',CompressorName,Length(CompressorName));

WhereInFile:=WhereInFile+SizeOf(Buf)-(255-Length(Buf.Name))+Buf.CompSize;
Close(F);
ResetFileMode;
End;

Procedure HYPObject.FindNextEntry;
Var RR       : Word;
Begin
SetFileMode(ReadOnly+ShareDenyNone);
Assign(F,FileName);
Reset(F,1);
Seek(F,WhereInFile);

BlockRead(F,Buf,SizeOf(Buf),RR);
If RR=0
   Then Begin
        LastEntry:=True;
        Close(F);
        ResetfileMode;
        Exit;
        End;

If Not BeQuick
   Then Begin
        With Buf,IBM(Entry) Do
         Begin
         FileName       := Name;
         OriginalSize   := RealSize;
         CompressedSize := CompSize;
         ContainsPaths  := Pos('\',Name)>0;
         If ID='ST'
            Then CompressionName:= 'Stored    '
            Else CompressionName:= 'Compressed';
         FileCRC        := HexWord(CRCHi) + HexWord(CRCLo);
         FileDate       := TimeStamp((LongInt(Date) Shl 16)+LongInt(Time));
         SaveID         := '';
         Extra          := '';
         End;
        End;
WhereInFile:=WhereInFile+SizeOf(Buf)-(255-Length(Buf.Name))+Buf.CompSize;

Close(F);
ResetFileMode;
End;

Procedure HYPObject.CheckProtection;
Var Old : LongInt;
Begin
Old:=WhereInFile;
BeQuick:=True;

FindFirstEntry;

BeQuick:=False;
WhereInFile:=Old;
LastEntry:=False;
End;

Function HYPObject.IsThisTypeFile(Var B ;Size : Word):Boolean;
Type Check = Array[0..2] Of Char;
Begin
HypInit;
IsThisTypeFile:=True;
If (Check(B)=#$1A'HP') Or
   (Check(B)=#$1A'ST')
   Then Exit;

IsThisTypeFile:=False;
End;

Var CO          : HYPPtr;

Begin
New(CO,HYPInit);
AddToList(CO);
End.

