program temp;

uses 
  crt,dos;

var
  ch : char;

begin


  repeat until keypressed;
  ch := readkey;
  writeln('ch is ', ord(ch));
  if ch = #0 then 
    ch := readkey;

  writeln('now ch is ', ord(ch));

end.

