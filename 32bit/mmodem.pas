{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R-,S+,V-}
unit mmodem;

interface

uses
  crt, dos,
  common,
  tmpcom,
  myio3;

const lastmodstring : string = '';
const lastmodact : string = '';
var
  p:array[1..2] of integer;
  ps:array[1..2] of astr;
  blankmenunow : boolean;
  mx1,mx2,my1,mc1,mb1,my2,mz1,mz2,mc2,mb2:integer;

procedure wr(i:integer; c:char);
procedure wrs(i:integer; s:astr);
procedure outmodemstring1(s:astr);
procedure outmodemstring000(s:astr; showit:boolean);
procedure outmodemstring(s:astr);
procedure dophonehangup(showit:boolean);
procedure dophoneoffhook(showit:boolean);
procedure dophoneonhook(showit:boolean);
procedure showmodemresp(s:string);
procedure showmodemact(s:string);

implementation

procedure showmodemresp(s:string);
begin
  if not(blankmenunow) then begin
 { window(1,1,80,25); }
  textcolor(mc2);
  textbackground(mb2);
  gotoxy(mx2,my2);
  write(mln(s,mz2));
  lastmodstring:=s;
  end;
end;

procedure showmodemact(s:string);
begin
  if not(blankmenunow) then begin
 { window(1,1,80,25);}
  textcolor(mc1);
  textbackground(mb1);
  gotoxy(mx1,my1);
  write(mln(s,mz1));
  lastmodact:=s;
  end;
end;

procedure wr(i:integer; c:char);
var j:integer;
begin
  tc(14);
  case i of
    1:begin
        if (p[i]>37) then begin
          for j:=1 to 37 do ps[i][j]:=ps[i][j+1];
          ps[i][0]:=chr(37); p[i]:=37;
        end;
      end;
    2:begin
        if (p[i]>14) then begin
          for j:=1 to 14 do ps[i][j]:=ps[i][j+1];
          ps[i][0]:=chr(14); p[i]:=14;
        end;
    end;
  end;
  ps[i]:=ps[i]+c; inc(p[i]);
end;

procedure wrs(i:integer; s:astr);
var j:integer;
begin
  for j:=1 to length(s) do wr(i,s[j]);
end;

procedure outmodemstring1(s:astr);
var i:integer;
begin
  for i:=1 to length(s) do begin
    com_tx(s[i]);
    delay(2);
  end;
  if (s<>'') then com_tx(^M);
end;

procedure outmodemstring000(s:astr; showit:boolean);
var i:integer;
    s2:string;
begin
  s2:='';
  for i:=1 to length(s) do
    case s[i] of
      '~':delay(500);
      '|':begin
          com_tx(^M);
          if (showit) then showmodemresp(s2);
          s2:='';
          end;
      ',':delay(1000);
      'v':term_ready(FALSE);
      '^':term_ready(TRUE);
    else
          begin
            com_tx(s[i]);
            if (showit) then begin
                wr(1,s[i]);
            end;
            s2:=s2+s[i];
            delay(2);
          end;
    end;
    if (s2<>'') and (showit) then showmodemresp(s2);
end;

procedure outmodemstring(s:astr);
begin
  outmodemstring000(s,TRUE);
end;

procedure dophonehangup(showit:boolean);
var rl:real;
    try,rcode:integer;
    c:char;
    s:string;

  procedure dely(r:real);
  var r1:real;
  begin
    r1:=timer;
    while abs(timer-r1)<r do;
  end;

begin
  if (spd<>'KB') then begin
    try:=0;
    while ((try<6) and (com_carrier) and (not keypressed)) do begin
      com_flush_rx;
      outmodemstring000(modemr^.hangup,false);
      com_lower_dtr;
      rl:=timer;
      s:='';
      while (allcaps(s)<>'NO CARRIER') and (abs(timer-rl)<2.0) do begin
        c:=cinkey;
        s:=s+c;
      end;
      com_flush_rx;
      inc(try);
    end;
    com_raise_dtr;
    if (keypressed) then c:=readkey;
  end;

end;

procedure dophoneoffhook(showit:boolean);
var rl1:real;
    c:char;
    done:boolean;
begin
   delay(300);
   com_flush_rx;
   outmodemstring000(modemr^.offhook,showit);
end;

procedure dophoneonhook(showit:boolean);
var rl1:real;
    c:char;
    done:boolean;
begin
   delay(300);
   com_flush_rx;
   outmodemstring000(modemr^.onhook,showit);
end;

end.
