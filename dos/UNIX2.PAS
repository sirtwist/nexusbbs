(***************************************************************************)
(* UNIX DATE Version 1.01                                                  *)
(* This unit provides access to UNIX date related functions and procedures *)
(* A UNIX date is the number of seconds from January 1, 1970. This unit    *)
(* may be freely used. If you modify the source code, please do not        *)
(* distribute your enhancements.                                           *)
(* (C) 1991-1993 by Brian Stark.                                           *)
(* This is a programming release from Digital Illusions                    *)
(* FidoNet 1:289/27.2 + Columbia, MO - USA                                 *)
(* Revision History                                                        *)
(* ----------------------------------------------------------------------- *)
(* 06-13-1993 1.02 | Minor code cleanup                                    *)
(* 05-23-1993 1.01 | Added a few more routines for use with ViSiON BBS     *)
(* ??-??-1991 1.00 | First release                                         *)
(* ----------------------------------------------------------------------- *)
(***************************************************************************)
UNIT UNIX2;

INTERFACE

Uses
   DOS;

Procedure SetTimeZone(tz:ShortInt);
Function  GetTimeZone : integer;
  {Returns the value from the enviroment variable "TZ". If not found, UTC is
   assumed, and a value of zero is returned}
Function  IsLeapYear(Source : Word) : Boolean;
  {Determines if the year is a leap year or not}
Function  Norm2Unix(Y, M, D, H, Min, S : Word) : LongInt;
  {Convert a normal date to its UNIX date. If environment variable "TZ" is
   defined, then the input parameters are assumed to be in **LOCAL TIME**}
Procedure Unix2Norm(Date : LongInt; Var Y, M, D, H, Min, S : Word);
  {Convert a UNIX date to its normal date counterpart. If the environment
   variable "TZ" is defined, then the output will be in **LOCAL TIME**}

Function  TodayInUnix : LongInt;
  {Gets today's date, and calls Norm2Unix}
{
 Following returns a string and requires the TechnoJock totSTR unit.
Function  Unix2Str(N : LongInt) : String;
}
Const
  TimeZone:ShortInt = 0;
  DaysPerMonth :
    Array[1..12] of ShortInt = (031,028,031,030,031,030,031,031,030,031,030,031);
  DaysPerYear  :
    Array[1..12] of Integer  = (031,059,090,120,151,181,212,243,273,304,334,365);
  DaysPerLeapYear :
    Array[1..12] of Integer  = (031,060,091,121,152,182,213,244,274,305,335,366);
  SecsPerYear      : LongInt  = 31536000;
  SecsPerLeapYear  : LongInt  = 31622400;
  SecsPerDay       : LongInt  = 86400;
  SecsPerHour      : Integer  = 3600;
  SecsPerMinute    : ShortInt = 60;

IMPLEMENTATION

Procedure SetTimeZone(tz:ShortInt);
begin
TimeZone:=TZ;
end;

Function GetTimeZone : integer;
Var
  Environment : String;
  Index : Integer;
Begin
  case timezone of
        1:index:=trunc(-12.0 * SecsPerHour);
        2:index:=trunc(-11.0 * SecsPerHour);
        3:index:=trunc(-10.0 * SecsPerHour);
        4:index:=trunc(-9.0 * SecsPerHour);
        5:index:=trunc(-8.0 * SecsPerHour);
        6:index:=trunc(-7.0 * SecsPerHour);
        7:index:=trunc(-7.0 * SecsPerHour);
        8:index:=trunc(-6.0 * SecsPerHour);
        9:index:=trunc(-6.0 * SecsPerHour);
        10:index:=trunc(-6.0 * SecsPerHour);
        11:index:=trunc(-5.0 * SecsPerHour);
        12:index:=trunc(-5.0 * SecsPerHour);
        13:index:=trunc(-5.0 * SecsPerHour);
        14:index:=trunc(-4.0 * SecsPerHour);
        15:index:=trunc(-4.0 * SecsPerHour);
        16:index:=trunc(-3.5 * SecsPerHour);
        17:index:=trunc(-3.0 * SecsPerHour);
        18:index:=trunc(-3.0 * SecsPerHour);
        19:index:=trunc(-2.0 * SecsPerHour);
        20:index:=trunc(-1.0 * SecsPerHour);
        21:index:=0;
        22:index:=0;
        23:index:=trunc(1.0 * SecsPerHour);
        24:index:=trunc(1.0 * SecsPerHour);
        25:index:=trunc(1.0 * SecsPerHour);
        26:index:=trunc(1.0 * SecsPerHour);
        27:index:=trunc(2.0 * SecsPerHour);
        28:index:=trunc(2.0 * SecsPerHour);
        29:index:=trunc(2.0 * SecsPerHour);
        30:index:=trunc(2.0 * SecsPerHour);
        31:index:=trunc(2.0 * SecsPerHour);
        32:index:=trunc(3.0 * SecsPerHour);
        33:index:=trunc(3.0 * SecsPerHour);
        34:index:=trunc(3.5 * SecsPerHour);
        35:index:=trunc(4.0 * SecsPerHour);
        36:index:=trunc(4.5 * SecsPerHour);
        37:index:=trunc(5.0 * SecsPerHour);
        38:index:=trunc(5.5 * SecsPerHour);
        39:index:=trunc(6.0 * SecsPerHour);
        40:index:=trunc(7.0 * SecsPerHour);
        41:index:=trunc(8.0 * SecsPerHour);
        42:index:=trunc(8.0 * SecsPerHour);
        43:index:=trunc(9.0 * SecsPerHour);
        44:index:=trunc(9.5 * SecsPerHour);
        45:index:=trunc(9.5 * SecsPerHour);
        46:index:=trunc(10.0 * SecsPerHour);
        47:index:=trunc(10.0 * SecsPerHour);
        48:index:=trunc(10.0 * SecsPerHour);
        49:index:=trunc(11.0 * SecsPerHour);
        50:index:=trunc(12.0 * SecsPerHour);
        51:index:=trunc(12.0 * SecsPerHour);
  end;
  GetTimeZone:=index;
End;

Function IsLeapYear(Source : Word) : Boolean;
Begin
(*
  NOTE: This is wrong!
*)
  Isleapyear:=(source mod 4=0) and ((source mod 100<>0) or (source mod 400=0));
End;

function cstr(i:longint):string;
var c:string[16];
begin
  str(i,c);
  cstr:=c;
end;

function tch(s:string):string;
begin
  if (length(s)>2) then s:=copy(s,length(s)-1,2) else
    if (length(s)=1) then s:='0'+s;
  tch:=s;
end;

Function Norm2Unix(Y,M,D,H,Min,S : Word) : LongInt;
Var
  UnixDate : LongInt;
  Index    : Word;
Begin
  UnixDate := 0;                                                 {initialize}
  Inc(UnixDate,S);                                              {add seconds}
  Inc(UnixDate,(SecsPerMinute * Min));                          {add minutes}
  Inc(UnixDate,(SecsPerHour * H));                                {add hours}
  (*************************************************************************)
  (* If UTC = 0, and local time is -06 hours of UTC, then                  *)
  (* UTC := UTC - (-06 * SecsPerHour)                                      *)
  (* Remember that a negative # minus a negative # yields a positive value *)
  (*************************************************************************)
  UnixDate := UnixDate - GetTimeZone;            {UTC offset}

  If D > 1 Then                                 {has one day already passed?}
    Inc(UnixDate,(SecsPerDay * (D-1)));

  If IsLeapYear(Y) Then
    DaysPerMonth[02] := 29
  Else
    DaysPerMonth[02] := 28;                             {Check for Feb. 29th}

  Index := 1;
  If M > 1 Then For Index := 1 To (M-1) Do    {has one month already passed?}
    Inc(UnixDate,(DaysPerMonth[Index] * SecsPerDay));

  While Y > 1970 Do
  Begin
    If IsLeapYear((Y-1)) Then
      Inc(UnixDate,SecsPerLeapYear)
    Else
      Inc(UnixDate,SecsPerYear);
    Dec(Y,1);
  End;

  Norm2Unix := UnixDate;
End;

Procedure Unix2Norm(Date : LongInt; Var Y, M, D, H, Min, S : Word);
{}
Var
  LocalDate : LongInt;
  Done      : Boolean;
  X         : ShortInt;
  TotDays   : Integer;
Begin
  Y   := 1970;
  M   := 1;
  D   := 1;
  H   := 0;
  Min := 0;
  S   := 0;
  LocalDate := Date + GetTimeZone;         {Local time date}
 (*************************************************************************)
 (* Sweep out the years...                                                *)
 (*************************************************************************)
  Done := False;
  While Not Done Do
  Begin
    If LocalDate >= SecsPerYear Then
    Begin
      Inc(Y,1);
      Dec(LocalDate,SecsPerYear);
    End
    Else
      Done := True;
                    { +1 }
    If (IsLeapYear(Y)) And (LocalDate >= SecsPerLeapYear) And
       (Not Done) Then
    Begin
      Inc(Y,1);
      Dec(LocalDate,SecsPerLeapYear);
    End;
  End;
  (*************************************************************************)
  M := 1;
  D := 1;
  Done := False;
  TotDays := LocalDate Div SecsPerDay;
  If IsLeapYear(Y) Then
  Begin
    DaysPerMonth[02] := 29;
    X := 1;
    Repeat
      If (TotDays <= DaysPerLeapYear[x]) Then
      Begin
        M := X;
        Done := True;
        Dec(LocalDate,(TotDays * SecsPerDay));
        D := DaysPerMonth[M]-(DaysPerLeapYear[M]-TotDays) + 1;
      End
      Else
        Done := False;
      Inc(X);
    Until (Done) or (X > 12);
  End
  Else
  Begin
    DaysPerMonth[02] := 28;
    X := 1;
    Repeat
      If (TotDays <= DaysPerYear[x]) Then
      Begin
        M := X;
        Done := True;
        Dec(LocalDate,(TotDays * SecsPerDay));
        D := DaysPerMonth[M]-(DaysPerYear[M]-TotDays) + 1;
      End
      Else
        Done := False;
      Inc(X);
    Until Done = True or (X > 12);
  End;
  H := LocalDate Div SecsPerHour;
    Dec(LocalDate,(H * SecsPerHour));
  Min := LocalDate Div SecsPerMinute;
    Dec(LocalDate,(Min * SecsPerMinute));
  S := LocalDate;
End;

Function  TodayInUnix : LongInt;
Var
  Year, Month, Day, DayOfWeek: Word;
  Hour, Minute, Second, Sec100: Word;
Begin
  GetDate(Year, Month, Day, DayOfWeek);
  GetTime(Hour, Minute, Second, Sec100);
  TodayInUnix := Norm2Unix(Year,Month,Day,Hour,Minute,Second);
End;

Function  Unix2Str(N : LongInt) : String;
Var
  Year, Month, Day, DayOfWeek  : Word;
  Hour, Minute, Second, Sec100 : Word;
  T : String;
Begin
  Unix2Norm(N, Year, Month, Day, Hour, Minute, Second);
  T := tch(cstr(Month))+'-'+tch(cstr(Day))+'-'+
       tch(cstr(Year))+' '+ tch(cstr(Hour))+':'+
       tch(cstr(Minute))+':'+tch(cstr(Second));
  If Hour > 12 Then
    T := T + ' PM'
  Else
    T := T + ' AM';
  Unix2Str := T;
End;


END.
