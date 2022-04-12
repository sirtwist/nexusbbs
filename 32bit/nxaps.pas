{----------------------------------------------------------------------------}
{ Nexus Bulletin Board System                                                }
{                                                                            }
{ All material contained herein is:                                          }
{                                                                            }
{ (c) Copyright 1996 Epoch Development Company.  All rights reserved.        }
{                                                                            }
{ MODULE     :  NXAPS.PAS  (Archive Processing System)                       }
{ AUTHOR     :  George A. Roberts IV                                         }
{                                                                            }
{----------------------------------------------------------------------------}

{$A+,B-,D-,E-,F-,I-,L-,N-,O-,R-,S+,V-}
{$M 20000,0,60000}

Program nxAPS;
Uses Dos,
     Crt,
     myio,
     misc,
     spawno,
     CompSys;     { The compression system unit }

{$I struct.pas}

Var Path    : PathStr;                         { The path to use           }
    Dum     : String[10];                      { A Dummy                   }
    ent     : infoblock;
    af      : file of archiverrec;
    a       : archiverrec;
    systatf : file of MatrixREC;
    found   : boolean;
    CO:CompressorType;                         { The "Work" object         }
    s:string;
    IBMRec  : IBM;                             { IBM info record           }
    MACRec  : MAC;                             { MAC info record           }
    commandtype, swaptype,
    oldformat,newformat:byte;
    commentfile2,processname,extractname:string;
    fileexists:boolean;

procedure endprogram(elevel:integer);
begin
{$I-} rmdir('.\~NXARC'); {$I+}
if (ioresult<>0) then begin
end;
halt(elevel);
end;

function fit(f1,f2:string):boolean;
var tf:boolean; c:integer;
begin
  tf:=TRUE;
  for c:=1 to length(f1) do
    if (f1[c]<>f2[c]) and (f1[c]<>'?') then tf:=FALSE;
  fit:=tf;
end;

procedure helpscreen;
begin
        textcolor(7);
        textbackground(0);
        clrscr;
        writeln('nxAPS v1.00 - Archive Processing System for Nexus Bulletin Board System');
        writeln('(c) Copyright 1996-97 Epoch Development Company. All rights reserved.');
        WriteLn;
        writeln('Syntax:   nxAPS swaptype {aetcxf} archive [filename|format]');
        writeln;
        writeln('swaptype  1=Disk, 2=XMS, 3=EMS, 4=Best Method');
        writeln;
        writeln('   a  Add [filename] to archive      e  Extract [filename] from archive');
        writeln('   t  Test archive integrity         c  Comment archive with [filename]');
        writeln('   x  Convert archive to [format]    f  Check if format supported');
        writeln;
        endprogram(1);
end;

procedure getparams;
var np,np2:integer;
    sp:string;
    idx,idx2:boolean;
begin
  idx:=FALSE;
  idx2:=FALSE;
  np:=paramcount;
  If ParamCount=0 Then Begin
        helpscreen;
  End;
  if (paramcount>0) then begin
  sp:=paramstr(1);
  if (sp='') then helpscreen;
  swaptype:=value(sp);
  sp:=paramstr(2);
  if (sp='') then helpscreen;
  case upcase(sp[1]) of
        'A':commandtype:=1;
        'E':commandtype:=2;
        'T':commandtype:=3;
        'C':commandtype:=4;
        'X':commandtype:=5;
        'F':commandtype:=6;
        else helpscreen;
  end;
  sp:=paramstr(3);
  if (sp='') then helpscreen;
  processname:=allcaps(sp);
  sp:=paramstr(4);
  case commandtype of
        1,2:begin
                  extractname:=allcaps(sp);
                  if (sp='') then helpscreen;
            end;
          4:begin
                  commentfile2:=sp;
                  if (sp='') then helpscreen;
            end;
          5:begin
                  newformat:=value(sp);
                  if (sp='') then helpscreen;
            end;
  end;
  end;
end;


procedure opensystat;
var nexusdir:string;
begin
nexusdir:=getenv('NEXUS');
if (nexusdir='') then begin
        endprogram(1);
end;
if (nexusdir[length(nexusdir)]<>'\') then nexusdir:=nexusdir+'\';
start_dir:=copy(nexusdir,1,length(nexusdir)-1);
assign(systatf,nexusdir+'MATRIX.DAT');
{$I-} reset(systatf); {$I+}
if (ioresult<>0) then begin
        endprogram(1);
end;
read(systatf,systat);
close(systatf);
end;

procedure setoldcomptype;
var s:string;

begin
If DetectCompressor(processname,CO)      { Find the compressor used   }
    Then Begin
         s:=CO^.WhichType;
         case upcase(s[1]) of
                'A':begin
                        case upcase(s[3]) of
                                'C':oldformat:=1;
                                'J':oldformat:=2;
                        end;
                    end;
                'D':oldformat:=10;
                'H':oldformat:=9;
                'L':oldformat:=3;
                'M':oldformat:=11;
                'P':oldformat:=4;
                'R':oldformat:=6;
                'S':begin
                        case upcase(s[2]) of
                                'I':oldformat:=12;
                                'Q':oldformat:=7;
                        end;
                    end;
                'Z':begin
                        case upcase(s[2]) of
                                'I':oldformat:=5;
                                'O':oldformat:=8;
                        end;
                    end;
         end;
    end else begin
         if (filesize(af)>13) then begin
                seek(af,13);
                found:=FALSE;
                while not(eof(af)) and not(found) do begin
                        read(af,a);
                        if (extonly(processname)<>'') and (allcaps(extonly(processname))=allcaps(a.extension)) and
                        (a.active) then
                        begin
                                oldformat:=filepos(af)-1;
                                found:=TRUE;
                        end;
                end;
                if (found) then begin
                end;
         end;
    end;
    fileexists:=TRUE;
end;

procedure setoldcomptype2;
var s:string;

begin
seek(af,1);
found:=FALSE;
                while not(eof(af)) and not(found) do begin
                        read(af,a);
                        if (extonly(processname)<>'') and (allcaps(extonly(processname))=allcaps(a.extension)) and
                        (a.active) then
                        begin
                                oldformat:=filepos(af)-1;
                                found:=TRUE;
                        end;
                end;
                fileexists:=FALSE;
end;

function showoldformat:string;
var s:string;
begin
s:='';
if (oldformat<>0) then begin
seek(af,oldformat);
read(af,a);
s:=a.name;
end else s:='Unknown';
showoldformat:=s;
end;

function smci3(s2:string;var ok:boolean):string;
var s:string;

begin
  s:='#NEXUS#';
  if (allcaps(s2)='ARCNAME') then begin
        s:=processname;
  end else
  if (allcaps(s2)='INFILE') then begin
        s:=extractname;
  end else
  if (allcaps(s2)='COMMENT') then begin
        s:=commentfile2;
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

  while not(done) do begin  
	ps1:=pos('|',ss);
	if (ps1<>0) then begin
                ss4:=ss4+copy(ss,1,ps1-1);
                ss:=copy(ss,ps1,length(ss));
                ps1:=1;
                ss[1]:=#28;
		ps2:=pos('|',ss);
                if (ps2<>0) then begin
                        ss3:=smci3(copy(ss,ps1+1,(ps2-ps1)-1),ok);
                        if (ok) then begin
                        ss4:=ss4+ss3;
                        ss:=copy(ss,ps2+1,length(ss));
                        end else begin
                        ss4:=ss4+copy(ss3,1,length(ss3)-1);
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

procedure shelldos(cl:string; var rcode:integer);
var t:text;
    s,s2:string;
    i:integer;
    bat:boolean;
begin
  nosound;
  bat:=FALSE;
  if (pos(' ',cl)<>0) then begin
          s2:=copy(cl,1,pos(' ',cl)-1);
          if (exist(s2)) then s2:=fexpand(s2);
          cl:=copy(cl,pos(' ',cl)+1,length(cl));
  end else begin
          s2:=cl;
          if (exist(s2)) then s2:=fexpand(s2);
  end;
  if (s2='') then begin
          s2:=getenv('COMSPEC');
          cl:='';
  end else
  if (allcaps(extonly(s2))<>'EXE') and (allcaps(extonly(s2))<>'COM') then begin
    assign(t,adrv(systat.temppath)+'~NXA'+cstr(oldformat)+'.BAT');
    rewrite(t);
    writeln(t,'@ECHO OFF');
    if (extonly(s2)='') then
    writeln(t,s2+' '+cl)
    else
    writeln(t,'CALL '+s2+' '+cl);
    writeln(t,'IF ERRORLEVEL '+cstr(rcode)+' ECHO '+cstr(rcode)+' > '+adrv(systat.temppath)+'ARLV'+cstr(oldformat)+'.DAT');
    close(t);
    s2:=getenv('COMSPEC');
    cl:='/c '+adrv(systat.temppath)+'~NXA'+cstr(oldformat)+'.BAT';
    bat:=TRUE;
  end;
  If not(exist(s2)) then s2 := FSearch(s2, getenv('PATH'));

  swapvectors;
  if (swaptype>0) then begin
        case swaptype of
		1:swaptype:=swap_disk;
		2:swaptype:=swap_xms;
                3:swaptype:=swap_ems;
		4:swaptype:=swap_all;
	end;
        Init_spawno('.\~NXARC',swaptype,20,0);
        rcode:=spawn(s2,cl,0);
  end else begin
        exec(s2,cl);
        rcode:=lo(dosexitcode);
  end;
  swapvectors;
  if (bat) then begin
    assign(t,adrv(systat.temppath)+'~NXA'+cstr(oldformat)+'.BAT');
    {$I-} erase(t); {$I+}
    if (ioresult<>0) then ;
    if (exist(adrv(systat.temppath)+'ARLV'+cstr(oldformat)+'.DAT')) then begin
    assign(t,adrv(systat.temppath)+'ARLV'+cstr(oldformat)+'.DAT');
    {$I-} erase(t); {$I+}
    if (ioresult<>0) then ;
    rcode:=0;
    end else rcode:=1;
  end;
  textattr:=7;
end;

procedure arcbatch(var ok:integer;      { result                     }
                    dir:astr;           { directory takes place in   }
                    batline:astr);     { .BAT file line to execute  }
var odir:string;
    rcode:integer;
    t:text;
begin
  getdir(0,odir);
  dir:=fexpand(dir);
  bslash(FALSE,dir);
  assign(t,adrv(systat.temppath)+'~NXAPSTM.BAT');
  {$I-} rewrite(t); {$I+}
  if (ioresult<>0) then begin
        ok:=1;
        exit;
  end;
  writeln(t,chr(exdrv(dir)+64)+':');
  writeln(t,'CD '+dir);
  writeln(t,batline);
  writeln(t,'CD \');
  writeln(t,chr(exdrv(odir)+64)+':');
  writeln(t,'CD '+odir);
  close(t);

  shelldos(adrv(systat.temppath)+'~NXAPSTM.BAT',rcode);

  {$I-} erase(t); {$I+}
  if (ioresult<>0) then begin end;
  ok:=rcode;
end;

procedure commentfile;
var ok:integer;
begin
if (fileexists) then begin
  CO^.CheckProtection;
  if (CO^.IsProtected) and not(systat.addwithav) then begin
        endprogram(4);
  end;
end;
seek(af,oldformat);
read(af,a);
ok:=a.errorlevel;
arcbatch(ok,'.',processmci(a.comment));
end;

procedure addfiles;
var ok:integer;
begin
  if (fileexists) then begin
  CO^.CheckProtection;                  { Grab the info about        }
  if (CO^.IsProtected) and not(systat.addwithav) then begin
        endprogram(4);
  end;
  end;
  seek(af,oldformat);
  read(af,a);
  if (a.compress='') then exit;
  ok:=a.errorlevel;
  arcbatch(ok,'.',processmci(a.compress));
  if (ok<>a.errorlevel) then endprogram(1)
end;

procedure extractfiles;
var ok:integer;
begin
  seek(af,oldformat);
  read(af,a);
  ok:=a.errorlevel;
  if (a.decompress<>'') then begin
  arcbatch(ok,'.',processmci(a.decompress));
  if (ok<>a.errorlevel) then endprogram(1)
  end;
end;

procedure testfiles;
var ok:integer;
begin
  seek(af,oldformat);
  read(af,a);
  ok:=a.errorlevel;
  if (a.testfiles='') then endprogram(0);
  arcbatch(ok,'.',processmci(a.testfiles));
  if (ok<>a.errorlevel) then endprogram(1);
end;

procedure convertarchive;
var f:file;
    ofn,nfn,nofn,ps,ns,es:string;
    eq:boolean;
    x:integer;
    a2:archiverrec;
    ok:integer;
begin
  seek(af,oldformat);
  read(af,a);
  seek(af,newformat);
  read(af,a2);
  if (a.decompress='') or (a2.compress='') then endprogram(3);
  eq:=(oldformat=newformat);
  if (eq) and not(systat.convertsame) then endprogram(3);
  CO^.CheckProtection;                  { Grab the info about        }
  if (CO^.IsProtected) and not(systat.convertwithav) then begin
        endprogram(4);
  end;
  fsplit(processname,ps,ns,es);
  if (eq) then begin
    nofn:=ps+ns+'.#$%';
  end;
  ofn:=processname;
  extractname:='*.*';
  ok:=a.errorlevel;
  arcbatch(ok,'.',processmci(a.decompress));
  if (ok<>a.errorlevel) then endprogram(1)
  else begin
    if (eq) then begin
        assign(f,ofn);
        {$I-} rename(f,nofn); {$I+}
        if (ioresult<>0) then begin end;
    end;
    if (es[3] in ['0'..'9']) then begin
        processname:=ps+ns+'.'+a2.extension[1]+copy(es,3,2);
    end else begin
        processname:=ps+ns+'.'+a2.extension;
    end;
    ok:=a2.errorlevel;
    arcbatch(ok,'.',processmci(a2.compress));
    if (ok<>a2.errorlevel) then begin
      if (eq) then begin assign(f,nofn); rename(f,ofn); end;
      endprogram(1);
    end;
    if (not exist(sqoutsp(processname))) then begin
        endprogram(1);
    end;
    assign(f,ofn);
    {$I-} erase(f); {$I+}
    if (ioresult<>0) then begin end;
    purgedir('.');
  end;
end;

Begin
{$I-} mkdir('.\~NXARC'); {$I+}
if (ioresult<>0) then begin
        endprogram(1);
end;
directvideo:=FALSE;
processname:='';
extractname:='';
oldformat:=0;
getparams;
opensystat;
filemode:=66;
assign(af,adrv(systat.gfilepath)+'ARCHIVER.DAT');
{$I-} reset(af); {$I+}
if (ioresult<>0) then begin
        writeln('Error opening ARCHIVER.DAT');
        endprogram(1);
end;
if (exist(processname)) then setoldcomptype else setoldcomptype2;
if (commandtype=6) then begin
        if (oldformat=0) then endprogram(1) else endprogram(0);
end;
if (oldformat<>0) then begin
case commandtype of
        1:addfiles;
        2:extractfiles;
        3:testfiles;
        4:commentfile;
        5:convertarchive;
end;
end else begin
        close(af);
        endprogram(1);
end;
close(af);
endprogram(0);
End.
