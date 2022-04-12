{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
{                        Next Epoch matriX User System                       }
{                                                                            }
{                             Module: MISC2.PAS                              }
{                                                                            }
{                                                                            }
{ All Material Contained Herein Is Copyright 1995 Intuitive Vision Software. }
{                            All Rights Reserved.                            }
{                                                                            }
{                       Written By George A. Roberts IV                      }
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R-,S+,V-}
unit misc2;

interface

uses
  crt, dos,
  common;

procedure bulletins(par:astr);
procedure ulist(s1:astr;s2:string);
procedure yourinfo;

implementation

uses file2,archive1,file8,mkmisc,mkstring;

procedure bulletins(par:astr);
var filv:text;
    main,subs,s,s2,s3,s4:astr;
    af:file of archiverrec;
    a:archiverrec;
    d:searchrec;
    td,td2:datetime;
    x2,i:integer;
    errors:byte;
    ok2:byte;
    displayonly,found,ok,nospace,dok,kabort:boolean;

    function zero(w:word):string;
    var s:string;
    begin
    s:=cstr(w);
    if length(s)=1 then s:='0'+s;
    zero:=s;
    end;

    function compdate(dt:datetime;t:datetime):boolean;
    begin
     compdate:=true;
     if (t.year<dt.year) then compdate:=false else
        if (t.month<dt.month) then compdate:=false else
                if (t.day<dt.day) then compdate:=false else
                        if (t.hour<dt.hour) then compdate:=false else
                                if (t.min<dt.min) then compdate:=false;
    end;

begin
  nl;
  ok:=false;
  nospace:=false;
  displayonly:=FALSE;
  if (par='DISPLAY') then displayonly:=TRUE;
  main:='newsmenu';
  subs:='news';
  s2:='';
      for x2:=1 to 100 do begin
      found:=FALSE;
      findfirst(adrv(systat^.afilepath)+subs+cstr(x2)+'.*',anyfile,d);
      if (doserror=0) then begin
        if (allcaps(d.name)=allcaps(subs+cstr(x2)+'.ANS')) or
                (allcaps(d.name)=allcaps(subs+cstr(x2)+'.TXT'))
                or (allcaps(d.name)=allcaps(subs+cstr(x2)+'.RIP')) then begin
                dos.unpacktime(d.time,td);
                fillchar(td2,sizeof(td2),#0);
                unixtodt(thisuser.laston,fddt);
                td2.year:=value(formatteddate(fddt,'YYYY'));
                td2.day:=value(formatteddate(fddt,'DD'));
                td2.month:=value(formatteddate(fddt,'MM'));
                if (compdate(td,td2)) then found:=TRUE;
                end;
      end;
      if not(found) then begin
      findnext(d);
      while (doserror=0) and not(found) do begin
        if (allcaps(d.name)=allcaps(subs+cstr(x2)+'.ANS')) or
                (allcaps(d.name)=allcaps(subs+cstr(x2)+'.TXT'))
                or (allcaps(d.name)=allcaps(subs+cstr(x2)+'.RIP')) then begin
                dos.unpacktime(d.time,td);
                unixtodt(thisuser.laston,fddt);
                td2.year:=value(formatteddate(fddt,'YYYY'));
                td2.day:=value(formatteddate(fddt,'DD'));
                td2.month:=value(formatteddate(fddt,'MM'));
                if (compdate(td,td2)) then found:=TRUE;
                end;
                findnext(d);
      end;
      end;
      if (found) then begin
      if (s2<>'') then s2:=s2+'%090%,';
      s2:=s2+'%030%'+cstr(x2);
      end;
      end;

  if (displayonly) then begin
      nl;
      if (s2<>'') then begin
        sprint('%090%Updated News Files: '+s2);
      end else begin
        sprint('%090%Updated News Files: %150%None');
      end;
      nl;
      exit;
  end;

  printf(main);
      repeat
      i:=8-length(subs); if (i<1) then i:=1;
      if (s2<>'') then begin
        sprint('%090%Updated News Files: '+s2);
      end else begin
        sprint('%090%Updated News Files: %150%None');
      end;
      sprompt(gstring(45));
      scaninput(s,'Q?D'^M,TRUE);
      if (not hangup) then begin
        if (s='?') then printf(main);
	if (s='D') then begin
		dyny:=false;
                if pynq('%120%Download All News Files? %110%')then begin
			dyny:=true;
                        sprompt('%030%Preparing NEWS for download... ');
                        findfirst(adrv(systat^.afilepath)+subs+'*.*',anyfile,d);
			if (doserror=0) and (allcaps(copy(d.name,1,length(main)))<>allcaps(main)) 
				then begin
                                file2.copyfile(ok,nospace,FALSE,adrv(systat^.afilepath)+
					d.name,newtemp+'WORK\'+d.name);
				if not(ok) then begin
                                        sprint('%120%Error Including '+d.name+'.');
				end;
			end;
			if not(nospace) then begin
				while (doserror=0) do begin
					findnext(d);
				if (doserror=0) and (allcaps(copy(d.name,1,length(main)))<>allcaps(main)) 
					then begin
                                        file2.copyfile(ok,nospace,FALSE,adrv(systat^.afilepath)+
					d.name,newtemp+'WORK\'+d.name);
					if not(ok) then begin
                                                sprint('%120%Error Including '+d.name+'.');
					end;
				end;                                                
			  end;
			if (nospace) then exit;
			end;
			if (nospace) then begin
                                sprint('Out of Drive Space to Archive News.');
			end;
                        sprompt('%150%Finished!|LF||LF|');
                        ok:=false;
                        ok2:=1;
			if not(nospace) then begin
				s3:='';
				repeat
					archive1.listarctypes2;
                                        sprompt('%090%Selection [%150%Q%090%=Quit] : %150%');
					scaninput(s3,'Q?',TRUE);
					if (s3='?') then archive1.listarctypes2;
				until (s3<>'?');
                                if (s3<>'Q') then begin
                                if (getarcext(value(s3))<>'') then
                                archive1.arccomp(ok2,value(s3),newtemp+'NEWS.'+getarcext(value(s3)),
                                        newtemp+'WORK\*.*');
                                end;
			end;                        
                        if (s3<>'Q') and (ok2=0) then begin
                        s3:=newtemp+'NEWS.'+a.extension;
			file8.send1(s3,dok,kabort);
			while not(dok) and not(kabort) do begin
				dyny:=TRUE;
                                if pynq('%120%Download Unsuccessful.  Try again? %110%') then begin
					send1(s3,dok,kabort);
				end else dok:=TRUE;
			end;
		end;
		end else begin
                        sprompt('%090%News File [%150%1%090%-%150%100%090%,%150%Q%090%uit] : %150%');
                        scaninput(s,'Q',TRUE);
                        if (s<>'Q') and (value(s)>=1) and (value(s)<=100) then begin
                        s3:=adrv(systat^.afilepath)+subs+cstr(value(s))+'.ANS';
                        if not(exist(s3)) then s3:=adrv(systat^.afilepath)+subs+cstr(value(s))+'.TXT';
			if not(exist(s3)) then begin
                                sprint('%150%News File Does Not Actually Exist.');
			end else begin
                        sprint('%030%Sending: %150%News File '+allcaps(cstr(value(s))));
			file8.send1(s3,dok,kabort);
			while not(dok) and not(kabort) do begin
				dyny:=TRUE;
                                if pynq('%120%Download Unsuccessful.  Try again? %110%') then begin
					send1(s3,dok,kabort);
				end else dok:=TRUE;
			end;
			end;
			end;
			end;
		end;
        if ((s<>'Q') and (s<>'?') and (s<>'D') and (s<>'') and (value(s)>=1) and (value(s)<=100)) then begin
                printf(subs+cstr(value(s)));
                if (nofile) then sprint('%150%Invalid Selection.');
		end;
      end;
    until ((s='Q') or (s='') or (hangup));
end;

procedure ulist(s1:astr;s2:string);
var u:userrec;
    sr:smalrec;
    s:astr;
    s4:string;
    i,j:integer;
    abort,next,sfo:boolean;

function nam2:string;
begin
  if (systat^.aliasprimary) then
  nam2:=caps(u.name) else
  nam2:=caps(u.realname);
end;

begin
  sfo:=(filerec(sf).mode<>fmclosed);
  if (not sfo) then begin
        {$I-} reset(sf); {$I+}
        if (ioresult<>0) then begin
                sl1('!','Error opening USERS.IDX');
                exit;
        end;
  end;
  if (s2='') then sprompt(gstring(150))
  else
  sprompt(s2);
  sprompt(gstring(151));
  sprompt(gstring(152));
  sprompt(gstring(153));
  sprompt(gstring(154));
  reset(uf);
  i:=0; j:=0;
  abort:=FALSE;
  mpausescr:=TRUE;
  printingfile:=TRUE;
  s4:=gstring(155);
  while (not abort) and not(mabort) and (i<filesize(sf)-1) do begin
    inc(i);
    seek(sf,i);
    read(sf,sr);
    if (sr.number<filesize(uf)) then begin
    seek(uf,sr.number);
    read(uf,u);
    ulname:=nam2;
    ulcall:=u.business;
    ulgen:=u.sex;
    ullast:=u.laston;
    if (aacs1(u,u.userid,s1)) then begin
      sprompt(s4);
      inc(j);
    end;
    end;
  end;
  if (not abort) and not(mabort) then begin
    nl;
    s:=' User';
    if (j<>1) then s:=s+'s';
    s:=s+' Listed.';
    sprint('%140%'+cstr(j)+s);
  end;
  close(uf);
  mpausescr:=FALSE;
  printingfile:=FALSE;
  if (not sfo) then close(sf);
end;

procedure yourinfo;
begin
printf('USERINFO');
if (nofile) then begin
cls;
sprint('%070%Real Name       : %030%'+mln(thisuser.realname,36));
sprint('%070%Alias           : %030%'+mln(thisuser.name,36));
sprint('%070%Address         : %030%'+mln(thisuser.street,30));
sprint('%070%                : %030%'+mln(thisuser.street2,30));
sprint('%070%                : %030%'+mln(thisuser.citystate+' '+thisuser.zipcode,50));
sprint('%070%Voice Phone     : %030%'+mln(thisuser.phone1,20));
sprint('%070%Data Phone      : %030%'+mln(thisuser.phone2,20));
nl;
sprint('%070%Calls       : %030%'+mln(cstr(thisuser.loggedon),5)+'%070%  Calls Today  : %030%'+
        mln(cstr(thisuser.ontoday),5));
sprint('%070%Msgs Posted : %030%'+mln(cstr(thisuser.msgpost),5)+'%070%  Feedback     : %030%'+
        mln(cstr(thisuser.feedback),5));
nl;
end;
end;

end.
