program t;

uses crt;

type
windowrec = pnScreenBuf;


procedure savescreen(var wind:windowrec; TLX,TLY,BRX,BRY:integer);
var r,c:integer;
begin
	c:=(BRX-TLX)+1;
	r:=(BRY-TLY)+1;
	RemoveSubWn;
	nGrabScreen(wind,TLX,TLY,c,r,nscreen);
end;

procedure removewindow(wind:windowrec);
begin
	RemoveSubWn;
	nPopScreen(wind,1,1,nscreen);
	nReleaseScreen(wind);
end;

var w:windowrec;
    c:char;

begin
window(4,4,76,20);
gotoxy(10,10);
writeln('This is a test.');
savescreen(w,1,1,80,25);
clrscr;
c:=readkey;
removewindow(w);
end.
