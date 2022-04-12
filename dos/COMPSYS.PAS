{ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป}
{บ      -- THIS FILE IS PART OF THE LIVESYSTEMS COMPRESSOR TOOLBOX. --      บ}
{บ          ALL RIGHTS RESERVED  (C) COPYRIGHTED G. HOOGTERP 1994           บ}
{บ                                                                          บ}
{บ             See the documentation for details on the license.            บ}
{บ                                                                          บ}
{ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ}
{$I-}
Unit CompSys;     { Compressor System Main Unit }
Interface
Uses Dos,
     BSC,         { Basic compressed object     Always first! }

     MAC_SIT,    { Macintosh SIT! formaat      }

     IBM_PKZ,     { Pkzip                       }
     IBM_ARJ,     { Arj                         }
     IBM_LHA,     { LHA/LZARC/LA                }
     IBM_SQZ,     { SQZ                         }
     IBM_ARC,     { ARC/PAK/ARC7                }
     IBM_HYP,     { Hyper                       }
     IBM_DWC,     { DWC                         }
     IBM_MDCD,    { MDCD                        }
     IBM_ZOO,     { ZOO                         }
     IBM_RAR;     { RAR                         }


Type CompressorType = ^BasicCompressorObject;

Function DetectCompressor(    _Filename : ComStr;
                          Var _CO       : CompressorType):Boolean;



Implementation

Const BufferSize      = 30*1024;  { Make sure there is enough heap! }

Type CheckBuffer = Array[1..BufferSize] of Byte;
Var  Check       : ^CheckBuffer;

Function DetectCompressor(    _Filename : ComStr;
                          Var _CO       : CompressorType):Boolean;
Var F       : File;
    RR      : Word;
    ThisOne : Byte;
    Found   : Boolean;

Begin
DetectCompressor:=False;
New(Check);
If Check=NIL
   Then Exit;
FillChar(Check^,SizeOf(Check^),#00);

Assign(F,_FileName);
Reset(F,1);
if (ioresult<>0) then begin
        dispose(check);
        exit;
end;
BlockRead(F,Check^,BufferSize,RR);
Close(F);
if (RR=0) or (ioresult<>0) then begin
        Dispose(Check);
        exit;
end;

ThisOne:=1;
Found:=False;
While (Not Found) And (ThisOne<=OPtr) Do
 Begin
 OList[ThisOne]^.FileName:=_FileName;
 Found:=OList[ThisOne]^.IsThisTypeFile(Check^,RR);
 If Not Found Then Inc(ThisOne);
 End;

If found
   Then Begin
        _CO:=OList[ThisOne];
        _CO^.Filename:=_FileName;
        End
   Else _CO:=NIL;

Dispose(Check);
DetectCompressor:=Found;
End;

End.
