{$A+,B+,D-,E+,F+,G+,I+,L-,N-,O-,R+,S+,V-}
{$M 60000,0,60000}      { Memory Allocation Sizes }
program omssetup;

uses dos,crt,myio,omsset2;

var oldwin:windowrec;
    oldy:integer;
    nexusdir:string;

begin
oldy:=wherey;
savescreen(oldwin,1,1,80,25);
nexusdir:=getenv('NEXUS');
if (nexusdir='') then begin
        writeln('You must have your NEXUS environment variable set in order for');
        writeln('OMSSetup to run.');
        writeln;
        halt;
end;
if (nexusdir[length(nexusdir)]<>'\') then nexusdir:=nexusdir+'\';
filemode:=66;
assign(systatf,nexusdir+'MATRIX.DAT');
{$I-} reset(systatf); {$I+}
if (ioresult<>0) then begin
        writeln('Error opening MATRIX.DAT');
        halt;
end;
read(systatf,systat);
close(systatf);
cursoron(FALSE);
nxwave;
cursoron(TRUE);
removewindow(oldwin);
gotoxy(1,oldy);
textcolor(7);
textbackground(0);
if (oldy=25) then writeln;
end.
