{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R+,S+,V-}
unit mainmail;

interface

uses
  crt, dos, common, myio3, file8, mkglobt, mkmsgabs, mkopen,
  mail0, mail1, mail3, mail9, mkmisc;

const replytoboard:integer=-1;

function ppost(base:integer):boolean;
procedure post(pp:boolean; replyto:longint; repto:string);
procedure msgsearch;
procedure scanmessages(mstr:string);
Procedure Waitscan(t:integer;mstr:string);

procedure nscan(mstr:string);
(* function getnextscanbase(first:boolean):boolean;
procedure displaynextmessage;
procedure getfirstmessage;
procedure getnextmessage;
procedure getpreviousmessage; *)
procedure pubreply(cn:longint);
procedure copymsg(cn:longint);
procedure forwardmsg(cn:longint);
procedure movemsg(cn:longint);
(* procedure deletemessage;
procedure extractmessage;
procedure untagcurrent;
procedure ListTitles; *)

implementation

uses {tmpcom,}tagunit,mkstring,mail52,file2,common2;

const postedok:boolean=FALSE;
      searching:boolean=FALSE;
      searchaction:byte=0;

function bslash(b:boolean; s:astr):astr;
begin
  if (b) then begin
    while (copy(s,length(s)-1,2)='\\') do s:=copy(s,1,length(s)-2);
    if (copy(s,length(s),1)<>'\') then s:=s+'\';
  end else
    while (copy(s,length(s),1)='\') do s:=copy(s,1,length(s)-1);
  bslash:=s;
end;

function substone(src,old,new:string):string;
var p:integer;
begin
  if (old<>'') then begin
    p:=pos(old,src);
    if (p>0) then begin
      insert(new,src,p+length(old));
      delete(src,p,length(old));
    end;
  end;
  substone:=src;
end;

procedure movemsg(cn:longint);
var f:file;
    ok:boolean;
    s,s2,oldbase:string;
    oldlength,totload:longint;
    i,oldboard:integer;
    usereal,done:boolean;
    olddate,oldsubj:string;
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
    replytoboard:=-1;
    oldbase:=stripcolor(memboard.name);
    if (mbopened) then mbclose;
    mbopencreate;
    if not(mbopened) then begin
        sprint('%120%Error opening message base.');
        sl1('!','Error opening '+stripcolor(memboard.name));
    end;
    CurrentMSG^.Seekfirst(cn);
    CurrentMSG^.MsgStartUp;
    oldsubj:=CurrentMSG^.GetSubj;
    olddate:=CurrentMSG^.GetDate+' '+CurrentMSG^.GetTime;
    i:=0; done:=FALSE; nl;
    repeat
      sprompt(gstring(36)); scaninput(s,'Q?',TRUE);
      if ((s='') or (s='Q')) then begin done:=TRUE; i:=numboards+1; end
      else
      if (s='?') then begin mbasechange(done,'L'); nl; end
      else begin
        i:=value(s);
        if ((i>=0) and (i<>board) and (i<=numboards)) then done:=TRUE;
        if (not done) then print('Cannot copy message to that base.');
        if (memboard.mbtype=2) then begin
                print('Cannot copy message to a netmail base.');
                done:=FALSE;
                end;
      end;
    until ((done) or (hangup));

    if ((i>=0) and (i<=numboards)) then begin
      oldboard:=board;
      replytoboard:=i;
      changeboard(i);
      if (board=i) then begin
        ok:=MbOpenCreate2;
        if not(ok) then begin
                sprint('%120%Error opening message base.');
                sl1('!','Error opening '+memboard.name);
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
        s:='* Message moved from '+oldbase;
        msg2^.DoStringLn(s);
        msg2^.DoStringLn('');
        CurrentMSG^.MsgTxtStartup;
        while not(CurrentMSG^.EOM) do begin
                s:=CurrentMSG^.GetString(78);
                if (copy(s,1,1)=#1) then
                        msg2^.DoKludgeLn(s)
                else
                        msg2^.DoStringLn(s);
        end;
        Msg2^.Writemsg;
        ok:=MbClose2;
        CurrentMSG^.Deletemsg;
      end;
    end;
    board:=oldboard;
    changeboard(board);
    if (mbopened) then mbclose;
end;

function ppost(base:integer):boolean;
var oldbase:integer;
begin
postedok:=FALSE;
oldbase:=board;
board:=base;
post(TRUE,-1,'');
loadboard(oldbase);
board:=oldbase;
ppost:=postedok;
end;

procedure post(pp:boolean; replyto:longint; repto:string);
var s:string;
    ok:boolean;
    oldboard:integer;
    Msg2:absmsgptr;

  procedure nope(s:string);
  begin
    if (ok) then begin nl; print(s); end;
    ok:=FALSE;
  end;

function GetMbType2:string;
begin
case memboard.MessageType of
        1:GetMbType2:='S';
        2:GetMbType2:='J';
        3:GetMbType2:='F';
end;
end;

function GetMbPath2:string;
begin
GetMbPath2:=bslash(TRUE,memboard.msgpath);
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
  ok:=TRUE;
  oldboard:=board;
  loadboard(board);
  if (not aacs(memboard.postacs)) then
    nope('Your access does not allow you to post in this message base.');
  if ((rpost in thisuser.ac) or (not aacs(systat^.normpubpost))) then
    nope('Your access privledges do not include posting.');
  if (((ptoday>=systat^.maxpubpost) or (systat^.maxpubpost=0)) and (not mso)) then
    nope('Too many messages posted today.');
  if (((ftoday>=systat^.maxfback) or (systat^.maxfback=0)) and (not mso)) then
    nope('Too many feedback messages posted today.');
  if (ok) then begin
    if (MBopened) then MbClose;
    if (replyto<>-1) then begin
        if (replytoboard<>-1) then begin
                board:=replytoboard;
        end;
    end;
    MbOpenCreate;
    if not(mbopened) then begin
        sprint('%120%Error Opening Message Base.');
        exit;
    end;
    
(*    if (replyto<>-1) then begin
      repstring:=repto;
    end else
      repstring:=''; *)

    cls;
    s:='';
    if (irt<>'') then begin s:=irt; irt:=''; end;
    if (inmsg(not(pp),(replyto<>-1),s,repto)) then begin
    
      if (replyto<>-1) and (replytoboard=-1) then begin
         CurrentMSG^.SetRefer(replyto);
      end;
      
      if (CurrentMSG^.WriteMSG<>0) then begin
         sprint('%140%ERROR!');
         sl1('!','Error posting message to '+memboard.name);
      end else begin
         if (replyto<>-1) and (replytoboard=-1) then begin
              if (MbOpenCreate2) then begin
               Msg2^.SeekFirst(replyto);
               Msg2^.MsgStartUp;
               Msg2^.SetSeeAlso(CurrentMSG^.GetMsgNum);
               Msg2^.Rewritehdr;
               mbclose2;
              end;
         end;
         postedok:=TRUE;
         sl1('+',CurrentMSG^.GetSubj+' posted on '+memboard.name);
         sprint('%140%#'+cstr(CurrentMSG^.GetMsgNum)+'%110% to %140%'+memboard.name+'%110%.');
         inc(thisuser.msgpost);
         inc(ptoday);
         if not(CurrentMSG^.IsPriv) then 
            inc(curact^.pubpost);
         if (memboard.mbtype in [1,2,3]) then elevel:=exitnetworkmail;
      end;

      topscr;
      
      end;
   if (mbopened) then MbClose;
   board:=oldboard;
   repaddress:='';
   end;
end;

{ readtype     0 normal
               1 yoursonly

  cn           start message #
               }

{procedure editmessage(i:integer);
var t:text;
    f:file;
    s:string;
    dfdt1,dfdt2,newmsgptr,totload:longint;
begin
  loadmhead(i,mheader);

  assign(t,newtemp+'nextempx.msg'); rewrite(t);
  totload:=0;
  repeat
    blockreadstr2(datf,s);
    inc(totload,length(s)+2);
    writeln(t,s);
  until (totload>=mheader.msglength);
  close(t);
  getftime(t,dfdt1);

  tedit(allcaps(newtemp+'nextempx.msg'));
  assign(f,newtemp+'nextempx.msg');
  getftime(f,dfdt2);
  close(f);

  if (dfdt1<>dfdt2) then begin
    assign(t,newtemp+'nextempx.msg');
    reset(t);
    mheader.msglength:=0;
    repeat
      readln(t,s);
      inc(mheader.msglength,length(s)+2);
    until (eof(t));
    close(f);
    newmsgptr:=filesize(brdf);
    seek(brdf,newmsgptr);
    outmessagetext(newtemp+'nextempx.msg',mixr,mheader,TRUE);
    loadmix(mixr,i);
    mixr.hdrptr:=newmsgptr;
    savemix(mixr,i);
    end;
end;     }

function doinitials(s:string):string;
var t,s1:string;
    i:integer;
begin
    t:='';
    t:=allcaps(copy(s,1,1));
    s1:=s;
    i:=pos(' ',s);
    while (i<>0) do begin
    s1:=copy(s1,i+1,length(s1)-i);
    t:=t+allcaps(copy(s1,1,1));
    i:=pos(' ',s1);
    end;
    i:=pos(' ',t);
    if (i<>0) then delete(t,i,length(t)-(i-1));
doinitials:=t;
end;

procedure pubreply(cn:longint);
var t:text;
    s,s3:string;
    i2,x:integer;
    stripit:boolean;
    adr:addrtype;


begin
    if (mbopened) then mbclose;
    mbopencreate;
    if not(mbopened) then exit;
    if (cn>himsg) then exit;
    CurrentMSG^.SeekFirst(cn);
    CurrentMsg^.MsgStartUp;
    if (memboard.mbtype=2) then begin
        CurrentMsg^.getOrig(adr);
                 if (adr.zone<>0) then begin
                        repaddress:=cstr(adr.zone)+':'+cstr(adr.net)+'/'+cstr(adr.node);
                        if (adr.point<>0) then repaddress:=repaddress+'.'+cstr(adr.point);
                 end;
    end;
    cn:=CurrentMSG^.GetMsgNum;
{    lmdate:=CurrentMSG^.GetDate+' '+CurrentMSG^.GetTime;}
    lmto:=CurrentMSG^.GetTo;
    if lmto='' then lmto:='All';
    assign(t,newtemp+'msgtmp'); rewrite(t);
    for x:=1 to 3 do begin
        if (gstring(79+x)<>'') then begin
        s:=processmci(gstring(79+x));
        while (pos(#13,s)<>0) do begin    
                if (pos(#13,s)<>1) then writeln(t,copy(s,1,pos(#13#10,s)-1));
                if (pos(#13,s)+2)<length(s) then
                        s:=copy(s,pos(#13,s)+2,length(s)-(pos(#13,s)+1))
                else s:='';
        end;
        writeln(t,s);
        end;
    end;
    CurrentMSG^.MsgTxtStartup;
    while not(CurrentMSG^.EOM) do begin
      s:=CurrentMSG^.GetString(77-length(doinitials(CurrentMSG^.GetFrom)));
      s3:=' ';
      while (s3<>'') and (CurrentMSG^.WasWrap) and not(CurrentMSG^.EOM) and (length(s)<70) do begin
        s3:=CurrentMSG^.GetString(73-(length(doinitials(CurrentMSG^.GetFrom)))-Length(s));
        if (s3<>'') then begin
              if (copy(s3,1,1)=' ') then
              s:=s+s3
              else
              s:=s+' '+s3;
        end;
      end;
      stripit:=false;
      if (copy(s,1,4)='--- ') then begin
        s[2]:='!';
      end;
      if (copy(s,1,10)=' * Origin:') then begin
                s[2]:='!';
                if (mbsorigin in memboard.mbstat) then stripit:=true;
      end;
      if (mbskludge in memboard.mbstat) then begin
                if (copy(s,1,1)=#1) then stripit:=true;
      end else begin
                if (copy(s,1,1)=#1) then s[1]:='@';
      end;
      if (mbsseenby in memboard.mbstat) then
                if (copy(s,1,8)='SEEN-BY:') then stripit:=true;
      i2:=pos(#12,s);
      while (i2<>0) do begin
                s:=copy(s,1,i2-1)+copy(s,i2+1,length(s)-i2);
                i2:=pos(#12,s);
                end;
      if not(stripit) then begin
      if (s<>'') then begin
      s:=doinitials(CurrentMSG^.GetFrom)+'> '+s;
      end else s:='';
      write(t,s+#13#10);
      end;
    end;
    for x:=1 to 3 do begin
        if (gstring(82+x)<>'') then begin
        s:=processmci(gstring(82+x));
        while (pos(#13,s)<>0) do begin    
                if (pos(#13,s)<>1) then writeln(t,copy(s,1,pos(#13#10,s)-1));
                if (pos(#13,s)+2)<length(s) then
                        s:=copy(s,pos(#13,s)+2,length(s)-(pos(#13,s)+1))
                else s:='';
        end;
        writeln(t,s);
        end;
    end;
    close(t);
    irt:=CurrentMSG^.GetSubj;
    if (allcaps(copy(irt,1,3))<>'RE:') and (irt<>'') then
        irt:='Re: '+irt;
    if (memboard.mbtype=3) then begin
        s3:=CurrentMSG^.GetReplyADDR;
        if (s3='') then begin
                s3:=CurrentMSG^.GetFrom;
        end else begin
                interaddr:=CurrentMSG^.GetReplyTo;
                interto:=CurrentMSG^.GetReplyName;
        end;
    end else begin
    s3:=CurrentMSG^.GetFrom;
    end;
    post(FALSE,cn,s3);
    assign(t,newtemp+'msgtmp');
    {$I-} reset(t); {$I+}
    if (ioresult=0) then begin close(t); erase(t); end;
end;

procedure copymsg(cn:longint);
var f:file;
    ok:boolean;
    netmailok:boolean;
    s,s2,oldbase:string;
    oldlength,totload:longint;
    i,oldboard:integer;
    usereal,done:boolean;
    olddate,oldsubj:string;
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
    netmailok:=(memboard.mbtype=2);
    oldboard:=board;
    replytoboard:=-1;
    oldbase:=stripcolor(memboard.name);
    if (mbopened) then mbclose;
    mbopencreate;
    if not(mbopened) then begin
        sprint('%120%Error Opening Message Base.');
        sl1('!','Error opening '+stripcolor(memboard.name));
    end;
    CurrentMSG^.Seekfirst(cn);
    CurrentMSG^.MsgStartUp;
    oldsubj:=CurrentMSG^.GetSubj;
    olddate:=CurrentMSG^.GetDate+' '+CurrentMSG^.GetTime;
    i:=0; done:=FALSE; nl;
    repeat
      sprompt(gstring(36)); scaninput(s,'Q?',TRUE);
      if ((s='') or (s='Q')) then begin done:=TRUE; i:=numboards+1; end
      else
      if (s='?') then begin mbasechange(done,'L'); nl; end
      else begin
        i:=value(s);
        if ((i>=0) and (i<>board) and (i<=numboards)) then done:=TRUE;
        if (not done) then print('Unable to copy message to that message base.');
        if (memboard.mbtype=2) and not(netmailok) then begin
                sprompt('%120%Unable to copy message to a netmail base.|LF|');
                done:=FALSE;
                end;
      end;
    until ((done) or (hangup));

    if ((i>=0) and (i<=numboards)) then begin
      oldboard:=board;
      replytoboard:=i;
      changeboard(i);
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
        s:='* Message copied from '+oldbase;
        msg2^.DoStringLn(s);
        msg2^.DoStringLn('');
        CurrentMSG^.MsgTxtStartup;
        while not(CurrentMSG^.EOM) do begin
                s:=CurrentMSG^.GetString(78);
                if (copy(s,1,1)=#1) then
                        msg2^.DoKludgeLn(s)
                else
                        msg2^.DoStringLn(s);
        end;
        Msg2^.Writemsg;
        ok:=MbClose2;
      end;
    end;
    board:=oldboard;
    changeboard(board);
    if (mbopened) then mbclose;
end;

procedure forwardmsg(cn:longint);
var t:text;
    oldto:string[80];
    s,s3:string;
    oldboard,i,i2,x:integer;
    done,stripit:boolean;
    addr:addrtype;

    function showaddress:string;
    var s4:string;
    begin
    s4:='';
    if (addr.zone<>0) then begin
        s4:=' ('+cstr(addr.zone)+':'+cstr(addr.net)+'/'+cstr(addr.node);
        if (addr.point<>0) then begin
                s4:=s4+'.'+cstr(addr.point);
        end;
        s4:=s4+')';
    end;
    showaddress:=s4;
    end;

begin
    oldboard:=board;
    replytoboard:=-1;
    if (mbopened) then mbclose;
    mbopencreate;
    if not(mbopened) then begin
        sprint('%120%Error Opening Message Base.');
        sl1('!','Error opening '+stripcolor(memboard.name));
    end;
    CurrentMSG^.Seekfirst(cn);
    CurrentMSG^.MsgStartUp;
    i:=0; done:=FALSE; nl;
    repeat
      sprompt(gstring(36)); scaninput(s,'Q?',TRUE);
      if ((s='') or (s='Q')) then begin done:=TRUE; i:=numboards+1; end
      else
      if (s='?') then begin mbasechange(done,'L'); nl; end
      else begin
        i:=value(s);
        if ((i>=0) and (i<=numboards)) then done:=TRUE;
        if (not done) then print('Cannot forward message to that base.');
      end;
    until ((done) or (hangup));
    assign(t,newtemp+'MSGTMP');
    {$I-} rewrite(t); {$I+}
    if (ioresult<>0) then begin
        sprompt('%120%Error creating temporary files... aborted.');
        sl1('!','Cannot create '+newtemp+'MSGTMP!');
        exit;
    end;
    irt:=CurrentMSG^.GetSubj+' (fwd)';
    s:='* Message forwarded by ';
    if (mbrealname in memboard.mbstat) then s:=s+thisuser.realname else
    s:=s+thisuser.name;
    s:=s+' via Nexus v'+getlongversion(2);
    writeln(t,s);
    s:='* Forwarded from base: '+stripcolor(memboard.name);
    writeln(t,s);
    CurrentMSG^.GetDest(addr);
    s:='       Original to : ';
    if (currentmsg^.getto='') then s:=s+'All' else s:=s+caps(CurrentMSG^.GetTo);
    if (currentmsg^.getto='') then oldto:='All' else oldto:=caps(CurrentMSG^.GetTo);
    if (memboard.mbtype=2) then s:=s+showaddress;
    writeln(t,s);
    CurrentMSG^.GetOrig(addr);
    s:='              From : ';
    if (memboard.mbtype=3) then s:=s+currentmsg^.getfrom else s:=s+caps(currentmsg^.getfrom);
    if (memboard.mbtype=2) then s:=s+showaddress;
    writeln(t,s);
    s:='           Subject : '+CurrentMSG^.GetSubj;
    s:='         Date/Time : ';
    s:=s+formatteddosdate(longdate2(CurrentMSG^.GetDate+' '+CurrentMSG^.GetTime),
        'DD NNN YYYY  AA:II#');
    writeln(t,s);
    writeln(t,'');
    writeln(t,'-------(B e g i n  F o r w a r d e d  M e s s a g e)--------------------------');
    forwarding_msg:=TRUE;
    CurrentMSG^.MsgTxtStartup;
    while not(CurrentMSG^.EOM) do begin
      s:=CurrentMSG^.GetString(78);
      s3:=' ';
      while (s3<>'') and (CurrentMSG^.WasWrap) and not(CurrentMSG^.EOM) and (length(s)<70) do begin
        s3:=CurrentMSG^.GetString(78-Length(s));
        if (s3<>'') then begin
              if (copy(s3,1,1)=' ') then
              s:=s+s3
              else
              s:=s+' '+s3;
        end;
      end;
      stripit:=false;
      if (copy(s,1,4)='--- ') then begin
        s[2]:='!';
      end;
      if (copy(s,1,10)=' * Origin:') then begin
                s[2]:='!';
                if (mbsorigin in memboard.mbstat) then stripit:=true;
      end;
      if (mbskludge in memboard.mbstat) then begin
                if (copy(s,1,1)=#1) then stripit:=true;
      end else begin
                if (copy(s,1,1)=#1) then s[1]:='@';
      end;
      if (mbsseenby in memboard.mbstat) then
                if (copy(s,1,8)='SEEN-BY:') then stripit:=true;
      i2:=pos(#12,s);
      while (i2<>0) do begin
                s:=copy(s,1,i2-1)+copy(s,i2+1,length(s)-i2);
                i2:=pos(#12,s);
                end;
      if not(stripit) then begin
      write(t,s+#13#10);
      end;
    end;
    writeln(t,'-------(E n d  F o r w a r d e d  M e s s a g e)------------------------------');
    writeln(t,'');
    close(t);

    if ((i>=0) and (i<=numboards)) then begin
      oldboard:=board;
      replytoboard:=i;
      if (mbopened) then mbclose;
      changeboard(i);
      if (board=i) then begin
        mbopencreate;
        if not(mbopened) then begin
                sprint('%120%Error opening message base.');
                sl1('!','Error opening '+memboard.name);
                exit;
        end;
        post(FALSE,-1,oldto);
        replytoboard:=-1;
    end;

    {$I-} reset(t); {$I+}
    if (ioresult=0) then begin close(t); erase(t); end;
    end;
    board:=oldboard;
    changeboard(board);
    if (mbopened) then mbclose;
end;

Procedure Wscan(b:integer;var num:integer;var quit:boolean);
var
s,real,alias:string;
cn:longint;
x2,n,i2,x,oldboard,savlil,i:integer;                  
glob,nw,nm,next:boolean;
nums:array[1..10] of integer;

begin
   real:=allcaps(thisuser.realname);
   alias:=allcaps(thisuser.name);
   glob:=false;
   if (quit) then glob:=true;
   quit:=false;
   oldboard:=board;quit:=false;
   num:=0;
   if (board<>b) then changeboard(b);
   if (board=b) then begin
                if (mbopened) then Mbclose;
                mbopencreate;
                if not(mbopened) then exit;
                lil:=0;x:=1;
                if (himsg>0) then begin
                        cn:=lastread+1;
                        if (glob) then begin
                                n:=((himsg-cn) div 10);
                                for x2:=1 to 10 do nums[x2]:=n*x2;
                        end;
                        CurrentMSG^.YoursFirst(cn,real,alias);
                        while (CurrentMSG^.Yoursfound) do begin
                                cn:=CurrentMSG^.GetMsgNum;
                                if (glob) then begin
                                        if (x<11) then
                                                if (cn+1>=nums[x]) then begin
                                                        ansig(27+(x*2),9);
                                                        setc(15 or (3 shl 4));
                                                        sprompt('栢');
                                                        inc(x);
                                                end;
                                end else if (cn mod 10)=0 then sprompt(' '+cstr(cn+1));
                                inc(num);
                                quit:=FALSE;
                                if not(glob) then
                                if (cn mod 10)=0 then for n:=1 to length(cstr(cn+1))+1 
                                        do sprompt(^H' '^H);
                                wkey(quit,next);
                                if not(quit) then CurrentMSG^.YoursNext;
                        end;
                        lil:=0;
                        end;
                        if (mbopened) then MbClose;
                end;
                if (x=1) and (glob) then
                        for n:=1 to 10 do begin
                                        ansig(27+(n*2),9);
                                        setc(15 or (3 shl 4));
                                        sprompt('栢');
                        end;
     board:=oldboard;
end;

procedure readmessages(cn:longint; readtype:byte; isnew,update:boolean; var quit:boolean);
var hread:longint;
    cmd:char;
    sstr,pstr,inp,s:string;
    displaykludges,abort,dispmsg,next,done,dolist:boolean;

    function toyou:boolean;
    begin
        if (allcaps(CurrentMSG^.Getto)=allcaps(thisuser.realname)) or (allcaps(CurrentMSG^.Getto)=allcaps(thisuser.name)) then
        toyou:=TRUE else toyou:=FALSE;
    end;

    function fromyou:boolean;
    begin
        if (allcaps(CurrentMSG^.Getfrom)=allcaps(thisuser.realname)) or
        (allcaps(CurrentMSG^.Getfrom)=allcaps(thisuser.name)) then
        fromyou:=TRUE else fromyou:=FALSE;
    end;

    procedure gotofirst;
    begin
    case readtype of
        0:currentMSG^.Seekfirst(cn);
        1:begin
                CurrentMSG^.YoursFirst(cn,allcaps(thisuser.realname),allcaps(thisuser.name));
          end;
        2:begin
                currentmsg^.seekfirst(cn);
                if (currentmsg^.seekfound) then currentmsg^.msgstartup;
                while (currentmsg^.seekfound) and (CurrentMSG^.IsPriv) and
                not(toyou) and not(fromyou) do
                begin
                currentmsg^.seeknext;
                if (currentmsg^.seekfound) then currentmsg^.msgstartup;
                end;
          end;
    end;
    end;

    procedure gotonext;
    begin
    case readtype of
        0:CurrentMSG^.SeekNext;
        1:begin
                CurrentMSG^.YoursNext;
          end;
        2:begin
                Currentmsg^.SeekNext;
                if (currentmsg^.seekfound) then currentmsg^.msgstartup;
                while (currentmsg^.seekfound) and (currentMSG^.IsPriv) and
                not(toyou) and not(fromyou) do
                begin
                currentmsg^.seeknext;
                if (currentmsg^.seekfound) then currentmsg^.msgstartup;
                end;
          end;
    end;
    end;

    function gotofound:boolean;
    begin
    case readtype of
        0:gotofound:=currentMSG^.Seekfound;
        1:gotofound:=CurrentMSG^.Yoursfound;
        2:gotofound:=CurrentMSG^.Seekfound;
    end;
    end;

    procedure gotoprior;
    begin
    case readtype of
        0:currentMSG^.SeekPrior;
        1:currentMSG^.YoursPrior;
        2:begin
                Currentmsg^.SeekPrior;
                if (currentmsg^.seekfound) then currentmsg^.msgstartup;
                while (currentmsg^.seekfound) and (CurrentMSG^.IsPriv) and
                not(toyou) and not(fromyou) do
                begin
                currentmsg^.seekPrior;
                if (currentmsg^.seekfound) then currentmsg^.msgstartup;
                end;
          end;
    end;
    end;

  procedure chkcmds(ti:integer);
  var i:integer;
      s:string;
      dok,kabort:boolean;
      t:text;
  var UTAG:^TagRecordOBJ;
  begin
      if ((cmd<>#0)) then
        case pos(cmd,sstr) of
          1:begin
                sprompt(gstring(602));
                sprompt(gstring(603));
                sprompt(gstring(604));
                sprompt(gstring(605));
                sprompt(gstring(606));
                sprompt(gstring(607));
                sprompt(gstring(608));
                sprompt(gstring(609));
                sprompt(gstring(610));
                sprompt(gstring(611));
                sprompt(gstring(612));
                sprompt(gstring(613));
                if (answerbaud=0) then
                sprompt(gstring(614));
                if (answerbaud>0) then
                sprompt(gstring(615));
                sprompt(gstring(616));
                sprompt(gstring(617));
                if (cso) and (memboard.mbtype<>0) then
                sprompt(gstring(618));
                sprompt(gstring(619));
                sprompt(gstring(620));
                if (isnew) then
                sprompt(gstring(621));
                if (mso) then
                sprompt(gstring(622));
                sprompt(gstring(623));
              end;
          3:begin
                copymsg(cn);
                MbOpenCreate;
                if not(mbopened) then exit;
                gotofirst;
                dispmsg:=TRUE;
            end;
          4:begin
                if ((mso) or ((toyou) or (fromyou))) then begin
                   if pynq(gstring(630)) then begin
                        CurrentMSG^.MsgStartup;
                        sl1('-','Deleted Message:');
                        sl1('-','    '+memboard.name+'  Msg #'+cstr(CurrentMSG^.GetMsgNum));
                        sl1('-','    Subject: '+CurrentMSG^.GetSubj);
                        CurrentMSG^.DeleteMSG;
                        inc(cn);
                        sprompt(gstring(631));
                    end;
                    findhimsg;
                    dispmsg:=TRUE;
                    if (cn<=himsg) then gotofirst;
                    if (himsg<=0) then begin
                        done:=TRUE;
                        dispmsg:=FALSE;
                    end;
                end else begin
                    sprompt(gstring(632));
                end;
                if (searching) then done:=TRUE;
              end;
           5:begin
                forwardmsg(cn);
                MbOpenCreate;
                if not(mbopened) then exit;
                gotofirst;
                dispmsg:=TRUE;
              end;
           6:if (mso) then begin
                movemsg(cn);
                MbOpenCreate;
                if not(mbopened) then exit;
                gotofirst;
                dispmsg:=TRUE;
             end;
           7:begin post(FALSE,-1,'');
                MbOpenCreate;
                if not(mbopened) then exit;
                gotofirst;
                end;
           8:begin quit:=TRUE; done:=TRUE; end;
           9:begin
                pubreply(cn);
                MbOpenCreate;
                if not(mbopened) then exit;
                gotofirst;
                end;
          10:begin
                nl;
                new(UTAG);
                if (UTAG=NIL) then begin
                        sprompt('%120%Insufficient memory to load tags!|LF|');
                end else begin
                UTAG^.Init(adrv(systat^.userpath)+hexlong(thisuser.userid)+'\'+hexlong(thisuser.userid)+'.NMT');
                UTAG^.Maxbases:=Numboards;
                if (UTAG^.IsTagged(memboard.baseid)) then begin
                        sprint('%030%Untagging: %150%'+memboard.name);
                        UTAG^.Removetag(memboard.baseid);
                        sl1('-','Removed message base tag for '+memboard.name);
                end else begin
                        sprint('%030%Tagging  : %150%'+memboard.name);
                        UTAG^.Addtag(memboard.baseid);
                        sl1('-','Added message base tag for '+memboard.name);
                end;
                UTAG^.Done;
                dispose(UTAG);
                nl;
                end;
              end;
          11:if ((mso) and (answerbaud=0)) then begin
                sprompt('|LF|%030%Filename to extract: ');
                CurrentMSG^.MsgStartUp;
                defaultst:=cstr(CurrentMSG^.GetMsgNum)+'.MSG';
                inputdln(s,12);
                dyny:=TRUE;
                nl;
                if exist(start_dir+'\EXPORT\'+s) then begin
                        sprompt('%150%File already exists. ');
                        if (pynq('%120%Overwrite? %110%')) then begin
                                exportmsg(start_dir+'\EXPORT\'+s,cn,cn+1,himsg+1,abort,next);
                                print('Finished!');
                        end;
                end else begin                        
                exportmsg(start_dir+'\EXPORT\'+s,cn,cn+1,himsg+1,abort,next);
                print('Finished!');
                end;
                end;
          13:if (answerbaud>0) then begin
                s:=newtemp+cstr(cn)+'.MSG';
                exportmsg(s,cn,cn+1,himsg+1,abort,next);
                sprint('%030%Sending: %150%'+cstr(cn)+'.MSG');
                send1(s,dok,kabort);
                while not(dok) and not(kabort) do begin
                        dyny:=TRUE;
                        if pynq('%120%Download Unsuccessful.  Try again? %110%') then begin
                                send1(s,dok,kabort);
                        end else dok:=TRUE;
                end;
                if exist(s) then begin
                        assign(t,s);
                        {$I-} erase(t); {$I+}
                        if ioresult<>0 then begin end;
                end;
              end;
          14:begin
                findhimsg;
                cn:=himsg;
                hread:=himsg;
                done:=TRUE;
              end;
          15:begin
                done:=TRUE;
                if (searching) then searchaction:=3;
             end;
          17:dolist:=TRUE;
          20:if (mso) then begin
                if (displaykludges) then displaykludges:=FALSE else
                displaykludges:=TRUE;
                gotofirst;
                dispmsg:=TRUE;
             end;
        end;
    end;

  procedure stitles;
  var numlisted:byte;
      oldpause:boolean;
      spec:string;
  begin
  oldpause:=(pause in thisuser.ac);
  thisuser.ac:=thisuser.ac-[pause];
  numlisted:=0;
  CurrentMSG^.MsgStartup;
  sprompt(gstring(680));
  sprompt(gstring(681));
  sprompt(gstring(682));
  sprompt(gstring(683));
  emailto:='';
  while (gotofound) and (lil<thisuser.pagelen-3) do begin
        if (memboard.mbtype=3) then begin
        CurrentMSG^.MsgTxtStartUp;
        s:=CurrentMSG^.GetNoKludgeStr(79);
        if (allcaps(copy(s,1,4))='TO: ') then begin
                emailto:=copy(s,5,length(s)-4);
        end;
        end;
        if (toyou) then spec:=gstring(686) else
        if (fromyou) then spec:=gstring(685) else
        spec:=gstring(684);
        sprompt(spec);
        emailto:='';
        gotonext;
        CurrentMSG^.MsgStartup;
        cn:=CurrentMSG^.GetMsgNum;
        msg_on:=cn;
  end;
  if not(gotofound) then begin
        gotoprior;
        if (memboard.messagetype<>3) then gotoprior;
        CurrentMSG^.MsgStartup;
        cn:=CurrentMSG^.GetMsgNum;
        msg_on:=cn;
  end;
  nl;
  if (oldpause) then thisuser.ac:=thisuser.ac+[pause];
  end;

function fileonly(s:string):string;
var
 x : integer;
 done : boolean;
begin
 x := length(s);
 done:=FALSE;
 while (x > 1) and not (done) do begin
       if s[x] = '\' then begin
          done := true;
       end;
       dec(x);
 end;
 if not(done) then s:='' else
 s := copy(s,x+2,length(s));
 fileonly := s;
end;

  procedure SendAttached;
  var s,s2,tmpstr:string;
      dok,kabort:boolean;
      x:integer;
  begin
                if (CurrentMSG^.IsFAttach) then begin
                s:=CurrentMSG^.GetSubj;
                if (spd='KB') then begin
                        sprompt('%030%Place files in which directory?|LF|');
                        sprompt('%090%> ');
                        input(s2,70);
                        if (s2<>'') then s2:=bslash(TRUE,s2);
                        nl;
                        if (s2<>'') then begin
                                while (pos(' ',s)<>0) do begin
                                tmpstr:=copy(s,1,pos(' ',s)-1);
                                s:=copy(s,pos(' ',s)+1,length(s));
                                if (exist(tmpstr)) then begin
                                sprompt('%030%Copying file %150%'+fileonly(tmpstr)+'%030%: ');
                                copyfile(dok,kabort,TRUE,tmpstr,s2+fileonly(tmpstr));
                                end else begin
                                sprompt('%030%Copying file %150%'+fileonly(tmpstr)+'%030%: %120%Does not exist!|LF|');
                                end;
                        end;
                        if (s<>'') then begin
                                tmpstr:=s;
                                if (exist(tmpstr)) then begin
                                sprompt('%030%Copying file %150%'+fileonly(tmpstr)+'%030%: ');
                                copyfile(dok,kabort,TRUE,tmpstr,s2+fileonly(tmpstr));
                                end else begin
                                sprompt('%030%Copying file %150%'+fileonly(tmpstr)+'%030%: %120%Does not exist!|LF|');
                                end;
                        end;
                        end;
                end else begin
                        if (s2<>'') then begin
                        while (pos(' ',s)<>0) do begin
                        tmpstr:=copy(s,1,pos(' ',s)-1);
                        s:=copy(s,pos(' ',s)+1,length(s));
                        sprint('%030%Sending: %150%'+fileonly(tmpstr));
                        send1(tmpstr,dok,kabort);
                        while not(dok) and not(kabort) do begin
                                dyny:=TRUE;
                        if pynq('%120%Download unsuccessful.  Try again? %110%') then begin
                                send1(tmpstr,dok,kabort);
                        end else dok:=TRUE;
                        end;
                        end;
                        if (s<>'') then begin
                        tmpstr:=s;
                        sprint('%030%Sending: %150%'+fileonly(tmpstr));
                        send1(tmpstr,dok,kabort);
                        while not(dok) and not(kabort) do begin
                                dyny:=TRUE;
                        if pynq('%120%Download unsuccessful.  Try again? %110%') then begin
                                send1(tmpstr,dok,kabort);
                        end else dok:=TRUE;
                        end;
                        end;
                        end;


                end;
                end;
  end;


begin
  if (private in memboard.mbpriv) and not(mso) and (readtype<>1) then readtype:=2;
  loadboard(board);
  if (mbopened) and not(searching) then MbClose;
  if not(searching) then MbOpenCreate;
  if (himsg<=0) and not(isnew) then begin
    sprompt(gstring(598));
    if (mbopened) then MbClose;
    exit;
  end;
  if (readtype=2) then begin
        gotofirst;
        if not(gotofound) then begin
                    if not(isnew) then sprompt(gstring(599));
                    if (mbopened) then MbClose;
                    exit;
        end;
  end;
if (mbskludge in memboard.mbstat) then displaykludges:=FALSE else displaykludges:=TRUE;
done:=FALSE;
abort:=FALSE;
quit:=FALSE;
next:=FALSE;
dolist:=FALSE;
hread:=CurrentMSG^.GetLastRead(thisuser.userid);
if (searching) then begin
pstr:=gstring(596);
sstr:=gstring(597);
end else begin
pstr:=gstring(600);
sstr:=gstring(601);
end;
msg_on:=1;
if (cn<>-1) then begin
        gotofirst;
        if not(gotofound) then exit;
        findhimsg;
        CurrentMSG^.MsgStartup;
        cn:=CurrentMSG^.GetMsgNum;
        msg_on:=cn;
        dispmsg:=TRUE;
end;
repeat
if (cn<>-1) then begin
        if (dolist) then begin
                stitles;
        end else begin
        if (dispmsg) then
        readmsg(displaykludges,abort,next);
        end;
        if (cn>hread) and (cn<=himsg) then hread:=cn else hread:=himsg;
end;
dolist:=FALSE;
dispmsg:=FALSE;
sprompt(pstr);
semaphore:=TRUE;
if (searching) then begin
onek(inp[1],sstr+^M);
inp[0]:=#1;
if (inp[1]=^M) then inp:='';
end else begin
scaninput(inp,sstr,true);
end;
semaphore:=FALSE;
cmd:=#0;
if (inp<>'') then begin
      if (value(inp)<>0) and not(searching) then begin
        cn:=value(inp);
        gotofirst;
        dispmsg:=TRUE;
      end else begin
      if (cn<=0) then begin
                cn:=1;
                gotofirst;
      end;
      cmd:=inp[1];
      case pos(cmd,sstr) of
         2:begin
                gotofirst;
                dispmsg:=TRUE;
            end;
         12:begin
                if (searching) then begin
                        searchaction:=1;
                        done:=TRUE;
                end else begin
              gotoprior;
              if not(gotofound) then begin
                        sprompt('|LF|%150%Already at the first message.|LF||LF|');
                        sprompt('|PAUSE|');
                        cn:=1;
                        gotofirst;
              end;
              dispmsg:=TRUE;
              end;
            end;
          16:begin
                SendAttached;
             end;
          18:begin
                if (CurrentMSG^.GetRefer<>0) then begin
                cn:=CurrentMSG^.GetRefer;
                gotofirst;
                end;
                dispmsg:=TRUE;
                end;
          19:begin if (CurrentMSG^.GetSeeAlso<>0) then begin
                cn:=CurrentMSG^.GetSeeAlso;
                gotofirst;
                end;
                dispmsg:=TRUE;
                end;
      end;
      end;
    chkcmds(1);
end else begin
        if (searching) then begin
                searchaction:=0;
                done:=TRUE;
        end else begin
                if (cn<=0) then begin
                        cn:=1;
                        gotofirst;
                end else gotonext;
                dispmsg:=TRUE;
        end;
end;
findhimsg;
if (cn<=himsg) then begin
        CurrentMSG^.MsgStartup;
        cn:=CurrentMSG^.GetMsgNum;
        msg_on:=cn;
end else done:=TRUE;
until not(gotofound) or (done);
if (update) then CurrentMSG^.SetLastRead(thisuser.userid,hread);
if (mbopened) and not(searching) then MbClose;
end;

(* procedure extractmessage;
var s:string;
    dok,kabort,abort,next:boolean;
    t:text;
begin
          if (answerbaud=0) then begin
                sprompt('|LF|%030%Filename to extract: ');
                defaultst:=cstrn(board)+cstrn(msg_on)+'.MSG';
                inputdln(s,12);
                dyny:=TRUE;
                nl;
                if exist(start_dir+'\EXPORT\'+s) then begin
                        if (pynq('%120%File already exists. Overwrite? %110%')) then begin
                                sprompt('%030%Exporting message... ');
                                exportmsg(start_dir+'\EXPORT\'+s,msg_on,msg_on+1,himsg+1,abort,next);
                                sprompt('%150%Finished!|LF|');
                        end;
                end else begin
                        sprompt('%030%Exporting message... ');
                        exportmsg(start_dir+'\EXPORT\'+s,msg_on,msg_on+1,himsg+1,abort,next);
                        sprompt('%150%Finished!|LF|');
                end;
          end else if (answerbaud>0) then begin
                s:=newtemp+cstrn(board)+cstrn(msg_on)+'.MSG';
                exportmsg(s,msg_on,msg_on+1,himsg+1,abort,next);
                sprompt('%030%Sending: %150%'+cstrn(board)+cstrn(msg_on)+'.MSG|LF|');
                send1(s,dok,kabort);
                while not(dok) and not(kabort) do begin
                        dyny:=TRUE;
                        if pynq('%120%Download unsuccessful.  Resend? %110%') then begin
                                send1(s,dok,kabort);
                        end else dok:=TRUE;
                end;
                if exist(s) then begin
                        assign(t,s);
                        {$I-} erase(t); {$I+}
                        if ioresult<>0 then begin end;
                end;
              end;
end;

procedure untagcurrent;
var UTAG:^TagRecordOBJ;
begin
                nl;
                new(UTAG);
                if (UTAG=NIL) then begin
                        sprompt('%120%Insufficient memory to load tags!|LF|');
                end else begin
                UTAG^.Init(adrv(systat^.userpath)+hexlong(thisuser.userid)+'\'+hexlong(thisuser.userid)+'.NMT');
                UTAG^.Maxbases:=Numboards;
                if (UTAG^.IsTagged(memboard.baseid)) then begin
                        sprint('%030%Untagging: %150%'+memboard.name);
                        UTAG^.Removetag(memboard.baseid);
                        sl1('-','Removed message base tag for '+memboard.name);
                end else begin
                        sprint('%030%Tagging  : %150%'+memboard.name);
                        UTAG^.Addtag(memboard.baseid);
                        sl1('-','Added message base tag for '+memboard.name);
                end;
                UTAG^.Done;
                dispose(UTAG);
                nl;
                end;
end; *)

(* procedure getnextmessage;
var real,alias:string;
    readtype:byte;
    hread:longint;

    function toyou:boolean;
    var toname:string;
    begin
        toname:=allcaps(CurrentMSG^.Getto);
        if (toname=real) or (toname=alias) then toyou:=TRUE else toyou:=FALSE;
    end;

    function fromyou:boolean;
    var fromname:string;
    begin
        fromname:=allcaps(CurrentMSG^.Getfrom);
        if (fromname=real) or (fromname=alias) then fromyou:=TRUE else fromyou:=FALSE;
    end;

    procedure gotonext;
    begin
    case readtype of
        0:CurrentMSG^.SeekNext;
        1:begin
                CurrentMSG^.YoursNext;
          end;
        2:begin
                Currentmsg^.SeekNext;
                if (currentmsg^.seekfound) then currentmsg^.msgstartup;
                while (currentmsg^.seekfound) and (currentMSG^.IsPriv) and
                not(toyou) and not(fromyou) do
                begin
                currentmsg^.seeknext;
                if (currentmsg^.seekfound) then currentmsg^.msgstartup;
                end;
          end;
    end;
    end;

    function gotofound:boolean;
    begin
    case readtype of
        0:gotofound:=currentMSG^.Seekfound;
        1:gotofound:=CurrentMSG^.Yoursfound;
        2:gotofound:=CurrentMSG^.Seekfound;
    end;
    end;

begin
   real:=allcaps(thisuser.realname);
   alias:=allcaps(thisuser.name);
if (normal in actions) then readtype:=0;
if (waiting in actions) then readtype:=1;
if (private in memboard.mbpriv) and not(mso) and (readtype<>1) then readtype:=2;
gotonext;
if not(gotofound) then begin
        actions:=actions+[nomessage];
        msg_on:=himsg+1;
end else begin
        currentmsg^.msgstartup;
        msg_on:=CurrentMSG^.GetMsgNum;
        actions:=actions+[showmessage];
end;
hread:=CurrentMSG^.Getlastread(thisuser.userid);
if (hread<msg_on) then begin
        if (msg_on>himsg) then msg_on:=himsg;
        CurrentMSG^.SetLastRead(thisuser.userid,msg_on);
end;
end;

procedure getfirstmessage;
var real,alias:string;
    readtype:byte;

    function toyou:boolean;
    var toname:string;
    begin
        toname:=allcaps(CurrentMSG^.Getto);
        if (toname=real) or (toname=alias) then toyou:=TRUE else toyou:=FALSE;
    end;

    function fromyou:boolean;
    var fromname:string;
    begin
        fromname:=allcaps(CurrentMSG^.Getfrom);
        if (fromname=real) or (fromname=alias) then fromyou:=TRUE else fromyou:=FALSE;
    end;

    procedure gotofirst;
    begin
    case readtype of
        0:currentMSG^.Seekfirst(msg_on);
        1:begin
                CurrentMSG^.YoursFirst(msg_on,real,alias);
          end;
        2:begin
                currentmsg^.seekfirst(msg_on);
                if (currentmsg^.seekfound) then currentmsg^.msgstartup;
                while (currentmsg^.seekfound) and (CurrentMSG^.IsPriv) and
                not(toyou) and not(fromyou) do
                begin
                currentmsg^.seeknext;
                if (currentmsg^.seekfound) then currentmsg^.msgstartup;
                end;
          end;
    end;
    end;

    function gotofound:boolean;
    begin
    case readtype of
        0:gotofound:=currentMSG^.Seekfound;
        1:gotofound:=CurrentMSG^.Yoursfound;
        2:gotofound:=CurrentMSG^.Seekfound;
    end;
    end;

begin
real:=allcaps(thisuser.realname);
alias:=allcaps(thisuser.name);
if (normal in actions) then readtype:=0;
if (waiting in actions) then readtype:=1;
if (private in memboard.mbpriv) and not(mso) and (readtype<>1) then readtype:=2;
gotofirst;
if not(gotofound) or ((msg_on<=0) or (msg_on>himsg)) then begin
          actions:=actions+[nomessage];
end else begin
          currentmsg^.msgstartup;
          msg_on:=CurrentMSG^.GetMsgNum;
          actions:=actions+[showmessage];
end;
end;

procedure getpreviousmessage;
var real,alias:string;
    readtype:byte;

    function toyou:boolean;
    var toname:string;
    begin
        toname:=allcaps(CurrentMSG^.Getto);
        if (toname=real) or (toname=alias) then toyou:=TRUE else toyou:=FALSE;
    end;

    function fromyou:boolean;
    var fromname:string;
    begin
        fromname:=allcaps(CurrentMSG^.Getfrom);
        if (fromname=real) or (fromname=alias) then fromyou:=TRUE else fromyou:=FALSE;
    end;

    function gotofound:boolean;
    begin
    case readtype of
        0:gotofound:=currentMSG^.Seekfound;
        1:gotofound:=CurrentMSG^.Yoursfound;
        2:gotofound:=CurrentMSG^.Seekfound;
    end;
    end;

    procedure gotoprior;
    begin
    case readtype of
        0:currentMSG^.SeekPrior;
        1:currentMSG^.YoursPrior;
        2:begin
                Currentmsg^.SeekPrior;
                if (currentmsg^.seekfound) then currentmsg^.msgstartup;
                while (currentmsg^.seekfound) and (CurrentMSG^.IsPriv) and
                not(toyou) and not(fromyou) do
                begin
                currentmsg^.seekPrior;
                if (currentmsg^.seekfound) then currentmsg^.msgstartup;
                end;
          end;
    end;
    end;

begin
   real:=allcaps(thisuser.realname);
   alias:=allcaps(thisuser.name);
if (normal in actions) then readtype:=0;
if (waiting in actions) then readtype:=1;
if (private in memboard.mbpriv) and not(mso) and (readtype<>1) then readtype:=2;
gotoprior;
if not(gotofound) then begin
        getfirstmessage;
end;
currentmsg^.msgstartup;
msg_on:=CurrentMSG^.GetMsgNum;
actions:=actions+[showmessage];
end;

procedure deletemessage;
var real,alias:string;

    function toyou:boolean;
    var toname:string;
    begin
        toname:=allcaps(CurrentMSG^.Getto);
        if (toname=real) or (toname=alias) then toyou:=TRUE else toyou:=FALSE;
    end;

    function fromyou:boolean;
    var fromname:string;
    begin
        fromname:=allcaps(CurrentMSG^.Getfrom);
        if (fromname=real) or (fromname=alias) then fromyou:=TRUE else fromyou:=FALSE;
    end;

begin
real:=allcaps(thisuser.realname);
alias:=allcaps(thisuser.name);
                if ((mso) or ((toyou) or (fromyou))) then begin
                   if pynq(gstring(630)) then begin
                        sl1('-','Deleted message #'+cstr(msg_on)+' from '+memboard.name);
                        sl1('-','Message from '+currentmsg^.getfrom+' to '+currentmsg^.getto);
                        sl1('-','Message subject: '+currentmsg^.Getsubj);
                        CurrentMSG^.DeleteMSG;
                        inc(msg_on);
                        sprompt(gstring(631));
                    end;
                    findhimsg;
                    if (msg_on<=himsg) then getfirstmessage;
                    if (himsg<=0) then begin
                        actions:=actions+[nomessage];
                        actions:=actions-[showmessage];
                    end;
                end else begin
                    sprompt(gstring(632));
                end;
end;



procedure ListTitles;
var numlisted:byte;
    oldpause:boolean;
    norm,ty,fy:string;
    s:string;
    real,alias:string;

    function toyou:boolean;
    var toname:string;
    begin
        toname:=allcaps(CurrentMSG^.Getto);
        if (toname=real) or (toname=alias) then toyou:=TRUE else toyou:=FALSE;
    end;

    function fromyou:boolean;
    var fromname:string;
    begin
        fromname:=allcaps(CurrentMSG^.Getfrom);
        if (fromname=real) or (fromname=alias) then fromyou:=TRUE else fromyou:=FALSE;
    end;

begin
  real:=allcaps(thisuser.realname);
  alias:=allcaps(thisuser.name);
  oldpause:=(pause in thisuser.ac);
  thisuser.ac:=thisuser.ac-[pause];
  numlisted:=0;
  sprompt(gstring(680));
  sprompt(gstring(681));
  sprompt(gstring(682));
  sprompt(gstring(683));
  norm:=gstring(684);
  fy:=gstring(685);
  ty:=gstring(686);
  emailto:='';
  if (getfirst in actions) then begin
        GetFirstMessage;
        actions:=actions-[getfirst];
  end;
  while not(nomessage in actions) and (lil<thisuser.pagelen-3) do begin
        if (memboard.mbtype=3) then begin
           CurrentMSG^.MsgTxtStartUp;
           s:=CurrentMSG^.GetNoKludgeStr(79);
           if (allcaps(copy(s,1,4))='TO: ') then begin
                emailto:=copy(s,5,length(s)-4);
           end;
        end;
        if (toyou) then sprompt(ty) else
        if (fromyou) then sprompt(fy) else
        sprompt(norm);
        emailto:='';
        getnextmessage;
  end;
  if (nomessage in actions) then begin
        actions:=actions-[nomessage];
        getpreviousmessage;
        if (memboard.messagetype<>3) then getpreviousmessage;
  end;
  nl;
  if (oldpause) then thisuser.ac:=thisuser.ac+[pause];
  actions:=actions-[showmessage];
end;

procedure displaynextmessage;
var abort,next:boolean;
begin
readmsg(abort,next);
end; *)

procedure scanmessages(mstr:string);
var ob:integer;
    done:boolean;
begin
ob:=board;
done:=FALSE;
if (mstr='0') or ((mstr<>'') and (value(mstr)<>0)) then begin
        if not(mbaseac(value(mstr))) then begin
                sprompt('%150%You do not have access to that base.|LF|');
                exit;
        end;
        board:=value(mstr);
end;
readmessages(-1,0,FALSE,TRUE,done);
board:=ob;
loadboard(board);
end;

Procedure Wrscan(cn:longint;b:integer;var quit:boolean);
var
s:string;
i2,oldboard,savlil,i:integer;
cb,nm,abort,next:boolean;

begin
   abort:=false;
   oldboard:=board;
   if (board<>b) then changeboard(b);
   if (board=b) then begin
                if (mbopened) then Mbclose;
                MbOpenCreate;
                lil:=0;
                if (himsg<>-1) then begin
                        cn:=currentMSG^.getlastread(thisuser.userid)+1;
                        CurrentMSG^.YoursFirst(cn,thisuser.realname,thisuser.name);
                        if (currentMSG^.YoursFound) then begin
                                CurrentMSG^.MsgStartup;
                                cn:=CurrentMSG^.GetMsgNum;
                                readmessages(cn,1,TRUE,FALSE,quit);
                        end;
                        if (mbopened) then MbClose;
                        lil:=0;
                        end;
                end;
   board:=oldboard;
end;

procedure qscan(b:integer; var quit:boolean);
var cn:word;
    oldboard:integer;
    done,abort,next:boolean;
    
begin
  done:=false;
  oldboard:=board;
  if (not quit) then begin
    if (board<>b) then changeboard(b);
    if (board=b) then begin
      if (mbopened) then MbClose;
      MbOpenCreate;
      if not(mbopened) then begin
        lil:=0;
        sprompt(gstring(30));
        exit;
      end;
      lil:=0;
      sprompt(gstring(29));
      cn:=lastread+1;
      if (himsg>0) then begin
        if (cn<=himsg) then begin
                readmessages(cn,0,true,true,quit);
        end else quit:=FALSE;
      end;
      if (mbopened) then MbClose;
      if (not quit) then begin
        lil:=0;
        sprompt(gstring(30));
      end;
    end;
    wkey(quit,next);
  end;
  board:=oldboard;
  loadboard(board);
end; 

(* function getnextscanbase(first:boolean):boolean;
var bb:integer;
begin
  if not(global in actions) then begin
        if (first) then begin
                getnextscanbase:=TRUE;
                exit;
        end else begin
                getnextscanbase:=FALSE;
                exit;
        end;
  end else begin
  sl1('+','Global scan of new messages');
  bb:=0;
  if (first) then begin
          new(MSGSCAN);
          if (MSGSCAN=NIL) then begin
                  sprint('%120%Unable to retrieve message base tag records.');
                  getnextscanbase:=FALSE;
                  exit;
          end else begin
                  MSGSCAN^.Init(adrv(systat^.userpath)+hexlong(thisuser.userid)+'\'+hexlong(thisuser.userid)+'.NMT');
                  MSGSCAN^.Maxbases:=Numboards;
                  bb:=MSGSCAN^.GetFirst(adrv(systat^.gfilepath)+'USER'+cstrn(cnode)+'.TMT');
          end;
  end else begin
          bb:=MSGSCAN^.GetNext;
  end;
  if (bb<>-1) and not(hangup) then begin
    while not(mbaseac(bb)) and (bb<>-1) do begin
          bb:=MSGSCAN^.GetNext;
    end;
    if (bb<>-1) then board:=bb else begin
        getnextscanbase:=FALSE;
        exit;
    end;
  end else begin
        getnextscanbase:=FALSE;
        exit;
  end;
  end;
  getnextscanbase:=TRUE;
end; *)

procedure gnscan;
var bb,oldboard:integer;
    quit:boolean;
  var UTAG:^TagRecordOBJ;
begin
  sl1('+','Global scan of new messages');
  oldboard:=board;
  bb:=0; quit:=FALSE;
  new(UTAG);
  if (UTAG=NIL) then begin
         sprompt('%120%Insufficient memory to load tags!|LF|');
  end else begin
  sprompt(gstring(28));
  UTAG^.Init(adrv(systat^.userpath)+hexlong(thisuser.userid)+'\'+hexlong(thisuser.userid)+'.NMT');
  UTAG^.Maxbases:=Numboards;
  repeat
    loadboard(bb);
    if (UTAG^.IsTagged(memboard.baseid)) then begin
        if (mbaseac(bb)) then qscan(bb,quit);
    end;
    inc(bb);
  until ((bb>numboards) or (quit) or (hangup));
  board:=oldboard;
  changeboard(board);
  sprompt(gstring(30));
  sprompt(gstring(31));
  UTAG^.Done;
  dispose(UTAG);
  end;
end;

procedure nscan(mstr:string);
var scanned:boolean;
    instr:string[20];
    which:byte;
    c:char;
    omconf:byte;
    abort,next:boolean;
begin
  abort:=FALSE; next:=FALSE;
  lil:=0;
  if (mstr='C') then qscan(board,next)
  else
  if (copy(mstr,1,1)='G') then begin
        scanned:=FALSE;
        if (length(mstr)>1) then begin
                if (mstr[2]='C') then begin
                        gnscan;
                        scanned:=TRUE;
                end;
                if (mstr[2]='A') then begin
                        omconf:=mconf;
                        mconf:=0;
                        gnscan;
                        mconf:=omconf;
                        scanned:=TRUE;
                end;
        end;
        if not(scanned) then begin
            sprompt(gstring(573));
            sprompt(gstring(575));
            sprompt(gstring(576));
            sprompt(gstring(577));
            instr:=allcaps(gstring(578));
            if (length(instr)<3) then instr:='CAQ';
            instr:=instr+^M;
            onek(c,instr);
            which:=pos(c,instr);
            case which of
                   1,4:begin
                         gnscan;
                       end;
                     2:begin
                        omconf:=mconf;
                        mconf:=0;
                        gnscan;
                        mconf:=omconf;
                       end;
            end;
        end;
  end
  else if ((value(mstr)>=0) and (mstr<>'')) then begin
        qscan(value(mstr),next);
  end else begin
    sprompt(gstring(573));
    sprompt(gstring(574));
    sprompt(gstring(575));
    sprompt(gstring(576));
    sprompt(gstring(577));
    instr:=allcaps(gstring(579));
    if (length(instr)<4) then instr:='CATQ';
    instr:=instr+^M;
    onek(c,instr);
    which:=pos(c,instr);
    case which of
           1,5:begin
               gnscan;
               end;
             2:begin
                        omconf:=mconf;
                        mconf:=0;
                        gnscan;
                        mconf:=omconf;
               end;
             3:begin
               qscan(board,next);
               end;
          end;
  end;
end;

(* procedure nscan(mstr:string);
var scanned:boolean;
    instr:string;
    which:byte;
    c:char;
begin
  lil:=0;
  if (mstr='C') then begin
        actions:=actions-[global];
  end else
  if (copy(mstr,1,1)='G') then begin
        scanned:=FALSE;
        if (length(mstr)>1) then begin
                if (mstr[2]='C') then begin
                        actions:=actions+[global,cconly];
                        scanned:=TRUE;
                end;
                if (mstr[2]='A') then begin
                        actions:=actions+[global];
                        scanned:=TRUE;
                end;
        end;
        if not(scanned) then begin
            sprompt(gstring(573));
            sprompt(gstring(575));
            sprompt(gstring(576));
            sprompt(gstring(577));
            instr:=allcaps(gstring(578));
            if (length(instr)<3) then instr:='CAQ';
            instr:=instr+^M;
            onek(c,instr);
            which:=pos(c,instr);
            case which of
                   1,4:begin
                         actions:=actions+[global,cconly];
                       end;
                     2:begin
                         actions:=actions+[global];
                       end;
            end;
        end;
  end
  else if ((value(mstr)<>0) or (mstr='0')) then begin
        actions:=actions-[global];
        board:=value(mstr);
  end else begin
    sprompt(gstring(573));
    sprompt(gstring(574));
    sprompt(gstring(575));
    sprompt(gstring(576));
    sprompt(gstring(577));
    instr:=allcaps(gstring(579));
    if (length(instr)<4) then instr:='CATQ';
    instr:=instr+^M;
    onek(c,instr);
    which:=pos(c,instr);
    case which of
           1,5:begin
                actions:=actions+[global,cconly];
               end;
             2:begin
                actions:=actions+[global];
               end;
             3:begin
                actions:=actions-[global];
               end;
          end;
  end;
end; *)

Procedure WaitGScan(t:integer);
type bytep=^byteptr;
     byteptr=RECORD
        base:integer;
        n:bytep;
     end;
var lasttot,tot,num,bb,b,oldboard,x:integer;
    searching,nonecurrently,newm,quit,qquit:boolean;
    wait,wait1,wait2:bytep;
    s,s2:string;
var UTAG:^TagRecordOBJ;

begin
    new(wait);
    wait1:=wait;
    wait1^.base:=-1;
    wait1^.n:=NIL;
    nonecurrently:=TRUE;
    Sl1('+','Global Search for New Waiting Mail');
    oldboard:=board;
    tot:=0;
    lasttot:=-1;
    newm:=false;
    bb:=0;quit:=False;
  new(UTAG);
  if (UTAG=NIL) then begin
          sprint('%120%Unable to retrieve message base tag records.');
  end else begin
    UTAG^.Init(adrv(systat^.userpath)+hexlong(thisuser.userid)+'\'+hexlong(thisuser.userid)+'.NMT');
    UTAG^.Maxbases:=Numboards;
    bb:=UTAG^.GetFirst(adrv(systat^.gfilepath)+'USER'+cstrn(cnode)+'.TMT');
    if (okansi) then begin
                cls;
                drawwindow(20,6,60,11,1,3,0,11,0,TRUE,'');
                drawwindow(20,12,60,15,1,3,0,11,0,TRUE,'');
                ansig(22,13);
                setc(8 or (3 shl 4));
                sprompt('Current Base: ');
                ansig(22,14);
                setc(8 or (3 shl 4));
                sprompt('Total Found : ');
    end;
    searching:=FALSE;
    while (bb<>-1) and not(quit) and not(hangup) do begin
        if mbaseac(bb) then begin
                quit:=false;
                searching:=FALSE;
                if (okansi) then begin
                        ansig(22,7);
                        textcolor(15);
                        setc(15 or (3 shl 4));
                        sprompt('                                    ');
                        ansig(22,7);
                        sprompt('Scanning '+copy(stripcolor(memboard.name),1,27));
                        ansig(26,9);
                        sprompt('0%'); 
                        setc(8 or (3 shl 4));
                        ansig(29,9);
                        sprompt('같같같같같같같같같같'); 
                        setc(15 or (3 shl 4));
                        ansig(50,9);
                        sprompt('100%');
                        quit:=true;
                        cursoron(FALSE);
                end else begin
                        sprompt(gstring(568));
                        sprompt(gstring(569));
                end;
                num:=0;
                wscan(board,num,quit);
                qquit:=quit;
                if not(okansi) then
                        for x:=1 to lenn(gstring(569)) do sprompt(^H' '^H);
                if (num=0) then begin
                        if not (quit) then if not(okansi) then sprompt(gstring(570)) else
                                begin
                                        ansig(36,13);
                                        setc(15 or (3 shl 4));
                                        sprompt('None');
                                end;
                end else begin
                        if not(quit) then if not(okansi) then sprint('%040%'+cstr(num)) else begin 
                                        ansig(36,13);
                                        sprompt('                ');
                                        setc(15 or (3 shl 4));
                                        ansig(36,13);
                                        sprompt(cstr(num));
                        end;
                        newm:=true;
                        if (nonecurrently) then begin
                                wait1^.base:=bb;
                                nonecurrently:=false;
                        end else begin
                                new(wait2);
                                wait2^.base:=bb;
                                wait2^.n:=NIL;
                                wait1^.n:=wait2;
                                wait1:=wait2;
                                end;
                        tot:=tot+num;
                        end;
                end;
                if not(quit) and (okansi) and (lasttot<>tot) then begin
                        lasttot:=tot;
                        ansig(36,14);
                        sprompt('                ');
                        setc(15 or (3 shl 4));
                        ansig(36,14);
                        if (tot=0) then sprompt('None') else
                        sprompt(cstr(tot));
                end;
                bb:=UTAG^.GetNext;
                if (mbopened) then MbClose;
        end;
        UTAG^.Done;
        dispose(UTAG);
    if (okansi) then ansig(1,17) else nl;
    if ((newm) and not(qquit)) then
        if pynq(gstring(572)) then
                begin
                bb:=0;quit:=false;
                wait1:=wait;
                while ((wait1<>NIL) and not(quit)) do begin
                        changeboard(wait1^.base); 
                        sprompt(gstring(34));
                        wrscan(1,board,quit);
                        nl;
                        wait1:=wait1^.n;
                end;
                end;
    if ((not newm) and not(qquit)) then begin
    sprompt(gstring(35));
    end;
    end;
    board:=oldboard;
    if (mbopened) then mbclose;
    wait1:=wait;
    while (wait1<>NIL) do begin
        wait2:=wait1^.n;
        dispose(wait1);
        wait1:=wait2;
    end;
end;

Procedure Waitscan(t:integer;mstr:string);
var 
abort,next,quit:boolean;
oldboard,num,x:integer;
s2,quest:string;

begin
    abort:=false;next:=false;oldboard:=0;
    if ((mstr='C') or (mstr<>'G') and ((mstr='0') or ((mstr<>'0') and (value(mstr)<>0)))) then 
        begin
        nl;sprompt('%070%Scanning ');
        if (mstr<>'C') then begin
                                oldboard:=board;
                                if (board<> value(mstr)) then begin
                                        changeboard(value(mstr));
                                end;
        end;
        sprompt('[%140%'+cstr(board)+'%070%] %140%'+ memboard.name+'%070% : %040%'+'Scanning');
        quit:=false;
        wscan(board,num,quit);
        for x:=1 to 8 do sprompt(^H' '^H);
        if num<>0 then
                sprompt('%040%'+cstr(num))
        else
                sprompt('%040%None');
        sprint(' found.');
        nl;
        if (num<>0) then 
                if pynq('%120%Read your messages now? %110%') then
                        wrscan(1,board,next); 
        if oldboard<>0 then board:=oldboard;
        oldboard:=0;
        
    end else
    if (mstr='G') then Waitgscan(t)
    else begin
        nl;
        case t of
                1:s2:='new messages to you';
                2:s2:='messages to you';
                3:s2:='messages from you';
        end;
        if ((curmenu=3) or (curmenu=4)) then
                quest:='%120%Scan for '+s2+'? %110%' else
                quest:='%120%Scan all bases for '+s2+'? %110%';
        if pynq(quest) then waitgscan(t) else
                if (not(curmenu=3) and
                        not(curmenu=4)) then
                begin
                nl;sprompt('%070%Scanning ');
                sprompt('[%140%'+cstr(board)+'%070%] %140%'+ memboard.name+'%070% : %040%Scanning');
                quit:=false;
                wscan(board,num,quit);
                for x:=1 to 8 do sprompt(^H' '^H);
                if num<>0 then
                        sprompt('%040%'+cstr(num))
                else
                        sprompt('%040%None');
                sprint(' found.');
                nl;
                if (num<>0) then 
                        if pynq('%120%Read your messages now? %110%') then
                                wrscan(1,board,next); 
        end;
    end;
end; 

procedure msgsearch;
var searchtext:string[40];
    sfrom,sto,ssubj,stext:boolean;
    sbases:byte;  { 0 current base 1 current conference 2 all conferences }
    ssearch,newsearch,quit:boolean;
    x,oldboard:integer;
    readtype:byte;
    omconf:byte;
    c:char;
    real,alias:string[36];
    cn:longint;

    function sertype:string;
    begin
        case sbases of
                0:sertype:='Current base';
                1:sertype:='Current conference';
                2:sertype:='All conferences';
        end;
    end;

    function newtype:string;
    begin
    if (newsearch) then begin
        newtype:='New';
    end else begin
        newtype:='All';
    end;
    end;

    function toyou:boolean;
    var toname:string;
    begin
        toname:=allcaps(CurrentMSG^.Getto);
        if (toname=real) or (toname=alias) then toyou:=TRUE else toyou:=FALSE;
    end;

    function fromyou:boolean;
    var fromname:string;
    begin
        fromname:=allcaps(CurrentMSG^.Getfrom);
        if (fromname=real) or (fromname=alias) then fromyou:=TRUE else fromyou:=FALSE;
    end;

    procedure gotofirst;
    begin
    case readtype of
        0:currentMSG^.Seekfirst(cn);
        1:begin
                currentmsg^.seekfirst(cn);
                if (currentmsg^.seekfound) then currentmsg^.msgstartup;
                while (currentmsg^.seekfound) and not(toyou) and not(fromyou) do
                begin
                currentmsg^.seeknext;
                if (currentmsg^.seekfound) then currentmsg^.msgstartup;
                end;
          end;
    end;
    end;

    procedure gotonext;
    begin
    case readtype of
        0:CurrentMSG^.SeekNext;
        1:begin
                Currentmsg^.SeekNext;
                if (currentmsg^.seekfound) then currentmsg^.msgstartup;
                while (currentmsg^.seekfound) and not(toyou) and not(fromyou) do
                begin
                currentmsg^.seeknext;
                if (currentmsg^.seekfound) then currentmsg^.msgstartup;
                end;
          end;
    end;
    end;

    procedure gotoprior;
    begin
    case readtype of
        0:currentMSG^.SeekPrior;
        1:begin
                Currentmsg^.SeekPrior;
                if (currentmsg^.seekfound) then currentmsg^.msgstartup;
                while (currentmsg^.seekfound) and not(toyou) and not(fromyou) do
                begin
                currentmsg^.seekPrior;
                if (currentmsg^.seekfound) then currentmsg^.msgstartup;
                end;
          end;
    end;
    end;


    procedure searchbase;
    var ok:boolean;
        s:string;
        skip:boolean;
    begin
    skip:=FALSE;
    sprompt(gstring(676));
    if (mbopened) then mbclose;
    mbopencreate;
    if not(mbopened) then begin
        sprompt(gstring(677));
        exit;
    end;
    if (newsearch) then cn:=CurrentMSG^.GetLastRead(thisuser.userid)+1 else
    cn:=1;
    gotofirst;
    while (CurrentMSG^.SeekFound) and not(hangup) and not(quit) and
    not(skip) do begin
        searchaction:=0;
        CurrentMSG^.MsgStartup;
        cn:=CurrentMSG^.GetMsgNum;
        ok:=FALSE;
        if (searchtext='') then ok:=TRUE;
        if (sfrom) and not(ok) then if (pos(searchtext,allcaps(CurrentMSG^.GetFrom))<>0) then ok:=TRUE;
        if (sto) and not(ok) then if (pos(searchtext,allcaps(CurrentMSG^.GetTo))<>0) then ok:=TRUE;
        if (ssubj) and not(ok) then if (pos(searchtext,allcaps(CurrentMSG^.GetSubj))<>0) then ok:=TRUE;
        if (stext) and not(ok) then begin
                CurrentMSG^.MsgTxtStartup;
                while not(CurrentMSG^.EOM) and not(ok) and not(hangup) and
                not(quit) and not(skip) do begin
                        s:=CurrentMSG^.GetNoKludgeStr(80);
                        while (CurrentMSG^.WasWrap) and not(currentmsg^.EOM) and (length(s)<75) do begin
                          s:=s+' '+CurrentMSG^.GetNoKludgeStr(78-Length(s));
                        end;
                        if (pos(searchtext,allcaps(s))<>0) then ok:=TRUE;
                        wkey(quit,skip);
                end;
        end;
        if (ok) and not(quit) and not(skip) then begin
                readmessages(cn,0,FALSE,FALSE,quit);
        end;
        if not(quit) and not(skip) then begin
        if (mbopened) then begin
                if (searchaction=0) then gotonext else gotoprior;
        end else skip:=TRUE;
        if (searchaction=1) and not(CurrentMSG^.Seekfound) then gotofirst;
        wkey(quit,skip);
        if (searchaction=3) then skip:=TRUE;
        end;
    end;
    if (mbopened) then mbclose;
    sprompt(gstring(677));
    end;

begin
real:=allcaps(thisuser.realname);
alias:=allcaps(thisuser.name);
if (private in memboard.mbpriv) and not(mso) then readtype:=1 else readtype:=0;
quit:=false;
searching:=TRUE;
searchaction:=0;
searchtext:='';
sfrom:=FALSE;
sto:=FALSE;
ssubj:=FALSE;
stext:=TRUE;
newsearch:=FALSE;
ssearch:=FALSE;
sbases:=0;
repeat
sprompt(gstring(665));
sprint(gstring(666)+searchtext);
sprint(gstring(667)+syn(sfrom));
sprint(gstring(668)+syn(sto));
sprint(gstring(669)+syn(ssubj));
sprint(gstring(670)+syn(stext));
sprint(gstring(671)+newtype);
sprint(gstring(672)+sertype);
sprompt(gstring(673));
onek(c,gstring(674));
if (hangup) then exit;
case pos(c,gstring(674)) of
        1:begin
                sprompt(gstring(675));
                defaultst:=searchtext;
                inputd(searchtext,40);
          end;
        2:begin
                sfrom:=not(sfrom);
          end;
        3:begin
                sto:=not(sto);
          end;
        4:begin
                ssubj:=not(ssubj);
          end;
        5:begin
                stext:=not(stext);
          end;
        6:begin
                newsearch:=not(newsearch);
          end;
        7:begin
                inc(sbases);
                if (sbases=3) then sbases:=0;
          end;
        8:ssearch:=TRUE;
        9:quit:=TRUE;
end;
until (ssearch) or (hangup) or (quit);
if not(hangup) and not(quit) then begin
if (sbases=0) then begin
        searchbase;
end else begin
        x:=0;
        oldboard:=board;
        omconf:=mconf;
        if (sbases=2) then mconf:=0;
        while (x<=numboards) and not(hangup) and not(quit) do begin
                if (board<>x) then changeboard(x);
                if (board=x) then begin
                        searchbase;
                end;
                inc(x);
        end;
        mconf:=omconf;
        board:=oldboard;
end;
end;
searching:=FALSE;
end;

end.
