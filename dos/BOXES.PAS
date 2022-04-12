{$A+,B-,D-,E+,F-,G-,I-,L+,N-,O-,R-,S+,V+,X+}
{$M 16384,0,655360}
Unit Boxes; { Copyright 1995, by John Stephenson }
{ This Unit uses direct video writes via the asmmisc unit, bypassing CRT }
Interface
Uses Crt,AsmMisc;
Type
  wordptr = ^word; { needed for inc(p,xxx); statement }
  explodingbox = object
    { Begining of the window }
    x,y: byte;
    { Size of the window }
    rows,cols: byte;

    box_to_use: byte;
    fill_box_with: char;
    border_color: byte;
    fill_color: byte;
    { 0 if there's no shadow, 128 if it's supposed to be plain black }
    shadow: byte;
    movecursor: boolean;

    Constructor Init(xpos,ypos,ccnt,rcnt,btu: byte; fbw: char; bc,fc: byte; ms: integer; shdw: byte);
    Procedure TextOut(xpos,ypos: byte; txt : string);
    Procedure FillAttr(times: word);
    Procedure Move(newx,newy,ms: integer);
    Procedure Movexy(newx,newy: byte);
    Procedure Scroll;
    Procedure PutHeader(st: String; color: byte);
    Procedure PutFooter(st: String; color: byte);
    Procedure HLine(ypos,btu: byte);
    Destructor Done(ms: integer);

    Private
      { The saved screen }
      SavedImage : wordptr;
      { The size of the saved screen }
      Datasize: word;
      { Old screen attributes }
      oldx,oldy,oldtextattr: byte;
  end;

  boxtype = record
    hl,   { Horizontal line }
    vl,   { Vertical Line   }
    tl,   { Top left        }
    sb,   { Split to bottom }
    tr,   { Top Right       }
    sl,   { Split to left   }
    md,   { Middle piece    }
    sr,   { Split to right  }
    bl,   { Bottom left     }
    st,   { Split to top    }
    br:   { Bottom right    }
    Char; { Of type byte    }
  end;

Const
  Box: array[1..4] of boxtype = { Typed constant idea }
   ((Hl:'Ä';Vl:'³';Tl:'Ú';Sb:'Â';Tr:'¿';Sl:'Ã';Md:'Å';Sr:'´';Bl:'À';St:'Á';Br:'Ù'),
    (Hl:'Í';Vl:'º';Tl:'É';Sb:'Ë';Tr:'»';Sl:'Ì';Md:'Î';Sr:'¹';Bl:'È';St:'Ê';Br:'¼'),
    (Hl:'Ä';Vl:'º';Tl:'Ö';Sb:'Ò';Tr:'·';Sl:'Ç';Md:'×';Sr:'¶';Bl:'Ó';St:'Ð';Br:'½'),
    (Hl:'Í';Vl:'³';Tl:'Õ';Sb:'Ñ';Tr:'¸';Sl:'Æ';Md:'Ø';Sr:'µ';Bl:'Ô';St:'Ï';Br:'¾')
   );

Function SaveRect(x,y,columncount,rowcount: byte; var saveptr : wordptr) : word;
Procedure RestRect(x,y,columncount,rowcount: byte; saveptr : wordptr);
Procedure DrawBox(xpos,ypos,rowcount,columncount,btu: byte; fw: char; bc,fc,shadow: byte);

Implementation

Function SaveRect(x,y,columncount,rowcount: byte; var saveptr: wordptr) : word;
{ This is a function that returns the amount of memory used to save a
  region of a screen, and it also will accolate and save it to a word
  pointer variable saveptr, (only typecasted as a word tho!), and it
  will save from x, y to x + rows, y + cols. Simple?
  I think the documentation is harder to understand :) }
var
  savesize : word;
  scroff   : word;
  scrdata  : wordptr;
  p : wordptr;
begin
  scroff := ((y - 1) * 80 + x - 1) * 2;
  Scrdata := ptr(vidseg, scroff);
  { Calculate the amount of memory required to hold rows * columns
    And remember that you're dealing with both attributes and characters   }
  SaveSize := rowcount * columncount * 2;
  getmem(saveptr, savesize);
  { Put it into a temporary pointer variable since it scrptr would have
    been changed (it's pointer variable -- which would be disasterous!) }
  p := saveptr;
  { Save the rows (needs to be done individually since scrptr^ is dynamic) }
  for rowcount := rowcount downto 1 do begin
    move(scrdata^, p^, columncount * 2);
    { Increase to the next column down in memory (dynamic too!) }
    inc(p, longint(columncount));
    { Increase to the next column on the screen (static -- of couse!) }
    inc(scrdata, 80);
  end;
  { Report back the amount of memory used to save the screen region }
  saverect := savesize;
end;

Procedure RestRect(x,y,columncount, rowcount : byte; saveptr : wordptr);
{ Procedure to restore a region of screen (from wherex, wherey to wherex +
  rowcount, wherey + columncount) from pointer variable saveptr }
Var
  scroff : word;
  scrdata : wordptr;
  p : wordptr;
Begin
  { Figure out where in video memory we're going! }
  scroff := ((y - 1) * 80 + x - 1) * 2;
  Scrdata := ptr(vidseg, scroff);
  { Set P to Saveptr (since that saveptr would have needed to be changed! }
  p := saveptr;
  { Restore the region saved in Saveptr }
  for rowcount := rowcount downto 1 do begin
    { Moves a line back to the video memory }
    move(p^, scrdata^, columncount * 2);
    { Move to the next line in the saved screen }
    inc(p, longint(columncount));
    { Move to the next line on the screen -- same position }
    inc(scrdata, 80);
  End;
End;

Procedure DrawBox(xpos,ypos,rowcount,columncount,btu: byte; fw: char; bc,fc,shadow: byte);
{ Procedure to create a box from position x, y, to x + rowcount, y
  + columncount, will use const's defined previously for box type }
var loop,temp,posit: byte;
Begin
  with box[btu] do begin
  textattr := bc;
  { Make upper left corner }
  putchars(xpos, ypos, tl, 1);
  { Make horizontal line }
  putchars(xpos + 1, ypos, hl, columncount - 2);
  { Make upper right corner }
  putchars(xpos + columncount - 1, ypos, tr, 1);
  temp := rowcount;
  posit := ypos;
  while (temp > 2) do begin
    { Move down a line }
    inc(posit);
    textattr := bc;
    { Make side piece }
    putchars(xpos, posit, vl, 1);
    { Fill with spaces }
    textattr := fc;
    putchars(xpos + 1, posit, fw, columncount - 2);
    textattr := bc;
    { Make side piece }
    putchars(xpos+columncount-1, posit, vl, 1);
    dec(temp);
  end;
  textattr := bc;
  { Make lower left corner }
  putchars(xpos, posit+1, bl, 1);
  { Make horizontal line }
  putchars(xpos + 1, posit+1, hl, columncount - 2);
  { Make lower right corner }
  putchars(xpos+columncount-1, posit+1, br, 1);
  { Shadowing? }
  if shadow <> 0 then begin
    textattr := shadow;
    putattrs(xpos+1,posit+2,columncount);
    for loop := ypos+1 to posit+1 do putattrs(xpos+columncount,loop,1);
  end;
  { And presto we're done! }
  end;
End;

Constructor ExplodingBox.Init(xpos, ypos, ccnt, rcnt, btu : byte; fbw : char; bc, fc : byte; ms : integer; shdw: byte);
{ A constructor (to be called like reg.init, or new(reg, init) etc. to
  save a region of the screen, save screen attributes, and blow up a box
  with ms millisecond delay in between each frame, done is the appropriate
  deconstructor to be used with Init }
var
  tempx, tempy, tempcols, temprows : byte;
Begin
  { Save the old screen attributes }
  oldx := wherex;
  oldy := wherey;
  oldtextattr := textattr;
  { Set the global variables for window beginings                          }
  movecursor := true;
  x := xpos;
  y := ypos;
  box_to_use := btu;
  fill_box_with := fbw;
  border_color := bc;
  fill_color := fc;
  shadow := shdw;
  gotoxy(x, y);
  { Set global variables saying the size of the window                     }
  rows := rcnt;
  cols := ccnt;
  if shadow = 0 then datasize := saverect(x,y,cols,rows,savedimage)
  else datasize := saverect(x,y,cols+1,rows+1,savedimage);

  { Blow up the window -- only if specified (delay must be not negative) }
  if abs(ms) = ms then begin
    { Begin in the middle }
    tempx := x+(cols div 2);
    tempy := y+(rows div 2);
    { Begin with a small window }
    tempcols := 1;
    temprows := 1;
    { Explode it to normal }
    repeat
      if x < tempx then dec(tempx);
      if y < tempy then dec(tempy);
      if cols > tempcols then inc(tempcols, 2);
      if rows > temprows then inc(temprows, 2);
      { Double check that we haven't moved too far }
      if cols < tempcols then dec(tempcols);
      if rows < temprows then dec(temprows);
      { Draw the box }
      drawbox(tempx,tempy,temprows,tempcols,box_to_use,fill_box_with,
        border_color,fill_color,shadow);
      { Delay a bit }
      delay(ms);
    until (tempcols = cols) and (temprows = rows)
      and (tempx = x) and (tempy = y);
  End
  { Or else just make the box }
  else drawbox(x,y,rows,cols,btu,fill_box_with,border_color,fill_color,shadow);
  textattr := fill_color;
End;

Procedure ExplodingBox.TextOut(XPos, Ypos : byte; txt : string);
{ This procedure is to allow a person to access the window without having
  to worry about it's screen positions in relation to the screen, but to
  the window }
Begin
  putstring(x+xpos,y+ypos,txt);
  if movecursor then gotoxy(x+xpos+length(txt),y+ypos);
End;

Procedure ExplodingBox.Movexy(newx,newy: byte);
{ This procedure will move the cursor to (newx,newy) relative to the
  current box }
begin
  if movecursor then gotoxy(x+newx,y+newy);
end;

Procedure ExplodingBox.fillattr(times : word);
{ This procedure is to fill a certain amount of spaces with a colour
  (from cursor position) and doesn't move cursor position! }
begin
  putattrs(wherex, wherey, times);
end;

Procedure ExplodingBox.Move(newx, newy, ms : integer);
{ Move the box by an offset to newx, newy at speed ms }
Var
  p: wordptr;
  size: integer;
  attr,loop: byte;
Begin
  attr := textattr;
  repeat
    { Save the original box }
    size := saverect(x,y,cols,rows,p);

    { Wait for a retrace }
    Retrace;
    { Restore the original screen }
    if shadow = 0 then Restrect(x,y,cols,rows,savedimage)
    else Restrect(x,y,cols+1,rows+1,savedimage);
    Freemem(savedimage,datasize);
    { Adjust the box, but make sure only one moves at a time (no diagonal  }
    { movement is wanted or required                                       }
    if x < newx then inc(x)
    else if x > newx then dec(x)
    else if y < newy then inc(y)
    else if y > newy then dec(y);
    { Save the new region }
    if shadow = 0 then datasize := saverect(x,y,cols,rows,savedimage)
    else datasize := saverect(x,y,cols+1,rows+1,savedimage);
    { Restore the old box }
    Restrect(x,y,cols,rows,p);
    freemem(p,size);
    if shadow <> 0 then begin
      textattr := shadow;
      putattrs(x+1,y+rows,cols);
      for loop := y+1 to y+rows do putattrs(x+cols,loop,1);
    end;
    { Delay a bit -- give the computer some rest :)                        }
    delay(ms);
  until (y = newy) and (x = newx);
  textattr := attr;
end;

Procedure ExplodingBox.Scroll;
{ To scroll the box one place up, without disturbing anything, including
  relative position of the cursor on the screen }
var
  screen: wordptr;
  sizeused: word;
begin
  sizeused := saverect(x+1,y+2,cols-2,rows-1,screen);
  restrect(x+1,y+1,cols-2,rows-3,screen);
  freemem(screen,sizeused);
  putchars(x+1,y+rows-2,' ',cols-2);
  if (wherey > y+1) and movecursor then gotoxy(wherex,wherey-1);
end;

Procedure ExplodingBox.HLine(ypos,btu: byte);
Var
  St: String;
  Attr: byte;
begin
  attr := textattr;
  case btu of
    1: begin { Single lined }
      case box_to_use of
        1: btu := 1;
        2: btu := 3;
        3: btu := 3;
        4: btu := 1;
      end;
    end;
    2: begin { Double lined }
      case box_to_use of
        1: btu := 4;
        2: btu := 2;
        3: btu := 2;
        4: btu := 4;
      end;
    end;
  end;
  textattr := border_color;
  textout(0,ypos,box[btu].sl);
  fillchar(st,sizeof(st),box[btu].hl);
  st[0] := char(pred(cols));
  textout(1,ypos,st);
  textout(cols-1,ypos,box[btu].sr);
  textattr := attr;
end;

Procedure ExplodingBox.PutHeader(st: String; color: byte);
Var attr: byte;
begin
  attr := textattr;
  textattr := border_color;
  textout(2,0,box[box_to_use].sr);
  textout(3+length(st),0,box[box_to_use].sl);
  textattr := color;
  textout(3,0,st);
  textattr := attr;
end;

Procedure ExplodingBox.PutFooter(st: String; color: byte);
Var attr: byte;
begin
  attr := textattr;
  textattr := border_color;
  textout(cols-(length(st)+4),pred(rows),box[box_to_use].sr);
  textout(cols-3,pred(rows),box[box_to_use].sl);
  textattr := color;
  textout(cols-(length(st)+3),pred(rows),st);
  textattr := attr;
end;

Destructor ExplodingBox.Done(ms: integer);
{ To deconstruct the region, restore the screen, free the memory and
  restore the saved attributes }
var
  tempx,tempy,tempcols,temprows: integer;
Begin
  { Blow up the window -- only if specified (delay must be not negative) }
  if abs(ms) = ms then begin
    { Begin in the middle }
    tempx := x;
    tempy := y;
    { Begin with a small window }
    tempcols := cols;
    temprows := rows;
    { Explode it to normal }
    repeat
      if tempx < x + (cols div 2) then inc(tempx);
      if tempy < y + (rows div 2) then inc(tempy);

      if temprows > 3 then dec(temprows,2)
      else if temprows = 3 then dec(temprows);

      if tempcols > 3 then dec(tempcols,2)
      else if tempcols = 3 then dec(tempcols);

      { Restore the video memory }
      if shadow = 0 then Restrect(x,y,cols,rows,savedimage)
      else Restrect(x,y,cols+1,rows+1,savedimage);
      { Draw the box }
      drawbox(tempx,tempy,temprows,tempcols,box_to_use,fill_box_with,border_color,fill_color,shadow);
      { Delay a bit }
      delay(ms);
    until (tempcols = 2) and (temprows = 2);
  End;
  { Restore the video memory }
  if shadow = 0 then Restrect(x,y,cols,rows,savedimage)
  else Restrect(x,y,cols+1,rows+1,savedimage);
  { Free the memory of the image }
  Freemem(savedimage,datasize);
  { Restore screen attributes }
  Textattr := oldtextattr;
  gotoxy(oldx,oldy);
End;

End.
