{$A+,B-,D-,E+,F-,G-,I+,L+,N-,O-Q-,R-,S+,T-,V+,X+,Y+}
{$M 16384,0,655360}
Unit KeyMisc;
Interface
Uses AsmMisc;
Type
  { These two records are used to trap keys. Uses linked list to conserve }
  { on memory }
  KeyPtr = ^key;
  Key = record
    Active: boolean;
    Extnded: boolean;
    Key: char;
    Proc: pointer;
    Next: KeyPtr;
  End;

Const
  Keys: keyptr = nil; { To keep track of trapped keys }
  Kpi: pointer = nil;
  Kpe: pointer = nil;
Var
  touchres: String; { Touch residuelle }
{ For easy reference to keys }
Const
  _Home     = #71;
  _End      = #79;
  _Up       = #72;
  _Down     = #80;
  _Left     = #75;
  _Right    = #77;
  _PageUp   = #73;
  _PageDown = #81;
  _Insert   = #82;
  _Delete   = #83;
  _CtrlPageUp   = #132;
  _CtrlPageDown = #118;
  _CtrlHome     = #119;
  _CtrlEnd      = #117;

  { First row }
  _AltQ     = #16;
  _AltW     = #17;
  _AltE     = #18;
  _AltR     = #19;
  _AltT     = #20;
  _AltY     = #21;
  _AltU     = #22;
  _AltI     = #23;
  _AltO     = #24;
  _AltP     = #25;

  { Second row }
  _AltA     = #30;
  _AltS     = #31;
  _AltD     = #32;
  _AltF     = #33;
  _AltG     = #34;
  _AltH     = #35;
  _AltJ     = #36;
  _AltK     = #37;
  _AltL     = #38;

  { Forth row }
  _AltZ     = #44;
  _AltX     = #45;
  _AltC     = #46;
  _AltV     = #47;
  _AltB     = #48;
  _AltN     = #49;
  _AltM     = #50;

  { Number row }
  _Alt1     = #120;
  _Alt2     = #121;
  _Alt3     = #122;
  _Alt4     = #123;
  _Alt5     = #124;
  _Alt6     = #125;
  _Alt7     = #126;
  _Alt8     = #127;
  _Alt9     = #128;
  _Alt0     = #129;
  _Alt_Dash = #130;
  _Alt_Equal= #131;

  { Function keys }

  _F1       = #59;
  _F2       = #60;
  _F3       = #61;
  _F4       = #62;
  _F5       = #63;
  _F6       = #64;
  _F7       = #65;
  _F8       = #66;
  _F9       = #67;
  _F10      = #68;

  { Variations of the keys }

  _AltF1    = #104;
  _AltF2    = #105;
  _AltF3    = #106;
  _AltF4    = #107;
  _AltF5    = #108;
  _AltF6    = #109;
  _AltF7    = #110;
  _AltF8    = #111;
  _AltF10   = #112;

  _ShiftF1  = #84;
  _ShiftF2  = #85;
  _ShiftF3  = #86;
  _ShiftF4  = #87;
  _ShiftF5  = #88;
  _ShiftF6  = #89;
  _ShiftF7  = #90;
  _ShiftF8  = #91;
  _ShiftF10 = #92;

  _CtrlF1   = #94;
  _CtrlF2   = #95;
  _CtrlF3   = #96;
  _CtrlF4   = #97;
  _CtrlF5   = #98;
  _CtrlF6   = #99;
  _CtrlF7   = #100;
  _CtrlF8   = #101;
  _CtrlF10  = #102;

Function Readkey: Char;
Function Keypressed: Boolean;

Procedure AddKey(ch: char; ExtendedCode: boolean; proced: pointer);
Procedure SetActive(Ch: char; ExtendedCode: boolean; Active: boolean);
Procedure ChangeKey(Ch: char; ExtendedCode: boolean; newch: char; NewExtendedCode: boolean; newproc: pointer);
Procedure RemoveKey(Ch: char; ExtendedCode: boolean);

Implementation

Function Keypressed: boolean;
begin
  if kpi <> nil then calluserproc(kpi);
  if (crt.keypressed) or (touchres <> '') then begin
    keypressed := true;
    if kpe <> nil then calluserproc(kpe);
  end
  else keypressed := false;
end;

Function Readkey: char;
Var
  Quit: boolean;
  Ch: Char;
  Curr: Keyptr;
begin
  If touchres <> '' then begin
    ch := touchres[1];
    delete(touchres,1,1);
  End
  else repeat
    repeat until keypressed;

    Quit := false;

    ch := crt.readkey;
    If ch = #0 then begin
      ch := crt.readkey;

      curr := keys;
      while curr <> nil do Begin
        If (curr^.key = ch) and (curr^.active) and (curr^.extnded = true) then begin
          calluserproc(curr^.proc);
          quit := true;
        End;
        curr := curr^.next;
      End;

      If not quit then begin
        touchres := touchres + ch; { Save the scan code }
        ch := #0;                  { Send a null }
      end;
      quit := not quit;
    End
    Else Begin
      curr := keys;
      while curr <> nil do Begin
        If (curr^.key = ch) and (curr^.active) and (curr^.extnded = false) then begin
          calluserproc(curr^.proc);
          quit := true;
        End;
        Curr := curr^.next;
      End;

      quit := not quit;
    end;
  Until Quit;
  Readkey := ch;
end;

Procedure AddKey(ch: char; ExtendedCode: boolean; proced: pointer);
var curr: keyptr;
Begin
  If keys = nil then begin
    new(keys);
    curr := keys;
  end
  else Begin
    curr := keys;
    while curr^.next <> nil do curr := curr^.next;
    New(curr^.next);
    Curr := curr^.next;
  End;
  with curr^ do begin
    next := nil;
    extnded := extendedcode;
    key := ch;
    Active := true;
    proc := proced;
  end;
End;

Procedure SetActive(Ch: char; ExtendedCode: boolean; Active: boolean);
Var curr: keyptr;
Begin
  Curr := keys;
  While (curr <> nil) and not ((ch = curr^.key) and (extendedcode = curr^.extnded)) do
    Curr := curr^.next;
  If curr = nil then exit;
  Curr^.active := active;
End;

Procedure ChangeKey(Ch: char; ExtendedCode: boolean; newch: char; NewExtendedCode: boolean; newproc: pointer);
Var curr: keyptr;
Begin
  curr := keys;
  while (curr <> nil) and not ((ch = curr^.key) and (extendedcode = curr^.extnded)) do
    curr := curr^.next;

  If curr = nil then exit;
  with curr^ do begin
    key := newch;
    Extnded := ExtendedCode;
    proc := newproc;
  end;
End;

Procedure RemoveKey(Ch: char; ExtendedCode: boolean);
Var
  _next,
  me,
  curr: keyptr;
Begin
  Curr := keys;
  while (curr <> nil) and not ((ch = curr^.key) and (extendedcode = curr^.extnded)) do
    curr := curr^.next;
  If curr = nil then exit;
  me := curr;
  _next := curr^.next;

  { Seek up to the one before it }
  curr := keys;
  if (ch = curr^.key) and (extendedcode = curr^.extnded) then begin
    keys := curr^.next;
  end
  else begin
    while (curr <> nil) and not ((ch = curr^.next^.key) and (extendedcode = curr^.next^.extnded)) do
      curr := curr^.next;
    if curr <> nil then curr^.next := _next;
  end;
  dispose(me);
End;

begin
  touchres := '';
End.
