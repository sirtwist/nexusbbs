Program MsgImprt;
{$I MKB.DEF}

Uses misc,ivst,MKGlobT,miscttt5,crt,myio,DOS,cmdlin,MKFile, MKString, MKMsgAbs, MKOpen,  MKDos;
{$I NEXUS.INC}

Var

  temp : string;
  netf : file of fidorec;
  net  : fidorec;
  done : boolean;
  msgok : boolean;
  ver  : string;
  cnt  : integer;
  orgin : string[50];
  fnode : string[15];
  Msg  : AbsMsgPtr;                      {Pointer to msg object}
  MsgAreaId: String[128];              {Message Area Id to post msg in}
  MsgFrom: String[50];                 {Author of the message}
  MsgTo: String[50];                   {Who the message is to}
  MsgSubj: String[100];                {Subject of the message}
  OrigAddr: AddrType;                  {Fido-style originating address}
  DestAddr: AddrType;                  {Fido-style destination address}
  MsgFileName: String;                 {File name with message text}
  WildName: String;                    {Search file name given for msg text}
  MsgType: MsgMailType;                {Type of msg to be written}
  Priv: Boolean;                       {Is message private}
  Del: Boolean;                        {Erase msg text file afterwards}
  DoEcho: Boolean;                     {Set to be echoed flag}
  TxtSearch: FindObj;                  {wildcard processor}
  NexusDir:string;
  MFile:file of matrixrec;
  MRec:matrixrec;
  mbf: file of boardrec;
  mb: boardrec;
  pday: string;
  pmonth: string;

procedure cfgheader;
begin
writeln('nxPOST v'+ver+' - Message Autoposter for Nexus Bulletin Board System');
writeln('(c) Copyright 1998-2001 George A. Roberts IV. All rights reserved.');
writeln('(c) Copyright 1995-97 Internet Pro''s Network LLC. All rights reserved.');
writeln;
end;

Function IntToStr(Num: longint): String;
{ Integer value to string }
Var st: string;
Begin
  Str(Num,St);
  IntToStr := st;
End;

procedure help;
  Begin
  writeln('Syntax:  NXPOST [drive:][\path\]filename.ext <required commands> [options]');
  writeln;
  writeln('     [drive:][\path\]filename.ext is the text file for message text');
  writeln;
  writeln('Required Commands:    -F<FromName>        -T<ToName>');
  writeln('                      -S<Subject>         -A<BaseTagName>');
  writeln;
  writeln('Text for the required commands may be in either of the following two formats:');
  writeln;
  writeln('1) One word (no quotes)                 example: -TAll');
  writeln('2) Two or more words (WITH quotes)      example: -S"Test Message"');
  writeln;
  writeln('Options:     -N<DestAddr>    = Send netmail to address');
  WriteLn('             -P              = Mark message as private');
  writeln('             -R              = Remove (delete) text file after processing');
  writeln('             -D<DayNumber>   = Post message on this day of the month only');
  writeln('             -M<MonthNumber> = Post message during this month only');
  Halt;
  End;


Procedure InitMsgValues;               {initial message values to defaults}
  Begin
  MsgAreaId := '';
  MsgFrom := 'nxPOST v'+ver;
  MsgTo := 'All';
  MsgSubj := 'Autoposted Message';
  WildName := 'MESSAGE.TXT';
  MsgType := mmtNormal;
  DoEcho := False;
  Priv := False;
  Del := False;
  FillChar(OrigAddr, SizeOf(OrigAddr), #0);
  FillChar(DestAddr, SizeOf(DestAddr), #0);
  orgin := '';
  fnode := '';
  End;


Procedure FixSpaces(Var St: String);   {change underscores to spaces}
  Var
    i: Word;

  Begin
  For i := 1 to Length(St) Do
    Begin
    If St[i] = '_' Then
      St[i] := ' ';
    End;
  End;

procedure msgid;
begin
 Msg^.DoKludgeLn(#1+'MSGID: '+ pointedaddrstr(OrigAddr)+ ' '+ lower(hexlong(getdosdate)));
end;


Procedure ProcessCmdLine;              {Process command line params}
  Var
    i: Word;
    TmpStr: String;
    cnt  : integer;
    done : boolean;

Begin
done := false;

if (ParamCount < 1) or (paramstr(1) = '?') or (is_param('?')) then begin
      help;
      halt;
end;

IF exist(wildname) then begin
        cwrite('%030%Text file : %150%'+wildname+#13#10);
        writeln;
end else begin
        cwrite('%120%ERROR: Message text file not found!'+#13#10);
end;

if is_param('A') = true then begin
        nexusdir:=bslash(TRUE,GetEnv('NEXUS'));
        if (nexusdir='') then begin
                writeln('You must have your NEXUS environment variable set for nxPOST to run.');
                halt;
        end;
        assign(mfile,nexusdir+'MATRIX.DAT');
        {$I-} reset(MFile); {$I+}
        if IOResult <> 0 then begin
         writeln('Error reading '+nexusdir+'MATRIX.DAT');
         halt;
        end;
        read(MFile,MRec);
        close(MFile);


        cwrite('%030%Loading message base...');
        assign(mbf,mrec.gfilepath+'MBASES.DAT');
        {$I-} reset(mbf); {$I+}
        if (ioresult<>0) then begin
                cwrite('%120%ERROR!'+#13#10);
                halt;
        end;
        cnt := 0;
        cnt := 0;
        msgok := false;
        done:=FALSE;
        while not(done) and not(eof(mbf)) do begin
                seek(mbf,cnt);
                read(mbf,mb);
                if uppercase(rtrim(ltrim(mb.nettagname))) = uppercase(ltrim(rtrim(param_text('A')))) then
                begin
                        done := true;
                        msgok := true;
                end else inc(cnt);
        end;

        if not(msgok) then begin
         cwrite('%120%ERROR!  Message Base not found!'+#13#10);
         halt(1);
        end;

        seek(mbf,cnt);
        read(mbf,mb);
        close(mbf);

        cwrite('%150%finished.'+#13#10);
        writeln;
        cwrite('%030%Base      : %150%'+mb.name+' ');



        if (mb.mbtype = 1) then begin
         DoEcho := True;
         MsgType := mmtEchomail;
         cwrite('%030%(%150%ECHOMAIL%030%)'+#13#10);
         end;

        if (mb.mbtype = 0) then begin
          cwrite('%030%(%150%LOCAL%030%)'+#13#10);
          MsgType := mmtNormal;
         end;


        if (mb.mbtype = 2) or (mb.mbtype = 3) then begin
         MsgType := mmtNetmail;
         cwrite('%030%(%150%NETMAIL%030%)'+#13#10);
        end;

  assign(netf,mrec.gfilepath+'NETWORK.DAT');
  {$i-}reset(netf);{$i+}
  read(netf,net);
  close(netf);

if (mb.mbtype<>0) then begin
  done := false;
  cnt := 1;
  repeat
        if (mb.address[cnt]) then done:=TRUE;
        if not(done) then inc(cnt);
        if (cnt=31) then begin
                done:=TRUE;
                cnt:=1;
        end;
  until (done);


  OrigAddr.zone := net.address[cnt].zone;
  OrigAddr.net  := net.address[cnt].net;
  OrigAddr.node := net.address[cnt].node;
  OrigAddr.point := net.address[cnt].point;
  fnode := addrstr(origaddr);

end else begin

  OrigAddr.zone := net.address[1].zone;
  OrigAddr.net  := net.address[1].net;
  OrigAddr.node := net.address[1].node;
  OrigAddr.point := net.address[1].point;
  fnode := addrstr(origaddr);

end;



if (mb.mbtype=2) or (mb.mbtype = 3) then begin
 if is_param('N') = true then begin
  If not ParseAddr(param_text('D'), OrigAddr, DestAddr) then begin
          writeln('ERROR! Netmail ToAddress is in an incorrect format!');
          doecho := false;
  end;
  end;
end;




        if mb.messagetype = 1 then
        begin
         MsgAreaId := 'S'+mb.msgpath+mb.filename;
        end;

        if mb.messagetype = 2 then
        begin
         MsgAreaId := 'J'+mb.msgpath+mb.filename;
        end;

        if mb.messagetype = 3 then
        begin
         MsgAreaId := 'F'+mb.msgpath;
        end;
    end;

if is_param('D') = true then
begin

 temp := tch(param_text('D'));
 if temp <> copy(misc.date,4,2) then
 begin
  writeln('Date specified does not match current date for posting.  Message aborted...');

  halt;
 end;

end;

if is_param('M') = true then
begin

 temp := tch(param_text('M'));
 if temp <> copy(misc.date,1,2) then
 begin
  writeln('Month specified does not match current month for posting.  Message aborted...');
  halt;
 end;

end;

if is_param('F') = true then
 begin
  MsgFrom := param_text('F');
  cwrite('%030%From      : %150%'+msgfrom+#13#10);
end;

if is_param('T') = true then
 begin
  Msgto := param_text('T');
  cwrite('%030%To        : %150%'+msgto+#13#10);
end;

if is_param('S') = true then
 begin
  Msgsubj := param_text('S');
  cwrite('%030%Subject   : %150%'+msgsubj+#13#10);
end;

if is_param('P') = true then
 begin
  priv := true;
end;

if is_param('R') = true then
 begin
  DEL := true;
end;

End;


Procedure ProcessMsgFile;              {Process text from message file}
  Var
    TF: TFile;                         {Use TFile object for ease of use}
    TmpStr: String;

Begin
  writeln;
  cwrite('%030%Processing message... ');
  TF.Init;

  If TF.OpenTextFile(MsgFileName) Then
    Begin

    If OpenMsgArea(Msg, MsgAreaId) Then
      Begin
      Msg^.StartNewMsg;

      msg^.setrefer(0);
      msg^.setseealso(0);
      msg^.setcost(0);
      msg^.setnextseealso(0);
      Msg^.SetDate(DateStr(GetDosDate));
      Msg^.SetTime(TimeStr(GetDosDate));
      Msg^.SetLocal(True);
      Msg^.SetEcho(DoEcho);
      Msg^.SetMailType(MsgType);

      msgid;

      IF (mb.mbtype = 2) or (mb.mbtype = 3) then
      begin
      Msg^.DoKludgeLn(#1+'INTL '+ inttostr(destAddr.zone) +':'+inttostr(destAddr.net) +'/'+inttostr(destAddr.node)+
      '.'+ inttostr(destAddr.point) +' '+fnode);
      end;

      Msg^.DoKludgeLn(#1+'PID: nxPOST '+ver);

      IF (mb.mbtype = 2) or (mb.mbtype = 3) then
      begin
        Msg^.DoKludgeLn(#1+'FLAGS DIR');
      end;

      TmpStr := TF.GetString;
      While TF.StringFound Do
        Begin
        If Length(TmpStr) > 0 Then
          Begin
          Case TmpStr[1] of
            '%': Begin
                 Case UpCase(TmpStr[2]) Of
                   'F': MsgFrom := Copy(TmpStr, 3, 50);
                   'S': MsgSubj := Copy(TmpStr, 3, 100);
                   'T': MsgTo := Copy(TmpStr, 3, 50);
                   'P': Priv := True;
                   'D': If ParseAddr(Copy(TmpStr, 3, 128), DestAddr, OrigAddr) Then;
                   Else
                     Begin
                     Msg^.DoStringLn(TmpStr);
                     End;
                   End;
                 End;
            #1:  Begin
                 Msg^.DoKludgeLn(TmpStr);
                 End;
            Else
              Begin
              Msg^.DoStringLn(TmpStr);
              End;
            End;
          End
        Else
          Begin
          Msg^.DoStringLn('');
          End;
        TmpStr := TF.GetString;
        End;

      FixSpaces(MsgFrom);
      Msg^.SetFrom(MsgFrom);
      FixSpaces(MsgTo);
      Msg^.SetTo(MsgTo);
      FixSpaces(MsgSubj);
      Msg^.SetSubj(MsgSubj);
      Msg^.SetPriv(Priv);
      Msg^.SetOrig(OrigAddr);
      Msg^.SetDest(DestAddr);

  if doecho = true then
  begin
  Msg^.DoStringLn(' ');
  Msg^.DoStringLn(#13+#10);
  Msg^.DoStringLn('--- nxPOST v'+ver);
  Msg^.dostringln(' * Origin: '+net.origins[mb.origin] + ' ('+fnode+')');


  end
  else
  begin
  Msg^.DoStringLn(' ');
  Msg^.DoStringLn(' ');
  Msg^.DoStringLn('--- nxPOST v'+ver);
  end;

      If Msg^.WriteMsg <> 0 Then
        cwrite('%120%ERROR! Cannot save message!'+#13#10)
      Else
        cwrite('%150%saved.'+#13#10);
      If CloseMsgArea(Msg) Then;
      End
    Else begin
      cwrite('%120%ERROR! Cannot open message base %120%'+msgareaid+'%120%!'+#13#10);
    end;
    If TF.CloseTextFile Then;
    End
  Else begin
    cwrite('%120%ERROR! Cannot open message text file %150%'+msgfilename+'%120%!'+#13#10);
  end;
  TF.Done;
  If Del Then Begin
    cwrite('%030%Erasing %150%'+msgfilename+'%030%... ');
    If EraseFile(MsgFileName) Then begin
      cwrite('%150%finished.'+#13#10);
    end else begin
      cwrite('%120%ERROR!'+#13#10);
    end;
  End;
  End;



Begin
filemode:=66;
done := false;
ver := '1.35';
clrscr;
cfgheader;
InitMsgValues;

wildname := paramstr(1);
if (pos('.',wildname)=0) then wildname:=wildname+'.TXT';
wildname:=allcaps(fexpand(wildname));

ProcessCmdLine;

IF exist(wildname) then
begin
TxtSearch.Init;
TxtSearch.FFirst(WildName);
While TxtSearch.Found Do
  Begin
  MsgFileName := TxtSearch.GetFullPath;
  ProcessMsgFile;
  TxtSearch.FNext;
  End;

TxtSearch.Done;
end;

END.
