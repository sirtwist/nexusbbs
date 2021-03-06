{$S-,R-,V-,D-}
{\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\}
{         TechnoJocks Turbo Toolkit v4.00            Released: Feb 1, 1988    }
{                                                                             }
{         Module: StrngTTT    --    string manipulation routines              }
{                                                                             }
{                       Copyright R. D. Ainsbury (c) 1986                     }
{\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\}

unit StrngTTT;

interface

Function PadLeft(Str:string;Size:byte;Pad:char):string;
Function PadCenter(Str:string;Size:byte;Pad:char):string;
Function PadRight(Str:string;Size:byte;Pad:char):string;
Function Last(N:byte;Str:string):string;
Function First(N:byte;Str:string):string;
Function Upper(Str:string):string;
Function Lower(Str:string):string;
Function Proper(Str:string):string;
Function OverType(N:byte;StrS,StrT:string):string;
Function Strip(L,C:char;Str:string):string;
Function LastPos(C:Char;Str:string):byte;
Function PosWord(Wordno:byte;Str:string):byte;
Function WordCnt(Str:string):byte;
Function ExtractWords(StartWord,NoWords:byte;Str:string):string;
Function Str_to_Int(Str:string):integer;
Function Real_to_str(Number:real;Decimals:byte):string;
Function Int_to_Str(Number:longint):string;

implementation

Function PadLeft(Str:string;Size:byte;Pad:char):string;
var temp : string;
begin
    Fillchar(Temp[1],Size,Pad);
    Temp[0] := chr(Size);
    If Length(Str) <= Size then
       Move(Str[1],Temp[1],length(Str))
    else
       Move(Str[1],Temp[1],size);
    PadLeft := Temp;
end;

Function PadCenter(Str:string;Size:byte;Pad:char):string;
var temp : string;
L : byte;
begin
    Fillchar(Temp[1],Size,Pad);
    Temp[0] := chr(Size);
    L := length(Str);
    If L <= Size then
       Move(Str[1],Temp[((Size - L) div 2) + 1],L)
    else
       Move(Str[((L - Size) div 2) + 1],Temp[1],Size);
    PadCenter := temp;
end; {center}

Function PadRight(Str:string;Size:byte;Pad:char):string;
var
  temp : string;
  L : integer;
begin
    Fillchar(Temp[1],Size,Pad);
    Temp[0] := chr(Size);
    L := length(Str);
    If L <= Size then
       Move(Str[1],Temp[succ(Size - L)],L)
    else
       Move(Str[1],Temp[1],size);
    PadRight := Temp;
end;

Function Last(N:byte;Str:string):string;
var Temp : string;
begin
    If N > length(Str) then
       Temp := Str
    else
       Temp := copy(Str,succ(length(Str) - N),N);
    Last := Temp;
end;  {Func Last}

Function First(N:byte;Str:string):string;
var Temp : string;
begin
    If N > length(Str) then
       Temp := Str
    else
       Temp := copy(Str,1,N);
    First := Temp;
end;  {Func First}

Function Upper(Str:string):string;
var
  I : integer;
begin
    For I := 1 to length(Str) do
        Str[I] := Upcase(Str[I]);
    Upper := Str;
end;  {Func Upper}

Function Lower(Str:string):string;
var
  I : integer;
begin
    For I := 1 to length(Str) do
        If ord(Str[I]) in [65..90] then
           Str[I] := chr(ord(Str[I]) + 32);
    Lower := Str;
end;  {Func Lower}

Function Proper(Str:string):string;
var
  I : integer;
  SpaceBefore: boolean;
begin
    SpaceBefore := true;
    Str := lower(Str);
    For I := 1 to length(Str) do
        If SpaceBefore and (ord(Str[I]) in [97..122]) then
        begin
            SpaceBefore := False;
            Str[I] := Upcase(Str[I]);
        end
        else
            If (SpaceBefore = False) and (Str[I] = ' ') then
                SpaceBefore := true;
    Proper := Str;
end;

Function OverType(N:byte;StrS,StrT:string):string;
{Overlays StrS onto StrT at Pos N}
var
  L : byte;
  StrN : string;
begin
    L := N + pred(length(StrS));
    If L < length(StrT) then
       L := length(StrT);
    If L > 255 then
       Overtype := copy(StrT,1,pred(N)) + copy(StrS,1,255-N)
        else
    begin
       Fillchar(StrN[1],L,' ');
       StrN[0] := chr(L);
       Move(StrT[1],StrN[1],length(StrT));
       Move(StrS[1],StrN[N],length(StrS));
       OverType := StrN;
    end;
end;  {Func OverType}

Function Strip(L,C:char;Str:string):string;
{L is left,center,right,all,ends}
var I :  byte;
begin
    Case Upcase(L) of
    'L' : begin       {Left}
              While Str[1] = C do
                    Delete(Str,1,1);
          end;
    'R' : begin       {Right}
              While Str[length(Str)] = C do
                    Delete(Str,length(Str),1);
          end;
    'B' : begin       {Both left and right}
              While Str[1] = C do
                    Delete(Str,1,1);
              While Str[length(Str)] = C do
                    Delete(Str,length(Str),1);
          end;
    'A' : begin       {All}
              I := 1;
              Repeat
                   If Str[I] = C then
                      Delete(Str,I,1)
                   else
                      I := succ(I);
              Until (I > length(Str)) or (Str = '');
          end;
    end;
    Strip := Str;
end;  {Func Strip}

Function LastPos(C:Char;Str:string):byte;
Var I : byte;
begin
    I := succ(Length(Str));
    Repeat
         I := Pred(I);
    Until (I = 0) or (Str[I] = C);
    LastPos := I;
end;  {Func LastPos}

Function LocWord(StartAT,Wordno:byte;Str:string):byte;
{local proc used by PosWord and Extract word}
var
  W,L: integer;
  Spacebefore: boolean;
begin
    If (Str = '') or (wordno < 1) or (StartAT > length(Str)) then
    begin
        LocWord := 0;
        exit;
    end;
    SpaceBefore := true;
    W := 0;
    L := length(Str);
    StartAT := pred(StartAT);
    While (W < Wordno) and (StartAT <= length(Str)) do
    begin
        StartAT := succ(StartAT);
        If SpaceBefore and (Str[StartAT] <> ' ') then
        begin
            W := succ(W);
            SpaceBefore := false;
        end
        else
            If (SpaceBefore = false) and (Str[StartAT] = ' ') then
                SpaceBefore := true;
    end;
    If W = Wordno then
       LocWord := StartAT
    else
       LocWord := 0;
end;

Function PosWord(Wordno:byte;Str:string):byte;
begin
    PosWord := LocWord(1,wordno,Str);
end;  {Func Word}

Function WordCnt(Str:string):byte;
var
  W,I: integer;
  SpaceBefore: boolean;
begin
    If Str = '' then
    begin
        WordCnt := 0;
        exit;
    end;
    SpaceBefore := true;
    W := 0;
    For  I :=  1 to length(Str) do
    begin
        If SpaceBefore and (Str[I] <> ' ') then
        begin
            W := succ(W);
            SpaceBefore := false;
        end
        else
            If (SpaceBefore = false) and (Str[I] = ' ') then
                SpaceBefore := true;
    end;
    WordCnt := W;
end;

Function ExtractWords(StartWord,NoWords:byte;Str:string):string;
var Start, finish : integer;
begin
    If Str = '' then
    begin
        ExtractWords := '';
        exit;
    end;
    Start := LocWord(1,StartWord,Str);
    If Start <> 0 then
       finish := LocWord(Start,succ(NoWords),Str)
    else
    begin
        ExtractWords := '';
        exit;
    end;
    If finish <> 0 then
       Repeat
           finish := pred(finish);
       Until Str[finish] <> ' '
    else
       finish := length(Str);
    ExtractWords := copy(Str,Start,succ(finish-Start));
end;  {Func ExtractWords}

Function Int_to_Str(Number:longint):string;
var Temp : string;
begin
    Str(Number,temp);
    Int_to_Str := temp;
end;

Function Str_to_Real(Str:string):real;
var temp,code : integer;
begin
    If length(Str) = 0 then
       Str_to_Real := 0
    else
    begin
        If Copy(Str,1,1)='.' Then
           Str:='0'+Str;
        If (Copy(Str,1,1)='-') and (Copy(Str,2,1)='.') Then
           Insert('0',Str,2);
        If Str[length(Str)] = '.' then
           Delete(Str,length(Str),1);
       val(Str,temp,code);
       if code = 0 then
          Str_to_Real := temp
       else
          Str_to_Real := 0;
    end;
end;

function Real_to_str(Number:real;Decimals:byte):string;
var Temp : string;
begin
    Str(Number:20:Decimals,Temp);
    repeat
         If copy(Temp,1,1) = ' ' then delete(Temp,1,1);
    until copy(temp,1,1) <> ' ';
    Real_to_Str := Temp;
end;

Function  Str_to_Int(Str:string):integer;
var temp,code : integer;
begin
    If length(Str) = 0 then
       Str_to_Int := 0
    else
    begin
       val(Str,temp,code);
       if code = 0 then
          Str_to_Int := temp
       else
          Str_to_Int := 0;
    end;
end;

end.
