{ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป}
{บ      -- THIS FILE IS PART OF THE LIVESYSTEMS COMPRESSOR TOOLBOX. --      บ}
{บ          ALL RIGHTS RESERVED  (C) COPYRIGHTED G. HOOGTERP 1994           บ}
{บ                                                                          บ}
{บ             See the documentation for details on the license.            บ}
{บ                                                                          บ}
{ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ}

Unit IBM_MDCD;
Interface
Uses BSC;

Type MDCDObject = Object(BasicCompressorObject)
       Constructor MDCDInit;
       Procedure FindFirstEntry;   Virtual;
       Procedure FindNextEntry;    Virtual;
       Procedure CheckProtection;  Virtual;
       Function IsThisTypeFile(Var B ;Size : Word):Boolean; Virtual;
     End; {Object}

     MDCDPtr = ^MDCDObject;

Implementation

Type LocalHeader    = Record                 {header for each compressed file   }
       Signature    : Array[0..3] Of Char;   {file/header signature (MDmd)      }
       ReleaseLevel : Byte;                  {compress version                  }
       HeaderType   : Byte;                  {header type. only type 1 for now  }
       HeaderSize   : Word;                  {size of this header in bytes      }
       UserInfo     : Word;                  {any user info desired             }
       Reserved1    : Word;                  {future use and upward compatablty }
       Reserved2    : LongInt;               {future use and upward compatablty }
       Reserved3    : Array[1..8] of byte;   {future use and upward compatablty }
       CompressType : Byte;                  {type of compression               }
       OrigFileSize : LongInt;               {original file size in bytes       }
       CompFileSize : LongInt;               {compressed file size in bytes     }
       FileAttr     : Word;                  {original file attribute           }
       FileDate     : LongInt;               {original file date/time           }
       FileCRC      : Word;                  {file crc                          }
       FileName     : String[12];            {file name                         }
       PathName     : String[67];            {original drive\path               }
     End;

Const MCDCMethodes : Array[0..1] Of String[7] =
                     (
                     'Stored ',
                     'LZW13  '
                     );



Var  F           : File;
     Buf         : LocalHeader;

Constructor MDCDObject.MDCDInit;
Begin
Init;
Platform:=ID_IBM;
CompressorType:='MD';
CompressorName:='MDCD';
Magic:=MDCD_Type;
End;



Procedure MDCDObject.FindFirstEntry;
Var  RR       : Word;
Begin
SetFileMode(ReadOnly+ShareDenyNone);
Assign(F,FileName);
Reset(F,1);
Seek(F,WhereInFile);

BlockRead(F,Buf,SizeOf(Buf),RR);

If Not BeQuick
   Then Begin
        With IBM(Entry) Do
         Begin
         FileName       := Buf.PathName+Buf.FileName;
         OriginalSize   := Buf.OrigFileSize;
         CompressedSize := Buf.CompFileSize;
         CompressionName:= MCDCMethodes[Buf.CompressType];
         FileCRC        := HexWord(Buf.FileCRC)+'    ';
         FileDate       := TimeStamp(Buf.FileDate);
         SaveID         := '';
         ContainsPaths  := Buf.PathName<>'';
         Extra          := '';
         End; {With}

        End;
WhereInFile:=WhereInFile+SizeOf(Buf)+Buf.CompFileSize;

Close(F);
ResetFileMode;
End;

Procedure MDCDObject.FindNextEntry;
Var HeaderID : LongInt;
    ExtraTag : Word;
    RR       : Word;
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
        ResetFileMode;
        Exit;
        End;


If Not BeQuick
   Then Begin
        With IBM(Entry) Do
         Begin
         FileName       := Buf.PathName+Buf.FileName;
         OriginalSize   := Buf.OrigFileSize;
         CompressedSize := Buf.CompFileSize;
         CompressionName:= MCDCMethodes[Buf.CompressType];
         FileCRC        := HexWord(Buf.FileCRC)+'    ';
         FileDate       := TimeStamp(Buf.FileDate);
         ContainsPaths  := Buf.PathName<>'';
         SaveID         := '';
         Extra          := '';
         End; {With}

        End;
WhereInFile:=WhereInFile+SizeOf(Buf)+Buf.CompFileSize;

Close(F);
ResetFileMode;
End;

Procedure MDCDObject.CheckProtection;
Var Old : LongInt;
Begin
Old:=WhereInFile;
BeQuick:=True;

BeQuick:=False;
WhereInFile:=Old;
LastEntry:=False;
End;

Function MDCDObject.IsThisTypeFile(Var B ;Size : Word):Boolean;
Type Check = Array[0..3] Of Char;
Begin
MDCDInit;
IsThisTypeFile:=True;

If Check(B)='MDmd'
   Then Exit;

IsThisTypeFile:=False;
End;


Var CO          : MDCDPtr;

Begin
New(CO,MDCDInit);
AddToList(CO);
End.

