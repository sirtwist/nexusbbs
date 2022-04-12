{$A+,B+,D-,E+,F+,I+,L-,N-,O+,R+,S+,V-}
unit common2;

interface

uses
  crt, dos,
  myio3, keyunit,
  tmpcom;

procedure skey1(c:char);
procedure remove_port;
procedure iport;
procedure sendcom1(c:char);
function recom1(var c:char):boolean;
procedure term_ready(ready_status:boolean);
procedure inuserwindow;
procedure sclearwindow;
procedure schangewindow(needcreate:boolean; newwind:integer);
FUNCTION Dosmem : LONGINT;
procedure topscr;
procedure tleft;
procedure tleft2;
procedure rereaduf;
procedure saveuf;
procedure sysopshell(takeuser:boolean);
procedure showmemory;


implementation

uses
  common, common1, common3,doors,execbat,newusers,useredit;

procedure sysopshell(takeuser:boolean);
var wind:windowrec;
    t:real;
    oldenv:string;
    sx,sy,ret:integer;
    s:string;

begin
  t:=timer;
  if ((useron) and (incom)) and not(ch) then begin
    sprompt(gstring(17));
  end;
  sx:=wherex; sy:=wherey;
  savescreen(wind,1,1,80,25);
  textcolor(7);
  textbackground(0);
  clrscr;
  writeln(stripcolor(verline(1)));
  writeln(stripcolor(verline(2)));
  writeln(stripcolor(verline(3)));
  writeln;
  writeln('Type "EXIT" to return to Nexus.');
  currentswap:=modemr^.swaplocalshell;
  sysopshelling:=TRUE;
  shelldos(FALSE,'',ret);
  sysopshelling:=FALSE;
  currentswap:=0;
  getdatetime(tim);
  if ((useron) and (outcom)) then com_flush_rx;
  chdir(start_dir);
  textcolor(7);
  textbackground(0);
  clrscr;
  removewindow(wind);
  gotoxy(sx,sy);
  if (useron) then begin
  freetime:=freetime+timer-t;
  topscr;
  sdc;
      if (incom) and not(ch) then begin
      sprompt(gstring(18));
    end;
  end;
end;

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
//   psp:=PTR(PrefixSeg,0);      {----PSP given by TP var                }
//  pmcb:=Ptr(PrefixSeg-1,0);    {----Programs MCB 1 paragraph before PSP}
//  emcb:=Ptr(psp^.envseg-1,0);  {----Environment MCB 1 paragraph before
                                 {   envseg                             }
//  dosmem:=LONGINT(pmcb^.allocation+emcb^.allocation+1)*16;
End; {of DOSmem}

procedure clrline(y:integer);
var sx,sy,sz:byte;
begin
  sx:=wherex; sy:=wherey; sz:=textattr;
  window(1,1,80,25);
  gotoxy(1,y); textattr:=7; clreol;
  inuserwindow;
  gotoxy(sx,sy); textattr:=sz;
end;

procedure skey1(c:char);
var s:string[50];
    ret,cz,i:integer;
    cc:char;
    chatstart,chatend,tchatted:datetimerec;
    major,minor:byte;
    wx,wy:integer;
    b,savwantout:boolean;
    f:file;
    t:text;
begin
  if not(disablelocalkeys) then
  case ord(c) of
      130:begin
        assign(t,start_dir+'\STACK.LOG');
        {$I-} rewrite(t); {$I+}
        writeln(t,'Nexus Bulletin Board System v'+ver);
        writeln(t,'MEMORY ALLOCATION DUMP - '+date+' '+time);
        writeln(t,'-----------------------------------------------------------------------------');
        writeln(t,'');
        writeln(t,'Remaining STACK     : ',sptr,' bytes');
        writeln(t,'Remaining HEAP      : ',memavail,' bytes');
        writeln(t,'Largest HEAP region : ',maxavail,' bytes');
        writeln(t,'');
        writeln(t,'DOS memory free     : ',dosmem,' bytes');
        writeln(t,'-----------------------------------------------------------------------------');
        close(t);
      end;
      36:begin cursoron(true); SysopShell(FALSE); end; { ALT-J : Shell to OS }
      38:cls;   { ALT-L : Clear Screen }
      59:begin  { F1 : Show Help }
                topscrnum:=2;
                topscr;
         end;
      18,22:if (useron) then begin      { ALT-E / ALT-U : Edit User }
	  wait(TRUE);
          wx:=wherex;
          wy:=wherey;
          uedit(usernum);
          getnewsecurity(thisuser.sl);
          inuserwindow;
          gotoxy(wx,wy);
	  wait(FALSE);
	end;
      32:begin
           wantout:=not(wantout);
           clrscr;
         end;
      35:hangup2:=TRUE; { Hang Up }
      49: {hangup with noise}
        begin
	  randomize;
	  for i:=1 to 50 do prompt(chr(random(255)));
          hangup2:=TRUE;
	end;
      118:begin  { Decrease User Time by 5 minutes }
	  b:=ch; ch:=TRUE;
          dec(utimeleft,5);
	  tleft;
	  ch:=b;
	end;
      132:begin  { Increase User Time by 5 Minutes }
	  b:=ch; ch:=TRUE;
          inc(utimeleft,5);
          if (utimeleft<0) then utimeleft:=32767;
	  tleft;
	  ch:=b;
	end;
      31:if (useron) then
	  with thisuser do begin
            if (sl=100) then
              if (realsl<>100) then begin
		thisuser.sl:=realsl;
		topscr; displaybox('Normal Access Restored.',2000);
	      end else
	    else begin
              realsl:=sl;
              thisuser.sl:=100;
	      topscr; displaybox('Temporary SysOp Access Granted.',2000);
	    end;
	  end;
      46:if (ch) then begin {go into chat}
	  chatr:='';
	end else begin
                    if (systat^.useextchat) then begin
			getdatetime(chatstart);
                        currentswap:=modemr^.swapchat;
			dodoorfunc('0',FALSE);
			getdatetime(chatend);
                        currentswap:=0;
			timediff(tchatted,chatstart,chatend);

			freetime:=freetime+dt2r(tchatted);
			tleft;
                    end else if (okansi) then begin
			getdatetime(chatstart);
                        splitscreen;
			getdatetime(chatend);
			timediff(tchatted,chatstart,chatend);
			freetime:=freetime+dt2r(tchatted);
			tleft;
                        end else chat;
	end;
{      71:if (ch) then chatfile(not cfo); }
      73:begin
                if (topscrnum>0) then dec(topscrnum) else topscrnum:=4;
                if (topscrnum=0) then begin
                        clrline(23);
                        clrline(24);
                end;
                topscr;                
         end;
      81:begin
                if (topscrnum=4) then topscrnum:=0 else inc(topscrnum);
                if (topscrnum=0) then begin
                        clrline(23);
                        clrline(24);
                end;
                topscr;
         end;

          { ALT-K : Toggle User Keyboard On/Off }
      37:if (not com_carrier) then displaybox('No Carrier Detected.',2000)
	else begin
	  if (outcom) then
	    if (incom) then incom:=FALSE else
	      if (com_carrier) then incom:=TRUE;
	  if (incom) then displaybox('User Keyboard ON.',2000)
		     else displaybox('User Keyboard OFF.',2000);
	  com_flush_rx;
	end;
      24:if (outcom) then begin { ALT-O : Toggle User Keyboard/Screen On/Off }
	  savwantout:=wantout; wantout:=FALSE;
	  wait(TRUE);
	  wantout:=savwantout;
	  displaybox('User Screen/Keyboard OFF',2000);
	  outcom:=FALSE; incom:=FALSE;
	end else
	  if (not com_carrier) then displaybox('No Carrier Detected.',2000)
	  else begin
	    displaybox('User Screen/Keyboard ON',2000);
	    savwantout:=wantout; wantout:=FALSE;
	    wait(FALSE);
	    wantout:=savwantout;
	    outcom:=TRUE; incom:=TRUE;
	  end;
(*      111:begin { Clear Chat }
	  chatcall:=FALSE; chatr:='';
	  thisuser.ac:=thisuser.ac-[alert]; tleft;
        end; *)
      25: { Page User }
	begin
	  repeat
	    outkey(^G);
	    displaybox('Paging User...',1000);
	    outkey(^G);
	    delay(100);
	    outkey(^G);
	    checkhangup;
	  until ((not empty) or (hangup));
	end;
(*      113:displaybox(chatr,2000); { Show Chat Reason } *)
    end;
end;

procedure setacch(c:char; b:boolean; var u:userrec);
begin
  if (b) then if (not (tacch(c) in u.ac)) then acch(c,u);
  if (not b) then if (tacch(c) in u.ac) then acch(c,u);
end;

function spflags:astr;
var r:uflags;
    s:astr;
begin
  s:='';
  with thisuser do begin
  if (rlogon in ac) then s:=s+'1Log ';
  if (rChat in ac) then s:=s+'noCht ';
  if (rPost in ac) then s:=s+'noPst ';
  if (rEmail in ac) then s:=s+'noPvt ';
  if (rMsg in ac) then s:=s+'dMsg ';
  if (alert in ac) then s:=s+'Alrt ';
  if (fnodlratio in ac) then s:=s+'ULDL ';
  if (fnopostratio in ac) then s:=s+'POST ';
  if (fnofilepts in ac) then s:=s+'PTS ';
  if (fnodeletion in ac) then s:=s+'DEL ';
  end;
  spflags:=s;
end;


procedure remove_port;
begin
  if (not localioonly) then com_deinstall;
end;

procedure iport;
var anyerrors:word;
    tmp:longint;
begin
  if (not localioonly) then begin
        if (modemr^.ctype=0) then begin
                localioonly:=TRUE;
                spd:='KB';
                answerbaud:=0;
                exit;
        end;
        if (com_installed) then com_deinstall;
        if (modemr^.lockport) then tmp:=modemr^.waitbaud
		else tmp:=answerbaud;
        com_startup(modemr^.ctype,modemr^.comport,tmp,anyerrors);
	case anyerrors of
        0:begin end;
        1:begin
                sl1('!','Error Addressing Port '+cstr(modemr^.comport));
                halt(exiterrors);
	end;
        else sl1('!','Comm Addressing Error: '+cstr(anyerrors));
	end;
  end;
  if (not(com_installed) and not(spd='KB')) then begin
        sl1('!','Communications Error!  Exiting...');
        hangup2:=TRUE;
  end;
end;

procedure sendcom1(c:char);
begin
  if (not localioonly) then com_tx(c);
end;

function recom1(var c:char):boolean;
begin
  c:=#0;
  if (localioonly) then recom1:=TRUE else begin
    if (not com_rx_empty) then begin
      c:=com_rx;
      recom1:=TRUE;
    end else
      recom1:=FALSE;
  end;
end;

procedure term_ready(ready_status:boolean);
begin
  if (not localioonly) then
    if (ready_status) then com_raise_dtr else com_lower_dtr;
end;

procedure inuserwindow;
var sx,sy,sz:byte;
begin
  sx:=wherex; sy:=wherey; sz:=textattr;
  case topscrnum of
        0:window(1,1,80,24);
        1,2:window(1,1,80,22);
  end;
  gotoxy(sx,sy); textattr:=sz;
end;

procedure sclearwindow;
var wind:windowrec;
    i,windysize:integer;
    x,y,z:byte;
begin
{  if (not useron) then exit;}

  x:=wherex; y:=wherey; z:=textattr;
  cursoron(FALSE);

  window(1,1,80,25); textattr:=7;
  for i:=(y+1) to 25 do clrline(i);

  inuserwindow;
  gotoxy(x,y); textattr:=z;
  cursoron(TRUE);
  
end;

procedure schangewindow(needcreate:boolean; newwind:integer);
var wind:windowrec;
    i,j,k,windysize,z:integer;
    sx,sy,sz:byte;
begin
  if (not needcreate) then exit;

  sx:=wherex; sy:=wherey; sz:=textattr;
  
  sclearwindow;

  cursoron(FALSE);

  topscr;
  inuserwindow;
  gotoxy(sx,sy); textattr:=sz;
  
end;

procedure blankzlog(var zz:CallInfoREC);
var i:integer;
begin
  with zz do begin
    date:=0;
    for i:=0 to 20 do userbaud[i]:=0;
    active:=0; calls:=0; newusers:=0; pubpost:=0; 
    fback:=0; criterr:=0; uploads:=0; downloads:=0; uk:=0; dk:=0;
    for i:=1 to 20 do reserved[i]:=0;
  end;
end;

function mrnn(i,l:integer):string;
begin
  mrnn:=mrn(cstr(i),l);
end;

function ctp(t,b:longint):string;
var s,s1:string[32];
    n:real;
begin
  s:=cstr((t*100) div b);
  if (length(s)=1) then s:=' '+s;
  s:=s+'.';
  if (length(s)=3) then s:=' '+s;
  n:=t/b+0.0005;
  s1:=cstr(trunc(n*1000) mod 10);
  ctp:=s+s1+'%';
end;

procedure topscr;
var nodestr,s,spe:string;
    i,j,k,windysize:integer;
    sx,sy,sz:byte;
    c:char;
    d:datetimerec;

begin
  cursoron(FALSE);
  sx:=wherex; sy:=wherey; sz:=textattr;
  window(1,1,80,25);
  case topscrnum of
        0:begin
          textbackground(3);
          gotoxy(1,25); clreol; gotoxy(1,25);
          textcolor(15); textbackground(3);
          if (ivr.level=1) and (cnode=3) then begin
                nodestr:=mln('Local',10);
          end else nodestr:=mln('Node '+cstr(cnode),10);
          with thisuser do begin
          if (answerbaud=0) then spe:='Local ' else
          spe:=mrn(cstr(answerbaud),6);
	  gotoxy(1,25);
          write(mln(copy(nam,1,24),24));
          textcolor(15);
	  gotoxy(26,25);
          write('³');
          textcolor(15);
          write(' '+nodestr);
	  gotoxy(37,25);
          textcolor(15);
          write('³');
          textcolor(15);
          gotoxy(38,25);
	  write(' SL: ');
          textcolor(15);
          gotoxy(43,25);
	  write(mn(sl,3));
          gotoxy(47,25);
          textcolor(15);
          write(' ³');
          gotoxy(49,25);
          textcolor(0);
	  write(' '+spe);
          textcolor(15);
          write(' ³');
          end;
          sde;
          gotoxy(64,25);
          textcolor(15);
          textbackground(3);
          write('³');
          gotoxy(66,25);
          textcolor(15);
          textbackground(3);
          cwrite('Left: ');
          tleft;
          end;
        1:begin
          textbackground(3);
          gotoxy(1,23); clreol; gotoxy(1,23);
          textcolor(15); textbackground(3);
          if (ivr.level=1) and (cnode=3) then begin
                nodestr:=mln('Local',10);
          end else nodestr:=mln('Node '+cstr(cnode),10);
          with thisuser do begin
          if (answerbaud=0) then spe:='Local ' else
          spe:=mrn(cstr(answerbaud),6);
          gotoxy(1,23);
          write(mln(copy(nam,1,24),24));
          textcolor(15);
          gotoxy(26,23);
          write('³');
          textcolor(15);
          write(' '+nodestr);
          gotoxy(37,23);
          textcolor(15);
          write('³');
          textcolor(15);
          gotoxy(38,23);
	  write(' SL: ');
          textcolor(15);
          gotoxy(43,23);
	  write(mn(sl,3));
          gotoxy(47,23);
          textcolor(15);
          write(' ³');
          gotoxy(49,23);
          textcolor(0);
	  write(' '+spe);
          textcolor(15);
          write(' ³');
          end;
          sde;
          gotoxy(64,23);
          textcolor(15);
          textbackground(3);
          write('³');
          gotoxy(66,23);
          textcolor(15);
          textbackground(3);
          cwrite('Left: ');
          tleft;
          textbackground(0);
          window(1,1,80,25);
          gotoxy(1,24); clreol; gotoxy(1,24);
          textbackground(0);
          gotoxy(1,25); clreol; gotoxy(1,25);
          gotoxy(1,24);
          textcolor(11);
          if (systat^.aliasprimary) then
          write(mln(caps(thisuser.realname),30)) else
          write(mln(caps(thisuser.name),30));
          textcolor(7); write('Restr: ');
          textcolor(11);
          write(spflags);
          gotoxy(1,25);
          textcolor(7);
          write('Fl1: ');
          textcolor(11);
          for c:='A' to 'Z' do if c in thisuser.ar then write(c) else write('-');
          textcolor(7);
          write(' Fl2: ');
          textcolor(11);
          for c:='A' to 'Z' do if c in thisuser.ar2 then write(c) else write('-');
          end;
        2:begin
          textbackground(3);
          gotoxy(1,23); clreol; gotoxy(1,23);
          textcolor(15); textbackground(3);
          write(mrn('Sysop Key Help - PgUp for Status Line/PgDn for more screens',80));
          textbackground(0);
          window(1,1,80,25);
          gotoxy(1,24); clreol; gotoxy(1,24);
          textbackground(0);
          gotoxy(1,25); clreol; gotoxy(1,25);
          gotoxy(1,24);
          cwrite(mln('%110%F1    %070%Help',26)+' '+mln('%110%ALT-D %070%Toggle screen mode',26)+' '+
          mln('%110%ALT-H %070%Hangup user',25));
          gotoxy(1,25);
          cwrite(mln('%110%ALT-C %070%Chat with user',26)+' '+mln('%110%ALT-E %070%Edit user account',26)+
          ' '+mln('%110%ALT-J %070%Shell to OS',25));
          end;
        3:begin
          textbackground(3);
          gotoxy(1,23); clreol; gotoxy(1,23);
          textcolor(15); textbackground(3);
          write(mrn('Sysop Key Help - PgUp/PgDn for more screens',80));
          textbackground(0);
          window(1,1,80,25);
          gotoxy(1,24); clreol; gotoxy(1,24);
          textbackground(0);
          gotoxy(1,25); clreol; gotoxy(1,25);
          gotoxy(1,24);
          cwrite(mln('%110%ALT-K %070%Toggle user keyboard',26)+' '+mln('%110%ALT-N %070%Hangup with noise',26)+' '+
          mln('%110%ALT-P %070%Page user',25));
          gotoxy(1,25);
          cwrite(mln('%110%ALT-L %070%Clear screen',26)+' '+mln('%110%ALT-O %070%Toggle user keyboard/scrn',26)+' '+
          mln('%110%ALT-S %070%Temp. sysop mode',25));
          end;
        4:begin
          textbackground(3);
          gotoxy(1,23); clreol; gotoxy(1,23);
          textcolor(15); textbackground(3);
          write(mrn('Sysop Key Help - PgUp for more screens/PgDn for Status Line',80));
          textbackground(0);
          window(1,1,80,25);
          gotoxy(1,24); clreol; gotoxy(1,24);
          textbackground(0);
          gotoxy(1,25); clreol; gotoxy(1,25);
          gotoxy(1,24);
          cwrite('%110%PGUP/PGDN      %070%Toggle status screen mode');
          gotoxy(1,25);
          cwrite('%110%CTRL-PGUP/PGDN %070%+/- 5 minutes on user''s time');
          end;
  end;
  cursoron(TRUE);
  inuserwindow;
  gotoxy(sx,sy); textattr:=sz;
end;

procedure gotopx(i:integer; dy:integer);
var y:integer;
begin
  y:=wherey;
  gotoxy(i,y+dy);
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


procedure tleft;
var s:string[16];
    lng:longint;
    zz:integer;
    sx,sy,sz,showy:byte;
    dt:datetimerec;
begin
  if ((usernum<>0) and (useron)) then begin
    sx:=wherex; sy:=wherey; sz:=textattr;
    case topscrnum of
        0:showy:=25;
        else showy:=23;
    end;
    textcolor(12);
    textbackground(3);
    cursoron(FALSE);
    window(1,1,80,25);
{    if (curon) then cursoron(FALSE);}
    if (hangup) then begin
        gotoxy(59,showy);
        write('DROP ');
    end else
      if (alert in thisuser.ac) then begin
        gotoxy(59,showy);
        write('ALERT');
      end else
         if (chatr<>'') then begin
            gotoxy(59,showy);
            write('CHAT ');
         end else
            if (trapping) then begin
                gotoxy(59,showy);
                write('TRAP ');
            end;
    gotoxy(72,showy);
    textcolor(15);
    r2dt((nsl),dt);
    write(longt(dt));
    inuserwindow;
    gotoxy(sx,sy); textattr:=sz;
    if (wantout) then cursoron(TRUE);
  end;
  if (((nsl<systat^.eventwarningtime*60) and (choptime<>0.0)) and
  not(telluserevent)) then begin
    sl1('!','User warned of approaching event');
    nl; nl;
    r2dt(nsl,dt);
    sprint('%120%System Event approaching in: %150%'+longtim(dt));
    nl;
    telluserevent:=TRUE;
  end;
  if ((nsl<0) and (choptime<>0.0)) then begin
            sl1('!','Logged User Off In Preparation For System Event');
            nl; nl;
            sprint('%120%Shutting Down For System Event.');
            nl;
            hangup2:=TRUE;
  end;
  if ((not ch) and (nsl<0) and (useron) and (choptime=0.0)) then begin
    nl; nl;

    printf('notmleft');
    if (nofile) then sprint('%120%You have used up all your time.  Time expired.');

    if (thisuser.timebank<>0) then begin
      utimeleft:=3;
      nl;
      sprint('%030%Your Time Bank account has %150%'+
             cstr(thisuser.timebank)+'%030% minutes left in it.');
      dyny:=TRUE;
      if pynq('%120%Withdraw From Time Bank? ') then begin
        prt('%120%Withdraw How Many Minutes? %110%'); inu(zz); lng:=zz;
	if (lng>0) then begin
	  if lng>thisuser.timebank then lng:=thisuser.timebank;
	  dec(thisuser.timebankadd,lng);
	  if (thisuser.timebankadd<0) then thisuser.timebankadd:=0;
	  dec(thisuser.timebank,lng);
          thisuser.tltoday:=0;
	  inc(thisuser.tltoday,lng);
	  sprint('%140%In Your Account: %150%'+cstr(thisuser.timebank)+
		  '%140%   Time Left Online: %120%'+cstr(trunc(nsl) div 60));
	  sl1('+','Time Expired. Took '+cstrl(lng)+' Min From TimeBank.');
	end;
      end else	sprint('%120%Hanging up...');
    end;
  end;
  if ((nsl<0) and not(useron)) and (noexit) then begin
        thisuser.tltoday:=15;
  end;
  if (nsl<0) then hangup2:=TRUE;
  checkhangup;
  sde;
end;

procedure tleft2;
var s:string[16];
    lng:longint;
    zz:integer;
    sx,sy,sz:byte;
    dt:datetimerec;
begin
  if (ch) then exit;
  if (((nsl<systat^.eventwarningtime*60) and (choptime<>0.0)) and
  not(telluserevent)) then begin
    sl1('!','User warned of approaching event');
    nl; nl;
    r2dt(nsl,dt);
    sprint('%120%System Event approaching in: %150%'+longtim(dt));
    nl;
    telluserevent:=TRUE;
  end;
  if ((nsl<0) and (choptime<>0.0)) then begin
    sl1('!','Logged User Off In Preparation For System Event');
    nl; nl;
    sprint('%120%Shutting Down For System Event.');
    nl;
    hangup2:=TRUE;
  end;
  if ((not ch) and (nsl<0) and (useron) and (choptime=0.0)) then begin
    nl; nl;

    printf('notmleft');
    if (nofile) then
      sprint('%120%You have used up all your time.  Time expired.');

    if (thisuser.timebank<>0) then begin
      utimeleft:=3;
      nl;
      sprint('%030%Your Time Bank account has %150%'+
             cstr(thisuser.timebank)+'%030% minutes left in it.');
      dyny:=TRUE;
      if pynq('%120%Withdraw From Time Bank? ') then begin
        prt('%120%Withdraw How Many Minutes? %110%'); inu(zz); lng:=zz;
	if (lng>0) then begin
	  if lng>thisuser.timebank then lng:=thisuser.timebank;
	  dec(thisuser.timebankadd,lng);
	  if (thisuser.timebankadd<0) then thisuser.timebankadd:=0;
	  dec(thisuser.timebank,lng);
	  inc(thisuser.tltoday,lng);
	  sprint('%140%In Your Account: %150%'+cstr(thisuser.timebank)+
		  '%140%   Time Left Online: %120%'+cstr(trunc(nsl) div 60));
	  sl1('+','Time Expired. Took '+cstrl(lng)+' Min From TimeBank.');
	end;
      end else
	sprint('%120%Hanging up...');
    end;
  end;
  if ((nsl<0) and not(useron)) and (noexit) then thisuser.tltoday:=15;
  if (nsl<0) then hangup2:=TRUE;
  checkhangup;
  sde;
end;


procedure rereaduf;
var savsl:integer;
    ufo:boolean;
begin
  if (usernum<>0) then begin
    if (realsl<>-1) then savsl:=thisuser.sl;
    ufo:=(filerec(uf).mode<>fmclosed);
    filemode:=66;
    if (not ufo) then begin
    {$I-} reset(uf);{$I+}
    if (ioresult=0) then begin
            {$I-} seek(uf,usernum); {$I+}
            if (ioresult=0) then begin
            read(uf,thisuser);
            end;
            if (not ufo) then close(uf);
    end;
    end;
    if (realsl<>-1) then begin
        realsl:=thisuser.sl;
        thisuser.sl:=savsl;
    end;
  end;
end;

procedure saveuf;
var savsl:integer;
    ufo:boolean;
begin
  if (usernum<>0) then begin
  if (realsl<>-1) then begin
    savsl:=thisuser.sl;
    thisuser.sl:=realsl;
  end else begin
    savsl:=thisuser.sl;
  end;

    thisuser.lastmconf:=mconf; thisuser.lastfconf:=fconf;
    
    ufo:=(filerec(uf).mode<>fmclosed);
     filemode:=66;
    if (not ufo) then begin
    {$I-} reset(uf);{$I+}
    if (ioresult=0) then begin
            {$I-} seek(uf,usernum); {$I+}
            if (ioresult=0) then begin
            write(uf,thisuser);
            end;
            if (not ufo) then close(uf);
    end;
    end;

    thisuser.sl:=savsl;
    end;
  
end;

procedure showmemory;
begin
writeln('Remaining STACK     : ',sptr,' bytes');
writeln('Remaining HEAP      : ',memavail,' bytes');
writeln('Largest HEAP region : ',maxavail,' bytes');
writeln('');
writeln('DOS memory free     : ',dosmem,' bytes');
end;

end.
