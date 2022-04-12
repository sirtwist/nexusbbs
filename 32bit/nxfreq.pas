program mxfreq;

uses myio,dos,crt,misc;

{$I nexus.inc}

var
   ver : string;
   a:TEXT;
   NexusDir:string;
   NFile:file of smalrec;
   NRec:smalrec;
   MFile:file of Matrixrec;
   MRec:Matrixrec;
   nx:ulrec;
   nxf:file of ulrec;
   cnt:integer;
   outfile:string;

procedure cfgheader;
begin
textcolor(7);
textbackground(0);
clrscr;
DRAWWINDOW2(1,1,78,4,1,3,0,11,'');
TEXTCOLOR(15);
GOTOXY(2,2);
write('nxFREQ v',ver,' - FREQ Directory List Creator for Nexus Bulletin Board System');
GOTOXY(2,3);
write('(c) Copyright 1995-97 Internet Pro''s Network LLC. All rights reserved.');
TEXTCOLOR(7);
TEXTBACKGROUND(0);
gotoxy(1,6);
end;

procedure helpscreen(emsg:string);
begin
cfgheader;
if (emsg<>'') then begin
writeln('ERROR: '+emsg);
writeln;
end;
writeln('Syntax:    NXFREQ [OUTPUTFILE]');
writeln;
writeln('           OUTPUTFILE  =  This is the filename of the FREQ directory list that');
writeln('                          nxFREQ will create');
writeln;
halt;
end;

procedure getparams;
var x:integer;
    sp:string;
begin
  if (paramcount=0) then helpscreen('');
  x:=1;
  while (x<=paramcount) do begin
        sp:=allcaps(paramstr(x));
        case sp[1] of
                '/','-':begin
                        case sp[2] of
                                '?','H':helpscreen('');
                        end;
                        end;
                 else begin
                        outfile:=allcaps(fexpand(sp));
                 end;
        end;
        inc(x);
   end;
   if (outfile='') then begin
        helpscreen('No output filename specified.');
   end;
end;

begin
     {$I-}
     FileMode:=66;
     ver     := '1.11';

getparams;
cfgheader;
cursoron(FALSE);
textcolor(15);

     NexusDir:=allcaps(getenv('NEXUS'));
     if (nexusdir[length(nexusdir)]<>'\') then nexusdir:=nexusdir+'\';
     assign(mfile,nexusdir+'MATRIX.DAT');
     {$I-} reset(MFile); {$I+}
     if (IOResult <> 0) then begin
        writeln('ERROR: Cannot open '+nexusdir+'MATRIX.DAT... aborting.');
        cursoron(true);
        halt;
     end;
     read(MFile,MRec);
     close(MFile);
     assign(NXF,MRec.gfilepath+'FBASES.DAT');
     reset(NXF);
     if IOResult <> 0 then begin
        writeln('ERROR: Cannot open '+allcaps(mrec.gfilepath)+'FBASES.DAT... aborting.');
        cursoron(true);
        halt;
     end;
     ASSIGN(A,outfile);
     {$I-} REwrite(A); {$I+}
     if (ioresult<>0) then begin
        writeln('ERROR: Cannot create output file '+allcaps(outfile)+'... aborting.');
        cursoron(TRUE);
        halt;
     end;

     gotoxy(1,6);
     textcolor(3);
     writeln('Reading file     : ');
     gotoxy(20,6);
     textcolor(15);
     writeln(mrec.gfilepath+'FBASES.DAT');
     gotoxy(1,7);
     textcolor(3);
     writeln('Creating file    : ');
     gotoxy(20,7);
     textcolor(15);
     writeln(outfile);
     gotoxy(1,8);
     textcolor(3);
     writeln('Adding filebase  - ');
     cnt := 0;

     while not(eof(nxf)) do begin
        cnt:=filepos(nxf);
        read(NXF,NX);
        if not(nx.cdrom) then begin
                WRITELN(A,NX.DLPATH);
        end;
        gotoxy(20,8);
        textcolor(15);
        cwrite('%150%'+mln(cstr(cnt),5)+' %030%- '+mln(nx.name,50));
     end;
     gotoxy(1,9);
     writeln('Finished!');
     close(a);
     cursoron(true);
end.
