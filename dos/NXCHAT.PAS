{$A+,B+,D-,E+,F+,G+,I+,L-,N-,O-,R+,S+,V-}
{$M 60000,0,100000}      { Memory Allocation Sizes }
program nxCHAT;

uses dos,crt,myio,nxwave2,ivmodem,multi;

{$I NEXUS.INC}

TYPE
ROOMidx=
RECORD
        room:array[1..1000] of boolean;
END;

RoomREC=
RECORD
        name:string[40];
        active:boolean;
        RESERVED:ARRAY[1..99] of BYTE;
END;

RoomLST=
RECORD
        Who:array[1..1000] of RECORD
                Name:string[36];
                Sig:string[8];
                usern:word;
        end;
END;

const chatver='0.99.35.008-beta';
      localc:boolean=FALSE;
      localecho:byte=1;   { 0 = Display Messages 1 = Display full text
                            2 = Display NOTHING }
var curx,cury,x2,currentroom:integer;
    ridxf:file of roomidx;
    ridx:roomidx;
    online:onlinerec;
    osig:string;
    errors:word;
    nexusdir:string;
    rm:roomrec;
    onlinef:file of onlinerec;

Function Wrap(Var st: String; maxlen: Byte; justify: Boolean): String;
  { returns a String of no more than maxlen Characters With the last   }
  { Character being the last space beFore maxlen. On return st now has }
  { the remaining Characters left after the wrapping.                  }
  Const
    space = #32;
  Var
    len      : Byte Absolute st;
    x,
    oldlen,
    newlen   : Byte;

  Function JustifiedStr(s: String; max: Byte): String;

    { Justifies String s left and right to length max. if there is more }
    { than one trailing space, only the right most space is deleted. The}
    { remaining spaces are considered "hard".  #255 is used as the Char }
    { used For padding purposes. This will enable easy removal in any   }
    { editor routine.                                                   }

    Const
      softSpace = #255;
    Var
      jstr      : String;
      len       : Byte Absolute jstr;
    begin
      jstr := s;
      While (jstr[1] = space) and (len > 0) do   { delete all leading spaces }
        delete(jstr,1,1);
      if jstr[len] = space then
        dec(len);                                { Get rid of trailing space }
      if not ((len = max) or (len = 0)) then begin
        x := pos('.',jstr);     { Attempt to start padding at sentence break }
        if (x = 0) or (x =len) then       { no period or period is at length }
          x := 1;                                    { so start at beginning }
        if pos(space,jstr) <> 0 then Repeat        { ensure at least 1 space }
          if jstr[x] = space then                      { so add a soft space }
            insert(softSpace,jstr,x+1);
          x := succ(x mod len);  { if eoln is reached return and do it again }
        Until len = max;        { Until the wanted String length is achieved }
      end; { if not ... }
      JustifiedStr := jstr;
    end; { JustifiedStr }


  begin  { Wrap }
    if len <= maxlen then begin                       { no wrapping required }
      Wrap := st;
      len  := 0;
    end else begin
      oldlen := len;                { save the length of the original String }
      len    := succ(maxlen);                        { set length to maximum }
      Repeat                     { find last space in st beFore or at maxlen }
        dec(len);
      Until (st[len] = space) or (len = 0);
      if len = 0 then                   { no spaces in st, so chop at maxlen }
        len := maxlen;
      if justify then
        Wrap := JustifiedStr(st,maxlen)
      else
        Wrap := st;
      newlen :=  len;          { save the length of the newly wrapped String }
      len := oldlen;              { and restore it to original length beFore }
      Delete(st,1,newlen);              { getting rid of the wrapped portion }
    end;
  end; { Wrap }

procedure enableindex;
begin
assign(ridxf,nexusdir+'CHAT\CHAN'+cstrn(currentroom)+'.IDX');
{$I-} reset(ridxf); {$I+}
if (ioresult<>0) then begin
        for x2:=1 to 1000 do ridx.room[x2]:=FALSE;
        rewrite(ridxf);
        write(ridxf,ridx);
        seek(ridxf,0);
end;
read(ridxf,ridx);
ridx.room[cnode]:=TRUE;
seek(ridxf,0);
write(ridxf,ridx);
close(ridxf);
end;

procedure updatenodestatus(s:string);
begin
        assign(onlinef,adrv(systat.gfilepath)+'USER'+cstrn(cnode)+'.DAT');
        {$I-} reset(onlinef); {$I+}
        if (ioresult<>0) then begin
                writeln('Error opening USER'+cstrn(cnode)+'.DAT');
                halt;
        end;
        read(onlinef,online);
        online.available:=TRUE;
        online.activity:='nxCHAT: '+s;
        seek(onlinef,0);
        write(onlinef,online);
        close(onlinef);
end;

procedure disableindex;
begin
assign(ridxf,nexusdir+'CHAT\CHAN'+cstrn(currentroom)+'.IDX');
{$I-} reset(ridxf); {$I+}
if (ioresult<>0) then begin
        for x2:=1 to 1000 do ridx.room[x2]:=FALSE;
        rewrite(ridxf);
        write(ridxf,ridx);
        seek(ridxf,0);
end;
read(ridxf,ridx);
ridx.room[cnode]:=FALSE;
seek(ridxf,0);
write(ridxf,ridx);
close(ridxf);
end;

procedure title;
begin
textcolor(7);
textbackground(0);
writeln('nxCHAT v'+chatver+' - Multinode Group/Private Chat for Nexus BBS Software');
writeln('(c) Copyright 1995-2000 George A. Roberts IV. All rights reserved.');
writeln;
end;

procedure helpscreen;
begin
title;
writeln('Syntax:   nxCHAT -N[Node] [-K]');
writeln;
writeln('Options:');
writeln;
writeln('       -N[Node]   =  Specifies the node number to use for this session');
writeln('                     of nxCHAT.');
writeln;
writeln('                     NOTE: If in LOCAL MODE, this will stop all');
writeln('                     online users from using this node for nxCHAT.');
writeln;
writeln('       -K         =  Specifies LOCAL MODE only.  No BBS interaction.');
writeln;
end;

procedure getparams;
var s:string;
    x:integer;
begin
        if (paramcount=0) then begin
                helpscreen;
                halt;
        end;
        x:=1;
        while (x<=paramcount) do begin
        s:=paramstr(x);
        case upcase(s[2]) of
                'N':begin
                        cnode:=value(copy(s,3,length(s)-2));
                    end;
                'K':begin
                        localonly:=TRUE;
                        localc:=TRUE;
                        comtype:=0;
                    end;
        end;
        inc(x);
        end;
        if (cnode=0) then begin
                writeln('You must specify a node number with the -N switch.');
                halt;
        end;
end;

procedure openfiles;
begin
        nexusdir:=getenv('NEXUS');
        if (nexusdir[length(nexusdir)]<>'\') then nexusdir:=nexusdir+'\';
        assign(systatf,nexusdir+'MATRIX.DAT');
        {$I-} reset(systatf); {$I+}
        if (ioresult<>0) then begin
                writeln('Error opening MATRIX.DAT');
                halt;
        end;
        read(systatf,systat);
        close(systatf);
        if not(localc) then begin
        if not(exist(adrv(systat.semaphorepath)+'INUSE.'+cstrnfile(cnode))) then begin
                writeln('Node is not in use!');
                halt;
        end;
        end;
        if not(existdir(nexusdir+'CHAT')) then begin
            {$I-} mkdir(nexusdir+'CHAT'); {$I+}
            if (ioresult<>0) then begin
                  writeln('Unable to create '+nexusdir+'CHAT ...');
                  halt;
            end;
        end;
        if not(existdir(nexusdir+'CHAT\MSG')) then begin
            {$I-} mkdir(nexusdir+'CHAT\MSG'); {$I+}
            if (ioresult<>0) then begin
                  writeln('Unable to create '+nexusdir+'CHAT\MSG ...');
                  halt;
            end;
        end;
end;

procedure getuser;
var s:string;
begin
if (localc) then begin
        okansi:=TRUE;
        ivtextcolor(9);
        ivtextbackground(0);
        ivwrite('Enter your name: ');
        ivtextcolor(15);
        s:='';
        ivreadln(s,36,'P');
        if (s='') then begin
                osig:='';
                exit;
                end;
        online.name:=s;
end else begin
        updatenodestatus('Joining chat');
        if (online.emulation>0) then okansi:=TRUE;
end;
if not(localc) then begin
if (online.baud<>0) then begin
if (online.lockbaud=0) then begin
        ivinstallmodem(online.comport,online.baud*10,errors);
end else begin
        ivinstallmodem(online.comport,online.lockbaud*10,errors);
end;
end else begin
        okansi:=TRUE;
        localonly:=TRUE;
        comtype:=0;
       end;
end;
osig:='';
if (online.nickname='') or (localc) then begin
ivtextcolor(9);
ivtextbackground(0);
ivwrite('Enter your nickname (');
ivtextcolor(15);
ivtextbackground(0);
ivwrite('8 characters');
ivtextcolor(9);
ivtextbackground(0);
ivwrite(') : ');
ivtextcolor(15);
ivtextbackground(0);
ivreadln(osig,8,'');
end else osig:=online.nickname;
end;

function getline1(s:string):string;
var rlf:file of roomlst;
    rl:^roomlst;
    ri:roomidx;
    x:integer;
    found:boolean;
    s2:string;
begin
assign(ridxf,nexusdir+'CHAT\CHAN'+cstrn(currentroom)+'.IDX');
{$I-}reset(ridxf); {$I+}
if (ioresult<>0) then begin
        getline1:='* Error searching signature list!';
        exit;
end;
read(ridxf,ri);
close(ridxf);
assign(rlf,nexusdir+'CHAT\CHAN'+cstrn(currentroom)+'.LST');
{$I-}reset(rlf); {$I+}
if (ioresult<>0) then begin
        getline1:='* Error searching nick list!';
        exit;
end;
new(rl);
read(rlf,rl^);
close(rlf);
x:=1;
found:=FALSE;
while (x<1001) and not(found) do begin
        if (ri.room[x]) then begin
                if allcaps(rl^.who[x].sig)=allcaps(s) then begin
                        found:=TRUE;
                        s2:='* '+rl^.who[x].sig+' is '+rl^.who[x].name;
                end;
        end;
        inc(x);
end;
if (found) then begin
        getline1:=s2;
end else begin
        getline1:='* '+s+': nick not found.';
end;
dispose(rl);
end;

function getline2(s:string):string;
begin
getline2:='';
end;

function getline3(s:string):string;
begin
getline3:='';
end;

Procedure SplitScreen;
const
  ver = '0.99';
var
  oldsnoop : boolean;
  c: char;
  loop: byte;
  quit: boolean;
  last: datetime;
  pm: boolean;
  x:integer;
  hourtmp: word;
  attr: byte;
  awords,s:string;
  cw: byte; { Current window }
  p: array[1..2] of record
    x,y: byte;
  End;
  lastmline:byte;
  cl: array[1..2] of String;
  lastcl:array[1..2] of string;
  logcl:array[1..2] of string;
  tempmsg:array[1..10] of string[250];
  backln:array[1..3] of string[250];
  backtype:array[1..3] of integer;
  backsig:array[1..3] of string[8];
  lasttempmsg:integer;
  temp,rtemp,quitmsg: String;
    i:integer;

Const
  off: array[1..2] of record
    x,y: byte;
  end = ((x:0;y:6),(x:0;y:16));

TYPE
msgheadrec=
RECORD
        fromname:string[36];
        fromsig:string[8];
        format:byte;                    { 1 = Message }
                                        { 2 = Control (enter/exit) }
                                        { 3 = Action  }
        res:array[1..33] of byte;
end;

msgrec=
RECORD
        msg:string[250];
end;

Procedure clearwindow(w: byte);
var loop: byte;
    tb: byte;
    y1:byte;
Begin
  ivtextcolor(7);
  ivtextbackground(0);
  if (w=1) then begin
  for loop := 1 to 13 do Begin
    ivgotoxy(off[w].x+1,off[w].y+loop);
    ivwrite('                                                                               ');
  End;
  end;
  { Clear the window }
  p[w].x:=1;
  p[w].y:=1;
  ivgotoxy(off[w].x+p[w].x,off[w].y+p[w].y);
  y1:=0;
  if (lastcl[w]<>'') then begin
    ivgotoxy(off[w].x+1,off[w].y+1);
    ivwrite(lastcl[w]);
    y1:=1;
  end;
  if (cl[w]<>'') then begin
    ivgotoxy(off[w].x+1,off[w].y+1+y1);
    ivwrite(cl[w]);
    ivgotoxy(off[w].x+1+length(cl[w]),off[w].y+1+y1);
    p[w].x:=1+length(cl[w]);
    p[w].y:=1+y1;
    ivgotoxy(off[cw].x+p[cw].x,off[cw].y+p[cw].y);
  end else begin
    p[w].x:=1;
    p[w].y:=1+y1;
    ivgotoxy(off[cw].x+p[cw].x,off[cw].y+p[cw].y);
  end;
End;


Procedure topheader;
var loop: byte;
Begin
  ivtextcolor(7);
  ivtextbackground(0);
  for loop := 1 to 5 do Begin
    ivgotoxy(1,loop);
    ivwrite('                                                                               ');
  end;
  ivgotoxy(1,1);
  ivwriteln('%090%旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴%010%�');
  ivwriteln('%090%�%091% � %151%nxCHAT Multinode Chat                                                     %010%�');
  ivwriteln('%090%�%010%컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸');
  ivwriteln('%100% Channel %080%-> %150%'+mln(cstr(currentroom),3)+'                                            '+
  '         %100%/? %020%for Help');
  ivwriteln('%100%   Topic %080%-> %150%'+rm.name);
end;

procedure wraplines;

      procedure pline(xx:integer);
      var sss,ssss:string;
      begin
      case backtype[xx] of
            1:begin
            sss:=backln[xx];
            ssss:=mln('%080%<%150%'+backsig[xx]+'%080%>%070%',11);
            while (sss<>'') do begin
                  inc(lastmline);
                  ivgotoxy(off[1].x+1,off[1].y+lastmline);
                  ivwrite(ssss);
                  ssss:=wrap(sss,68,false);
                  ivwrite(ssss);
                  ssss:=mln('',11);
            end;
              end;
            2:begin
            sss:=backln[xx];
            ssss:='%080%- %070%';
            while (sss<>'') do begin
                  inc(lastmline);
                  ivgotoxy(off[1].x+1,off[1].y+lastmline);
                  ivwrite(ssss);
                  ssss:=wrap(sss,79,false);
                  ivwrite(ssss);
                  ssss:='   ';
            end;
              end;
            3:begin
            sss:=backln[xx];
            ssss:='';
            while (sss<>'') do begin
                  ivtextcolor(13);
                  ivtextbackground(0);
                  inc(lastmline);
                  ivgotoxy(off[1].x+1,off[1].y+lastmline);
                  ivwrite(ssss);
                  ssss:=wrap(sss,79,false);
                  ivwrite(ssss);
                  ssss:='   ';
            end;
              end;
           end;
      end;

begin
clearwindow(1);
lastmline:=0;
pline(1);
pline(2);
pline(3);
end;

procedure helpnorm;
var c8:char;
begin
clearwindow(1);
ivgotoxy(off[1].x+1,off[1].y+1);
ivwriteln('%090%Available commands:');
ivgotoxy(off[1].x+1,off[1].y+2);
ivwriteln('');
ivgotoxy(off[1].x+1,off[1].y+3);
ivwriteln('%100%/? %020%[ACTION]              %080%- %070%This help screen, /? ACTION for');
ivgotoxy(off[1].x+1,off[1].y+4);
ivwriteln('                           %070%action word help.');
ivgotoxy(off[1].x+1,off[1].y+5);
ivwriteln('%100%/JOIN %020%[#]                %080%- %070%Join channel #');
ivgotoxy(off[1].x+1,off[1].y+6);
ivwriteln('%100%/TOPIC %020%[desc]            %080%- %070%Set channel topic to "desc"');
ivgotoxy(off[1].x+1,off[1].y+7);
ivwriteln('%100%/ME %020%[action]             %080%- %070%Displays an action from you');
ivgotoxy(off[1].x+1,off[1].y+8);
ivwriteln('%100%/WHOIS %020%[nick]            %080%- %070%Displays information about a user');
ivgotoxy(off[1].x+1,off[1].y+10);
ivwriteln('%100%/BYE %020%[msg]               %080%- %070%Exit chat (optional message)');
ivgotoxy(off[1].x+1,off[1].y+11);
ivwriteln('%100%/Q[UIT] [msg]            %080%- %070%Exit chat (optional message)');
ivgotoxy(off[1].x+1,off[1].y+12);
ivwriteln('');
ivgotoxy(off[1].x+1,off[1].y+13);
ivwrite('%150%Press any key to continue...');
c8:=#0;
while not(ivKeypressed) do begin doslice end;
c8:=ivreadchar;
wraplines;
ivgotoxy(off[cw].x+p[cw].x,off[cw].y+p[cw].y);
end;

procedure helpaction;
var c8:char;
begin
clearwindow(1);
ivgotoxy(off[1].x+1,off[1].y+1);
ivwriteln('%090%Available action words:');
ivgotoxy(off[1].x+1,off[1].y+2);
ivwriteln('');
ivgotoxy(off[1].x+1,off[1].y+3);
ivwriteln('%100%/SMILE %020%[atname]               %080%- %070%Sends message saying you are smiling');
ivgotoxy(off[1].x+1,off[1].y+4);
ivwriteln('                                     %070%If ATNAME is left off= everyone');
ivgotoxy(off[1].x+1,off[1].y+5);
ivwriteln('%100%/CHUCKLE                      %080%- %070%Sends message saying you are chuckling');
ivgotoxy(off[1].x+1,off[1].y+6);
ivwriteln('');
ivgotoxy(off[1].x+1,off[1].y+7);
ivwrite('%150%Press any key to continue...');
while not(ivKeypressed) do begin doslice; end;
c8:=ivreadchar;
wraplines;
ivgotoxy(off[cw].x+p[cw].x,off[cw].y+p[cw].y);
end;

function timer:real;
var r:registers;
    h,m,s,t:real;
begin
  r.ax:=44*256;
  msdos(dos.registers(r));
  h:=(r.cx div 256); m:=(r.cx mod 256); s:=(r.dx div 256); t:=(r.dx mod 256);
  timer:=h*3600+m*60+s+t/100;
end;

function mtime:longint;
var h,m,s,s100:word;
begin
gettime(h,m,s,s100);
mtime:=(h*36000)+(m*600)+(s*100)+s100;
end;

procedure checkmsgs;
var f:file;
    m:msgrec;
    mh:msgheadrec;
    sr:searchrec;
    sss,ssss:string;
    shown:boolean;
begin
shown:=false;
findfirst(nexusdir+'CHAT\MSG\*.'+cstrnfile(cnode),anyfile-directory-volumeid,sr);
while (doserror=0) do begin
      assign(f,nexusdir+'CHAT\MSG\'+sr.name);
      {$I-} reset(f,1); {$I+}
      if (ioresult=0) then begin
            blockread(f,mh,sizeof(msgheadrec));
            while not(eof(f)) do begin
                  blockread(f,m,sizeof(msgrec));
                  If lastmline > 13 then begin
                  wraplines;
                  end;
backln[1]:=backln[2];
backln[2]:=backln[3];
backsig[1]:=backsig[2];
backsig[2]:=backsig[3];
backtype[1]:=backtype[2];
backtype[2]:=backtype[3];
case mh.format of
        1:begin
            backln[3]:=m.msg;
            backtype[3]:=1;
            backsig[3]:=mh.fromsig;
            sss:=m.msg;
            ssss:=mln('%080%<%150%'+mh.fromsig+'%080%>%070%',11);
            while (sss<>'') do begin
                  inc(lastmline);
                  if (lastmline>13) then wraplines;
                  ivgotoxy(off[1].x+1,off[1].y+lastmline);
                  ivwrite(ssss);
                  ssss:=wrap(sss,68,false);
                  ivwrite(ssss);
                  ssss:=mln('',11);
            end;
          end;
        2:begin
            backln[3]:=m.msg;
            backtype[3]:=2;
            backsig[3]:='';
            sss:=m.msg;
            ssss:='%080%- %070%';
            while (sss<>'') do begin
                  inc(lastmline);
                  if (lastmline>13) then wraplines;
                  ivgotoxy(off[1].x+1,off[1].y+lastmline);
                  ivwrite(ssss);
                  ssss:=wrap(sss,79,false);
                  ivwrite(ssss);
                  ssss:='   ';
            end;
          end;
        3:begin
            backln[3]:=m.msg;
            backtype[3]:=3;
            backsig[3]:='';
            sss:=m.msg;
            ssss:='';
            while (sss<>'') do begin
                  ivtextcolor(13);
                  ivtextbackground(0);
                  inc(lastmline);
                  if (lastmline>13) then wraplines;
                  ivgotoxy(off[1].x+1,off[1].y+lastmline);
                  ivwrite(ssss);
                  ssss:=wrap(sss,79,false);
                  ivwrite(ssss);
                  ssss:='   ';
            end;
          end;
end;
end;
close(f);
ivgotoxy(curx,cury);
{$I-} erase(f); {$I+}
if (ioresult<>0) then begin end;
end;
findnext(sr);
end;
end;

procedure writemsg(ss:string; tpe:byte);
var f:file;
    m:msgrec;
    mh:msgheadrec;
    sss,ssss:string;
    x,x2:integer;
    r:real;
begin
if (ss<>'') then begin
assign(ridxf,nexusdir+'CHAT\CHAN'+cstrn(currentroom)+'.IDX');
filemode:=66;
{$I-} reset(ridxf); {$I+}
if (ioresult<>0) then begin
        for x2:=1 to 1000 do ridx.room[x2]:=FALSE;
        rewrite(ridxf);
        write(ridxf,ridx);
        seek(ridxf,0);
end;
read(ridxf,ridx);
close(ridxf);
mh.fromname:=online.name;
mh.fromsig:=osig;
if (tpe=4) then mh.format:=2 else
mh.format:=tpe;
m.msg:=ss;
for x2:=1 to 1000 do
if (ridx.room[x2]) and (x2<>cnode) then begin
r:=timer;
assign(f,nexusdir+'CHAT\MSG\MSG'+cstr(trunc(r))+'.'+cstrnfile(x2));
{$I-} rewrite(f,1); {$I+}
if (ioresult=0) then begin
for x:=1 to sizeof(mh.res) do mh.res[x]:=0;
blockwrite(f,mh,sizeof(msgheadrec));
blockwrite(f,m,sizeof(msgrec));
close(f);
end;
end;

If (lastmline > 13) then begin
wraplines;
end;
backln[1]:=backln[2];
backln[2]:=backln[3];
backsig[1]:=backsig[2];
backsig[2]:=backsig[3];
backtype[1]:=backtype[2];
backtype[2]:=backtype[3];
if (localecho=1) then begin
case tpe of
        1:begin
            backln[3]:=m.msg;
            backtype[3]:=1;
            backsig[3]:=osig;
            sss:=m.msg;
            ssss:=mln('%080%<%150%'+osig+'%080%>%070%',11);
            while (sss<>'') do begin
                  inc(lastmline);
                  if (lastmline>13) then wraplines;
                  ivgotoxy(off[1].x+1,off[1].y+lastmline);
                  ivwrite(ssss);
                  ssss:=wrap(sss,68,false);
                  ivwrite(ssss);
                  ssss:=mln('',11);
            end;
          end;
        2:begin
            backln[3]:=m.msg;
            backtype[3]:=2;
            backsig[3]:='';
            sss:=m.msg;
            ssss:='%080%- %070%';
            while (sss<>'') do begin
                  inc(lastmline);
                  if (lastmline>13) then wraplines;
                  ivgotoxy(off[1].x+1,off[1].y+lastmline);
                  ivwrite(ssss);
                  ssss:=wrap(sss,79,false);
                  ivwrite(ssss);
                  ssss:='   ';
            end;
          end;
        3:begin
            backln[3]:=m.msg;
            backtype[3]:=3;
            backsig[3]:='';
            sss:=m.msg;
            ssss:='';
            while (sss<>'') do begin
                  ivtextcolor(13);
                  ivtextbackground(0);
                  inc(lastmline);
                  if (lastmline>13) then wraplines;
                  ivgotoxy(off[1].x+1,off[1].y+lastmline);
                  ivwrite(ssss);
                  ssss:=wrap(sss,79,false);
                  ivwrite(ssss);
                  ssss:='   ';
            end;
          end;
end;
end;
ivgotoxy(12,24);
end;
end;

procedure dispmsg(s:string; tpe:byte);
var f:file;
    m:msgrec;
    mh:msgheadrec;
    x,x2:integer;
    r:real;
    sss,ssss:string;
begin
if (s<>'') then begin
If lastmline > 13 then begin
wraplines;
end;
backln[1]:=backln[2];
backln[2]:=backln[3];
backsig[1]:=backsig[2];
backsig[2]:=backsig[3];
backtype[1]:=backtype[2];
backtype[2]:=backtype[3];
case tpe of
        1:begin
            backln[3]:=s;
            backtype[3]:=1;
            backsig[3]:=osig;
            sss:=s;
            ssss:=mln('%080%<%150%'+osig+'%080%>%070%',11);
            while (sss<>'') do begin
                  inc(lastmline);
                  if (lastmline>13) then wraplines;
                  ivgotoxy(off[1].x+1,off[1].y+lastmline);
                  ivwrite(ssss);
                  ssss:=wrap(sss,68,false);
                  ivwrite(ssss);
                  ssss:=mln('',11);
            end;
          end;
        2:begin
            backln[3]:=s;
            backtype[3]:=2;
            backsig[3]:='';
            sss:=s;
            ssss:='%080%- %070%';
            while (sss<>'') do begin
                  inc(lastmline);
                  if (lastmline>13) then wraplines;
                  ivgotoxy(off[1].x+1,off[1].y+lastmline);
                  ivwrite(ssss);
                  ssss:=wrap(sss,79,false);
                  ivwrite(ssss);
                  ssss:='   ';
            end;
          end;
        3:begin
            backln[3]:=s;
            backtype[3]:=3;
            backsig[3]:='';
            sss:=s;
            ssss:='';
            while (sss<>'') do begin
                  ivtextcolor(13);
                  ivtextbackground(0);
                  inc(lastmline);
                  if (lastmline>13) then wraplines;
                  ivgotoxy(off[1].x+1,off[1].y+lastmline);
                  ivwrite(ssss);
                  ssss:=wrap(sss,79,false);
                  ivwrite(ssss);
                  ssss:='   ';
            end;
          end;
end;

ivgotoxy(12,24);
end;
end;

procedure writetempmsg(tpe:byte);
var f:file;
    m:msgrec;
    mh:msgheadrec;
    x,x2:integer;
    r:real;
begin
if (lasttempmsg<>0) then begin
assign(ridxf,nexusdir+'CHAT\CHAN'+cstrn(currentroom)+'.IDX');
filemode:=66;
{$I-} reset(ridxf); {$I+}
if (ioresult<>0) then begin
        for x2:=1 to 1000 do ridx.room[x2]:=FALSE;
        rewrite(ridxf);
        write(ridxf,ridx);
        seek(ridxf,0);
end;
read(ridxf,ridx);
close(ridxf);
for x2:=1 to 1000 do
if (ridx.room[x2]) and (x2<>cnode) then begin
r:=timer;
assign(f,nexusdir+'CHAT\MSG\MSG'+cstr(trunc(r))+'.'+cstrnfile(x2));
{$I-} rewrite(f,1); {$I+}
if (ioresult=0) then begin
mh.fromname:=online.name;
mh.fromsig:=osig;
mh.format:=tpe;
for x:=1 to sizeof(mh.res) do mh.res[x]:=0;
blockwrite(f,mh,sizeof(msgheadrec));
for x:=1 to lasttempmsg do begin
m.msg:=tempmsg[x];
blockwrite(f,m,sizeof(msgrec));
end;
close(f);
end;
end;
for x:=1 to lasttempmsg do begin
m.msg:=tempmsg[x];
If lastmline > 13 then begin
clearwindow(1);
lastmline:=1;
ivgotoxy(off[1].x+1,off[1].y+lastmline);
inc(lastmline);
ivwrite(backln[1]);
ivgotoxy(off[1].x+1,off[1].y+lastmline);
inc(lastmline);
ivwrite(backln[2]);
ivgotoxy(off[1].x+1,off[1].y+lastmline);
inc(lastmline);
ivwrite(backln[3]);
end;
backln[1]:=backln[2];
backln[2]:=backln[3];
backtype[1]:=backtype[2];
backtype[2]:=backtype[3];
ivgotoxy(off[1].x+1,off[1].y+lastmline);
inc(lastmline);
if (localecho=1) then begin
ivtextcolor(15);
ivtextbackground(0);
case mh.format of
        1:begin
ivwrite(mln(mh.fromsig,8)+': ');
backln[3]:='%150%'+mln(mh.fromsig,8)+': %030%'+m.msg;
ivtextcolor(3);
ivtextbackground(0);
ivwrite(m.msg);
ivtextcolor(7);
ivtextbackground(0);
          end;
        2:begin
                ivtextcolor(14);
                ivtextbackground(0);
                ivwrite(m.msg);
                ivtextcolor(7);
                ivtextbackground(0);
          end;
        3:begin
                ivtextcolor(12);
                ivtextbackground(0);
                ivwrite(m.msg);
                ivtextcolor(7);
                ivtextbackground(0);
          end;
end;
ivgotoxy(off[cw].x+p[cw].x,off[cw].y+p[cw].y);
end;
if (localecho=0) then begin
ivtextcolor(11);
ivtextbackground(0);
ivwrite(mln(osig,8)+': ');
ivtextcolor(15);
ivtextbackground(0);
ivwrite('Message sent...');
ivgotoxy(off[cw].x+p[cw].x,off[cw].y+p[cw].y);
end;
end;

end;
end;

function tcheck(s:real; i:integer):boolean;
var r:real;
begin
  r:=timer-s;
  if r<0.0 then r:=r+86400.0;
  if (r<0.0) or (r>32760.0) then r:=32766.0;
  if trunc(r)>i then tcheck:=FALSE else tcheck:=TRUE;
end;


procedure joinchannel(chnum:integer);
var rf:file of roomrec;
    rlf:file of roomlst;
    rl:^roomlst;
    i2:integer;
begin
        if (chnum>1000) then begin
            dispmsg('%120%Invalid channel number.',3);
            exit;
        end;
        if (currentroom<>0) then begin
        disableindex;
        end;
        new(rl);
        assign(rf,nexusdir+'CHAT\CHANNELS.DAT');
        assign(rlf,nexusdir+'CHAT\CHAN'+cstrn(chnum)+'.LST');
        {$I-} reset(rf); {$I+}
        if (ioresult<>0) then begin
                rewrite(rf);
                rm.name:='';
                rm.active:=FALSE;
                write(rf,rm);
                seek(rf,0);
        end;
                if (chnum>filesize(rf)-1) then begin
                  for i2:=filesize(rf) to chnum do begin
                        seek(rf,i2);
                        fillchar(rm,sizeof(rm),#0);
                        rm.name:='None';
                        rm.active:=FALSE;
                        write(rf,rm);
                  end;
                end;
                seek(rf,chnum);
                read(rf,rm);
                if not(rm.active) then begin
                      rm.name:='None';
                      rm.active:=TRUE;
                      seek(rf,chnum);
                      write(rf,rm);
                end;
                close(rf);
                {$I-} reset(rlf); {$I+}
                if (ioresult<>0) then begin rewrite(rlf); end;
                rl^.who[cnode].name:=online.name;
                rl^.who[cnode].sig:=osig;
                if not(localc) then rl^.who[cnode].usern:=online.number
                else rl^.who[cnode].usern:=0;
                seek(rlf,0);
                write(rlf,rl^);
                close(rlf);
                dispose(rl);
                currentroom:=chnum;
                enableindex;
                updatenodestatus('Channel '+cstr(currentroom));
                topheader;
end;

procedure settopic(topic:string);
var rf:file of roomrec;
begin
        assign(rf,nexusdir+'CHAT\CHANNELS.DAT');
        {$I-} reset(rf); {$I+}
        if (ioresult<>0) then begin
                rewrite(rf);
                rm.name:='';
                rm.active:=FALSE;
                write(rf,rm);
                seek(rf,0);
        end;
                seek(rf,currentroom);
                read(rf,rm);
                rm.name:=topic;
                seek(rf,currentroom);
                write(rf,rm);
                close(rf);
                topheader;
end;

procedure getinput(var s:string; ml,sl:integer);
var x,cp,sp:integer;
    c:char;
    st:real;
    origcolor:byte;
    oldecho:boolean;

  procedure dobackspace;
  var i:integer;
      c:byte;
  begin
    if (cp>1) then begin
      dec(cp);
      dec(sp);
      if (sp=1) then begin
            if (sl div 2 <= cp) then begin
                  ivwrite(^H' '^H);
                  ivwrite(copy(s,(cp - (sl div 2)),sl div 2));
                  sp:=(sl div 2) + 1;
            end else begin
                  ivwrite(^H' '^H);
                  ivwrite(copy(s,1,cp-1));
                  sp:=cp;
            end;
      end else begin
            ivwrite(^H' '^H);
      end;
    end;
  end;

begin
  cp:=1;
  sp:=1;
  st:=timer;
  ivtextcolor(15);
  ivtextbackground(1);
  ivwrite(mln('',sl));
  for x:=1 to sl do ivwrite(^H' '^H);
  repeat
    while not(ivkeypressed) and (ivcarrier) do begin
        doslice;
        if tcheck(st,2) then begin
                curx:=wherex;
                cury:=wherey;
                checkmsgs;
                st:=timer;
        end;
    end;
    if (ivcarrier) then begin
    ivtextcolor(15);
    ivtextbackground(1);
    c:=ivreadchar;
    if (c in [#32..#255]) then begin
     if (cp<=ml) then begin
      s[0]:=chr(cp);
      s[cp]:=c; inc(cp); inc(sp);
      ivwrite(c);
      if (sp>sl) then begin
            for x:=1 to sl do ivwrite(^H' '^H);
            ivwrite(copy(s,(cp - (sl div 2)),sl div 2));
            sp:=(sl div 2)+1;
      end;
     end else begin end;
    end else case c of
      ^H:dobackspace;
      ^X:while (cp<>1) do dobackspace;
    end;
    end;
  until ((c=^M) or (c=^N) or not(ivCarrier));
  s[0]:=chr(cp-1);
end;

Begin
  lastmline:=0;
  cw := 2;
  p[1].x := 1;
  p[1].y := 1;
  p[2].x := 1;
  p[2].y := 1;
  cl[1] := '';
  cl[2] := '';
  lastcl[1] := '';
  lastcl[2] := '';
  logcl[1]:='';
  logcl[2]:='';
  awords:='';

  cls;

  joinchannel(1);
  topheader;
  ivgotoxy(1,6);
  ivtextcolor(9);
  ivtextbackground(0);
  for x:=1 to 79 do ivwrite('�');
  ivgotoxy(1,23);
  ivtextcolor(9);
  ivtextbackground(0);
  for x:=1 to 79 do ivwrite('�');
{  Drawwindow(1,16,78,23,2,0,0,3,3,online.name+' ('+osig+')',FALSE);}

  ivgotoxy(off[cw].x+p[cw].x,off[cw].y+p[cw].y);
  lasttempmsg:=0;
  for x:=1 to 10 do tempmsg[x]:='';
  for x:=1 to 3 do backln[x]:='';
  for x:=1 to 3 do backsig[x]:='';
  for x:=1 to 3 do backtype[x]:=1;
  writemsg(osig+' has entered chat',2);
  writemsg(osig+' has joined channel '+cstr(currentroom),4);
  dispmsg('Now chatting in channel '+cstr(currentroom),2);
  repeat
    { Check to see If we should update the clock }

    ivgotoxy(1,24);
    ivwrite(mln('%080%<%150%'+osig+'%080%>%070%',11));
    ivtextcolor(15);
    ivtextbackground(1);
    getinput(s,250,68);
    quit:=FALSE;
    if (ivcarrier) then begin
    if (s[1]='/') then begin
                awords:='';
                if allcaps(copy(s,1,3))='/ME' then begin
                        if (copy(s,5,length(s)-4)<>'') then begin
                        awords:='* '+osig+' '+copy(s,5,length(s)-4);
                        end;
                end else
                if allcaps(copy(s,1,6))='/SMILE' then begin
                        if (copy(s,8,length(s))<>'') then begin
                        awords:='* '+osig+' smiles at '+copy(s,8,length(s));
                        end else begin
                        awords:='* '+osig+' smiles at everyone';
                        end;
                end else
                if allcaps(s)='/CHUCKLE' then begin
                        awords:='* '+osig+' chuckles';
                end else
                if (allcaps(copy(s,1,5))='/HELP') then begin
                        if (allcaps(copy(s,7,length(s)))='ACTION') or
                           (allcaps(copy(s,7,length(s)))='ACTIONS') then begin
                              helpaction;
                        end else begin
                        helpnorm;
                        end;
                        awords:='SKIP';
                end else
                if (allcaps(copy(s,1,2))='/?') then begin
                        if (allcaps(copy(s,4,length(s)))='ACTION') or
                           (allcaps(copy(s,4,length(s)))='ACTIONS') then begin
                              helpaction;
                        end else begin
                        helpnorm;
                        end;
                        awords:='SKIP';
                end else
                if (allcaps(copy(s,1,5))='/JOIN') then begin
                        if (copy(s,7,length(s))<>'') then begin
                              writemsg(osig+' has left channel '+cstr(currentroom),4);
                              dispmsg('Leaving channel '+cstr(currentroom),2);
                              joinchannel(value(copy(s,7,length(s))));
                              writemsg(osig+' has joined channel '+cstr(currentroom),4);
                              dispmsg('Now chatting in channel '+cstr(currentroom),2);
                        end;
                        awords:='SKIP';
                end else
                if (allcaps(copy(s,1,6))='/TOPIC') then begin
                        if (copy(s,8,length(s))<>'') then begin
                              settopic(copy(s,8,length(s)));
                              writemsg('Topic now "'+copy(s,8,length(s))+'"',2);
                        end;
                        awords:='SKIP';
                end else
                if allcaps(copy(s,1,6))='/WHOIS' then begin
                        if (copy(s,8,length(s))<>'') then begin
                        awords:=getline1(copy(s,8,length(s)));
                        dispmsg(awords,3);
                        awords:=getline2(copy(s,8,length(s)));
                        if (awords<>'') then begin
                        awords:='';
                        dispmsg(awords,3);
                        end;
                        awords:=getline3(copy(s,8,length(s)));
                        if (awords<>'') then begin
                        dispmsg(awords,3);
                        end;
                        awords:='';
                        end;
                end else
                if allcaps(copy(s,1,4))='/BYE' then begin
                        quitmsg:='';
                        if (copy(s,6,length(s)-5)<>'') then begin
                        quitmsg:=copy(s,6,length(s)-5);
                        end;
                        quit:=TRUE;
                        awords:='SKIP';
                end else
                if allcaps(s)='/ECHO ON' then begin
                        awords:='SKIP';
                        localecho:=1;
                end else
                if allcaps(s)='/ECHO BRIEF' then begin
                        awords:='SKIP';
                        localecho:=0;
                end else
                if allcaps(s)='/ECHO OFF' then begin
                        awords:='SKIP';
                        localecho:=2;
                end else
                if (allcaps(copy(s,1,5))='/QUIT') or
                   (allcaps(copy(s,1,2))='/Q') then begin
                        quitmsg:='';
                        if (copy(s,7,length(s)-6)<>'') then begin
                        quitmsg:=copy(s,7,length(s)-6);
                        end;
                        quit:=TRUE;
                        awords:='SKIP';
                end;
                if (awords<>'') and (awords<>'SKIP') then begin
                writemsg(awords,3);
                end;
          end else begin
                writemsg(s,1);
          end;
    end;

    (* repeat
      while not(ivKeypressed) do begin
        doslice;
        if tcheck(st,2) then begin
                checkmsgs;
                st:=timer;
        end;
      end;
      c:=ivreadchar;
    until c in [#8,#9,#13,^W,#25,#27,' '..#255];

    { Process colours & tabs }
    Case c of
      #9: Begin
        c := #0;
      End;
    End;

    quit := (c = #27);
    If (not quit) and (c <> #0) then begin
      { Make sure we're in the right window, If not then relocate }
      cw := 2;
      ivgotoxy(off[cw].x+p[cw].x,off[cw].y+p[cw].y);
      { Process the keys }
      ivtextcolor(7);
      ivtextbackground(0);
      Case c of
        ^W: begin
            cw:=2;
            cl[cw]:='';
            lastcl[cw]:='';
            clearwindow(2);
            end;
        ^Y: Begin
          p[cw].x := 1;
          ivgotoxy(off[cw].x+p[cw].x,off[cw].y+p[cw].y);
          ivwrite(#27+'[K');
          ivgotoxy(off[cw].x+p[cw].x,off[cw].y+p[cw].y);
          cl[cw] := '';
          logcl[cw]:='';
        End;
        #8: Begin
          If p[cw].x <> 1 then begin
            Dec(p[cw].x);
            dec(cl[cw][0]); { take off a character in current line }
            dec(logcl[cw][0]);
            ivwrite(^H' '^H);
          End;
        End;
        #13: Begin
          lastcl[cw]:=cl[cw];
          if (lasttempmsg<>0) then begin
                inc(lasttempmsg);
                if (lasttempmsg>10) then begin
                        writetempmsg(1);
                        lasttempmsg:=0;
                        writemsg(cl[cw],1);
                end else begin
                        tempmsg[lasttempmsg]:=cl[cw];
                        writetempmsg(1);
                        lasttempmsg:=0;
                end;
                  logcl[cw]:='';
                  cl[cw] := '';
                  inc(p[cw].y);
                  p[cw].x := 1;
                  ivgotoxy(off[cw].x+p[cw].x,off[cw].y+p[cw].y);
          end else begin
          if (cl[cw][1]='/') then begin
                awords:='';
                if allcaps(copy(cl[cw],1,3))='/ME' then begin
                        if (copy(cl[cw],5,length(cl[cw])-4)<>'') then begin
                        awords:='%120%* %150%'+osig+' %120%'+copy(cl[cw],5,length(cl[cw])-4);
                        end;
                end else
                if allcaps(cl[cw])='/HELP' then begin
                        helpnorm;
                        awords:='SKIP';
                end else
                if allcaps(copy(cl[cw],1,6))='/WHOIS' then begin
                        if (copy(cl[cw],8,length(cl[cw]))<>'') then begin
                        awords:=getline1(copy(cl[cw],8,length(cl[cw])));
                        dispmsg(awords,3);
                        awords:=getline2(copy(cl[cw],8,length(cl[cw])));
                        if (awords<>'') then begin
                        awords:='';
                        logcl[cw]:='';
                        cl[cw] := '';
                        inc(p[cw].y);
                        p[cw].x := 1;
                        ivgotoxy(off[cw].x+p[cw].x,off[cw].y+p[cw].y);
                        dispmsg(awords,3);
                        end;
                        awords:=getline3(copy(cl[cw],8,length(cl[cw])));
                        if (awords<>'') then begin
                        logcl[cw]:='';
                        cl[cw] := '';
                        inc(p[cw].y);
                        p[cw].x := 1;
                        ivgotoxy(off[cw].x+p[cw].x,off[cw].y+p[cw].y);
                        dispmsg(awords,3);
                        end;
                        awords:='';
                        end;
                end else
                if allcaps(copy(cl[cw],1,4))='/BYE' then begin
                        quitmsg:='';
                        if (copy(cl[cw],6,length(cl[cw])-5)<>'') then begin
                        quitmsg:=copy(cl[cw],6,length(cl[cw])-5);
                        end;
                        quit:=TRUE;
                        awords:='SKIP';
                end else
                if allcaps(cl[cw])='/ECHO ON' then begin
                        awords:='SKIP';
                        localecho:=1;
                end else
                if allcaps(cl[cw])='/ECHO BRIEF' then begin
                        awords:='SKIP';
                        localecho:=0;
                end else
                if allcaps(cl[cw])='/ECHO OFF' then begin
                        awords:='SKIP';
                        localecho:=2;
                end else
                if (allcaps(copy(cl[cw],1,5))='/QUIT') or
                   (allcaps(copy(cl[cw],1,2))='/Q') then begin
                        quitmsg:='';
                        if (copy(cl[cw],7,length(cl[cw])-6)<>'') then begin
                        quitmsg:=copy(cl[cw],7,length(cl[cw])-6);
                        end;
                        quit:=TRUE;
                        awords:='SKIP';
                end;
                if (awords<>'') and (awords<>'SKIP') then begin
                writemsg(awords,3);
                end;
                  logcl[cw]:='';
                  cl[cw] := '';
                  inc(p[cw].y);
                  p[cw].x := 1;
                  ivgotoxy(off[cw].x+p[cw].x,off[cw].y+p[cw].y);
          end else begin
                  writemsg(cl[cw],1);
                  logcl[cw]:='';
                  cl[cw] := '';
                  inc(p[cw].y);
                  p[cw].x := 1;
                  ivgotoxy(off[cw].x+p[cw].x,off[cw].y+p[cw].y);
          end;
          end;
        End;
        else Begin
          If 70 <= byte(cl[cw][0]) then begin { Should we wrap? }
            temp := '';
            rtemp := '';
            loop := byte(cl[cw][0]);
            { Check for a space in the line }
            If pos(#32,cl[cw]) <> 0 then while (cl[cw][loop] <> #32) do Begin
              ivwrite(^H' '^H);
              temp := temp + cl[cw][loop];
              delete(cl[cw],loop,1);
              delete(logcl[cw],loop,1);
              dec(loop);
            end
            { If no space then cut the line short }
            else while (loop >= 69) do Begin
              ivwrite(^H' '^H);
              temp := temp + cl[cw][loop];
              delete(cl[cw],loop,1);
              delete(logcl[cw],loop,1);
              dec(loop);
            End;
            { Reverse what's in Temp }
            If temp[0] <> #0 then for loop := byte(temp[0]) downto 1 do rtemp := rtemp + temp[loop];

            inc(lasttempmsg);
            if (lasttempmsg>10) then begin
                lasttempmsg:=10;
                writetempmsg(1);
                lasttempmsg:=1;
                for x:=1 to 10 do tempmsg[x]:='';
            end;
            tempmsg[lasttempmsg]:=cl[cw];
            inc(p[cw].y);
            p[cw].x := 1;
            ivgotoxy(off[cw].x+p[cw].x,off[cw].y+p[cw].y);

            ivwrite(rtemp+c);
            p[cw].x:=length(rtemp+c)+1;
            logcl[cw]:='';
            
            lastcl[cw]:=cl[cw];
            cl[cw] := rtemp+c;
            logcl[cw]:= rtemp+c;
          end
          else Begin
            cl[cw] := cl[cw] + c;
            logcl[cw]:=logcl[cw]+c;
            inc(p[cw].x);
            ivwrite(c);
          End;
        End;
      End;
      { Make sure it hasn't scrolled too far }
      If p[cw].y > 6 then clearwindow(cw);
    End; *)
  until (quit) or not(ivCarrier);
  if (quitmsg<>'') then begin
        writemsg(osig+' has left chat (QUIT: '+quitmsg+')',2);
  end else begin
        if not(ivCarrier) then begin
              writemsg(osig+' has left chat (disconnected)',2);
        end else begin
              writemsg(osig+' has left chat',2);
        end;
  end;
  disableindex;
  textattr := lightgray;
  cls;
End;

procedure getroom;
var rf:file of roomrec;
    rlf:file of roomlst;
    rl:roomlst;
    i,tr,i2,gr:integer;
    sr:searchrec;
    numlisted:integer;
    listrooms:boolean;
    s,s2:string;
    don:boolean;
begin
listrooms:=TRUE;
don:=false;
assign(rf,nexusdir+'CHAT\CHANNELS.DAT');
assign(rlf,nexusdir+'CHAT\CHANS.LST');
repeat
if (listrooms) then begin
cls;
ivwriteln('%090%Available Channels:');
ivwriteln('');
i:=1;
{$I-} reset(rf); {$I+}
if (ioresult=0) then begin
read(rf,rm);
while (i<=1000) and not(eof(rf)) do begin
        read(rf,rm);
        if (rm.active) then ivwriteln('%150%'+mrn(cstr(i),4)+' %090%'+rm.name);
        inc(i);
end;
close(rf);
end;
end;
listrooms:=TRUE;
ivwriteln('');
s:='';
ivwrite('%090%Selection (%150%?%090%=Help) : %150%');
ivreadln(s,1,'U');
gr:=value(s);
if (s='') then listrooms:=TRUE else begin
if (gr<>0) then s:='J';
case s[1] of
     '?':begin
                ivwriteln('');
                ivwriteln('%080%(%150%J%080%)%090% Join channel (or use room #)');
                ivwriteln('%080%(%150%C%080%)%090% Create channel');
                ivwriteln('%080%(%150%Q%080%)%090% Exit nxCHAT');
                ivwriteln('');
                listrooms:=FALSE;
         end;
     'C':begin
        ivwrite('%090%New channel name: %150%');
        s2:='';
        ivreadln(s2,40,'');
        i:=1;
        writeln(nexusdir+'CHAT\CHANNELS.DAT');
        {$I-} reset(rf); {$I+}
        if (ioresult<>0) then begin
                rewrite(rf);
                rm.name:='';
                rm.active:=FALSE;
                write(rf,rm);
                seek(rf,0);
        end;
                read(rf,rm);
                i:=0;
                while not(eof(rf)) and (i=0) do begin
                        read(rf,rm);
                        if not(rm.active) then i:=filepos(rf)-1;
                end;
                if (i=0) then i:=filesize(rf);
                rm.name:=s2;
                rm.active:=TRUE;
                seek(rf,i);
                write(rf,rm);
                close(rf);
                {$I-} reset(rlf); {$I+}
                if (ioresult<>0) then begin rewrite(rlf); end;
                if (i>filesize(rlf)-1) then
                for i2:=filesize(rlf) to i do begin
                        seek(rlf,i2);
                        fillchar(rl,sizeof(rl),#0);
                        write(rlf,rl);
                end;
                rl.who[cnode].Name:=online.name;
                rl.who[cnode].sig:=osig;
                if not(localc) then rl.who[cnode].usern:=online.number
                else rl.who[cnode].usern:=0;
                seek(rlf,i);
                write(rlf,rl);
                close(rlf);
                currentroom:=i;
                don:=TRUE;
        if (i>1000) then ivwriteln('%120%Cannot create any more channels.');
        end;
     'Q':begin
        don:=TRUE;
        end;
     'J':begin
        if (gr=0) then begin
        ivwrite('%090%Join which channel: %150%');
        s2:='';
        ivreadln(s2,4,'');
        tr:=value(s2);
        end else tr:=gr;
        {$I-} reset(rf); {$I+}
        if (ioresult<>0) then begin
                ivwriteln('%120%No rooms available.');
        end else begin
                if (tr>filesize(rf)-1) then begin
                        ivwriteln('%120%Channel not available.');
                end else begin
                        seek(rf,tr);
                        read(rf,rm);
                        close(rf);
                        if (rm.active) then begin
                        ivwriteln('%090%Joining Channel: %150%'+rm.name);
                        rl.who[cnode].Name:=online.name;
                        rl.who[cnode].sig:=osig;
                        if not(localc) then
                                rl.who[cnode].usern:=online.number
                        else
                                rl.who[cnode].usern:=0;
                        {$I-} reset(rlf); {$I+}
                        if (ioresult<>0) then begin
                                ivwriteln('%120%Error addressing channel!');
                        end else begin
                        seek(rlf,tr);
                        write(rlf,rl);
                        close(rlf);
                        currentroom:=tr;
                        don:=TRUE;
                        end;
                        end else begin
                        ivwriteln('%120%Channel not available.');
                        end;
                end;
        end;
        end;
        else listrooms:=TRUE;
end;
end;
until (don);
end;

procedure endprogram;
begin
if not(localonly) then ivdeinstallmodem;
clrscr;
halt;
end;

procedure updatestatus;
begin
window(1,1,80,25);
gotoxy(1,25);
textcolor(15);
textbackground(3);
clreol;
write(mln(online.name,24)+' � Node '+mln(cstr(cnode),4)+'�');
textcolor(7);
textbackground(0);
window(1,1,80,24);
end;

begin
currentroom:=0;
getparams;
clrscr;
openfiles;
updatestatus;
getuser;
if (osig='') then endprogram;
updatestatus;
splitscreen;
endprogram;
end.
