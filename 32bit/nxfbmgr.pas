{----------------------------------------------------------------------------}
{ Nexus Bulletin Board System                                                }
{                                                                            }
{ All material contained herein is                                           }
{  (c) Copyright 1996 Epoch Development Company.  All rights reserved.       }
{  (c) Copyright 1994-95 Intuitive Vision Software.  All rights reserved.    }
{                                                                            }
{ MODULE     :  NXFBMGR.PAS (Main File Base Manager Program Module)          }
{ AUTHOR     :  George A. Roberts IV                                         }
{                                                                            }
{----------------------------------------------------------------------------}
{ Nexus and Nexecutable are trademarks of Epoch Development Company.         }
{----------------------------------------------------------------------------}
{$A+,B+,D-,E+,F+,G+,I+,L-,N-,O-,R+,S+,V-}
{$M 65400,0,200000}      { Memory Allocation Sizes }
program nxFBMGR;

uses dos,crt,myio,fbm1,fbm4,misc,overlay;

{$O MKMISC}
{$O MKSTRING}
{$O MISC}
{$O FBM1}
{$O FBM4}
{$O MYIO}

Const
  ovrmaxsize = 50000;

var oldwin:windowrec;
    ovrpath:string;
    oldx,oldy:integer;
    nxe:boolean;
    x:integer;
    sd,s,startupdir:string;
    systatf:file of matrixrec;

Var
  ExitSave  : Pointer;

{$F+} Procedure ErrorHandle; {$F-}

{*****************************************************************************
 * Note: If another error occurs in this procedure,                          *
 * it is NOT executed again!                                                 *
 *****************************************************************************}

Var
  T:Text;
  F,f2:File;
  S:String[80];
  VidSeg:Word;
  X,Y:Integer;
  savsl:byte;
  C:Char;
  ufo:boolean;
Begin
  ExitProc:=ExitSave;
  If (ErrorAddr<>Nil) then
  Begin
    assign(t,systat.trappath+'NXFBMGR.LOG');
    {$I-} append(t); {$I+}
    if (ioresult<>0) then
    begin
      rewrite(t);
      append(t);
      writeln(t,'NEXUS CRITICAL ERROR LOG - Screen image at time of SYSTEM ERROR.');
      writeln(t,'The "²" character shows the cursor position at time of error.');
      writeln(t,'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
    end;
    writeln(t,'CRITICAL ERROR ON '+date+' AT '+time);
    writeln(t,'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
    writeln(t,'ERROR CODE: '+cstr(exitcode));
    writeln(t);
    writeln(t,'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[Screen Image]ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
    if (mem[$0000:$0449]=7) then vidseg:=$B000 else vidseg:=$B800;
    for y:=1 to 25 do
    begin
      s:='';
      for x:=1 to 80 do
      begin
        c:=chr(mem[vidseg:(160*(y-1)+2*(x-1))]);
        if (c=#0) then c:=#32;
        if ((x=wherex) and (y=wherey)) then c:=#178;
        if ((x<>80) or ((x=80) and (c<>#32))) then s:=s+c;
      end;
      writeln(t,s);
    end;
    writeln(t,'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
    close(t);


    halt(254);
    
    {* CRITICAL ERROR ERRORLEVEL *}

  end;
end;

procedure endprogram;
begin
removewindow(oldwin);
if (oldy=25) then writeln;
gotoxy(oldx,oldy);
{$I-} chdir(startupdir); {$I+}
if (ioresult<>0) then begin end;
cursoron(TRUE);
halt;
end;

procedure helpscreen;
begin
textcolor(7);
textbackground(0);
clrscr;
writeln('nxFBMGR v',ver,fbuild,' - Filebase Manager for Nexus Bulletin Board System');
writeln('(c) Copyright 1996-2001 George A. Roberts IV. All rights reserved.');
writeln('(c) Copyright 1994-95 Internet Pro''s Network LLC. All rights reserved.');
writeln;
writeln('Syntax:');
writeln;
writeln('   NXFBMGR [Options]');
writeln;
writeln('Options:');
writeln;
writeln('   /B[base#]           Load nxFBMGR and edit [base#] file database');
writeln('   /S[order][sortby]   Sort all file bases');
writeln('                               Order : A-Ascending  D-Descending');
writeln('                               Sortby: N-Filename   D-Date');
writeln('                                       E-Extension  F-Filepoints');
writeln('                                       S-Filesize   T-Times DLed');
writeln('   /NOCD               Do not scan for active CD-ROMs');
halt;
end;

procedure getparams;
var s:string;
    x2:integer;
    sort:boolean;
begin

if (paramcount=0) then exit;
for x2:=1 to paramcount do begin
        s:=paramstr(x2);
        if (s[1]='-') or (s[1]='/') then begin
                case upcase(s[2]) of
                        '?':helpscreen;
                        'B':begin
                                cbase:=value(copy(s,3,length(s)-2));
                            end;
                        'Z':begin
                                nxe:=TRUE;
                            end;
                        'N':begin
                                nosearchcdroms:=TRUE;
                            end;
                        'S':begin
                                sortonly:=TRUE;
                                if (length(s)=4) then sorttype:=allcaps(copy(s,3,2));
                            end;
                end;
       end;
end;
end;

procedure bscreen;
var  wfcFile : file;
begin
   window(1,1,80,25);
   cursoron(FALSE);
   assign(wfcFile,bslash(true,pathonly(paramstr(0)))+'NXFBMGR.BIN');
   {$I-} reset(wfcFile,1); {$I+}
   if (ioresult<>0) then begin
        displaybox('Error reading '+bslash(true,pathonly(paramstr(0)))+'NXFBMGR.BIN',2000);
        halt;
   end;
   if (filesize(wfcfile)<4000) then begin
        displaybox(bslash(true,pathonly(paramstr(0)))+'NXFBMGR.BIN is an invalid size!',2000);
        halt;
   end;
   blockRead(wfcFile,mem[$B800:0],4000);
   close(wfcFile);
end;

begin
  exitsave:=exitproc;
  exitproc:=@errorhandle;
ver:='0.99';
ovrfilemode:=$42;
sd:=paramstr(0);
sd:=copy(sd,1,length(sd)-12);
ovrinit(sd+'\NXFBMGR.OVR');
ovrpath:=sd+'\NXFBMGR.OVR';
if (ovrresult<>ovrok) then
begin
    write('Overlay Error.  Please inform the Nexus Development Team immediately!'); halt(1);
end;
ovrinitems;
ovrsetbuf(maxavail-ovrmaxsize); ovrsetretry(maxavail-(ovrmaxsize div 2));
getdir(0,startupdir);
if (startupdir[length(startupdir)]='\') then startupdir:=copy(startupdir,
        1,length(startupdir)-1);
nxe:=FALSE;
nexusdir:=getenv('NEXUS');
if (nexusdir[length(nexusdir)]='\') then nexusdir:=copy(nexusdir,1,length(nexusdir)-1);
if (nexusdir='') then begin
        writeln('You must have your Nexus environment variable set in order to run nxFBMGR.');
        halt;
end;
start_dir:=nexusdir;
getparams;
if not(nxe) then begin
    textcolor(7);
    textbackground(0);
    writeln('nxFBMGR v',ver,' - File Base Manager for Nexus Bulletin Board System.');
    writeln('(c) Copyright 1996-2001 George A. Roberts IV. All rights reserved.');
end;
savescreen(oldwin,1,1,80,25);
oldx:=wherex;
oldy:=wherey;
if not(nxe) then begin
    textcolor(7);
    textbackground(0);
    clrscr;
    bscreen;
end;
assign(systatf,nexusdir+'\MATRIX.DAT');
{$I-} reset(systatf); {$I+}
if (ioresult<>0) then begin
        displaybox('Error reading MATRIX.DAT information.',3000);
        endprogram;
end;
read(systatf,systat);
close(systatf);
assign(systemf,adrv(systat.gfilepath)+'\SYSTEM.DAT');
{$I-} reset(systemf); {$I+}
if (ioresult<>0) then begin
        displaybox('Error reading SYSTEM.DAT information.',3000);
        endprogram;
end;
read(systemf,syst);
close(systemf);
mainmenu;
endprogram;
end.

