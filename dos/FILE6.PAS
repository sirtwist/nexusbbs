{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R-,S+,V-}
unit file6;

interface

uses
  crt, dos, common,
  execbat;

procedure delbatch(n:integer);
procedure mpkey(var s:astr);
function bproline1(cline:astr):astr;
procedure bproline(var cline:astr; filespec:astr);
function okprot(prot:protrec; ul,dl,batch,resume:boolean):boolean;
procedure showprots(ul,dl,batch,resume:boolean);
function findprot(cs:char; ul,dl,batch,resume:boolean):integer;
procedure batchdl;
procedure removebatchfiles;
procedure clearbatch;

implementation

uses file0, file1, file2, file4, file9, archive1;

var protocol:protrec;             { protocol in memory                    }
    batchf:file of flaggedrec;
    batchrec:flaggedrec;

function substall2(src,old,new:astr):astr;
var p:integer;
begin
  p:=1;
  while p>0 do begin
    p:=pos(old,allcaps(src));
    if p>0 then begin
      insert(new,src,p+length(old));
      delete(src,p,length(old));
    end;
  end;
  substall2:=src;
end;

procedure delbatch(n:integer);
var c:integer;
begin
  if ((n>=1) and (n<=numbatchfiles)) then begin
        assign(batchf,adrv(systat^.temppath)+'FLAG'+cstrn(cnode)+'.DAT');
        {$I-} reset(batchf); {$I+}
        if (ioresult<>0) then begin
                exit;
        end;
        if (filesize(batchf)=0) then begin
                close(batchf);
                {$I-} erase(batchf); {$I+}
                if (ioresult<>0) then begin end;
                numbatchfiles:=0;
                exit;
        end;
        if (numbatchfiles<>filesize(batchf)) then numbatchfiles:=filesize(batchf);
        if (n>numbatchfiles) then begin
                close(batchf);
                exit;
        end;
        seek(batchf,n-1);
        read(batchf,batchrec);
        batchtime:=batchtime-batchrec.ttime;
        for c:=n to numbatchfiles-1 do begin
                seek(batchf,c);
                read(batchf,batchrec);
                seek(batchf,c-1);
                write(batchf,batchrec);
        end;
        dec(numbatchfiles);
        seek(batchf,filesize(batchf)-1);
        truncate(batchf);
        if (filesize(batchf)=0) then begin
                close(batchf);
                {$I-} erase(batchf); {$I+}
                if (ioresult<>0) then begin end;
                numbatchfiles:=0;
        end else close(batchf);
  end;
end;

procedure mpkey(var s:astr);
var sfqarea,smqarea:boolean;
begin
  sfqarea:=fqarea; smqarea:=mqarea;
  fqarea:=FALSE; mqarea:=FALSE;

  onek(s[1],'ABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890!@#$%^&*()[]+=-/\~`?<>,.{}');

  fqarea:=sfqarea; mqarea:=smqarea;
end;


function bproline1(cline:astr):astr;
var s,s1:astr;
begin
  if ((not incom) and (not outcom)) then s1:=cstrl(0) else begin
         s1:=cstrl(answerbaud);
  end;
  s:=substall2(cline,'|BAUD|',s1);
  if ((not incom) and (not outcom)) then s1:=cstrl(0) else begin
        if not(modemr^.lockport) then s1:='0' else s1:=cstrl(modemr^.waitbaud);
  end;
  s:=substall2(s,'|LOCKBAUD|',s1);
  s:=substall2(s,'|FILELIST|',processmci(protocol.dlflist));
  s:=substall2(s,'|DLDIR|',aonoff(memuboard.cdrom,allcaps(newtemp+'CDROM'),allcaps(memuboard.dlpath)));
  s:=substall2(s,'|ULDIR|',allcaps(newtemp));
  s:=substall2(s,'|PORT|',cstr(modemr^.comport));
  s:=substall2(s,'|TEMPFILE|',processmci(protocol.templog));
  s:=substall2(s,'|NODE|',cstrn(cnode));
  s:=processmci(s);
  while (pos('\\',s)<>0) do begin
        delete(s,pos('\\',s),1);
  end;
  bproline1:=s;
end;

procedure bproline(var cline:astr; filespec:astr);
const lastpos:integer=-1;
begin
  if (pos('|FILENAME|',allcaps(cline))<>0) then begin
    lastpos:=pos('|FILENAME|',allcaps(cline))+length(filespec);
    cline:=substall2(cline,'|FILENAME|',filespec);
  end else begin
    insert(' '+filespec,cline,lastpos);
    inc(lastpos,length(filespec)+1);
  end;
end;

function okprot(prot:protrec; ul,dl,batch,resume:boolean):boolean;
var s:astr;
begin
  okprot:=FALSE;
  with prot do begin
    if (batch) then begin
        if not(xbBatch in xbstat) then exit;
    end;
        if (resume) then begin
                if not(xbResume in xbstat) then exit;
        end; { else begin }
    if (ul) then s:=ulcmd;
    if (dl) then s:=dlcmd;
    if (s='') then exit;
    if not(xbactive in xbstat) then exit;
    if not(aacs(acs)) then exit;
  end;
  OKProt:=TRUE;
end;

procedure showprots(ul,dl,batch,resume:boolean);
var s:astr;
    i:integer;
    abort,next:boolean;
begin
  nofile:=TRUE;
  if (resume) then printf('PRRESUME')
  else begin
    if (ul) then printf('PRUL');
    if (batch) and (dl) then printf('PRFLAGDL');
    if (not batch) and (dl) then printf('PRDL');
  end;
  if (nofile) then begin
    seek(xf,0);
    abort:=FALSE; next:=FALSE; i:=0;
    while ((i<=filesize(xf)-1) and (not abort)) do begin
      read(xf,protocol);
      if (okprot(protocol,ul,dl,batch,resume)) then sprint(protocol.descr);
      wkey(abort,next);
      inc(i);
    end;
  end;
end;

(* XF should be OPEN  --
   returns:
     (-1):Ascii   (xx):Xmodem   (xx):Xmodem-CRC   (xx):Ymodem  (-4):Zmodem
     (-10):Quit   (-11):Next    (-12):Batch       (-99):Invalid (or no access)
   else, the protocol #
*)
function findprot(cs:char; ul,dl,batch,resume:boolean):integer;
var s:astr;
    i:integer;
    done:boolean;
begin
  findprot:=-99;
  if (cs='') then exit;
  seek(xf,0);
  done:=FALSE; i:=0;
  while ((i<=filesize(xf)-1) and (not done)) do begin
    read(xf,protocol);
    with protocol do
      if (cs=ckeys) then
        if (okprot(protocol,ul,dl,batch,resume)) then begin
           done:=TRUE; findprot:=i;
        end;
    inc(i);
  end;
end;

procedure removebatchfiles2;
var s:astr;
    i:integer;
begin
  if numbatchfiles=0 then begin
    nl; sprompt('%120%No files currently flagged.|LF|');
  end else
    repeat
      nl;
      sprompt('%030%File # to unflag (%150%1%030%-%150%'+cstr(numbatchfiles)+'%030%, %150%?%030%=List) : %150%');
      scaninput(s,'Q?'^M,TRUE); i:=value(s);
      if (s='?') then listbatchfiles;
      if (i>0) and (i<=numbatchfiles) then begin
        delbatch(i);
      end;
    until (s<>'?');
end;

procedure batchdl;
var batfile,tfil:text;  {@4 file list file}
    xferstart,xferend,tooktime,batchtime1:datetimerec;
    singlename,nfn,snfn,s,s1,s2,i,logfile:astr;
    st,tott,tooktime1:real;
    tblks,tblks1,cps,lng:longint;
    x5,x,tpts,tpts1,tnfils,tnfils1:integer;
    x2,sx,sy,hua,n,p,toxfer,rcode:integer;
    c:char;
    isbatch,dldesc,ok,nospace,displayed,swap,done1,dok,kabort,nomore,readlog:boolean;

  procedure sprtcl(c:char; s:astr);
  var wnl:boolean;
  begin
    if copy(s,length(s),1)<>#0 then wnl:=TRUE else wnl:=FALSE;
    if not wnl then s:=copy(s,1,length(s)-1);
    sprompt('%030%'+c+'%070%) %090%'+s);
    if wnl then nl;
  end;

  procedure addnacc(i:integer; s:astr);
  var oldboard,pl,rn:integer;
  begin
    if (i<>-1) then begin
      oldboard:=fileboard; fileboard:=i;
      s:=sqoutsp(stripname(s));
      recno(align(s),pl,rn); {* opens ulff *}
      if rn<>0 then begin
        NXF.Seekfile(rn);
        NXF.Readheader;
        inc(NXF.Fheader.Numdownloads);
        NXF.Fheader.LastDLDate:=u_daynum(datelong+'  '+time);
        NXF.Rewriteheader(NXF.Fheader);
      end;
      fileboard:=oldboard;
    end;
  end;

  procedure chopoffspace(var s:astr);
  begin
    if (pos(' ',s)<>0) then s:=copy(s,1,pos(' ',s)-1);
  end;

procedure clearbatch2;
begin
    assign(batchf,adrv(systat^.temppath)+'FLAG'+cstrn(cnode)+'.DAT');
    {$I-} erase(batchf); {$I+}
    numbatchfiles:=0;
    batchtime:=0.0;
end;

  procedure figuresucc;
  var filestr,statstr:astr;
      foundit:boolean;

    function wasok:boolean;
    var i:integer;
        foundcode:boolean;
    begin
      foundcode:=FALSE;
      if (protocol.dlcode=rcode) then foundcode:=TRUE;
      wasok:=FALSE;
      if (not(foundcode)) then exit;
      wasok:=TRUE;
    end;

  begin
    readlog:=FALSE;
    if not(wasok) then exit;
    if (not readlog) then begin
      {$I-} reset(batchf); {$I+}
      if (ioresult<>0) then begin
        sprint('The file containing the list of flagged files has become corrupted.  You may');
        sprint('not have received all the files that were flagged.  '+systat^.sysopname);
        sprint('has been informed.');
        sl1('!','FLAG'+cstrn(cnode)+'.DAT is bad or missing after download.');
        exit;
      end;
      if (toxfer>1) then sl1('%','Files downloaded in BATCH mode');
      while (toxfer>0) do begin
        seek(batchf,toxfer-1);
        read(batchf,batchrec);
        sl1('%','Download '+allcaps(stripname(batchrec.filename)));
        inc(tnfils);
        inc(tblks,batchrec.blocks);
        inc(tpts,batchrec.filepoints);
        loaduboard(batchrec.filebase);
        if (not (fbnoratio in memuboard.fbstat)) and not(batchrec.isfree) then begin
          inc(tnfils1);
          inc(tblks1,batchrec.blocks);
          inc(tpts1,batchrec.filepoints);
        end;
        addnacc(batchrec.filebase,batchrec.filename);
        dec(toxfer);
      end;
      close(batchf);
      clearbatch2;
     end;
  end;

begin
  dldesc:=false;
  singlename:='';
  if (numbatchfiles=0) then begin
    nl;
    sprint('%030%There are currently no files flagged.');
  end else begin

    done1:=FALSE;
    repeat
      listbatchfiles;
      nl;
      p:=0;
      if (batchtime>nsl) then begin
        sprompt('%120%Insufficient time remaining for download.  You must remove some files from|LF|');
        sprompt('%120%your batch.|LF||LF|');
      end;
      s:='RC';
      sprompt('%030%(%150%R%030%)emove file, %030%(%150%C%030%)lear all files, ');
      if (batchtime<nsl) then begin
              sprompt('%030%(%150%A%030%)dd files, ');
              s:=s+'A';
      end;
      sprompt('%030%(%150%Q%030%)uit');
      if (batchtime>nsl) then begin
              sprompt(': %150%');
              s:=s+'Q';
      end else begin
              sprompt(', %030%(%150%ENTER%030%) to continue: %150%');
              s:=s+'Q'^M;
      end;
      onek(c,s);
      case c of
        'R':begin
                removebatchfiles2;
                if (numbatchfiles=0) then begin
                        done1:=true;
                        p:=-10;
                end;
            end;
        'C':begin
                clearbatch;
                done1:=true;
                p:=-10;
            end;
        'A':begin
                fflag:=TRUE;
                dlflag:=FALSE;
                idl;
            end;
        'Q':begin
                p:=-10;
                done1:=TRUE;
            end;
        #13:begin
                done1:=TRUE;
            end;
        end;
    until (done1) or (hangup);
    if (p<>-10) then begin
    nl;
    if pynq('%120%Download file descriptions? %110%') then dldesc:=TRUE;
    end;
    isbatch:=FALSE;
    if (numbatchfiles>1) then isbatch:=TRUE;
    if (numbatchfiles=1) and (dldesc) then isbatch:=TRUE;
    {$I-} reset(xf); {$I+}
    if (ioresult<>0) then begin
        sprompt('|LF|%120%No protocols available!  Transfer aborted!|LF||LF|');
        p:=-10;
    end;
    i:='?';
    if (thisuser.defprotocol<>'@') and (p<>-10) then
    p:=findprot(thisuser.defprotocol,TRUE,FALSE,isbatch,FALSE);
    if (p=0) or (p=-99) then
    repeat
      done1:=FALSE;
      nl;
      showprots(FALSE,TRUE,isbatch,FALSE); 
      nl;
      sprompt(gstring(67)); mpkey(i);
      if (i='Q') then begin done1:=true; p:=-10; end else begin
        p:=findprot(i[1],FALSE,TRUE,isbatch,FALSE);
        if (p=-99) then begin
                sprint(gstring(8)); 
        end else done1:=TRUE;
      end;
    until (done1) or (hangup);

    if (p<>-10) then begin
      seek(xf,p); read(xf,protocol); close(xf);
      repeat
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
      until (c<>'?');
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
        tblks:=0; tpts:=0; tnfils:=0;
        tblks1:=0; tpts1:=0; tnfils1:=0;
        toxfer:=0; tott:=0.0;
        nl; nl;

        assign(batchf,adrv(systat^.temppath)+'FLAG'+cstrn(cnode)+'.DAT');
        {$I-} reset(batchf); {$I+}
        if (ioresult<>0) then begin
                sprint('No Files Are Currently Flagged.');
                exit;
        end;
        displayed:=FALSE;
        if (dldesc) then begin
            assign(batfile,newtemp+'WORK\FILES.BBS');
            {$I-} rewrite(batfile); {$I+}
            writeln(batfile,'');
            if (ioresult=0) then begin
                 seek(batchf,0);
                 while not(eof(batchf)) do begin
                        read(batchf,batchrec);
                        write(batfile,mln(stripname(batchrec.filename),12)+'   ');
                        x5:=1;
                        while (x5<=10) and (batchrec.descript[x5]<>'') do begin
                                if (x5<>1) then write(batfile,mln(' ',15));
                                writeln(batfile,batchrec.descript[x5]);
                                inc(x5);
                        end;
                        writeln(batfile,'');
                        writeln(batfile,'');
                 end;
                 seek(batchf,0);
                 close(batfile);
            end;
        end;
        if (numbatchfiles<>filesize(batchf)) then numbatchfiles:=filesize(batchf);
        nfn:=processmci(protocol.dlcmd);
        if (numbatchfiles=1) and not(dldesc) then begin
          done1:=FALSE;
            seek(batchf,0);
            read(batchf,batchrec);
            toxfer:=1; snfn:=nfn;
            ok:=TRUE;
            if (batchrec.iscdromfile) then begin
                if not(displayed) then begin
                        sprint('%120%Copying files on CD-ROM to the local disk...');
                        nl;
                        displayed:=TRUE;
                       end;
                sprompt('%150%'+allcaps(mln(stripname(batchrec.filename),12))+': ');
                copyfile(ok,nospace,TRUE,adrv(batchrec.filename),newtemp+'CDROM\'+stripname(batchrec.filename));
                nl;
                if not(ok) or (nospace) then begin
                        sprompt('%120%Cannot copy %150%'+stripname(batchrec.filename));
                        if (nospace) then sprint(' %150%- Insufficient Drive Space!')
                                else nl;
                        singlename:=batchrec.filename;
                end else singlename:=newtemp+'CDROM\'+stripname(batchrec.filename);
            end else singlename:=batchrec.filename;
            if (length(nfn)>protocol.maxchrs) then ok:=FALSE
              else tott:=tott+batchrec.ttime;
        if (ok) and (numbatchfiles=1) then begin
         nfn:=nfn+' SINGLE '+cstrl(modemr^.comport);
         if (not(incom) and not(outcom)) then nfn:=nfn+' '+cstrl(0)
                else nfn:=nfn+' '+cstrl(answerbaud);
         if not(modemr^.lockport) then nfn:=nfn+' '+cstrl(answerbaud) else
                nfn:=nfn+' '+cstrl(modemr^.waitbaud);
         nfn:=nfn+' '+singlename;
        end;
        end;
        displayed:=FALSE;
        if (protocol.dlflist='') and ((numbatchfiles<>1) or (dldesc)) then begin
                sl1('!','Batch download failed: No download file list');
                sprint('%120%Error accessing transfer protocol... aborted.');
                exit;
        end;
        if (protocol.dlflist<>'') and ((numbatchfiles<>1) or (dldesc)) then begin
          tott:=0.0;
          assign(batfile,bproline1(protocol.dlflist));
          rewrite(batfile);
          if (xbUseOpus in protocol.xbstat) then begin
          writeln(batfile,cstrl(modemr^.comport));
          writeln(batfile,cstrl(answerbaud));
          writeln(batfile,adrv(systat^.trappath)+'NEX'+cstrn(cnode)+'.LOG');
          writeln(batfile,ctim(nsl));
          end;
          for n:=1 to numbatchfiles do begin
            seek(batchf,n-1);
            read(batchf,batchrec);
            if (batchrec.iscdromfile) then begin
                if not(displayed) then begin
                        sprint('%120%Copying files on CD-ROM to the local disk...');
                        nl;
                        displayed:=TRUE;
                       end;
                sprompt('%150%'+allcaps(mln(stripname(batchrec.filename),12))+': ');
                copyfile(ok,nospace,TRUE,adrv(batchrec.filename),newtemp+'CDROM\'+stripname(batchrec.filename));
                nl;
                if not(ok) or (nospace) then begin
                        sprompt('%120%Cannot copy %150%'+stripname(batchrec.filename));
                        if (nospace) then sprint(' %150%- Insufficient Drive Space!')
                                else nl;
                        writeln(batfile,batchrec.filename);
                end else
                writeln(batfile,newtemp+'CDROM\'+stripname(batchrec.filename));
            end else
            writeln(batfile,batchrec.filename);
            inc(toxfer); tott:=tott+batchrec.ttime;
          end;
          if (dldesc) then writeln(batfile,newtemp+'WORK\FILES.BBS');
          close(batfile);
          close(batchf);
         nfn:=nfn+' BATCH '+cstrl(modemr^.comport);
         if (not(incom) and not(outcom)) then nfn:=nfn+' '+cstrl(0)
                else nfn:=nfn+' '+cstrl(answerbaud);
         if not(modemr^.lockport) then nfn:=nfn+' '+cstrl(answerbaud) else
                nfn:=nfn+' '+cstrl(modemr^.waitbaud);
         nfn:=nfn+' '+bproline1(protocol.dlflist);

        end;                     

        (* Create transfer batch file *)

        if (xbINTERNAL in protocol.xbstat) then begin
                s:=adrv(systat^.utilpath)+'NXPDRIVE.EXE -S -B'+cstr(answerbaud);
                s:=s+' -C'+cstr(modemr^.comport)+' -N'+cstr(cnode);
                case modemr^.ctype of
                        0:s:=s+' -D1';
                        1:s:=s+' -D2';
                        2:s:=s+' -D3';
                        3:s:=s+' -D1';
                end;
                if (xbMiniDisplay in protocol.xbstat) then begin
                        s:=s+' -M';
                end;
                if (protocol.dlcmd='INT_ZMODEM_SEND') then begin
                        s:=s+' -Z';
                end else
                if (protocol.dlcmd='INT_YMOD-G_SEND') then begin
                        s:=s+' -G';
                end else
                if (protocol.dlcmd='INT_YMODEM_SEND') then begin
                        s:=s+' -Y';
                end else
                if (protocol.dlcmd='INT_XMOD1K_SEND') then begin
                        s:=s+' -K';
                end else
                if (protocol.dlcmd='INT_XMODEM_SEND') then begin
                        s:=s+' -X';
                end;
                if (isbatch) then begin
                        s:=s+' -L='+bproline1(protocol.dlflist);
                end else begin
                        s:=s+' -F='+singlename;
                end;
        end else begin
                assign(batfile,newtemp+'NXPROT01.BAT');
                rewrite(batfile);
                writeln(batfile,'@ECHO OFF'); 
                if (protocol.envcmd<>'') then
                          writeln(batfile,bproline1(protocol.envcmd));
                writeln(batfile,nfn);
                writeln(batfile,'EXIT');
                close(batfile);
                s:=newtemp+'NXPROT01.BAT';
        end;

        (* delete old log file *)
        if (exist(bproline1(protocol.templog))) then begin
          assign(batfile,bproline1(protocol.templog));
          {$I-} erase(batfile); {$I+}
          if (ioresult<>0) then begin end;
        end;

        r2dt(batchtime,batchtime1);
        shelling:=1;
        if (useron) then
          sprint('%150%Sending files (Time: '+longtim(batchtime1)+')');

        if not(xbINTERNAL in protocol.xbstat) then begin
        if (useron) then shel('User downloading: '+nam)
                    else shel('Sending file(s)');
        end else shel('');
        getdatetime(xferstart);
        currentswap:=modemr^.swapprotocol;
        rcode:=protocol.dlcode;
        shelldos(FALSE,s,rcode);
        shel2;
        currentswap:=0;
        shelling:=0;
        getdatetime(xferend);
        timediff(tooktime,xferstart,xferend);
        assign(batfile,newtemp+'NXPROT01.BAT');
        {$I-} erase(batfile); {$I+}
        if (ioresult<>0) then begin end;
        figuresucc;
        tooktime1:=dt2r(tooktime);
        if (tooktime1>=1.0) then begin
          cps:=tblks; cps:=cps*1024;
          cps:=trunc(cps/tooktime1);
        end else
          cps:=0;

        nl; nl;
        purgedir(newtemp+'CDROM');
        purgedir(newtemp+'WORK');

        if (exist(bproline1(protocol.templog))) then begin
          assign(batfile,bproline1(protocol.templog));
          {$I-} erase(batfile); {$I+}
          if (ioresult<>0) then begin end;
        end;

        if (exist(bproline1(protocol.dlflist))) then begin
          assign(batfile,bproline1(protocol.dlflist));
          {$I-} erase(batfile); {$I+}
          if (ioresult<>0) then begin end;
        end;

        s:='%030%Download Totals : %150%';
        if (tnfils=0) then s:=s+'No' else s:=s+cstr(tnfils);
        s:=s+' file'; if (tnfils<>1) then s:=s+'s';
        lng:=tblks; lng:=lng*1024;
        s:=s+'%030%, %150%'+cstrl(lng)+' Bytes';
        if (tpts<>0) and (systat^.fileptratio) then begin
          s:=s+'%030%, %150%'+cstr(tpts)+' File Point';
          if (tpts<>1) then s:=s+'s';
        end;
        s:=s+'%030%.';
        sprint(s);
        if (tnfils1<>tnfils) then begin
          if (tnfils<tnfils1) then tnfils1:=tnfils;

          s:='%030%Download charges: %150%';
          if (tnfils1=0) then s:=s+'No' else s:=s+cstr(tnfils1);
          s:=s+' file'; if (tnfils1<>1) then s:=s+'s';
          lng:=tblks1; lng:=lng*1024;
          s:=s+'%030%, %150%'+cstrl(lng)+' bytes';
          if (tpts1<>0) and (systat^.fileptratio) then begin
            s:=s+'%030%, %150%'+cstr(tpts1)+' Filepoint';
            if (tpts1<>1) then s:=s+'s';
          end;
          s:=s+'.';
          sprint(s);
        end;

        sprint('%030%Download time   : %150%'+longtim(tooktime)+'%030%, Transfer rate: %150%'+cstr(cps)+' cps');

        thisuser.dk:=thisuser.dk+(tblks1 div 8);
        inc(thisuser.downloads,tnfils1);
        dodl(tpts1);

        inc(curact^.downloads,tnfils);
        inc(curact^.dk,tblks div 8);

        if (numbatchfiles<>0) then begin
          tblks:=0; tpts:=0;
          {$I-} reset(batchf); {$I+}
          if (ioresult<>0) then exit;
          for n:=1 to numbatchfiles do begin
            seek(batchf,n-1);
            read(batchf,batchrec);
            inc(tblks,batchrec.blocks);
            inc(tpts,batchrec.filepoints);
          end;
          close(batchf);
          lng:=tblks; lng:=lng*1024;
          s:='%030%Not transferred :  %110%'+cstr(numbatchfiles)+' file';
          if (numbatchfiles<>1) then s:=s+'s';
          s:=s+'%030%, %150%'+cstrl(lng)+' bytes';
          if (tpts<>0) then begin
            s:=s+'%030%, %150%'+cstr(tpts)+' filepoint';
            if (tpts<>1) then s:=s+'s';
          end;
          s:=s+'%150%.';
          sprint(s);
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
      end;
    end;
  end;
end;


procedure removebatchfiles;
var s:astr;
    i:integer;
begin
  if numbatchfiles=0 then begin
    nl; sprint('%150%There are currently no flagged files.');
  end else begin
    listbatchfiles;
    repeat
      nl;
      sprompt('%030%File # to remove (%150%1%030%-%150%'+
      cstr(numbatchfiles)+'%030%, %150%?%030%=List, %150%Q%030%=Quit) : %150%');
      scaninput(s,'Q?',TRUE); i:=value(s);
      if (s='?') then listbatchfiles;
      if (i>0) and (i<=numbatchfiles) then begin
        sprint('%030%File #%150%'+cstr(i)+' %030%removed from batch.');
        delbatch(i);
      end;
      nl;
      if (numbatchfiles=0) then sprint('%150%There are currently no flagged files.');
    until (s='Q') or (numbatchfiles=0);
    end;
end;

procedure clearbatch;
begin
  nl;
  if pynq('%120%Unflag all files? %110%') then begin
    assign(batchf,adrv(systat^.temppath)+'FLAG'+cstrn(cnode)+'.DAT');
    {$I-} erase(batchf); {$I+}
    if (ioresult<>0) then begin end;
    numbatchfiles:=0;
    batchtime:=0.0;
  end;
end;

end.
