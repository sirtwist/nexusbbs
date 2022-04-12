{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R-,S+,V-}
unit file14;

interface

uses
  crt,dos,
  myio3,
  common;

procedure getgifspecs(fn:astr; var sig:astr; var x,y,c:word);
procedure dogifspecs(fn:astr; var abort,next:boolean);

implementation

uses file0,file11;

procedure getgifspecs(fn:astr; var sig:astr; var x,y,c:word);
var f:file;
    rec:array[1..11] of byte;
    c1,i,numread:word;
begin
  assign(f,fn);
  filemode:=64;
  {$I-} reset(f,1); {$I+}
  if (ioresult<>0) then begin
    sig:='NOTFOUND';
    exit;
  end;
  
  blockread(f,rec,11,numread);
  close(f);
  filemode:=66;

  if (numread<>11) then begin
    sig:='BADGIF';
    exit;
  end;

  sig:='';
  for i:=1 to 6 do sig:=sig+chr(rec[i]);

  x:=rec[7]+rec[8]*256;
  y:=rec[9]+rec[10]*256;
  c1:=(rec[11] and 7)+1;
  c:=1;
  for i:=1 to c1 do c:=c*2;
end;

procedure dogifspecs(fn:astr; var abort,next:boolean);
var s,sig:astr;
    x,y,c:word;
begin
  getgifspecs(fn,sig,x,y,c);
  s:='%030%'+mln(stripname(fn),12);
  if (sig='NOTFOUND') then
    s:=s+'   '+#3#7+'NOT FOUND'
  else
    s:=s+'   '+#3#5+mln(cstrl(x)+'x'+cstrl(y),10)+'   '+
         mln(cstr(c)+' colors',10)+'   '+#3#7+sig;
  sprint(s);
end;


end.
