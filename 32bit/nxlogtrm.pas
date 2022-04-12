program nxLOGTRM;

uses dos,crt,misc,between,myio,mkstring;

var tf,tf2:text;
    s,s2:string;
    numlines:longint;
    nodenum:integer;
    started:boolean;
    ver:string;
    w2,oldwind:windowrec;
    x,oldx,oldy:integer;
    add:array[1..10] of string;

procedure title;
begin
writeln('nxLOGTRM v',ver,' - Logfile Trimmer for Nexus Bulletin Board System.');
write('(c) Copyright 1997-2001 George A. Roberts IV. All right reserved.');
writeln;
end;

procedure opensystat;
var systatf:file of MatrixREC;
begin
nexusdir:=allcaps(getenv('NEXUS'));
if (nexusdir[length(nexusdir)]<>'\') then nexusdir:=nexusdir+'\';
start_dir:=bslash(FALSE,nexusdir);
assign(systatf,nexusdir+'MATRIX.DAT');
{$I-} reset(systatf); {$I+}
if (ioresult<>0) then begin
        displaybox('Error opening '+nexusdir+'MATRIX.DAT ... aborting.',3000);
        halt;
end;
read(systatf,systat);
close(systatf);
end;

procedure helpscreen;
begin
title;
writeln('Syntax: NXLOGTRM [filename] [filename] [filename...]');
writeln;
writeln('nxLOGTRM automatically trims your NEXUS.LOG, NXFILES.LOG, and NEXxxxx.LOG files');
writeln('located in your \NEXUS\LOGS directory.  The use of the additional filenames');
writeln('on the commandline is for support of third party Nexus utilities that support');
writeln('the Nexus Logfile Specification.  Up to 10 additional logfile names may be');
writeln('passed on the commandline.  If no path information is specified, nxLOGTRM will');
writeln('assume the logfile resides in your \NEXUS\LOGS directory.');
halt;
end;

procedure getparams;
var np,np2:integer;
    sp:string;
    idx,idx2:boolean;
begin
  if (paramcount>0) then begin
  np2:=1;
  np:=1;
  while (np2<=paramcount) do begin
        sp:=paramstr(np2);
        if (allcaps(sp)='/?') or (allcaps(sp)='-?') or (allcaps(sp)='?') then begin
          helpscreen;
        end else begin
          if (np<11) then begin
                  add[np]:=allcaps(sp);
                  inc(np);
          end;
        end;
        inc(np2);
  end;
  end;
end;

procedure processlog(outlog:string);
begin
writeln;
writeln('Processing file : '+outlog);
write('Trimming date   : Searching...');
assign(tf,outlog);
assign(tf2,adrv(systat.trappath)+'~NXLOGT.LOG');
{$I-} reset(tf); {$I+}
if (ioresult<>0) then begin
        writeln;
        writeln;
        writeln('Unable to open '+outlog);
        delay(2000);
        exit;
end;
rewrite(tf2);
started:=false;
while not(eof(tf)) do begin
        readln(tf,s);
        if not(started) and (copy(s,1,14)='--- Created by') then begin
                s2:=copy(s,length(s)-17,18);
                s2:=striplead(s2,' ');
                s2:=copy(s2,1,8);
                if (check_date(date,s2)<=systat.backsysoplogs-1) then begin
                started:=TRUE;
                writeln;
                write('Outputting log  :       lines');
                numlines:=0;
                end else begin
                gotoxy(19,wherey);
                clreol;
                write(s2);
                end;
        end;
        if (started) then begin
                writeln(tf2,s);
                inc(numlines);
                gotoxy(19,wherey);
                write(mrn(cstr(numlines),5));
        end;
end;
close(tf2);
close(tf);
{$I-} erase(tf); {$I+}
if (ioresult<>0) then begin end;
{$I-} rename(tf2,outlog); {$I+}
if (ioresult<>0) then begin
        displaybox('ERROR!! Cannot rename log file!',3000);
        halt;
end;
writeln;
end;

begin
ver:='1.01';
for x:=1 to 10 do add[x]:='';
getparams;
title;
opensystat;
for nodenum:=1 to 1000 do begin
        if exist(adrv(systat.trappath)+'NEX'+cstrn(nodenum)+'.LOG') then begin
        processlog(adrv(systat.trappath)+'NEX'+cstrn(nodenum)+'.LOG');
        end;
end;
processlog(adrv(systat.trappath)+'NEXUS.LOG');
processlog(adrv(systat.trappath)+'NXFILES.LOG');

for nodenum:=1 to 10 do begin
        if (add[nodenum]<>'') then begin
                if (pos('\',add[nodenum])=0) then begin
                        add[nodenum]:=adrv(systat.trappath)+add[nodenum];
                end;
                processlog(add[nodenum]);
        end;
end;
end.
