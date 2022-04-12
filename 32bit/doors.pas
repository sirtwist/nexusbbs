(*****************************************************************************)
(*>                                                                         <*)
(*>  DOORS   .PAS -  Written by Eric Oman                                   <*)
(*>                                                                         <*)
(*>  Online door procedures.                                                <*)
(*>                                                                         <*)
(*****************************************************************************)
{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R-,S+,V-}
unit doors;

interface

uses
  crt, dos,
  execbat;

var timeremaining:real;

function process_door(s:string):string;
procedure write_dorinfo1_def(path:string;rname:boolean);     { RBBS-PC DORINFO1.DEF }
procedure write_door_sys(path:string;rname:boolean);         { GAP DOOR.SYS }
procedure write_chain_txt(path:string);                      { WWIV CHAIN.TXT }
procedure write_callinfo_bbs(path:string;rname:boolean);     { Wildcat! CALLINFO.BBS }
procedure write_sfdoors_dat(path:string;rname:boolean);      { Spitfire SFDOORS.DAT }
procedure write_doorfile_sr(s:string;rname:boolean);         { SR Games DOORFILE.SR }
procedure dodoorfunc(cline:string;editors:boolean);
function gettags:boolean;

implementation

uses file0,common,mkstring,mkmisc;

function dt2r2(dt:datetimerec):real;
begin
  with dt do
    dt2r2:=day*1440.0+hour*60.0+min;
end;

function timestr:string;
var i:string;
begin
  {str(nsl/60,i);}
  {i:=copy(i,2,length(i));}
  {i:=copy(i,1,pos('.',i)-1);}
  i:=cstrr(timeremaining*60,10);
  timestr:=i;
end;

function substall2(src,old,anew:string):string;
var p:integer;
begin
  p:=1;
  while p>0 do begin
    p:=pos(old,allcaps(src));
    if p>0 then begin
      insert(anew,src,p+length(old));
      delete(src,p,length(old));
    end;
  end;
  substall2:=src;
end;

function process_door(s:string):string;
var ps1,ps2,i:integer;
    sda,namm:string;
    sdoor:string[255];
    ok,done:boolean;
begin
  namm:=caps(thisuser.realname);
  sdoor:='';
  
  done:=false;
  while not(done) do begin  
	ps1:=pos('|',s);
	if (ps1<>0) then begin
	s[ps1]:=#28;
	ps2:=pos('|',s);
	if not(ps2=0) then
        s:=substall2(s,copy(s,ps1,(ps2-ps1)+1),smci3(copy(s,ps1+1,(ps2-ps1)-1),ok));
	end;
	if (pos('|',s)=0) then done:=TRUE;
  end;
  for i:=1 to length(s) do if (s[i]=#28) then s[i]:='|';
  
  sdoor:=s;
  process_door:=sdoor;
end;

procedure write_dorinfo1_def(path:string;rname:boolean);  (* RBBS-PC's DORINFO1.DEF *)
var fp:text;
    first,last:string;
    s:string;
begin
  assign(fp,path+'DORINFO1.DEF');
	rewrite(fp);
        writeln(fp,stripcolor(systat^.bbsname));
        first:=copy(systat^.sysopname,1,pos(' ',systat^.sysopname)-1);
        last:=copy(systat^.sysopname,length(first)+2,length(systat^.sysopname));
  writeln(fp,first);
  writeln(fp,last);
  if spd='KB' then writeln(fp,'COM0') else writeln(fp,'COM'+cstr(modemr^.comport));
  if spd='KB' then s:='0' else s:=cstrl(answerbaud);
  writeln(fp,s+' BAUD,N,8,1');
  writeln(fp,'0');
  if (rname) then begin
    if pos(' ',thisuser.realname)=0 then begin
      first:=thisuser.realname;
      last:='';
    end else begin
      first:=copy(thisuser.realname,1,pos(' ',thisuser.realname)-1);
      last:=copy(thisuser.realname,length(first)+2,length(thisuser.realname));
    end;
    first:=caps(first);
    last:=caps(last);
  end else begin
    if pos(' ',thisuser.name)=0 then begin
      first:=thisuser.name;
      last:='';
    end else begin
      first:=copy(thisuser.name,1,pos(' ',thisuser.name)-1);
      last:=copy(thisuser.name,length(first)+2,length(thisuser.name));
    end;
  end;
  writeln(fp,caps(first));
  writeln(fp,caps(last));
  writeln(fp,thisuser.citystate);
  if (okansi) then writeln(fp,'1') else writeln(fp,'0');
  writeln(fp,thisuser.sl);
  s:=cstrr(timeremaining,10);
  if length(s)>3 then s:='999';
  writeln(fp,s);
  writeln(fp,'0');
  close(fp);
end;

procedure write_door_sys(path:string;rname:boolean);    (* GAP's DOOR.SYS *)
var fp:text;
    i:integer;
    s:string;
begin
  assign(fp,path+'DOOR.SYS');
  rewrite(fp);
  if spd<>'KB' then writeln(fp,'COM'+cstr(modemr^.comport)+':') else writeln(fp,'COM0:');
  if spd<>'KB' then writeln(fp,cstrl(answerbaud)) else writeln(fp,cstrl(modemr^.waitbaud));
        writeln(fp,'8');
        writeln(fp,'1');
  if not(modemr^.lockport) then writeln(fp,cstrl(answerbaud)) else writeln(fp,cstrl(modemr^.waitbaud));
        if wantout then writeln(fp,'Y') else writeln(fp,'N');
        writeln(fp,'Y');
        if sysop then writeln(fp,'Y') else writeln(fp,'N');
        if alert in thisuser.ac then writeln(fp,'Y') else writeln(fp,'N');
  if (rname) then writeln(fp,thisuser.realname) else writeln(fp,thisuser.name);
  writeln(fp,thisuser.citystate);
  writeln(fp,copy(thisuser.phone1,1,3)+' '+copy(thisuser.phone1,5,8));
  writeln(fp,copy(thisuser.phone2,1,3)+' '+copy(thisuser.phone2,5,8));
  writeln(fp,thisuser.pw);
  writeln(fp,cstr(thisuser.sl));
  writeln(fp,cstr(thisuser.loggedon));
  unixtodt(thisuser.laston,fddt);
  writeln(fp,formatteddate(fddt,'MM/DD/YY'));
  writeln(fp,cstr(trunc(timeremaining) * 60));
  writeln(fp,cstrl(trunc(timeremaining)));
  if (okansi) then begin
        writeln(fp,'GR')
  end else begin
        writeln(fp,'NG');
  end;
  writeln(fp,cstr(thisuser.pagelen));
        if novice in thisuser.ac then writeln(fp,'N') else writeln(fp,'Y');
  s:='';
  for i:=1 to 7 do
    if chr(i+64) in thisuser.ar then s:=s+cstr(i);
  writeln(fp,s);
  writeln(fp,'7');
	writeln(fp,'12/31/99');
        writeln(fp,cstr(usernum));
        writeln(fp,'Z');
        writeln(fp,cstr(thisuser.uploads));
        writeln(fp,cstr(thisuser.downloads));
        writeln(fp,cstr(trunc(thisuser.dk)));
        writeln(fp,'999999');
        unixtodt(thisuser.bday,fddt);
        writeln(fp,formatteddate(fddt,'MM/DD/YY'));
	writeln(fp,thisuser.bday);
        writeln(fp,copy(adrv(systat^.gfilepath),1,length(adrv(systat^.gfilepath))-1));
        writeln(fp,copy(adrv(systat^.afilepath),1,length(adrv(systat^.afilepath))-1));
        writeln(fp,systat^.sysopname);
	writeln(fp,thisuser.name);
	writeln(fp,'00:00');
        writeln(fp,'Y');
        writeln(fp,'N');
        writeln(fp,'Y');
        writeln(fp,'3');
        writeln(fp,'0');
        unixtodt(thisuser.laston,fddt);
        writeln(fp,formatteddate(fddt,'MM/DD/YY'));
	writeln(fp,'00:00');
	writeln(fp,'00:00');
        writeln(fp,'0');
        writeln(fp,'0');
        writeln(fp,cstr(trunc(thisuser.uk)));
        writeln(fp,cstr(trunc(thisuser.dk)));
	writeln(fp,thisuser.note);
        writeln(fp,'0');
        writeln(fp,'0');
	close(fp);
end;

procedure write_chain_txt(path:string);
var fp:text;
    ton,tused:real;
    s:string[20];

  function bo(b:boolean):string;
  begin
    if b then bo:='1' else bo:='0';
  end;

begin
  assign(fp,path+'CHAIN.TXT');
  rewrite(fp);
  with thisuser do begin
    writeln(fp,usernum);                      { user number        }
    writeln(fp,name);                         { user name          }
    writeln(fp,realname);                     { real name          }
    writeln(fp,'');                           { "call sign" ?      }
    unixtodt(thisuser.bday,fddt);
    writeln(fp,ageuser(formatteddate(fddt,'MM/DD/YY')));                { age                }
    writeln(fp,sex);                          { sex                }
    str(credit:7,s); writeln(fp,s+'.00');     { credit             }
    unixtodt(thisuser.laston,fddt);
    writeln(fp,formatteddate(fddt,'MM/DD/YY'));
    writeln(fp,'80');                         { # screen columns   }
    writeln(fp,pagelen);                      { # screen rows      }
    writeln(fp,sl);                           { SL                 }
    writeln(fp,bo(so));                       { is he a SysOp?     }
    writeln(fp,bo(cso));                      { is he a CoSysOp?   }
    writeln(fp,bo(okansi));                   { is graphics on?    }
    writeln(fp,bo(incom));                    { is remote?         }
    str(timeremaining*60:10:2,s); writeln(fp,s);           { time left (sec)    }
    writeln(fp,adrv(systat^.gfilepath));             { gfiles path        }
    writeln(fp,adrv(systat^.gfilepath));             { data path          }
    writeln(fp,adrv(systat^.trappath)+'NEX'+cstrn(cnode)+'.LOG');   { SysOp log filespec }
    s:=cstrl(answerbaud); if (s='KB') then s:='0';          { baud rate          }
    writeln(fp,s);
    writeln(fp,modemr^.comport);               { COM port           }
    writeln(fp,stripcolor(systat^.bbsname));   { system name        }
    writeln(fp,systat^.sysopname);             { SysOp's name       }
    with timeon do begin
      ton:=hour*3600.0+min*60.0+sec;
      tused:=timer-ton;
      if (tused<0) then tused:=tused+3600.0*24.0;
    end;
    writeln(fp,trunc(ton));                   { secs on f/midnight }
    writeln(fp,trunc(tused));                 { time used (sec)    }
    writeln(fp,uk);                           { upload K           }
    writeln(fp,uploads);                      { uploads            }
    writeln(fp,dk);                           { download K         }
    writeln(fp,downloads);                    { downloads          }
    writeln(fp,'8N1');                        { COM parameters     }
  end;
  close(fp);
end;

procedure write_callinfo_bbs(path:string;rname:boolean);
var fp:text;
    s:string;

  function bo(b:boolean):string;
  begin
    if b then bo:='1' else bo:='0';
  end;

begin
  assign(fp,path+'CALLINFO.BBS');
  rewrite(fp);
  with thisuser do begin
    if (rname) then writeln(fp,allcaps(thisuser.realname)) else writeln(fp,allcaps(thisuser.name));
    if answerbaud=300 then s:='1' else
      if answerbaud=1200 then s:='2' else
      if answerbaud=2400 then s:='0' else
      if answerbaud=9600 then s:='3' else
      if spd='KB' then s:='5' else
      s:='4';
    writeln(fp,s);
    writeln(fp,allcaps(thisuser.citystate));
    writeln(fp,cstr(thisuser.sl));
    writeln(fp,timestr);
    if okansi then writeln(fp,'COLOR') else writeln(fp,'MONO');
    writeln(fp,thisuser.pw);
    writeln(fp,cstr(usernum));
    writeln(fp,'0');
    writeln(fp,copy(time,1,5));
    writeln(fp,copy(time,1,5)+' '+date);
    writeln(fp,'A');
    writeln(fp,'0');
    writeln(fp,'999999');
    writeln(fp,'0');
    writeln(fp,'999999');
    writeln(fp,thisuser.phone1);
    unixtodt(thisuser.laston,fddt);
    writeln(fp,formatteddate(fddt,'MM/DD/YY HH:MM'));
    if (novice in thisuser.ac) then writeln(fp,'NOVICE') else writeln(fp,'EXPERT');
    writeln(fp,'All');
    writeln(fp,'01/01/80');
    writeln(fp,cstr(thisuser.loggedon));
    writeln(fp,cstr(thisuser.pagelen));
    writeln(fp,'0');
    writeln(fp,cstr(thisuser.uploads));
    writeln(fp,cstr(thisuser.downloads));
    writeln(fp,'8  { Databits }');
    if ((incom) or (outcom)) then writeln(fp,'REMOTE') else writeln(fp,'LOCAL');
    if ((incom) or (outcom)) then writeln(fp,'COM'+cstr(modemr^.comport)) else writeln(fp,'COM0');
    unixtodt(thisuser.bday,fddt);
    writeln(fp,formatteddate(fddt,'MM/DD/YY'));
    if spd='KB' then writeln(fp,cstr(modemr^.waitbaud)) else writeln(fp,cstrl(answerbaud));
    if ((incom) or (outcom)) then writeln(fp,'TRUE') else writeln(fp,'FALSE');
    if (spdarq) then write(fp,'MNP/ARQ') else write(fp,'Normal');
    writeln(fp,' Connection');
    writeln(fp,'12/31/99 23:59');
    writeln(fp,'1');
    writeln(fp,'1');
  end;
  close(fp);
end;

procedure write_doorfile_sr(s:string;rname:boolean);
var fp:text;
begin
if (s<>'') then if (copy(s,length(s),1)<>'\') then s:=s+'\';
assign(fp,s+'DOORFILE.SR');
rewrite(fp);
if (rname) then
writeln(fp,thisuser.realname)
else
writeln(fp,thisuser.name);
if (okansi) then writeln(fp,'1') else writeln(fp,'0');
if (okansi) then writeln(fp,'1') else writeln(fp,'0');
writeln(fp,thisuser.pagelen);
if spd<>'KB' then writeln(fp,cstrl(answerbaud)) else writeln(fp,modemr^.waitbaud);
if spd<>'KB' then writeln(fp,modemr^.comport) else writeln(fp,'0');
writeln(fp,cstrl(trunc(timeremaining)));
close(fp);
end;

procedure write_sfdoors_dat(path:string;rname:boolean);   { Spitfire SFDOORS.DAT }
var fp:text;
    s:string;
begin
  assign(fp,path+'SFDOORS.DAT');
  rewrite(fp);
  writeln(fp,cstr(usernum));
  if (rname) then writeln(fp,allcaps(thisuser.realname)) else writeln(fp,allcaps(thisuser.name));
  writeln(fp,thisuser.pw);
  if (rname) then begin
    if (pos(' ',thisuser.realname)=0) then s:=thisuser.realname
    else s:=copy(thisuser.realname,1,pos(' ',thisuser.realname)-1);
  end else begin
    if (pos(' ',thisuser.name)=0) then s:=thisuser.name
    else s:=copy(thisuser.name,1,pos(' ',thisuser.name)-1);
  end;
  writeln(fp,s);
  if (spd='KB') then writeln(fp,'0') else writeln(fp,cstrl(answerbaud));
  writeln(fp,cstr(modemr^.comport));
  writeln(fp,timestr);
  writeln(fp,'0');   { seconds since midnight }
  writeln(fp,start_dir+'\');
  if okansi then writeln(fp,'TRUE') else writeln(fp,'FALSE');
  writeln(fp,cstr(thisuser.sl));
  writeln(fp,cstr(thisuser.uploads));
  writeln(fp,cstr(thisuser.downloads));
  if (security.timepercall<>0) then writeln(fp,cstr(security.timepercall))
  else
  writeln(fp,cstr(security.timeperday));
  writeln(fp,'0');   { time on (seconds) }
  writeln(fp,'0');   { extra time (seconds) }
  writeln(fp,'FALSE');
  writeln(fp,'TRUE');
  writeln(fp,'FALSE');
  if (spd='KB') then writeln(fp,'0') else writeln(fp,spd);
  if (spdarq) then writeln(fp,'TRUE') else writeln(fp,'FALSE');
  writeln(fp,cstr(board));
  writeln(fp,cstr(fileboard));
  writeln(fp,cstr(cnode));
  writeln(fp,'0');
  writeln(fp,'0');
  writeln(fp,'0');
  writeln(fp,'0');
  writeln(fp,cstr(trunc(thisuser.uk)));
  writeln(fp,cstr(trunc(thisuser.dk)));
  writeln(fp,thisuser.phone1);
  writeln(fp,thisuser.citystate);
  if (security.timepercall<>0) then writeln(fp,cstr(security.timepercall))
  else
  writeln(fp,cstr(security.timeperday));
  writeln(fp,'FALSE');
  if (chatr<>'') then writeln(fp,'TRUE') else
  writeln(fp,'FALSE');
  writeln(cstr(trunc(timeremaining)));
  writeln('0');
  writeln(showdatestr(thisuser.subdate));
  close(fp);
end;

procedure dodoorfunc(cline:string;editors:boolean);
var doorstart,doorend,doortime:datetimerec;
    s2,srdoor,s,cline2:string;
    retcode,savsl,savdsl:integer;
    realname:boolean;
    doorfile:file of doorrec;
    drec:doorrec;
begin
  realname:=FALSE;
  srdoor:=online.activity;
  if ((sqoutsp(cline)='') and (incom)) then begin
    sprint('%120%Door Not Specified.  Please Inform Sysop.');
    sl1('!','Command String for Door Menu command was empty.');
    editorok:=FALSE;
    exit;
  end;

  if (realsl<>-1) then begin
    savsl:=thisuser.sl;
    thisuser.sl:=realsl;
    saveuf;
  end;
  if (cline='') then begin
        sprint('%120%Error Accessing Door #'+cline+'...');
	sl1('!','Door Definition does not exist for Door #'+cline);
        editorok:=FALSE;
	exit;
  end;
  if (value(cline)=0) and (cline<>'0') then begin
        sprint('%120%Error Accessing External Chat Program...');
	sl1('!','Door Definition does not exist for Door #'+cline+' (chat)');
        editorok:=FALSE;
	exit;
  end;
  if (editors) then assign(doorfile,adrv(systat^.gfilepath)+'EDITORS.DAT') else
  assign(doorfile,adrv(systat^.gfilepath)+'DOORS.DAT');
  {$I-} reset(doorfile); {$I+}
  if (ioresult<>0) then begin
	if (editors) then begin
        sprint('%120%Error Accessing Editors...');
        sl1('!','Error Opening '+allcaps(adrv(systat^.gfilepath)+'EDITORS.DAT'));
        editorok:=FALSE;
	exit;
	end else begin
        sprint('%120%Error Accessing Doors...');
        sl1('!','Error Opening '+allcaps(adrv(systat^.gfilepath)+'DOORS.DAT'));
	exit;
	end;
  end;
  if (value(cline)>filesize(doorfile)-1) then begin
	if (editors) then begin
        sprint('%120%Error Accessing Editor #'+cline+'...');
        sl1('!','Editor Definition does not exist for Editor #'+cline);
        editorok:=FALSE;
	exit;
	end else begin
        sprint('%120%Error Accessing Door #'+cline+'...');
	sl1('!','Door Definition does not exist for Door #'+cline);
	exit;
	end;
  end;
  seek(doorfile,value(cline));
  read(doorfile,drec);
  close(doorfile);
  online.available:=FALSE;
  if (editors) then
  online.activity:='Editor: '+copy(stripcolor(drec.doorname),1,14)
  else
  online.activity:='Door: '+copy(stripcolor(drec.doorname),1,14);
  updateonline;
  cline2:=cline;
  realname:=drec.realname;
  s:=process_door(drec.doorfilename);
  s2:=process_door(drec.doordroppath);
  if s2[length(s2)]<>'\' then s2:=s2+'\';
  if not(drec.doordroptype=7) then
  if not(existdir(s2)) then begin
	if (editors) then begin
	sl1('!','Dropfile Path For '+stripcolor(drec.doorname)+' Does Not Exist.  Not Running Editor.');
	sprint('%120%Error Running Editor %150%'+drec.doorname);
        editorok:=FALSE;
	pausescr;
	end else begin
	sl1('!','Dropfile Path For '+stripcolor(drec.doorname)+' Does Not Exist.  Not Running Door.');
	sprint('%120%Error Running Door %150%'+drec.doorname);
	pausescr;
	end;
	exit;
  end;
  if ((trunc(nsl/60)<drec.maxminutes) or (drec.maxminutes<=0)) then timeremaining:=nsl/60 else
	timeremaining:=drec.maxminutes;
  case drec.DoorDropType of
    { DOOR.SYS }
    1:begin
          write_door_sys(s2,realname);
      end;
    { DOORFILE.SR }
    2:begin
          write_doorfile_sr(s2,realname);
      end;
    { CHAIN.TXT }
    3:begin
          write_chain_txt(s2);
      end;
    { DORINFO1.DEF }
    4:begin
          write_dorinfo1_def(s2,realname);
      end;
    { SFDOORS.DAT }
    5:begin
          write_sfdoors_dat(s2,realname);
      end;
    { CALLINFO.BBS }
    6:begin
          write_callinfo_bbs(s2,realname);
      end;
    { NO DROP FILE }
    7:begin end; 
    else begin
	if (editors) then begin
        sprint('%120%Error Accessing Editor #'+cline+'...');
	sl1('!','Door Drop File type is invalid for Editor #'+cline);
        editorok:=FALSE;
	exit;
	end else begin
        sprint('%120%Error Accessing Door #'+cline+'...');
	sl1('!','Door Drop File type is invalid for Door #'+cline);
	exit;
	end;
    end;
  end;
  if (drec.showloadingstring) then begin
  nl;
  sprint('%030%Now running %140%'+drec.DOORName+'%030%...');
  nl;
  end;

  if (editors) then 
  sl1('d','Running Editor     : '+stripcolor(drec.DOORName))
  else
  sl1('d','Running Door       : '+stripcolor(drec.DOORName));
  sl1('d','Commandline        : '+s);
  
  getdatetime(doorstart);
  shelling:=4;
  shel('Running Door: '+stripcolor(drec.DoorName));
  retcode:=0;
  shelldos(FALSE,s,retcode); 
  shel2;
  getdatetime(doorend);
  timediff(doortime,doorstart,doorend);

  inc(drec.tracktoday.timesused);
  inc(drec.tracktoday.minutesused,trunc(dt2r2(doortime)));

  inc(drec.trackforever.timesused);
  inc(drec.trackforever.minutesused,trunc(dt2r2(doortime)));

  {$I-} reset(doorfile); {$I+}
  if (ioresult<>0) then begin
	if (editors) then begin
        sl1('!','Error Opening '+allcaps(adrv(systat^.gfilepath)+'EDITORS.DAT'));
        sl1('!','Tracking record not updated.');
	exit;
	end else begin
        sl1('!','Error Opening '+allcaps(adrv(systat^.gfilepath)+'DOORS.DAT'));
        sl1('!','Tracking record not updated.');
	exit;
	end;
  end;
  {$I-} seek(doorfile,value(cline)); {$I+}
  if (ioresult<>0) then begin
	if (editors) then begin
	sl1('!','Editor Definition does not exist for Door #'+cline);
        sl1('!','Tracking record not updated.');
	exit;
	end else begin
	sl1('!','Door Definition does not exist for Door #'+cline);
        sl1('!','Tracking record not updated.');
	exit;
	end;
  end;
  write(doorfile,drec);
  close(doorfile);
  chdir(start_dir);

  if (realsl<>-1) then begin
    reset(uf); seek(uf,usernum); read(uf,thisuser); close(uf);
    thisuser.sl:=savsl;
  end;

  if (com_carrier) then com_flush_rx;
  getdatetime(tim);
  
  sl1('d','Returned           : '+longtim(doortime)+' spent');
  online.activity:=srdoor;
  online.available:=TRUE;
  updateonline;
  checkhangup;
end;

function gettags:boolean;
var doorfile:file of doorrec;
    drec:doorrec;
begin
  assign(doorfile,adrv(systat^.gfilepath)+'EDITORS.DAT');
  {$I-} reset(doorfile); {$I+}
  if (ioresult<>0) then begin
        sl1('!','Error Opening '+allcaps(adrv(systat^.gfilepath)+'EDITORS.DAT'));
	exit;
  end;
  if (thisuser.msgeditor>filesize(doorfile)-1) then begin
        sl1('!','Editor Definition does not exist for Editor #'+cstr(thisuser.msgeditor));
	exit;
  end;
  seek(doorfile,thisuser.msgeditor);
  read(doorfile,drec);
  close(doorfile);
  if (SelectTagline in drec.eflags) then gettags:=TRUE else gettags:=FALSE;
end;

end.
