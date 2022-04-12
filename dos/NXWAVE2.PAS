unit nxwave2;

interface

uses dos,crt,mkmsgabs,multi,mkstring,mkmisc;

{$I BLUEWAVE.INC}
{$I IVOMS.INC}
{$I NEXUS.INC}

const   localonly:boolean=FALSE;
        echomail:boolean=FALSE;
        nouserfile:boolean=FALSE;
        dyny:boolean=TRUE;
        cnode:integer=0;
        abort:boolean=FALSE;
        lastread:longint=0;
        uploading:boolean=FALSE;
        menu:boolean=FALSE;
        fastdownload:boolean=FALSE;
        packetreceived:boolean=FALSE;
        totalnew:longint=0;
        totalnew2:longint=0;
        numboards:integer=0;
        usernum:word=0;
        himsg:longint=0;
        mbopened:boolean=FALSE;
        newdlpath:string='';
        newulpath:string='';
        newtemppath:string='';
        iv_expired:boolean=FALSE;
        nobundleexit:boolean=FALSE;

Type  StringPtr=^StringIDX;


var online:onlinerec;
    stridx:stringptr;
    langr:languagerec;
    nxw:nxwaverec;
    nxwf:file of nxwaverec;
    nxwu:nxwuserrec;
    nxwuf:file of nxwuserrec;
    memboard:boardrec;
    bf:file of boardrec;
    systatf:file of MatrixREC;
    start_dir:string;
    systat:MatrixREC;
    systf:file of systemrec;
    syst:systemrec;
    thisuser:userrec;
    timeon:datetimerec;
    nexusdir:string;
    CurrentmSG:absmsgptr;
    user:userrec;
    userf:file of userrec;



function onoff(b:boolean):string;
procedure ynq(s:string);
function pynq(s:string):boolean;
function cstr(i:longint):string;
function lenn(s:string):integer;
function mln(s:string; l:integer):string;
function mrn(s:string; l:integer):string;
function cstrn(i:longint):string;
function allcaps(s:string):string;
function caps(s:string):string;
function bslash(b:boolean; s:string):string;
procedure purgedir(s:string);                {* erase all non-dir files in dir *}
function substone(src,old,new:string):string;
function arcmci(src,fn,ifn:string):string;
function adrv(s:string):string;
function value(s:string):longint;
function cstrnfile(i:longint):string;
function stripcolor(o:string):string;
function sqoutsp(s:string):string;
function existdir(fn:astr):boolean;
function exist(fn:string):boolean;
function findbasenum(l:longint):integer;
function tacch(c:char):uflags;
function ageuser(bday:string):integer;
function aacs1(u:userrec; un:LONGINT; s:string):boolean;
function aacs(s:string):boolean;
function time:string;
function date:string;
function leapyear(yr:integer):boolean;
function days(mo,yr:integer):integer;
function daycount(mo,yr:integer):integer;
function u_daynum(dt:string):longint;
function daynum(dt:string):integer;
procedure getdatetime(var dt:datetimerec);
procedure timediff(var dt:datetimerec; dt1,dt2:datetimerec);
function nsl:real;
function longt(dt:datetimerec):string;
procedure r2dt(r:real; var dt:datetimerec);
function tch(s:string):string;
function cstrf2(i:longint;ivryear:integer):string;
function dt2r(dt:datetimerec):real;
function gstring(x:integer):STRING;
function datelong:string;

implementation

uses nxwave1,ivmodem;

function datelong:string;
var r:registers;
    y,m,d:string[4];
    yy,mm,dd,dow:word;
begin
  getdate(yy,mm,dd,dow);
  str(yy,y); str(mm,m); str(dd,d);
  datelong:=tch(m)+'/'+tch(d)+'/'+y;
end;

function gstring(x:integer):STRING;
var f:file;
    s:string;
    numread:word;
begin
if (stridx^.offset[x]<>-1) then begin
assign(f,adrv(systat.gfilepath)+langr.filename+'.NXL');
{$I-}reset(f,1); {$I+}
if (ioresult<>0) then begin
        gstring:='';
        exit;
end;
{$I-} seek(f,stridx^.offset[x]); {$I+}
if (ioresult<>0) then begin
        gstring:='';
        close(f);
        exit;
end;
blockread(f,s[0],1,numread);
if (numread<>1) then begin
        gstring:='';
        close(f);
        exit;
end;
blockread(f,s[1],ord(s[0]),numread);
if (numread<>ord(s[0])) then begin
        gstring:='';
        close(f);
        exit;
end;
close(f);
end else s:='';
gstring:=s;
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

function dt2r(dt:datetimerec):real;
begin
  with dt do
    dt2r:=day*86400.0+hour*3600.0+min*60.0+sec;
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
  str(yy-1900,y); str(mm,m); str(dd,d);
  date:=tch(m)+'/'+tch(d)+'/'+tch(y);
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

function daynum(dt:string):integer;
var d,m,y,t,c:integer;
begin
  t:=0;
  m:=value(copy(dt,1,2));
  d:=value(copy(dt,4,2));
  y:=value(copy(dt,7,2))+1900;
  for c:=1970 to y-1 do
    if (leapyear(c)) then inc(t,366) else inc(t,365);
  t:=t+daycount(m,y)+(d-1);
  daynum:=t;
  if y<1970 then daynum:=0;
end;

procedure getdatetime(var dt:datetimerec);
var w1,w2,w3,w4:word;
begin
  gettime(w1,w2,w3,w4);
  with dt do begin
    day:=daynum(date);
    hour:=w1;
    min:=w2;
    sec:=w3;
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

function nsl:real;
var ddt,dt:datetimerec;
    beenon:real;
begin
    getdatetime(dt);
    timediff(ddt,timeon,dt);
    beenon:=dt2r(ddt);
    nsl:=((online.timeleft*60.0)-(beenon));
end;

function longt(dt:datetimerec):string;
var s:string;
    d:integer;

  function ads(s:string):string;
  begin
    if (length(s)<2) then begin
      s:='0'+s;
      if (length(s)<1) then s:='0'+s;
    end;
    ads:=s;
  end;

function cstrl(li:longint):string;
var c:string;
begin
  str(li,c);
  cstrl:=c;
end;

begin
  s:='';
  with dt do begin
    d:=day;
    if (d>0) then hour:=hour+(d*24);
    if (hour>24) then s:='++' else s:=ads(cstrl(hour));
    s:=s+':'+ads(cstrl(min))+':'+ads(cstrl(sec));
  end;
  longt:=s;
end;

procedure r2dt(r:real; var dt:datetimerec);
begin
  with dt do begin
    day:=trunc(r/86400.0); r:=r-(day*86400.0);
    hour:=trunc(r/3600.0); r:=r-(hour*3600.0);
    min:=trunc(r/60.0); r:=r-(min*60.0);
    sec:=trunc(r);
  end;
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

function ageuser(bday:string):integer;
var i:integer;
begin
  i:=value(copy(datelong,7,4))-value(copy(bday,7,4));
  if (daynum(copy(bday,1,6)+copy(datelong,7,2))>daynum(datelong)) then dec(i);
  ageuser:=i;
end;

function aacs1(u:userrec; un:LONGINT; s:string):boolean;
var s1,s2:string;
    p1,p2,i,j:integer;
    c,c1,c2:char;
    b:boolean;

  procedure getrest;
  begin
    s1:=c;
    p1:=i;
    if ((i<>1) and (s[i-1]='!')) then begin s1:='!'+s1; dec(p1); end;
    if (c in ['E','F','G','M','Q','R','V','X']) then begin
      s1:=s1+s[i+1];
      inc(i);
    end else begin
      j:=i+1;
      repeat
	if (s[j] in ['0'..'9']) then begin
	  s1:=s1+s[j];
	  inc(j);
	end;
      until ((j>length(s)) or (not (s[j] in ['0'..'9'])));
      i:=j-1;
    end;
    p2:=i;
  end;

  function argstat(s:string):boolean;
  var vs:string;
      year,month,day,dayofweek,hour,minute,second,sec100:word;
      x:integer;
      vsi:longint;
      boolstate,res:boolean;
      fddt:datetime;
  begin
    boolstate:=(s[1]<>'!');
    if (not boolstate) then s:=copy(s,2,length(s)-1);
    vs:=copy(s,2,length(s)-1); vsi:=value(vs);
    case s[1] of
      'A':begin
          unixtodt(u.bday,fddt);
          res:=(ageuser(formatteddate(fddt,'MM/DD/YYYY'))>=vsi);
          end;
{      'B':res:=((value(spd)>=value(vs+'00')) or (spd='KB'));}
      'E':res:=(upcase(vs[1]) in u.ar);
      'F':res:=(upcase(vs[1]) in u.ar2);
      'G':res:=(u.sex=upcase(vs[1]));
      'H':begin
	    gettime(hour,minute,second,sec100);
	    res:=(hour=vsi);
	  end;
      'N':res:=(cnode=vsi);
      'Q':res:=(upcase(vs[1]) in u.ar);
      'P':res:=(u.filepoints>=vsi);
      'R':res:=(tacch(upcase(vs[1])) in u.ac);
      'S':res:=(u.sl>=vsi);
{      'T':res:=(trunc(nsl) div 60>=vsi);}
      'U':res:=(un=vsi);
      'W':begin
	    getdate(year,month,day,dayofweek);
	    res:=(dayofweek=ord(s[1])-48);
	  end;
{      'X':begin
		res:=false;
		for x:=1 to 26 do begin
			if (cdavail[x]=vsi) then res:=true;
		end;
	  end;
      'Y':res:=(((lastyesno) and (vsi=1)) or (not(lastyesno) and (vsi=2)));}
      {'Y':res:=(trunc(timer) div 60>=vsi);}
      'Z':begin 
		case (memboard.mbtype) of
		     0:if vs='L' then res:=true else res:=false;
		     1:if vs='E' then res:=true else res:=false;
                     2:if vs='N' then res:=true else res:=false;
		end;
	 end;
    end;
    if (not boolstate) then res:=not res;
    argstat:=res;
  end;

begin
  s:=allcaps(s);
  i:=0;
  while (i<length(s)) do begin
    inc(i);
    c:=s[i];
    if (c in ['A'..'Z']) and (i<>length(s)) then begin
      getrest;
      b:=argstat(s1);
      delete(s,p1,length(s1));
      if (b) then s2:='^' else s2:='%';
      insert(s2,s,p1);
      dec(i,length(s1)-1);
    end;
  end;
  s:='('+s+')';
  while (pos('&',s)<>0) do delete(s,pos('&',s),1);
  while (pos('^^',s)<>0) do delete(s,pos('^^',s),1);
  while (pos('(',s)<>0) do begin
    i:=1;
    while ((s[i]<>')') and (i<=length(s))) do begin
      if (s[i]='(') then p1:=i;
      inc(i);
    end;
    p2:=i;
    s1:=copy(s,p1+1,(p2-p1)-1);
    while (pos('|',s1)<>0) do begin
      i:=pos('|',s1);
      c1:=s1[i-1]; c2:=s1[i+1];
      s2:='%';
      if ((c1 in ['%','^']) and (c2 in ['%','^'])) then begin
	if ((c1='^') or (c2='^')) then s2:='^';
	delete(s1,i-1,3);
	insert(s2,s1,i-1);
      end else
	delete(s1,i,1);
    end;
    while(pos('%%',s1)<>0) do delete(s1,pos('%%',s1),1);   {leave only "%"}
    while(pos('^^',s1)<>0) do delete(s1,pos('^^',s1),1);   {leave only "^"}
    while(pos('%^',s1)<>0) do delete(s1,pos('%^',s1)+1,1); {leave only "%"}
    while(pos('^%',s1)<>0) do delete(s1,pos('^%',s1),1);   {leave only "%"}
    delete(s,p1,(p2-p1)+1);
    insert(s1,s,p1);
  end;
  aacs1:=(not (pos('%',s)<>0));
end;

function aacs(s:string):boolean;
begin
aacs:=aacs1(thisuser,thisuser.userid,s);
end;

function findbasenum(l:longint):integer;
var bif:file of baseidx;
    bi:baseidx;
begin
if (l=-1) then begin
        findbasenum:=-1;
        exit;
end;
assign(bif,adrv(systat.gfilepath)+'MBASES.IDX');
{$I-} reset(bif); {$I+}
if (ioresult<>0) then begin
        findbasenum:=-1;
        exit;
end;
if (filesize(bif)-1<l) then begin
        findbasenum:=-1;
        exit;
end;
seek(bif,l);
read(bif,bi);
close(bif);
findbasenum:=bi.offset;
end;

function sqoutsp(s:string):string;
begin
  while (pos(' ',s)>0) do delete(s,pos(' ',s),1);
  sqoutsp:=s;
end;

  function existdir(fn:astr):boolean;
  var srec:searchrec;
  begin
    while (fn[length(fn)]='\') do fn:=copy(fn,1,length(fn)-1);
    findfirst(fexpand(sqoutsp(fn)),anyfile,srec);
    existdir:=(doserror=0) and (srec.attr and directory=directory);
  end;

function exist(fn:string):boolean;
var srec:searchrec;
begin
  findfirst(sqoutsp(fn),anyfile,srec);
  exist:=(doserror=0);
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

procedure ynq(s:string);
var ss,sss:string;
    ps1,ps2,bb,i,p1,p2,x,z:integer;
    c,mc:char;
    done,xx:boolean;
begin
  if not(ivCarrier) then exit;
  if (dyny) then ss:=s+gstring(100) else
        ss:=s+gstring(102);
  ivwrite(ss);
end;

function yn:boolean;
var c:char;
    s:string;
    dn,yynn:boolean;
begin
  yynn:=dyny;
  if (ivcarrier) then begin
    dn:=false;
    s:=allcaps(GString(99));
    if (length(s)<2) then s:='YNCD';
    s:=s+^M;
    repeat
    c:=#0;
    repeat
      while not(ivKeypressed) do begin doslice; end;
      c:=upcase(ivreadchar);
      if (c=#0) then begin
            c:=upcase(ivreadchar);
            case c of
                    #77:c:='C';
                    #75:c:='D';
            end;
      end;
    until (pos(c,s)<>0) or not(ivcarrier);
    if (c=s[5]) then begin
      ivwriteln('');
      if (yynn) then yn:=TRUE else yn:=FALSE;
      dn:=TRUE;
    end;
    if (c=s[1]) then begin
      if not(yynn) then begin
            ivwrite(gstring(103));
            ivwriteln(gstring(100));
      end else ivwriteln('');
      yn:=TRUE;
      dn:=TRUE;
    end;
    if (c=s[2]) then begin
      if (yynn) then begin
            ivwrite(gstring(101));
            ivwriteln(gstring(102));
      end else ivwriteln('');
      yn:=FALSE;
      dn:=TRUE;
    end;
    if (c=s[3]) then begin
      if (yynn) then begin
            ivwrite(gstring(101));
            ivwrite(gstring(102));
            yynn:=FALSE;
      end;
    end;
    if (c=s[4]) then begin
      if not(yynn) then begin
            ivwrite(gstring(103));
            ivwrite(gstring(100));
            yynn:=TRUE;
      end;
    end;
    if not(ivcarrier) then begin
      yn:=FALSE;
      dn:=TRUE;
    end;
    until (dn);
  end;
  dyny:=FALSE;
end;

function pynq(s:string):boolean;
begin
  ynq(s);
  pynq:=yn;
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
begin
  while (lenn(s)<l) do s:=s+' ';
  if (lenn(s)>l) then
    repeat s:=copy(s,1,length(s)-1) until (lenn(s)=l) or (length(s)=0);
  mln:=s;
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

end.
