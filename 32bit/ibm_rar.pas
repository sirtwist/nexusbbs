{ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»}
{º      -- THIS FILE IS PART OF THE LIVESYSTEMS COMPRESSOR TOOLBOX. --      º}
{º          ALL RIGHTS RESERVED  (C) COPYRIGHTED G. HOOGTERP 1994           º}
{º                                                                          º}
{º             See the documentation for details on the license.            º}
{º                                                                          º}
{ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼}

Unit IBM_RAR;
Interface
Uses BSC,DOS,CRT;

Type RARObject = Object(BasicCompressorObject)
       Constructor RARInit;
       Procedure FindFirstEntry;   Virtual;
       Procedure FindNextEntry;    Virtual;
       Procedure CheckProtection;  Virtual;
       Function IsThisTypeFile(Var B ;Size : Word):Boolean; Virtual;
     End; {Object}

     RARPtr = ^RARObject;

Implementation

Const RARMethodes : Array[$30..$35] of String[7] =
                    ( 'Storing',
                      'Fastest',
                      'Fast   ',
                      'Normal ',
                      'Good   ',
                      'Best   '
                      );



Type HeaderType   = Record
       CRC        : Word;
       Typ        : Byte;
       Flags      : Word;
       Size       : Word;
     End;

     ArcHeader    = Record
      Res1        : Word;
      Res2        : LongInt;
     End;

     FileHeader   = Record
      PackSize    : LongInt;
      UnpSize     : LongInt;
      HostOS      : Byte;
      FCRC        : LongInt;
      FileDate    : LongInt;
      UnpVer      : Byte;
      Methode     : Byte;
      NameSize    : Word;
      Attr        : LongInt;
     End;

     CommHeader   = Record
      UnpSize     : Word;
      UnpVer      : Byte;
      Methode     : Byte;
      CommCrc     : Word;
     End;
     NameBuffer   = Array[1..255] of Char;

Var F        : File;
    Header   : HeaderType;
    ArchHead : ArcHeader;
    CommHead : CommHeader;
    FileHead : FileHeader;
    AName    : NameBuffer;

Constructor RARObject.RARInit;
Begin
Init;
Platform:=ID_MULTI;
CompressorType:='RAR';
CompressorName:='RAR';
HeaderTitle :='%150%Filename         Orig     Comp     Method  Time  Date      Ver  CRC      Sec';
HeaderLines :='%090%ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ ÍÍÍÍÍÍÍÍ ÍÍÍÍÍÍÍÍ ÍÍÍÍÍÍÍ ÍÍÍÍÍ ÍÍÍÍÍÍÍÍÍ ÍÍÍÍ ÍÍÍÍÍÍÍÍ ÍÍÍ';
Magic:=RAR_Type;  { A unique number within the toolbox }
End;

Function Nr2Str(W : LongInt;Len : Byte):String;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
  Convert a number to a string of a certain length.
 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Var Tmp : String[10];
    C   : Byte;
Begin
Str(W,Tmp);
if (length(tmp)>2) then tmp:=copy(tmp,length(tmp)-(len-1),len);
For C:=1 To (len-length(tmp)) Do
  tmp:='0'+tmp;
Nr2Str:=Tmp;
End;

Function Nr2Str2(W : LongInt;Len : Byte):String;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
  Convert a number to a string of a certain length.
 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Var Tmp : String[10];
    C   : Byte;
Begin
Str(W,Tmp);
For C:=1 To (len-length(tmp)) Do
        tmp:=tmp+'0';
Nr2Str2:=Tmp;
End;

Function TStamp(Time : Longint):TimeString;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
  Create a timestamp string from a MSdos timestamp longint.
 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Var DateRec : DateTime;
    TempStr : TimeString;
Begin
UnpackTime(Time,DAteRec);
TempStr:='';
With DateRec Do
 TempStr:= Nr2Str(Hour,2)+':'+Nr2Str(Min,2)+' '+
           Nr2Str(Month,2)+'/'+Nr2Str(Day,2)+'/'+Nr2Str(Year,2);
TStamp:=TempStr;
End;


Function HexB(Number: Byte): String;
  Var
    HChar: Char;
    LChar: Char;

  Begin
  LChar := Chr((Number And $F) + 48);
  If LChar > '9' Then
    LChar := Chr(Ord(LChar) + 7);
  HChar := Chr((Number shr 4) + 48);
  If HChar > '9' Then
    HChar := Chr(Ord(HChar) + 7);
  HexB := HChar + LChar;
  End;


Function HexStr(Number: Word): String;
  Begin
  HexStr := HexB(Number Shr 8) + HexB(Number And $FF);
  End;


Function HexL(Number: LongInt): String;
  Type
    WordRec = Record
      Lo: Word;
      Hi: Word;
    End;

  Begin
  HexL := HexStr(WordRec(Number).Hi) + HexStr(WordRec(Number).Lo);
  End;

function cstr(i:longint):string;
var c:string[16];
begin
  str(i,c);
  cstr:=c;
end;

Procedure RARObject.FindFirstEntry;
Var  RR       : Word;
     Stop     : Boolean;
Begin
filemode:=66;
Assign(F,FileName);
{$I-} Reset(F,1); {$I+}
if (ioresult<>0) then begin
writeln('OOPS!');
halt;
end;

Stop:=False;
Repeat
 Seek(F,WhereInFile);
 BlockRead(F,Header,SizeOf(Header),RR);
 If RR<>SizeOf(Header)
    Then Begin
         Close(F);
         LastEntry:=True;
         ResetFileMode;
         Exit;
         End;

 WhereInFile:=WhereInFile+Header.Size;

 Case Header.Typ of
   $73 : Begin
         SolidArchive  := IsBitSet(Header.Flags,$0008);
         ProtectedFile := IsBitSet(Header.Flags,$0020);

         If SolidArchive
            Then FileExtra:=FileExtra+'SolidArchive, ';
         If IsBitSet(Header.Flags,$0004)
            Then FileExtra:=FileExtra+'Locked archive, ';
         If ProtectedFile
            Then FileExtra:=FileExtra+'Authenticity info present, ';

         If FileExtra<>''
             Then Dec(FileExtra[0],2);
         End;
   $74 : Begin
         BlockRead(F,FileHead,SizeOf(FileHead),RR);
         Stop:=True;
         WhereInFile:=WhereInFile+FileHead.PackSize;
         If Not BeQuick
            Then Begin
                 With IBM(Entry) Do
                  Begin
                  Fillchar(AName,SizeOf(AName),#00);
                  BlockRead(F,AName,FileHead.NameSize,RR);
                  FileName       :=Asciiz2String(AName);
                  ContainsPaths  :=Pos('/',FileName)>0;
                  OriginalSize   :=FileHead.UnpSize;
                  CompressedSize :=FileHead.PackSize;
                  CompressionName:=RARMethodes[FileHead.Methode];
                  FileCRC:=HexL(FileHead.FCRC);
                  FileDate:=TStamp(FileHead.FileDate)+'  '+cstr(filehead.unpver div 10)+'.'+nr2str2(filehead.unpver mod 10,2);
                  SaveID:='---';
                  If ProtectedFile Then SaveID[3]:='A';
                  case FileHead.HostOS of
                        0:SaveID[1]:='D';
                        1:SaveID[1]:='2';
                        2:SaveID[1]:='W';
                        3:SaveID[1]:='U';
                  end;
                  
                  End;
                 HasPassword:=IsBitSet(Header.Flags,$0004);
                 End;
         End;
End; {Case}

Until Stop;
Close(F);
ResetFileMode;
End;

Procedure RARObject.FindNextEntry;
Var HeaderID : LongInt;
    ExtraTag : Word;
    RR       : Word;
    Stop     : Boolean;

Begin
filemode:=66;
Assign(F,FileName);
Reset(F,1);
Seek(F,WhereInFile);

Stop:=False;
Repeat
 Seek(F,WhereInFile);
 BlockRead(F,Header,SizeOf(Header),RR);
 If RR<>SizeOf(Header)
    Then Begin
         Close(F);
         LastEntry:=True;
         ResetFileMode;
         Exit;
         End;

 WhereInFile:=WhereInFile+Header.Size;

 If Header.Typ=$74
    Then Begin
         BlockRead(F,FileHead,SizeOf(FileHead),RR);
         Stop:=True;
         WhereInFile:=WhereInFile+FileHead.PackSize;
         If Not BeQuick
            Then Begin
                 With IBM(Entry) Do
                  Begin
                  Fillchar(AName,SizeOf(AName),#00);
                  BlockRead(F,AName,FileHead.NameSize,RR);
                  FileName       :=Asciiz2String(AName);
                  ContainsPaths  :=Pos('/',FileName)>0;
                  OriginalSize   :=FileHead.UnpSize;
                  CompressedSize :=FileHead.PackSize;
                  CompressionName:=RARMethodes[FileHead.Methode];
                  FileCRC:=HexL(FileHead.FCRC);
                  FileDate:=TStamp(FileHead.FileDate)+'  '+cstr(filehead.unpver div 10)+'.'+nr2str2(filehead.unpver mod 10,2);
                  SaveID:='---';
                  If ProtectedFile Then SaveID[3]:='A';
                  case FileHead.HostOS of
                        0:SaveID[1]:='D';
                        1:SaveID[1]:='2';
                        2:SaveID[1]:='W';
                        3:SaveID[1]:='U';
                  end;
                  HasPassword:=IsBitSet(Header.Flags,$0004);
                  End;
                 End;
         End;
Until Stop;

Close(F);
ResetFileMode;
End;

Procedure RARObject.CheckProtection;
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

Function RARObject.IsThisTypeFile(Var B ;Size : Word):Boolean;
Begin
RARInit;  { Reinit the current object }
IsThisTypeFile:=True;
WhereInFile:=0;

With HeaderType(B) Do
 If (CRC=$6152)   And
    (Typ=$72)     And
    (Flags=$1A21) And
    (Size=$007)
    Then Exit;

If IsExeFile(B)
   Then Begin
        If SearchBuffer(B,Size,6000,7500,#$52#$61#$72#$21#$1A#$07#$00,WhereInFile)
           Then begin
           platform:=ID_DOS;
           SelfExtractor:=True;
           Exit;
           end;
        If SearchBuffer(B,Size,9000,10000,#$52#$61#$72#$21#$1A#$07#$00,WhereInFile)
           Then begin
           platform:=ID_DOS;
           SelfExtractor:=True;
           Exit;
           end;
        If SearchBuffer(B,Size,13000,14000,#$52#$61#$72#$21#$1A#$07#$00,WhereInFile)
           Then begin
           Platform:=ID_OS2;
           SelfExtractor:=True;
           Exit;
           end;
        If SearchBuffer(B,Size,24000,25000,#$52#$61#$72#$21#$1A#$07#$00,WhereInFile)
           Then begin
           Platform:=ID_OS2;
           SelfExtractor:=True;
           Exit;
           end;
        If SearchBuffer(B,Size,28000,30000,#$52#$61#$72#$21#$1A#$07#$00,WhereInFile)
           Then begin
           Platform:=ID_DOS;
           SelfExtractor:=True;
           Exit;
           end;
        End;
IsThisTypeFile:=False;
End;



Var CO          : RARPtr;

Begin
New(CO,RARInit);     { Create an instance of this object                 }
AddToList(CO);       { Add it to the list of available compressorobjects }
End.

