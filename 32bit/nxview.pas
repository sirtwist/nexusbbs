{$A+,B+,D-,E+,F+,G+,I+,L-,N-,O-,R+,S+,V-}
{$M 65000,0,100000}      { Memory Allocation Sizes }
program nxview;

uses dos,crt,myio,misc,mulaware,ansi3;

const ver2='1.04';
      multsk:string='None Detected';
      mcimod:byte=0;
      mcichange:integer=0;
      mcipad:string='';

var t:text;
    x:integer;
    fname:string;
    s:string;
    extratype:word;

procedure title;
begin
  textcolor(7);
  textbackground(0);
  clrscr;
  writeln('nxVIEW v',ver2,' - File Viewer for Nexus Bulletin Board System Color Codes');
  writeln('(c) Copyright 1996-97 Epoch Development Company.  All Rights Reserved.');
end;

    function getlastparen(s8:string):integer;
    var x8,x9:integer;
    begin
    x8:=length(s8);
    x9:=0;
    while (x8>1) and (x9=0) do begin
    if (s8[x8]=')') then x9:=x8;
    dec(x8);
    end;
    getlastparen:=x9;
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

procedure getos;
var regs:registers;
    hiver,lover:string;
begin
  regs.ax:=$3306;
  intr($21,regs);
  if ((regs.bl=5) and (regs.bh=50)) then multitasker:=WinNT;
          Case MultiTasker of
                None         : begin
                        regs.ah:=$30;
                        intr($21,regs);
                        multsk:='DOS v'+cstr(regs.al)+'.'+cstr(regs.ah);
                        end;
                DESQview     : begin
                        str(Hi(MulVersion),HiVer);str(Lo(MulVersion),LoVer);
                        multsk:='DESQview v'+HiVer+'.'+LoVer;
                        end;
                WinEnh       : begin
                        str(Hi(MulVersion),HiVer);str(Lo(MulVersion),LoVer);
                        if (Hiver='4') then
                        multsk:='Windows 95'
                        else
                        multsk:='Windows v'+Hiver+'.'+LoVer+'/Enhanced';
                        end;
                OS2          : begin
                        str(Hi(MulVersion),HiVer);str(Lo(MulVersion),LoVer);
                        multsk:='OS/2 v'+HiVer+'.'+LoVer;
                        end;
                DoubleDOS    : multsk:='DoubleDOS';
                MultiDos     : multsk:='MultiDos Plus';
                VMiX         : begin
                        str(Hi(MulVersion),HiVer);str(Lo(MulVersion),LoVer);
                        multsk:='VMiX v'+HiVer+'.'+LoVer;
                        end;
                TopView      : begin
                                If MulVersion <> 0 then
                                        begin
                                        str(Hi(MulVersion),HiVer);str(Lo(MulVersion),LoVer);
                                        multsk:='TopView v'+HiVer+'.'+LoVer
                                end Else
                                        multsk:='TaskView, DESQview 2.00-2.25, OmniView, or Compatible';
                                end;
                TaskSwitcher : multsk:='DOS 5.0 Task Switcher or Compatible';
                WinStandard  : multsk:='Windows 2.xx or 3.x in Real or Standard Mode';
                WinNT        : begin
                               str(Hi(MulVersion),HiVer);str(Lo(MulVersion),LoVer);
                               multsk:='Windows NT v'+Hiver+'.'+LoVer;
                                end;
                end;
end;

procedure pause;
var c:char;
    b:byte;
begin
b:=textattr;
textcolor(15);
write('Hit that key!');
while not(keypressed) do begin end;
c:=readkey;
textattr:=b;
writeln;
end;

procedure pauseyn;
var c:char;
    b:byte;
begin
b:=textattr;
textcolor(12);
write('Continue? ');
textcolor(11);
write('Yes');
while not(keypressed) do begin end;
c:=readkey;
case upcase(c) of
        'Y',#13:begin
                textattr:=b;
                writeln;
               end;
        'N':begin
                writeln(^H^H^H'No');
                textcolor(7);
                halt;
            end;
end;
end;

function smci3(s2:string;tpe:byte):string;
var c2:char;
    s,ss,ss3,dum:string;
    j,i,ps3,ps4,ps5,lparen:integer;
    i2,r:real;
    oldpf,done:boolean;
    newmod:byte;
    newchange:integer;

begin
  newmod:=0;
  s:='#NEXUS#';
  if (allcaps(s2)='NUMEDITORS') then begin
        s:='1';
  end else
  if (allcaps(s2)='NMNAME') then begin
        s:='Node2 User';
  end else
  if (allcaps(s2)='NMNODE') then begin
        s:='2';
  end else
  if (allcaps(s2)='NMMESSAGE') then begin
        s:='Hey!  How about a chat!';
  end else
  if (allcaps(s2)='MINBAUD') then begin
        s:='2400';
  end else
  if (allcaps(s2)='LOCKBEGIN') then begin
        s:='00:00:00';
  end else
  if (allcaps(s2)='LOCKEND') then begin
        s:='00:00:00';
  end else
  if (allcaps(s2)='CUREDITOR') then begin
        s:='Internal Nexus Line Editor';
  end else
  if (allcaps(s2)='CURLANG') then begin
        s:='English (Nexus Default)';
  end else
  if (allcaps(copy(s2,1,2))='PL') and (mcimod=0) then begin
        newmod:=1;
        newchange:=value(copy(s2,3,length(s2)-2));
        s:='';
  end else
  if (allcaps(copy(s2,1,2))='PR') and (mcimod=0) then begin
        newmod:=2;
        newchange:=value(copy(s2,3,length(s2)-2));
        s:='';
  end else
  if (allcaps(copy(s2,1,2))='PC') and (mcimod=0) then begin
        newmod:=3;
        newchange:=value(copy(s2,3,length(s2)-2));
        s:='';
  end else
  if (allcaps(s2)='NLNODE') then s:='1' else
  if (allcaps(s2)='NLNAME') then begin
        if (systat.aliasprimary) then
        s:='Node1 Alias'
        else s:='Node1 Realname';
  end else
  if (allcaps(s2)='NLFROM') then s:='Everywhere' else
  if (allcaps(s2)='NLAVAIL') then begin
        s:='Avail';
  end else
  if (allcaps(s2)='NLACT') then s:='Looking at files' else
  if (allcaps(s2)='MCONF') then s:='A' else
  if (allcaps(s2)='MCONFNAME') then begin
        s:='%120%Main Message Conference';
  end else
  if (allcaps(s2)='MSGPRIV') then s:='P' else
  if (allcaps(s2)='MSGTO') then begin
        s:='John Doe';
  end else
  if (allcaps(s2)='MSGFROM') then begin
        s:='Jane Doe';
  end else
  if (allcaps(s2)='MSGNEW') then begin
        s:='%120%Y';
  end else
  if (allcaps(s2)='MSGDATE') then begin
        s:=date;
  end else
  if (allcaps(s2)='MSGTIME') then begin
        s:=Time;
  end else
  if (allcaps(s2)='MSGSUBJ') then begin
        s:='Test Message';
  end else
  if (allcaps(s2)='MSGFLAGS') then begin
    s:='loc pvt ';
  end else
  if (allcaps(s2)='MSGREFER') then begin
      s:='<- 1';
  end else
  if (allcaps(s2)='MSGNEXT') then begin
      s:='3 ->';
  end else
  if (allcaps(s2)='MBNUMBER') then s:='0' else
  if (allcaps(s2)='MBNAME') then begin
        s:='%140%Private Messages';
	end else
  if (allcaps(s2)='MSGFILE') then begin
        s:='C:\NEXUS\MSGTMP'; 
	end else
  if (allcaps(s2)='HIGHMSG') then s:='3' else
  if (allcaps(s2)='MAXLINES') then begin
          s:='200';
	end else
  if (allcaps(s2)='MBASE') then begin
          s:=' %080%[%150%0%080%] %140%Private Messages';
	end else
  if (allcaps(s2)='CURMSG') then s:='2' else
  if (allcaps(s2)='FPOINTS') then s:='100' else
  if (allcaps(s2)='FBASE') then begin
          s:=' %080%[%150%0%080%] %140%Newly Uploaded Files';
	end else
  if (allcaps(s2)='FCONF') then s:='A' else
  if (allcaps(s2)='FCONFNAME') then begin
        s:='%120%Main File Conference';
  end else
  if (allcaps(s2)='FBNUMBER') then s:='1' else
  if (allcaps(s2)='ULFILE') then s:='TEST.RAR' else
  if (allcaps(s2)='FBNAME') then begin
        s:='%140%Newly Uploaded Files';
	end else
  if (allcaps(s2)='FBFREE') then begin
          s:='100';
	end else
  if (allcaps(s2)='DLFLAG') then s:='1' else
  if (allcaps(s2)='ULDLNUM') then begin
        s:='1 to 10';
        end else
  if (allcaps(s2)='ULDLKB') then begin
        s:='1k to 10k';
        end else
  if (allcaps(s2)='UREAL') then s:='John Doe' else
  if (allcaps(s2)='UFIRST') then s:='John'
	else
  if (allcaps(s2)='ULAST') then begin
        s:='Doe';
	end else
  if (allcaps(s2)='UALIAS') then s:='Mr. SysOp' else
  if (allcaps(s2)='UNAME') then s:='Mr. SysOp' else
  if (allcaps(s2)='UCALLFROM') then begin
        s:='Epoch Comm Systems';
  end else
  if (allcaps(s2)='UGENDER') then s:='M' else
  if (allcaps(s2)='ULASTON') then s:=datelong else
  if (allcaps(s2)='ULNAME') then s:='John Doe' else
  if (allcaps(s2)='ULCALL') then begin
        s:='Epoch Comm Systems';
  end else
  if (allcaps(s2)='ULGEN') then s:='M' else
  if (allcaps(s2)='ULLAST') then s:=date else
  if (allcaps(s2)='UADDRESS1') then s:='100 Somewhere St.' else
  if (allcaps(s2)='UADDRESS2') then s:='' else
  if (allcaps(s2)='UCITYST') then s:='Chicago, IL' else
  if (allcaps(s2)='UZIPCODE') then s:='60000-0000' else
  if (allcaps(s2)='UACCKEY') then s:='PASSWORD' else
  if (allcaps(s2)='SLEVEL') then s:='100' else
  if (allcaps(s2)='SLDESC') then s:='SysOp Security Level' else
  if (allcaps(s2)='SUBDESC') then s:='SysOp Subscription' else
  if (allcaps(s2)='SUBLEFT') then s:='30' else
  if (allcaps(s2)='SUBDAYS') then s:='60' else
  if (allcaps(s2)='TIMELEFT') then s:='24:00:00' else
  if (allcaps(s2)='UTITLE') then s:='SysOp' else
  if (allcaps(s2)='UPHONE1') then s:='312-000-0000' else
  if (allcaps(s2)='UPHONE2') then s:='' else
  if (allcaps(s2)='UPHONE3') then s:='' else
  if (allcaps(s2)='UPHONE4') then s:='' else
  if (allcaps(s2)='UTERM') then begin
                s:='Ansi';
	end else
  if (allcaps(s2)='TIMEBANK') then s:='100' else
  if (allcaps(s2)='TBADDED') then s:='0' else
  if (allcaps(s2)='USERUK') then s:='102' else
  if (allcaps(s2)='USERDK') then s:='437' else
  if (allcaps(s2)='USERUL') then s:='1' else
  if (allcaps(s2)='USERDL') then s:='3' else
  if (allcaps(s2)='USERPOST') then s:='10' else
  if (allcaps(s2)='USERFEED') then s:='2' else
  if (allcaps(s2)='LCNAME') then s:='John Doe' else
  if (allcaps(s2)='LCFROM') then s:='BBSland, USA' else
  if (allcaps(s2)='LCBAUD') then s:='28800' else
  if (allcaps(s2)='LCNODE') then s:='1' else
  if (allcaps(s2)='LCDATE') then s:=date else
  if (allcaps(s2)='LCTIME') then s:=time else
  if (allcaps(s2)='NODE') then s:='1' else
  if (allcaps(s2)='PADDEDNODE') then s:='0001' else
  if (allcaps(s2)='SEMANODE') then s:='001' else
  if (allcaps(s2)='TEMPDIR') then s:='C:\NEXUS\TEMP\NODE0001\' else
  if (allcaps(s2)='LOCKBAUD') then begin
        s:='0';
	end else
  if (allcaps(s2)='BAUD') then begin
        s:='0';
	end else
  if (allcaps(s2)='PORT') then s:='1' else
  if (allcaps(s2)='MULTIOS') then s:=multsk else
  if (allcaps(s2)='CMDLIST') then s:='ABC' else
  if (allcaps(s2)='CREASON') then s:='I want to talk to you!' else
  if (allcaps(s2)='BELL') then s:=^G else
  if (allcaps(s2)='LF') then s:=^M^J else
  if (allcaps(s2)='BS') then s:=^H else
  if (copy(allcaps(s2),1,2)='BS') then begin
        s:='';
        i:=value(copy(s2,3,length(s2)-2));
        if (i=0) then i:=1;
        j:=1;
        while (j<=i) do begin
                s:=s+^H;
                inc(j);
        end;
	end else
  if (allcaps(copy(s2,1,4))='GOTO') then begin
                gotoxy(value(copy(s2,5,pos(',',s2)-5)),
                        value(copy(s2,pos(',',s2)+1,length(s2)-pos(',',s2))));
  end else
  if (allcaps(s2)='PAUSE') then begin
        pause;
        s:='';
        end else
  if (allcaps(s2)='PAUSEYN') then begin
        pauseyn;
        s:='';
        end else
  if (allcaps(s2)='CLS') then begin
        clrscr;
        s:='';
  end else
  if (copy(allcaps(s2),1,5)='DELAY') then begin
	i:=value(copy(s2,6,length(s2)-5));
        if (i<>0) then delay(i*1000);
        s:='';
	end else
  if (allcaps(s2)='BBSNAME') then s:='Some BBS' else
  if (allcaps(s2)='BBSPHONE') then s:='000-000-0000' else
  if (allcaps(s2)='SYSOPNAME') then s:='John Doe' else
  if (allcaps(s2)='SYSOPAVAIL') then begin
         s:='Available';
  end else
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
  end;
  end else
  if (allcaps(s2)='NOABORT') then begin
        s:='';
  end;
{  if (mcimod<>0) then begin
        mcipad:=mcipad+s;
        s:='';
  end;}
  if (newmod<>0) then begin
        mcimod:=newmod;
        mcichange:=newchange;
  end;
  if (s='#NEXUS#') then s:=#28+s2+'|';
  smci3:=s;
end;

procedure newwrite(s:string);
var ss,sss,ss3,ss4:string;
    back,ps1,ps2,p1,p2,p3,colr:integer;
    tb:byte;
    c,mc:char;
    dispextra,done:boolean;
begin
  ss:=s; sss:='';
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
		ss[ps1]:=#28;
		ps2:=pos('|',ss);
		if (ps2-ps1<=1) then begin end else
                if (ps2<>0) then begin
                        ss3:=smci3(copy(ss,ps1+1,(ps2-ps1)-1),1);
                        if (mcimod<>0) then begin
                        mcipad:=mcipad+ss3;
                        end else begin
                        ss4:=ss4+ss3;
                        end;
                        ss:=copy(ss,ps2+1,length(ss));
{                        ss:=substone(ss,copy(ss,ps1,(ps2-ps1)+1),ss3);}
                end;
	end;
	if (pos('|',ss)=0) then done:=TRUE;
  end;
  if (ss<>'') then ss4:=ss4+ss;
  ss:=ss4;


  dispextra:=FALSE;
  if (copy(ss,length(ss)-4,5)='[s'+#13+#10) then dispextra:=TRUE;

  done:=false;
  begin
     while (ss<>'') and (pos('%',ss)<>0) do begin
      p1:=500;
      p2:=500;
      p3:=pos('%',ss); if (p3=0) then p3:=500;
      if (p3<p1) then p1:=p3 else p3:=500;
      colr:=100;
      back:=100;
      if (hback<>255) then back:=hback;
      if (p1<>500) then begin
        if (p3<>500) then begin
                ss[p3]:=#28;
                if ((length(ss)>=p3+4) and (ss[p3+1] in ['0'..'9']) and
                        (ss[p3+2] in ['0'..'9']) and (ss[p3+3] in ['0'..'9'])
                        and (ss[p3+4]='%')) then
                begin
                        ss[p3+4]:=#28;
                        colr:=value(ss[p3+1]+ss[p3+2]);
                        if (back=100) then back:=value(ss[p3+3]);
                        if (colr>31) or ((colr=0) and not((ss[p3+1]+ss[p3+2])='00')) then colr:=7;
                        if (back>7) or ((back=0) and not(ss[p3+3]='0')) then back:=0;
                        if (colr<>100) then begin
                                sss:=copy(ss,1,p3-1);
                                ss:=copy(ss,p3+5,length(ss)-(p3+4));
                        end;
                end else begin
                        ss[p3]:='%';
                        sss:=copy(ss,1,p3);
                        ss:=copy(ss,p3+1,length(ss)-p3);
                end;
        end;
      end else begin
        sss:=ss; ss:='';
      end;

      for ps1:=1 to length(sss) do display_ansi(sss[ps1]);

      if (colr<>100) and (back<>100) then begin
        tb:=0;
        if (colr-16>=0) then begin
                tb:=((colr-16) or (back shl 4));
                inc(tb,128);
        end else tb:=(colr or (back shl 4));
        textattr:=tb;
      end;
    end;
    for ps1:=1 to length(ss) do if (ss[ps1]=#28) then ss[ps1]:='%';
  end;
  for ps1:=1 to length(ss) do display_ansi(ss[ps1]);
end;

procedure helpscreen;
begin
clrscr;
title;
textcolor(7);
textbackground(0);
gotoxy(1,6);
writeln('Syntax :  NXVIEW [Filename]');
writeln;
writeln('     [Filename]  =  The filename to display.  nxVIEW assumes that');
writeln('                    the extension is .TXT unless an extension is');
writeln('                    specified.');
halt;
end;


procedure getparams;
var s2:string;
    x:integer;
begin
x:=1;
if (paramcount=0) then helpscreen;
while (x<=paramcount) do begin
        s2:=paramstr(x);
        if (s2[1]='-') or (s2[1]='/') then begin
                case upcase(s2[2]) of
                        '?':helpscreen;
                end;
        end else begin
                fname:=s2;
        end;
        inc(x);
end;
end;

begin
getparams;
if (pos('.',fname)=0) then fname:=fname+'.TXT';
if not(exist(fname)) then begin
        writeln('File not found: '+fname);
        halt;
end;
assign(t,fname);
{$I-} reset(t); {$I+}
if (ioresult<>0) then begin
        writeln('Error reading '+fname);
        halt;
end;
extratype:=0;
while not(eof(t)) do begin
        readln(t,s);
        newwrite(s+#13#10); 
end;
close(t);
textcolor(7);
textbackground(0);
gotoxy(1,wherey-1);
cursoron(TRUE);
end.
