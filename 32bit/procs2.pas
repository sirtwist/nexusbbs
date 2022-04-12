{$A+,B+,D-,E+,F+,G+,I+,L-,N-,O+,R+,S+,V-}
unit procs2;

interface

uses dos,crt,misc,spawno,myio;

procedure checkkey(var c:char);

implementation


var x4:integer;

procedure runspec(b:byte);
var  wr:windowrec;
     s:string;
     odir:string;
     x,y,x1,y1,x2,y2:integer;
     newswaptype:byte;
     goahead:boolean;
begin
     x:=wherex;
     y:=wherey;
     x1:=Lo(windmin)+1;
     y1:=Hi(windmin)+1;
     x2:=lo(windmax)+1;
     y2:=hi(windmax)+1;
     goahead:=TRUE;

     getdir(0,odir);
     savescreen(wr,1,1,80,25);
     window(1,1,80,25);
     textcolor(7);
     textbackground(0);
     case b of
           11:begin
                s:='';
                clrscr;
                writeln('nxFBMGR v',ver,' (c) 1996-97 Epoch Development Company. All rights reserved.');
                writeln('              (c) 1994-95 Intuitive Vision Computer Services.');
                writeln;
                writeln('Type "EXIT" to return to nxFBMGR.');
                writeln;
              end;
     end;

     cursoron(TRUE);
     newswaptype:=swap_all;
     if (goahead) then begin
        Init_spawno(nexusdir,newswaptype,20,0);
        if (spawn(getenv('COMSPEC'),s,0)=-1) then begin
                displaybox('Error spawning external program!',2000);
        end;
     end;
     removewindow(wr);
     window(x1,y1,x2,y2);
     gotoxy(x,y);
     cursoron(FALSE);
  {$I-} chdir(chr(exdrv(odir)+64)+':'); {$I+}
  if (ioresult<>0) then begin end;
  {$I-} chdir(odir); {$I+}
  if (ioresult<>0) then begin end;

end;

procedure checkkey(var c:char);
var b:byte;
begin
b:=ord(c);
if (b=36) then begin
        b:=11;
        runspec(b);
        c:=#0;
end;
end;

begin
end.
