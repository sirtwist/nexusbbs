{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R-,S+,V-}
unit file12;

interface

uses
  crt,dos,
  execbat,
  mmodem,
  common;

procedure batchul(cms:string);

implementation

uses file0,file1, file2, file4, file9, archive1,file6,file11,doors,mkmisc;

var protocol:protrec;             { protocol in memory                    }

procedure batchul(cms:string);
var fi:file of byte;
    dirinfo:searchrec;
    s2:string;
    retcode:integer;
    tempr:real;
    xferstart,xferend,tooktime,takeawayulrefundgot1,ulrefundgot1:datetimerec;
    tconvtime1,st1:datetimerec;
    nfn,pc,fn,s,tempdesc:astr;
    st,tconvtime,convtime,ulrefundgot,takeawayulrefundgot:real;
    totb,totfils,totb1,totfils1,cps,lng,totpts:longint;
    n,newbase,olduboard,x2,fileswithid,atype,x,i,p,hua,pl,dbn,gotpts,ubn,filsuled,oldboard,passn:integer;
    fpacked:longint;
    dt:datetime;
    fi2:file;
    blks:longint;
    c:char;
    tempfilename:string;
    t:text;
    rcode:integer;
    isbatch,done2,abort,ahangup,next,done,dok,kabort,wenttosysop,ok,convt,
      beepafter,fok,nospace,savpause:boolean;


  function plural:string;
  begin
    if (totfils<>1) then plural:='s' else plural:='';
  end;

begin
  purgedir(newtemp);
  olduboard:=fileboard;
  newbase:=-1;
  tempfilename:='';
  if (cms<>'') then begin
        newbase:=value(cms);
        if (newbase<>fileboard) and (newbase>=0) and (newbase<=maxulb) then begin
                loaduboard(newbase);
                fileboard:=newbase;
                end;
  end;
                
  fiscan(pl);
  if (baddlpath) then begin
    nl;
    printf('ULACCESS');
    if (nofile) then sprint('%120%You cannot upload to this file base.');
    exit;
  end;
  if (not aacs(memuboard.ulacs)) then begin
    nl; 
    printf('ULACCESS');
    if (nofile) then sprint('%120%You cannot upload to this file base.');
    exit;
  end;
  if ((memuboard.cdrom) and (incom)) then begin
        nl;
        sprint('%120%You cannot upload to a CD-ROM base.');
        exit;
  end;
  
  savpause:=(pause in thisuser.ac);
  if (savpause) then thisuser.ac:=thisuser.ac-[pause];

  beepafter:=FALSE; done:=FALSE;
  fileswithid:=0;
  nl;
  printf('UPLOADS');
  if (nofile) then begin
      sprint('%030%All Files will be checked upon receipt for FILE_ID.DIZ Description files.');
      sprint('%030%If FILE_ID.DIZ is not found, you will be prompted to enter up to a '+cstr(syst.ndesclines)+' line');
      sprint('%030%description for each file.');
  end;
  filemode:=66;
  nl;
  isbatch:=pynq('%120%Are you uploading multiple files? %110%');
  nl;
  {$I-} reset(xf); {$I+}
  if (ioresult<>0) then begin
        sprint('%120%No protocols available!');
        sl1('!','Error opening PROTOCOL.DAT');
        exit;
  end;
  done:=FALSE;
  p:=-99;
  if (thisuser.defprotocol<>'@') then
  p:=findprot(thisuser.defprotocol,TRUE,FALSE,isbatch,FALSE);
  if (p=-99) then
  repeat
    nl;
    showprots(TRUE,FALSE,isbatch,FALSE);
    nl;
    sprompt('%030%Protocol (%150%Q%030%=Quit) : %150%'); mpkey(s);
    if (s[1]='Q') then begin done:=TRUE; p:=-10; end else begin
      p:=findprot(s[1],TRUE,FALSE,isbatch,FALSE);
      if (p=-99) then print('Invalid entry.') else done:=TRUE;
    end;
  until (done) or (hangup);
  if (p<>-10) then begin
    seek(xf,p); read(xf,protocol); close(xf);
      sprint('%030%Using protocol: %150%'+protocol.descr);
      if not(isbatch) and (xbNameSingle in protocol.xbstat) then begin
        nl;
        sprompt('%030%Filename : %150%');
        input(tempfilename,12);
        if (tempfilename='') then exit;
      end;
      sprompt('|LF|%030%(%150%Y%030%)es, hang up after transfer|LF|');
      sprompt('%030%(%150%N%030%)o, do not hang up after transfer|LF|');
      sprompt('%030%(%150%A%030%)sk after transfer is completed|LF|');
      sprompt('%030%(%150%Q%030%)uit, abort transfer|LF||LF|');
      sprompt('%120%Hangup after transfer? %110%No');
      onekcr:=FALSE;
      onekda:=FALSE;
      onek(c,'QNYA'^M);
      onekcr:=TRUE;
      onekda:=TRUE;
      hua:=pos(c,'QNYA'^M);
      if (hua=5) then hua:=2;
      if (hua<>2) then prompt(^H' '^H^H' '^H);
      case hua of
         1:begin
           sprint('%110%Quit');
           end;
         2:begin
           nl;
           end;
         3:begin
           sprint('%110%Yes');
           end;
         4:begin
           sprint('%110%Ask');
           end;
      end;
    dok:=TRUE;
    if (hua<>1) then begin
      lil:=0;
      nl; nl;
      if (useron) then begin
      sprint('%030%Ready to receive uploads: ');
      nl;
      end;
      lil:=0;

      getdatetime(xferstart);
      shelling:=1;
      currentswap:=modemr^.swapprotocol;
      nfn:=processmci(protocol.ulcmd);
      { %1 = BATCH, SINGLE, RESUME }
      { %2 = COMPORT }
      { %3 = BAUD RATE }
      { %4 = LOCK BAUD }
      { %5 = FILENAME (if single) }
      if (isbatch) then
      nfn:=nfn+' BATCH'
      else nfn:=nfn+' SINGLE';
      nfn:=nfn+' '+cstrl(modemr^.comport);
      if (not(incom) and not(outcom)) then nfn:=nfn+' '+cstrl(0)
                else nfn:=nfn+' '+cstrl(answerbaud);
      if not(modemr^.lockport) then nfn:=nfn+' '+cstrl(answerbaud) else
                nfn:=nfn+' '+cstrl(modemr^.waitbaud);
      if not(isbatch) and (tempfilename<>'') then nfn:=nfn+' '+tempfilename;
      rcode:=protocol.ulcode;

      if (xbINTERNAL in protocol.xbstat) then begin
        nfn:=adrv(systat^.utilpath)+'NXPDRIVE.EXE -R='+newtemp+' -B'+cstr(answerbaud);
        nfn:=nfn+' -C'+cstr(modemr^.comport)+' -N'+cstr(cnode);
        if not(isbatch) and (tempfilename<>'') then nfn:=nfn+' -F='+tempfilename;
        case modemr^.ctype of
               0:nfn:=nfn+' -D1';
               1:nfn:=nfn+' -D2';
               2:nfn:=nfn+' -D3';
               3:nfn:=nfn+' -D1';
        end;
        if (xbMiniDisplay in protocol.xbstat) then begin
               nfn:=nfn+' -M';
        end;
                if (protocol.dlcmd='INT_ZMODEM_RECV') then begin
                        nfn:=nfn+' -Z';
                end else
                if (protocol.dlcmd='INT_YMOD-G_RECV') then begin
                        nfn:=nfn+' -G';
                end else
                if (protocol.dlcmd='INT_YMODEM_RECV') then begin
                        nfn:=nfn+' -Y';
                end else
                if (protocol.dlcmd='INT_XMOD1K_RECV') then begin
                        nfn:=nfn+' -K';
                end else
                if (protocol.dlcmd='INT_XMODEM_RECV') then begin
                        nfn:=nfn+' -X';
                end;
                shel('');
      end else begin
      if (useron) then shel('User uploading: '+nam)
                       else shel('Receiving file(s)...');
      end;

      {$I-} chdir(chr(exdrv(bslash(FALSE,newtemp))+64)+':'); {$I+}
      if (ioresult<>0) then begin
        sl1('!','Unable to access temporary directory for uploads!');
      end else begin
              {$I-} chdir(bslash(FALSE,newtemp)); {$I+}
              if (ioresult<>0) then begin
                        sl1('!','Unable to access temporary directory for uploads!');
              end else shelldos(FALSE,nfn,rcode);
      end;
      {$I-} chdir(chr(exdrv(start_dir)+64)+':'); {$I+}
      if (ioresult<>0) then begin end;
      {$I-} chdir(start_dir); {$I+}
      if (ioresult<>0) then begin end;
      shel2;
      shelling:=2;
      currentswap:=0;
      getdatetime(xferend);
      timediff(tooktime,xferstart,xferend);


      ulrefundgot:=(dt2r(tooktime))*(systat^.ulrefund/100.0);
      freetime:=freetime+ulrefundgot;

      {*****}

      lil:=0;
      nl;
      nl;
      sprint('%030%Transfer completed.');
      nl;
      lil:=0;

      tconvtime:=0.0; takeawayulrefundgot:=0.0;
      totb:=0; totfils:=0; totb1:=0; totfils1:=0; totpts:=0;

      findfirst(newtemp+'*.*',anyfile-directory-volumeid,dirinfo);
      while (doserror=0) do begin
        inc(totfils1);
        inc(totb1,dirinfo.size);
        findnext(dirinfo);
      end;
      tempr:=dt2r(tooktime);
      if (tempr=0) then tempr:=1;
      cps:=trunc(totb1/tempr)*60;

      abort:=FALSE; next:=FALSE;

      if (totfils1=0) then begin
        sprint('%120%No files detected!  Transfer aborted.');
        exit;
      end;

      case hua of
        3:begin
              lil:=0;
              sprompt('|LF|%030%The system will disconnect in %150%10 %030%seconds.'+
              ' (%150%!%030%=Hangup now, any key to abort)|LF||LF|');
              st:=timer;
              lasttret:=0;
              x:=11;
              x2:=0;
              sprompt('%030%Waiting: ');
              while (tcheck(st,10)) and (empty) do begin
                x:=tret(st);
                if (x<>-1) then begin
                        if (x2<>0) then prompt(^H' '^H^H' '^H);
                        if ((-(-11+x))=0) then begin
                                sprompt('%140%Disconnecting...');
                        end else begin
                                sprompt('%140%'+mrn(cstr(-(-11+x)),2));
                        end;
                        x2:=x;
                end;
                end;
                nl;
              if (empty) then hangup2:=TRUE;
              lasttret:=0;
              if (not empty) then
                if upcase(inkey)='!' then
                  hangup2:=TRUE else hangup2:=false;
              lil:=0;
            end;
        4:begin
           nl;
           if pynq('%120%Are you sure you want to logoff? %110%') then hangup2:=TRUE;
        end;
      end;

      ahangup:=FALSE;
      checkhangup;
      if (hangup) then begin
        if (spd<>'KB') then begin
          dophonehangup(FALSE);
          spd:='KB';
        end;
        hangup2:=FALSE; ahangup:=TRUE;
      end;

      r2dt(ulrefundgot,ulrefundgot1);
      if (not ahangup) then begin
       sprompt('%030%Files uploaded        : %150%'+cstr(totfils1)+'%030% file');
        if (totfils1<>1) then sprint('%030%s') else nl;
        sprint('%030%File size uploaded    : %150%'+cstrl(totb1)+'%030% bytes');
        sprint('%030%Total upload time     : %150%'+longtim(tooktime));
        sprint('%030%Transfer rate         : %150%'+cstr(cps)+'%030% cps');
        sprint('%030%Time refund           : %150%'+longtim(ulrefundgot1));
        nl;
        pausescr;
      end;

      fiscan(pl);

      {* files not in upload batch queue are ONLY done during the first pass *}
      {* files already in the upload batch queue done during the second pass *}

        findfirst(newtemp+'*.*',anyfile-directory-volumeid,dirinfo);
        while (doserror=0) do begin
          fn:=sqoutsp(dirinfo.name);
          nl;
          ubn:=0;
          wenttosysop:=FALSE;
          fiscan(pl);
          NXF.Fheader.filename:=fn;
          ok:=false;
          sprint('%030%Found file: %150%'+allcaps(fn));
          nl;
(*          if (searchfordups(fn)) then begin
              assign(t,newtemp+fn);
              {$I-} erase(t); {$I+}
              if (ioresult<>0)
              exit;
            end; *)
          if (systat^.extuploadpath<>'') then begin
              sprint(gstring(69));
              currentfile:=newtemp+fn;
              s2:=process_door(systat^.extuploadpath);
              currentswap:=modemr^.swapdoor;
              shel1; 
              shelldos(FALSE,s2,retcode); 
              shel2;
              currentswap:=0;
              currentfile:='';
          end;
          nl;
          if (rvalidate in thisuser.ac) then begin
              wenttosysop:=TRUE;
          end else begin
              if not(ahangup) then
              if (pynq('%120%Mark file as private to '+systat^.sysopname+'? %110%'))
              then wenttosysop:=TRUE;
          end;
          if (not wenttosysop) then begin
              nl;
              done:=FALSE;
              if (ahangup) then begin
                if (newbase<>-1) then dbn:=newbase else dbn:=olduboard;
              end else repeat
                  if (newbase<>-1) then begin
                          dbn:=newbase;
                  end else begin
                          sprompt(gstring(66));
                          defaultst:=cstr(olduboard);
                          inputdef(s,3,'P'); dbn:=value(s);
                          if (s='?') then begin
                                fbasechange(done2,'L');
                                dbn:=-1;
                                nl;
                          end;
                          if (s='') then dbn:=olduboard;
                          if (not (fbaseac(dbn) and infconf(dbn))) then begin
                            sprint('%120%You are not allowed to upload to that filebase.');
                            dbn:=-1;
                          end else loaduboard(dbn);
                          {if (exist(sqoutsp(adrv(memuboard.dlpath)+fn))) then begin
                              sprint('%150%'+fn+' %120%already exists in that filebase.');
                              dbn:=-1;
                          end;}
                  end;
                  if (dbn<>-1) and (s<>'?') then done:=TRUE;
              until ((done) or (hangup));
              fileboard:=dbn;
              nl;
          end;
             {if (passn<>1) then begin
              dothispass:=TRUE;
              sprint('%030%Found file %150%'+fn+'%030%.');
              ubn:=-1;
              fileboard:=-1;
              loaduboard(fileboard);
              wenttosysop:=(fileboard=systat^.tosysopdir);
            end; }

            if (wenttosysop) then fileboard:=systat^.tosysopdir;
            fiscan(pl);
            nl;
            tempdesc:='';
            arcstuff(ok,convt,blks,convtime,TRUE,newtemp,fn,tempdesc);
            nl;
            tconvtime:=tconvtime+convtime; NXF.Fheader.Filesize:=blks;
            assign(fi2,newtemp+fn);
            {$I-} reset(fi2,1); {$I+}
            if (ioresult=0) then begin
              GetFTime(fi2,fpacked);
              UnpackTime(fpacked,dt);
              NXF.Fheader.FileDate:=DTToUnixDate(dt);
              close(fi2);
            end;
            doffstuff(NXF.Fheader,fn,gotpts);
            fok:=TRUE;
            loaduboard(fileboard);
            if (ok) then begin
              sprint('%030%Moving file to %140%'+memuboard.name);
              sprompt('%140%Progress: ');
              movefile(fok,nospace,TRUE,newtemp+fn,(memuboard.dlpath)+fn);
              if (fok) then begin
                newff(NXF.Fheader);
                if (tempdesc<>'') then begin
                  NXF.AddDescLine(tempdesc);
                  sprompt('|LF|%030%GIF specifications added to description: %150%'+tempdesc+'|LF|');
                end;
                nl;
                sprompt(gstring(70));
                ok:=FALSE;
                if (afound(newtemp+fn)) then begin
                  arcdecomp(ok,atype,memuboard.dlpath+fn,'FILE_ID.DIZ');
                end;
                if (ok) then begin
                  ok:=true;
                  if (exist(newtemp+'WORK\FILE_ID.DIZ')) then begin
                    ok:=false;
                    assign(t,newtemp+'WORK\FILE_ID.DIZ');
                    {$I-} reset(t); {$I+}
                    if (ioresult<>0) then ok:=true else begin
                      if (tempdesc<>'') then x:=2 else x:=1;
                      while not(eof(t)) and (x<=syst.ndesclines) do begin
                        readln(t,s);
                        NXF.AddDescLine(copy(s,1,45));
                        inc(x);
                      end;
                      close(t);
                    end;
                    if exist(newtemp+'WORK\FILE_ID.DIZ') then {$I-} erase(t); {$I+}
                    if not(ok) then begin
                      sprint('%150% Found and noted.');
                      inc(fileswithid);
                    end;
                  end;
                end else ok:=true;
                if (ok) then sprint('%150% None found.');
                if (ok) then begin
                  if (ahangup) then begin
                    NXF.AddDescLine('<No description provided.>');
                  end else begin
                    dodescrs(NXF.Fheader,pl,wenttosysop);
                    assign(t,newtemp+'DESCRIPT.TMP');
                    {$I-} reset(t); {$I+}
                    if (ioresult<>0) then begin
                      NXF.AddDescLine('<No description provided.>');
                    end else begin
                      x:=1;
                      while not(eof(t)) and (x<=syst.ndesclines) do begin
                        readln(t,s);
                        NXF.AddDescLine(copy(s,1,45));
                        inc(x);
                      end;
                      close(t);
                      {$I-} erase(t); {$I+}
                      if (ioresult<>0) then begin end;
                    end;
                  end;
                end;
                sprompt('|LF|%150%'+fn+'%030% uploaded successfully.|LF|');
                sl1('+','Uploaded '+sqoutsp(fn)+' on '+memuboard.name);
                inc(totfils);
                lng:=blks; lng:=lng*1024;
                inc(totb,lng);
                inc(totpts,gotpts);
              end else begin
                sprompt('|LF|%120%Could not move file to proper directory.  Upload cancelled.|LF|');
                sl1('!','Error moving file '+sqoutsp(fn)+' Into Directory');
              end;
            end else begin
              sprint('%120%Upload unsuccessful.');
              if ((thisuser.sl>0 {systat^.minresumelatersl} ) and
              (NXF.Fheader.filesize div 1024>systat^.minresume)) then begin
                nl;
                dyny:=TRUE;
                if pynq('%120%Save file to resume upload later? %110%') then begin
                  sprompt('%140%Progress: ');
                  movefile(fok,nospace,TRUE,newtemp+fn,adrv(memuboard.dlpath)+fn);
                  if (fok) then begin
                    nl;
                    doffstuff(NXF.Fheader,fn,gotpts);
                    NXF.Fheader.fileflags:=NXF.Fheader.fileflags+[ffresumelater];
                    NXF.Fheader.access:='';
                    NXF.Fheader.magicname:='';
                    newff(NXF.Fheader);
                    s:='-- File saved for later resume --';
                    if (tempdesc<>'') then begin
                      NXF.AddDescLine(tempdesc);
                      sprint('%030%GIF specifications added to description: %150%'+tempdesc);
                    end;
                    nl;
                    sprompt(gstring(70));
                    ok:=FALSE;
                    if (afound(newtemp+fn)) then begin
                      arcdecomp(ok,atype,newtemp+fn,'FILE_ID.DIZ');
                    end;
                    if (ok) then begin
                      ok:=true;
                      if (exist(newtemp+'WORK\FILE_ID.DIZ')) then begin
                        ok:=false;
                        assign(t,newtemp+'WORK\FILE_ID.DIZ');
                        {$I-} reset(t); {$I+}
                        if (ioresult<>0) then ok:=true else begin
                          if (tempdesc<>'') then x:=2 else x:=1;
                          while not(eof(t)) and (x<=syst.ndesclines) do begin
                            readln(t,s);
                            NXF.AddDescLine(copy(s,1,45));
                            inc(x);
                          end;
                          close(t);
                        end;
                        if exist(newtemp+'WORK\FILE_ID.DIZ') then {$I-} erase(t); {$I+}
                        if not(ok) then begin
                          sprint('%150% Found and noted.');
                          inc(fileswithid);
                        end;
                      end;
                    end else ok:=true;
                    if (ok) then sprint('%150% None found.');
                    if (ok) then begin
                      if (ahangup) then begin
                        NXF.AddDescLine('<No description provided.>');
                      end else begin
                        dodescrs(NXF.Fheader,pl,wenttosysop);
                        assign(t,newtemp+'DESCRIPT.TMP');
                        {$I-} reset(t); {$I+}
                        if (ioresult<>0) then begin
                          NXF.AddDescLine('<No description provided.>');
                        end else begin
                          x:=1;
                          while not(eof(t)) and (x<=syst.ndesclines) do begin
                            readln(t,s);
                            NXF.AddDescLine(copy(s,1,45));
                            inc(x);
                          end;
                          close(t);
                          {$I-} erase(t); {$I+}
                          if (ioresult<>0) then begin end;
                        end;
                      end;
                    end;
                  end else begin
                    sprint('%120%Could not move file to proper directory.  Upload cancelled.');
                    sl1('!','Error moving File '+sqoutsp(fn)+' into directory');
                  end;
                end;
              end;
              if (not (ffresumelater in NXF.Fheader.fileflags)) then begin
                s:='File deleted';
                assign(fi,newtemp+fn); erase(fi);
              end;
              sl1('!','Errors uploading '+sqoutsp(fn)+' - '+s);
            end;

            if (not ok) then begin
              st:=(rte*(NXF.Fheader.Filesize div 1024));
              takeawayulrefundgot:=takeawayulrefundgot+st;
              r2dt(st,st1);
              sprompt('|LF|%030%Time refund of %150%'+longtim(st1)+'%030% will be taken away.|LF|');
            end;
          findnext(dirinfo);
        end;

   fileboard:=olduboard;
   fiscan(pl);

     nl;
     sprint('%030%Files uploaded        : %150%'+cstr(totfils1));
     if (totfils<>totfils1) then
     sprint('%030%Files successful      : %150%'+cstr(totfils));
     sprint('%030%File size uploaded    : %150%'+cstrl(totb1)+'%030% bytes');
     sprint('%030%Upload time           : %150%'+longtim(tooktime));
     sprint('%030%Files with FILE_ID.DIZ: %150%'+cstr(fileswithid));
     r2dt(tconvtime,tconvtime1);
     if (tconvtime<>0.0) then
     sprint('%030%Total convert time    : %150%'+longtim(tconvtime1)+'%120% [Not Refunded]');
     sprint('%030%Transfer rate         : %150%'+cstr(cps)+' cps');
     nl;
     r2dt(ulrefundgot,ulrefundgot1);
     sprint('%030%Time refund           : %150%'+longtim(ulrefundgot1));

     inc(curact^.uploads,totfils);
     inc(curact^.uk,totb1 div 1024);
     if (aacs(systat^.ulvalreq)) then begin
       if (totpts<>0) then
       sprint('%030%Filepoints            : %150%'+cstr(totpts));
       sprint('%030%Upload credits        : %150%'+cstr(totfils)+'%030% files, %150%'+cstr(totb1 div 1024)+'%030%k');
       inc(thisuser.uploads,totfils);
       inc(thisuser.filepoints,totpts);
       thisuser.uk:=thisuser.uk+(totb1 div 1024);
     end else begin
       sprompt('%030%File');
       if (systat^.uldlratio) then sprompt('%030% credit')
       else sprompt('%030%points');
       sprint('%030% will be awarded when %150%'+systat^.sysopname+'%030% validates the file'+plural+'.');
     end;
     nl;

     if (choptime<>0.0) then begin
       choptime:=choptime+ulrefundgot;
       freetime:=freetime-ulrefundgot;
       sprint('%030%Sorry, no upload time refund may be given at this time.');
       sprint('%030%You will receive your refund after the event.');
       nl;
     end;

     if (takeawayulrefundgot<>0.0) then begin
       nl;
       r2dt(takeawayulrefundgot,takeawayulrefundgot1);
       sprint('%030%Taking away time refund of %150%'+longtim(takeawayulrefundgot1)+'%030%.');
       freetime:=freetime-takeawayulrefundgot;
     end;

     if (ahangup) then begin
       printf('LOGOFF');
       delay(2000);
       dophonehangup(FALSE);
       hangup2:=TRUE;
     end;

   end;
 end;
 if (savpause) then thisuser.ac:=thisuser.ac+[pause];
 printf('AFTERUL');
 loaduboard(olduboard);
end;

end.
