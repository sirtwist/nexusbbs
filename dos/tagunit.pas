{----------------------------------------------------------------------------}
{ Next Epoch matriX User System - Nexus BBS Software                         }
{                                                                            }
{ All material contained herein is (c) Copyright 1995-96 Intuitive Vision    }
{ Software.  All Rights Reserved.                                            }
{                                                                            }
{ MODULE     :  TAGUNIT.PAS (Message, File, and ivOMS Tag Object)            }
{ AUTHOR     :  George A. Roberts IV                                         }
{                                                                            }
{----------------------------------------------------------------------------}
{ Intuitive Vision Software is a Division of Intuitive Vision Computer       }
{ Services.  Nexus, Next Epoch matriX User System, and ivOMS are Trademarks  }
{ of Intuitive Vision Software.                                              }
{----------------------------------------------------------------------------}

Unit TagUnit;

Interface

uses crt;

TYPE UserTagREC=
     RECORD
        BaseID:LONGINT;
     end;

TYPE TagRecordOBJ =
  OBJECT
  CurrentRecord:LONGINT;
  MaxBases:INTEGER;
  NoSearch,
  SearchOpen,
  FileOpen:BOOLEAN;
  UTF1:File;
  UTF:File of UserTagRec;
  UTF2:FILE;
  UTAG:UserTagRec;
  TEMPTAGS:ARRAY[0..4096] of BYTE;
  PROCEDURE Init(fname:STRING);
  FUNCTION ISTAGGED(x:LONGINT):BOOLEAN;
  FUNCTION GETFIRST(s:string):LONGINT;
  FUNCTION GETNEXT:LONGINT;
  FUNCTION GETPREV:LONGINT;
  PROCEDURE ADDTAG(x:LONGINT);
  PROCEDURE REMOVETAG(x:LONGINT);
  PROCEDURE UNTAGALL;
  FUNCTION istemptagged(x:integer):BOOLEAN;
  FUNCTION FINDTAG(x:LONGINT):LONGINT;
  PROCEDURE SORTTAGS(s:string;tp:byte);
  PROCEDURE Done;
END;

IMPLEMENTATION

CONST LastFindTag:LONGINT=-1;
      LastFindRec:LONGINT=-1;

PROCEDURE TagRecordOBJ.Init(fname:STRING);

begin
FileOpen:=FALSE;
Assign(utf,fname);
Assign(utf2,fname);
filemode:=66;
nosearch:=FALSE;
SearchOpen:=FALSE;
{$I-} reset(utf); {$I+}
if (ioresult<>0) then begin
        FileOpen:=FALSE;
        CurrentRecord:=-1;
        exit;
end;
FileOpen:=TRUE;
CurrentRecord:=0;
LastFindTag:=-1;
LastFindREC:=-1;
end;


FUNCTION TagRecordOBJ.FINDTAG(x:LONGINT):LONGINT;
var x4:LONGINT;
    x3,x2:integer;
    found:boolean;
    ta:array[1..100] of longint;
begin
filemode:=66;
{$I-} reset(utf2,1); {$I+}
x2:=ioresult;
if (x2<>0) then begin
        writeln(x2);
        findtag:=-1;
        exit;
end;
x4:=0;
x2:=0;
fillchar(ta,sizeof(ta),#0);
found:=FALSE;
repeat
blockread(utf2,ta[1],sizeof(ta),x2);
x3:=1;
while (x3<=(x2 div 4)) and not(found) and (x>=ta[x3]) do begin
        if (ta[x3]=x) then begin
                x3:=(x3-1)+x4;
                found:=TRUE;
        end else inc(x3);
end;
inc(x4,100);
until (found) or (x2<sizeof(ta));
close(utf2);
if (found) then begin
        findtag:=x3;
end else findtag:=-1;
end;

FUNCTION TagRecordOBJ.ISTAGGED(x:LONGINT):BOOLEAN;
begin
if not(FileOpen) then begin
        ISTAGGED:=FALSE;
        exit;
end;
close(utf);
if (findtag(x)<>-1) then ISTAGGED:=TRUE else ISTAGGED:=FALSE;
{$I-} reset(utf); {$I+}
if (ioresult<>0) then begin
        FileOpen:=FALSE;
        CurrentRecord:=-1;
        exit;
end;
FileOpen:=TRUE;
CurrentRecord:=0;
end;

FUNCTION TagRecordOBJ.GETFIRST(s:string):LONGINT;
var numread:word;
begin
assign(utf1,s);
{$I-} reset(utf1,1); {$I+}
if (ioresult<>0) then begin
        searchopen:=FALSE;
        GetFirst:=-1;
        exit;
end;
blockread(utf1,temptags,sizeof(temptags),numread);
close(utf1);
if (numread<sizeof(temptags)) then begin
        searchopen:=FALSE;
        GetFirst:=-1;
        exit;
end;
searchopen:=TRUE;
currentrecord:=-1;
GetFirst:=GetNext;
end;

Function TagRecordOBJ.istemptagged(x:integer):BOOLEAN;
begin
case x mod 8 of
0:istemptagged:=(temptags[x div 8] and 1)<>0;
1:istemptagged:=(temptags[x div 8] and 2)<>0;
2:istemptagged:=(temptags[x div 8] and 4)<>0;
3:istemptagged:=(temptags[x div 8] and 8)<>0;
4:istemptagged:=(temptags[x div 8] and 16)<>0;
5:istemptagged:=(temptags[x div 8] and 32)<>0;
6:istemptagged:=(temptags[x div 8] and 64)<>0;
7:istemptagged:=(temptags[x div 8] and 128)<>0;
end;
end;

FUNCTION TagRecordOBJ.GETNEXT:LONGINT;
var done2:boolean;
begin
if not(SearchOpen) then begin
        GetNext:=-1;
        exit;
end;
inc(CurrentRecord);
done2:=FALSE;
while not(done2) and (currentrecord<=maxbases) do begin
    if not(istemptagged(currentrecord)) then begin
    inc(currentrecord);
    end else begin
        done2:=TRUE;
    end;
end;
if (done2) then begin
        GetNext:=CurrentRecord;
end else begin
        GetNext:=-1;
end;
end;

FUNCTION TagRecordOBJ.GETPREV:LONGINT;
var done2:Boolean;
begin
if not(SearchOpen) then begin
        GetPrev:=-1;
        exit;
end;
dec(CurrentRecord);
done2:=FALSE;
while not(done2) and (currentrecord>0) do begin
    if not(istemptagged(currentrecord)) then begin
    dec(currentrecord);
    end else begin
        done2:=TRUE;
    end;
end;
if (done2) then begin
        GetPrev:=CurrentRecord;
end else begin
        GetPrev:=-1;
end;
end;

PROCEDURE TagRecordOBJ.ADDTAG(x:LONGINT);
var x2,x3,oldcurrent:longint;
begin
if not(FileOpen) then begin
        filemode:=66;
        rewrite(utf);
        utag.BaseID:=x;
        write(utf,utag);
        FileOpen:=TRUE;
        CurrentRecord:=0;
        exit;
end;
seek(utf,0);
read(utf,utag);
x2:=utag.baseid;
oldcurrent:=0;
while (x>x2) and not(eof(utf)) do begin
        read(utf,utag);
        inc(oldcurrent);
        x2:=utag.baseid;
end;
if (x>x2) then x2:=-1;
if (x=x2) then exit;
if (x2=-1) then begin
        seek(utf,filesize(utf));
        utag.BaseID:=x;
        write(utf,utag);
end else begin
        for x3:=(filesize(utf)-1) downto oldcurrent do begin
                seek(utf,x3);
                read(utf,utag);
                seek(utf,x3+1);
                write(utf,utag);
        end;
        seek(utf,oldcurrent);
        utag.BaseId:=x;
        write(utf,utag);
end;
end;

PROCEDURE TagRecordOBJ.REMOVETAG(x:LONGINT);
var l:longint;
    x3:longint;
begin
if not(FileOpen) then begin
        exit;
end;
close(utf);
l:=FindTag(x);
{$I-} reset(utf); {$I+}
if (ioresult<>0) then begin
        FileOpen:=FALSE;
        CurrentRecord:=-1;
        exit;
end;
FileOpen:=TRUE;
if (l=-1) then exit;
CurrentRecord:=0;
for x3:=(l+1) to (filesize(utf)-1) do begin
                seek(utf,x3);
                read(utf,utag);
                seek(utf,x3-1);
                write(utf,utag);
end;
seek(utf,filesize(utf)-1);
truncate(utf);
if (filesize(utf)=0) then begin
close(utf);
{$I-} erase(utf); {$I+}
if (ioresult<>0) then begin end;
FileOpen:=FALSE;
CurrentRecord:=-1;
end else seek(utf,currentrecord);
end;

PROCEDURE TagRecordOBJ.UNTAGALL;
begin
if not(FileOpen) then exit;
close(utf);
{$I-} erase(utf); {$I+}
if (ioresult<>0) then begin end;
FileOpen:=FALSE;
CurrentRecord:=-1;
end;

PROCEDURE TagRecordOBJ.SORTTAGS(s:string;tp:byte);
TYPE
BaseIDX=
RECORD
        BaseID:LONGINT;         { Permanent Base ID - Should match record # }
        Offset:INTEGER;         { Offset to record # in base data file      }
end;

var bf:file of BaseIDX;
    b:BaseIDX;
    ut:usertagrec;
    x2,x:integer;

        function nofilename(s2:string):string;
        var x3:integer;
        begin
        x3:=length(s2);
        while (x3>0) and (s2[x3]<>'\') do begin
                s2:=copy(s2,1,length(s2)-1);
                x3:=length(s2);
        end;
        nofilename:=s2;
        end;

begin
assign(utf1,s);
rewrite(utf1,1);
if (fileopen) then begin
if (tp=1) then
assign(bf,nofilename(s)+'MBASEID.IDX')
else assign(bf,nofilename(s)+'FBASEID.IDX');
{$I-} reset(bf); {$I+}
if (ioresult<>0) then begin
        nosearch:=TRUE;
end else begin
        fillchar(temptags,sizeof(temptags),#0);
        seek(utf,0);
        while not(eof(utf)) do begin
                read(utf,utag);
                seek(bf,utag.baseid);
                read(bf,b);
                case b.offset mod 8 of
                        0:temptags[b.offset div 8]:=temptags[b.offset div 8] + 1;
                        1:temptags[b.offset div 8]:=temptags[b.offset div 8] + 2;
                        2:temptags[b.offset div 8]:=temptags[b.offset div 8] + 4;
                        3:temptags[b.offset div 8]:=temptags[b.offset div 8] + 8;
                        4:temptags[b.offset div 8]:=temptags[b.offset div 8] + 16;
                        5:temptags[b.offset div 8]:=temptags[b.offset div 8] + 32;
                        6:temptags[b.offset div 8]:=temptags[b.offset div 8] + 64;
                        7:temptags[b.offset div 8]:=temptags[b.offset div 8] + 128;
                end;
        end;
        blockwrite(utf1,temptags,sizeof(temptags));
        close(bf);
end;
end;
close(utf1);
end;

PROCEDURE TagRecordOBJ.Done;
begin
if (FileOpen) then begin
close(utf);
end;
CurrentRecord:=-1;
LastFindTag:=-1;
LastFindREC:=-1;
FileOpen:=FALSE;
nosearch:=FALSE;
searchopen:=FALSE;
end;

end.
