{$A+,B+,D-,E+,F+,I+,L-,N-,O+,R+,S+,V-}
unit COMMON5;

interface

uses common;

function datelong:string;
function getnumeditors:string;
function getcurrenteditor:string;
function getc(c:byte):string;
function tch(s:string):string;
function time:string;
function date:string;
function value(s:string):longint;
function cstr(i:longint):string;
function cstrf(i:longint):string;
function cstrn(i:longint):string;
function cstrnfile(i:longint):string;
function cstrf2(i:longint;ivryear:integer):string;
function cstrl(li:longint):string;
function cstrr(rl:real; base:integer):string;
function centered(s:string;x:integer):string;
function inmconf(b:integer):boolean;
function infconf(b:integer):boolean;
procedure pfl(fn:string; var abort,next:boolean; cr:boolean);
function exist(fn:string):boolean;
procedure printfile(fn:string);
procedure printf(fn:string);              { see if an *.ANS file is available} 
function aacs(s:string):boolean;
function getlongversion(tp:byte):string;
function verline(i:integer):string;
function ctim(rl:real):string;
function tlef:string;
function longtim(dt:datetimerec):string;
function dt2r(dt:datetimerec):real;
procedure r2dt(r:real; var dt:datetimerec);
procedure timediff(var dt:datetimerec; dt1,dt2:datetimerec);
function getdow:byte;
procedure getdatetime(var dt:datetimerec);
function showdatestr(unix:longint):string;

implementation

uses dos,crt,myio3,mkmisc,mkstring;

function aacs(s:string):boolean;
begin
  aacs:=aacs1(thisuser,thisuser.userid,s);
end;

function tch(s:string):string;
begin
  if (length(s)>2) then s:=copy(s,length(s)-1,2) else
    if (length(s)=1) then s:='0'+s;
  tch:=s;
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

function centered(s:string;x:integer):string;
var temp : string;
L : byte;
begin
    Fillchar(Temp[1],x,' ');
    Temp[0] := chr(x);
    L := lennmci(s);
    If L <= x then
       Move(s[1],Temp[((x - L) div 2) + 1],L)
    else
       Move(s[((L - x) div 2) + 1],Temp[1],x);
    centered := temp;
end; {center}

function cstr(i:longint):string;
var c:string[16];
begin
  str(i,c);
  cstr:=c;
end;

function cstrf(i:longint):string;
var 
x:integer;
c:string[16];
begin
  str(i,c);
  for x:=1 to (6-length(c)) do
	c:='0'+c;
  cstrf:=c;
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

function cstrf2(i:longint;ivryear:integer):string;
var  x:integer;
     c:string[16];
begin
  str(i,c);
  for x:=1 to (7-length(c)) do
	c:='0'+c;
  c:=tch(cstr(ivryear))+c;
  c:=copy(c,1,2)+'-'+copy(c,3,3)+'-'+copy(c,6,4);
  cstrf2:=c;
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


function cstrl(li:longint):string;
var c:string;
begin
  str(li,c);
  cstrl:=c;
end;

function cstrr(rl:real; base:integer):string;
var i:integer;
    s:string;
    r1,r2:real;
begin
  if (rl<=0.0) then cstrr:='0'
  else begin
    r1:=ln(rl)/ln(1.0*base);
    r2:=exp(ln(1.0*base)*(trunc(r1)));
    s:='';
    while (r2>0.999) do begin
      i:=trunc(rl/r2);
      s:=s+copy('0123456789ABCDEF',i+1,1);
      rl:=rl-i*r2;
      r2:=r2/(1.0*base);
    end;
    cstrr:=s;
  end;
end;

function inmconf(b:integer):boolean;
var cf:file of boolean;
    i,i2:integer;
    isgood,found:boolean;
begin
isgood:=FALSE;
if (mconf<>0) then begin
        assign(cf,adrv(systat^.gfilepath)+'MCONF'+chr(mconf+64)+'.IDX');
        {$I-} reset(cf); {$I+}
        if (ioresult<>0) then begin
                sl1('!','Error opening MCONF'+chr(mconf+64)+'.IDX');
                inmconf:=FALSE;
                exit;
        end;
        {$I-} seek(cf,b); {$I+}
        if (ioresult=0) then begin
                read(cf,found);
                if (found) then isgood:=TRUE;
        end;
        close(cf);
end else begin
        i2:=1;
        while (i2<=26) and not(isgood) do begin
                if (chr(i2+64) in amconf) then begin
                assign(cf,adrv(systat^.gfilepath)+'MCONF'+chr(i2+64)+'.IDX');
                {$I-} reset(cf); {$I+}
                if (ioresult<>0) then begin
                        sl1('!','Error opening MCONF'+chr(i2+64)+'.IDX');
                end else begin
                        {$I-} seek(cf,b); {$I+}
                        if (ioresult=0) then begin
                                read(cf,found);
                                if (found) then isgood:=TRUE;
                        end;
                        close(cf);        
                end;
                end;
                inc(i2);
        end;
end;
inmconf:=isgood;
end;


function infconf(b:integer):boolean;
var cf:file of boolean;
    i,i2:integer;
    isgood,found:boolean;
begin
isgood:=FALSE;
if (fconf<>0) then begin
        assign(cf,adrv(systat^.gfilepath)+'FCONF'+chr(fconf+64)+'.IDX');
        {$I-} reset(cf); {$I+}
        if (ioresult<>0) then begin
                sl1('!','Error opening FCONF'+chr(fconf+64)+'.IDX');
                infconf:=FALSE;
                exit;
        end;
        {$I-} seek(cf,b); {$I+}
        if (ioresult=0) then begin
                read(cf,found);
                if (found) then isgood:=TRUE;
        end;
        close(cf);
end else begin
        i2:=1;
        while (i2<=26) and not(isgood) do begin
                if (chr(i2+64) in afconf) then begin
                assign(cf,adrv(systat^.gfilepath)+'FCONF'+chr(i2+64)+'.IDX');
                {$I-} reset(cf); {$I+}
                if (ioresult<>0) then begin
                        sl1('!','Error opening FCONF'+chr(i2+64)+'.IDX');
                end else begin
                        {$I-} seek(cf,b); {$I+}
                        if (ioresult=0) then begin
                                read(cf,found);
                                if (found) then isgood:=TRUE;
                        end;
                        close(cf);        
                end;
                end;
                inc(i2);
        end;
end;
infconf:=isgood;
end;

procedure pfl(fn:string; var abort,next:boolean; cr:boolean);
var fil:text;
    ofn:string;
    rt:real;
    ls:string[255];
    ps,i:integer;
    c,c2:char;
    oldmci,oldpause,oaa:boolean;

function tcheck(s:real; i:integer):boolean;
var r:real;
begin
  r:=timer-s;
  if r<0.0 then r:=r+86400.0;
  if (r<0.0) or (r>32760.0) then r:=32766.0;
  if trunc(r)>i then tcheck:=FALSE else tcheck:=TRUE;
end;

begin
  oldmci:=noshowmci;
  printingfile:=TRUE;
  if not(displayingmenu) then
  oaa:=allowabort;
  allowabort:=TRUE;
  abort:=FALSE; next:=FALSE;
  oldpause:=(pause in thisuser.ac);
  thisuser.ac:=thisuser.ac+[pause];
  nofile:=FALSE;
  if (not hangup) then begin
    assign(fil,sqoutsp(fn));
    filemode:=66;
    rt:=timer;
    i:=1;
    while ((tcheck(rt,3)) and (i<>0)) do begin
    {$I-} reset(fil); {$I+}
    i:=ioresult;
    end;
    if (i<>0) then nofile:=TRUE
    else begin
      abort:=FALSE;
      mabort:=FALSE;
      while ((not eof(fil)) and (not nofile) and
             (not abort) and not(mabort) and (not hangup)) do begin
	ps:=0;
        croff:=FALSE;
	repeat
	  inc(ps);
	  read(fil,ls[ps]);
        until ((ls[ps]=#13) or (ps=255) or (eof(fil)) or (hangup));
	ls[0]:=chr(ps);
        if (ls[ps]=#13) then begin
          if (not eof(fil)) then begin
            read(fil,c);
            if (eof(fil)) then ls[0]:=chr(ps-1) else begin
            ls[ps+1]:=#10;
            ls[0]:=chr(ps+1);
            end;
          end;
        end else croff:=TRUE;
        if (pos(^[,ls)<>0) then begin
		ctrljoff:=TRUE;
                lil:=0;
                {noshowpipe:=TRUE;}
        end;
        mpausescr:=TRUE;
        sprompt(ls);
        if (displayingmenu) then begin
                c2:=#0;
                wkey2(c2,abort,next);
                if (pos(upcase(c2),allcaps(smlist))<>0) then begin
                        abort:=TRUE;
                        mc:=upcase(c2);
                end else mc:=#0;
        end else
        wkey(abort,next);
      end;
      close(fil);
    end;
  end;
  if (oldpause) then thisuser.ac:=thisuser.ac+[pause]
        else thisuser.ac:=thisuser.ac-[pause];
  if not(displayingmenu) then
  allowabort:=oaa;
  printingfile:=FALSE; ctrljoff:=FALSE;
  mabort:=FALSE;
  displayingmenu:=FALSE;
{ curco:=255-curco;
  setc(7 or (0 shl 4)); 
  redrawforansi; }
  clearansi;
  topscr;
  mpausescr:=FALSE;
  noshowpipe:=FALSE;
  lil:=wherey-1;
  pap:=wherex-1;
  noshowmci:=oldmci;
end;


function exist(fn:string):boolean;
var srec:searchrec;
begin
  findfirst(sqoutsp(fn),anyfile,srec);
  exist:=(doserror=0);
end;

procedure printfile(fn:string);
var s:string;
    year,month,day,dayofweek:word;
    x,i,j,wx,wy:integer;
    abort,next:boolean;
begin
  fn:=allcaps(fn); s:=fn;
  if (copy(fn,length(fn)-3,4)='.ANS') then begin
    if (exist(copy(fn,1,length(fn)-4)+'.ANS')) then
      repeat
	i:=random(10);
	if (i=0) then
	  fn:=copy(fn,1,length(fn)-4)+'.ANS'
	else
	  fn:=copy(fn,1,length(fn)-4)+'.AN'+cstr(i);
      until (exist(fn));
  end;

  if (copy(fn,length(fn)-3,4)='.TXT') then begin
    if (exist(copy(fn,1,length(fn)-4)+'.TXT')) then
      repeat
	i:=random(10);
	if (i=0) then
          fn:=copy(fn,1,length(fn)-4)+'.TXT'
	else
          fn:=copy(fn,1,length(fn)-4)+'.TX'+cstr(i);
      until (exist(fn));

  end;

  getdate(year,month,day,dayofweek);
  s:=fn; s[length(s)-1]:=chr(dayofweek+49);
  if (exist(s)) then fn:=s;

  pfl(fn,abort,next,TRUE);
end;

procedure printf(fn:string);              { see if an *.ANS file is available} 
var ffn,ps,ns,es,s,sss:string;                  { if you have ansi graphics invoked}
    ps1,ps2,i,j,wx,wy:integer;
    year,month,day,dayofweek:word;
    done,abort,next:boolean;
begin
  nofile:=FALSE;
  fn:=sqoutsp(fn);
  fn:=processMCI(fn);
  sss:='';
  if (fn='') then exit;
  if (pos('\',fn)=0) then begin
    j:=2;
    fsplit(fexpand(fn),ps,ns,es);
    if (langr.displaypath<>'') then begin
        if (not exist(adrv(langr.displaypath)+ns+'.*')) then begin
                if (langr.checkdefpath) then begin
                        if not(exist(adrv(systat^.afilepath)+ns+'.*')) then nofile:=true
                         else begin
                                ffn:=adrv(systat^.afilepath)+fn;
                         end;
                end else nofile:=TRUE;
        end else begin
                ffn:=adrv(langr.displaypath)+fn;
        end;
    end else begin
        if (not exist(adrv(systat^.afilepath)+ns+'.*')) then nofile:=TRUE
        else begin
                ffn:=adrv(systat^.afilepath)+fn;
             end;
    end;
  end else ffn:=fn;
  if not(nofile) then begin
    ffn:=fexpand(ffn);
{    if (pos('.',fn)<>0) then printfile(ffn)
    else begin
      if ((okansi) and (exist(ffn+'.ans'))) then printfile(ffn+'.ans') else
        nofile:=TRUE;
      if (nofile) then
	  if (exist(ffn+'.txt')) then printfile(ffn+'.txt');
    end;
    end;
    if (nofile) then begin
	sl1('!','File: '+fn+' does not exist.');
    end;}

    if (pos('.',fn)=0) then begin
      if ((okansi) and (exist(ffn+'.ANS'))) then begin
        ffn:=ffn+'.ANS';
        nofile:=FALSE;
      end else nofile:=TRUE;
      if (nofile) then
          if (exist(ffn+'.TXT')) then begin
          ffn:=ffn+'.TXT';
          nofile:=FALSE;
          end;
      end;
    end;
    if (nofile) then begin
	sl1('!','File: '+fn+' does not exist.');
    end else begin


  ffn:=allcaps(ffn); s:=ffn;
  if (copy(ffn,length(ffn)-3,4)='.ANS') then begin
    if (exist(copy(ffn,1,length(ffn)-4)+'.ANS')) then
      repeat
	i:=random(10);
	if (i=0) then
          ffn:=copy(ffn,1,length(ffn)-4)+'.ANS'
	else
          ffn:=copy(ffn,1,length(ffn)-4)+'.AN'+cstr(i);
      until (exist(ffn));
  end;

  if (copy(ffn,length(ffn)-3,4)='.TXT') then begin
    if (exist(copy(ffn,1,length(ffn)-4)+'.TXT')) then
      repeat
	i:=random(10);
	if (i=0) then
          ffn:=copy(ffn,1,length(ffn)-4)+'.TXT'
	else
          ffn:=copy(ffn,1,length(ffn)-4)+'.TX'+cstr(i);
      until (exist(ffn));

  end;

  getdate(year,month,day,dayofweek);
  s:=ffn; s[length(s)-1]:=chr(dayofweek+49);
  if (exist(s)) then ffn:=s;

  pfl(ffn,abort,next,TRUE);
  end;
end;

function getc(c:byte):string;
const xclr:array[0..7] of char=('0','4','2','6','1','5','3','7');
var s:string;
    b:boolean;

  procedure adto(ss:string);
  begin
    if (s[length(s)]<>';') and (s[length(s)]<>'[') then s:=s+';';
    s:=s+ss; b:=TRUE;
  end;

begin
  b:=FALSE;
  if ((curco and (not c)) and $88)<>0 then begin
    s:=#27+'[0';
    curco:=$07;
  end else
    s:=#27+'[';
  if (c and 7<>curco and 7) then adto('3'+xclr[c and 7]);
  if (c and $70<>curco and $70) then adto('4'+xclr[(c shr 4) and 7]);
  if (c and 128<>0) then adto('5');
  if (c and 8<>0) then adto('1');
  if (not b) then adto('3'+xclr[c and 7]);
  s:=s+'m';
  getc:=s;
end;

function getnumeditors:string;
var doorfile:file of doorrec;
    s:string;
begin
        assign(doorfile,adrv(systat^.gfilepath)+'EDITORS.DAT');
        filemode:=66;
        {$I-} reset(doorfile); {$I+}
        if (ioresult<>0) then begin
                s:='0';
        end else begin
                s:=cstr(filesize(doorfile)-1);
                close(doorfile);
        end;
        getnumeditors:=s;
end;

function getcurrenteditor:string;
var doorfile:file of doorrec;
    doorr:doorrec;
    s:string;
begin
        assign(doorfile,adrv(systat^.gfilepath)+'EDITORS.DAT');
        filemode:=66;
        {$I-} reset(doorfile); {$I+}
        if (ioresult<>0) then begin
                s:='';
        end else begin
                        case thisuser.msgeditor of
                                -1:s:='nxEDIT ANSI Editor';
                                 0:s:='Internal Line Editor';
                                 else begin
                        if (thisuser.msgeditor <= filesize(doorfile)-1) then begin
                                seek(doorfile,thisuser.msgeditor);
                                read(doorfile,doorr);
                                s:=doorr.doorname;
                                close(doorfile);
                        end;
                        end;
                        end;
        end;
        getcurrenteditor:=s;
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

function getlongversion(tp:byte):string;
begin
getlongversion:=version+'.'+copy(build,2,length(build)-1);
end;

function verline(i:integer):string;
var s:string;
begin
  s:='';
  case i of  
    1:begin
        s:='%070%N%150%exus %070%B%150%ulletin %070%B%150%oard %070%S%150%ystem/DOS %150%v'+getlongversion(1);
      end;
    2:s:='%090%(c) Copyright 1994-2003 George A. Roberts IV. All rights reserved.';
    3:s:='%090%This is an Open Source Project available from http://www.nexusbbs.net/';
  end;
  verline:=s;
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

function tlef:string;
begin
  tlef:=ctim(nsl);
end;

function longtim(dt:datetimerec):string;
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

function dt2r(dt:datetimerec):real;
begin
  with dt do
    dt2r:=day*86400.0+hour*3600.0+min*60.0+sec;
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

function getdow:byte;
var y,m,d,dow:WORD;
begin
getdate(y,m,d,dow);
getdow:=dow;
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

    
function showdatestr(unix:longint):string;
var d:datetime;
begin
UnixToDT(unix,d);
showdatestr:=FormattedDate(d,'MM/DD/YYYY HH:II:SS');
end;

end.
