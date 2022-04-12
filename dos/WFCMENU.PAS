{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R-,S+,V-}
unit wfcmenu;

interface

uses
  crt, dos,

  sysop11,
  cuser, doors,

  tmpcom,
  mmodem,
  
  myio3, common, logon1, logon2, newusers, mkmisc,mkstring;

const rest:boolean=FALSE;
var ww:windowrec;
    ox,oy:integer;

procedure wfcmdefine;
procedure hangupphone;
procedure wfcmenus(wanthangup:boolean);
procedure wfcmenu1;
procedure killwaitingsema;

implementation

type wfcir=array[1..9] of string;
     wfcip=^wfcir;
     wfcir2=array[1..25] of string;
     wfcip2=^wfcir2;
const 
  curscreen: byte = 1;
  topnode  : integer = 1;
  curnode  : integer = 1;
  refreshtime : integer = 90;
var
  lactive : real;
  dt,
  ddt,
  dt2,dt22,
  ddt2,
  ddt3,
  lastkeypress : datetimerec;
  wfci    : wfcip;
  wfci2   : wfcip2;
  standard,highlight : string;

procedure createwaitingsema;
var f:file;
begin
assign(f,adrv(systat^.semaphorepath)+'WAITING.'+cstrnfile(cnode));
{$I-} rewrite(f); {$I+}
if (ioresult<>0) then begin end;
end;

procedure killwaitingsema;
var f:file;
begin
assign(f,adrv(systat^.semaphorepath)+'WAITING.'+cstrnfile(cnode));
{$I-} erase(f); {$I+}
if (ioresult<>0) then begin end;
end;

function ew(str : string; n : integer) : string;
  Var
    count : integer;
    i : integer;
    len : integer;
    done : boolean;
    retstr : string;

  Begin
  retstr := '';
  len := length(str);
  count := 0;
  i := 1;
  done := false;
  While (i <= len) and (not done) do
    Begin
    While ((i <= len) and (str[i] = '')) do
      inc(i);
    if i <= len then
      inc(count);
    if count = n then
      begin
      retstr[0] := #0;
      If (i > 1) Then
        If Str[i-1] = ';' Then
          RetStr := ';';
      while ((i <= len) and (str[i] <> '')) do
        begin
        inc(retstr[0]);
        retstr[ord(retstr[0])] := str[i];
        inc(i);
        end;
      done := true;
      end
    Else
      while ((i <= len) and (str[i] <> '')) do
        inc(i);
    End;
  ew := retstr;
  End;

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

procedure lastcaller(nn:integer);
  var 
  hilc,z:integer;
  lcallf: File of Lcallers; 

Begin
  if (nn=0) then begin
  assign(lcallf,adrv(systat^.gfilepath)+'LASTON.DAT');
  end else begin
  assign(lcallf,adrv(systat^.gfilepath)+'LASTON.'+cstrnfile(nn));
  end;
  filemode:=66; 
  {$I-} reset(lcallf); {$I+}
  if (ioresult<>0) then begin
                fillchar(lcall,sizeof(lcall),#0);
                lcall.node:=cnode;
                lcall.name:='%120%No data available';
                exit;
  End;
  hilc:=-1;
  for z:=9 downto 0 do begin
		seek(lcallf,z); read(lcallf,lcall);
                if (lcall.node<>0) and (hilc=-1) then hilc:=z;
  end;
  if (hilc<>-1) then begin
        seek(lcallf,z);
        read(lcallf,lcall);
  end else begin
                fillchar(lcall,sizeof(lcall),#0);
                lcall.name:='%120%No data available';
  end;
  close(lcallf);
end;

procedure showstatstoday(nn:integer);
var cif:file of callinforec;
    ci:callinforec;
    ds:string;
    xx:longint;
    done,ent:boolean;
    c:char;
begin
        if (nn=0) then begin
        assign(cif,adrv(systat^.gfilepath)+'CALLINFO.DAT');
        end else begin
        assign(cif,adrv(systat^.gfilepath)+'CALLINFO.'+cstrnfile(nn));
        end;
        {$I-} reset(cif); {$I+}
        if (ioresult<>0) then begin
        if (nn=0) then begin
                displaybox('Error opening CALLINFO.DAT',2000);
        end else begin
                displaybox('Error opening CALLINFO.'+cstrnfile(nn),2000);
        end;
        exit;
        end;
        clrscr;
        ds:=datelong;
        sprompt('%090%Show stats for date: %150%');
        getbirth(ds,TRUE);
        if (ds<>'') then begin
        done:=FALSE;
        xx:=1;
        while (xx<=filesize(cif)-1) and not(done) do begin
                seek(cif,xx);
                read(cif,ci);
                if (ci.date)=u_daynum(ds) then begin
                        done:=TRUE;
                end else inc(xx);
        end;
        close(cif);
        if (done) then begin
                clrscr;
                unixtodt(ci.date,fddt);
                ds:=formatteddate(fddt,'MM/DD/YYYY');
                sprint('%090%Statistics for date: %150%'+ds);
                nl;
                sprint('%090%Minutes Activity: %150%'+cstr(ci.active));
                sprint('%090%Number of Calls : %150%'+cstr(ci.calls));
                sprint('%090%New Users       : %150%'+cstr(ci.newusers));
                sprint('%090%Public Posts    : %150%'+cstr(ci.pubpost));
                sprint('%090%Feedback        : %150%'+cstr(ci.fback));
                sprint('%090%Critical Errors : %150%'+cstr(ci.criterr));
                sprint('%090%Uploads         : %150%'+cstr(ci.uploads));
                sprint('%090%Uploaded Data   : %150%'+showblocks(ci.uk));
                sprint('%090%Downloads       : %150%'+cstr(ci.downloads));
                sprint('%090%Downloaded Data : %150%'+showblocks(ci.dk));
                nl;
                pausescr;
        end else begin
                clrscr;
                sprint('%070%No statistics found for '+ds);
                nl;
                pausescr;
        end;
        end;
end;

function wfckey:char;
var rt:real;
    f:file;
begin
    rt:=timer;
    while not(keypressed) do begin
        timeslice;
        if (TRUE{tcheck(rt,5)}) then begin
        if (exist(adrv(systat^.semaphorepath)+'MXUPDATE.'+cstrnfile(cnode))) then begin
		filemode:=66;
		{$I-} reset(systatf); {$I-}
		if ioresult<>0 then sl1('!','Error Re-reading MATRIX.DAT - MXUPDATE.xxx')
		else begin
                  read(systatf,systat^);
			close(systatf);
                  assign(f,adrv(systat^.semaphorepath)+'MXUPDATE.'+cstrnfile(cnode));
			{$I-} erase(f); {$I-}
                  if ioresult<>0 then begin end;
		end;
        end;
        if (exist(adrv(systat^.semaphorepath)+'READSYS.'+cstrnfile(cnode))) then begin
                assign(systemf,adrv(systat^.gfilepath)+'SYSTEM.DAT');
                filemode:=66;
                {$I-} reset(systemf); {$I+}
                if (ioresult<>0) then begin
                      sl1('!','Error Re-reading SYSTEM.DAT - READSYS.xxx');
                      displaybox('Error opening SYSTEM.DAT... exiting.',3000);
                      halt(exiterrors);
                end;
                read(systemf,syst);
                close(systemf);
                assign(f,adrv(systat^.semaphorepath)+'READSYS.'+cstrnfile(cnode));
                {$I-} erase(f); {$I-}
                if ioresult<>0 then begin end;
	end;
        if (exist(adrv(systat^.semaphorepath)+'SHUTDOWN.'+cstrnfile(cnode))) then begin
                displaybox('Node shutting down due to semaphore request.',2000);
                sl1('!','Shutdown requested via SHUTDOWN semaphore');
                hangup2:=TRUE;
                quitafterdone:=TRUE;
                assign(f,adrv(systat^.semaphorepath)+'SHUTDOWN.'+cstrnfile(cnode));
		{$I-} erase(f); {$I+}
                if ioresult<>0 then begin end; 
	end;
        rt:=timer;
        end;
    end;
    wfckey:=readkey;
end;

procedure showstatstotal(nn:integer);
var tif:file of totalsrec;
    ti:totalsrec;
    ds:string;
    xx:longint;
    done,ent:boolean;
    c:char;
begin
        if (nn=0) then begin
        assign(tif,adrv(systat^.gfilepath)+'TOTALS.DAT');
        end else begin
        assign(tif,adrv(systat^.gfilepath)+'TOTALS.'+cstrnfile(nn));
        end;
        {$I-} reset(tif); {$I+}
        if (ioresult<>0) then begin
        if (nn=0) then begin
                displaybox('Error opening TOTALS.DAT',2000);
        end else begin
                displaybox('Error opening TOTALS.'+cstrnfile(nn),2000);
        end;
        exit;
        end;
        read(tif,ti);
        close(tif);
                clrscr;
                unixtodt(ti.date,fddt);
                ds:=formatteddate(fddt,'MM/DD/YYYY');
                sprint('%090%Statistics since: %150%'+ds);
                nl;
                sprint('%090%Minutes Activity: %150%'+cstr(ti.active));
                sprint('%090%Number of Calls : %150%'+cstr(ti.calls));
                sprint('%090%New Users       : %150%'+cstr(ti.newusers));
                sprint('%090%Public Posts    : %150%'+cstr(ti.pubpost));
                sprint('%090%Feedback        : %150%'+cstr(ti.fback));
                sprint('%090%Critical Errors : %150%'+cstr(ti.criterr));
                sprint('%090%Uploads         : %150%'+cstr(ti.uploads));
                sprint('%090%Downloads       : %150%'+cstr(ti.downloads));
                nl;
                pausescr;
end;

procedure typeofstats;
var c:char;
    s:string;
    x:integer;
    done:boolean;
begin
done:=FALSE;
repeat
clrscr;
sprint('%080%(%150%1%080%) %090%Statistics by Date (all nodes)');
sprint('%080%(%150%2%080%) %090%Statistics by Date (specific node)');
sprint('%080%(%150%3%080%) %090%Total Statistics (all nodes)');
sprint('%080%(%150%4%080%) %090%Total Statistics (specific node)');
nl;
sprompt('%090%Selection %080%(%150%Q%080%uit) %090%: %150%');
onek(c,'1234Q');
case c of
        '1':showstatstoday(0);
        '2':begin
                sprompt('%090%Node # : %150%');
                input(s,4);
                x:=value(s);
                if (x>0) then showstatstoday(x);
            end;
        '3':showstatstotal(0);
        '4':begin
                sprompt('%090%Node # : %150%');
                input(s,4);
                x:=value(s);
                if (x>0) then showstatstotal(x);
            end;
        'Q':done:=TRUE;
end;
until (done);
end;
                
procedure wfcmdefine;
var i:integer;
begin
  textcolor(7);
  etoday:=0; ptoday:=0; ftoday:=0; chatt:=0; shutupchatcall:=FALSE;
  badfpath:=FALSE;

  fastlogon:=FALSE;
  if (fastlocal) then fastlogon:=TRUE;
  fileboard:=1; board:=1;
  readuboard:=-1; readboard:=-1;
  nopfile:=FALSE; enddayf:=FALSE;
  reading_a_msg:=FALSE;
  checkit:=FALSE;
  outcom:=FALSE; useron:=FALSE; chatr:=''; buf:='';
  hangup2:=FALSE; usernum:=1; chatcall:=FALSE; hungup:=FALSE;
  textbackground(0); clrscr; pap:=0;
  lactive:=timer;
  {$I-} reset(uf); {$I+}
  if ioresult<>0 then begin
	writeln('Error reading User file.');
	halt(exiterrors);
  end;
  if (filesize(uf)>1) then begin
    seek(uf,1); read(uf,thisuser);
    close(uf);
    usernum:=1;
  end else begin
    close(uf);
    with thisuser do begin
      pagelen:=24;
      ac:=[onekey,pause,novice,ansi,color];
    end;
  end;
end;

procedure getcallera(var c:char; var chkcom:boolean);
var rl,
    rl1:real;
    s:astr;
    mdm,
    mdmr,
    mdmc:string;
    ring:boolean;

  procedure getresultcode(rs:astr);
  var i,j:integer;
  begin
   if (pos('CONNECT',rs)<>0) then begin
   if (pos('CONNECT 2400',rs)<>0)  then spd:='2400' else
   if (pos('CONNECT 4800',rs)<>0)  then spd:='4800' else
   if (pos('CONNECT 7200',rs)<>0)  then spd:='7200' else
   if (pos('CONNECT 9600',rs)<>0)  then spd:='9600' else
   if (pos('CONNECT 12000',rs)<>0) then spd:='12000' else
    if (pos('CONNECT 14400',rs)<>0) then spd:='14400' else
    if (pos('CONNECT 16800',rs)<>0) then spd:='19200' else
    if (pos('CONNECT 19200',rs)<>0) then spd:='19200' else
    if (pos('CONNECT 21600',rs)<>0) then spd:='21600' else
    if (pos('CONNECT 24000',rs)<>0) then spd:='24000' else
    if (pos('CONNECT 24600',rs)<>0) then spd:='24600' else
    if (pos('CONNECT 26400',rs)<>0) then spd:='26400' else
    if (pos('CONNECT 28800',rs)<>0) then spd:='28800' else
    if (pos('CONNECT 29333',rs)<>0) then spd:='29333' else
    if (pos('CONNECT 30666',rs)<>0) then spd:='30666' else
    if (pos('CONNECT 31200',rs)<>0) then spd:='31200' else
    if (pos('CONNECT 32000',rs)<>0) then spd:='32000' else
    if (pos('CONNECT 33333',rs)<>0) then spd:='33333' else
    if (pos('CONNECT 33600',rs)<>0) then spd:='33600' else
    if (pos('CONNECT 34666',rs)<>0) then spd:='34666' else
    if (pos('CONNECT 36000',rs)<>0) then spd:='36000' else
    if (pos('CONNECT 37333',rs)<>0) then spd:='37333' else
    if (pos('CONNECT 38400',rs)<>0) then spd:='38400' else
    if (pos('CONNECT 38666',rs)<>0) then spd:='38666' else
    if (pos('CONNECT 40000',rs)<>0) then spd:='40000' else
    if (pos('CONNECT 41333',rs)<>0) then spd:='41333' else
    if (pos('CONNECT 42666',rs)<>0) then spd:='42666' else
    if (pos('CONNECT 44000',rs)<>0) then spd:='44000' else
    if (pos('CONNECT 45333',rs)<>0) then spd:='45333' else
    if (pos('CONNECT 46666',rs)<>0) then spd:='46666' else
    if (pos('CONNECT 48000',rs)<>0) then spd:='48000' else
    if (pos('CONNECT 49333',rs)<>0) then spd:='49333' else
    if (pos('CONNECT 50666',rs)<>0) then spd:='50666' else
    if (pos('CONNECT 52000',rs)<>0) then spd:='52000' else
    if (pos('CONNECT 53333',rs)<>0) then spd:='53333' else
    if (pos('CONNECT 54666',rs)<>0) then spd:='54666' else
    if (pos('CONNECT 56000',rs)<>0) then spd:='56000' else
    if (pos('CONNECT 57333',rs)<>0) then spd:='57333' else
    if (pos('CONNECT 57600',rs)<>0) then spd:='57600' else
    if (pos('CONNECT 58666',rs)<>0) then spd:='58666' else
    if (pos('CONNECT 60000',rs)<>0) then spd:='60000' else
    if (pos('CONNECT 61333',rs)<>0) then spd:='61333' else
    if (pos('CONNECT 62666',rs)<>0) then spd:='62666' else
    if (pos('CONNECT 64000',rs)<>0) then spd:='64000' else
    if (pos('CONNECT 76800',rs)<>0) then spd:='76800' else
    if (pos('CONNECT 115200',rs)<>0) then spd:='115200' else
    if (pos('CONNECT 128000',rs)<>0) then spd:='128000' else
    if (pos('CONNECT TELNET',rs)<>0) then spd:= 'TELNET' else
			spd := '38400';
    chkcom:=true;
{		cDelay(150);}
    exit;
   end;
  end;

{  procedure wmb(s:astr);
  begin
    sprint('%070%'+s[1]+'%150%'+copy(s,2,length(s)-1));
  end; }

begin
  ring:=false;
  mdmr:='';
  if (chkcom) then begin
    rl:=timer;
    repeat

                  if (recom1(c)) then begin
                     c:=upcase(c);
                     if (c=#10) or (c=#13) then begin
                             if (pos(modemr^.rspring,mdmr)<>0) then begin
                             chkcom:=TRUE;
                             ring:=TRUE;
                             end;
                             if not(ring) then begin
                                       showmodemresp(mdmr);
                                       mdmr:='';
                             end;
                     end else begin
                             mdmr:=mdmr+c;
                     end;
                  end else begin
                     timeslice;
                  end;


{    if (recom1(c)) then ;
    mdmr:=mdmr+c;
    if (pos(modemr^.rspring,mdmr)<>0) then begin
      chkcom:=TRUE; rl:=timer;
      ring:=true;
      while (c<>#13) and (abs(rl-timer)<0.2) do begin
        c:=cinkey;
      end;
    end; }

    until (abs(timer-rl)>2.5) or (ring) or (length(mdmr)>10);
    if not(ring) then begin
                             if (pos(modemr^.rspring,mdmr)<>0) then begin
                             chkcom:=TRUE;
                             ring:=TRUE;
                             end;
    end;
    showmodemact('Receiving incoming connection');
    showmodemresp(mdmr);

    if not(ring) then begin
        chkcom:=FALSE;
    end;

    if (chkcom) then begin
      begin
        com_flush_rx;
        if (answerbaud=0) then outmodemstring(modemr^.answer);
      end;
      {if (sysopon) then 
      cDelay(50); com_flush_rx; } rl1:=timer; s:=''; rl:=0.0;
      mdmc:='';
      repeat
        chkcom:=FALSE;
        if (answerbaud>2) then begin
          spd:=cstrl(answerbaud);
          chkcom:=TRUE;
          answerbaud:=0;
        end;
        if (keypressed) then begin
          c:=upcase(readkey);
          if (c='H') then begin
            com_flush_rx;
          end;
          chkcom:=TRUE;
        end;
        c:=cinkey;
        if (rl<>0.0) and (abs(rl-timer)>2.0) and (c=#0) then c:=#13;
        if (c<#32) and (c<>#13) then c:=#0;
        if c<>#0 then
          if c<>#13 then begin
            mdmc:=mdmc+c;
            rl:=timer;
          end else begin
            if (pos(modemr^.rspcarrier,mdmc)<>0) then chkcom:=TRUE;
            getresultcode(mdmc);
            rl:=0.0;
          end;
        if (c=#13) then s:='';
        if (abs(timer-rl1)>45.0) then chkcom:=TRUE;
      until chkcom;
      showmodemresp(mdmc);
      if (abs(timer-rl1)>45.0) then begin c:='X'; end;
    end;
    if (spd<>'KB') then begin
        showmodemact('Completing connection');
        incom:=TRUE;
        answerbaud:=value(spd);
    end;
  end;
  window(1,1,80,25);
end;

procedure hangupphone;
begin
  showmodemact('Disconnecting');
  dophonehangup(TRUE);
end;

procedure wfcmenuorig;
var  wfcFile : file;
     wfcif   : text;
     ss      : string;

begin
   window(1,1,80,25);
   cursoron(FALSE);
   wantout:=TRUE;
   assign(wfcFile,systat^.gFilePath+'nexus.bin');
   {$I-} reset(wfcFile,1); {$I+}
   if (ioresult<>0) then begin
        displaybox('Error reading '+adrv(systat^.gFilePath)+'NEXUS.BIN',2000);
        hangup2:=TRUE;
        exit;
   end;
   if (filesize(wfcfile)<4000) then begin
        displaybox(adrv(systat^.gFilePath)+'NEXUS.BIN is an invalid size!',2000);
        hangup2:=TRUE;
        exit;
   end;
   blockRead(wfcFile,mem[$B800:0],4000);
   close(wfcFile);
   assign(wfcif,adrv(systat^.gFilePath)+'NEXUS1.SCI');
   {$I-} reset(wfcif); {$I+}
   if (ioresult<>0) then begin
        displaybox('Error reading '+adrv(systat^.gFilePath)+'NEXUS1.SCI',2000);
        hangup2:=TRUE;
        exit;
   end;
   readln(wfcif,ss);
   lastcaller(cnode);
   gotoxy(value(ew(ss,1)),value(ew(ss,2)));
   sprompt(ew(ss,3));
   readln(wfcif,ss);
   lastcaller(0);
   gotoxy(value(ew(ss,1)),value(ew(ss,2)));
   sprompt(ew(ss,3));
   readln(wfcif,ss);
   mx1:=value(ew(ss,1));
   my1:=value(ew(ss,2));
   mz1:=value(ew(ss,3));
   mc1:=value(ew(ss,4));
   if (ew(ss,4)='') then mc1:=7;
   mb1:=value(ew(ss,5));
   if (ew(ss,5)='') then mb1:=0;
   readln(wfcif,ss);
   mx2:=value(ew(ss,1));
   my2:=value(ew(ss,2));
   mz2:=value(ew(ss,3));
   mc2:=value(ew(ss,4));
   if (ew(ss,4)='') then mc2:=7;
   mb2:=value(ew(ss,5));
   if (ew(ss,5)='') then mb2:=0;
   while not(eof(wfcif)) do begin
        readln(wfcif,ss);
        gotoxy(value(ew(ss,1)),value(ew(ss,2)));
        sprompt(ew(ss,3));
   end;
   close(wfcif);
   if (lastmodact <> '') then showmodemact(lastmodact);
   if (lastmodstring <> '') then showmodemresp(lastmodstring);
end;

procedure whosonline(cn:integer);
var olinef:file of onlinerec;

begin
if exist(adrv(systat^.semaphorepath+'INUSE.'+cstrnfile(cn))) or
exist(adrv(systat^.semaphorepath+'WAITING.'+cstrnfile(cn))) then begin
        nlnode:=cn;        
        assign(olinef,adrv(systat^.gfilepath)+'USER'+cstrn(cn)+'.DAT');
        filemode:=66;
        {$I-} reset(olinef); {$I+}
        if (ioresult=0) then begin
                seek(olinef,0);
                read(olinef,online);
                close(olinef);
        end else begin
                fillchar(online,sizeof(online),#0);
        end;
end else begin
        nlnode:=cn;        
        fillchar(online,sizeof(online),#0);
end;
end;

procedure handlenode(cn:integer);
var olinef:file of onlinerec;
    ch:array[1..3] of string[26];
    cc:char;
    cr,mx:integer;
    ol:onlinerec;
    dn:boolean;
    tf:text;

begin
if exist(adrv(systat^.semaphorepath+'INUSE.'+cstrnfile(cn))) or
exist(adrv(systat^.semaphorepath+'WAITING.'+cstrnfile(cn))) then begin
        assign(olinef,adrv(systat^.gfilepath)+'USER'+cstrn(cn)+'.DAT');
        filemode:=66;
        {$I-} reset(olinef); {$I+}
        if (ioresult=0) then begin
                seek(olinef,0);
                read(olinef,ol);
                close(olinef);
                ch[1]:='Shut down node            ';
                ch[2]:='Log user off (notify user)';
                ch[3]:='Terminate user session    ';
                if (ol.status>0) then mx:=3 else mx:=1;
                setwindow(ww,25,10,55,13+mx,3,0,8,'Node Action',TRUE);
                dn:=FALSE;
                for cr:=1 to mx do begin
                        gotoxy(2,cr+1);
                        textcolor(7);
                        textbackground(0);
                        write(ch[cr]);
                end;
                cr:=1;
                repeat
                        gotoxy(2,cr+1);
                        textcolor(15);
                        textbackground(1);
                        write(ch[cr]);
                        while not(keypressed) do begin
                                timeslice;
                        end;
                        cc:=readkey;
                        case cc of
                                #0:begin
                                        cc:=readkey;
                                        case cc of
                                                #72:begin
                                                        gotoxy(2,cr+1);
                                                        textcolor(7);
                                                        textbackground(0);
                                                        write(ch[cr]);
                                                        dec(cr);
                                                        if (cr<1) then cr:=mx;
                                                    end;
                                                #80:begin
                                                        gotoxy(2,cr+1);
                                                        textcolor(7);
                                                        textbackground(0);
                                                        write(ch[cr]);
                                                        inc(cr);
                                                        if (cr>mx) then cr:=1;
                                                    end;
                                        end;
                                   end;
                                #13:begin
                                        case cr of
                                                1:if pynqbox('Shut down node '+cstr(cn)+'? ') then begin
                                                        assign(tf,adrv(systat^.semaphorepath)+'SHUTDOWN.'+cstrnfile(cn));
                                                        {$I-} rewrite(tf); {$I+}
                                                        if (ioresult<>0) then begin
                                                                displaybox('Error writing shutdown semaphore',2000);
                                                        end else close(tf);
                                                  end;
                                                2:if pynqbox('Log user off node '+cstr(cn)+'? ') then begin
                                                        assign(tf,adrv(systat^.semaphorepath)+'LOGOFF.'+cstrnfile(cn));
                                                        {$I-} rewrite(tf); {$I+}
                                                        if (ioresult<>0) then begin
                                                                displaybox('Error writing logoff semaphore',2000);
                                                        end else close(tf);
                                                  end;
                                                3:if pynqbox('Terminate user session on node '+cstr(cn)+'? ') then begin
                                                        assign(tf,adrv(systat^.semaphorepath)+'TERMUSER.'+cstrnfile(cn));
                                                        {$I-} rewrite(tf); {$I+}
                                                        if (ioresult<>0) then begin
                                                                displaybox('Error writing termuser semaphore',2000);
                                                        end else close(tf);
                                                  end;
                                        end;
                                        dn:=TRUE;
                                    end;
                                #27:dn:=TRUE;
                        end;
                until (dn);
                removewindow(ww);
        end else begin
                displaybox('Node not active',2000);
        end;
end else begin
        displaybox('Node not active',2000);
end;
end;

procedure wfcmenu2;
var  wfcFile : file;
     wfcif   : text;
     cnn     : integer;
     ss      : string;

begin
   window(1,1,80,25);
   cursoron(FALSE);
   wantout:=TRUE;
   assign(wfcFile,systat^.gFilePath+'nexus2.bin');
   {$I-} reset(wfcFile,1); {$I+}
   if (ioresult<>0) then begin
        displaybox('Error reading '+adrv(systat^.gFilePath)+'NEXUS2.BIN',2000);
        hangup2:=TRUE;
        exit;
   end;
   if (filesize(wfcfile)<4000) then begin
        displaybox(adrv(systat^.gFilePath)+'NEXUS2.BIN is an invalid size!',2000);
        hangup2:=TRUE;
        exit;
   end;
   blockRead(wfcFile,mem[$B800:0],4000);
   close(wfcFile);
   assign(wfcif,adrv(systat^.gFilePath)+'NEXUS2.SCI');
   {$I-} reset(wfcif); {$I+}
   if (ioresult<>0) then begin
        displaybox('Error reading '+adrv(systat^.gFilePath)+'NEXUS2.SCI',2000);
        hangup2:=TRUE;
        exit;
   end;
   readln(wfcif,standard);
   for cnn:=0 to 9 do begin
         whosonline(topnode+cnn);
         gotoxy(value(ew(standard,1)),value(ew(standard,2))+cnn);
         sprompt(ew(standard,3));
   end;
   readln(wfcif,highlight);
   readln(wfcif,ss);
   mx1:=value(ew(ss,1));
   my1:=value(ew(ss,2));
   mz1:=value(ew(ss,3));
   mc1:=value(ew(ss,4));
   if (ew(ss,4)='') then mc1:=7;
   mb1:=value(ew(ss,5));
   if (ew(ss,5)='') then mb1:=0;
   readln(wfcif,ss);
   mx2:=value(ew(ss,1));
   my2:=value(ew(ss,2));
   mz2:=value(ew(ss,3));
   mc2:=value(ew(ss,4));
   if (ew(ss,4)='') then mc2:=7;
   mb2:=value(ew(ss,5));
   if (ew(ss,5)='') then mb2:=0;
   while not(eof(wfcif)) do begin
        readln(wfcif,ss);
        gotoxy(value(ew(ss,1)),value(ew(ss,2)));
        sprompt(ew(ss,3));
   end;
   close(wfcif);
   whosonline(curnode);
   gotoxy(value(ew(highlight,1)),value(ew(highlight,2))+(curnode-topnode));
   sprompt(ew(highlight,3));
   if (lastmodact <> '') then showmodemact(lastmodact);
   if (lastmodstring <> '') then showmodemresp(lastmodstring);
end;

procedure wfcmenu1;
begin
noshowmci:=FALSE;
noshowpipe:=FALSE;
case curscreen of
        1:wfcmenuorig;
        2:wfcmenu2;
end;
getdatetime(dt2);
getdatetime(dt22);
end;

(* procedure wfcmenus(wanthangup:boolean);
var u:userrec;
    lcallf:file of lcallers;
    lcall:lcallers;
    s:astr;
    i,j,k:integer;
    c,c1:char;
    chkcom:boolean;
    sysopfo:boolean;



begin
  textcolor(7);
  textbackground(0);
  if (wanthangup) then begin
    hangupphone;
    wanthangup:=FALSE;
  end;
  wfcmdefine;

  elevel:=exitnormal;
  if (localioonly) then spd:='KB';
  iport;
  if (not(com_installed)) and not(localioonly) then begin
        sl1('!','Error Opening Communications!');
        writeln('! ',time,' NEXUS    Error Opening Communications!');
        hangup2:=TRUE;
        elevel:=exiterrors;
  end else begin
        if not(localioonly) then begin
        s:=FossilID;
        if (s='') then s:='Unknown';
        sl1('i',s);
        end;
  end;
  if (hangup) then begin
        sl1('!','Carrier lost!');
        exit;
  end;

  term_ready(TRUE);
  
  repeat
    if (daynum(datelong)<>ldate) then
      if (daynum(datelong)-ldate)=1 then inc(ldate)
      else begin
	clrscr;
	writeln('Date corrupted.');
	halt(1);
      end;
    randomize; incom:=FALSE; outcom:=FALSE;
    hangup2:=FALSE; hungup:=FALSE; irt:=''; cfo:=FALSE;
    c:=#0; chkcom:=FALSE; freetime:=0.0; extratime:=0.0; choptime:=0.0;
    sdc; lil:=0; cursoron(FALSE);

    tc(3);
    
    c:=' ';  
    if (answerbaud>2) then begin
      c:='A';
      chkcom:=FALSE;
    end;
    timeslice;
    if (c<>' ') then c:=#0;
    if (not com_rx_empty) then chkcom:=TRUE;
    displaybox('TEST',2000);
    if (((c<>#0) or (not com_rx_empty) or (chkcom)) and (answerbaud=0)) then begin
      spdarq:=FALSE;
      displaybox('TEST2',2000);
      if (not localioonly) then begin
        displaybox('TEST3',2000);
	getcallera(c1,chkcom);
	if (not incom) and ((spd='KB') and (c<>' ')) then begin
	  if (quitafterdone) then begin
            hangup2:=TRUE;
	    doneday:=TRUE;
	  end;
	end;
      end;
    end;
  until ((incom) or (c=' ') or (doneday));

  etoday:=0; ptoday:=0; ftoday:=0; chatt:=0; shutupchatcall:=FALSE;
  badfpath:=FALSE;

  if (not doneday) then begin
    window(1,1,80,25);
    textbackground(0);
    clrscr;
  end;
  curco:=7; sdc;
  if (incom) then begin
    com_flush_rx; term_ready(TRUE);
    outcom:=TRUE;
  end else begin
    term_ready(FALSE);
    incom:=FALSE; outcom:=FALSE;
  end;
  getdatetime(timeon); ftoday:=0;
  com_flush_rx;
  lil:=0;
  thisuser.ac:=thisuser.ac-[ansi,rip];
  curco:=$07;
  checkit:=TRUE; beepend:=FALSE;

  
  if (wantout) then cursoron(TRUE);

  savesystat;
end; *)

procedure wfcmenus(wanthangup:boolean);
var u:userrec;
    times:integer;
    ltime,
    s,
    wfcmessage,owfc:astr;
    rr,
    rl,
    rl1,
    rl2,
    rl3,
    lastinit:real;
    i,
    j,
    k,
    sk,
    rcode:integer;
    f:file;
    c,
    c1,
    c2:char;
    nogoodcmd,
    wfcm,
    phoneoffhook,
    chkcom,
    tdoneafternext,
    oldphoneoffhook,
    checkupper,sysopfo,kp:boolean;

   procedure i1;
   var s:astr;
       rl,
       rl1:real;
       tryc:integer;
       c,
       isc:char;
       mdm:string;
       done:boolean;
       tt:integer;
       tries : byte;
   begin
      if ((modemr^.init1<>'') and (answerbaud=0) and (not localioonly)) then begin
         if (not keypressed) then begin
            showmodemact('Initializing modem');
            c:=#0; s:='';
            done:=FALSE;
            rl:=timer;
            while (keypressed) do c:=upCase(readkey);
               com_set_speed(modemr^.waitbaud);
               for tt:=1 to 3 do begin
               tries := 0;
               if (((modemr^.init2<>'') and (tt=2)) or ((modemr^.init3<>'') and (tt=3)) or (tt=1)) then
               repeat
               inc(tries);
               case tt of
                1:outmodemstring(modemr^.init1);
                2:outmodemstring(modemr^.init2);
                3:outmodemstring(modemr^.init3);
               end;
{              com_flush_rx; }
               rl1:=timer;
               mdm:='';
               repeat
                  if (recom1(c)) then begin
                     c:=upcase(c);
                     if (c=#10) or (c=#13) then begin
                             if (pos(modemr^.rspok,mdm)<>0) then done:=TRUE;
                             if not(done) then begin
                                       showmodemresp(mdm);
                                       mdm:='';
                             end;
                     end else begin
                             mdm:=mdm+c;
                     end;
                  end;
               until ((abs(timer-rl1)>2.5) or (done)) or (keypressed);
               showmodemresp(mdm);
               if (done) then delay(100);
               if (tries = 3) then done := true;
               until ((done) or (keypressed));
               end;
         end;
         while (keypressed) do isc:=readkey;
         com_flush_rx;
         rl1:=timer;
         repeat
            c:=cinkey
         until (abs(timer-rl1)>0.1);
      end;
      phoneoffhook:=FALSE;
      wfcmessage:='';
      lastinit:=timer;
      while (keypressed) do c:=readkey;
      com_flush_rx;
   end;

   procedure getokay;
   var mdo:string;
       cc:char;
       dn:boolean;
       rl2:real;
   begin
               rl2:=timer;
               mdo:='';
               dn:=FALSE;
               repeat
                  if (recom1(cc)) then begin
                     cc:=upcase(cc);
                     if (cc=#10) or (cc=#13) then begin
                             if (pos(modemr^.rspok,mdo)<>0) then dn:=TRUE;
                             if not(dn) then begin
                                       showmodemresp(mdo);
                                       mdo:='';
                             end;
                     end else begin
                             mdo:=mdo+cc;
                     end;
                  end;
               until ((abs(timer-rl2)>2.5) or (dn)) or (keypressed);
               showmodemresp(mdo);
               com_flush_rx;
               if (dn) then delay(100);
   end;

   procedure takeoffhook;
   begin
      if (not localioonly) then begin
         showmodemact('Taking off hook');
         dophoneoffhook(TRUE);
         phoneoffhook:=TRUE;
         getokay;
         showmodemact('Phone off hook');
      end;
   end;

   procedure putonhook;
   begin
      if (not localioonly) then begin
         showmodemact('Putting on hook');
         dophoneonhook(TRUE);
         phoneoffhook:=FALSE;
         wfcmessage:='';
         getokay;
      end;
   end;

  procedure beephim;
  var rl,
      rl1 : real;
      ch:char;
  begin
    takeoffhook;
    rl:=timer;
    repeat
      sound(1500); delay(20);
      sound(1000); delay(20);
      sound(800); delay(20);
      nosound;
      rl1:=timer;
      while (abs(rl1-timer)<0.9) and (not keypressed) do;
    until (abs(rl-timer)>30.0) or (keypressed);
    if keypressed then ch:=readkey;
    i1;
  end;

{  procedure packallbases;
  var b:boolean;
  begin
    cls;
    b:=(pause in thisuser.ac);
    thisuser.ac:=thisuser.ac-[pause];
    doshowpackbases;
    if (b) then thisuser.ac:=thisuser.ac+[pause];
    cls;
    wfcm:=FALSE;
    sysoplog('Packed the message bases');
  end;
  }

  (* procedure chkevents;
  var i,rcode:integer;
  begin
    if (checkevents(0)<>0) then
      for i:=0 to numevents do begin
        if (checkpreeventtime(i,0)) then
          if (not phoneoffhook) then begin
            takeoffhook;
            wfcmessage:='Phone off hook in preparation for event at '+
                        copy(ctim(events[i]^.exectime),4,5)+':00';
          end;
        if (checkeventtime(i,0)) then
          with events[i]^ do begin
            i1;
            if (busyduring) then takeoffhook;
            cls; write('- '+copy(ctim(exectime),4,5)+':00 - Event: ');
            writeln('"'+description+'"');
            sl1('');
            sl1('[> Ran Event "'+description+'" on '+date+' '+time);
            case etype of
              'D':begin
                    sysopfo:=(textrec(sysopf).mode<>fmclosed);
                    if (sysopfo) then close(sysopf);

                    shelldos(FALSE,execdata,rcode);
                    cursoron(FALSE);
                    if (sysopfo) then append(sysopf);
                    sl1('[> Returned from "'+description+'" on '+date+' '+time);
                    cls;
{                    cdelay(1000);}
                    outmodemstring1(modemr^.hangup);
{                    cdelay(300);}
                    i1;
                    wfcm:=FALSE;
                  end;
              'E':begin

                    doneday:=TRUE;
                    elevel:=value(execdata);
                  end;
              'P':begin
                    packallbases;
                    i1;
                  end;
            end;
          end;
      end;
  end; *)

  procedure closemenu;
  begin
    {if (systat^.localscreensec) then wantout:=FALSE;}
    sysopon:=FALSE; sk:=0;
    owfc:='';
    wfcm:=FALSE;
  end;

{type typeListItems = array[1..20] of string[21]; }
Var
{  list : ^typeListItems; }
  Cont,
  NumItems,
  pos,
  first,
  cur:byte;
  MenuC:Char;
  Pause:Boolean;

{ Procedure InitItems;
begin
  new(list);
  List^[1 ] := '    System Setup    ';
  List^[2 ] := '    Answer Phone    ';
  List^[3 ] := '     Dos Shell      ';
  List^[4 ] := '    Local Login     ';
  List^[5 ] := '    Menu Editor     ';
  List^[6 ] := '    System Info     ';
  List^[7 ] := '     Read Email     ';
  List^[8 ] := '   Read User Mail   ';
  List^[9 ] := '    Write Email     ';
  List^[10] := '    User Editor     ';
  List^[11] := '   Exec TERM.BAT    ';
  List^[12] := '   Message Bases    ';
  List^[13] := '     File Bases     ';
  List^[14] := '   Pack Messages    ';
  List^[15] := '      Off-Hook      ';
  List^[16] := '    Hangup Modem    ';
  List^[17] := '     Protocols      ';
  List^[18] := '   Sysop Loggings   ';
  List^[19] := ' Conference Editor  ';
  List^[20] := '    Quit Impulse    ';
  NumItems := 20;
end; }

procedure runoption(item : byte);
var cnfc : char;
begin
 if item in [1..21] then begin
      cursoron(true);
      case item of
{        1  : pullconfig; }
         1  : begin
              i1;
              end;
         2  : chkcom:=TRUE;
         3  : begin
              takeoffhook;
              SysopShell(FALSE);
              chdir(start_dir);
              putonhook;
              wfcmenu1;
              i1;
              end;
         4  : begin
            oldphoneoffhook:=phoneoffhook;
            {if (status^.offhooklocallogon) then }
            takeoffhook;
            window(1,1,80,25);
            gotoxy(1,25);
            sprompt('%070%Log on? %080%(%150%Y%070%es%080%/%150%N%070%o%080%/%150%F%070%ast%080%) ');
            rl2:=timer;
            while (not keypressed) and (abs(timer-rl2)<30.0) do timeSlice;
            if (keypressed) then c:=upCase(readkey);
            case c of
               'F':begin
                  fastlogon:=TRUE;
                  c:=' ';
               end;
               'Y': begin
                    c:=' ';
                    end;
               else c:='@';
            end;
            if (c='@') then begin
               window(1,1,80,25);
               gotoxy(1,25);
               clreol;
               if ({(status^.offhooklocallogon) and }(not oldphoneoffhook)) then putonhook;
               nogoodcmd:=TRUE;
            end;
         end;
{         5  : menu_edit;
         6  : begin
            cls;
            printf('sysinfo');
            pauseScr;
         end;
         7  : begin
            cls;
            mailr;
         end;
         8  :begin
            cls;
            reset(uf);
            seek(uf,1);
            write(uf,thisuser);
            close(uf);
            write('Read which user''s mail? ');
            finduser(s,i);
            writeln;
            if (i<1) then pausescr
            else begin
               usernum:=i;
               reset(uf);
               seek(uf,i);
               read(uf,thisuser);
               close(uf);
               readinzscan;
               if (thisuser.waiting<>0) then begin
                  cls;
                  macok:=TRUE;
                  readmail;
                  macok:=FALSE;
                  reset(uf);
                  seek(uf,i);
                  write(uf,thisuser);
                  close(uf);
               end else begin
                  writeln('You have no mail waiting.');
                  writeln;
                  pausescr;
               end;
               usernum:=1;
               reset(uf);
               seek(uf,1);
               read(uf,thisuser);
               close(uf);
               readinzscan;
            end;
         end;
         9  :begin
            cls;
            reset(uf);
            seek(uf,1);
            write(uf,thisuser);
            close(uf);
            write('Which user is sending mail? ');
            finduser(s,i);
            writeln;
            if (i<1) then pausescr
            else begin
               usernum:=i;
               reset(uf);
               seek(uf,i);
               read(uf,thisuser);
               close(uf);
               readinzscan;
               macok:=TRUE;
               smail(pynq('Send mass mail? ',false));
               macok:=FALSE;
               nl;
               pausescr;
               usernum:=1;
               reset(uf);
               seek(uf,1);
               read(uf,thisuser);
               close(uf);
               readinzscan;
            end;
         end;
         10 : pulledit; }
         10 :begin
            takeoffhook;
            sl1('d','Starting nxSETUP');
            currentswap:=modemr^.swaplocalshell;
            shelldos(FALSE,adrv(systat^.utilpath)+'\NXSETUP.EXE /Z',rcode);
            currentswap:=0;
            sl1('d','Returned from nxSETUP');
            chdir(start_dir);
            putonhook;
            wfcmenu1;
            i1;
         end;
         11 :if (exist(adrv(start_dir)+'\TERM.BAT')) then begin
            window(1,1,80,25);
            clrscr;
            textcolor(14);
            writeln('Running TERM.BAT ....');
            sl1('d','Ran terminal program');
            currentswap:=modemr^.swaplocalshell;
            shelldos(FALSE,adrv(start_dir)+'\TERM.BAT',rcode);
            currentswap:=0;
            sl1('d','Returned from "TERM.BAT"');
            chdir(start_dir);
            wfcmenu1;
            i1;
         end;
         12 :begin
            takeoffhook;
            sl1('d','Starting nxED');
            currentswap:=modemr^.swaplocalshell;
            shelldos(FALSE,adrv(systat^.utilpath)+'\NXED.EXE',rcode);
            currentswap:=0;
            sl1('d','Returned from nxED');
            chdir(start_dir);
            putonhook;
            wfcmenu1;
            i1;
         end;
{         12 : boardedit;
         13 : dlboardedit;
         14 : begin
            cls;
            if (pynq('Do you REALLY want to pack the message bases? ',true)) then doshowpackbases;
         end; }
         15 : begin
            if (not phoneoffhook) then takeoffhook
            else putonhook;
            nogoodcmd:=TRUE;
         end;
         16 : begin
            putonhook;
            nogoodcmd:=TRUE;
         end;
{         17 : exproedit;
         18 : begin
            cls;
            showlogs;
            nl;
            pausescr;
         end; 
         19 : begin
            cls;
            sprompt('|U1Edit Message or File Conf? |U9[|U0M/F|U9]:|U3 ');
            onek(cnfc,'MFQ'^M);
            case cnfc of
               'M':if (cso) then editconf(0);
               'F':if (cso) then editconf(1);
            end;
         end; }
         20 : begin
            elevel:=exitnormal;
            hangup2:=TRUE;
            doneday:=TRUE;
         end;
         21 :begin
            takeoffhook;
            currentswap:=modemr^.swaplocalshell;
            shelldos(FALSE,adrv(systat^.utilpath)+'\UTHEME.EXE *'+adrv(systat^.gfilepath)+'\THEMES\ '+
            adrv(systat^.gfilepath)+' SILENT',rcode);
            currentswap:=0;
            chdir(start_dir);
            putonhook;
            wfcmenu1;
            i1;
         end;
      end;
      wfcmenu1;
   end;
end;

procedure erasesema;
var ff:file;
begin
assign(ff,adrv(systat^.semaphorepath)+'SHUTDOWN.'+cstrnfile(cnode));
{$I-} erase(ff); {$I+}
if (ioresult<>0) then begin
        displaybox('Error erasing shutdown semaphore',2000);
end;
end;

begin
   CursorOn(False);
   inwfcmenu:=TRUE;
   with online do begin
                Name:='Available Node';
                real:='Available Node';
                nickname:='';
                number:=0;
                status:=0;
                available:=false;
                business:='';
                activity:='Waiting For Caller';
                baud:=0;
                comport:=0;
                lockbaud:=0;
                emulation:=1;
   end;
   updateonline;
   createwaitingsema;
   if (not systat^.localsec) then sysopon:=TRUE;
   getdatetime(lastkeypress);
   blankmenunow:=FALSE;
   {wantout:=not systat^.localscreensec;}
   sk:=0;
   nogoodcmd:=FALSE;
   if (wanthangup) then begin
      dophonehangup(TRUE);
      wanthangup:=FALSE;
   end;
   if (localioonly) then spd:='KB';
   wfcmdefine;
   wfcmenu1;
   wfcm:=TRUE;
   iport;

  if (not(com_installed)) and not(localioonly) then begin
        sl1('!','Error Opening Communications!');
        writeln('! ',time,' NEXUS    Error Opening Communications!');
        hangup2:=TRUE;
        elevel:=exiterrors;
  end else begin
        if not(localioonly) then begin
        s:=FossilID;
        if (s='') then s:='Unknown';
        sl1('i','Fossil: '+s);
        end;
  end;
  if (hangup) then begin
        sl1('!','Connection terminated!');
        exit;
  end;


   term_ready(TRUE);
   i1;
   tdoneafternext:=doneafternext;
   if (not systat^.localsec) then sysopon:=TRUE;
   times:=0;

   First := 1;
   Pos   := 1;

   cursoron(false);
   checkupper:=FALSE;
   sl1('w','Waiting for caller');
   getdatetime(dt2);
   getdatetime(dt22);
   kp:=TRUE;
   repeat
      if not(sysopon) then wfcmessage:='SYSTEM LOCKED - [SPACE] to unlock';
      inc(times);
      if (tdoneafternext) then wfcmessage:='Not answering any more calls.';
      if (not wfcm) then wfcm:=TRUE;
      if (daynum(datelong)<>ldate) then
      if (daynum(datelong)-ldate)=1 then inc(ldate)
      else begin
	clrscr;
	writeln('Date corrupted.');
	halt(1);
      end;
         randomize;
         incom:=FALSE;
         outcom:=FALSE;
         hangup2:=FALSE;
         hungup:=FALSE;
         {lastname:='';
         macok:=TRUE;}
         cfo:=FALSE;
         c:=#0;
         chkcom:=FALSE;
         freetime:=0.0;
         extratime:=0.0;
         choptime:=0.0;
         {bread:=0;}
         lil:=0;
         cursoron(FALSE);
         textattr := 7;
         sdc;
         if ((not blankmenunow){ and (systat^.wfcblanktime>0)}) then begin
            getdatetime(dt);
            timediff(ddt,lastkeypress,dt);
            if (ddt.min>=10{systat^.wfcblanktime}) then begin
               blankmenunow:=TRUE;
               window(1,1,80,25);
               clrscr;
            end;
         end;
         if (ltime<>time) then begin
            ltime:=time;
            inc(sk);
            if (timer-lastinit>30*60) then begin
               lastinit:=timer;
               if (not phoneoffhook) then i1;
            end;
         end;
         rr:=timer;
         if (rr-lactive<0.0) then rr:=rr+(24.0*60*60);
         rr:=rr-lactive;
         getdatetime(ddt3);
         timediff(ddt2,dt2,ddt3);
         rl3:=dt2r(ddt2);
         if (rl3>=5) then begin
                if (exist(adrv(systat^.semaphorepath)+'SHUTDOWN.'+cstrnfile(cnode))) then begin
                        displaybox2(ww,'Shutdown requested...');
                        sl1('!','SHUTDOWN requested via semaphore');
                        erasesema;
                        hangup2:=TRUE;
                        doneday:=TRUE;
                        removewindow(ww);
                end;
                if (exist(adrv(systat^.semaphorepath)+'READLANG.'+cstrnfile(cnode))) then begin
                     displaybox2(ww,'Reloading current language...');
                     sl1('!','Reload of language requested by READLANG semaphore');
                     getlang(clanguage);
                     menufname:=allcaps(langr.menuname);
                     if (menufname='') then menufname:='ENGLISH';
                     sl1('!','Reload of language complete');
                     assign(f,adrv(systat^.semaphorepath)+'READLANG.'+cstrnfile(cnode));
                     {$I-} erase(f); {$I-}
                     if ioresult<>0 then begin end;
                     removewindow(ww);
                     wfcmenu1;
                end;
                if (exist(adrv(systat^.semaphorepath)+'MXUPDATE.'+cstrnfile(cnode))) then begin
                        displaybox2(ww,'Reloading system settings...');
                        filemode:=66;
                        {$I-} reset(systatf); {$I-}
                        if ioresult<>0 then sl1('!','Error Re-reading MATRIX.DAT - MXUPDATE.xxx')
                        else begin
                              sl1('!','MATRIX.DAT update requested via semaphore');
                              read(systatf,systat^);
                              close(systatf);
                              assign(f,adrv(systat^.semaphorepath)+'MXUPDATE.'+cstrnfile(cnode));
                              {$I-} erase(f); {$I-}
                              if ioresult<>0 then begin end;
                        end;
                        removewindow(ww);
                        wfcmenu1;
                end;
                if (exist(adrv(systat^.semaphorepath)+'READSYS.'+cstrnfile(cnode))) then begin
                      displaybox2(ww,'Reloading system settings...');
                      assign(systemf,adrv(systat^.gfilepath)+'SYSTEM.DAT');
                      filemode:=66;
                      {$I-} reset(systemf); {$I+}
                      if (ioresult<>0) then begin
                            sl1('!','Error Re-reading SYSTEM.DAT - READSYS.xxx');
                            displaybox('Error opening SYSTEM.DAT... exiting.',3000);
                            halt(exiterrors);
                      end;
                      sl1('!','SYSTEM.DAT reload requested via semaphore');
                      read(systemf,syst);
                      close(systemf);
                      assign(f,adrv(systat^.semaphorepath)+'READSYS.'+cstrnfile(cnode));
                      {$I-} erase(f); {$I-}
                      if ioresult<>0 then begin end;
                      removewindow(ww);
                      wfcmenu1;
                end;
                getdatetime(dt2);
         end;
         getdatetime(ddt3);
         timediff(ddt2,dt22,ddt3);
         rl3:=dt2r(ddt2);
         if ((curscreen=2) and (rl3>=refreshtime)) then begin
                wfcmenu1;
                refreshtime:=90;
                getdatetime(dt22);
         end;
         if (sysopon) then
            if (sk=30) and (systat^.localsec) then closemenu;
{         if (nightly) or (numevents>=1) then chkevents; }
         if ((wfcmessage<>'') and (wfcmessage<>owfc)) or (kp) then begin
                window(1,1,80,25);
                gotoxy(1,25);
                clreol;
                sprompt('%080%þ %120%'+wfcmessage+'%070%');
                owfc:=wfcmessage;
         end;
         if (tdoneafternext) then begin
            takeoffhook;
            elevel:=exitnormal;
            hangup2:=TRUE;
            doneday:=TRUE;
            clrscr;
         end;

         if not(blankmenunow) then begin
{            For Cont := First To First + 3 do begin
               If (Cont - First + 1 = Pos) Then textattr:= wfc.h
               else textattr := wfc.n;
               GotoXY(wfc.x, wfc.y + Cont-First);
               if textattr=wfc.n then write(' '+List^[Cont]+' ')
               else write(' '+List^[Cont]+' ')
            end; }
         end;
         {while not(keyPressed) do } timeSlice;
         kp:=FALSE;
         if (keypressed) then begin
            if (blankmenunow) then begin
               blankmenunow:=FALSE;
               window(1,1,80,25);
               wfcmenu1;
               getdatetime(lastkeypress);
               menuc := readkey;
               c := #0;
               kp:=TRUE;
            end else begin
                    menuc := readKey;
                    c := upCase(menuC);
                    if (c=#0) then begin
                        c:=readkey;
                        checkupper:=TRUE;
                    end;
                    kp:=TRUE;
            end;
         end;

         if (c<>#0) then begin
            wfcm:=FALSE;
            window(1,1,80,25);
            gotoxy(1,25);
            clreol;
            textColor(7);
            if (not sysopon) and (not chkcom) then begin
               if (checkupper) then begin
                        case c of
                        #104:begin
                                curscreen:=1;
                             end;
                        #105:begin
                                curscreen:=2;
                             end;
                        else nogoodcmd:=TRUE;
                        end;
                  c:='#';
                  checkupper:=FALSE;
               end else begin
               case c of
                  'Q': runOption(20);
                  'L',' ':begin
                     sysopon:=checkPw;
                     if (sysopon) then begin
                        wantout:=TRUE;
                        wfcmessage:='';
                     end;
                     c:=#2;
                  end;
                  else nogoodcmd:=TRUE;
               end;
               end;
               if (not nogoodcmd) then getdatetime(lastkeypress);
            end else begin
               sk:=0;
               {cl(1);
               if (c<>#0) then CursorOn(True); }
               if (checkupper) then begin
                case c of
                        #20:begin
                                runoption(21);
                            end;
                        #72:if (curscreen=2) then begin
                                whosonline(curnode);
                                gotoxy(value(ew(standard,1)),value(ew(standard,2))+(curnode-topnode));
                                sprompt(ew(standard,3));
                                dec(curnode);
                                if (curnode<topnode) then curnode:=topnode;
                                whosonline(curnode);
                                gotoxy(value(ew(highlight,1)),value(ew(highlight,2))+(curnode-topnode));
                                sprompt(ew(highlight,3));
                                c:=#1;
                            end else c:=#1;
                        #73:if (curscreen=2) then begin
                                if (topnode>1) then begin
                                        topnode:=topnode-10;
                                        curnode:=curnode-10;
                                end else c:=#1;
                            end else c:=#1;
                        #80:if (curscreen=2) then begin
                                whosonline(curnode);
                                gotoxy(value(ew(standard,1)),value(ew(standard,2))+(curnode-topnode));
                                sprompt(ew(standard,3));
                                inc(curnode);
                                if (curnode>topnode+9) then curnode:=topnode+9;
                                whosonline(curnode);
                                gotoxy(value(ew(highlight,1)),value(ew(highlight,2))+(curnode-topnode));
                                sprompt(ew(highlight,3));
                                c:=#1;
                            end else c:=#1;
                        #81:if (curscreen=2) then begin
                                        if (topnode<991) then begin
                                                topnode:=topnode+10;
                                                curnode:=curnode+10;;
                                        end else c:=#1;
                            end else c:=#1;
                        #104:begin
                                curscreen:=1;
                             end;
                        #105:begin
                                curscreen:=2;
                             end;
                        else nogoodcmd:=TRUE;
                end;
                if (c<>#1) then c:='#';
                checkupper:=FALSE;
               end else begin
               case curscreen of
                        1:begin
                               case c of
                                  'A' : runoption(2);
                                  'D':runOption(3);
                                  'H','+': runOption(16);
                                  'I' : runoption(1);
                                  'L',' ':runOption(4);
                                  'M':runOption(12);
                                  'O':runOption(15);
                                  'Q': runOption(20);
                                  'S':runOption(10);
                                  'T':runoption(11);
                                  'Z':typeofstats;

                                  {'B': if checkPw then runOption(12);
                                  'C','/':begin
                                             clrscr;
                                             printfile(systat^.gfilepath+'user.log');
                                             pausescr;
                                          end;
                                  'U':if checkPw then runOption(10);
                                  'W':if checkPw then runOption(9); 
                                  '#':if checkPw then runOption(5);
                                  'E':if checkPw then runOption(17);
                                  'F':if checkPw then runOption(13);
                                  'P':runOption(14);
                                  'X':runOption(18);
                                  'M':if checkPw then runOption(7); 
                                  'R':if checkPw then runOption(8); }

                                  else nogoodcmd:=TRUE;
                               end;
                               getdatetime(lastkeypress);
                        end;
                      2:begin
                               case c of
                                  'A' : runoption(2);
                                  'D':runOption(3);
                                  'H','+': runOption(16);
                                  'I' : runoption(1);
                                  'L',' ':runOption(4);
                                  'O':runOption(15);
                                  'Q': runOption(20);
                                  'S':runOption(10);
                                  'T':runoption(11);
                                  'Z':typeofstats;
                                  #13:begin
                                        handlenode(curnode);
                                        c:='#';
                                        refreshtime:=10;
                                      end;
                                  else nogoodcmd:=TRUE;
                               end;
                               getdatetime(lastkeypress);
                        end;
                      end;
               end;
               if (not nogoodcmd) then getdatetime(lastkeypress);
            end;
            if (not nogoodcmd) then begin
               if (c<>'A') and (c<>#1) then begin
                  curco:=7;
{                  window(1,1,80,25);
                  cls; }
                  com_flush_rx;
               end;
               if (c=#2) then c:='Z';
               if ((sysopon) and (c<>#1)) then lactive:=timer;
            end else begin
               nogoodcmd:=FALSE;
               wfcm:=TRUE;
               c:=#0;
            end;
         end;
         if (fastlogon) and (c<>' ') then c:=' ';
         if not(usewfcmenu) and (c<>' ') then c:=' ';
         if (c in ['A'..'Z','+','/','@','#',' ']) then begin
                wfcmenu1;
         end;
         CursorOn(False);
         if (c<>' ') then c:=#0;
         if (lastmodact<>'Waiting for connection') and not(phoneoffhook) then begin
                showmodemact('Waiting for connection');
         end;
         if (answerbaud>2) then  begin
            c:='A';
            chkcom:=FALSE;
            incom:=TRUE;
         end else
         if (not com_rx_empty) then chkcom:=TRUE;
         if ((c<>#0) or (not com_rx_empty) or (chkcom)) then begin
            if ((not phoneoffhook) and (not localioonly)) then begin
               getcallera(c1,chkcom);
               if (not incom) and ((spd='KB') and (c<>' ')) then begin
                  wfcm:=FALSE;
                  i1;
                  if (quitafterdone) then begin
                     elevel:=exitnormal;
                     hangup2:=TRUE;
                     doneday:=TRUE;
                  end;
               end;
            end;
         end;
   until ((incom) or (c=' ') or (doneday));
   etoday:=0;
   ptoday:=0;
   ftoday:=0;
   chatt:=0;
   shutupchatcall:=FALSE;
   {contlist:=FALSE;}
   badfpath:=FALSE;
{   dispose(list); }

   if (not doneday) then begin
      window(1,1,80,25);
      clrscr;
{      if (spd <> 'KB') then writeLn('['+spd+'] Baud - '); }
   end;

   if (incom) then begin
      com_flush_rx;
      term_ready(TRUE);
      outcom:=TRUE;
      com_set_speed(value(spd));
   end
   else begin
      term_ready(FALSE);
      incom:=FALSE;
      outcom:=FALSE;
      wfcm:=FALSE;
   end;
   getdatetime(timeon); ftoday:=0;
   com_flush_rx;
   lil:=0;

   inwfcmenu:=FALSE;
   {if (systat^.localscreensec) then wantout:=FALSE;}
   if (spd='KB') and (not wantout) then wantout:=TRUE;
   if (wantout) then CursorOn(True);
{   if ((spd <> 'KB') AND (spd <> 'TELNET')) then
      case (value(spd) div 100) of
         3 : inc(status.todayzlog.userbaud[0]);
         12 : inc(status^.todayzlog.userbaud[1]);
         24 : inc(status^.todayzlog.userbaud[2]);
         48 : inc(status^.todayzlog.userbaud[3]);
      else
      inc(status^.todayzlog.userbaud[4]); 
   end; }


  curco:=7; sdc;
  lil:=0;
  thisuser.ac:=thisuser.ac-[ansi];
  curco:=$07;
  checkit:=TRUE; beepend:=FALSE;



   savesystat;
   chatt:=0;
   killwaitingsema;
end;

end.
