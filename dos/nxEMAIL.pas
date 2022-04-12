{$A+,B+,D-,E+,F+,G+,I+,L-,N-,O-,R-,S+,V-}
{$M 65000,0,100000}      { Memory Allocation Sizes }
program netmgr;

uses dos,crt,myio,misc,mkmsgabs,mkopen,mkglobt,mkstring,mkdos,
        fidonet;

const  list:boolean=FALSE;
       imp:boolean=FALSE;
       exp:boolean=FALSE;
       auto:boolean=FALSE;
       nxe:boolean=FALSE;
       ver2:string='0.99';
       build:string='.36.002';
       noshowmci:boolean=FALSE;
       noshowpipe:boolean=FALSE;
       mcimod:byte=0;                { 0 - no modification   1 - L justify   }
                                     { 2 - right justify                     }
       mcichange:integer=0;
       mcipad:string='';

var currentmsg,newmsg:absmsgptr;
    addr,addr2:addrtype;
    s:string;
    showstring:boolean;
    ir:internetrec;
    iff:file of internetrec;
    ni:fidorec;
    lf:file;
    nf:file of fidorec;
    emf:file of nxEMAILREC;
    em:nxEMAILREC;
    abf:file of autobotREC;
    ab:autobotREC;
    oldwind,totalwind:windowrec;
    oldx,oldy:integer;
    gways:array[1..30] of integer;
    x:integer;
    totip,totit:integer;
    totep,totet:integer;
    totlp,totlh,totlt:integer;
    totap,totat:integer;
    vers:string;

function smci3(s2:string;var ok:boolean):string;
var c2:char;
    s:string;
    dum:string[36];
    j,i:integer;
    i2,r:real;
    add:addrtype;
    newmod:byte;
    newchange:integer;
    done:boolean;


begin
  newmod:=0;
  s:='#NEXUS#';
  if (noshowmci) then begin
	smci3:=#28+s2+'|';
	exit;
  end;
  if (allcaps(s2)='NOMCI') then begin
        noshowmci:=TRUE;
        s:='';
  end else
  if (allcaps(s2)='NOCOLOR') then begin
        noshowpipe:=TRUE;
        s:='';
  end else
  if (allcaps(copy(s2,1,2))='PL') and (mcimod=0) then begin
        newmod:=1;
        newchange:=value(copy(s2,3,length(s2)-2));
        if (newchange=0) then newmod:=0;
        s:='';
  end else
  if (allcaps(copy(s2,1,2))='PR') and (mcimod=0) then begin
        newmod:=2;
        newchange:=value(copy(s2,3,length(s2)-2));
        if (newchange=0) then newmod:=0;
        s:='';
  end else
  if (allcaps(copy(s2,1,2))='PC') and (mcimod=0) then begin
        newmod:=3;
        newchange:=value(copy(s2,3,length(s2)-2));
        if (newchange=0) then newmod:=0;
        s:='';
  end else
  if (allcaps(s2)='MSGTO') then begin
        s:=CurrentMSG^.GetFrom;
  end else
  if (allcaps(s2)='MSGFROM') then begin
        s:=ab.rFrom;
  end else
  if (allcaps(s2)='MSGDATE') then begin
        s:=newMSG^.GetDate;
  end else
  if (allcaps(s2)='MSGTIME') then begin
        s:=newMSG^.GetTime;
  end else
  if (allcaps(s2)='MSGSUBJ') then begin
        s:=ab.rSubject;
  end else
  if (allcaps(s2)='BBSNAME') then s:=systat.bbsname else
  if (allcaps(s2)='BBSPHONE') then s:=systat.bbsphone else
  if (allcaps(s2)='SYSOPNAME') then s:=systat.sysopname else
  if (allcaps(s2)='DATE') then s:=date else
  if (allcaps(s2)='TIME') then s:=time else
  if (allcaps(s2)='EP') then begin
  case mcimod of
        1:begin
          s:=mln(mcipad,mcichange);
          mcimod:=0;
          mcichange:=0;
          mcipad:='';
          end;
        2:begin
          s:=mrn(mcipad,mcichange);
          mcimod:=0;
          mcichange:=0;
          mcipad:='';
          end;
        3:begin
          s:=centered(mcipad,mcichange);
          mcimod:=0;
          mcichange:=0;
          mcipad:='';
          end;
        else s:='';
  end;
  end;
  if (newmod<>0) then begin
        mcimod:=newmod;
        mcichange:=newchange;
  end;
  if (s='#NEXUS#') then begin
        s:=#28+s2+'|';
        ok:=FALSE;
  end else ok:=TRUE;
  smci3:=s;
end;

function processMCI(ss:string):string;
var ss3,ss4:string;
    ps1,ps2:integer;
    ok,done:boolean;
begin
  done:=false;
  ss4:='';
  mcipad:='';

  while not(done) do begin  
	ps1:=pos('|',ss);
	if (ps1<>0) then begin
                if (mcimod<>0) then begin
                mcipad:=mcipad+copy(ss,1,ps1-1);
                end else begin
                ss4:=ss4+copy(ss,1,ps1-1);
                end;
                ss:=copy(ss,ps1,length(ss));
                ps1:=1;
                ss[1]:=#28;
		ps2:=pos('|',ss);
                if (ps2<>0) then begin
                        ss3:=smci3(copy(ss,ps1+1,(ps2-ps1)-1),ok);
                        if (ok) then begin
                        if (mcimod<>0) then begin
                        mcipad:=mcipad+ss3;
                        end else begin
                        ss4:=ss4+ss3;
                        end;
                        ss:=copy(ss,ps2+1,length(ss));
                        end else begin
                        if (mcimod<>0) then begin
                        mcipad:=mcipad+copy(ss3,1,length(ss3)-1);
                        end else begin
                        ss4:=ss4+copy(ss3,1,length(ss3)-1);
                        end;
                        ss:=copy(ss,ps2,length(ss));
                        end;
                end;
	end;
	if (pos('|',ss)=0) then done:=TRUE;
  end;
  if (ss<>'') then ss4:=ss4+ss;
  ss:=ss4;
  for ps1:=1 to length(ss) do if ss[ps1]=#28 then ss[ps1]:='|';

  processMCI:=ss;
end;

procedure blockwritestr(var f:file;s:string);
begin
blockwrite(f,s[1],length(s));
end;

procedure opensysopf;
begin
  filemode:=66;
  {$I-} reset(lf,1); {$I+}
  if (ioresult<>0) then begin
    rewrite(lf,1);
  end;
  {$I-} seek(lf,filesize(lf)); {$I+}
  if (ioresult<>0) then begin end;
end;

procedure opensysopf2;
begin
  filemode:=66;
  {$I-} reset(lf,1); {$I+}
  if (ioresult<>0) then begin
    rewrite(lf,1);
  end else begin
  {$I-} seek(lf,filesize(lf)); {$I+}
  if (ioresult<>0) then begin end;
  blockwritestr(lf,#13#10);
  end;
end;

procedure logit(c:char;s:string);
begin
    s:=stripcolor(s);
    filemode:=66;
    opensysopf;
    blockwritestr(lf,c+' '+time+' '+s+#13#10);
    close(lf);
end;

procedure setuplogwindow;
var w8:windowrec;
begin
        setwindow(w8,2,6,78,16,3,0,8,'Processing...',TRUE);
        window(3,8,77,14);
        clrscr;
end;

procedure logit2(c:char;s:string);
var w8:windowrec;
begin
        logit(c,s);
        savescreen(w8,3,9,77,14);
        movewindow(w8,3,8);
        window(3,8,77,14);
        gotoxy(2,7);
        clreol;
        textcolor(3);
        textbackground(0);
        write(c,' ',time,' ',copy(s,1,60));
        window(1,1,80,25);
end;

procedure setuptotals;
begin
setwindow(totalwind,2,18,60,23,3,0,8,'Statistics',TRUE);
textcolor(7);
textbackground(0);
gotoxy(2,1);
write('           Process  Total              Process  Total');
gotoxy(2,2);
write('Import  :                   AUTOBOT :');
gotoxy(2,3);
write('Export  :                   LISTSERV: ');
end;


procedure settotals(row,column,value:integer);
var ox,oy,x1,y1,x2,y2:integer;
begin
ox:=wherex;
oy:=wherey;
x1:=lo(windmin)+1;
y1:=hi(windmin)+1;
x2:=lo(windmax)+1;
y2:=lo(windmax)+1;
window(3,19,77,22);
case column of
        1:begin
              if (row>2) then begin
                gotoxy(41,row-1);
              end else begin
                gotoxy(13,row+1);
              end;
              textcolor(15);
              textbackground(0);
              write(mrn(cstr(value),7));
          end;
        2:begin
              if (row>2) then begin
                gotoxy(50,row-1);
              end else begin
                gotoxy(22,row+1);
              end;
              textcolor(15);
              textbackground(0);
              write(mrn(cstr(value),5));
          end;
end;
window(x1,y1,x2,y2);
gotoxy(ox,oy);
end;

function isinbound(addr,addr2:addrtype; var gw:integer):boolean;
var x:integer;
    found:boolean;
    c:char;
begin
x:=1;
found:=FALSE;
while (x<31) and not(found) do begin
        if ((ir.gateways[x].toaddress.zone=addr.zone) and
           (ir.gateways[x].toaddress.net=addr.net) and
           (ir.gateways[x].toaddress.node=addr.node) and
           (ir.gateways[x].toaddress.point=addr.point))
           and
           ((ni.address[ir.gateways[x].fromaddress].zone=addr2.zone) and
           (ni.address[ir.gateways[x].fromaddress].net=addr2.net) and
           (ni.address[ir.gateways[x].fromaddress].node=addr2.node) and
           (ni.address[ir.gateways[x].fromaddress].point=addr2.point))
           then found:=TRUE else inc(x);
end;
if (found) then gw:=x else gw:=-1;
isinbound:=found;
end;

function nomovename(s:string):boolean;
var t:text;
    s2:string;
    found:boolean;
    lf:file of listservrec;
    ll:listservrec;
begin
        assign(t,adrv(systat.gfilepath)+'NOIMPORT.TXT');
        {$I-} reset(t); {$I+}
        if (ioresult=0) then begin
                found:=FALSE;
                while not(eof(t)) and not(found) do begin
                        readln(t,s2);
                        s2:=stripboth(s2,' ');
                        if (allcaps(s)=allcaps(s2)) then found:=TRUE;
                end;
                close(t);
        end;
        if not(found) then begin
        assign(lf,adrv(systat.gfilepath)+'LISTSERV.DAT');
        {$I-} reset(lf); {$I+}
        if (ioresult=0) then begin
                seek(lf,1);
                while not(eof(lf)) and not(found) do begin
                        read(lf,ll);
                        if (allcaps(ll.trigger)=allcaps(s)) then found:=TRUE;
                end;
                close(lf);
        end;
        end;
        nomovename:=found;
end;

procedure findbases;
var x:integer;
begin
filemode:=66;
assign(bf,adrv(systat.gfilepath)+'MBASES.DAT');
{$I-} reset(bf); {$I+}
if (ioresult<>0) then begin
        writeln('Error opening MBASES.DAT!');
        halt;
end;
for x:=1 to 30 do gways[x]:=-1;
for x:=1 to 30 do begin
        seek(bf,0);
        while not(eof(bf)) do begin
                read(bf,memboard);
                if (memboard.mbtype=3) and (memboard.gateway=x) then
                if (gways[x]=-1) then gways[x]:=filepos(bf)-1;
        end;
end;
close(bf);
end;

function getbasename(x:integer):string;
var s:string;
begin
filemode:=66;
assign(bf,adrv(systat.gfilepath)+'MBASES.DAT');
{$I-} reset(bf); {$I+}
if (ioresult<>0) then begin
        writeln('Error opening MBASES.DAT!');
        halt;
end;
seek(bf,x);
read(bf,memboard);
close(bf);
case memboard.messagetype of
        1:s:='S';
        2:s:='J';
        3:s:='F';
end;
s:=s+memboard.msgpath;
if (s[length(s)]<>'\') then s:=s+'\';
if (memboard.messagetype<>3) then s:=s+memboard.filename;
getbasename:=s;
end;

    function getaddr(zone,net,node,point:integer):string;
    var s:string;
    begin
      s:=cstr(zone)+':'+cstr(net)+'/'+cstr(node)+'.'+cstr(point);
      getaddr:=s;
    end;

  function getaddressnumber:byte;
  var x2:byte;
      dn2:boolean;
  begin
    x2:=1;
    dn2:=FALSE;
    while not(dn2) and (x2<=30) do begin
            if (memboard.address[x2]) then dn2:=TRUE else inc(x2);
    end;
    if not(dn2) then x2:=1;
    getaddressnumber:=x2;
  end;

  function getorigin:string;
  var s:astr;
      x2:byte;
      dn2:boolean;
  begin
    if (ni.origins[memboard.origin]<>'') then s:=ni.origins[memboard.origin]
      else if (ni.origins[1]<>'') then s:=ni.origins[1]
	else s:=copy(stripcolor(systat.bbsname),1,50);
    while (copy(s,length(s),1)=' ') do
      s:=copy(s,1,length(s)-1);
    x2:=getaddressnumber;
    s:=s+' ('+getaddr(ni.address[x2].zone,ni.address[x2].net,
                 ni.address[x2].node,ni.address[x2].point);
    s:=' * Origin: '+s+')';
    getorigin:=s;
  end;


function findtimezone(x2:integer):string;
var x:integer;
    s:string;
begin
case x2 of
        1:x:=-12;
        2:x:=-11;
        3:x:=-10;
        4:x:=-9;
        5:x:=-8;
        6,7:x:=-7;
        8,9,10:x:=-6;
        11,12,13:x:=-5;
        14,15:x:=-4;
        16,17,18:x:=-3;
        19:x:=-2;
        20:x:=-1;
        21,22:x:=0;
        23,24,25,26:x:=1;
        27,28,29,30,31:x:=2;
        32,33,34:x:=3;
        35,36:x:=4;
        37,38:x:=5;
        39:x:=6;
        40:x:=7;
        41,42:x:=8;
        43,44,45:x:=9;
        46,47,48:x:=10;
        49:x:=11;
        50,51:x:=12;
end;
s:='UTC';
if (x<0) then s:=s+'-' else s:=s+'+';
s:=s+cstr(abs(x));
findtimezone:=s;
end;

procedure importmail;
var gw:integer;
    gwname:string;
    w1,w2:windowrec;
begin
settotals(1,1,totip);
settotals(1,2,totit);
showstring:=TRUE;
logit2('+','Scanning inbound NETMAIL ('+allcaps(systat.netmailpath)+')');
if (openorcreatemsgarea(currentmsg,'F'+systat.netmailpath)) then begin
currentmsg^.seekfirst(1);
while (currentmsg^.seekfound) do begin
        inc(totit);
        currentmsg^.msgstartup;
        currentmsg^.GetOrig(addr);
        currentmsg^.GetDest(addr2);
        s:=currentmsg^.getto;
        if (isinbound(addr,addr2,gw)) and not(nomovename(s)) and
        not(currentMSG^.islocal) and not(currentmsg^.isrcvd) then
        begin
        gwname:=getbasename(gways[gw]);
        if (gwname<>'') then
        if (openorcreatemsgarea(newmsg,gwname)) then begin
        inc(totip);
        logit2('+','IMPORT: Importing message to '+stripcolor(memboard.name));
        logit2('+','Message from   : '+Currentmsg^.GetFrom);
        logit2('+','Message to     : '+currentmsg^.Getto);
        logit2('+','Message subject: '+currentmsg^.Getsubj);
                        case memboard.mbtype of
                                0:newMSG^.SetMailType(mmtNormal);
                                1:newMSG^.SetMailType(mmtEchoMail);
                                2:newMSG^.SetMailType(mmtNetMail);
                                3:newMSG^.SetMailType(mmtNetMail);
                        end;
        newmsg^.Startnewmsg;
        newmsg^.SetTo(CurrentMSG^.GetTo);
        newmsg^.SetFrom(CurrentMSG^.GetFrom);
        newmsg^.SetSubj(CurrentMSG^.GetSubj);
        newmsg^.SetDate(CurrentMSG^.GetDate);
        newmsg^.SetTime(CurrentMSG^.GetTime);
        newmsg^.SetOrig(addr);
        newmsg^.SetDest(addr2);
        newmsg^.setrefer(0);
        newmsg^.setseealso(0);
        newmsg^.setcost(currentmsg^.getcost);
        newmsg^.setnextseealso(0);
          newmsg^.SetLocal(CurrentMSG^.IsLocal);
          newmsg^.SetHold(CurrentMSG^.IsHold);
          newmsg^.SetRcvd(CurrentMSG^.IsRcvd);
          newmsg^.setpriv(CurrentMSG^.IsPriv);
          newmsg^.SetCrash(CurrentMSG^.IsCrash);
          newmsg^.SetDirect(CurrentMSG^.IsDirect);
          newmsg^.SetKillSent(CurrentMSG^.IsKillSent);
          newmsg^.SetSent(CurrentMSG^.IsSent);
          newmsg^.SetFattach(CurrentMSG^.IsFattach);
          newmsg^.SetReqRct(CurrentMSG^.IsReqRct);
          newmsg^.SetReqAud(currentMSG^.IsReqAud);
          newmsg^.SetRetRct(currentMsg^.IsRetRct);
          newmsg^.SetFileReq(currentMSG^.IsFileReq);
          CurrentMSG^.MsgTxtStartup;
          while not(CurrentMSG^.EOM) do begin
             newmsg^.DoChar(CurrentMSG^.GetChar);
          end;
          newmsg^.doKludgeln(^A+'Forwarded by nxEMAIL v'+vers+' '+getaddr(ni.address[1].zone,ni.address[1].net,
          ni.address[1].node,ni.address[1].point)+', '+formatteddosdate(getdosdate,'DD NNN YY')+'  '+time);
          newmsg^.doKludgeln(^A+'Via '+getaddr(addr2.zone,addr2.net,addr2.node,addr2.point)+' @'+
          formatteddosdate(getdosdate,'YYYYMMDD.HHIISS')+'.'+findtimezone(systat.timezone)+' nxEMAIL v'+vers);
          if (newmsg^.Writemsg<>0) then begin
                logit2('!','ERROR: Error saving message!');
          end else
                CurrentMSG^.DeleteMSG;
          if (closemsgarea(newmsg)) then begin end;
         end;
        end;
        settotals(1,1,totip);
        settotals(1,2,totit);
        CurrentMSG^.SeekNext;
end;
if (closemsgarea(currentmsg)) then begin end;
end;
end;

function isoutbound(addr,addr2:addrtype; var gw:integer):boolean;
var found:boolean;
    c:char;
begin
found:=FALSE;
        if ((ir.gateways[gw].toaddress.zone=addr.zone) and
           (ir.gateways[gw].toaddress.net=addr.net) and
           (ir.gateways[gw].toaddress.node=addr.node) and
           (ir.gateways[gw].toaddress.point=addr.point))
           and
           ((ni.address[ir.gateways[gw].fromaddress].zone=addr2.zone) and
           (ni.address[ir.gateways[gw].fromaddress].net=addr2.net) and
           (ni.address[ir.gateways[gw].fromaddress].node=addr2.node) and
           (ni.address[ir.gateways[gw].fromaddress].point=addr2.point))
           then found:=TRUE;
isoutbound:=found;
end;


procedure exportmail;
var gw:integer;
    w1,w2:windowrec;
    s2:string;

        function getpath:string;
        var s:string;
        begin
        case memboard.messagetype of
                1:s:='S';
                2:s:='J';
                3:s:='F';
        end;
        s:=s+memboard.msgpath;
        if (s[length(s)]<>'\') then s:=s+'\';
        if (memboard.messagetype<>3) then s:=s+memboard.filename;
        getpath:=s;
        end;

begin
settotals(2,1,totep);
settotals(2,2,totet);
filemode:=66;
assign(bf,adrv(systat.gfilepath)+'MBASES.DAT');
{$I-} reset(bf); {$I+}
if (ioresult<>0) then begin
        writeln('Error opening MBASES.DAT!');
        halt;
end;
while not(eof(bf)) do begin
read(bf,memboard);
if (memboard.mbtype=3) then begin
showstring:=TRUE;
logit2('-','Scanning outbound from '+stripcolor(memboard.name));
if (openorcreatemsgarea(currentmsg,getpath)) then begin
currentmsg^.seekfirst(1);
while (currentmsg^.seekfound) do begin
        inc(totet);
        currentmsg^.msgstartup;
        currentmsg^.GetOrig(addr);
        currentmsg^.GetDest(addr2);
        s:=currentmsg^.getto;
        gw:=memboard.gateway;
        if (isoutbound(addr2,addr,gw)) and not(CurrentMSG^.IsSent) and
        (CurrentMSG^.Islocal)
        then begin
        if (openorcreatemsgarea(newmsg,'F'+systat.netmailpath)) then begin
        inc(totep);
        if (pos('@',CurrentMSG^.GetTo)=0) then begin
        CurrentMSG^.MsgTxtStartup;
        s2:='';
        while (allcaps(copy(s2,1,3))<>'TO:') and not(CurrentMSG^.EOM) do begin
                s2:=CurrentMSG^.GetString(80);
                while (CurrentMSG^.WasWrap) and not(currentmsg^.EOM) and (length(s2)<75) do
                begin
                       s2:=s2+' '+CurrentMSG^.GetString(78-Length(s2));
                end;
        end;
        s2:=copy(s2,5,length(s2)-4);
        end else begin
                s2:=CurrentMSG^.GetTo;
        end;
        logit2('-','EXPORT: Exporting message to NETMAIL ('+allcaps(systat.netmailpath)+')');
        logit2('-','Message from   : '+currentmsg^.Getfrom);
        logit2('-','Message to     : '+currentmsg^.getto);
        logit2('-','Message subject: '+currentmsg^.Getsubj);
        newMSG^.SetMailType(mmtNetMail);
        newmsg^.Startnewmsg;
        newmsg^.SetTo(CurrentMSG^.GetTo);
        newmsg^.SetFrom(CurrentMSG^.GetFrom);
        newmsg^.SetSubj(CurrentMSG^.GetSubj);
        newmsg^.SetDate(CurrentMSG^.GetDate);
        newmsg^.SetTime(CurrentMSG^.GetTime);
        newmsg^.SetOrig(addr);
        newmsg^.SetDest(addr2);
        newmsg^.setrefer(0);
        newmsg^.setseealso(0);
        newmsg^.setcost(currentmsg^.getcost);
        newmsg^.setnextseealso(0);
          newmsg^.SetLocal(CurrentMSG^.IsLocal);
          newmsg^.SetHold(CurrentMSG^.IsHold);
          newmsg^.SetRcvd(CurrentMSG^.IsRcvd);
          newmsg^.setpriv(CurrentMSG^.IsPriv);
          newmsg^.SetCrash(CurrentMSG^.IsCrash);
          newmsg^.SetDirect(CurrentMSG^.IsDirect);
          newmsg^.SetKillSent(TRUE);
          CurrentMSG^.SetSent(TRUE);
          CurrentMSG^.RewriteHdr;
          newmsg^.SetSent(FALSE);
          newmsg^.SetFattach(CurrentMSG^.IsFattach);
          newmsg^.SetReqRct(CurrentMSG^.IsReqRct);
          newmsg^.SetReqAud(currentMSG^.IsReqAud);
          newmsg^.SetRetRct(currentMsg^.IsRetRct);
          newmsg^.SetFileReq(currentMSG^.IsFileReq);
        CurrentMSG^.MsgTxtStartup;
        while not(CurrentMSG^.EOM) do begin
             newmsg^.DoChar(CurrentMSG^.GetChar);
        end;
        if (newmsg^.Writemsg<>0) then begin
                logit2('!','ERROR: Error saving message!');
        end else begin
                if (currentmsg^.iskillsent) then currentmsg^.deletemsg;
        end;
        if (closemsgarea(newmsg)) then begin end;
        end;
        end;
        settotals(2,1,totep);
        settotals(2,2,totet);
        CurrentMSG^.SeekNext;
end;
if (closemsgarea(currentmsg)) then begin end;
end;
end;
end;
close(bf);
end;

function readautobot(tn:integer):boolean;
begin
assign(abf,adrv(systat.gfilepath)+'AUTOBOT.DAT');
{$I-} reset(abf); {$I+}
if (ioresult<>0) then begin
        readautobot:=FALSE;
        exit;
end;
if (tn>filesize(abf)-1) then begin
        readautobot:=FALSE;
        exit;
end;
seek(abf,tn);
read(abf,ab);
close(abf);
end;

function istrigger(s:string):integer;
var result:integer;
begin
result:=-1;
assign(abf,adrv(systat.gfilepath)+'AUTOBOT.DAT');
{$I-} reset(abf); {$I+}
if (ioresult<>0) then begin
        istrigger:=-1;
        exit;
end;
seek(abf,1);
while not(eof(abf)) and (result=-1) do begin
        read(abf,ab);
        if (allcaps(s)=allcaps(ab.trigger)) then begin
                result:=filepos(abf)-1;
        end;
end;
close(abf);
istrigger:=result;
end;

procedure autobot;
var gw:integer;
    gwname:string;
    w1,w2:windowrec;
    trnum:integer;
    s2,s3:string;
    d:datetimerec;
    tf:text;
begin
settotals(3,1,totap);
settotals(3,2,totat);
showstring:=TRUE;
logit2('+','Scanning inbound NETMAIL ('+allcaps(systat.netmailpath)+')');
if (openorcreatemsgarea(currentmsg,'F'+systat.netmailpath)) then begin
currentmsg^.seekfirst(1);
while (currentmsg^.seekfound) do begin
        inc(totat);
        currentmsg^.msgstartup;
        currentmsg^.GetOrig(addr);
        currentmsg^.GetDest(addr2);
        s:=currentmsg^.getto;
        trnum:=istrigger(s);
        if (isinbound(addr,addr2,gw)) and not(nomovename(s)) and
        not(currentMSG^.islocal) and not(currentmsg^.isrcvd) and
        (trnum<>-1) then begin
        if not(readautobot(trnum)) then exit;
        if not(exist(ab.response)) then exit;
        gwname:=getbasename(gways[gw]);
        if (gwname<>'') then
        if (openorcreatemsgarea(newmsg,gwname)) then begin
        inc(totap);
        logit2('@','AUTOBOT: Received trigger '+allcaps(s));
        logit2('+','Creating message in e-mail base: '+stripcolor(memboard.name));
        logit2('+','Message to     : '+currentmsg^.getfrom);
        logit2('+','Response title : '+ab.name);
                        case memboard.mbtype of
                                0:newMSG^.SetMailType(mmtNormal);
                                1:newMSG^.SetMailType(mmtEchoMail);
                                2:newMSG^.SetMailType(mmtNetMail);
                                3:newMSG^.SetMailType(mmtNetMail);
                        end;
        newmsg^.Startnewmsg;
        newmsg^.SetTo(ir.gateways[gw].toname);
        newmsg^.SetFrom(ab.rFrom);
        newmsg^.SetSubj(ab.rSubject);
        newmsg^.SetDate(date);
        newmsg^.SetTime(time);
        addr.zone:=ni.address[ir.gateways[gw].fromaddress].zone;
        addr.net:=ni.address[ir.gateways[gw].fromaddress].net;
        addr.node:=ni.address[ir.gateways[gw].fromaddress].node;
        addr.point:=ni.address[ir.gateways[gw].fromaddress].point;
        addr2.zone:=ir.gateways[gw].toaddress.zone;
        addr2.net:=ir.gateways[gw].toaddress.net;
        addr2.node:=ir.gateways[gw].toaddress.node;
        addr2.point:=ir.gateways[gw].toaddress.point;
        newmsg^.SetOrig(addr);
        newmsg^.SetDest(addr2);
        newmsg^.setrefer(0);
        newmsg^.setseealso(0);
        newmsg^.setcost(currentmsg^.getcost);
        newmsg^.setnextseealso(0);
          newmsg^.SetLocal(TRUE);
          newmsg^.setpriv(TRUE);
          newmsg^.SetKillSent(TRUE);
          newmsg^.dokludgeln(^A+'MSGID: '+pointedaddrstr(addr)+' '+lower(hexlong(getdosdate)));
          s2:=currentmsg^.GetMSGID;
          if (s2<>'') then newmsg^.DoKludgeln(^A+'REPLY: '+s2);
          newmsg^.doKludgeln(^A+'PID: nxEMAIL v'+ver2);
          newmsg^.doStringLn('TO: '+currentmsg^.GetFrom);
          newmsg^.dostringln('');
          assign(tf,ab.response);
          {$I-} reset(tf); {$I+}
          if (ioresult=0) then begin
                while not(eof(tf)) do begin
                        readln(tf,s2);
                        s2:=processMCI(s2);
                        newmsg^.dostringln(s2);
                end;
                close(tf);
                newmsg^.dostringln('');
                s3:='--- nxEMAIL/DOS v'+ver2;
                newmsg^.dostringln(s3);
                if (newmsg^.Writemsg<>0) then begin
                        logit2('!','ERROR: Error saving message!');
                end else
                        CurrentMSG^.DeleteMSG;
          end else begin
                logit2('!','ERROR: Error reading '+allcaps(ab.response)+'!');
          end;
          if (closemsgarea(newmsg)) then begin end;
         end;
        end;
        settotals(3,1,totap);
        settotals(3,2,totat);
        CurrentMSG^.SeekNext;
end;
if (closemsgarea(currentmsg)) then begin end;
end;
end;

procedure listserver;
var gw:integer;
    gwname:string;
    w1,w2:windowrec;
    trnum:integer;
    s2,s3:string;
    d:datetimerec;
    tf:text;
    lf:file of listservrec;
    ll:listservrec;

function isltrigger(s:string):integer;
var result:integer;
begin
result:=-1;
assign(lf,adrv(systat.gfilepath)+'LISTSERV.DAT');
{$I-} reset(lf); {$I+}
if (ioresult<>0) then begin
        isltrigger:=-1;
        exit;
end;
seek(lf,1);
while not(eof(lf)) and (result=-1) do begin
        read(lf,ll);
        if (allcaps(s)=allcaps(ll.trigger)) then begin
                result:=filepos(lf)-1;
        end;
end;
close(lf);
isltrigger:=result;
end;

function isltrigger2(s:string):integer;
var result:integer;
begin
result:=-1;
assign(lf,adrv(systat.gfilepath)+'LISTSERV.DAT');
{$I-} reset(lf); {$I+}
if (ioresult<>0) then begin
        isltrigger2:=-1;
        exit;
end;
seek(lf,1);
while not(eof(lf)) and (result=-1) do begin
        read(lf,ll);
        if (allcaps(s)=allcaps(ll.trigger)) then begin
                result:=ll.userid;
        end;
end;
close(lf);
isltrigger2:=result;
end;

function readlistserv(tn:integer):boolean;
begin
assign(lf,adrv(systat.gfilepath)+'LISTSERV.DAT');
{$I-} reset(lf); {$I+}
if (ioresult<>0) then begin
        readlistserv:=FALSE;
        exit;
end;
if (tn>filesize(lf)-1) then begin
        close(lf);
        readlistserv:=FALSE;
        exit;
end;
seek(lf,tn);
read(lf,ll);
close(lf);
end;

    function getbasenumber(ll:longint):longint;
    var bif:file of baseididx;
        bi:baseididx;
    begin
        assign(bif,adrv(systat.gfilepath)+'MBASEID.IDX');
        {$I-} reset(bif); {$I+}
        if (ioresult<>0) then begin
                logit2('!','ERROR: Error reading MBASEID.IDX!');
                getbasenumber:=-1;
                exit;
        end;
        seek(bif,ll);
        read(bif,bi);
        if (bi.baseid=ll) then begin
                getbasenumber:=bi.offset;
        end else begin
                getbasenumber:=-1;
        end;
        close(bif);
    end;

function notonlist:boolean;
var ttf:text;
    ss:string;
    tempbool:boolean;
begin
assign(ttf,adrv(systat.gfilepath)+'LIST'+cstrn(ll.userid)+'.USR');
{$I-} reset(ttf); {$I+}
if (ioresult<>0) then begin
        notonlist:=TRUE;
        exit;
end;
tempbool:=TRUE;
while not(eof(ttf)) and (tempbool) do begin
        readln(ttf,ss);
        if (allcaps(ss)=allcaps(currentmsg^.getfrom)) then tempbool:=FALSE;
end;
notonlist:=tempbool;
close(ttf);
end;


procedure exportfromecho;
var lastread,himsg:longint;
    gwname2:string;
    tf,tf2:text;
    stripit:boolean;
    i2:integer;
    outname:string;
    basename:string;
    newmsg2:boolean;
begin
trnum:=1;
logit2('*','Scanning local storage bases for outbound messages...');
while (readlistserv(trnum)) do begin
logit2('*','Scanning list: '+stripcolor(ll.name));
gwname:=getbasename(getbasenumber(ll.mbaseid));
basename:=stripcolor(memboard.name);
gwname2:=getbasename(gways[ll.gateway]);
assign(tf2,adrv(systat.gfilepath)+'LIST'+cstrn(ll.userid)+'.USR');
{$I-} reset(tf2); {$I+}
if (ioresult<>0) then exit;
close(tf2);
if (openorcreatemsgarea(currentmsg,gwname)) then begin
        lastread:=currentmsg^.GetLastRead(ll.userid);
        himsg:=currentmsg^.GetHighMsgNum;
        currentmsg^.seekfirst(lastread+1);
        while (currentmsg^.seekfound) do begin
                if (openorcreatemsgarea(newmsg,gwname2)) then begin
                        {$I-} reset(tf2); {$I+}
                        if (ioresult<>0) then exit;
                        newmsg2:=TRUE;
                        while (outname<>'') and not(eof(tf2)) do begin
                        readln(tf2,outname);
                        currentmsg^.msgstartup;
                        if (newmsg2) then begin
                        logit2('*','Exporting message #'+cstr(currentmsg^.getmsgnum)+' from '+basename);
                        newmsg2:=FALSE;
                        end;
                        if (allcaps(outname)<>allcaps(currentmsg^.getfrom)) then begin
                        case memboard.mbtype of
                                0:newMSG^.SetMailType(mmtNormal);
                                1:newMSG^.SetMailType(mmtEchoMail);
                                2:newMSG^.SetMailType(mmtNetMail);
                                3:newMSG^.SetMailType(mmtNetMail);
                        end;
                        logit2('+','Exporting to '+outname);
                        newmsg^.Startnewmsg;
                        if (ir.gateways[ll.gateway].gatewaytype=0) then
                                newmsg^.SetTo(ir.gateways[ll.gateway].toname)
                        else
                                newmsg^.SetTo(outname);
                        newmsg^.SetFrom(currentmsg^.Getfrom);
                        newmsg^.SetSubj(currentmsg^.getsubj);
                        newmsg^.SetDate(currentmsg^.getdate);
                        newmsg^.SetTime(currentmsg^.gettime);
                        addr.zone:=ni.address[ir.gateways[ll.gateway].fromaddress].zone;
                        addr.net:=ni.address[ir.gateways[ll.gateway].fromaddress].net;
                        addr.node:=ni.address[ir.gateways[ll.gateway].fromaddress].node;
                        addr.point:=ni.address[ir.gateways[ll.gateway].fromaddress].point;
                        addr2.zone:=ir.gateways[ll.gateway].toaddress.zone;
                        addr2.net:=ir.gateways[ll.gateway].toaddress.net;
                        addr2.node:=ir.gateways[ll.gateway].toaddress.node;
                        addr2.point:=ir.gateways[ll.gateway].toaddress.point;
                        newmsg^.SetOrig(addr);
                        newmsg^.SetDest(addr2);
                        newmsg^.setrefer(0);
                        newmsg^.setseealso(0);
                        newmsg^.setcost(currentmsg^.getcost);
                        newmsg^.setnextseealso(0);
                        newmsg^.SetLocal(TRUE);
                        newmsg^.setpriv(TRUE);
                        newmsg^.SetKillSent(TRUE);
                        newmsg^.dokludgeln(^A+'MSGID: '+pointedaddrstr(addr)+' '+lower(hexlong(getdosdate)));
                        newmsg^.doKludgeln(^A+'PID: nxEMAIL v'+ver2);
                        if (ir.gateways[ll.gateway].gatewaytype=0) then begin
                                newmsg^.doStringLn('TO: '+outname);
                        end;
                        newmsg^.dostringln('Reply-To: '+currentmsg^.getfrom+' <'+ll.replyaddr+'>');
                        newmsg^.dostringln('Sender: '+currentmsg^.getfrom+' <'+ll.replyaddr+'>');
                        newmsg^.dostringln('');
                        currentmsg^.msgtxtstartup;
                        while not(currentmsg^.EOM) do begin
                                s2:=currentmsg^.GetString(78);
                                stripit:=false;
                                if (allcaps(copy(s2,1,3))='TO:') then begin
                                        s2:='~'+s2;
                                end;
                                if (copy(s2,1,4)='--- ') or (s2='---') then begin
                                        s2[2]:='!';
                                end;
                                if (copy(s2,1,10)=' * Origin:') then begin
                                        s2[2]:='!';
                                        if (mbsorigin in memboard.mbstat) then stripit:=true;
                                end;
                                if (copy(s2,1,1)=#1) then stripit:=true;
                                if (copy(s2,1,8)='SEEN-BY:') then stripit:=true;
                                i2:=pos(#12,s2);
                                while (i2<>0) do begin
                                        s2:=copy(s2,1,i2-1)+copy(s2,i2+1,length(s2)-i2);
                                        i2:=pos(#12,s2);
                                end;
                                if not(stripit) then newmsg^.DoStringLn(s2);
                        end;
                        newmsg^.dostringln('');
                        if (pos('@',currentmsg^.getfrom)=0) then begin
                                if (ll.footer<>'') then begin
                                assign(tf,ll.footer);
                                {$I-} reset(tf); {$I+}
                                if (ioresult=0) then begin
                                while not(eof(tf)) do begin
                                        readln(tf,s2);
                                        s2:=processMCI(s2);
                                        newmsg^.dostringln(s2);
                                end;
                                close(tf);
                                end;
                                end;
                        end;
                        newmsg^.dostringln('');
                        s3:='--- nxEMAIL/DOS v'+ver2;
                        newmsg^.dostringln(s3);
                        if (newmsg^.Writemsg<>0) then begin
                                logit2('!','ERROR: Error saving message!');
                        end;
                        end;
                        end;
                        close(tf2);
                end;
                currentmsg^.seeknext;
                if (closemsgarea(newmsg)) then begin end;
        end;
end;
currentmsg^.SetLastRead(ll.userid,himsg);
if (closemsgarea(currentmsg)) then begin end;
inc(trnum);
end;
end;

procedure posttolist;
var stripit:boolean;
    tf2:text;
    i2:integer;
begin
        if not(readlistserv(trnum)) then exit;
        if (notonlist) then begin
                gwname:=getbasename(gways[gw]);
                if (gwname<>'') then
                if (openorcreatemsgarea(newmsg,gwname)) then begin
                        logit2('!','LISTSERV: Bouncing unauthorized message.');
                        logit2('!','Message from   : '+currentmsg^.getfrom);
                        logit2('!','Message subject: '+currentmsg^.getsubj);
                        inc(totlp);
                        case memboard.mbtype of
                                0:newMSG^.SetMailType(mmtNormal);
                                1:newMSG^.SetMailType(mmtEchoMail);
                                2:newMSG^.SetMailType(mmtNetMail);
                                3:newMSG^.SetMailType(mmtNetMail);
                        end;
                        newmsg^.Startnewmsg;
                        if (ir.gateways[gw].gatewaytype=0) then begin
                                newmsg^.SetTo(ir.gateways[gw].toname);
                        end else begin
                                newmsg^.SetTo(currentmsg^.Getfrom);
                        end;
                        newmsg^.SetFrom('listserv');
                        newmsg^.SetSubj('Bounced message');
                        newmsg^.SetDate(date);
                        newmsg^.SetTime(time);
                        addr.zone:=ni.address[ir.gateways[gw].fromaddress].zone;
                        addr.net:=ni.address[ir.gateways[gw].fromaddress].net;
                        addr.node:=ni.address[ir.gateways[gw].fromaddress].node;
                        addr.point:=ni.address[ir.gateways[gw].fromaddress].point;
                        addr2.zone:=ir.gateways[gw].toaddress.zone;
                        addr2.net:=ir.gateways[gw].toaddress.net;
                        addr2.node:=ir.gateways[gw].toaddress.node;
                        addr2.point:=ir.gateways[gw].toaddress.point;
                        newmsg^.SetOrig(addr);
                        newmsg^.SetDest(addr2);
                        newmsg^.setrefer(0);
                        newmsg^.setseealso(0);
                        newmsg^.setcost(currentmsg^.getcost);
                        newmsg^.setnextseealso(0);
                        newmsg^.SetLocal(TRUE);
                        newmsg^.setpriv(TRUE);
                        newmsg^.SetKillSent(TRUE);
                        newmsg^.dokludgeln(^A+'MSGID: '+pointedaddrstr(addr)+' '+lower(hexlong(getdosdate)));
                        s2:=currentmsg^.GetMSGID;
                        if (s2<>'') then newmsg^.DoKludgeln(^A+'REPLY: '+s2);
                        newmsg^.doKludgeln(^A+'PID: nxEMAIL v'+ver2);
                        newmsg^.doStringLn('TO: '+currentmsg^.GetFrom);
                        if (ir.gateways[gw].gatewaytype=0) then begin
                                newmsg^.doStringLn('TO: '+currentmsg^.GetFrom);
                                newmsg^.dostringln('');
                        end;
                        newmsg^.dostringln('');
                        newmsg^.dostringln('Re: Your message to the '+stripcolor(ll.name)+' list.');
                        newmsg^.dostringln('');
                        newmsg^.dostringln('Your message has been bounced because you are not on this list.');
                        newmsg^.dostringln('');
                        newmsg^.dostringln('===============================================================================');
                        while not(CurrentMSG^.EOM) do begin
                                s2:=CurrentMSG^.GetString(78);
                                stripit:=false;
                                if (copy(s2,1,4)='--- ') or (s2='---') then begin
                                        s2[2]:='!';
                                end;
                                if (copy(s2,1,10)=' * Origin:') then begin
                                        s2[2]:='!';
                                        if (mbsorigin in memboard.mbstat) then stripit:=true;
                                end;
                                if (copy(s2,1,1)=#1) then stripit:=true;
                                if (copy(s2,1,8)='SEEN-BY:') then stripit:=true;
                                i2:=pos(#12,s2);
                                while (i2<>0) do begin
                                        s2:=copy(s2,1,i2-1)+copy(s2,i2+1,length(s2)-i2);
                                        i2:=pos(#12,s2);
                                end;
                                if not(stripit) then
                                        newmsg^.DoStringLn(s2);
                        end;
                        newmsg^.dostringln('===============================================================================');
                        newmsg^.dostringln('');
                        s3:='--- nxEMAIL/DOS v'+ver2;
                        newmsg^.dostringln(s3);
                        if (newmsg^.Writemsg<>0) then begin
                                logit2('!','ERROR: Error saving message!');
                        end else
                                CurrentMSG^.DeleteMSG;
                        end;
        end else begin
        gwname:=getbasename(getbasenumber(ll.mbaseid));
        if (gwname<>'') then
        if (openorcreatemsgarea(newmsg,gwname)) then begin
        inc(totlp);
        logit2('*','LISTSERV: New message to list '+allcaps(ll.name));
        logit2('+','Message to      : '+CurrentMSG^.Getto);
        logit2('+','Message from    : '+CurrentMSG^.Getfrom);
        logit2('+','Message subject : '+CurrentMSG^.GetSubj);
        case memboard.mbtype of
              0:newMSG^.SetMailType(mmtNormal);
              1:newMSG^.SetMailType(mmtEchoMail);
              2:newMSG^.SetMailType(mmtNetMail);
              3:newMSG^.SetMailType(mmtNetMail);
        end;
        newmsg^.Startnewmsg;
        newmsg^.SetTo('All');
        newmsg^.SetFrom(CurrentMSG^.GetFrom);
        newmsg^.SetSubj(CurrentMSG^.GetSubj);
        newmsg^.SetDate(CurrentMSG^.GetDate);
        newmsg^.SetTime(CurrentMSG^.GetTime);
        newmsg^.setrefer(0);
        newmsg^.setseealso(0);
        newmsg^.setcost(currentmsg^.getcost);
        newmsg^.setnextseealso(0);
        newmsg^.SetLocal(TRUE);
        if (private in memboard.mbpriv) or (pubpriv in memboard.mbpriv) then begin
                  newmsg^.setpriv(TRUE);
                  if (memboard.mbtype=2) then newmsg^.SetKillSent(TRUE);
        end;
          if (memboard.mbtype=1) then begin
          addr.zone:=ni.address[getaddressnumber].zone;
          addr.net:=ni.address[getaddressnumber].net;
          addr.node:=ni.address[getaddressnumber].node;
          addr.point:=ni.address[getaddressnumber].point;
          newmsg^.dokludgeln(^A+'MSGID: '+pointedaddrstr(addr)+' '+lower(hexlong(getdosdate)));
          end;
          newmsg^.doKludgeln(^A+'PID: nxEMAIL v'+ver2);
                        CurrentMSG^.MsgTxtStartup;
                        while not(CurrentMSG^.EOM) do begin
                                s2:=CurrentMSG^.GetString(78);
                                stripit:=false;
                                if (copy(s2,1,4)='--- ') or (s2='---') then begin
                                        s2[2]:='!';
                                end;
                                if (copy(s2,1,10)=' * Origin:') then begin
                                        s2[2]:='!';
                                        if (mbsorigin in memboard.mbstat) then stripit:=true;
                                end;
                                if (copy(s2,1,1)=#1) then stripit:=true;
                                if (copy(s2,1,8)='SEEN-BY:') then stripit:=true;
                                i2:=pos(#12,s2);
                                while (i2<>0) do begin
                                        s2:=copy(s2,1,i2-1)+copy(s2,i2+1,length(s2)-i2);
                                        i2:=pos(#12,s2);
                                end;
                                if not(stripit) then
                                        newmsg^.DoStringLn(s2);
                                end;
                        end;
                if (ll.footer<>'') then begin
                assign(tf,ll.footer);
                {$I-} reset(tf); {$I+}
                if (ioresult=0) then begin
                while not(eof(tf)) do begin
                        readln(tf,s2);
                        s2:=processMCI(s2);
                        newmsg^.dostringln(s2);
                end;
                close(tf);
                end;
                end;
                newmsg^.dostringln('');
                s3:='--- nxEMAIL/DOS v'+ver2;
                newmsg^.dostringln(s3);
                if (memboard.mbtype=1) then begin
                        s3:=getorigin;
                        newmsg^.dostringln(s3);
                end;
                if (newmsg^.Writemsg<>0) then begin
                        logit2('!','ERROR: Error saving message!');
                end else
                        CurrentMSG^.DeleteMSG;
          if (closemsgarea(newmsg)) then begin end;
         end;
end;

procedure serverfunc;
var stripit:boolean;
    tf2:text;
    name:string;
    cmd:byte;

        function getcommand:byte;
        var s2:string;
            ctype:byte;
        begin
                        ctype:=4;
                        CurrentMSG^.MsgTxtStartup;
                        while not(CurrentMSG^.EOM) do begin
                                s2:=CurrentMSG^.GetString(78);
                                if (allcaps(copy(s2,1,9))='SUBSCRIBE') then begin
                                ctype:=1;
                                name:=copy(s2,11,length(s2));
                                end;
                                if (allcaps(copy(s2,1,11))='UNSUBSCRIBE') then begin
                                ctype:=2;
                                name:=copy(s2,13,length(s2));
                                end;
                                if (allcaps(copy(s2,1,4))='HELP') then begin
                                ctype:=3;
                                end;
                        end;
                getcommand:=ctype;
        end;

        procedure addtolist;
        begin
                        if (notonlist) then begin
                        logit2('+','SUBSCRIBE: '+currentmsg^.Getfrom+'  LIST: '+allcaps(name));
                        assign(tf2,adrv(systat.gfilepath)+'LIST'+cstrn(ll.userid)+'.USR');
                        {$I-} append(tf2); {$I+}
                        if (ioresult<>0) then begin
                                rewrite(tf2);
                        end;
                        writeln(tf2,currentmsg^.getfrom);
                        close(tf2);
                        end else begin
                                logit2('!','SUBSCRIBE: '+currentmsg^.getfrom+' - ALREADY ON LIST.');
                                cmd:=5;
                        end;
        end;

        procedure removefromlist;
        var tf3:text;
            ss:string;
        begin
                if not(notonlist) then begin
               logit2('-','REMOVE: '+currentmsg^.Getfrom+'  LIST: '+allcaps(name));
               assign(tf2,adrv(systat.gfilepath)+'LIST'+cstrn(ll.userid)+'.USR');
               assign(tf3,adrv(systat.gfilepath)+'LIST'+cstrn(ll.userid)+'.NEW');
               {$I-} reset(tf2); {$I+}
               if (ioresult<>0) then begin
                       exit;
               end;
               rewrite(tf3);
               while not(eof(tf2)) do begin
                        readln(tf2,ss);
                        if (allcaps(ss)=allcaps(currentmsg^.getfrom)) then begin end else
                        begin
                                writeln(tf3,ss);
                        end;
               end;
               close(tf2);
               close(tf3);
               {$I-} erase(tf2); {$I+}
               if (ioresult<>0) then begin end;
               {$I-} rename(tf3,adrv(systat.gfilepath)+'LIST'+cstrn(ll.userid)+'.USR');
               if (ioresult<>0) then begin end;
                        end else begin
                                logit2('!','REMOVE: '+currentmsg^.getfrom+' - NO SUCH USER.');
                                cmd:=6;
                        end;
        end;

begin
        cmd:=getcommand;
        if not(cmd in [3,4]) then begin
                trnum:=isltrigger(name);
                if (trnum=-1) then cmd:=0 else
                if not(readlistserv(trnum)) then begin
                  logit2('!','SERVER: Unable to read list for '+cstr(trnum));
                  exit;
                end;
        end;
                gwname:=getbasename(gways[gw]);
                if (gwname<>'') then
                if (openorcreatemsgarea(newmsg,gwname)) then begin
                        inc(totlp);
                        case cmd of
                        1:begin
                                addtolist;
                          end;
                        2:begin
                                removefromlist;
                          end;
                        end;
                        case memboard.mbtype of
                                0:newMSG^.SetMailType(mmtNormal);
                                1:newMSG^.SetMailType(mmtEchoMail);
                                2:newMSG^.SetMailType(mmtNetMail);
                                3:newMSG^.SetMailType(mmtNetMail);
                        end;
                        newmsg^.Startnewmsg;
                        newmsg^.SetTo(ir.gateways[gw].toname);
                        newmsg^.SetFrom('listserv');
                        case cmd of
                                0:newmsg^.SetSubj('Your listserver message');
                                1:newmsg^.SetSubj('SUBSCRIPTION');
                                2:newmsg^.SetSubj('UNSUBSCRIBING');
                                3:newmsg^.SetSubj('LISTSERV HELP');
                                4:newmsg^.SetSubj('UNRECOGNIZED COMMAND');
                                5:newmsg^.SetSubj('Already on '+allcaps(name)+' list');
                                6:newmsg^.SetSubj('Not on '+allcaps(name)+' list');
                        end;
                        newmsg^.SetDate(date);
                        newmsg^.SetTime(time);
                        addr.zone:=ni.address[ir.gateways[gw].fromaddress].zone;
                        addr.net:=ni.address[ir.gateways[gw].fromaddress].net;
                        addr.node:=ni.address[ir.gateways[gw].fromaddress].node;
                        addr.point:=ni.address[ir.gateways[gw].fromaddress].point;
                        addr2.zone:=ir.gateways[gw].toaddress.zone;
                        addr2.net:=ir.gateways[gw].toaddress.net;
                        addr2.node:=ir.gateways[gw].toaddress.node;
                        addr2.point:=ir.gateways[gw].toaddress.point;
                        newmsg^.SetOrig(addr);
                        newmsg^.SetDest(addr2);
                        newmsg^.setrefer(0);
                        newmsg^.setseealso(0);
                        newmsg^.setcost(currentmsg^.getcost);
                        newmsg^.setnextseealso(0);
                        newmsg^.SetLocal(TRUE);
                        newmsg^.setpriv(TRUE);
                        newmsg^.SetKillSent(TRUE);
                        newmsg^.dokludgeln(^A+'MSGID: '+pointedaddrstr(addr)+' '+lower(hexlong(getdosdate)));
                        s2:=currentmsg^.GetMSGID;
                        if (s2<>'') then newmsg^.DoKludgeln(^A+'REPLY: '+s2);
                        newmsg^.doKludgeln(^A+'PID: nxEMAIL v'+ver2);
                        newmsg^.doStringLn('TO: '+currentmsg^.GetFrom);
                        newmsg^.dostringln('');
                        case cmd of
                                0:begin
                                  newmsg^.DoStringln('The list you attempted to subscribe to does not exist on this server.');
                                  logit2('!','ERROR: '+currentmsg^.Getfrom+' requested invalid list: '+allcaps(name));
                                  end;
                                1:begin
                                        assign(tf,ll.signup);
                                        {$I-} reset(tf); {$I+}
                                        if (ioresult=0) then begin
                                                while not(eof(tf)) do begin
                                                        readln(tf,s2);
                                                        newmsg^.DoStringLn(s2);
                                                end;
                                                close(tf);
                                        end;
                                  end;
                                2:begin
                                        assign(tf,ll.logoff);
                                        {$I-} reset(tf); {$I+}
                                        if (ioresult=0) then begin
                                                while not(eof(tf)) do begin
                                                        readln(tf,s2);
                                                        newmsg^.DoStringLn(s2);
                                                end;
                                                close(tf);
                                        end;
                                  end;
                                3,4:begin
                                  case cmd of
                                        3:begin
                                          logit2('?','HELP: '+currentmsg^.Getfrom+' requested help.');
                                          end;
                                        4:begin
                                          logit2('?','HELP: Unrecognized command.');
                                          logit2('?','HELP: Help sent to '+currentmsg^.getfrom);
                                          newmsg^.dostringln('UNRECOGNIZED COMMAND');
                                          newmsg^.dostringln('');
                                          end;
                                  end;
                newmsg^.dostringln('nxEMAIL v'+ver2+'- LISTSERV HELP');
                newmsg^.dostringln('');
                newmsg^.dostringln('SUBSCRIBE [listname]          ex. SUBSCRIBE NEXUS          Subscribe to a list');
                newmsg^.dostringln('UNSUBSCRIBE [listname]        ex. UNSUBSCRIBE NEXUS        Unsubscribe a list');
                newmsg^.dostringln('HELP                          ex. HELP                     This help message');
                                  end;
                                5:begin
                                        newmsg^.dostringln('LISTSERV COMMAND: SUBSCRIBE '+allcaps(name));
                                        newmsg^.dostringln('');
                                        newmsg^.dostringln('You are already a member of the '+allcaps(name)+' list.');
                                  end;
                                6:begin
                                        newmsg^.dostringln('LISTSERV COMMAND: UNSUBSCRIBE '+allcaps(name));
                                        newmsg^.dostringln('');
                                        newmsg^.dostringln('You not a member of the '+allcaps(name)+' list.');
                                  end;
                        end;
                        newmsg^.dostringln('');
                        s3:='--- nxEMAIL/DOS v'+ver2;
                newmsg^.dostringln(s3);
                if (newmsg^.Writemsg<>0) then begin
                        logit2('!','ERROR: Error saving message!');
                end else
                        logit2('!','Saved message...');
                        CurrentMSG^.DeleteMSG;
                end;
end;

begin
settotals(4,1,totlp);
settotals(4,2,totlt);
showstring:=TRUE;
logit2('+','Scanning inbound NETMAIL ('+allcaps(systat.netmailpath)+')');
if (openorcreatemsgarea(currentmsg,'F'+systat.netmailpath)) then begin
currentmsg^.seekfirst(1);
while (currentmsg^.seekfound) do begin
        inc(totlt);
        currentmsg^.msgstartup;
        currentmsg^.GetOrig(addr);
        currentmsg^.GetDest(addr2);
        s:=currentmsg^.getto;
        trnum:=isltrigger(s);
        if (isinbound(addr,addr2,gw)) and 
        not(currentMSG^.islocal) and not(currentmsg^.isrcvd) and
        ((trnum<>-1) or (allcaps(currentmsg^.getto)='LISTSERV')) then begin
                if (trnum<>-1) then begin
                        posttolist;
                end else begin
                        serverfunc;
                end;
        end;
        settotals(4,1,totlp);
        settotals(4,2,totlt);
        CurrentMSG^.SeekNext;
end;
if (closemsgarea(currentmsg)) then begin end;
end;
exportfromecho;
end;

procedure title;
begin
writeln('nxEMAIL v',vers,' - Internet Email Processor for Nexus BBS Software');
writeln('(c) Copyright 1996-2001 George A. Roberts IV. All rights reserved.');
writeln;
end;

procedure helpscreen;
begin
textcolor(7);
textbackground(0);
clrscr;
title;
writeln('Syntax:     nxEMAIL <command> [command] [command]');
writeln;
writeln('Commands:');
writeln;
writeln('               LISTSERV        Process incoming list-server messages');
writeln('               AUTOBOT         Process incoming AUTOBOT messages');
writeln('               IMPORT          Import new email from netmail area');
writeln('               EXPORT          Export outgoing email to netmail format');
halt;
end;

procedure getparams;
var np,np2:integer;
    sp:string;
begin
  imp:=FALSE;
  exp:=FALSE;
  auto:=FALSE;
  np:=paramcount;
  if (np=0) then helpscreen;
  np2:=1;
  while (np2<=np) do begin
        sp:=allcaps(paramstr(np2));
        case sp[1] of
                '/','-':begin
                        case sp[2] of
                                '?','H':helpscreen;
                                'Z':nxe:=TRUE;
                        end;
                        end;
                 else begin
                        if (allcaps(sp)='IMPORT') then imp:=TRUE;
                        if (allcaps(sp)='EXPORT') then exp:=TRUE;;
                        if (allcaps(sp)='AUTOBOT') then auto:=TRUE;
                        if (allcaps(sp)='LISTSERV') then list:=TRUE;
                 end;
        end;
        inc(np2);
   end;
end;

procedure openfiles;
var systatf:file of MatrixREC;
begin
nexusdir:=getenv('NEXUS');
if (nexusdir[length(nexusdir)]='\') then nexusdir:=copy(nexusdir,1,length(nexusdir)-1);
start_dir:=nexusdir;
filemode:=66;
assign(systatf,nexusdir+'\MATRIX.DAT');
{$I-} reset(systatf); {$I+}
if (ioresult<>0) then begin
        writeln('Error opening '+allcaps(nexusdir)+'\MATRIX.DAT!');
        halt;
end;
read(systatf,systat);
close(systatf);
filemode:=66;
assign(iff,adrv(systat.gfilepath)+'INTERNET.DAT');
{$I-} reset(iff); {$I+}
if (ioresult<>0) then begin
        writeln('Error opening '+adrv(systat.gfilepath)+'INTERNET.DAT!');
        halt;
end;
read(iff,ir);
close(iff);
filemode:=66;
assign(nf,adrv(systat.gfilepath)+'NETWORK.DAT');
{$I-} reset(nf); {$I+}
if (ioresult<>0) then begin
        writeln('Error opening '+adrv(systat.gfilepath)+'NETWORK.DAT!');
        halt;
end;
read(nf,ni);
close(nf);
filemode:=66;
assign(emf,adrv(systat.gfilepath)+'NXEMAIL.DAT');
{$I-} reset(emf); {$I+}
if (ioresult<>0) then begin
        writeln('Error opening '+adrv(systat.gfilepath)+'NXEMAIL.DAT ... recreated.');
        fillchar(em,sizeof(em),#0);
        em.nomovefile:=adrv(systat.gfilepath)+'NOIMPORT.TXT';
        em.nobouncefile:=adrv(systat.gfilepath)+'NOBOUNCE.TXT';
        em.bouncenoexist:=TRUE;
        rewrite(emf);
        write(emf,em);
        seek(emf,0);
end;
read(emf,em);
close(emf);
end;


function commandline:string;
var s:string;
begin
s:='';
if (list) then s:='LISTSERV ';
if (auto) then s:=s+'AUTOBOT ';
if (imp) then s:=s+'IMPORT ';
if (exp) then s:=s+'EXPORT ';
commandline:=s;
end;

procedure bscreen;
var  wfcFile : file;
begin
   window(1,1,80,25);
   cursoron(FALSE);
   assign(wfcFile,bslash(true,pathonly(paramstr(0)))+'NXEMAIL.BIN');
   {$I-} reset(wfcFile,1); {$I+}
   if (ioresult<>0) then begin
        displaybox('Error reading '+bslash(true,pathonly(paramstr(0)))+'NXEMAIL.BIN',2000);
        halt;
   end;
   if (filesize(wfcfile)<4000) then begin
        displaybox(bslash(true,pathonly(paramstr(0)))+'NXEMAIL.BIN is an invalid size!',2000);
        halt;
   end;
   blockRead(wfcFile,mem[$B800:0],4000);
   close(wfcFile);
end;

begin
totip:=0;
totit:=0;
openfiles;
vers:=ver2;
getparams;
findbases;
assign(lf,adrv(systat.trappath)+'NEXUS.LOG');
opensysopf2;
blockwritestr(lf,'--- Created by nxEMAIL v'+vers+' on '+date+' '+time+#13#10);
blockwritestr(lf,#13#10);
close(lf);
cursoron(FALSE);
oldx:=wherex;
oldy:=wherey;
savescreen(oldwind,1,1,80,25);
if not(nxe) then begin
    textcolor(7);
    textbackground(0);
    clrscr;
    bscreen;
end;
{drawwindow2(1,1,78,4,1,3,0,11,'');
gotoxy(3,2);
textcolor(15);
textbackground(3);
write('nxEMAIL v',ver2,' - Internet Email Processor for Nexus BBS Software');
gotoxy(3,3);
write('(c) Copyright 1996-2001 George A. Roberts IV. All rights reserved.'); }
setuptotals;
setuplogwindow;
logit2(':','Begin; nxEMAIL v'+vers);
logit2(':','Commandline : '+commandline);
logit2(':','Netmail path: '+systat.netmailpath);
if (list) then begin
        logit2('#','Begin; LISTSERV processing');
        listserver;
        logit2('#','End; LISTSERV processing');
end;
if (auto) then begin
        logit2('#','Begin; AUTOBOT processing');
        autobot;
        logit2('#','End; AUTOBOT processing');
end;
if (imp) then begin
        logit2('#','Begin; IMPORT processing');
        importmail;
        logit2('#','End; IMPORT processing');
end;
if (exp) then begin
        logit2('#','Begin; EXPORT processing');
        exportmail;
        logit2('#','End; EXPORT processing');
end;
if (list) then begin
logit2('$','LISTSERV - Processed: '+mln(cstr(totlt),6)+' Handled  : '+mln(cstr(totlh),6)+' Exported: '+mln(cstr(totlp),6));
end;
if (auto) then begin
logit2('$','AUTOBOT  - Processed: '+mln(cstr(totat),6)+' Responses: '+mln(cstr(totap),6));
end;
if (imp) then begin
logit2('$','Import   - Processed: '+mln(cstr(totit),6)+' Imported : '+mln(cstr(totip),6));
end;
if (exp) then begin
logit2('$','Export   - Processed: '+mln(cstr(totet),6)+' Exported : '+mln(cstr(totep),6));
end;
logit2(':','End; nxEMAIL v'+vers);
delay(2000);
removewindow(totalwind);
removewindow(oldwind);
if oldy=25 then writeln;
gotoxy(1,oldy);
textcolor(7);
textbackground(0);
cursoron(TRUE);
if not(nxe) then begin
writeln('nxEMAIL v',vers,' - Internet Email Processor for Nexus BBS Software');
writeln('(c) Copyright 1996-2001 George A. Roberts IV. All rights reserved.');
end;
end.
