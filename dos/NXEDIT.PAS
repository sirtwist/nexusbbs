{$A+,B+,D-,E+,F+,G-,I+,L-,N-,O-,R-,S+,V-}
{$M 65400,50000,200000}      { Memory Allocation Sizes }
program nxEDIT;

uses dos,crt,misc,myio,ivmodem,mulaware;

type
 ttype = array[1..400] of string[81];
const
   root: word = 19;
   quotedirect:boolean=FALSE;
   onelinetop:boolean=FALSE;
   topscreen: word = 5;       {first screen line for text entry}
   scrlines: word = 19;       {number of screen lines for text entry}
   scrollsiz: word = 14;      {number of lines to scroll by}
   insert_mode: boolean = true;
   max_msg_lines: word = 400;
   wwrap=78;
   save:boolean=FALSE;
   quoteavail:boolean=FALSE;
   localonly:boolean=FALSE;
   default_fore=7;
   default_back=0;
   noabort:boolean=FALSE;
var
   cnode:integer;
   tagdir:string;
   exitmode: boolean;
   key_source: byte;
   key: char;
   process_fkeys: boolean;
   par: string;
   onf:file of onlinerec;
   o:onlinerec;
   linenum: word;
   linecnt: word;
   topline: integer;    {message line number at top of screen}
   cline:   integer;    {current message line number}
   ccol:    integer;    {current column number}

   phyline: array[1..18] of string[81];
                        {physical display text}

   pleft:   integer;    {previous value of minutes_left}

   datetime: string[20];
   fromusername,tousername: string[35];
   subject: string[79];
   areaname: string;
   mnum: word;
   priv: string;

   text: ^ttype;
   quote: array[1..200] of string[81];

   helpon: boolean;
   dropfilepath: string;

procedure updatestatus;
var oldx,oldy:integer;
    ta:byte;
begin
ta:=textattr;
oldx:=wherex;
oldy:=wherey;
cursoron(FALSE);
window(1,1,80,25);
textcolor(15);
textbackground(3);
gotoxy(1,25);
clreol;
if (localonly) then begin
          write(mln('Local User',35));
end else begin
if (systat.aliasprimary) then
          write(mln(o.name,35))
          else write(mln(o.real,35));
end;
	  gotoxy(37,25);
          textcolor(15);
          write('³');
          gotoxy(47,25);
          write(' ³');
          gotoxy(49,25);
          if (o.baud=0) then
          write(' '+mln('Local',6))
          else
          write(' '+mln(cstr(o.baud*10),6));
          textcolor(15);
          write(' ³');
          gotoxy(64,25);
          write('³');
          gotoxy(66,25);
          cwrite('Left: ');
          window(1,1,80,24);
          gotoxy(oldx,oldy);
          cursoron(TRUE);
          textattr:=ta;
end;

procedure clear_eol;
begin;
 if (not localonly) then ivSend(#27+'[K');
 clreol;
end;

function get_key: char;
var
 ch: char;
begin;
 if localonly then begin
  ch:=readkey;
  if (ch=#0) and (keypressed) then begin;
   ch:=#0;
   key_source:=sysop_key;
  end else key_source:=remote;
 end else begin;
  key_source:=remote;
  while not(ivKeypressed) and (ivCarrier) do begin
        timeslice;
  end;
  ch:=ivReadChar;
 end;
 get_key:=ch;
end;

procedure space;
begin;
 ivWrite(' ');
end;

procedure dgreen(s: string);
begin;
 ivTextcolor(lightgreen);
 ivWrite(s);
end;

procedure default_color;
begin;
 ivTextcolor(default_fore);
end;

procedure position(x,y: byte);
begin;
 ivGotoxy(x,y);
end;

procedure copyright;
begin
{   ivGotoxy(1,24);
   ivTextcolor(15);
   ivTextbackground(0);
   clear_eol;
   ivWrite('nxEDIT v'+version+'  ú (c) Copyright 1996-2001 George A. Roberts IV ú  ESC for HELP ');}
end;

procedure bottomline;
begin
   ivTextcolor(8);
   ivTextbackground(0);
   ivGotoxy(1,24);
   if (quoteavail) then begin
   ivWrite('ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[');
   ivTextcolor(15);
   if (noabort) then begin
   ivWrite('CTRL %080%(A)bort (%150%Z%080%)%150%Save %080%(%150%Q%080%)%150%uote');
   end else begin
   ivWrite('CTRL %080%(%150%A%080%)%150%bort %080%(%150%Z%080%)%150%Save %080%(%150%Q%080%)%150%uote');
   end;
   ivTextcolor(8);
   ivWrite(']Ù');
   end else begin
   ivWrite('ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[');
   ivTextcolor(15);
   if (noabort) then begin
   ivWrite('CTRL %080%(A)bort (%150%Z%080%)%150%Save');
   end else begin
   ivWrite('CTRL %080%(%150%A%080%)%150%bort %080%(%150%Z%080%)%150%Save');
   end;
   ivTextcolor(8);
   ivWrite(']Ù');
   end;
end;

procedure display_header;
var x2:integer;
begin
   ivTextcolor(8);
   ivWriteln('ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
   if not(onelinetop) then begin
   ivWrite('³');
   ivTextcolor(15);
   ivTextbackground(3);
   ivWrite(' To     : ');
   ivWrite(ToUserName);
   while wherex<40 do ivWrite(' ');
   ivWrite(' From   : ');
   ivWrite(FromUserName);
   while wherex<79 do ivWrite(' ');
   ivTextcolor(8);
   ivTextbackground(0);
   ivWriteln('³');
   end;
   ivWrite('³');
   ivTextcolor(15);
   ivTextbackground(3);
   ivWrite(' Subject: ');
   ivTextcolor(15);
   ivWrite(Subject);
   while wherex<79 do ivWrite(' ');
   ivTextcolor(8);
   ivTextbackground(0);
   ivWriteln('³');
   if (onelinetop) then begin
   ivWriteln('ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´');
   if (localonly) then begin
   end else begin
   ivGotoXY(wherex,66);
   ivWrite('[');
   ivTextcolor(15);
   ivWrite('Node #');
   ivTextcolor(8);
   for x2:=1 to (4-length(cstr(cnode))) do
   ivWrite('°');
   ivTextcolor(15);
   ivWrite(cstr(cnode));
   ivTextcolor(8);
   ivWriteln(']');
   end;
   end else begin
   ivWrite('ÃÄ[');
   ivTextcolor(15);
   ivWrite('#');
   ivTextcolor(8);
   for x2:=1 to (5-length(cstr(mnum))) do
   ivWrite('°');
   ivTextcolor(15);
   ivWrite(cstr(mnum));
   ivTextcolor(8);
   ivWrite(']');
   for x2:=10 to (35-(length(areaname) div 2)) do begin
     ivWrite('Ä');
   end;
   ivWrite('[ ');
   ivTextcolor(15);
   ivWrite(areaname);
   ivTextcolor(8);
   ivWrite(' ]');
   while wherex<66 do ivWrite('Ä');
   ivWrite('[');
   ivTextcolor(15);
   ivWrite('Node #');
   ivTextcolor(8);
   for x2:=1 to (4-length(cstr(cnode))) do
   ivWrite('°');
   ivTextcolor(15);
   ivWrite(cstr(cnode));
   ivTextcolor(8);
   ivWriteln(']Ä´');
   end;
   bottomline;
   copyright;
end;

procedure insert_line(contents: string);
var
 i: integer;
begin
 for i := max_msg_lines downto cline+1 do text^[i] := text^[i-1];
 text^[cline] := contents;
 if cline < linecnt then inc(linecnt);
 if cline > linecnt then linecnt := cline;
end;

procedure delete_line;
var
 i: integer;
begin
 for i := cline to max_msg_lines do text^[i]:=text^[i+1];
 text^[max_msg_lines] := '';
 if (cline <= linecnt) and (linecnt > 1) then dec(linecnt);
end;

procedure remove_trailing;
begin
 while text^[cline][length(text^[cline])]=' ' do delete(text^[cline],length(text^[cline]),1);
end;

procedure append_space;
begin
 text^[cline]:=text^[cline]+' ';
end;

function curlength: integer;
begin
 curlength:=length(text^[cline]);
end;


procedure clear_screen;
begin;
 if (not localonly) then ivsend(#27+'[2J');
 clrscr;
end;

procedure count_lines;
begin;
 linecnt := max_msg_lines;
 while (linecnt > 0) and (length(text^[linecnt]) = 0) do dec(linecnt);
{ if replyline(mr.text[linecnt]) then begin;
  inc(linecnt);
  inc(linecnt);
 end;}
end;

function line_boundry: boolean;
begin
 line_boundry := (ccol=1) or (ccol > curlength);
end;


function curchar: char;
begin
 if ccol <= curlength then curchar:=text^[cline][ccol] else curchar := ' ';
end;

function delimiter: boolean;
begin
 case curchar of
  '0'..'9','a'..'z','A'..'Z','_':  delimiter := false;
  else delimiter := true;
 end;
end;


(* ----------------------------------------------------------- *)
function lastchar: char;
begin
 if curlength = 0 then lastchar := ' ' else lastchar:=text^[cline][curlength];
end;


(* ----------------------------------------------------------- *)
procedure reposition;
   {update physical cursor position}
var
   eol:  integer;

begin
   eol := curlength+1;
   if ccol > eol then
      ccol := eol;

   count_lines;
   position(ccol,cline-topline+topscreen);
end;

procedure Show_line_number;
begin;
 position(2,cline-topline+topscreen);
 write(cline:2,':');
end;


(* ----------------------------------------------------------- *)
procedure set_phyline;
   {set physical line to match logical line (indicates display update)}
begin
 phyline[cline-topline+1]:=text^[cline];
end;


(* ----------------------------------------------------------- *)
procedure update_eol;
   {update screen after changing end-of-line}
begin
   remove_trailing;
   reposition;
   clear_eol;        {remove end of line on screen}
   set_phyline;
end;


(* ----------------------------------------------------------- *)
procedure refresh_screen;
var
   pline:   integer;
   pcol:    integer;
   phline:  integer;

begin
   if (cline >= max_msg_lines) then
      cline := max_msg_lines;

   pline := cline;
   cline := topline;
   pcol := ccol;
   ccol := 1{-3};       {backspace to before the line number}

   for cline := topline to topline+scrlines-1 do
   begin
      phline := cline-topline+1;

      if cline > max_msg_lines then
      begin
         reposition;
         dGREEN('--');
         phyline[phline] := '--';
         clear_eol;
      end
      else

      begin
         if text^[cline]<>phyline[phline] then
         begin
            reposition;
            default_color;
            if curlength > 0 then
               ivWrite(text^[cline]);
            if curlength < length(phyline[phline]) then
               clear_eol;
            set_phyline;
         end;
      end;
   end;
   ccol := pcol;
   cline := pline;
   reposition;
end;


(* ----------------------------------------------------------- *)
procedure scroll_screen(lines: integer);
begin
   inc(topline,lines);

   if (cline < topline) or (cline >= topline+scrlines) then
      topline := cline - scrlines div 2;

   if topline < 1 then
      topline := 1
   else
   if topline >= max_msg_lines then
      dec(topline,scrollsiz div 2);


   refresh_screen;
end;


(* ----------------------------------------------------------- *)
procedure cursor_up;
begin
   if cline > 1 then
      dec(cline);

   if cline < topline then
      scroll_screen(-scrollsiz)
   else
      reposition;
end;


(* ----------------------------------------------------------- *)
procedure cursor_down;
begin
   inc(cline);
   if (cline >= max_msg_lines) then
      cline := max_msg_lines;

   if (cline-topline >= scrlines) then
      scroll_screen(scrollsiz)
   else
      reposition;
end;


(* ----------------------------------------------------------- *)
procedure cursor_endline;
begin
   ccol := 79;
   reposition;
end;

procedure cursor_begline;
begin
   ccol := 1;
   reposition;
end;


(* ----------------------------------------------------------- *)
procedure cursor_left;
begin
   if (ccol = 1) and (cline>1) then
   begin
      cursor_up;
      cursor_endline;
   end
   else

   begin
      dec(ccol);
      if (not localonly) then ivSend(#27'[D'); {cursor left}
      gotoxy(wherex-1,wherey);
   end;
end;


(* ----------------------------------------------------------- *)
procedure cursor_right;
begin
   if ccol > curlength then
   begin
      ccol := 1;
      cursor_down;
   end
   else
   begin
      default_color;
      ivWrite(curchar);
      inc(ccol);
   end;
end;


(* ----------------------------------------------------------- *)
procedure cursor_wordright;
begin
   if delimiter then
   begin
      {skip blanks right}
      repeat
         cursor_right;
         if line_boundry then exit;
      until not delimiter;
   end
   else

   begin
      {find next blank right}
      repeat
         cursor_right;
         if line_boundry then exit;
      until delimiter;

      {then move to a word start (recursive)}
      cursor_wordright;
   end;
end;


(* ----------------------------------------------------------- *)
procedure cursor_wordleft;
begin
   if delimiter then
   begin
      {skip blanks left}
      repeat
         cursor_left;
         if line_boundry then exit;
      until not delimiter;

      {find next blank left}
      repeat
         cursor_left;
         if line_boundry then exit;
      until delimiter;

      {move to start of the word}
      cursor_right;
   end
   else

   begin
      {find next blank left}
      repeat
         cursor_left;
         if line_boundry then exit;
      until delimiter;

      {and then move a word left (recursive)}
      cursor_wordleft;
   end;
end;


(* ----------------------------------------------------------- *)
procedure join_lines;
   {join the current line with the following line, if possible}
begin
   if (curlength + length(text^[cline+1])) >= 78 then
      exit;

   if (lastchar <> ' ') then
      append_space;
   text^[cline]:=text^[cline]+text^[cline+1];
   inc(cline);
   delete_line;
   dec(cline);

   refresh_screen;
end;


(* ----------------------------------------------------------- *)
procedure split_line;
   {splits the current line at the cursor, leaves cursor in original position}
var
   pcol:    integer;

begin
   pcol := ccol;
   remove_trailing;                       {get the portion for the next line}
   par := copy(text^[cline],ccol,78);

   text^[cline][0] := chr(ccol-1);       {remove it from the current line}
   update_eol;

   ccol := 1;                             {open a blank line}
   inc(cline);
   insert_line(par);

   if cline-topline > scrlines-2 then
      scroll_screen(scrollsiz)
   else
      refresh_screen;

   dec(cline);
   ccol := pcol;
end;


(* ----------------------------------------------------------- *)
procedure cursor_newline;
begin
   if insert_mode then
      split_line;

   ccol := 1;
   cursor_down;
end;


(* ----------------------------------------------------------- *)
procedure reformat_paragraph;
   {paragraph reformat, starting at current line and ending at any
    empty or indented line; leaves cursor after last line formatted}
begin

   remove_trailing;
   ccol := curlength;

   {for each line of the paragraph}
   while curchar <> ' ' do
   begin

      {for each word of the current line}
      repeat
         {determine length of first word on the following line}
         inc(cline);
         remove_trailing;
         ccol := 1;
         while curchar <> ' ' do
            inc(ccol);
         dec(cline);

         {hoist a word from the following line if it will fit}
         if (ccol > 1) and (ccol + curlength < wwrap) then
         begin
            if curlength > 0 then
            begin
               {add a second space after sentences}
               case lastchar of
                  '.','?','!':
                     append_space;
               end;
               append_space;
            end;
            text^[cline]:=text^[cline]+copy(text^[cline+1],1,ccol-1);

            {remove the hoisted word}
            inc(cline);
            while (curchar = ' ') and (ccol <= curlength) do
               inc(ccol);
            delete(text^[cline],1,ccol-1);
            if curlength = 0 then
               delete_line;
            dec(cline);
         end
         else
            ccol := 0;  {end of line}
      until ccol = 0;

      {no more lines will fit - either time for next line, or end of paragraph}
      inc(cline);
      ccol := 1;
      remove_trailing;
   end;

end;


(* ----------------------------------------------------------- *)
procedure visual_reformat;
   {reformat paragraph, update display}
var
   pline: integer;

begin
   pline := cline;
   reformat_paragraph;

   {find start of next paragraph}
   while (curlength = 0) and (cline <= linecnt) do
      inc(cline);

   {find top of screen for redisplay}
   while cline-topline > scrlines-2 do
   begin
      inc(topline,scrollsiz);
      pline := topline;
   end;

   refresh_screen;
end;


(* ----------------------------------------------------------- *)
procedure word_wrap;
   {line is full and a character must be inserted.  perform word-wrap,
    updating screen and leave ready for the insertion}
var
   pcol:    integer;
   pline:   integer;

begin
   pcol := ccol;
   pline := cline;

   ccol := curlength;
   if curchar = ' ' then
   begin
      cursor_newline;            {insert a c/r if line ends with a space}
      exit;
   end;

   {find start of word to wrap}
   while (ccol > 0) and (curchar <> ' ') do
      dec(ccol);

   {cancal wrap if no spaces in whole line}
   if ccol = 0 then
   begin
      ccol := 1;
      cursor_down;
      exit;
   end;

   {get the portion to be moved down}
   par := copy(text^[cline],ccol+1,78);

   {remove it from current line and refresh screen}
   text^[cline][0] := chr(ccol);
   update_eol;

   {place text on open a new line following the cursor}
   inc(cline);
   insert_line(par);

   {join the wrapped text with the following lines of text}
   reformat_paragraph;

   {restore cursor to proper position after the wrap}
   cline := pline;
   if pcol > curlength then
   begin
      ccol := pcol-curlength-1;   {position cursor after wrapped word}
      cursor_down;
   end
   else
      ccol := pcol;               {restore original cursor position}

   if (cline-topline >= scrlines) then
      scroll_screen(scrollsiz)
   else
      refresh_screen;
end;


(* ----------------------------------------------------------- *)
procedure insert_char(c: char);
   {insert a character at the cursor position; word-wrap if needed}
var c2:char;
begin
   {remove trailing spaces unless appending current line}
   if ccol < curlength then
      remove_trailing;

   {word-wrap needed if line is full}
   if (insert_mode and (curlength = wwrap)) or (ccol > wwrap) then
   begin
      if (ccol <= wwrap) then          {wrap last word if cursor is not at end}
         word_wrap
      else

      if c = ' ' then               {space at end-line is the same as newline}
      begin
         cursor_newline;
         exit;
      end
      else
         word_wrap;                 {otherwise wrap word down and continue}
   end;
   {keep track of number of active lines}
   count_lines;

   {insert character into the middle of a line}
   if insert_mode and (ccol <= curlength) then
   begin
      insert(c,text^[cline],ccol);

      {update display line following cursor}
      default_color;
      ivWrite(copy(text^[cline],ccol,78));

      {position cursor for next insertion}
      inc(ccol);
      reposition;
   end
   else

   {append a character to the end of a line}
   begin
      while curlength < ccol do
         append_space;
      text^[cline][ccol] := c;

      {advance the cursor, updating the display}
      cursor_right;
   end;

   set_phyline;
end;


(* ----------------------------------------------------------- *)
procedure delete_char;
begin

   {delete whole line if it is empty}
   if (ccol<1) and (cline=1) then begin
      ccol:=1;
      exit;
   end;
   if ccol > curlength then
      join_lines
   else

   {delete in the middle of a line}
   if ccol <= curlength then
   begin
      delete(text^[cline],ccol,1);
      default_color;
      ivWrite(copy(text^[cline],ccol,78));
      space;
      reposition;
      set_phyline;
   end;
end;


(* ----------------------------------------------------------- *)
procedure delete_wordright;
begin
   if curchar = ' ' then
      repeat   {skip blanks right}
         delete_char;
      until (curchar <> ' ') or (ccol > curlength)

   else
      repeat   {find next blank right}
         delete_char;
      until delimiter;

end;



(* ----------------------------------------------------------- *)
procedure cursor_tab;
begin
   repeat
      insert_char(' ');
   until (ccol mod 8) = 0;
end;


(* ----------------------------------------------------------- *)
procedure page_down;
begin
   if topline+scrlines < max_msg_lines then
   begin
      inc(cline,scrollsiz);
      scroll_screen(scrollsiz);
   end;
end;

procedure page_up;
begin
   if topline > 1 then
   begin
      dec(cline,scrollsiz);
      if cline < 1 then
         cline := 1;
      scroll_screen(-scrollsiz);
   end;
end;


(* ----------------------------------------------------------- *)
procedure visual_insert_line;
   {open a blank line, update display}
begin
   insert_line('');
   if cline-topline > scrlines-2 then
      scroll_screen(scrollsiz)
   else
      refresh_screen;
end;


(* ----------------------------------------------------------- *)
procedure visual_delete_line;
   {delete the line at the cursor, update display}
begin
   delete_line;
   refresh_screen;
end;


(* ----------------------------------------------------------- *)
procedure display_insert_status;
begin
   if (onelinetop) then position(75,2) else
   position(75,3);
   ivTextcolor(12);
   ivTextbackground(3);
   if insert_mode then
      ivWrite('INS')
   else
      ivWrite('OVR');
end;


(* ----------------------------------------------------------- *)
procedure display_message_header;
begin
   position(1,1);
   display_header;
   reposition;
end;

(* ----------------------------------------------------------- *)
procedure prepare_screen;
var
   i: integer;
begin
   clear_screen;
   linenum := 1;

   position(1,6);

   for i := 1 to scrlines do  {physical lines are now invalid}
      phyline[i] := '' {#0};
   pleft := -1;
   display_message_header;
   scroll_screen(0); {causes redisplay}
end;


(* ----------------------------------------------------------- *)
procedure redisplay;
begin
   topline := cline - scrlines div 2;
   prepare_screen;
end;


(* ----------------------------------------------------------- *)
procedure visual_display_original;
begin
{   clear_screen;
{   linenum := 2;
   {display_original;    **********************************}
{   prepare_screen;}
end;


(* ----------------------------------------------------------- *)
procedure visual_quote_original;
begin
{   linenum := 2;
{   cmdline := '';
{   position(1,22);
{   quote_from_original;
{  prepare_screen;}
end;

procedure DispHelp;
var c:char;
begin;
{  UP ARROW     - Moves the cursor up one line
 DOWN ARROW   - Moves the cursor down one line
 LEFT ARROW   - Moves the cursor to the left one space
 RIGHT ARROW  - Moves the cursor to the right one space
 INSERT       - Toggle the text insert/typeover mode
 DELETE       - Delete the character currently under the cursor

 CTRL-A or /A - Abort & exit program
 CTRL-B       - Restore line of text from buffer
 CTRL-C       - Center the current line of text on the screen
 CTRL-D       - Move cursor to the right one space
 CTRL-E       - Move cursor up one line
 CTRL-J       - Left justify the current line of text on the screen
 CTRL-K       - Toggle LineDraw mode ON or OFF, or select line style
 CTRL-L       - List / edit available macros
 CTRL-P       - Place cursor at the end of the line
 CTRL-Q or /Q - Quote window (Available only with message replies)
 CTRL-R       - Redraw the editing screen
 CTRL-S       - Move cursor to the left one space
 CTRL-T       - Delete text from the cursor to the end of the line
 CTRL-U       - Delete text from the cursor to the end of the current word
 CTRL-V       - Toggle INSERT/TYPEOVER Modes
 CTRL-W       - Return cursor to the beginning of the line
 CTRL-X       - Move cursor down one line
 CTRL-Y       - Erase current line of text
 CTRL-Z or /S - Save message text & exit program

 There are also SysOP only keys that may be used:

 F1.. 10      - Activate previously defined SysOp text macros
 ALT- F2      - Import a textfile into the message
 ALT- F3      - Export message contents to a file
 ALT- C       - Invoke external chat utility
 ALT- H       - Terminate Connection
 ALT- J       - Shell to DOS
 ALT- =       - Add one minute to user's time
 ALT- -       - Subtract one minute from user's time }
 ivTextcolor(8);
 ivTextbackground(0);
 ivWriteln('ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
 ivWrite('³');
 ivTextcolor(15);
 ivTextbackground(3);
 ivWrite(' nxEDIT v'+version+' - User Command Help                                            ');
 ivTextcolor(8);
 ivTextbackground(0);
 ivWriteln('³');
 ivWriteln('ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');
 ivWriteln('');
 ivTextcolor(3);
 ivTextbackground(0);
 ivWriteln('ARROW RIGHT  - Move cursor one character to the right');
 ivWriteln('ARROW LEFT   - Move cursor one character to the left');
 ivWriteln('ARROW UP     - Move cursor one line up');
 ivWriteln('ARROW DOWN   - Move cursor one line down');
 ivWriteln('');
 ivWriteln('CTRL-C       - Move one screen up');
 ivWriteln('CTRL-R       - Move one screen down');
 ivWriteln('CTRL-Y       - Delete current line');
 ivWriteln('CTRL-V       - Overtype/Insert mode');
 ivWriteln('');
 ivWriteln('ESC          - Access menu');
 if (quoteavail) then
 ivWriteln('CTRL-Q       - Quote original text');
 ivWriteln('CTRL-A       - Abort editing');
 ivWriteln('CTRL-Z       - Save text');
 ivWriteln('');
 ivTextcolor(15);
 ivTextbackground(0);
 ivWrite('-press any key-');
 c:=get_key;
end;

procedure DoHelp;
begin;
  clear_screen;
  DispHelp;
  prepare_screen;
  display_insert_status;
  reposition;
end;

function optionmenu: byte;
var c:char;
    wh,left:byte;
    dohelp,doquote,exit,done:boolean;

procedure showhighlight;
begin
ivTextcolor(15);
case wh of
     1:begin
            ivGotoxy(22,24);
            ivTextbackground(3);
            ivWrite('Save');
            ivGotoxy(22,24);
       end;
     2:begin
            ivGotoxy(29,24);
            ivTextbackground(3);
            ivWrite('Abort');
            ivGotoxy(29,24);
       end;
     3:begin
            ivGotoxy(37,24);
            ivTextbackground(3);
            ivWrite('Edit');
            ivGotoxy(37,24);
       end;
     4:begin
            ivGotoxy(44,24);
            ivTextbackground(3);
            ivWrite('Help');
            ivGotoxy(44,24);
       end;
     5:begin
            ivGotoxy(51,24);
            ivTextbackground(3);
            ivWrite('Quote');
            ivGotoxy(51,24);
       end;
end;
end;

procedure showunhighlight;
begin
ivTextcolor(15);
ivTextbackground(0);
case wh of
     1:begin
            ivGotoxy(22,24);
            ivWrite('Save');
            ivGotoxy(22,24);
       end;
     2:begin
            ivGotoxy(29,24);
            ivWrite('Abort');
            ivGotoxy(29,24);
       end;
     3:begin
            ivGotoxy(37,24);
            ivWrite('Edit');
            ivGotoxy(37,24);
       end;
     4:begin
            ivGotoxy(44,24);
            ivWrite('Help');
            ivGotoxy(44,24);
       end;
     5:begin
            ivGotoxy(51,24);
            ivWrite('Quote');
            ivGotoxy(51,24);
       end;
end;
end;

begin
doquote:=FALSE;
dohelp:=FALSE;
ivGotoxy(2,24);
done:=FALSE;
ivTextcolor(15);
ivTextbackground(0);
clear_eol;
count_lines;
ivWrite('%080%[%150%Select an option: ');
if (linecnt=0) and (noabort) then begin
        ivWrite('%080%(Save)');
end else begin
        ivWrite('%080%(%150%Save%080%)');
end;
if not(noabort) then begin
        ivWrite(' (%150%Abort%080%) ');
end else begin
        ivWrite(' (Abort) ');
end;
ivWrite('(%150%Edit%080%) (%150%Help%080%)');
{

  Select an option: (Save) (Abort) (Edit) (Help)]ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

}


if (quoteavail) then ivWrite(' %080%(%150%Quote%080%)]ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ') else
ivwrite(']ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');
if (noabort) and (linecnt=0) then wh:=3 else wh:=1;
exit:=FALSE;
showhighlight;
repeat
c:=get_key;
      if (c = #0) and (key_source = sysop_key) then
      begin
         c := get_key;

         case c of
            'K':  c := ^S;     {LeftArrow}
            'M':  c := ^D;     {RightArrow}
            else
               c := #0;
         end;
      end;
            delay(70);

      if (c = #27) and (ivKeypressed) then
      begin
         c := get_key;   {time_key(120) **********************;}
         if c = '[' then c := get_key;
         if c = 'O' then c := get_key;

         case c of
            'C':  c := ^D;     {RightArrow}
            'D':  c := ^S;     {LeftArrow}

            #0:   c := #27;    {timeout - escape key}
         end;
      end;
case c of
     'S','s':if (linecnt=0) and (noabort) then begin end else begin
                     showunhighlight;
                     save:=TRUE;
                     exit:=TRUE;
                     done:=TRUE;
                     wh:=1;
             end;
     'A','a':if not(noabort) then begin
                     showunhighlight;
                     save:=FALSE;
                     exit:=TRUE;
                     done:=TRUE;
                     wh:=2;
             end;
     'E','e':begin
                  showunhighlight;
                  save:=false;
                  exit:=false;
                  done:=TRUE;
                  wh:=3;
             end;
     'H','h':begin
                  showunhighlight;
                  save:=false;
                  exit:=false;
                  done:=TRUE;
                  dohelp:=TRUE;
                  wh:=4;
     end;
     'Q','q':if (quoteavail) then begin
                  showunhighlight;
                  save:=false;
                  doquote:=TRUE;
                  exit:=false;
                  done:=TRUE;
                  wh:=5;
     end;
     #13:begin
              case wh of
                   1:if (linecnt=0) and (noabort) then begin end else begin
                     save:=TRUE;
                     exit:=TRUE;
                     done:=TRUE;
                     end;
                   2:if not(noabort) then begin
                     save:=FALSE;
                     exit:=TRUE;
                     done:=TRUE;
                     end;
                   3:begin
                     save:=false;
                     exit:=false;
                     done:=TRUE;
                     end;
                   4:begin
                     save:=false;
                     exit:=false;
                     done:=TRUE;
                     dohelp:=TRUE;
                     end;
                   5:if (quoteavail) then begin
                     save:=false;
                     exit:=false;
                     done:=TRUE;
                     doquote:=TRUE;
                     end;
              end;
         end;
     ^S:begin
             showunhighlight;
                                      dec(wh);
                                      if (noabort) and (wh=2) then dec(wh);
                                      if (noabort) and (linecnt=0) and (wh=1) then dec(wh);
                                      if not(quoteavail) then begin
                                      if (wh=0) then wh:=4;
                                      end else begin
                                      if (wh=0) then wh:=5;
                                      end;
        end;
     ^D:begin
             showunhighlight;
                                      inc(wh);
                                      if not(quoteavail) then begin
                                      if (wh=5) then wh:=1;
                                      if (noabort) and (linecnt=0) and (wh=1) then inc(wh);
                                      if (noabort) and (wh=2) then inc(wh);
                                      end else begin
                                      if (wh=6) then wh:=1;
                                      if (noabort) and (linecnt=0) and (wh=1) then inc(wh);
                                      if (noabort) and (wh=2) then inc(wh);
                                      end;
        end;
     #27:begin
         done:=TRUE;
         end;
end;
showhighlight;
until (done) or not(ivCarrier);
bottomline;
if (exit) then begin
   optionmenu:=1;
end else begin
     if (doquote) then optionmenu:=2 else
     if (dohelp) then optionmenu:=3 else optionmenu:=0;
end;
end;

function abortcheck: boolean;
var c:char;
    wh:byte;
    exit,done:boolean;
begin
ivGotoxy(1,24);
done:=FALSE;
ivTextcolor(15);
ivTextbackground(0);
clear_eol;
ivWrite('%080%À[%150%Abort & quit - are you sure? %080%(%150%YES%080%) (%150%NO%080%)]ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');
wh:=1;
exit:=FALSE;
ivTextcolor(15);
case wh of
     1:begin
            ivGotoxy(33,24);
            ivTextbackground(3);
            ivWrite('YES');
            ivGotoxy(39,24);
            ivTextbackground(0);
            ivWrite('NO');
            ivGotoxy(33,24);
       end;
     2:begin
            ivGotoxy(33,24);
            ivTextbackground(0);
            ivWrite('YES');
            ivGotoxy(39,24);
            ivTextbackground(3);
            ivWrite('NO');
            ivGotoxy(39,24);
       end;
end;
repeat
c:=get_key;
      if (c = #0) and (key_source = sysop_key) then
      begin
         c := get_key;

         case c of
            'K':  c := ^S;     {LeftArrow}
            'M':  c := ^D;     {RightArrow}
            else
               c := #0;
         end;
      end;
      delay(70);
      if (c = #27) and (ivKeypressed) then
      begin
         c := get_key;   {time_key(120) **********************;}
         if c = '[' then c := get_key;
         if c = 'O' then c := get_key;

         case c of
            'C':  c := ^D;     {RightArrow}
            'D':  c := ^S;     {LeftArrow}

            #0:   c := #27;    {timeout - escape key}
         end;
      end;
case c of
     'Y','y':begin
                     save:=FALSE;
                     exit:=TRUE;
                     done:=TRUE;
                     wh:=1;
             end;
     'N','n':begin
                     save:=FALSE;
                     exit:=FALSE;
                     done:=TRUE;
                     wh:=2;
             end;
     #13:begin
              case wh of
                   1:begin
                     save:=FALSE;
                     exit:=TRUE;
                     done:=TRUE;
                     end;
                   2:begin
                     save:=FALSE;
                     exit:=FALSE;
                     done:=TRUE;
                     end;
              end;
         end;
     ^S:begin
             if (wh=1) then wh:=2 else wh:=1;
        end;
     ^D:begin
             if (wh=1) then wh:=2 else wh:=1;
        end;
     #27:begin
              done:=TRUE;
         end;
end;
case wh of
     1:begin
            ivGotoxy(33,24);
            ivTextbackground(3);
            ivWrite('YES');
            ivGotoxy(39,24);
            ivTextbackground(0);
            ivWrite('NO');
            ivGotoxy(33,24);
       end;
     2:begin
            ivGotoxy(33,24);
            ivTextbackground(0);
            ivWrite('YES');
            ivGotoxy(39,24);
            ivTextbackground(3);
            ivWrite('NO');
            ivGotoxy(39,24);
       end;
end;
until (done) or not(ivCarrier);
bottomline;
abortcheck:=exit;
end;

function mln(s:string; l:integer):string;
var i:integer;
begin
  while (length(s)<l) do s:=s+' ';
  if (length(s)>l) then s:=copy(s,1,l);
  mln:=s;
end;

procedure quotemessage;
var topl,curl,x2:integer;
    c:char;
    done:boolean;
    maxquote:integer;
    lastquoted:integer;

procedure setupwindow;
begin
ivGotoxy(1,17);
ivTextcolor(8);
ivTextbackground(0);
ivWrite('Õ[');
ivTextcolor(15);
ivWrite('Quote Window');
ivTextcolor(8);
ivWrite(']ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¸');

   ivGotoxy(1,24);
   ivWrite('À[');
   ivTextcolor(15);
   ivWrite('ESC-End');
   ivTextcolor(8);
   ivWrite(']Ä[');
   ivTextcolor(15);
   ivWrite('ENTER-Quote');
   ivTextcolor(8);
   ivWrite(']Ä[');
   ivTextcolor(15);
   ivWrite('Up/Down-Scroll');
   ivTextcolor(8);
   ivWrite(']ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');
end;

procedure displayquote;
var x:integer;
begin
ivTextcolor(3);
ivTextbackground(0);
for x:=topl to (topl+5) do begin
ivGotoxy(1,(x+18)-topl);
clear_eol;
ivWrite(quote[x]);
end;
end;

procedure showposition;
begin
ivTextcolor(15);
ivTextbackground(3);
ivGotoxy(1,curl+17);
clear_eol;
ivWrite(mln(quote[topl+(curl-1)],79));
ivGotoxy(1,curl+17);
end;

procedure showunhighlight;
begin
ivTextcolor(3);
ivTextbackground(0);
ivGotoxy(1,curl+17);
clear_eol;
ivWrite(mln(quote[topl+(curl-1)],79));
ivGotoxy(1,curl+17);
end;

procedure countquote;
begin
while (maxquote>0) and (quote[maxquote]='') do dec(maxquote);
end;

begin
lastquoted:=0;
maxquote:=200;
countquote;
scrlines:=root-6;
scrollsiz:=(root-5)-6;
scroll_screen(0);
setupwindow;
topl:=1;
curl:=1;
displayquote;
done:=FALSE;
repeat
showposition;
c:=get_key;
      if (c = #0) and (key_source = sysop_key) then
      begin
         c := get_key;

         case c of
            'H','8':  c := ^E;     {UpArrow}
            'G','7':  C := ^L;     {Home}
            'I','9':  c := ^R;     {PgUp}
            'O','1':  c := ^P;     {End}
            'P','2':  c := ^X;     {DownArrow}
            'Q','3':  c := ^C;     {PgDn}
            else
               c := #0;
         end;
      end;
      delay(70);
      if (c = #27) and (ivKeypressed) then
      begin
         c := get_key;   {time_key(120) **********************;}
         if c = '[' then c := get_key;
         if c = 'O' then c := get_key;

         case c of
            'A','8':  c := ^E;     {UpArrow}
            'B','2':  c := ^X;     {DownArrow}
            'H','7':  c := ^L;     {Home}
            'K','1',                 {End - PROCOMM+}
            'R':  c := ^P;     {End - GT}
            'r','9':  c := ^R;     {PgUp}
            'q','3':  c := ^C;     {PgDn}

            #0:   c := #27;    {timeout - escape key}
         end;
      end;
case c of
     #13:begin
              if (topl+(curl-1)<>lastquoted) then begin
              lastquoted:=(topl+(curl-1));
              insert_line(quote[topl+(curl-1)]);
              inc(cline);
              ivTextcolor(default_fore);
              ivTextbackground(default_back);
              scroll_screen(0);
              showunhighlight;
              inc(curl);
              if (curl=7) then begin
                if (topl+6<=maxquote) then begin
                inc(topl);
                displayquote;
                end;
                curl:=6;
              end;
              end;
         { insert highlighted quote line into the message. }
         end;
     ^L:begin
             lastquoted:=0;
             showunhighlight;
             curl:=1;
             topl:=1;
             displayquote;
        end;
     ^P:begin
             lastquoted:=0;
             showunhighlight;
             curl:=6;
             topl:=maxquote-5;
             displayquote;
        end;
     ^R:begin
             lastquoted:=0;
             showunhighlight;
             if (topl=1) then begin
                curl:=1;
             end else begin
             dec(topl,6);
             if (topl<1) then topl:=1;
             displayquote;
             end;
        end;
     ^E:begin
             lastquoted:=0;
             showunhighlight;
             dec(curl);
             if (curl=0) then begin
                if (topl>1) then begin
                   dec(topl);
                   displayquote;
                end;
                curl:=1;
             end;
        end;
     ^C:begin
             lastquoted:=0;
             showunhighlight;
             if (topl+5>=maxquote) then begin
                curl:=(maxquote-topl)+1;
             end else begin
             if (topl+10>maxquote) then begin
                topl:=maxquote-5;
                displayquote;
             end else begin
             inc(topl,6);
             displayquote;
             end;
             end;
        end;
     ^X:begin
             lastquoted:=0;
             showunhighlight;
             inc(curl);
             if (topl+(curl-1)>maxquote) then begin
                dec(curl);
             end else
             if (curl=7) then begin
                if (topl+6<=maxquote) then begin
                inc(topl);
                displayquote;
                end;
                curl:=6;
             end;
        end;
     #27:begin
              done:=TRUE;
         end;
end;
until (done) or not(ivCarrier);
ivTextcolor(7);
ivTextbackground(0);
scrlines:=root;
scrollsiz:=root-5;
for x2:=1 to 7 do begin
ivGotoxy(1,x2+16);
clear_eol;
end;
bottomline;
scroll_screen(0);
end;

procedure selecttagline;
var topl,curl,x2:integer;
    c:char;
    done:boolean;
    maxquote:integer;
    lastquoted:integer;
    Tagline:tagrec;
    Tagf:file of tagrec;

procedure setupwindow;
begin
ivGotoxy(1,17);
ivTextcolor(8);
ivTextbackground(0);
ivWrite('Õ[');
ivTextcolor(15);
ivWrite('Pick Tagline');
ivTextcolor(8);
ivWrite(']ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¸');

   ivGotoxy(1,24);
   ivWrite('À[');
   ivTextcolor(15);
   ivWrite('ESC-None');
   ivTextcolor(8);
   ivWrite(']Ä[');
   ivTextcolor(15);
   ivWrite('ENTER-Select');
   ivTextcolor(8);
   ivWrite(']Ä[');
   ivTextcolor(15);
   ivWrite('Up/Down-Scroll');
   ivTextcolor(8);
   ivWrite(']ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');
end;

function gettagline(x:integer):string;
begin
seek(tagf,x-1);
read(tagf,tagline);
gettagline:=tagline.tag;
end;

procedure displayquote;
var x:integer;
begin
ivTextcolor(3);
ivTextbackground(0);
for x:=topl to (topl+5) do begin
ivGotoxy(1,(x+18)-topl);
clear_eol;
ivWrite(gettagline(x));
end;
end;

procedure showposition;
begin
ivTextcolor(15);
ivTextbackground(3);
ivGotoxy(1,curl+17);
ivWrite(mln(gettagline(topl+(curl-1)),79));
ivGotoxy(1,curl+17);
end;

procedure showunhighlight;
begin
ivTextcolor(3);
ivTextbackground(0);
ivGotoxy(1,curl+17);
ivWrite(mln(gettagline(topl+(curl-1)),79));
ivGotoxy(1,curl+17);
end;

begin
if (tagdir='') then exit;
assign(tagf,tagdir);
{$I+} reset(tagf); {$I+}
if (ioresult<>0) then begin
exit;
end;
lastquoted:=0;
maxquote:=filesize(tagf);
scrlines:=root-6;
scrollsiz:=(root-5)-6;
scroll_screen(0);
setupwindow;
topl:=1;
curl:=1;
displayquote;
done:=FALSE;
repeat
showposition;
c:=get_key;
      if (c = #0) and (key_source = sysop_key) then
      begin
         c := get_key;

         case c of
            'H','8':  c := ^E;     {UpArrow}
            'G','7':  C := ^L;     {Home}
            'I','9':  c := ^R;     {PgUp}
            'O','1':  c := ^P;     {End}
            'P','2':  c := ^X;     {DownArrow}
            'Q','3':  c := ^C;     {PgDn}

            else
               c := #0;
         end;
      end;
      delay(70);
      if (c = #27) and (ivKeypressed) then
      begin
         c := get_key;   {time_key(120) **********************;}
         if c = '[' then c := get_key;
         if c = 'O' then c := get_key;

         case c of
            'A','8':  c := ^E;     {UpArrow}
            'B','2':  c := ^X;     {DownArrow}
            'H','7':  c := ^L;     {Home}
            'K','1',                 {End - PROCOMM+}
            'R':  c := ^P;     {End - GT}
            'r','9':  c := ^R;     {PgUp}
            'q','3':  c := ^C;     {PgDn}

            #0:   c := #27;    {timeout - escape key}
         end;
      end;

case c of
     #13:begin
              if (topl+(curl-1)<>lastquoted) then begin
              lastquoted:=(topl+(curl-1));
              cline:=linecnt+1;
              insert_line('');
              cline:=linecnt+1;
              insert_line('... '+gettagline(topl+(curl-1)));
              inc(cline);
              done:=TRUE;
              end;
         { insert highlighted quote line into the message. }
         end;
     ^L:begin
             lastquoted:=0;
             showunhighlight;
             curl:=1;
             topl:=1;
             displayquote;
        end;
     ^P:begin
             lastquoted:=0;
             showunhighlight;
             curl:=6;
             topl:=maxquote-5;
             displayquote;
        end;
     ^R:begin
             lastquoted:=0;
             showunhighlight;
             if (topl=1) then begin
                curl:=1;
             end else begin
             dec(topl,6);
             if (topl<1) then topl:=1;
             displayquote;
             end;
        end;
     ^E:begin
             lastquoted:=0;
             showunhighlight;
             dec(curl);
             if (curl=0) then begin
                if (topl>1) then begin
                   dec(topl);
                   displayquote;
                end;
                curl:=1;
             end;
        end;
     ^C:begin
             lastquoted:=0;
             showunhighlight;
             if (topl+5>=maxquote) then begin
                curl:=(maxquote-topl)+1;
             end else begin
             if (topl+10>maxquote) then begin
                topl:=maxquote-5;
                displayquote;
             end else begin
             inc(topl,6);
             displayquote;
             end;
             end;
        end;
     ^X:begin
             lastquoted:=0;
             showunhighlight;
             inc(curl);
             if (topl+(curl-1)>maxquote) then begin
                dec(curl);
             end else
             if (curl=7) then begin
                if (topl+6<=maxquote) then begin
                inc(topl);
                displayquote;
                end;
                curl:=6;
             end;
        end;
     #27:begin
              done:=TRUE;
         end;
end;
until (done) or not(ivCarrier);
close(tagf);
ivTextcolor(7);
ivTextbackground(0);
scrlines:=root;
scrollsiz:=root-5;
for x2:=1 to 7 do begin
ivGotoxy(1,x2+16);
clear_eol;
end;
bottomline;
scroll_screen(0);
end;

function visual_edit: boolean;
var
   key:  char;
   i:    integer;
   testb:byte;
   done,domenu:boolean;

begin
   {disable function key polling during display}
   process_fkeys := false;
   done:=FALSE;

   {determine initial cursor and screen position}
   ccol := curlength+1;
   topline := 1;
   while (cline-topline) > (scrollsiz+3) do
      inc(topline,scrollsiz);

   {paint the initial screen}
   window(1,1,80,24);
   prepare_screen;
   display_insert_status;
   reposition;


   {process visual commands}
   repeat
      ivTextcolor(7);
      ivTextbackground(0);
      key := get_key;

      {translate local keyboard into wordstar keys}
      if (key = #0) and (key_source = sysop_key) then
      begin
         key := get_key;

         case key of
            'G','7':  key := ^L;     {Home}
            'H','8':  key := ^E;     {UpArrow}
            'I','9':  key := ^R;     {PgUp}
            'K','4':  key := ^S;     {LeftArrow}
            'M','6':  key := ^D;     {RightArrow}
            'O','1':  key := ^P;     {End}
            'P','2':  key := ^X;     {DownArrow}
            'Q','3':  key := ^C;     {PgDn}
            'R','0':  key := ^V;     {Ins}
            'S','.':  key := ^G;     {Del}
            's':  key := ^A;     {Ctrl-Left}
            't':  key := ^F;     {Ctlr-Right}


            else
               {dispatch_function_key(key);        *****************}
               key := #0;
         end;
      end;


      {translate vt102 / ansi-bbs keyboard into wordstar keys}
      if (key = #27) and (ivKeypressed) then
      begin
         key := get_key;   {time_key(120) **********************;}
         if key = '[' then key := get_key;
         if key = 'O' then key := get_key;

         case key of
            'A','8':  key := ^E;     {UpArrow}
            'B','2':  key := ^X;     {DownArrow}
            'C','6':  key := ^D;     {RightArrow}
            'D','4':  key := ^S;     {LeftArrow}
            'H','7':  key := ^L;     {Home}
            'K','1',                 {End - PROCOMM+}
            'R':  key := ^P;     {End - GT}
            'r','9':  key := ^R;     {PgUp}
            'q','9':  key := ^C;     {PgDn}
            'n','0':  key := ^V;     {Ins}

            #0:   key := #27;    {timeout - escape key}
         end;
      end;


      {process each character typed}
      case key of
         ^A:      if not(noabort) then begin
                     done:=TRUE;
                     save:=FALSE;
                     if (done) and not(save) then begin
                        done:=abortcheck;
                     end;
                     reposition;
                  end;
         ^B:      visual_reformat;
         ^C:      page_down;
         ^D:      cursor_right;
         ^E:      cursor_up;
         ^F:      cursor_wordright;
         ^G:      delete_char;
         ^I:      cursor_tab;
         ^J:      join_lines;
         ^L:      cursor_begline;
         ^M:      cursor_newline;
         ^N:      begin
                     split_line;
                     reposition;
                  end;

         ^O:      redisplay;
         ^P:      cursor_endline;
{         ^Q:      visual_quote_original; ****************}
         ^Q:
                if (quoteavail) then begin
                  quotemessage;
                  reposition;
                  end;
         ^R:      page_up;
         ^S:      cursor_left;
         ^T:      delete_wordright;
         ^V:      begin
                     insert_mode := not insert_mode;
                     display_insert_status;
                     reposition;
                  end;
         ^X:      cursor_down;
         ^Y:      visual_delete_line;
         ^Z:      begin
                  if (linecnt<>0) then begin
                  save:=TRUE;
                  done:=TRUE;
                  end else if not(noabort) then begin
                        save:=FALSE;
                        done:=abortcheck;
                  end;
                  end;

         #$7f,^H: begin
                     cursor_left;
                     if insert_mode then
                        delete_char;
                  end;

         ^U,
         #27:begin
                  domenu:=FALSE;
                  if (ivKeypressed) then begin
                     key:=ivReadChar;
                     if (key='[') then begin
                        if (ivKeypressed) then begin
                        key:=ivReadChar;
                        case key of
                             'A':begin
                                      cursor_up;
                                 end;
                             'B':begin
                                      cursor_down;
                                 end;
                             'C':begin
                                      cursor_right;
                                 end;
                             'D':begin
                                      cursor_left;
                                 end;
                        end;
                        end;
                     end;
                  end else domenu:=TRUE;
                  if (domenu) then begin
                     testb:=optionmenu;
                     case testb of
                          1:done:=true;
                          2:begin
                                               if (quoteavail) then begin
                                               quotemessage;
                                               reposition;
                                               end;
                          end;
                          3:begin
                            dohelp;
                            end;
                          else done:=FALSE;
                     end;
                     if (save) and (linecnt=0) then save:=FALSE;
                     if (done) and not(save) then begin
                        done:=abortcheck;
                     end;
                     reposition;
                  end;
             end;

         ' '..#255:     {all other characters are self-inserting}
                  begin
                  if (key='/') and (ccol=1) then begin
                     testb:=optionmenu;
                     case testb of
                          1:done:=true;
                          2:begin
                                               if (quoteavail) then begin
                                               quotemessage;
                                               reposition;
                                               end;
                          end;
                          3:begin
                            dohelp;
                            end;
                          else done:=FALSE;
                     end;
                     if (save) and (linecnt=0) then save:=FALSE;
                     if (done) and not(save) then begin
                        done:=abortcheck;
                     end;
                     reposition;
                  end else insert_char(key);
                 end;
      end;

   until (done) or not(ivCarrier);

   position(1,23);
   process_fkeys := true;
   if (save) then visual_edit:=TRUE else visual_edit:=FALSE;
end;


procedure gettaglinedir;
begin
tagdir:=adrv(systat.gfilepath)+'TAGLINES.DAT';
end;

  function getver:string;
  begin
          getver:=version;
  end;

procedure helpscreen;
begin
writeln('Syntax:  nxEDIT [options]');
writeln;
writeln('        -N[Node]      Current Node Number to use');
writeln('        -K            Local communications only');
writeln('        -D[path]      Path where MSGINF and MSGTMP files are found');
writeln;
halt;
end;

procedure getparams;
var s2:string;
    x:integer;
begin
if (paramcount=0) then helpscreen;
x:=1;
while (x<=paramcount) do begin
        s2:=paramstr(x);
        if (s2[1]='-') or (s2[1]='/') then
        case upcase(s2[2]) of
                'N':cnode:=value(copy(s2,3,length(s2)-2));
                'K':localonly:=TRUE;
                'A':noabort:=TRUE;
                'D':begin
                        dropfilepath:=copy(s2,3,length(s2)-2);
                        if (dropfilepath[length(dropfilepath)]<>'\') then
                                dropfilepath:=dropfilepath+'\';
                    end;
                'Q':quotedirect:=TRUE;
                'O':begin
                    onelinetop:=TRUE;
                    root:=20;
                    scrlines:=root;
                    scrollsiz:=root-5;
                    topscreen:=4;
                    end;
                '?':helpscreen;
        end;
        inc(x);
end;
end;

procedure title;
begin
writeln('nxEDIT v'+version+' - Fullscreen editor for Nexus BBS Software');
writeln('(c) Copyright 1996-2001 George A. Roberts IV. All rights reserved.');
writeln;
end;

var
 a,n: word;
 f: system.text;
 systatf:file of matrixREC;
 nexusdir:string;
 err:word;
 c12:char;

begin;
 title;
 cnode:=0;
 helpon:=false;
 dropfilepath:='';
 nexusdir:=getenv('NEXUS');
 if (nexusdir[length(nexusdir)]='\') then nexusdir:=copy(nexusdir,1,length(nexusdir)-1);
 start_dir:=nexusdir;
 assign(systatf,nexusdir+'\MATRIX.DAT');
 {$I-} reset(systatf); {$I+}
 if (ioresult<>0) then begin
        writeln('Error opening '+allcaps(NEXUSDIR)+'\MATRIX.DAT');
        halt;
 end;
 read(systatf,systat);
 close(systatf);
 getparams;
 if (cnode<>0) then begin
 filemode:=66;
 assign(onf,adrv(systat.gfilepath)+'USER'+cstrn(cnode)+'.DAT');
 {$I-} reset(onf); {$I+}
 if (ioresult<>0) then begin
        writeln('Node error:  Node not in use.');
        halt;
 end;
 read(onf,o);
 close(onf);
 if (o.comport=0) then localonly:=TRUE;
 end;
 if not(localonly) then begin
        if (o.Lockbaud=0) then
        ivInstallModem(o.comport,o.baud*10,err)
        else
        ivInstallModem(o.comport,o.lockbaud*10,err);
        if (err=1) then begin
                writeln('Comport Error: Error opening comport.');
                halt;
        end;
        if (o.emulation<>0) then okansi:=TRUE;
 end else begin
        okansi:=TRUE;
        comtype:=0;
 end;
 updatestatus;
 areaname:='';
 datetime:='';
 fromusername:='';
 tousername:='';
 mnum:=0;
 priv:='';
 subject:='';
 gettaglinedir;
 if exist(dropfilepath+'MSGINF') then begin;
  assign(f,dropfilepath+'MSGINF');
  reset(f);
  readln(f,fromusername);
  readln(f,tousername);
  readln(f,subject);
  readln(f,mnum);
  readln(f,areaname);
  readln(f,priv);
  close(f);
 end;
 new(text);
 fillchar(text^,sizeof(text^),#0);
 fillchar(quote,sizeof(quote),#0);
 assign(f,dropfilepath+'MSGTMP');
 n:=0;
 {$I-}
 reset(f);
 {$I+}
 if ioresult=0 then begin;
  while not eof(f) and (n<200) do begin;
   inc(n);
   readln(f,quote[n]);
  end;
  if (n<>0) then quoteavail:=TRUE;
  close(f);
 end;
 cline := 1;
 if (n<>0) and (quotedirect) then begin
     for err:=1 to n do begin
          text^[err]:=quote[err];
     end;
     cline:=n+1;
     quoteavail:=FALSE;
 end;
 count_lines;
 if not visual_edit then begin;
  clear_screen;
  window(1,1,80,25);
  clrscr;
  assign(f,dropfilepath+'MSGTMP');
  {$I-} erase(f); {$I+}
  if (ioresult<>0) then begin end;
  dispose(text);
  ivDeInstallModem;
  halt(1);
 end;
 count_lines;
 if linecnt<>0 then begin;
  selecttagline;
  clear_screen;
  assign(f,dropfilepath+'MSGTMP');
  rewrite(f);
  for a:=1 to linecnt do writeln(f,text^[a]);
  if (tagdir='') then writeln(f,'');
{  writeln(f,' +  nxEDIT v'+getver); }
  close(f);
 end;
 window(1,1,80,25);
 clrscr;
 dispose(text);
 ivDeInstallModem;
 halt(0);
end.
