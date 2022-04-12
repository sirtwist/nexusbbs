{----------------------------------------------------------------------------}
{ nxNOTIFY - Nexecutable notifier for Nexus Bulletin Board System v1.00      }
{                                                                            }
{ All material contained herein is                                           }
{  (c) Copyright 1996-97 Epoch Development Company.  All Rights Reserved.    }
{  (c) Copyright 1995-96 Intuitive Vision Software.  All Rights Reserved.    }
{                                                                            }
{ MODULE     :  NXNOTIFY.PAS  (Main Program Module)                          }
{ AUTHOR     :  George A. Roberts IV                                         }
{                                                                            }
{----------------------------------------------------------------------------}

{$A+,B+,D-,E+,F+,G+,I+,L-,N-,O-,R+,S+,V-}
{$M 65000,0,100000}      { Memory Allocation Sizes }
program nxNOTIFY;

uses dos,crt,misc;

{$I NEXUS.INC}

const ver='1.03';

var sr:searchrec;
    t,t2,logf:text;
    x:integer;
    s:string;
    skipnode:integer;
    systatf:file of MatrixREC;
    systat:MatrixREC;
    Nexusdir:STRING;
    infile:string;
    isok,isnospace:boolean;

procedure title;
begin
writeln('nxNOTIFY v'+ver+' - Node Notifier for Nexus Bulletin Board System');
writeln('(c) Copyright 1996-2001 George A. Roberts IV. All rights reserved.');
writeln;
end;

procedure helpscreen;
begin
textcolor(7);
textbackground(0);
clrscr;
title;
writeln('Syntax:  nxNOTIFY Nexecutablename [node#]');
writeln;
writeln('         Nexecutablename = The [drive:][path]filename of the Nexecutable that');
writeln('                           you wish to notify all online users with.');
writeln;
writeln('         node#           = If you wish to exclude a specific node, pass');
writeln('                           the node # here');
writeln;
halt;
end;

procedure startlog;
begin
{$I-} append(logf); {$I+}
if (ioresult<>0) then begin
        rewrite(logf);
end;
writeln(logf,'');
writeln(logf,'--- Created by nxNOTIFY v'+ver+' on '+date+' '+time);
writeln(logf,'');
end;

procedure logit(c:char;s:string);
begin
writeln(logf,c,' ',time,' ',s);
end;

procedure haltit;
begin
logit('!','Halt; nxNOTIFY v'+ver);
close(logf);
halt;
end;

procedure endit;
begin
logit(':','End; nxNOTIFY v'+ver);
close(logf);
halt;
end;

procedure copyfile(var ok,nospace:boolean; showprog:boolean;
                   srcname,destname:astr);
var buffer:array[1..16384] of byte;
    totread,fs,dfs:longint;
    nrec,i,x,x2:integer;
    src,dest:file;

  procedure dodate;
  var tm:longint;
  begin
    getftime(src,tm);
    setftime(dest,tm);
  end;

begin
  ok:=TRUE; nospace:=FALSE;
  assign(src,srcname);
  filemode:=64;
  {$I-} reset(src,1); {$I+}
  if (ioresult<>0) then begin ok:=FALSE; exit; end;
  dfs:=freek(exdrv(destname));
  fs:=trunc(filesize(src)/1024.0)+1;
  if (fs>=dfs) then begin
    close(src);
    nospace:=TRUE; ok:=FALSE;
    exit;
  end else begin
    fs:=filesize(src);
    assign(dest,destname);
    filemode:=66;
    {$I-} rewrite(dest,1); {$I+}
    if (ioresult<>0) then begin ok:=FALSE; exit; end;
    if (showprog) then begin
      write('0% ');
    end;
    x:=1;
    totread:=0;
    repeat
      filemode:=64;
      blockread(src,buffer,16384,nrec);
      filemode:=66;
      blockwrite(dest,buffer,nrec);
      totread:=totread+nrec;
      if (showprog) then begin
        for x2:=x to 10 do begin
        if (totread>=((fs div 10)*x2)) then begin
                write('²');
                inc(x);
                end;
        end;
      end;
      until (nrec<16384);
      writeln(' 100%');
    filemode:=66;
    close(dest);
    filemode:=64;
    close(src);
    filemode:=66;
    dodate;
  end;
end;


begin
if (paramcount=0) then helpscreen;
infile:=paramstr(1);
skipnode:=0;
if (paramcount=2) then skipnode:=value(paramstr(2));
if (infile='?') or (infile='/?') or (infile='-?') then helpscreen;
title;
assign(logf,'NXNOTIFY.LOG');
startlog;
logit(':','Begin; nxNOTIFY v'+ver);
Nexusdir:=getenv('NEXUS');
if (nexusdir[length(nexusdir)]<>'\') then nexusdir:=nexusdir+'\';
assign(systatf,nexusdir+'MATRIX.DAT');
{$I-} reset(systatf); {$I+}
if (ioresult<>0) then begin
        writeln('Error opening '+nexusdir+'MATRIX.DAT...');
        logit('!','Error opening '+nexusdir+'MATRIX.DAT');
        haltit;
end;
read(systatf,systat);
close(systatf);
assign(t,infile);
writeln('Searching for nodes in use...');
writeln;
logit('~','Searching for nodes in use...');
findfirst(systat.semaphorepath+'INUSE.*',anyfile,sr);
while (doserror=0) do begin
        x:=value(copy(sr.name,pos('.',sr.name)+1,length(sr.name)-pos('.',sr.name)));
        if (x=0) then x:=1000;
        if (skipnode<>x) then begin
        if not(exist(systat.semaphorepath+'WAITING.'+cstrnfile(x))) then begin
        logit('+','Found active node: Node #'+cstr(x));
        writeln('Found node #'+cstr(x));
        copyfile(isok,isnospace,TRUE,infile,systat.semaphorepath+'AUTORUN.'+cstrnfile(x));
        if not(isok) then begin
                if (isnospace) then logit('!','Error creating AUTORUN for node #'+cstr(x)+' - No space!')
                else logit('!','Error creating AUTORUN for node #'+cstr(x)+' - No space!');
        end;
        end;
        end;
        findnext(sr);
end;
writeln('Finished!');
endit;
end.
