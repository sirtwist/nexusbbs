unit unixdate;

interface

uses dos,crt,mkmisc,mkstring;

function curdatetimeunix:longint;
function unixtime2str(unix:longint):string;
function str2unixtime(dt:string):longint;      { format: 00/00/00  00:00:00 }

implementation

function tch(s:string):string;
begin
  if (length(s)>2) then s:=copy(s,length(s)-1,2) else
    if (length(s)=1) then s:='0'+s;
  tch:=s;
end;

function time:string;
var h,m,s:string[3];
    hh,mm,ss,ss100:word;
begin
  gettime(hh,mm,ss,ss100);
  str(hh,h); str(mm,m); str(ss,s);
  time:=tch(h)+':'+tch(m)+':'+tch(s);
end;

function date:string;
var r:registers;
    y,m,d:string[3];
    yy,mm,dd,dow:word;
begin
  getdate(yy,mm,dd,dow);
  str(yy-1900,y); str(mm,m); str(dd,d);
  date:=tch(m)+'/'+tch(d)+'/'+tch(y);
end;

function unixtime2str(unix:longint):string;
var d:datetime;
begin
UnixToDT(unix,d);
unixtime2str:=FormattedDate(d,'MM/DD/YY  HH:II:SS');
end;

function value(s:string):longint;
var i:longint;
    j:integer;
begin
  val(s,i,j);
  if (j<>0) then begin
    s:=copy(s,1,j-1);
    val(s,i,j)
  end;
  value:=i;
  if (s='') then value:=0;
end;

function leapyear(yr:integer):boolean;
begin
  leapyear:=(yr mod 4=0) and ((yr mod 100<>0) or (yr mod 400=0));
end;

function days(mo,yr:integer):integer;
var d:integer;
begin
  d:=value(copy('312831303130313130313031',1+(mo-1)*2,2));
  if ((mo=2) and (leapyear(yr))) then inc(d);
  days:=d;
end;

function daycount(mo,yr:integer):integer;
var m,t:integer;
begin
  t:=0;
  for m:=1 to (mo-1) do t:=t+days(m,yr);
  daycount:=t;
end;

function str2unixtime(dt:string):longint;
var d,m,y,c,h,min,s,count:integer;
    t:longint;
begin
  t:=0;
  m:=value(copy(dt,1,2));
  d:=value(copy(dt,4,2));
  y:=value(copy(dt,7,2))+1900;
  h:=0;
  min:=0;
  s:=0;
  count:=1;                           
  if (pos(':',dt)<>0) and (pos(':',dt)>11) then begin
        h:=value(copy(dt,pos(':',dt)-2,2));
        min:=value(copy(dt,pos(':',dt)+1,2));
        dt[pos(':',dt)]:='-';
        if (pos(':',dt)<>0) then
         s:=value(copy(dt,pos(':',dt)+1,2));
  end;
  for c:=1970 to y-1 do
    if (leapyear(c)) then t:=t+(366*86400) else t:=t+(365*86400);
  t:=t+((daycount(m,y)+(d-1))*86400);
  str2unixtime:=t+(h*3600)+(min*60)+s;
  if y<1970 then str2unixtime:=0;
end;

function curdatetimeunix:longint;
begin
curdatetimeunix:=str2unixtime(date+'  '+time);
end;

end.
(* A public domain Turbo Pascal unit to convert between the date formats *)
(* of DOS and Unix; by Robert Walking-Owl October 1993                   *)

unit UnixDate;

interface

function DosToUnixDate(DOSTime: LongInt): LongInt;
function UnixToDosDate(UnixDate: LongInt): LongInt;

implementation
  uses DOS;

function DosToUnixDate(DOSTime: LongInt): LongInt;
const DaysInMonth: array[1..12] of word =
  (30, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
var i, j :    Word;
    UnixDate: LongInt;
    DTR:      DateTime;
begin
   UnPackTime(DOSTime,DTR);
   UnixDate := 0;
   UnixDate:=(DTR.year-1970)*365+((DTR.year-1971) div 4);
   j:=pred(DTR.day);
   if DTR.month<>1
     then for i:=1 to pred(DTR.month) do j:=j+DaysInMonth[i];
   if ((DTR.year mod 4)=0) and (DTR.month>2)
     then inc(j);
   UnixDate:=UnixDate+j; (* Add number of days this year *)
   UnixDate:=(UnixDate*24)+DTR.hour;
   UnixDate:=(UnixDate*60)+DTR.min;
   UnixDate:=(UnixDate*60)+DTR.sec;
   DosToUnixDate:=UnixDate;
end;

function UnixToDosDate(UnixDate: LongInt): LongInt;
const DaysInMonth: array[1..12] of word =
  (30, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
var i, j :    Word;
    DTR:      DateTime;
    DosTime:  LongInt;
begin
   DaysInMonth[2]:=28;
   DTR.sec  := UnixDate mod 60;  UnixDate := UnixDate div 60;
   DTR.min  := UnixDate mod 60;  UnixDate := UnixDate div 60;
   DTR.hour := UnixDate mod 24;  UnixDate := UnixDate div 24;
   DTR.day  := UnixDate mod 365; UnixDate := UnixDate div 365;
   DTR.year := UnixDate+1970;
   DTR.day  := 1+DTR.day-((DTR.year-1972) div 4);
   if (DTR.day > (31+29)) and ((DTR.year mod 4)=0)
     then inc(DaysInMonth[2]);
   DTR.month:=1;
   while DTR.day>DaysInMonth[DTR.Month]
     do begin
       DTR.day := DTR.day - DaysInMonth[DTR.Month];
       inc(DTR.month)
       end;
   PackTime(DTR,DosTime);
   UnixToDosDate:=DosTime;
end;

end.


This archive includes the Turbo Pascal source for a unit that will
convert between Unix-file timestamps and DOS-file timestamps.

The advantage is that you can write software, such as archivers
or archiver-utilities which can handle Unix-style dates and times.
(Note many systems will store the data in BigEndian format, so
you'll have to do a further bit of conversion.)

If the value is bigendian: Turbo Pascal includes the function Swap 
for words.  To swap a long integer you'll have to reverse the bytes.

Both systems store a packed record of the date and time in a four
byte long-integer (also called a double-word).


DOS stores the date and time (of a file) actually as two packed words:
                  
                   Date:              Time:

Bit:        FEDCBA98 76543210  FEDCBA98 76543210
            xxxxxxx. ........  ........ ........   Year - 1980
            .......x xxx.....  ........ ........   Month     (1-12)
            ........ ...xxxxx  ........ ........   Day       (1-31)

            ........ ........  xxxxx... ........   Hours     (0-23)
            ........ ........  .....xxx xxx.....   Minutes   (0-59)
            ........ ........  ........ ...xxxxx   Seconds/2 (0-29)
                                                         

Unix stores the date as the number of seconds since January 1, 1970 UTC
(Universal Coordinated Time = Grenwich Mean Time).  The is an _exact_
number (not including leap seconds)--it accounts for months of 28 (or
29, for leap years), 30 and 31 days.

Note that some (Unix) software assumes your time is set for UTC and stores
the date/time stamp blindly, while others attempt to figure out which
time zone you're in and convert the time appropriately.  (This can be
done if the TZ variable is set properly.)  So don't fret if you find the
conversions a few hours off...



