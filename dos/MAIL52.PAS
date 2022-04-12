{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R-,S+,V-}
unit mail52;

interface

uses
  crt, dos,
  common, mkopen, mkmsgabs;

procedure Movemsg(x:longint);

implementation

uses mail0,mail9;


procedure Movemsg(x:longint);
var f:file;
    s,s2,oldbase:string;
    oldlength,totload:longint;
    i,oldboard:integer;
    ok,usereal,done:boolean;
    Msg2:absmsgptr;

function GetMbType2:string;
begin
case memboard.MessageType of
        1:GetMbType2:='S';
        2:GetMbType2:='J';
        3:GetMbType2:='F';
end;
end;

function GetMbPath2:string;
var s:string;
begin
s:=memboard.msgpath;
if (s[length(s)]<>'\') then s:=s+'\';
GetMbPath2:=s;
end;

function GetMbFileName2:string;
begin
if (memboard.messagetype<>3) then GetMbFileName2:=memboard.filename else
GetMbFileName2:='';
end;


function MbOpenCreate2:boolean;
begin
MbOpenCreate2:=OpenOrCreateMsgArea(Msg2,GetMbType2+GetMbPath2+GetMbFileName2);
end;

function MbClose2:boolean;
begin
MbClose2:=(CloseMsgArea(MSG2));
end;



begin
    oldboard:=board;
    oldbase:=stripcolor(memboard.name);
    if (mbopened) then mbclose;
    mbopencreate;
    if not(mbopened) then begin
        sprint('%120%Error Opening Message Base.');
        sl1('!','Error opening '+stripcolor(memboard.name));
    end;
    CurrentMSG^.Seekfirst(x);
    CurrentMSG^.MsgStartUp;
    i:=0; done:=FALSE; nl;
    repeat
      sprompt(gstring(36)); scaninput(s,'Q?',TRUE);
      if ((s='') or (s='Q')) then begin done:=TRUE; i:=numboards+1; end
      else
      if (s='?') then begin mbasechange(done,'L'); nl; end
      else begin
        i:=value(s);
        if ((i>=0) and (i<>board) and (i<=numboards)) then done:=TRUE;
        if (not done) then print('Cannot Copy Message To That Base.');
        if (memboard.mbtype=2) then begin
                print('Cannot Copy Message to a netmail base.');
                done:=FALSE;
                end;
      end;
    until ((done) or (hangup));

    if ((i>=0) and (i<=numboards)) then begin
      oldboard:=board;
      changeboard(i);
      ok:=false;
      if (board=i) then begin
        ok:=MbOpenCreate2;
        if not(ok) then begin
                sprint('%120%Error Opening Message Base.');
                sl1('!','Error Opening '+memboard.name);
                exit;
        end;
        Msg2^.Startnewmsg;
        Msg2^.SetTo(CurrentMSG^.GetTo);
        Msg2^.SetFrom(CurrentMSG^.GetFrom);
        Msg2^.SetSubj(CurrentMSG^.GetSubj);
        Msg2^.SetDate(CurrentMSG^.GetDate);
        msg2^.SetTime(CurrentMSG^.GetTime);
        msg2^.setrefer(0);
        msg2^.setseealso(0);
        msg2^.setcost(currentmsg^.getcost);
        msg2^.setnextseealso(0);
        msg2^.setlocal(TRUE);
        if (memboard.mbtype=1) then msg2^.setecho(TRUE);
        if (private in memboard.mbpriv) then msg2^.setpriv(TRUE);
    s:='Original Base: '+oldbase;
    msg2^.DoStringLn(s);
    s:='------ Message Moved ------';
    msg2^.DoStringLn(s);
    msg2^.DoStringLn('');
    CurrentMSG^.MsgTxtStartup;
    while not(CurrentMSG^.EOM) do begin
      msg2^.DoStringLn(CurrentMSG^.GetString(79));
    end;
        if (Msg2^.Writemsg<>0) then begin
                sprint('%120%Error saving message.');
        end else CurrentMSG^.DeleteMSG;
        ok:=MbClose2;
      end;

    end;
    board:=oldboard;
    changeboard(board);
    if (mbopened) then mbclose;
end;

end.
