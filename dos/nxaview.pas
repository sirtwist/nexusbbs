{----------------------------------------------------------------------------}
{ Nexus Bulletin Board Software                                              }
{                                                                            }
{ All material contained herein is:                                          }
{                                                                            }
{ (c) Copyright 1996 Epoch Development Company. All rights reserved.         }
{                                                                            }
{ MODULE     :  NXAVIEW.PAS  (Archive Viewing)                               }
{ AUTHOR     :  George A. Roberts IV                                         }
{                                                                            }
{----------------------------------------------------------------------------}

{$A+,B-,D-,E-,F-,I-,L-,N-,O-,R-,S+,V-}
{$M 10000,0,60000}

Program nxAVIEW;
Uses Dos,
     Crt,
     myio,
     misc,
     spawno,
     CompSys;     { The compression system unit }

{$I struct.pas}
{$I NEXUS.INC}

const swaptype:byte=4;
Var CO      : CompressorType;                  { The "Work" object         }
    Search  : SearchRec;                       { For handeling Filespecs.  }
    Path    : PathStr;                         { The path to use           }
    Dum     : String[10];                      { A Dummy                   }
    ent     : infoblock;
    nocolor : boolean;
    IBMRec  : IBM;                             { IBM info record           }
    MACRec  : MAC;                             { MAC info record           }
    outf: text;
    processname,outputname:string;
    af:file of archiverrec;
    a:archiverrec;
    systatf:file of matrixrec;
    systat:matrixrec;
    oldformat:byte;

function fit(f1,f2:string):boolean;
var tf:boolean; c:integer;
begin
  tf:=TRUE;
  for c:=1 to length(f1) do
    if (f1[c]<>f2[c]) and (f1[c]<>'?') then tf:=FALSE;
  fit:=tf;
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
        writeln('nxAVIEW v1.00 - Archive Contents Viewer for Nexus Bulletin Board System');
        writeln('(c) Copyright 1996-97 Epoch Development Company. All rights reserved.');
        WriteLn;
        writeln('Syntax:   nxAVIEW filename [outputfile]');
        writeln;
        writeln('       filename =      filename to view');
        writeln('       output   =      if this parameter is specified, nxAVIEW');
        writeln('                       will NOT parse color codes, and will place');
        writeln('                       the unparsed output in the specified filename');
        Halt;
  End;
  if (paramcount>0) then begin
  np2:=1;
  while (np2<=np) do begin
        sp:=paramstr(np2);
        if (sp<>'') then
                if (processname='') then begin
                processname:=fexpand(sp);
                end else begin
                outputname:=fexpand(sp);
                end;
        inc(np2);
  end;
  end;
end;

procedure newwrite(s:string);
begin
if (nocolor) then begin
        write(outf,s);
end else begin
        cwrite(s);
end;
end;

procedure opensystat;
var nexusdir:string;
begin
nexusdir:=getenv('NEXUS');
if (nexusdir='') then begin
        halt;
end;
if (nexusdir[length(nexusdir)]<>'\') then nexusdir:=nexusdir+'\';
start_dir:=copy(nexusdir,1,length(nexusdir)-1);
assign(systatf,nexusdir+'MATRIX.DAT');
{$I-} reset(systatf); {$I+}
if (ioresult<>0) then begin
        halt;
end;
read(systatf,systat);
close(systatf);
end;

procedure setoldcomptype;
var s:string;
    found:boolean;

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
         end;
    end;
end;

procedure internalviewer;
begin
         CO^.CheckProtection;                  { Grab the info about        }
                                               { Security, version etc      }
         newwrite(CO^.WriteHeader(1));           { Write the header for the   }
         newwrite(CO^.WriteHeader(2));           { Write the header for the   }
         newwrite(CO^.WriteHeader(3));           { Write the header for the   }
         newwrite(CO^.WriteHeader(4));           { Write the header for the   }
         newwrite(#13#10);
         newwrite(CO^.WriteHeader(5));           { Write the header for the   }
         newwrite(CO^.WriteHeader(6));           { Write the header for the   }
                                               { found platform.            }
         CO^.FindFirstEntry;                   { Find the first file inside }
         While Not CO^.LastEntry Do Begin
          Case PlatformID(CO^.WhichPlatform) Of
                ID_IBM, ID_MULTI : CO^.ReturnEntry(IBMRec);
                ID_MAC : CO^.ReturnEntry(MACRec);
          End; {Mac}
          newwrite(CO^.PrintEntry+#13#10);       { Show the entry             }
          CO^.FindNextEntry;                   { Find the next entry        }
          End;
end;

function smci3(s2:string;var ok:boolean):string;
var s:string;

begin
  s:='#NEXUS#';
  if (allcaps(s2)='ARCNAME') then begin
        s:=processname;
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
        Init_spawno('.',swaptype,20,0);
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
begin
  getdir(0,odir);
  dir:=fexpand(dir);
  bslash(FALSE,dir);
  {$I-} chdir(chr(exdrv(dir)+64)+':'); {$I+}
  if (ioresult<>0) then exit;
  {$I-} chdir(dir); {$I+}
  if (ioresult<>0) then exit;

  shelldos(batline,rcode);

  {$I-} chdir('\'); {$I+}
  if (ioresult<>0) then begin end;
  {$I-} chdir(chr(exdrv(odir)+64)+':'); {$I+}
  if (ioresult<>0) then begin end;
  {$I-} chdir(odir); {$I+}
  if (ioresult<>0) then begin end;
  
  ok:=rcode;
end;

procedure externalviewer;
var ok:integer;
begin
seek(af,oldformat);
read(af,a);
ok:=a.errorlevel;
arcbatch(ok,'.',processmci(a.listfiles));
end;


Begin
nocolor:=FALSE;
directvideo:=FALSE;
processname:='';
outputname:='';
getparams;
opensystat;
oldformat:=0;
assign(af,adrv(systat.gfilepath)+'ARCHIVER.DAT');
{$I-} reset(af); {$I+}
if (ioresult<>0) then begin
       newwrite('%120%Error opening ARCHIVER.DAT!');
       halt;
end;
If (processname='') or not(exist(processname)) Then Begin
if (nocolor) then halt;
        writeln('nxAVIEW v1.00 - Archive Contents Viewer for Nexus Bulletin Board System');
        writeln('(c) Copyright 1996-97 Epoch Development Company. All rights reserved.');
        WriteLn;
        writeln('Syntax:   nxAVIEW [/c] filename');
        writeln;
        writeln('       /c       =      do not parse color codes');
        writeln('       filename =      filename to view');
        Halt;
End;
if (outputname='') then nocolor:=FALSE else nocolor:=TRUE;
if (nocolor) then begin
assign(outf,outputname);
rewrite(outf);
end;
setoldcomptype;
if (oldformat<>0) then begin
        seek(af,oldformat);
        read(af,a);
        if ((a.listfiles='') and (oldformat<13)) then internalviewer else externalviewer;
end else begin
                        newwrite('%150%'+fileonly(processname)+'%120%: Unknown archive format.'+#13#10);
                        newwrite(#13#10);
end;
close(af);
if (nocolor) then close(outf);
End.
