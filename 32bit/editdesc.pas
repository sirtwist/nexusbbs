unit editdesc;

interface

uses dos,crt,myio,misc,winttt5;


function editdescription(maxlines:integer):boolean;

implementation

const
   topscreen = 1;       {first screen line for text entry}
   scrlines: word = 21;       {number of screen lines for text entry}
   scrsize: word = 21;
   scrollsiz: word = 13;      {number of lines to scroll by}
   insert_mode: boolean = true;
   max_msg_lines: word = 400;
   wwrap=43;
   save:boolean=FALSE;
   changed:boolean=FALSE;
var
   tempdir:string;
   exitmode: boolean;
   key: char;
   w2:windowrec;
   process_fkeys: boolean;
   par: string;
   linenum: word;
   linecnt: word;
   topline: integer;    {message line number at top of screen}
   cline:   integer;    {current message line number}
   ccol:    integer;    {current column number}

   phyline: array[1..21] of string[46];
                        {physical display text}

   pleft:   integer;    {previous value of minutes_left}


   text: array[1..400] of string[46];


procedure clear_eol;
begin;
 clreol;
end;

procedure space;
begin;
 write(' ');
end;

procedure dyellow(s: string);
begin;
 textcolor(yellow);
 write(s);
end;

procedure dgreen(s: string);
begin;
 textcolor(lightgreen);
 write(s);
end;

procedure dgrey(s: string);
begin;
 textcolor(lightgray);
 write(s);
end;

procedure dmagenta(s: string);
begin;
 textcolor(magenta);
 write(s);
end;

procedure dcyan(s: string);
begin;
 textcolor(cyan);
 write(s);
end;


procedure default_color;
begin;
 textcolor(7);
end;

procedure position(x,y: byte);
begin;
 gotoxy(x,y);
end;

procedure insert_line(contents: string);
var
 i: integer;
begin
 for i := max_msg_lines downto cline+1 do text[i] := text[i-1];
 text[cline] := contents;
 if cline < linecnt then inc(linecnt);
 if cline > linecnt then linecnt := cline;
end;

procedure delete_line;
var
 i: integer;
begin
 for i := cline to max_msg_lines do text[i]:=text[i+1];
 text[max_msg_lines] := '';
 if (cline <= linecnt) and (linecnt > 1) then dec(linecnt);
end;

procedure remove_trailing;
begin
 while text[cline][length(text[cline])]=' ' do delete(text[cline],length(text[cline]),1);
end;

procedure append_space;
begin
 text[cline]:=text[cline]+' ';
end;

function curlength: integer;
begin
 curlength:=length(text[cline]);
end;


procedure clear_screen;
begin;
 clrscr;
end;

procedure count_lines;
begin;
 linecnt := max_msg_lines;
 while (linecnt > 0) and (length(text[linecnt]) = 0) do dec(linecnt);
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
 if ccol <= curlength then curchar:=text[cline][ccol] else curchar := ' ';
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
 if curlength = 0 then lastchar := ' ' else lastchar:=text[cline][curlength];
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
 phyline[cline-topline+1]:=text[cline];
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
   dashdisp:boolean;

begin
   dashdisp:=FALSE;
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
         if not(dashdisp) then begin
         dGREEN('--');
         dashdisp:=TRUE;
         end;
         clear_eol;
         phyline[phline] := '--';
      end
      else

      begin
         if text[cline]<>phyline[phline] then
         begin
            reposition;
            default_color;
            if curlength > 0 then
               write(text[cline]);
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
   ccol := 45;
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
      write(curchar);
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
   if (curlength + length(text[cline+1])) >= 45 then
      exit;

   if (lastchar <> ' ') then
      append_space;
   text[cline]:=text[cline]+text[cline+1];
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
   par := copy(text[cline],ccol,45);

   text[cline][0] := chr(ccol-1);       {remove it from the current line}
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
            text[cline]:=text[cline]+copy(text[cline+1],1,ccol-1);

            {remove the hoisted word}
            inc(cline);
            while (curchar = ' ') and (ccol <= curlength) do
               inc(ccol);
            delete(text[cline],1,ccol-1);
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
   par := copy(text[cline],ccol+1,45);

   {remove it from current line and refresh screen}
   text[cline][0] := chr(ccol);
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
      insert(c,text[cline],ccol);

      {update display line following cursor}
      default_color;
      write(copy(text[cline],ccol,45));

      {position cursor for next insertion}
      inc(ccol);
      reposition;
   end
   else

   {append a character to the end of a line}
   begin
      while curlength < ccol do
         append_space;
      text[cline][ccol] := c;

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
      delete(text[cline],ccol,1);
      default_color;
      write(copy(text[cline],ccol,45));
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


(* ----------------------------------------------------------- *)
procedure display_message_header;
begin
   position(1,1);
   reposition;
end;

(* ----------------------------------------------------------- *)
procedure prepare_screen;
var
   i: integer;
begin
   setwindow(w2,15,1,64,23,3,0,8,'Edit Description',TRUE);
   window(17,2,62,22);
   linenum := 1;

   position(1,1);

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


function mln(s:string; l:integer):string;
var i:integer;
begin
  while (length(s)<l) do s:=s+' ';
  if (length(s)>l) then s:=copy(s,1,l);
  mln:=s;
end;

function visual_edit: boolean;
var
   key:  char;
   i:    integer;
   testb:byte;
   done,domenu,autosave:boolean;

begin
   {disable function key polling during display}
   done:=FALSE;

   {determine initial cursor and screen position}
   cline := 1;
   ccol := 1;
   topline := 1;
   while (cline-topline) > (scrollsiz+3) do
      inc(topline,scrollsiz);

   {paint the initial screen}
   window(1,1,80,24);
   prepare_screen;
   reposition;


   {process visual commands}
   repeat
      textcolor(7);
      textbackground(0);
      key := readkey;

      {translate local keyboard into wordstar keys}
      if (key = #0) then
      begin
         key := readkey;

         case key of
            #68:  begin
                        autosave:=TRUE;
                        done:=TRUE;
                        key:=#0;
                  end;
            'G':  key := ^L;     {Home}
            'H':  key := ^E;     {UpArrow}
            'I':  key := ^R;     {PgUp}
            'K':  key := ^S;     {LeftArrow}
            'M':  key := ^D;     {RightArrow}
            'O':  key := ^P;     {End}
            'P':  key := ^X;     {DownArrow}
            'Q':  key := ^C;     {PgDn}
            'R':  key := ^V;     {Ins}
            'S':  key := ^G;     {Del}
            's':  key := ^A;     {Ctrl-Left}
            't':  key := ^F;     {Ctlr-Right}


            else
               {dispatch_function_key(key);        *****************}
               key := #0;
         end;
      end;



      {process each character typed}
      case key of
         ^B:      begin changed:=TRUE; visual_reformat; end;
         ^C:      page_down;
         ^D:      cursor_right;
         ^E:      cursor_up;
         ^F:      cursor_wordright;
         ^G:      begin changed:=TRUE; delete_char; end;
         ^I:      cursor_tab;
         ^J:      begin
                join_lines;
                changed:=TRUE;
                end;
         ^L:      cursor_begline;
         ^M:      cursor_newline;
         ^N:      begin
                     split_line;
                     reposition;
                  end;

         ^O:      redisplay;
         ^P:      cursor_endline;
         ^R:      page_up;
         ^S:      cursor_left;
         ^V:      begin
                     insert_mode := not insert_mode;
                     if (insert_mode) then halfcursor else oncursor;
                     reposition;
                  end;
         ^X:      cursor_down;
         ^Y:      begin
                  visual_delete_line;
                  changed:=TRUE;
                  end;

         #$7f,^H: begin
                     changed:=TRUE;
                     cursor_left;
                     {if insert_mode then}
                        delete_char;
                  end;

         ^U,
         #27:begin
                  done:=TRUE;
             end;

         ' '..#255:begin     {all other characters are self-inserting}
                  changed:=TRUE;
                  insert_char(key);
                  end;
      end;

   until (done);

   position(1,23);
   oncursor;
   if (changed) then begin
   if not(autosave) then
   autosave:=pynqbox('Save Changes? ');
   visual_edit:=autosave;
   end else visual_edit:=FALSE;
end;

function adrv(s,start_dir:string):string;
var 
  s2:string;
begin
{$IFDEF LINUX}
  adrv := s;
{$ELSE}
  s2:=s;
  if (s2<>'') then begin
    if (s2[2]<>':') then
      if (s2[1]<>'\') then 
        s2:=start_dir+'\'+s2
      else 
        s2:=copy(start_dir,1,2)+s2;
  end else begin
    s2:=start_dir+'\';
  end;
  adrv:=s2;
{$ENDIF}
end;


procedure gettempdir;
var systatf:file of MatrixREC;
    systat:MatrixREC;
    nexusdir:string;
begin
nexusdir:=GETENV('NEXUS');
if (nexusdir[length(nexusdir)]<>'\') then nexusdir:=nexusdir+'\';
assign(systatf,nexusdir+'MATRIX.DAT');
{$I-} reset(systatf); {$I+}
if (ioresult<>0) then begin
   tempdir:='';
   exit;
end;
read(systatf,systat);
close(systatf);
tempdir:=adrv(systat.temppath,copy(nexusdir,1,length(nexusdir)-1));
end;

function editdescription(maxlines:integer):boolean;
var
 a,n: word;
 f: system.text;
 tempbool:boolean;
begin;
 tempbool:=FALSE;
 changed:=FALSE;
 save:=FALSE;
 insert_mode:=TRUE;
 if (maxlines>0) and (maxlines<=400) then max_msg_lines:=maxlines;
 if (insert_mode) then halfcursor else oncursor;
 gettempdir;
 fillchar(text,sizeof(text),#0);
 assign(f,tempdir+'FILETMP');
 {$I-}
 reset(f);
 {$I+}
 if ioresult=0 then begin;
  n:=0;
  while not eof(f) do begin;
   inc(n);
   readln(f,text[n]);
  end;
  close(f);
 end;
 count_lines;
 tempbool:=visual_edit;
 if not(tempbool) then begin;
 removewindow(w2);
  assign(f,tempdir+'FILETMP');
  {$I-} erase(f); {$I+}
  if (ioresult<>0) then begin end;
  editdescription:=tempbool;
  exit;
 end;
 count_lines;
 if linecnt<>0 then begin;
  assign(f,tempdir+'FILETMP');
  rewrite(f);
  for a:=1 to linecnt do writeln(f,text[a]);
  close(f);
 end;
 removewindow(w2);
 editdescription:=tempbool;
end;

end.
