{$A+,B+,D-,E+,F+,G-,I+,L-,N-,O-,R+,S+,V-}
{$M 65400,50000,200000}      { Memory Allocation Sizes }
program nxWAVE;

uses dos,crt,nxwave1,myio,nxwave2,ivmodem;

var startdir:string;
    f1:file;
    ox,oy:integer;

procedure title;
begin
clrscr;
drawwindow2(1,1,78,4,1,3,0,11,'');
textcolor(15);
textbackground(3);
gotoxy(2,2);
write('nxWAVE v'+version+' - Blue Wave <tm> Processor for Nexus Bulletin Board System');
gotoxy(2,3);
writeln('(c) Copyright 1996-2001 George A. Roberts IV. All rights reserved.');
textcolor(7);
textbackground(0);
gotoxy(1,6);
end;

procedure helpscreen;
begin
textcolor(7);
textbackground(0);
clrscr;
writeln('nxWAVE v'+version+' - Blue Wave <tm> Processor for Nexus Bulletin Board System');
writeln('(c) Copyright 1996-2001 George A. Roberts IV. All rights reserved.');
writeln;
writeln('Syntax :  NXWAVE [Command] [Node Information] [Other Info]');
writeln;
writeln('Options:');
writeln;
writeln('Command  :  D           = Auto-Download');
writeln('            U           = Auto-Upload');
writeln('            M           = Menu (normal execution)');
writeln;
writeln('Node Info:  -N[Node]    = Node number to process mail for');
writeln('            -K          = Local Only no Online Interface (via UserID #)');
writeln('                          (must specify UserID Number {see below})');
writeln('            -NOEMPTY    = Do not bundle empty mail packets');
writeln;
writeln('Other    :  -#[number]  = Specify UserID Number (for Local Only)');
writeln;
end;

procedure getparams;
var s:string;
    x:integer;
    uidf:file of useridrec;
    uid:useridrec;
    found:boolean;
begin
        cnode:=0;
        if (paramcount=0) then begin
                helpscreen;
                halt;
        end;
        x:=1;
        while (x<=paramcount) do begin
                s:=paramstr(x);
                case upcase(s[1]) of
                        '-','/':begin
                                case upcase(s[2]) of
                                '?':begin
                                        helpscreen;
                                        halt;
                                    end;
                                'N':begin
                                        if (allcaps(copy(s,2,length(s)))='NOEMPTY') then begin
                                                nobundleexit:=TRUE;
                                        end else
                                        cnode:=value(copy(s,3,length(s)-2));
                                    end;
                                '#':begin
                                        found:=FALSE;
                                        assign(uidf,adrv(systat.gfilepath)+'USERID.IDX');
                                        {$I-} reset(uidf); {$I+}
                                        if (ioresult<>0) then begin
                                                title;
                                                writeln('ERROR: Cannot open '+adrv(systat.gfilepath)+'USERID.IDX!');
                                                halt;
                                        end;
                                        usernum:=0;
                                        while not(eof(uidf)) and not(found) do begin
                                                read(uidf,uid);
                                                if ((uid.userid=value(copy(s,3,length(s)-2))) and
                                                   (uid.number<>-1)) then begin
                                                        found:=TRUE;
                                                        usernum:=uid.number;
                                                end;
                                        end;
                                        close(uidf);
                                    end;
                                'K':begin
                                        localonly:=TRUE;
                                        nouserfile:=TRUE;
                                    end;
                                end;
                                end;
                        'U':begin
                        uploading:=TRUE;
                        end;
                        'D':begin
                        uploading:=FALSE;
                        end;
                        'M':begin
                        uploading:=FALSE;
                        menu:=TRUE;
                        end;
                        '?':begin
                                helpscreen;
                                halt;
                            end;
                end;
        inc(x);
        end;
        if (cnode=0) then begin
                title;
                writeln('Node Number not specified.');
                halt;
        end;
end;

procedure opensystat;
begin
filemode:=66;
assign(systatf,nexusdir+'MATRIX.DAT');
{$I-} reset(systatf); {$I+}
if (ioresult<>0) then begin
                title;
                writeln('Error opening '+nexusdir+'MATRIX.DAT');
                halt;
end;
read(systatf,systat);
close(systatf);
assign(systf,adrv(systat.gfilepath)+'SYSTEM.DAT');
{$I-} reset(systf); {$I+}
if (ioresult<>0) then begin
        title;
        writeln('Error opening '+adrv(systat.gfilepath)+'SYSTEM.DAT');
        halt;
end;
read(systf,syst);
close(systf);
end;


begin
getdir(0,startdir);
nexusdir:=getenv('NEXUS');
if (nexusdir='') then begin
        writeln('The NEXUS environment variable MUST be set in order for nxWAVE to');
        writeln('operate correctly.  Please set your NEXUS environment variable.');
        halt;
end;
if (nexusdir[length(nexusdir)]<>'\') then nexusdir:=nexusdir+'\';
start_dir:=copy(nexusdir,1,length(nexusdir)-1);
opensystat;
getparams;
title;
getNXW;
getuser;
languagestartup;
maintenance;
getdatetime(timeon);
updatestatus;
clrscr;
if (menu) then begin
domainmenu;
end else begin
if not(uploading) then begin
        BuildScanTable;
        makebundlelist;
        if (abort) or ((totalnew2=0) and (nobundleexit)) then begin
                purgedir(bslash(FALSE,newtemppath));
        end else begin
                packmail;
                if (totalnew<>0) then begin
                        ivwrite(gstring(1959));
                        updatelastread;
                        ivwriteln(gstring(1960));
                end;
                saveuser;
        end;
end else begin
unpackmail;
processUPL;
end;
end;
if (echomail) then begin
assign(f1,adrv(systat.semaphorepath)+'SCANMAIL.'+cstrnfile(cnode));
rewrite(f1);
close(f1);
end;
stopmodem;
{$I-} chdir(startdir); {$I+}
if (ioresult<>0) then begin end;
ox:=wherex;
oy:=wherey;
window(1,1,80,25);
textcolor(7);
textbackground(0);
gotoxy(1,25);
clreol;
gotoxy(ox,oy);
endprogram;
end.
