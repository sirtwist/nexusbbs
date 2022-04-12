{$A+,B-,D-,E+,F-,G-,I-,L+,N-,O-,R-,S-,V+,X+}
{$M 16384,0,655360}
Unit AsmMisc; { by John MD Stephenson; Copyright 1995 }
{
  Country specific case conversation and other info retrieval
  donated to the public domain by Bj”rn Felten @ 2:203/208.
  Arne de.Bruijn wrote the WildComp function.
  The UnCrunch routine comes from TheDraw (pd)
  All other code is written by myself, or uncredited Public Domain.
}

{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿}
{³                              } Interface {                             ³}
{ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}
Uses Dos,Crt;
Const
  { 
    Instead of using: textattr := blue shl 4+lightblue;
    Use: textattr := _blue+lightblue;
  }
  
  _Black        = Black shl 4;
  _Blue         = Blue shl 4;
  _Green        = Green shl 4;
  _Cyan         = Cyan shl 4;
  _Red          = Red shl 4;
  _Magenta      = Magenta shl 4;
  _Brown        = Brown shl 4;
  _LightGray    = LightGray shl 4;
  _DarkGray     = DarkGray shl 4;
  _LightBlue    = LightBlue shl 4;
  _LightGreen   = LightGreen shl 4;
  _LightCyan    = LightCyan shl 4;
  _LightRed     = LightRed shl 4;
  _LightMagenta = LightMagenta shl 4;
  _Yellow       = Yellow shl 4;
  _White        = White shl 4;

Type
  tRGB = record R,G,B: byte; end;
  tPal = array[0..255] of tRGB;

  DelimType = record
    thousands,
    decimal,
    date,
    time: array[0..1] of Char;
  end;

  CurrType = (leads,             { symbol precedes value }
              trails,            { value precedes symbol }
              leads_,            { symbol, space, value }
              _trails,           { value, space, symbol }
              replace);          { replaced }

  datefmt = (USA,Europe,Japan);

  CountryType = record
    DateFormat     : Word;           { 0: USA, 1: Europe, 2: Japan }
    CurrSymbol     : array[0..4] of Char;
    Delimiter      : DelimType;      { Separators }
    CurrFormat     : CurrType;       { Way currency is formatted }
    CurrDigits     : Byte;           { Digits in currency }
    Clock24hrs     : Boolean;        { True if 24-hour clock }
    CaseMapCall    : Procedure;      { Lookup table for ASCII > $80 }
    DataListSep    : array[0..1] of Char;
    CID            : word;
    Reserved       : array[0..7] of Char;
  end;

  CountryInfo =  record
    case InfoID: byte of
      1: (IDSize     : word;
          CountryID  : word;
          CodePage   : word;
          TheInfo    : CountryType);
      2: (UpCaseTable: pointer);
  end;

  { Used to save the screen with SaveScreen, And RestoreScreen }
  Screensavetype = record
    Screen: pointer;
    X,y,attr: byte;
  End;

var
  CountryOk          : Boolean;        { Could determine country code flag }
  CountryRec         : CountryInfo;
  Maxwidth,maxheight : Byte;
  ScreenSize         : Word;
  ToggleStatus       : Byte; // absolute $0040:$0017;
  TimerAddr          : Longint; // absolute $0040:$006C;
  kbdHeadPtr         : Word; // absolute $0040:$1A;
  kbdTailPtr         : Word; // absolute $0040:$1C;
  OrgCursor          : Word;          { Stores original cursor at start up }

{ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ}
Procedure BlinkOff;
Procedure BlinkOn;
Procedure CallUserProc(proc: pointer);
Procedure CLI; 
Procedure CursorOff;
Procedure CursorOn;
Procedure GetBorder(var color: byte);
Procedure SetBorder(color: byte);
Procedure GetCursor(var cursor: word);
Procedure SetCursor(cursor: word);
Procedure PutAttrs(x,y: byte; times: word);
Procedure PutChars(x,y: byte; chr: char; times: word);
Procedure PutString(x,y: byte; s: string);
Procedure ReallocateMemory(P: Pointer);
Procedure Retrace;
Procedure SaveScreen(var screen: screensavetype);
Procedure ShowScreen(var orgscreen: screensavetype);
Procedure RestoreScreen(var orgscreen: screensavetype);
Procedure SetColor(Color,r,g,b: Byte);
Procedure GetColor(Color: byte; var r,g,b: byte);
Procedure SetPal(var vPal: tPal);
Procedure GetPal(var vPal: tPal);
Procedure Scroll(x1,y1,x2,y2,times: byte);
Procedure StuffChar(c: char);
Procedure STI;
Procedure UnCrunch(var Addr1,Addr2; BlkLen: Word);
Procedure ColdBoot;
Procedure WarmBoot;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Function Anykeypressed: Boolean;
Function Execute(Name,tail: pathstr): Word;
// Function LoCase(c: Char): Char;
Function LoCaseStr(s: String): String;
// Function UpCase(c: Char): Char;
Function UpCaseStr(s: String): String;
Function WildComp(NameStr,SearchStr: String): Boolean;
{ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ}
Type
  Screentype = array[0..7999] of byte;
Var
  VidSeg    : Word;
  Screenaddr: ^ScreenType;
  LoTable   : Array[0..127] of byte;
  CRP, LTP  : Pointer;

{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿}
{³                            } Implementation {                          ³}
{ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}

Procedure CLI;
begin
//Inline($FA);
end;

Procedure STI;
begin
//Inline($FB);
end;

Procedure WarmBoot; //Assembler;
begin
end;

Procedure ColdBoot; // Assembler;
begin
End;

Procedure CallUserProc(proc: pointer);
begin 
//Inline($FF/$5E/<proc); 
end;

Procedure SetColor(color,r,g,b: Byte); // Assembler;
begin
End;

Procedure GetColor(Color: byte; var r,g,b: byte); // Assembler;
{ This reads the values of the Red, Green and Blue DAC values of a
  certain color and returns them to you in r (red), g (green), b (blue) }
begin
end;

Procedure SetPal(var vPal: tPal);
Var loop: byte;
Begin
  For loop := 0 to 255 do with vPal[loop] do SetColor(loop,r,g,b);
End;

Procedure GetPal(var vPal: tPal);
Var loop: byte;
Begin
  For loop := 0 to 255 do with vPal[loop] do GetColor(loop,r,g,b);
End;

Procedure SetBorder(color : byte);  //assembler;
begin
end;

Procedure GetBorder(var color : byte);// assembler;
begin
end;

Procedure GetCursor(var cursor: word); // assembler;
begin
End;

Procedure SetCursor(cursor: word); // assembler;
begin
End;

Procedure CursorOn; // assembler;
begin
end;

Procedure CursorOff; // assembler;
begin
end;

Procedure StuffChar(c : char); // assembler;
begin
end;

Procedure BlinkOff; // assembler;
{ Note that the BL is the actual register, but BH _should_ also be set to 0 }
begin
end;

Procedure BlinkOn; // assembler;
{ Note that the BL is the actual register, but BH _should_ also be set to 0 }
begin
end;

Procedure Retrace; // assembler;
{ waits for a vertical retrace }
begin
end;

Procedure UnCrunch(var Addr1,Addr2; BlkLen:Word); // assembler;
{ From TheDraw, not my Procedure }
begin
end;

Procedure ReallocateMemory(P : Pointer); // Assembler;
begin
End;

Function Execute(Name, tail : pathstr) : Word; // Assembler;
begin
End;

Procedure Putchars(x, y : byte; chr : char; times : word);
{ Procedure to fill a count amount of characters from position x, y }
var offst: word;
begin
  offst := (pred(y)*maxwidth+pred(x))*2;
//  asm
//    mov es, VidSeg    { Segment to start at       }
//    mov di, offst     { Offset to start at        }
//    mov al, chr       { Data to place             }
//    mov ah, textattr  { Colour to use             }
//    mov cx, times     { How many times            }
//    cld               { Forward in direction      }
//    rep stosw         { Store the word (cx times) }
//  end;
end;

Procedure PutAttrs(x,y: byte; times: word);
{ This Procedure is to fill a certain amount of spaces with a colour       }
{ (from cursor position) and doesn't move cursor position!                 }
var offst: word;
begin
  offst := succ((pred(y)*maxwidth+pred(x))*2);
//  asm
//    mov es, VidSeg
//    mov di, offst
//    mov cx, times
//    mov ah, 0
//    mov al, textattr
//    cld
//   @s1:
//    stosb
//    inc di    { Increase another above what the stosb already loops }
//    loop @s1  { Loop until cx = 0                                   }
//  end;
end;

Procedure PutString(x, y: byte; s: string);
Begin
  { Does a direct video write -- extremely fast. }
//  asm
//    mov dh, y         { move X and Y into DL and DH (DX) }
//    mov dl, x

//    xor al, al
//    mov ah, textattr  { load color into AH }
//    push ax           { PUSH color combo onto the stack }

//    mov ax, VidSeg
//    push ax           { PUSH video segment onto stack }

//    mov bx, 0040h     { check 0040h:0049h to get number of screen columns }
//   mov es, bx
//    mov bx, 004Ah
//    xor ch, ch
//    mov cl, es:[bx]
//    xor ah, ah        { move Y into AL; decrement to convert Pascal coords }
//    mov al, dh
//    dec al
//    xor bh, bh        { shift X over into BL; decrement again }
//    mov bl, dl
//    dec bl
//    cmp cl, 80        { see if we're in 80-column mode }
//    je @eighty_column
//    mul cx            { multiply Y by the number of columns }
//    jmp @multiplied
//   @eighty_column:    { 80-column mode: it may be faster to perform the }
//    mov cl, 4         {   multiplication via shifts and adds: remember  }
//    shl ax, cl        {   that 80d = 1010000b , so one can SHL 4, copy  }
//    mov dx, ax        {   the result to DX, SHL 2, and add DX in.       }
//    mov cl, 2
//    shl ax, cl
//    add ax, dx
//   @multiplied:
//    add ax, bx        { add X in }
//    shl ax, 1         { multiply by 2 to get offset into video segment }
//    mov di, ax        { video pointer is in DI }
//    lea si, s         { string pointer is in SI }
//    SEGSS lodsb
//    cmp al, 00h       { if zero-length string, jump to end }
//    je @done
//    mov cl, al
//    xor ch, ch        { string length is in CX }
//    pop es            { get video segment back from stack; put in ES }
//    pop ax            { get color back from stack; put in AX (AH = color) }
//   @write_loop:
//    SEGSS lodsb       { get character to write }
//    mov es:[di], ax   { write AX to video memory }
//    inc di            { increment video pointer }
//    inc di
//    loop @write_loop  { if CX > 0, go back to top of loop }
//   @done:             { end }
//  end;
end;

Function WildComp(NameStr,SearchStr: String): Boolean; // assembler;
{
 Compare SearchStr with NameStr, and allow wildcards in SearchStr.
 The following wildcards are allowed:
 *ABC*        matches everything which contains ABC
 [A-C]*       matches everything that starts with either A,B or C
 [ADEF-JW-Z]  matches A,D,E,F,G,H,I,J,W,V,X,Y or Z
 ABC?         matches ABC, ABC1, ABC2, ABCA, ABCB etc.
 ABC[?]       matches ABC1, ABC2, ABCA, ABCB etc. (but not ABC)
 ABC*         matches everything starting with ABC
 (for using with DOS filenames like DOS (and 4DOS), you must split the
  filename in the extention and the filename, and compare them seperately)
}
Var
  LastW,LastNFnd: word;
 
begin

end;

Function Upcasestr(S : String) : String; // Assembler;
begin
end;

Function Locasestr(S : String) : String; // Assembler;
begin
end;

{ Convert a character to upper case }

//function UpCase(c : char); // Assembler;
//begin
//end; { UpCase }

  { Convert a character to lower case }

//function LoCase; // Assembler;
//begin
//end;                                 { LoCase }

Function AnyKeypressed: boolean; { Better function than pascals CRT one! }
begin // adjusted
  AnyKeyPressed := keypressed;
end;

Procedure Scroll(x1,y1,x2,y2,times: byte);
var loop: byte;
begin
  { Move the screen memory }
//  for loop := y1+times+1 to y2 do begin
//    move(mem[VidSeg:pred(loop)*maxwidth*2 + pred(x1)*2],
//      mem[VidSeg:pred(loop-times)*maxwidth*2 + pred(x1)*2],(x2-x1+1)*2);
//  end;

  { Clear the remaining region }
//  for loop := y2-times+1 to y2 do putchars(x1,loop,' ',x2-x1+1);
end;

Procedure SaveScreen(var screen: screensavetype);
Begin
  { If a status lines been used, increase until nolonger there }
//  with screen do Begin
//    getmem(screen,screensize);
//    x := wherex;
//    y := wherey;
//    attr := textattr;
//    Move(ScreenAddr^,Screen^,maxheight * maxwidth * 2);
//  End;
End;

Procedure ShowScreen(var orgscreen: screensavetype);
Begin
//  with orgscreen do Begin
//    Move(Screen^,ScreenAddr^,maxheight*maxwidth*2);
//    gotoxy(x,y);
//    textattr := attr;
//  End;
End;

Procedure RestoreScreen(var orgscreen: screensavetype);
Begin
//  with orgscreen do Begin
//    Move(Screen^,ScreenAddr^,maxheight*maxwidth*2);
//    gotoxy(x,y);
//    textattr := attr;
//    freemem(screen,screensize);
//  End;
End;

Var oe: pointer;
Procedure FinishUp; far;
Begin
//  exitproc := oe;
//  cursoron;
End;

Begin
  { Init the video addresses }
//  if lastmode = 7 then VidSeg := $B000 else VidSeg := $B800;
//  screenaddr := ptr(VidSeg,$0000);

  { Init the video }
//  Maxwidth := succ(lo(windmax));  { Get maximum window positions, which are   }
//  Maxheight := succ(hi(windmax)); { the maxwidth and maxheight to be precise! }
//  ScreenSize := maxheight*maxwidth*2; { For easy references to move commands. }
  
//  GetCursor(OrgCursor);
//  oe := exitproc;
//  exitproc := @finishup; { To restore the cursor }

  { Init the tables for Upcasing }
//  Crp := @CountryRec;
//  Ltp := @LoTable;
//  asm
    { Exit if Dos version < 3.0 }
//    mov     ah, 30h
//    int     21h
//    cmp     al, 3
//    jb      @1
    { Call Dos 'Get extended country information' function }
//    mov     ax, 6501h
//    les     di, CRP
//    mov     bx,-1
//    mov     dx,bx
//    mov     cx,41
//    int     21h
//    jc      @1
    { Call Dos 'Get country dependent information' function }
//    mov     ax, 6502h
//    mov     bx, CountryRec.CodePage
//    mov     dx, CountryRec.CountryID
//    mov     CountryRec.TheInfo.CID, dx
//    mov     cx, 5
//    int     21h
//    jc      @1
    { Build LoCase table }
//    les     di, LTP
//    mov     cx, 80h
//    mov     ax, cx
//    cld
//   @3:
//    stosb
//    inc     ax
//    loop    @3
//    mov     di, offset LoTable - 80h
//    mov     cx, 80h
//    mov     dx, cx
//    push    ds
//    lds     bx, CountryRec.UpCaseTable
//    sub     bx, 7eh
//   @4:
//    mov     ax, dx
//    xlat
//    cmp     ax, 80h
//    jl      @5
//    cmp     dx, ax
//    je      @5
//    xchg    bx, ax
//    mov     es:[bx+di], dl
//    xchg    bx, ax
//   @5:
//    inc     dx
//    loop    @4
//    pop     ds

//    mov     [CountryOk], True
//    jmp     @2
//   @1:
//    mov     [CountryOk], False
//   @2:
//  end;
end.
