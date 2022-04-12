unit ivmodem;

interface

uses dos,crt,tmpcom,nxwave2,ansi2,mulaware;

const okansi:boolean=FALSE;
      ivFossil=1;
      ivDigiboard=2;
      comtype:byte=ivFossil;
      nofile:boolean=FALSE;
      linenum:integer=0;
      sysop_key=1;
      remote=2;

procedure cls;
procedure ivInstallModem(comport:word; speed:longint; var error:word);
procedure ivDeinstallModem;
function  ivReadChar:char;
procedure ivReadln(var s:string; ml:integer; flags:string);
function  ivKeypressed:boolean;
procedure ivSend(s:string);
procedure ivWriteChar(c:char);
procedure ivWrite(s:string);
procedure ivWriteln(s:string);
procedure ivTextColor(c:integer);
procedure ivTextBackground(c:integer);
procedure ivDisplayFile(fn:string; var abort:boolean);
function  ivCarrier:boolean;
procedure ivGotoxy(x,y:integer);


implementation

const lansi:boolean=FALSE;

procedure cls;
begin
  ivtextcolor(7);
  ivtextbackground(0);
  clrscr;
  linenum:=0;
  if (okansi) then begin
          if (comtype<>0) then com_tx_string(#27+'[2J');
  end else begin
          if (comtype<>0) then com_tx_string(^L);
  end;
end;

function ivKeypressed:boolean;
begin
ivKeypressed:=FALSE;
if (keypressed) then begin
        ivKeypressed:=TRUE;
        exit;
end;
if (comtype<>0) then
if not(com_rx_empty) then ivKeypressed:=TRUE;
end;

procedure ivGotoxy(x,y:integer);
begin
  if (comtype<>0) then com_tx_string(#27+'['+cstr(y)+';'+cstr(x)+'H');
  gotoxy(x,y);
end;

function ivCarrier:boolean;
begin
if (comtype<>0) then ivcarrier:=com_carrier else ivcarrier:=TRUE;
end;

procedure ivsend(s:string);
begin
if (comtype<>0) then com_tx_string(s);
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

procedure ivTextColor(c:integer);
var s:string;
    i:integer;
    i2:byte;
begin
    if (okansi) then begin
    textcolor(c);
    i2:=textattr;
    s:=getc(i2);
    curco:=i2;
    if (comtype<>0) then com_tx_string(s);
    end;
end;

procedure ivTextBackground(c:integer);
var s:string;
    f,i:integer;
    i2:byte;
begin
    if (okansi) then begin
    textbackground(c);
    i2:=textattr;
    s:=getc(i2);
    curco:=i2;
    if (comtype<>0) then com_tx_string(s);
    end;
end;

procedure dispchar(c:char);
begin
if (lansi) then begin
        display_ansi(c);
end else begin
        write(c);
end;
end;

function substall2(src,old,new:astr):astr;
var p:integer;
begin
  p:=1;
  while p>0 do begin
    p:=pos(old,allcaps(src));
    if p>0 then begin
      insert(new,src,p+length(old));
      delete(src,p,length(old));
    end;
  end;
  substall2:=src;
end;

function smci4(s2:string):string;
var s:string;
    i,j:integer;
begin
  s:='';
  if (allcaps(s2)='NODE') then s:=cstr(cnode) else
  if (allcaps(s2)='PADDEDNODE') then s:=cstrn(cnode) else
  if (allcaps(s2)='NEXUSDIR') then s:=nexusdir else
  if (allcaps(s2)='LF') then begin
        s:=#13#10;
        inc(linenum);
  end else
  if (allcaps(s2)='BS') then s:=^H' '^H else
  if (copy(allcaps(s2),1,2)='BS') then begin
        s:='';
        i:=value(copy(s2,3,length(s2)-2));
        if (i=0) then i:=1;
        j:=1;
        while (j<=i) do begin
                s:=s+^H' '^H;
                inc(j);
        end;
	end else
  if (allcaps(s2)='UREAL') then s:=thisuser.realname else
  if (allcaps(s2)='UALIAS') then s:=thisuser.name else
  if (allcaps(s2)='CLS') then begin
        cls;
  end else
  if (s='') then s:=#28+s2+'|';
  smci4:=s;
end;


function process_door(ss:string):string;
var ps1,ps2,i:integer;
    ss3,ss4:string;
    done:boolean;
begin
  done:=false;
  ss4:='';
  while not(done) do begin
	ps1:=pos('|',ss);
	if (ps1<>0) then begin
                ss4:=ss4+copy(ss,1,ps1-1);
		ss[ps1]:=#28;
		ps2:=pos('|',ss);
		if (ps2-ps1<=1) then begin end else
                if (ps2<>0) then begin
                        ss3:=smci4(copy(ss,ps1+1,(ps2-ps1)-1));
                        ss4:=ss4+ss3;
                        ss:=copy(ss,ps2+1,length(ss));
                end;
	end;
	if (pos('|',ss)=0) then done:=TRUE;
  end;
  if (ss<>'') then ss4:=ss4+ss;
  ss:=ss4;
  for ps1:=1 to length(ss) do if ss[ps1]=#28 then ss[ps1]:='|';


  process_door:=ss;
end;

procedure ivWrite(s:string);
var ss,sss:string;
    ps1,p1,p2,p3:integer;
    back,colr:integer;
begin
     ss:=process_door(s);
     while (ss<>'') and (pos('%',ss)<>0) do begin
      p1:=500;
      p2:=500;
      p3:=pos('%',ss); if (p3=0) then p3:=500;
      if (p3<p1) then p1:=p3 else p3:=500;
      colr:=100;
      back:=100;
      if (p1<>500) then begin
	if (p3<>500) then begin
		ss[p3]:=#28;
		if ((length(ss)>=p3+4) and (ss[p3+1] in ['0'..'9']) and
			(ss[p3+2] in ['0'..'9']) and (ss[p3+3] in ['0'..'9']) 
			and (ss[p3+4]='%')) then
                begin
			ss[p3+4]:=#28;
			colr:=value(ss[p3+1]+ss[p3+2]);
                        if (back=100) then back:=value(ss[p3+3]);
                        if (colr>31) or ((colr=0) and not((ss[p3+1]+ss[p3+2])='00')) then colr:=100;
			if (back>7) or ((back=0) and not(ss[p3+3]='0')) then back:=100;
			if (colr<>100) then begin
				sss:=copy(ss,1,p3-1);
				ss:=copy(ss,p3+5,length(ss)-(p3+4));
			end;
		end else begin
			ss[p3]:='%';
			sss:=copy(ss,1,p3);
			ss:=copy(ss,p3+1,length(ss)-p3);
		end;
        end;
      end else begin
	sss:=ss; ss:='';
      end;

      if (comtype<>0) then com_tx_string(sss);
      for ps1:=1 to length(sss) do dispchar(sss[ps1]);

      if (colr<>100) then begin
        if (back<>100) then begin
                ivtextcolor(colr);
                ivtextbackground(back);
        end else ivtextcolor(colr);
      end;
    end;
    for ps1:=1 to length(ss) do if (ss[ps1]=#28) then ss[ps1]:='%';
  if (comtype<>0) then com_tx_string(ss);
  for ps1:=1 to length(ss) do dispchar(ss[ps1]);
end;

procedure ivWriteln(s:string);
begin
ivwrite(s+#13#10);
inc(linenum);
end;

procedure ivWriteChar(c:char);
begin
if (comtype<>0) then com_tx(c);
write(c);
end;

function ivReadChar:char;
begin
ivreadchar:=#0;
if (keypressed) then ivreadchar:=readkey else
if (comtype<>0) then ivReadChar:=com_rx;
end;

(* flags: "U" - Uppercase only
	  "C" - Colors allowed
	  "L" - Linefeeds OFF - no linefeed after <CR> pressed
	  "P" - Capitalize characters ("ERIC OMAN" --> "Eric Oman")
*)

procedure ivReadln(var s:string; ml:integer; flags:string);
var os:string;
    cp:integer;
    c:char;
    origcolor:byte;
    hu,cempty,xxupperonly,xxcolor,xxnolf,xxredisp,xxcaps:boolean;

  procedure dobackspace;
  var i:integer;
      c:byte;
  begin
    if (cp>1) then begin
      dec(cp);
      if (s[cp] in [#32..#255]) then begin
        ivWritechar(^H); ivWritechar(' '); ivWritechar(^H);
      end else begin
	if (cp>1) then
	  if (not (s[cp-1] in [#32..#255])) then begin
            dec(cp);
	  end;
      end;
    end;
  end;

begin
  flags:=allcaps(flags);
  xxupperonly:=(pos('U',flags)<>0); xxcolor:=(pos('C',flags)<>0);
  xxnolf:=(pos('L',flags)<>0);
  xxcaps:=(pos('P',flags)<>0);
  origcolor:=curco; os:=s;
  xxredisp:=FALSE;
  if (comtype<>0) then
  if not(com_carrier) then exit;
  if (s<>'') then begin
        ivWrite(s);
        cp:=length(s)+1;
        xxredisp:=FALSE;
  end else begin
  cp:=1;
  end;
  repeat
    cempty:=TRUE;
    while not(ivkeypressed) do begin timeslice; end;
    c:=ivReadChar;
    if (xxupperonly) then c:=upcase(c);
    if (xxcaps) then
      if (cp>1) then begin
	if (c in ['A'..'Z','a'..'z']) then
	  if (s[cp-1] in ['A'..'Z','a'..'z']) then begin
	    {if (c in ['A'..'Z']) then c:=chr(ord(c)+32);}
	  end else
	    if (c in ['a'..'z']) then c:=chr(ord(c)-32);
      end else
	c:=upcase(c);
    if (c in [#32..#255]) then
     if (cp<=ml) then begin
        s[cp]:=c; inc(cp); ivWritechar(c);
      end else
	  begin
	  end
    else case c of
      ^H:dobackspace;
      ^X:while (cp<>1) do dobackspace;
      #27:begin
           xxredisp:=TRUE;
           s:='';
          end;
    end;
    if (comtype<>0) then hu:=com_carrier else hu:=TRUE;
  until ((c=^M) or (c=^N) or not(hu));
  s[0]:=chr(cp-1);
  if ((xxredisp) and (s='')) then begin
    s:=os;
    ivWrite(s);
  end;
  if (not xxnolf) then ivWriteln('');
end;







{ If ivFossil then

        Errors =    1) Error addressing Comport

  If ivDigiboard then

        Errors =    1) Error addressing DigiChannel

  Errors = anything else then ok

  }

procedure ivInstallModem(comport:word; speed:longint; var error:word);
begin
if (comtype<>0) then com_startup(comtype,comport,speed,error);
end;

procedure ivDeinstallModem;
begin
if (comtype<>0) then com_deinstall;
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

procedure ivDisplayFile(fn:string; var abort:boolean);
var fil:text;
    ofn:string;
    rt:real;
    ls:string[255];
    ps,i:integer;
    c,c2:char;
    linesshown:integer;
    cempty,hu,oldpause,oaa:boolean;

function tcheck(s:real; i:integer):boolean;
var r:real;
begin
  r:=timer-s;
  if r<0.0 then r:=r+86400.0;
  if (r<0.0) or (r>32760.0) then r:=32766.0;
  if trunc(r)>i then tcheck:=FALSE else tcheck:=TRUE;
end;

begin
  abort:=FALSE;
  nofile:=FALSE;
  ivtextcolor(7);
  ivtextbackground(0);
  if (comtype<>0) then hu:=com_carrier else hu:=TRUE;
  if (hu) then begin
    assign(fil,fn);
    filemode:=66;
    rt:=timer;
    i:=1;
    while ((tcheck(rt,2)) and (i<>0)) do begin
    {$I-} reset(fil); {$I+}
    i:=ioresult;
    end;
    if (i<>0) then nofile:=TRUE
    else begin
      abort:=FALSE;
      while ((not eof(fil)) and (not nofile) and
             (not abort) and (hu)) do begin
	ps:=0;
	repeat
	  inc(ps);
	  read(fil,ls[ps]);
          if (comtype<>0) then hu:=com_carrier else hu:=TRUE;
        until ((ls[ps]=^M) or (ps=255) or (eof(fil)) or not(hu));
	ls[0]:=chr(ps);
	if (ls[ps]=^M) then begin
	  if (not eof(fil)) then read(fil,c);
	  ls[0]:=chr(ps-1);
        end;
        if (pos(#27,ls)<>0) then lansi:=TRUE else lansi:=FALSE;
        ivWriteln(ls);
        inc(linesshown);
                if (ivKeypressed) then begin
                        c2:=ivReadChar;
                        case upcase(c2) of
                                'A':abort:=TRUE;
                                #27:abort:=TRUE;
                        end;
                end;
        if (comtype<>0) then hu:=com_carrier else hu:=TRUE;
      end;
      close(fil);
    end;
  end;
  lansi:=FALSE;
  ivTextColor(7);
  ivTextBackground(0);
end;


end.
