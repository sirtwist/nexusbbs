unit oldlang;

interface

uses dos,crt,misc;

procedure compile(impname,compname:string);

implementation

TYPE Tstring=STRING[255];
var si:stringidx;
    f2:file of Tstring;
    t:text;
    s:string;
    f:file;
    x,x2:integer;
    linenum:integer;
    totsize:longint;
    ts2:tstring;
    numstr:integer;


function striplead(st:string;ch:char):string;
  var
    tempstr:        string;

  begin
  tempstr := st;
  While ((TempStr[1] = Ch) and (Length(TempStr) > 0)) do
    tempstr := copy (tempstr,2,length(tempstr));
  striplead := tempstr;
  end;


Function StripTrail(St:String;Ch:Char):String;
  Var
    TempStr: String;
    i: Integer;

  Begin
  TempStr := St;
  i := Length(St);
  While ((i > 0) and (St[i] = Ch)) Do
    i := i - 1;
  TempStr[0] := Chr(i);
  StripTrail := TempStr;
  End;


Function StripBoth(St:String;Ch:Char):String;

  Begin
  StripBoth := StripTrail(StripLead(St,Ch),Ch);
  End;


function setstring(s2:string;num:integer):boolean;
var ts:tstring;
begin
seek(f2,num-1);
ts:=s2;
read(f2,ts);
if (ts<>'') then begin
        setstring:=FALSE;
        exit;
end;
ts:=s2;
seek(f2,num-1);
write(f2,ts);
setstring:=TRUE;
end;

procedure compilestrings;
var s2:tstring;
    x2:integer;
begin
rewrite(f,1);
fillchar(si,sizeof(si),#0);
blockwrite(f,si,sizeof(si));
for x2:=1 to 2000 do begin
seek(f2,x2-1);
read(f2,s2);
if (s2<>'') then begin
inc(numstr);
si.offset[x2]:=filepos(f);
blockwrite(f,s2[0],ord(s2[0])+1);
inc(totsize,ord(s2[0])+1);
end else si.offset[x2]:=-1;
end;
seek(f,0);
blockwrite(f,si,sizeof(si));
close(f);
close(f2);
writeln('Finished!');
end;

procedure compile(impname,compname:string);
begin
numstr:=0;
totsize:=0;
writeln('Import File : '+allcaps(impname));
writeln('Export File : '+allcaps(compname));
writeln;
assign(t,impname);
{$I-} reset(t); {$I+}
if (ioresult<>0) then begin
        writeln('Error opening input file: '+impname);
        halt;
end;
assign(f2,'MAKELANG.~~~');
rewrite(f2);
ts2:='';
write('Setting up string database... ');
for x:=0 to 1999 do begin
write(f2,ts2);
end;
writeln('Finished!');
write('Importing '+allcaps(impname)+'... ');
linenum:=0;
while not(eof(t)) do begin
readln(t,s);
inc(linenum);
if (copy(s,1,1)<>';') and (s<>'') then begin
if not(setstring(copy(s,8,length(s)),value(stripboth(copy(s,1,5),' ')))) then
        begin
                writeln('Error!');
                writeln;
                writeln(allcaps(impname)+' - Line #',linenum,' in file: Duplicate String.');
                close(f2);
                close(t);
                {$I-} erase(f2); {$I+}
                if (ioresult<>0) then begin end;
                halt;
        end;
end;
end;
writeln('Finished!');
write('Compiling '+allcaps(compname)+'... ');
assign(f,compname);
compilestrings;
close(t);
{$I-} erase(f2); {$I+}
if (ioresult<>0) then begin
end;
writeln('Strings: ',numstr,'  Data: ',totsize);
end;

end.
