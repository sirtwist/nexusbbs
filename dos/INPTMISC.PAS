{$A+,B-,D-,E+,F-,G-,I-,L+,N-,O-,R-,S+,V+,X+}
{$M 16384,0,655360}
Unit InptMisc; { by John Stephenson; Copyright 1995 }

Interface
uses dos,crt,
     Asmmisc,Boxes,KeyMisc,Mouse,StrMisc;
Const
  Normal  = 1;
  Capital = 2;
  Name    = 3;
  Secret  = 4;
  Number  = 5;

Type
  Colorstype = record
    Border,
    Maintext,
    HighLightedText,
    Entrytext,
    Shadow: byte;
  end;

Const { For ExplodingMenu.AddChoice }
  None = 0;
  Unavail = 1;
  LineType = 2;
  UnAccessable = 3;
  QuitType = 4;

Type
  pMenuChoices = ^tMenuChoices;

  pChoices = ^tChoices;
  tChoices = record
    hotkey: char;
    desc: ^String;
    attr,
    hilight: byte;
    Next: pChoices;
  End;

  tMenuChoices = object
    TotalChoices: integer;
    Head,
    Choices: pChoices;

    Constructor Init;
    Procedure AddChoice(hk: char; ds: string; atr: byte);
    Procedure SetChoice(ctc: integer; hk: char; ds: string; atr: byte);
    Procedure GetChoice(ctc: integer; var hk: char; var ds: string; var atr: byte);
    Destructor Done;
  end;

  ExplodingMenu = object(tMenuChoices)
    StartChoices,     { Where, relative to the box, do the choices start }
    EndChoices: byte; { Where, relative to the start, do the choices end }

    Place,            { Place in scrollable menu list }
    Choice,lastchoice: integer;
    Quit,Select: boolean;

    CallOnMove: Pointer;

    StartX,StartY,LenX,LenY,
    MShadow,
    BorderColor,
    TitleColor,
    MenuColor,HighlightMenuColor,
    BarColor,HighlightBarColor: byte;
    Unavailcolor,
    Unavailbarcolor,
    CharsColor,
    IconColor: byte;
    Title: String;

    Menu: ExplodingBox;

    MoreUp,MoreDown,
    LeftChar,RightChar: char;

    { 0 for "wy" will auto size it to menu choices and start choices }
    Constructor Init(_x,_y,wx,wy: byte; tit: string);
    Procedure SetColors(borderc,titlec,menuc,himenuc,barc,hbarc,shdw: byte);
    { Normally done by ProcessInput, but acceptable to call elsewise }
    Procedure DrawBox;
    Procedure ProcessInput;
    Procedure Update;
    Destructor Done;

    Private
      BoxOnScreen: boolean;
  End;

Const
  BackSpaceChar : char = ' ';
  WriteEnter: boolean = true;
  WrapInput: boolean = false;
  AllowEsc: Boolean = true;

  DefaultColors: colorstype =
   (border:cyan;
    Maintext:lightgray;
    HighLightedText:white+blue;
    entrytext:white+blue;
    shadow:darkgray);

  BlueColors: colorstype =
   (border:_blue+lightblue;
    maintext:_blue+lightcyan;
    HighLightedText:_blue+white;
    entrytext:_lightgray+black;
    shadow:darkgray);

  RedColors: colorstype =
   (border:_red+lightred;
    maintext:_red+white;
    HighLightedText:_red+white;
    entrytext:_lightgray+black;
    shadow:darkgray);

  GreenColors: colorstype =
   (border:_green+lightgreen;
    maintext:_green+white;
    HighLightedText:_green+white;
    entrytext:_lightgray+black;
    shadow:darkgray);

Var
  ColorCfg: ColorsType;

Function AnyKeypressed: boolean;
Function CapInput(len: byte; default: String): String;
Function GetColor(sx,sy,tattr: byte; sample:string ): byte;
Function GetYn(xs,ys: byte; st: String; yes: boolean): boolean;
Function NameInput(len: byte; default: String): String;
Function NormalInput(len: byte; default: String): String;
Function NumInput(len: byte; default: String): String;
Function SecretInput(len: byte; default: String): String;
Function FromUnixDate(s: String): Longint; { UNIX date to normal date }
Function ToUnixDate(fdate: LongInt): String;
Procedure GregorianToJulian(Year, Month, Day : word; Var Julian : LongInt);
Procedure JulianToGregorian(Julian: LongInt; Var Year,Month,Day: Word);

Procedure WaitKey;
Procedure WaitInput(ms: word);
Procedure GetString(y: byte; txt: String; var st: String; wlen,typeinput: byte);
Procedure BGetNumber(y: byte; txt: String; var num: byte; low,high: byte); { byte }
Procedure IGetNumber(y: byte; txt: String; var num: integer; low,high: integer); { integer }
Procedure LGetNumber(y: byte; txt: String; var num: longint; low,high: longint); { longint }
Procedure Blip;

Implementation

Const
  Insrt: boolean = true;

Function AnyKeypressed: boolean;
Var temp: boolean;
begin
  if kpi <> nil then calluserproc(kpi);
  if mouseinstalled then temp := asmmisc.anykeypressed or mousepressed or (touchres <> '')
  else temp := asmmisc.anykeypressed or (touchres <> '');

  if kpe <> nil then calluserproc(kpi);
  if temp then begin
    anykeypressed := true;
    if kpe <> nil then calluserproc(kpi);
  end
  else anykeypressed := false;
end;

Procedure blip;
begin
  sound(1000);  delay(15);
  sound(2500);  delay(7);
  nosound;      delay(3);
End; { End blip }

Procedure InputDrv(var tline: string; len: byte; name,showit,allcap,numinput: boolean);
{ This procedure is not designed to be called directly, use Capinput,
  NormalInput, NameInput, and SecretInput to get input with }
var
  ch: char;
  loop,i,j,place: byte;
  temp,rtemp: String;
  Quit: Boolean;
  Cursor: word;
begin
  Getcursor(cursor);
  if insrt then setcursor(1543)
  else setcursor(8);
  Quit := False;
  touchres := touchres+tline;
  tline := '';
  place := 1; { Place of character in relation to String }
  repeat
    ch := readkey;

    if name then begin
      if place = 1 then ch := upcase(ch)
      else if tline[place - 1] = #32 then ch := upcase(ch);
    End;
    if allcap then ch := upcase(ch);
    if (numinput and (ch in [#0,#8,#13,#25,#27,'0'..'9','-','+',':','/','.'])) or not numinput then
    case ch of
      #0: begin
        ch := readkey;
        case ch of
          _home: begin
            if place-1 <> 0 then gotoxy(wherex-(place-1),wherey);
            place := 1;
          End;
          _end: begin
            if length(tline)-place+1<>0 then gotoxy(wherex+(length(tline)-place+1),wherey);
            place := byte(tline[0])+1;
          End;
          _left: begin
            if place <> 1 then begin
              dec(place);
              gotoxy(wherex-1,wherey);
            End;
          End;
          _right: begin
            if place<byte(tline[0])+1 then begin
              inc(place);
              gotoxy(wherex+1,wherey);
            End;
          End;
          _insert: begin
            insrt := not insrt;
            if insrt then setcursor(1543)
            else setcursor(8);
          end;
          _delete: begin
            if place<byte(tline[0])+1 then begin
              Delete(tline,place,1);
              { Rewrite that part of the line + the delete character to }
              { erase the last character on the screen }
              if showit then write(copy(tline,place,255)+Backspacechar)
              else write(dup('.',byte(tline[0])-place+1)+Backspacechar);
              { Go over to the starting place, plus lone more for the now }
              { deleted character }
              gotoxy(wherex-(byte(tline[0])-place+1+1),wherey);
            End;
          End;
        End;
      End;

      #8: if place <> 1 then begin
        if place = byte(tline[0]) + 1 then begin
          dec(tline[0]);
          write(#8+Backspacechar+#8);
          dec(place);
        end
        else begin
          dec(place);
          Delete(tline,place,1);
          { Go over to where we're deleting }
          gotoxy(wherex-1,wherey);
          { Rewrite that part of the line + the delete character to }
          { erase the last character on the screen }
          if showit then write(copy(tline,place,255)+Backspacechar)
          else write(dup('.',length(copy(tline,place,255)))+Backspacechar);
          { Go over to the starting place }
          gotoxy(wherex-length(copy(tline,place,255)+Backspacechar),wherey);
        End;
      End;
      #25: if tline[0] <> #0 then begin { ClrLine }
        gotoxy(wherex-(place-1),wherey);
        write(dup(backspacechar,length(tline)));
        gotoxy(wherex-length(tline),wherey);
        tline := '';
        place := 1;
      End;
      #27: if AllowEsc then quit := true;
      #1..#31:;
      { Normal character detected }
      else begin
        if (length(tline) <> len) or ((not insrt) and (place-1 <> len)) then begin
          { If it's at the end of the line }
          if place = length(tline)+1 then begin
            if showit then write(ch)
            else write('.');
            tline := tline + ch;
            inc(place);
          end
          { They must be half way through it then }
          else begin
            if not insrt then begin
              if showit then write(ch)
              else write('.');
              tline[place] := ch;
              inc(place);
            end
            else begin
              insert(ch,tline,place);
              if showit then write(copy(tline,place,255))
              else write(dup('.',length(copy(tline,place,255))));
              { Go over to the starting place }
              gotoxy(wherex-(length(copy(tline,place,255))-1),wherey);
              inc(place);
            End;
          End;
        end
        { End of line, and can't write any more.. }
        else begin
          if not WrapInput then blip
          { Then we should wrap it! }
          else begin
            temp[0] := #0;
            rtemp[0] := #0;
            loop := byte(tLine[0]);
            { Check for a space in the line }
            if pos(#32,tLine) <> 0 then begin
              while (tLine[loop] <> #32) do begin
                write(#8+backspacechar+#8); { Delete character }
                temp := temp + tLine[loop];
                dec(loop);
                dec(tline[0]);
              End;
              { If no space then cut the line short }
              { Reverse what's in Temp }
              if temp[0] <> #0 then for loop := byte(temp[0]) downto 1 do rtemp := rtemp + temp[loop];
            End;
            touchres := touchres + rtemp + ch;
            ch := #13;
          End;
        End;
      End;
    End; { Case structure }
  until (ch = #13) or quit;
  if quit then tline := '';
  if writeenter then writeln('');
  Setcursor(cursor);
End; { End Inputdrv }

Function SecretInput(len: byte; default: String): String;
begin
  InputDrv(default,len,false,false,false,false);
  SecretInput := default;
End;

Function NameInput(len: byte; default: String): String;
begin
  InputDrv(default,len,true,true,false,false);
  NameInput := default;
End;

Function NormalInput(len: byte; default: String): String;
begin
  InputDrv(default,len,false,true,false,false);
  NormalInput := default;
End;

Function CapInput(len: byte; default: String): String;
begin
  InputDrv(default,len,false,true,true,false);
  CapInput := default;
End;

Function NumInput(len: byte; default: String): String;
begin
  InputDrv(default,len,false,true,false,true);
  NumInput := default;
End;

function mln(s:string; l:integer):string;
begin
  while (length(s)<l) do s:=s+' ';
  if (length(s)>l) then
        s:=copy(s,1,l);
  mln:=s;
end;

Function GetColor(sx,sy,tattr: byte; sample:string): byte;
var
  choicebox: explodingbox;
  i,j: byte;
  quit: byte;
  ch: char;
  x,y,
  oldx,oldy: byte;
  attr: byte;
  cursor: word;
  button,
  mx,my,
  oldmx,oldmy,
  diffy,diffx: word;
const
  xmax = 32;
  ymax = 8;
begin
  getcursor(cursor);
  cursoroff;
  with choicebox do begin
    with colorcfg do begin;
      init(sx,sy,36,14,4,' ',cyan,white,5,shadow);
      textout(2,1,'Choose color from chart');
      putheader(' Color Selection ',(yellow or (blue shl 4)));
      putfooter(' Enter to Select ',(yellow or (blue shl 4)));
    end;

    for i := 1 to 8 do begin
      for j := 1 to 16 do begin
        textattr := (i-1) shl 4+(j-1);
        textout(1+j,i+2,'þ');
      End;
      for j := 1 to 16 do begin
        textattr := (i-1) shl 4+(j-1) or $80;
        textout(1+16+j,i+2,'þ');
      End;
    End;
  End;

  mx := 80;
  my := 80;
  oldmy := my;
  oldmx := mx;
  if mouseinstalled then Setmousepos(mx,my);

  quit := 0;
  oldx := 0;
  oldy := 0;
  {x := (tattr and $F)+1;
  if tattr and $80 = $80 then inc(x,$10);
  y := ((tattr and $7F) shr 4)+1;}
  x:= (tattr and 7)+1;
  if (tattr and 8)<>0 then inc(x,8);
  if (tattr and 128)<>0 then inc(x,16);
  y:=((tattr shr 4) and 7)+1;
  repeat
    if (x <> oldx) or (y <> oldy) then begin
      if x > xmax then x := 1;
      if y > ymax then y := 1;
      if x < 1 then x := xmax;
      if y < 1 then y := ymax;

      textattr := ColorCfg.Maintext;
      { Erase the old arrows }
      choicebox.textout(oldx+1,2,' ');
      choicebox.textout(1,2+oldy,' ');

      { Draw the new ones }
      choicebox.textout(x+1,2,#25);
      choicebox.textout(1,2+y,#26);

      attr := ((x-1) and $F) or ((y-1) shl 4);
      if (x-1) and $10 = $10 then inc(attr,blink);

      textattr := attr;
      choicebox.textout(2,12,mln(sample,31));
      oldx := x;
      oldy := y;
    End;

    if keypressed then begin
      ch := upcase(readkey);
      case ch of
        #0: begin
          ch := readkey;
          case ch of
            _home    :x:=1;
            _end     :x:=xmax;
            _up      :dec(y);
            _down    :inc(y);
            _right   :inc(x);
            _left    :dec(x);
            _pageup  :y:=1;
            _pagedown:y:=ymax;
            else blip;
          End;
        End;
        #13,#32: quit := 1;
        #27: quit := 2;
        else blip;
      End;
    End;

    If mouseinstalled then begin
      GetMousePos(mx,my,button);
      If (mx <> oldmx) or (my <> oldmy) then begin
        if kpe <> nil then calluserproc(kpe);

        { Half sensitivity per space }
        diffy := abs(integer(my) - integer(oldmy)) div 8 div 2;
        diffx := abs(integer(mx) - integer(oldmx)) div 8 div 2;
        if (diffx <> 0) or (diffy <> 0) then begin
          if my < oldmy then dec(y,diffy);
          if my > oldmy then inc(y,diffy);
          if mx < oldmx then dec(x,diffx);
          if mx > oldmx then inc(x,diffx);
          mx := 80;
          my := 80;
          Setmousepos(mx,my);
          oldmy := my;
          oldmx := mx;
        End;
      end;

      If button > 0 then begin
        if kpe <> nil then calluserproc(kpe);

        If button = leftb then quit := 1
        Else if button = rightb then quit := 2
        Else begin
          blip;
          repeat until not mousepressed;
        End;
      End;
    End;

  Until (quit <> 0) and ((not mouseinstalled) or (not mousepressed));
  choicebox.done(3);
  case quit of
    1: getcolor := attr;
    2: getcolor := tattr;
  End;
  setcursor(cursor);
End;

Procedure GetString(y: byte; txt: String; var st: String; wlen,typeinput: byte);
{ To get a string of maximum length "wlen", at y position "y" with the      }
{ description "txt", into the variable "st" using the type of input         }
{ "typeinput".  And in addition center the box.. phew!                      }
Var
  Popup: explodingbox;
  Boxlen,len: integer;
  Cursor: word;
Begin
  getcursor(cursor);
  If wlen = 0 then wlen := 255;

  { 2 is for the spaces at the sides }
  Boxlen := 4+length(txt)+wlen;

  { 2 is for the box sides }
  If boxlen+2 > maxwidth then boxlen := maxwidth-2;

  { The length of the string }
  Len := boxlen-(4+length(txt));
  If len < 0 then len := wlen;

  Cursoroff;
  with colorcfg do
    Popup.init((maxwidth div 2)-(boxlen div 2)+1,y,boxlen,3,4,' ',border,maintext,5,shadow);
  Popup.textout(2,1,txt);
  Cursoron;

  Textattr := colorcfg.entrytext;
  Popup.FillAttr(len);

  Case typeinput of
    Name:    st := nameinput(len,st);
    Normal:  st := normalinput(len,st);
    Capital: st := capinput(len,st);
    Number:  st := numinput(len,st);
    Secret:  st := secretinput(len,st);
  End;

  Cursoroff;
  Popup.done(3);
  Setcursor(cursor);
End;

Procedure LGetNumber(y: byte; txt: String; var num: longint; low,high: longint);
var
  numbr: String;
  temp: String;
  code: integer;
  len: byte;
begin
  str(num,numbr);
  str(high,temp);
  len := length(temp);
  repeat
    GetString(y,txt,numbr,len,number);
    Val(numbr,num,code);
  until (code = 0) and (num >= low) and (num <= high);
end;

Procedure BGetNumber(y: byte; txt: String; var num: byte; low,high: byte); { byte }
var ltemp: longint;
begin
  ltemp := num;
  LGetNumber(y,txt,ltemp,low,high);
  num := ltemp;
end;

Procedure IGetNumber(y: byte; txt: String; var num: integer; low,high: integer); { integer }
var ltemp: longint;
begin
  ltemp := num;
  LGetNumber(y,txt,ltemp,low,high);
  num := ltemp;
end;

Function GetYn(xs,ys: byte; st: String; yes: boolean): boolean;
Var
  _Quit: boolean;
  Popup: explodingbox;
  _oy,_Yes: boolean;
  Ch: char;
  Cursor: Word;
  Mx,My,Button: Word;
Begin
  Getcursor(cursor);
  Cursoroff;
  With popup do begin
    _Quit := false;
    _Yes := yes;
    _Oy := not _yes;
    with colorcfg do Init(xs,ys,7+length(st),3,4,' ',border,maintext,5,shadow);
    Textout(2,1,st);
    Repeat
      if _oy <> _yes then begin
        Textattr := colorcfg.entrytext;
        If _yes then textout(length(st)+2,1,'Yes')
        Else textout(length(st)+2,1,'No ');
        _oy := _yes;
      End;

      If keypressed then begin
        Ch := upcase(readkey);
        Case ch of
          #13,#27: _quit := true;
          'Y': begin _yes := true; _quit := true; End;
          'N': begin _yes := false; _quit := true; End;
          #0:;
          Else _yes := not _yes;
        End;
      End;

      If mouseinstalled then begin
        GetMousePos(mx,my,button);
        If button <> 0 then begin
          if kpe <> nil then calluserproc(kpe);
          If button = leftb then _quit := true
          Else if button = rightb then _yes := not _yes
          Else if button = middleb then _yes := not _yes
          Else blip;
        End;
        repeat until not mousepressed;
      End;
    Until _quit;
    Done(3);
  End;

  If ch <> #27 then getyn := _yes
  Else getyn := yes;
  Setcursor(cursor);
End;

Procedure WaitKey;
begin
  repeat until anykeypressed;
  while keypressed do readkey;
  if mouseinstalled then repeat until not mousepressed;
end;

Procedure WaitInput(ms: word);
Var
  I: word;
Begin
  I := ms div 10;
  Repeat
    Delay(10);
    Dec(i);
  Until (i=0) or anykeypressed;
  if mouseinstalled then repeat until not mousepressed;
End;

Constructor tMenuChoices.Init;
begin
  TotalChoices := 0;
  Choices := nil;
end;

Procedure tMenuChoices.AddChoice(hk: char; ds: string; atr: byte);
begin
  inc(totalchoices);
  if totalchoices = 1 then begin
    new(head);
    choices := head;
  end
  else begin
    { Get to the end }
    while choices^.next <> nil do choices := choices^.next;

    new(choices^.next);
    choices := choices^.next;
  end;

  with choices^ do begin
    hotkey := hk;
    getmem(desc,length(ds)+1);
    desc^ := ds;
    attr := atr;
    hilight := pos(hotkey,desc^);
    next := nil;
  end;
end;

Procedure tMenuChoices.SetChoice(ctc: integer; hk: char; ds: string; atr: byte);
var loop: integer;
Begin
  choices := head;
  for loop := 1 to pred(ctc) do choices := choices^.next;
  with choices^ do begin
    hotkey := hk;
    freemem(desc,length(desc^)+1);
    getmem(desc,length(ds)+1);
    desc^ := ds;
    attr := atr;
    hilight := pos(hotkey,desc^);
  end;
End;

Procedure tMenuChoices.GetChoice(ctc: integer; var hk: char; var ds: string; var atr: byte);
var loop: integer;
Begin
  choices := head;
  for loop := 1 to pred(ctc) do choices := choices^.next;
  with choices^ do begin
    hk := hotkey;
    ds := desc^;
    atr := attr;
  end;
End;

Destructor tMenuChoices.Done;
Var Temp: pchoices;
Begin
  { Dispose of the list of choices }
  choices := head;
  while choices <> nil do begin
    temp := choices^.next;
    dispose(choices);
    choices := temp;
  end;
end;

Constructor ExplodingMenu.Init(_x,_y,wx,wy: byte; tit: string);
begin

  Boxonscreen := false;
  StartChoices := 0;
  EndChoices := 0;
  Place := 1;
  Choice := 1;
  CallOnMove := nil;

  lenx := wx;
  leny := wy;
  startx := _x;
  starty := _y;
  title := tit;

  { The little characters on the side of the bar }
  LeftChar := #0;
  RightChar := #0;
  { The little characters saying if there's more to it than shown }
  MoreUp := #24;
  MoreDown := #25;

  { Set default colors }
  SetColors(_blue+lightblue,_blue+white,_blue+lightcyan,_blue+white,_lightgray+black,_lightgray+blue,darkgray);
  Choice := 1;
end;

Procedure ExplodingMenu.SetColors(borderc,titlec,menuc,himenuc,barc,hbarc,shdw: byte);
begin
  BorderColor := borderc;
  TitleColor := titlec;
  MenuColor := menuc;
  HighlightMenuColor := himenuc;
  BarColor := barc;
  HighlightBarColor := hbarc;
  MShadow := shdw;

  Unavailcolor := MenuColor and $F0+lightgray;
  Unavailbarcolor := BarColor and $F0+darkgray;
  CharsColor := BarColor and $F0+black;
  IconColor := MenuColor and $F0+yellow;
end;

Procedure ExplodingMenu.DrawBox;
Begin
  if not boxonscreen then begin
    boxonscreen := true;
    if leny = 0 then leny := startchoices+totalchoices+2;
    menu.init(startx,starty,lenx,leny,1,' ',BorderColor,MenuColor,5,mshadow);
    menu.movecursor := false;
    if title <> '' then begin
      textattr := titlecolor;
      menu.textout(lenx div 2-length(title) div 2,0,title);
    end;
    if leny-startchoices-2 > totalchoices then endchoices := totalchoices
    else endchoices := leny-startchoices-2;
  end;
  Update;
End;

Procedure ExplodingMenu.Update;
var
  loop: integer;
  Temp: byte;
Begin
  Choices := head;
  for loop := 1 to pred(place) do choices := choices^.next;
  temp := totalchoices;
  if temp > endchoices then temp := endchoices;
  For loop := 1 to temp do with choices^ do begin
    { Put those borders back in place }
    textattr := bordercolor;
    menu.textout(0,loop+startchoices,box[menu.box_to_use].vl);
    menu.textout(lenx-1,loop+startchoices,box[menu.box_to_use].vl);

    Case attr of
      None,quittype: begin
        if pred(loop)+place = choice then textattr := barcolor
        else Textattr := menucolor;
        menu.Textout(1,loop+StartChoices,ljust(' '+desc^,lenx-2));
        If HiLight <> 0 then begin
          If pred(loop)+place = Choice then Textattr := HighLightBarColor
          Else Textattr := HighLightMenuColor;
          PutAttrs(menu.x+1+hilight,menu.y+loop+StartChoices,1);
        End;
      End;

      Linetype: menu.hline(loop+startchoices,1);

      Unavail,UnAccessable: begin
        If pred(loop)+place=choice then textattr := unavailbarcolor
        Else textattr := unavailcolor;
        Menu.Textout(1,loop+StartChoices,ljust(' '+desc^,lenx-2));
      End;
    End;

    if pred(loop)+place = choice then begin
      textattr := charscolor;
      if leftchar <> #0 then menu.textout(1,loop+startchoices,leftchar);
      if rightchar <> #0 then menu.textout(lenx-2,loop+startchoices,rightchar);
    end;
    Choices := next;
  end;
  { Put the scroll characters in there in needed }
  textattr := iconcolor;
  if (place > 1) and (moreup <> #0) then menu.textout(lenx-1,1+startchoices,MoreUp);
  if (place < totalchoices-endchoices+1) and (moredown <> #0) then menu.textout(lenx-1,leny-2,MoreDown);
End;

Procedure ExplodingMenu.ProcessInput;
Var
  Loop: byte;
  Change,Found: boolean;
  Ch: char;
  i,j: integer;
  mousex,mousey,oldmousey,button: word;
  diff: integer;

  Procedure Check;
  begin
    if choice < 1 then choice := 1;
    if choice > totalchoices then choice := totalchoices;

    if choice < place then place := choice;
    if choice > place+endchoices-1 then place := choice-endchoices+1;
    if place < 1 then place := 1;
    if (place+endchoices-1 > totalchoices) and (totalchoices-endchoices-1>0)
      then place := totalchoices-endchoices+1;
  End;

  Procedure IncCheck; Forward;
  Procedure DecCheck; Forward;

  Procedure IncCheck;
  Var loop: word;
  begin
    Check;
    choices := head;
    for loop := 1 to pred(choice) do choices := choices^.next;
    while not (choices^.attr in [none,quittype,unavail]) do begin
      Inc(Choice);
      Choices := choices^.next;
      if choice > totalchoices then begin
        choice := totalchoices;
        DecCheck;
      end;
    End;
    Check;
  end;

  Procedure DecCheck;
  Var loop: word;
  begin
    Check;
    choices := head;
    for loop := 1 to pred(choice) do choices := choices^.next;
    while not (choices^.attr in [none,quittype,unavail]) do begin
      Dec(Choice);
      Choices := head;
      For loop := 1 to pred(choice) do choices := choices^.next;
      if choice < 1 then begin
        Choice := 1;
        IncCheck;
      end;
    End;
    Check;
  end;

Begin
  If not boxonscreen then drawbox;
  inccheck;

  mousex := 0;
  mousey := 80;
  oldmousey := mousey;
  if mouseinstalled then Setmousepos(mousex,mousey);

  Select := false;
  Quit := false;
  LastChoice := Choice;
  If CallOnMove <> nil then CallUserProc(CallOnMove);

  Repeat
    Update;

    change := false;
    repeat
      if keypressed then begin
        change := true;
        Ch := upcase(readkey);
        case ch of
          #0: begin
            ch := readkey;
            case ch of
              _Home: begin
                Choice := 1;
                Place := 1;
                inccheck;
              end;
              _End: begin
                Choice := TotalChoices;
                Place := Choice-(endchoices-1);
                if place < 1 then place := 1;
                deccheck;
              end;
              _PageUp: begin
                Dec(choice,endchoices);
                Dec(place,endchoices);
                inccheck;
              end;
              _PageDown: begin
                Inc(choice,endchoices);
                Inc(place,endchoices);
                deccheck;
              end;
              _Up,_Left: begin
                dec(choice);
                deccheck;
              end;
              _Down,_Right: begin
                inc(choice);
                inccheck;
              end;
            end;
          End;
          #13,' ': begin
            choices := head;
            for loop := 1 to pred(choice) do choices := choices^.next;
            if (choices^.attr in [none,quittype]) then Select := true;
          end;
          #27: begin
            Quit := true;
            Choice := totalchoices;
          End;

          'A'..'Z','0'..'9': begin
            found := false;
            i := choice;
            choices := head;
            for loop := 1 to i do choices := choices^.next;
            repeat
              inc(i);
              found := (upcase(choices^.desc^[1]) = ch) and (choices^.attr in [quittype,none]);
              choices := choices^.next;
            until found or (i >= totalchoices);

            if not found then begin
              found := false;
              i := 0;
              choices := head;
              repeat
                inc(i);
                found := (upcase(choices^.hotkey) = ch) and (choices^.attr in [quittype,none]);
                choices := choices^.next;
              until found or (i >= totalchoices);
            end;

            if found then begin
              change := true;
              choice := i;
              choices := head;
              i := 0;
              j := 0;
              repeat
                inc(i);
                if (upcase(choices^.hotkey) = ch) and (choices^.attr in [quittype,none]) then inc(j);
                choices := choices^.next;
              until (j = 2) or (i = totalchoices);

              select := false;
              if j = 1 then select := true;
            end;
            check;
          end;
        End;
      End;

      If mouseinstalled then begin
        GetMousePos(mouseX,mouseY,button);
        If (mousey <> oldmousey) then begin
          if kpe <> nil then calluserproc(kpe);
          { Half sensitivity per space }
          diff := abs(integer(mousey) - integer(oldmousey)) div 8 div 2;
          if diff <> 0 then begin
            change := true;
            if mousey < oldmousey then begin
              dec(choice,diff);
              deccheck;
            end;
            if mousey > oldmousey then begin
              inc(choice,diff);
              inccheck;
            end;
            mousex := 0;
            mousey := 80;
            Setmousepos(mousex,mousey);
            oldmousey := mousey;
            { Non-wrap around choice list for the mouse }
            if choice > totalchoices then choice := totalchoices;
            if choice < 1 then choice := 1;
          End;
        end;

        If button <> 0 then begin
          if kpe <> nil then calluserproc(kpe);
          If button = leftb then begin
            choices := head;
            for loop := 1 to pred(choice) do choices := choices^.next;
            if (choices^.attr in [none,quittype]) then Select := true;
          end
          Else if button = rightb then quit := true
          Else begin
            blip;
            repeat until not mousepressed;
          End;
        End;
      End;
    Until Change or select or quit;

    If (choice <> lastchoice) then begin
      If CallOnMove <> nil then CallUserProc(CallOnMove);
      LastChoice := Choice;
    end;

  Until (Select or quit) and ((not mouseinstalled) or (not mousepressed));

  Update;

  If quit or select then begin
    choices := head;
    for loop := 1 to pred(choice) do choices := choices^.next;
    if choices^.attr and Quittype = quittype then quit := true;
  end;
End;

Destructor ExplodingMenu.Done;
Begin
  { Finish up the box }
  if boxonscreen then menu.done(3);
end;

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

Begin
  Touchres := '';
  ColorCfg := DefaultColors;
End.
