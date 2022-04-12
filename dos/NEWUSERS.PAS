(*****************************************************************************)
(*>                                                                         <*)
(*>    New Users - Copyright 1993 Intuitive Vision Software                 <*)
(*>                                                                         <*)
(*****************************************************************************)
{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R-,S+,V-}
unit newusers;

interface

uses
  crt, dos, mail0, misc2, misc3, miscx, cuser, doors, archive1, 
  menus, menus2, mkmsgabs, mkstring, mkdos, mkglobt, common, mainmail;

procedure newuser1;
procedure newuser2;
procedure newuserinit(nam:astr);
procedure informsysop(fn:string; msgbase:integer);

implementation

uses file2;

var perm:permidrec;

procedure defaulttags;
var ok,nospace:boolean;
begin
                {$I-} mkdir(adrv(systat^.userpath)+hexlong(thisuser.userid)); {$I+}
                if (ioresult<>0) then begin end;
                {$I-} mkdir(adrv(systat^.userpath)+hexlong(thisuser.userid)+'\FATTACH'); {$I+}
                if (ioresult<>0) then begin end;
                sprompt('%030%Updating message base tags... %150%');
                copyfile(ok,nospace,TRUE,adrv(systat^.userpath)+'DEFAULT.NMT',
                        adrv(systat^.userpath)+hexlong(thisuser.userid)+'\'+hexlong(thisuser.userid)+'.NMT');
                if not(ok) then
                        if (nospace) then sl1('!','Cannot create default message tags!')
                        else sl1('!','Cannot create default message tags (no space)!');
                sprompt('%030%Updating offline mail base tags... %150%');
                copyfile(ok,nospace,TRUE,adrv(systat^.userpath)+'DEFAULT.NMT',
                        adrv(systat^.userpath)+hexlong(thisuser.userid)+'\'+hexlong(thisuser.userid)+'.NWT');
                if not(ok) then
                        if (nospace) then sl1('!','Cannot create default offline mail tags!')
                        else sl1('!','Cannot create default offline mail tags (no space)!');
                sprompt('%030%Updating file base tags... %150%');
                copyfile(ok,nospace,TRUE,adrv(systat^.userpath)+'DEFAULT.NFT',
                        adrv(systat^.userpath)+hexlong(thisuser.userid)+'\'+hexlong(thisuser.userid)+'.NFT');
                if not(ok) then
                        if (nospace) then sl1('!','Cannot create default file tags!')
                        else sl1('!','Cannot create default file tags (no space)!');
end;


procedure p1;
var c:char;
    tries,i,ii,t:integer;
    s,s1,s2:astr;
    atype,pw:astr;
    nwac:set of uflags;
    done,abort,next,choseansi,chosecolor:boolean;

  procedure showstuff;
  begin
    if (systat^.newuserpw<>'') then begin
      tries:=0; pw:='';
      while ((pw<>systat^.newuserpw) and
            (tries<systat^.maxlogontries) and (not hangup)) do begin
                   prt('New user password: ');
                   echo:=FALSE;
                   input(pw,20);
                   echo:=TRUE;
                   if ((systat^.newuserpw<>pw) and (pw<>'')) then begin
                        sl1('!','Illegal new user password: '+pw);
                        inc(tries);
                   end;
      end;
      if (tries>=systat^.maxlogontries) then begin
        printf('NONEWUSR');
        hangup2:=TRUE;
      end;
    end;
  end;

  procedure doitall;
  type neworderrec=array[1..4] of integer;
  const neworder:neworderrec=(10,7,9,-1);
  var i:integer;
      c:char;
  begin
    showstuff;
    i:=1;
    repeat
      case i of
           1:begin
             if (thisuser.name='NEW USER') then begin
                cstuff(neworder[i],1);
             end else begin
                   thisuser.realname:=thisuser.name;
                   if not(pynq(gstring(50))) then begin
                        thisuser.realname:='Not Entered Yet';
                        cstuff(neworder[i],1);
                   end;
             end;
             if not(hangup) then schangewindow(TRUE,1);
             end;
           2:if (systat^.allowalias) then cstuff(neworder[i],1) else
                thisuser.name:=thisuser.realname;
           else cstuff(neworder[i],1);
      end;
      inc(i);
    until ((neworder[i]=-1) or (hangup));
  end;

begin
  t:=0;
  thisuser.mruler:=1;
  thisuser.phone1:='000-000-0000';
  thisuser.phone2:='000-000-0000';
  thisuser.phone3:='000-000-0000';
  thisuser.phone4:='000-000-0000';
  thisuser.street:='';
  thisuser.street2:='';
  thisuser.citystate:='';
  thisuser.zipcode:='00000-0000';
  thisuser.sex:='U';
  thisuser.option1:='';
  thisuser.option2:='';
  thisuser.option3:='';
  thisuser.note:='';
  thisuser.business:='';
  thisuser.title:='';
  thisuser.desc[1]:='';
  thisuser.desc[2]:='';
  thisuser.desc[3]:='';
  thisuser.desc[4]:='';
  if (okansi) then thisuser.msgeditor:=-1 else
  thisuser.msgeditor:=0;
  thisuser.uscheme:=1;
  thisuser.pagelen:=systat^.pagelen;
  thisuser.language:=clanguage;
  nwac:=[];
  if (ansi in thisuser.ac) then nwac:=nwac+[ansi];
  if (color in thisuser.ac) then nwac:=nwac+[color];
  nwac:=nwac+[pause,novice,onekey];
  thisuser.ac:=nwac;
  getsubscription(1);
  if (ansi in nwac) then thisuser.ac:=thisuser.ac+[ansi];
  if (color in nwac) then thisuser.ac:=thisuser.ac+[color];
  if not(novice in thisuser.ac) then thisuser.ac:=thisuser.ac+[novice];
  if not(onekey in thisuser.ac) then thisuser.ac:=thisuser.ac+[onekey];
  if not(pause in thisuser.ac) then thisuser.ac:=thisuser.ac+[pause];
  doitall;
  thisuser.phentrytype:=callfromarea;
  thisuser.zipentrytype:=callfromarea2;
end;

procedure p3;
var c:char;
    tries,i,ii,t:integer;
    s,s1,s2:astr;
    atype,pw:astr;
    done,abort,next,choseansi,chosecolor:boolean;

  procedure dc2(var abort:boolean; c:char; n,v:astr; c2:char; n2,v2:astr);
  begin
    sprint('%140%'+c+'%070% '+mln(n,11)+': %040%'+mln(v,22)+'  %140%'+
             c2+'%070% '+mln(n2,11)+': %040%'+mln(v2,22));
    wkey(abort,next);
  end;

begin
{  nl;
  if ((not hangup) and pynq('Verify Your User Information? ')) then
    repeat
      done:=FALSE;
      cls;
      abort:=FALSE; next:=FALSE;
      if (ansi in thisuser.ac) then begin
        atype:='ANSI';
        if (color in thisuser.ac) then atype:=atype+' w/ Color'
        else atype:=atype+' w/o Color';
      end else
        atype:='TTY';
      with thisuser do begin
        unixtodt(thisuser.bday,fddt);
        dc2(abort,'A','Alias',name,'H','Computer',option1);
        dc2(abort,'B','Real Name',  realname,'I','Birthdate',
        formatteddate(fddt,'MM/DD/YYYY')+', Age: '+cstr(ageuser(formatteddate(fddt,'MM/DD/YYYY'))));
        dc2(abort,'C','Phone',    phone1,'J','Gender',        sex);
                  
        dc2(abort,'D','Address',    street        ,'K','Reference', option3);
        dc2(abort,'E','City, State',citystate,'L','Emulation',       atype);
        dc2(abort,'F','Zip Code',   zipcode,'M','Screen Size','80x'+cstr(pagelen));
            
        dc2(abort,'G','Occupation', option2,'N','Access Key',   pw);
      end;
      nl;
      sprompt('%090%Selection [%150%S%090%ave] : %150%');
      onek(c,'SABCDEFGHIJKLMN');
      if (c<>'S') then cstuff(pos(c,'DILEHGACNBMJKF'),1) else done:=TRUE;
    until ((done) or (hangup));}
end;

procedure getnextuserid;
var permf:file of permidrec;
begin
  filemode:=18;
  assign(permf,adrv(systat^.gfilepath)+'PERMID.DAT');
  {$I-} reset(permf); {$I+}
  if (ioresult<>0) then begin
        sl1('!','Error reading PERMID.DAT');
        sprint('There was an internal system error.  System is shutting down.');
        hangup2:=TRUE;
        doneday:=TRUE;
  end else begin
        seek(permf,0);
        read(permf,perm);
        inc(perm.lastuserid);
        thisuser.UserID:=perm.LastUserID;
        seek(permf,0);
        write(permf,perm);
        close(permf);
  end;
  filemode:=66;
end;

procedure p2;
var pw:string;
    tries,i,t:integer;
    c:char;
begin
  if (not hangup) then begin
    sprompt(gstring(293));

    {$I-} reset(uf); {$I+}
    if (ioresult<>0) then begin
        sprint('%120%Error!');
        nl;
        sprint('Terminating connection...');
        sl1('!','Unable to open USERS.DAT!');
        hangup2:=TRUE;
        exit;
    end;

    usernum:=filesize(uf);
    seek(uf,usernum);
    write(uf,thisuser);
    close(uf);

    with thisuser do begin
      deleted:=FALSE;
      loggedon:=0;
      msgpost:=0;
      feedback:=0;
      ontoday:=0;
      illegal:=0; 
      downloads:=0; uploads:=0; dk:=0; uk:=0;
      ttimeon:=0; note:='';

      for i:=1 to 20 do boardsysop[i]:=-1;
      for i:=1 to 20 do uboardsysop[i]:=-1;
      lastmsg:=1; lastfil:=1; credit:=0; timebank:=0;

      for i:=1 to 20 do clearentry[i]:=FALSE;
      for i:=1 to 50 do reserved1[i]:=0;
      for i:=1 to 50 do reserved2[i]:=0;
      for i:=1 to 50 do reserved3[i]:=0;
      for i:=1 to 50 do reserved4[i]:=0;
      for i:=1 to 100 do reserved5[i]:=0;

      trapactivity:=FALSE; trapseperate:=FALSE;
      timebankadd:=0;
      chatauto:=FALSE; chatseperate:=FALSE;
      slogseperate:=FALSE;

      mruler:=1;

      realsl:=sl;
      
      getnewsecurity(thisuser.sl);
      tltoday:=security.timeperday;
      utimeleft:=tltoday;
    if (security.timepercall>0) then begin
        if (security.timepercall<utimeleft) then
        utimeleft:=security.timepercall;
    end;
    end;

    {$I-} reset(uf); {$I+}
    if (ioresult<>0) then begin
        sl1('!','Cannot add new user!!');
        sl1('!','Disconnecting...');
        sprompt('|LF|%120%Error adding your user record!  Disconnecting...|LF|');
        hangup2:=TRUE;
        exit;
    end;
    getnextuserid;
    thisuser.firston:=u_daynum(datelong);
    thisuser.filescandate:=u_daynum(datelong);
    thisuser.laston:=u_daynum(datelong);
    seek(uf,usernum); write(uf,thisuser);
    close(uf);
    {$I-} reset(systemf); {$I+}
    if (ioresult<>0) then begin
        sl1('!','ERROR: Cannot update SYSTEM.DAT!!');
    end else begin
        seek(systemf,0);
        write(systemf,syst);
        close(systemf);
    end;

    isr(thisuser.name,thisuser.realname,usernum,thisuser.UserID);
    sprompt(gstring(294));
    sprompt(gstring(295));

    useron:=TRUE;
{    window(1,1,80,25);
    clrscr; }
    schangewindow(TRUE,1);
    topscr;
  end;
end;

procedure newuser1;
var i:integer;
begin
  if (systat^.numusers>=32767) then begin
    sl1('!','MAXIMUM USER COUNT REACHED!!!');
    sprompt('%120%We''re sorry, but this system has reached its maximum number of allowable|LF|');
    sprompt('%120%users...  this will be noted to the system operator.  You should try back|LF|');
    sprompt('%120%within a few days to see if the situation has been remedied.|LF|');
    nl;
    hangup2:=TRUE;
  end else begin
    printf('NEWBEGIN');
    sl1('+','New user entering information');
    p1;
    with online do begin
        name:=thisuser.name;
        real:=thisuser.realname;
        nickname:=thisuser.nickname;
        userid:=thisuser.userid;
        number:=usernum;
        available:=true;
        activity:='New user application';
    end;
    updateonline;
  end;
end;

procedure informsysop(fn:string; msgbase:integer);
var s,s2:string;
    f:text;
    priv,done:boolean;
    mfrom,mto,msubj:string;
    oldboard,x,ps1,ps2:integer;
    d:datetimerec;
    fidor:fidorec;
    fidorf:file of fidorec;
    add2:addrtype;

    function getaddr(zone,net,node,point:integer):string;
    var s:string;
    begin
      if (point=0) then
	s:=cstr(zone)+':'+cstr(net)+'/'+cstr(node)+')'
      else
	s:=cstr(zone)+':'+cstr(net)+'/'+cstr(node)+'.'+cstr(point)+')';
      getaddr:=s;
    end;

  function getorigin:string;
  var s:astr;
  begin
    if (fidor.origins[memboard.origin]<>'') then s:=fidor.origins[memboard.origin]
      else if (fidor.origins[1]<>'') then s:=fidor.origins[1]
        else s:=copy(stripcolor(systat^.bbsname),1,50);
    while (copy(s,length(s),1)=' ') do
      s:=copy(s,1,length(s)-1);
    getorigin:=s;
  end;


procedure loadboard2(i:integer);
var bfo:boolean;
    tnum:integer;
begin
  if (readboard<>i) then begin
    tnum:=0;
    bfo:=(filerec(bf).mode<>fmclosed);
    filemode:=66; 
    if (not bfo) then begin
    {$I-} reset(bf); {$I+}
    if (ioresult<>0) then begin tnum:=-1; end;
    end;
    if (tnum<>-1) then begin 
    if ((i-1<0) or (i>filesize(bf)-1)) then i:=0;
    seek(bf,i); read(bf,memboard);
    readboard:=i;
    if (not bfo) then close(bf);
    end;
  end;
end;

function substone(src,old,new:string):string;
var p:integer;
begin
  if (old<>'') then begin
    p:=pos(old,src);
    if (p>0) then begin
      insert(new,src,p+length(old));
      delete(src,p,length(old));
    end;
  end;
  substone:=src;
end;

  function vtpword(i:integer):string;
  begin
  case i of
        0:vtpword:='';
        1:vtpword:='.a'+copy(build,2,length(build));
        2:vtpword:='.b'+copy(build,2,length(build));
        3:vtpword:='.d'+copy(build,2,length(build));
        4:vtpword:='.eep'+copy(build,2,length(build));
        else vtpword:='/PIRATED';
  end;
  end;

begin
if exist(systat^.afilepath+fn) then begin
oldboard:=board;
loadboard2(msgbase);
Mbopencreate;
if not(mbopened) then begin
        sl1('!','AutoPost: Error opening message base');
        sl1('!','AutoPost: Aborted.');
exit;
end;
if (memboard.mbtype in [1..3]) then begin
assign(fidorf,systat^.gfilepath+'NETWORK.DAT');
{$I-} reset(fidorf); {$I+}
if (ioresult<>0) then begin
        sl1('!','AutoPost: Error opening '+systat^.gfilepath+'NETWORK.DAT');
        sl1('!','AutoPost: Aborted.');
	exit;
end;
read(fidorf,fidor);
close(fidorf);
end;
case memboard.mbtype of
	0:CurrentMSG^.SetMailType(mmtNormal);
	1:CurrentMSG^.SetMailType(mmtEchoMail);
	2:CurrentMSG^.SetMailType(mmtNetMail);
        3:CurrentMSG^.SetMailType(mmtNetMail);
end;
CurrentMSG^.StartNewMsg;       {initialize for adding msg}

  CurrentMSG^.DoKludgeLn(^A+'PID: Nexus '+version);
priv:=TRUE;
assign(f,systat^.afilepath+fn);
{$I-} reset(f); {$I+}
if (ioresult<>0) then begin
        sl1('!','Error Reading '+fn+' for Auto-Post');
        exit;
end else begin
x:=1;
while (not eof(f)) do begin
    readln(f,s);
    s:=processMCI(s);

  case x of
        1:begin
                priv:=TRUE;
                if (allcaps(copy(s,1,3))='YES') then priv:=TRUE;
                if (allcaps(copy(s,1,2))='NO') then priv:=FALSE;
        end;
        2:begin
                mfrom:=s;
        end;
        3:begin
                mto:=s;
        end;
        4:begin
                msubj:=s;
        end;
        else begin
                  if (length(s)>78) then begin
                        CurrentMSG^.Dostringln(copy(s,1,78));
                        CurrentMSG^.DoStringln(copy(s,79,78));
                  end else begin
                        CurrentMSG^.DoStringLn(s);
                  end;
          end;
    end;
inc(x);    
end;
end;
      CurrentMSG^.Dostringln('');
      if (memboard.mbtype>=1) then begin
                s:='--- Nexus AutoPost v'+version;
                s:=s+' [Node '+cstr(cnode)+']';
                CurrentMSG^.DoStringLn(s);
                if (memboard.mbtype=1) then begin
                        s:=' * Origin: '+getorigin+' (';
                        x:=0;
			repeat
				inc(x);
                        until (memboard.address[x]) or (x=30);
                        if (x=30) and not(memboard.address[x]) then x:=1;
                        add2.zone:=fidor.address[x].zone;
                        add2.net:=fidor.address[x].net;
                        add2.node:=fidor.address[x].node;
                        add2.point:=fidor.address[x].point;
                        CurrentMSG^.SetOrig(add2);
                        s:=s+getaddr(add2.zone,add2.net,add2.node,add2.point);
                        CurrentMSG^.DoStringLn(s);
                end;
      end;
      if (memboard.mbtype in [1..3]) then 
                currentmsg^.dokludgeln(^A+'MSGID: '+pointedaddrstr(add2)+' '+lower(hexlong(getdosdate)));

with CurrentMSG^ do begin
    SetPriv(priv);
    SetSubj(msubj);
    SetDate(DateStr(GetDosDate));
    SetTime(TimeStr(GetDosDate));
    SetFrom(mfrom);
    SetTo(mto);
    SetEcho(TRUE);
    SetLocal(TRUE);
end;

      if (CurrentMSG^.WriteMSG<>0) then begin
         sl1('!','Error writing Auto-Notify for '+fn);
      end else sl1('+','Wrote Auto-Notify for '+fn);
if (mbopened) then MBclose;
board:=oldboard;
loadboard2(board);
if (useron) then loadboard(board);
close(f);
end;
end;

procedure newuser2;
var i:integer;
begin
    p3;
    p2;
    nl;
    defaulttags;
    nl;
    printf('NEWUSER1');
    i:=0;
    if (systat^.newapp>0) then begin
      if (systat^.newapp<>0) then i:=systat^.newapp;
      nl; pausescr; lil:=0;
      printf('NEWUSER2');
      if (i<>0) then begin
      irt:='\New user application';
      privuser:=systat^.sysopname;
      if (ppost(0)) then inc(thisuser.feedback);
      privuser:='';
      end;
    end;

    informsysop('NEWUSER.NOT',0);

    inc(curact^.newusers);
    wasnewuser:=TRUE;
    useron:=TRUE;
end;

procedure newuserinit(nam:astr);
var s:astr;
begin
  if (modemr^.closedsystem) then begin
    printf('nonewusr');
    hangup2:=TRUE;
  end else begin
    with thisuser do begin
      name:=nam;
      trapactivity:=FALSE;
      trapseperate:=FALSE;
    end;
    inittrapfile;
  end;
end;

end.

