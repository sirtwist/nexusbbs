{$O+}
unit fbm4;

interface

uses dos,crt,myio,misc,fbcommon,cdrom3,mkmisc,mkstring,procs2,nxfs2,
     fbm1,fbm2,fbm3,sysop20;

const cbase:integer=-1;
      nosearchcdroms:boolean=FALSE;
      sortonly:boolean=FALSE;
      sorttype:string[2]='AN';
      aredeleted:boolean=FALSE;
      aretagged:boolean=FALSE;
      aremoved:boolean=FALSE;
      recordmoved:boolean=FALSE;

Type GlobalPass=array[1..9] of byte;

var curbase:integer;

const showfilename:boolean=FALSE;

var firstlp,lp,lp2:listptr;
    curf,movf:ulrec;
    curread,movread:integer;
    NXF,NXF2:nxFILEOBJ;

{$I BUILD3.INC}

procedure mainmenu;

implementation

procedure mainmenu;
var cur2,top2,cur,top:integer;
    found,nofound:boolean;
    z,x,numfound:integer;
    w8:windowrec;
    cdfilesize:longint;
    cds:cdrec;
    cdi:cdidxrec;
    cdif:file of cdidxrec;
    cdf:file of cdrec;

begin
if (sortonly) then begin
        sort(0,sorttype[2],true,not(nosearchcdroms),(sorttype[1]='A'),FALSE);
        exit;
end;
cursoron(FALSE);
if (cbase<>-1) then begin
        curbase:=cbase;
        loadfilebase(curbase,1);
        if (nosearchcdroms) and (curf.cdrom) then nosearchcdroms:=FALSE;
end;

  nofound:=TRUE;
  fillchar(cdavail,sizeof(cdavail),#0);
  if not(nosearchcdroms) then begin
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
                        nofound:=FALSE;
              end;
        end;
        nofound:=TRUE;
        inc(z);
  end;
  if (numfound=0) then begin
                        gotoxy(2,1);
                        textcolor(15);
                        write('No CD-ROMs available!');
  end;
  close(cdf);
  delay(2000);
  removewindow(w8);
  end;


cur:=1;
top:=1;
curread:=-1;
movread:=-1;
if (cbase=-1) then begin
repeat
curbase:=getfbase(cur,top,1,'');
if (curbase<>-1) then begin
        loadfilebase(curbase,1);
end;
cur2:=1;
top2:=1;
if (curbase<>-1) then begin
        fblistbox(w8,top2,cur2,1,6,78,23,3,0,8,'','File Base Manager',TRUE);
        removewindow(w8);
end;
until (curbase=-1);
end else begin
        cur2:=1;
        top2:=1;
        curbase:=cbase;
        loadfilebase(curbase,1);
        fblistbox(w8,top2,cur2,1,6,78,23,3,0,8,'','File Base Manager',TRUE);
        removewindow(w8);
end;
cursoron(TRUE);
cleanuptemp;
end;

end.
