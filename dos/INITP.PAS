{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R-,S+,V-}
unit initp;

interface

uses
  crt, dos,
  myio3, mail6,cdrom,
  common;

procedure initp1;
procedure init;

var startdir:string;

implementation

uses file0;

procedure readp;
var filv:text;
    d:astr;
    x,a,count:integer;
    cnd,s:string;
    c,c2:char;
    wind:windowrec;
    getnodenum:boolean;

  function sc(s:astr; i:integer):char;
  begin
    if (i>length(s)) then sc:=#0 else begin
    s:=allcaps(s); sc:=s[i];
    end;
  end;


  function atoi(s:astr):word;
  var i,code:integer;
  begin
    val(s,i,code);
    if code<>0 then i:=0;
    atoi:=i;
  end;

        procedure getavailablenode;
        var dir:searchrec;
            mr:modemrec;
            mrf:file of modemrec;
            done:boolean;

function fileonly(s:string):string;
var
 x : integer;
 dn : boolean;
begin
 x := length(s);
 dn:=FALSE;
 while (x > 1) and not (dn) do begin
       if s[x] = '\' then begin
          dn := true;
       end;
       dec(x);
 end;
 if not(dn) then s:='' else
 s := copy(s,x+2,length(s));
 fileonly := s;
end;

        begin
        done:=FALSE;
        cnode:=0;
        findfirst(adrv(systat^.gfilepath)+'NODE????.DAT',AnyFile,dir);
        while (doserror=0) and not(done) do begin
                writeln(adrv(systat^.gfilepath)+dir.name);
                assign(mrf,adrv(systat^.gfilepath)+dir.name);
                {$I-} reset(mrf); {$I+}
                if (ioresult=0) then begin
                        {$I-} read(mrf,mr); {$I+}
                        if (ioresult=0) then begin
                                writeln('read');
                                if ((not(localioonly) and (mr.ctype<>0)) or ((localioonly) and (mr.ctype=0))) then begin
                                        writeln(mr.ctype);
                                        if not(exist(adrv(systat^.semaphorepath)+'INUSE.'+
                                        cstrnfile(value(copy(dir.name,5,4)))))
                                        then begin
                                                done:=TRUE;
                                                writeln('true');
                                        end;
                                end;
                        end;
                        close(mrf);
                end;
                if not(done) then findnext(dir);
        end;
        if (done) then cnode:=value(copy(dir.name,5,4));
        writeln(cnode);
       end;

        procedure helpscreen;
        begin
                textcolor(7);
                textbackground(0);
                clrscr;
                cwrite(verline(1)+#13#10);
                cwrite(verline(2)+#13#10);
                cwrite(verline(3)+#13#10);
                textcolor(7);
                textbackground(0);
                writeln;
                writeln('Syntax:   NEXUS <required parameters> [options]');
                writeln;
                writeln('Required parameters:');
                writeln;
                writeln('-N[xxxx:A]  Start node #xxxx, -NA for auto-node');
                writeln('-Bxxxxxx    Start Nexus in online mode with baud rate xxxxxx');
                writeln('-K[F]       Local I/O only (-KF for fast logon)');
                writeln;
                writeln('Options:');
                writeln;
                writeln('-Xxxxx      Ext. event xxxx sec. after start');
                writeln('-E[E:N]xxx  Exit with errorlevel xxx (-EE errors, -EN normal)');
                writeln('-CDMAP      Use CDROM map instead of scan');
                writeln;
                {$I-} chdir(startdir); {$I+}
                if (ioresult<>0) then begin end;
                halt(elevel);
        end;
begin
  cursoron(FALSE); exteventtime:=0;
  answerbaud:=0; quitafterdone:=FALSE; nightly:=FALSE;
  localioonly:=FALSE;
  a:=0;
  cnode:=0;
  cnd:='';
  if (paramcount=0) then begin
        helpscreen;
  end;
  while (a<paramcount) do begin
    inc(a);
    if ((sc(paramstr(a),1)='-') or (sc(paramstr(a),1)='/')) then
      case sc(paramstr(a),2) of
        'B':begin answerbaud:=value(copy(paramstr(a),3,length(paramstr(a))-2));
            spd:=cstrl(answerbaud);
            quitafterdone:=true; usewfcmenu:=FALSE; end;
        'T':begin telnet:=TRUE; end;
        'C':begin
                if (allcaps(copy(paramstr(a),2,length(paramstr(a))))='CDMAP') then
                        cdmap:=TRUE;
            end;
        'N':begin
            d:=paramstr(a);
            if (sc(d,3)='A') then begin
                getnodenum:=true;
            end else begin
            for x:=3 to length(d) do
                cnd:=cnd+d[x];
            cnode:=value(cnd);
            end;
            end;
        'E':if (length(paramstr(a))>=4) then begin
              d:=allcaps(paramstr(a));
              case d[3] of
                'E':exiterrors:=value(copy(d,4,length(d)-3));
                'N':exitnormal:=value(copy(d,4,length(d)-3));
              end;
            end;
        'K':begin
            localioonly:=TRUE;
            spd:='KB';
            fastlocal:=FALSE;
            case sc(paramstr(a),3) of
                'F':begin
                        fastlocal:=TRUE;
                        usewfcmenu:=FALSE;
                    end;
                'L':begin
                        disablelocalkeys:=TRUE;
                        usewfcmenu:=false;
                    end;
            end;
            end;
        'X':exteventtime:=atoi(copy(paramstr(a),3,length(paramstr(a))-2));
        '?':begin
                helpscreen;
        end;
      end;

  end;
  if (getnodenum) then begin
                getavailablenode;
  end;
  allowabort:=TRUE;
end;


procedure initp1;
var filv:text;
    fstringf:file;
    conf:file of confrec;
    modemrf:file of modemrec;
    fidorf:file of fidorec;
    fidor:fidorec;                { FidoNet information                   }
    langname:string;
    f,fp:file;
    sr:smalrec;
    wind:windowrec;
    x,sx,sy,numread,i:integer;
    testl:longint;
    uidf:file of useridrec;
    uid:useridrec;
    donedr,dn,errs,npatch,npatch2:boolean;
    dvs,s:astr;
    drec:searchrec;
    regs:registers;

  procedure wmsgs(s:astr);
  var x,y:integer;
  begin
    cwrite('%120%<%100%ù%120%> '+s+#13#10);
  end;

  procedure inmsgs(sh:astr; var s:astr; len:integer);
  var x,y:integer;
  begin
    cwrite('%090%'+sh+#13#10);
    cwrite('%090%: ');
    infielde(s,len);
    writeln;
  end;

  function existdir(fn:astr):boolean;
  var srec:searchrec;
  begin
    while (fn[length(fn)]='\') do fn:=copy(fn,1,length(fn)-1);
    findfirst(fexpand(sqoutsp(fn)),anyfile,srec);
    existdir:=(doserror=0) and (srec.attr and directory=directory);
  end;
    
  procedure abend(s:astr);
  begin
    wmsgs(s+' exiting.%070%');
    halt(exiterrors);
  end;

  procedure findbadpaths(x:integer);
  var s,s1,s2:astr;
      i:integer;
  begin
    infield_out_fgrd:=7;
    infield_out_bkgd:=0;
    infield_inp_fgrd:=7;
    infield_inp_bkgd:=0;

    with systat^ do
      for i:=1 to x do begin
        case i of 1:s1:='Data'; 2:s1:='User'; 3:s1:='Menus';  4:s1:='Temporary';
                  5:s1:='Graphics'; 6:s1:='Log'; 
                  7:s1:='Swap';
                  8:s1:='Current Node Temporary'; 9:s1:='Current Node Swap';
        end;
        case i of
          1:s:=gfilepath;  2:s:=userpath;    4:s:=temppath;
          3:s:=menupath;   5:s:=afilepath;  6:s:=trappath;
          7:s:=swappath;   8:s:=newtemp;    9:s:=newswap;
        end;
        if (not existdir(s)) then begin
          cursoron(TRUE);
          writeln;
          wmsgs('The '+s1+' path set as: '+s);
          wmsgs('Path is invalid or missing.');
          repeat
            writeln;
            s2:=s; inmsgs('New '+s1+' path: ',s2,60); s2:=allcaps(sqoutsp(s2));
            if (s=s2) or (s2='') then begin
                 writeln;
                 abend('Path does not exist...');
            end else begin
              if (s2<>'') then
                if (copy(s2,length(s2),1)<>'\') then s2:=s2+'\';
              if (existdir(s2)) then
                case i of
                  1:gfilepath:=s2;  2:userpath:=s2;
                  3:menupath:=s2;   4:temppath:=s2;
                  5:afilepath:=s2;  6:trappath:=s2;
                  7:swappath:=s2;
                  8:newtemp:=s2;   9:newswap:=s2;
                end
              else begin
                writeln;
                wmsgs('Path does not exist...');
              end;
            end;
          until (existdir(s2));
          cursoron(FALSE);
        end;
      end;
  end;

begin
  textbackground(7); textcolor(0);
  wantout:=TRUE;
  ldate:=daynum(datelong);
  ch:=FALSE; lil:=0; thisuser.pagelen:=20; buf:=''; chatcall:=FALSE;
  chatr:=''; 
 
  textcolor(7);textbackground(0);
  if (exist(start_dir+'\ERR'+cstrn(cnode)+'.FLG')) then begin
    assign(filv,start_dir+'\ERR'+cstrn(cnode)+'.FLG'); erase(filv);
    textcolor(12);
    cwrite('%120%<%100%ù%120%> A critical error occurred during the last Nexus execution...'+#13#10);
    inc(curact^.criterr);
    savesystat;
    wascriterr:=TRUE;
  end;
  
  findbadpaths(7);

  assign(f,adrv(systat^.semaphorepath)+'INUSE.'+cstrnfile(cnode));
  {$I-} reset(f); {$I+}
  if ioresult<>0 then begin
        rewrite(f);
        close(f);
  end else begin
                getftime(f,testl);
                close(f);
                cwrite('%120%<%100%ù%120%> Node in use or no node number specified... exiting.%070%'+#13#10);
                hangup2:=TRUE;
                halt;
  end;


  cwrite('%090%<%100%ù%090%> Clearing node user information...'+#13#10);
  assign(onlinef,adrv(systat^.gfilepath)+'USER'+cstrn(cnode)+'.DAT');
  filemode:=66;
  with online do begin
                Name:='Available Node';
                real:='Available Node';
                nickname:='';
                number:=0;
                status:=0;
                available:=false;
                business:='';
                activity:='Waiting For Caller';
                baud:=0;
                comport:=0;
                lockbaud:=0;
                emulation:=1;
  end;
  rewrite(onlinef);
  seek(onlinef,0);
  write(onlinef,online);
  close(onlinef);
  if (cnode>syst.highnode) then begin syst.highnode:=cnode;
        end;

  newtemp:=systat^.temppath+'NODE'+cstrn(cnode)+'\';
  newswap:=systat^.swappath+'NODE'+cstrn(cnode)+'\';
  if not (existdir(copy(newtemp,1,length(newtemp)-1))) then begin
                {$I-} system.mkdir(copy(newtemp,1,length(newtemp)-1)); {$I+}
                if (ioresult<>0) then begin
                        wmsgs('Creating: '+newtemp);
                        abend('Error creating temporary directory...');
                end;
                end;
  if not (existdir(copy(newswap,1,length(newswap)-1))) then begin
                {$I-} system.mkdir(copy(newswap,1,length(newswap)-1)); {$I+}
                if (ioresult<>0) then begin
                        wmsgs('Creating: '+newswap);
                        abend('Error creating swap directory...');
                end;
                end;
  
  findbadpaths(9);

  if not(existdir(newtemp+'WORK')) then begin
  {$I-} system.mkdir(newtemp+'WORK'); {$I+}
  if ioresult<>0 then begin
                        wmsgs('Creating: '+newtemp+'WORK\');
                        abend('Error creating work directory...');
  end;
  end;
  
  if not(existdir(newtemp+'CDROM')) then begin
  {$I-} system.mkdir(newtemp+'CDROM'); {$I+}
  if ioresult<>0 then begin
                        wmsgs('Creating: '+newtemp+'CDROM\');
                        abend('Error creating CD-ROM directory...');
  end;
  end;

  if not(existdir(newtemp+'NXWAVE1')) then begin
  {$I-} system.mkdir(newtemp+'NXWAVE1'); {$I+}
  if ioresult<>0 then begin
                        wmsgs('Creating: '+newtemp+'NXWAVE1\');
                        abend('Error creating nxWAVE work directory...');
  end;
  end;

  if not(existdir(newtemp+'NXWAVE2')) then begin
  {$I-} system.mkdir(newtemp+'NXWAVE2'); {$I+}
  if ioresult<>0 then begin
                        wmsgs('Creating: '+newtemp+'NXWAVE2\');
                        abend('Error creating nxWAVE work directory...');
  end;
  end;

  if not(existdir(start_dir+'\EXPORT')) then begin
  {$I-} system.mkdir(start_dir+'\EXPORT'); {$I+}
  if ioresult<>0 then begin
                        wmsgs('Creating: '+start_dir+'\EXPORT\');
                        abend('Error creating message export directory...');
  end;
  end;

  assign(sysopf,adrv(systat^.trappath)+'NEX'+cstrn(cnode)+'.LOG');
  filemode:=66;
  {$I-} reset(sysopf,1); {$I+}
  if (ioresult<>0) then begin
    rewrite(sysopf,1);
    blockwritestr(sysopf,''+#13#10);
  end;
  close(sysopf);
  first_time:=TRUE;



  sysophead;

  sl1(':','Begin; Nexus v'+ver);
  assign(modemrf,adrv(systat^.gfilepath)+'NODE'+cstrn(cnode)+'.DAT');
  filemode:=66; 
  {$I-} reset(modemrf); {$I+}
  if (ioresult<>0) then begin
                        cwrite('%120%<%100%ù%120%> Node '+cstr(cnode)+' has not been configured. '+
                        'Use nxSETUP to configure this node.'+#13#10);
                        sl1('!','Node '+cstr(cnode)+' not configured.');
                        {$I-} erase(f); {$I+}
                        if (ioresult<>0) then begin
                                cwrite('%120%<%100%ù%120%> Error removing active node status'+
                                ' - could cause system malfunctions.%070%'+#13#10);
                        end;
                        {$I-} erase(onlinef); {$I+}
                        if (ioresult<>0) then begin end;
                        halt;
  end else begin
  new(modemr);
  {$I-} read(modemrf,modemr^); {$I+}
  if (ioresult<>0) then begin
                        cwrite('%120%<%100%ù%120%> Error reading information for node '+cstr(cnode)+'...'+#13#10);
                        sl1('!','Node '+cstr(cnode)+' corrupted.');
                        {$I-} erase(f); {$I+}
                        if (ioresult<>0) then begin
                                cwrite('%120%<%100%ù%120%> Error removing active node status -'+
                                ' could cause system malfunctions.%070%'+#13#10);
                        end;
                        {$I-} erase(onlinef); {$I+}
                        if (ioresult<>0) then begin end;
                        halt;
  end else close(modemrf);
  end;
  sl1(':','Running under '+multsk);
  if (modemr^.ctype=0) and not(localioonly) then begin
                        localioonly:=TRUE;
                        spd:='';
                        sl1('c','Starting node in local only mode');
  end;        

  getlang(clanguage);
  langname:=allcaps(langr.filename);
  menufname:=allcaps(langr.menuname);
  if (menufname='') then menufname:='ENGLISH';
  if (langname='') then langname:='ENGLISH';
  sl1('_','Using Default Language File: '+langname);
  sl1('_','Using Default Menu File    : '+menufname);

  assign(fidorf,adrv(systat^.gfilepath)+'NETWORK.DAT');
  filemode:=66; 
  {$I-} reset(fidorf); {$I+}
  if (ioresult<>0) then begin
    filemode:=67; 
    rewrite(fidorf);
    with fidor do begin
      for x:=1 to 30 do with address[x] do begin
      zone:=0; net:=0; node:=0; point:=0; 
      end;
      for i:=1 to 20 do origins[i]:='';
      origins[1]:=copy(stripcolor(systat^.bbsname),1,50);
      text_color:=1; quote_color:=3; tear_color:=9; origin_color:=5;
      skludge:=TRUE; sseenby:=TRUE; sorigin:=FALSE;
      nodelistpath:='';
      for i:=1 to sizeof(res) do res[i]:=0;
    end;
    write(fidorf,fidor);
  end;
  close(fidorf);

  assign(securityf,adrv(systat^.gfilepath)+'SECURITY.DAT');
  {$I-} reset(securityf); {$I-}
  if (ioresult<>0) then begin
        abend('Error opening SECURITY.DAT...');
  end;

  npatch:=false;
  assign(sf,adrv(systat^.gfilepath)+'USERS.IDX');
  filemode:=66; 
  {$I-} reset(sf); {$I+}
  if (ioresult<>0) then begin
        npatch:=true;
  end else close(sf);


  npatch2:=FALSE;
  assign(uidf,adrv(systat^.gfilepath)+'USERID.IDX');
  filemode:=66;
  {$I-} reset(uidf); {$I+}
  if (ioresult<>0) then begin
        npatch2:=TRUE;
  end else close(uidf);

  if (npatch) and not(npatch2) then begin
  wmsgs('Error reading USERS.IDX...');
  end else
  if (npatch2) and not(npatch) then begin
  wmsgs('Error reading USERID.IDX...');
  end else
  if (npatch2) and (npatch) then begin
  wmsgs('Error reading USERS.IDX and USERID.IDX...');
  end;

  assign(uf,adrv(systat^.gfilepath)+'USERS.DAT');
  filemode:=66; 
  {$I-} reset(uf); {$I+}
  if (ioresult<>0) then begin
        abend('USERS.DAT has been corrupted or does not exist...');
  end;
  if (filesize(uf)>1) then begin
    seek(uf,1);
    read(uf,thisuser);
  end else begin
        abend('USERS.DAT has been corrupted or does not exist...');
  end;
  if (npatch) or (npatch2) then begin
        if (npatch) then begin
        rewrite(sf);
        sr.name:='';
        sr.real:='';
        sr.nickname:='';
        sr.number:=0;
        sr.UserID:=0;
        write(sf,sr);
        end;
        if (npatch2) then begin
        rewrite(uidf);
        uid.userid:=0;
        uid.number:=0;
        write(uidf,uid);
        end;
        seek(uf,1);
        while not(eof(uf)) do begin
         read(uf,thisuser);
         if not(thisuser.deleted) then begin
                if (npatch) then begin
                sr.name:=thisuser.name;
                sr.real:=thisuser.realname;
                sr.nickname:=thisuser.nickname;
                sr.number:=filepos(uf)-1;
                sr.UserID:=thisuser.UserID;
                write(sf,sr);
                end;
                if (npatch2) then begin
                uid.userid:=thisuser.UserID;
                uid.number:=filepos(uf)-1;
                write(uidf,uid);
                end;
           end else if (npatch2) then begin
                uid.userid:=thisuser.userid;
                uid.number:=-1;
                write(uidf,uid);
           end;
         end;
         if (npatch) then close(sf);
         if (npatch2) then close(uidf);
         removewindow(w);
         if (npatch) and not(npatch2) then begin
         wmsgs('USERS.IDX has been fixed');
         end else
         if (npatch2) and not(npatch) then begin
         wmsgs('USERID.IDX has been fixed');
         end else
         if (npatch2) and (npatch) then begin
         wmsgs('USERS.IDX and USERID.IDX have been fixed');
         end;
         seek(uf,1);
         read(uf,thisuser);
         npatch:=false;
         npatch2:=FALSE;
  end;

  {$I-} reset(sf); {$I+}
  if ioresult=0 then begin
  if (syst.numusers<>(filesize(sf)-1)) then begin
    wmsgs('User count does not match with USERS.IDX...');
    syst.numusers:=(filesize(sf)-1);
  {$I-} reset(systemf); {$I+}
  if (ioresult<>0) then begin
        abend('Error opening SYSTEM.DAT...');
  end;
  write(systemf,syst);
  close(systemf);
    wmsgs('User count fixed');
  end;
  close(sf);
  end;
  close(uf);

  assign(xf,adrv(systat^.gfilepath)+'PROTOCOL.DAT');
  
  assign(fp,adrv(systat^.gfilepath)+'MBASES.DAT');
  assign(bf,adrv(systat^.gfilepath)+'MBASES.DAT');
  filemode:=66; 
  {$I-} reset(bf); {$I+} 
  if ioresult<>0 then begin
                abend('Error reading in Message Base information...');
  end;
  if (filesize(bf)=0) then begin
                abend('Error reading in Message Base information...');
  end;
  numboards:=filesize(bf)-1;
  close(bf);
  
  filemode:=66;
  new(con);
  assign(conf,systat^.gfilepath+'CONFS.DAT');
  {$I-} reset(conf); {$I+}
  if (ioresult<>0) then begin
        rewrite(conf);
        fillchar(con^,sizeof(con^),#0);
        con^.msgconf[1].name:='Main Conference';
        con^.msgconf[1].active:=TRUE;
        con^.msgconf[1].hidden:=false;
        con^.msgconf[1].access:='';
        con^.fileconf[1].name:='Main Conference';
        con^.fileconf[1].active:=TRUE;
        con^.fileconf[1].hidden:=false;
        con^.fileconf[1].access:='';
        write(conf,con^);
        seek(conf,0);
  end;
  read(conf,con^);
  close(conf);

  assign(ulf,adrv(systat^.gfilepath)+'FBASES.DAT');
  filemode:=66; 
  {$I-} reset(ulf); {$I+}
  if ioresult<>0 then begin
                abend('Error reading in File Base information...');
  end;
  if (filesize(ulf)=0) then begin
                abend('Error reading in File Base information...');
  end;
  maxulb:=filesize(ulf)-1;
  close(ulf);

  cfo:=FALSE;

  textbackground(0); textcolor(7);
end;

procedure init;
var x1,x,y,rcode:integer;
    s,vertype:string;
begin
  ver:=version+'.'+copy(build,2,length(build)-1)+'/DOS';
  textcolor(7);
  textbackground(0);
  cwrite(verline(1)+#13#10);
  cwrite(verline(2)+#13#10);
  cwrite(verline(3)+#13#10);
  writeln;
  if (daynum(datelong)=0) then begin
    cwrite('%120%<%100%ù%120%> Error reading system date and time... exiting.%070%'+#13#10);
    halt(exiterrors);
  end;

  defaultst:=''; spd:='KB'; 
  hangup2:=FALSE; incom:=FALSE; outcom:=FALSE;
  echo:=TRUE; doneday:=FALSE;
  checkbreak:=FALSE;
  slogging:=TRUE; trapping:=FALSE;
  inmsgfileopen:=FALSE;
  beepend:=FALSE;
  wascriterr:=FALSE;
  fsearchtext:='';
  checksnow:=systat^.cgasnow;
  directvideo:=not systat^.usebios;
  new(curact);
  with curact^ do begin
      active:=0; calls:=0; newusers:=0; pubpost:=0;
      fback:=0; criterr:=0; uploads:=0; downloads:=0; uk:=0; dk:=0;
  end;

  cwrite('%090%<%100%ù%090%> Reading system configuration settings...'+#13#10);
  new(systat);
  assign(systatf,start_dir+'\MATRIX.DAT');
  filemode:=66;
  {$I-} reset(systatf); {$I+}
  if (ioresult<>0) then
  begin
    cwrite('%120%<%100%ù%120%> Unable to find '+allcaps(start_dir)+'\MATRIX.DAT'+#13#10);
    writeln;
    cwrite('%070%The MATRIX.DAT is a required file. If you cannot find your MATRIX.DAT file,'+#13#10);
    writeln('re-create one using nxSETUP.');
    if (exiterrors<>-1) then halt(exiterrors) else halt(254);
  end;
  {$I-} read(systatf,systat^); {$I+}
  if (ioresult<>0) then begin
        cwrite('%120%<%100%ù%120%> Error reading in MATRIX.DAT ... exiting.%070%'+#13#10);
        halt;
  end;
  close(systatf);

  if (value(copy(version,1,pos('.',version)-1))<>systat^.majorversion) or 
      (systat^.minorversion<95)  then
        begin
                cwrite('%120%<%100%ù%120%> Configuration version mismatch error...%070%'+#13#10);
                writeln;
                writeln('Your MATRIX.DAT is for version ',systat^.majorversion,'.',
                        systat^.minorversion,' and cannot be used.  Please use your');
                writeln('upgrade package to upgrade your MATRIX.DAT to a compatible version.');
                writeln;
                halt(exiterrors);
        end;

  systat^.majorversion:=value(copy(version,1,pos('.',version)-1));
  systat^.minorversion:=value(copy(version,pos('.',version)+1,2));
  systat^.cbuild:=value(copy(build,2,2));
  if (copy(build,4,1)<>'') and (length(build)>3) then 
  systat^.cbuildmod:=copy(build,4,4)
  else
  systat^.cbuildmod:='';
  assign(systemf,adrv(systat^.gfilepath)+'SYSTEM.DAT');
  filemode:=66;
  {$I-} reset(systemf); {$I+}
  if (ioresult<>0) then begin
        cwrite('%120%<%100%ù%120%> Error opening SYSTEM.DAT... exiting.%070%'+#13#10);
        halt(exiterrors);
  end;

  read(systemf,syst);
  close(systemf);

  readp;
  if cnode>1000 then cnode:=0;
  if cnode<1 then cnode:=0;
  if (cnode=0) then begin
                cwrite('%120%<%100%ù%120%> Invalid node number/no node number specified.%070%'+#13#10);
                halt;
  end;
  new(stridx);
  initp1;

  if not(syst.ordone) then begin
        common.getdatetime(syst.ordate);
        syst.ordone:=TRUE;
  end;
  {$I-} reset(systemf); {$I+}
  if (ioresult<>0) then begin
        sl1('!','Error Updating SYSTEM.DAT');
  end else begin
        write(systemf,syst);
        close(systemf);
  end;

  cwrite('%090%<%100%ù%090%> Initializing available CD-ROMs (if any)...'+#13#10);
  INITCDROMS;
end;

end.
