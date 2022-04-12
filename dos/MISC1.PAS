{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
{                        Next Epoch matriX User System                       }
{                                                                            }
{                             Module: MISC1.PAS                              }
{                                                                            }
{                                                                            }
{ All Material Contained Herein Is Copyright 1995 Intuitive Vision Software. }
{                            All Rights Reserved.                            }
{                                                                            }
{                       Written By George A. Roberts IV                      }
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R-,S+,V-}
unit misc1;

interface

uses
  crt, dos, myio3, mail0,
  common;

procedure listnodes;
procedure pageuser;
procedure reqchat(x:astr);
procedure TimeBank(c:char;s:astr);
function ctp(t,b:longint):astr;
procedure SelectConference(c2:string;b:byte);
procedure cdsonline;

implementation

uses doors,execbat,mainmail;

Procedure SelectConference(c2:string;b:byte); {1:message 2:file }
var x,testloop:integer;
    done,left:boolean;
    c:char;
    oconf:byte;
    s:string;

begin
done:=FALSE;
if (c2='') then begin
repeat
left:=TRUE;
case b of
        1:begin
                oconf:=mconf;
                sprompt(gstring(350));
                sprompt(gstring(351));
                sprompt(gstring(352));
                sprompt(gstring(353));
                for x:=1 to 26 do begin
                if ((con^.msgconf[x].active) and not(con^.msgconf[x].hidden)
                and aacs(con^.msgconf[x].access)) then begin
                                mconf:=x;
                                if (left) then begin
                                        sprompt(gstring(343));
                                        left:=false;
                                end else begin
                                        sprompt(gstring(344));
                                        left:=TRUE;
                                end;
                end;
                end;
                sprompt(gstring(354));
                onek(c,gstring(355)+^M);
                mconf:=oconf;
          end;
        2:begin
                oconf:=fconf;
                sprompt(gstring(363));
                sprompt(gstring(364));
                sprompt(gstring(365));
                sprompt(gstring(366));
                for x:=1 to 26 do begin
                        if ((con^.fileconf[x].active) and 
                                not(con^.fileconf[x].hidden) and 
                                aacs(con^.fileconf[x].access)) then begin
                                fconf:=x;
                                if (left) then begin
                                        sprompt(gstring(345));
                                        left:=FALSE;
                                end else begin
                                        sprompt(gstring(346));
                                        left:=TRUE;
                                end;
                        end;
                        end;
          sprompt(gstring(361));
          onek(c,gstring(362)+^M);
          fconf:=oconf;
          end;
end;
if c=#13 then done:=TRUE;
if (c<>'?') and not(done) then begin
        x:=ord(c)-64;
        case b of
                1:begin
                        if ((con^.msgconf[x].active) and (aacs(con^.msgconf[x].access))) then begin
                                mconf:=x;
                                sprompt(gstring(356));
                                nl;
                                sprint('%150%Scanning for first available message base...');
                                if not(mbaseac(board)) then begin
                                testloop:=0;
                                repeat
                                while not(inmconf(testloop)) and not(hangup) do begin
                                        inc(testloop);
                                end;
                                while not(hangup) and (testloop<=numboards) and not(mbaseac(testloop)) do begin
                                        inc(testloop);
                                end;
                                if (testloop<0) or (testloop>numboards) then testloop:=0;
                                if (testloop<>board) then begin
                                         changeboard(testloop);
                                         if (board=testloop) then sprompt(gstring(357));
                                end;
                                until (board=testloop) or (hangup);
                                end;
                                done:=TRUE;
                        end else begin
                                sprompt(gstring(360));
                        end;
                  end;
                2:begin
                        if ((con^.fileconf[x].active) and (aacs(con^.fileconf[x].access))) then begin
                                fconf:=x;
                                sprompt(gstring(358));
                                if not(fbaseac(fileboard)) then begin
                                testloop:=0;
                                nl;
                                sprint('%150%Scanning for first available file base...');
                                repeat
                                while not(infconf(testloop)) and not(hangup) do begin
                                        inc(testloop);
                                end;
                                while (testloop<=maxulb) and not(hangup) and not(fbaseac(testloop)) do begin
                                        inc(testloop);
                                end;
                                if (testloop<0) or (testloop>maxulb) then testloop:=0;
                                if (testloop<>fileboard) then begin
                                         changefileboard(testloop);
                                         if (fileboard=testloop) then sprompt(gstring(359));
                                end;
                                until (fileboard=testloop) or (hangup);
                                end;
                                done:=TRUE;
                        end else begin
                                sprompt(gstring(360));
                        end;
                  end;
               end;
end;
until (done);
end else begin
        x:=ord(c2[1])-64;
        case b of
                1:begin
                        if ((con^.msgconf[x].active) and (aacs(con^.msgconf[x].access))) then begin
                                mconf:=x;
                                sprompt(gstring(356));
                                if not(mbaseac(board)) then begin
                                testloop:=0;
                                nl;
                                sprint('%150%Scanning for first available message base...');
                                repeat
                                while not(inmconf(testloop)) and not(hangup) do begin
                                        inc(testloop);
                                end;
                                while (testloop<=numboards) and not(hangup) and not(mbaseac(testloop)) do begin
                                        inc(testloop);
                                end;
                                if (testloop<0) or (testloop>numboards) then testloop:=0;
                                if (testloop<>board) then begin
                                         changeboard(testloop);
                                         if (board=testloop) then sprompt(gstring(357));
                                end;
                                until (board=testloop) or (hangup);
                                end;
                                done:=TRUE;
                        end else begin
                                sprompt(gstring(360));
                        end;
                  end;
                2:begin
                        if ((con^.fileconf[x].active) and (aacs(con^.fileconf[x].access))) then begin
                                fconf:=x;
                                sprompt(gstring(358));
                                if not(fbaseac(fileboard)) then begin
                                testloop:=0;
                                nl;
                                sprint('%150%Scanning for first available file base...');
                                repeat
                                while not(infconf(testloop)) and not(hangup) do begin
                                        inc(testloop);
                                end;
                                while (testloop<=maxulb) and not(hangup) and not(fbaseac(testloop)) do begin
                                        inc(testloop);
                                end;
                                if (testloop<0) or (testloop>maxulb) then testloop:=0;
                                if (testloop<>fileboard) then begin
                                         changefileboard(testloop);
                                         if (fileboard=testloop) then sprompt(gstring(359));
                                end;
                                until (fileboard=testloop) or (hangup);
                                end;
                                done:=TRUE;
                        end else begin
                                sprompt(gstring(360));
                        end;
                  end;
               end;
end;
end;


procedure listnodes;
type  avtype=array[1..1000] of boolean;
var     x,x2:integer;
        f:file;
        sr:searchrec;
        dstr:string;
        oline:onlinerec;
        avnodes:^avtype;
        olinef:file of onlinerec;
        s:string;


begin
sprompt(gstring(161));
sprompt(gstring(162));
sprompt(gstring(163));
dstr:=gstring(164);
oline:=online;
new(avnodes);
fillchar(avnodes^,sizeof(avnodes^),#0);
findfirst(adrv(systat^.semaphorepath)+'INUSE.*',anyfile,sr);
while (doserror=0) do begin
x:=value(copy(sr.name,pos('.',sr.name)+1,length(sr.name)-pos('.',sr.name)));
if (x=0) then x:=1000;
avnodes^[x]:=TRUE;
findnext(sr);
end;
findfirst(adrv(systat^.semaphorepath)+'WAITING.*',anyfile,sr);
while (doserror=0) do begin
x:=value(copy(sr.name,pos('.',sr.name)+1,length(sr.name)-pos('.',sr.name)));
if (x=0) then x:=1000;
avnodes^[x]:=TRUE;
findnext(sr);
end;
for x:=1 to 1000 do begin
if (avnodes^[x]) then begin
        nlnode:=x;
        assign(olinef,adrv(systat^.gfilepath)+'USER'+cstrn(x)+'.DAT');
        filemode:=66;
        {$I-} reset(olinef); {$I+}
        if ioresult=0 then begin
        seek(olinef,0);
        read(olinef,online);
        close(olinef);
        if (not(aacs(systat^.seeinvisible)) and (online.invisible)) then begin
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
        end;
        sprompt(dstr);
        end;
end;
end;
nlnode:=1;
dispose(avnodes);
online:=oline;
nl;
end;

procedure pageuser;
var s:string;
    i,i3:integer;
    f:file;
    oline:onlinerec;
    sr:searchrec;
    olinef:file of onlinerec;

    procedure writemessage(nn:integer; ss:string);
    var nmf:file of nodemsgrec;
        nm:nodemsgrec;
    begin
    assign(nmf,adrv(systat^.semaphorepath)+'NODEMSG.'+cstrnfile(nn));
    {$I-} reset(nmf); {$I+}
    if (ioresult<>0) then begin
        rewrite(nmf);
    end;
    seek(nmf,filesize(nmf));
    nm.message:=ss;
    nm.sentbynode:=cnode;
    nm.sentby:=caps(nam);
    write(nmf,nm);
    close(nmf);
    end;


begin
repeat
listnodes;
sprompt('%090%Page node number (%150%A%090%=All,%150%Q%090%=Quit) : %150%');
scaninput(s,'AQ'^M,TRUE);
i:=value(s);
if (s<>'Q') and (s<>'') and ((i>0) and (i<1000)) then begin
if (i=cnode) then begin
        nl;
        sprint('%120%That node is not available!');
        nl;
        pausescr;
end else begin
filemode:=66;
assign(f,adrv(systat^.semaphorepath)+'INUSE.'+cstrnfile(i));
{$I-} reset(f); {$I+}
if (ioresult<>0) then begin
        nl;
        sprint('%120%That node is not available!');
        nl;
        pausescr;
end else begin
        close(f);
        assign(olinef,adrv(systat^.gfilepath)+'USER'+cstrn(i)+'.DAT');
        filemode:=66;
        {$I-} reset(olinef); {$I+}
        if ioresult=0 then begin
        seek(olinef,0);
        read(olinef,oline);
        close(olinef);
        if (oline.available) then begin
                nl;
                sprint('%120%Reason for page?');
                sprompt(gstring(19));
                inputl(s,72);
                if (s<>'') then begin
                        writemessage(i,s);
                end else begin
                        sprint('%120%Aborted!');
                        exit;
                end;
        end else begin
                sprint('%120%That user is not available for paging!');
                exit;
        end;
end;
end;
end;
end;
if (s='A') then begin
nl;
sprint('%090%Message:');
sprompt(gstring(19));
inputl(s,72);
if (s='') then begin
        sprint('%120%Aborted!');
        exit;
end;
findfirst(adrv(systat^.semaphorepath)+'INUSE.*',anyfile,sr);
while (doserror=0) do begin
        i3:=value(copy(sr.name,pos('.',sr.name)+1,length(sr.name)-pos('.',sr.name)));
        if (i3<>cnode) then begin
        filemode:=66;
        assign(f,adrv(systat^.semaphorepath)+'INUSE.'+cstrnfile(i3));
        {$I-} reset(f); {$I+}
        if (ioresult=0) then begin
                close(f);
                assign(olinef,adrv(systat^.gfilepath)+'USER'+cstrn(i3)+'.DAT');
                filemode:=66;
                {$I-} reset(olinef); {$I+}
                if ioresult=0 then begin
                        seek(olinef,0);
                        read(olinef,oline);
                        close(olinef);
                        if (oline.available) then begin
                                lil:=0;
                                sprint('%090%Sending message to %150%Node '+cstr(i3)+'%090%...');
                                writemessage(i3,s);
                        end;
                end;
        end;
        end;
findnext(sr);
end;
end;
until (s='') or (s='Q');
nl;
end;


procedure reqchat(x:astr);
var wx,wy,wy2,ret,c,ii,i:integer;
    chatend,chatstart,tchatted:datetimerec;
    r:char;
    ufo,chatted:boolean;
    s,why,who:astr;
begin
  why:='';
  who:='';
  if (pos(';',x)<>0) then begin
   why:=copy(x,1,pos(';',x)-1);
   who:=copy(x,pos(';',x)+1,length(x));
  end else begin
   why:=x;
  end;
  if (why='') then why:='%090%Why would you like to chat with '+systat^.sysopname+'?';
  nl;
  if ((chatt<systat^.maxchat) or (systat^.maxchat=0) or (cso)) then begin
    sprint(why);
    chatted:=FALSE;

    prt('> '); mpl(70); inputl(s,70);

    if (s<>'') then begin
      inc(chatt);
      if ((not sysop) or (rchat in thisuser.ac)) then begin
        sl1('+','Chat Attempt: '+copy(s,1,50));
      end else begin
        sl1('+','Chat: '+copy(s,1,50));
        sprompt(gstring(14));
        ii:=0; c:=0;
        wx:=wherex;
        wy:=wherey;
        wy2:=wy;
        if (wy2<10) then wy2:=12 else wy2:=3;
        displaybox3(wy2,w,'SPACE to Enter Chat, ENTER to Turn Audio Off');
        window(1,1,80,24);
        gotoxy(wx,wy);
        repeat
          inc(ii);
          if (outcom) then sendcom1(^G);
          sprompt(gstring(15));
          wx:=wherex;
          wy:=wherey;
          if (outcom) then sendcom1(^G);
          if (shutupchatcall) then delay(1500)
          else
            for i:=1 to 5 do begin
              sound(500); delay(30); nosound; 
              sound(500); delay(30); nosound;
              delay(500); 
            end;
          nosound;
          if (keypressed) then begin
            r:=readkey;
            case r of
              #32:begin
                    removewindow(w);
                    window(1,1,80,24);
                    textattr:=curco;
                    gotoxy(wx,wy);
                    chatted:=TRUE; chatt:=0;
                    pap:=0;
                    if (systat^.useextchat) then begin
                        getdatetime(chatstart);
                        currentswap:=modemr^.swapchat;
                        dodoorfunc('0',FALSE);
                        currentswap:=0;
                        getdatetime(chatend);
                        timediff(tchatted,chatstart,chatend);

                        freetime:=freetime+dt2r(tchatted);
                        tleft;
                    end else if (okansi) then begin
                        splitscreen;
                        end else chat;
                  end;
               ^M:begin
                        removewindow(w);
                        window(1,1,80,24);
                        textattr:=curco;
                        gotoxy(wx,wy);
                        shutupchatcall:=TRUE;
               end;
            end;
          end;
        until ((chatted) or (ii=9) or (hangup));
        if not(chatted) and not(shutupchatcall) then begin
                removewindow(w);
                window(1,1,80,24);
                textattr:=curco;
                gotoxy(wx,wy);
        end;
      end;
      if (not chatted) then begin
        chatr:=s;
        nl;
        printf('nosysop');
        if (nofile) then begin
                nl;
                sprint('%150%'+systat^.sysopname+'%120% is not available for chat.');
                nl;
        end;
        if (who<>'') then begin
          if pynq('%120%Send message to %150%'+caps(who)+'%120%? %110%') then begin
          irt:='/Tried chatting on '+date+' '+time;
          cls;
          privuser:=caps(processmci(who));
          if (ppost(0)) then begin end;
          privuser:='';
        end;
        end;
      end else
        chatr:='';
      tleft;
    end;
  end else begin
    printf('goaway');
    irt:='/Tried Chat More Than '+cstr(systat^.maxchat)+' Times';
    sl1('!','Tried Chat More Than '+cstr(systat^.maxchat)+' Times.');
    if pynq('%120%Send Message To %150%'+caps(who)+'%120%? %110%') then begin
    cls;
    privuser:=caps(who);
    if (ppost(0)) then begin end;
    privuser:='';
    end;
  end;
end;

procedure TimeBank(c:char;s:astr);
var lng,maxpercall,maxperday,maxever:longint;
    zz:integer;
    tdone:boolean;
    dt:datetimerec;

  function cantdeposit:boolean;
  begin
    cantdeposit:=TRUE;
    if ((thisuser.timebankadd>=maxperday) and (maxperday<>0)) then exit;
    if ((thisuser.timebank>=maxever) and (maxever<>0)) then exit;
    cantdeposit:=FALSE;
  end;

begin
  tdone:=false;
  if (c='A') then begin
  maxperday:=security.AddTBDay;
  maxpercall:=security.AddTBCall;
  maxever:=security.maxintb;
  end else begin
  maxperday:=security.withtbday; maxever:=0;
  maxpercall:=security.withtbcall;
  end;
  if ((maxever<>0) and (thisuser.timebank>maxever)) then
    thisuser.timebank:=maxever;
  if ((choptime<>0.0) and (c='W')) then begin
    sprint('%120%You cannot withdraw time during this call.');
    tdone:=true;
    end;
  if ((cantdeposit) and (c='A')) then begin
    tdone:=true;
    if (thisuser.timebankadd>=maxperday) then
      sprint('%120%You cannot add any more time to your account today.');
    if (thisuser.timebank>=maxever) then
      sprint('%120%You cannot add any more time to your account.');
  end;
  if (c='A') then begin
        if (thisuser.timebankadd>=maxperday) then begin
                tdone:=TRUE;
                sprint('%120%You cannot add any more time to your account today.');
        end;
        if (thisuser.timebank>=maxever) then begin
                tdone:=TRUE;
                sprint('%120%You cannot add any more time to your account.');
        end;
  end;
  if (c='W') then begin
        if (thisuser.timebankwith>=maxperday) then begin
                tdone:=TRUE;
                sprint('%120%You cannot withdraw any more time today.');
        end;
  end;
  if (not tdone) then
  case c of
    'A':begin
          prt('Add How Many Minutes? '); inu(zz); lng:=zz;
          nl;
          if (not badini) then
            if (lng>0) then
              if (lng>trunc(nsl) div 60) then
                sprint('%120%You Only Have '+cstr(trunc(nsl) div 60)+' Left Online.')
              else
                if (lng+thisuser.timebankadd>maxperday) then
                  sprint('%120%You can only add '+cstr(maxperday)+' minutes per day.')
                else
                if (lng+tbaddcall>maxpercall) then
                        sprint('%120%You can only add '+cstr(maxpercall)+' minutes per call.')
                   else
                  if (lng+thisuser.timebank>maxever) and (maxever<>0) then
                    sprint('%120%Your account limit is '+cstr(maxever)+' minutes.')
                  else begin
                    inc(thisuser.timebankadd,lng);
                    inc(thisuser.timebank,lng);
                    dec(utimeleft,lng);
                    inc(tbaddcall,lng);
                    sl1('+','Deposited '+cstr(lng)+' Min In TimeBank.');
                  end;
              end;
          'W':begin
                prt('Withdraw How Many Minutes? '); inu(zz); lng:=zz;
                nl;
                if (not badini) then
                  if (lng>thisuser.timebank) then
                    sprint('%120%You only have '+cstr(thisuser.timebank)+' minutes in your account.')
                  else
                  if (lng>maxperday) then
                        sprint('%120%You may only withdraw '+cstr(maxperday)+' minutes per day.')
                     else
                   if (lng+tbwithcall>maxpercall) then
                        sprint('%120%You may only withdraw '+cstr(maxpercall)+' minutes per call.')
                      else
                    if (lng>0) then begin
                        getdatetime(dt);
                      if (lng*60>(exteventtime*60)-(trunc(dt2r(dt))-trunc(dt2r(timeon)))) and
                      (exteventtime<>0) then begin
                        sprint('%120%You cannot withdraw this much time because of an upcoming event.');
                      end else begin
                      dec(thisuser.timebankadd,lng);
                      if (thisuser.timebankadd<0) then thisuser.timebankadd:=0;
                      dec(thisuser.timebank,lng);
                      inc(utimeleft,lng);
                      inc(tbwithcall,lng);
                      sl1('-','Took '+cstr(lng)+' Min From TimeBank.');
                      end;
                    end;
                  end;
  end;
  {until (c='Q');}
end;

function ctp(t,b:longint):astr;
var s,s1:astr;
    n:real;
begin
  if ((t=0) or (b=0)) then begin
    ctp:='  0.0%';
    exit;
  end;
  n:=(t*100)/b;
  str(n:5:1,s);
  s:=s+'%';
  ctp:=s;
end;

procedure cdsonline;
var nofound:boolean;
    cdf:file of cdrec;
    cds:cdrec;
    x,z:integer;
    temp1,temp2:string;
    cdfilesize:longint;

begin
  sl1(':','Viewing available CD-ROMs');
  assign(cdf,adrv(systat^.gfilepath)+'CDS.DAT');
  {$I-} reset(cdf); {$I+}
  if ioresult<>0 then begin
        for x:=1 to 26 do cdavail[x]:=0;
        sl1('!','No CD-ROMs Configured');
        exit;
  end;
  cdfilesize:=filesize(cdf)-1;
  seek(cdf,1);
  read(cdf,cds);
  if (cds.volumeid='') and (cds.uniquefile='') then begin
        close(cdf);
        for x:=1 to 26 do cdavail[x]:=0;
        sl1('!','No CD-ROMs Configured');
        exit;
  end;
  seek(cdf,1);
  nofound:=TRUE;
  sprompt(gstring(347));
  temp1:=gstring(348);
  temp2:=gstring(349);
  z:=1;
  while (z<=cdfilesize) and not(eof(cdf)) do begin
        read(cdf,cds);
        if (aacs(cds.viewacs)) then begin
        sprompt(mln(cds.name,36)+' %080%: ');
        for x:=1 to 26 do begin
              if (cdavail[x]=filepos(cdf)-1) then begin
                        sprompt(temp1);
                        nofound:=FALSE;
              end;
        end;
        if (nofound) then sprompt(temp2);
        end;
        nofound:=TRUE;
        inc(z);
  end;
  close(cdf);
  nl;
end;

end.
