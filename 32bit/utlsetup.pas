program utlsetup;

uses dos,crt,misc,myio;

const  noshowmci:boolean=FALSE;
       noshowpipe:boolean=FALSE;
       mcimod:byte=0;                { 0 - no modification   1 - L justify   }
                                     { 2 - right justify                     }
       mcichange:integer=0;
       mcipad:string='';

var fname:string;
    tf:text;
    euf:file of extutilsrec;
    eu:extutilsrec;
    desc,path:string;
    systatf:file of matrixrec;
    fnd:boolean;
    x,i:longint;

procedure helpscreen;
begin
writeln('UTLSetup v1.00 - Utility Menu Setup for Nexus Bulletin Board System');
writeln('(c) Copyright 2001 George A. Roberts IV. All rights reserved.');
writeln;
writeln('Syntax: UTLSETUP [drive:][\path\]filename.txt');
writeln;
writeln('[drive:][\path\]filename.txt represents the import filename.');
writeln;
halt;
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
  if (allcaps(s2)='NEXUSDIR') then s:=nexusdir else
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

procedure getparams;
var np,np2:integer;
    sp:string;
begin
  np:=paramcount;
  if (np=0) then helpscreen;
  np2:=1;
  while (np2<=np) do begin
        sp:=allcaps(paramstr(np2));
        case sp[1] of
                '/','-':begin
                        case sp[2] of
                                '?','H':helpscreen;
                        end;
                        end;
                 else begin
                        fname:=allcaps(sp);
                 end;
        end;
        inc(np2);
   end;
end;

begin
getparams;
nexusdir:=getenv('NEXUS');
if (nexusdir='') then begin
     displaybox('ERROR: NEXUS environment variable not set - exiting!',3000);
     halt;
end else nexusdir:=bslash(TRUE,nexusdir);
assign(systatf,nexusdir+'MATRIX.DAT');
{$I-} reset(systatf); {$I+}
if (ioresult<>0) then begin
     displaybox('ERROR: Cannot read MATRIX.DAT',3000);
     halt;
end;
read(systatf,systat);
close(systatf);
assign(tf,fname);
{$I-} reset(tf); {$I+}
if (ioresult<>0) then begin
     displaybox('Unable to import '+fname,3000);
     halt;
end;
filemode:=66;
assign(euf,adrv(systat.gfilepath)+'UTILMENU.DAT');
{$I-} reset(euf); {$I+}
if (ioresult<>0) then begin
     {displaybox('Cannot open UTILMENU.DAT',3000);
     halt;}
     rewrite(euf);
end;
readln(tf,desc);
readln(tf,path);
fnd:=false;
seek(euf,0);
while not(eof(euf)) and not(fnd) do begin
     read(euf,eu);
     if (allcaps(path)=allcaps(eu.executable)) then fnd:=TRUE;
end;
if not(fnd) then begin
     i:=0;
     fnd:=false;
     seek(euf,0);
     if (filesize(euf)>0) then
     while not(fnd) do begin
          read(euf,eu);
          if (allcaps(desc)<allcaps(eu.description)) then fnd:=TRUE else inc(i);
          if (eof(euf)) then fnd:=TRUE;
     end;
     if (fnd) then
     for x:=filesize(euf)-1 downto i do begin
          seek(euf,x);
          read(euf,eu);
          seek(euf,x+1);
          write(euf,eu);
     end;
     seek(euf,i);
     fillchar(eu,sizeof(eu),#0);
     eu.description:=desc;
     eu.executable:=path;
     write(euf,eu);
end;
close(euf);
end.
