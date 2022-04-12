{$A+,B+,D-,E+,F+,I+,L-,N-,O+,R+,S+,V-}
unit common1;

interface

uses
  crt, dos,
  myio3,
  tmpcom;

function checkpw:boolean;
function adrv(s:string):string;
function u_daynum(dt:string):longint;
procedure pausescr;
procedure wait(b:boolean);
procedure inittrapfile;
procedure chatfile(b:boolean);
procedure local_input1(var i:string; ml:integer; tf:boolean);
procedure local_input(var i:string; ml:integer);
procedure local_inputl(var i:string; ml:integer);
procedure local_onek(var c:char; ch:string);
function chinkey:char;
procedure inli1(var s:string);
procedure chat;
procedure showsysfunc;
procedure redrawforansi;
Procedure SplitScreen;

implementation

uses
  mail0, common, common2, common3;

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

function checkpw:boolean;
var s:string[20];
    savsl,savdsl:integer;
begin
  checkpw:=TRUE;
  prompt('Sysop Password: ');

  savsl:=thisuser.sl;
  thisuser.sl:=realsl;
  echo:=((aacs(systat^.seepw)) and (not systat^.localsec));
  thisuser.sl:=savsl;

  echo:=false;
  input(s,20);
  echo:=TRUE;

  if (s<>systat^.sysoppw) then
  begin
    checkpw:=FALSE;
    if (incom) and (s<>'') then sl1('!','Incorrect Sysop Password : '+s);
  end;
end;


procedure pausescr;
var i,x:integer;
    s:string[3];
    s3:string;
    s2:string;
    c:char;
    bb:byte;
    noshow,noshow2:boolean;
begin
  nosound;
  bb:=curco;
  noshow:=noshowpipe;
  noshow2:=noshowmci;
  noshowpipe:=FALSE;
  noshowmci:=FALSE;
  if (mpausescr) then begin
        noynnl:=TRUE;
        if not(pynq(gstring(25))) then mabort:=TRUE;
        noynnl:=FALSE;
        s2:=gstring(25);
        if (mabort) then s2:=s2+gstring(102) else s2:=s2+gstring(100);
  end else begin
        s2:=gstring(24);
  end;

  x:=lenn(s2);
  if not(mpausescr) then begin
        sprompt(s2);
        getkey(c);
  end;
        if ((okansi) and (not hangup)) then begin
           s:=cstr(x);
           if (outcom) then begin
              for i:=1 to x do pr1(^H' '^H);
           end;
           if (wantout) then begin
              for i:=1 to x do write(^H' '^H);
           end;
        end else begin
           for i:=1 to x do begin outkey(^H); outkey(' '); outkey(^H); end;
           if (trapping) then begin
              for i:=1 to x do write(trapfile,^H);
              for i:=1 to x do write(trapfile,' ');
              for i:=1 to x do write(trapfile,^H);
           end;
        end;
  curco:=255-curco;
  setc(bb);
  lil:=0;
  noshowpipe:=noshow;
  noshowmci:=noshow2;
end;

procedure wait(b:boolean);
const lastc:byte=0;
var c,len:integer;
begin
  if (b) then begin
    lastc:=curco;
    sprompt(gstring(16))
  end else begin
    len:=lenn(gstring(16));
    for c:=1 to len do prompt(^H);
    for c:=1 to len do prompt(' ');
    for c:=1 to len do prompt(^H);
    setc(lastc);
  end;
end;

procedure inittrapfile;

function ttype:string;
begin
ttype:='';
if (trapping) then
        if (thisuser.trapseperate) then ttype:='USER' else ttype:='GLOBAL';
end;

begin
  if (systat^.globaltrap) or (thisuser.trapactivity) then trapping:=TRUE
    else trapping:=FALSE;
  if (trapping) then begin
    if (thisuser.trapseperate) then
      assign(trapfile,adrv(systat^.trappath)+'U'+cstr(thisuser.userid)+'.TRP')
    else
      assign(trapfile,adrv(systat^.trappath)+'GLOB'+cstrn(cnode)+'.TRP');
    {$I-} append(trapfile); {$I+}
    if (ioresult<>0) then begin
      rewrite(trapfile);
      writeln(trapfile);
    end;
    writeln(trapfile,'--- Nexus Activity Trap ('+ttype+') - '+nam+' on at '+date+' '+time);
  end;
end;

function doinitials(s:string):string;
var t,s1:string;
    i:integer;
begin
    t:='';
    t:=allcaps(copy(s,1,1));
    s1:=s;
    i:=pos(' ',s);
    while (i<>0) do begin
    s1:=copy(s1,i+1,length(s1)-i);
    t:=t+allcaps(copy(s1,1,1));
    i:=pos(' ',s1);
    end;
    i:=pos(' ',t);
    if (i<>0) then delete(t,i,length(t)-(i-1));
    doinitials:=t;
end;


procedure chatfile(b:boolean);
var bf:file of byte;
    s:string[91];
    cr:boolean;
begin
  s:='CHAT'+cstrn(cnode)+'.LOG';
  if (thisuser.chatseperate) then s:='U'+cstr(usernum)+'.CHT';
  s:=adrv(systat^.trappath)+s;
  if (not b) then begin
    if (cfo) then begin
      cfo:=FALSE;
      if (textrec(cf).mode<>fmclosed) then close(cf);
    end;
  end else begin
    cfo:=TRUE;
    if (textrec(cf).mode=fmoutput) then close(cf);
    assign(cf,s); assign(bf,s);
    cr:=FALSE;
    {$I-} reset(cf); {$I+}
    if (ioresult<>0) then
      rewrite(cf)
    else begin
      close(cf);
      append(cf);
    end;                                                           
    writeln(cf);
    writeln(cf,'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
    writeln(cf,'Chat session started: '+dat);
    writeln(cf,'Chat session between: '+systat^.sysopname+' ('+doinitials(systat^.sysopname)+') and '
                +caps(nam)+' ('+doinitials(caps(nam))+')');
    writeln(cf,'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
    writeln(cf);
  end;
end;

procedure local_input1(var i:string; ml:integer; tf:boolean);
var r:real;
    cp:integer;
    cc:char;
begin
  cp:=1;
  repeat
    cc:=readkey;
    if (not tf) then cc:=upcase(cc);
    if (cc in [#32..#255]) then
      if (cp<=ml) then begin
        i[cp]:=cc;
        inc(cp);
        write(cc);
      end
      else
    else
      case cc of
        ^H:if (cp>1) then begin
            cc:=^H;
            write(^H);
            dec(cp);
          end;
    ^U,^X:while (cp<>1) do begin
            dec(cp);
            write(^H);
          end;
      end;
  until (cc in [^M,^N]);
  i[0]:=chr(cp-1);
  if (wherey<=hi(windmax)-hi(windmin)) then writeln;
end;

procedure local_input(var i:string; ml:integer);  (* Input uppercase only *)
begin
  local_input1(i,ml,FALSE);
end;

procedure local_inputl(var i:string; ml:integer);   (* Input lower & upper case *)
begin
  local_input1(i,ml,TRUE);
end;

procedure local_onek(var c:char; ch:string);                    (* 1 key input *)
begin
  repeat c:=upcase(readkey) until (pos(c,ch)>0);
  writeln(c);
end;

function chinkey:char;
var c:char;
begin
  c:=#0; chinkey:=#0;
  if (keypressed) then begin
    c:=readkey;
    wcolor:=TRUE;
    if (c=#0) then
      if (keypressed) then begin
        c:=readkey;
        skey1(c);
        c:=#1;
        if (buf<>'') then begin
          c:=buf[1];
          buf:=copy(buf,2,length(buf)-1);
        end;
      end;
    chinkey:=c;
  end else
    if ((not com_rx_empty) and (incom)) then begin
      c:=cinkey;
      wcolor:=FALSE;
      chinkey:=c;
    end;
end;

procedure inli1(var s:string);             (* Input routine for chat *)
var cv,cc,cp,g,i,j,x,x2:integer;
    c,c1,c2:char;
    s2:string;
    menu:boolean;
begin
  cp:=1;
  menu:=false;
  if s='MENU' then c:=#27 else c:=#00;
  s:='';
  if (ll<>'') then begin
    prompt(ll);
    s:=ll; ll:='';
    cp:=length(s)+1;
  end;
  repeat
    checkhangup;
    if (c<>#27) then getkey(c);
    case ord(c) of
      7:if (outcom) then sendcom1(^G);
      8:if (cp>1) then begin
          dec(cp); pap:=cp;
          prompt(^H);
        end;
      9:begin
           cv:=5-(cp mod 5);
           if (cp+cv<79) then
             for cc:=1 to cv do begin
               s[cp]:=' ';
               inc(cp); pap:=cp;
               prompt(' ');
             end;
         end;
      23:if cp>1 then
           repeat
             dec(cp); pap:=cp;
             prompt(^H);
           until (cp=1) or (s[cp]=' ');
      24:begin
           for cv:=1 to cp-1 do prompt(^H' '^H);
           cp:=1;
           pap:=0;
         end;
      27:if (cp=1) then begin
           menu:=true;
           c:=^M;
           sprompt('Selection [?=Help] : ');
           onekcr:=false;
           onek(c2,'THCPSQ?'^M);
           onekcr:=true;
           x2:=22;
           case c2 of
                '?':s:='/HELP';
                'T':begin
                        for x:=1 to x2 do prompt(^H' '^H);
                        sprompt('Filename: ');
                        inputmain(s2,60,'L');
                        x2:=10+length(s2);
                        if (s2<>'') then begin
                                s:='/TYPE '+s2;
                        end else begin
                                menu:=false;
                                s:='';
                                c:=#00;
                        end;
                end;
                'H':s:='/BYE';
                'C':s:='/CLS';
                'P':s:='/PAGE';
                'S':if (thisuser.sl=255) then s:='/SHELL' else begin
                        menu:=false;
                        s:='';
                        c:=#00;
                end;
                'Q':s:='/Q';
           end;
           for x:=1 to x2 do prompt(^H' '^H);
         end;
      32..255:if (cp<79) then begin
                s[cp]:=c; pap:=cp; inc(cp);
                outkey(c);
                if (trapping) then write(trapfile,c);
              end;
  end;
  until ((c=^M) or (cp=79) or (hangup) or (not ch));
  if (not ch) then begin c:=#13; ch:=FALSE; end;
  if not(menu) then s[0]:=chr(cp-1) else s[0]:=chr(length(s));
  if (c<>^M) then begin
    cv:=cp-1;
    while (cv>0) and (s[cv]<>' ') and (s[cv]<>^H) do dec(cv);
    if (cv>(cp div 2)) and (cv<>cp-1) then begin
      ll:=copy(s,cv+1,cp-cv);
      for cc:=cp-2 downto cv do prompt(^H);
      for cc:=cp-2 downto cv do prompt(' ');
      s[0]:=chr(cv-1);
    end;
  end;
  if (wcolor) then j:=1 else j:=2;
  if not(menu) then begin
  nl;
  if ((s<>'') and (c=^M)) then nl;
  end;
end;

procedure chat;
var chatstart,chatend,tchatted:datetimerec;
    s,xx:string;
    t1:real;
    i,savpap:integer;
    c:char;
    savecho,savprintingfile:boolean;
begin
  nosound;
  getdatetime(chatstart);

  savprintingfile:=printingfile;
  savpap:=pap; ch:=TRUE;
  chatcall:=FALSE; savecho:=echo; echo:=TRUE;
  if (systat^.autochatopen) then chatfile(TRUE)
     else if (thisuser.chatauto) then chatfile(TRUE);
  nl; nl;
  thisuser.ac:=thisuser.ac-[alert];

  printf('chatinit');
  if (nofile) then begin sprompt(gstring(12)); nl; end;
  print('Nexus Line Chat '+ver+' - Press ESC to access Menu.');
  nl;

  wcolor:=TRUE;

  if (chatr<>'') then begin
    print(' '); chatr:='';
  end;
  repeat
    inli1(xx);
    if (xx[1]='/') then xx:=allcaps(xx);
    if (copy(xx,1,6)='/TYPE ') then begin
      s:=copy(xx,7,length(xx));
      if (s<>'') then begin
        printfile(s);
        if (nofile) then print('File Not Found.');
      end;
    end
    else if (xx='/SHELL') and (thisuser.sl=255) then begin
      print('Shelling...');
      sysopshell(FALSE)
    end
    else if ((xx='/HELP') or (xx='/?')) then begin
      nl;
      if (thisuser.sl=100) then
      sprint('T   Type A File');
      sprint('H   Hang Up');
      sprint('C   Clear The Screen');
      sprint('P   Page The SysOp And User');
      if (thisuser.sl=100) then
      sprint('S   Shell To DOS With User [SL 100 ONLY]');
      sprint('Q   Exit Chat Mode');
      nl;
      xx:='MENU';
    end
    else if (xx='/CLS') then cls
    else if (xx='/PAGE') then begin
      for i:=650 to 700 do begin
        sound(i); delay(4);
        nosound;
      end;
      repeat
        dec(i); sound(i); delay(2);
        nosound;
      until (i=200);
      prompt(^G^G^G^G^G^G);
    end

    else if (xx='/ACS') then begin
      prt('ACS:'); inputl(s,20);
      if (aacs(s)) then print('You have access to that!')
        else print('You DO NOT have access to that.');
    end

    else if (xx='/BYE') then begin
      print('Hanging Up...');
      hangup2:=TRUE;
    end
    else if (xx='/Q') then begin
      ch:=FALSE; print('Chat Ended...');
    end;
    if (cfo) then writeln(cf,xx);
  until ((not ch) or (hangup));

  printf('chatend');
  if (nofile) then begin nl; sprint(gstring(13)); end;

  getdatetime(chatend);
  timediff(tchatted,chatstart,chatend);

  freetime:=freetime+dt2r(tchatted);

  tleft;
  sl1('+','Chatted For '+longtim(tchatted));
  ch:=FALSE; echo:=savecho;
  if ((hangup) and (cfo)) then
  begin
    writeln(cf);
    writeln(cf,'NO CARRIER');
    writeln(cf);
    writeln(cf,'Caller Dropped Carrier.');
    writeln(cf);
  end;
  pap:=savpap; printingfile:=savprintingfile;
  if (cfo) then chatfile(FALSE);
end;

procedure showsysfunc;
var swind:windowrec;
    xx,yy,z:integer;
    c:char;
begin
      xx:=wherex; yy:=wherey; z:=textattr;
      savescreen(w,1,1,80,25);
      window(1,1,80,25);
      gotoxy(1,25);
      textcolor(14);
      textbackground(0);
      clreol;
      write('Esc');
      textcolor(7);
      write('=Quit');
      setwindow2(swind,1,1,78,23,3,0,8,'SysOp Function Keys','Nexus Online Help',TRUE);
      cursoron(FALSE);
gotoxy(2,2);
textbackground(0);
textcolor(14);
write('ALT-J');
textcolor(7);
write('     Local Shell');
gotoxy(2,3);
textcolor(14);
write('ALT-C');
textcolor(7);
write('     Clear Screen');
gotoxy(2,5);
textcolor(14);
write('F1');
textcolor(7);
write('        This Help Screen');
gotoxy(2,6);
textcolor(14);
write('F2');
textcolor(7);
write('        Change User Information');
gotoxy(2,7);
textcolor(14);
write('F3');
textcolor(7);
write('        Switch Between Screen Logging/Full User Activity');
gotoxy(2,8);
textcolor(14);
write('F5');
textcolor(7);
write('        Disconnect User');
gotoxy(2,9);
textcolor(14);
write('F6');
textcolor(7);
write('        Disconnect User With Line Noise');
gotoxy(2,10);
textcolor(14);
write('F7');
textcolor(7);
write('        Decrease User''s Time by 5 Minutes');
gotoxy(2,11);
textcolor(14);
write('F8');
textcolor(7);
write('        Increase User''s Time by 5 Minutes');
gotoxy(2,12);
textcolor(14);
write('F9');
textcolor(7);
write('        Toggle Normal Access/Temporary SysOp Access');
gotoxy(2,13);
textcolor(14);
write('F10');
textcolor(7);
write('       Chat with User');
gotoxy(2,14);
textcolor(14);
write('HOME');
textcolor(7);
write('      Chat: Toggle Chat Logging On/Off');
gotoxy(2,15);
textcolor(14);
write('ALT-F2');
textcolor(7);
write('    Toggle User''s Keyboard On/Off');
gotoxy(2,16);
textcolor(14);
write('ALT-F3');
textcolor(7);
write('    Toggle User''s Screen and Keyboard On/Off');
gotoxy(2,17);
textcolor(14);
write('ALT-F5');
textcolor(7);
gotoxy(2,18);
textcolor(14);
write('ALT-F6');
textcolor(7);
gotoxy(2,19);
textcolor(14);
write('ALT-F8');
textcolor(7);
write('    Set Chat Status to Off');
gotoxy(2,20);
textcolor(14);
write('ALT-F9');
textcolor(7);
write('    Page User with Beeps');
gotoxy(2,21);
textcolor(14);
write('ALT-F10');
textcolor(7);
write('   Show User''s Reason for wanting to Chat');
      repeat
      while not(keypressed) do begin end;
      c:=readkey;
      until (c=#27);
      removewindow(swind);
      removewindow(w);
      if (useron) then topscr;
      gotoxy(xx,yy); textattr:=z;
      cursoron(TRUE);
end;

procedure redrawforansi;
begin
  textattr:=7; curco:=7;
  if ((outcom) and (okansi)) then begin
    pr1(#27+'[0m');
  end;
end;

Procedure SplitScreen;
const
  bs = 4;
var
  oldsnoop : boolean;
  c: char;
  loop: byte;
  quit: boolean;
  last: datetime;
  pm: boolean;
  hourtmp: word;
  attr: byte;
  syslines : array[1..2] of BYTE;
  cw: byte; { Current window }
  p: array[1..2] of record
    x,y: byte;
  End;
  cl: array[1..2] of String;
  lastcl:array[1..2,1..3] of string;
  logcl:array[1..2] of string;
  chatstart,chatend,tchatted:datetimerec;
  temp,rtemp: String;
    i,savpap:integer;
    savecho,savprintingfile:boolean;

Const
  off: array[1..2] of record
    x,y: byte;
  end = ((x:1;y:2),(x:1;y:14));


Procedure clearwindow(w: byte);
var loop: byte;
    tb: byte;
    y1,y2:byte;
Begin
  if (wcolor) then setc(systat^.sysopcolor) else
                        setc(systat^.usercolor);
  for loop := 1 to syslines[w] do Begin
    ansig(off[w].x,off[w].y+loop);
    for tb:= 1 to 78 do outkey(' ');
  End;
  { Clear the window }
  p[cw].x:=1;
  p[cw].y:=1;
  ansig(off[cw].x+p[cw].x,off[cw].y+p[cw].y);
  y1:=0;
  for y2:=1 to 3 do
  if (lastcl[w][y2]<>#1+'NEXUS'+#1) then begin
    ansig(off[w].x+1,off[w].y+y2);
    sprompt(lastcl[w][y2]);
    inc(y1);
  end;
  if (cl[w]<>'') then begin
    ansig(off[w].x+1,off[w].y+1+y1);
    sprompt(cl[w]);
    ansig(off[w].x+1+length(cl[w]),off[w].y+1+y1);
    p[w].x:=1+length(cl[w]);
    p[w].y:=1+y1;
    ansig(off[cw].x+p[cw].x,off[cw].y+p[cw].y);
  end else begin
    p[w].x:=1;
    p[w].y:=1+y1;
    ansig(off[cw].x+p[cw].x,off[cw].y+p[cw].y);
  end;
End;

Begin
  If (ch) then exit;
  inuserwindow;
  if (topscrnum<>0) then syslines[2]:=7 else syslines[2]:=9;
  syslines[1]:=9;
  getdatetime(chatstart);
  savprintingfile:=printingfile;
  savpap:=pap; ch:=TRUE;
  chatcall:=FALSE; savecho:=echo; echo:=TRUE;
  if (systat^.autochatopen) then chatfile(TRUE)
     else if (thisuser.chatauto) then chatfile(TRUE);

  cw := 2;
  p[1].x := 1;
  p[1].y := 1;
  p[2].x := 1;
  p[2].y := 1;
  cl[1] := '';
  cl[2] := '';
  lastcl[1][1] := #1+'NEXUS'+#1;
  lastcl[1][2] := #1+'NEXUS'+#1;
  lastcl[1][3] := #1+'NEXUS'+#1;
  lastcl[2][1] := #1+'NEXUS'+#1;
  lastcl[2][2] := #1+'NEXUS'+#1;
  lastcl[2][3] := #1+'NEXUS'+#1;
  logcl[1]:='';
  logcl[2]:='';
  setc(7);
  cls;
  ansig(1,1);
  sprompt('|PL78|%151%|EP|');
  ansig(1,1);
  sprompt('Nexus Split-Screen Chat         (c) Copyright 1996-2000 George A. Roberts IV.');
  temp:='%090%Ú';
  for i:=2 to ((78-length(caps(nam))) div 2)-1 do temp:=temp+'Ä';
  temp:=temp+'%080%(%150%'+caps(nam)+'%080%)%090%';
  for i:=lenn(temp)+1 to 77 do temp:=temp+'Ä';
  temp:=temp+'¿';
  ansig(1,2);
  sprompt(temp);
  clearwindow(1);
  temp:='%090%À';
  for i:=lenn(temp)+1 to 77 do temp:=temp+'Ä';
  temp:=temp+'Ù';
  ansig(1,12);
  sprompt(temp);
  ansig(1,13);
  sprompt('|PC78|%150%CTRL-W %110%Clear Window   %150%CTRL-Y %110%Erase Line|EP|');
  gotoxy(1,13);
  cwrite('              %150%ESC %110%Exit   %150%CTRL-W %110%Clear Window   %150%CTRL-Y %110%Erase Line');
  temp:='%090%Ú';
  for i:=2 to ((78-length(systat^.sysopname)) div 2)-1 do temp:=temp+'Ä';
  temp:=temp+'%080%(%150%'+systat^.sysopname+'%080%)%090%';
  for i:=lenn(temp)+1 to 77 do temp:=temp+'Ä';
  temp:=temp+'¿';
  ansig(1,14);
  sprompt(temp);
  clearwindow(2);
  temp:='%090%À';
  for i:=lenn(temp)+1 to 77 do temp:=temp+'Ä';
  temp:=temp+'Ù';
  ansig(1,15+syslines[2]);
  sprompt(temp);
  ansig(off[cw].x+p[cw].x,off[cw].y+p[cw].y);
  repeat
    { Check to see If we should update the clock }

    repeat
      getkey(c);

    if ((topscrnum<>0) and (syslines[2]=9)) or
    ((topscrnum=0) and (syslines[2]=7)) then begin
        if (topscrnum<>0) then syslines[2]:=7 else syslines[2]:=9;
        clearwindow(2);
        if (syslines[2]=7) then begin
            ansig(1,23);
            for i:= 1 to 78 do outkey(' ');
            ansig(1,24);
            for i:= 1 to 78 do outkey(' ');
        end;
        temp:='%090%À';
        for i:=lenn(temp)+1 to 77 do temp:=temp+'Ä';
        temp:=temp+'Ù';
        ansig(1,15+syslines[2]);
        sprompt(temp);
        ansig(off[cw].x+p[cw].x,off[cw].y+p[cw].y);
    end;

    until (c in [#0,#8,#9,#13,^W,#25,#27,' '..#255]) or (hangup);

    { Process colours & tabs }
    Case c of
      'A'..'Z': if (wcolor) then setc(systat^.sysopcolor) else
                        setc(systat^.usercolor);
      'a'..'z': if (wcolor) then setc(systat^.sysopcolor) else
                        setc(systat^.usercolor);
      #0: Begin getkey(c); c := #0; End;
      #9: Begin
        c := #0;
      End;
      #27:if not(wcolor) then begin
          c:=#0;
          end;
      else if (wcolor) then setc(systat^.sysopcolor) else
                        setc(systat^.usercolor);
    End;

    quit := (c = #27);
    if (hangup) then quit:=TRUE;
    If (not quit) and (c <> #0) then begin
      { Make sure we're in the right window, If not then relocate }
      If wcolor then begin
        If cw = 1 then begin
          cw := 2;
          ansig(off[cw].x+p[cw].x,off[cw].y+p[cw].y);
        End;
      End
      Else Begin
        If cw = 2 then begin
          cw := 1;
          ansig(off[cw].x+p[cw].x,off[cw].y+p[cw].y);
        End;
      End;
      { Process the keys }
      Case c of
        ^W: begin
            if (wcolor) then cw:=2 else cw:=1;
            cl[cw]:='';
            lastcl[cw][1]:=#1+'NEXUS'+#1;
            lastcl[cw][2]:=#1+'NEXUS'+#1;
            lastcl[cw][3]:=#1+'NEXUS'+#1;
        If wcolor then clearwindow(2)
        Else clearwindow(1);
            end;
        ^Y: Begin
          p[cw].x := 1;
          ansig(off[cw].x+p[cw].x,off[cw].y+p[cw].y);
          prompt(#27+'[K');
          ansig(off[cw].x+p[cw].x,off[cw].y+p[cw].y);
          cl[cw] := '';
          logcl[cw]:='';
        End;
        #8: Begin
          If p[cw].x <> 1 then begin
            Dec(p[cw].x);
            dec(cl[cw][0]); { take off a character in current line }
            dec(logcl[cw][0]);
            prompt(^H);
          End;
        End;
        #13: Begin
                  lastcl[cw][1]:=lastcl[cw][2];
                  lastcl[cw][2]:=lastcl[cw][3];
                  lastcl[cw][3]:=cl[cw];
                  if (cfo) then if (wcolor) then writeln(cf,doinitials(systat^.sysopname)+
                        '> '+logcl[cw]) else writeln(cf,doinitials(caps(nam)+'> '+logcl[cw]));
                  logcl[cw]:='';
                  cl[cw] := '';
                  inc(p[cw].y);
                  p[cw].x := 1;
                  ansig(off[cw].x+p[cw].x,off[cw].y+p[cw].y);
        End;
        else Begin
          If 75 <= byte(cl[cw][0]) then begin { Should we wrap? }
            temp := '';
            rtemp := '';
            loop := byte(cl[cw][0]);
            { Check for a space in the line }
            If (pos(#32,cl[cw]) <> 0) then begin
                while (cl[cw][loop] <> #32) do Begin
                      prompt(^H' '^H);
                      temp := temp + cl[cw][loop];
                      delete(cl[cw],loop,1);
                      delete(logcl[cw],loop,1);
                      dec(loop);
                end;
            { If no space then cut the line short }
            end else begin
             while (loop >= 74) do Begin
              prompt(^H' '^H);
              temp := temp + cl[cw][loop];
              delete(cl[cw],loop,1);
              delete(logcl[cw],loop,1);
              dec(loop);
             End;
            end;
            { Reverse what's in Temp }
            If temp[0] <> #0 then for loop := byte(temp[0]) downto 1 do rtemp := rtemp + temp[loop];

            inc(p[cw].y);
            If (p[cw].y <= syslines[cw]) then begin
                    p[cw].x := 1;
                    ansig(off[cw].x+p[cw].x,off[cw].y+p[cw].y);

                    prompt(rtemp+c);
                    p[cw].x:=length(rtemp+c)+1;
                    if (cfo) then if (wcolor) then writeln(cf,doinitials(systat^.sysopname)+
                        '> '+logcl[cw]) else writeln(cf,doinitials(caps(nam))+'> '+logcl[cw]);
            
                    lastcl[cw][1]:=lastcl[cw][2];
                    lastcl[cw][2]:=lastcl[cw][3];
                    lastcl[cw][3]:=cl[cw];
                    cl[cw] := rtemp+c;
                    logcl[cw]:= rtemp+c;
             end else begin
                    p[cw].x:=1;
                    if (cfo) then if (wcolor) then writeln(cf,doinitials(systat^.sysopname)+
                        '> '+logcl[cw]) else writeln(cf,doinitials(caps(nam))+'> '+logcl[cw]);
            
                    lastcl[cw][1]:=lastcl[cw][2];
                    lastcl[cw][2]:=lastcl[cw][3];
                    lastcl[cw][3]:=cl[cw];
                    cl[cw] := rtemp+c;
                    logcl[cw]:= rtemp+c;
             end;
          end else Begin
            cl[cw] := cl[cw] + c;
            logcl[cw]:=logcl[cw]+c;
            inc(p[cw].x);
            prompt(c);
          End;
        End;
      End;
      { Make sure it hasn't scrolled too far }
      If p[cw].y > syslines[cw] then clearwindow(cw);
    End;
  until (quit) or (hangup);
  ch := false;
  textattr := lightgray;
  if (cfo) then chatfile(FALSE);
  getdatetime(chatend);
  timediff(tchatted,chatstart,chatend);
  freetime:=freetime+dt2r(tchatted);
  inuserwindow;
  topscr;
  tleft;
  cls;
  pausescr;
 { jsclrscr;
}
End;

end.
