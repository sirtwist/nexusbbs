program nxWAIT;
  
uses dos,crt,misc,myio;

{$I NEXUS.INC}

var f:file;
    v,b:string;
    cnode:integer;
    onlinef:file of onlinerec;
    online:onlinerec;
    systatf:file of Matrixrec;
    systat:Matrixrec;
    gName:string[36]; {NAME}
    Where:string[40]; {WHERE}
    Active:string[20]; {ACTIVITY}
    NexusDir:string;
    w:windowrec;
    s2:string;
    clear:boolean;
    x:integer;

procedure endprogram;
begin
halt;
end;

procedure title;
begin
drawwindow3(w,1,1,78,4,1,3,0,11,'');
textcolor(15);
gotoxy(2,2);
write('nxWAIT v',v,' - Node Status Creator for Nexus Bulletin Board System');
gotoxy(2,3);
write('(c) Copyright 1996-97 Epoch Development Company. All rights reserved.');
textcolor(7);
textbackground(0);
gotoxy(1,7);
end;


procedure help;
begin
textcolor(7);
textbackground(0);
clrscr;
writeln('nxWAIT v',v,' - Node Status Creator for Nexus Bulletin Board System');
writeln('(c) Copyright 1996-97 Epoch Development Company. All rights reserved.');
writeln;
writeln('Syntax:    nxWAIT [-C(node)] | [-N(node) (configfile)]');
writeln;
writeln('           -C(node)               = Clear this node');
writeln('           -N(node) (configfile)  = Activate this node with (configfile) for');
writeln('                                    information');
writeln;
writeln('Examples:   nxWAIT -C1             ; Clears node 1 status');
writeln('            nxWAIT -N1 NODE1.CFG   ; Activates node 1 with NODE1.CFG used');
writeln('                                   ; for the information');
writeln;
halt;
end;

procedure getcommands;
var s,s1:string;
    t:text;
    x2:integer;
    done:boolean;

begin
done:=false;
clear:=FALSE;
cnode:=0;
if (paramcount=0) then help;
x2:=1;
while (x2<=paramcount) do begin
s:=paramstr(x2);
if (length(s)>1) then
case upcase(s[1]) of
        '-','/':begin
                case upcase(s[2]) of
                        '?','H':help;
                        'N':cnode:=value(copy(s,3,length(s)-2));
                        'C':begin
                                clear:=TRUE;
                                cnode:=value(copy(s,3,length(s)-2));
                            end;
                end;
                end;
            '?':help;
        else begin
                s2:=allcaps(s);
        end;
end;
inc(x2);
end;
if (cnode=0) then begin
title;
writeln('Node number not specified.');
end;
if not(clear) then begin
assign(t,s2);
{$I-} reset(t); {$I+}
if ioresult<>0 then begin
        title;
        writeln('Error Opening ',allcaps(s2),'.');
        endprogram;
end;
while not(eof(t)) and not(done) do begin
readln(t,s);
gname:=copy(s,1,36);
if (pos(';',gname)<>0) then
gname:=copy(s,1,pos(';',gname)-1);
readln(t,s);
where:=copy(s,1,40);
if (pos(';',where)<>0) then
where:=copy(s,1,pos(';',where)-1);
readln(t,s);
active:=copy(s,1,20);
if (pos(';',active)<>0) then
active:=copy(s,1,pos(';',active)-1);
done:=TRUE;
end;
close(t);
end;
end;

procedure openmatrix;
begin
NexusDir:=GetEnv('NEXUS');
if NexusDir[length(nexusDir)]<>'\' then NexusDir:=NexusDir+'\';
filemode:=66;
assign(systatf,NexusDir+'MATRIX.DAT');
{$I-} reset(systatf); {$I+}
if ioresult<>0 then begin
        writeln('Error Opening ',allcaps(NexusDir+'MATRIX.DAT'),'.');
        endprogram;
end;
read(systatf,systat);
close(systatf);
assign(f,systat.semaphorepath+'WAITING.'+cstrnfile(cnode));
assign(onlinef,systat.gfilepath+'USER'+cstrn(cnode)+'.DAT');
end;


begin
v:='1.06';
b:='.01';
GetCommands;
title;
OpenMatrix;
if exist(systat.semaphorepath+'INUSE.'+cstrnfile(cnode)) then begin
writeln('Node ',cstr(cnode),' is currently in use.');
endprogram;
end;
if (clear) then begin
        write('Clearing Node #'+cstr(cnode)+'... ');
        {$I-} erase(onlinef); {$I+}
        if (ioresult<>0) then begin writeln('ERROR!'); end else
        writeln('Finished!');
end else begin
write('Setting status for Node #'+cstr(cnode)+' (using '+s2+')... ');
rewrite(f);
close(f);
with online do begin
online.name:=gname;
real:=gname;
nickname:='';
business:=where;
number:=0;
activity:=active;
available:=false;
baud:=0;
lockbaud:=0;
comport:=0;
emulation:=0;
end;
rewrite(onlinef);
write(onlinef,online);
close(onlinef);
writeln('Finished!');
end;
endprogram;
end.

