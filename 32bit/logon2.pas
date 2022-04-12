{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R-,S+,V-}
unit logon2;

interface

uses
  crt, dos,
  archive1,
  misc2, miscx,
  cuser,
  menus,
  common;

procedure logon;
procedure logoff;
procedure endday;

implementation

uses keyunit,mkstring,mkmisc;

procedure logon;
var d:searchrec;
    dt:datetimerec;
    ssf:file of subscriptionrec;
    ss:subscriptionrec;
    s:astr;
    tmpdate,lng:longint;
    x:integer;
    c:char;
    changed,found,abort:boolean;


  procedure findchoptime;
  var lng,lng2,lng3:longint;

    procedure onlinetime;
    var dt:datetimerec;
        secs:longint;
    begin
      secs:=trunc(nsl);
      dt.day:=secs div 86400; secs:=secs-(dt.day*86400);
      dt.hour:=secs div 3600; secs:=secs-(dt.hour*3600);
      dt.min:=secs div 60; secs:=secs-(dt.min*60);
      dt.sec:=secs;
      sprint('%120%System Event is approaching in: %150%'+longtim(dt));
      sprint('%120%Online Time adjusted accordingly.');
    end;

    procedure onlinetime2;
    begin
      sprompt('%120%System Event is starting... |LF||LF|');
      sprompt('%120%Shutting down for System Event...|LF||LF|');
      hangup2:=TRUE;
    end;

  begin
    if (exteventtime<>0) then
    begin
      lng:=exteventtime;
      if (lng<trunc(nsl/60.0)) then
      begin
        telluserevent:=TRUE;
        choptime:=(nsl-(lng*60.0))+120.0;
        if (trunc(nsl)<0) then
        onlinetime2 else
        onlinetime;
        exit;
      end;
    end;
  end;

begin
  getdatetime(common.timeon); mread:=0; extratime:=0.0; freetime:=0.0;
  useron:=TRUE; com_flush_rx; 
  
  logon1st;

  if (aacs(systat^.sop)) and (not fastlogon) then
  begin
    dyny:=true;
    if pynq(gstring(20)) then fastlogon:=TRUE;
  end;

  if (aacs(systat^.loginvisible)) then begin
    if pynq(gstring(32)) then begin
     online.invisible:=TRUE;
     updateonline;
    end;
  end;

  filemode:=66;
  with online do begin
        name:=thisuser.name;
        real:=thisuser.realname;
        nickname:=thisuser.nickname;
        number:=usernum;
        userid:=thisuser.userid;
        status:=2;
        business:=thisuser.business;
        available:=true;
        activity:='Logging on';
        if not(okansi) then emulation:=0 else emulation:=1;
  end;
  updateonline;

  if (hangup) then exit;
  

  savesystat;

  findchoptime;

  with thisuser do
  begin
    if ((alert in ac) and (sysop)) then chatcall:=TRUE;
  end;

{  if not(registered) then begin
  common.getdatetime(dt);
  if (dt.day-syst.ordate.day)>45 then begin
        sprompt('%070%');
        cls;
        sprint('%110%Message from Epoch Development Company:');
        nl;
        sprompt('%120% This software has been in use for %150%'+cstr((dt.day-syst.ordate.day)-30)+' day');
        if ((dt.day-syst.ordate.day)-30)<>1 then sprint('%150%s') else nl;
        sprint('%120% past the 30 day evaluation period!');
        nl;
        sprint('%110%Please urge %150%'+systat^.sysopname+' %110%to register his copy %150%TODAY!');
        nl;
        delay(((dt.day-syst.ordate.day)-40)*100);
  end;
  end else if (expired) then begin
        sprompt('%070%');
        cls;
        sprint('%110%Message from Epoch Development Company:');
        nl;
        sprint('%120% This copy of Nexus Bulletin Board System has expired!');
        nl;
        delay(10000);
  end; }
  
  for x:=1 to 20 do 
        if (thisuser.clearentry[x]) then begin
                sprompt(gstring(256));
                case x of
                        1:begin
                                cstuff(1,1);
                        end;
                        2:begin
                                cstuff(4,1);
                        end;
                        3:begin
                                cstuff(14,1);
                           end;
                        4:begin
                                cstuff(2,1);
                        end;
                        5:begin
                                cstuff(38,1);
                        end;
                        6:begin
                                cstuff(39,1);
                        end;
                        7:begin
                                cstuff(40,1);
                        end;
                        8:begin
                                cstuff(41,1);
                        end;
                        9:begin
                                cstuff(5,1);
                        end;
                        10:begin
                                cstuff(6,1);
                        end;
                        11:begin
                                cstuff(13,1);
                           end;
                        12:begin
                                cstuff(29,1);
                           end;
                end;
                thisuser.clearentry[x]:=FALSE;
        end;
  saveuf;
  online.business:=thisuser.business;
  updateonline;

  { Enter Subscription Checking Here }

  assign(ssf,adrv(systat^.gfilepath)+'SUBSCRIP.DAT');
  {$I-} reset(ssf); {$I+}
  if (ioresult<>0) then begin
        sl1('!','Error Opening SUBSCRIP.DAT');
        sl1('!','Unable to update user''s subscription');
  end else begin
        if (thisuser.subscription>filesize(ssf)-1) then begin
                sl1('!','Subscription Setting for User no longer available');
                sl1('!','Please change to available Subscription Level');
        end else begin
                seek(ssf,thisuser.subscription);
                read(ssf,ss);
                if (ss.sublength<>0) and (ss.newsublevel<>0) then begin
                tmpdate:=u_daynum(datelong+'  '+time);
                tmpdate:=tmpdate-thisuser.subdate;
                tmpdate:=trunc(tmpdate/86400);
                if (tmpdate>ss.sublength) then begin
                        getsubscription(ss.newsublevel);
                        {$I-} seek(ssf,ss.newsublevel); {$I+}
                        if (ioresult<>0) then begin
                        read(ssf,ss);
                        nl;
                        sprint('%030%Subscription has expired...');
                        nl;
                        sprint('%030%Changing Subscription to %150%'+ss.description+'%030%...');
                        nl;
                        end;
                end;
                end;
                csubdesc:=ss.description;
        end;
        close(ssf);
  end;
  { End Subscription Checking }

end;

procedure logoff;
var tmpfile:file;
    ddt,dt:datetimerec;
    i,tt,rcode:integer;
    zf,zf3:file of CallInfoREC;
    d1,d2:CallInfoREC;
    lcallf:file of lcallers; 
    lcall:lcallers;
    n,z,x,x1,y1,ior:integer;
    ont:boolean;
    d3:TotalsREC;
    zf2,zf4:file of TotalsREC;
begin
  term_ready(FALSE);

  getdatetime(dt); timediff(ddt,common.timeon,dt); tt:=trunc((dt2r(ddt)+30)/60);
  curact^.active:=tt;
  if (spd<>'KB') and (usernum<>0) and (useron) and not(online.invisible) then
  begin
    filemode:=66;
    assign(zf,adrv(systat^.gfilepath)+'CALLINFO.DAT');
    {$I-} reset(zf); {$I+}
    if (ioresult<>0) then begin
      rewrite(zf);
      fillchar(d1,sizeof(d1),#0);
      write(zf,d1);
      d1.date:=u_daynum(datelong);
      write(zf,d1);
    end;
    seek(zf,filesize(zf)-1);
    read(zf,d1);
    unixtodt(d1.date,fddt);
    if (formatteddate(fddt,'MM/DD/YYYY')<>datelong) or (filesize(zf)=1) then begin
    seek(zf,filesize(zf));
    fillchar(d1,sizeof(d1),#0);
    d1.date:=u_daynum(datelong);
    write(zf,d1);
    seek(zf,filesize(zf)-1);
    read(zf,d1);
    end;
    case (answerbaud div 100) of
      3:inc(d1.userbaud[0]);
      12:inc(d1.userbaud[1]);
      24:inc(d1.userbaud[2]);
      48:inc(d1.userbaud[3]);
      72:inc(d1.userbaud[4]);
      96:inc(d1.userbaud[5]);
      120:inc(d1.userbaud[6]);
      144:inc(d1.userbaud[7]);
      168:inc(d1.userbaud[8]);
      192:inc(d1.userbaud[9]);
      216:inc(d1.userbaud[10]);
      240:inc(d1.userbaud[11]);
      264:inc(d1.userbaud[12]);
      288:inc(d1.userbaud[13]);
      312:inc(d1.userbaud[14]);
      336:inc(d1.userbaud[15]);
      384:inc(d1.userbaud[16]);
      576:inc(d1.userbaud[22]);
      768:inc(d1.userbaud[28]);
      1152:inc(d1.userbaud[34]);
      else inc(d1.userbaud[40]);
    end;
    d1.active:=d1.active+curact^.active;
    d1.calls:=d1.calls+curact^.calls;
    d1.newusers:=d1.newusers+curact^.newusers;
    d1.pubpost:=d1.pubpost+curact^.pubpost;
    d1.fback:=d1.fback+curact^.fback;
    d1.criterr:=d1.criterr+curact^.criterr;
    d1.uploads:=d1.uploads+curact^.uploads;
    d1.downloads:=d1.downloads+curact^.downloads;
    d1.uk:=d1.uk+curact^.uk;
    d1.dk:=d1.dk+curact^.uk;
    seek(zf,filesize(zf)-1);
    write(zf,d1);
    close(zf);
    filemode:=66;
    assign(zf3,adrv(systat^.gfilepath)+'CALLINFO.'+cstrnfile(cnode));
    {$I-} reset(zf3); {$I+}
    if (ioresult<>0) then begin
      rewrite(zf3);
      fillchar(d1,sizeof(d1),#0);
      write(zf3,d1);
      d1.date:=u_daynum(datelong);
      write(zf3,d1);
    end;
    seek(zf3,(filesize(zf3)-1));
    read(zf3,d1);
    unixtodt(d1.date,fddt);
    if (formatteddate(fddt,'MM/DD/YYYY')<>datelong) or (filesize(zf3)=1) then begin
    seek(zf3,filesize(zf3));
    fillchar(d1,sizeof(d1),#0);
    d1.date:=u_daynum(datelong);
    write(zf3,d1);
    seek(zf3,filesize(zf3)-1);
    read(zf3,d1);
    end;
    case (answerbaud div 100) of
      3:inc(d1.userbaud[0]);
      12:inc(d1.userbaud[1]);
      24:inc(d1.userbaud[2]);
      48:inc(d1.userbaud[3]);
      72:inc(d1.userbaud[4]);
      96:inc(d1.userbaud[5]);
      120:inc(d1.userbaud[6]);
      144:inc(d1.userbaud[7]);
      168:inc(d1.userbaud[8]);
      192:inc(d1.userbaud[9]);
      216:inc(d1.userbaud[10]);
      240:inc(d1.userbaud[11]);
      264:inc(d1.userbaud[12]);
      288:inc(d1.userbaud[13]);
      312:inc(d1.userbaud[14]);
      336:inc(d1.userbaud[15]);
      384:inc(d1.userbaud[16]);
      576:inc(d1.userbaud[22]);
      768:inc(d1.userbaud[28]);
      1152:inc(d1.userbaud[34]);
      else inc(d1.userbaud[40]);
    end;
    d1.active:=d1.active+curact^.active;
    d1.calls:=d1.calls+curact^.calls;
    d1.newusers:=d1.newusers+curact^.newusers;
    d1.pubpost:=d1.pubpost+curact^.pubpost;
    d1.fback:=d1.fback+curact^.fback;
    d1.criterr:=d1.criterr+curact^.criterr;
    d1.uploads:=d1.uploads+curact^.uploads;
    d1.downloads:=d1.downloads+curact^.downloads;
    d1.uk:=d1.uk+curact^.uk;
    d1.dk:=d1.dk+curact^.uk;
    seek(zf3,filesize(zf3)-1);
    write(zf3,d1);
    close(zf3);
    filemode:=66;
    assign(zf2,adrv(systat^.gfilepath)+'TOTALS.'+cstrnfile(cnode));
    {$I-} reset(zf2); {$I+}
    if (ioresult<>0) then begin
      rewrite(zf2);
      fillchar(d3,sizeof(d3),#0);
      d3.date:=u_daynum(datelong);
      write(zf2,d3);
    end;
    seek(zf2,0);
    read(zf2,d3);
    case (answerbaud div 100) of
      3:inc(d3.userbaud[0]);
      12:inc(d3.userbaud[1]);
      24:inc(d3.userbaud[2]);
      48:inc(d3.userbaud[3]);
      72:inc(d3.userbaud[4]);
      96:inc(d3.userbaud[5]);
      120:inc(d3.userbaud[6]);
      144:inc(d3.userbaud[7]);
      168:inc(d3.userbaud[8]);
      192:inc(d3.userbaud[9]);
      216:inc(d3.userbaud[10]);
      240:inc(d3.userbaud[11]);
      264:inc(d3.userbaud[12]);
      288:inc(d3.userbaud[13]);
      312:inc(d3.userbaud[14]);
      336:inc(d3.userbaud[15]);
      384:inc(d3.userbaud[16]);
      576:inc(d3.userbaud[22]);
      768:inc(d3.userbaud[28]);
      1152:inc(d3.userbaud[34]);
      else inc(d3.userbaud[40]);
    end;
    d3.active:=d3.active+curact^.active;
    d3.calls:=d3.calls+curact^.calls;
    d3.newusers:=d3.newusers+curact^.newusers;
    d3.pubpost:=d3.pubpost+curact^.pubpost;
    d3.fback:=d3.fback+curact^.fback;
    d3.criterr:=d3.criterr+curact^.criterr;
    d3.uploads:=d3.uploads+curact^.uploads;
    d3.downloads:=d3.downloads+curact^.downloads;
    seek(zf2,0);
    write(zf2,d3);
    close(zf2);
    filemode:=66;
    assign(zf4,adrv(systat^.gfilepath)+'TOTALS.DAT');
    {$I-} reset(zf4); {$I+}
    if (ioresult<>0) then begin
      rewrite(zf4);
      fillchar(d3,sizeof(d3),#0);
      d3.date:=u_daynum(datelong);
      write(zf4,d3);
    end;
    seek(zf4,0);
    read(zf4,d3);
    case (answerbaud div 100) of
      3:inc(d3.userbaud[0]);
      12:inc(d3.userbaud[1]);
      24:inc(d3.userbaud[2]);
      48:inc(d3.userbaud[3]);
      72:inc(d3.userbaud[4]);
      96:inc(d3.userbaud[5]);
      120:inc(d3.userbaud[6]);
      144:inc(d3.userbaud[7]);
      168:inc(d3.userbaud[8]);
      192:inc(d3.userbaud[9]);
      216:inc(d3.userbaud[10]);
      240:inc(d3.userbaud[11]);
      264:inc(d3.userbaud[12]);
      288:inc(d3.userbaud[13]);
      312:inc(d3.userbaud[14]);
      336:inc(d3.userbaud[15]);
      384:inc(d3.userbaud[16]);
      576:inc(d3.userbaud[22]);
      768:inc(d3.userbaud[28]);
      1152:inc(d3.userbaud[34]);
      else inc(d3.userbaud[40]);
    end;
    d3.active:=d3.active+curact^.active;
    d3.calls:=d3.calls+curact^.calls;
    d3.newusers:=d3.newusers+curact^.newusers;
    d3.pubpost:=d3.pubpost+curact^.pubpost;
    d3.fback:=d3.fback+curact^.fback;
    d3.criterr:=d3.criterr+curact^.criterr;
    d3.uploads:=d3.uploads+curact^.uploads;
    d3.downloads:=d3.downloads+curact^.downloads;
    seek(zf4,0);
    write(zf4,d3);
    close(zf4);

  assign(lcallf,adrv(systat^.gfilepath)+'LASTON.DAT');
  filemode:=66;
  {$I-} reset(lcallf); {$I+}
  if ioresult<>0 then begin
                rewrite(lcallf); lcall.node:=0;
                for z:=0 to 9 do write(lcallf,lcall);
  end;                
  {$I-} reset(systemf); {$I-}
  if (ioresult=0) then begin
        read(systemf,syst);
        close(systemf);
  end;
  for z:=9 downto 1 do begin
      seek(lcallf,z-1); read(lcallf,lcall);
      seek(lcallf,z); write(lcallf,lcall);
  end;
  inc(syst.callernum);
  with lcall do begin
      node:=cnode; name:=nam;
      number:=usernum;
      citystate:=copy(thisuser.business,1,30);
      if (telnet) then begin
        userbaud:='Telnet';
      end else begin
        userbaud:=cstr(answerbaud);
      end;
      dateon:=date;
  end;
  lcall.timeon:=ctim(dt2r(common.timeon));
  seek(lcallf,0); write(lcallf,lcall);
  close(lcallf);
  assign(lcallf,adrv(systat^.gfilepath)+'LASTON.'+cstrnfile(cnode));
  filemode:=66;
  {$I-} reset(lcallf); {$I+}
  if ioresult<>0 then begin
                rewrite(lcallf); lcall.node:=0;
                for z:=0 to 9 do write(lcallf,lcall);
  end;
  {$I-} reset(systemf); {$I-}
  if (ioresult=0) then begin
        read(systemf,syst);
        close(systemf);
  end;
  for z:=9 downto 1 do begin
      seek(lcallf,z-1); read(lcallf,lcall);
      seek(lcallf,z); write(lcallf,lcall);
  end;
  inc(syst.callernum);
  with lcall do begin
      node:=cnode; name:=nam;
      number:=usernum;
      citystate:=copy(thisuser.business,1,30);
      if (telnet) then begin
        userbaud:='Telnet';
      end else begin
        userbaud:=cstr(answerbaud);
      end;
      dateon:=date;
  end;
  lcall.timeon:=ctim(dt2r(common.timeon));
  seek(lcallf,0); write(lcallf,lcall);
  close(lcallf);

  end;


  {$I-} reset(systemf); {$I-}
  if (ioresult<>0) then begin
        sl1('!','Error Updating SYSTEM.DAT');
  end else begin
        write(systemf,syst);
        close(systemf);
  end;


  if ((useron) and (usernum>0)) then
  begin
    purgedir(newtemp);
    chdir(start_dir);
  end;
    slogging:=TRUE;
    if (exist(adrv(systat^.temppath)+'FLAG'+cstrn(cnode)+'.DAT')) then begin
        assign(tmpfile,adrv(systat^.temppath)+'FLAG'+cstrn(cnode)+'.DAT');
        {$I-} erase(tmpfile); {$I+}
        if (ioresult<>0) then begin end;
    end;

    if (trapping) then
    begin
      if (hungup) then
      begin
        writeln(trapfile);
        writeln(trapfile,'NO CARRIER');
      end;
      close(trapfile); trapping:=FALSE;
    end;


  if ((useron) and (usernum>0)) then
  begin
    thisuser.laston:=syst.lastdate; inc(thisuser.loggedon);

    (* if not logged in, but logged on *)
    if (realsl<>-1) then thisuser.sl:=realsl;

    thisuser.illegal:=0; thisuser.ttimeon:=thisuser.ttimeon+tt;
    if (choptime<>0.0) then inc(thisuser.tltoday,trunc(choptime/60.0));
    thisuser.tltoday:=thisuser.tltoday-tt; { trunc(nsl/60.0); }

    filemode:=66;
    {$I-} reset(uf); {$I+}
    if (ioresult<>0) then begin
        sl1('!','Error updating User Information');
    end else begin
    if ((usernum>=1) and (usernum<=filesize(uf)-1)) then
      begin seek(uf,usernum); write(uf,thisuser); end;
    close(uf);
    end;
  end;

    if (spd<>'KB') then inc(d3.active,tt);
    inc(d3.fback,ftoday);
    savesystat;
    

    if (hungup) then sl1('!','Caller Dropped Carrier');
    if ((useron) and (usernum>0)) then
    sl1('~','Msgs Read  : '+mln(cstr(mread),6)+' Time On    : '+mln(cstr(tt),6));
    x1:=wherex;
    y1:=wherey;
    window(1,1,80,25);
    gotoxy(1,25);
    textbackground(0);
    clreol;
    gotoxy(x1,y1);
    spd:='KB';
    answerbaud:=0;
    with curact^ do begin
      active:=0; calls:=0; newusers:=0; pubpost:=0;
      fback:=0; criterr:=0; uploads:=0; downloads:=0; uk:=0; dk:=0;
    end;
end;

procedure endday;
var f:file;
begin
  useron:=FALSE;
  filemode:=66;
  assign(f,adrv(systat^.semaphorepath)+'INUSE.'+cstrnfile(cnode));
  {$I-} erase(f); {$I+}
  if (ioresult<>0) then begin
        writeln('Error removing active node status.  Could cause system malfunctions.');
  end;
  {$I-} erase(onlinef); {$I+}
  if (ioresult<>0) then begin end;
  dispose(con);
  dispose(stridx);
  dispose(curact);
  dispose(modemr);
  dispose(systat);
end;

end.
