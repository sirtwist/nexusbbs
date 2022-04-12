{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R-,S+,V-}
unit mail0;

interface

uses
  crt, dos, common, mkopen, mkglobt,mkmsgabs,keyunit;

const
  MBopened:boolean=FALSE;  { has brdf been opened yet? }
  oldnummsgs:integer=0;    { old number of messages }

var
  irt:string[80];          { reason for reply                      }
  ll:string[80];           { "last-line" string for word-wrapping  } 
  wasyourmsg:boolean;
  lmto:string;
{  lmdate:string;}
  CurrentMSG:AbsMsgPtr;
  
procedure outmessagetext(fn:string; eraseit:boolean);
function getdestaddr:string;
function getorigaddr:string;
procedure findhimsg;
procedure MbOpen;
procedure MbOpenCreate;
procedure MbClose;
function findbasenum(l:longint):integer;

implementation

function getdestaddr:string;
var addr:addrtype;
    s:string;
begin
s:='';
if (mbopened) then begin
        currentMSG^.GetDest(addr);
        if (addr.zone<>0) then begin
                s:=cstr(addr.zone)+':'+cstr(addr.net)+'/'+cstr(addr.node);
                if (addr.point<>0) then s:=s+cstr(addr.point);
        end
end;
getdestaddr:=s;
end;

function getorigaddr:string;
var addr:addrtype;
    s:string;
begin
s:='';
if (mbopened) then begin
        currentMSG^.GetOrig(addr);
        if (addr.zone<>0) then begin
                s:=cstr(addr.zone)+':'+cstr(addr.net)+'/'+cstr(addr.node);
                if (addr.point<>0) then s:=s+cstr(addr.point);
        end
end;
getorigaddr:=s;
end;

function findbasenum(l:longint):integer;
var bif:file of baseididx;
    bi:baseididx;
begin
if (l=-1) then begin
        findbasenum:=-1;
        exit;
end;
assign(bif,adrv(systat^.gfilepath)+'MBASEID.IDX');
{$I-} reset(bif); {$I+}
if (ioresult<>0) then begin
        findbasenum:=-1;
        exit;
end;
if (filesize(bif)-1<l) then begin
        findbasenum:=-1;
        exit;
end;
seek(bif,l);
read(bif,bi);
close(bif);
findbasenum:=bi.offset;
end;

  function existdir(fn:astr):boolean;
  var srec:searchrec;
  begin
    while (fn[length(fn)]='\') do fn:=copy(fn,1,length(fn)-1);
    findfirst(fexpand(sqoutsp(fn)),anyfile,srec);
    existdir:=(doserror=0) and (srec.attr and directory=directory);
  end;

function bslash(b:boolean; s:astr):astr;
begin
  if (b) then begin
    while (copy(s,length(s)-1,2)='\\') do s:=copy(s,1,length(s)-2);
    if (copy(s,length(s),1)<>'\') then s:=s+'\';
  end else
    while (copy(s,length(s),1)='\') do s:=copy(s,1,length(s)-1);
  bslash:=s;
end;

procedure outmessagetext(fn:string; eraseit:boolean);
var t:text;
    s:string;
    c,lc:char;
    numch:integer;
    d:datetimerec;

begin
  s:='';
  assign(t,fn);
  {$I-} reset(t); {$I+}
  if (ioresult<>0) then exit;
  CurrentMSG^.DoKludgeLn(^A+'PID: Nexus '+getlongversion(3));
  numch:=0;
  if (memboard.mbtype=3) and (emailto<>'') then begin
        CurrentMSG^.DoKludgeLn(^A+'X-Mailreader: Nexus Bulletin Board System v'+getlongversion(3));
        CurrentMSG^.DoStringLn('TO: '+emailto);
        CurrentMSG^.DoStringLN('');
  end;
  while (not eof(t)) do begin
    read(t,c);
    case c of
        #10:begin
            end;
        #13:begin
                lc:=#13;
                CurrentMSG^.DoChar(c);
                numch:=0;
            end;
        #141:begin
                if (numch<80) then begin
                        CurrentMSG^.DoChar(#32);
                end;
                CurrentMSG^.DoChar(c);
                numch:=0;
            end;
            else begin
                inc(numch);
                CurrentMSG^.DoChar(c);
            end;
     end;
  end;
  close(t);
  if (eraseit) then begin
        {$I-} erase(t); {$I+}
        if (ioresult<>0) then begin
        end;
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

procedure MbOpen;
begin
if not(existdir(bslash(FALSE,getmbpath))) then begin
        Mbopened:=FALSE;
        sl1('!','Msg Base #'+cstr(board)+': Path does not exist!');
        exit;
end;
MBopened:=OpenMsgArea(CurrentMsg,GetMbType+GetMbPath+GetMbFileName);
findhimsg;
if (mbopened) then begin
lastread:=CurrentMSG^.GetLastRead(thisuser.userid)
end else lastread:=-1;
end;

procedure MbOpenCreate;
begin
if not(existdir(bslash(FALSE,getmbpath))) then begin
        Mbopened:=FALSE;
        sl1('!','Msg Base #'+cstr(board)+': Path does not exist!');
        exit;
end;
MbOpened:=OpenOrCreateMsgArea(CurrentMsg,GetMbType+GetMbPath+GetMbFileName);
findhimsg;
if (mbopened) then begin
lastread:=CurrentMSG^.GetLastRead(thisuser.userid)
end else lastread:=-1;
end;

procedure MbClose;
begin
MbOpened:=not(CloseMsgArea(CurrentMSG));
end;

end.
