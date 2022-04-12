{��������������������������������������������������������������������������ͻ}
{�      -- THIS FILE IS PART OF THE LIVESYSTEMS COMPRESSOR TOOLBOX. --      �}
{�          ALL RIGHTS RESERVED  (C) COPYRIGHTED G. HOOGTERP 1994           �}
{�                                                                          �}
{�             See the documentation for details on the license.            �}
{�                                                                          �}
{��������������������������������������������������������������������������ͼ}

{ Items marked with * are new in this version }

{ Define UseASM}

Unit BSC; { Basic Compressor Routines }
Interface
Uses Dos;

{$I Struct.pas}

Const MaxCompressors     = 16;  { Maximum number of compressors that can be   }
                                { Can be maximal 255 but 16 is enough for now }

Const ReadOnly           = $00;   { Filemode constants }
      WriteOnly          = $01;
      ReadWrite          = $02;

      ShareCompatible    = $00;
      ShareDenyReadWrite = $10;
      ShareDenyWrite     = $20;
      ShareDenyRead      = $30;
      ShareDenyNone      = $40;

      Inheritance        = $80;
      DefaultFileMode    = ReadOnly+ShareCompatible;

Type
     BasicCompressorObject = Object        { Basic compressor object     }
        FileName           : ComStr;       { Current filename            }
        CompressorType     : CompressorID; { Unique short compressor ID  }
        CompressorName     : NameString;   { Full compressor name        }
        Magic              : MagicTypes;   { A unique number             }
        WhereInFile        : LongInt;      { Filepointer                 }

        ProtectedFile      : Boolean;      { Sec. Env. boolean           }
        SelfExtractor      : Boolean;      { SelfExtractor boolean       }
        ContainsPaths      : Boolean;      { Contains paths boolean      }
        HasPassword        : Boolean;      { Password protected          }
        SolidArchive       : Boolean;      { Is solid                    }


        HeaderTitle        : String[132];  { Title line for header       }
        HeaderLines        : String[132];  { Second line for header      }
        FileExtra          : String[132];  { Extra info found in the file}
        Entry              : InfoBlock;    { Internal entry buffer       }

        Platform           : PlatformID;   { Compressors platform        }
        LastEntry          : Boolean;      { True if end of file         }
        BeQuick            : Boolean;      { Don't show so don't conv.   }
        PreviouseMode      : Byte;         { Memory byte last filemode   }

        Constructor Init;

        { � Compressor dependend functions ����������������������������� }

        Procedure FindFirstEntry;         Virtual;
        Procedure FindNextEntry;          Virtual;
        Procedure CheckProtection;        Virtual;
        Function PrintEntry:string;             Virtual;
        Function IsThisTypeFile(Var B; Size : Word):Boolean; Virtual;
        Procedure ReturnEntry(Var E);     Virtual;

        { � Compressor independend functions ��������������������������� }

        Function IsProtected:Boolean;            { has Security envelope    }
        Function IsSelfExtractor:Boolean;        { is selfextracting file   }
        Function HasPaths:Boolean;               { Contains dir. structure  }
        Function IsSolidArchive:Boolean;         { Is solid                 }
        Function IsPasswordProtected:Boolean;    { Has passwords            }

        Function WhichType:CompressorID;         { Return Compressor ID     }
        Function WhichPlatform:PlatFormID;       { Return current platform  }
        Function PlatformName:String;            { The name of the platform }
        Function WriteHeader(wh:byte):string;    { Write a header on screen }

        { � Misc. tools ������������������������������������������������ }

        Function Asciiz2String(Var A):String;
        Function TimeStamp(Time : LongInt):TimeString;
        Function UnixTime(Time : LongInt):TimeString;
        Function Nr2Str(W : LongInt;Len : Byte):String;
        Function HexWord(Number : Word):String;
        Function ShortFileName(FileSpec : ComStr):ComStr;
        Function StripPath(F : ComStr):PathStr;
        Function IsBitSet(Flag,Bit : Word):Boolean;
        Function SearchBuffer(Var B ;
                                  Size  : Word;
                                  Start : Word;
                                  Stop  : Word;
                                  Check : String;
                              Var InFile: LongInt
                                  ):Boolean;
        Function IsEXEFile(Var B):Boolean;
        Function LongSwap(L : LongInt):LongInt;

{*}     Procedure SetFileMode(Mode : Byte);
{*}     Procedure ResetFileMode;
      End; {Basic Compressor Object}


{��������������������������������������������������������������������������
  Create an array of pointers to compressionobjects.
 ��������������������������������������������������������������������������}

Type ObjectList  = Array[1..MaxCompressors] of ^BasicCompressorObject;
Var  OList       : ObjectList;
     OPtr        : Byte;
     ExitSave    : Pointer;

Procedure AddToList(P : Pointer);

Implementation


Constructor BasicCompressorObject.Init;
{���������������������������������������������������������������������������
  Initialize the object, fill all the fields.
 ���������������������������������������������������������������������������}
Begin
BeQuick      :=False;
LastEntry    :=False;
SelfExtractor:=False;
ProtectedFile:=False;
ContainsPaths:=False;
HasPassword  :=False;
SolidArchive :=False;

CompressorType:='UNK';
CompressorName:='* Unknown *' ;
Magic         := None;

PlatForm    :=ID_IBM;
HeaderTitle :='%150%Filename         Orig     Comp     Method  Time     Date        CRC      Sec';
HeaderLines :='%090%���������������� �������� �������� ������� �������� ����������� �������� ���';
FileExtra   :='';
End;


{��������������������������������������������������������������������������
  Virtual procedures and functions
 ��������������������������������������������������������������������������}

Procedure BasicCompressorObject.FindFirstEntry;
{���������������������������������������������������������������������������
  Find the first entry in a compressed file.   VIRTUAL procedure
 ���������������������������������������������������������������������������}
Begin
End;

Procedure BasicCompressorObject.FindNextEntry;
{���������������������������������������������������������������������������
  Find the next entry in a compressed file.    VIRTUAL procedure
 ���������������������������������������������������������������������������}
Begin
End;


Procedure BasicCompressorObject.CheckProtection;
{���������������������������������������������������������������������������
  Check a file for protectionflags, paths etc. VIRTUAL procedure
 ���������������������������������������������������������������������������}
Begin
End;


Function BasicCompressorObject.WriteHeader(wh:byte):string;             { Write a header on screen }
{���������������������������������������������������������������������������
  Write an header to the screen.       VIRTUAL procedure
 ���������������������������������������������������������������������������}
var s:string;
Begin
case wh of
        1:s:='%090%Filename    : %150%'+strippath(Filename)+#13#10;
        2:begin
                s:='%090%Compressor  : %150%'+compressorname;
                if (selfextractor) then begin
                  s:=s+' %090%(%150%SelfExtracting%090%)'+#13#10;
                end else s:=s+#13#10;
                s:=s+#13#10;
          end;
        3:s:='%090%Platform    : %150%'+platformname+#13#10;
        4:if (fileextra<>'') then begin
                s:='%090%Information : %150%'+FileExtra+#13#10;
          end else s:='';
        5:s:=HeaderTitle+#13#10;
        6:s:=HeaderLines+#13#10;
end;
writeheader:=s;
End;


function cstr(i:longint):string;
var c:string[16];
begin
  str(i,c);
  cstr:=c;
end;

function mln(s:string; l:integer):string;
begin
  while (length(s)<l) do s:=s+' ';
  if (length(s)>l) then s:=copy(s,1,l);
  mln:=s;
end;

function mrn(s:string; l:integer):string;
begin
  while length(s)<l do s:=' '+s;
  if length(s)>l then s:=copy(s,1,l);
  mrn:=s;
end;

FUNCTION BasicCompressorObject.PrintEntry:STRING;
{���������������������������������������������������������������������������
  Write an entry to the screen.    VIRTUAL procedure.
 ���������������������������������������������������������������������������}
var s:string;
Begin
With IBM(Entry) Do
 Begin
 s:='%140%'+shortfilename(filename)+' %030%'+
    mrn(cstr(originalsize),8)+' '+
    mrn(cstr(compressedsize),8)+' %040%'+
    compressionname+' %120%'+
    mln(filedate,20)+' %040%'+
    filecrc+' %150%'+
    saveid;
 End;
 printentry:=s;
End;

Procedure BasicCompressorObject.ReturnEntry(Var E);
{���������������������������������������������������������������������������
  Return an entry as untyped variable.   VIRTUAL procedure.
 ���������������������������������������������������������������������������}
Begin
Move(IBM(Entry),E,SizeOf(Entry));
End;

Function BasicCompressorObject.IsThisTypeFile(Var B;Size : Word):Boolean;
{���������������������������������������������������������������������������
  Detect if the current file is of this type. VIRTUAL procedure
 ���������������������������������������������������������������������������}
Begin
IsThisTypeFile:=False;
End;

{��������������������������������������������������������������������������
  Non-virtual procedures and functions
 ��������������������������������������������������������������������������}


Function BasicCompressorObject.IsProtected:Boolean;
{���������������������������������������������������������������������������
  Return the value of the ProtectedFile boolean.
 ���������������������������������������������������������������������������}
Begin
IsProtected:=ProtectedFile;
End;

Function BasicCompressorObject.IsSelfExtractor:Boolean;
{���������������������������������������������������������������������������
  Return the value of the SelfExtractor boolean.
 ���������������������������������������������������������������������������}
Begin
IsSelfExtractor:=SelfExtractor;
End;

Function BasicCompressorObject.HasPaths:Boolean;
{���������������������������������������������������������������������������
  Return the value of the haspaths boolean.
 ���������������������������������������������������������������������������}
Begin
HasPaths:=ContainsPaths;
End;

Function BasicCompressorObject.IsPasswordProtected:Boolean;
{���������������������������������������������������������������������������
  Return the value of the HasPassword boolean.
 ���������������������������������������������������������������������������}
Begin
IsPasswordProtected:=HasPassword;
End;

Function BasicCompressorObject.IsSolidArchive:Boolean;
{���������������������������������������������������������������������������
  Return the value of the HasPassword boolean.
 ���������������������������������������������������������������������������}
Begin
IsSolidArchive:=SolidArchive;
End;



Function BasicCompressorObject.WhichType:CompressorID;
{���������������������������������������������������������������������������
  Return the value of the CompressorType field.
 ���������������������������������������������������������������������������}
Begin
WhichType:=CompressorType;
End;

Function BasicCompressorObject.WhichPlatform:PlatFormID;
{���������������������������������������������������������������������������
  Return the value of the Platform field.
 ���������������������������������������������������������������������������}
Begin
WhichPlatform:=PlatForm;
End;


Function BasicCompressorObject.PlatformName:String;
{���������������������������������������������������������������������������
  Return a description of the platform
 ���������������������������������������������������������������������������}
Begin
Case Platform Of
 ID_IBM      : PlatformName:='IBM or compatible';
 ID_MAC      : PlatformName:='Apple MacIntosh';
 ID_MULTI    : PlatformName:='Multi-platform support';
 ID_OS2      : PlatformName:='OS/2 Executable';
 ID_DOS      : PlatformName:='DOS Executable';
 Else          PlatformName:='Unknown platform';
End; {Case}
End;


{���������������������������������������������������������������������������
  LowLevel utility routines.
 ���������������������������������������������������������������������������}

Const  Months     : Array[0..12] of String[3]
                  = (
                    '???',
                    'Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'
                    );


Function BasicCompressorObject.Asciiz2String(Var A):String;
{���������������������������������������������������������������������������
  Convert an ASCIIZ string to a TP string.
 ���������������������������������������������������������������������������}
Type Temp = Array[1..255] of Char;
Var S : String;
Begin
Move(Temp(A),S[1],255);

S[0]:=#01;
While (Length(S)<255) And (S[Length(S)]<>#00) Do
 Inc(S[0]);
Dec(S[0]);
Asciiz2String:=S;
End;

Function BasicCompressorObject.TimeStamp(Time : Longint):TimeString;
{���������������������������������������������������������������������������
  Create a timestamp string from a MSdos timestamp longint.
 ���������������������������������������������������������������������������}
Var DateRec : DateTime;
    TempStr : TimeString;
Begin
UnpackTime(Time,DAteRec);
TempStr:='';
With DateRec Do
 TempStr:= Nr2Str(Hour,2)+':'+Nr2Str(Min,2)+':'+Nr2Str(Sec,2)+' '+
           Nr2Str(Day,2)+' '+Months[Month]+' '+Nr2Str(Year,4);
TimeStamp:=TempStr;
End;

Function BasicCompressorObject.UnixTime(Time : LongInt):TimeString;
Begin
UnixTime:=' Unsupported format ';
End;


Function BasicCompressorObject.Nr2Str(W : LongInt;Len : Byte):String;
{���������������������������������������������������������������������������
  Convert a number to a string of a certain length.
 ���������������������������������������������������������������������������}
Var Tmp : String[10];
    C   : Byte;
Begin
Str(W:Len,Tmp);
For C:=1 To Length(Tmp) Do
 If Tmp[C]=' '
    Then Tmp[C]:='0';
Nr2Str:=Tmp;
End;


Function BasicCompressorObject.HexWord(number : Word):String;
{���������������������������������������������������������������������������
  Convert a word to a HEX value.
 ���������������������������������������������������������������������������}
Const HexNum : Array[0..15] Of Char = '0123456789ABCDEF';
Begin
HexWord:=HexNum[(Hi(Number) And $F0) Shr 4] + HexNum[(Hi(Number) And $0F)]+
         HexNum[(Lo(Number) And $F0) Shr 4] + HexNum[(Lo(Number) And $0F)];
End;

Function BasicCompressorObject.ShortFileName(FileSpec : ComStr):ComStr;
{���������������������������������������������������������������������������
  Shorten a full filespecifier to a filename with pathindication
    F.e.: C:\TEST\PROG\BLABLA.PAS becomes
          ...\BLABLA.PAS
 ���������������������������������������������������������������������������}
Var Dum  : DirStr;
    Name : NameStr;
    Ext  : ExtStr;
    Count: Byte;
Begin
For Count:=1 To Length(FileSpec) do
 If FileSpec[Count]='/'
    then FileSpec[Count]:='\';
FSplit(FileSpec,Dum,Name,Ext);
If Dum<>''
   Then Dum:='...\'+Name+Ext
   Else Dum:=Name+Ext;
While Length(Dum)<=15 Do
 Dum:=Dum+' ';
ShortFileName:=Dum;
End;

Function BasicCompressorObject.StripPath(F : ComStr):PathStr;
{���������������������������������������������������������������������������
  Strip the path and return only the filename.
 ���������������������������������������������������������������������������}
Var Dum   : Byte;
Begin
Dum:=Length(F);
Repeat
 Dec(Dum);
Until (Dum=0) Or (F[Dum] in ['\','/',':']);
If Dum>0
   Then Delete(F,1,Dum);
StripPath:=F;
End;

{���������������������������������������������������������������������������
  SearchBuffer searches a buffer of a certain size for a certain string.
  The Start and stop offset can be given to limit the search range.
  InFile returns the position of the string within the buffer if found.
 ���������������������������������������������������������������������������}

{$IfNDef UseASM}
Function BasicCompressorObject.SearchBuffer(Var B;
                                                Size  : Word;
                                                Start : Word;
                                                Stop  : Word;
                                                Check : String;
                                            Var InFile: LongInt
                                           ):Boolean;

Type TC = Array[0..$FFFE] of Char;
Var BufPtr : Word;
    Found  : Boolean;
    Ok     : Boolean;
    TmpPtr : Word;
Begin
SearchBuffer:=True;
BufPtr:=Start;
Found:=False;
While (Not Found) And (BufPtr<Stop) Do
  Begin
  If Check[1]=TC(B)[BufPtr]
     Then Begin
          Ok:=True;
          TmpPtr:=BufPtr+1;
          While Ok And ((TmpPtr-BufPtr)<Length(Check)) Do
            Begin
            Ok:=TC(B)[TmpPtr]=Check[TmpPtr-BufPtr+1];
            Inc(TmpPtr);
            End;
          Found:=Ok;
          End;

  Inc(BufPtr);
  End;
SearchBuffer:=Found;
InFile:=BufPtr-1;
End;

{$Else}

Function BasicCompressorObject.SearchBuffer(Var B;
                                                Size  : Word;
                                                Start : Word;
                                                Stop  : Word;
                                                Check : String;
                                            Var InFile: LongInt
                                                ):Boolean; External;
{$L .\SEARCH.OBJ}

{$EndIf}


Function BasicCompressorObject.IsEXEFile(Var B):Boolean;
{���������������������������������������������������������������������������
  Check if the file is an exe file.
 ���������������������������������������������������������������������������}
Type Check = Array[0..1] of Char;
Begin
isEXEFile:=Check(B)='MZ';
End;

Function BasicCompressorObject.IsBitSet(Flag,Bit : Word):Boolean;
Begin
IsBitSet:=(Flag and Bit)=Bit;
End;

Function BasicCompressorObject.LongSwap(L : LongInt):LongInt;
Type TC = Record
           W1,W2 : Word;
          End;
{���������������������������������������������������������������������������
  Swap a longint from INTEL to MOTEROLA format or vice versa
 ���������������������������������������������������������������������������}
Begin
LongSwap:=(LongInt(SWAP(TC(L).W1)) Shl 16) + LongInt(SWAP(TC(L).W2));
End;

{���������������������������������������������������������������������������
 Store, set and reset the filemode variable
 ���������������������������������������������������������������������������}

Procedure BasicCompressorObject.SetFileMode(Mode : Byte);
Begin
PreviouseMode:=FileMode;
FileMode:=Mode;
End;

Procedure BasicCompressorObject.ResetFileMode;
Begin
FileMode:=PreviouseMode;
PreviouseMode:=DefaultFileMode;
End;


{���������������������������������������������������������������������������
  The Object list support
 ���������������������������������������������������������������������������}

Procedure AddToList(P : Pointer);
{���������������������������������������������������������������������������
  Add an object to the list.
 ���������������������������������������������������������������������������}
Begin
If OPtr=MaxCompressors Then Exit;
Inc(OPtr);
OList[OPtr]:=P;
End;


{$F+}
Procedure MyExitProc;
{���������������������������������������������������������������������������
  Dispose the objects in the list. Clean up!
 ���������������������������������������������������������������������������}
Begin
ExitProc:=ExitSave;
While OPtr>0 Do
 Begin
 If OList[OPtr]<>NIL
    Then Begin
         Dispose(OList[OPtr]);
         OLIst[OPtr]:=NIL;
         End;
 Dec(OPtr);
 End;
End;
{$F-}





Begin
ExitSave:=ExitProc;
ExitProc:=@MyExitProc;   { Install the cleanup procedure in the exitlist }

OPtr:=0;                 { Init the ObjectList                           }
FillChar(OList,SizeOf(OList),#00);
End.
