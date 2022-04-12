unit runprog;

interface

uses dos,crt,common;

procedure runprogram(progname:string);

implementation

uses menus,doors;

TYPE
        HEADER=
        RECORD
                ID:ARRAY[1..3] of CHAR;
                revision:byte;
                OurCR:STRING[93];
                CreatedBy:STRING[60];
                CreatedOn:STRING[19];
                Copyright:STRING[80];
                Info1:STRING[80];
                Info2:STRING[80];
                VStart:LONGINT;
                VSize:LONGINT;
                CodeStart:LONGINT;
                CodeSize:LONGINT;
                IndexStart:LONGINT;
                IndexSize:LONGINT;
                VIndexStart:LONGINT;
                VIndexSize:LONGINT;
        END;

type cindex=Array[1..2000] of LONGINT;
type frecord=RECORD
        fl:file;
        ferror:byte;
        fopen:boolean;
     end;

var f:file;
    flist:array[1..10] of frecord;
    CodeIndex : ^cindex;
    VarIndex:ARRAY[1..100] of LONGINT;
    hdr : ^Header;
    w:word;
    x,codeid: integer;
    btype,b,b2:byte;
    s:string;

function smci4(s2:string):string;
var ss:string;
    i:integer;
    b:byte;
begin
ss:=#28+s2+#3;
i:=value(s2);
case i of
 0..399:begin
seek(f,varindex[i]);
blockread(f,i,2);
blockread(f,b,1);
case b of
        1:begin
          blockread(f,ss[0],1);
          blockread(f,ss[1],ord(ss[0]));
          end;
end;
end;
 400..1000:begin
                case i of
                        400:ss:=systat^.bbsname;
                        401:ss:=systat^.sysopname;
                end;
           end;
end;
smci4:=ss;
end;

function process(s:string):string;
var ps1,ps2:integer;
    ss,ss3,ss4:string;
    done:boolean;

begin
  ss:=s;
  done:=false;
  ss4:='';
  while not(done) do begin  
        ps1:=pos(#3,ss);
	if (ps1<>0) then begin
                ss4:=ss4+copy(ss,1,ps1-1);
		ss[ps1]:=#28;
                ps2:=pos(#3,ss);
		if (ps2-ps1<=1) then begin end else
                if (ps2<>0) then begin
                        ss3:=smci4(copy(ss,ps1+1,(ps2-ps1)-1));
                        ss4:=ss4+ss3;
                        ss:=copy(ss,ps2+1,length(ss));
                end;
	end;
        if (pos(#3,ss)=0) then done:=TRUE;
  end;
  if (ss<>'') then ss4:=ss4+ss;
  ss:=ss4;
  for ps1:=1 to length(ss) do if ss[ps1]=#28 then ss[ps1]:=#3;

  done:=false;
  ss4:='';
  while not(done) do begin  
        ps1:=pos(#1,ss);
	if (ps1<>0) then begin
                ss4:=ss4+copy(ss,1,ps1-1);
		ss[ps1]:=#28;
                ps2:=pos(#1,ss);
		if (ps2-ps1<=1) then begin end else
                if (ps2<>0) then begin
                        ss3:=gstring(value(copy(ss,ps1+1,(ps2-ps1)-1)));
                        ss4:=ss4+ss3;
                        ss:=copy(ss,ps2+1,length(ss));
                end;
	end;
        if (pos(#1,ss)=0) then done:=TRUE;
  end;
  if (ss<>'') then ss4:=ss4+ss;
  ss:=ss4;
  for ps1:=1 to length(ss) do if ss[ps1]=#28 then ss[ps1]:=#1;

  process:=ss;
end;

function process2(s:string):string;
var ps1,ps2:integer;
    ss,ss3,ss4:string;
    done:boolean;

begin
  ss:=s;
  done:=false;
  ss4:='';
  while not(done) do begin  
        ps1:=pos(#3,ss);
	if (ps1<>0) then begin
                ss4:=ss4+copy(ss,1,ps1-1);
		ss[ps1]:=#28;
                ps2:=pos(#3,ss);
		if (ps2-ps1<=1) then begin end else
                if (ps2<>0) then begin
                        ss3:=smci4(copy(ss,ps1+1,(ps2-ps1)-1));
                        ss4:=ss4+ss3;
                        ss:=copy(ss,ps2+1,length(ss));
                end;
	end;
        if (pos(#3,ss)=0) then done:=TRUE;
  end;
  if (ss<>'') then ss4:=ss4+ss;
  ss:=ss4;
  for ps1:=1 to length(ss) do if ss[ps1]=#28 then ss[ps1]:=#3;

  done:=false;
  ss4:='';
  while not(done) do begin  
        ps1:=pos(#1,ss);
	if (ps1<>0) then begin
                ss4:=ss4+copy(ss,1,ps1-1);
		ss[ps1]:=#28;
                ps2:=pos(#1,ss);
		if (ps2-ps1<=1) then begin end else
                if (ps2<>0) then begin
                        ss3:=gstring(value(copy(ss,ps1+1,(ps2-ps1)-1)));
                        ss4:=ss4+ss3;
                        ss:=copy(ss,ps2+1,length(ss));
                end;
	end;
        if (pos(#1,ss)=0) then done:=TRUE;
  end;
  if (ss<>'') then ss4:=ss4+ss;
  ss:=ss4;
  for ps1:=1 to length(ss) do if ss[ps1]=#28 then ss[ps1]:=#1;

  process2:=processMCI(ss);
end;

procedure fileput(b:byte; s:string);
begin
{$I-} blockwrite(flist[b].fl,s[1],length(s)); {$I+}
flist[b].ferror:=ioresult;
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
 fileonly := copy(s,1,pos('.',s)-1);
end;

procedure newstatus(newname:string);
var oc:byte;
    wx,wy:byte;
begin
          oc:=textattr;
          wx:=wherex;
          wy:=wherey;
          window(1,1,80,25);
          gotoxy(27,25);
          textcolor(14);
          textbackground(3);
          write(' Nexecutable : ');
          textcolor(12);
          write(mln(allcaps(newname),15));
          window(1,1,80,24);
          textattr:=oc;
          gotoxy(wx,wy);
end;

procedure runprogram(progname:string);
var inif,needelse,tempbool,noneedelse,nocommand:boolean;
    ts1,tempstr:string;
begin
inif:=FALSE;
needelse:=FALSE;
noneedelse:=FALSE;
progname:=allcaps(progname);
if pos('.',progname)=0 then progname:=progname+'.EXE';
if pos('\',progname)=0 then progname:=adrv(systat^.nexecutepath)+progname;
newstatus(fileonly(progname));
assign(f,progname);
{$I-} reset(f,1); {$I+}
if (ioresult<>0) then begin
        sl1('!','Unable to nexecute: '+progname);
        topscr;
        exit;
end;
sl1('+','Nexecuting '+progname);
new(hdr);
if (hdr=NIL) then begin
        sl1('!','Insufficient memory to execute nexecutable!');
        sl1('!','Terminating...');
        topscr;
        exit;
end;
seek(f,112);
blockread(f,hdr^,sizeof(hdr^));
seek(f,hdr^.indexstart);
new(codeindex);
if (codeindex=NIL) then begin
        sl1('!','Insufficient memory to run nexecutable!');
        topscr;
        exit;
end;
fillchar(codeindex^,sizeof(codeindex^),#0);
blockread(f,codeindex^,hdr^.indexsize);
seek(f,hdr^.vindexstart);
fillchar(varindex,sizeof(varindex),#0);
blockread(f,varindex,hdr^.vindexsize);
seek(f,112+sizeof(hdr^));
x:=1;
nocommand:=TRUE;
while (codeindex^[x]<>0) and not(hangup) do begin
if (codeindex^[x]>filesize(f)-1) then begin
        sl1('!','ERROR in nexecutable: Instruction #'+cstr(x));
        sprint('%120%Nexecutable: Runtime Error 001 at INST:'+cstrn(x));
        dispose(codeindex);
        close(f);
        topscr;
        exit;
end;
seek(f,codeindex^[x]);
blockread(f,codeid,2);
blockread(f,btype,1);
if (inif) then begin
        if not(nocommand) then
        if not(needelse) and not(noneedelse) and (btype<>8) and (btype<>9) then btype:=0;
end;
case btype of
        1:begin
                blockread(f,s[0],1);
                blockread(f,s[1],ord(s[0]));
                sprint(process(s));
          end;
        2:begin
                blockread(f,s[0],1);
                blockread(f,s[1],ord(s[0]));
                sprompt(process(s));
          end;
        3:begin
                blockread(f,b,1);
                blockread(f,b2,1);
                ansig(b,b2);
          end;
        4:begin
                cls;
          end;
        5:begin
                blockread(f,w,2);
                delay(w);
          end;
        6:if (inif) then begin
                nocommand:=FALSE;
                blockread(f,s[0],1);
                blockread(f,s[1],ord(s[0]));
                if (exist(process2(s))) then noneedelse:=TRUE;
          end;
        7:begin
                inif:=TRUE;
          end;
        8:begin
                if (noneedelse) then noneedelse:=FALSE else needelse:=TRUE;
          end;
        9:begin
                inif:=FALSE;
                nocommand:=TRUE;
                noneedelse:=FALSE;
                needelse:=FALSE;
          end;
       10:begin
                blockread(f,b,1);
                getsubscription(b);
                sl1('x','Setting Subscription to Level #'+cstr(b));
          end;
       11:if (inif) then begin
                nocommand:=FALSE;
                blockread(f,s[0],1);
                blockread(f,s[1],ord(s[0]));
                tempbool:=dyny;
                dyny:=TRUE;
                if (pynq(process(s))) then noneedelse:=TRUE;
                dyny:=tempbool;
          end;
       12:if (inif) then begin
                nocommand:=FALSE;
                blockread(f,s[0],1);
                blockread(f,s[1],ord(s[0]));
                tempbool:=dyny;
                dyny:=FALSE;
                if (pynq(process(s))) then noneedelse:=TRUE;
                dyny:=tempbool;
          end;
       13:begin
                sl1(':','(HALT) Finished nexecutable '+progname);
                dispose(codeindex);
                dispose(hdr);
                close(f);
                for x:=1 to 10 do begin
                        if (flist[x].fopen) then begin
                                flist[x].fopen:=FALSE;
                                {$I-} close(flist[x].fl); {$I+}
                                if (ioresult<>0) then begin end;
                        end;
                end;
                topscr;
                exit;
          end;
       14:begin
                blockread(f,s[0],1);
                blockread(f,s[1],ord(s[0]));
                ts1:=process(s);
                domenucommand(tempbool,ts1,tempstr);
{                MainMenuHandle(ts1); }
          end;
       15:begin
                blockread(f,w,2);
                currentswap:=modemr^.swapdoor;
                dodoorfunc(cstr(w),FALSE);
                currentswap:=0;
          end;
       16:begin
                if (flist[b].fopen) then flist[b].ferror:=1
                else begin
                blockread(f,b,1);
                blockread(f,s[0],1);
                blockread(f,s[1],ord(s[0]));
                blockread(f,b2,1);
                filemode:=b2;
                assign(flist[b].fl,process2(s));
                {$I-} rewrite(flist[b].fl,1); {$I+}
                flist[b].ferror:=ioresult;
                if (flist[b].ferror<>0) then flist[b].fopen:=TRUE;
                end;
          end;
       17:begin
                if (flist[b].fopen) then flist[b].ferror:=1
                else begin
                blockread(f,b,1);
                blockread(f,s[0],1);
                blockread(f,s[1],ord(s[0]));
                blockread(f,b2,1);
                filemode:=b2;
                assign(flist[b].fl,process2(s));
                {$I-} reset(flist[b].fl,1); {$I+}
                flist[b].ferror:=ioresult;
                if (flist[b].ferror=0) then begin
                        seek(flist[b].fl,filesize(flist[b].fl));
                        flist[b].fopen:=TRUE;
                end;
                end;
          end;
(*                              'FILECREATE','FILEOPEN','FILEPUT',
                               'FILECLOSE',,'FILERR','DISPLAYFILE'  *)

       18:begin
                blockread(f,b,1);
                blockread(f,s[0],1);
                blockread(f,s[1],ord(s[0]));
                fileput(b,process2(s));
          end;
       19:begin
                blockread(f,b,1);
                {$I-} close(flist[b].fl); {$I+}
                flist[b].ferror:=ioresult;
                flist[b].fopen:=FALSE;
          end;
       20:if (inif) then begin
                nocommand:=FALSE;
                blockread(f,b,1);
                if (flist[b].ferror<>0) then noneedelse:=TRUE;
          end;
       21:begin
                blockread(f,s[0],1);
                blockread(f,s[1],ord(s[0]));
                printf(process2(s));
          end;
end;
inc(x);
end;
close(f);
for x:=1 to 10 do begin
        if (flist[x].fopen) then begin
                flist[x].fopen:=FALSE;
                {$I-} close(flist[x].fl); {$I+}
                if (ioresult<>0) then begin end;
        end;
end;
dispose(codeindex);
dispose(hdr);
sl1(':','Finished nexecutable '+progname);
topscr;
end;

end.
