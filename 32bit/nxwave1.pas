unit nxwave1;

interface

uses dos,crt,myio,mkmisc,mkmsgabs,mkglobt,mkopen,spawno,nxwave2,
     ivmodem,nxwave3,mkdos,mkstring,keyunit,unix2,tagunit,mulaware;

procedure endprogram;
procedure languagestartup;
procedure updatestatus;
procedure BuildScanTable;
procedure showbundlelist;
procedure makebundlelist;
procedure WriteINF;
procedure getNXW;
procedure getuser;
procedure processUPL;
procedure packmail;
procedure unpackmail;
procedure saveuser;
procedure maintenance;
procedure domainmenu;
function askdl:byte;
procedure updatelastread;
procedure stopmodem;
procedure startmodem;
procedure ResetPointers;

implementation

TYPE ScanTableREC=
     RECORD
          BaseNum:INTEGER;
          BaseName:STRING[60];
          TotMsgs:INTEGER;
          NewMsgs:INTEGER;
          BundleMsgs:INTEGER;
          Pers   :INTEGER;
          StartMSG:INTEGER;
          FirstMSG:INTEGER;
          Bundle:BOOLEAN;
          RESERVED:ARRAY[1..40] of BYTE;
     end;

CONST scanbuilt:boolean=FALSE;
var tdf:file of ScanTableREC;
var error:word;

procedure checkdir(ss:string);

  function existdir(fn:string):boolean;
  var srec:searchrec;
  begin
    while (fn[length(fn)]='\') do fn:=copy(fn,1,length(fn)-1);
    findfirst(fexpand(sqoutsp(fn)),anyfile,srec);
    existdir:=(doserror=0) and (srec.attr and directory=directory);
  end;

begin

  if not(existdir(ss)) then begin
        {$I-} mkdir(ss); {$I+}
        if (ioresult<>0) then begin
                writeln('Error creating user directory!');
                halt;
        end;
  end;

end;

procedure endprogram;
begin
if (stridx<>NIL) then dispose(stridx);
end;

function recreatelanguage:boolean;
var langf:file of languagerec;
    langr:languagerec;
    x:integer;
begin
assign(langf,adrv(systat.gfilepath)+'LANGUAGE.DAT');
{$I-} rewrite(langf); {$I+}
if (ioresult<>0) then begin
        displaybox('Error Creating LANGUAGE.DAT',4000);
        recreatelanguage:=FALSE;
        end;
langr.name:='English';
langr.filename:='ENGLISH';
langr.menuname:='ENGLISH';
langr.access:='';
langr.displaypath:='';
langr.checkdefpath:=FALSE;
langr.startmenu:=6;
for x:=1 to sizeof(langr.reserved1) do langr.reserved1[x]:=0;
write(langf,langr);
write(langf,langr);
close(langf);
end;

procedure getlang(b:byte);
var langf:file of languagerec;
    ok:boolean;
begin
ok:=TRUE;
assign(langf,adrv(systat.gfilepath)+'LANGUAGE.DAT');
{$I-} reset(langf); {$I+}
if (ioresult<>0) then begin
         ok:=recreatelanguage;
         if (ok) then begin
                {$I-} reset(langf); {$I+}
                if (ioresult<>0) then begin
                        ivwriteln('%120%Error opening Language Control File!  Hanging up!');
                        halt;
                end;
         end else begin
                        ivwriteln('%120%Error opening Language Control File!  Hanging up!');
                        halt;
         end;
end;
if (b<=filesize(langf)-1) then begin
        seek(langf,b);
        read(langf,langr);
end else begin
        if (filesize(langf)-1>=1) then begin
                seek(langf,1);
                read(langf,langr);
        end else begin
                        ivwriteln('%120%Error opening Language Control File!  Hanging up!');
                        halt;
        end;
end;
close(langf);
end;

procedure languagestartup;
var fstringf:file;
    numread:word;
begin
  getlang(1);
  new(stridx);
  assign(fstringf,adrv(systat.gfilepath)+allcaps(langr.filename)+'.NXL');
  filemode:=66; 
  {$I-} reset(fstringf,1); {$I-}
  if ioresult<>0 then begin
        writeln('Error Reading '+allcaps(langr.filename)+'.NXL... Exiting.');
        endprogram;
  end;
  blockread(fstringf,stridx^,sizeof(stridx^),numread);
  if (numread<>sizeof(stridx^)) then begin
        writeln('Error Reading '+allcaps(langr.filename)+'.NXL... Exiting.');
        endprogram;
  end;
  close(fstringf);
end;



procedure updatestatus;
var oldx,oldy:integer;
    ta:byte;
begin
ta:=textattr;
oldx:=wherex;
oldy:=wherey;
cursoron(FALSE);
window(1,1,80,25);
textcolor(15);
textbackground(3);
gotoxy(1,25);
clreol;
if (systat.aliasprimary) then
          write(mln(thisuser.name,35))
          else write(mln(thisuser.realname,35));
	  gotoxy(37,25);
          textcolor(15);
          write('³');
          gotoxy(38,25);
	  write(' SL: ');
          gotoxy(43,25);
          write(mln(cstr(thisuser.sl),3));
          gotoxy(47,25);
          write(' ³');
          gotoxy(49,25);
          if (online.baud=0) then
          write(' '+mln('Local',6))
          else
          write(' '+mln(cstr(online.baud*10),6));
          textcolor(15);
          write(' ³');
          gotoxy(64,25);
          write('³');
          gotoxy(66,25);
          cwrite('Left: ');
          window(1,1,80,24);
          gotoxy(oldx,oldy);
          cursoron(TRUE);
          textattr:=ta;
end;

procedure updatetime;
var dt:datetimerec;
    oldx,oldy:integer;
    ta:byte;
begin
ta:=textattr;
oldx:=wherex;
oldy:=wherey;
cursoron(FALSE);
window(1,1,80,25);
textcolor(15);
textbackground(3);
gotoxy(72,25);
r2dt((nsl),dt);
write(longt(dt));
window(1,1,80,24);
gotoxy(oldx,oldy);
cursoron(TRUE);
textattr:=ta;
end;

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

function smci3(s2:string):string;
var s:string;
begin
  s:='';
  if (allcaps(s2)='NODE') then s:=cstr(cnode) else
  if (allcaps(s2)='PADDEDNODE') then s:=cstrn(cnode) else
  if (allcaps(s2)='NEXUSDIR') then s:=nexusdir else
  if (s='') then s:=#28+s2+'|';
  smci3:=s;
end;


function process_door(s:string):string;
var ps1,ps2,i:integer;
    sda,namm:string;
    sdoor:string[255];
    done:boolean;
begin
  namm:=thisuser.realname;
  sdoor:='';
  
  done:=false;
  while not(done) do begin  
	ps1:=pos('|',s);
	if (ps1<>0) then begin
	s[ps1]:=#28;
	ps2:=pos('|',s);
	if not(ps2=0) then
	s:=substall2(s,copy(s,ps1,(ps2-ps1)+1),smci3(copy(s,ps1+1,(ps2-ps1)-1)));
	end;
	if (pos('|',s)=0) then done:=TRUE;
  end;
  for i:=1 to length(s) do if (s[i]=#28) then s[i]:='|';
  
  sdoor:=s;
  process_door:=sdoor;
end;

function swapout(s:string):integer;
var b:byte;
    oldx,oldy,ta:byte;
begin
ta:=textattr;
oldx:=wherex;
oldy:=wherey;
window(1,1,80,24);
savescreen(w,1,1,80,24);
clrscr;
textcolor(15);
textbackground(1);
gotoxy(1,1);
writeln(s);
Init_spawno(copy(nexusdir,1,length(nexusdir)-1),(swap_ems AND swap_xms AND swap_disk),20,0);
b:=spawn(getenv('COMSPEC'),' /c '+process_door(s),0);
if (b=-1) then begin
       exec(getenv('COMSPEC'),' /c '+process_door(s));
       swapout:=lo(dosexitcode);
end else swapout:=0;
updatestatus;
removewindow(w);
window(1,1,80,24);
gotoxy(oldx,oldy);
textattr:=ta;
end;

function swapout2(s:string):integer;
var b:byte;
    oldx,oldy,ta:byte;
    c:char;
begin
ta:=textattr;
oldx:=wherex;
oldy:=wherey;
window(1,1,80,24);
savescreen(w,1,1,80,24);
clrscr;
textcolor(15);
textbackground(1);
gotoxy(1,1);
clreol;
writeln(adrv(systat.utilpath)+'NXAPS.EXE '+s);
Init_spawno(copy(nexusdir,1,length(nexusdir)-1),(swap_ems and swap_xms and swap_disk),20,0);
b:=spawn(adrv(systat.utilpath)+'NXAPS.EXE',s,0);
if (b=-1) then begin
       exec(adrv(systat.utilpath)+'NXAPS.EXE',s);
       swapout2:=lo(dosexitcode);
end else swapout2:=0;
updatestatus;
removewindow(w);
window(1,1,80,24);
gotoxy(oldx,oldy);
textattr:=ta;
end;

function askdl:byte;
var s,s2:string;
    an,x,x2,rn:integer;
    cmd:char;
    d:boolean;
    tdfrec:ScanTableREC;
begin
reset(tdf);
repeat
d:=false;
ivtextcolor(3);
ivtextbackground(0);
ivwrite(gstring(1900));
ivwrite(gstring(1901));
s:='';
ivreadln(s,20,'U');
if (s='') then s:='D';
case s[1] of
        '?':begin
                ivwrite(gstring(1902));
                ivwrite(gstring(1903));
                ivwrite(gstring(1904));
                ivwrite(gstring(1905));
                ivwrite(gstring(1906));
                ivwrite(gstring(1907));
            end;
        'D':begin
                askdl:=1;
                d:=TRUE;
                end;
        'R':begin
                close(tdf);
                showbundlelist;
                reset(tdf);
            end;
        'A':begin
                askdl:=2;
                d:=TRUE;
                end;
        else begin
                x2:=1;
                an:=-1;
                s2:='';
                while ((x2<=length(s)) and not(s[x2] in ['A'..'Z','+','-'])) do begin
                        s2:=s2+s[x2];
                        inc(x2);
                end;
                an:=value(s2);
                cmd:=s[x2];
                x:=value(copy(s,x2+1,length(s)-x2));
                case cmd of
                        '-':begin
                                seek(tdf,0);
                                rn:=-1;
                                while not(eof(tdf)) and (rn=-1) do begin
                                read(tdf,tdfrec);
                                writeln(tdfrec.basenum);
                                if (tdfrec.basenum=an) then begin
                                        rn:=filepos(tdf)-1;
                                end;
                                writeln(rn);
                                end;
                                if (rn<>-1) then begin
                                ivwriteln('%030%Removing '+tdfrec.basename);
                                seek(tdf,rn);
                                tdfrec.Bundlemsgs:=0;
                                tdfrec.Bundle:=FALSE;
                                tdfrec.startmsg:=-1;
                                write(tdf,tdfrec);
                                end;
                            end;
                        '+':begin
                                seek(tdf,0);
                                rn:=-1;
                                while not(eof(tdf)) and (rn=-1) do begin
                                read(tdf,tdfrec);
                                if (tdfrec.basenum=an) then begin
                                        rn:=filepos(tdf)-1;
                                end;
                                end;
                                if (rn<>-1) then begin
                                ivwriteln('%030%Adding '+tdfrec.basename);
                                        seek(tdf,rn);
                                        tdfrec.Bundlemsgs:=tdfrec.newmsgs;
                                        tdfrec.StartMSG:=tdfrec.firstmsg;
                                        tdfrec.Bundle:=TRUE;
                                        write(tdf,tdfrec);
                                end;
                            end;
                        'L':begin
                            end;
                end;
        end;
end;
until (d);
close(tdf);
end;


procedure maintenance;
begin
assign(tdf,newdlpath+'NXWAVE.TMP');
{$I-} erase(tdf); {$I+}
if (ioresult<>0) then begin end;
if (nxwu.lastupd<>date) then begin
ivtextcolor(3);
ivtextbackground(0);
assign(nxwuf,adrv(systat.gfilepath)+'OMSUSER.DAT');
filemode:=66;
{$I-} reset(nxwuf); {$I+}
if (ioresult<>0) then begin
        writeln('Error Opening OMSUSER.DAT');
        endprogram;
end;
seek(nxwuf,usernum);
read(nxwuf,nxwu);
nxwu.numdl:=0;
nxwu.lastupd:=date;
seek(nxwuf,usernum);
write(nxwuf,nxwu);
end;
end;


procedure findhimsg;
begin
if not(Mbopened) then HiMsg:=0 else begin
        HiMsg:=CurrentMSG^.GetHighMsgNum;
end;
end;

function GetMbType:string;
begin
case memboard.MessageType of
        1:GetMbType:='S';
        2:GetMbType:='J';
        3:GetMbType:='F';
end;
end;

function GetMbPath:string;
var s:string;
begin
s:=memboard.msgpath;
if (s[length(s)]<>'\') then s:=s+'\';
GetMbPath:=s;
end;

function GetMbFileName:string;
begin
if (memboard.messagetype<>3) then GetMbFileName:=memboard.filename else
GetMbFileName:='';
end;

procedure MbOpenCreate;
begin
MbOpened:=OpenOrCreateMsgArea(CurrentMsg,GetMbType+GetMbPath+GetMbFileName);
findhimsg;
if (mbopened) then begin
lastread:=CurrentMSG^.GetLastRead(thisuser.userid)
end else lastread:=-1;
end;

procedure stopmodem;
begin
ivDeInstallModem;
end;


procedure startmodem;
begin
if not(localonly) then begin
if (online.baud=0) then begin
localonly:=TRUE;
comtype:=0;
end else begin
if (online.lockbaud=0) then
        ivInstallModem(online.comport,online.baud*10,error)
else
        ivInstallModem(online.comport,online.lockbaud*10,error);
if (error<>0) then begin
        writeln('Error opening Comport!');
        endprogram;
end;
end;
end else comtype:=0;
end;

procedure MbClose;
begin
MbOpened:=not(CloseMsgArea(CurrentMSG));
end;

procedure getuser;
var onlinef:file of onlinerec;
    sf:file of smalrec;
    sr:smalrec;
    uf:file of userrec;
    x,x2:integer;
    cdir:string;
begin
keydir:=nexusdir;
getdir(0,cdir);
{$I+} chdir(bslash(FALSE,nexusdir)); {$I+}
if (ioresult<>0) then begin
end;
checkkey('NEXUS');
{$I+} chdir(bslash(FALSE,cdir)); {$I+}
if (ioresult<>0) then begin
end;
assign(uf,adrv(systat.gfilepath)+'USERS.DAT');
if not((localonly) and (nouserfile)) then begin
        if not(exist(systat.semaphorepath+'INUSE.'+cstrnfile(cnode))) then begin
                writeln('No User Online.');
                endprogram;
        end;
        assign(onlinef,systat.gfilepath+'USER'+cstrn(cnode)+'.DAT');
        {$I-} reset(onlinef); {$I+}
        if (ioresult<>0) then begin
                writeln('Error Opening Node User Information.');
                endprogram;
        end;
        read(onlinef,online);
        close(onlinef);
        usernum:=online.number;
        okansi:=(online.emulation>0);
        assign(sf,systat.gfilepath+'USERS.IDX');
        {$I-} reset(sf); {$I+}
        if (ioresult<>0) then begin
                writeln('Error Opening USERS.IDX');
                endprogram;
        end;
        x2:=0;
        x:=0;
        while (x2=0) and not(eof(sf)) do begin
                seek(sf,x);
                read(sf,sr);
                if (allcaps(sr.real)=allcaps(online.real)) and (sr.number=usernum)
                then begin
                        x2:=x;
                end;
                inc(x);
        end;
        close(sf);
        if (x2=0) then begin
                writeln('User not found!');
                endprogram;
        end;
end else begin
        okansi:=TRUE;
        if (usernum=0) then begin
                writeln('Local Mode: No User Number Specified.');
                endprogram;
        end;
        assign(sf,systat.gfilepath+'USERS.IDX');
        {$I-} reset(sf); {$I+}
        if (ioresult<>0) then begin
                writeln('Error Opening USERS.IDX');
                endprogram;
        end;
        x2:=0;
        x:=0;
        while (x2=0) and not(eof(sf)) do begin
                seek(sf,x);
                read(sf,sr);
                if (sr.number=usernum) then begin
                        x2:=x;
                end;
                inc(x);
        end;
        close(sf);
        if (x2=0) then begin
                writeln('User not found!');
                endprogram;
        end;
end;
startmodem;
assign(userf,adrv(systat.gfilepath)+'USERS.DAT');
{$I-} reset(userf); {$I+}
if (ioresult<>0) then begin
        writeln('Error reading USERS.DAT');
        endprogram;
end;
if (usernum>filesize(userf)-1) then begin
        writeln('USERS.DAT does not match USERS.IDX');
        endprogram;
end;
seek(userf,usernum);
read(userf,thisuser);
close(userf);
assign(nxwuf,systat.gfilepath+'OMSUSER.DAT');
{$I-} reset(nxwuf); {$I+}
if (ioresult<>0) then begin
        writeln('Error reading OMSUSER.DAT');
        domailsetup(TRUE);
        {$I-} reset(nxwuf); {$I+}
        if (ioresult<>0) then begin
                writeln('Error re-reading OMSUSER.DAT... Terminating.');
                endprogram;
        end;
end;
if (thisuser.userid>filesize(nxwuf)-1) then begin
        close(nxwuf);
        domailsetup(TRUE);
        {$I-} reset(nxwuf); {$I+}
        if (ioresult<>0) then begin
                writeln('Error re-reading OMSUSER.DAT... Terminating.');
                endprogram;
        end;
end;
{$I-} seek(nxwuf,thisuser.userid); {$I+}
if (ioresult<>0) then begin
        writeln('Error finding User.');
        endprogram;
end;
read(nxwuf,nxwu);
close(nxwuf);
if (localonly) then begin
        newulpath:=process_door(nxw.localulpath);
        newdlpath:=process_door(nxw.localdlpath);
        newtemppath:=process_door(nxw.localtemppath);
        online.timeleft:=30;
end else begin
        newulpath:=adrv(systat.temppath)+'NODE'+cstrn(cnode)+'\NXWAVE1\';
        newdlpath:=adrv(systat.temppath)+'NODE'+cstrn(cnode)+'\NXWAVE1\';
        newtemppath:=adrv(systat.temppath)+'NODE'+cstrn(cnode)+'\NXWAVE2\';
end;
if not(existdir(bslash(false,newulpath))) then begin
        {$I-} mkdir(bslash(false,newulpath)); {$I+}
        if (ioresult<>0) then begin
                writeln('Error creating directory!');
                endprogram;
        end;
end;
if not(existdir(bslash(false,newdlpath))) then begin
        {$I-} mkdir(bslash(false,newdlpath)); {$I+}
        if (ioresult<>0) then begin
                writeln('Error creating directory!');
                endprogram;
        end;
end;
if not(existdir(bslash(false,newtemppath))) then begin
        {$I-} mkdir(bslash(false,newtemppath)); {$I+}
        if (ioresult<>0) then begin
                writeln('Error creating directory!');
                endprogram;
        end;
end;
end;

procedure getNXW;
begin
assign(nxwf,systat.gfilepath+'NXWAVE.DAT');
filemode:=66;
{$I-} reset(nxwf); {$I+}
if (ioresult<>0) then begin
        writeln('Error Reading '+systat.gfilepath+'NXWAVE.DAT');
        endprogram;
end;
read(nxwf,nxw);
close(nxwf);
SetTimeZone(systat.timezone);
end;

procedure tp2c(s:string; var s2:string; count:word);
var x:integer;
begin
fillchar(s2[0],count,#0);
x:=length(s);
if (length(s)>count-1) then x:=count-1;
move(s[1],s2[0],x);
end;

procedure makebundlelist;
type txBufArray=array[1..32767] of char;
     txBuf=^txBufArray;
var v,v1,x,x2,totnew,totpers,totalpers:integer;
    mptr:longint;
    spin:array[1..4] of char;
    dheader:array[1..4] of string;
    sp:byte;
    mscan:boolean;
    mixr:mix_rec;
    mixf:file of mix_rec;
    ftir:fti_rec;
    ftif:file of fti_rec;
    datf:file;
    s:string;
    c,c2:char;
    addr,addr2:addrtype;
    himsgnum,xx:integer;
    counter:longint;
    txb:txBuf;
    tdfrec:ScanTableREC;
    tuname,tualias,tname,fname:string;
    twitit,cempty,prv,readingtdf,toyou,fromyou,del:boolean;

function so:boolean;
begin
  so:=(aacs(systat.sop));
end;

function cso:boolean;
begin
  cso:=((so) or (aacs(systat.csop)));
end;

function mso:boolean;
var i:byte;
    b:boolean;
begin
  b:=FALSE;
  if x<>0 then for i:=1 to 20 do
    if (x=thisuser.boardsysop[i]) then b:=TRUE;
  mso:=((cso) or (aacs(systat.msop)) or (b));
end;


begin
tuname:=allcaps(thisuser.realname);
tualias:=allcaps(thisuser.name);
{if (menu) and (totalnew2=0) then begin
ivwrite(gstring(1920));
ivwrite(gstring(1921));
c:=#0;
while not(ivKeypressed) do begin timeslice; end;
c:=ivreadchar;
exit;
end;}
new(txb);
spin[1]:='/';
spin[2]:='-';
spin[3]:='\';
spin[4]:='|';
assign(bf,systat.gfilepath+'MBASES.DAT');
{$I-} reset(bf); {$I+}
if (ioresult<>0) then begin
                writeln('Error reading Message Bases.');
                endprogram;
end;
numboards:=filesize(bf)-1;
assign(mixf,newtemppath+nxw.packetname+'.MIX');
assign(ftif,newtemppath+nxw.packetname+'.FTI');
assign(datf,newtemppath+nxw.packetname+'.DAT');
if not(menu) and (totalnew2=0) then begin
ivwrite(gstring(1920));
if (nobundleexit) then exit;
end;
if (totalnew2<>0) then
if not(menu) then begin
ivwrite(gstring(1921));
ivwrite(gstring(1922));
if (okansi) then begin
dheader[1]:=gstring(1923);
dheader[2]:=gstring(1924);
dheader[3]:=gstring(1925);
dheader[4]:=gstring(1926);
end else begin
dheader[1]:=gstring(1927);
dheader[2]:=gstring(1928);
dheader[3]:=gstring(1929);
dheader[4]:=gstring(1930);
end;
ivwrite(dheader[1]);
ivwrite(dheader[2]);
ivwrite(dheader[3]);
ivwrite(dheader[4]);
end else begin
ivwrite(gstring(1931));
if (okansi) then begin
ivtextcolor(15);
ivwrite('0% ');
ivtextcolor(12);
ivwrite('þþþþþþþþþþþþþþþþþþþþ ');
ivtextcolor(15);
ivwrite('100%');
ivsend(#27+'[25D');
for x:=1 to 25 do write(^H);
end else begin
ivwriteln('0% --------------------- 100%');
ivwrite('   ');
end;
end;
v:=1;
abort:=FALSE;
rewrite(datf,1);
rewrite(ftif);
{$I-} reset(tdf); {$I+}
if (ioresult<>0) then begin
        ivwrite(gstring(1932));
        endprogram;
end;
totalpers:=0;
while not(eof(tdf)) and (ivcarrier) and not(abort) do begin
        read(tdf,tdfrec);
        seek(bf,tdfrec.basenum);
        read(bf,memboard);
        if (TRUE) then begin
                if (TRUE) then begin
                MbOpenCreate;
                if (mbopened) then begin
                if not(menu) then begin
                ivtextcolor(15);
                ivwrite(mrn(cstr(tdfrec.basenum),5)+' ');
                ivtextcolor(3);
                ivwrite('  '+mln(tdfrec.basename,34)+'  ');
                ivtextcolor(7);
                ivwrite(mrn(cstr(tdfrec.totmsgs),5)+'  ');
                sp:=1;
                end;
                if (tdfrec.bundle) then
                CurrentMSG^.Seekfirst(tdfrec.startmsg);
                totnew:=0;
                totpers:=0;
                mptr:=-1;
                if (tdfrec.bundle) then
                while (CurrentMSG^.Seekfound) and not(abort) do begin
                    CurrentMSG^.MsgStartup;
                    if not(CurrentMSG^.isDeleted) then begin
                    fname:=allcaps(CurrentMSG^.GetFrom);
                    tname:=allcaps(CurrentMSG^.GetTo);
                    twitit:=FALSE;
                    for xx:=1 to 5 do begin
                        if (fname=nxwu.twits[xx]) then twitit:=TRUE;
                    end;
                    fromyou:=(fname=tuname) or (fname=tualias);
                    toyou:=(tname=tuname) or (tname=tualias);
                    prv:=(CurrentMSG^.ispriv) or (private in memboard.mbpriv);

                    if (not(twitit) and ((nxwu.bundlefrom) or not(fromyou))
                    and (((prv) and ((toyou) or (fromyou) or (mso))) or not(prv))) then begin
                    if not(menu) then begin
                    ivtextcolor(15);
                    ivtextbackground(0);
                    ivwrite(spin[sp]);
                    end;
                    if (memboard.mbtype in [2,3]) and (toyou) then CurrentMSG^.SetRcvd(TRUE);
                    inc(totnew);
                    inc(totalnew);
                    if (menu) then begin
        for v1:=v to 20 do begin
        if (totalnew>=((totalnew2 div 20)*v1)) then begin
                ivtextcolor(1);
                ivtextbackground(0);
                ivwrite('Û');
                inc(v);
                end;
        end;
        end;

                    if (toyou) then begin
                        inc(totpers);
                        inc(totalpers);
                    end;


                with ftir do begin
                tp2c(CurrentMSG^.Getfrom,s,36);
                move(s[0],mfrom[1],36);
                tp2c(CurrentMSG^.Getto,s,36);
                move(s[0],mto[1],36);
                tp2c(CurrentMSG^.Getsubj,s,72);
                move(s[0],subject[1],72);
                tp2c(CurrentMSG^.GetDate+' '+CurrentMSG^.GetTime,s,20);
                move(s[0],date[1],20);
                msgnum:=CurrentMSG^.Getmsgnum;
                replyto:=CurrentMSG^.Getrefer;
                replyat:=CurrentMSG^.Getseealso;
                if (memboard.mbtype=2) then begin
                        CurrentMSG^.GetOrig(Addr);
                        orig_zone:=addr.zone;
                        orig_net:=addr.net;
                        orig_node:=addr.node;
                end;
                flags:=[];
                if (currentmsg^.ispriv) then flags:=flags+[FTI_MSGPRIVATE];
                if (currentmsg^.iscrash) then flags:=flags+[FTI_MSGCRASH];
                if (currentmsg^.isrcvd) then flags:=flags+[FTI_MSGREAD];
                if (currentmsg^.issent) then flags:=flags+[FTI_MSGSENT];
                if (currentmsg^.isfattach) then flags:=flags+[FTI_MSGFILE];
                if (currentmsg^.iskillsent) then flags:=flags+[FTI_MSGKILL];
                if (currentmsg^.islocal) then flags:=flags+[FTI_MSGLOCAL];
                if (currentmsg^.ishold) then flags:=flags+[FTI_MSGHOLD];
                if (currentmsg^.isfilereq) then flags:=flags+[FTI_MSGFRQ];
                if (currentmsg^.isDirect) then flags:=flags+[FTI_MSGDIRECT];
                    seek(datf,filesize(datf));
                    msgptr:=filepos(datf);
                    txb^[1]:=' ';
                    CurrentMSG^.MsgTxtStartup;
                    counter:=1;
                    while not(CurrentMSG^.EOM) and (counter<32767) do begin
                        c:=CurrentMSG^.Getchar;
                        inc(counter);
                        txb^[counter]:=c;
                    end;
                    blockwrite(datf,txb^,counter);
                    msglength:=counter;
                    seek(ftif,filesize(ftif));
                    if (mptr=-1) then begin
                        mptr:=(filepos(ftif)*sizeof(FTI_REC));
                    end;
                    write(ftif,ftir);
                    end;
                    himsgnum:=CurrentMSG^.Getmsgnum;
                    if not(menu) then begin
                    ivwrite(^H' '^H);
                    inc(sp);
                    if (sp=5) then sp:=1;
                    end;
                    end;
                    end;
                    CurrentMsg^.Seeknext;
                    if not(menu) then
                    if ivKeypressed then begin
                        c2:=ivReadChar;
                        if (c2 in [#32,#27,'A','a']) then abort:=TRUE;
                    end;
                end;
                if not(abort) then begin
                filemode:=66;
                {$I-} reset(mixf); {$I+}
                if (ioresult<>0) then begin
                      rewrite(mixf);
                end;
                seek(mixf,filesize(mixf));
                tp2c(cstr(tdfrec.basenum),s,6);
                move(s[0],mixr.areanum[1],6);
                mixr.totmsgs:=totnew;
                mixr.numpers:=totpers;
                mixr.msghptr:=mptr;
                write(mixf,mixr);
                close(mixf);
                if not(menu) then begin
                ivtextcolor(15);
                ivtextbackground(0);
                ivwrite(mrn(cstr(totnew),5)+'  ');
                if (totpers<>0) then ivtextcolor(12)
                else ivtextcolor(15);
                ivwrite(mrn(cstr(totpers),5)+'  ');
                ivtextcolor(8);
                ivwriteln('-----  -----');
                end;
                end else ivwriteln(' %120% -- Aborted.');
                if (mbopened) then MbClose;
                    if not(menu) then
                    if ivKeypressed then begin
                        c2:=ivReadChar;
                        if (c2 in [#32,#27,'A','a']) then abort:=TRUE;
                    end;
                    if (abort) then ivwriteln('%120%Aborted.');
                end;
        end;
        end;
end;
close(datf);
close(ftif);
close(tdf);
if (menu) then begin
ivwriteln('');
ivwriteln('');
end else
if (totalnew<>0) and not(abort) then begin
if (okansi) then begin
ivwrite(gstring(1933));
end else begin
ivwrite(gstring(1934));
end;
                ivtextcolor(3);
                ivtextbackground(0);
                ivwrite('  '+mln('Grand Totals',40)+'         ');
                ivwrite('%150%'+mrn(cstr(totalnew),5)+'  ');
                if (totpers<>0) then ivwrite('%120%'+mrn(cstr(totalpers),5)+'  ')
                else ivwrite('%150%'+mrn(cstr(totalpers),5)+'  ');
                ivtextcolor(8);
                ivwriteln('-----  -----');
end;
close(bf);
dispose(txb);
end;

procedure updatelastread;
var x:integer;
    mscan:boolean;
    tdfrec:ScanTableREC;
begin
assign(bf,systat.gfilepath+'MBASES.DAT');
{$I-} reset(bf); {$I+}
if (ioresult<>0) then begin
                writeln('Error reading Message Bases.');
                endprogram;
end;
{$I-} reset(tdf); {$I+}
if (ioresult<>0) then begin
        ivwrite(gstring(1935));
        exit;
end;
while not(eof(tdf)) do begin
        read(tdf,tdfrec);
        if (tdfrec.bundlemsgs<>0) then begin
        seek(bf,tdfrec.basenum);
        read(bf,memboard);
        MbOpenCreate;
        if (mbopened) then begin
                CurrentMSG^.Setlastread(thisuser.userid,himsg);
                MbClose;
        end;
        end;
end;
close(bf);
close(tdf);
{$I-} erase(tdf); {$I+}
if (ioresult<>0) then begin end;
end;

procedure ResetPointers;
var x:integer;
    UTAG:^TagRecordOBJ;

begin
assign(bf,systat.gfilepath+'MBASES.DAT');
{$I-} reset(bf); {$I+}
if (ioresult<>0) then begin
                writeln('Error reading Message Bases.');
                endprogram;
end;
numboards:=filesize(bf)-1;
x:=0;
ivwrite('%030%Resetting pointers... ');
new(UTAG);
if (UTAG=NIL) then begin
        ivwriteln(gstring(1937));
        exit;
end;
checkdir(adrv(systat.userpath)+hexlong(thisuser.userid)+'\');
UTAG^.Init(adrv(systat.userpath)+hexlong(thisuser.userid)+'\'+hexlong(thisuser.userid)+'.NWT');
UTAG^.MaxBases:=Numboards;
UTAG^.SortTags(adrv(systat.gfilepath)+'USER'+cstrn(cnode)+'.TWT',1);
x:=(UTAG^.Getfirst(adrv(systat.gfilepath)+'USER'+cstrn(cnode)+'.TWT'));
rewrite(tdf);
while (x<>-1) and (ivcarrier) do begin
                seek(bf,x);
                read(bf,memboard);
                if (aacs1(thisuser,thisuser.userid,memboard.acs)) then begin
                MbOpenCreate;
                if (mbopened) then begin
                        CurrentMSG^.SetLastRead(thisuser.userid,0);
                        MbClose;
                end;
                end;
                x:=(UTAG^.GetNext);
end;
UTAG^.Done;
dispose(UTAG);
close(bf);
ivwriteln('%150%Finished!');
end;


procedure BuildScanTable;
var x,x2,totnew,totpers:integer;
    mptr:longint;
    mscan:boolean;
    s:string;
    addr:addrtype;
    himsgnum:integer;
    counter:longint;
    fname,tname:string;
    tuname,tualias:string;
    tdfrec:scantablerec;
    toyou,fromyou,prv,del:boolean;
    UTAG:^TagRecordOBJ;

function so:boolean;
begin
  so:=(aacs(systat.sop));
end;

function cso:boolean;
begin
  cso:=((so) or (aacs(systat.csop)));
end;

function mso:boolean;
var i:byte;
    b:boolean;
begin
  b:=FALSE;
  if x<>0 then for i:=1 to 20 do
    if (x=thisuser.boardsysop[i]) then b:=TRUE;
  mso:=((cso) or (aacs(systat.msop)) or (b));
end;


begin
if not(scanbuilt) then begin
tuname:=allcaps(thisuser.realname);
tualias:=allcaps(thisuser.name);
assign(bf,systat.gfilepath+'MBASES.DAT');
{$I-} reset(bf); {$I+}
if (ioresult<>0) then begin
                writeln('Error reading Message Bases.');
                endprogram;
end;
numboards:=filesize(bf)-1;
x:=0;
ivwrite(gstring(1936));
abort:=FALSE;
new(UTAG);
if (UTAG=NIL) then begin
        ivwriteln(gstring(1937));
        exit;
end;
checkdir(adrv(systat.userpath)+hexlong(thisuser.userid)+'\');
UTAG^.Init(adrv(systat.userpath)+hexlong(thisuser.userid)+'\'+hexlong(thisuser.userid)+'.NWT');
UTAG^.MaxBases:=Numboards;
UTAG^.SortTags(adrv(systat.gfilepath)+'USER'+cstrn(cnode)+'.TWT',1);
x:=(UTAG^.Getfirst(adrv(systat.gfilepath)+'USER'+cstrn(cnode)+'.TWT'));
rewrite(tdf);
while (x<>-1) and (ivcarrier) do begin
            begin
                seek(bf,x);
                read(bf,memboard);
                if (aacs1(thisuser,thisuser.userid,memboard.acs)) then begin
                ivwrite(memboard.name);
                MbOpenCreate;
                if (mbopened) then begin
                tdfrec.TotMsgs:=CurrentMSG^.Numberofmsgs;
                tdfrec.startmsg:=lastread+1;
                tdfrec.firstmsg:=lastread+1;
                CurrentMSG^.Seekfirst(lastread+1);
                totnew:=0;
                totpers:=0;
                mptr:=-1;
                while (CurrentMSG^.Seekfound) do begin
                    CurrentMSG^.MsgStartup;
                    if not(CurrentMSG^.isDeleted) then begin
                    fname:=allcaps(CurrentMSG^.GetFrom);
                    tname:=allcaps(CurrentMSG^.GetTo);
                    fromyou:=(fname=tualias) or (fname=tuname);
                    toyou:=(tname=tualias) or (tname=tuname);
                    prv:=(CurrentMSG^.ispriv) or (private in memboard.mbpriv);

                    if ((nxwu.bundlefrom) or not(fromyou))
                    and (((prv) and ((toyou) or (fromyou) or (mso))) or not(prv)) then begin
                            inc(totnew);
                            inc(totalnew2);
                            if (toyou) then inc(totpers);
                    end;
                    end;
                    CurrentMsg^.Seeknext;
                end;
                tdfrec.basenum:=x;
                tdfrec.basename:=mln(memboard.name,34);
                tdfrec.newmsgs:=totnew;
                tdfrec.bundle:=TRUE;
                tdfrec.bundlemsgs:=totnew;
                if (totnew=0) then tdfrec.bundle:=FALSE;
                tdfrec.pers:=totpers;
                write(tdf,tdfrec);
                end;
                if (mbopened) then MbClose;
                for x2:=1 to lenn(memboard.name) do begin
                        ivwrite(^H' '^H);
                end;
                end;
                end;
        x:=(UTAG^.GetNext);
end;
UTAG^.Done;
dispose(UTAG);
close(bf);
close(tdf);
scanbuilt:=TRUE;
end;
end;

procedure showbundlelist;
var x,x2,totnew,totpers,totalnew,totalpers:integer;
    mptr:longint;
    spin:array[1..4] of char;
    dheader:array[1..4] of string;
    sp:byte;
    mscan:boolean;
    s:string;
    c:char;
    addr:addrtype;
    himsgnum:integer;
    counter:longint;
    fname,tname:string;
    tuname,tualias:string;
    tdfrec:scantablerec;
    toyou,fromyou,prv,del,mabort:boolean;

function so:boolean;
begin
  so:=(aacs(systat.sop));
end;

function cso:boolean;
begin
  cso:=((so) or (aacs(systat.csop)));
end;

function mso:boolean;
var i:byte;
    b:boolean;
begin
  b:=FALSE;
  if x<>0 then for i:=1 to 20 do
    if (x=thisuser.boardsysop[i]) then b:=TRUE;
  mso:=((cso) or (aacs(systat.msop)) or (b));
end;


begin
mabort:=FALSE;
tuname:=allcaps(thisuser.realname);
tualias:=allcaps(thisuser.name);
assign(bf,systat.gfilepath+'MBASES.DAT');
{$I-} reset(bf); {$I+}
if (ioresult<>0) then begin
                writeln('Error reading Message Bases.');
                endprogram;
end;
numboards:=filesize(bf)-1;
x:=0;
ivwrite(gstring(1921));
ivwrite(gstring(1922));
if (okansi) then begin
dheader[1]:=gstring(1923);
dheader[2]:=gstring(1924);
dheader[3]:=gstring(1925);
dheader[4]:=gstring(1926);
end else begin
dheader[1]:=gstring(1927);
dheader[2]:=gstring(1928);
dheader[3]:=gstring(1929);
dheader[4]:=gstring(1930);
end;
ivwrite(dheader[1]);
ivwrite(dheader[2]);
ivwrite(dheader[3]);
ivwrite(dheader[4]);
abort:=FALSE;
{$I-} reset(tdf); {$I+}
if (ioresult<>0) then begin
        ivwrite(gstring(1932));
        endprogram;
end;
totalnew:=0;
totalpers:=0;
while not(eof(tdf)) and (ivcarrier) and not(mabort) do begin
                read(tdf,tdfrec);
                ivtextcolor(15);
                ivtextbackground(0);
                ivwrite(mrn(cstr(tdfrec.basenum),5)+' ');
                ivtextcolor(3);
                ivtextbackground(0);
                ivwrite('  '+mln(tdfrec.basename,34)+'  ');
                ivtextcolor(7);
                ivwrite(mrn(cstr(tdfrec.TotMsgs),5)+'  ');
                sp:=1;
                totnew:=tdfrec.bundlemsgs;
                totpers:=tdfrec.pers;
                inc(totalnew,totnew);
                inc(totalpers,totpers);
                mptr:=-1;
                ivwrite('%150%'+mrn(cstr(totnew),5)+'  ');
                if (totpers<>0) then ivwrite('%120%'+mrn(cstr(totpers),5)+'  ')
                else ivwrite('%150%'+mrn(cstr(totpers),5)+'  ');
                ivtextcolor(8);
                ivwriteln('-----  -----');
                if (linenum=23) then begin
                        ivtextcolor(12);
                        c:=#0;
                        ivwrite('Continue? %110%Yes');
                        while not(ivKeypressed) do begin timeslice;  end;
                        c:=ivreadchar;
                        if upcase(c)='N' then begin
                                for x2:=1 to 18 do
                                ivwrite(^H' '^H);
                                linenum:=0;
                                mabort:=TRUE;
                        end else begin
                                for x2:=1 to 18 do
                                ivwrite(^H' '^H);
                                linenum:=0;
                        end;
                end;
end;
if not(mabort) then begin
if (okansi) then begin
ivwrite(gstring(1933));
end else begin
ivwrite(gstring(1934));
end;
                ivtextcolor(3);
                ivtextbackground(0);
                ivwrite('  '+mln('Grand Totals',40)+'         ');
                ivwrite('%150%'+mrn(cstr(totalnew),5)+'  ');
                if (totpers<>0) then ivwrite('%120%'+mrn(cstr(totalpers),5)+'  ')
                else ivwrite('%150%'+mrn(cstr(totalpers),5)+'  ');
                ivtextcolor(8);
                ivwriteln('-----  -----');
end;
close(tdf);
end;

procedure WriteINF;
var inf:INF_HEADER;
    infarea:INF_AREA_INFO;
    f:file;
    s:string;
    mscan:boolean;
    x,x2:integer;
    UTAG:^TagRecordOBJ;
begin
assign(f,newtemppath+nxw.packetname+'.INF');
with inf do begin
  ver:=PACKET_LEVEL;
  for x:=1 to 5 do begin
        tp2c(nxw.news[x],s,13);
        move(s[0],readerfiles[x][1],13);
  end;
  fillchar(regnum,sizeof(regnum),#0);
  mashtype:=0;
  tp2c(thisuser.realname,s,43);
  move(s[0],loginname[1],43);
  tp2c(thisuser.name,s,43);
  move(s[0],aliasname[1],43);
  tp2c(nxwu.password,s,21);
  for x:=1 to 21 do password[x]:=ord(s[x-1])+10;
  passtype:=0;
  zone:=411;
  net:=411;
  node:=0;
  point:=0;
  tp2c(systat.sysopname,s,41);
  move(s[0],sysop[1],41);
  ctrl_flags:=[inf_no_config,inf_no_freq];
  tp2c(systat.bbsname,s,65);
  move(s[0],systemname[1],65);
  maxfreqs:=0;
  fillchar(obsolete2,sizeof(obsolete2),#0);
  inf.uflags:=[INF_HOTKEYS,INF_XPERT,INF_GRAPHICS];
  fillchar(keywords,sizeof(keywords),#0);
  fillchar(filters,sizeof(filters),#0);
  fillchar(macros,sizeof(macros),#0);
  inf.netmail_flags:=[];
  if (aacs(systat.netmail) and aacs(systat.setnetmailflags)) then begin
  inf.netmail_flags:=[INF_CAN_CRASH,INF_CAN_ATTACH,INF_CAN_KSENT,INF_CAN_HOLD,
        INF_CAN_FREQ,INF_CAN_DIRECT];
  end;
  credits:=0;
  debits:=0;
  can_forward:=TRUE;
  inf_header_len:=ORIGINAL_INF_HEADER_LEN;
  inf_areainfo_len:=ORIGINAL_INF_AREA_LEN;
  mix_structlen:=ORIGINAL_MIX_STRUCT_LEN;
  fti_structlen:=ORIGINAL_FTI_STRUCT_LEN;
  uses_upl_file:=TRUE;
  from_to_len:=0;
  subject_len:=0;
  tp2c(nxw.packetname,s,9);
  move(s[0],packet_id[1],9);
  fillchar(reserved,sizeof(reserved),#0);
end;
rewrite(f,1);
blockwrite(f,inf,sizeof(inf));
assign(bf,systat.gfilepath+'MBASES.DAT');
{$I-} reset(bf); {$I+}
if (ioresult<>0) then begin
                writeln('Error reading Message Bases.');
                endprogram;
end;
numboards:=filesize(bf)-1;
x:=0;
new(UTAG);
if (UTAG=NIL) then begin
        ivwrite(gstring(1937));
        exit;
end;
checkdir(adrv(systat.userpath)+hexlong(thisuser.userid)+'\');
UTAG^.Init(adrv(systat.userpath)+hexlong(thisuser.userid)+'\'+hexlong(thisuser.userid)+'.NWT');
UTAG^.MaxBases:=Numboards;
UTAG^.SortTags(adrv(systat.gfilepath)+'USER'+cstrn(cnode)+'.TWT',1);
while (x<=numboards) do begin
        seek(bf,x);
        read(bf,memboard);
        mscan:=UTAG^.IsTagged(memboard.baseid);
        if (aacs1(thisuser,thisuser.userid,memboard.acs)) then begin
        with infarea do begin
                        tp2c(cstr(x),s,6);
                        move(s[0],areanum[1],6);
                        tp2c(memboard.nettagname,s,21);
                        move(s[0],echotag[1],21);
                        tp2c(stripcolor(memboard.name),s,50);
                        move(s[0],title[1],50);
                        area_flags:=[];
                        if (mscan) then begin
                        area_flags:=area_flags+[INF_SCANNING];
                        end;
                        if not(MBrealname in memboard.mbstat) then
                        area_flags:=area_flags+[INF_ALIAS_NAME];
                        if (memboard.mbtype in [1..3]) then
                        area_flags:=area_flags+[INF_ECHO];
                        if (memboard.mbtype in [2,3]) then
                        area_flags:=area_flags+[INF_NETMAIL];
                        if (aacs1(thisuser,thisuser.userid,memboard.postacs)) then
                        area_flags:=area_flags+[INF_POST];
                        if (private in memboard.mbpriv) then
                        area_flags:=area_flags+[INF_NO_PUBLIC];
                        if (public in memboard.mbpriv) then
                        area_flags:=area_flags+[INF_NO_PRIVATE];
                        if (MBfilter in memboard.mbstat) then
                        area_flags:=area_flags+[INF_NO_HIGHBIT];
                        network_type:=INF_NET_FIDONET;
                        if (memboard.mbtype=3) then
                        network_type:=INF_NET_INTERNET;
                end;
                blockwrite(f,infarea,sizeof(infarea));
                end;
                inc(x);
end;
UTAG^.Done;
dispose(utag);
close(bf);
close(f);
end;

procedure sendmail(fname:string);
var protf:file of protrec;
    prot:protrec;
    s:string;
    nbaud,nlock:longint;
begin
assign(protf,adrv(systat.gfilepath)+'PROTOCOL.DAT');
{$I-} reset(protf); {$I+}
if (ioresult<>0) then begin
        ivwrite(gstring(1938));
        exit;
end;
if (nxwu.protocol>filesize(protf)-1) then begin
        ivwrite(gstring(1939));
        exit;
end;
seek(protf,nxwu.protocol);
read(protf,prot);
close(protf);
nbaud:=online.baud*10;
nlock:=online.lockbaud*10;
ivwrite(gstring(1940));
if (xbINTERNAL in prot.xbstat) then begin
                s:=adrv(systat.utilpath)+'NXPDRIVE.EXE -S -B'+cstr(nbaud);
                s:=s+' -C'+cstr(online.comport)+' -N'+cstr(cnode);
                case online.comtype of
                        0:s:=s+' -D2';
                        1:s:=s+' -D1';
                        2:s:=s+' -D3';
                end;
                if (xbMiniDisplay in prot.xbstat) then begin
                        s:=s+' -M';
                end;
                if (prot.dlcmd='INT_ZMODEM_SEND') then begin
                        s:=s+' -Z';
                end else
                if (prot.dlcmd='INT_YMOD-G_SEND') then begin
                        s:=s+' -G';
                end else
                if (prot.dlcmd='INT_YMODEM_SEND') then begin
                        s:=s+' -Y';
                end else
                if (prot.dlcmd='INT_XMOD1K_SEND') then begin
                        s:=s+' -K';
                end else
                if (prot.dlcmd='INT_XMODEM_SEND') then begin
                        s:=s+' -X';
                end;
                s:=s+' -F='+fname;
end else begin
s:=prot.dlcmd+' SINGLE '+cstr(online.comport)+' '+cstr(nbaud)+' '+
        cstr(nlock)+' '+fname;
end;
stopmodem;
if (swapout(s)<>0) then begin end;
startmodem;
end;

function getday:string;
var year,month,day,dayofweek:word;
    s:string;
begin
  getdate(year,month,day,dayofweek);
  case dayofweek of
        0:s:='SU';
        1:s:='MO';
        2:s:='TU';
        3:s:='WE';
        4:s:='TH';
        5:s:='FR';
        6:s:='SA';
  end;
  getday:=s;
end;

function getnum(x:word):string;
var s:string;
begin
if (x in [1..9]) then s:=cstr(x) else
begin
s:=chr((x-9)+64);
end;
getnum:=s;
end;

function getarcext(b:byte):string;
var af:file of archiverrec;
    a:archiverrec;
begin
  assign(af,adrv(systat.gfilepath)+'ARCHIVER.DAT');
  {$I-} reset(af); {$I+}
  if (ioresult<>0) then begin
  getarcext:='';
  exit;
  end;
  if (b>filesize(af)) then begin
        getarcext:='';
        close(af);
  exit;
  end;
  seek(af,b);
  read(af,a);
  getarcext:=a.extension;
  close(af);
end;


procedure packmail;
var arcf:file of archiverrec;
    arc:archiverrec;
    pname,pname2,s,infiles:string;
    i:integer;
    f:file;
begin
if (ivcarrier) then begin
pname:=nxw.packetname+'.'+getday+getnum(nxwu.numdl+1);
if (localonly) then begin
        ivwrite(gstring(1941));
        ivwriteln(newdlpath+pname);
end else begin
        ivwriteln(gstring(1942));
end;
if (ivcarrier) then writeinf;
chdir(bslash(FALSE,newtemppath));
infiles:='*.*';
for i:=1 to 5 do begin
if (nxw.news[i]<>'') then begin
        infiles:=infiles+' '+adrv(systat.afilepath)+nxw.news[i];
end;
end;
pname2:=nxw.packetname+'.'+getarcext(nxwu.archiver);
s:='4 a '+newdlpath+pname2+' '+infiles;
if (swapout2(s)=0) then begin
        assign(f,newdlpath+pname2);
        {$I-} rename(f,newdlpath+pname); {$I+}
        while (ioresult<>0) do begin
                inc(nxwu.numdl);
                pname:=nxw.packetname+'.'+getday+getnum(nxwu.numdl+1);
                {$I-} rename(f,newdlpath+pname); {$I+}
        end;
        if not(localonly) then begin
                sendmail(newdlpath+pname);
        end;
        inc(nxwu.numdl);
end;
end;
purgedir(bslash(FALSE,newtemppath));
end;

procedure receivemail(pname:string);
var protf:file of protrec;
    prot:protrec;
    fname,s:string;
    nbaud,nlock:longint;
begin
if (ivcarrier) then begin
assign(protf,adrv(systat.gfilepath)+'PROTOCOL.DAT');
{$I-} reset(protf); {$I+}
if (ioresult<>0) then begin
        ivwrite(gstring(1943));
        exit;
end;
{$I-} seek(protf,nxwu.protocol); {$I+}
if (ioresult<>0) then begin
        ivwrite(gstring(1944));
        exit;
end;
read(protf,prot);
close(protf);
ivwrite(gstring(1945));
fname:=nxw.packetname+'.NEW';
nbaud:=online.baud*10;
nlock:=online.lockbaud*10;
if (xbINTERNAL in prot.xbstat) then begin
                s:=adrv(systat.utilpath)+'NXPDRIVE.EXE -R=. -B'+cstr(nbaud);
                s:=s+' -C'+cstr(online.comport)+' -N'+cstr(cnode);
                case online.comtype of
                        0:s:=s+' -D2';
                        1:s:=s+' -D1';
                        2:s:=s+' -D3';
                end;
                if (xbMiniDisplay in prot.xbstat) then begin
                        s:=s+' -M';
                end;
                if (prot.dlcmd='INT_ZMODEM_RECV') then begin
                        s:=s+' -Z';
                end else
                if (prot.dlcmd='INT_YMOD-G_RECV') then begin
                        s:=s+' -G';
                end else
                if (prot.dlcmd='INT_YMODEM_RECV') then begin
                        s:=s+' -Y';
                end else
                if (prot.dlcmd='INT_XMOD1K_RECV') then begin
                        s:=s+' -K';
                end else
                if (prot.dlcmd='INT_XMODEM_RECV') then begin
                        s:=s+' -X';
                end;
                s:=s+' -F='+fname;
end else begin
s:=prot.ulcmd+' SINGLE '+cstr(online.comport)+' '+cstr(nbaud)+' '+
        cstr(nlock)+' '+fname;
end;
stopmodem;
if (swapout(s)<>0) then begin end;
startmodem;
end;
end;

procedure unpackmail;
var s:string;
    sr:searchrec;
    f:file;
begin
if (ivcarrier) then begin
chdir(bslash(FALSE,newulpath));
if not(localonly) then begin
        receivemail(nxw.packetname+'.NEW');
end;
findfirst(newulpath+nxw.packetname+'.NEW',anyfile-directory-volumeid,sr);
if (doserror=0) then begin
ivtextcolor(3);
ivtextbackground(0);
ivwrite('Unpacking Bundle: ');
ivtextcolor(15);
ivwriteln(newulpath+sr.name);
chdir(bslash(FALSE,newtemppath));
{s:=arcmci(arc.unarcline,newulpath+sr.name,'*.*');}
s:='4 e '+newulpath+sr.name+' *.*';
if (swapout2(s)<>0) then begin end;
packetreceived:=TRUE;
assign(f,newulpath+sr.name);
{$I-} erase(f); {$I+}
if (ioresult<>0) then begin end;
findnext(sr);
end else packetreceived:=FALSE;
end else packetreceived:=FALSE;
end;


function GetUnixDate(Date:Longint):STRING;
var y,m,d,h,min,s:word;
begin
Unix2Norm(date,y,m,d,h,min,s);
getunixdate:=tch(cstr(m))+'/'+tch(cstr(d))+'/'+tch(cstr(y));
end;

function GetUnixTime(Date:Longint):STRING;
var y,m,d,h,min,s:word;
begin
Unix2Norm(date,y,m,d,h,min,s);
getunixTime:=tch(cstr(h))+':'+tch(cstr(min))+':'+tch(cstr(s));
end;

procedure updateuser;
var f:file;
begin
assign(userf,adrv(systat.gfilepath)+'USERS.DAT');
filemode:=66;
{$I-} reset(userf); {$I+}
if (ioresult<>0) then begin
        writeln('Error reading USERS.DAT');
        endprogram;
end;
if (usernum>filesize(userf)-1) then begin
        writeln('USERS.DAT does not match USERS.IDX');
        endprogram;
end;
seek(userf,usernum);
write(userf,thisuser);
close(userf);
assign(f,adrv(systat.semaphorepath)+'READUSER.'+cstrnfile(cnode));
{$I-} rewrite(f); {$I+}
if (ioresult<>0) then begin end;
end;

procedure processUPL;
var f:file;
    UPLH:UPL_HEADER;
    UPLR:UPL_REC;
    t:text;
    network_to:string;
    s,s2:string;
    dt:datetime;
    add:integer;
    x,x2:integer;
    mbnum:integer;
    d:datetimerec;
    rver:string;
    fidof:file of fidorec;
    fidor:fidorec;
    dosd:longint;
    addr,addr2:addrtype;
    numread:word;
    iff:file of internetrec;
    ir:internetrec;

  procedure setnetflags;
  begin
  CurrentMSG^.SetPriv(TRUE);
  if (upl_netcrash in uplr.netmail_attr) then currentMSG^.SetCrash(TRUE);
  if (upl_netfile in uplr.netmail_attr) then currentMSG^.SetFAttach(TRUE);
  if (upl_netkill in uplr.netmail_attr) then currentMSG^.SetKillSent(TRUE);
  if (upl_netlocal in uplr.netmail_attr) then currentMSG^.Setlocal(TRUE);
  if (upl_netfrq in uplr.netmail_attr) then currentMSG^.SetFileReq(TRUE);
  if (upl_netdirect in uplr.netmail_attr) then currentMSG^.SetDirect(TRUE);
  if (upl_nethold in uplr.netmail_attr) then currentMSG^.SetHold(TRUE);
  end;

  function vtpword(i:integer):string;
  var bstring:string;
  begin
  bstring:=tch(cstr(systat.cbuild));
  if (systat.cbuildmod<>'') then bstring:=bstring+systat.cbuildmod;
  case i of
        0:if (registered) then vtpword:='.'+bstring+'-beta+ (public)' else
          vtpword:='.'+bstring+'-beta (public)';
        1:vtpword:='.'+bstring+'-alpha';
        2:vtpword:='.'+bstring+'-beta';
        3:vtpword:='.'+bstring+'-dev';
        4:vtpword:='.'+bstring+'-eep';
        else vtpword:='.'+bstring+'/PIRATED';
  end;
  end;

  function getorigin:string;
  var s:astr;
  begin
    if (fidor.origins[memboard.origin]<>'') then s:=fidor.origins[memboard.origin]
      else if (fidor.origins[1]<>'') then s:=fidor.origins[1]
	else s:=copy(stripcolor(systat.bbsname),1,50);
    while (copy(s,length(s),1)=' ') do
      s:=copy(s,1,length(s)-1);
    getorigin:=s;
  end;

    function getaddr(zone,net,node,point:integer):string;
    var s:string;
    begin
      if (point=0) then
	s:=cstr(zone)+':'+cstr(net)+'/'+cstr(node)+')'
      else
	s:=cstr(zone)+':'+cstr(net)+'/'+cstr(node)+'.'+cstr(point)+')';
      getaddr:=s;
    end;

        function rr(s4:string; num:integer):string;
        var x4,x5:integer;
            s5:string;
        begin
        s5:='';
        x5:=0;
                for x4:=num downto 1 do begin
                        s5:=s4[length(s4)-x5]+s5;
                        inc(x5);
                end;
                rr:=s5
        end;
begin
if (packetreceived) then begin
assign(fidof,adrv(systat.gfilepath)+'NETWORK.DAT');
{$I-} reset(fidof); {$I+}
if (ioresult<>0) then begin
        writeln('Error opening NETWORK.DAT');
        endprogram;
end;
read(fidof,fidor);
close(fidof);
assign(iff,adrv(systat.gfilepath)+'INTERNET.DAT');
{$I-} reset(iff); {$I+}
if (ioresult<>0) then begin
        writeln('Error opening INTERNET.DAT');
        endprogram;
end;
read(iff,ir);
close(iff);
assign(f,newtemppath+nxw.packetname+'.UPL');
{$I-} reset(f,1); {$I+}
if (ioresult<>0) then begin
        writeln('Error opening '+newtemppath+nxw.packetname+'.UPL');
        exit;
end;
blockread(f,uplh,sizeof(uplh),numread);
if (uplh.upl_header_len<>sizeof(uplh)) then begin
        seek(f,uplh.upl_header_len);
end;
        assign(bf,adrv(systat.gfilepath)+'MBASES.DAT');
        filemode:=66;
        {$I-} reset(bf); {$I+}
        if (ioresult<>0) then begin
                writeln('Error opening MBASES.DAT');
                endprogram;
        end;
ivwrite(gstring(1947));
s:='';
move(uplh.reader_name[1],s[1],80);
s[0]:=chr(80);
if (pos(#0,s)>0) then
s[0]:=chr(pos(#0,s)-1);
ivwrite(s);
rver:='';
move(uplh.vernum[1],rver[1],20);
rver[0]:=chr(20);
if (pos(#0,rver)>0) then
rver[0]:=chr(pos(#0,rver)-1);
for x:=1 to length(rver) do rver[x]:=chr(ord(rver[x])+10);
ivwrite(' v'+rver);
if (uplh.not_registered) then ivwriteln(' [NR]') else ivwriteln('');
s:='';
move(uplh.reader_tear[1],s[1],16);
s[0]:=chr(16);
if (pos(#0,s)>0) then
s[0]:=chr(pos(#0,s)-1);
if (s<>'') then begin
      s2:=s+' v'+rver;
end else begin
      s2:='';
end;
rver:=s2;
if (uplh.not_registered) and (rver<>'') then rver:=rver+' [NR]';
if (okansi) then ivwrite(gstring(1948)) else ivwrite(gstring(1949));
while not(eof(f)) do begin
        network_to:='';
        blockread(f,uplr,uplh.upl_rec_len);
        with uplr do begin
        s:='';
        move(echotag[1],s[1],21);
        s[0]:=chr(21);
        if (pos(#0,s)>0) then
        s[0]:=chr(pos(#0,s)-1);
        numboards:=filesize(bf)-1;
        mbnum:=0;
        if not(upl_inactive in uplr.msg_attr) then
        while (mbnum<=numboards) do begin
                seek(bf,mbnum);
                read(bf,memboard);
                if allcaps(copy(s,1,20))=allcaps(copy(memboard.nettagname,1,20)) then begin
                if (mbopened) then Mbclose;
                MbOpenCreate;
                if (mbopened) then begin
                        case memboard.mbtype of
                                0:CurrentMSG^.SetMailType(mmtNormal);
                                1:CurrentMSG^.SetMailType(mmtEchoMail);
                                2:CurrentMSG^.SetMailType(mmtNetMail);
                                3:CurrentMSG^.SetMailType(mmtNetMail);
                        end;
                        CurrentMSG^.StartNewMSG;
                        if (memboard.mbtype=3) and (memboard.gateway<>0) then
                        begin
        addr2.zone:=fidor.address[ir.gateways[memboard.gateway].fromaddress].zone;
        addr2.net:=fidor.address[ir.gateways[memboard.gateway].fromaddress].net;
        addr2.node:=fidor.address[ir.gateways[memboard.gateway].fromaddress].node;
        addr2.point:=fidor.address[ir.gateways[memboard.gateway].fromaddress].point;
        CurrentMSG^.SetOrig(addr2);
        addr.zone:=ir.gateways[memboard.gateway].toaddress.zone;
        addr.net:=ir.gateways[memboard.gateway].toaddress.net;
        addr.node:=ir.gateways[memboard.gateway].toaddress.node;
        addr.point:=ir.gateways[memboard.gateway].toaddress.point;
        CurrentMSG^.SetDest(addr);
                        end;

	add:=0;
        if (memboard.mbtype in [1..3]) then
        if (memboard.mbtype in [1,3]) then begin
        x:=1;
	repeat
                if (memboard.address[x]) then add:=x;
                inc(x);
	until ((add>0) or (x=31));
	if (add=0) then add:=1;
        addr2.zone:=fidor.address[add].zone;
        addr2.net:=fidor.address[add].net;
        addr2.node:=fidor.address[add].node;
        addr2.point:=fidor.address[add].point;
        CurrentMSG^.SetOrig(addr2);
        end else begin
        x:=1;
	repeat
                if (memboard.address[x]) then
                        if (fidor.address[x].zone=uplr.destzone) then add:=x;
                inc(x);
	until ((add>0) or (x=31));
	if (add=0) then add:=1;
        setnetflags;
        addr2.zone:=fidor.address[add].zone;
        addr2.net:=fidor.address[add].net;
        addr2.node:=fidor.address[add].node;
        addr2.point:=fidor.address[add].point;
        CurrentMSG^.SetOrig(addr2);
        addr.zone:=uplr.destzone;
        addr.net:=uplr.destnet;
        addr.node:=uplr.destnode;
        addr.point:=uplr.destpoint;
        CurrentMSG^.SetDest(addr);
        end;

                        s:='';
                        move(mfrom[1],s[1],36);
                        s[0]:=chr(36);
                        if (pos(#0,s)>0) then
                        s[0]:=chr(pos(#0,s)-1);
                        CurrentMSG^.SetFrom(s);
                        ivwrite(gstring(1950));
                        ivwriteln(copy(memboard.name,1,52)+' %150%('+memboard.nettagname+'%150%)');
                        ivwrite(gstring(1951));
                        ivwrite(s);
                        if (memboard.mbtype=2) then ivwriteln(' ('+addrstr(addr2)+')')
                        else ivwriteln('');
                        s:='';
                        if (memboard.mbtype in [1..3]) then begin
                        move(net_dest[1],s[1],100);
                        s[0]:=chr(100);
                        if (pos(#0,s)>0) then
                        s[0]:=chr(pos(#0,s)-1);
                        network_to:=s;
                        end;
                        if (memboard.mbtype=3) then begin
                        if (memboard.gateway<>0) then begin
                        s:=ir.gateways[memboard.gateway].toname;
                        end else s:='UUCP';
                        CurrentMSG^.SetTo(s);
                        end else begin
                        move(mto[1],s[1],36);
                        s[0]:=chr(36);
                        if (pos(#0,s)>0) then
                        s[0]:=chr(pos(#0,s)-1);
                        CurrentMSG^.SetTo(s);
                        end;
                        ivwrite(gstring(1952));
                        if (memboard.mbtype<>3) then
                        ivwrite(s)
                        else
                        ivwrite(network_to+' (via '+s+')');
                        if (memboard.mbtype=2) then ivwriteln(' ('+addrstr(addr)+')')
                        else ivwriteln('');
                        s:='';
                        move(subj[1],s[1],72);
                        s[0]:=chr(72);
                        if (pos(#0,s)>0) then
                        s[0]:=chr(pos(#0,s)-1);
                        CurrentMSG^.SetSubj(s);
                        ivwrite(gstring(1953));
                        ivwriteln(s);
                        ivwriteln('');
{                        UnixtoDt(uplr.unix_date,dt);
                        Dosd:=Unix.UnixToDosDate(uplr.unix_date);}
                        s:=GetUnixDate(uplr.unix_date);
                        {formatteddosdate(dosd,'MM/DD/YY');}
{                       s:=rr(cstrn(dt.month),2)+'/'+rr(cstrn(dt.day),2)+
                                '/'+rr(cstrn(dt.year),2);}
                        CurrentMSG^.SetDate(s);
                        s2:=s;
                        s:=GetUnixTime(uplr.unix_date);
{                        s:=formatteddosdate(dosd,'HH:NN:SS');}
{                        s:=rr(cstrn(dt.hour),2)+':'+rr(cstrn(dt.min),2)+
                                ':'+rr(cstrn(dt.sec),2);}
                        CurrentMSG^.Settime(s);
                        CurrentMSG^.SetEcho(TRUE);
                        CurrentMSG^.SetLocal(TRUE);
                        if (upl_private in uplr.msg_attr) then CurrentMSG^.SetPriv(TRUE);
                        if (upl_no_echo in uplr.msg_attr) then CurrentMSG^.SetEcho(FALSE);
                        if (uplr.replyto<>0) then
                        CurrentMSG^.SetRefer(uplr.replyto);
                        s:='';
                        move(filename[1],s[1],13);
                        s[0]:=chr(13);
                        if (pos(#0,s)>0) then
                        s[0]:=chr(pos(#0,s)-1);
                        assign(t,newtemppath+s);
                        {$I-} reset(t); {$I+}
                        if (ioresult=0) then begin
        if (memboard.mbtype in [1..3]) then begin
        currentmsg^.dokludgeln(^A+'MSGID: '+pointedaddrstr(addr2)+' '+lower(hexlong(memboard.msgid)));
        inc(memboard.msgid);
        if (memboard.mbtype in [1,2]) then if (allcaps(copy(network_to,1,6))='REPLY:') then begin
                        CurrentMSG^.dokludgeln(^A+network_to);
                end;
        end;
                                if (registered) then begin
                                        if (expired) then begin
                                                s:='EXPIRED';
                                        end else begin
                                                s:=cstrf2(ivr.serial,value(copy(ivr.regdate,7,2)));
                                        end;
                                end else begin
                                getdatetime(d);
                                if (d.day-syst.ordate.day)>30 then begin
                                        s:='EXPIRED';
                                end else begin
                                        s:='Eval.';
                                end;
                                end;
                                CurrentMSG^.DoKludgeLn(^A+'PID: Nexus '+version+vtpword(ivr.rtype)+' '+s);
                                if (memboard.mbtype=3) and (network_to<>'') then begin
                                CurrentMSG^.DoStringLN('TO: '+network_to);
                                CurrentMSG^.DoStringLN('');
                                end;
                                while not(eof(t)) do begin
                                        readln(t,s);
                                        if (copy(s,1,4)='--- ') then begin
                                                s[1]:='_';
                                                s[2]:='_';
                                                s[3]:='_';
                                        end;
                                        if (copy(s,1,10)=' * Origin:') then begin
                                                s[2]:='+';
                                        end;
                                        if (copy(s,1,1)=^A) then
                                        CurrentMSG^.DoKludgeln(s)
                                        else
                                        CurrentMSG^.Dostringln(s);
                                end;
                                close(t);
                                if (rver<>'') then
                                CurrentMSG^.Dostringln('___ '+rver);
      if (memboard.mbtype in [1,2,3]) then begin
        s:='--- Nexus v'+version+vtpword(ivr.rtype);
                        if not(registered) then begin
                                if (expired) then begin
                                        s:=s+' EXPIRED';
                                end else begin
                                getdatetime(d);
                                if (d.day-syst.ordate.day)>30 then begin
                                        s:=s+' [NR-'+cstr((d.day-syst.ordate.day)-30)+']';
                                end else s:=s+' Eval.'
                                end;
                        end;
                        if (fidor.nodeintear) then
        if (ivr.level=1) and (cnode=3) then s:=s+' [Local]'
                else s:=s+' [node '+cstr(cnode)+']';
        currentmsg^.dostringln(s);
      end;

	s:=' * Origin: '+getorigin+' (';
	s:=s+getaddr(fidor.address[add].zone,fidor.address[add].net,
		fidor.address[add].node,fidor.address[add].point);
                        if (memboard.mbtype=1) then CurrentMSG^.Dostringln(s);
                        if (currentMSG^.writemsg<>0) then begin
                                ivwriteln('%120%Error writing Message!');
                        end else begin
                        inc(thisuser.msgpost);
                        if (memboard.mbtype in [1..3]) then
                                echomail:=TRUE;
                        end;
                        end else begin
                                ivwriteln('%120%Invalid Message.');
                        end;
                        if (mbopened) then MBclose;
                end else begin
                        ivwriteln('%120%Error!');
                end; { else }
                seek(bf,mbnum);
                write(bf,memboard);
                mbnum:=numboards;
                end; { if }
                inc(mbnum);
        end; { while }
        end;
end; { while }
updateuser;
close(f);
close(bf);
purgedir(bslash(FALSE,newtemppath));
end else begin
ivwrite(gstring(1954));
end;
end;

procedure saveuser;
begin
assign(nxwuf,systat.gfilepath+'OMSUSER.DAT');
filemode:=66;
{$I-} reset(nxwuf); {$I+}
if (ioresult<>0) then begin
        writeln('Error reading OMSUSER.DAT');
        endprogram;
end;
{$I-} seek(nxwuf,thisuser.userid); {$I+}
if (ioresult<>0) then begin
        writeln('Error finding User.');
        endprogram;
end;
write(nxwuf,nxwu);
close(nxwuf);
end;

procedure domainmenu;
var c:char;
    abort2,done:boolean;
begin
repeat
c:=#0;
done:=FALSE;
abort2:=FALSE;
abort:=FALSE;
updatestatus;
ivdisplayfile(adrv(systat.afilepath)+'NXWAVE.TXT',abort2);
if (abort2) then ivwrite(gstring(1955));
ivwrite(gstring(1956));
while not(ivkeypressed) do begin timeslice; end;
c:=ivreadchar;
{updatetime;}
ivtextcolor(15);
ivwriteln(upcase(c));
case pos(upcase(c),gstring(1957)) of
        1:domailsetup(TRUE);
        2:begin
                cls;
                BuildScanTable;
                ivwriteln('');
                showbundlelist;
                if not(abort) then
                case askdl of
                        1:begin
                                makebundlelist;
                                if (totalnew2=0) and (nobundleexit) then begin end
                                else begin
                                packmail;
                                if (ivcarrier) and (totalnew<>0) then begin
                                if pynq(gstring(1958)) then
                                        ivwriteln(gstring(1959));
                                        updatelastread;
                                        ivwriteln(gstring(1960));
                                if not(localonly) then purgedir(bslash(FALSE,newdlpath));
                                saveuser;
                                end;
                                end;
                          end;
                        2:begin
                                if (ivcarrier) and (totalnew<>0) then begin
                                if pynq(gstring(1958)) then
                                        ivwriteln(gstring(1959));
                                        updatelastread;
                                        ivwriteln(gstring(1960));
                                end;
                                if not(localonly) then purgedir(bslash(FALSE,newdlpath));
                          end;
                end;
            end;
        3:begin
                unpackmail;
                processUPL;
            end;
        4:begin
                done:=TRUE;
            end;
end;
until (done) or not(ivcarrier);
end;

end.
