{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R-,S+,V-}
unit file1;

interface

uses
  crt, dos,
  common;

procedure dodl(fpneed:integer);
procedure doul(pts:integer);
procedure dlx(f1:fheaderrec; rn:integer; var abort:boolean);
procedure dl(fn:astr);
procedure dodescrs(var f:fheaderrec;              {* file record      *}
                   var pl:integer;            {* # files in dir   *}
                   var tosysop:boolean);      {* whether to-SysOp *}
procedure newff(f:fheaderrec); {* ulff needs to be open before calling *}
procedure doffstuff(var f:fheaderrec; fn:astr; var gotpts:integer);
procedure idl;
procedure idl2;
procedure writefv(rn:integer; f:fheaderrec);
procedure unlisted_download(s:astr);
procedure do_unlisted_download;
procedure listed_download(basenum:integer; s:astr);
function searchfordups(completefn:astr):boolean;
procedure arcstuff(var ok,convt:boolean;    { if ok - if converted }
                   var blks:longint;        { # blocks     }
                   var convtime:real;       { convert time }
                   itest:boolean;           { whether to test integrity }
                   fpath:astr;              { filepath     }
                   var fn:astr;             { filename     }
                   var descr:astr);         { description  }

implementation

uses
  file0, file6, file8, file14, file11, archive1,doors,execbat;

var
  locbatup:boolean;

procedure dodl(fpneed:integer);
begin
  if (systat^.fileptratio) then begin
  nl;
  nl;
  if (not aacs(systat^.nofilepts)) or
     (not (fnofilepts in thisuser.ac)) then begin
    if (fpneed>0) then dec(thisuser.filepoints,fpneed);
    if (thisuser.filepoints<0) then thisuser.filepoints:=0;
    if (fpneed<>0) then
      sprint('%140%New file points: '+cstr(thisuser.filepoints));
  end;
  end;
end;

procedure writefv(rn:integer; f:fheaderrec);
var vfo:boolean;
begin
  NXF.seekfile(rn);
  NXF.Rewriteheader(f);
end;

procedure doul(pts:integer);
begin
  if (not aacs(systat^.ulvalreq)) then begin
    sprint('%140%Upload received.');
    if (systat^.uldlratio) then
      sprint('%140%Credit will be awarded as soon as the file is validated.')
    else
      sprint('%140%File points will be awarded as soon as the file is validated.');
  end else
    if ((not systat^.uldlratio) and (not systat^.fileptratio) and (pts=0)) then begin
      sprint('%140%Thank you for the upload, '+caps(nam)+'.');
      sprint('%140%You will receive file points as soon as '+systat^.sysopname+' validates the file!');
    end else
      inc(thisuser.filepoints,pts);
end;


procedure dlx(f1:fheaderrec; rn:integer; var abort:boolean);
var u:userrec;
    tooktime,xferstart,xferend:datetimerec;
    i,ii,tt,bar,s:astr;
    rl,tooktime1:real;
    cps,lng:longint;
    inte,pl,z:integer;
    c:char;
    next,ps,ok,tl:boolean;
begin
  abort:=FALSE; next:=FALSE;
  ps:=TRUE;
  abort:=FALSE;
  begin
    ps:=FALSE;

    getdatetime(xferstart);
    send1(adrv(memuboard.dlpath)+f1.filename,ok,abort);
    getdatetime(xferend);
    timediff(tooktime,xferstart,xferend);

    if (not (-lastprot in [10,11,12])) then
      if (not abort) then
        if (not ok) then begin
          sprint('%120%Download failed.');
          sl1('!','Tried Download ['+sqoutsp(f1.filename)+
                   '] From '+memuboard.name);
          ps:=TRUE;
        end else begin
          if (not (fbnoratio in memuboard.fbstat)) then begin
            inc(thisuser.downloads);
            thisuser.dk:=thisuser.dk+(f1.filesize div 1024);
          end;
          inc(curact^.downloads);
          inc(curact^.dk,(f1.filesize div 1024));

          if (not incom) then nl;

          lng:=f1.filesize;
          sprint('Sent : 1 File'); 
          sprint('Time : '+longtim(tooktime));
          s:='Total: '+cstrl(lng)+' bytes';
          if (fbnoratio in memuboard.fbstat) then s:=s+'%140% [Free]';
          sprint(s);

          s:='Download ['+sqoutsp(f1.filename)+'] from '+memuboard.name;

          tooktime1:=dt2r(tooktime);
          if (tooktime1>=1.0) then begin
            cps:=f1.filesize;
            cps:=trunc(cps/tooktime1);
          end else
            cps:=0;

          s:=s+' ['+cstr(f1.filesize div 1024)+'k, '+ctim(dt2r(tooktime))+
               ', '+cstr(cps)+' cps]';
          sl1('+',s);
          if (not (fbnoratio in memuboard.fbstat)) and
             (f1.filepoints>0) then dodl(f1.filepoints);

          if (rn<>-1) then begin
            inc(f1.numdownloads);
            NXF.RewriteHeader(f1);
          end;
        end;
  end;
  if (ps) then begin
    NXF.Rewriteheader(f1);
  end;
end;

procedure dl(fn:astr);
var oldfboard,i2,x,x2,pl,rn,l,tm,tm2:integer;
    c:char;
    oldc:byte;
    batchf:file of flaggedrec;
    batch:flaggedrec;
    showingtitle,
    global,flagging,wildcard,done,already,next,skip,abort:boolean;
begin
  abort:=FALSE;
  oldfboard:=fileboard;
  wildcard:=FALSE;
  if (fflag) and not(dlflag) then flagging:=TRUE else flagging:=FALSE;
  if (pos('*',fn)<>0) or (pos('?',fn)<>0) then begin
        if not(fflag) then dlflag:=TRUE;
        wildcard:=TRUE;
        fflag:=TRUE;
  end;
  done:=FALSE;
  global:=FALSE;
  recno(align(fn),pl,rn);
  tm:=0;
  if (baddlpath) and not(fballowofflinerequest in memuboard.fbstat) then exit;
  if (rn<>0) then done:=TRUE;
  skip:=false;
  if (rn=0) then begin
        sprompt(gstring(478));
        if pynq(gstring(479)) then begin
                        global:=TRUE;
                        nl;
                        oldc:=fconf;
                        fconf:=0;
                        if (fbaseac(tm)) then begin
                        changefileboard(tm);
                        if (tm=fileboard) then begin
                        sprompt(gstring(477));
                        recno(align(fn),pl,rn);
                        end;
                        end;
        end else done:=TRUE;
  end;
  repeat
  showingtitle:=FALSE;
  if (rn<>0) then begin
        if (global) then nl;
    while (rn<>0) and (not abort) and (not hangup) do begin
      NXF.Seekfile(rn);
      NXF.ReadHeader;
      already:=false;
      assign(batchf,adrv(systat^.temppath)+'FLAG'+cstrn(cnode)+'.DAT');
      {$I-} reset(batchf); {$I+}
      if (ioresult=0) then begin
      i2:=1;
      while (i2<=numbatchfiles) and not(eof(batchf)) do begin
      read(batchf,batch);
      if (allcaps(adrv(memuboard.dlpath)+sqoutsp(NXF.Fheader.filename))=allcaps(batch.filename))
         then begin
                already:=TRUE;
              end;
      inc(i2);
      end;
      close(batchf);
      end;
      if not(already) then begin
      if (fflag) and (not(dlflag) or (wildcard) or (global)) then begin
          nl;
          if not(showingtitle) then begin
                if ((systat^.uldlratio) and (not systat^.fileptratio)) then begin
                sprompt(gstring(390));
                sprompt(gstring(391));
                sprompt(gstring(392));
                sprompt(gstring(393));
                end else begin
                sprompt(gstring(394));
                sprompt(gstring(395));
                sprompt(gstring(396));
                sprompt(gstring(397));
                end;
                showingtitle:=TRUE;
                end;
                topp:=rn;
                NXF.DescStartup;
                Curdesc:=1;
                sprompt(gstring(377));
                sprompt(gstring(378));
                sprompt(gstring(379));
                nl;
                sprompt(gstring(476)+gstring(100));
                lil:=0;

         onekda:=false;
         onekcr:=false;
         onek(c,gstring(98)+^M);
         onekda:=true;
         onekcr:=True;
         case upcase(c) of
                'Y':nl;
                'N':begin
                        skip:=TRUE;
                        sprint(gstring(101)+gstring(102));
                end;
                'Q':begin
                        skip:=TRUE;
                        abort:=TRUE;
                        done:=TRUE;
                        if (flagging) then dlflag:=FALSE;
                        sprint(gstring(101)+gstring(97));
                end;
         end;
      end;
      if not(skip) then begin
        dlx(NXF.Fheader,rn,abort);
        nl;
      end;
      skip:=FALSE;
      end;
      nrecno(align(fn),pl,rn);
    end;
    if (global) then nl;
  end;
  if (global) then begin
  inc(tm);
  if (tm<=maxulb) then
  if (fbaseac(tm)) then begin
        changefileboard(tm);
        if (tm=fileboard) then begin
                lil:=0;
                sprompt(gstring(477));
                recno(align(fn),pl,rn);
        end;
  end;
  end;
  wkey(done,next);
  until (done) or (tm>maxulb);
  if (global) then begin
        nl;
        fconf:=oldc;
  end;
  loaduboard(oldfboard);
  fileboard:=oldfboard;
end;

procedure idl;
var s:astr; down,prp:boolean;
    oldboard,x:integer;
    batchf:file of flaggedrec;
    batch:flaggedrec;

function gtname(s:string):string;
begin
        while (pos('\',s)<>0) do begin
                s:=copy(s,pos('\',s)+1,length(s)-pos('\',s));
        end;
gtname:=s;
end;

begin
  down:=TRUE;prp:=true;
  oldboard:=fileboard;
  if (not intime(timer,modemr^.dllowtime[getdow+1],modemr^.dlhitime[getdow+1])) then
  begin
        printf('DLHOURS');
        down:=FALSE;
  end;
  if (answerbaud<modemr^.minimumbaud) then
    if (not intime(timer,modemr^.lockbegin_dltime[getdow+1],modemr^.lockend_dltime[getdow+1])) then begin
      printf('LOCKHRS');
      down:=FALSE;
      end;
  if (down) then begin
    nl;
    if not(fflag) then begin
        dlflag:=true;
        fflag:=true;
    end;
    printf('DOWNLOAD');
    if (nofile) then sprompt(gstring(59));
    if not(infilelist) then begin
    assign(batchf,adrv(systat^.temppath)+'FLAG'+cstrn(cnode)+'.DAT');
    {$I-} reset(batchf); {$I+}
    if (ioresult=0) then begin
    if (numbatchfiles<>0) then begin
    x:=1;
    while (x<=numbatchfiles) and not(eof(batchf)) do begin
        read(batchf,batch);
        sprint('%030%Filename #'+cstr(x)+' : %150%'+gtname(batch.filename));
        inc(x);
        end;
    end;
    close(batchf);
    end;
    end;
    repeat
    sprompt('%030%Filename #'+cstr(numbatchfiles+1)+' : %150%'); mpl(12); input(s,12);
    dyny:=true;
    if (s<>'') then dl(s);
    if not(fflag) and not(dlflag) then s:='';
    until (s='');
    {if ((numbatchfiles=1) and (dlflag)) then begin
        $I- reset(batchf); $I+
        if (ioresult=0) then begin
                read(batchf,batch);
                close(batchf);
                numbatchfiles:=0;
                s:=gtname(batch.filename);
                fileboard:=batch.filebase;
                $I- erase(batchf); $I+
                loaduboard(fileboard);
                fflag:=false;
                dl(s);
        end;
    end;}
    if (numbatchfiles<>0) then if (dlflag) then batchdl;
    dlflag:=false;
    fileboard:=oldboard;
    end;
end;

procedure idl2;
var s,s2,s3,s4:astr; down,prp:boolean;
    oldboard,x,x2:integer;
    batchf:file of flaggedrec;
    batch:flaggedrec;

function gtname(s:string):string;
begin
        while (pos('\',s)<>0) do begin
                s:=copy(s,pos('\',s)+1,length(s)-pos('\',s));
        end;
gtname:=s;
end;

begin
  down:=TRUE;prp:=true;
  oldboard:=fileboard;
  if (not intime(timer,modemr^.dllowtime[getdow+1],modemr^.dlhitime[getdow+1])) then 
  begin
        printf('DLHOURS');
        down:=FALSE;
  end;
  if (answerbaud<modemr^.minimumbaud) then
    if (not intime(timer,modemr^.lockbegin_dltime[getdow+1],modemr^.lockend_dltime[getdow+1])) then begin
      printf('LOCKHRS');
      down:=FALSE;
      end;
  if (down) then begin
    if not(fflag) then begin
        dlflag:=true;
        fflag:=true;
    end;
    s2:='';
{    repeat}
    x:=numbatchfiles+1;
    s3:='%030%[%150%File #'+cstr(x)+'%030%] Filename or Number : %150%';
    sprompt(s3);
    mpl(12); inputmain(s,12,'UL');
    dyny:=true;
    if (pos('.',s)=0) and (s<>'') then begin    
         if ((value(s)<>0) and (value(s)<=NXF.Numfiles)) then begin
                for x2:=1 to length(s) do begin
                        prompt(^H' '^H);
                end;
                NXF.Seekfile(value(s)); NXF.readheader;
                s:=NXF.Fheader.filename;
                sprompt('%150%'+sqoutsp(s));
         end else begin
                sprompt('%120%File not found.');
         end;
    end;
    nl;
    if (s<>'') then begin
        dl(align(s));
    end;
    if not(fflag) and not(dlflag) then s:='';
{    until (s='');}
    if (numbatchfiles<>0) and (s<>'') and (dlflag) then batchdl;
    dlflag:=false;
    fileboard:=oldboard;
    end;
end;


procedure dodescrs(var f:fheaderrec;              {* file record      *}
                   var pl:integer;            {* # files in dir   *}
                   var tosysop:boolean);      {* whether to-SysOp *}
var i,maxlen:integer;
    isgif:boolean;
    s:string;
    t:text;
begin
  if ((tosysop) and (systat^.tosysopdir<>-1) and
      (systat^.tosysopdir>=0) and (systat^.tosysopdir<=maxulb)) then begin
  end else tosysop:=FALSE;
  nl;

  loaduboard(fileboard);
  isgif:=isgifext(f.filename);
  maxlen:=45;
  if ((fbusegifspecs in memuboard.fbstat) and (isgif)) then dec(maxlen,14);

  sprint('%030%Please enter the description of %150%'+allcaps(f.filename));
  sprint('%030%You have %150%'+cstr(syst.ndesclines)+' %030%lines of %150%'+cstr(maxlen)+' %030%characters each.');
  sprompt(gstring(19));
  mpl(maxlen); inputl(s,maxlen);

  assign(t,newtemp+'DESCRIPT.TMP');
  {$I-} rewrite(t); {$I+}
  if (ioresult<>0) then begin
        exit;
  end;
  i:=1;
  while (s<>'') and not(hangup) and (i<=syst.ndesclines) do begin
      inc(i);
      writeln(t,s);
      sprompt(gstring(19)); mpl(45);
      inputl(s,45);
  end;
  close(t);
end;

procedure newff(f:fheaderrec); {* ulff needs to be open before calling *}
begin
  NXF.Addnewfile(f);
end;

procedure doffstuff(var f:fheaderrec; fn:astr; var gotpts:integer);
var rfpts:real;
begin
  f.FheaderID[1]:=#1;
  f.FheaderID[2]:='N';
  f.FheaderID[3]:='E';
  f.FheaderID[4]:='X';
  f.FheaderID[5]:='U';
  f.FheaderID[6]:='S';
  f.FheaderID[7]:=#1;
  f.filename:=fn;
  f.uploadedby:=caps(nam);
  f.uploadeddate:=u_daynum(datelong+'  '+time);
  f.numdownloads:=0;
  f.lastdldate:=f.uploadeddate;
  f.magicname:='';
  f.access:='';

  rfpts:=(f.filesize div 1024)/systat^.fileptcompbasesize;
  f.filepoints:=round(rfpts);
  if (f.filepoints<1) then f.filepoints:=1;
  gotpts:=round(rfpts*(systat^.fileptcomp div 100));
  if (gotpts<1) then gotpts:=1;

  f.fileflags:=[];
  if (not fso) and (not systat^.validateallfiles) then
    f.fileflags:=f.fileflags+[ffnotval];
end;

function searchfordups(completefn:astr):boolean;
var wildfn,nearfn,s:astr;
    oldboard,i:integer;
    fcompleteacc,fcompletenoacc,fnearacc,fnearnoacc,
    harddrive,hadacc,b1,b2:boolean;

  procedure searchb(b:integer; fn:astr; var hadacc,fcl,fnr:boolean);
  const spin:array[1..4] of char=('/','-','\','|');
  var cs,pl,rn:integer;

  begin
    fnr:=false;
    fcl:=false;
    hadacc:=fbaseac(b); { loads in memuboard }
    if ((harddrive) and (memuboard.cdrom)) then exit;
    fileboard:=b;

    cs:=0;
    recno(align(fn),pl,rn);
    if (badfpath) then exit;
    while (rn<=pl) and (rn<>0) do begin
      inc(cs);
      if (cs=5) then cs:=1;
      sprompt('%150%'+spin[cs]);
      NXF.SeekFile(rn);
      NXF.ReadHeader;
      if (NXF.Fheader.filename=completefn) then fcl:=TRUE
      else begin
        if (pos(copy(completefn,1,pos('.',completefn)-1),
                copy(NXF.Fheader.filename,1,pos('.',NXF.Fheader.filename)-1))<>0) then
                begin
                        nearfn:=NXF.Fheader.filename;
                        fnr:=TRUE;
                end;
      end;
      nrecno(align(fn),pl,rn);
      sprompt(^H' '^H);
    end;
    fiscan(pl);
  end;

begin
  harddrive:=FALSE;
  case systat^.searchdup of
        0:begin
                searchfordups:=FALSE;
                exit;
        end;
        2:harddrive:=TRUE;
  end;

  oldboard:=fileboard;
  nl;
  if (harddrive) then sprompt('%030%Scanning %140%hard drive bases %030%for duplicates of %150%'+completefn+'%030%... ')
  else sprompt('%030%Scanning %140%all bases %030%for duplicates of %150%'+completefn+'%150%... ');

  searchfordups:=TRUE;

  if (systat^.searchdupstrict) then
  wildfn:=copy(completefn,1,pos('.',completefn))+'???'
  else wildfn:='????????.???';
  fcompleteacc:=FALSE; fcompletenoacc:=FALSE;
  fnearacc:=FALSE; fnearnoacc:=FALSE;
  b1:=FALSE; b2:=FALSE;

  i:=0;
  while (i<=maxulb) do begin
    searchb(i,wildfn,hadacc,b1,b2); { fbaseac loads in memuboard ... }
    loaduboard(i);
    if (b1) then begin
      s:='User tried upload ['+sqoutsp(completefn)+'] to #'+cstr(fileboard)+
         ': existed in #'+cstr(i);
      if (not hadacc) then s:=s+' - no access to';
      sl1('!',s);
      nl; nl;
      if (hadacc) then
        sprint('%150%'+sqoutsp(completefn)+'%120% already exists in %030%'+
               memuboard.name+'%030% #'+cstr(i)+'%120%.')
      else
        sprint('%150%'+sqoutsp(completefn)+
               '%120% cannot be accepted by this system at this time.');
      exit;
    end;
    if (b2) then begin
      s:=sqoutsp(completefn)+': user warned that '+sqoutsp(nearfn)+
         ' exists in #'+cstr(i);
      if (not hadacc) then s:=s+' - no access';
      sl1('!',s);
      nl; nl;
      if (hadacc) then
        sprint('%120%Warning: %150%'+sqoutsp(nearfn)+'%120% exists in %140%'+
               memuboard.name+'%140% #'+cstr(i)+'.')
      else
        sprint('%120%Warning: %150%'+sqoutsp(nearfn)+
               '%120% exists on this system.');
      dyny:=false;
      searchfordups:=pynq('%120%Is this the same file? %110%');
      exit;
    end;
    inc(i);
  end;

  sprint('%150%None found.');
  fileboard:=oldboard;
  loaduboard(fileboard);
  searchfordups:=FALSE;
end;

(*
procedure ul(var abort:boolean; fn:astr; var addbatch:boolean);
var t,baf:text;
    fi:file of byte;
    s:astr;
    s2:string;
    f:fheaderrec;
    xferstart,xferend,tooktime,ulrefundgot1,convtime1:datetimerec;
    ulrefundgot,convtime,rfpts,tooktime1:real;
    cps,lng,origblocks:longint;
    retcode,atype,x,rn,pl,cc,oldboard,np,sx,sy,gotpts:integer;
    c:char;
    uls,ok,kabort,convt,aexists,resumefile,wenttosysop,offline:boolean;
begin
  oldboard:=fileboard;
  fiscan(pl);
  if (baddlpath) then begin
        nl;
        sprint('%120%Unable to upload to this base.');
        nl;
        exit;
  end;

  uls:=incom; ok:=TRUE; rn:=0;
  if (fn[1]=' ') then ok:=FALSE;
  s2:='0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ. -@#$%^&()_';
  if (fso) then s2:=s2+'?*';
  for x:=1 to length(fn) do
    ok:=(pos(fn[x],s2)<>0);
  np:=0;
  for x:=1 to length(fn) do if (fn[x]='.') then inc(np);
  if (np<>1) then ok:=FALSE;
  if (not ok) then begin
    nl;
    print('Illegal filename.');
    nl;
    exit;
  end;

  {* aexists:    if file already EXISTS in dir
     rn:         rec-num of file if already EXISTS in file listing
     resumefile: if user is going to RESUME THE UPLOAD
     uls:        whether file is to be actually UPLOADED
     offline:    if uploaded a file to be offline automatically..
  *}

  resumefile:=FALSE; uls:=TRUE; offline:=FALSE; abort:=FALSE;
  aexists:=exist(adrv(memuboard.dlpath)+fn);

  recno(align(fn),pl,rn);
  if (baddlpath) then begin
        sl1('!','Invalid upload path: '+memuboard.dlpath);
        exit;
        end;
  nl;
  if (rn<>0) then begin
    NXF.Seekfile(rn);
    NXF.Readheader;
    resumefile:=(ffresumelater in NXF.Fheader.fileflags);
    if (resumefile) then begin
      print('This Is A RESUME-LATER File.');
      resumefile:=((allcaps(NXF.Fheader.Uploadedby)=allcaps(thisuser.name)) or
        (allcaps(NXF.Fheader.Uploadedby)=allcaps(thisuser.realname)) or (fso));
      if (resumefile) then begin
        if (not incom) then begin
          print('Cannot be resumed locally.');
          exit;
        end;
        dyny:=TRUE;
        resumefile:=pynq('%120%Resume upload of '+sqoutsp(fn)+'? %110%');
        if (not resumefile) then exit;
      end else begin
        print('%120%You did not upload this file.');
        exit;
      end;
    end;
  end;
  if not((fso) and (addbatch) and (iswildcard(fn))) then begin
  if ((not aexists) and (not incom)) then begin
    uls:=FALSE;
    offline:=TRUE;
    print('This file does not exist in the files directory.');
    dyny:=true;
    if not pynq('%120%Do you want to create an offline file entry? %110%') then exit;
  end;
  if (not resumefile) then begin
    if (((aexists) or (rn<>0)) and (not fso)) then begin
      print('File already exists.');
      exit;
    end;
    if (pl>=memuboard.maxfiles) then begin
      sprint('%120%This file base cannot accept any more files.');
      exit;
    end;
    if (not aexists) and (not offline) and
       (freek(exdrv(adrv(memuboard.dlpath)))<=systat^.minspaceforupload)
    then begin
      nl; sprint('%120%Insufficient disk space.');
      c:=chr(exdrv(adrv(memuboard.dlpath))+64);
      if c='@' then
        sl1('!','Main Nexus drive full!  Insufficient space to upload a file!')
      else sl1('!',c+': Drive full!  Insufficient space to upload a file!');
      exit;
    end;
    if (aexists) then begin
      uls:=FALSE;
      print('Using '+sqoutsp(adrv(memuboard.dlpath)+fn));
      if (rn<>0) then sprint('%140%File Already Exists In Listing.');
      dyny:=(rn=0);
      if (locbatup) then begin
        sprompt('%120%Upload this file? [%150%Q%120%=Quit] : ');
        if (dyny) then sprompt('%110%Yes') else sprompt('%110%No');
        onekcr:=false;
        onekda:=false;
        onek(c,'YNQ'^M);
        onekda:=true;
        onekcr:=true;
        case c of
                'Y':begin
                        ok:=true;
                        if not(dyny) then begin
                                prompt(^H' '^H^H' '^H);
                                sprompt('%110%Yes');
                        end;
                end;
                        
                'N':begin
                        ok:=false;
                        if (dyny) then begin
                                prompt(^H' '^H^H' '^H^H' '^H);
                                sprompt('%110%No');
                        end;
                end;

                'Q':begin
                        ok:=false;
                        abort:=true;
                        if (dyny) then 
                                prompt(^H' '^H^H' '^H^H' '^H)
                        else
                                prompt(^H' '^H^H' '^H);
                        sprompt('%110%Quit');

                    end;
                else begin
                        if (dyny) then ok:=true else ok:=false;
                end;
        end;
      end else
        ok:=pynq('%120%Upload this file? %110%');
      rn:=0;
    end;
    end;

    if ((ok) and (not abort) and (incom)) then
      if (searchfordups(fn)) then exit;

    if (uls) then begin
      dyny:=TRUE;
      ok:=pynq('%120%Upload '+sqoutsp(fn)+'? %110%');
    end;
    if ((ok) and (uls) and (not resumefile)) then begin
      assign(fi,adrv(memuboard.dlpath)+fn);
      {$I-} rewrite(fi); {$I+}
      if ioresult<>0 then begin
        {$I-} close(fi); {$I+}
        cc:=ioresult;
        ok:=FALSE;
      end else begin
        close(fi);
        erase(fi);
      end;
      if (not ok) then begin
        print('Unable to upload that file.');
        addbatch:=false;
        exit;
      end;
    end;
  end;

  if (not ok) then exit;
  wenttosysop:=TRUE;
  if (not resumefile) then begin
    f.filename:=fn;
  end;
  ok:=TRUE;
  if (uls) then begin

    getdatetime(xferstart);
    
    if not(addbatch) then begin
        receive1(adrv(memuboard.dlpath)+fn,resumefile,ok,kabort,addbatch);
        addbatch:=false;
    end;

      getdatetime(xferend);
      timediff(tooktime,xferstart,xferend);
    
    ulrefundgot:=(dt2r(tooktime))*(systat^.ulrefund/100.0);
    freetime:=freetime+ulrefundgot;
    sprint('%090%Gave time refund of %110%'+ctim(ulrefundgot));


    if (not kabort) then sprint('%110%Transfer complete.');
    nl;
    
            {running External Program }
            if (systat^.extuploadpath<>'') then begin
                currentfile:=newtemp+fn;
                s2:=process_door(systat^.extuploadpath);
                currentswap:=modemr^.swapdoor;
                shel1; 
                shelldos(FALSE,s2,retcode); 
                shel2;
                currentswap:=0;
                currentfile:='';
            end;
            {end running}

  end;
  nl;
  
  if (kabort) then begin
      fileboard:=oldboard;
      exit;
  end;

  convt:=FALSE;
  if (not offline) then begin
    assign(fi,adrv(memuboard.dlpath)+fn);
    {$I-} reset(fi); {$I+}
    if (ioresult<>0) then ok:=FALSE
    else begin
      f.filesize:=filesize(fi);
      close(fi);
      if (f.filesize=0) then ok:=FALSE;
      origblocks:=f.filesize;
    end;
  end;

  if ((ok) and (not offline)) then begin

    arcstuff(ok,convt,f.filesize,convtime,uls,adrv(memuboard.dlpath),fn,s);
    doffstuff(f,fn,gotpts);

    if (ok) then begin
      if ((not resumefile) or (rn=0)) then newff(f) else writefv(rn,f);
            ok:=false;
            fn:=f.filename;
            if (afound(adrv(memuboard.dlpath)+fn)) then begin
                nl;
                sprompt(gstring(70));
                arcdecomp(ok,atype,adrv(memuboard.dlpath)+fn,'FILE_ID.DIZ');
            end;
            if (ok) then begin
                ok:=true;
                if (exist(newtemp+'WORK\FILE_ID.DIZ')) then 
                begin
                        ok:=false;
                        assign(t,newtemp+'WORK\FILE_ID.DIZ');
                        {$I-} reset(t); {$I+}
                        if (ioresult<>0) then ok:=true else 
                        begin
                                x:=1;
                                while not(eof(t)) and (x<=syst.ndesclines) do 
                                begin
                                        readln(t,s);
                                        NXF.AddDescLine(copy(s,1,45));
                                        inc(x);
                                end;
                        end;
                if exist(newtemp+'WORK\FILE_ID.DIZ') then {$I-} erase(t); {$I+}
                if not(ok) then sprint('%150% Found and noted.');
                end;
            end else ok:=true;
            if (ok) then begin
                if (atype>0) then sprint(' %150%None found.');
                dodescrs(f,pl,wenttosysop);
                assign(t,newtemp+'DESCRIPT.TMP');
                {$I-} reset(t); {$I+}
                if (ioresult<>0) then begin
                        NXF.AddDescLine('<No Description Provided.>');
                end else begin
                                x:=1;
                                while not(eof(t)) and (x<=syst.ndesclines) do 
                                begin
                                        readln(t,s);
                                        NXF.AddDescLine(copy(s,1,45));
                                        inc(x);
                                end;
                                close(t);
                                {$I-} erase(t); {$I+}
                                if (ioresult<>0) then begin end;
                end;
            end;

      if (uls) then begin
        if (aacs(systat^.ulvalreq)) then begin
          inc(thisuser.uploads);
          inc(thisuser.uk,(f.filesize div 1024) div 8);
        end;
        inc(curact^.uploads);
        inc(curact^.uk,(f.filesize div 1024) div 8);
      end;

      s:='Upload '+sqoutsp(fn)+' to: '+memuboard.name;
      if (uls) then begin
        tooktime1:=dt2r(tooktime);
        if (tooktime1>=1.0) then begin
          cps:=f.filesize;
          cps:=trunc(cps/tooktime1);
        end else
          cps:=0;
        s:='Upload '+sqoutsp(fn)+' ['+cstr(f.filesize div 1024)+'k, '+
                ctim(tooktime1)+', '+cstr(cps)+' cps] to: '+memuboard.name;
      end;
      sl1('+',s);
      if ((incom) and (uls)) then begin
        if (convt) then begin
          lng:=origblocks;
          sprint('%090%Original file size : %150%'+cstrl(lng)+' bytes.');
        end;
        lng:=f.filesize;
        if (convt) then
          sprint('%090%New file size      : %150%'+cstrl(lng)+' bytes') else
          sprint('%090%File size          : %150%'+cstrl(lng)+' bytes');
          sprint('%090%Upload time        : %150%'+longtim(tooktime));
        r2dt(convtime,convtime1);
        if (convt) then
          sprint('%090%Convert time       : %150%'+longtim(convtime1)+' [Not Refunded]');
          sprint('%090%Transfer rate      : %150%'+cstr(cps)+' cps');
        r2dt(ulrefundgot,ulrefundgot1);
          sprint('%090%Time refund        : %150%'+longtim(ulrefundgot1));
        if (gotpts<>0) then
          sprint('%090%File points        : %150%'+cstr(gotpts)+' pts');
        nl;
        if (choptime<>0.0) then begin
          choptime:=choptime+ulrefundgot;
          freetime:=freetime-ulrefundgot;
          sprint('%140%Sorry, no upload time refund may be given at this time.');
          sprint('%140%You will get your refund after the event.');
          nl;
        end;
        doul(gotpts);
      end
      else sprint('%110%Entry added.');
    end;
  end;
  if (not ok) and (not offline) then begin
    if (exist(adrv(memuboard.dlpath)+fn)) then begin
      sprint('%120%Upload not received.');
      s:='File Deleted';
      if ((thisuser.sl>0 {systat^.minresumelatersl} ) and
          (f.filesize div 1024>systat^.minresume)) then begin
        nl;
        dyny:=TRUE;
        if pynq('%120%Save file to resume later? %110%') then begin
          doffstuff(f,fn,gotpts);
          f.fileflags:=f.fileflags+[ffresumelater];
          if (not aexists) or (rn=0) then newff(f) else writefv(rn,f);
          s:='File saved to be resumed later';
        end;
      end;
      if (not (ffresumelater in f.fileflags)) then begin
        if (exist(adrv(memuboard.dlpath)+fn)) then begin
          assign(fi,adrv(memuboard.dlpath)+fn);
          {$I-} erase(fi); {$I+}
        end;
      end;
      sl1('!','Error uploading '+sqoutsp(fn)+' - '+s);
    end;
    sprint('%090%Taking away time refund of %110%'+ctim(ulrefundgot)+'%090% minutes.');
    freetime:=freetime-ulrefundgot;
  end;
  if (offline) then begin
    f.filesize:=0;
    doffstuff(f,fn,gotpts);
    f.fileflags:=f.fileflags+[ffisrequest];
    newff(f);
  end;
  fileboard:=oldboard;
  fiscan(pl);
end;

*)

procedure unlisted_download(s:astr);
var dok,kabort:boolean;
    pl,oldnumbatchfiles,oldfileboard:integer;
begin
  if (s<>'') then begin
    if (not exist(s)) then print('File not found.')
    else if (iswildcard(s)) then print('Wildcards are not allowed.')
      else begin
        oldnumbatchfiles:=numbatchfiles;
        oldfileboard:=fileboard; fileboard:=-1;
        fflag:=FALSE;
        dlflag:=TRUE;
        send1(s,dok,kabort);
        if (numbatchfiles=oldnumbatchfiles) and (dok) and (not kabort) then
          dodl(5);
        fileboard:=oldfileboard;
      end;
  end;
end;

procedure listed_download(basenum:integer; s:astr);
var dok,kabort:boolean;
    olduboard:integer;
    pl,rn,oldnumbatchfiles:integer;
    flf:integer;
begin
  if (s<>'') then begin
    s:=allcaps(s);
    olduboard:=fileboard;
    if fbaseac(basenum) then begin
        changefileboard(basenum);
        if (iswildcard(s)) then begin
                print('Wildcards are not allowed.');
                exit;
        end;
        recno(s,pl,rn);
        if (rn=0) then begin
                print('File not found.');
                exit;
        end;
        NXF.Seekfile(rn);
        if (NXF.Ferror) then begin
                print('File not found.');
                exit;
        end;
        NXF.Readheader;
        oldnumbatchfiles:=numbatchfiles;
        flf:=ymbadd(adrv(memuboard.dlpath)+NXF.Fheader.filename);
        case flf of
               -1:begin
                  sprint('%150%'+NXF.Fheader.filename+' %030%has been requested.');
                  end;
                0:begin
                  sprint('%030%Flagged file: %150%'+NXF.Fheader.filename);
                  end;
                else begin
                sprint('%150%'+NXF.Fheader.filename+' %030%- '+showflagfile(flf));
                end;
        end;

        if (numbatchfiles<>oldnumbatchfiles) then begin
                batchdl;
        end;
        fileboard:=olduboard;
        end;
  end;
end;

procedure do_unlisted_download;
var s:astr;
begin
  nl;
  sprint('%070%Enter file name to download [d:\path\filename.ext] : ');
  sprompt(gstring(19));
  mpl(76); input(s,76);
  unlisted_download(s);
end;

procedure arcstuff(var ok,convt:boolean;    { if ok - if converted }
                   var blks:longint;        { # blocks     }
                   var convtime:real;       { convert time }
                   itest:boolean;           { whether to test integrity }
                   fpath:astr;              { filepath     }
                   var fn:astr;             { filename     }
                   var descr:astr);         { description  }
var fi:file of byte;
    convtook,convstart,convend:datetimerec;
    oldnam,newnam,s,sig:astr;
    sttime:real;
    x,y,c:word;
    ok2:integer;
    af:file of archiverrec;
    a,a2:archiverrec;
    oldarc,newarc:integer;
begin
  {*  oldarc: current archive format, 0 if none
   *  newarc: desired archive format, 0 if none
   *  oldnam: current filename
   *  newnam: desired archive format filename
   *}

  if (memuboard.cdrom) then begin
        sprint('Skipping archive '+fn+': CD-ROM base.');
        exit;
  end;

  convtime:=0.0;
  ok:=TRUE;

  assign(fi,fpath+fn);
  {$I-} reset(fi); {$I+}
  if (ioresult<>0) then blks:=0
  else begin
    blks:=(filesize(fi));
    close(fi);
  end;

  newarc:=memuboard.arctype;
  oldarc:=1;
  oldnam:=sqoutsp(fpath+fn);
  assign(af,adrv(systat^.gfilepath)+'ARCHIVER.DAT');
  {$I-} reset(af); {$I+}
  if (ioresult<>0) then begin
        sprint('%120%No archivers defined!');
        exit;
  end;
  if (filesize(af)<2) then begin
        sprint('%120%No archivers defined!');
        exit;
  end;
  seek(af,1);
  oldarc:=0;
  while not(eof(af)) do begin
        read(af,a);
        if (a.extension<>'') and (a.extension=copy(fn,length(fn)-2,3)) and (a.active)
                then oldarc:=filepos(af)-1;
  end;
  if (newarc>filesize(af)-1) then newarc:=0 else begin
        seek(af,newarc);
        read(af,a);
        if not(a.active) or (a.extension='') then newarc:=0;
  end;
  if (newarc=0) then newarc:=oldarc;

  {* if both archive formats supported ... *}
  if ((oldarc<>0) and (newarc<>0)) then begin
        seek(af,newarc);
        read(af,a);
        seek(af,oldarc);
        read(af,a2);
        {* archive extension supported *}
    newnam:=fn;
    if (pos('.',newnam)<>0) then newnam:=copy(newnam,1,pos('.',newnam)-1);
    newnam:=sqoutsp(fpath+newnam+'.'+a.extension);
    {* if integrity tests supported ... *}
    if (itest) then begin
      sprompt('%030%Testing file integrity... ');
      arcintegritytest(ok,oldarc,oldnam);
      if (not ok) then begin
        sl1('!',oldnam+' in #'+cstr(fileboard)+': errors in archive');
        sl1('!','No conversion on this file.');
        sprint('%120%Errors!');
      end else
        sprint('%150%Passed.');
      end;

    {* if conversion required ... *}
    if ((ok) and (oldarc<>newarc) and (newarc<>0)) then begin
      convt:=incom;   {* don't convert if local and non-file-SysOp *}
      s:=a.extension;
      if (fso) then begin
        dyny:=TRUE;
        convt:=pynq('%120%Convert archive to .'+s+' format? %110%');
      end;
      if (convt) then begin
        nl;

        ok:=FALSE;
        sprompt('%030%Converting archive... ');
        getdatetime(convstart);
        conva(ok2,oldarc,newarc,'nextemp5.dat',oldnam,newnam);
        getdatetime(convend);
        timediff(convtook,convstart,convend);
        convtime:=dt2r(convtook);
      case ok2 of
        0:begin
                sprompt('%150%Finished!|LF|');
                ok:=TRUE;
          end;
        1:begin
                sprompt('%120%ERROR! Not converted!|LF|');
                sl1('!','Error converting!');
          end;
        3:begin
                sprompt('%150%No conversion necessary.|LF|');
                sl1('!','Archive skipped.  No conversion necessary.');
          end;
        4:begin
                sprompt('%150%Archive AV stamped.  Not converted.|LF|');
                sl1('!','Archive AV stamped.  No conversion necessary.');
          end;
        end;

        if (ok) then begin
          assign(fi,fpath+fn);
          rewrite(fi); close(fi); erase(fi);
          assign(fi,newnam);
          {$I-} reset(fi); {$I+}
          if (ioresult<>0) then ok:=FALSE
          else begin
            blks:=filesize(fi);
            close(fi);
            if (blks=0) then ok:=FALSE;
          end;
          fn:=stripname(newnam);
          sprint('%110%No errors in conversion.  File passed.');
        end else begin
          assign(fi,newnam);
          rewrite(fi); close(fi); erase(fi);
          sl1('a',oldnam+' on #'+cstr(fileboard)+': conversion unsuccessful');
          sprint('%110%Errors during conversion.  Original format retained.');
          newarc:=oldarc;
        end;
        ok:=TRUE;
      end else
        newarc:=oldarc;
    end;

    {* if comment fields supported/desired ... *}
    if (ok) then begin
      s:=sqoutsp(fpath+fn);
      arccomment(ok,newarc,memuboard.cmttype,s);
      ok:=TRUE;
    end;
  end;
  fn:=sqoutsp(fn);

  if ((isgifext(fn)) and (fbusegifspecs in memuboard.fbstat)) then begin
    getgifspecs(adrv(memuboard.dlpath)+fn,sig,x,y,c);
    s:='('+cstrl(x)+'x'+cstrl(y)+','+cstr(c)+'c) ';
    descr:=s+descr;
    if (length(descr)>45) then descr:=copy(descr,1,45);
  end;
  close(af);
end;

end.
