program NXEview;

uses dos,crt,mkstring,misc;

{$I NXERUN.INC}

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
        END;


var f:file;
    h:header;
    s:string[4];
    exefilename:string;

procedure title;
begin
textcolor(7);
textbackground(0);
clrscr;
writeln('nxeVIEW v1.05 - Nexecutable Information Viewer for Nexus Bulletin Board System');
writeln('(c) Copyright 1996-2000 George A. Roberts IV. All rights reserved.');
writeln;
end;

procedure helpscreen;
begin
writeln('Syntax:   NXEVIEW [nexecutable]');
writeln;
writeln('nxeVIEW will assume the extention of .EXE if none is given.');
writeln;
halt;
end;

procedure getparams;
var s:string;
    x:integer;
    found:boolean;
begin
        if (paramcount=0) then begin
                helpscreen;
        end;
        x:=1;
        while (x<=paramcount) do begin
                s:=paramstr(x);
                case upcase(s[1]) of
                        '-','/':begin
                                case upcase(s[2]) of
                                '?':helpscreen;
                                end;
                                end;
                            '?':begin
                                helpscreen;
                                end;
                        else begin
                                if (pos('.',s)=0) then s:=s+'.EXE';
                                exefilename:=fexpand(allcaps(s));
                        end;
                end;
        inc(x);
        end;
end;

begin
title;
getparams;
if (exefilename='') then helpscreen;
assign(f,exefilename);
{$I-} reset(f,1); {$I+}
if (ioresult<>0) then begin
        writeln('Error opening file '+exefilename);
        halt;
end;
if (filesize(f)<sizeof(nxeExeHdr)) then begin
        writeln('This is not a valid Nexecutable.');
        halt;
end;
seek(f,sizeof(nxeExeHdr));
blockread(f,s[1],3);
s[0]:=#3;
if (s<>'NXE') then begin
        writeln('This is not a valid NXE file.');
        halt;
end;
seek(f,sizeof(nxeExeHdr));
blockread(f,h,sizeof(h));
close(f);
writeln('Nexecutable  : '+mln(exefilename,40)+' Format revision: '+cstr(h.revision)+'.00');
writeln;
if (h.createdby<>'') then begin
writeln('Created by   : '+h.createdby);
end else begin
writeln('Created by   : Anonymous');
end;
writeln('Created on   : '+h.createdon);
if (h.copyright<>'') then begin
writeln('Copyright    : '+wwrap(h.copyright,60));
if (extrastring<>'') then begin
        writeln('               '+extrastring);
end;
end else begin
writeln('Copyright    : No copyright specified.');
end;
writeln;
if (h.info1<>'') or (h.info2<>'') then begin
writeln('Author''s included information :');
writeln;
if (h.info1<>'') then writeln(h.info1);
if (h.info2<>'') then writeln(h.info2);
writeln;
end;
end.
