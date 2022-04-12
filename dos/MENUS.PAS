{nexus nexus nexus nexus nexus nexus nexus nexus nexus nexus nexus nexus nexu}
{ nexus nexus nexus  млмммм   ммммм  лмм ммл млм мм   ммммм   nexus nexus nex}
{s nexus nexus nexus Блл Блл Блл  Бл Блл Блл Блл Блл Блл  пл s nexus nexus ne}
{us nexus nexus nexu Алл Алл АллммАл Алл Алл Алл Алл Алл     us nexus nexus n}
{xus nexus nexus nex Алл Алл Алл       мпм   Алл Алл пллм    xus nexus nexus }
{exus nexus nexus ne Алл Алл Алл     Алл Алл Алл Алл    пллм exus nexus nexus}
{nexus nexus nexus n Алл Алл Алл  м  Алл Алл Алл Алл м   Алл nexus nexus nexu}
{ nexus nexus nexus  Алп Алп  ллллп  Алп Алл АллмАлп плллллп  nexus nexus nex}
{s nexus nexus nexus NEXUS   BULLETIN    Алл  BOARD   SYSTEM s nexus nexus ne}
{us nexus nexus nexus nexus nexus nexus n пп  nexus nexus nexus nexus nexus n}
{xus nexus nexus nexus nexus nexus nexus nexus nexus nexus nexus nexus nexus }
{============================================================================}
{                                                                            }
{                      Nexus Bulletin Board System v1.00                     }
{                                                                            }
{ MODULE: MENUS.PAS                                                          }
{ DESC  : Main Menu Source File                                              }
{                                                                            }
{ All material contained herein is copyright 1995-2000 George A. Roberts IV. }
{ All rights reserved.                                                       }
{                                                                            }
{============================================================================}
{$A+,B+,D-,E+,F+,I+,L+,N-,O-,R-,S+,V-}
Unit Menus;

Interface

Uses
  Crt,      Dos,      InitP,    Mail0,    Mail1,    Mail3,    
  Mail6,    Mail9,    File0,    File1,    File2,    File4,
  File5,    File6,    File7,    File8,    File9,    File10,   File11,
  File12,   File14,   Archive1, Archive2, Misc1,    file25,
  Misc2,    Misc3,    MiscX,    CUser,    Doors,    Menus2, 
  Menus3,   myio3,    Common,   mainmail, runprog,  script;

Procedure readin2;
Procedure mainmenuhandle(var cmd:string);
procedure fcmd(var cmd:string; var i:integer; noc:integer;
	       var cmdexists,cmdnothid:boolean);
Procedure domenuexec(cmd:string; var newmenucmd:string);
Procedure domenucommand(var done:boolean; cmd:string; var newmenucmd:string);

Implementation

uses newusers;

const firstbase:boolean=FALSE;
var oboard:integer;

procedure dosc;
  var s:string;
      i:integer;
begin
    s:=^M^J+#27+'[0m';
    for i:=1 to length(s) do dosansi(s[i]);
end;

Procedure readin2;
var s:string;
    nacc:boolean;
begin
{  actions:=[];}
  readin(true);
  nacc:=FALSE;
  with menur do begin
    if ((not aacs(acs)) or (accesskey<>'')) then
    begin
      nacc:=TRUE;
      if (accesskey<>'') then
      begin
      nl; sprompt(gstring(4)); input(s,15);
	if (s=accesskey) then nacc:=FALSE;
      end;
      if (nacc) then
      begin
	nl; print('Access Denied.'); pausescr;
	print('Dropping To Fallback Menu.');
	curmenu:=fallback;
	readin(true);
      end;
    end;
    if (not nacc) then
      if (forcehelplevel<>0) then
	chelplevel:=forcehelplevel
      else
	if (novice in thisuser.ac) then chelplevel:=2 else chelplevel:=1;
  end;
end;

procedure checkforcelevel;
begin
  if (chelplevel<menur.forcehelplevel) then chelplevel:=menur.forcehelplevel;
end;

procedure getcmd(var s:string);
var s1,ss,oss,shas0,shas1:string;
    i:integer;
    c:char;
    oldco,oldco2:byte;
    gotcmd,has0,has1,has2:boolean;
begin
  s:='';
  if (buf<>'') then
    if (copy(buf,1,1)='`') then
    begin
      buf:=copy(buf,2,length(buf)-1);
      i:=pos('`',buf);
      if (i<>0) then
      begin
	s:=allcaps(copy(buf,1,i-1)); buf:=copy(buf,i+1,length(buf)-i);
	nl; exit;
      end;
    end;

  shas0:='?|'; shas1:='';
  has0:=FALSE; has1:=FALSE; has2:=FALSE;

  { find out what kind of 0:"x", 1:"/x", and 2:"//xxxxxxxx..." commands
    are in this menu. }

  for i:=1 to noc do 
    if (aacs(cmdr[i].acs)) then
      if (cmdr[i].ckeys[0]=#1) then
      begin
	has0:=TRUE; shas0:=shas0+cmdr[i].ckeys;
      end else
        if ((cmdr[i].ckeys[1]='/') and (cmdr[i].ckeys[0]=#2)) then begin
	  has1:=TRUE;
          shas1:=shas1+cmdr[i].ckeys[2];
        end else begin
          if (allcaps(cmdr[i].ckeys)='!ENTER') then shas0:=shas0+#13;
          if (allcaps(cmdr[i].ckeys)='!ESC') then shas0:=shas0+#27;
          if (allcaps(cmdr[i].ckeys)='!BS') then shas0:=shas0+#8;
          if (allcaps(cmdr[i].ckeys)='!SPACE') then shas0:=shas0+#32;
          has2:=TRUE;
        end;

  oldco:=curco;
  oldco2:=lastco;

  gotcmd:=FALSE; ss:='';
  if (not (onekey in thisuser.ac)) then begin
    semaphore:=TRUE;
    input(s,60);
    semaphore:=false;
  end else begin
    repeat
      semaphore:=TRUE;
      if (mc<>#0) then begin
          c:=mc; mc:=#0;
      end else begin
          c:=#0; mc:=#0;
          getkey(c); c:=upcase(c);
      end;
      semaphore:=false;
      oss:=ss;
      if (ss='') then begin
        if ((c='/') and ((has1) or (has2) or (thisuser.sl=100))) then begin
                mpl(2);
                ss:='/';
        end;
        if (((fqarea) or (mqarea){ or (curmenu=7)}) and (c in ['0'..'9'])) then ss:=c
        else
        if (pos(c,shas0)<>0) then begin
                gotcmd:=TRUE;
                ss:=c;
        end;
        if not(gotcmd) and (c=#13) then gotcmd:=TRUE;
      end else
	if (ss='/') then begin
	  if (c=^H) then ss:='';
          if ((c='/') and ((has2) or (thisuser.sl=100))) then begin
                ss:=ss+'/';
                mpl(77-pap);
          end;
	  if ((pos(c,shas1)<>0) and (has1)) then
	    begin gotcmd:=TRUE; ss:=ss+c; end;
	end else
	  if (copy(ss,1,2)='//') then begin
	    if (c=#13) then
	      gotcmd:=TRUE
	    else
	      if (c=^H) then
		ss:=copy(ss,1,length(ss)-1)
	      else
		if (c=^X) then begin
		  for i:=1 to length(ss)-2 do
		    prompt(^H' '^H);
		  ss:='//';
		  oss:=ss;
		end else
		  if ((length(ss)<62) and (c>=#32) and (c<=#127)) then
		    ss:=ss+c;
	  end else
	    if ((length(ss)>=1) and (ss[1] in ['0'..'9']) and
                ((fqarea) or (mqarea){ or (curmenu=7)})) then begin
	      if (c=^H) then ss:=copy(ss,1,length(ss)-1);
	      if (c=#13) then gotcmd:=TRUE;
	      if (c in ['0'..'9']) then begin
		ss:=ss+c;
		if (length(ss)=5) then gotcmd:=TRUE;
	      end;
	    end;

      if ((length(ss)=1) and (length(oss)=2)) then setc(oldco);
      if (oss<>ss) then begin
	if (length(ss)>length(oss)) then prompt(copy(ss,length(ss),1));
	if (length(ss)<length(oss)) then prompt(^H' '^H);
      end;
      if ((not (ss[1] in ['0'..'9'])) and
        ((length(ss)=2) and (length(oss)=1))) then setc(7 or (0 shl 4));

    until ((gotcmd) or (hangup));

    if (copy(ss,1,2)='//') then ss:=copy(ss,3,length(ss)-2);

    s:=ss;
  end;
  semaphore:=FALSE;
  nl;

  if (pos(' ',s)<>0) then                 {* "command macros" *}
    if (copy(s,1,2)<>'\\') then begin
      if (onekey in thisuser.ac) then begin
         s1:=copy(s,2,length(s)-1);
	 if (copy(s1,1,1)='/') then s:=copy(s1,1,2) else s:=copy(s1,1,1);
	 s1:=copy(s1,length(s)+1,length(s1)-length(s));
      end else begin
        s1:=copy(s,pos(' ',s)+1,length(s)-pos(' ',s))+^M;
        s:=copy(s,1,pos(' ',s)-1);
      end;
      while (pos(' ',s1)<>0) do s1[pos(' ',s1)]:=^M;
      dm(' '+s1,c);
    end;
  setc(oldco2);
end;

procedure mainmenuhandle(var cmd:string);
var newarea:integer;
    dn:boolean;
begin
  dn:=false;
  while not(dn) do begin
  loadboard(board);
  loaduboard(fileboard);
  tleft;
  checkforcelevel;

(*  if (curmenu=7) then begin
          lastcommandgood:=FALSE;
          if (chelplevel=3) then begin
                showthismenu;
          end else begin
                  if (showmessage in actions) then begin
                        displaynextmessage;
                        actions:=actions-[showmessage];
                  end;
          end;
          online.activity:='Reading Messages';
          updateonline;
  end else begin *)
          if ((forcepause in menur.menuflags) and (chelplevel>1) and (lastcommandgood))
                    then pausescr;
          lastcommandgood:=FALSE;
          showthismenu;
          if (curmenu>1) then begin
          online.activity:='Menu: '+menur.name;
          updateonline;
          end;
(*  end; *)

  if (not (nomenuprompt in menur.menuflags)) then begin
    if (autotime in menur.menuflags) then
      sprint('%080%(%030%Time left: %150%'+tlef+'%080%)');
    if (menur.mnufooter<>'') then begin
        printf(adrv(systat^.afilepath)+menur.mnufooter);
    end;
    if ((nofile) or (menur.mnufooter='')) then
    sprompt(menur.menuprompt);
  end;
  if (onekey in thisuser.ac) then mpl(1) else mpl(78-pap);
  dn:=TRUE;
  end;

  getcmd(cmd);

  if (cmd='?') then
  begin
    cmd:='';
    inc(chelplevel);
    if (chelplevel>3) then chelplevel:=3;
    if ((menur.tutorial='*OFF*') and (chelplevel>=3)) then chelplevel:=2;
  end else
    if (menur.forcehelplevel<>0) then chelplevel:=menur.forcehelplevel
    else
      if (novice in thisuser.ac) then chelplevel:=2 else chelplevel:=1;

  checkforcelevel;

  if (fqarea) or (mqarea){ or (curmenu=7)} then begin
    newarea:=value(cmd);
    if ((newarea<>0) or (copy(cmd,1,1)='0')) then begin
        if (fqarea) then begin
                if (newarea>=0) and (newarea<=maxulb) and fbaseac(newarea) then
                begin
                        changefileboard(newarea);
                end else begin
                        sprint('|LF|%150%You do not have access to that base.');
                        pausescr;
                end;
        end else if (mqarea) then
        begin
                if (newarea>=0) and (newarea<=numboards) and mbaseac(newarea) then begin
                        changeboard(newarea);
                end else begin
                        sprint('|LF|%150%You do not have access to that base.');
                        pausescr;
                end;
        end; (* else if (curmenu=7) then begin
                if (newarea>=0) and (newarea<=himsg) then begin
                        if (newarea=0) then newarea:=1;
                        msg_on:=newarea;
                        getfirstmessage;
                end else begin
                        if (getfirst in actions) then begin
                                getfirstmessage;
                        end;
                        actions:=actions+[showmessage];

                end;
        end; *)
        cmd:='';
    end;
  end;
end;

procedure fcmd(var cmd:string; var i:integer; noc:integer;
	       var cmdexists,cmdnothid:boolean);
var done:boolean;
begin
  done:=FALSE;
  if (cmd=#13) then cmd:='!ENTER';
  if (cmd=#27) then cmd:='!ESC';
  if (cmd=#8) then cmd:='!BS';
  repeat
    inc(i);
    if (cmd=cmdr[i].ckeys) then begin
      cmdexists:=TRUE;
      if (oksecurity(i,cmdnothid)) then done:=TRUE;
    end;
  until ((i>noc) or (done));
  if ((cmd='!ENTER') or (cmd='!ESC') or (cmd='!BS')) and not(cmdexists) then
        cmd:='';
  if (i>noc) then i:=0;
end;

procedure domenuexec(cmd:string; var newmenucmd:string);
var cmdacs,cmdnothid,cmdexists,done:boolean;
    nocsave,i:integer;

begin
  if (newmenucmd<>'') then begin cmd:=newmenucmd; newmenucmd:=''; end;
  if (cmd<>'') then begin
    cmdacs:=FALSE; cmdexists:=FALSE; cmdnothid:=FALSE; done:=FALSE;
    nocsave:=noc; i:=0;
    repeat
      fcmd(cmd,i,nocsave,cmdexists,cmdnothid);
      if (i<>0) then begin
	cmdacs:=TRUE;
	domenucommand(done,cmdr[i].cmdkeys+cmdr[i].mstring,newmenucmd);
      end;
    until ((i=0) or (done));
    if (hangup) or (cmd='') then begin
	done:=TRUE;
	newmenucmd:='';
    end;
    if (not done) and not(hangup) then
      if ((not cmdacs) and (cmd<>'')) then begin
	nl;
	if ((cmdnothid) and (cmdexists)) then
          sprompt('%120%You do not have sufficient access for this menu command.|LF|')
	else
          sprompt('%120%Unlisted or invalid command.|LF|');
      end;
  end;
end;

procedure domenucommand(var done:boolean; cmd:string; var newmenucmd:string);
var cms,s:string;
    x,ret,z,i:integer;
    c1,c2,c:char;
    bb:byte;
    t:real;
    how:byte;
    d:datetimerec;
    frcmd,endofscan,nomessages,quit,abort,b,nocmd:boolean;

  function semicmd(x:integer):string;
  var s:string;
      i,p:integer;
  begin
    s:=cms; i:=1;
    while (i<x) and (s<>'') do begin
      p:=pos(';',s);
      if (p<>0) then s:=copy(s,p+1,length(s)-p) else s:='';
      inc(i);
    end;
    while (pos(';',s)<>0) do s:=copy(s,1,pos(';',s)-1);
    semicmd:=s;
  end;

begin
  newmenutoload:=FALSE;
  newmenucmd:='';
  c1:=cmd[1]; c2:=cmd[2];
  cms:=copy(cmd,3,length(cmd)-2);
  nocmd:=FALSE;
  lastcommandovr:=FALSE;
  case c1 of
    '0':case c2 of
          '1','2','3':dochangemenu(done,newmenucmd,c2,cms);
          '4':sl1('_',cms);
          '5':begin runprogram(cms); end;
          '6':begin doscript(semicmd(1),semicmd(2)); end;
          '7':begin
		s:=cms;
                while (pos(' ',s)<>0) do s[pos(' ',s)]:=^M;
		dm(' '+s,c);
	      end;
          '8':if (semicmd(1)<>'') then begin
		if (semicmd(2)='') then prt('> ') else prt(semicmd(2));
		input(s,20);
		if (s<>semicmd(1)) then begin
		  done:=TRUE;
		  if (semicmd(3)<>'') then sprint(semicmd(3));
		end;
	      end;
          '9':begin
                currentswap:=modemr^.swapdoor;
                dodoorfunc(cms,FALSE);
                currentswap:=0;
              end;
	else  nocmd:=TRUE;
	end;
     '1':case c2 of
          '0':begin
		if ((allcaps(cms)='CONNECT') or (allcaps(cms)='LOGON')) then begin
			printf(cms);
			z:=0;         
			repeat
				inc(z);
				printf(cms+cstr(z));
			until (z=9) or (nofile) or (hangup);
		end else if (usernum<>0) then begin
				z:=0;
				if (allcaps(cms))='SL' then z:=1;
                        if (allcaps(cms))='UFLAG' then z:=3;
				if (allcaps(cms))='USER' then z:=4;
				case z of 
                              1:printf('SL'+cstr(thisuser.sl));
					3:for c:='A' to 'Z' do 
                                if (c in thisuser.ar) then printf('UFLAG'+c);
                              4:printf('USER'+cstr(thisuser.userid));
					else printf(cms);
				end;
                end else printf(cms);
	     end;
          '1':begin sprompt(cms); end;
          '2':begin sprint(cms); end;
          '3':cls;
          '4':pausescr;
          '5':common.ansig(value(semicmd(1)),value(semicmd(2)));
          '6':begin
		case value(semicmd(2)) of
			1:dyny:=TRUE;
			2:dyny:=false;
		end;
                lastyesno:=pynq(semicmd(1));
	      end;
          '7':drawwindow(value(semicmd(1)),value(semicmd(2)),value(semicmd(3)),
                value(semicmd(4)),value(semicmd(5)),value(semicmd(6)),value(semicmd(7)),
                value(semicmd(8)),value(semicmd(9)),TRUE,semicmd(10));
	end;
    '2':case c2 of
          '0','1','2','3','4':doarccommand(c2,'');
          '5':lfii;
	  else  nocmd:=TRUE;
	end;
    '3':begin online.activity:='Browsing File Bases'; updateonline;
	case c2 of
          '0':begin { File }
		online.activity:='Joining New Conference'; updateonline;
                SelectConference(cms,2);
		end;
          '1':fbasechange(done,cms);
          '2':setdirs;
          '3':begin
		online.activity:='New File Scan';
		nf(cms);
		end;
          '4':begin
                online.activity:='Searching File Bases'; updateonline;
                search;
               end;
          '5':begin
                online.activity:='Browsing Files'; updateonline;
                if (value(cms)=0) and (cms<>'0') then begin
                if (browse(-1,'','','',0,abort)) then begin end;
                end else begin
                if (browse(value(cms),'','','',0,abort)) then begin end;
                end;
              end;
          '6':pointdate;
          '7':yourfileinfo;
          '8':begin
                sprompt(gstring(300));
	      end;
          '9':begin
                cdsonline;
              end;
	else  nocmd:=TRUE;
	end;
	end;
    '4':begin online.activity:='Browsing Files'; Updateonline;
        case c2 of
          '0':clearbatch;
          '1':listbatchfiles;
          '2':removebatchfiles;
          '8':dirf(TRUE);
          '9':dirf(FALSE);
        else  nocmd:=TRUE;
	end;
	end;
    '5':begin online.activity:='Browsing Files'; Updateonline;
        case c2 of
          '0','1':begin
		fflag:=FALSE;
                if c2='1' then fflag:=TRUE;
		online.activity:='Downloading';
		online.available:=false;
		updateonline;
		idl;
		online.available:=true;
		updateonline;
		fflag:=FALSE;
	     end;
          '2':begin
		online.activity:='Uploading';
		online.available:=false;
		updateonline;
                batchul(cms);
		online.available:=true;
		updateonline;
		end;
          '3':if (cms='') then do_unlisted_download
		else unlisted_download(cms);
          '5':validatefiles;
          '7':begin
                online.activity:='Downloading File(s)';
                online.available:=FALSE;
                updateonline;
                listed_download(value(semicmd(1)),semicmd(2));
                online.available:=TRUE;
                online.activity:='Menu: '+menur.name;
                updateonline;
              end;
        else  nocmd:=TRUE;
	end;
	end;
(*    'R':begin
        case c2 of
                'A':begin
                        if (getfirst in actions) then begin
                                getfirstmessage;
                                if (nomessage in actions) then begin
                                        actions:=actions-[nomessage];
                                        if (newmsg in actions) then begin
                                                newmenutoload:=TRUE;
                                        end else begin
                                                dochangemenu(done,newmenucmd,'3',cms);
                                        end;
                                end;
                                actions:=actions-[getfirst];
                        end;
                        actions:=actions+[showmessage];
                    end;
                'C':begin
                        copymsg(msg_on);
                        MbOpenCreate;
                        if (mbopened) then begin
                                getfirstmessage;
                                if (nomessage in actions) then begin
                                        actions:=actions-[nomessage];
                                        if (newmsg in actions) then begin
                                                newmenutoload:=TRUE;
                                        end else begin
                                                dochangemenu(done,newmenucmd,'3',cms);
                                        end;
                                end;
                        end;
                    end;
                'D':begin
                    Deletemessage;
                    pausescr;
                                if (nomessage in actions) then begin
                                        actions:=actions-[nomessage];
                                        if (newmsg in actions) then begin
                                                newmenutoload:=TRUE;
                                        end else begin
                                                dochangemenu(done,newmenucmd,'3',cms);
                                        end;
                                end;
                    end;
                'F':begin
                        forwardmsg(msg_on);
                        MbOpenCreate;
                        if (mbopened) then begin
                                getfirstmessage;
                                if (nomessage in actions) then begin
                                        actions:=actions-[nomessage];
                                        if (newmsg in actions) then begin
                                                newmenutoload:=TRUE;
                                        end else begin
                                                dochangemenu(done,newmenucmd,'3',cms);
                                        end;
                                end;
                        end;
                    end;
                'I':begin
                        sprompt('|LF|%150%Remaining messages ignored.|LF|');
                        findhimsg;
                        CurrentMSG^.SetLastRead(thisuser.userid,himsg);
                        msg_on:=himsg+1;
                    end;
                'L':begin
                        ListTitles;
                    end;
                'N':begin
                        if (getfirst in actions) then begin
                                getfirstmessage;
                                if (nomessage in actions) then begin
                                        actions:=actions-[nomessage];
                                        if (newmsg in actions) then begin
                                                newmenutoload:=TRUE;
                                        end else begin
                                                dochangemenu(done,newmenucmd,'3',cms);
                                        end;
                                end;
                                actions:=actions-[getfirst];
                        end else begin
                                getnextmessage;
                                if (nomessage in actions) then begin
                                        actions:=actions-[nomessage];
                                        if (newmsg in actions) then begin
                                                newmenutoload:=TRUE;
                                        end else begin
                                                dochangemenu(done,newmenucmd,'3',cms);
                                        end;
                                end;
                        end;
                    end;
                'M':if (mso) then begin
                        movemsg(msg_on);
                        MbOpenCreate;
                        if (mbopened) then begin
                                getfirstmessage;
                                if (nomessage in actions) then begin
                                        actions:=actions-[nomessage];
                                        if (newmsg in actions) then begin
                                                newmenutoload:=TRUE;
                                        end else begin
                                                dochangemenu(done,newmenucmd,'3',cms);
                                        end;
                                end;
                        end;
                    end;
                '-':begin
                        getpreviousmessage;
                        if (nomessage in actions) then begin
                                actions:=actions-[nomessage];
                                        if (newmsg in actions) then begin
                                                newmenutoload:=TRUE;
                                        end else begin
                                                dochangemenu(done,newmenucmd,'3',cms);
                                        end;
                        end;
                    end;
                '<':begin
                        if (CurrentMSG^.GetRefer<>0) then begin
                        msg_on:=CurrentMSG^.GetRefer;
                        getfirstmessage;
                        if (nomessage in actions) then begin
                               actions:=actions-[nomessage];
                                        if (newmsg in actions) then begin
                                                newmenutoload:=TRUE;
                                        end else begin
                                                dochangemenu(done,newmenucmd,'3',cms);
                                        end;
                        end;
                        end else begin
                        getpreviousmessage;
                        if (nomessage in actions) then begin
                                actions:=actions-[nomessage];
                                        if (newmsg in actions) then begin
                                                newmenutoload:=TRUE;
                                        end else begin
                                                dochangemenu(done,newmenucmd,'3',cms);
                                        end;
                        end;
                        end;
                    end;
                '>':begin
                        if (CurrentMSG^.GetSeeAlso<>0) then begin
                        msg_on:=CurrentMSG^.GetSeeAlso;
                        getfirstmessage;
                        if (nomessage in actions) then begin
                               actions:=actions-[nomessage];
                                        if (newmsg in actions) then begin
                                                newmenutoload:=TRUE;
                                        end else begin
                                                dochangemenu(done,newmenucmd,'3',cms);
                                        end;
                        end;
                        end else begin
                        if (getfirst in actions) then begin
                                getfirstmessage;
                                if (nomessage in actions) then begin
                                        actions:=actions-[nomessage];
                                        if (newmsg in actions) then begin
                                                newmenutoload:=TRUE;
                                        end else begin
                                                dochangemenu(done,newmenucmd,'3',cms);
                                        end;
                                end;
                                actions:=actions-[getfirst];
                        end else begin
                                getnextmessage;
                                if (nomessage in actions) then begin
                                        actions:=actions-[nomessage];
                                        if (newmsg in actions) then begin
                                                newmenutoload:=TRUE;
                                        end else begin
                                                dochangemenu(done,newmenucmd,'3',cms);
                                        end;
                                end;
                        end;
                        end;
                    end;
                'P':begin
                        post(FALSE,-1,'');
                        pausescr;
                        MbOpenCreate;
                        if (mbopened) then begin
                                getfirstmessage;
                                if (nomessage in actions) then begin
                                        actions:=actions-[nomessage];
                                        if (newmsg in actions) then begin
                                                newmenutoload:=TRUE;
                                        end else begin
                                                dochangemenu(done,newmenucmd,'3',cms);
                                        end;
                                end;
                        end;
                    end;
                'R':begin
                        pubreply(msg_on);
                        pausescr;
                        MbOpenCreate;
                        if (mbopened) then begin
                                getfirstmessage;
                                if (nomessage in actions) then begin
                                        actions:=actions-[nomessage];
                                        if (newmsg in actions) then begin
                                                newmenutoload:=TRUE;
                                        end else begin
                                                dochangemenu(done,newmenucmd,'3',cms);
                                        end;
                                end;
                        end;
                    end;
                'S':begin { skip to next base in new scan }
                                        if (newmsg in actions) then begin
                                                newmenutoload:=TRUE;
                                        end;
                    end;
                'T':begin
                        UnTagCurrent;
                        actions:=actions+[showmessage];
                        pausescr;
                    end;
                'Q':begin
                        board:=oboard;
                        changeboard(board);
                        dochangemenu(done,newmenucmd,'3',cms);
                    end;
                'X':begin
                        extractmessage;
                        actions:=actions+[showmessage];
                        pausescr;
                    end;
        end;
        end; *)
    '6':begin online.activity:='Browsing Messages'; updateonline;
	case c2 of
          '0':begin { Message }
		online.activity:='Joining New Conference'; updateonline;
                SelectConference(cms,1);
		end;
          '1':mbasechange(done,cms);
          '2':chbds;
          '3':begin
		online.activity:='Reading Messages'; updateonline;
                scanmessages(cms);
{               actions:=actions+[normal];
                dochangemenu(done,newmenucmd,'2','7');
                oboard:=board; }
		end;
          '4':begin
		online.activity:='Posting A Message';
		updateonline;
                if (cms='') then begin
                post(FALSE,-1,'');
                end else begin
                ppost(value(cms));
                end;
	      end;
          '5':begin
		online.activity:='Posting Feedback'; updateonline;
		if (semicmd(2)<>'') then irt:='/'+semicmd(2) else
		irt:='/Feedback On '+date+' '+time;
		privuser:=semicmd(1);
                inc(ftoday);
                if (ppost(0)) then begin
                        inc(thisuser.feedback);
                        inc(curact^.fback);
                end;
		privuser:='';
		end;
          '6':begin
                online.available:=FALSE;
                online.activity:='Downloading Messages'; updateonline;
		bb:=curco;
		t:=timer;
		dosc;
                currentswap:=modemr^.swapdoor;
                shelldos(FALSE,adrv(systat^.utilpath)+'NXWAVE.EXE D -N'+cstr(cnode),ret);
		common.getdatetime(tim);
                currentswap:=0;
		if ((useron) and (outcom)) then com_flush_rx;
		chdir(start_dir);
		if (useron) then begin
			freetime:=freetime+timer-t;
			topscr;
			sdc;
		end;
		setc(bb);
                online.available:=TRUE;
                updateonline;
	      end;
          '7':begin
                online.available:=FALSE;
                online.activity:='Uploading Messages'; updateonline;
		bb:=curco;
		t:=timer;
		dosc;
                currentswap:=modemr^.swapdoor;
                shelldos(FALSE,adrv(systat^.utilpath)+'NXWAVE.EXE U -N'+cstr(cnode),ret);
		common.getdatetime(tim);
                currentswap:=0;
		if ((useron) and (outcom)) then com_flush_rx;
		chdir(start_dir);
		if (useron) then begin
			freetime:=freetime+timer-t;
			topscr;
			sdc;
		end;
		setc(bb);
                online.available:=TRUE;
                updateonline;
	      end;
          '8':begin
                sprompt(gstring(301));
	      end;
          '9':begin
                online.available:=FALSE;
                online.activity:='Offline Mail'; updateonline;
                bb:=curco;
                t:=timer;
                dosc;
                currentswap:=modemr^.swapdoor;
                shelldos(FALSE,adrv(systat^.utilpath)+'NXWAVE.EXE M -N'+cstr(cnode),ret);
                common.getdatetime(tim);
                currentswap:=0;
                if ((useron) and (outcom)) then com_flush_rx;
                {$I-} chdir(start_dir); {$I+}
                if (ioresult<>0) then begin end;
                if (useron) then begin
			freetime:=freetime+timer-t;
			topscr;
			sdc;
                end;
                setc(bb);
                online.available:=TRUE;
                updateonline;
	      end;
	else  nocmd:=TRUE;
	end;
	end;

   '7':case c2 of
          '0':begin
		online.activity:='Reading New Messages'; updateonline;
                nscan(cms);
(*                firstbase:=TRUE;
                oboard:=board;
                dochangemenu(done,newmenucmd,'2','7'); *)
		end;
          '1':begin
                online.activity:='Searching Messages'; updateonline;
                msgsearch;
                end;
         '2':begin
                online.activity:='Waiting Message Scan'; updateonline;
		waitscan(1,cms);
                end; 
         else nocmd:=TRUE;
       end;
    '8':case c2 of
          '0':Begin
		cls; 
                sprint(verline(1));
                sprint(verline(2));
                sprint(verline(3));
                nl;
                curco:=7;
                textattr:=7;
                sprint('%070%d e s i g n  &  d e v e l o p m e n t  %100%George A. Roberts IV');
                sprint('%070%d e s i g n  c o n s u l t a t i o n   %100%Daniel Jones & Kevin Kuphal');
                sprint('%070%d o c u m e n t a t i o n  a s s i s t %100%Vincent Danen');
                nl;
		end;                                    
          '1':begin
                online.activity:='Chatting with SysOp';
                online.available:=FALSE;
                updateonline;
                reqchat(cms);
                online.available:=TRUE;
                updateonline;
              end;
          '3':LogOfCallers(1);
          '4':sysopstatus;
          '5':begin 
                if (semicmd(2)<>'') then how:=value(semicmd(2)) else how:=2;
                if (how=1) then online.activity:='New user information' else
                online.activity:='User information';
                online.available:=FALSE;
                updateonline;
                cstuff(value(cms),how);
                if (value(cms)=15) then newmenutoload:=TRUE;
                online.name:=thisuser.name;
                online.real:=thisuser.realname;
                online.business:=thisuser.business;
                online.available:=TRUE;
                updateonline;
	      end;
          '6':bulletins('');
          '7':bulletins('DISPLAY');
          '8':informsysop(semicmd(1),value(semicmd(2)));
	else  nocmd:=TRUE;
	end;

     '9':case c2 of
         '0':TimeBank('A',cms);
         '1':TimeBank('W',cms);
         '2':ulist(semicmd(1),semicmd(2));
         '3':yourinfo;
         '4':begin
                nl;
                if pynq('%030%Would you like to be available to be paged? %150%') then
                        online.available:=TRUE
                else online.available:=FALSE;
                updateonline;
             end;
         '5':listnodes;
         '6':pageuser;
         '7':begin { nxCHAT }
                online.available:=TRUE;
                online.activity:='Chatting'; updateonline;
		bb:=curco;
		dosc;
                currentswap:=modemr^.swapdoor;
                shelldos(FALSE,adrv(systat^.utilpath)+'NXCHAT.EXE -N'+cstr(cnode),ret);
		common.getdatetime(tim);
                currentswap:=0;
		if ((useron) and (outcom)) then com_flush_rx;
		chdir(start_dir);
		if (useron) then begin
			topscr;
			sdc;
		end;
		setc(bb);
                online.activity:='Menu: '+menur.name;
                online.available:=TRUE;
                updateonline;
             end;
         '9':begin
                online.activity:='SymSys(tm)';
                online.available:=FALSE;
                updateonline;
                sl1('*','Entered SymSys(tm)');
		minidos;
                online.available:=TRUE;
                updateonline;
	      end;
         else nocmd:=TRUE;
	 end;
    'D':begin online.activity:='Disconnecting'; updateonline;
	case c2 of
          '0':if pynq(cms) then begin
                printf('LOGOFF');
                hangup2:=TRUE;
		done:=TRUE;
	      end;
          '1':begin
		lil:=0;
                hangup2:=TRUE;
		done:=TRUE;
		end;
          '2':begin
		lil:=0;
                sprompt(cms);
                hangup2:=TRUE;
		done:=TRUE;
	      end;
          '3':begin
               hangup2:=true;
	       hungup:=TRUE;
	       done:=TRUE;
	     end;
          '4':begin
               hangup2:=TRUE;
               lcycle:=TRUE;
               done:=TRUE;
              end;
	else  nocmd:=TRUE;
	end;
	end;
  else
	nocmd:=TRUE;
  end;
  lastcommandgood:=not nocmd;
  if (curmenu>1) then begin
          online.activity:='Menu: '+menur.name;
          updateonline;
  end;
  if (lastcommandovr) then lastcommandgood:=FALSE;
  if (nocmd) then begin
    sl1('!','Invalid menu command : '+cmd);
    if (cso) then
    begin
        sprompt('|LF|%150%Invalid command.|LF|');
    end;
  end;
  if (curmenu<>7) and (mbopened) then begin
        mbclose;
  end;
  if (newmenutoload) then
  begin
    readin2;
(*    nomessages:=FALSE;
    endofscan:=FALSE;
    if (newmsg in actions) then begin
        if (firstbase) then begin
              oboard:=board;
              if (global in actions) then begin
                      sprompt(gstring(28));
              end;
        end;
        nomessages:=TRUE;
        endofscan:=FALSE;
        while (nomessages) and not(endofscan) do begin
                if not(firstbase) then begin
                sprompt(gstring(30));
                end;
                endofscan:=not(getnextscanbase(firstbase));
                if (firstbase) then firstbase:=FALSE;
                if not(endofscan) then begin
                        if (mbopened) then mbclose;
                        loadboard(board);
                        mbopencreate;
                        msg_on:=lastread+1;
                        nomessages:=FALSE;
                        if (msg_on>himsg) then nomessages:=TRUE;
                        if (mbopened) then mbclose;
                        sprompt(gstring(29));
                end;
        end;
        if (endofscan) then begin
           sprompt(gstring(30));
           if (global in actions) then begin
                sprompt(gstring(31));
                MSGSCAN^.Done;
                dispose(MSGSCAN);
           end;
           if (mbopened) then mbclose;
           board:=oboard;
           changeboard(board);
           dochangemenu(done,newmenucmd,'3',cms);
           actions:=[];
           readin2;
        end;
    end;
    if (curmenu=7) and not(endofscan) then begin
        loadboard(board);
        MbOpenCreate;
        if (newmsg in actions) then begin
                msg_on:=lastread+1;
        end else begin
                msg_on:=1;
        end;
        if (mbopened) then begin
                getfirstmessage;
                if not(newmsg in actions) then begin
                        actions:=actions+[getfirst];
                        actions:=actions-[showmessage];
                end;
        end;
        if (not(newmsg in actions) and ((nomessage in actions) or not(mbopened))) then begin
              if (mbopened) then mbclose;
              sprompt(gstring(598));
              dochangemenu(done,newmenucmd,'3',cms);
              actions:=[];
              readin2;
              pausescr;
        end;
        if (newmsg in actions) and (nomessage in actions) then begin
                end;
    end; *)
    lastcommandgood:=FALSE;
    if (newmenucmd='') then begin
      i:=1;
      frcmd:=FALSE;
      while (i<=noc) do begin
        if (autoexec in cmdr[i].commandflags) then begin
                if (aacs(cmdr[i].acs)) then begin
                        frcmd:=TRUE;
                        cmdr[i].ckeys:='FIRSTCMD';
                end;
        end;
        inc(i);
      end;
      if (frcmd) then newmenucmd:='FIRSTCMD';
    end;
  end;
end;

{ End File MENUS.PAS }

end.
