{ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป}
{บ      -- THIS FILE IS PART OF THE LIVESYSTEMS COMPRESSOR TOOLBOX. --      บ}
{บ          ALL RIGHTS RESERVED  (C) COPYRIGHTED G. HOOGTERP 1994           บ}
{บ                                                                          บ}
{บ             See the documentation for details on the license.            บ}
{บ                                                                          บ}
{ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ}


{
 This macintosh format is included because I happened to have it around. It
 is not supported in any real sense at this moment. If you happen to have
 to have information and structures of other Macintosh compression formats
 and selfextractors and such, this information would be appriciated so I
 can include a bigger selection of Mac formats in a future version of this
 toolbox.
}

Unit MAC_SIT;
Interface
Uses Dos,BSC;

Type SITObject = Object(BasicCompressorObject)
       Constructor SITInit;
       Procedure FindFirstEntry;   Virtual;
       Procedure FindNextEntry;    Virtual;
       Procedure CheckProtection;  Virtual;
       Function IsThisTypeFile(Var B ;Size : Word):Boolean; Virtual;
       Function PrintEntry:STRING;       Virtual;
       Procedure ReturnEntry(Var E); Virtual;
     End; {Object}

     SITPtr = ^SITObject;

Implementation


Type MacBinary = Record
       Ver     : Byte;
       Name    : String[63];
       Typ     : array[0..3] Of Char;
       Creator : Array[0..3] Of Char;
       Filler  : Array[73..127] Of Char;
     End;

Type
     LocalHeader          = Record
       ID                 : InfoArray;
       Fill               : Array[1..18] Of char;
       ResType            : Byte;
       DatType            : Byte;
       Name               : MacName;
       Typ                : InfoArray;
       Creator            : InfoArray;
       Fill2              : Array[1..12] Of Char;

       ResSize            : LongInt;
       DataSize           : LongInt;
       ResComp            : LongInt;
       DatComp            : LongInt;
     End;



Var  F           : File;
     Buf         : LocalHeader;
     MacBin      : MacBinary;

Constructor SITObject.SITInit;
Begin
Init;
Platform:=ID_MAC;
CompressorType:='SIT';
CompressorName:='StuffIT';
Magic:=SIT_Type;
HeaderTitle :='Name                                                            Typ  Crea';
HeaderLines :='อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ ออออ ออออ';
End;


Procedure SITObject.FindFirstEntry;
Var  RR       : Word;
Begin
SetFileMode(ReadOnly+ShareDenyNone);
Assign(F,FileName);
Reset(F,1);
Seek(F,WhereInFile);
BlockRead(F,MacBin,SizeOf(MacBin),RR);
FileExtra:='MacBinary : Type: '+MacBin.Typ+' Creator: '+MacBin.Creator;
WhereInFile:=WhereInFile+128;

BlockRead(F,Buf,SizeOf(Buf),RR);
If (Buf.ResType+Buf.DatType)=0
   Then Begin
        LastEntry:=True;
        Close(F);
        ResetFileMode;
        Exit;
        End;

If Not BeQuick
   Then Begin
        With Buf,Mac(Entry) Do
         Begin
         ResName     := Name;

         ResCompSize := Swap(ResComp);
         ResRealSize := Swap(ResSize);
         DataCompSize:= Swap(DatComp);
         DataRealSize:= Swap(DataSize);

         ResourceType:= ResType;
         DataType    := DatType;

         FileTyp     := Typ;
         FileCreator := Creator;
         End;
        End;

WhereInFile:= WhereInFile+
              LongInt(SizeOf(Buf))+
              MAC(Entry).ResCompSize+
              MAC(Entry).DataCompSize-
              12;


Close(F);
ResetFileMode;
End;

Procedure SITObject.FindNextEntry;
Var HeaderID : LongInt;
    ExtraTag : Word;
    RR       : Word;
Begin
SetFileMode(ReadOnly+ShareDenyNone);
Assign(F,FileName);
Reset(F,1);
Seek(F,WhereInFile);

BlockRead(F,Buf,SizeOf(Buf),RR);
If (Buf.ResType+Buf.DatType)=0
   Then Begin
        LastEntry:=True;
        Close(F);
        ResetFileMode;
        Exit;
        End;

If Not BeQuick
   Then Begin
        With Buf,Mac(Entry) Do
         Begin
         ResName     := Name;

         ResCompSize := Swap(ResComp);
         ResRealSize := Swap(ResSize);
         DataCompSize:= Swap(DatComp);
         DataRealSize:= Swap(DataSize);
         ResourceType:= ResType;
         DataType    := DatType;
         FileTyp     := Typ;
         FileCreator := Creator;
         End;
        End;
WhereInFile:= WhereInFile+
              SizeOf(Buf)+
              MAC(Entry).ResCompSize+
              MAC(Entry).DataCompSize-
              12;

Close(F);
ResetFileMode;
End;

Procedure SITObject.CheckProtection;
Var Old : LongInt;
Begin
Old:=WhereInFile;
BeQuick:=True;

FindFirstEntry;

BeQuick:=False;
WhereInFile:=Old;
LastEntry:=False;
End;

Function SITObject.IsThisTypeFile(Var B ;Size : Word):Boolean;
Begin
SITInit;
IsThisTypeFile:=True;
If MacBinary(B).Typ='SITD'
   Then Exit;
IsThisTypeFile:=False;
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

function SITObject.PrintEntry:string;
var s:string;
Begin
With MAC(Entry) Do
 Begin
 s:=mln(resname,63)+' '+fileTyp+' '+fileCreator+#13#10;
 s:=s+'  Data Type: '+mln(cstr(datatype),3)+' Comp: '+mln(cstr(datacompsize),6)+' Orig: '+mln(cstr(dataRealSize),6);
 s:=s+'  Res. Type: '+mln(cstr(resourcetype),3)+' Comp: '+mln(cstr(rescompsize),6)+' Orig: '+mln(cstr(resRealSize),6);
 End;
 printentry:=s;
End;

Procedure SITObject.ReturnEntry(Var E);
Begin
End;

Var CO          : SITPtr;

Begin
New(CO,SITInit);
AddToList(CO);
End.

