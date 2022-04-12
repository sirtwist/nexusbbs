Unit StrMisc;
Interface
Uses Asmmisc,Dos;
Const
  JustChar: char = ' '; { Character to do justification & centering with }

Function AddBackSlash(st: PathStr): PathStr;
Function Center(St: String; maxplace: byte): String;
Function CommaStr(Num: Longint): String;
Function Dup(ch: char; times: byte): String;
Function HexToInt(HexStr: String) : Longint;
Function InString(st: String; ch: char; times: byte): boolean;
Function IntToHex(Num: longint; digits: byte): String;
Function IntToStr(Num: longint): String;
Function LJust(St: String; Maxplace: Byte): String;
Function LTrim(St: String): String;
Function LZero(Num: Longint; Zeros: Byte): String;
Function LastPos(Ch: char; St: string): byte;
Function Letter(ch: char): boolean;
Function MetricStr(Num: Longint): String;
Function Proper(St: String): String;
Function RemoveBackSlash(st: PathStr): PathStr;
Function RJust(St: String; Maxplace: Byte): String;
Function RTrim(St: String): String;
Function StrToInt(St: String): longint;
Function WordWrap(var st: string; place: byte): string;
Function ToUnixDate(fdate: LongInt): String;
Function FromUnixDate(s: String): Longint;
Function CarretProcess(s: string): String;
Procedure ReverseStr(var str: string);
Procedure GregorianToJulian(Year, Month, Day : word; Var Julian : LongInt);
Procedure JulianToGregorian(Julian: LongInt; Var Year,Month,Day: Word);

Const { Used for conversions of dates }
  S1970 = 2440588;
  D0    =    1461;
  D1    =  146097;
  D2    = 1721119;

Implementation
Const
  hexid: array[0..$F] of char = '0123456789ABCDEF'; { For dec to hex }

Function CarretProcess(s: String): String;
var return: string;
begin
  return := '';
  while s <> '' do begin
    case s[1] of
      '^': begin
        s[2] := upcase(s[2]);
        return := return+char(byte(s[2])-byte('A')+1);
        delete(s,1,2);
      End;
      else begin
        return := return+s[1];
        delete(s,1,1);
      End;
    End;
  End;
  CarretProcess := return;
End;

Function IntToStr(Num: longint): String;
{ Integer value to string }
Var st: string;
Begin
  Str(Num,St);
  IntToStr := st;
End;

Function StrToInt(St: String): longint;
{ String to integer value }
Var num: longint; code: integer;
Begin
  Val(St,num,code);
  StrToInt := num;
End;

Function HexToInt(HexStr: String): Longint;
{ Hexadecimal to integer value }
Var
  I,HexNibble: word;
  Temp: Longint;
  Code: integer;
Begin
  Temp := 0;
  hexstr := upcasestr(hexstr);

  {
    Remove all of the garbage characters, ie $3F8, or 3F8h
    MUST be done in reverse order, as not to mess up the indexes in the
    string with the old ones!
  }
  for i := length(hexstr) downto 1 do
    if not (HexStr[i] in ['0'..'9','A'..'F']) then delete(hexstr,i,1);

  {
    Most significant on left, right? So do it from the right where it's
    accending in order to save headaches
  }
  For I := Length(HexStr) downto 1 do Begin
    If HexStr[I] in ['0'..'9'] then hexnibble := Byte(HexStr[i]) - byte('0')
    else hexnibble := Byte(HexStr[i]) - byte('A')+10;

    Inc(Temp,longint(HexNibble) * (1 shl (4*(longint(Length(HexStr)) - I))));
  End;
  HexToInt := Temp;
End;

Function IntToHex(num: longint; digits: byte): String;
var
  s: String;
  c: byte;
  n: array[1..sizeof(longint)] of byte absolute num;
begin
  s := '';
  for c := 4 downto 1 do s := s + hexid[n[c] shr 4]+hexid[n[c] and $F];
  s := copy(s,8-digits+1,digits);
  while length(s) < digits do s := hexid[0]+s;
  IntToHex := s;
End;

Function LZero(Num: longint; Zeros: Byte): String;
{ Justifies the num into places, padding with zeros }
Var st: String;
Begin
  Str(Num,St);
  while Length(st) < Zeros do St := '0' + St;
  LZero := St;
End;

Function LJust(St: String; Maxplace: Byte): String;
{ Appends spaces until justified to maxplace }
Var loop: byte;
Begin
  For loop := length(st) to maxplace do st := st+justchar;
  Ljust := copy(st,1,maxplace);
End;

Function RJust(St: String; Maxplace: Byte): String;
{ Appends to begining spaces until justified to maxplace }
Var loop: byte;
Begin
  For loop := length(st) to maxplace do st := justchar+st;
  Rjust := copy(st,1,maxplace);
End;

Function InString(st: string; ch: char; times: byte): boolean;
{
  If "ch" is in the string "st" "times" times then this function will
  return true, good for checking to insure a date field (MM/DD/YYYY)
  contains the required two /'s and not more or less
}
Var place: byte;
Begin
  repeat
    dec(times);
    place := pos(ch,st);
    if place <> 0 then delete(st,place,1);
  until (place = 0) or (times = 0);

  if place = 0 then instring := false
  else begin
    instring := pos(ch,st) = 0;
  end;
end;

Function Dup(ch: char; times: byte): String;
{ Dups Ch "times" and returns, good for things like: "---------------" }
Var temp: String;
begin
  fillchar(temp,sizeof(temp),ch);
  temp[0] := char(times);
  dup := temp;
End;

Function LastPos(Ch: char; St: string): byte;
{ Just like Pos, except in reverse }
Var place: byte;
Begin
  Place := succ(Length(St));
  Repeat
    Dec(Place);
  Until (Place = 0) or (St[place] = Ch);
  LastPos := Place;
End;

Function WordWrap(var st: string; place: byte): string;
{
  Take the string (st) and return up to desired "place" of it, and move
  back to space, and finally delete what was in the string. PHEW!
}
Var
  TruncAt: byte;
begin
  if place <= length(st) then begin
    TruncAt := lastpos(' ', copy(st,1,place));
    If TruncAt = 0 then truncat := place;
  End
  Else truncat := length(st);
  WordWrap := copy(st,1,truncat);
  Delete(st,1,truncat);
End;

Function Letter(ch: char): boolean;
{ Is ch a valid letter? }
begin
  letter := upcase(ch) in ['A'..'Z'];
end;

Function Center(St: String; maxplace: byte): String;
{ Center the string to fit inbetween maxplace }
var temp: string; num: byte;
Begin
  num := (maxplace div 2)-(length(st) div 2);
  temp := dup(justchar,num);
  temp := temp+st;
  temp := temp+dup(justchar,maxplace-num-length(st));
  center := temp;
End;

Function Proper(St: String): String;
Var loop: byte;
begin
  st := locasestr(st);
  st[1] := upcase(st[1]);
  for loop := 1 to length(st) do if (st[loop] = ' ') then
    st[loop+1] := upcase(st[loop+1]);
  Proper := st;
end;

Function RTrim(St: String): String;
{ Trim all justification characters (spaces) on the right side }
Begin
  while (st[0] <> #0) and (st[length(st)] = justchar) do dec(st[0]);
  Rtrim := st;
End;

Function LTrim(St: String): String;
{ Trim all the justification characters (spaces) on the left side }
Begin
  while (st[0] <> #0) and (st[1] = justchar) do delete(st,1,1);
  Ltrim := st;
end;

Procedure ReverseStr(var str: string);
{ Reverses str into rts ;) }
Var
  temp: string;
  loop: byte;
Begin
  temp[0] := str[0];
  for loop := 1 to length(str) do temp[length(str)-loop+1] := str[loop];
  str := temp;
End;

Function CommaStr(Num: Longint): String;
{ To "comma" a string, using the obsolete imperial standard. }
Var
  loop: byte;
  st: string;
  times: shortint;
Begin
  str(num,st);
  reversestr(st);
  times := length(st) div 3;
  if length(st) mod 3 = 0 then dec(times);
  for loop := 1 to times do insert(',',st,loop*3+loop);
  reversestr(st);
  commastr := st;
End;

Function MetricStr(Num: Longint): String;
{
  Do NOT put spaces in if it's just 1000-9999, only 10000+ according to
  metric standard.
}
Var
  loop: byte;
  st: string;
  times: shortint;
Begin
  str(num,st);
  if length(st) > 4 then begin
    reversestr(st);
    times := length(st) div 3;
    if length(st) mod 3 = 0 then dec(times);
    for loop := 1 to times do insert(' ',st,loop*3+loop);
    reversestr(st);
  end;
  metricstr := st;
End;

Procedure GregorianToJulian(Year, Month, Day : word; Var Julian : LongInt);
Var
  Century,
  XYear    : LongInt;
begin
  If Month <= 2 then begin
    dec(Year);
    inc(month, 12);
  End;
  dec(Month, 3);
  Century := Year div 100;
  XYear := Year mod 100;
  Century := (Century * D1) shr 2;
  XYear := (XYear * D0) shr 2;
  Julian := ((((Month*153)+2) div 5)+Day)+D2+XYear+Century;
End;

Procedure JulianToGregorian(Julian: LongInt; Var Year,Month,Day: Word);
Var
  Temp, XYear: LongInt;
  YYear, YMonth, YDay : Integer;
begin
  Temp := (((Julian - D2) shl 2) - 1);
  XYear := (Temp mod D1) or 3;
  Julian := Temp div D1;
  YYear := (XYear div D0);
  Temp := ((((XYear mod D0) + 4) shr 2) * 5) - 3;
  YMonth := Temp div 153;
  If YMonth >= 10 then begin
    Inc(yYear);
    Dec(yMonth,12);
  End;
  inc(YMonth, 3);
  YDay := Temp mod 153;
  YDay := (YDay + 5) div 5;
  Year := YYear + (Julian * 100);
  Month := YMonth;
  Day := YDay;
End;

Function ToUnixDate(fdate: LongInt): String;
Var
   dt: DateTime;
   secspast, datenum, dayspast: LongInt;
   s: String;
Begin
   UnpackTime(fdate,dt);
   With dt do GregorianToJulian(year,month,day,datenum);
   dayspast := datenum-S1970;
   secspast := dayspast*86400;
   with dt do secspast := secspast+hour*3600+min*60+sec;
   s := '';
   While (secspast <> 0) and (Length(s) < 255) do begin
      s := Char((secspast and $7)+$30)+s;
      secspast := (secspast shr 3);
   End;
   s := '0' + s;
   ToUnixDate := s
End;

Function FromUnixDate(s: String): Longint;
Var
   dt: DateTime;
   secspast, datenum: Longint;
   n: Word;
Begin
   secspast := 0;
   For n := 1 to Length(s) do
      secspast := (secspast shl 3) + Byte(s[n]) - $30;
   datenum := (secspast div 86400) + S1970;
   with dt do JulianToGregorian(datenum,year,month,day);
   secspast := secspast mod 86400;
   dt.hour := secspast div 3600;
   secspast := secspast mod 3600;
   dt.min := secspast div 60;
   dt.sec := secspast mod 60;
   PackTime(dt,secspast);
   FromUnixDate := secspast
End;

Function AddBackSlash(st: PathStr): PathStr;
Begin
  If st[length(st)] <> '\' then St := St + '\';
  AddBackSlash := st;
End;

Function RemoveBackSlash(st: PathStr): PathStr;
Begin
  While St[length(st)] = '\' do Delete(St,length(st),1);
  RemoveBackSlash := st;
End;

End.