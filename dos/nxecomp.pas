{$A+,B+,D-,E+,F+,G+,I+,L-,N-,O-,R+,S+,V-}
{$M 65000,0,100000}      { Memory Allocation Sizes }
program nxeCOMP;

uses dos,crt,myio,misc,mkstring;

{$I NXERUN.INC}

CONST Tags : ARRAY[1..27] of STRING[20]= ('PRINT','PROMPT','GOTOXY','VAR',
                                         'CLS','DELAY','FILEEXIST','IF',
                                         'ELSE','ENDIF','SUBSCRIPT','YN',
                                         'NY','HALT','MENU','DOOR','$COPYRIGHT',
                                         '$CREATEDBY','$INFO1','$INFO2',
                                         'FILECREATE','FILEOPEN','FILEPUT',
                                         'FILECLOSE','FILEERR','DISPLAYFILE',
                                         'FILEPUTLN');

(*                        PRINT         displays a line of text with LF
                        PROMPT        displays a line of text without LF
                        FILEOPEN      opens a textfile
                        FILEPUT       writes a line to textfile
                        FILECLOSE     closes textfile
                        INTEGER       creates a variable of type INTEGER
                        STRING        creates a variable of type STRING
                        BOOLEAN       creates a variable of type BOOLEAN
                        DISPLAYFILE <filename>     *)

TYPE
        HEADER=
        RECORD
                ID:ARRAY[1..3] of CHAR;
                revision:byte;
                OurCR:STRING[93];
                CreatedBy:STRING[60];
                CreatedOn:STRING[19];
                Copyright:STRING[80];
                Info1:STRING[80];
                Info2:STRING[80];
                VStart:LONGINT;
                VSize:LONGINT;
                CodeStart:LONGINT;
                CodeSize:LONGINT;
                IndexStart:LONGINT;
                IndexSize:LONGINT;
                VIndexStart:LONGINT;
                VIndexSize:LONGINT;
        END;

TYPE vsptr=^vstring;
     vstring=
     RECORD
        ident:string[20];
        entry:string[255];
        id:integer;
        p,n:vsptr;
     END;

CONST nextcodeid:integer=1;
      nextstrid:integer=1;
      numkeywords:integer=27;

var f,f2:FILE;
      tcopyr,
      tcreatedby,
      tinfo1,
      tinfo2:string[80];
      ftime,stime,dtime:datetimerec;
    vs,vs1:vsptr;
    compilename:pathstr;
    curstring:string;
    curline:longint;
    finalname:pathstr;
    h:header;
    CodeIndex:ARRAY[1..2000] of LONGINT;
    VarIndex:ARRAY[1..100] of LONGINT;
    ConstIndex:ARRAY[1..100] of LONGINT;
    t:text;
    scrline:string;
    totalsize,numberread:longint;
    lshown:byte;

procedure comperror(x:integer);
begin
writeln;
writeln(curstring);
case x of
        1:writeln('Error 0001 (Line '+cstr(curline)+'): File not found - '+compilename);
        2:writeln('Error 0002 (Line '+cstr(curline)+'): Insufficient memory to allocate string');
        3:writeln('Error 0003 (Line '+cstr(curline)+'): Variable out of range');
        4:writeln('Error 0004 (Line '+cstr(curline)+'): Unknown identifier');
        5:writeln('Error 0005 (Line '+cstr(curline)+'): " Expected');
end;
cursoron(TRUE);
halt;
end;

procedure createnewstring(s1:string; v:string);
var vs2:vsptr;
begin
vs1:=vs;
vs2:=NIL;
while (vs1<>NIL) do begin
        vs2:=vs1;
        vs1:=vs1^.n;
end;
new(vs1);
if (vs1<>NIL) then begin
if (vs=NIL) then vs:=vs1;
vs1^.p:=vs2;
vs1^.id:=nextstrid;
inc(nextstrid);
vs1^.ident:=allcaps(s1);
vs1^.entry:=v;
vs1^.n:=NIL;
if (vs2<>NIL) then
vs2^.n:=vs1;
end else begin
        comperror(1);
end;
end;

procedure disposestrings;
var vs2:vsptr;
begin
vs1:=vs;
vs2:=NIL;
while (vs1<>NIL) do begin
        vs2:=vs1^.n;
        dispose(vs1);
        vs1:=vs2;
end;
end;

function smci4(s2:string):string;
var ss:string;
    vs2:vsptr;
    found:boolean;
begin
if (allcaps(copy(s2,1,4))='SYS.') then begin
        if (allcaps(copy(s2,5,length(s2)))='NAME') then begin
                ss:=#3+'400'+#3;
        end;
        if (allcaps(copy(s2,5,length(s2)))='SYSOP') then begin
                ss:=#3+'401'+#3;
        end;
end else if (allcaps(copy(s2,1,3))='STR') then begin
        ss:=#1+copy(s2,4,length(s2))+#1;
end else begin
vs1:=vs;
vs2:=NIL;
found:=FALSE;
ss:=s2;
while (vs1<>NIL) and not(found) do begin
        vs2:=vs1^.n;
        if allcaps(vs1^.ident)=allcaps(s2) then begin
                ss:=#3+cstr(vs1^.id)+#3;
                found:=TRUE;
        end;
        vs1:=vs2;
end;
vs1:=vs;
end;
smci4:=ss;
end;

function varstring(s:string):string;
var ps1,ps2:integer;
    ss:string;
    done:boolean;

function substone(src,old,new:string):string;
var p:integer;
begin
  if (old<>'') then begin
    p:=pos(old,src);
    if (p>0) then begin
      insert(new,src,p+length(old));
      delete(src,p,length(old));
    end;
  end;
  substone:=src;
end;

begin
  ss:=s;
  done:=false;
  while not(done) do begin  
        ps1:=pos('$',ss);
	if (ps1<>0) then begin
		ss[ps1]:=#28;
                ps2:=pos('$',ss);
		if (ps2-ps1<=1) then begin end else
		if (ps2<>0) then
                        ss:=substone(ss,copy(ss,ps1,(ps2-ps1)+1),smci4(copy(ss,ps1+1,(ps2-ps1)-1)));
	end;
        if (pos('$',ss)=0) then done:=TRUE;
  end;
  for ps1:=1 to length(ss) do if (ss[ps1]=#28) then ss[ps1]:='$';
  varstring:=ss;
end;

function quotedstring(s:string):string;
var x,i1,i2:integer;
        found:boolean;
begin
i1:=pos('"',s);
if (i1=0) then begin
        quotedstring:='';
        exit;
end;
x:=length(s);
found:=false;
while (x>i1) and not(found) do begin
        if (s[x]='"') then begin
        i2:=x;
        found:=TRUE;
        end else dec(x);
end;
if not(found) then begin
        comperror(5);
end;
quotedstring:=varstring(copy(s,i1+1,(i2-i1)-1));
end;

function parenstr(s:string):string;
var x,i1,i2:integer;
        found:boolean;
begin
i1:=pos('(',s);
if (i1=0) then begin
        parenstr:='';
        exit;
end;
x:=length(s);
found:=false;
while (x>i1) and not(found) do begin
        if (s[x]=')') then begin
        i2:=x;
        found:=TRUE;
        end else dec(x);
end;
if not(found) then begin
        comperror(5);
end;
parenstr:=varstring(copy(s,i1+1,(i2-i1)-1));
end;

function commastr(s:string; x:integer):string;
var x2,x3:integer;
    s2:string;
begin
x3:=1;
while (x3<=x) do begin
x2:=pos(',',s);
if (x2=0) then begin
        commastr:=s;
        exit;
end;
s2:=copy(s,1,pos(',',s)-1);
s:=copy(s,pos(',',s)+1,length(s));
inc(x3);
end;
commastr:=s2;
end;

function getvartype(var s:string):byte;
var s2:string;
begin
s2:=copy(stripboth(s,' '),1,pos(' ',s)-1);
s:=stripboth(copy(stripboth(s,' '),pos(' ',s)+1,length(s)),' ');
if (allcaps(s2)='STRING') then begin
        getvartype:=1;
        exit;
end;
end;

function getvarname(var s:string):string;
var s2:string;
begin
s2:=copy(stripboth(s,' '),1,pos(' ',s)-1);
s:=stripboth(copy(stripboth(s,' '),pos(' ',s)+1,length(s)),' ');
getvarname:=allcaps(s2);
end;

procedure processline(s:string);
var thistag:string;
    x:integer;
    b2:byte;
    found:boolean;
    s2:string;
    w:word;
    l:longint;
begin
curstring:=s;
s:=stripboth(s,' ');
if (s<>'') and (copy(s,1,1)<>';') then begin
if (pos(' ',s)=0) then begin
        if (pos('(',s)=0) then begin
                thistag:=s;
                s:='';
        end else begin
                thistag:=striplead(copy(s,1,pos('(',s)-1),' ');
                s:=striptrail(copy(s,pos('(',s),length(s)),' ');
        end;
end else begin
thistag:=copy(s,1,pos(' ',s)-1);
s:=stripboth(copy(s,pos(' ',s)+1,length(s)),' ');
end;
x:=1;
found:=FALSE;
while (x<numkeywords+1) and not(found) do begin
        if allcaps(thistag)=tags[x] then begin
                if (x<>4) and not(x in [17..20]) then begin
                CodeIndex[nextcodeid]:=filepos(f);
                blockwrite(f,nextcodeid,2);
                inc(nextcodeid);
                end;
                case x of
                        1:begin
                                b2:=1;
                                blockwrite(f,b2,1);
                                s2:=quotedstring(s);
                                blockwrite(f,s2[0],1);
                                blockwrite(f,s2[1],length(s2));
                                found:=TRUE;
                          end;
                        2:begin
                                b2:=2;
                                blockwrite(f,b2,1);
                                s2:=quotedstring(s);
                                blockwrite(f,s2[0],1);
                                blockwrite(f,s2[1],length(s2));
                                found:=TRUE;
                          end;
                        3:begin
                                b2:=3;
                                blockwrite(f,b2,1);
                                b2:=value(commastr(s,1));
                                blockwrite(f,b2,1);
                                b2:=value(commastr(s,2));
                                blockwrite(f,b2,1);
                                found:=TRUE;
                          end;
                        4:begin
                                case getvartype(s) of
                                        1:begin
                                          createnewstring(getvarname(s),quotedstring(s));
                                          found:=TRUE;
                                          end;
                                end;
                          end;
                        5:begin
                                b2:=4;
                                blockwrite(f,b2,1);
                                found:=TRUE;
                          end;
                        6:begin
                                l:=value(s);
                                if (l<0) or (l>65535) then begin
                                        comperror(3);
                                end;
                                w:=l;
                                b2:=5;
                                blockwrite(f,b2,1);
                                blockwrite(f,w,2);
                                found:=TRUE;
                          end;
                        7:begin
                                b2:=6;
                                blockwrite(f,b2,1);
                                s2:=quotedstring(s);
                                blockwrite(f,s2[0],1);
                                blockwrite(f,s2[1],length(s2));
                                found:=TRUE;
                          end;
                        8:begin
                                b2:=7;
                                blockwrite(f,b2,1);
                                x:=0;
                                s:=stripboth(s,' ');
                                if (s<>'') and (copy(s,1,1)<>';') then begin
if (pos(' ',s)=0) then begin
        if (pos('(',s)=0) then begin
                thistag:=s;
                s:='';
        end else begin
                thistag:=striplead(copy(s,1,pos('(',s)-1),' ');
                s:=striptrail(copy(s,pos('(',s),length(s)),' ');
        end;
end else begin
thistag:=copy(s,1,pos(' ',s)-1);
s:=stripboth(copy(s,pos(' ',s)+1,length(s)),' ');
end;
end;
                          end;
                        9:begin
                                b2:=8;
                                blockwrite(f,b2,1);
                                found:=TRUE;
                          end;
                        10:begin
                                b2:=9;
                                blockwrite(f,b2,1);
                                found:=TRUE;
                          end;
                        11:begin
                                b2:=10;
                                blockwrite(f,b2,1);
                                l:=value(s);
                                if (l<0) or (l>255) then begin
                                        comperror(3);
                                end;
                                b2:=byte(l);
                                blockwrite(f,b2,1);
                                found:=TRUE;
                           end;
                        12:begin
                                b2:=11;
                                blockwrite(f,b2,1);
                                s2:=quotedstring(s);
                                blockwrite(f,s2[0],1);
                                blockwrite(f,s2[1],length(s2));
                                found:=TRUE;
                          end;
                        13:begin
                                b2:=12;
                                blockwrite(f,b2,1);
                                s2:=quotedstring(s);
                                blockwrite(f,s2[0],1);
                                blockwrite(f,s2[1],length(s2));
                                found:=TRUE;
                          end;
                        14:begin
                                b2:=13;
                                blockwrite(f,b2,1);
                                found:=TRUE;
                          end;
                        15:begin
                                b2:=14;
                                blockwrite(f,b2,1);
                                found:=TRUE;
                                s2:=commastr(s,1);
                                s2:=s2+commastr(quotedstring(s),2);
                                blockwrite(f,s2[0],1);
                                blockwrite(f,s2[1],length(s2));
                           end;
                        16:begin
                                b2:=15;
                                found:=TRUE;
                                l:=value(s);
                                if (l<0) or (l>65535) then begin
                                        comperror(3);
                                end;
                                w:=l;
                                blockwrite(f,b2,1);
                                blockwrite(f,w,2);
                                found:=TRUE;
                           end;
                        17:begin
                                tcopyr:=quotedstring(s);
                                found:=TRUE;
                           end;
                        18:begin
                                tcreatedby:=quotedstring(s);
                                found:=TRUE;
                           end;
                        19:begin
                                found:=TRUE;
                                tinfo1:=quotedstring(s);
                           end;
                        20:begin
                                found:=TRUE;
                                tinfo2:=quotedstring(s);
                           end;
                        21:begin
                                b2:=16;
                                blockwrite(f,b2,1);
                                found:=TRUE;
                                b2:=value(commastr(s,1));
                                blockwrite(f,b2,1);
                                s2:=quotedstring(commastr(s,2));
                                blockwrite(f,s2[0],1);
                                blockwrite(f,s2[1],length(s2));
                                b2:=value(commastr(s,3));
                                blockwrite(f,b2,1);
                           end;                                
                        22:begin
                                b2:=17;
                                blockwrite(f,b2,1);
                                found:=TRUE;
                                b2:=value(commastr(s,1));
                                blockwrite(f,b2,1);
                                s2:=quotedstring(commastr(s,2));
                                blockwrite(f,s2[0],1);
                                blockwrite(f,s2[1],length(s2));
                                b2:=value(commastr(s,3));
                                blockwrite(f,b2,1);
                           end;                                
                        23:begin
                                b2:=18;
                                blockwrite(f,b2,1);
                                found:=TRUE;
                                b2:=value(commastr(s,1));
                                blockwrite(f,b2,1);
                                s2:=quotedstring(commastr(s,2));
                                blockwrite(f,s2[0],1);
                                blockwrite(f,s2[1],length(s2));
                           end;                                
                        24:begin
                                b2:=19;
                                blockwrite(f,b2,1);
                                found:=TRUE;
                                b2:=value(s);
                                blockwrite(f,b2,1);
                           end;                                
                        25:begin
                                b2:=20;
                                blockwrite(f,b2,1);
                                found:=TRUE;
                                b2:=value(parenstr(s));
                                blockwrite(f,b2,1);
                           end;
                        26:begin
                                b2:=21;
                                blockwrite(f,b2,1);
                                found:=TRUE;
                                s2:=quotedstring(s);
                                blockwrite(f,s2[0],1);
                                blockwrite(f,s2[1],length(s2));
                           end;
                        27:begin
                                b2:=18;
                                blockwrite(f,b2,1);
                                found:=TRUE;
                                b2:=value(commastr(s,1));
                                blockwrite(f,b2,1);
                                s2:=quotedstring(commastr(s,2))+#13+#10;
                                blockwrite(f,s2[0],1);
                                blockwrite(f,s2[1],length(s2));
                           end;
                end;
        end;
        inc(x);
end;
if not(found) then comperror(4);
end;
end;

procedure buildvars;
var vs2:vsptr;
    b:byte;
begin
h.vstart:=filepos(f);
vs1:=vs;
vs2:=NIL;
fillchar(varindex,sizeof(varindex),#0);
while (vs1<>NIL) do begin
        vs2:=vs1^.n;
        varindex[vs1^.id]:=filepos(f);
        blockwrite(f,vs1^.id,2);
        b:=1;
        blockwrite(f,b,1);
        blockwrite(f,vs1^.entry[0],1);
        blockwrite(f,vs1^.entry[1],255);
        vs1:=vs2;
end;
vs1:=vs;
h.vsize:=filepos(f)-h.vstart;
end;

function getexename(s:string):string;
var p:pathstr;
    d:dirstr;
    n:namestr;
    e:extstr;
begin
p:=s;
fsplit(p,d,n,e);
getexename:=n+'.EXE';
end;

procedure title;
begin
writeln('nxeCOMP v0.99.05 - Nexecutable Compiler for Nexus Bulletin Board System');
writeln('(c) Copyright 1996-2000 George A. Roberts IV. All rights reserved.');
writeln;
end;

procedure helpscreen;
begin
textcolor(7);
textbackground(0);
clrscr;
title;
writeln('SYNTAX:  nxeCOMP [SourceFile]');
writeln;
writeln('         SourceFile is the source file for the NXE to be compiled.');
writeln('         An extention of .NXS is assumed unless otherwise specified.');
writeln;
halt;
end;

procedure updategraph;
var x2:integer;
begin
for x2:=lshown to 40 do begin
if (numberread>=((totalsize div 40)*x2)) then begin
                gotoxy(3+lshown,wherey);
                write('Û');
                inc(lshown);
                end;
end;
end;

procedure getparams;
var s:string;
    x:integer;
    found:boolean;
begin
        if (paramcount=0) then begin
                helpscreen;
        end;
        x:=1;
        while (x<=paramcount) do begin
                s:=paramstr(x);
                case upcase(s[1]) of
                        '-','/':begin
                                case upcase(s[2]) of
                                '?':helpscreen;
                                end;
                                end;
                            '?':begin
                                helpscreen;
                                end;
                        else begin
                                compilename:=s;
                        end;
                end;
        inc(x);
        end;
end;

begin
getparams;
title;
if (compilename='') then helpscreen;
if (pos('.',compilename)=0) then compilename:=compilename+'.NXS';
compilename:=allcaps(fexpand(compilename));
h.id[1]:='N';
h.id[2]:='X';
h.id[3]:='E';
h.revision:=1;
h.ourcr:='Portions of this code (c) Copyright 1996-2000 George A. Roberts IV.';
h.CreatedOn:=date+' '+time;
tcreatedby:='';
tcopyr:='';
tinfo1:='';
tinfo2:='';
h.CreatedBy:=tcreatedby;
h.Copyright:=tcopyr;
h.Info1:=tinfo1;
h.Info2:=tinfo2;
h.VStart:=0;
h.Vsize:=0;
h.codestart:=0;
h.codesize:=0;
h.indexstart:=0;
h.indexsize:=0;
h.VIndexStart:=0;
h.VIndexSize:=0;
fillchar(codeindex,sizeof(codeindex),#0);
finalname:=fexpand(getexename(compilename));
writeln('Compiling : ',compilename);
writeln('Creating  : ',finalname);
writeln;
getdatetime(stime);
assign(f2,compilename);
{$I-} reset(f2,1); {$I+}
if (ioresult<>0) then begin comperror(1); end;
totalsize:=filesize(f2);
close(f2);
assign(t,compilename);
{$I-} reset(t); {$I+}
if (ioresult<>0) then begin
comperror(1);
end;
numberread:=0;
assign(f,finalname);
rewrite(f,1);
blockwrite(f,nxeExeHdr,sizeof(nxeExeHdr));
blockwrite(f,h,sizeof(h));
h.codestart:=filepos(f);
curline:=1;
cursoron(FALSE);
lshown:=1;
write('0% °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° 100%');
gotoxy(4,wherey);
while not(eof(t)) do begin
readln(t,scrline);
inc(numberread,length(scrline)+2);
processline(scrline);
updategraph;
inc(curline);
end;
writeln;
dec(curline);
h.codesize:=filepos(f)-h.codestart;
buildvars;
h.indexstart:=filepos(f);
h.indexsize:=(nextcodeid-1)*4;
blockwrite(f,codeindex,(nextcodeid-1)*4);
h.vindexstart:=filepos(f);
h.vindexsize:=(nextstrid-1)*4;
blockwrite(f,varindex,(nextstrid-1)*4);
seek(f,sizeof(nxeExeHdr));
h.CreatedBy:=tcreatedby;
h.Copyright:=tcopyr;
h.Info1:=tinfo1;
h.Info2:=tinfo2;
blockwrite(f,h,sizeof(h));
close(t);
close(f);
disposestrings;
getdatetime(dtime);
timediff(ftime,stime,dtime);
writeln;
writeln(cstr(curline)+' lines, '+longtim(ftime)+', '+cstr(h.codesize)+' bytes code, '+cstr(h.vsize)+' bytes data.');
cursoron(TRUE);
end.
