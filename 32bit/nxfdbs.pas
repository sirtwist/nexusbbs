{$A+,B+,D-,E+,F+,G-,I+,L-,N-,O-,R+,S+,V-}
{$M 64400,50000,200000}      { Memory Allocation Sizes }
program nxFDBS;

uses crt,dos,misc,nxfs2,myio;

var nkw,ndl:integer;

procedure repackfiles(kw,dl:integer);
var NXF,NXF2:nxFILEOBJ;
    ULF:File of ulrec;
    ulr:ulrec;
    x,x2:integer;
    s:string;
    w2:windowrec;
    tf:file;
    e:integer;

begin
        assign(ulf,adrv(systat.gfilepath)+'FBASES.DAT');
        {$I-} reset(ulf); {$I+}
        if (ioresult<>0) then begin
                displaybox('Error opening FBASES.DAT!',3000);
                exit;
        end;
        setwindow(w2,5,10,75,15,3,0,8,'Resizing File Databases',TRUE);
        textcolor(15);
        textbackground(0);
        gotoxy(2,2);
        write('File base        :');
        gotoxy(2,3);
        write('Current filename :');
        while not(eof(ulf)) do begin
                window(6,11,74,14);
                read(ulf,ulr);
                gotoxy(21,2);
                textcolor(3);
                textbackground(0);
                cwrite(mln(ulr.name,50));
                if (fbdirdlpath in ulr.fbstat) then begin
                        NXF.Init(adrv(ulr.dlpath)+ulr.filename+'.NFD',syst.nkeywords,syst.ndesclines);
                        NXF2.Init(adrv(ulr.dlpath)+ulr.filename+'.NFN',kw,dl);
                end else begin
                        NXF.Init(adrv(systat.filepath)+ulr.filename+'.NFD',syst.nkeywords,syst.ndesclines);
                        NXF2.Init(adrv(systat.filepath)+ulr.filename+'.NFN',kw,dl);
                end;
                if (NXF.Numfiles>0) then
                        for x:=1 to NXF.Numfiles do begin
                                NXF.Seekfile(x); NXF.Readheader;
                                gotoxy(21,3);
                                textcolor(3);
                                textbackground(0);
                                cwrite(mln(NXF.Fheader.filename,50));
                                NXF2.AddNewFile(NXF.Fheader);
                                x2:=1;
                                NXF.KeywordStartup;
                                s:=NXF.GetKeyword;
                                while (s<>'') and (x2<=kw) do begin
                                        NXF2.AddKeyword(s);
                                        s:=NXF.GetKeyword;
                                        inc(x2);
                                end;
                                x2:=1;
                                NXF.DescStartup;
                                s:=NXF.Getdescline;
                                while (s<>#1+'EOF'+#1) and (x2<=dl) do begin
                                        NXF2.AddDescLine(s);
                                        s:=NXF.GetDescline;
                                        inc(x2);
                                end;
                        end;
                        NXF.Done;
                        NXF2.Done;
                        if (fbdirdlpath in ulr.fbstat) then begin
                                if exist(adrv(ulr.dlpath)+ulr.filename+'.FDB') then begin
                                        assign(tf,adrv(ulr.dlpath)+ulr.filename+'.FDB');
                                        {$I-} erase(tf); {$I+}
                                        if (ioresult<>0) then begin end;
                                end;
                                assign(tf,adrv(ulr.dlpath)+ulr.filename+'.NFD');
                                {$I-} rename(tf,adrv(ulr.dlpath)+ulr.filename+'.FDB'); {$I+}
                                if (ioresult<>0) then begin
                                        displaybox('Error creating backup.',2000);
                                end else begin
                                        assign(tf,adrv(ulr.dlpath)+ulr.filename+'.NFN');
                                        {$I-} rename(tf,adrv(ulr.dlpath)+ulr.filename+'.NFD'); {$I+}
                                        if (ioresult<>0) then begin
                                                displaybox('Error resizing!',3000);
                                                displaybox('Backup of original: '+adrv(ulr.dlpath)+ulr.filename+'.FDB',3000);
                                        end;
                                end;
                        end else begin
                                if exist(adrv(systat.filepath)+ulr.filename+'.FDB') then begin
                                        assign(tf,adrv(systat.filepath)+ulr.filename+'.FDB');
                                        {$I-} erase(tf); {$I+}
                                        if (ioresult<>0) then begin end;
                                end;
                                assign(tf,adrv(systat.filepath)+ulr.filename+'.NFD');
                                {$I-} rename(tf,adrv(systat.filepath)+ulr.filename+'.FDB'); {$I+}
                                e:=ioresult;
                                if (e<>0) then begin
                                        if (e=2) then begin end else
                                        displaybox('Error creating backup.',2000);
                                end else begin
                                        assign(tf,adrv(systat.filepath)+ulr.filename+'.NFN');
                                        {$I-} rename(tf,adrv(systat.filepath)+ulr.filename+'.NFD'); {$I+}
                                        e:=ioresult;
                                        if (e<>0) then begin
                                                case e of
                                                        2:begin end;
                                                        else begin
                                                displaybox('Error resizing!',3000);


     displaybox('Backup of original: '+adrv(systat.filepath)+ulr.filename+'.FDB',3000);
                                                end;
                                              end;
                                        end;
                                end;
                        end;
        end;
        close(ulf);
        removewindow(w2);
end;

procedure helpscreen;
begin
writeln('nxFDBS v1.00 - Nexus File Database System <tm> RESIZER');
writeln('(c) Copyright 1996-2000 George A. Roberts IV. All rights reserved.');
writeln;
writeln('Syntax:   NXFDBS keywords desclines');
writeln;
writeln('          keywords     number of keywords allowed per file');
writeln('          desclines    number of description lines allowed per file');
writeln;
halt;
end;

procedure getparams;
var s:string;
    x:integer;
begin
if (paramcount<>2) then helpscreen;
x:=1;
while (x<=paramcount) do begin
        s:=paramstr(x);
        case x of
                1:nkw:=value(s);
                2:ndl:=value(s);
        end;
        inc(x);
end;
end;

procedure openfiles;
var systatf:file of MatrixREC;
begin
nexusdir:=getenv('NEXUS');
if (nexusdir[length(nexusdir)]='\') then nexusdir:=copy(nexusdir,1,length(nexusdir)-1);
start_dir:=nexusdir;
assign(systatf,nexusdir+'\MATRIX.DAT');
{$I-} reset(systatf); {$I+}
if (ioresult<>0) then begin
        displaybox('Error opening '+allcaps(nexusdir)+'\MATRIX.DAT!',3000);
        halt;
end;
read(systatf,systat);
close(systatf);
assign(systemf,adrv(systat.gfilepath)+'SYSTEM.DAT');
{$I-} reset(systemf); {$I+}
if (ioresult<>0) then begin
        displaybox('Error opening '+allcaps(adrv(systat.gfilepath))+'SYSTEM.DAT!',3000);
        halt;
end;
read(systemf,syst);
close(systemf);
end;

begin
cursoron(FALSE);
getparams;
openfiles;
repackfiles(nkw,ndl);
{$I-} reset(systemf); {$I+}
if (ioresult<>0) then begin
        displaybox('Error opening '+allcaps(adrv(systat.gfilepath))+'SYSTEM.DAT!',3000);
        halt;
end;
read(systemf,syst);
syst.nkeywords:=nkw;
syst.ndesclines:=ndl;
seek(systemf,0);
write(systemf,syst);
close(systemf);
cursoron(TRUE);
end.
