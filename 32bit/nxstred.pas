{----------------------------------------------------------------------------}
{ Nexus Bulletin Board System                                                }
{                                                                            }
{ All material contained herein is                                           }
{  (c) Copyright 1996 Epoch Development Company.  All rights reserved.       }
{  (c) Copyright 1994-95 Intuitive Vision Software.  All rights reserved.    }
{                                                                            }
{ MODULE     :  NXSTRED.PAS (String Editor Program Module)                   }
{ AUTHOR     :  George A. Roberts IV                                         }
{                                                                            }
{----------------------------------------------------------------------------}
{ Nexus and Nexecutable are trademarks of Epoch Development Company.         }
{----------------------------------------------------------------------------}
{$A+,B+,D-,E+,F+,G+,I+,L-,N-,O-,R+,S+,V-}
{$M 50000,0,100000}      { Memory Allocation Sizes }

uses dos,crt,myio,misc,mulaware,ansi3;

TYPE  StringPtr=^StringIDX;

CONST maxstr:integer=2000;
      mcimod:byte=0;                { 0 - no modification   1 - L justify   }
                                    { 2 - right justify                     }
      mcichange:integer=0;
      mcipad:string='';
      noshowmci:boolean=FALSE;
      noshowpipe:boolean=FALSE;
      langname:string='ENGLISH';
      multsk:string='';
      fullscreen:boolean=FALSE;
      showfullfilename:string='';

VAR   current:longint;
      stridx:stringptr;
      langr:languagerec;

procedure endprogram;
begin
textcolor(7);
textbackground(0);
dispose(stridx);
clrscr;
end;

procedure getlang(b:byte);
var langf:file of languagerec;
    ok:boolean;
    fstringf:file;
    numread:word;
begin
ok:=TRUE;
assign(langf,adrv(systat.gfilepath)+'LANGUAGE.DAT');
{$I-} reset(langf); {$I+}
if (ioresult<>0) then begin
         displaybox('Error reading LANGUAGE.DAT',2000);
         endprogram;
end;
if (b<=filesize(langf)-1) then begin
        seek(langf,b);
        read(langf,langr);
end else begin
        if (filesize(langf)-1>=1) then begin
                seek(langf,1);
                read(langf,langr);
        end else begin
         displaybox('Error reading LANGUAGE.DAT',2000);
         endprogram;
        end;
end;
close(langf);
assign(fstringf,adrv(systat.gfilepath)+langr.filename+'.NXL');
filemode:=66; 
{$I-} reset(fstringf,1); {$I-}
if ioresult<>0 then begin
        displaybox('Error reading '+adrv(systat.gfilepath)+langr.filename+'.NXL ... Exiting.',2000);
        endprogram;
end;
blockread(fstringf,stridx^,sizeof(stridx^),numread);
if (numread<>sizeof(stridx^)) then begin
        displaybox('Error reading '+adrv(systat.gfilepath)+langr.filename+'.NXL ... Exiting.',2000);
        endprogram;
end;
close(fstringf);
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
if (fullscreen) then begin
while not(keypressed) do begin end;
c:=readkey;
end;
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
if (fullscreen) then begin
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
end;

function smci3(s2:string):string;
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
  if (allcaps(copy(s2,1,4))='GOTO') and (fullscreen) then begin
                gotoxy(value(copy(s2,5,pos(',',s2)-5)),
                        value(copy(s2,pos(',',s2)+1,length(s2)-pos(',',s2))));
                s:='';
  end else
  if (allcaps(s2)='PAUSE') then begin
        pause;
        s:='';
        end else
  if (allcaps(s2)='PAUSEYN') then begin
        pauseyn;
        s:='';
        end else
  if (allcaps(s2)='CLS') and (fullscreen) then begin
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

function processMCI(ss:string):string;
var ss3,ss4:string;
    ps1,ps2:integer;
    ok,done:boolean;
begin
  done:=false;
  ss4:='';
  mcipad:='';

{ Testing | Testing2 | Testing 3 | }

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
                        ss3:=smci3(copy(ss,ps1+1,(ps2-ps1)-1));
                        if (mcimod<>0) then begin
                        mcipad:=mcipad+ss3;
                        end else begin
                        ss4:=ss4+ss3;
                        end;
                        ss:=copy(ss,ps2+1,length(ss));
                end;
	end;
	if (pos('|',ss)=0) then done:=TRUE;
  end;
  if (ss<>'') then ss4:=ss4+ss;
  ss:=ss4;
  for ps1:=1 to length(ss) do if ss[ps1]=#28 then ss[ps1]:='|';

  processMCI:=ss;
end;

procedure cwritenew2(s:string);
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
                        ss3:=smci3(copy(ss,ps1+1,(ps2-ps1)-1));
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
  for ps1:=1 to length(ss) do if ss[ps1]=#28 then ss[ps1]:='|';


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

procedure displayfile(fn:string);
var tf:text;
    ss:string;
begin
assign(tf,fn);
{$I-} reset(tf); {$I+}
if (ioresult<>0) then exit;
while not(eof(tf)) do begin
      readln(tf,ss);
      cwritenew2(ss+#13#10);
end;
close(tf);
end;

procedure printf(fn:string);              { see if an *.ANS file is available} 
var ffn,ps,ns,es,s,sss:string;                  { if you have ansi graphics invoked}
    ps1,ps2,i,j,wx,wy:integer;
    year,month,day,dayofweek:word;
    nofile,done,abort,next:boolean;
begin
  nofile:=FALSE;
  fn:=sqoutsp(fn);
  fn:=processMCI(fn);
  sss:='';
  if (fn='') then exit;
  if (pos('\',fn)=0) then begin
    j:=2;
    fsplit(fexpand(fn),ps,ns,es);
    if (langr.displaypath<>'') then begin
        if (not exist(adrv(langr.displaypath)+ns+'.*')) then begin
                if (langr.checkdefpath) then begin
                        if not(exist(adrv(systat.afilepath)+ns+'.*')) then nofile:=true
                         else begin
                                ffn:=adrv(systat.afilepath)+fn;
                         end;
                end else nofile:=TRUE;
        end else begin
                ffn:=adrv(langr.displaypath)+fn;
        end;
    end else begin
        if (not exist(adrv(systat.afilepath)+ns+'.*')) then nofile:=TRUE
        else begin
                ffn:=adrv(systat.afilepath)+fn;
             end;
    end;
  end else ffn:=fn;
  if not(nofile) then begin
    ffn:=fexpand(ffn);

    if (pos('.',fn)=0) then begin
      if (exist(ffn+'.ans')) then begin
        ffn:=ffn+'.ANS';
        nofile:=FALSE;
      end;
      if (nofile) then
          if (exist(ffn+'.TXT')) then begin
          ffn:=ffn+'.txt';
          nofile:=FALSE;
          end;
    end;
    end;


  ffn:=allcaps(ffn); s:=ffn;
  if (copy(ffn,length(ffn)-3,4)='.ANS') then begin
    if (exist(copy(ffn,1,length(ffn)-4)+'.ANS')) then
      repeat
	i:=random(10);
	if (i=0) then
          ffn:=copy(ffn,1,length(ffn)-4)+'.ANS'
	else
          ffn:=copy(ffn,1,length(ffn)-4)+'.AN'+cstr(i);
      until (exist(ffn));
  end;

  if (copy(ffn,length(ffn)-3,4)='.TXT') then begin
    if (exist(copy(ffn,1,length(ffn)-4)+'.TXT')) then
      repeat
	i:=random(10);
	if (i=0) then
          ffn:=copy(ffn,1,length(ffn)-4)+'.TXT'
	else
          ffn:=copy(ffn,1,length(ffn)-4)+'.TX'+cstr(i);
      until (exist(ffn));

  end;

  getdate(year,month,day,dayofweek);
  s:=ffn; s[length(s)-1]:=chr(dayofweek+49);
  if (exist(s)) then ffn:=s;

  displayfile(ffn);
end;

procedure cwritenew(s:string);
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
                        ss3:=smci3(copy(ss,ps1+1,(ps2-ps1)-1));
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
  for ps1:=1 to length(ss) do if ss[ps1]=#28 then ss[ps1]:='|';


  dispextra:=FALSE;
  if (copy(ss,length(ss)-4,5)='[s'+#13+#10) then dispextra:=TRUE;

  if (length(ss)>2) then begin
     if (allcaps(copy(ss,1,6))='|FILE|') then begin
                while (pos(#13,ss)<>0) do begin
                        delete(ss,pos(#13,ss),1);
                end;
                while (pos(#10,ss)<>0) do begin
                        delete(ss,pos(#10,ss),1);
                end;
                showfullfilename:=copy(ss,7,length(ss)-6);
                ss:='%150%<<Press SPACE to view file>>';
     end;
  end;

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

procedure openfiles;
var systatf:file of MatrixREC;
begin
nexusdir:=getenv('NEXUS');
if (nexusdir[length(nexusdir)]='\') then nexusdir:=copy(nexusdir,1,length(nexusdir)-1);
filemode:=66;
assign(systatf,nexusdir+'\MATRIX.DAT');
{$I-} reset(systatf); {$I+}
if (ioresult<>0) then begin
        writeln('Error opening '+allcaps(nexusdir)+'\MATRIX.DAT!');
        endprogram;
end;
read(systatf,systat);
close(systatf);
end;


function gstring(x:integer):STRING;
var f:file;
    s:string;
    numread:word;
begin
if (stridx^.offset[x]<>-1) then begin
assign(f,adrv(systat.gfilepath)+langr.filename+'.NXL');
{$I-}reset(f,1); {$I+}
if (ioresult<>0) then begin
        gstring:='';
        exit;
end;
{$I-} seek(f,stridx^.offset[x]); {$I+}
if (ioresult<>0) then begin
        gstring:='';
        close(f);
        exit;
end;
blockread(f,s[0],1,numread);
if (numread<>1) then begin
        gstring:='';
        close(f);
        exit;
end;
blockread(f,s[1],ord(s[0]),numread);
if (numread<>ord(s[0])) then begin
        gstring:='';
        close(f);
        exit;
end;
close(f);
end else s:='';
gstring:=s;
end;

procedure bottom;
begin
window(1,1,80,25);
gotoxy(1,25);
textcolor(15);
textbackground(1);
clreol;
write('nxSTRED v'+version+' - Configurable String Editor for Nexus Bulletin Board System');
textcolor(7);
textbackground(0);
end;

procedure top1;
begin
window(1,1,80,25);
gotoxy(1,1);
textbackground(1);
clreol;
if (current=1) then begin
      textcolor(8);
end else begin
      textcolor(15);
end;
write(mln('- previous',40));
if (current=maxstr) then begin
      textcolor(8);
end else begin
      textcolor(15);
end;
gotoxy(41,1);
write(mrn('next -',40));
textcolor(7);
textbackground(0);
end;

procedure top2;
begin
window(1,1,80,25);
gotoxy(1,2);
textbackground(3);
clreol;
textcolor(15);
write(mln(' ',64)+' ³ '+mrn(cstr(current)+' of '+cstr(maxstr),12));
textcolor(7);
textbackground(0);
end;

procedure top3;
begin
window(1,1,80,25);
gotoxy(1,4);
textbackground(0);
clreol;
textcolor(9);
write('ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
textcolor(7);
textbackground(0);
end;

procedure main;
var curstr,s:string;
    done:boolean;
    c:char;
    w2:windowrec;

    procedure clearspace;
    var x:integer;
    begin
    textcolor(7);
    textbackground(0);
    for x:=5 to 24 do begin
      gotoxy(1,x);
      clreol;
    end;
    end;

begin
cursoron(FALSE);
done:=FALSE;
repeat
gotoxy(1,3);
textcolor(7);
textbackground(0);
clreol;
curstr:=gstring(current);
write(copy(curstr,1,80));
clearspace;
gotoxy(1,5);
cwritenew(curstr);
while not(keypressed) do begin end;
c:=readkey;
case c of
      #0:begin
            c:=readkey;
            case c of
                  #75:begin
                        if (current>1) then begin
                              dec(current);
                        end else current:=maxstr;
                        top1;
                        top2;
                      end;
                  #77:begin
                        if (current=maxstr) then begin
                              current:=1;
                        end else inc(current);
                        top1;
                        top2;
                      end;
            end;
         end;
      #32:begin
          fullscreen:=TRUE;
          window(1,1,80,24);
          clrscr;
          printf(showfullfilename);
          showfullfilename:='';
          pause;
          clrscr;
          top1;
          top2;
          top3;
          fullscreen:=FALSE;
          end;
     '0'..'9':begin
  setwindow(w2,26,12,55,14,3,0,8,'',TRUE);
  gotoxy(2,1);
  textcolor(7);
  textbackground(0);
  write('Goto String Number : ');
  gotoxy(21,1);
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
  if (value(s)>0) and (value(s)<=maxstr) then begin
  if (s<>'') then begin
                        current:=value(s);
                        top1;
                        top2;
  end;
  end;
  removewindow(w2);

                        end;
      #13:begin
                                        gotoxy(1,3);
                                        infield_inp_fgrd:=10;
                                        infield_inp_bkgd:=0;
                                        infield_out_fgrd:=7;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=FALSE;
                                        infield_numbers_only:=FALSE;
                                        infield_show_colors:=FALSE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        infield_insert:=TRUE;
                                        infield_maxshow:=80;
                                        s:=curstr;
                                        infielde(s,255);
                                        infield_maxshow:=0;
                                        infield_allcaps:=FALSE;
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        if (s<>curstr) then begin
                                          { set string }
                                        end;
            
          end;
      #27:done:=TRUE;
end;
until (done);
cursoron(TRUE);
end;

begin
current:=1;
new(stridx);
getos;
openfiles;
if (paramcount=1) then begin
      getlang(value(paramstr(1)));
end else begin
      getlang(1);
end;
clrscr;
bottom;
top1;
top2;
top3;
main;
endprogram;
end.
