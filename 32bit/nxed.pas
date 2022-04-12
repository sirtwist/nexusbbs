{$A+,B+,D-,E+,F+,G-,I+,L-,N-,O-,R+,S+,V-}
{$M 65400,50000,200000}      { Memory Allocation Sizes }
program nxED;

uses dos,crt,myio,mkopen,mkmsgabs,misc,mkglobt,spawno,mkstring,mkdos,fidonet,
        ivhelp2,tagunit,keyunit;

type msgptr=^msgtype;
     msgtype=array[1..2,1..200] of string[80];

const viewkludge:byte=1;
      checknewmsgs:boolean=FALSE;
     
var cmsg:absmsgptr;
    currentbase:integer;
    top:integer;
    numboards:integer;
    oldwin:windowrec;
    oldy:integer;

const isdir:boolean=FALSE;

procedure endprogram;
begin
removewindow(oldwin);
if oldy=25 then writeln;
gotoxy(1,oldy);
textcolor(7);
textbackground(0);
cursoron(TRUE);
end;

procedure setuptags;
var UTAG:^TagRecordOBJ;
begin
new(utag);
                if (UTAG=NIL) then begin
                        displaybox('Unable to get message tags!',3000);
                        exit;
                end;
                UTAG^.Init(adrv(systat.userpath)+'00000001.NMT');
                UTAG^.Maxbases:=Numboards;
                UTAG^.SortTags(adrv(systat.gfilepath)+'NXED.TMT',1);
                UTAG^.Done;
                Dispose(UTAG);
end;

function getmsgbase(ii:integer):integer;
var cur:integer;
    tseek:integer;
    firstlp,lp,lp2:listptr;
    ii2,x:integer;
    rt:returntype;
    UTAG:^TagRecordOBJ;
    w2:windowrec;
    done3:boolean;

  function Format2(b:byte):string;
  var s:string;
  begin
  case b of
        1:s:='Squish';
        2:s:='JAM   ';
        3:s:='*.MSG ';
  end;
  format2:=s;
  end;

  function Btype(b:byte):string;
  var s:string;
  begin
  case b of
        0:s:='Local          ';
        1:s:='Echomail       ';
        2:s:='Netmail        ';
        3:s:='Internet E-Mail';
  end;
  Btype:=s;
  end;

begin
new(utag);
                if (UTAG=NIL) then begin
                        displaybox('Unable to get message tags!',3000);
                        exit;
                end;
                UTAG^.Init(adrv(systat.userpath)+'00000003.NMT');
                UTAG^.Maxbases:=Numboards;
                tseek:=UTAG^.GetFirst(adrv(systat.gfilepath)+'NXED.TMT');
                                new(lp);
                                lp^.p:=NIL;
                                if (tseek=-1) then
                                lp^.list:='No bases tagged.'
                                else begin
                                seek(bf,tseek);
                                read(bf,memboard);
                                lp^.list:=mln(cstr(tseek),5)+mln(memboard.name,45)+'  %070%'+
                                        Btype(memboard.mbtype)+'   '+format2(memboard.messagetype);
                                tseek:=UTAG^.GetNext;
                                end;
                                firstlp:=lp;
                                while (tseek<>-1) do begin
                                seek(bf,tseek);
                                read(bf,memboard);
                                new(lp2);
                                lp2^.p:=lp;
                                lp^.n:=lp2;
                                lp2^.list:=mln(cstr(tseek),5)+mln(memboard.name,45)+' %070% '+
                                        Btype(memboard.mbtype)+'   '+format2(memboard.messagetype);
                                lp:=lp2;
                                tseek:=UTAG^.GetNext;
                                end;
                                lp^.n:=NIL;
                                removewindow(w);
                                done3:=false;
                                cur:=ii+1;
                                repeat
                                for x:=1 to 100 do rt.data[x]:=-1;
                                lp:=firstlp;
  listbox_escape:=TRUE;
  listbox_enter:=TRUE;
  listbox_insert:=FALSE;
  listbox_delete:=FALSE;
  listbox_tag:=FALSE;
  listbox_move:=FALSE;
  listbox_goto:=TRUE;
  listbox_goto_offset:=1;
  listbox_allow_extra:=FALSE;
  listbox_allow_extra_func:=FALSE;
  listbox_extrakeys:='';
  listbox_extrakeys_func:='';
  listbox_f10:=FALSE;
                                listbox(w2,rt,top,cur,lp,1,1,79,24,3,0,8,'Message Bases','',FALSE);
                                textcolor(7);
                                textbackground(0);
                                case rt.kind of
{                                        0:begin
                                                c3:=chr(rt.data[100]);
                                                removewindow(w2);
                                                checkkey(c3);
                                                rt.data[100]:=-1;
}                                                
                                        1:begin
                                                if (rt.data[1])<>-1 then begin
                                                                ii:=rt.data[1]-1;
                                                                done3:=TRUE;
                                                                lp:=firstlp;
                                                                while (lp<>NIL) do begin
                                                                        lp2:=lp^.n;
                                                                        dispose(lp);
                                                                        lp:=lp2;
                                                                end;
                                                end;
                                          end;
                                        2:begin
                                                ii:=-1;
                                                lp:=firstlp;
                                                while (lp<>NIL) do begin
                                                        lp2:=lp^.n;
                                                        dispose(lp);
                                                        lp:=lp2;
                                                end;
                                                done3:=TRUE;
                                        end;
                               end;
                               until (done3);
                               UTAG^.Done;
                               dispose(utag);
        getmsgbase:=ii;
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

function getmsgbase2(ii:integer):integer;
var cur:integer;
    newmsgs:string;
    firstlp,lp,lp2:listptr;
    ii2,x:integer;
    rt:returntype;
    w2:windowrec;
    done3:boolean;
    c3:char;

  function Format2(b:byte):string;
  var s:string;
  begin
  case b of
        1:s:='Squish';
        2:s:='JAM   ';
        3:s:='*.MSG ';
  end;
  format2:=s;
  end;

  function Btype(b:byte):string;
  var s:string;
  begin
  case b of
        0:s:='Local          ';
        1:s:='Echomail       ';
        2:s:='Netmail        ';
        3:s:='Internet E-Mail';
  end;
  Btype:=s;
  end;

begin
if (checknewmsgs) then displaybox2(w2,'Scanning for bases with new messages...');
                                new(lp);
                                seek(bf,0);       
                                read(bf,memboard);
newmsgs:=' ';
if (checknewmsgs) then begin
if (OpenOrCreateMsgArea(cmsg,GetMbType+GetMbPath+GetMbFileName)) then begin
        if (cmsg^.getlastread(1)+1<=cmsg^.gethighmsgnum) then
        newmsgs:='%120%*%070%' else newmsgs:=' ';
        if not(CloseMsgArea(cmsg)) then displaybox('Error closing Message Base.',3000);
end;
end;
                                ii2:=0;
                                lp^.p:=NIL;
                                lp^.list:=newmsgs+mln(cstr(ii2),5)+mln(memboard.name,45)+'  %070%'+
                                        Btype(memboard.mbtype)+'  '+format2(memboard.messagetype);
                                firstlp:=lp;
                                while (not(eof(bf))) do begin
                                inc(ii2);
                                read(bf,memboard);
newmsgs:=' ';
if (checknewmsgs) then begin
if (OpenOrCreateMsgArea(cmsg,GetMbType+GetMbPath+GetMbFileName)) then begin
        if (cmsg^.getlastread(1)+1<=cmsg^.gethighmsgnum) then
        newmsgs:='%120%*%070%' else newmsgs:=' ';
        if not(CloseMsgArea(cmsg)) then displaybox('Error closing Message Base.',3000);
end;
end;
                                new(lp2);
                                lp2^.p:=lp;
                                lp^.n:=lp2;
                                lp2^.list:=newmsgs+mln(cstr(ii2),5)+mln(memboard.name,45)+' %070% '+
                                        Btype(memboard.mbtype)+'  '+format2(memboard.messagetype);
                                lp:=lp2;
                                end;
if (checknewmsgs) then begin
     removewindow(w2);
     checknewmsgs:=FALSE;
     newmsgs:='New messages shown: * marks bases with new messages'
end else newmsgs:='New messages not shown';
                                lp^.n:=NIL;
                                removewindow(w);
                                done3:=false;
                                cur:=ii+1;
                                repeat
                                for x:=1 to 100 do rt.data[x]:=-1;
                                lp:=firstlp;
                                listbox_f10:=FALSE;
  listbox_escape:=TRUE;
  listbox_enter:=TRUE;
  listbox_insert:=FALSE;
  listbox_delete:=FALSE;
  listbox_tag:=FALSE;
  listbox_move:=FALSE;
  listbox_goto:=TRUE;
  listbox_goto_offset:=1;
  listbox_allow_extra:=FALSE;
  listbox_allow_extra_func:=TRUE;
  listbox_extrakeys:='';
  listbox_extrakeys_func:=chr(59)+chr(49);
  listbox_help:='%140%F1%070%=Help Contents ';
  listbox_bottom:='%140%Alt-N%070%=New Messages ';
                                listbox(w2,rt,top,cur,lp,1,1,79,24,3,0,8,'nxED: Message Bases',newmsgs,FALSE);
  listbox_help:='';
                                textcolor(7);
                                textbackground(0);
                                case rt.kind of
{                                        0:begin
                                                c3:=chr(rt.data[100]);
                                                removewindow(w2);
                                                checkkey(c3);
                                                rt.data[100]:=-1;
                                          end;}
                                         0:begin
                                                c3:=chr(rt.data[100]);
                                                case c3 of
                                                    #49:begin
                                                          ii:=rt.data[1]-1;
                                                          checknewmsgs:=TRUE;
                                                          lp:=firstlp;
                                                          while (lp<>NIL) do begin
                                                             lp2:=lp^.n;
                                                             dispose(lp);
                                                             lp:=lp2;
                                                          end;
                                                          done3:=TRUE;
                                                        end;
                                                    #59:begin
                                                       helppath:=systat.gfilepath;
                                                       showhelp('NXED',3,1,1,79,24,3,0,8,FALSE);
                                                       cursoron(FALSE);
                                                    end;
                                                end;
                                                rt.data[100]:=-1;
                                           end;
                                        1:begin
                                                if (rt.data[1])<>-1 then begin
                                                                ii:=rt.data[1]-1;
                                                                done3:=TRUE;
                                                                lp:=firstlp;
                                                                while (lp<>NIL) do begin
                                                                        lp2:=lp^.n;
                                                                        dispose(lp);
                                                                        lp:=lp2;
                                                                end;
                                                end;
                                          end;
                                        2:begin
                                                ii:=-1;
                                                lp:=firstlp;
                                                while (lp<>NIL) do begin
                                                        lp2:=lp^.n;
                                                        dispose(lp);
                                                        lp:=lp2;
                                                end;
                                                done3:=TRUE;
                                        end;
                               end;
                               until (done3);
        getmsgbase2:=ii;
end;

procedure opensystat;
var systatf:file of MatrixREC;
    err:integer;
begin
assign(systatf,nexusdir+'\MATRIX.DAT');
filemode:=66;
{$I-} reset(systatf); {$I+}
err:=ioresult;
if (err<>0) then begin
        displaybox('Error reading '+nexusdir+'\MATRIX.DAT - Error '+cstr(err),3000);
        halt;
end;
read(systatf,systat);
close(systatf);
end;

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

        procedure showflags;
        var s2:string;
        begin
    s2:='';
    if (cmsg^.islocal) then s2:='Loc ';
    if not(public in memboard.mbpriv) then
    if (cmsg^.isPriv) then s2:=s2+'Pvt ';
    if (memboard.mbtype in [2,3]) then begin
    if (cmsg^.isHold) then s2:=s2+'Hold ';
    if (cmsg^.isCrash) then s2:=s2+'Crash ';
    if (cmsg^.isKillsent) then s2:=s2+'Kill ';
    if (cmsg^.isSent) then s2:=s2+'Sent ';
    if (cmsg^.isFattach) then s2:=s2+'FAtt ';
    if (cmsg^.isFileReq) then s2:=s2+'FReq ';
    if (cmsg^.isRcvd) then s2:=s2+'Rcvd ';
    if (isDir) then s2:=s2+'Dir ';
    if (cmsg^.isreqrct) then s2:=s2+'RRR ';
    if (cmsg^.isretrct) then s2:=s2+'Recp';
    end;
    textcolor(12);
    textbackground(0);
    gotoxy(30,1);
    write(mrn(s2,48));
        end;

procedure replymsg(x:integer);
var s,s2,s3,toname,fromname,subject:string;
    t,t2:text;
    i2:integer;
    stripit,rep:boolean;
    dadd,oadd:addrtype;
    add2:addrtype;
    fidof:file of fidorec;
    fidor:fidorec;
    replytonum:integer;
    add:integer;
    c:char;
    MSGIDLine:STRING;
    ftime,ftime2:longint;

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

        procedure clearwindow;
        begin
        window(1,6,80,24);
        clrscr;
        window(1,1,80,24);
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


        procedure showheader;
        var 
            s2:string;
        begin
        window(1,1,80,24);
        gotoxy(1,1);
        clreol;
        textcolor(3);
        write('Date        : ');
        textcolor(15);
        s2:=date;
        s2[3]:='-';
        s2[6]:='-';
        write(s2+' '+copy(time,1,5));
        showflags;
        gotoxy(1,2);
        textcolor(3);
        clreol;
        write('From        : ');
        textcolor(15);
        if (mbrealname in memboard.mbstat) then 
           fromname:=thisuser.realname else
           fromname:=thisuser.name;
        write(mln(fromname,36)+' ');
        if (memboard.mbtype in [2,3]) then begin
          write(addrstr(oadd));
        end;
        gotoxy(1,3);
        textcolor(3);
        clreol;
        write('To          : ');
        textcolor(15);
        write(mln(toname,36)+' ');
        if (memboard.mbtype in [2,3]) and (dadd.zone<>0) then begin
        write(addrstr(dadd));
        end;
        gotoxy(1,4);
        textcolor(3);
        clreol;
        write('Subject     : ');
        textcolor(15);
        write(subject);
        gotoxy(1,5);
        textcolor(3);
        write('컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�');
        gotoxy(15,2);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=false;
                                        infield_numbers_only:=FALSE;
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        infielde(fromname,36);
                                        if (infield_escape_exited) then exit;
if (memboard.mbtype in [2,3]) then begin
        gotoxy(52,2);
        s2:=addrstr(oadd);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=false;
                                        infield_numbers_only:=FALSE;
                                        infield_address:=TRUE;
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        infielde(s2,20);
                                        infield_address:=FALSE;
                                        if (infield_escape_exited) then exit;
        conv_netnode(s2,oadd.zone,oadd.net,oadd.node,oadd.point);
end;
        gotoxy(15,3);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=false;
                                        infield_numbers_only:=FALSE;
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        infielde(toname,36);
                                        if (infield_escape_exited) then exit;
if (memboard.mbtype in [2,3]) then begin
        gotoxy(52,3);
        if (dadd.zone<>0) then
        s2:=addrstr(dadd)
        else
        s2:='';
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=false;
                                        infield_numbers_only:=FALSE;
                                        infield_address:=TRUE;
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        infielde(s2,20);
                                        infield_address:=FALSE;
                                        if (infield_escape_exited) then exit;
        conv_netnode(s2,dadd.zone,dadd.net,dadd.node,dadd.point);
end;
	add:=0;
        if (memboard.mbtype=1) then begin
                x:=1;
                repeat
                        if (memboard.address[x]) then add:=x;
                        inc(x);
                until ((add>0) or (x=31));
                if (add=0) then add:=1;
                oadd.zone:=fidor.address[add].zone;
                oadd.net:=fidor.address[add].net;
                oadd.node:=fidor.address[add].node;
                oadd.point:=fidor.address[add].point;
                cmsg^.SetOrig(oadd);
        end else if (memboard.mbtype in [2,3]) then begin
                x:=1;
                repeat
                if (memboard.address[x]) then
                        if (fidor.address[x].zone=dadd.zone) then add:=x;
                inc(x);
                until ((add>0) or (x=31));
                if (add=0) then add:=1;
                oadd.zone:=fidor.address[add].zone;
                oadd.net:=fidor.address[add].net;
                oadd.node:=fidor.address[add].node;
                oadd.point:=fidor.address[add].point;
                cmsg^.SetOrig(oadd);
        end;
        gotoxy(52,2);
        textcolor(3);
        textbackground(0);
        write(mln(addrstr(oadd),20));
        gotoxy(15,4);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=false;
                                        infield_numbers_only:=FALSE;
                                        infield_maxshow:=55;
                                        infield_show_colors:=TRUE;
                                        infielde(subject,70);
                                        infield_maxshow:=0;
                                        if (infield_escape_exited) then exit;

        window(1,5,80,24);
        end;

        procedure getnetmailflags;
        var w8:windowrec;
            c8:char;
        begin
        setwindow2(w8,2,8,60,17,3,0,8,'Message Flags','ENTER to Continue',TRUE);
        cursoron(FALSE);
        gotoxy(2,2);
        cwrite('%030%[%150%C%030%] Crash               [%150%H%030%] Hold');
        gotoxy(2,3);
        cwrite('%030%[%150%D%030%] Direct              [%150%R%030%] Received');
        gotoxy(2,4);
        cwrite('%030%[%150%K%030%] Kill/Sent           [%150%S%030%] Sent');
        gotoxy(2,5);
        cwrite('%030%[%150%A%030%] File Attach         [%150%V%030%] Return Receipt Request');
        gotoxy(2,6);
        cwrite('%030%[%150%T%030%] Return Receipt      [%150%F%030%] File Request');
        if not(public in memboard.mbpriv) then begin
        gotoxy(2,7);
        cwrite('%030%[%150%P%030%] Private');
        end;
        window(1,1,80,25);
        repeat
        while not(keypressed) do begin
        end;
        c8:=readkey;
        case upcase(c8) of
                'C':Cmsg^.Setcrash(not(cmsg^.iscrash));
                'H':Cmsg^.SetHold(not(cmsg^.ishold));
                'D':isdir:=not(isdir);
                'R':cmsg^.SetRcvd(not(cmsg^.isrcvd));
                'K':cmsg^.SetKillSent(not(cmsg^.iskillsent));
                'S':cmsg^.setsent(not(cmsg^.issent));
                'A':cmsg^.setfattach(not(cmsg^.isfattach));
                'V':cmsg^.setreqrct(not(cmsg^.isreqrct));
                'T':cmsg^.setretrct(not(cmsg^.isretrct));
                'F':cmsg^.setfilereq(not(cmsg^.isfilereq));
                'P':if not(public in memboard.mbpriv) then
                        cmsg^.setpriv(not(cmsg^.ispriv));
        end;
        if not(c8 in [#13,#27]) then showflags;
        until (c8=#13) or (c8=#27);
        removewindow(w8);
        if (c8=#27) then infield_escape_exited:=TRUE;
        cmsg^.SetDirect(isdir);
        cmsg^.setdest(dadd);
        end;

begin
replytonum:=x;
assign(fidof,adrv(systat.gfilepath)+'NETWORK.DAT');
{$I-} reset(fidof); {$I+}
if (ioresult<>0) then begin
        displaybox('Error opening NETWORK.DAT',3000);
        halt;
end;
read(fidof,fidor);
close(fidof);
rep:=(x<>-1);
if (rep) then begin
        cmsg^.seekfirst(x);
        if not(cmsg^.seekfound) then begin
                displaybox('Error reading message!',1500);
                exit;
        end;
end;
begin
clearwindow;
if (rep) then cmsg^.msgstartup;
if (rep) then begin
                toname:=cmsg^.getfrom;
                if (toname='') then
                if (private in memboard.mbpriv) then toname:='' else
                toname:='All';
end else begin
                if (private in memboard.mbpriv) then toname:='' else
                toname:='All';
end;
if (rep) then begin
        MSGIDLine:=cmsg^.GetMSGID;
        subject:=cmsg^.getsubj;
        if (allcaps(copy(subject,1,3))<>'RE:') and (subject<>'') then
            subject:='Re: '+subject;
end else subject:='';
if (memboard.mbtype in [2,3]) then begin
        if (rep) then begin
            cmsg^.getdest(add2);
            oadd:=add2;
        end else begin
                add:=0;
                x:=1;
                repeat
                if (memboard.address[x]) then
                        add:=x;
                inc(x);
                until ((add>0) or (x=31));
                if (add=0) then add:=1;
                oadd.zone:=fidor.address[add].zone;
                oadd.net:=fidor.address[add].net;
                oadd.node:=fidor.address[add].node;
                oadd.point:=fidor.address[add].point;
        end;
end;
if (memboard.mbtype in [2,3]) then begin
        if (rep) then begin
           cmsg^.getorig(add2);
           dadd:=add2;
        end else begin
                dadd.zone:=0;
                dadd.net:=0;
                dadd.node:=0;
                dadd.point:=0;
        end;
end;
assign(t,'MSGTMP');
rewrite(t);
if (rep) then begin
      s2:='';
      s2:=CMSG^.GetFrom;
      s2:=doinitials(s2);
      cmsg^.msgtxtstartup;
      while not(cmsg^.EOM) do begin
      s:=CMSG^.GetString(77-length(s2));
      s:=stripcolor(s);
      s3:=' ';
      while (s3<>'') and not(CMSG^.EOM) and (CMSG^.WasWrap) and (length(s)<70) do begin
        s3:=CMSG^.GetString(73-(length(s2))-Length(s));
        writeln(s3);
        writeln(CMSG^.WasWrap);
        if (s3<>'') then begin
        if (copy(s3,1,1)=' ') then
        s:=s+s3
        else
        s:=s+' '+s3;
        end;
      end;

      stripit:=false;
      if (copy(s,1,10)=' * Origin:') then s[2]:='!';
      if (copy(s,1,4)='--- ') then s[2]:='!';
      if (viewkludge=1) then begin
      if (copy(s,1,1)=#1) then stripit:=true;
      if (copy(s,1,8)='SEEN-BY:') then stripit:=true;
      end else begin
        if (copy(s,1,1)=#1) then s[1]:='@';
      end;
      i2:=pos(#12,s);
      while (i2<>0) do begin
                s:=copy(s,1,i2-1)+copy(s,i2+1,length(s)-i2);
                i2:=pos(#12,s);
                end;
      if not(stripit) then begin
      if (s<>'') then begin
      s:=s2+'> '+s;
      end else s:='';
      writeln(t,s);
      end;
    end;
end;
cmsg^.setseealso(cmsg^.gethighmsgnum+1);
cmsg^.rewritehdr;
case memboard.mbtype of
                                0:cmsg^.SetMailType(mmtNormal);
                                1:cmsg^.SetMailType(mmtEchoMail);
                                2:cmsg^.SetMailType(mmtNetMail);
                                3:cmsg^.SetMailType(mmtNetMail);
end;
cmsg^.startnewmsg;
isdir:=FALSE;
if (private in memboard.mbpriv) then begin
        cmsg^.setpriv(TRUE);
end;
cmsg^.setlocal(TRUE);
if (memboard.mbtype in [2,3]) then
cmsg^.setkillsent(TRUE);
showheader;
if (infield_escape_exited) then begin
infield_escape_exited:=FALSE;
close(t);
{$I-} erase(t); {$I+}
if (ioresult<>0) then begin
end;
exit;
end;
if (memboard.mbtype in [2,3]) then begin
        getnetmailflags;
end;
if (infield_escape_exited) then begin
infield_escape_exited:=FALSE;
exit;
end;
assign(t2,'D:\BWAVE\SIGS\SIG.TXT');
{$I-} reset(t2); {$I+}
if (ioresult=0) then begin
        writeln(t,'');
        writeln(t,'');
        while not(eof(t2)) do begin
                read(t2,c);
                write(t,c);
        end;
        close(t2);
end;
close(t);
{$I-} reset(t); {$I+}
if (ioresult<>0) then begin
        displaybox('Error re-addressing Temp File.',3000);
        exit;
end;
GetFTime(t,ftime);
close(t);
                                assign(t,'MSGINF');
                                rewrite(t);
{                                if (mbrealname in memboard.mbstat) then 
                                writeln(ttf,thisuser.realname) else
                                writeln(ttf,thisuser.name);}
                                writeln(t,fromname);
                                writeln(t,toname);
                                writeln(t,subject);
                                writeln(t,cstr(cmsg^.gethighmsgnum+1));
                                writeln(t,stripcolor(memboard.name));
                                writeln(t,allcaps(syn(Public in memboard.mbpriv)));
                                close(t);
Init_spawno(nexusdir,swap_all,20,0);
{if (spawn(getenv('COMSPEC'),' /c EDIT MSGTMP',0)=-1) then begin
       exec(getenv('COMSPEC'),' /c EDIT MSGTMP');
end;}
if (spawn(getenv('COMSPEC'),' /c '+adrv(systat.utilpath)+'NXEDIT.EXE -K -Q',0)=-1) then begin
       exec(getenv('COMSPEC'),' /c '+adrv(systat.utilpath)+'NXEDIT.EXE -K -Q');
end;
cmsg^.setecho(TRUE);
cmsg^.setfrom(fromname);
cmsg^.setto(toname);
cmsg^.setsubj(subject);
cmsg^.setdate(date);
cmsg^.settime(time);
cmsg^.setrefer(replytonum);
assign(t,'MSGTMP');
{$I-} reset(t); {$I+}
if (ioresult<>0) then begin
        displaybox('Message aborted!',1500);
        exit;
end;
GetFTime(t,Ftime2);
if (Ftime=FTime2) then begin
        displaybox('Message not edited - aborted!',1500);
        close(t);
        {$I-} erase(t); {$I+}
        if (ioresult<>0) then begin end;
        exit;
end;
if (memboard.mbtype in [1..3]) then begin
cmsg^.dokludgeln(^A+'MSGID: '+pointedaddrstr(oadd)+' '+lower(hexlong(memboard.msgid)));
inc(memboard.msgid);
if (rep) then
if (MSGIDLine<>'') then
cmsg^.DoKludgeLn(^A+'REPLY: '+MsgIDLine);
end;

                                if (registered) then begin
{                                       if (expired) then begin
                                                s:='EXPIRED';
                                        end else begin }
                                                s:=cstrf2(ivr.serial,value(copy(ivr.regdate,7,2)));
{                                        end; }
                                end else begin
                                        s:='ULFREE';
                                end;
                                CMSG^.DoKludgeLn(^A+'PID: Nexus '+version+vtpword(ivr.rtype)+' '+s);

{cmsg^.dokludgeln(^A+'PID: nxED 0.99.50-alpha');}
while not(eof(t)) do begin
readln(t,s);
cmsg^.dostringln(s);
end;
close(t);
{$I-} erase(t); {$I+}
if (ioresult<>0) then begin end;
{cmsg^.dostringln('');
cmsg^.dostringln('--- nxED v0.99.50-alpha'); }

if (memboard.mbtype in [1..3]) then begin
        s:='--- Nexus v'+version+vtpword(ivr.rtype);
{                        if not(registered) then begin
                                if (expired) then begin
                                        s:=s+' EXPIRED';
                                end else begin
                                        s:=s+' Unlicensed'
                                end;
                        end; }
                        if (fidor.nodeintear) then s:=s+' [local]';
                        cmsg^.dostringln(s);
end;

if (memboard.mbtype in [1,3]) then begin
	s:=' * Origin: '+getorigin+' (';
	s:=s+getaddr(fidor.address[add].zone,fidor.address[add].net,
		fidor.address[add].node,fidor.address[add].point);
        cmsg^.dostringln(s);
end;

if (cmsg^.writemsg<>0) then begin
        displaybox('Error writing message!',3000);
end else displaybox('Message Saved : #'+cstr(cmsg^.getmsgnum),1500);
end;
end;

procedure readmsgs(smsg:longint);
var done:boolean;
    c:char;
    s:string;
    xx,topline,lastline,numlines,numlines2:integer;
    w2:windowrec;
    msglines:msgptr;
    origmsg:integer;
    t:text;
    arrow,stripit:boolean;

        function showmsgtype(b:byte):string;
        begin
        case b of
                0:showmsgtype:='LOCAL';
                1:showmsgtype:='ECHOMAIL';
                2:showmsgtype:='NETMAIL';
                3:showmsgtype:='INTERNET E-MAIL';
        end;
        end;

        procedure updatestatusline;
        begin
        textcolor(15);
        textbackground(3);
        window(1,1,80,25);
        gotoxy(1,25);
        write(mln(stripcolor(memboard.name)+' ('+showmsgtype(memboard.mbtype)+')',50));
        textcolor(0);
        write(' � ');
        textcolor(15);
        write(mrn(cstr(cmsg^.getmsgnum),5)+' of '+mln(cstr(cmsg^.GetHighMsgNum),5));
        textcolor(7);
        textbackground(0);
        end;

        procedure setupstatusline;
        begin
        window(1,1,80,25);
        gotoxy(1,25);
        textcolor(15);
        textbackground(3);
        clreol;
        textcolor(7);
        textbackground(0);
        end;

        function showflags2:string;
        var s2:string;
        begin
    s2:='';
    if (cmsg^.islocal) then s2:='Loc ';
    if not(public in memboard.mbpriv) then
    if (cmsg^.isPriv) then s2:=s2+'Pvt ';
    if (memboard.mbtype in [2,3]) then begin
    if (cmsg^.isHold) then s2:=s2+'Hold ';
    if (cmsg^.isCrash) then s2:=s2+'Crash ';
    if (cmsg^.isKillsent) then s2:=s2+'Kill ';
    if (cmsg^.isSent) then s2:=s2+'Sent ';
    if (cmsg^.isFattach) then s2:=s2+'FAtt ';
    if (cmsg^.isFileReq) then s2:=s2+'FReq ';
    if (cmsg^.isRcvd) then s2:=s2+'Rcvd ';
    if (isDir) then s2:=s2+'Dir ';
    if (cmsg^.isreqrct) then s2:=s2+'RRR ';
    if (cmsg^.isretrct) then s2:=s2+'Recp';
    end;
    showflags2:=mrn(s2,48);
        end;

        procedure showheader;
        var add:addrtype;
            s2:string;
        begin
        window(1,1,80,24);
        gotoxy(1,1);
        clreol;
        textcolor(3);
        write('Date        : ');
        textcolor(15);
        write(copy(cmsg^.getdate+' '+cmsg^.gettime,1,14));
        showflags;

        gotoxy(1,2);
        textcolor(3);
        clreol;
        write('From        : ');
        textcolor(15);
        write(mln(cmsg^.getfrom,36)+' ');
    if (memboard.mbtype in [2,3]) then begin
    cmsg^.getorig(add);
    s2:=cstr(add.zone)+':'+cstr(add.net)+
                '/'+cstr(add.node);
    if (add.point<>0) then s2:=s2+'.'+cstr(add.point);
    write(mln(s2,15));
    end;
        gotoxy(1,3);
        textcolor(3);
        clreol;
        write('To          : ');
        textcolor(15);
        write(mln(cmsg^.getto,36)+' ');
    if (memboard.mbtype in [2,3]) then begin
    cmsg^.getdest(add);
    s2:=cstr(add.zone)+':'+cstr(add.net)+
                '/'+cstr(add.node);
    if (add.point<>0) then s2:=s2+'.'+cstr(add.point);
    write(mln(s2,15));
    end;
        gotoxy(1,4);
        textcolor(3);
        clreol;
        write('Subject     : ');
        textcolor(15);
        write(cmsg^.getsubj);
        gotoxy(1,5);
        textcolor(3);
        write('컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�');
        window(1,5,80,24);
        end;

        procedure updatetext;
        var tx,j:integer;
            s2:string;
        begin
        for tx:=1 to 19 do begin
        gotoxy(1,tx+5);
        textattr:=memboard.text_color;
        textcolor(7);
        textbackground(0);
        if (topline+(tx-1)<=lastline) then begin
        clreol;
        s2:=msglines^[viewkludge,topline+(tx-1)];
        j:=pos('>',s2);
        if ((j>0) and (j<=5)) then begin
        if (pos('<',s2)=0) or (pos('<',s2)>5) then begin
                textattr:=memboard.quote_color;
        end;
        end;
        if (copy(s2,1,4)='... ') then textattr:=memboard.tag_color;
        if (copy(s2,1,4)='___ ') or (copy(s2,1,3)='~~~') then
                textattr:=memboard.oldtear_color;
        if (copy(s2,1,4)='--- ') then textattr:=memboard.tear_color;
        if (copy(s2,1,10)=' * Origin:') then
                begin
                textattr:=memboard.origin_color;
                end;
        if (copy(s2,1,1)=#1) or (copy(s2,1,8)='SEEN-BY:') then textcolor(2);
        writeln(s2);
        end else
        clreol;
        end;
        end;

        procedure showheader2(var t2:text);
        var add:addrtype;
            s2:string;
        begin
        write(t2,'Date        : ');
        write(t2,copy(cmsg^.getdate+' '+cmsg^.gettime,1,14));
        writeln(t2,showflags2);

        write(t2,'From        : ');
        write(t2,mln(cmsg^.getfrom,36)+' ');
    if (memboard.mbtype in [2,3]) then begin
    cmsg^.getorig(add);
    s2:=cstr(add.zone)+':'+cstr(add.net)+
                '/'+cstr(add.node);
    if (add.point<>0) then s2:=s2+'.'+cstr(add.point);
    write(t2,mln(s2,15));
    end;
    writeln(t2);
        write(t2,'To          : ');
        write(t2,mln(cmsg^.getto,36)+' ');
    if (memboard.mbtype in [2,3]) then begin
    cmsg^.getdest(add);
    s2:=cstr(add.zone)+':'+cstr(add.net)+
                '/'+cstr(add.node);
    if (add.point<>0) then s2:=s2+'.'+cstr(add.point);
    write(t2,mln(s2,15));
    end;
        writeln(t2);
        write(t2,'Subject     : ');
        writeln(t2,cmsg^.getsubj);
        writeln(t2,'컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�');
        end;


begin
cmsg^.seekfirst(smsg);
if not(cmsg^.seekfound) then cmsg^.seekprior;
if (cmsg^.GetHighMsgNum<=0) then begin
     displaybox('There are no messages in this message base.',2000);
     exit;
end;
if not(cmsg^.seekfound) then begin
     displaybox('There are no available messages in this message base.',2000);
     exit;
end;
done:=FALSE;
setupstatusline;
while (cmsg^.seekfound) and not(done) do begin
        cmsg^.msgstartup;
        smsg:=cmsg^.getmsgnum;
        if not(cmsg^.isdeleted) then begin
        isdir:=cmsg^.isdirect;
        showheader;
        cmsg^.msgtxtstartup;
        textcolor(7);
        textbackground(0);
        numlines:=0;
        numlines2:=0;
        new(msglines);
        arrow:=FALSE;
        for xx:=1 to 200 do msglines^[1,xx]:='';
        for xx:=1 to 200 do msglines^[2,xx]:='';
        while not(Cmsg^.EOM) and (numlines<200) do begin
             inc(numlines);
             s:=cmsg^.getstring(80);
             while (CMSG^.WasWrap) and not(CMSG^.EOM) and (length(s)<75) do begin
                s:=s+' '+CMSG^.GetString(78-Length(s));
             end;
             while (pos(#10,s)<>0) do begin
                delete(s,pos(#10,s),1);
             end;
             msglines^[2,numlines]:=s;
             stripit:=false;        
             if (copy(s,1,1)=#1) then stripit:=true;
             if (copy(s,1,8)='SEEN-BY:') then stripit:=true;
             if not(stripit) then begin
                inc(numlines2);
                msglines^[1,numlines2]:=s;
             end;
        end;
        if (viewkludge=1) then lastline:=numlines2 else
        lastline:=numlines;
        updatestatusline;
        topline:=1;
        updatetext;
        repeat
        while not(keypressed) do begin end;
        c:=readkey;
        case upcase(c) of
                #0:begin
                        c:=readkey;
                        case c of
                                #19:begin
                                        origmsg:=cmsg^.getmsgnum;
                                        if (memboard.mbtype in [2,3]) then
                                        if not(cmsg^.isrcvd) and not(cmsg^.islocal) then
                                        begin
                                                cmsg^.setrcvd(TRUE);
                                        end;
                                        replymsg(origmsg);
                                        cmsg^.seekfirst(origmsg);
                                        dispose(msglines);
                                        setupstatusline;
                                        arrow:=TRUE;
                                    end;
                                #59:begin
                                        helppath:=systat.gfilepath;
                                        showhelp('NXED',4,1,1,79,24,3,0,8,FALSE);
                                        cursoron(FALSE);
                                    end;
                                #82:begin
                                        origmsg:=cmsg^.getmsgnum;
                                        if (memboard.mbtype in [2,3]) then
                                        if not(cmsg^.isrcvd) and not(cmsg^.islocal) then
                                        begin
                                                cmsg^.setrcvd(TRUE);
                                        end;
                                        replymsg(-1);
                                        cmsg^.seekfirst(origmsg);
                                        dispose(msglines);
                                        setupstatusline;
                                        arrow:=TRUE;
                                    end;
                                #83:begin
                                        origmsg:=cmsg^.getmsgnum;
                                        if pynqbox('Delete this message? ') then
                                        cmsg^.deletemsg;
                                        cmsg^.seekfirst(origmsg);
                                        if not(cmsg^.seekfound) then
                                                cmsg^.seekfirst(origmsg - 1);
                                        dispose(msglines);
                                        arrow:=TRUE;
                                    end;
                                #72:begin
                                        if (topline>1) then begin
                                                dec(topline);
                                                updatetext;
                                        end;
                                    end;
                                #75:begin
                                        if (memboard.mbtype in [2,3]) then
                                        if not(cmsg^.isrcvd) and not(cmsg^.islocal) then
                                        begin
                                                cmsg^.setrcvd(TRUE);
                                        end;
                                        cmsg^.seekprior;
                                        if not(cmsg^.seekfound) then
                                        begin
                                                cmsg^.seekfirst(1);
                                        end;
                                        dispose(msglines);
                                        arrow:=TRUE;
                                    end;
                                #77:begin
{                                       if (memboard.mbtype in [2,3]) then
                                        if not(cmsg^.isrcvd) and not(cmsg^.islocal) then
                                        begin
                                                cmsg^.setrcvd(TRUE);
                                        end;}
                                        cmsg^.seeknext;
                                        if not(cmsg^.seekfound) then begin
                                                displaybox('End of messages.',1500);
                                                cmsg^.seekfirst(cmsg^.getmsgnum);
                                        end;
                                        dispose(msglines);
                                        arrow:=TRUE;
                                    end;
                                #80:begin
                                        if (topline<lastline-17) then begin
                                                inc(topline);
                                                updatetext;
                                        end;
                                    end;
                                chr(47):begin
                                        if (viewkludge=2) then viewkludge:=1
                                        else viewkludge:=2;
                                        if (viewkludge=1) then lastline:=numlines2 else
                                        lastline:=numlines;
                                        updatetext;
                                end;
                       end;
                   end;
                                'V':begin
                                        if (viewkludge=2) then viewkludge:=1
                                        else viewkludge:=2;
                                        if (viewkludge=1) then lastline:=numlines2 else
                                        lastline:=numlines;
                                        updatetext;
                                end;
                                'R':begin
                                        origmsg:=cmsg^.getmsgnum;
                                        if (memboard.mbtype in [2,3]) then
                                        if not(cmsg^.isrcvd) and not(cmsg^.islocal) then
                                        begin
                                                cmsg^.setrcvd(TRUE);
                                        end;
                                        replymsg(origmsg);
                                        cmsg^.seekfirst(origmsg);
                                        dispose(msglines);
                                        setupstatusline;
                                        arrow:=TRUE;
                                    end;
                                'E','P':begin
                                        origmsg:=cmsg^.getmsgnum;
                                        if (memboard.mbtype in [2,3]) then
                                        if not(cmsg^.isrcvd) and not(cmsg^.islocal) then
                                        begin
                                                cmsg^.setrcvd(TRUE);
                                        end;
                                        replymsg(-1);
                                        cmsg^.seekfirst(origmsg);
                                        dispose(msglines);
                                        setupstatusline;
                                        arrow:=TRUE;
                                    end;
                                'D':begin
                                        origmsg:=cmsg^.getmsgnum;
                                        if pynqbox('Delete this message? ') then
                                        cmsg^.deletemsg;
                                        cmsg^.seekfirst(origmsg);
                                        if not(cmsg^.seekfound) then
                                                cmsg^.seekfirst(origmsg - 1);
                                        dispose(msglines);
                                        arrow:=TRUE;
                                    end;
               'W':begin
  setwindow(w2,18,12,63,14,3,0,8,'',TRUE);
  gotoxy(2,1);
  textcolor(7);
  textbackground(0);
  write('Output to File : ');
  gotoxy(19,1);
  s:='';
  infield_inp_fgrd:=15;
  infield_inp_bkgd:=1;
  infield_out_fgrd:=3;
  infield_out_bkgd:=0;
  infield_allcaps:=TRUE;
  infield_numbers_only:=FALSE;
  infield_escape_zero:=FALSE;
  infield_escape_blank:=TRUE;
  infield_putatend:=FALSE;
  infield_insert:=TRUE;
  infield_clear:=FALSE;
  infield_maxshow:=25;
  infielde(s,60);
  infield_escape_blank:=FALSE;
  infield_putatend:=FALSE;
  infield_insert:=TRUE;
  infield_allcaps:=FALSE;
  removewindow(w2);
  if (s<>'') then begin
        assign(t,s);
        if (exist(s)) then begin
                if pynqbox('File exists.  Append to end of file? ') then begin
                        append(t);
                end else begin
                        rewrite(t);
                end;
        end else begin
                rewrite(t);
        end;
  showheader2(t);
  cmsg^.Msgtxtstartup;
  while not(CMSG^.EOM) do begin
             s:=cmsg^.getstring(80);
             while (CMSG^.WasWrap) and not(CMSG^.EOM) and (length(s)<75) do begin
                s:=s+' '+CMSG^.GetString(78-Length(s));
             end;
             stripit:=false;
             if (copy(s,1,1)=#1) then stripit:=true;
             if (copy(s,1,8)='SEEN-BY:') then stripit:=true;
             if not(stripit) or (viewkludge=2) then begin
                writeln(t,s);
             end;
  end;
  close(t);
  end;
                   end;                        
          '0'..'9':begin
  setwindow(w2,28,12,53,14,3,0,8,'',TRUE);
  gotoxy(2,1);
  textcolor(7);
  textbackground(0);
  write('Goto Message # : ');
  gotoxy(19,1);
  s:=c;
  infield_inp_fgrd:=15;
  infield_inp_bkgd:=1;
  infield_out_fgrd:=3;
  infield_out_bkgd:=0;
  infield_allcaps:=false;
  infield_numbers_only:=TRUE;
  infield_escape_zero:=FALSE;
  infield_escape_blank:=TRUE;
  infield_putatend:=TRUE;
  infield_insert:=TRUE;
  infield_clear:=FALSE;
  infielde(s,5);
  infield_escape_blank:=FALSE;
  infield_putatend:=FALSE;
  infield_insert:=TRUE;
  if (s='') then smsg:=0 else
  smsg:=value(s);
  if (smsg>=1) and (smsg<=cmsg^.GetHighMsgNum) then begin
                                        if (memboard.mbtype in [2,3]) then
                                        if not(cmsg^.isrcvd) and not(cmsg^.islocal) then
                                        begin
                                                cmsg^.setrcvd(TRUE);
                                        end;
  cmsg^.seekfirst(smsg);
  dispose(msglines);
  arrow:=TRUE;
  end;
  removewindow(w2);
                   end;
               #13:begin
                                        if (memboard.mbtype in [2,3]) then
                                        if not(cmsg^.isrcvd) and not(cmsg^.islocal) then
                                        begin
                                                cmsg^.setrcvd(TRUE);
                                        end;
                   cmsg^.seeknext;
                   dispose(msglines);
                   arrow:=TRUE;
                   end;
               #27:begin
                                        {if (memboard.mbtype in [2,3]) then
                                        if not(cmsg^.isrcvd) and not(cmsg^.islocal) then
                                        begin
                                                cmsg^.setrcvd(TRUE);
                                        end;}
                        done:=TRUE;
                        dispose(msglines);
                   end;
        end;
        until (arrow) or (done);
        end else cmsg^.seeknext;
end;
if (smsg>cmsg^.getlastread(1)) then cmsg^.setlastread(1,smsg);
window(1,1,80,25);
end;

procedure readsysop;
begin
assign(uf,adrv(systat.gfilepath)+'USERS.DAT');
{$I-} reset(uf); {$I+}
if (ioresult<>0) then begin
     displaybox('Error reading sysop user record!',2000);
     endprogram;
end;
seek(uf,1);
read(uf,thisuser);
close(uf);
end;

var firsttime:boolean;

begin
firsttime:=TRUE;
nexusdir:=getenv('NEXUS');
keydir:=bslash(TRUE,nexusdir);
checkkey('NEXUS');
oldy:=wherey;
if (nexusdir[length(nexusdir)]='\') then nexusdir:=copy(nexusdir,1,length(nexusdir)-1);
start_dir:=nexusdir;
if (nexusdir='') then begin
        writeln('You must set your NEXUS environment variable to point to your main Nexus');
        writeln('directory or nxED will not run.');
        writeln;
        halt;
end;
opensystat;
readsysop;
currentbase:=0;
filemode:=66;
   assign(bf,adrv(systat.gfilepath)+'MBASES.DAT');
   {$I-} reset(bf); {$I+}
   if (ioresult<>0) then begin
        displaybox('Error reading MBASES.DAT',3000);
        halt;
   end;
   numboards:=filesize(bf)-1;
   setuptags;
top:=1;
savescreen(oldwin,1,1,80,25);
repeat
while (checknewmsgs) or (firsttime) do begin
     currentbase:=getmsgbase2(currentbase);
     firsttime:=FALSE;
end;
firsttime:=TRUE;
if (currentbase<>-1) then begin
seek(bf,currentbase);
read(bf,memboard);
if (OpenOrCreateMsgArea(cmsg,GetMbType+GetMbPath+GetMbFileName)) then begin
        if (cmsg^.getlastread(1)+1>cmsg^.gethighmsgnum) then
        readmsgs(cmsg^.GetHighMsgNum)
        else
        readmsgs(cmsg^.GetLastRead(1)+1);
if not(CloseMsgArea(cmsg)) then displaybox('Error closing Message Base.',3000);
end else displaybox('No Messages.',3000);
seek(bf,currentbase);
write(bf,memboard);
end;
until (currentbase=-1);
close(bf);
endprogram;
end.


