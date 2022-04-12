{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R-,S+,V-}
unit init2;

interface

uses
  crt, dos, myio, misc, mulaware;

procedure readp;
procedure initp1(Nexusdir:string);
procedure init(Nexusdir:string);
procedure savesystat2(nexusdir:string);

implementation

uses sysop2h;

procedure savesystat2(nexusdir:string);
var f:file;
    systatf:file of MatrixREC;
    x:integer;
    t:file;
    sr:searchrec;
begin
  filemode:=66;
  assign(systatf,nexusdir+'\MATRIX.DAT');
  rewrite(systatf); write(systatf,systat); close(systatf);
  findfirst(adrv(systat.semaphorepath)+'INUSE.*',anyfile,sr);
  while (doserror=0) do begin
        x:=value(copy(sr.name,pos('.',sr.name)+1,length(sr.name)-pos('.',sr.name)));
        if (x=0) then x:=1000;
        if (TRUE) then begin
                assign(f,adrv(systat.semaphorepath)+'INUSE.'+cstrnfile(x));
                {$I-} reset(f); {$I+}
                if (ioresult=0) then begin
                        close(f);
			assign(t,adrv(systat.semaphorepath)+'MXUPDATE.'+cstrnfile(x));
			rewrite(t);
			close(t);
		end;
        end;
   findnext(sr);
   end;
end;

procedure readp;
var filv:text;
    d:astr;
    x,a,count:integer;
    cnd,s:string;
    c,c2:char;

  function sc(s:astr; i:integer):char;
  begin
    s:=allcaps(s); sc:=s[i];
  end;


  function atoi(s:astr):word;
  var i,code:integer;
  begin
    val(s,i,code);
    if code<>0 then i:=0;
    atoi:=i;
  end;

begin
  cursoron(FALSE);
  a:=0;
  cnd:='';
end;

procedure initp1(Nexusdir:string);
var filv:text;
    conf:file of confrec;
    fstringf:file;
    hiver,lover:string;
    sr:smalrec;
    fidorf:file of fidorec;
    langname:string;
    fidor:fidorec;
    fp:file;
    uidf:file of useridrec;
    uid:useridrec;
    x,sx,sy,numread,i:integer;
    donedr,dn,errs,npatch,npatch2:boolean;
    dvs,s:astr;
    drec:searchrec;

  function existdir(fn:astr):boolean;
  var srec:searchrec;
  begin
    while (fn[length(fn)]='\') do fn:=copy(fn,1,length(fn)-1);
    findfirst(fexpand(sqoutsp(fn)),anyfile,srec);
    existdir:=(doserror=0) and (srec.attr and directory=directory);
  end;


  function findbadpaths:boolean;
  var s:astr;
      i:integer;
      yes:boolean;
  begin
    yes:=false;
    with systat do begin
      i:=0;
      repeat
        inc(i);
        case i of
          1:s:=gfilepath;  
          2:s:=afilepath;  
          3:s:=menupath;   
          4:s:=trappath;
          5:s:=userpath;    
          6:s:=utilpath;
          7:s:=semaphorepath;
          9:s:=filepath;
        end;
        if (not existdir(s)) then yes:=TRUE;
      until (yes) or (i=9);
      end;
      cursoron(FALSE);
      findbadpaths:=yes;
  end;

function gstring(x:integer):STRING;
var f:file;
    s:string;
    numread:word;
begin
assign(f,adrv(systat.gfilepath)+'ENGLISH.NXL');
{$I-}reset(f,1); {$I+}
if (ioresult<>0) then begin
        gstring:='';
        exit;
end;
if (stridx.offset[x]<>-1) then begin
{$I-} seek(f,stridx.offset[x]); {$I+}
if (ioresult<>0) then begin
        gstring:='';
        close(f);
        exit;
end;
blockread(f,s[0],1,numread);
if (numread<>1) then begin
        gstring:='';
        close(f);
        exit;
end;
blockread(f,s[1],ord(s[0]),numread);
if (numread<>ord(s[0])) then begin
        gstring:='';
        close(f);
        exit;
end;
end else begin
s:='';
end;
close(f);
gstring:=s;
end;


begin
  textbackground(7); textcolor(0);

  textcolor(7);textbackground(0);

  while (findbadpaths) do pomisc1(TRUE);

  {new(fstring);}
  
  assign(nxsetf,adrv(systat.gfilepath)+'NXSETUP.DAT');
  {$I-} reset(nxsetf); {$I+}
  if (ioresult<>0) then begin
        rewrite(nxsetf);
        nxset.fbmgr:=systat.utilpath+'NXFBMGR.EXE -Z';
        nxset.ommgr:=systat.utilpath+'OMSSETUP.EXE';
        for x:=1 to sizeof(nxset.reserved) do nxset.reserved[x]:=0;
        nxset.restrict:=FALSE;
        for x:=1 to 10 do begin
                nxset.speckey[x].name:='';
                nxset.speckey[x].path:='';
        end;
        for x:=1 to sizeof(nxset.reserved2) do nxset.reserved2[x]:=0;
        nxset.swaptype:=4;
        write(nxsetf,nxset);
        close(nxsetf);
  end else begin
        read(nxsetf,nxset);
        close(nxsetf);
  end;

  npatch:=readsystemdat;
  if not(npatch) then begin
        displaybox('Error reading SYSTEM.DAT ... exiting!',3000);
        halt(1);
  end;

  npatch:=false;
  assign(sf,adrv(systat.gfilepath)+'USERS.IDX');
  filemode:=66; 
  {$I-} reset(sf); {$I+}
  if (ioresult<>0) then begin
        npatch:=true;
  end else close(sf);


  npatch2:=FALSE;
  assign(uidf,adrv(systat.gfilepath)+'USERID.IDX');
  filemode:=66;
  {$I-} reset(uidf); {$I+}
  if (ioresult<>0) then begin
        npatch2:=TRUE;
  end else close(uidf);

  if (npatch) and not(npatch2) then begin
  displaybox2(w,'Error reading USERS.IDX...');
  end else
  if (npatch2) and not(npatch) then begin
  displaybox2(w,'Error reading USERID.IDX...');
  end else
  if (npatch2) and (npatch) then begin
  displaybox2(w,'Error reading USERS.IDX and USERID.IDX...');
  end;
  assign(uf,adrv(systat.gfilepath)+'USERS.DAT');
  filemode:=66; 
  {$I-} reset(uf); {$I+}
  if (ioresult<>0) then begin
        displaybox('Error reading USERS.DAT!',2000);
        halt(1);
{        rewrite(uf);
        fillchar(thisuser,sizeof(thisuser),#0);
        write(uf,thisuser);
        thisuser.userid:=1;
        syst.lastuserid:=1;
        write(uf,thisuser);
        seek(uf,0); }
  end;
  if (filesize(uf)>1) then begin
    seek(uf,1);
    read(uf,thisuser);
  end else begin
        fillchar(thisuser,sizeof(thisuser),#0);
        seek(uf,1);
        write(uf,thisuser);
        seek(uf,1);
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
                seek(uidf,thisuser.userid);
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
         displaybox('Error reading USERS.IDX ... Fixed.',2000);
         end else
         if (npatch2) and not(npatch) then begin
         displaybox('Error reading USERID.IDX ... Fixed.',2000);
         end else
         if (npatch2) and (npatch) then begin
         displaybox('Error reading USERS.IDX and USERID.IDX... Fixed.',2000);
         end;
         seek(uf,1);
         read(uf,thisuser);
         npatch:=false;
         npatch2:=FALSE;
  end;

  filemode:=66; 
  {$I-} reset(sf); {$I+}
  if (ioresult<>0) then begin
        displaybox('Error opening USERS.IDX.',3000);
        halt(1);
  end;
  if (syst.numusers<>(filesize(sf)-1)) then begin
    displaybox2(w,'User Count does not match with USERS.IDX ...');
    syst.numusers:=(filesize(sf)-1);
    updatesystem;
    removewindow(w);
    displaybox('User Count does not match with USERS.IDX ... Fixed.',2000);
  end;
  close(sf);
  close(uf);

  assign(bf,adrv(systat.gfilepath)+'MBASES.DAT');
  filemode:=66; 
  {$I-} reset(bf); {$I+} 
  if (ioresult<>0) then begin
         displaybox('ERROR: Cannot read MBASES.DAT',3000);
         halt;
  end;
  numboards:=filesize(bf);
  close(bf);
  dec(numboards);
   

  assign(ulf,adrv(systat.gfilepath)+'FBASES.DAT');
  filemode:=66; 
  {$I-} reset(ulf); {$I+}
  if (ioresult<>0) then begin
        displaybox('ERROR: Cannot read FBASES.DAT',3000);
        halt(0);
  end;
  maxulb:=filesize(ulf);
  close(ulf);
  dec(maxulb);
  
  uephone1:='Phone #1';
  uephone2:='Phone #2';
  ueopt1:='Optional #1';
  ueopt2:='Optional #2';
  ueopt3:='Optional #3';
  textbackground(0); textcolor(7);
  assign(fstringf,adrv(systat.gfilepath)+'ENGLISH.NXL');
  filemode:=66; 
  {$I-} reset(fstringf,1); {$I-}
  if ioresult<>0 then begin
        exit;
  end;
  blockread(fstringf,stridx,sizeof(stridx),numread);
  if (numread<>sizeof(stridx)) then begin
        exit;
  end;
  close(fstringf);
  uephone1:=gstring(196);
  uephone2:=gstring(197);
  ueopt1:=gstring(198);
  ueopt2:=gstring(199);
  ueopt3:=gstring(200);
  if (uephone1='') then uephone1:='Phone #1';
  if (uephone2='') then uephone2:='Phone #2';
  if (ueopt1='') then ueopt1:='Optional #1';
  if (ueopt2='') then ueopt2:='Optional #2';
  if (ueopt3='') then ueopt3:='Optional #3';

end;

procedure init(Nexusdir:string);
var rcode:integer;
begin
  if (daynum(datelong)=0) then begin
    clrscr;
    writeln('Please set the DATE and TIME in your operating system.');
    writeln('These items are required for Nexus and its utilities to run properly.');
    halt;
  end;

  checkbreak:=FALSE;
  checksnow:=systat.cgasnow;
  directvideo:=not systat.usebios;

  readp; 
  initp1(NexusDir);
end;

end.
