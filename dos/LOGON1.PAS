(*****************************************************************************)
(*>                                                                         <*)
(*>  LOGON1  .PAS -  Copyright 1995 Intuitive Vision Software.              <*)
(*>                  All Rights Reserved.                                   <*)
(*>                                                                         <*)
(*>  Logon functions -- Part 1.                                             <*)
(*****************************************************************************)
{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R-,S+,V-}
unit logon1;

interface

uses
  crt, dos,
  logon2, newusers,
  mainmail,
  misc2, miscx,
  archive1,
  menus, 
  common,iemsi;

function getuser:boolean;
procedure createtags;

implementation

uses mail0, myio3,mkstring,tagunit,mkmisc;

const iname:string='';
      ialias:string='';
      ipassword:string='';
      ivoice:string='';
      iiemsi:boolean=FALSE;
      iemsitried:boolean=FALSE;

procedure getpws(var ok:boolean; var tries:integer);
var phone,pw,s:astr;
begin
  if (spd<>'KB') or ((spd='KB') and (systat^.localsec) and not(fastlogon)) then begin
        ok:=TRUE; echo:=FALSE;
                if not(iiemsi) then begin
                        sprompt(gstring(2));
                        input(pw,20);
                end else pw:=ipassword;
                if (systat^.phonepw) then begin
                    if not(iiemsi) then begin
                            sprompt('%150%Complete Phone #: %150%(%080%###%090%) %080%###%090%-%150%');
                            input(phone,4);
                    end else phone:=(copy(ivoice,length(ivoice)-3,4));
                end else phone:=(copy(thisuser.phone1,length(thisuser.phone1)-3,4));
                echo:=TRUE;
  if ((thisuser.pw<>pw) or (copy(thisuser.phone1,length(thisuser.phone1)-3,4)<>phone)) then
  begin
    sprompt(gstring(6));
    if (not hangup) and (usernum<>0) then begin
      s:='Invalid password. Tried: '+caps(nam)+'  AK: '+pw;
      if (systat^.phonepw) then s:=s+'  PH#: '+phone;
      sl1('!',s);
    end;
    inc(thisuser.illegal);
    seek(uf,usernum); write(uf,thisuser);
    inc(tries);
    if (tries>=systat^.maxlogontries) then begin
        if pynq('%120%Send a message to '+systat^.sysopname+'? %110%') then begin
                online.activity:='Posting Feedback'; updateonline;
                irt:='/Password Failure on '+date+' '+time;
                privuser:=systat^.sysopname;
                if (ppost(0)) then begin end;
                privuser:='';
        end;
        hangup2:=TRUE;
    end;
    ok:=FALSE;
  end;
  if ((aacs(systat^.spw) and (systat^.sysoppw<>'')) and (ok) and (incom) and (not hangup)) then
  begin
    echo:=FALSE;
    sprompt('%150%'+gstring(3));
    input(pw,20);
    if (pw<>systat^.sysoppw) then begin
      sprompt(gstring(6));
      sl1('!','Illegal system password: '+pw); inc(tries);
      if (tries>=systat^.maxlogontries) then hangup2:=TRUE;
      ok:=FALSE;
    end;
    echo:=TRUE;
  end;                      
end else ok:=TRUE;
(*
  if (spd<>'KB') or ((spd='KB') and (systat^.localsec)) then begin
  ok:=TRUE; echo:=FALSE;
  if (Fastlogon) then
        begin
  end else
  begin
  if not(iiemsi) then begin
  sprompt('%150%'+gstring(2));
  input(pw,20);
  if (systat^.phonepw) then
  begin
    sprompt('%150%Complete Phone #: %150%(%080%###%090%) %080%###%090%-%150%');
    input(phone,4);
  end else
    phone:=(copy(thisuser.phone1,length(thisuser.phone1)-3,4));
  echo:=TRUE;
  if ((thisuser.pw<>pw) or (copy(thisuser.phone1,length(thisuser.phone1)-3,4)<>phone)) then
  begin
    sprompt(gstring(6));
    if (not hangup) and (usernum<>0) then begin
      s:='Invalid password. Tried: '+caps(nam)+'  AK: '+pw;
      if (systat^.phonepw) then s:=s+'  PH#: '+phone;
      sl1('!',s);
    end;
    inc(thisuser.illegal);
    seek(uf,usernum); write(uf,thisuser);
    inc(tries); if (tries>=systat^.maxlogontries) then begin
        if pynq('%120%Send a message to '+systat^.sysopname+'? %110%') then begin
        online.activity:='Posting Feedback'; updateonline;
        irt:='/Password Failure on '+date+' '+time;
        privuser:=systat^.sysopname;
        if (ppost(0)) then begin end;
        privuser:='';
        end;
        hangup2:=TRUE;
    end;
    ok:=FALSE;
  end;
  end;
  if ((aacs(systat^.spw) and (systat^.sysoppw<>'')) and (ok) and (incom) and (not hangup)) then
  begin
    echo:=FALSE;
    sprompt('%150%'+gstring(3));
    input(pw,20);
    if (pw<>systat^.sysoppw) then
    begin
      sprompt(gstring(6));
      sl1('!','Illegal system password: '+pw); inc(tries);
      if (tries>=systat^.maxlogontries) then hangup2:=TRUE;
      ok:=FALSE;
    end;
    echo:=TRUE;
  end else begin
        if (ipassword<>thisuser.pw) then begin
                iiemsi:=FALSE;
                sprompt('%120%Invalid password transmitted via IEMSI information!|LF||LF|');
                sprompt('%150%'+gstring(2));
                input(pw,20);
        end;
        if (systat^.phonepw) and (iiemsi) then
        begin
                iiemsi:=FALSE;
                if (copy(ivoice,length(ivoice)-3,4)<>(copy(thisuser.phone1,length(thisuser.phone1)-3,4))) then begin
                sprompt('%150%Complete Phone #: %150%(%080%###%090%) %080%###%090%-%150%');
                input(phone,4); echo:=TRUE;
                end else phone:=(copy(ivoice,length(ivoice)-3,4));
        end else phone:=(copy(thisuser.phone1,length(thisuser.phone1)-3,4));
  if ((thisuser.pw<>ipassword) or (copy(thisuser.phone1,length(thisuser.phone1)-3,4)<>phone)) then
  begin
    sprompt(gstring(6));
    if (not hangup) and (usernum<>0) then begin
      s:='Invalid password. Tried: '+caps(nam)+'  AK: '+pw;
      if (systat^.phonepw) then s:=s+'  PH#: '+phone;
      sl1('!',s);
    end;
    inc(thisuser.illegal);
    seek(uf,usernum); write(uf,thisuser);
    inc(tries); if (tries>=systat^.maxlogontries) then begin
        if pynq('%120%Send a message to '+systat^.sysopname+'? %110%') then begin
                online.activity:='Posting Feedback'; updateonline;
                irt:='/Password Failure on '+date+' '+time;
                privuser:=systat^.sysopname;
                if (ppost(0)) then begin end;
                privuser:='';
        end;
        hangup2:=TRUE;
    end;
    ok:=FALSE;
  end;
  if ((aacs(systat^.spw) and (systat^.sysoppw<>'')) and (ok) and (incom) and (not hangup)) then
  begin
    echo:=FALSE;
    sprompt('%150%'+gstring(3));
    input(pw,20);
    if (pw<>systat^.sysoppw) then
    begin
      sprompt(gstring(6));
      sl1('!','Illegal system password: '+pw); inc(tries);
      if (tries>=systat^.maxlogontries) then hangup2:=TRUE;
      ok:=FALSE;
    end else ok:=TRUE;
    echo:=TRUE;
  end;
  end;
  end;
  end else ok:=TRUE; *)
end;

procedure createtags;
var UTAG:^TagRecordOBJ;
begin
                new(UTAG);
                if (UTAG=NIL) then begin
                        sprint('%120%Unable to update message base tag records.');
                end else begin
                UTAG^.Init(adrv(systat^.userpath)+hexlong(thisuser.userid)+'\'+hexlong(thisuser.userid)+'.NMT');
                UTAG^.Maxbases:=Numboards;
                UTAG^.SortTags(adrv(systat^.gfilepath)+'USER'+cstrn(cnode)+'.TMT',1);
                UTAG^.Done;
                dispose(UTAG);
                end;
                new(UTAG);
                if (UTAG=NIL) then begin
                        sprint('%120%Unable to update file base tag records.');
                end else begin
                UTAG^.Init(adrv(systat^.userpath)+hexlong(thisuser.userid)+'\'+hexlong(thisuser.userid)+'.NFT');
                UTAG^.MaxBases:=Maxulb;
                UTAG^.SortTags(adrv(systat^.gfilepath)+'USER'+cstrn(cnode)+'.TFT',2);
                UTAG^.Done;
                dispose(UTAG);
                end;
end;

function getuser:boolean;
var lckout:text;
    lout,pw,s,phone,newusername,acsreq:astr;
    lng:longint;
    x,y,y1,y2,tries,i,ttimes,z,zz:integer;
    don1,don2,done,nu,ok,toomuch,wantnewuser,acsuser:boolean;
    HiVer,LoVer:string;
    conff:file of confrec;
    cnf:confrec;
begin
  wasnewuser:=FALSE;
  utimeleft:=15;
  extratime:=0.0; freetime:=0.0; choptime:=0.0;
  with thisuser do begin
    usernum:=-1;
    name:='NO USER'; realname:='Not entered yet';
    sl:=0; ar:=[];
    ac:=ac+[onekey,pause,novice,color];
    pagelen:=24;
  end;
  with online do begin
        name:='Unknown';
        real:='Unknown';
        nickname:='';
        number:=0;
        userid:=0;
        status:=1;
        business:='';
        available:=true;
        activity:='Logging on';
        if not(okansi) then emulation:=0 else emulation:=1;
  end;
  updateonline;
  topscr;
  getdatetime(common.timeon);
  mread:=0; extratime:=0.0; freetime:=0.0;
  realsl:=-1;
  newusername:='';
  wantnewuser:=FALSE;
  nu:=FALSE;
  echo:=TRUE; 
  pw:='';
  
  schangewindow(true,1);

  ttimes:=0; tries:=0; s:='';
  iiemsi:=FALSE;
  iemsitried:=FALSE;
  repeat
    repeat
      if (not wantnewuser) then begin
        if (spd='KB') then begin
                if not(fastlogon) then sprompt(gstring(1));
        end else begin
                if (iemsitried) or not(systat^.allowiemsi) then sprompt(gstring(1));
        end;
      end;
      s:='';
      com_flush_rx;
      if not(systat^.allowiemsi) then iemsitried:=TRUE;

      if (spd<>'KB') and not(iemsitried) then begin
      case isiemsi(iname,ialias,ipassword,ivoice) of
                0:iiemsi:=TRUE;
                1:begin
                        iiemsi:=FALSE;
                        sprompt(gstring(1));
                  end;
                2:begin
                        iiemsi:=FALSE;
                        outcom:=FALSE;
                        sprompt(gstring(1));
                        outcom:=TRUE;
                  end;
      end;
      iemsitried:=TRUE;
      if (iiemsi) then begin
        com_flush_rx;
        sl1('+','IEMSI Session Completed Successfully');
        sl1('+','IEMSI Real Name: '+iname);
        sl1('+','IEMSI Alias    : '+ialias);
        sl1('+','IEMSI Password : '+ipassword);
        sl1('+','IEMSI Phone #  : '+ivoice);
        s:=iname;

      end;
      end;
      if ((spd='KB') and (fastlogon)) then usernum:=1 else begin
      repeat
      finduser(s,usernum);
      assign(lckout,adrv(systat^.gfilepath)+'LOCKOUT.TXT');
      {$I-} reset(lckout); {$I+}
      don2:=true;
      if ioresult=0 then begin
        repeat
        readln(lckout,lout);
        if pos(allcaps(lout),allcaps(s))<>0 then begin
                sprint('%140%'+lout+' %070%Is invalid as a user name.  Please try again.');
                sl1('!','Invalid user name: '+lout);
                don1:=true;
                don2:=false;
                end;
        until (eof(lckout) or (don1));
        close(lckout);
        end;
      until (don2);
      end;

      if (pos('|',s)<>0) then begin
        nl;
        print('MCI codes are not valid at logon.');
        sl1('!','User tried MCI usage at logon');
        hangup2:=TRUE;          
      end;

      if (not hangup) then begin
        newusername:='';
        if (usernum=0) then
          if (s<>'') then begin
            dyny:=false;
            if pynq(gstring(7)) then usernum:=-1;
            newusername:=s;
          end else begin
            inc(ttimes);
            if (ttimes>systat^.maxlogontries) then hangup2:=TRUE;
          end;
      end;
    until ((usernum<>0) or (hangup));
    ok:=TRUE; done:=FALSE;
    if (not hangup) then
      case usernum of
       -1:begin
            if allcaps(s)='NEW' then newusername:='NEW USER';
            newuserinit(newusername);
            nu:=TRUE;
            done:=TRUE; ok:=FALSE;
          end;
      else
          if (usernum=-3) then begin
            nl;
            print('Illegal user number.  Negative numbers are invalid.');
            sl1('!','User Tried Negative Number At Logon');
            hangup2:=TRUE;
          end else begin
            reset(uf);
            seek(uf,usernum); read(uf,thisuser);
            echo:=FALSE;
            if not(okansi) then begin
            textcolor(7);
            textbackground(0);
            end;
            repeat
                getpws(ok,tries);
            until (ok) or (hangup);
            echo:=true;
            if (ok) then
            begin
              done:=TRUE;
            end;
            
            close(uf);
            if (not ok) then begin
              sclearwindow;
            end;
          end;
    end;
  until ((done) or (hangup));
  if ((thisuser.lockedout) and (not hangup)) then begin
    printf(thisuser.lockedfile);
    sl1('!',nam+': Attempted Logon When Locked Out');
    hangup2:=TRUE;
  end;
  if ((not nu) and (not hangup)) then
  begin
  getnewsecurity(thisuser.sl);
  utimeleft:=thisuser.tltoday;
  if (security.timepercall>0) then begin
        if (security.timepercall<utimeleft) then
        utimeleft:=security.timepercall;
  end;
  unixtodt(thisuser.laston,fddt);
  if (formatteddate(fddt,'MM/DD/YYYY')<>datelong) and not(hangup) then begin
    reset(uf);
    seek(uf,usernum);
    read(uf,thisuser);
    with thisuser do begin
        tltoday:=security.timeperday;
        utimeleft:=tltoday;
        timebankadd:=0; ontoday:=0;
        laston:=u_daynum(datelong);
    end;
  if (security.timepercall>0) then begin
        if (security.timepercall<utimeleft) then
        utimeleft:=security.timepercall;
  end;
    seek(uf,usernum);
    write(uf,thisuser);
    close(uf);
  end;
    toomuch:=FALSE;
            if (not systat^.localsec) then begin
{              if (not useron) then begin
                useron:=TRUE;
              end;}
              schangewindow(TRUE,1);
{              useron:=FALSE;}
            end;
    unixtodt(thisuser.laston,fddt);
    if (((rlogon in thisuser.ac) or (security.callsperday=1)) and
       (thisuser.ontoday>=1) and (formatteddate(fddt,'MM/DD/YYYY')=datelong)) then begin
      printf('CALLLIMT');
      if (nofile) then print('You are only allowed one call per day.');
      toomuch:=TRUE;
    end else
      if ((thisuser.ontoday>=security.callsperday) and
          (formatteddate(fddt,'MM/DD/YYYY')=datelong)) then begin
        printf('CALLLIMT');
        if (nofile) then
          print('You are only allowed '+cstr(security.callsperday)+' calls per day.');
        toomuch:=TRUE;
      end else
        if ((thisuser.tltoday<=0) and (formatteddate(fddt,'MM/DD/YYYY')=datelong)) then begin
          printf('TIMELIMT');
          if (nofile) then
            prompt('You are only allowed '+cstr(security.timeperday)+' minutes per day.');
          toomuch:=TRUE;
          if (thisuser.timebank>0) then begin
            nl; nl;
            sprint('%140%You Have '+cstrl(thisuser.timebank)+
                   ' Minutes Left In Your TimeBank.');
            dyny:=TRUE;
            if pynq('%120%Withdraw From TimeBank? %110%') then begin
              prt('How Many Minutes? '); inu(zz); lng:=zz;
              if (lng>0) then begin
                if (lng>thisuser.timebank) then lng:=thisuser.timebank;
                dec(thisuser.timebankadd,lng);
                if (thisuser.timebankadd<0) then thisuser.timebankadd:=0;
                dec(thisuser.timebank,lng);
                inc(thisuser.tltoday,lng);
                inc(utimeleft,lng);
                inc(tbwithcall,lng);
                sprint('%140%In Your Account: %030%'+cstr(thisuser.timebank)+
                        '%140%   Time Left Online: %030%'+cstr(trunc(nsl) div 60));
                sl1('+','No Time Left. Took '+cstrl(lng)+' Min From TimeBank.');
              end;
            end;
            if (thisuser.tltoday>=0) then toomuch:=FALSE else sprint('%120%Disconnecting...');
          end;
        end;
    if (toomuch) then
    begin
      sl1('!',nam+' : Exceeded Logon Limit.');
      hangup2:=TRUE;
    end;
{       sprint('%140%You are only allowed to log on one node at a time.  If you are');
        sprint('%140%not currently logged on to a node, then there has been a system');
        sprint('%140%malfunction, and it will be reset at midnight tonight.');
        nl;
        sl1('!',nam+' : Tried logging on more than one node');
        hangup2:=TRUE;
        sprint('%120%Disconnecting...');
        doneday:=TRUE;
  end;}
    
    if (tries=systat^.maxlogontries) then hangup2:=TRUE;
    if (not hangup) then inc(thisuser.ontoday);
  end;
  checkit:=FALSE;
  
  if ((usernum>0) and (not hangup)) then
  begin
    mconf:=1;
    fconf:=1;
    saveuf;
    getuser:=nu;
    {useron:=TRUE;}
    schangewindow(true,1);
    {useron:=FALSE;}
    inittrapfile;
  
  amconf:=[];
  afconf:=[];
  assign(conff,adrv(systat^.gfilepath)+'CONFS.DAT');
  {$I-} reset(conff); {$I-}
  if (ioresult<>0) then begin
        sl1('!','Could not read Conference Information.');
  end else begin
        read(conff,cnf);
        close(conff);
        for x:=1 to 26 do begin
                if (cnf.msgconf[x].active) then begin
                        if aacs(cnf.msgconf[x].access) then amconf:=
                                amconf+[chr(x+64)];
                end;
        end;
        for x:=1 to 26 do begin
                if (cnf.fileconf[x].active) then begin
                        if aacs(cnf.fileconf[x].access) then afconf:=
                                afconf+[chr(x+64)];
                end;
        end;
  end;

  tbaddcall:=0;
  tbwithcall:=0;
  if (thisuser.language<1) then thisuser.language:=1;
  clanguage:=thisuser.language;
  getlang(clanguage);
  end;
  if (hangup) then getuser:=FALSE;
end;

end.
