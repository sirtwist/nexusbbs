{nexus nexus nexus nexus nexus nexus nexus nexus nexus nexus nexus nexus nexu}
{ nexus nexus nexus  ÜÛÜÜÜÜ   ÜÜÜÜÜ  ÛÜÜ ÜÜÛ ÜÛÜ ÜÜ   ÜÜÜÜÜ   nexus nexus nex}
{s nexus nexus nexus ±ÛÛ ±ÛÛ ±ÛÛ  ±Û ±ÛÛ ±ÛÛ ±ÛÛ ±ÛÛ ±ÛÛ  ßÛ s nexus nexus ne}
{us nexus nexus nexu °ÛÛ °ÛÛ °ÛÛÜÜ°Û °ÛÛ °ÛÛ °ÛÛ °ÛÛ °ÛÛ     us nexus nexus n}
{xus nexus nexus nex °ÛÛ °ÛÛ °ÛÛ       ÜßÜ   °ÛÛ °ÛÛ ßÛÛÜ    xus nexus nexus }
{exus nexus nexus ne °ÛÛ °ÛÛ °ÛÛ     °ÛÛ °ÛÛ °ÛÛ °ÛÛ    ßÛÛÜ exus nexus nexus}
{nexus nexus nexus n °ÛÛ °ÛÛ °ÛÛ  Ü  °ÛÛ °ÛÛ °ÛÛ °ÛÛ Ü   °ÛÛ nexus nexus nexu}
{ nexus nexus nexus  °Ûß °Ûß  ÛÛÛÛß  °Ûß °ÛÛ °ÛÛÜ°Ûß ßÛÛÛÛÛß  nexus nexus nex}
{s nexus nexus nexus NEXUS   BULLETIN    °ÛÛ  BOARD   SYSTEM s nexus nexus ne}
{us nexus nexus nexus nexus nexus nexus n ßß  nexus nexus nexus nexus nexus n}
{xus nexus nexus nexus nexus nexus nexus nexus nexus nexus nexus nexus nexus }
{============================================================================}
{                                                                            }
{                      Nexus Bulletin Board System v1.00                     }
{                                                                            }
{ MODULE: NEXUS.PAS                                                          }
{ DESC  : Main Executable Source File                                        }
{                                                                            }
{ All material contained herein is copyright 1995-2000 George A. Roberts IV. }
{ All rights reserved.                                                       }
{                                                                            }
{============================================================================}
{$A+,B+,D-,E+,F+,G-,I+,L-,N-,O-,R+,S+,V-}
{$IFDEF MSDOS}
{$M 65500,0,220000}      { Memory Allocation Sizes }
{$ENDIF}
{$IFDEF WIN32}
{$M 131000}
{$ENDIF}

Program Nexus;
Uses
  Crt,    Dos,
{$IFDEF MSDOS}
  overlay,
{$ENDIF}
Common, common2, InitP,   mail6,  Menus2, File0,
  MyIO3,  Logon1,  Logon2,  NewUsers, WfcMenu, Menus,  TmpCom,
  runprog,mkstring,mkmisc,script;

{$IFDEF MSDOS}
{$O initp}
{$O common1}
{$O common2}
{$O common3}
{$O common4}
{$O common5}
{$O logon1}
{$O logon2}
{$O execbat}
{$O mmodem}
{$O cuser}
{$O mkopen}
{$O mkmisc}
{$O mkstring}
{$O mkglobt}
{$O mkmsgjam}
{$O mkmsgsqu}
{$O mkmsgfid}
{$O File0}
{$O file1}
{$O file2}
{$O file4}
{$O file5}
{$O file25}
{$O file6}
{$O file8}
{$O file9}
{$O file10}
{$O file11}
{$O file12}
{$O file14}
{$O menus2}
{$O menus3}
{$O misc1}
{$O misc2}
{$O misc3}
{$O miscx}
{$O mail0}
{$O mail1}
{$O mail3}
{$O mainmail}
{$O mail52}
{$O mail4}
{$O mail6}
{$O mail9}
{$O archive1}
{$O archive2}
{$O wfcmenu}
{$O sysop11}
{$O myio3}
{$O newusers}
{$O doors}
{$O cdrom}
{$O cdrom2}
{$O volume}
{$O useredit}
{$ENDIF}

Const
  ovrmaxsize = 50000;
Var
  ExitSave  : Pointer;
  ExecFirst : Boolean;
  NewMenuCmd: String;
  testloop:integer;

{$F+} Procedure ErrorHandle; {$F-}

{*****************************************************************************
 * Note: If another error occurs in this procedure,                          *
 * it is NOT executed again!                                                 *
 *****************************************************************************}

Var
  T:Text;
  F,f2:File;
  S:String[80];
  VidSeg:Word;
  X,Y:Integer;
  savsl:byte;
  C:Char;
  ufo:boolean;
Begin
  ExitProc:=ExitSave;
  If (ErrorAddr<>Nil) then
  Begin
    assign(t,systat^.trappath+'ERR'+cstrn(cnode)+'.LOG');
    {$I-} append(t); {$I+}
    if (ioresult<>0) then
    begin
      rewrite(t);
      append(t);
      writeln(t,'NEXUS CRITICAL ERROR LOG - Screen image at time of SYSTEM ERROR.');
      writeln(t,'The "²" character shows the cursor position at time of error.');
      writeln(t,'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
    end;
    writeln(t,'CRITICAL ERROR ON '+date+' AT '+time);
    writeln(t,'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
    writeln(t,'NEXUS VERSION: '+mln(ver,20)+' ERROR CODE: '+cstr(exitcode));
    if (useron) then begin
            if (spd<>'KB') then s:='CONNECTED AT '+cstr(answerbaud)+' BAUD' else s:='CONNECTED LOCALLY';
            writeln(t,'USER         : '+allcaps(thisuser.name)+' '+s);
    end;
    writeln(t);
    writeln(t,'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[Screen Image]ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
    if (mem[$0000:$0449]=7) then vidseg:=$B000 else vidseg:=$B800;
    for y:=1 to 25 do
    begin
      s:='';
      for x:=1 to 80 do
      begin
        c:=chr(mem[vidseg:(160*(y-1)+2*(x-1))]);
        if (c=#0) then c:=#32;
        if ((x=wherex) and (y=wherey)) then c:=#178;
        if ((x<>80) or ((x=80) and (c<>#32))) then s:=s+c;
      end;
      writeln(t,s);
    end;
    writeln(t,'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
    close(t);


    if (not localioonly) then com_lower_dtr;
    delay(2000);
    if (not localioonly) then com_raise_dtr;

    if (not localioonly) then com_deinstall;
    if (useron) then begin
  if (usernum<>0) then begin
  if (realsl<>-1) then begin
    savsl:=thisuser.sl;
    thisuser.sl:=realsl;
  end else begin
    savsl:=thisuser.sl;
  end;

    thisuser.lastmconf:=mconf; thisuser.lastfconf:=fconf;

    ufo:=(filerec(uf).mode<>fmclosed);
    filemode:=66;
    if (not ufo) then begin
    {$I-} reset(uf);{$I+}
    if (ioresult=0) then begin
            {$I-} seek(uf,usernum); {$I+}
            if (ioresult=0) then begin
            write(uf,thisuser);
            end;
            if (not ufo) then close(uf);
    end;
    end;

    thisuser.sl:=savsl;
    end;


    end;

    filemode:=66;
    assign(f,start_dir+'\ERR'+cstrn(cnode)+'.FLG');
    rewrite(f);
    close(f);
    {$I-} setfattr(f,dos.hidden); {$I+}

    textcolor(7);
    textbackground(0);
    filemode:=66;
    assign(f2,adrv(systat^.semaphorepath)+'INUSE.'+cstrnfile(cnode));
    {$I-} erase(f2); {$I+}
    if ioresult<>0 then begin
        writeln;
        writeln('! ',time,' ','Cannot remove INUSE.'+cstrnfile(cnode));
        writeln('! ',time,' ','CRITICAL ERROR #'+cstr(exitcode));
        writeln('! ',time,' ','Consult ERR'+cstrn(cnode)+'.LOG in '+adrv(systat^.trappath));
        if (exiterrors=-1) then exiterrors:=254;
        writeln('! ',time,' ','Exiting with errorlevel ',exiterrors);
        halt(exiterrors);
    end;
    {$I-} erase(onlinef); {$I+}
    if (ioresult<>0) then begin end;

    writeln;
    writeln('! ',time,' ','CRITICAL ERROR #'+cstr(exitcode));
    writeln('! ',time,' ','Consult ERR'+cstrn(cnode)+'.LOG in '+adrv(systat^.trappath));
    if (exiterrors=-1) then exiterrors:=254;
    writeln('! ',time,' ','Exiting with errorlevel ',exiterrors);
    {$I-} chdir(copy(paramstr(0),1,length(paramstr(0))-10)); {$I+}
    if (ioresult<>0) then begin end;
    halt(exiterrors);

    {* CRITICAL ERROR ERRORLEVEL *}

  end;
end;

Var
  I:Integer;
  NeedToHangup,Aa,Abort,Next,Done:Boolean;
  tuser:userrec;
  st:real;
  s,cmd:string;

Begin
  exitsave:=exitproc;
  exitproc:=@errorhandle;
  start_dir:=getenv('NEXUS');
  getdir(0,startdir);

  if (start_dir='') then begin
        writeln('You must set your NEXUS environment variable to point to your main Nexus');
        writeln('directory, or Nexus will not run.');
        writeln;
        halt(254);
  end;
  if (start_dir[length(start_dir)]='\') and (length(start_dir)>3) then begin
        start_dir:=copy(start_dir,1,length(start_dir)-1);
  end;
  {$I-} chdir(start_dir); {$I+}
  if (ioresult<>0) then begin
        writeln('Error changing to start directory.  Please check your directory');
        writeln('structure and your NEXUS environment variable to make sure that');
        writeln('they are correct.');
        halt(254);
  end;
  ovrfilemode:=$42;
  ovrinit(allcaps(copy(paramstr(0),1,length(paramstr(0))-10))+'\NEXUS.OVR');
  if (ovrresult<>ovrok) then
  begin
        writeln('Your NEXUS.OVR has been corrupted.  Please contact the Nexus Development');
        writeln('team to receive assistance.  Please note the internal error number and');
        writeln('report it to the Nexus Development Team.');
        writeln;
        writeln('CRITICAL ERROR #1002');
        writeln;
        halt(254);
  end;
  overlayinems:=FALSE;
  ovrinitems;
  if (ovrresult=ovrok) then overlayinems:=TRUE;
  if not(overlayinems) then begin
        ovrsetbuf(maxavail-ovrmaxsize);
        ovrsetretry(maxavail-(ovrmaxsize div 2));
  end;

  checksnow:=TRUE; directvideo:=FALSE;


  textattr:=7;
  curco:=7;
  init;
  if (overlayinems) then begin
        sl1('i','Overlays loaded in EMS');
  end;
  sl1('i','Available stack     : '+cstrl(sptr)+' bytes');
  sl1('i','Available heap      : '+cstrl(memavail)+' bytes');
  sl1('i','Largest help region : '+cstrl(maxavail)+' bytes');
  sl1('i','Free DOS memory     : '+cstrl(dosmem)+' bytes');
  directvideo:=systat^.usebios;

  defaultst:='';
  tuser.name:='';
  tuser.tltoday:=0;
  tuser.loggedon:=0;
  useron:=FALSE; usernum:=0;

  needtohangup:=FALSE;           { hang up if critical error last call! }

  repeat
    write_msg:=FALSE;
    lcycle:=FALSE;
    checksnow:=systat^.cgasnow;

    curmenu:=langr.startmenu;
{    if (usewfcmenu) then begin }
    killwaitingsema;
    wfcmenus(needtohangup);
        {waitforcaller;}
{    end; }
    needtohangup:=FALSE;

    if not(hangup) then begin
          mpausescr:=false;
          reading_a_msg:=false;
          inuserwindow;
          if (not doneday) then begin
                  thisuser.ac:=thisuser.ac-[color,ansi];
                  curco:=7;
                  textattr:=7;
                  s:='CONNECT';
                  if (spd<>'KB') then begin
                        if (telnet) then begin
                                s:=s+'ED VIA TELNET';
                        end else begin
                                s:=s+' '+cstr(answerbaud);
                        end;
                        nl;
                        sprint(s);
                        nl;
                  end else begin
                        cls;
                        s:=s+' LOCAL';
                  end;
                  sl1('~',s);

                  if (spd='KB') then begin
                        thisuser.ac:=thisuser.ac+[color,ansi];
                        ansidetected:=TRUE;
                  end else begin
                        sprompt(gstring(52));
                        pr1(#27+'[6n');
                        st:=timer;
                        while ((tcheck(st,5)) and (empty)) do begin timeslice; end;
                        if (not empty) then begin
                                 thisuser.ac:=thisuser.ac+[ansi,color];
                                 com_flush_rx;
                                 ansidetected:=TRUE;
                                 pr1(^H' '^H^H' '^H^H' '^H);
                                 sprompt('%030%Detected emulation : %150%ANSI|LF|');
                        end else begin
                                textcolor(7);
                                textbackground(0);
                                curco:=7;
                                pr1(^H' '^H^H' '^H^H' '^H^H' '^H);
                                sprompt('Detected emulation : TTY|LF|');
                        end;
                        s:='';
                        nl;
                        nl;
                  end;
                  setc(7 or (0 shl 4));
                  textcolor(7);
                  textbackground(0);
                  curco:=7;
                  sprint(verline(1));
                  sprint(verline(2));
                  sprint(verline(3));
                  nl;

                  sprompt(gstring(51));
                  delay(2000);


                  if ((answerbaud<modemr^.minimumbaud) and (spd<>'KB')) then begin
                           if ((modemr^.lockbegintime[getdow]<>0) or (modemr^.lockendtime[getdow]<>0)) then begin

                              if (not intime(timer,modemr^.lockbegintime[getdow],modemr^.lockendtime[getdow])) then begin
                                printf('NO-HRS');
                                if (nofile) then begin
                                  print('Calling Hours for |MINBAUD| baud and below users on node |NODE|');
                                  print('are from |LOCKBEGIN| to |LOCKEND|.');
                                end;
                                nl;
                                print('Terminating Connection...');
                                delay(1000);
                                hangup2:=TRUE;
                              end;
                              if (not hangup) then
                              if ((modemr^.lockbegintime[getdow]<>0) or (modemr^.lockendtime[getdow]<>0)) then begin
                                printf('YES-HRS');
                                if (nofile) then begin
                                          print('Please remember:  Callers connecting with |MINBAUD| baud and below on');
                                          print('node |NODE| will not be allowed to access the system from |LOCKBEGIN| to');
                                          print('|LOCKEND|.');
                                end;
                              end;
                           end else begin
                            printf('MINIMUM');
       if (nofile) then print('Only callers connecting at |MINBAUD| baud and above may access this system.');
                            delay(1000);
                            hangup2:=TRUE;
                           end;
                  end;
          end;
          if not(hangup) and not(doneday) then begin
                  fillchar(globc,sizeof(globc),#0);
                  globcmds:=0;
                  if (exist(adrv(systat^.menupath)+'global.mnu')) then begin
                         curmenu:=1; readingl;
                  end else sl1('!','GLOBAL.MNU Is Missing.  Skipped.');
                  mpausescr:=FALSE;
                  useron:=FALSE; usernum:=0;
                  menustackptr:=1; for i:=1 to 8 do menustack[i]:=0;
                  menustack[i]:=langr.startmenu;
                  last_menu:=langr.startmenu;
                  if (not(fastlogon)) then
                         if (exist(adrv(systat^.nexecutepath)+'PRELOGON.NPX')) then begin
                               doscript(adrv(systat^.nexecutepath)+'PRELOGON.NPX','');
                         end else sl1('!','PRELOGON.NPX Is Missing.  Skipped.');

{          if (exist(adrv(systat^.menupath)+'PRELOGON.MNU')) then begin
                curmenu:=3; readin(true);
                newmenucmd:=''; i:=1;
                while ((i<=noc) and (newmenucmd='')) and not(hangup) do
                begin
                  cmdr[i].commandflags:=cmdr[i].commandflags+[autoexec];
                  cmdr[i].ckeys:='FIRSTCMD';
                  if (aacs(cmdr[i].acs)) then begin
                        newmenucmd:='FIRSTCMD';
                  end;
                  inc(i);
                end;
                execfirst:=(newmenucmd='FIRSTCMD');
  If (ExecFirst) then
  Begin
    ExecFirst:=FALSE;
    Cmd:=NewMenuCmd;
    NewMenuCmd:='';
  End Else MainMenuHandle(Cmd);

  if ((copy(cmd,1,2)='\\') and (thisuser.sl=100)) then begin
    domenucommand(done,copy(cmd,3,length(cmd)-2),newmenucmd);
    if (newmenucmd<>'') then cmd:=newmenucmd else cmd:='';
  end;

  if (cmd<>'') then
  begin
    newmenucmd:='';
    repeat
        domenuexec(cmd,newmenucmd);
        checkhangup;
    until (newmenucmd='') or (hangup);
  end;
          end else sl1('!','Pre-Logon menu (PRELOGON.MNU) is missing.  Skipped...');}

          end;
  end;
  checkhangup;
  if (not doneday) and not(hangup) then begin
  filemode:=66;
  with online do begin
                Name:='Unknown';
                real:='Unknown';
                number:=0;
                available:=false;
                business:='';
                activity:='Logging on...';
                if (spd='KB') then begin
                        baud:=0;
                        lockbaud:=0;
                        comport:=0;
                end else begin
                        case modemr^.ctype of
                                1:comtype:=0;
                                2:comtype:=2;
                                3:comtype:=1;
                        end;
                        baud:=answerbaud div 10;
                        comport:=modemr^.comport;
                        if (modemr^.lockport) then lockbaud:=(modemr^.waitbaud div 10)
                                else lockbaud:=0;
                end;
                if not(okansi) then emulation:=0 else emulation:=1;
  end;
  rewrite(onlinef);
  seek(onlinef,0);
  write(onlinef,online);
  close(onlinef);
  if (getuser) then begin
                newuser1;
                checkhangup;
                if not(hangup) then begin
                schangewindow(TRUE,1);

{          if (exist(adrv(systat^.menupath)+'NEWUSER.MNU')) then begin
                curmenu:=2; readin(true);
                newmenucmd:=''; i:=1;
                while ((i<=noc) and (newmenucmd='')) and not(hangup) do
                begin
                  cmdr[i].commandflags:=cmdr[i].commandflags+[autoexec];
                  cmdr[i].ckeys:='FIRSTCMD';
                  if (aacs(cmdr[i].acs)) then begin
                        newmenucmd:='FIRSTCMD';
                  end;
                  inc(i);
                end;
                execfirst:=(newmenucmd='FIRSTCMD');
  If (ExecFirst) then
  Begin
    ExecFirst:=FALSE;
    Cmd:=NewMenuCmd;
    NewMenuCmd:='';
  End Else MainMenuHandle(Cmd);

  if ((copy(cmd,1,2)='\\') and (thisuser.sl=100)) then begin
    domenucommand(done,copy(cmd,3,length(cmd)-2),newmenucmd);
    if (newmenucmd<>'') then cmd:=newmenucmd else cmd:='';
  end;

  if (cmd<>'') then
  begin
    newmenucmd:='';
    repeat
        domenuexec(cmd,newmenucmd);
        checkhangup;
    until (newmenucmd='') or (hangup);
  end;
          end else sl1('!','New User menu (NEWUSER.MNU) is missing.  Skipped...'); }

                if (exist(adrv(systat^.nexecutepath)+'NEWUSER.NPX')) then
                begin
                        doscript(adrv(systat^.nexecutepath)+'NEWUSER.NPX','');
                end else
                        sl1('!','NEWUSER.NPX Is Missing.  Skipped.');

                if not(hangup) then newuser2;
                end;
      end;
      if (not hangup) then
      begin
        createtags;
        logon;
        if (not hangup) then
        begin
          with thisuser do
          begin
            unixtodt(filescandate,fddt);
            newdate:=formatteddate(fddt,'MM/DD/YYYY');
            loadboard(0);
            loaduboard(1);
            fileboard:=1;
            board:=0;
            testloop:=0;
            while (testloop<=32767) and not(mbaseac(testloop)) do begin
            inc(testloop);
            end;
            if (testloop<0) or (testloop>32767) then testloop:=0;
            loadboard(testloop);
            testloop:=0;
            while (testloop<=32767) and not(fbaseac(testloop)) do begin
            inc(testloop);
            end;
            if (testloop<0) or (testloop>32767) then testloop:=1;
            loaduboard(testloop);
            tuser:=thisuser;
          end;

          if (fastlogon) then begin
                  if (exist(adrv(systat^.nexecutepath)+'FASTLOG.NPX')) then begin
                        doscript(adrv(systat^.nexecutepath)+'FASTLOG.NPX','');
                  end else sl1('!','FASTLOG.NPX is missing.  Skipped.');
          end else begin
                  if (exist(adrv(systat^.nexecutepath)+'LOGON.NPX')) then begin
                        doscript(adrv(systat^.nexecutepath)+'LOGON.NPX','');
                  end else sl1('!','LOGON.NPX is missing.  Skipped.');
          end;

        end;

          fastlogon:=false;

          batchtime:=0.0; numbatchfiles:=0;

          curmenu:=langr.startmenu; readin(true);

          if (novice in thisuser.ac) then chelplevel:=2 else chelplevel:=1;
        {if (copy(thisuser.bday,1,5)=copy(date,1,5)) then printf('BIRTHDAY');}

        newmenucmd:=''; i:=1;
        execfirst:=FALSE;
        while ((i<=noc) and (newmenucmd='')) do
        begin
          if (autoexec in cmdr[i].commandflags) then
            if (aacs(cmdr[i].acs)) then begin
                execfirst:=TRUE;
                cmdr[i].ckeys:='FIRSTCMD';
            end;
            inc(i);
        end;
        if (execfirst) then newmenucmd:='FIRSTCMD';
        while (not hangup) do begin
                 If (ExecFirst) then
                 Begin
                   ExecFirst:=FALSE;
                   Cmd:=NewMenuCmd;
                   NewMenuCmd:='';
                 End Else MainMenuHandle(Cmd);
               
                 if ((copy(cmd,1,2)='\\') and (thisuser.sl=100)) then begin
                   domenucommand(done,copy(cmd,3,length(cmd)-2),newmenucmd);
                   if (newmenucmd<>'') then cmd:=newmenucmd else cmd:='';
                 end;
               
                 if (cmd<>'') then
                 begin
                   newmenucmd:='';
                   repeat
                       domenuexec(cmd,newmenucmd);
                       checkhangup;
                   until (newmenucmd='') or (hangup);
                 end;
                 checkhangup;
        end;
      end;
      end;

      if (useron) and (usernum<>0) then begin
        tuser.tltoday:=thisuser.tltoday;
        tuser.loggedon:=thisuser.loggedon;
      end;
      if not(doneday) then begin
      logoff;
      if tuser.name='' then tuser.name:='No Caller';
      if tuser.realname='' then tuser.realname:='No Caller';
      if (useron) then begin
      sl1('~','Time Left  : '+mln(cstr(tuser.tltoday),6)+' Total Calls: '+mln(cstr(tuser.loggedon),6));
      if (systat^.aliasprimary) then begin
              sl1('+',tuser.name+' offline');
      end else begin
              sl1('+',tuser.realname+' offline');
      end;
      end;
      useron:=FALSE;
      if not(lcycle) and not(usewfcmenu) then quitafterdone:=true;
      if (quitafterdone) then
      begin
        hangup2:=TRUE; doneday:=TRUE;
      end;
      end;

      textcolor(7);

      if not(usewfcmenu) then begin
              if (wherex<>1) then writeln;
              writeln;
              if (systat^.aliasprimary) then
              writeln('+ ',time,' ',tuser.name,' offline')
              else
              writeln('+ ',time,' ',tuser.realname,' offline');
      end;

      if ((com_carrier) and (not hungup)) then
        if (spd<>'KB') and not(lcycle) then needtohangup:=TRUE;
  until (doneday);

  endday;
  if (needtohangup) then hangupphone;
  remove_port;

  textcolor(7);
  textbackground(0);
  cursoron(TRUE);
  if (usewfcmenu) then clrscr;
  writeln(': ',time,' Exit; Nexus v',ver,', Errorlevel=',elevel);
  sl1(':','Exit; Nexus v'+ver+', Errorlevel='+cstr(elevel));
  {$I-} chdir(startdir); {$I+}
  if (ioresult<>0) then begin end;
  halt(elevel);
end.
