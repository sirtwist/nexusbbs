{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R-,S+,V-}
unit miscx;

interface

uses
  crt, dos,
  common,
  doors,
  misc1;

procedure finduser(var s:astr; var usernum:integer);
procedure dsr(uname:astr; unum:integer);
procedure isr(uname,ureal:astr; usernum:integer; UID:LONGINT);
procedure logon1st;

implementation

uses
  archive1,myio3,mkstring,mkmisc;

procedure finduser(var s:astr; var usernum:integer);
var user:userrec;
    sr:smalrec;
    nn:astr;
    i,ii,t:integer;
    sfo,ufo,dn:boolean;
begin
  nn:='';
  if (s<>'') then nn:=s;
  s:=''; usernum:=0;
  repeat
  dn:=TRUE;
  if (nn='') then inputcaps(nn,36);
  while (copy(nn,1,1)=' ') do nn:=copy(nn,2,length(nn)-1);
  while (copy(nn,length(nn),1)=' ') do nn:=copy(nn,1,length(nn)-1);
  while (pos('  ',nn)<>0) do delete(nn,pos('  ',nn),1);
  if not(systat^.aliasprimary) then
        if ((pos(' ',nn)=0) and (nn<>'') and (allcaps(nn)<>'NEW')) then begin
                sprompt(gstring(21));
                sprompt(gstring(1));
                nn:='';
                dn:=FALSE;
        end;
  until (dn) or (hangup);
  if ((hangup) or (nn='')) then exit;
  s:=nn;
  if (nn<>'') then begin
      sfo:=(filerec(sf).mode<>fmclosed);
      if (not sfo) then reset(sf);
      ii:=0; t:=1;
      while ((t<=filesize(sf)-1) and (ii=0)) do begin
        seek(sf,t); read(sf,sr);
        if (systat^.aliasprimary) then begin
        if (allcaps(nn)=allcaps(sr.name)) or (allcaps(nn)=allcaps(sr.real)) then
                ii:=sr.number;
        end else begin
        if (allcaps(nn)=allcaps(sr.real)) then ii:=sr.number;
        end;
        inc(t);
      end;
      if (ii<>0) then usernum:=ii;
    end;
    if (allcaps(nn)='NEW') then usernum:=-1;
    if (usernum=0) then begin
        sprompt(gstring(9));
        sl1('!','Logon name not found: '+nn);
    end;
    if (not sfo) then close(sf);
end;

procedure dsr(uname:astr; unum:integer);
var t,ii:integer;
    sr:smalrec;
    sfo:boolean;
    uidf:file of useridrec;
    uid:useridrec;
    found:boolean;
begin
  sfo:=(filerec(sf).mode<>fmclosed);
  if (not sfo) then reset(sf);

  ii:=0; t:=1;
  while ((t<=filesize(sf)-1) and (ii=0)) do begin
    seek(sf,t); read(sf,sr);
    if (allcaps(sr.name)=allcaps(uname)) and (sr.number=unum) then ii:=t;
    inc(t);
  end;

  if (ii<>0) then begin
    if (ii<>filesize(sf)-1) then
      for t:=ii to filesize(sf)-2 do begin
        seek(sf,t+1); read(sf,sr);
        seek(sf,t); write(sf,sr);
      end;
    seek(sf,filesize(sf)-1); truncate(sf);
    dec(syst.numusers); savesystat;
  found:=FALSE;
  assign(uidf,adrv(systat^.gfilepath)+'USERID.IDX');
  {$I-} reset(uidf); {$I+}
  if (ioresult=0) then begin
        while not(eof(uidf)) and not(found) do begin
                read(uidf,uid);
                if (uid.number=unum) then begin
                        found:=TRUE;
                        uid.number:=-1;
                        seek(uidf,filepos(uidf)-1);
                        write(uidf,uid);
                end;
        end;
  close(uidf);
  end;
  end
  else sl1('!','Could not delete '+uname);
  if (not sfo) then close(sf);
end;

procedure isr(uname,ureal:astr; usernum:integer; UID:LONGINT);
var t,i,ii:integer;
    sr:smalrec;
    sfo:boolean;
    uidf:file of useridrec;
    uid2:useridrec;
begin
  sfo:=(filerec(sf).mode<>fmclosed);
  if (not sfo) then reset(sf);

  with sr do begin
  name:=caps(uname);
  real:=caps(ureal);
  number:=usernum;
  UserID:=UID;
  end;
  seek(sf,filesize(sf)); write(sf,sr);
  {$I-} reset(systemf); {$I-}
  if (ioresult=0) then begin
        read(systemf,syst);
        inc(syst.numusers);
        seek(systemf,0);
        write(systemf,syst);
        close(systemf);
  end;
  if (not sfo) then close(sf);
  assign(uidf,adrv(systat^.gfilepath)+'USERID.IDX');
  {$I-} reset(uidf); {$I+}
  if (ioresult<>0) then begin
        sprint('%120%ERROR: %150%Unable to create User Record.  Exiting...');
        sl1('!','Unable to open USERID.IDX!');
        hangup2:=TRUE;
  end else begin
        seek(uidf,filesize(uidf));
        uid2.UserID:=UID;
        uid2.Number:=UserNum;
        write(uidf,uid2);
        close(uidf);
  end;
  savesystat;
end;

procedure logon1st;
var u:userrec;
    doorfile:file of doorrec;
    drec:doorrec;
    t:text;
    f:file;
    fil:file of astr;
    zf:file of CallInfoREC;
    d1,d2:CallInfoREC;
    s,s1:astr;
    x,n,z,c1,num,rcode:integer;
    c:char;
    abort:boolean;
begin
  if (spd<>'KB') then begin
    inc(syst.callernum);
    inc(curact^.calls);
  end;

  realsl:=thisuser.sl;
  purgedir(newtemp);

  unixtodt(syst.lastdate,fddt);
  if (formatteddate(fddt,'MM/DD/YYYY')<>datelong) then begin
    fillchar(d1,sizeof(d1),#0);
    assign(zf,adrv(systat^.gfilepath)+'CALLINFO.DAT');
    {$I-} reset(zf); {$I+}
    if (ioresult<>0) then begin
      rewrite(zf);
      d1.date:=0;
      write(zf,d1);
    end;
    d1.date:=u_daynum(datelong);
    seek(zf,filesize(zf));
    write(zf,d1);
    close(zf);
    fillchar(d1,sizeof(d1),#0);
    assign(zf,adrv(systat^.gfilepath)+'CALLINFO.'+cstrnfile(cnode));
    {$I-} reset(zf); {$I+}
    if (ioresult<>0) then begin
      rewrite(zf);
      d1.date:=0;
      write(zf,d1);
    end;
    d1.date:=u_daynum(datelong);
    seek(zf,filesize(zf));
    write(zf,d1);
    close(zf);
    
    assign(doorfile,adrv(systat^.gfilepath)+'EDITORS.DAT');
    {$I-} reset(doorfile); {$I+}
    if (ioresult=0) then begin
        while not(eof(doorfile)) do begin
                read(doorfile,drec);
                drec.trackyesterday.timesused:=drec.tracktoday.timesused;
                drec.trackyesterday.minutesused:=drec.trackyesterday.minutesused;
                drec.tracktoday.timesused:=0;
                drec.tracktoday.minutesused:=0;
                seek(doorfile,filepos(doorfile)-1);
                write(doorfile,drec);
       end;
       close(doorfile);
    end;
    assign(doorfile,adrv(systat^.gfilepath)+'DOORS.DAT');
    {$I-} reset(doorfile); {$I+}
    if (ioresult=0) then begin
        while not(eof(doorfile)) do begin
                read(doorfile,drec);
                drec.trackyesterday.timesused:=drec.tracktoday.timesused;
                drec.trackyesterday.minutesused:=drec.trackyesterday.minutesused;
                drec.tracktoday.timesused:=0;
                drec.tracktoday.minutesused:=0;
                seek(doorfile,filepos(doorfile)-1);
                write(doorfile,drec);
       end;
       close(doorfile);
    end;
    enddayf:=TRUE;
    cursoron(TRUE);
  end;

  opensysopf;
  blockwritestr(sysopf,''+#13#10);
  close(sysopf);
  sl1('+',nam+' logged on (node '+cstr(cnode)+')');
  sl1('~','Caller #   : '+mln(cstr(syst.callernum),6)+' Calls today: '+mln(cstr(thisuser.ontoday+1),6));
  sl1('~','Calls total: '+mln(cstr(thisuser.loggedon),6));

  if (trapping) then begin
  sl1('i','Global Trapping enabled');
  end;
  syst.lastdate:=u_daynum(datelong);
  savesystat;
  {$I-} reset(systemf); {$I+}
  if (ioresult<>0) then begin
        sl1('!','Error Updating SYSTEM.DAT');
  end else begin
        write(systemf,syst);
        close(systemf);
  end;
end;

end.
