{$O+}
unit misc;

interface

uses dos,crt,mkmisc,mkstring,multi;

const nxe:boolean=FALSE;

{$I NEXUS.INC}

var ver:string;
    nexusdir:string;
    stridx:stringidx;
    ueopt1,ueopt2,ueopt3,uephone1,uephone2:string;
    start_dir:string;
    systat:MatrixREC;
    nxsetf:file of nxsetuprec;
    systemf:file of systemrec;
    syst:systemrec;
    permf:file of PermIDREC;
    perm:permIDREC;
    nxset:nxsetuprec;
    thisuser:userrec;
    uf:file of userrec;
    sf:file of smalrec;
    sr:smalrec;
    bf:file of boardrec;
    memboard:boardrec;
    numboards:integer;
    maxulb:integer;
    ulf:file of ulrec;
    memuboard:ulrec;
    newtemp:string;

procedure timeslice;
function exdrv(s:string):byte;
function getlanguage:byte;
function onoff(b:boolean):string;
function cstr(i:longint):string;
function lenn(s:string):integer;
function mln(s:string; l:integer):string;
function mn(i,l:longint):string;
function mrn(s:string; l:integer):string;
function cstrn(i:longint):string;
function allcaps(s:string):string;
function caps(s:string):string;
function bslash(b:boolean; s:string):string;
procedure purgedir(s:string);
function datelong:string;
function substone(src,old,newstr:string):string;
function arcmci(src,fn,ifn:string):string;
function adrv(s:string):string;
function value(s:string):longint;
function valuereal(s:string):real;
function cstrnfile(i:longint):string;
function stripcolor(o:string):string;
function sqoutsp(s:string):string;
function leapyear(yr:integer):boolean;
function days(mo,yr:integer):integer;
function daycount(mo,yr:integer):integer;
function daynum(dt:string):integer;
function u_daynum(dt:string):longint;
function u_daynumstring(l:longint):string;
function tch(s:string):string;
function time:string;
function date:string;
function aonoff(b:boolean; s1,s2:string):string;
function exist(fn:string):boolean;
function existdir(s:string):boolean;
function syn(b:boolean):string;
function recreatelanguage:boolean;
function tacch(c:char):uflags;
function showdatestr(unix:longint):string;
procedure showhelp(helpname:string; topic:integer);
procedure getdatetime(var dt:datetimerec);
procedure timediff(var dt:datetimerec; dt1,dt2:datetimerec);
function longtim(dt:datetimerec):string;
function freek(d:integer):longint;
function pathonly(s:string):string;
function fileonly(s:string):string;
function extonly(s:string):string;
function cstrf2(i:longint;ivryear:integer):string;
function timer:real;
procedure updatesystem;
procedure readpermid;
procedure updatepermid;
function cstrl(li:longint):string;
function readsystemdat:boolean;
function fit(f1,f2:astr):boolean;
function centered(s:string;x:integer):string;
function tchnode(s:string):string;
FUNCTION Dosmem : LONGINT;
function ctim(rl:real):string;
function dt2r(dt:datetimerec):real;
function tch2(s:string):string;
function cstrreal(rl:real):string;
function longtim2(dt:datetimerec):string;
function longtim3(dt:datetimerec):string;
procedure r2dt(r:real; var dt:datetimerec);

implementation

uses myio,ivhelp1,procspec;

var dirinfo:searchrec;

procedure timeslice; begin multi.doslice; end;

procedure r2dt(r:real; var dt:datetimerec);
begin
  with dt do begin
    day:=trunc(r/86400.0); r:=r-(day*86400.0);
    hour:=trunc(r/3600.0); r:=r-(hour*3600.0);
    min:=trunc(r/60.0); r:=r-(min*60.0);
    sec:=trunc(r);
  end;
end;

function tch2(s:string):string;
begin
  if (length(s)>2) then s:=copy(s,length(s)-1,2) else
    if (length(s)=1) then s:=s+'0';
  tch2:=s;
end;

function tchnode(s:string):string;
begin
  if (length(s)>3) then s:=copy(s,length(s)-1,3) else
    if (length(s)=1) then s:='00'+s else
    if (length(s)=2) then s:='0'+s;
  tchnode:=s;
end;

function tch3(s:string):string;
begin
  if (length(s)>2) then s:=copy(s,length(s)-1,2) else
    if (length(s)=1) then s:='0'+s;
  tch3:=s;
end;

function cstrreal(rl:real):string;
var i,i2:integer;
    s:string;
    r1,r2:real;
begin
  if (rl<=0.0) then cstrreal:='0.00'
  else begin
    r1:=frac(rl);
    r1:=r1 * 100.0;
    i:=round(r1);
    i2:=trunc(rl);
    s:=cstr(i2)+'.'+tch3(cstr(i));
    cstrreal:=s;
  end;
end;

function ctim(rl:real):string;
var d,h,m,s:string;
begin
  rl:=rl-(86400.0 * trunc((rl/86400)));
  s:=tch(cstr(trunc(rl-int(rl/60.0)*60.0)));
  rl:=rl-trunc(rl-int(rl/60.0)*60.0);
  m:=tch(cstr(trunc(int(rl/60.0)-int(rl/3600.0)*60.0)));
  rl:=rl-trunc(int(rl/60.0)-int(rl/3600.0)*60.0);
  h:=cstr(trunc(rl/3600.0));
  if (length(h)=1) then h:='0'+h;
  ctim:=h+':'+m+':'+s;
end;

function readsystemdat:boolean;
begin
  assign(systemf,adrv(systat.gfilepath)+'SYSTEM.DAT');
  filemode:=66;
  {$I-} reset(systemf); {$I+}
  if (ioresult<>0) then begin
        readsystemdat:=FALSE;
        exit;
  end;
  read(systemf,syst);
  close(systemf);
  readsystemdat:=TRUE;
end;

procedure writesystemsema;
var sr:searchrec;
    x:integer;
    f:file;
    t:text;
begin
  findfirst(adrv(systat.semaphorepath)+'INUSE.*',anyfile,sr);
  while (doserror=0) do begin
        x:=value(copy(sr.name,pos('.',sr.name)+1,length(sr.name)-pos('.',sr.name)));
        if (x=0) then x:=1000;
                filemode:=66;
                assign(f,adrv(systat.semaphorepath)+'INUSE.'+cstrnfile(x));
                {$I-} reset(f); {$I+}
                if (ioresult=0) then begin
                        close(f);
                        assign(t,adrv(systat.semaphorepath)+'READSYS.'+cstrnfile(x));
			rewrite(t);
			close(t);
		end;
   findnext(sr);
   end;
end;

procedure updatesystem;
var sy2:systemrec;
begin
  {$I-} reset(systemf); {$I+}
  if (ioresult<>0) then begin
        displaybox('Error Updating SYSTEM.DAT',3000);
  end else begin
        read(systemf,sy2);
        sy2.callernum:=syst.callernum;
        if (syst.numusers<>sy2.numusers) then sy2.numusers:=syst.numusers;
        seek(systemf,0);
        write(systemf,sy2);
        close(systemf);
        writesystemsema;
  end;
end;

procedure updatepermid;
var sy2:systemrec;
begin
  assign(permf,adrv(systat.gfilepath)+'PERMID.DAT');
  {$I-} reset(permf); {$I+}
  if (ioresult<>0) then begin
        displaybox('Error Updating PERMID.DAT',3000);
  end else begin
        seek(permf,0);
        write(permf,perm);
        close(permf);
  end;
end;

procedure readpermid;
var sy2:systemrec;
begin
  assign(permf,adrv(systat.gfilepath)+'PERMID.DAT');
  {$I-} reset(permf); {$I+}
  if (ioresult<>0) then begin
        displaybox('Error reading PERMID.DAT',3000);
        halt;
  end else begin
        seek(permf,0);
        read(permf,perm);
        close(permf);
  end;
end;

function tch(s:string):string;
begin
  if (length(s)>2) then s:=copy(s,length(s)-1,2) else
    if (length(s)=1) then s:='0'+s;
  tch:=s;
end;


function cstrf2(i:longint;ivryear:integer):string;

var
x:integer;
c:string[16];
begin
  str(i,c);
  for x:=1 to (7-length(c)) do
	c:='0'+c;
  c:=tch(cstr(ivryear))+c;
  c:=copy(c,1,2)+'-'+copy(c,3,3)+'-'+copy(c,6,4);
  cstrf2:=c;
end;

function pathonly(s:string):string;
var
 x : integer;
 done : boolean;
begin
 x := length(s);
 done:=FALSE;
 while (x > 1) and not (done) do begin
       if s[x] = '\' then begin
          done := true;
       end else begin
          s := copy(s,1,length(s)-1);
       end;
       dec(x);
 end;
 if not(done) then s:='';
 pathonly := s;
end;

function fileonly(s:string):string;
var
 x : integer;
 done : boolean;
begin
 x := length(s);
 done:=FALSE;
 while (x > 1) and not (done) do begin
       if s[x] = '\' then begin
          done := true;
       end;
       dec(x);
 end;
 if not(done) then s:='' else
 s := copy(s,x+2,length(s));
 fileonly := s;
end;

function extonly(s:string):string;
var
 x : integer;
 done : boolean;
begin
 x := length(s);
 done:=FALSE;
 while (x > 1) and not (done) do begin
       if s[x] = '.' then begin
          done := true;
       end;
       dec(x);
 end;
 if not(done) then s:='' else
 s := copy(s,x+2,length(s));
 extonly := s;
end;

Function DriveSize(d:byte):Longint; { -1 not found, 1=>1 Giga }
Var
  R : Registers;
Begin
  With R Do
  Begin
    ah:=$36; dl:=d; Intr($21,R);
    If AX=$FFFF Then DriveSize:=-1 { Drive not found }
    Else If (DX=$FFFF) or (Longint(ax)*cx*dx=1073725440) Then DriveSize:=1
    Else DriveSize:=Longint(ax)*cx*dx;
  End;
End;

Function DriveFree(d:byte):Longint; { -1 not found, 1=>1 Giga }
Var
  R : Registers;
Begin
  With R Do
  Begin
    ah:=$36; dl:=d; Intr($21,R);
    If AX=$FFFF Then DriveFree:=-1 { Drive not found }
    Else If (BX=$FFFF) or (Longint(ax)*bx*cx=1073725440) Then DriveFree:=1
    Else DriveFree:=Longint(ax)*bx*cx;
  End;
End;

function freek(d:integer):longint;
var lng:longint;
begin
  lng:=drivefree(d);
  if (lng=1) then freek:=1048576 else
  freek:=lng div 1024;
end;

procedure showhelp(helpname:string; topic:integer);
        begin ivhelp1.showhelp(nexusdir,helpname,topic);
        end;

function showdatestr(unix:longint):string;
var d:datetime;
begin
UnixToDT(unix,d);
showdatestr:=FormattedDate(d,'MM/DD/YYYY HH:II:SS');
end;

function tacch(c:char):uflags;
begin
  case c of
    'A':tacch:=rlogon;
    'B':tacch:=rchat;
    'C':tacch:=rvalidate;
    'D':tacch:=rbackspace;
    'E':tacch:=rpost;
    'F':tacch:=remail;
    'G':tacch:=rmsg;
    'H':tacch:=fnodlratio;
    'I':tacch:=fnopostratio;
    'J':tacch:=fnofilepts;
    'K':tacch:=fnodeletion;
  end;
end;

function recreatelanguage:boolean;
var langf:file of languagerec;
    langr:languagerec;
    x:integer;
begin
assign(langf,adrv(systat.gfilepath)+'LANGUAGE.DAT');
{$I-} rewrite(langf); {$I+}
if (ioresult<>0) then begin
        displaybox('Error Creating LANGUAGE.DAT',4000);
        recreatelanguage:=FALSE;
        end;
langr.name:='English';
langr.filename:='ENGLISH';
langr.menuname:='ENGLISH';
langr.access:='';
langr.displaypath:='';
langr.checkdefpath:=FALSE;
langr.startmenu:=6;
for x:=1 to sizeof(langr.reserved1) do langr.reserved1[x]:=0;
write(langf,langr);
write(langf,langr);
close(langf);
end;

function syn(b:boolean):string;
begin
  if (b) then syn:='Yes' else syn:='No ';
end;

function exist(fn:string):boolean;
var srec:searchrec;
begin
  findfirst(sqoutsp(fn),anyfile,srec);
  exist:=(doserror=0);
end;


function time:string;
var h,m,s:string[3];
    hh,mm,ss,ss100:word;
begin
  gettime(hh,mm,ss,ss100);
  str(hh,h); str(mm,m); str(ss,s);
  time:=tch(h)+':'+tch(m)+':'+tch(s);
end;

function date:string;
var r:registers;
    y,m,d:string[3];
    yy,mm,dd,dow:word;
begin
  getdate(yy,mm,dd,dow);
  y:=copy(cstr(yy),3,2);
  str(mm,m); str(dd,d);
  date:=tch(m)+'/'+tch(d)+'/'+tch(y);
end;

function datelong:string;
var r:registers;
    y,m,d:string[4];
    yy,mm,dd,dow:word;
begin
  getdate(yy,mm,dd,dow);
  str(yy,y); str(mm,m); str(dd,d);
  datelong:=tch(m)+'/'+tch(d)+'/'+y;
end;

function leapyear(yr:integer):boolean;
begin
  leapyear:=(yr mod 4=0) and ((yr mod 100<>0) or (yr mod 400=0));
end;

function days(mo,yr:integer):integer;
var d:integer;
begin
  d:=value(copy('312831303130313130313031',1+(mo-1)*2,2));
  if ((mo=2) and (leapyear(yr))) then inc(d);
  days:=d;
end;

function daycount(mo,yr:integer):integer;
var m,t:integer;
begin
  t:=0;
  for m:=1 to (mo-1) do t:=t+days(m,yr);
  daycount:=t;
end;

function daynum(dt:string):integer;
var d,m,y,t,c:integer;
begin
  t:=0;
  m:=value(copy(dt,1,2));
  d:=value(copy(dt,4,2));
  y:=value(copy(dt,7,4));
  for c:=1970 to y-1 do
    if (leapyear(c)) then inc(t,366) else inc(t,365);
  t:=t+daycount(m,y)+(d-1);
  daynum:=t;
  if y<1970 then daynum:=0;
end;

function u_daynum(dt:string):longint;
var d,m,y,c,h,min,s,count:integer;
    t:longint;
begin
  t:=0;
  m:=value(copy(dt,1,2));
  d:=value(copy(dt,4,2));
  y:=value(copy(dt,7,4));
  h:=0;
  min:=0;
  s:=0;
  count:=1;                           
  if (pos(':',dt)<>0) and (pos(':',dt)>11) then begin
        h:=value(copy(dt,pos(':',dt)-2,2));
        min:=value(copy(dt,pos(':',dt)+1,2));
        dt[pos(':',dt)]:='-';
        if (pos(':',dt)<>0) then
         s:=value(copy(dt,pos(':',dt)+1,2));
  end;
  for c:=1970 to y-1 do
    if (leapyear(c)) then t:=t+(366*86400) else t:=t+(365*86400);
  t:=t+((daycount(m,y)+(d-1))*86400);
  u_daynum:=t+(h*3600)+(min*60)+s;
  if y<1970 then u_daynum:=0;
end;

function u_daynumstring(l:longint):string;
var d,m,y,c:integer;
    t:longint;

        function moreyears:boolean;
        begin
        if (leapyear(c+1)) then begin
            moreyears:=((l - (366*86400))>0);
        end else begin
            moreyears:=((l - (365*86400))>0);
        end;
        end;
begin
  t:=0;
  y:=1970;
  while (moreyears) do begin
  end;
  for c:=1970 to y-1 do
    if (leapyear(c)) then t:=t+(366*86400) else t:=t+(365*86400);
  t:=t+((daycount(m,y)+(d-1))*86400);
  u_daynumstring:=''; {t+(trunc(timer));}
  if y<1970 then u_daynumstring:='';
end;

function timer:real;
var r:registers;
    h,m,s,t:real;
begin
  r.ax:=44*256;
  msdos(dos.registers(r));
  h:=(r.cx div 256); m:=(r.cx mod 256); s:=(r.dx div 256); t:=(r.dx mod 256);
  timer:=h*3600+m*60+s+t/100;
end;

function sqoutsp(s:string):string;
begin
  while (pos(' ',s)>0) do delete(s,pos(' ',s),1);
  sqoutsp:=s;
end;

function stripcolor(o:string):string;
var s,s2:string;
    count,i:integer;
    lc:boolean;
begin
  s2:=o;
  s:='';
  count:=0;
  i:=1;
  while (i<=length(o)-4) do begin
       if (o[i]='%') and (o[i+4]='%') and (o[i+1] in ['0'..'9']) and
                (o[i+2] in ['0'..'9']) and (o[i+3] in ['0'..'9']) then inc(i,4) else
			s:=s+o[i];
       inc(i);
  end;
  if (length(o)>4) {and (i<length(o))} then begin
    if not((o[length(o)-4]='%') and (o[length(o)]='%') and (o[length(o)-3] in ['0'..'9'])
        and (o[length(o)-2] in ['0'..'9']) and (o[length(o)-1] in ['0'..'9'])) then begin
        for count:=i to (length(o)) do begin
                s:=s+(o[count]);
        end;
    end;
  end else begin
  s:=s2;
  end;
  stripcolor:=s;
end;

function cstrnfile(i:longint):string;
var 
x:integer;
c:string[16];
begin
  if (i=1000) then c:='000' else begin
  str(i,c);
  for x:=1 to (3-length(c)) do
	c:='0'+c;
  end;
  cstrnfile:=c;
end;

function onoff(b:boolean):string;
begin
  if (b) then onoff:='On ' else onoff:='Off';
end;

function value(s:string):longint;
var i:longint;
    j:integer;
begin
  val(s,i,j);
  if (j<>0) then begin
    s:=copy(s,1,j-1);
    val(s,i,j)
  end;
  value:=i;
  if (s='') then value:=0;
end;

function valuereal(s:string):real;
var i,i2:longint;
    j:real;
begin
  if (pos('.',s)<>0) then begin
        i:=value(copy(s,1,pos('.',s)-1));
        i2:=value(copy(s,pos('.',s)+1,length(s)));
        if (length(copy(s,pos('.',s)+1,length(s)))=1) then i2:=i2 * 10;
        j:=i+(i2/100);
  end else begin
        i:=value(s);
        j:=i;
  end;
  if (s='') then valuereal:=0;
  valuereal:=j;
end;

function adrv(s:string):string;
var s2:string;
begin
s2:=s;
if (s2<>'') then begin
if (s2[2]<>':') then
                if (s2[1]<>'\') then s2:=start_dir+'\'+s2
                else s2:=copy(start_dir,1,2)+s2;
end else begin
                s2:=start_dir+'\';
end;
adrv:=s2;
end;

function exdrv(s:string):byte;
begin
  s:=fexpand(s);
  exdrv:=ord(s[1])-64;
end;

function bslash(b:boolean; s:string):string;
begin
  if (b) then begin
    while (copy(s,length(s)-1,2)='\\') do s:=copy(s,1,length(s)-2);
    if (copy(s,length(s),1)<>'\') then s:=s+'\';
  end else
    while (copy(s,length(s),1)='\') do s:=copy(s,1,length(s)-1);
  bslash:=s;
end;

function existdir(s:string):boolean;
var savedir:string;
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

function substone(src,old,newstr:string):string;
var p:integer;
begin
  p:=1;
  while p>0 do begin
    p:=pos(allcaps(old),allcaps(src));
    if (p>0) then begin
      insert(newstr,src,p+length(old));
      delete(src,p,length(old));
    end;
  end;
  substone:=src;
end;

function arcmci(src,fn,ifn:string):string;
begin
  src:=substone(src,'|ARCNAME|',fn);
  src:=substone(src,'|INFILE|',ifn);
  arcmci:=src;
end;

function cstr(i:longint):string;
var c:string[16];
begin
  str(i,c);
  cstr:=c;
end;

procedure purgedir(s:string);                {* erase all non-dir files in dir *}
var odir,odir2:string;
    dirinfo:searchrec;
    f:file;
    att:word;
    x:integer;
    curname:string;
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
    x:=0;
    curname:=dirinfo.name;
   { while (x<260) and (dirinfo.name[x]<>#0) do begin
           curname:=curname+dirinfo.name[x];
           inc(x);
    end; }
    assign(f,fexpand(curname));
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

function lenn(s:string):integer;
var i,len:integer;
begin
  len:=length(s); i:=1;
  while (i<=length(s)) do begin
    if (s[i]='%') then
      if (i<length(s)) then begin 
	if s[i]='%' then if (i+4<=length(s)) then begin
		if (s[i+4]='%') then
		if (s[i+1] in ['0'..'9']) and
			(s[i+2] in ['0'..'9']) and
			(s[i+3] in ['0'..'9']) then begin
			dec(len,5); inc(i,4); end;
		end;
	end;
    inc(i);
  end;
  lenn:=len;
end;

function mln(s:string; l:integer):string;
var i,i2:integer;
    s2:string;
begin
  s2:='';
  while (lenn(s)<l) do s:=s+' ';
  if (lenn(s)>l) then
  if (length(s)<=4) then begin
        s:=copy(s,1,l);
  end else begin
  i:=1;
  i2:=0;
  while (i<=length(s)-4) and (i2<l) do begin
    if (s[i]='%') and (s[i+4]='%') and
         (s[i+1] in ['0'..'9']) and (s[i+2] in ['0'..'9']) and
                (s[i+3] in ['0'..'9']) then begin
                        s2:=s2+s[i]+s[i+1]+s[i+2]+s[i+3]+s[i+4];
                        inc(i,4);
    end else begin
        s2:=s2+s[i];
        inc(i2);
    end;
    inc(i);
  end;
  if not((s[length(s)-4]='%') and (s[length(s)]='%')
         and (s[i+1] in ['0'..'9']) and (s[i+2] in ['0'..'9']) and
                (s[i+3] in ['0'..'9'])) then begin
        if (i2<l) then begin
                inc(i2);
                s2:=s2+s[length(s)-3];
        end;
        if (i2<l) then begin
                inc(i2);
                s2:=s2+s[length(s)-2];
        end;
        if (i2<l) then begin
                inc(i2);
                s2:=s2+s[length(s)-1];
        end;
        if (i2<l) then begin
                inc(i2);
                s2:=s2+s[length(s)];
        end;
  end;
  s:=s2;
  end;
  mln:=s;
end;

function mn(i,l:longint):string;
begin
  mn:=mln(cstr(i),l);
end;

function mrn(s:string; l:integer):string;
begin
  while lenn(s)<l do s:=' '+s;
  if lenn(s)>l then s:=copy(s,1,l);
  mrn:=s;
end;

function cstrn(i:longint):string;
var 
x:integer;
c:string[16];
begin
  str(i,c);
  for x:=1 to (4-length(c)) do
	c:='0'+c;
  cstrn:=c;
end;

function allcaps(s:string):string;
var i:integer;
begin
  for i:=1 to length(s) do s[i]:=upcase(s[i]);
  allcaps:=s;
end;

function caps(s:string):string;
var i:integer;
begin
  for i:=1 to length(s) do
    if (s[i] in ['A'..'Z']) then s[i]:=chr(ord(s[i])+32);
  for i:=1 to length(s) do
    if (not (s[i] in ['A'..'Z','a'..'z'])) then
      if (s[i+1] in ['a'..'z']) then s[i+1]:=upcase(s[i+1]);
  s[1]:=upcase(s[1]);
  caps:=s;
end;

function aonoff(b:boolean; s1,s2:string):string;
begin
  if (b) then aonoff:=s1 else aonoff:=s2;
end;

procedure getdatetime(var dt:datetimerec);
var w1,w2,w3,w4:word;
begin
  gettime(w1,w2,w3,w4);
  with dt do begin
    day:=daynum(datelong);
    hour:=w1;
    min:=w2;
    sec:=w3;
  end;
end;

function getlanguage:byte;
var langf:file of languagerec;
    langr:languagerec;
    firstlp,lp,lp2:listptr;
    rt:returntype;
    w2:windowrec;
    c3:char;
    b:byte;
    x,cur,top:integer;
    done,ok:boolean;
begin
b:=0;
assign(langf,adrv(systat.gfilepath)+'LANGUAGE.DAT');
filemode:=66;
{$I-} reset(langf); {$I+}
if (ioresult<>0) then begin
        displaybox('Error reading LANGUAGE.DAT',4000);
        getlanguage:=0;
        exit;
end;
ok:=TRUE;
if (filesize(langf)<2) then begin
        close(langf);
        ok:=recreatelanguage;
end;
if not(ok) then begin
        getlanguage:=0;
        exit;
end else begin
assign(langf,adrv(systat.gfilepath)+'LANGUAGE.DAT');
filemode:=66;
{$I-} reset(langf); {$I+}
if (ioresult<>0) then begin
        displaybox('Error reading LANGUAGE.DAT',4000);
        getlanguage:=0;
        exit;
end;
end;
listbox_tag:=FALSE;
listbox_insert:=FALSE;
listbox_delete:=FALSE;
listbox_move:=FALSE;

                                new(lp);
                                seek(langf,1);       
                                read(langf,langr);
                                lp^.p:=NIL;
                                lp^.list:=mln(langr.name,40);
                                firstlp:=lp;
                                x:=1;
                                while (x<99) and (not(eof(langf))) do begin
                                        inc(x);
                                        seek(langf,x);
                                        read(langf,langr);
                                        new(lp2);
                                        lp2^.p:=lp;
                                        lp^.n:=lp2;
                                        lp2^.list:=mln(langr.name,40);
                                        lp:=lp2;
                                end;
                                lp^.n:=NIL;
                                top:=1;
                                cur:=1;
                                for x:=1 to 100 do rt.data[x]:=-1;
                                done:=FALSE;
                                repeat
                                lp:=firstlp;
                                listbox(w2,rt,top,cur,lp,18,7,62,20,3,0,8,'Select Language','',TRUE);
                                case rt.kind of
                                        0:begin
                                                c3:=chr(rt.data[100]);
                                                removewindow(w2);
                                                checkkey(c3);
                                                rt.data[100]:=-1;
                                                done:=FALSE;
                                          end;
                                        1:begin
                                                done:=TRUE;
                                                if (rt.data[1]=-1) then b:=0 else
                                                        b:=rt.data[1];
                                        end;
                                        else begin
                                                b:=0;
                                                done:=TRUE;
                                             end;
                                end;
                                removewindow(w2);
                                until (done);
listbox_tag:=TRUE;
listbox_insert:=TRUE;
listbox_delete:=TRUE;
listbox_move:=TRUE;
getlanguage:=b;
close(langf);
lp:=firstlp;
while (lp<>NIL) do begin
         lp2:=lp^.n;
         dispose(lp);
         lp:=lp2;
end;
end;

procedure timediff(var dt:datetimerec; dt1,dt2:datetimerec);
begin
  with dt do begin
    day:=dt2.day-dt1.day;
    hour:=dt2.hour-dt1.hour;
    min:=dt2.min-dt1.min;
    sec:=dt2.sec-dt1.sec;

    if (hour<0) then begin inc(hour,24); dec(day); end;
    if (min<0) then begin inc(min,60); dec(hour); end;
    if (sec<0) then begin inc(sec,60); dec(min); end;
  end;
end;

function longtim(dt:datetimerec):string;
var s:string;
    d:integer;

  procedure ads(comma:boolean; i:integer; lab:string);
  begin
    if (i<>0) then begin
      s:=s+cstr(i)+' '+lab;
      if (i<>1) then s:=s+'s';
      if (comma) then s:=s+', ';
    end;
  end;

begin
  s:='';
  with dt do begin
    d:=day;
    if (d>=7) then begin
      ads(TRUE,d div 7,'week');
      d:=d mod 7;
    end;
    ads(TRUE,d,'day');
    ads(TRUE,hour,'hour');
    ads(TRUE,min,'minute');
    ads(FALSE,sec,'second');
  end;
  if (s='') then s:='0 seconds';
  if (copy(s,length(s)-1,2)=', ') then s:=copy(s,1,length(s)-2);
  longtim:=s;
end;

function cstrl(li:longint):string;
var c:string;
begin
  str(li,c);
  cstrl:=c;
end;

function fit(f1,f2:astr):boolean;
var tf:boolean; c:integer;
begin
  tf:=TRUE;
  for c:=1 to 12 do
    if (f1[c]<>f2[c]) and (f1[c]<>'?') then tf:=FALSE;
  fit:=tf;
end;

function centered(s:string;x:integer):string;
var temp : string;
L : byte;
begin
    Fillchar(Temp[1],x,' ');
    Temp[0] := chr(x);
    L := length(s);
    If L <= x then
       Move(s[1],Temp[((x - L) div 2) + 1],L)
    else
       Move(s[((L - x) div 2) + 1],Temp[1],x);
    centered := temp;
end; {center}

FUNCTION Dosmem : LONGINT;
Type
  MCBrec = RECORD
             location   : Char; {----'M' is normal block, 'Z' is last block }
             ProcessID,
             allocation : WORD; {----Number of 16 Bytes paragraphs allocated}
             reserved   : ARRAY[1..11] OF Byte;
           END;

  PSPrec = RECORD
             int20h,
             EndofMem        : WORD;
             Reserved1       : BYTE;
             Dosdispatcher   : ARRAY[1..5] OF BYTE;
             Int22h,
             Int23h,
             INT24h          : POINTER;
             ParentPSP       : WORD;
             HandleTable     : ARRAY[1..20] OF BYTE;
             EnvSeg          : WORD; {----Segment of Environment}
             Reserved2       : LONGINT;
             HandleTableSize : WORD;
             HandleTableAddr : POINTER;
             Reserved3       : ARRAY[1..23] OF BYTE;
             Int21           : WORD;
             RetFar          : BYTE;
             Reserved4       : ARRAY[1..9] OF BYTE;
             DefFCB1         : ARRAY[1..36] OF BYTE;
             DefFCB2         : ARRAY[1..20] OF BYTE;
             Cmdlength       : BYTE;
             Cmdline         : ARRAY[1..127] OF BYTE;
           END;

Var
  pmcb   : ^MCBrec;
  emcb   : ^MCBrec;
  psp    : ^PSPrec;
  dmem   : LONGINT;

Begin
   psp:=PTR(PrefixSeg,0);      {----PSP given by TP var                }
  pmcb:=Ptr(PrefixSeg-1,0);    {----Programs MCB 1 paragraph before PSP}
  emcb:=Ptr(psp^.envseg-1,0);  {----Environment MCB 1 paragraph before
                                    envseg                             }
  dosmem:=LONGINT(pmcb^.allocation+emcb^.allocation+1)*16;
End; {of DOSmem}

function dt2r(dt:datetimerec):real;
begin
  with dt do
    dt2r:=day*86400.0+hour*3600.0+min*60.0+sec;
end;

function longtim2(dt:datetimerec):string;
var s:string;
    d:integer;

        function datereturn:string;
        var d2,y,m:integer;
            done:boolean;
            months:array[1..12] of integer;
        begin
                months[1]:=31;
                months[2]:=28;
                months[3]:=31;
                months[4]:=30;
                months[5]:=31;
                months[6]:=30;
                months[7]:=31;
                months[8]:=31;
                months[9]:=30;
                months[10]:=31;
                months[11]:=30;
                months[12]:=31;
                d2:=dt.day;
                y:=1970;
                done:=false;
                while not(done) do begin
                        if (leapyear(y)) then begin
                                if (d2>=366) then begin
                                dec(d2,366);
                                inc(y);
                                end else begin
                                        done:=TRUE;
                                end;
                        end else begin
                                if (d2>=365) then begin
                                dec(d2,365);
                                inc(y);
                                end else begin
                                        done:=TRUE;
                                end;
                        end;
                end;
                m:=1;
                if (d2>0) then begin
                        done:=FALSE;
                        m:=1;
                        if (leapyear(y)) then begin
                               months[2]:=29;
                        end;
                        while not(done) do begin
                                if (d2>=months[m]) then begin
                                        dec(d2,months[m]);
                                        inc(m);
                                end else done:=TRUE;
                        end;
                end;
                inc(d2);
                if (d2=0) then begin
                        dec(m);
                        if (m=0) then begin
                                m:=12;
                                dec(y);
                                d2:=months[m];
                        end;
                end;
                datereturn:=tch(cstr(m))+'/'+tch(cstr(d2))+'/'+tch(cstr(y));
        end;

begin
  s:='';
  with dt do begin
    s:=datereturn+' ';
    s:=s+tch(cstr(hour))+':'+tch(cstr(min))+':'+tch(cstr(sec));
  end;
  longtim2:=s;
end;

function longtim3(dt:datetimerec):string;
var s:string;
    d:integer;

        function datereturn:string;
        const mon:array [1..12] of string =
          ('January','February','March','April','May','June',
           'July','August','September','October','November','December');
        var d2,y,m:integer;
            done:boolean;
            months:array[1..12] of integer;
        begin
                months[1]:=31;
                months[2]:=28;
                months[3]:=31;
                months[4]:=30;
                months[5]:=31;
                months[6]:=30;
                months[7]:=31;
                months[8]:=31;
                months[9]:=30;
                months[10]:=31;
                months[11]:=30;
                months[12]:=31;
                d2:=dt.day;
                y:=1970;
                done:=false;
                while not(done) do begin
                        if (leapyear(y)) then begin
                                if (d2>=366) then begin
                                dec(d2,366);
                                inc(y);
                                end else begin
                                        done:=TRUE;
                                end;
                        end else begin
                                if (d2>=365) then begin
                                dec(d2,365);
                                inc(y);
                                end else begin
                                        done:=TRUE;
                                end;
                        end;
                end;
                m:=1;
                if (d2>0) then begin
                        done:=FALSE;
                        m:=1;
                        if (leapyear(y)) then begin
                               months[2]:=29;
                        end;
                        while not(done) do begin
                                if (d2>=months[m]) then begin
                                        dec(d2,months[m]);
                                        inc(m);
                                end else done:=TRUE;
                        end;
                end;
                inc(d2);
                if (d2=0) then begin
                        dec(m);
                        if (m=0) then begin
                                m:=12;
                                dec(y);
                                d2:=months[m];
                        end;
                end;
                datereturn:=mon[m]+' '+tch(cstr(d2))+', '+cstr(y);
        end;

begin
  s:='';
  with dt do begin
    s:=datereturn;
  end;
  longtim3:=s;
end;

end.
