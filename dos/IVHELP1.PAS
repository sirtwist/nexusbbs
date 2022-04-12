{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R-,S+,V-}
unit ivHelp1;

interface

uses dos,crt,ivhelp2,misc,myio;

procedure showhelp(nexusdir,helpname:string; topic:integer);

implementation

procedure showhelp(nexusdir,helpname:string; topic:integer);
var x,y,x1,y1,x2,y2:integer;
begin
     helppath:=adrv(systat.gfilepath);
     x:=wherex;
     y:=wherey;
     x1:=Lo(windmin)+1;
     y1:=Hi(windmin)+1;
     x2:=lo(windmax)+1;
     y2:=hi(windmax)+1;
     helpname:=allcaps(helpname);
     ivhelp2.showhelp(helpname,topic,1,1,79,24,3,0,8,FALSE);
     cursoron(FALSE);
     window(x1,y1,x2,y2);
     gotoxy(x,y);
end;

end.
