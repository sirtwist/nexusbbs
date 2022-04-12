{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R-,S+,V-}
unit file8;

interface

uses
  crt,dos,common,
  myio3,
  execbat;

function ymbadd(fname:astr):INTEGER;
procedure send1(fn:astr; var dok,kabort:boolean);
{procedure receive1(fn:astr; resumefile:boolean; var dok,kabort,addbatch:boolean);}
function checkfileratio:integer;
function showflagfile(x:integer):STRING;

implementation

uses file0, file6;

var protocol:protrec;             { protocol in memory                    }

function showflagfile(x:integer):STRING;
begin
case x of
                1:showflagfile:='File Doesn''t Exist';
                2:showflagfile:='File is Request Only';
                3:showflagfile:='File is Resume-Later';
                4:showflagfile:='File is Unvalidated';
                5:showflagfile:=gstring(62);
                6:showflagfile:='Not enough Time Left';
                7:showflagfile:=gstring(63);
                8:showflagfile:='Access To File Denied';
                else showflagfile:='';
end;
end;

procedure abeep;
var a,b,c,i,j:integer;
begin
  for j:=1 to 3 do begin
    for i:=1 to 3 do begin
      a:=i*500;
      b:=a;
      while (b>a-300) do begin
        sound(b);
        dec(b,50);
        c:=a+1000;
        while (c>a+700) do begin
          sound(c); dec(c,50);
          delay(2);
        end;
      end;
    end;
    delay(50);
    nosound;
  end;
end;

function checkfileratio:integer;
var i,r,t:real;
    j:integer;
    badratio:boolean;
    olduboard:integer;
    batchf:file of flaggedrec;
    batch:flaggedrec;
begin
  t:=0;
  olduboard:=fileboard;
  assign(batchf,adrv(systat^.temppath)+'FLAG'+cstrn(cnode)+'.DAT');
  filemode:=64;
  {$I-} reset(batchf); {$I+}
  if (ioresult<>0) then begin
        numbatchfiles:=0;
  end else begin
  if (numbatchfiles<>filesize(batchf)) then numbatchfiles:=filesize(batchf);
  if (numbatchfiles<>0) then
    for j:=1 to numbatchfiles do begin
      read(batchf,batch);
      loaduboard(batch.filebase);
      if (not (fbnoratio in memuboard.fbstat)) and not(batch.isfree) then
        t:=t+(batch.blocks);
    end;
    close(batchf);
  end;
  badratio:=FALSE;
  if (thisuser.dk>thisuser.uk) then begin
  t:=t+thisuser.dk;
  if (thisuser.uk=0) then r:=(t+0.001) else
  r:=(t+0.001)/(thisuser.uk+0.001);
  if (r>security.dlratiokb) then badratio:=TRUE;
  end;
  if (thisuser.downloads>thisuser.uploads) then begin
  if (thisuser.uploads=0) then i:=(thisuser.downloads+numbatchfiles+0.001)
  else
  i:=(thisuser.downloads+numbatchfiles+0.001)/(thisuser.uploads+0.001);
  if (i>security.dlratiofiles) then badratio:=TRUE;
  end;
  if ((aacs(systat^.nodlratio)) or (fnodlratio in thisuser.ac)) then
    badratio:=FALSE;
  if (not systat^.uldlratio) then badratio:=FALSE;
  checkfileratio:=0;
  if (badratio) then
    if (numbatchfiles=0) then checkfileratio:=1 else checkfileratio:=2;
  fileboard:=olduboard;
  loaduboard(fileboard);
  if (fbnoratio in memuboard.fbstat) then checkfileratio:=0;
end;




function ymbadd(fname:astr):INTEGER;
var t1,t2:real;
    f:file of byte;
    dt:datetimerec;
    sof:longint;
    ior:word;
    s:string;
    slrn,rn,pl,fblks:integer;
    slfn:astr;
    ffo:boolean;
    batchf:file of flaggedrec;
    batch:flaggedrec;
    ymbadd2,x:integer;


procedure filerequest(fn:string; fb:integer);
var rf:file of requestrec;
    rr:requestrec;
    x:integer;
begin
assign(rf,adrv(systat^.userpath)+'REQUESTS.DAT');
filemode:=66;
{$I-} reset(rf); {$I+}
if (ioresult<>0) then begin
        rewrite(rf);
        rr.fileavail:=FALSE;
        rr.ReqDenied:=FALSE;
        rr.filename:='';
        rr.Filebase:=-1;
        rr.UserReal:='';
        for x:=1 to 100 do rr.reserved[x]:=0;
        write(rf,rr);
end;
seek(rf,filesize(rf));
rr.fileavail:=FALSE;
rr.ReqDenied:=FALSE;
rr.filename:=allcaps(fn);
rr.filebase:=fb;
rr.UserReal:=thisuser.realname;
for x:=1 to 100 do rr.reserved[x]:=0;
write(rf,rr);
close(rf);
sl1('!','Request: '+fn+' by '+rr.UserReal);
end;

begin
  fname:=sqoutsp(fname);
  ymbadd2:=0;
  if (exist(fname)) then begin
    filemode:=64;
    assign(f,fname);
    {$I-} reset(f); {$I+}
    if (ioresult<>0) then begin
                ymbadd:=1;
                exit;
    end;
    filemode:=66;
    sof:=filesize(f);
    fblks:=trunc((sof)/1024.0);
    t1:=rte*fblks;
    close(f);
    t2:=batchtime+t1;
    if (t2>nsl) then begin
                ymbadd:=6;
                exit;
    end else begin
      assign(batchf,adrv(systat^.temppath)+'FLAG'+cstrn(cnode)+'.DAT');
      filemode:=66;
      {$I-} reset(batchf); {$I+}
      if (ioresult<>0) then begin
        numbatchfiles:=0;
        rewrite(batchf);
      end;
      with batch do begin
        if (fileboard<>-1) then begin
          slrn:=lrn; slfn:=lfn;
          recno(align(stripname(fname)),pl,rn);
          NXF.Seekfile(rn); NXF.Readheader;
          if (NXF.Fheader.filepoints>thisuser.filepoints) and
          (NXF.Fheader.filepoints>0) and (not(ffisfree in NXF.Fheader.fileflags)) and
          (not aacs(systat^.nofilepts)) and (not(fnofilepts in thisuser.ac)
          and (systat^.fileptratio)) then begin
                ymbadd:=5;
                if (filesize(batchf)=0) then begin
                        close(batchf);
                        {$I-} erase(batchf) {$I+}
                end else close(batchf);
                exit;
          end;
          if (checkfileratio<>0) and (not (fbnoratio in memuboard.fbstat)) and
          (not(ffisfree in NXF.Fheader.fileflags)) then begin
                ymbadd:=7;
                if (filesize(batchf)=0) then begin
                        close(batchf);
                        {$I-} erase(batchf) {$I+}
                end else close(batchf);
                exit;
          end;
          if (ffnotval in NXF.Fheader.fileflags) and not(fso) then begin
                ymbadd:=4;
                if (filesize(batchf)=0) then begin
                        close(batchf);
                        {$I-} erase(batchf) {$I+}
                end else close(batchf);
                exit;
          end;
          if (ffisrequest in NXF.Fheader.fileflags) then begin          
                if (fballowofflinerequest in memuboard.fbstat) then begin
                        dyny:=TRUE;
                        if pynq('%150%'+allcaps(NXF.Fheader.filename)+'%120% is Offline.  Request it? ') then
                        begin
                        filerequest(NXF.Fheader.filename,fileboard);
                        ymbadd2:=-1;
                        end;
                end else begin
                ymbadd:=2;
                if (filesize(batchf)=0) then begin
                        close(batchf);
                        {$I-} erase(batchf) {$I+}
                end else close(batchf);
                end;
                exit;
          end;                
          if (ffresumelater in NXF.Fheader.fileflags) then begin
                ymbadd:=3;
                if (filesize(batchf)=0) then begin
                        close(batchf);
                        {$I-} erase(batchf) {$I+}
                end else close(batchf);
                exit;
          end;
          if not(aacs(NXF.Fheader.access)) then begin
                ymbadd:=8;
                if (filesize(batchf)=0) then begin
                        close(batchf);
                        {$I-} erase(batchf) {$I+}
                end else close(batchf);
                exit;
          end;          
          
          lrn:=slrn; lfn:=slfn;
          if (fbnoratio in memuboard.fbstat) or
          ((systat^.fileptratio) and ((fnofilepts in thisuser.ac) or aacs(systat^.nofilepts)))
          or (ffisfree in NXF.Fheader.fileflags) then
          batch.isfree:=TRUE else batch.isfree:=FALSE;
          filepoints:=NXF.Fheader.filepoints;
          blocks:=(NXF.Fheader.filesize div 1024);
          for x:=1 to 10 do descript[x]:='';
          x:=1;
          s:='';
          NXF.DescStartup;
          while (x<=10) and (s<>#1+'EOF'+#1) do begin
                  s:=NXF.GetDescLine;
                  descript[x]:=s;
                  inc(x);
          end;
        end else begin
          filepoints:=unlisted_filepoints;
          blocks:=fblks;
          for x:=1 to 10 do descript[x]:='';
        end;

        if (memuboard.cdrom) then batch.iscdromfile:=TRUE else
                batch.iscdromfile:=FALSE;
        inc(numbatchfiles);
        filename:=sqoutsp(fname);
        ttime:=t1;
        filebase:=fileboard;
        batchtime:=t2;

        seek(batchf,filesize(batchf));
        write(batchf,batch);
        close(batchf);
        sl1('+','Flagged '+stripname(filename)+'.');
        r2dt(batchtime,dt);
      end;
    end;
  end else begin
                if (fballowofflinerequest in memuboard.fbstat) then begin
                        dyny:=TRUE;
                        if pynq('%150%'+allcaps(stripname(fname))+'%120% is Offline.  Request it? ') then
                        begin
                        filerequest(stripname(fname),fileboard);
                        ymbadd2:=-1;
                        end;
                end else begin
                        ymbadd2:=1;
                end;
  end;
  ymbadd:=ymbadd2;
end;

procedure addtologupdown;
var s:astr;
begin
  s:='  ULs: '+cstr(trunc(thisuser.uk))+'k in '+cstr(thisuser.uploads)+' file';
  if thisuser.uploads<>1 then s:=s+'s';
  s:=s+'  -  DLs: '+cstr(trunc(thisuser.dk))+'k in '+cstr(thisuser.downloads)+' file';
  if thisuser.downloads<>1 then s:=s+'s';
  sl1(':',s);
end;

procedure send1(fn:astr; var dok,kabort:boolean);
var nfn,cp,slfn,s:astr;
    st:real;
    filsize:longint;
    dcode:word; { dos exit code }
    p,i,sx,sy,t,pl,rn,slrn,errlevel:integer;
    g,c:char;
    flf:integer;
    b,done1,foundit:boolean;
begin
  done1:=FALSE;
  filemode:=66;
  {$I-} reset(xf); {$I+}
  if (ioresult<>0) then begin
        sprint('Error reading Protocols.');
        pausescr;
        exit;
  end;
    if (fflag) then p:=-12 else
    repeat
      nl;
      showprots(FALSE,TRUE,FALSE,FALSE);
      nl;
      sprompt('%030%Protocol [%150%Q%030%uit] : %150%'); mpkey(s);
      if (s[1]='Q') then begin done1:=true; p:=-10; end else begin
        p:=findprot(s[1],FALSE,TRUE,FALSE,FALSE);
        if (p=-99) then print('Invalid entry.') else done1:=TRUE;
      end;
    until (done1) or (hangup);

  dok:=TRUE; kabort:=FALSE;
  if (-p in [1,2,3,4]) or (p in [1..200]) then
    case checkfileratio of
      1:begin
          nl;
          sprint(gstring(63));
          nl;
          prompt('You have DLed: '+cstr(trunc(thisuser.dk))+'k in '+cstr(thisuser.downloads)+' file');
          if thisuser.downloads<>1 then print('s') else nl;
          prompt('You have ULed: '+cstr(trunc(thisuser.uk))+'k in '+cstr(thisuser.uploads)+' file');
          if thisuser.uploads<>1 then print('s') else nl;
          nl;
          print('  1 upload for every '+cstr(security.dlratiofiles)+' downloads must be maintained.');
          print('  1k must be uploaded for every '+cstr(security.dlratiokb)+'k downloaded.');
          sl1('!','Tried to download while ratio out of balance:');
          addtologupdown;
          p:=-11;
        end;
      2:begin
          nl;
          sprint(gstring(63));
          nl;
          print('Assuming you download the files already flagged,');
          print('your upload/download ratio would be out of balance.');
          sl1('!','Tried to flag files while ratio out of balance:');
          addtologupdown;
          p:=-11;
        end;
    end;
  if (p>=0) then begin seek(xf,p); read(xf,protocol); end;
  close(xf);
  lastprot:=p;
  case p of
   -12:begin
        flf:=ymbadd(fn);
        case flf of
               -1:begin
                  sprint('%150%'+stripname(fn)+' %030%has been requested.');
                  end;
                0:begin
                  sprint('%030%Flagged File: %150%'+stripname(fn));
                  end;
                else begin
                sprint('%150%'+stripname(fn)+' %030%- '+showflagfile(flf));
                end;
        end;
       end;
   -10:begin kabort:=true; dok:=false; end;
  else
      if (incom) then begin
        if (xbINTERNAL in protocol.xbstat) then begin
                cp:=adrv(systat^.utilpath)+'NXPDRIVE.EXE -S -B'+cstr(answerbaud);
                cp:=cp+' -C'+cstr(modemr^.comport)+' -N'+cstr(cnode);
                case modemr^.ctype of
                        0:cp:=cp+' -D1';
                        1:cp:=cp+' -D2';
                        2:cp:=cp+' -D3';
                        3:cp:=cp+' -D1';
                end;
                if (xbMiniDisplay in protocol.xbstat) then begin
                        cp:=cp+' -M';
                end;
                if (protocol.dlcmd='INT_ZMODEM_SEND') then begin
                        cp:=cp+' -Z';
                end else
                if (protocol.dlcmd='INT_YMOD-G_SEND') then begin
                        cp:=cp+' -G';
                end else
                if (protocol.dlcmd='INT_YMODEM_SEND') then begin
                        cp:=cp+' -Y';
                end else
                if (protocol.dlcmd='INT_XMOD1K_SEND') then begin
                        cp:=cp+' -K';
                end else
                if (protocol.dlcmd='INT_XMODEM_SEND') then begin
                        cp:=cp+' -X';
                end;
                cp:=cp+' -F='+sqoutsp(fn);
        end else begin
                cp:=processmci(protocol.dlcmd);
                cp:=cp+' SINGLE '+cstrl(modemr^.comport);
                if (not(incom) and not(outcom)) then cp:=cp+' '+cstrl(0)
                        else cp:=cp+' '+cstrl(answerbaud);
                if not(modemr^.lockport) then cp:=cp+' '+cstrl(answerbaud) else
                        cp:=cp+' '+cstrl(modemr^.waitbaud);
                cp:=cp+' '+sqoutsp(fn);
        end;

        shelling:=1;
        currentswap:=modemr^.swapprotocol;
        if (useron) then sprint('%030%Sending:');
        if not(xbINTERNAL in protocol.xbstat) then begin
        if (useron) then shel('User downloading: '+nam)
                    else shel('Sending file(s)');
        end else shel('');
        errlevel:=protocol.dlcode;
        shelldos(FALSE,cp,errlevel);
        shel2;
        currentswap:=0;
        shelling:=0;

        foundit:=FALSE; i:=0;
        if (protocol.dlcode=errlevel) then foundit:=TRUE;

        dok:=TRUE;
        if not(foundit) then dok:=FALSE;
      end;
  end;
end;

procedure receive1(fn:astr; resumefile:boolean; var dok,kabort,addbatch:boolean);
var cp,nfn,s:astr;
    st:real;
    filsize:longint;
    p,i,t,fno,sx,sy,nof,errlevel:integer;
    c:char;
    b,done1,foundit:boolean;
begin
  done1:=FALSE;
  reset(xf);
  repeat
      nl;
      showprots(TRUE,FALSE,FALSE,resumefile);
      nl;
      sprompt('%030%Protocol [%150%Q%030%uit] : %150%'); mpkey(s);
      if (s[1]='Q') then begin p:=-11;dok:=FALSE; kabort:=TRUE; done1:=TRUE; end else begin
        p:=findprot(s[1],TRUE,FALSE,FALSE,resumefile);
        if (p=-99) then print('Invalid entry.') else done1:=TRUE;
      end;
  until (done1) or (hangup);
  if (p>=0) then begin seek(xf,p); read(xf,protocol); end;
  close(xf);
  case p of
    -11,-10:begin dok:=FALSE; kabort:=TRUE; end;
  else
      if (incom) then begin
        cp:=processmci(protocol.ulcmd);
        bproline(cp,sqoutsp(fn));
        shelling:=1;
        currentswap:=modemr^.swapprotocol;
        if (useron) then sprint('%030%Receiving:');
        if (useron) then
        shel('Uploading |  User Name: '+caps(thisuser.name)) else
                       shel('Uploading');
        errlevel:=protocol.ulcode;
        shelldos(FALSE,cp,errlevel);
        shel2;
        shelling:=0;
        currentswap:=0;
        foundit:=FALSE; i:=0;
        if (protocol.ulcode=errlevel) then foundit:=TRUE;

        dok:=TRUE;
        if (not(foundit)) then dok:=FALSE;
      end;
  end;
end;

end.
