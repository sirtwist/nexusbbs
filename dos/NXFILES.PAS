{$A+,B+,D-,E+,F+,G+,I+,L-,N-,O-,R+,S+,V-}
{$M 20000,0,40000}      { Memory Allocation Sizes }
program nxFILES;

uses dos,crt,misc,myio,cdrom3,fbcommon,nxfs2,mkmisc;

const processfile:string='FILES.BBS';
      startline:longint=1;
      extchar:byte=14;
      firstline:byte=14;
      oneline:boolean=FALSE;
      nocd:boolean=FALSE;
      usecd:integer=0;
      version2:string='1.11';
      build:string='';
      skipnoexist:boolean=FALSE;
      validate:byte=1;
      namelogged:boolean=FALSE;
      datesubtract:integer=0;
      deleteafter:boolean=FALSE;
      presentyes:boolean=FALSE;
      onemore:boolean=TRUE;

var t:text;
    lf:text;
    oldx,oldy:integer;
    oldwind:windowrec;
    s:string;
    x2:integer;
    logbases,logfiles,logimport,logleft:integer;
    logfile:string;
    c:char;
    pl:longint;
    ulf:file of ulrec;
    current:integer;
    systatf:file of matrixrec;
    NXF:nxFILEOBJ;
    fdescf:text;
    filename,description:string;
    done2:boolean;


procedure endprogram;
begin
removewindow(oldwind);
cursoron(TRUE);
if oldy=25 then writeln;
gotoxy(1,oldy);
textcolor(7);
textbackground(0);
halt;
end;

procedure helpscreen;
begin
textcolor(7);
textbackground(0);
clrscr;
writeln('nxFILES v',version2,' - FILES.BBS importer for Nexus Bulletin Board System');
writeln('(c) Copyright 1996-2002 George A. Roberts IV. All rights reserved.');
writeln;
writeln('Syntax :  NXFILES [options]');
writeln;
writeln('             -F[FILENAME] = Used to override the default name FILES.BBS');
writeln('             -S[Line#]    = Used to override the default start line of 1');
writeln('             -L[LinePos]  = Used to override the default first line');
writeln('                            description start column of 14');
writeln('             -C[LinePos]  = Used to override the default extended');
writeln('                            description start column of 14');
writeln('             -E           = Used to override the default of flagging');
writeln('                            a non-existant file as offline - Skip File.');
writeln('             -D           = Delete FILES.BBS file when finished.');
writeln('             -V[0|1|2]    = 0 = Nexus Default Validation');
writeln('                            1 = Validate ALL files (DEFAULT)');
writeln('                            2 = Mark ALL files unvalidated');
writeln('             -X[-|Number] = -           Do not search CD-ROM bases');
writeln('                            CD-Number   Search ONLY this disk number');
writeln('             -Y           = Present "Yes" to continue question');
writeln('             -T[Days]     = Set Upload Date forward [Days] number of days');
writeln('             -G[Logname]  = Set Log File Name (default is NXFILES.LOG in');
writeln('                            the \NEXUS\LOGS\ directory).');
halt;
end;

procedure getparams;
var s2:string;
    x:integer;
begin
x:=1;
logfile:='';
while (x<=paramcount) do begin
        s2:=paramstr(x);
        if (s2[1]='-') or (s2[1]='/') then
        case upcase(s2[2]) of
                'F':processfile:=copy(s2,3,length(s2)-2);
                'S':startline:=value(copy(s2,3,length(s2)-2));
                'C':extchar:=value(copy(s2,3,length(s2)-2));
                'O':oneline:=TRUE;
                'L':firstline:=value(copy(s2,3,length(s2)-2));
                'G':logfile:=copy(s2,3,length(s2)-2);
                'D':deleteafter:=TRUE;
                'E':skipnoexist:=TRUE;
                'Y':presentyes:=TRUE;
                'T':datesubtract:=value(copy(s2,3,length(s2)-2));
                'V':begin
                        validate:=value(copy(s2,3,length(s2)-2));
                        if (validate>2) then validate:=1;
                    end;
                'X':begin
                        if s2[3]='-' then nocd:=TRUE else
                        usecd:=value(copy(s2,3,length(s2)-2));
                    end;
                '?':helpscreen;
                        
        end;
        inc(x);
end;
end;

procedure logit(c:char;s:string);
begin
writeln(lf,c,' ',time,' ',s);
end;

procedure openmatrix;
var nexusdir:string;
begin
nexusdir:=getenv('NEXUS');
if (nexusdir='') then begin
        writeln('You must have your NEXUS environment variable set for nxFILES to work');
        writeln('properly.');
        writeln;
        halt;
end;
if (nexusdir[length(nexusdir)]<>'\') then nexusdir:=nexusdir+'\';
start_dir:=copy(nexusdir,1,length(nexusdir)-1);
assign(systatf,nexusdir+'MATRIX.DAT');
{$I-} reset(systatf); {$I+}
if (ioresult<>0) then begin
        displaybox('Error reading '+allcaps(nexusdir)+'MATRIX.DAT',3000);
        endprogram;
end;
read(systatf,systat);
close(systatf);
assign(systemf,adrv(systat.gfilepath)+'SYSTEM.DAT');
{$I-} reset(systemf); {$I+}
if (ioresult<>0) then begin
        displaybox('Error reading '+allcaps(adrv(systat.gfilepath))+'SYSTEM.DAT',3000);
        endprogram;
end;
read(systemf,syst);
close(systemf);
if (logfile='') then logfile:=adrv(systat.trappath)+'NXFILES.LOG';
assign(lf,logfile);
{$I-} append(lf); {$I+}
if (ioresult<>0) then begin
        rewrite(lf);
end;
writeln(lf,'');
writeln(lf,'--- Created by nxFILES v'+version2+' on '+date+' '+time);
writeln(lf,'');
logit(':','Begin; nxFILES v'+version2);
end;


function loadfileboard(board:integer):boolean;
var x,x2:integer;
begin
loadfileboard:=TRUE;
if (board>filesize(ulf)-1) then begin
        loadfileboard:=FALSE;
        exit;
end;
seek(ulf,board);
{$I-} read(ulf,memuboard); {$I-}
if (ioresult<>0) then begin
        loadfileboard:=FALSE;
        exit;
end else begin
    if (memuboard.cdrom) then begin
           if not(nocd) then begin
           x:=1;
           x2:=0;
           while (x<=26) do begin
           if (memuboard.cdnum=cdavail[x]) then x2:=x;
           inc(x);
           end;
           if (x2<>0) then begin
           if (memuboard.cdnum=cdavail[x2]) then begin
                if ((usecd<>0) and (memuboard.cdnum=usecd)) or (usecd=0) then
                begin
                        if (memuboard.dlpath='') then begin
                                memuboard.dlpath:=chr(x2+64)+':\';
                        end else
                        if memuboard.dlpath[1]='\' then memuboard.dlpath:=chr(x2+64)+':'+memuboard.dlpath
                                else
                        if memuboard.dlpath[2]=':' then memuboard.dlpath[1]:=chr(x2+64) else
                                if memuboard.dlpath[1]<>'\' then memuboard.dlpath:=chr(x2+64)+
                                        ':\'+memuboard.dlpath;
                end else loadfileboard:=FALSE;
           end;
           end else loadfileboard:=FALSE;
           end else loadfileboard:=FALSE;
    end else if (usecd<>0) then loadfileboard:=FALSE;
end;
end;

function fit(f1,f2:string):boolean;
var tf:boolean; c:integer;
begin
  tf:=TRUE;
  for c:=1 to 12 do
    if (f1[c]<>f2[c]) and (f1[c]<>'?') then tf:=FALSE;
  fit:=tf;
end;

procedure getfile;
var another:boolean;
    x3,rn,cn:integer;
    fi:file;
    fpacked:longint;
    dt:datetime;
    ex:boolean;
    s2:string;
var rfpts:real;
begin
onemore:=FALSE;
assign(fdescf,'~NXF.TMP');
rewrite(fdescf);
inc(logfiles);
if (s<>'') then
if not(s[1] in [' ','*',';']) then begin
        filename:=copy(s,1,pos(' ',s)-1);
        writeln(fdescf,copy(s,firstline,45));
        another:=TRUE;
        x3:=1;
        while (s<>'') and (another) and not(eof(t)) do begin
                readln(t,s);
                if (s='') then another:=FALSE;
                if (s<>'') then if (s[1]<>' ') and (s[1]<>'|') then begin
                        another:=FALSE;
                        onemore:=TRUE;
                end;
                if (another) and (x3<syst.ndesclines) then begin
                inc(x3);
                writeln(fdescf,copy(s,extchar,45));
                end;
        end;
end;
close(fdescf);
rn:=0; cn:=1;
while (cn<=pl) and (rn=0) do begin
    NXF.Seekfile(cn);
    NXF.ReadHeader;
    if fit(align(filename),align(NXF.Fheader.filename)) then rn:=cn;
    inc(cn);
end;
if (rn=0) then begin

        ex:=exist(memuboard.dlpath+filename);
        if (ex) or not(skipnoexist) then begin
        assign(fi,memuboard.dlpath+filename);
        {$I-} reset(fi,1); {$I+}
        if (ioresult<>0) then begin
                NXF.Fheader.Filesize:=0;
                NXF.Fheader.FileDate:=0;
        end else begin
        NXF.Fheader.Filesize:=(filesize(fi));
                GetFTime(fi,fpacked);
                UnpackTime(fpacked,dt);
                NXF.Fheader.FileDate:=DTToUnixDate(dt);
        close(fi);
        end;
        NXF.Fheader.FheaderID[1]:=#1;
        NXF.Fheader.FheaderID[2]:='N';
        NXF.Fheader.FheaderID[3]:='E';
        NXF.Fheader.FheaderID[4]:='X';
        NXF.Fheader.FheaderID[5]:='U';
        NXF.Fheader.FheaderID[6]:='S';
        NXF.Fheader.FheaderID[7]:=#1;
        NXF.Fheader.filename:=allcaps(filename);
        NXF.Fheader.magicname:='';
        NXF.Fheader.uploadedby:=caps(systat.sysopname);
        NXF.Fheader.UploadedDate:=u_daynum(datelong+' '+time)+(datesubtract*86400);
        NXF.Fheader.NumDownloads:=0;
        NXF.Fheader.LastDLDate:=NXF.Fheader.UploadedDate;
        NXF.Fheader.Access:='';
        NXF.Fheader.AccessKey:='';

        fillchar(NXF.Fheader.Reserved,sizeof(NXF.Fheader.Reserved),#0);

        rfpts:=trunc(NXF.Fheader.Filesize/1024.0)/systat.fileptcompbasesize;
        NXF.Fheader.filepoints:=round(rfpts);
        if (NXF.Fheader.filepoints<1) then NXF.Fheader.filepoints:=1;

        NXF.Fheader.FileFlags:=[];
        if ((not systat.validateallfiles) and (validate=0)) or
        (validate=2) then NXF.Fheader.FileFlags:=NXF.Fheader.FileFlags+[ffnotval];

        if not(ex) then NXF.Fheader.FileFlags:=NXF.Fheader.FileFlags+[ffisrequest];
        NXF.AddNewFile(NXF.Fheader);
        {$I-} reset(fdescf); {$I+}
        if (ioresult<>0) then begin
        end else begin
                while not(eof(fdescf)) do begin
                        readln(fdescf,s2);
                        NXF.AddDescLine(s2);
                end;
                close(fdescf);
                {$I-} erase(fdescf); {$I+}
                if (ioresult<>0) then begin end;
        end;
        cwrite('    %030%Adding file : %150%'+filename);
        if not(ex) then writeln('  (Offline)') else writeln;
        textcolor(7);
        if not(namelogged) then begin
                namelogged:=TRUE;
                logit(':','Scanning '+stripcolor(memuboard.name));
        end;
        if not(ex) then begin
                logit('!','  Added file: '+filename+' (offline)');
        end else begin
                logit('+','  Added file: '+filename);
        end;
        inc(pl);
        inc(logimport);
        end else inc(logleft);
        end else inc(logleft);
end;

procedure getcds;
var found,nofound:boolean;
    z,x,numfound:integer;
    w8:windowrec;
    cdfilesize:longint;
    cds:cdrec;
    cdi:cdidxrec;
    cdif:file of cdidxrec;
    cdf:file of cdrec;
    d:searchrec;
begin
  cursoron(FALSE);
  nofound:=TRUE;
  
  setwindow(w8,14,11,66,13,3,0,8,'CD-ROMs',TRUE);
  nofound:=true;
  gotoxy(2,1);
  textcolor(7);
  textbackground(0);
  write('Searching...');
  filemode:=66;
  INITCDROMS;
  assign(cdf,adrv(systat.gfilepath)+'CDS.DAT');
  {$I-} reset(cdf); {$I+}
  if ioresult<>0 then begin
        gotoxy(2,1);
        textcolor(15);
        textbackground(0);
        write('No CD-ROMs Available.');
        nofound:=FALSE;
  end;
  cdfilesize:=filesize(cdf)-1;
  seek(cdf,1);
  nofound:=TRUE;
  z:=1;
  numfound:=0;
  while (z<=cdfilesize) and not(eof(cdf)) do begin
        read(cdf,cds);
        for x:=1 to 26 do begin
              if (cdavail[x]=filepos(cdf)-1) then begin
                        inc(numfound);
                        gotoxy(2,1);
                        textcolor(7);
                        write('Found CD-ROM: ');
                        cwrite(mln(cds.name,34));
                        delay(750);
                        nofound:=FALSE;
              end;
        end;
        nofound:=TRUE;
        inc(z);
  end;
  if (numfound=0) then begin
                        gotoxy(2,1);
                        textcolor(15);
                        write('No CD-ROMs Available!');
  end;
  close(cdf);
  delay(1000);
  removewindow(w8);
end;

begin
getparams;
openmatrix;
processfile:=allcaps(processfile);
logbases:=0;
logfiles:=0;
logimport:=0;
logleft:=0;
if (allcaps(processfile)<>'FILES.BBS') then
logit('i','Processing      : '+processfile);
if (nocd) then
logit('i','CD-ROMs         : None')
else begin
if (usecd=0) then
logit('i','CD-ROM          : All')
else
logit('i','CD-ROM          : '+cstr(usecd));
end;
if (datesubtract<>0) then
logit('i','Forward # Days  : '+cstr(datesubtract));
cursoron(FALSE);
  oldx:=wherex;
  oldy:=wherey;
  savescreen(oldwind,1,1,80,25);
    textcolor(7);
    textbackground(0);
    clrscr;
    for x2:=1 to 24 do writeln('같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�');
  drawwindow2(1,1,78,4,1,3,0,11,'');
  gotoxy(3,2);
  textcolor(15);
  textbackground(3);
  write('nxFILES v',version2,' - FILES.BBS importer for Nexus Bulletin Board System');
  gotoxy(3,3);
  write('(c) Copyright 1996-2002 George A. Roberts IV. All rights reserved.');
if not(nocd) then getcds;
if not(presentyes) then begin
if not(pynqbox('Continue to import '+processfile+'? ')) then begin
        endprogram;
end;
end;
gotoxy(1,25);
textcolor(14);
textbackground(0);
write('Space or Esc');
textcolor(7);
write('=Abort Import');
current:=0;
assign(ulf,adrv(systat.gfilepath)+'FBASES.DAT');
filemode:=66;
{$I-} reset(ulf); {$I+}
if (ioresult<>0) then begin
        displaybox('Error opening '+adrv(systat.gfilepath)+'FBASES.DAT',3000);
        endprogram;
end;
setwindow(w,1,7,78,22,3,0,8,'Scanning File Bases',TRUE);
window(3,9,76,20);
done2:=FALSE;
while (current<=filesize(ulf)) and not(done2) do begin
if (loadfileboard(current)) then begin
inc(logbases);
textcolor(7);
textbackground(0);
writeln('Searching '+mln(stripcolor(memuboard.name)+'...',50));
if (exist(memuboard.dlpath+processfile)) then begin
assign(t,memuboard.dlpath+processfile);
{$I-} reset(t); {$I-}
if (ioresult=0) then begin
for x2:=1 to (startline-1) do begin
readln(t,s);
end;
if (fbdirdlpath in memuboard.fbstat) then
    NXF.Init(adrv(memuboard.dlpath)+memuboard.filename+'.NFD',syst.nkeywords,syst.ndesclines)
  else
    NXF.Init(adrv(systat.filepath)+memuboard.filename+'.NFD',syst.nkeywords,syst.ndesclines);
pl:=NXF.Numfiles;
readln(t,s);
while (not(eof(t)) or (onemore)) and not(done2) do begin
        getfile;
        while (keypressed) do begin
                c:=readkey;
                case upcase(c) of
                    ' ',#27:done2:=TRUE;
                end;
        end;
end;
close(t);
if (deleteafter) then begin
        logit('-','Erasing '+memuboard.dlpath+processfile);
        {$I-} erase(t); {$I+}
        if (ioresult<>0) then begin
                textcolor(12);
                writeln('Error deleting '+memuboard.dlpath+processfile);
                logit('!','Error deleting '+memuboard.dlpath+processfile);
                textcolor(7);
        end;
end;
        while (keypressed) do begin
                c:=readkey;
                case upcase(c) of
                    ' ',#27:done2:=TRUE;
                end;
        end;
NXF.Done;
end;
end;
end;
inc(current);
namelogged:=FALSE;
end;
close(ulf);
logit('i','Bases Processed : '+cstr(logbases));
logit('i','Files Processed : '+cstr(logfiles));
logit('i','Files Imported  : '+cstr(logimport));
logit('i','Files Ignored   : '+cstr(logleft));
logit(':','End; nxFILES v'+version2);
close(lf);
removewindow(w);
endprogram;
end.
