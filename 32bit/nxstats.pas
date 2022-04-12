program nxstats;

uses dos,crt,misc;

const mcimod:byte=0;                { 0 - no modification   1 - L justify   }
                                    { 2 - right justify                     }
      mcichange:integer=0;
      mcipad:string='';

var systatf:file of matrixrec;
    xx:array[1..10] of
     record
          urec:longint;
          posts:longint;
     end;

function newcentered(s:string;x:integer):string;
var temp : string;
L : byte;
begin
    Fillchar(Temp[1],x,' ');
    Temp[0] := chr(x);
    L := length(s);
    If L <= x then
       Move(s[1],Temp[((x - L) div 2) + 1],L)
    else
       temp:=copy(s,1,x);
    newcentered := temp;
end; {center}

function smci3(s2:string;var ok:boolean):string;
var c2:char;
    s,ss,ss3,dum:string;
    j,i,ps3,ps4,ps5,lparen:integer;
    i2,r:real;
    newmod:byte;
    newchange:integer;
    done:boolean;


begin
  newmod:=0;
  s:='#NEXUS#';
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
  if (allcaps(copy(s2,1,9))='T10POSTER') then begin
        j:=value(copy(s2,10,length(s2)-2));
        seek(uf,xx[j].urec);
        read(uf,thisuser);
        s:=thisuser.name;
  end else
  if (allcaps(copy(s2,1,8))='T10POSTS') then begin
        j:=value(copy(s2,9,length(s2)-2));
        s:=cstr(xx[j].posts);
  end else
  if (allcaps(s2)='BBSNAME') then s:=systat.bbsname else
  if (allcaps(s2)='SYSOPNAME') then s:=systat.sysopname else
  if (allcaps(s2)='LF') then s:=^M^J else
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
          s:=newcentered(mcipad,mcichange);
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

procedure top10posts;
var fl,x,xxx:longint;
    totposts:longint;

  procedure dotop10postsfile;
  var t,t2:text;
      sss:string;
  begin
  assign(t,systat.gfilepath+'T10POSTS.TPL');
  assign(t2,systat.afilepath+'T10POSTS.ANS');
  {$I-} reset(t); {$I+}
  if (ioresult<>0) then begin
     writeln('Skipping T10POSTS -- unable to open T10POSTS.TPL');
     exit;
  end;
  rewrite(t2);
  while not(eof(t)) do begin
     readln(t,sss);
     writeln(t2,processmci(sss));
  end;
  close(t);
  close(t2);
  end;

begin
  assign(uf,adrv(systat.gfilepath)+'USERS.DAT');
  {$I-} reset(uf); {$I+}
  if (ioresult<>0) then begin
          writeln('Error reading '+adrv(systat.gfilepath)+'USERS.DAT');
          halt;
  end;
  fillchar(xx,sizeof(xx),#0);
  seek(uf,1);
  while not(eof(uf)) do begin
          read(uf,thisuser);
          fl:=filepos(uf)-1;
          x:=1;
          while (x<11) and (thisuser.msgpost<xx[x].posts) do begin
               inc(x);
          end;
          if (x<11) then begin
               for xxx:=9 downto x do begin
                    xx[xxx+1].posts:=xx[xxx].posts;
                    xx[xxx+1].urec:=xx[xxx].urec;
               end;
               xx[x].posts:=thisuser.msgpost;
               xx[x].urec:=fl;
          end;
  end;
  dotop10postsfile;
  close(uf);
end;

begin
  nexusdir:=getenv('NEXUS');
  if (nexusdir[length(nexusdir)]='\') then nexusdir:=copy(nexusdir,1,length(nexusdir)-1);
  filemode:=66;
  if (nexusdir='') then begin
        writeln('You must set your NEXUS environment variable to point to your main Nexus');
        writeln('directory or nxSTATS will not run.');
        writeln;
        halt(0);
  end;
{  getparams; }
  assign(systatf,nexusdir+'\MATRIX.DAT');
  {$I-} reset(systatf); {$I+}
  if (ioresult<>0) then begin
        writeln('Error reading '+nexusdir+'\MATRIX.DAT');
        halt;
  end;
  read(systatf,systat);
  close(systatf);
  top10posts;
end.
