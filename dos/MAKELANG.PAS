program buildstring;

uses dos,crt,misc,oldlang,expstr,strfix;

var systatf:file of MatrixREC;
    systat:MatrixREC;
    NexusDir:STRING;
    impname,compname:string;
    activity:byte;


procedure writesema;
var f:file;
    x:integer;
    t:file;
    sr:searchrec;
begin
  findfirst(adrv(systat.semaphorepath)+'INUSE.*',anyfile,sr);
  while (doserror=0) do begin
        x:=value(copy(sr.name,pos('.',sr.name)+1,length(sr.name)-pos('.',sr.name)));
        if (x=0) then x:=1000;
        assign(f,adrv(systat.semaphorepath)+'INUSE.'+cstrnfile(x));
        {$I-} reset(f); {$I+}
        if (ioresult=0) then begin
               close(f);
               assign(t,adrv(systat.semaphorepath)+'READLANG.'+cstrnfile(x));
			rewrite(t);
			close(t);
        end;
        findnext(sr);
   end;
end;


function getcompname:string;
var ps:DirStr;
    ns:NameStr;
    es:ExtStr;
begin
    fsplit(fexpand(impname),ps,ns,es);
    getcompname:=systat.gfilepath+ns+'.NXL';
end;

function getcompname2:string;
begin
    getcompname2:=fexpand(impname);
end;

procedure title;
begin
writeln('MAKELANG v1.10 - External String Compiler for Nexus Bulletin Board System');
writeln('(c) Copyright 1996-2000 George A. Roberts IV. All rights reserved.');
writeln;
end;

procedure helpscreen;
begin
textcolor(7);
textbackground(0);
clrscr;
title;
writeln('Syntax:');
writeln;
writeln('    MAKELANG [/U|/X] [SOURCE]');
writeln;
writeln('By default, MAKELANG will assume complete compile of a source file.  The SOURCE');
writeln('parameter should be the filename (no extension) of the <language>.TXT file that');
writeln('contains the strings to be compiled.  This text file MUST have the extension of');
writeln('.TXT.');
writeln;
writeln('Options:');
writeln;
writeln('    /U       COMPILE UPDATE FILE:  SOURCE should be the filename (no extension)');
writeln('             of the <language>.NEW file that contains the updated strings.');
writeln('             The file MUST have an extension of .NEW');
writeln('    /X       EXPORT FROM LANGUAGE:  SOURCE should be the <language> name that');
writeln('             you wish to export.  This should be the 8 character filename (no');
writeln('             extension) of the <language>.NXL file to be exported from.');
writeln('             The file <language>.EXP will be created in the current directory.');
halt;
end;

procedure getparams;
var x,x2:integer;
    s:string;
begin
x2:=paramcount;
if (x2=0) then helpscreen;
x:=1;
activity:=1;
while (x<=x2) do begin
        s:=paramstr(x);
        if (copy(s,1,1)='-') or (copy(s,1,1)='/') and (length(s)>1) then begin
        case upcase(s[2]) of
                '?':begin
                        helpscreen;
                    end;
                'U':begin
                        activity:=2;
                    end;
                'X':begin
                        activity:=3;
                    end;
        end;
        end else begin
                        impname:=paramstr(x);
        end;
inc(x);
end;
end;

begin
getparams;
title;
if (pos('.',impname)<>0) then impname:=copy(impname,1,pos('.',impname)-1);
case activity of
        1:impname:=impname+'.TXT';
        2:impname:=impname+'.NEW';
        3:impname:=impname+'.EXP';
end;
nexusdir:=getenv('NEXUS');
if (nexusdir='') then begin
        writeln('You must have your NEXUS environment variable set.');
        halt;
end;
if (nexusdir[length(nexusdir)]<>'\') then nexusdir:=nexusdir+'\';
assign(systatf,nexusdir+'MATRIX.DAT');
{$I-} reset(systatf); {$I+}
if (ioresult<>0) then begin
        writeln('Error opening MATRIX.DAT!');
        halt;
end;
read(systatf,systat);
close(systatf);
compname:=getcompname;
impname:=getcompname2;
case activity of
        1:begin
          compile(impname,compname);
          writesema;
          end;
        2:begin
          update(impname,compname);
          writesema;
          end;
        3:begin
          export(compname,impname);
          end;
end;
end.
