{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R-,S+,V-}
unit file0;

interface

uses
  crt,dos,
  common,nxfilsys;

const
  ulffopen1:boolean=TRUE;   { whether ulff has been opened before }
  topp:integer=1;

var
  dirinfo:searchrec;
  found:boolean;
  lasttret:integer;
  NXF:nxFileOBJ;

function tcheck(s:real; i:integer):boolean;
procedure listbatchfiles;
function align(fn:string):string;
function baddlpath:boolean;
function bslash(b:boolean; s:astr):astr;
function existdir(s:astr):boolean;
procedure ffile(fn:astr);
function isflagged(s:string;fb:integer):boolean;
procedure fileinfo2(editing:boolean; var abort,next:boolean); 
procedure fiscan(var pl:integer);
function fit(f1,f2:astr):boolean;
procedure gfn(var fn:astr);
function isgifdesc(d:astr):boolean;
function isgifext(fn:astr):boolean;
function isul(s:astr):boolean;
function iswildcard(s:astr):boolean;
procedure nfile;
procedure precno(fn:astr; var pl,rn:integer);
procedure nrecno(fn:astr; var pl,rn:integer);
procedure recno(fn:astr; var pl,rn:integer);
function rte:real;
function stripname(i:astr):astr;
function tret(s:real):integer;
function tchk(s:real; i:real):boolean;

implementation

uses file25;

function isflagged(s:string;fb:integer):boolean;
        begin
        isflagged:=file25.isflagged(s,fb);
        end;

function ctim2(rl:real):string;
var h,m,s:string;
begin
  s:=common.tch(common.cstr(system.trunc(rl-system.int(rl/60.0)*60.0)));
  m:=common.tch(common.cstr(system.trunc(system.int(rl/60.0)-system.int(rl/3600.0)*60.0)));
  h:=common.cstr(system.trunc(system.int(rl/3600.0)));
  if (system.length(h)=1) then h:='0'+h;
  ctim2:=h+':'+m+':'+s;
end;

function longtim2(dt:datetimerec):string;
var s:string;
    d:integer;

  procedure ads(comma:boolean; i:integer; lab:string);
  begin
    if (i<>0) then begin
      s:=s+cstrl(i)+' '+lab;
      if (i<>1) then s:=s+'s';
      if (comma) then s:=s+', ';
    end;
  end;

begin
  s:='';
  with dt do begin
    d:=day;
    if (d>=7) then begin
      ads(TRUE,d div 7,'wk');
      d:=d mod 7;
    end;
    ads(TRUE,d,'day');
    ads(TRUE,hour,'hr');
    s:=s+cstrl(min)+' min, ';
    s:=s+cstrl(sec)+' sec';
  end;
  if (s='') then s:='0 sec';
  if (copy(s,length(s)-1,2)=', ') then s:=copy(s,1,length(s)-2);
  longtim2:=s;
end;


function rte2(i:longint):real;
begin
  rte2:=1400.0/i;
end;

function align(fn:string):string;
var f,e,t:astr; c,c1:integer;
begin
  c:=pos('.',fn);
  if (c=0) then begin
    f:=fn; e:='   ';
  end else begin
    f:=copy(fn,1,c-1); e:=copy(fn,c+1,3);
  end;
  f:=mln(f,8);
  e:=mln(e,3);
  c:=pos('*',f); if (c<>0) then for c1:=c to 8 do f[c1]:='?';
  c:=pos('*',e); if (c<>0) then for c1:=c to 3 do e[c1]:='?';
  c:=pos(' ',f); if (c<>0) then for c1:=c to 8 do f[c1]:=' ';
  c:=pos(' ',e); if (c<>0) then for c1:=c to 3 do e[c1]:=' ';
  align:=f+'.'+e;
end;

function baddlpath:boolean;
var s:string;
begin
  if (badfpath) then begin
    sl1('!','Invalid Path (Base #'+cstr(fileboard)+'): '+
             adrv(memuboard.dlpath));
  end;
  baddlpath:=badfpath;
end;

procedure listbatchfiles;
var tot:record
          pts:integer;
          blks:longint;
          tt:real;
        end;
    s,s2:astr;
    batchf:file of flaggedrec;
    batch:flaggedrec;
    i:integer;
    abort,next:boolean;

procedure pbn(var abort,next:boolean);
var 
x:integer;
s,s1:astr;
begin
loaduboard(fileboard);
if (systat^.fileptratio) then begin
        sprompt(gstring(488));
        sprompt(gstring(489));
        sprompt(gstring(490));
end else begin
        sprompt(gstring(485));
        sprompt(gstring(486));
        sprompt(gstring(487));
end;
end;



  function showblocks(l2:longint):STRING;
  var tstr,tstr2:string;
      ti:integer;
  begin
  {mrn(cstrl(li),6)}
  if (l2>1024) then begin
        tstr:=cstr(l2 div 1024);
        tstr2:=cstr(trunc(((l2 mod 1024)/1024)*100));
        while (length(tstr2)<2) do tstr2:='0'+tstr2;
        ti:=value(copy(tstr2,1,1));
        if (value(copy(tstr2,2,1))>4) then inc(ti);
        showblocks:=tstr+'.'+cstr(ti)+'M';
  end else begin
        showblocks:=cstrl(l2)+'k';
  end;
  end;

  procedure ptsf;
  var s:string;
      xit:integer;
      avail:boolean;
      li:longint;
  begin
        if (batch.filebase<>-1) then begin
                loaduboard(batch.filebase);
          li:=batch.blocks;
          sprompt('%090%');
          sprompt(mrn(showblocks(li),6));
          if (systat^.fileptratio) then begin
                if (fbnoratio in memuboard.fbstat) or (batch.isfree) then
                s:=' Free ' else s:=' '+mrn(cstr(batch.filepoints),4)+' ';
                sprompt(s);
          end else begin
                if (fbnoratio in memuboard.fbstat) or (batch.isfree) then
                s:=' Free ' else s:='      ';
                sprompt(s);
          end;
          end else begin
          li:=batch.blocks;
          sprompt(mrn(showblocks(li),6));
          if (systat^.fileptratio) then begin
                if (batch.isfree) then
                s:='Free  ' else
                s:=' '+mrn(cstr(batch.filepoints),4)+' ';
                sprompt(s);
          end else begin
                if (batch.isfree) then
                s:='Free  ' else
                s:='      ';
                sprompt(s);
          end;
          end;
  end;


begin
  cls;
  pbn(abort,next);
  if (numbatchfiles=0) then begin
    nl; sprint('%150%No files currently flagged for download.');
  end else begin
    abort:=FALSE; next:=FALSE;
    with tot do begin
      pts:=0; blks:=0; tt:=0.0;
    end;
    assign(batchf,adrv(systat^.temppath)+'FLAG'+cstrn(cnode)+'.DAT');
    {$I-} reset(batchf); {$I+}
    if (ioresult<>0) then begin
        nl; sprint('%150%No files currently flagged for download.');
        numbatchfiles:=0;
        exit;
    end;
    s:='';
    s2:='';
    i:=1;         
    while (not abort) and (not hangup) and (i<=numbatchfiles) and
        not(eof(batchf)) do begin
        read(batchf,batch);
      with batch do begin
        sprompt('%030%');
        sprompt(' '+mrn(cstrl(i),4)+' ');
        sprompt('%150%');
        sprompt(' '+mln(stripname(filename),12)+' ');
        ptsf;
        sprompt(' %120%'+ctim2(ttime)+' ');
        sprompt('%030%');
        sprint(' '+copy(descript[1],1,35));
        tot.pts:=tot.pts+filepoints;
        tot.blks:=tot.blks+blocks;
        tot.tt:=tot.tt+ttime;
      end;
      inc(i);
    end;
    with tot do begin
      if (systat^.fileptratio) then begin
           sprint('%090%       컴컴컴컴컴컴  컴컴�  컴컴 컴컴컴컴');
      end else begin
           sprint('%090%       컴컴컴컴컴컴  컴컴�       컴컴컴컴');
      end;
      sprompt('%030%Totals:');
      s:='%150%'+cstr(numbatchfiles)+' %030%file';
      if (numbatchfiles>1) then s:=s+'s';
      sprompt(mrn(s,12));
      sprompt('%150% '+mrn(showblocks(blks),6));
      if (systat^.fileptratio) then begin
        sprompt(' '+mrn(cstr(pts),4)+'  ');
      end else begin
        sprompt('       ');
      end;
      sprint(ctim2(tt));
      end;
    close(batchf);
  end;
end;

function bslash(b:boolean; s:astr):astr;
begin
  if (b) then begin
    while (copy(s,length(s)-1,2)='\\') do s:=copy(s,1,length(s)-2);
    if (copy(s,length(s),1)<>'\') then s:=s+'\';
  end else
    while (copy(s,length(s),1)='\') do s:=copy(s,1,length(s)-1);
  bslash:=s;
end;

function existdir(s:astr):boolean;
var savedir:astr;
    okd:boolean;
begin
  okd:=TRUE;
  s:=bslash(FALSE,fexpand(s));

  if ((length(s)=2) and (copy(s,2,1)=':')) then begin
    getdir(0,savedir);
    {$I-} chdir(s); {$I+}
    if (ioresult<>0) then okd:=FALSE;
    chdir(savedir);
    exit;
  end;

  okd:=(exist(s));

  if (okd) then begin
    findfirst(s,anyfile,dirinfo);
    if (dirinfo.attr and directory<>directory) or
       (doserror<>0) then okd:=FALSE;
  end;

  existdir:=okd;
end;

procedure fiscan(var pl:integer); { loads in memuboard ... }
var dirinfo:searchrec;
    s:astr;
    rt:real;
begin
  loaduboard(fileboard);
  s:=adrv(memuboard.dlpath); s:=copy(s,1,length(s)-1);
  if ((length(s)=2) and (s[2]=':')) then badfpath:=FALSE
  else begin
    rt:=timer;
    while (tcheck(rt,2)) and (doserror<>0) do begin
    findfirst(s,dos.directory,dirinfo);
    end;
    badfpath:=(doserror<>0);
  end;
  
  if (fbdirdlpath in memuboard.fbstat) then
  NXF.Init(adrv(memuboard.dlpath)+memuboard.filename+'.NFD',syst.nkeywords,syst.ndesclines)
  else
  NXF.Init(adrv(systat^.filepath)+memuboard.filename+'.NFD',syst.nkeywords,syst.ndesclines);
  pl:=NXF.NumFiles; 

  bnp:=FALSE;
end;

procedure ffile(fn:astr);
begin
  findfirst(fn,anyfile,dirinfo);
  found:=(doserror=0);
end;

procedure verbfileinfo2(editing,abort,next:boolean);
var i2:integer;
    s:string[45];
begin
    i2:=2;
    s:='';
    while (i2<=syst.ndesclines) and (s<>#1+'EOF'+#1) do begin
              s:=NXF.GetDescLine;
              if (s<>#1+'EOF'+#1) then
              sprint('%030%                : %140%'+s);
              wkey(abort,next);
              inc(i2);
        end;
end;


procedure fileinfo2(editing:boolean; var abort,next:boolean);
var dt:datetimerec;
    s:astr;
    r:real;
    x:longint;
    i,i2:integer;
begin
  sprompt('%090%컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[%150%File Information%090%]컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴|LF|');
  with NXF.Fheader do
    for i:=1 to 5 do begin
      case i of
        1:begin
            s:='%030%Filename        : %150%'+filename;
            sprint(s);
            s:='%030%File size';
            if (systat^.fileptratio) then begin
                s:=s+'/points:'; 
                end else
                s:=s+'       :';
            s:=s+' %150%'+cstrl(filesize)+' bytes';
            if (systat^.fileptratio) then begin
                s:=s+', '+cstr(filepoints)+' point';
                if filepoints>1 then s:=s+'s';
            end;
          end;
        2:begin
            s:='%030%Approx. DL time : %150%';
            if (spd<>'KB') and (answerbaud<>0) then begin
            r:=rte2(answerbaud div 10)*(filesize div 1024); r2dt(r,dt);
            end else begin
            r:=rte2(2880)*(filesize div 1024); r2dt(r,dt);
            end;
            s:=s+longtim(dt);
          end;
        3:begin
            sprompt('%030%Uploaded by     : ');
            sprint('%150%'+caps(uploadedby)+'%030% on %150%'+showdatestr(uploadeddate));
            sprompt('%030%Last downloaded : %150%'+showdatestr(lastDLdate)+'%030% (%150%'+
                cstr(numdownloads)+'%030% time');
            if (numdownloads<>1) then sprompt('%030%s');
            sprint(' total)');
          end;
        4:begin
            i2:=0;
            if (ffnotval in fileflags) then begin
                sprompt('%030%Special info    : ');
                sprompt('%120%This file is not validated.|LF|');
                i2:=1;
            end;
            if (ffisrequest in fileflags) then begin
                if (i2=0) then begin
                sprompt('%030%Special info    : ');
                i2:=1;
                end else sprompt('%030%                : ');
                sprompt('%120%This file is offline.|LF|');
            end;
            if (ffresumelater in fileflags) then begin
                if (i2=0) then begin
                sprompt('%030%Special info    : ');
                i2:=1;
                end else sprompt('%030%                : ');
                sprompt('%120%This file upload needs to be resumed.|LF|');
            end;
            s:='';
          end;
        5:begin 
sprompt('%090%컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴|LF|');
                sprompt('%030%Description     : ');
                NXF.DescStartup;
                s:=NXF.GetDescLine;
                if (s<>#1+'EOF'+#1) then begin
                        sprint('%140%'+s);
                        verbfileinfo2(editing,abort,next);
                end;
                s:='';
          end;
      end;
      if (s<>'') then begin
        sprint(s);
        wkey(abort,next);
      end;
      s:='';
    end;
  nl;
end;


function fit(f1,f2:astr):boolean;
var tf:boolean; c:integer;
begin
  tf:=TRUE;
  for c:=1 to 12 do
    if (f1[c]<>f2[c]) and (f1[c]<>'?') then tf:=FALSE;
  fit:=tf;
end;


procedure gfn(var fn:astr);
var i:integer;
    fn2,fn3:string;
begin
  sprompt(gstring(64));
  sprompt(gstring(65)); 
  if (fn='') then defaultst:='*.*'
  else defaultst:=fn;
  inputd(fn,12);
  if (pos('.',fn)=0) then fn:=fn+'.';
  if (pos('*',fn)<>0) then begin
      fn2:=align(fn);
      fn3:=copy(fn2,10,3);
      fn2:=copy(fn2,1,8);
      if (pos('*',fn2)<>0) then begin
          while (pos(' ',fn2)<>0) do begin
                fn2[pos(' ',fn2)]:='?';
          end;
          fn2[pos('*',fn2)]:='?';
      end;
      if (pos('*',fn3)<>0) then begin
          while (pos(' ',fn3)<>0) do begin
                fn3[pos(' ',fn3)]:='?';
          end;
          fn3[pos('*',fn3)]:='?';
      end;
      fn2:=sqoutsp(fn2);
      fn3:=sqoutsp(fn3);
      fn:=fn2+'.'+fn3;
  end;
end;

function isgifdesc(d:astr):boolean;
begin
  isgifdesc:=((copy(d,1,1)='(') and (pos('x',d) in [1..7]) and
              (pos('c)',d)<>0));
end;

function isgifext(fn:astr):boolean;
begin
  fn:=allcaps(copy(fn,pos('.',fn)+1,3));
  isgifext:=((fn='GIF') or (fn='GYF'));
end;

function isul(s:astr):boolean;
begin
  isul:=((pos('\',s)<>0) or (pos(':',s)<>0) or (pos('|',s)<>0));
end;

function iswildcard(s:astr):boolean;
begin
  iswildcard:=((pos('*',s)<>0) or (pos('?',s)<>0));
end;

procedure nfile;
begin
  findnext(dirinfo);
  found:=(doserror=0);
end;

procedure nrecno(fn:astr; var pl,rn:integer);
var c:integer;
begin
  rn:=0;
  fiscan(pl);
  if (lrn<pl) and (lrn>=0) then begin
    c:=lrn+1;
    while (c<=pl) and (rn=0) do begin
      NXF.seekfile(c);
      NXF.ReadHeader;
      if fit(align(fn),align(NXF.Fheader.filename)) then rn:=c;
      inc(c);
    end;
    lrn:=rn;
  end;
end;

procedure precno(fn:astr; var pl,rn:integer);
var c:integer;
begin
  rn:=0;
  fiscan(pl);
  if (lrn<pl) and (lrn>=0) then begin
    c:=lrn-1;
    while (c<=pl) and (c>-1) and (rn=0) do begin
      NXF.seekfile(c);
      NXF.ReadHeader;
      if fit(align(fn),align(NXF.Fheader.filename)) then rn:=c;
      dec(c);
    end;
    lrn:=rn;
  end;
end;

procedure recno(fn:astr; var pl,rn:integer);
var c:integer;
begin
  fiscan(pl);
  rn:=0; c:=1;
  while (c<=pl) and (rn=0) do begin
    NXF.seekfile(c);
    NXF.ReadHeader;
    if fit(align(fn),align(NXF.Fheader.filename)) then rn:=c;
    inc(c);
  end;
  lrn:=rn;
  lfn:=fn;
end;

function rte:real;
var i:longint;
begin
  i:=(answerbaud div 10); if (i=0) then i:=240;
  rte:=1400.0/i;
end;


function stripname(i:astr):astr;
var i1:astr;
    n:integer;

  function nextn:integer;
  var n:integer;
  begin
    n:=pos(':',i1);
    if (n=0) then n:=pos('\',i1);
    if (n=0) then n:=pos('/',i1);
    nextn:=n;
  end;

begin
  i1:=i;
  while (nextn<>0) do i1:=copy(i1,nextn+1,80);
  stripname:=i1;
end;

function tret(s:real):integer;
var r:real;
begin
  r:=timer-s;
  if r<0.0 then r:=r+86400.0;
  if (r<0.0) or (r>32760.0) then r:=32766.0;
  if (trunc(r)<>lasttret) then tret:=trunc(r) else tret:=-1;
  lasttret:=trunc(r);
end;


function tchk(s:real; i:real):boolean;
var r:real;
begin
  r:=timer;
  if r<s then r:=r+86400.0;
  if (r-s)>i then tchk:=FALSE else tchk:=TRUE;
end;

function tcheck(s:real; i:integer):boolean;
var r:real;
begin
  r:=timer-s;
  if r<0.0 then r:=r+86400.0;
  if (r<0.0) or (r>32760.0) then r:=32766.0;
  if trunc(r)>i then tcheck:=FALSE else tcheck:=TRUE;
end;

end.
