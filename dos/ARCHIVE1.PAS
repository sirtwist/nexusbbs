{$A+,B+,D-,E+,F+,I+,L-,N-,O+,R-,S+,V-}
unit archive1;

interface

uses
  crt, dos,
  myio3,
  execbat,
  common;

procedure purgedir(s:astr);                {* erase all non-dir files in dir *}
function arcmci(src,fn,ifn:astr):astr;
procedure arcdecomp(var ok:boolean; atype:integer; fn,fspec:astr);
procedure arccomp(var ok:byte; atype:integer; fn,fspec:astr);
procedure arccomment(var ok:boolean; atype,cnum:integer; fn:astr);
procedure arcintegritytest(var ok:boolean; atype:integer; fn:astr);
procedure conva(var ok:integer; otype,ntype:integer; tdir,ofn,nfn:astr);
function getarcext(b:byte):string;
function afound(fn:astr):boolean;
procedure listarctypes;
procedure listarctypes2;
procedure invarc;

implementation

uses file0, file1, file2, file4, file7, file9, file11;

const
  maxdoschrline=127;

procedure purgedir(s:astr);                {* erase all non-dir files in dir *}
var odir,odir2:astr;
    dirinfo:searchrec;
    f:file;
    att:word;
begin
  s:=fexpand(s);
  while copy(s,length(s),1)='\' do s:=copy(s,1,length(s)-1);
  getdir(0,odir); getdir(exdrv(s),odir2);
  {$I-} chdir(s); {$I+}
  if (ioresult<>0) then exit;
  findfirst('*.*',AnyFile,dirinfo);
  while (doserror=0) do begin
    if not ((dirinfo.attr and VolumeID=VolumeID) or
    (dirinfo.attr and Directory=Directory)) then begin
    assign(f,fexpand(dirinfo.name));
    {$I-} setfattr(f,$00); {$I+}
    if (ioresult<>0) then begin end;    {* remove possible read-only, etc, attributes *}
    {$I-} erase(f); {$I+}      {* erase the $*@( file !!     *}
    if (ioresult<>0) then begin end;
    end;
    findnext(dirinfo);         {* move on to the next one... *}
  end;
  {$I-} chdir(odir2); {$I+}
  if (ioresult<>0) then begin end;
  {$I-} chdir(odir); {$I+}
  if (ioresult<>0) then begin end;
end;

function substone(src,old,new:string):string;
var p:integer;
begin
  p:=1;
  while p>0 do begin
    p:=pos(allcaps(old),allcaps(src));
    if (p>0) then begin
      insert(new,src,p+length(old));
      delete(src,p,length(old));
    end;
  end;
  substone:=src;
end;

function arcmci(src,fn,ifn:astr):astr;
begin
  src:=substone(src,'|ARCNAME|',fn);
  src:=substone(src,'|INFILE|',ifn);
  arcmci:=src;
end;

procedure arcbatch(var ok:integer;      { result                     }
                    bfn:astr;           { .BAT filename              }
                    dir:astr;           { directory takes place in   }
                    batline:astr);     { .BAT file line to execute  }
var bfp:text;
    odir,todev:astr;
    i,rcode:integer;
    si:boolean;
begin
  getdir(0,odir);
  dir:=fexpand(dir);
  bslash(FALSE,dir);
  {$I-} chdir(chr(exdrv(dir)+64)+':'); {$I+}
  if (ioresult<>0) then begin
        ok:=1;
        exit;
  end;
  {$I-} chdir(dir); {$I+}
  if (ioresult<>0) then begin
        ok:=1;
        exit;
  end;
  rcode:=0;
  shelldos(FALSE,batline,rcode);
  {$I-} chdir(chr(exdrv(odir)+64)+':'); {$I+}
  if (ioresult<>0) then ;
  {$I-} chdir(start_dir); {$I+}
  if (ioresult<>0) then ;
  ok:=rcode;
end;

function afound(fn:astr):boolean;
var retcode:integer;
    s:string;
begin
  currentswap:=modemr^.swaparchiver;
  retcode:=0;
  s:=adrv(systat^.utilpath)+'NXAPS.EXE 4 f '+fn;
  arcbatch(retcode,'~NXA'+cstrn(cnode)+'.BAT',newtemp,s);
  if (retcode=0) then afound:=TRUE else afound:=FALSE;
  currentswap:=0;
end;

procedure arcdecomp(var ok:boolean; atype:integer; fn,fspec:astr);
var s:string;
    retcode:integer;
begin
  purgedir(newtemp+'WORK');
  currentswap:=modemr^.swaparchiver;
  retcode:=0;
  shel('');
  s:=adrv(systat^.utilpath)+'NXAPS.EXE '+cstr(currentswap)+' e '+fn+' '+fspec;
  arcbatch(retcode,'~NXA'+cstrn(cnode)+'.BAT',newtemp+'WORK',s);
  shel2;
  ok:=(retcode=0);
  currentswap:=0;
end;

procedure arccomp(var ok:byte; atype:integer; fn,fspec:astr);
var s:string;
    retcode:integer;
begin
  currentswap:=modemr^.swaparchiver;
  retcode:=0;
  s:=adrv(systat^.utilpath)+'NXAPS.EXE '+cstr(modemr^.swaparchiver)+' a '+fn+' '+fspec;
  shel('');
  arcbatch(retcode,'~NXA'+cstrn(cnode)+'.BAT',newtemp,s);
  shel2;
  ok:=retcode;
  currentswap:=0;
  purgedir(newtemp+'WORK');
end;

procedure arccomment(var ok:boolean; atype,cnum:integer; fn:astr);
var s:string;
    retcode:integer;
begin
  if (cnum<>0) and (systat^.filearccomment[cnum]<>'') then begin
  currentswap:=modemr^.swaparchiver;
  retcode:=0;
  shel('');
  s:=adrv(systat^.utilpath)+'NXAPS.EXE '+cstr(modemr^.swaparchiver)+' c '+fn+' '+systat^.filearccomment[cnum];
  arcbatch(retcode,'~NXA'+cstrn(cnode)+'.BAT',newtemp,s);
  shel2;
  if (retcode=0) then ok:=TRUE else ok:=FALSE;
  currentswap:=0;
  end;
end;

procedure arcintegritytest(var ok:boolean; atype:integer; fn:astr);
var retcode:integer;
    s:string;
begin
  currentswap:=modemr^.swaparchiver;
  retcode:=0;
  s:=adrv(systat^.utilpath)+'NXAPS.EXE '+cstr(modemr^.swaparchiver)+' t '+fn;
  shel('');
  arcbatch(retcode,'~NXA'+cstrn(cnode)+'.BAT',newtemp,s);
  shel2;
  if (retcode=0) then ok:=TRUE else ok:=FALSE;
  currentswap:=0;
end;

procedure conva(var ok:integer; otype,ntype:integer; tdir,ofn,nfn:astr);
var retcode:integer;
    s:string;
begin
  purgedir(newtemp);
  currentswap:=modemr^.swaparchiver;
  retcode:=0;
  shel('');
  s:=adrv(systat^.utilpath)+'NXAPS.EXE '+cstr(modemr^.swaparchiver)+' x '+ofn+' '+cstr(ntype);
  arcbatch(retcode,'~NXA'+cstrn(cnode)+'.BAT',newtemp,s);
  shel2;
  ok:=retcode;
  currentswap:=0;
end;



procedure listarctypes2;
var i,j:integer;
    af:file of archiverrec;
    a:archiverrec;
begin
  i:=1; j:=0;
  assign(af,adrv(systat^.gfilepath)+'ARCHIVER.DAT');
  {$I-} reset(af); {$I+}
  if (ioresult<>0) then begin
  sprint('%120%No Archivers Defined!');
  exit;
  end;
  if (filesize(af)<2) then begin
        sprint('%120%No Archivers Defined!');
        close(af);
  exit;
  end;
  sprint('%030%Available Archive Formats: ');
  j:=1;
  seek(af,1);
  while not(eof(af)) do begin
    read(af,a);
    if (a.extension<>'') and (a.active) then begin
       sprint('%150%'+mln(cstr(j),3)+' %030%'+mln(a.extension,3)+' '+a.name);
       inc(j);
    end;
  end;
  close(af);
  nl;
end;

function getarcext(b:byte):string;
var af:file of archiverrec;
    a:archiverrec;
begin
  assign(af,adrv(systat^.gfilepath)+'ARCHIVER.DAT');
  {$I-} reset(af); {$I+}
  if (ioresult<>0) then begin
  getarcext:='';
  exit;
  end;
  if (b>filesize(af)) then begin
        getarcext:='';
        close(af);
  exit;
  end;
  seek(af,b);
  read(af,a);
  getarcext:=a.extension;
  close(af);
end;

procedure listarctypes;
begin
listarctypes2;
end;

procedure invarc;
begin
  print('Unsupported Archive Format.');
  nl;
  listarctypes;
  nl;
end;

end.
