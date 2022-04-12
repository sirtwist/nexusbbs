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
  ToggleStatus       : Byte absolute $0040:$0017;
  TimerAddr          : Longint absolute $0040:$006C;
  kbdHeadPtr         : Word absolute $0040:$1A;
  kbdTailPtr         : Word absolute $0040:$1C;
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
Function LoCase(c: Char): Char;
Function LoCaseStr(s: String): String;
Function UpCase(c: Char): Char;
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
Inline($FA);
end;

Procedure STI;
begin
Inline($FB);
end;

Procedure WarmBoot; Assembler;
Asm
  Xor  Ax,Ax
  Mov  Es,Ax
  Mov  Word ptr Es:[472h],1234h
  Mov  Ax,0F000h
  Push Ax
  Mov  Ax,0FFF0h
  Push Ax
  Retf
End;

Procedure ColdBoot; Assembler;
Asm
  Xor  Ax,Ax
  Mov  ES,Ax
  Mov  Word ptr Es:[472h],0000h
  Mov  Ax, 0F000h
  Push Ax
  Mov  Ax,0FFF0h
  Push Ax
  Retf
End;

Procedure CallUserProc(proc: pointer);
begin Inline($FF/$5E/<proc); end;

Procedure SetColor(color,r,g,b: Byte); Assembler;
Asm
  mov  dx, 3C8h   { Color port }
  mov  al, color  { Number of color to change }
  out  dx, al
  inc  dx         { Inc dx to write }
  mov  al, r      { Red value }
  out  dx, al
  mov  al, g      { Green }
  out  dx, al
  mov  al, b      { Blue }
  out  dx, al
End;

Procedure GetColor(Color: byte; var r,g,b: byte); Assembler;
{ This reads the values of the Red, Green and Blue DAC values of a
  certain color and returns them to you in r (red), g (green), b (blue) }
asm
  mov  dx, 3C7h
  mov  al, color
  out  dx, al
  add  dx, 2
  in   al, dx
  les  di, r
  stosb
  in   al, dx
  les  di, g
  stosb
  in   al, dx
  les  di, b
  stosb
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

Procedure SetBorder(color : byte);  assembler;
asm
  mov ax, $1001
  mov bh, color
  int $10
End;

Procedure GetBorder(var color : byte); assembler;
asm
  mov ax, $1008
  int $10
  les DI, color
  mov [ES:DI], bh
end;

Procedure GetCursor(var cursor: word); assembler;
Asm
  mov ah, $03
  int $10
  les di, cursor
  mov [ES:DI], cx
End;

Procedure SetCursor(cursor: word); assembler;
Asm
  mov ah, $01
  mov cx, cursor
  int $10
End;

Procedure CursorOn; assembler;
asm
  mov ah, $01
  mov cx, OrgCursor
  int 10h
end;

Procedure CursorOff; assembler;
asm
  mov ah, $01
  mov cx, $FFFF
  int 10h
end;

Procedure StuffChar(c : char); assembler;
asm
  mov ah, $05
  mov cl, c   { cl = c }
  xor ch, ch  { ch = 0 }
  int $16
end;

Procedure BlinkOff; assembler;
{ Note that the BL is the actual register, but BH _should_ also be set to 0 }
asm
  mov ax, $1003
  mov bx, $0000
  int $10
end;

Procedure BlinkOn; assembler;
{ Note that the BL is the actual register, but BH _should_ also be set to 0 }
asm
  mov ax, $1003
  mov bx, $0001
  int $10
end;

Procedure Retrace; assembler;
{ waits for a vertical retrace }
  asm
    mov dx, $03DA
   @loop1:
    in al, dx
    test al, 8
    jz @loop1
   @loop2:
    in al, dx
    test al, 8
    jnz @loop2
  end;

Procedure UnCrunch(var Addr1,Addr2; BlkLen:Word); assembler;
{ From TheDraw, not my Procedure }
asm
  PUSH    DS             { Save data segment.}
  LDS     SI, Addr1      { Source Address}
  LES     DI, Addr2      { Destination Addr}
  MOV     CX, BlkLen     { Length of block}
  JCXZ    @Done
  MOV     DX,DI          { Save X coordinate for later.}
  XOR     AX,AX          { Set Current attributes.}
  CLD
 @LOOPA:
  LODSB                  { Get next character.}
  CMP     AL,32          { If a control character, jump.}
  JC      @ForeGround
  STOSW                  { Save letter on screen.}
 @Next:
  LOOP    @LOOPA
  JMP     @Done
 @ForeGround:
  CMP     AL,16          { If less than 16, then change the}
  JNC     @BackGround    { foreground color.  Otherwise jump.}
  AND     AH,0F0h        { Strip off old foreground.}
  OR      AH,AL
  JMP     @Next
 @BackGround:
  CMP     AL,24          { If less than 24, then change the}
  JZ      @NextLine      { background color.  If exactly 24,}
  JNC     @FlashBitToggle{ then jump down to next line.}
  SUB     AL,16          { Otherwise jump to multiple output}
  ADD     AL,AL          { routines.}
  ADD     AL,AL
  ADD     AL,AL
  ADD     AL,AL
  AND     AH,8Fh         { Strip off old background.}
  OR      AH,AL
  JMP     @Next
 @NextLine:
  ADD     DX,160         { If equal to 24,}
  MOV     DI,DX          { then jump down to}
  JMP     @Next          { the next line.}
 @FlashBitToggle:
  CMP     AL,27          { Does user want to toggle the blink}
  JC      @MultiOutput   { attribute?}
  JNZ     @Next
  XOR     AH,128         { Done.}
  JMP     @Next
 @MultiOutput:
  CMP     AL,25          { Set Z flag if multi-space output.}
  MOV     BX,CX          { Save main counter.}
  LODSB                  { Get count of number of times}
  MOV     CL,AL          { to display character.}
  MOV     AL,32
  JZ      @StartOutput   { Jump here if displaying spaces.}
  LODSB                  { Otherwise get character to use.}
  DEC     BX             { Adjust main counter.}
 @StartOutput:
  XOR     CH,CH
  INC     CX
  REP STOSW
  MOV     CX,BX
  DEC     CX             { Adjust main counter.}
  LOOPNZ  @LOOPA         { Loop if anything else to do...}
 @Done:
  POP     DS             { Restore data segment.}
end;

Procedure ReallocateMemory(P : Pointer); Assembler;
Asm
  Mov  AX, PrefixSeg
  Mov  ES, AX
  Mov  BX, word ptr P+2
  Cmp  Word ptr P,0
  Je   @OK
  Inc  BX
 @OK:
  Sub  BX, AX
  Mov  AH, $4A
  Int  $21
  Jc   @Out
  Les  DI, P
  Mov  Word Ptr HeapEnd,DI
  Mov  Word Ptr HeapEnd+2,ES
 @Out:
End;

Function Execute(Name, tail : pathstr) : Word; Assembler;
Asm
  Push Word Ptr HeapEnd+2
  Push Word Ptr HeapEnd
  Push Word Ptr Name+2
  Push Word Ptr Name
  Push Word Ptr Tail+2
  Push Word Ptr Tail
  Push Word Ptr HeapPtr+2
  Push Word Ptr HeapPtr
  Call ReallocateMemory
  Call SwapVectors
  Call Dos.Exec
  Call SwapVectors
  Call ReallocateMemory
  Mov  AX, DosError
  Or   AX, AX
  Jnz  @Done
  Mov  AH, $4D
  Int  $21 { Return error in will be in AX (if any) }
 @Done:
End;

Procedure Putchars(x, y : byte; chr : char; times : word);
{ Procedure to fill a count amount of characters from position x, y }
var offst: word;
begin
  offst := (pred(y)*maxwidth+pred(x))*2;
  asm
    mov es, VidSeg    { Segment to start at       }
    mov di, offst     { Offset to start at        }
    mov al, chr       { Data to place             }
    mov ah, textattr  { Colour to use             }
    mov cx, times     { How many times            }
    cld               { Forward in direction      }
    rep stosw         { Store the word (cx times) }
  end;
end;

Procedure PutAttrs(x,y: byte; times: word);
{ This Procedure is to fill a certain amount of spaces with a colour       }
{ (from cursor position) and doesn't move cursor position!                 }
var offst: word;
begin
  offst := succ((pred(y)*maxwidth+pred(x))*2);
  asm
    mov es, VidSeg
    mov di, offst
    mov cx, times
    mov ah, 0
    mov al, textattr
    cld
   @s1:
    stosb
    inc di    { Increase another above what the stosb already loops }
    loop @s1  { Loop until cx = 0                                   }
  end;
end;

Procedure PutString(x, y: byte; s: string);
Begin
  { Does a direct video write -- extremely fast. }
  asm
    mov dh, y         { move X and Y into DL and DH (DX) }
    mov dl, x

    xor al, al
    mov ah, textattr  { load color into AH }
    push ax           { PUSH color combo onto the stack }

    mov ax, VidSeg
    push ax           { PUSH video segment onto stack }

    mov bx, 0040h     { check 0040h:0049h to get number of screen columns }
    mov es, bx
    mov bx, 004Ah
    xor ch, ch
    mov cl, es:[bx]
    xor ah, ah        { move Y into AL; decrement to convert Pascal coords }
    mov al, dh
    dec al
    xor bh, bh        { shift X over into BL; decrement again }
    mov bl, dl
    dec bl
    cmp cl, 80        { see if we're in 80-column mode }
    je @eighty_column
    mul cx            { multiply Y by the number of columns }
    jmp @multiplied
   @eighty_column:    { 80-column mode: it may be faster to perform the }
    mov cl, 4         {   multiplication via shifts and adds: remember  }
    shl ax, cl        {   that 80d = 1010000b , so one can SHL 4, copy  }
    mov dx, ax        {   the result to DX, SHL 2, and add DX in.       }
    mov cl, 2
    shl ax, cl
    add ax, dx
   @multiplied:
    add ax, bx        { add X in }
    shl ax, 1         { multiply by 2 to get offset into video segment }
    mov di, ax        { video pointer is in DI }
    lea si, s         { string pointer is in SI }
    SEGSS lodsb
    cmp al, 00h       { if zero-length string, jump to end }
    je @done
    mov cl, al
    xor ch, ch        { string length is in CX }
    pop es            { get video segment back from stack; put in ES }
    pop ax            { get color back from stack; put in AX (AH = color) }
   @write_loop:
    SEGSS lodsb       { get character to write }
    mov es:[di], ax   { write AX to video memory }
    inc di            { increment video pointer }
    inc di
    loop @write_loop  { if CX > 0, go back to top of loop }
   @done:             { end }
  end;
end;

Function WildComp(NameStr,SearchStr: String): Boolean; assembler;
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
Asm
  cld               { Set flag: go forward through strings }
  push ds           { Save TP's datasegment }
  lds si,SearchStr  { Load pointer to SearchStr (may contain wildcards) }
  les di,NameStr    { Load pointer to NameStr }
  xor ah,ah
  lodsb             { Load length of SearchStr, and increment pointer }
  mov cx,ax         { Store in cx }
  mov al,es:[di]    { Load length of NameStr }
  inc di            { Increment pointer }
  mov bx,ax         { Store length in bx }
  xor dh,dh         { Clear searching flag }
  mov LastNFnd,0    { Set no saved position }
  or cx,cx          { SearchStr empty? }
  jnz @ChkChr       { No -> Get next char }
  or bx,bx          { NameStr empty? }
  jz @ChrAOk        { Yes (both empty) -> compare ok }
  jmp @ChrNOk       { Jump to compare failed }
  { Following the main loop }
  { Registers in loop: }
  { AH    - various }
  { AL    - current char from SearchStr }
  { BX    - Chars left in NameStr }
  { CX    - Chars left in SearchStr }
  { DH    - Flag: 1=Searching in progress) }
  { DL    - Flag: 1=first char was ! in [...] }
  { DS:SI - Pointer to next char in SearchStr }
  { ES:DI - Pointer to current char in NameStr }
  @ChkChr:
  lodsb             { Get char from SearchStr, and increment pointer }
  cmp al,'*'        { Is it a '*'? }
  jne @ChkVrg       { No -> check for '?' }
  dec cx            { Decrement SearchStr counter, and check for }
  jz @ChrAOk        { chars left, No -> compare ok }
  mov dh,1          { Set flag ??? }
  mov LastW,cx      { Save chars left in SearchStr }
  mov LastNFnd,0    { Set no saved position }
  jmp @ChkChr       { Check next char in SearchStr }
  @ChkVrg:
  cmp al,'?'        { Is it a '?' ? }
  jnz @NormChr      { No -> check for set ('[') }
  inc di            { Increment pointer NameStr (always ok) }
  or bx,bx          { NameStr already empty? }
  je @ChrOk         { Yes -> this char ok }
  dec bx            { Decrement NameStr counter }
  jmp @ChrOk        { Jump to this char ok }
  @NormChr:
  or bx,bx          { NameStr already empty? }
  je @ChrNOk        { Yes -> compare failed }
  cmp al,'['        { Is it a set ('[') }
  jne @No4DosChr    { No -> normal char compare }
  cmp word ptr [si],']?' { Is it a 'need char' ('[?]')? }
  je @SkipRange     { Yes -> No set check }
  mov ah,byte ptr es:[di]  { Store current char in NameStr }
  xor dl,dl         { Set flag normal set }
  cmp byte ptr [si],'!'    { Is it a 'not' set (first char '!')? }
  jnz @ChkRange     { No -> a normal set }
  inc si            { Set to next char in SearchStr }
  dec cx            { Decrement counter }
  jz @ChrNOk        { SearchStr empty? Yes -> compare failed }
  inc dx            { Set flag 'not' set }
  { Following the check set loop }
  { AH - Char from NameStr, checked if in set }
  { Rest same as mainloop }
  @ChkRange:
  lodsb             { Get char from SearchStr }
  dec cx            { Decrement counter }
  jz @ChrNOk        { SearchStr empty? Yes -> compare failed }
  cmp al,']'        { End of set reached ? }
  je @NChrNOk       { Yes -> Char not found in set }
  cmp ah,al         { Char in set ? }
  je @NChrOk        { Yes -> Char found in set }
  cmp byte ptr [si],'-' { Range of chars ? }
  jne @ChkRange     { No? -> Check next char }
  inc si            { Increment pointer SearchStr }
  dec cx            { Decrement SearchStr chars left }
  jz @ChrNOk        { Empty? Yes -> compare failed }
  cmp ah,al         { Compare first char from range with char from NameStr } 
  jae @ChkR2        { Is it higher or equal? Yes -> check last range char } 
  inc si            { Char not in range }
  dec cx            { Skip last in range }
  jz @ChrNOk        { SearchStr empty? Yes -> compare failed }
  jmp @ChkRange     { Check next char of set }
  @ChkR2:
  lodsb             { Get last range char }
  dec cx            { Decrement SearchStr chars left }
  jz @ChrNOk        { Empty? Yes -> compare failed }
  cmp ah,al         { Compare last char from range with char from NameStr } 
  ja @ChkRange      { In range? Yes -> check next char from set } 
  { Fall through to Char in set }
  @NChrOk:          { Char in set }
  or dl,dl          { 'not' flag set? }
  jnz @ChrNOk       { Yes -> compare failed }
  inc dx            { Set 'not' flag }
  { Fall through to Char not in set, but with 'not' flag set -> chr found } 
  @NChrNOk:         { Char not in set }
  or dl,dl          { 'not' flag set? }
  jz @ChrNOk        { No -> compare failed }
  @NNChrOk:         { Char in set }
  cmp al,']'        { This was the set terminate char (']')? }
  je @NNNChrOk      { Yes -> No need to skip to end of set }
  @SkipRange:       { Skip to end of set }
  lodsb             { Get char from SearchStr }
  cmp al,']'        { Set termination char (']')? }
  loopne @SkipRange { No -> repeat until found or out of chars }
  jne @ChrNOk       { Not found? -> out of chars -> compare failed }
  @NNNChrOk:
  dec bx            { Decrement NameStr chars left }
  inc di            { Increment NameStr pointer }
  jmp @ChrOk        { This char was ok }
  @No4DosChr:
  cmp es:[di],al    { Normal compare }
  jne @ChrNOk       { Not equal? -> compare failed }
  inc di            { Decrement NameStr chars left }
  dec bx            { Increment NameStr pointer }
  @ChrOk:           { This char was ok }
  or dh,dh          { Search in progress? }
  jz @NoStore       { No -> Skip Last found store }
  xor dh,dh         { Clear search flag: found a matching char }
  mov LastNFnd,bx   { Save last found char pos }
  @NoStore:
  dec cx            { Decrement SearchStr chars left }
  jnz @ChkChr       { Empty? No -> Process new char }
  or bx,bx          { NameStr empty? }
  jnz @ChrNOk       { No -> compare failed }
  @ChrAOk:          { Whole string compared ok }
  mov al,1          { Return true }
  jmp @EndR         { Jump to end of Procedure }
  @ChrNOk:          { Somewhere was a mismatch }
  jcxz @IChrNOk     { Because of empty SearchStr? Yes -> fail }
  or bx,bx          { Because of empty NameStr? }
  jz @IChrNOk       { Yes -> fail }
  or dh,dh          { Search in progress? }
  jz @WCNotOk       { No -> Check for second+ char search mismatch }
  inc di            { This char not the one searching for }
  dec bx            { Skip it (dec NameStr left, inc NameStr ptr) }
  jz @IChrNOk       { NameStr empty? Yes -> fail }
  @Retry:           { Start search again }
  mov ax,[LastW]    { Get pos in SearchStr after last '*' }
  sub ax,cx         { Restore state of }
  add cx,ax         { SearchStr char left counter }
  sub si,ax         { and SearchStr pointer }
  dec si            { Adjust pointer }
  jmp @ChkChr       { Get new char }
  @WCNotOk:         { Check for second+ char search mismatch }
  mov ax,LastNFnd   { Get position of last good char in NameStr }
  or ax,ax          { No saved position? }
  jz @IChrNOk       { Yes -> fail }
  mov LastNFnd,0    { Set no saved position }
  sub ax,bx         { Restore state of }
  add bx,ax         { NameStr char left counter }
  sub di,ax         { and NameStr pointer }
  mov dh,1          { Set search in progress flag }
  jmp @Retry        { And restore SearchStr }
  @IChrNOk:         { Compare failed }
  mov al,0          { Return false }
  @EndR:
  pop ds            { Restore TP's datasegment }
end;

Function Upcasestr(S : String) : String; Assembler;
Asm
  Push    DS
  Lds     SI,S
  Les     DI,@Result
  Cld
  LodSb
  StoSb
  Xor     CH,CH
  Mov     CL,AL
  JCXZ    @OUT
 @LOOP:
  LODSB
  xor ah, ah
  push ax
  call upcase
  StoSb
  Loop    @Loop
 @OUT:
  POP   DS
end;

Function Locasestr(S : String) : String; Assembler;
Asm
  PUSH    DS
  LDS     SI,S
  LES     DI,@Result
  CLD
  LODSB
  STOSB
  xor     CH,CH
  MOV     CL,AL
  JCXZ    @OUT
 @LOOP:
  LODSB
  xor ah, ah
  push ax
  call locase { So we're not duping a lot of instructions }
  STOSB
  LOOP    @LOOP
 @OUT:
  POP   DS
end;

{ Convert a character to upper case }

function UpCase; Assembler;
asm
  mov     al, c
  cmp     al, 'a'
  jb      @2
  cmp     al, 'z'
  ja      @1
  sub     al, ' '
  jmp     @2
 @1:
  cmp     al, 80h
  jb      @2
  sub     al, 7eh
  push    ds
  lds     bx,CountryRec.UpCaseTable
  xlat
  pop     ds
 @2:
end; { UpCase }

  { Convert a character to lower case }

function LoCase; Assembler;
asm
  mov     al, c
  cmp     al, 'A'
  jb      @2
  cmp     al, 'Z'
  ja      @1
  or      al, ' '
  jmp     @2
 @1:
  cmp     al, 80h
  jb      @2
  sub     al, 80h
  mov     bx,offset LoTable
  xlat
 @2:
end;                                 { LoCase }

Function AnyKeypressed: boolean; { Better function than pascals CRT one! }
begin
  AnyKeyPressed := ((mem[$40:$17] and $0F)>0) or (mem[$40:$18]>0) or keypressed;
end;

Procedure Scroll(x1,y1,x2,y2,times: byte);
var loop: byte;
begin
  { Move the screen memory }
  for loop := y1+times+1 to y2 do begin
    move(mem[VidSeg:pred(loop)*maxwidth*2 + pred(x1)*2],
      mem[VidSeg:pred(loop-times)*maxwidth*2 + pred(x1)*2],(x2-x1+1)*2);
  end;

  { Clear the remaining region }
  for loop := y2-times+1 to y2 do putchars(x1,loop,' ',x2-x1+1);
end;

Procedure SaveScreen(var screen: screensavetype);
Begin
  { If a status lines been used, increase until nolonger there }
  with screen do Begin
    getmem(screen,screensize);
    x := wherex;
    y := wherey;
    attr := textattr;
    Move(ScreenAddr^,Screen^,maxheight * maxwidth * 2);
  End;
End;

Procedure ShowScreen(var orgscreen: screensavetype);
Begin
  with orgscreen do Begin
    Move(Screen^,ScreenAddr^,maxheight*maxwidth*2);
    gotoxy(x,y);
    textattr := attr;
  End;
End;

Procedure RestoreScreen(var orgscreen: screensavetype);
Begin
  with orgscreen do Begin
    Move(Screen^,ScreenAddr^,maxheight*maxwidth*2);
    gotoxy(x,y);
    textattr := attr;
    freemem(screen,screensize);
  End;
End;

Var oe: pointer;
Procedure FinishUp; far;
Begin
  exitproc := oe;
  cursoron;
End;

Begin
  { Init the video addresses }
  if lastmode = 7 then VidSeg := $B000 else VidSeg := $B800;
  screenaddr := ptr(VidSeg,$0000);

  { Init the video }
  Maxwidth := succ(lo(windmax));  { Get maximum window positions, which are   }
  Maxheight := succ(hi(windmax)); { the maxwidth and maxheight to be precise! }
  ScreenSize := maxheight*maxwidth*2; { For easy references to move commands. }
  
  GetCursor(OrgCursor);
  oe := exitproc;
  exitproc := @finishup; { To restore the cursor }

  { Init the tables for Upcasing }
  Crp := @CountryRec;
  Ltp := @LoTable;
  asm
    { Exit if Dos version < 3.0 }
    mov     ah, 30h
    int     21h
    cmp     al, 3
    jb      @1
    { Call Dos 'Get extended country information' function }
    mov     ax, 6501h
    les     di, CRP
    mov     bx,-1
    mov     dx,bx
    mov     cx,41
    int     21h
    jc      @1
    { Call Dos 'Get country dependent information' function }
    mov     ax, 6502h
    mov     bx, CountryRec.CodePage
    mov     dx, CountryRec.CountryID
    mov     CountryRec.TheInfo.CID, dx
    mov     cx, 5
    int     21h
    jc      @1
    { Build LoCase table }
    les     di, LTP
    mov     cx, 80h
    mov     ax, cx
    cld
   @3:
    stosb
    inc     ax
    loop    @3
    mov     di, offset LoTable - 80h
    mov     cx, 80h
    mov     dx, cx
    push    ds
    lds     bx, CountryRec.UpCaseTable
    sub     bx, 7eh
   @4:
    mov     ax, dx
    xlat
    cmp     ax, 80h
    jl      @5
    cmp     dx, ax
    je      @5
    xchg    bx, ax
    mov     es:[bx+di], dl
    xchg    bx, ax
   @5:
    inc     dx
    loop    @4
    pop     ds

    mov     [CountryOk], True
    jmp     @2
   @1:
    mov     [CountryOk], False
   @2:
  end;
end.
