{$A+,B+,D-,E+,F+,I+,L+,N-,R-,S+,V-,O+}
unit myio;

interface

uses
  crt, dos;

const
  infield_seperators:set of char=[' ','\','.'];
  vidseg:word=$B800;
  ismono:boolean=FALSE;
  showcontrolbox:boolean=FALSE;
  yndefault:boolean=TRUE;
  curon:boolean=TRUE;

type
  listtemprec =
  RECORD
     list:string[120];
     tagged:boolean;
  END;
     
  windowrec = array[0..4003] of byte;
  infield_special_function_proc_rec=procedure(c:char);
  returntype = RECORD
        kind:byte;  { Enter Pressed  -  1
                      Esc Pressed    -  2
                      Ins Pressed    -  3
                      Del Pressed    -  4
                      Alt-M Pressed  -  5
                      Other pressed  -  254
                      Other pressed (scan code) - 0 }
        high:byte;  { Highest byte in DATA that is used }
        data:array[1..100] of integer;

                    { Format -   Case Kind of

                        0 - first value is ascii character, if 0, then second
                                value is scancode

                        1 - (none tagged)  first value is item hit enter on
                            (some tagged)  all values are passed that were
                                           tagged
                        2 - data is empty
                        3 -                first value passed is item insert
                                           was pressed on
                        4 - (none tagged)  first value is item hit del on
                            (some tagged)  all values are passed that were
                                           tagged
                        5 - (none tagged)  key is ignored
                            (some tagged)  all values are passed in order
                                           from top to bottom that were tagged
                                           and last item in data is the item
                                           to move all items (in order) in
                                           before
                    }
        end;
  listptr = ^listtype;
  listtype = RECORD
        p:listptr;
        n:listptr;
        list:string[120];
  end;

const
  hback:byte=255;
  infield_func_keys:boolean=FALSE;
  infield_func_keys_allowed:string='';
  infield_func_key_pressed:char=#0;
  infield_only_allow_on:boolean=FALSE;
  infield_arrow_exit:boolean=FALSE;
  infield_showmci:boolean=TRUE;
  infield_arrow_exited:boolean=FALSE;
  infield_arrow_exited_keep:boolean=FALSE;
  infield_special_function_on:boolean=FALSE;
  infield_escape_exited:boolean=FALSE;
  infield_arrow_exit_typedefs:boolean=FALSE;
  infield_normal_exit_keydefs:boolean=FALSE;
  infield_normal_exited:boolean=FALSE;
  infield_allcaps:boolean=FALSE;
  infield_numbers_only:boolean=FALSE;
  infield_address:boolean=FALSE;
  infield_maxshow:byte=0;
  infield_insert:boolean=TRUE;
  infield_put_slash:boolean=FALSE;
  infield_no_slash_blank:boolean=TRUE;
  infield_show_colors:boolean=FALSE;
  infield_escape_zero:boolean=FALSE;
  infield_escape_blank:boolean=FALSE;
  infield_escape_save:boolean=FALSE;
  infield_putatend:boolean=FALSE;
  infield_clear:boolean=FALSE;
  listbox_f10:boolean=TRUE;
  listbox_f10_pressed:boolean=FALSE;
  listbox_escape:boolean=TRUE;
  listbox_enter:boolean=TRUE;
  listbox_insert:boolean=TRUE;
  listbox_delete:boolean=TRUE;
  listbox_tag:boolean=TRUE;
  listbox_move:boolean=TRUE;
  listbox_goto:boolean=FALSE;
  listbox_goto_offset:integer=0;
  listbox_allow_extra:boolean=FALSE;
  listbox_allow_extra_func:boolean=FALSE;
  listbox_extrakeys:string='';
  listbox_extrakeys_func:string='';
  listbox_bottom:string[40]='';
  listbox_help:string[27]='';
  infield_min_value:longint=-1;
  infield_restrict_list:string='';
  infield_max_value:longint=-1;
  pynqbox_escape:boolean=FALSE;
  titlefore:byte=10;
  titleback:byte=0;

var
  infield_out_fgrd,
  infield_out_bkgd,
  infield_inp_fgrd,
  infield_inp_bkgd:byte;
  infield_last_arrow,
  infield_last_normal:byte;
  infield_only_allow:string;
  infield_special_function_proc:infield_special_function_proc_rec;
  infield_special_function_keys:string;
  infield_arrow_exit_types:string;
  infield_normal_exit_keys:string;
  w:windowrec;

procedure cursoron(b:boolean);
procedure infield1(x,y:byte; var s:string; len:byte);
procedure infielde(var s:string; len:byte);
procedure infield(var s:string; len:byte);
function l_yn:boolean;
function l_pynq(s:string):boolean;
procedure cwrite(s:string);
procedure cwriteat(x,y:integer; s:string);
function cstringlength(s:string):integer;
Procedure DrawWindow2(x1,y1,x2,y2,tpe,bk,f1,f2:integer;s:string);
Procedure DrawWindow3(var w:windowrec; x1,y1,x2,y2,tpe,bk,f1,f2:integer;s:string);
procedure cwritecentered(y:integer; s:string);
procedure writecentered(y:integer; s:string);
procedure box(linetype,TLX,TLY,BRX,BRY:integer;title:string;tcolor,bcolor:integer;shadow:boolean);
procedure boxgray(linetype,TLX,TLY,BRX,BRY:integer; title:string;tcolor,bcolor:integer;shadow:boolean);
procedure checkvidseg;
procedure savescreen(var wind:windowrec; TLX,TLY,BRX,BRY:integer);
procedure setwindowgray(var wind:windowrec; TLX,TLY,BRX,BRY,tcolr,bcolr,boxtype:integer;title:string;shadow:boolean);
procedure setwindow(var wind:windowrec; TLX,TLY,BRX,BRY,tcolr,bcolr,boxtype:integer;title:string;shadow:boolean);
procedure setwindow2(var wind:windowrec; TLX,TLY,BRX,BRY,tcolr,bcolr,boxtype:integer;title,title2:string;shadow:boolean);
procedure setwindow3(var wind:windowrec; TLX,TLY,BRX,BRY,tcolr,bcolr,boxtype:integer;title,title2:string;shadow:boolean);
procedure setwindow4(var wind:windowrec; TLX,TLY,BRX,BRY,tcolr,bcolr,boxtype:integer; title,title2:string;shadow:boolean);
procedure setwindow5(var wind:windowrec; TLX,TLY,BRX,BRY,tcolr,bcolr,boxtype:integer; title,title2:string;shadow:boolean);
procedure removewindow(wind:windowrec);
procedure removewindow1(wind:windowrec);
procedure listbox(var wind:windowrec;var return:returntype;var ti,si:integer;lp:listptr; TLX,TLY,BRX,BRY,tcolr,bcolr,
        boxtype:integer;title,title2:string;shadow:boolean);
procedure newlistbox(var wind:windowrec;var return:returntype;fname:string;var ti,si:longint; TLX,TLY,BRX,BRY,tcolr,bcolr,
        boxtype:integer;title,title2:string;shadow:boolean);
procedure movewindow(wind:windowrec; TLX,TLY:integer);
function pynqbox(s:string):boolean;
procedure displaybox(s:string; d:integer);
procedure displaybox2(var w:windowrec; s:string);
procedure displaybox3(y:integer; var w:windowrec; s:string);

implementation

{uses winttt5;}
uses inptmisc;

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
var y,m,d:string[3];
    yy,mm,dd,dow:word;
begin
  getdate(yy,mm,dd,dow);
  str(yy-1900,y); str(mm,m); str(dd,d);
  date:=tch(m)+'/'+tch(d)+'/'+tch(y);
end;

function allcaps(s:string):string;
var i:integer;
begin
  for i:=1 to length(s) do s[i]:=upcase(s[i]);
  allcaps:=s;
end;

function caps(s:string):string;
var i:integer;
begin
  for i:=1 to length(s) do
    if (s[i] in ['A'..'Z']) then s[i]:=chr(ord(s[i])+32);
  for i:=1 to length(s) do
    if (not (s[i] in ['A'..'Z','a'..'z'])) then
      if (s[i+1] in ['a'..'z']) then s[i+1]:=upcase(s[i+1]);
  s[1]:=upcase(s[1]);
  caps:=s;
end;

function cstr(i:longint):string;
var c:string[16];
begin
  str(i,c);
  cstr:=c;
end;


procedure cursoron(b:boolean);
begin
  if (b) then begin
  curon:=TRUE;
  ASM
  mov ah, $01
  mov ch, $06
  mov cl, $07
  int $10
  end;
  end else begin
  ASM
  mov ah, $01
  mov ch, $20
  mov cl, $00
  int $10
  end;
  curon:=FALSE;
  end;
end;

procedure oncursor;
begin
cursoron(TRUE);
end;

procedure halfcursor;
begin
ASM
  mov ah, $01
  mov ch, $08
  mov cl, $07
  int $10
end;
end;

function lenn(s:string):integer;
var i,len:integer;
begin
  len:=length(s); i:=1;
  while (i<=length(s)) do begin
    if (s[i]='%') then
        if (i+4<=length(s)) then begin
                if (s[i+4]='%') and (s[i+1] in ['0'..'9']) and
                        (s[i+2] in ['0'..'9']) and
                        (s[i+3] in ['0'..'9']) then
                        begin
                                dec(len,5); inc(i,4);
                        end;
                end;
    inc(i);
  end;
  lenn:=len;
end;


function mrn(s:string; l:integer):string;
begin
  while lenn(s)<l do s:=' '+s;
  if lenn(s)>l then s:=copy(s,1,l);
  mrn:=s;
end;

function mln(s:string; l:integer):string;
var i,i2:integer;
    s2:string;
begin
  s2:='';
  while (lenn(s)<l) do s:=s+' ';
  if (lenn(s)>l) then
  if (length(s)<=4) then begin
        s:=copy(s,1,l);
  end else begin
  i:=1;
  i2:=0;
  while (i<=length(s)-4) and (i2<l) do begin
    if (s[i]='%') and (s[i+4]='%') and
         (s[i+1] in ['0'..'9']) and (s[i+2] in ['0'..'9']) and
                (s[i+3] in ['0'..'9']) then begin
                        s2:=s2+s[i]+s[i+1]+s[i+2]+s[i+3]+s[i+4];
                        inc(i,4);
    end else begin
        s2:=s2+s[i];
        inc(i2);
    end;
    inc(i);
  end;
  if not((s[length(s)-4]='%') and (s[length(s)]='%')
         and (s[i+1] in ['0'..'9']) and (s[i+2] in ['0'..'9']) and
                (s[i+3] in ['0'..'9'])) then begin
        if (i2<l) then begin
                inc(i2);
                s2:=s2+s[length(s)-3];
        end;
        if (i2<l) then begin
                inc(i2);
                s2:=s2+s[length(s)-2];
        end;
        if (i2<l) then begin
                inc(i2);
                s2:=s2+s[length(s)-1];
        end;
        if (i2<l) then begin
                inc(i2);
                s2:=s2+s[length(s)];
        end;
  end;
  s:=s2;
  end;
  mln:=s;
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


function getcolorsequence:string;
var x1,y1,x2,y2,x,y:integer;
    tempbyte:byte;
    tfore,tback:byte;
    s:string;

begin
x1:=lo(windmin)+1;
x2:=lo(windmax)+1;
y1:=hi(windmin)+1;
y2:=hi(windmax)+1;
x:=wherex;
y:=wherey;
tempbyte:=7;
tempbyte:=getcolor(3,8,tempbyte,'This is an example string.');
tfore:=tempbyte and 7;
if (tempbyte and 8)<>0 then inc(tfore,8);
if (tempbyte and 128)<>0 then inc(tfore,16);
tback:=((tempbyte shr 4) and 7);
s:=tch(cstr(tfore))+cstr(tback);
window(x1,y1,x2,y2);
gotoxy(x,y);
getcolorsequence:=s;
end;


procedure infield1(x,y:byte; var s:string; len:byte);
var os,str2:string;
    x2,currentleft,sta,sx,sy,z,i,p:integer;
    c:char;
    oins,address,numonly,caps,ins,done,nokeyyet:boolean;

  procedure gocpos(s1:string);
  var s2,s3:string;
      tmpv:integer;
  begin
    s2:='';
    s3:='';
    s2:=s1;
    if (infield_maxshow<len) and (infield_maxshow<>0) then begin
        if (p<currentleft) then begin
                gotoxy(x,y);
                write(copy(s2,p,infield_maxshow));
                currentleft:=p;
                gotoxy(x,y);
        end else begin
                if (p>=currentleft+(infield_maxshow-1)) then begin
                        s3:=copy(s2,p-(infield_maxshow-1),infield_maxshow);
                        gotoxy(x,y);
                        write(s3);
                        if (length(s3)<infield_maxshow) then begin
                                for tmpv:=1 to (infield_maxshow-length(s3)) do
                                        write('°');
                        end;
                        currentleft:=p-(infield_maxshow-1);
                        gotoxy(x+(infield_maxshow-1),y);
                end else begin
                        gotoxy(x+(p-currentleft),y);
                end;
        end;
    end else gotoxy(x+p-1,y);
  end;

  procedure exit_w_arrow;
  var i:integer;
  begin
    infield_arrow_exited:=TRUE;
    infield_last_arrow:=ord(c);
    done:=TRUE;
    if not(infield_arrow_exited_keep) then begin
      s:=os;
    end;
  end;

  procedure exit_w_normal;
  var i:integer;
  begin
    infield_normal_exited:=TRUE;
    infield_last_normal:=ord(c);
    done:=TRUE;
    if (infield_arrow_exited_keep) then begin
      z:=len;
      for i:=len downto 1 do
        if (s[i]=' ') then dec(z) else i:=1;
      s[0]:=chr(z);
    end else
      s:=os;
  end;

begin
  infield_escape_exited:=FALSE;
  sta:=textattr; sx:=wherex; sy:=wherey;
  os:=s;
  ins:=infield_insert;
  oins:=infield_insert;
  if (ins) then halfcursor else oncursor;
  done:=FALSE;
  caps:=infield_allcaps;
  address:=infield_address;
  numonly:=infield_numbers_only;
  infield_arrow_exited:=FALSE;
  gotoxy(x,y);
  textattr:=(infield_inp_bkgd*16)+infield_inp_fgrd;
  p:=1;
  if (infield_maxshow=0) then
       for i:=1 to len do write('°')
  else
       for i:=1 to infield_maxshow do write('°');
  gotoxy(x,y);
  if (infield_maxshow=0) then begin
  if (infield_putatend) then p:=length(s)+1 else p:=1;
  write(s);
  end else begin
  if (infield_putatend) then begin
       p:=length(s)+1;
       if (length(s)<=infield_maxshow) then begin
              currentleft:=1;
              write(copy(s,1,infield_maxshow));
       end else begin
              currentleft:=(length(s)-infield_maxshow)+1;
              write(copy(s,currentleft,(length(s)-currentleft)+1));
       end;
  end else begin
  currentleft:=1;
  write(copy(s,1,infield_maxshow));
  end;
  end;
  gocpos(s);
  nokeyyet:=TRUE;
  repeat
    repeat c:=readkey
    until ((not infield_only_allow_on) or
           (pos(c,infield_special_function_keys)<>0) or
           (pos(c,infield_normal_exit_keys)<>0) or
           (pos(c,infield_only_allow)<>0) or (c=#0));

    if ((infield_normal_exit_keydefs) and
        (pos(c,infield_normal_exit_keys)<>0)) then exit_w_normal;

    if ((infield_special_function_on) and
        (pos(c,infield_special_function_keys)<>0)) then
      infield_special_function_proc(c)
    else begin
      if (nokeyyet) then begin
        nokeyyet:=FALSE;
        if (c in [#32..#255]) and (infield_clear) then begin
          if ((infield_restrict_list<>'') and (pos(c,infield_restrict_list)<>0)) or
                (infield_restrict_list='') then begin
          gotoxy(x,y);
          s:='';
          if (infield_maxshow<>0) then begin
                for i:=1 to infield_maxshow do begin
                        write('°');
                end;
          end else begin
                for i:=1 to len do write('°');
          end;
          p:=1;
          gotoxy(x,y);
          end;
        end;
      end;
      case c of
         #0:begin
              c:=readkey;
              if ((infield_arrow_exit) and (infield_arrow_exit_typedefs) and
                  (pos(c,infield_arrow_exit_types)<>0)) then exit_w_arrow
              else
              case c of
                #72,#80:if (infield_arrow_exit) then exit_w_arrow;
                #75:begin
                        nokeyyet:=FALSE;
                        if (p>1) then dec(p);
                    end;
                #77:begin
                        if (p<length(s)+1) then inc(p);
                        nokeyyet:=FALSE;
                    end;
                #71:p:=1;
                #79:begin
                      p:=length(s)+1;
                    end;
                #82:begin
                        ins:=not ins;
                        infield_insert:=ins;
                       if (ins) then halfcursor else oncursor;
                    end;
                #83:if (p<=length(s)) then begin
                      delete(s,p,1);
                      if (infield_maxshow<>0) then begin
                        for i:=p to ((currentleft+infield_maxshow)-1) do begin
                                if (i<=length(s)) then write(s[i]) else
                                        write('°');
                        end;
                      end else begin
              for i:=p to length(s) do write(s[i]);
              if (len>length(s)) then begin
                for i:=length(s)+1 to len do write('°');
                end;
                      end;
                    end;
                #115:if (p>1) then begin
                       i:=p-1;
                       while ((not (s[i-1] in infield_seperators)) or
                             (s[i] in infield_seperators))
                             and (i>1) do
                         dec(i);
                       p:=i;
                     end;
                #116:if (p<=len) then begin
                       i:=p+1;
                       while ((not (s[i-1] in infield_seperators)) or
                             (s[i] in infield_seperators))
                             and (i<=len) do
                         inc(i);
                       p:=i;
                     end;
                #117:if (p<=len) then
                       for i:=p to length(s) do begin
                         s[i]:=' ';
                         write(' ');
                       end;
                else if (infield_func_keys) then
                     if (pos(c,infield_func_keys_allowed)<>0) then begin
                        infield_func_key_pressed:=c;
                        s:='';
                        done:=TRUE;
                     end;
              end;
              gocpos(s);
            end;
         #27:begin
               infield_escape_exited:=TRUE;
               if (infield_escape_zero) then begin
                   s:='0';
               end else begin
               if (infield_escape_blank) then s:='' else
               if (infield_escape_save) then s:=s else s:=os;
               end;
               done:=TRUE;
             end;
        #13:begin
              done:=TRUE;
            end;
        #8:if (p<>1) then begin
                      dec(p);
                      delete(s,p,1);
                      gocpos(s);
                      if (infield_maxshow<>0) then begin
                        for i:=p to ((currentleft+infield_maxshow)-1) do begin
                                if (i<=length(s)) then write(s[i]) else
                                        write('°');
                        end;
                      end else begin
                        for i:=p to length(s) do write(s[i]);
                        if (len>length(s)) then begin
                        for i:=length(s)+1 to len do
                                write('°');
                        end;
                      end;
             if (p=currentleft+1) and (p>2) then begin
                dec(currentleft,2);
                dec(p,2);
                gocpos(s);
                write(copy(s,p,2));
                inc(p,2);
             end;
             gocpos(s);
           end;
        #16:begin
              str2:=getcolorsequence;
              cursoron(TRUE);
              ins:=infield_insert;
              if (ins) then halfcursor else oncursor;
              textattr:=(infield_inp_bkgd*16)+infield_inp_fgrd;
              if (str2<>'') then begin
              str2:='%'+str2+'%';
              if (p<>len) then begin
                s:=copy(s,1,p-1)+str2+copy(s,p,length(s)-(p-1));
              end;
              if (infield_maxshow<>0) then begin
                        for i:=p to ((currentleft+infield_maxshow)-1) do begin
                                if (i<=length(s)) then write(s[i]) else
                                        write('°');
                        end;
              end else begin
              for i:=p to length(s) do write(s[i]);
              if (len>length(s)) then begin
              for i:=length(s)+1 to len do write('°');
              end;
              end;
              inc(p,5);
              gocpos(s);
              end;
            end;
      else
            if ((c in [#32..#255]) and (p<=len)) then begin
              if ((infield_restrict_list<>'') and (pos(c,infield_restrict_list)<>0)) or
                (infield_restrict_list='') then begin
              if ((ins) and (p<>len)) then begin
                write(' ');
                if ((length(s)+1)<len) then s:=s+s[length(s)] else
                        s[length(s)]:=s[length(s)-1];
                for i:=(length(s)-1) downto p+1 do s[i]:=s[i-1];
                if (infield_maxshow<>0) then begin
                        for i:=p+1 to ((currentleft+infield_maxshow)-1) do begin
                                if (i<=length(s)) then write(s[i]) else
                                        write('°');
                        end;

                end else begin
                        for i:=p+1 to length(s) do write(s[i]);
                        if (len>length(s)) then begin
                                for i:=length(s)+1 to len do write('°');
                        end;
                end;
                gocpos(s);
              end;
              if (numonly) then begin
                if ((c='-') and (p=1)) and (infield_min_value<0) then begin
                        if length(s)=0 then s:='-' else
                        s[p]:=c;
                        write(c);
                        inc(p);
                end;
                if (c in ['0'..'9']) then begin
                        if (length(s)<p) then s:=s+c else
                        s[p]:=c;
                        write(c);
                        inc(p);
                end;
              end else begin
              if (address) then begin
                if (c in [':','/','.','0'..'9']) then begin
                        if (length(s)<p) then s:=s+c else
                        s[p]:=c;
                        write(c);
                        inc(p);
                end;
              end else begin
              if (caps) then write(upcase(c)) else
                write(c);
              if (p>length(s)) then begin
                if (caps) then s:=s+upcase(c) else s:=s+c;
              end else begin
              if (caps) then s[p]:=upcase(c) else
                s[p]:=c;
              end;
              inc(p);
              end;
              end;
              gocpos(s);
              end;
            end;
      end;
    end;
  until done;
  if (infield_put_slash) and not(infield_escape_exited) then if (s[length(s)]<>'\')
        and ((s<>'') and (infield_no_slash_blank)) then s:=s+'\';
  if (infield_numbers_only) then begin
        if not((infield_min_value=-1) and (infield_max_value=-1)) then begin
                if (value(s)<infield_min_value) then s:=os;
                if (value(s)>infield_max_value) then s:=os;
        end;
  end;
  gotoxy(x,y);
  textattr:=(infield_out_bkgd*16)+infield_out_fgrd;
  if (infield_maxshow<>0) then begin
          for i:=1 to infield_maxshow do write(' ');
          gotoxy(x,y);
          if (infield_show_colors) then begin
                  cwrite(mln(s,infield_maxshow));
                  end else
                  write(copy(s,1,infield_maxshow));
  end else begin
          for i:=1 to len do write(' ');
          gotoxy(x,y);
          if (infield_show_colors) then
                  cwrite(mln(s,len)) else
                  write(mln(s,len));
  end;
  gotoxy(sx,sy);
  textattr:=sta;
  infield_insert:=oins;

  infield_only_allow_on:=FALSE;
  infield_special_function_on:=FALSE;
  infield_normal_exit_keydefs:=FALSE;
end;

procedure infielde(var s:string; len:byte);
begin
  cursoron(true);
  infield1(wherex,wherey,s,len);
  cursoron(false);
end;

{ x1,y1 -  Upper Left Corner
  x2,y2 -  Lower Right Corner
  tpe   -  1 -  Normal Window   2 - Window with Display Line At Bottom
  bk    -  Background Color (0-7)
  f1    -  Foreground 1  (0-15)  Left and Top of Window
  f2    -  Foreground 2  (0-15)  Right and Bottom of Window
  s     -  String to display if using TPE=2 Window }

Procedure DrawWindow2(x1,y1,x2,y2,tpe,bk,f1,f2:integer;s:string);
var
c,x,b:integer;
t:integer;

begin
checkvidseg;
textbackground(bk);
textcolor(f1);
gotoxy(x1,y1);
write('Ú');
for x:=(x1+1) to (x2-1) do write('Ä');
textcolor(f2);
write('¿');
if (tpe=1) then c:=y2-1;
if (tpe>1) then c:=y2-2;
for x:=(y1+1) to (c) do begin
gotoxy(x1,x);
textcolor(f1);
textbackground(bk);
write('³');
for b:=(x1+1) to (x2-1) do write(' ');
textcolor(f2);
write('³');
mem[vidseg:(160*(x-1)+2*(x2))+1]:=8;
end;
gotoxy(x1,c+1);
textcolor(f1);
textbackground(bk);
write('À');
textcolor(f2);
for x:=(x1+1) to (x2-1) do write('Ä');
write('Ù');
mem[vidseg:(160*(c)+2*(x2))+1]:=8;
if (tpe>1) then begin
        gotoxy(x1,y2);
        textcolor(f1);
        textbackground(bk);
        for x:=x1 to x2 do write(' ');
        mem[vidseg:(160*(y2-1)+2*(x2))+1]:=8;
        textcolor(8);
        gotoxy(x1+(((((x2-x1)+1)-length(s)) div 2)-((((x2-x1)+1)-length(s)) mod 2)),y2);
        write(s);
        textcolor(8);
        end;
for x:=(x1+1) to (x2+1) do begin
if (tpe=1) then mem[vidseg:(160*(c+1)+2*(x-1))+1]:=8
        else mem[vidseg:(160*(c+2)+2*(x-1))+1]:=8;
end;
textcolor(7);
end;

Procedure DrawWindow3(var w:windowrec; x1,y1,x2,y2,tpe,bk,f1,f2:integer;s:string);
begin
savescreen(w,x1,y1,x2+1,y2+1);
drawwindow2(x1,y1,x2,y2,tpe,bk,f1,f2,s);
end;

procedure infield(var s:string; len:byte);
begin
  s:=''; infielde(s,len);
end;

function l_yn:boolean;
var c:char;
begin
  if (yndefault) then
  write('Yes')
  else write('No');
  repeat c:=upcase(readkey) until (c in ['Y','N',#13,#27]);
  if (c='Y') then begin
        if not(yndefault) then begin
                write(^H^H);
                write('Yes');
        end;
        l_yn:=TRUE;
  end;
  if (c='N') then begin
        if (yndefault) then begin
                write(^H^H^H);
                write('No');
         end;
         l_yn:=FALSE;
  end;
  if (c=#13) then begin
        if (yndefault) then begin
                l_yn:=TRUE;
        end else begin
                l_YN:=FALSE;
        end;
  end;
  if (c=#27) then begin
        l_yn:=FALSE;
        pynqbox_escape:=TRUE;
  end;
end;

function l_pynq(s:string):boolean;
begin
  textcolor(12); write(s); textcolor(11);
  l_pynq:=l_yn;
end;

function pynqbox(s:string):boolean;
var w5:windowrec;
begin
        setwindow(w5,(40-((length(s) div 2)+3)),12,(41+((length(s) div 2)+3)),14,3,0,8,'',TRUE);
        gotoxy(2,1);
        textcolor(12);
        textbackground(0);
        write(s);
        textcolor(11);
        pynqbox:=l_yn;
        removewindow(w5);
end;

procedure displaybox(s:string; d:integer);
var w:windowrec;
begin
        textcolor(12);
        textbackground(0);
        setwindow(w,(40-((length(s) div 2)+3)),12,(40+((length(s) div 2)+3)),14,3,0,8,'',TRUE);
        gotoxy(2,1);
        textcolor(12);
        write(s);
        textcolor(11);
        delay(d);
        removewindow(w);
end;


procedure displaybox2(var w:windowrec; s:string);
begin
        textcolor(12);
        textbackground(0);
        setwindow(w,(40-((length(s) div 2)+3)),12,(40+((length(s) div 2)+3)),14,3,0,8,'',TRUE);
        gotoxy(2,1);
        textcolor(12);
        write(s);
        textcolor(11);
end;

procedure displaybox3(y:integer; var w:windowrec; s:string);
begin
        textcolor(12);
        textbackground(0);
        setwindow(w,(40-((length(s) div 2)+3)),y,(40+((length(s) div 2)+3)),y+2,3,0,8,'',TRUE);
        gotoxy(2,1);
        textcolor(12);
        write(s);
        textcolor(11);
end;

procedure color(fg,bg:integer);
begin
  textcolor(fg);
  textbackground(bg);
end;





procedure cwrite(s:string);
var ss,sss:string;
    back,ps1,ps2,p1,p2,p3,colr:integer;
    tb:byte;
    c,mc:char;
    done:boolean;
begin
  ss:=s; sss:='';
  done:=false;
  begin
     while (ss<>'') and (pos('%',ss)<>0) do begin
      p1:=500;
      p2:=500;
      p3:=pos('%',ss); if (p3=0) then p3:=500;
      if (p3<p1) then p1:=p3 else p3:=500;
      colr:=100;
      back:=100;
      if (hback<>255) then back:=hback;
      if (p1<>500) then begin
        if (p3<>500) then begin
                ss[p3]:=#28;
                if ((length(ss)>=p3+4) and (ss[p3+1] in ['0'..'9']) and
                        (ss[p3+2] in ['0'..'9']) and (ss[p3+3] in ['0'..'9'])
                        and (ss[p3+4]='%')) then
                begin
                        ss[p3+4]:=#28;
                        colr:=value(ss[p3+1]+ss[p3+2]);
                        if (back=100) then back:=value(ss[p3+3]);
                        if (colr>31) or ((colr=0) and not((ss[p3+1]+ss[p3+2])='00')) then colr:=7;
                        if (back>7) or ((back=0) and not(ss[p3+3]='0')) then back:=0;
                        if (colr<>100) then begin
                                sss:=copy(ss,1,p3-1);
                                ss:=copy(ss,p3+5,length(ss)-(p3+4));
                        end;
                end else begin
                        ss[p3]:='%';
                        sss:=copy(ss,1,p3);
                        ss:=copy(ss,p3+1,length(ss)-p3);
                end;
        end;
      end else begin
        sss:=ss; ss:='';
      end;

      for ps1:=1 to length(sss) do write(sss[ps1]);

      if (colr<>100) and (back<>100) then begin
        tb:=0;
        if (colr-16>=0) then begin
                tb:=((colr-16) or (back shl 4));
                inc(tb,128);
        end else tb:=(colr or (back shl 4));
        textattr:=tb;
      end;
    end;
    for ps1:=1 to length(ss) do if (ss[ps1]=#28) then ss[ps1]:='%';
  end;
  for ps1:=1 to length(ss) do write(ss[ps1]);
end;

{procedure cwrite(s:string);
var i:integer;
begin
  if (hback<>255) then textbackground(hback);
  if (length(s)<=4) then begin
        write(s);
  end else begin
  for i:=1 to length(s)-4 do begin
    if (s[i]='%') and (s[i+4]='%') and
         (s[i+1] in ['0'..'9']) and (s[i+2] in ['0'..'9']) and
                (s[i+3] in ['0'..'9']) then begin
                        textcolor(value(s[i+1]+s[i+2]));
                        if (hback=255) then textbackground(value(s[i+3]));
                        inc(i,4);
    end else begin
        write(s[i]);
    end;
  end;
  if not((s[length(s)-4]='%') and (s[length(s)]='%')
         and (s[i+1] in ['0'..'9']) and (s[i+2] in ['0'..'9']) and
                (s[i+3] in ['0'..'9'])) then begin
        write(s[length(s)-3]);
        write(s[length(s)-2]);
        write(s[length(s)-1]);
        write(s[length(s)]);
  end;
  end;
end;
}

procedure cwriteat(x,y:integer; s:string);
begin
  gotoxy(x,y);
  cwrite(s);
end;

function cstringlength(s:string):integer;
var len,i:integer;
begin
  len:=length(s); i:=1;
  while (i<=length(s)) do begin
    if ((s[i]=#2) or (s[i]=#3)) then begin dec(len,2); inc(i); end;
    inc(i);
  end;
  cstringlength:=len;
end;

procedure cwritecentered(y:integer; s:string);
begin
  cwriteat(40-(cstringlength(s) div 2),y,s);
end;

procedure writecentered(y:integer; s:string);
var x,x2:integer;
    s2:string;
begin
  x:=length(s);
  s2:='';
  if (x<y) then begin
        for x2:=1 to ((y-x) div 2) do s2:=s2+' ';
        write(s2,s,s2);
  end else
        write(copy(s,1,y));
end;


{*
 *  ÚÄÄÄ¿   ÉÍÍÍ»   °°°°°   ±±±±±   ²²²²²   ÛÛÛÛÛ   ÖÄÄÄ·  ÕÍÍÍ¸
 *  ³ 1 ³   º 2 º   ° 3 °   ± 4 ±   ² 5 ²   Û 6 Û   º 7 º  ³ 8 ³
 *  ÀÄÄÄÙ   ÈÍÍÍ¼   °°°°°   ±±±±±   ²²²²²   ÛÛÛÛÛ   ÓÄÄÄ½  ÔÍÍÍ¾
 *}
procedure box(linetype,TLX,TLY,BRX,BRY:integer; title:string;tcolor,bcolor:integer;shadow:boolean);
var i,j:integer;
    TL,TR,BL,BR,hline,vline:char;
begin
  checkvidseg;
  window(1,1,80,25);
  textbackground(bcolor);
  case linetype of
    1:begin
        TL:=#218; TR:=#191; BL:=#192; BR:=#217;
        vline:=#179; hline:=#196;
      end;
    2:begin
        TL:=#201; TR:=#187; BL:=#200; BR:=#188;
        vline:=#186; hline:=#205;
      end;
    3:begin
        TL:=#176; TR:=#176; BL:=#176; BR:=#176;
        vline:=#176; hline:=#176;
      end;
    4:begin
        TL:=#177; TR:=#177; BL:=#177; BR:=#177;
        vline:=#177; hline:=#177;
      end;
    5:begin
        TL:=#178; TR:=#178; BL:=#178; BR:=#178;
        vline:=#178; hline:=#178;
      end;
    6:begin
        TL:=#219; TR:=#219; BL:=#219; BR:=#219;
        vline:=#219; hline:=#219;
      end;
    7:begin
        TL:=#214; TR:=#183; BL:=#211; BR:=#189;
        vline:=#186; hline:=#196;
      end;
    8:begin
{        TL:=#213; TR:=#184; BL:=#212; BR:=#190;
        vline:=#179; hline:=#205; }
        TL:=#254; TR:=#254; BL:=#254; BR:=#254;
        vline:=#179; hline:=#196;
      end;
  else
      begin
        TL:=#32; TR:=#32; BL:=#32; BR:=#32;
        vline:=#32; hline:=#32;
      end;
  end;
  if (tcolor<>8) then tcolor:=9;
  textcolor(tcolor);
  gotoxy(TLX,TLY); write(TL);
  gotoxy(BRX,TLY); write(TR);
  gotoxy(TLX,BRY); write(BL);
  gotoxy(BRX,BRY); write(BR); if shadow then begin;
  mem[vidseg:(160*(BRY-1)+2*(BRX))+1]:=8;

{Where vidseg is $B800 or $B000...notice the +1 on the end of the mem..I'm }
  textcolor(tcolor); end;
  for i:=TLX+1 to TLX+1 do begin
    gotoxy(i,TLY);      {Top line}
    write(hline);
  end;
  if (title='') then
        for i:=(tlx+2) to (tlx+5) do begin
            gotoxy(i,TLY);      {Top line}
            write(hline);
        end;
  for i:=(TLX+4+length(title)) to BRX-1 do begin
    gotoxy(i,TLY);      {Top line}
    write(hline);
  end;
  for i:=TLX+1 to BRX-1 do begin
    gotoxy(i,BRY);      {Bottom line}
    write(hline);
  end;
  for i:=TLY+1 to BRY-1 do begin
    gotoxy(TLX,i);      {Left line}
    write(vline);
  end;
  for i:=TLY+1 to BRY-1 do begin
    gotoxy(BRX,I);      {Right line}
    write(vline);
    if shadow then begin;
    mem[vidseg:(160*(i-1)+2*(BRX))+1]:=8;
    textcolor(tcolor); end;
  end;
  gotoxy(TLX+1,BRY+1);
  if shadow then begin; for i:=TLX+1 to BRX+1 do begin;
  mem[vidseg:(160*(BRY)+2*(i-1))+1]:=8; end; end;
  if title <> '' then
  begin
  gotoxy(TLX+2,TLY);
  if (showcontrolbox) then begin
  textcolor(tcolor);
  write('´');
  textcolor(15);
  textbackground(0);
  write('þ');
  textcolor(tcolor);
  textbackground(bcolor);
  write('Ã');
  gotoxy(tlx+6,Tly);
  end;
  textcolor(tcolor);
  write('[');
  textcolor(titlefore);
  textbackground(titleback);
  write(title);
  textcolor(tcolor);
  textbackground(bcolor);
  write(']');
  write(hline);
  end;
  if (linetype>0) then window(TLX+1,TLY+1,BRX-1,BRY-1)
                  else window(TLX,TLY,BRX,BRY);
end;

procedure boxgray(linetype,TLX,TLY,BRX,BRY:integer; title:string;tcolor,bcolor:integer;shadow:boolean);
var i,j:integer;
    TL,TR,BL,BR,hline,vline:char;
begin
  checkvidseg;
  window(1,1,80,25);
  textbackground(bcolor);
  case linetype of
    1:begin
        TL:=#218; TR:=#191; BL:=#192; BR:=#217;
        vline:=#179; hline:=#196;
      end;
    2:begin
        TL:=#201; TR:=#187; BL:=#200; BR:=#188;
        vline:=#186; hline:=#205;
      end;
    3:begin
        TL:=#176; TR:=#176; BL:=#176; BR:=#176;
        vline:=#176; hline:=#176;
      end;
    4:begin
        TL:=#177; TR:=#177; BL:=#177; BR:=#177;
        vline:=#177; hline:=#177;
      end;
    5:begin
        TL:=#178; TR:=#178; BL:=#178; BR:=#178;
        vline:=#178; hline:=#178;
      end;
    6:begin
        TL:=#219; TR:=#219; BL:=#219; BR:=#219;
        vline:=#219; hline:=#219;
      end;
    7:begin
        TL:=#214; TR:=#183; BL:=#211; BR:=#189;
        vline:=#186; hline:=#196;
      end;
    8:begin
{        TL:=#213; TR:=#184; BL:=#212; BR:=#190;
        vline:=#179; hline:=#205; }
        TL:=#254; TR:=#254; BL:=#254; BR:=#254;
        vline:=#179; hline:=#196;
      end;
  else
      begin
        TL:=#32; TR:=#32; BL:=#32; BR:=#32;
        vline:=#32; hline:=#32;
      end;
  end;
  textcolor(tcolor);
  gotoxy(TLX,TLY); write(TL);
  gotoxy(BRX,TLY); write(TR);
  gotoxy(TLX,BRY); write(BL);
  gotoxy(BRX,BRY); write(BR); if shadow then begin;
  mem[vidseg:(160*(BRY-1)+2*(BRX))+1]:=8;

{Where vidseg is $B800 or $B000...notice the +1 on the end of the mem..I'm }
  textcolor(tcolor); end;
  for i:=TLX+1 to TLX+1 do begin
    gotoxy(i,TLY);      {Top line}
    write(hline);
  end;
  if (title='') then
        for i:=(tlx+2) to (tlx+5) do begin
            gotoxy(i,TLY);      {Top line}
            write(hline);
        end;
  for i:=(TLX+4+length(title)) to BRX-1 do begin
    gotoxy(i,TLY);      {Top line}
    write(hline);
  end;
  for i:=TLX+1 to BRX-1 do begin
    gotoxy(i,BRY);      {Bottom line}
    write(hline);
  end;
  for i:=TLY+1 to BRY-1 do begin
    gotoxy(TLX,i);      {Left line}
    write(vline);
  end;
  for i:=TLY+1 to BRY-1 do begin
    gotoxy(BRX,I);      {Right line}
    write(vline);
    if shadow then begin;
    mem[vidseg:(160*(i-1)+2*(BRX))+1]:=8;
    textcolor(tcolor); end;
  end;
  gotoxy(TLX+1,BRY+1);
  if shadow then begin; for i:=TLX+1 to BRX+1 do begin;
  mem[vidseg:(160*(BRY)+2*(i-1))+1]:=8; end; end;
  if title <> '' then
  begin
  gotoxy(TLX+2,TLY);
  if (showcontrolbox) then begin
  textcolor(tcolor);
  write('µ');
  textcolor(15);
  textbackground(0);
  write('þ');
  textcolor(tcolor);
  textbackground(bcolor);
  write('Æ');
  gotoxy(tlx+6,Tly);
  end;
  textcolor(tcolor);
  write('[');
  textcolor(7);
  textbackground(0);
  write(title);
  textcolor(tcolor);
  textbackground(bcolor);
  write(']');
            write(hline);
  end;
  if (linetype>0) then window(TLX+1,TLY+1,BRX-1,BRY-1)
                  else window(TLX,TLY,BRX,BRY);
end;

procedure box2(linetype,TLX,TLY,BRX,BRY:integer; title,title2:string;tcolor,bcolor:integer;shadow:boolean);
var i,j:integer;
    TL,TR,BL,BR,hline,vline:char;
begin
  checkvidseg;
  window(1,1,80,25);
  textbackground(bcolor);
  case linetype of
    1:begin
        TL:=#218; TR:=#191; BL:=#192; BR:=#217;
        vline:=#179; hline:=#196;
      end;
    2:begin
        TL:=#201; TR:=#187; BL:=#200; BR:=#188;
        vline:=#186; hline:=#205;
      end;
    3:begin
        TL:=#176; TR:=#176; BL:=#176; BR:=#176;
        vline:=#176; hline:=#176;
      end;
    4:begin
        TL:=#177; TR:=#177; BL:=#177; BR:=#177;
        vline:=#177; hline:=#177;
      end;
    5:begin
        TL:=#178; TR:=#178; BL:=#178; BR:=#178;
        vline:=#178; hline:=#178;
      end;
    6:begin
        TL:=#219; TR:=#219; BL:=#219; BR:=#219;
        vline:=#219; hline:=#219;
      end;
    7:begin
        TL:=#214; TR:=#183; BL:=#211; BR:=#189;
        vline:=#186; hline:=#196;
      end;
    8:begin
{        TL:=#213; TR:=#184; BL:=#212; BR:=#190;
        vline:=#179; hline:=#205; }
        TL:=#254; TR:=#254; BL:=#254; BR:=#254;
        vline:=#179; hline:=#196;
      end;
  else
      begin
        TL:=#32; TR:=#32; BL:=#32; BR:=#32;
        vline:=#32; hline:=#32;
      end;
  end;
  if (tcolor<>8) then tcolor:=9;
  textcolor(tcolor);
  gotoxy(TLX,TLY); write(TL);
  gotoxy(BRX,TLY); write(TR);
  gotoxy(TLX,BRY); write(BL);
  gotoxy(BRX,BRY); write(BR); if shadow then begin;
  mem[vidseg:(160*(BRY-1)+2*(BRX))+1]:=8;

{Where vidseg is $B800 or $B000...notice the +1 on the end of the mem..I'm }
  textcolor(tcolor); end;
  for i:=TLX+1 to TLX+1 do begin
    gotoxy(i,TLY);      {Top line}
    write(hline);
  end;
  if (title='') then
        for i:=(tlx+2) to (tlx+5) do begin
            gotoxy(i,TLY);      {Top line}
            write(hline);
        end;
  for i:=(TLX+4+length(title)) to ((BRX - (3 + length(title2))) - 1) do begin
    gotoxy(i,TLY);      {Top line}
    write(hline);
  end;
  if (title2='') then
        for i:=(brx-5) to (brx-1) do begin
            gotoxy(i,TLY);      {Top line}
            write(hline);
        end;
  for i:=TLX+1 to BRX-1 do begin
    gotoxy(i,BRY);      {Bottom line}
    write(hline);
  end;
  for i:=TLY+1 to BRY-1 do begin
    gotoxy(TLX,i);      {Left line}
    write(vline);
  end;
  for i:=TLY+1 to BRY-1 do begin
    gotoxy(BRX,I);      {Right line}
    write(vline);
    if shadow then begin;
    mem[vidseg:(160*(i-1)+2*(BRX))+1]:=8;
    textcolor(tcolor); end;
  end;
  gotoxy(TLX+1,BRY+1);
  if shadow then begin; for i:=TLX+1 to BRX+1 do begin;
  mem[vidseg:(160*(BRY)+2*(i-1))+1]:=8; end; end;
  if title <> '' then
  begin
  gotoxy(TLX+2,TLY);
  if (showcontrolbox) then begin
  textcolor(tcolor);
  write('´');
  textcolor(15);
  textbackground(0);
  write('þ');
  textcolor(tcolor);
  textbackground(bcolor);
  write('Ã');
  gotoxy(tlx+6,Tly);
  end;
  textcolor(tcolor);
{  write('´'); }
  write('[');
  textcolor(titlefore);
  textbackground(titleback);
  write(title);
  textcolor(tcolor);
  textbackground(bcolor);
  write(']');
{  write('Ã'); }
  end;
  if title2 <> '' then
  begin
  gotoxy(BRX-(3+length(title2)),TLY);
  textcolor(tcolor);
  write('[');
  textcolor(titlefore);
  textbackground(titleback);
  write(title2);
  textcolor(tcolor);
  textbackground(bcolor);
  write(']');
  write(hline);
  end;
  if (linetype>0) then window(TLX+1,TLY+1,BRX-1,BRY-1)
                  else window(TLX,TLY,BRX,BRY);
end;

procedure box3(linetype,TLX,TLY,BRX,BRY:integer; title,title2:string;tcolor,bcolor:integer;shadow:boolean);
var i,j:integer;
    TL,TR,BL,BR,hline,vline:char;
begin
  checkvidseg;
  window(1,1,80,25);
  textbackground(bcolor);
  case linetype of
    1:begin
        TL:=#218; TR:=#191; BL:=#192; BR:=#217;
        vline:=#179; hline:=#196;
      end;
    2:begin
        TL:=#201; TR:=#187; BL:=#200; BR:=#188;
        vline:=#186; hline:=#205;
      end;
    3:begin
        TL:=#176; TR:=#176; BL:=#176; BR:=#176;
        vline:=#176; hline:=#176;
      end;
    4:begin
        TL:=#177; TR:=#177; BL:=#177; BR:=#177;
        vline:=#177; hline:=#177;
      end;
    5:begin
        TL:=#178; TR:=#178; BL:=#178; BR:=#178;
        vline:=#178; hline:=#178;
      end;
    6:begin
        TL:=#219; TR:=#219; BL:=#219; BR:=#219;
        vline:=#219; hline:=#219;
      end;
    7:begin
        TL:=#214; TR:=#183; BL:=#211; BR:=#189;
        vline:=#186; hline:=#196;
      end;
    8:begin
{        TL:=#213; TR:=#184; BL:=#212; BR:=#190;
        vline:=#179; hline:=#205; }
        TL:=#254; TR:=#254; BL:=#254; BR:=#254;
        vline:=#179; hline:=#196;
      end;
  else
      begin
        TL:=#32; TR:=#32; BL:=#32; BR:=#32;
        vline:=#32; hline:=#32;
      end;
  end;
  if (tcolor<>8) then tcolor:=9;
  textcolor(tcolor);
  gotoxy(TLX,TLY); write(TL);
  gotoxy(BRX,TLY); write(TR);

{Where vidseg is $B800 or $B000...notice the +1 on the end of the mem..I'm }
  for i:=TLX+1 to TLX+1 do begin
    gotoxy(i,TLY);      {Top line}
    write(hline);
  end;
  if (title='') then
        for i:=(tlx+2) to (tlx+5) do begin
            gotoxy(i,TLY);      {Top line}
            write(hline);
        end;
  for i:=(TLX+4+length(title)) to ((BRX - (3 + length(title2))) - 1) do begin
    gotoxy(i,TLY);      {Top line}
    write(hline);
  end;
  if (title2='') then
        for i:=(brx-5) to (brx-1) do begin
            gotoxy(i,TLY);      {Top line}
            write(hline);
        end;
  if title <> '' then
  begin
  gotoxy(TLX+2,TLY);
  textcolor(tcolor);
{  write('´'); }
  write('[');
  textcolor(titlefore);
  textbackground(titleback);
  write(title);
  textcolor(tcolor);
  textbackground(bcolor);
  write(']');
{  write('Ã'); }
  end;
  if title2 <> '' then
  begin
  gotoxy(BRX-(3+length(title2)),TLY);
  textcolor(tcolor);
  write('[');
  textcolor(titlefore);
  textbackground(titleback);
  write(title2);
  textcolor(tcolor);
  textbackground(bcolor);
  write(']');
  write(hline);
  end;
  if (linetype>0) then window(TLX+1,TLY+1,BRX-1,BRY-1)
                  else window(TLX,TLY,BRX,BRY);
end;

procedure box4(linetype,TLX,TLY,BRX,BRY:integer; title,title2:string;tcolor,bcolor:integer;shadow:boolean);
var i,j:integer;
    TL,TR,BL,BR,hline,vline:char;
begin
  checkvidseg;
  window(1,1,80,25);
  textbackground(bcolor);
  case linetype of
    1:begin
        TL:=#218; TR:=#191; BL:=#192; BR:=#217;
        vline:=#179; hline:=#196;
      end;
    2:begin
        TL:=#201; TR:=#187; BL:=#200; BR:=#188;
        vline:=#186; hline:=#205;
      end;
    3:begin
        TL:=#176; TR:=#176; BL:=#176; BR:=#176;
        vline:=#176; hline:=#176;
      end;
    4:begin
        TL:=#177; TR:=#177; BL:=#177; BR:=#177;
        vline:=#177; hline:=#177;
      end;
    5:begin
        TL:=#178; TR:=#178; BL:=#178; BR:=#178;
        vline:=#178; hline:=#178;
      end;
    6:begin
        TL:=#219; TR:=#219; BL:=#219; BR:=#219;
        vline:=#219; hline:=#219;
      end;
    7:begin
        TL:=#214; TR:=#183; BL:=#211; BR:=#189;
        vline:=#186; hline:=#196;
      end;
    8:begin
{        TL:=#213; TR:=#184; BL:=#212; BR:=#190;
        vline:=#179; hline:=#205; }
        TL:=#254; TR:=#254; BL:=#254; BR:=#254;
        vline:=#179; hline:=#196;
      end;
  else
      begin
        TL:=#32; TR:=#32; BL:=#32; BR:=#32;
        vline:=#32; hline:=#32;
      end;
  end;
  if (tcolor<>8) then tcolor:=9;
  textcolor(tcolor);
  gotoxy(TLX,TLY); write(TL);
  gotoxy(BRX,TLY); write(TR);

{Where vidseg is $B800 or $B000...notice the +1 on the end of the mem..I'm }
  for i:=TLX+1 to TLX+1 do begin
    gotoxy(i,TLY);      {Top line}
    write(hline);
  end;
  if (title='') then
        for i:=(tlx+2) to (tlx+5) do begin
            gotoxy(i,TLY);      {Top line}
            write(hline);
        end;
  for i:=(TLX+4+length(title)) to ((BRX - (3 + length(title2))) - 1) do begin
    gotoxy(i,TLY);      {Top line}
    write(hline);
  end;
  if (title2='') then
        for i:=(brx-5) to (brx-1) do begin
            gotoxy(i,TLY);      {Top line}
            write(hline);
        end;
  if title <> '' then
  begin
  gotoxy(TLX+2,TLY);
  textcolor(tcolor);
{  write('´'); }
  write('[');
  textcolor(titlefore);
  textbackground(titleback);
  write(title);
  textcolor(tcolor);
  textbackground(bcolor);
  write(']');
{  write('Ã'); }
  end;
  if title2 <> '' then
  begin
  gotoxy(BRX-(3+length(title2)),TLY);
  textcolor(tcolor);
  write('[');
  textcolor(titlefore);
  textbackground(titleback);
  write(title2);
  textcolor(tcolor);
  textbackground(bcolor);
  write(']');
  write(hline);
  end;
  if (linetype>0) then window(TLX+1,TLY+1,BRX-1,BRY-1)
                  else window(TLX,TLY,BRX,BRY);
end;

procedure checkvidseg;
begin
  if (mem[$0000:$0449]=7) then vidseg:=$B000 else vidseg:=$B800;
  ismono:=(vidseg=$B000);
end;

procedure savescreen(var wind:windowrec; TLX,TLY,BRX,BRY:integer);
var x,y,i:integer;
begin
  checkvidseg;

  wind[4000]:=TLX; wind[4001]:=TLY;
  wind[4002]:=BRX; wind[4003]:=BRY;

  i:=0;
  for y:=TLY to BRY do
    for x:=TLX to BRX do begin
      inline($FA);
      wind[i]:=mem[vidseg:(160*(y-1)+2*(x-1))];
      wind[i+1]:=mem[vidseg:(160*(y-1)+2*(x-1))+1];
      inline($FB);
      inc(i,2);
    end;
end;

procedure setwindowgray(var wind:windowrec; TLX,TLY,BRX,BRY,tcolr,bcolr,boxtype:integer; title:string;shadow:boolean);
var i:integer;
begin
  savescreen(wind,TLX,TLY,BRX+1,BRY+1);        { save under window }
  window(TLX,TLY,BRX,BRY);                 { set window size }
  color(tcolr,bcolr);                      { set window colors }
  clrscr;                                  { clear window for action }
  boxgray(boxtype,TLX,TLY,BRX,BRY,title,tcolr,bcolr,shadow);      { Set the border }
end;

procedure setwindow(var wind:windowrec; TLX,TLY,BRX,BRY,tcolr,bcolr,boxtype:integer; title:string;shadow:boolean);
var i:integer;
begin
  savescreen(wind,TLX,TLY,BRX+1,BRY+1);        { save under window }
  window(TLX,TLY,BRX,BRY);                 { set window size }
  color(tcolr,bcolr);                      { set window colors }
  clrscr;                                  { clear window for action }
  box(boxtype,TLX,TLY,BRX,BRY,title,tcolr,bcolr,shadow);      { Set the border }
end;

procedure setwindow2(var wind:windowrec; TLX,TLY,BRX,BRY,tcolr,bcolr,boxtype:integer; title,title2:string;shadow:boolean);
var i:integer;
begin
  savescreen(wind,TLX,TLY,BRX+1,BRY+1);        { save under window }
  window(TLX,TLY,BRX,BRY);                 { set window size }
  color(tcolr,bcolr);                      { set window colors }
  clrscr;                                  { clear window for action }
  box2(boxtype,TLX,TLY,BRX,BRY,title,title2,tcolr,bcolr,shadow);      { Set the border }
end;

procedure setwindow3(var wind:windowrec; TLX,TLY,BRX,BRY,tcolr,bcolr,boxtype:integer; title,title2:string;shadow:boolean);
var i:integer;
begin
  window(TLX,TLY,BRX,BRY);                 { set window size }
  color(tcolr,bcolr);                      { set window colors }
  box3(boxtype,TLX,TLY,BRX,BRY,title,title2,tcolr,bcolr,shadow);      { Set the border }
end;

procedure setwindow4(var wind:windowrec; TLX,TLY,BRX,BRY,tcolr,bcolr,boxtype:integer; title,title2:string;shadow:boolean);
var i:integer;
    tf,tb:integer;
begin
  window(TLX,TLY,BRX,BRY);                 { set window size }
  color(tcolr,bcolr);                      { set window colors }
  tf:=titlefore;
  tb:=titleback;
  titlefore:=7;
  titleback:=0;
  box2(boxtype,TLX,TLY,BRX,BRY,title,title2,tcolr,bcolr,shadow);      { Set the border }
  titlefore:=tf;
  titleback:=tb;

end;

procedure setwindow5(var wind:windowrec; TLX,TLY,BRX,BRY,tcolr,bcolr,boxtype:integer; title,title2:string;shadow:boolean);
var i:integer;
begin
  window(TLX,TLY,BRX,BRY);                 { set window size }
  color(tcolr,bcolr);                      { set window colors }
  box2(boxtype,TLX,TLY,BRX,BRY,title,title2,tcolr,bcolr,shadow);      { Set the border }
end;

procedure removewindow(wind:windowrec);
var TLX,TLY,BRX,BRY,x,y,i:integer;
begin
  checkvidseg;

  window(1,1,80,25);
  color(14,0);

  TLX:=wind[4000]; TLY:=wind[4001];
  BRX:=wind[4002]; BRY:=wind[4003];

  i:=0;
  for y:=TLY to BRY do
    for x:=TLX to BRX do begin
      inline($FA);
      mem[vidseg:(160*(y-1)+2*(x-1))]:=wind[i];
      mem[vidseg:(160*(y-1)+2*(x-1))+1]:=wind[i+1];
      inline($FB);
      inc(i,2);
    end;
end;

procedure removewindow1(wind:windowrec);
var oldx1,oldy1,oldx2,oldy2,sx,sy,sz:byte;
begin
  window(1,1,80,25);
  sx:=wherex; sy:=wherey; sz:=textattr;
  oldx1:=lo(windmin)+1; oldy1:=hi(windmin)+1;
  oldx2:=lo(windmax)-1; oldy2:=hi(windmax)-1;

  removewindow(wind);

  window(oldx1,oldy1,oldx2,oldy2);
  gotoxy(sx,sy); textattr:=sz;
end;


{  returntype = RECORD
        kind:byte;   Enter Pressed  -  1
                      Esc Pressed    -  2
                      Ins Pressed    -  3
                      Del Pressed    -  4
                      Alt-M Pressed  -  5
        high:byte;   Highest byte in DATA that is used
        data:array[1..100] of integer;

                     Format -   Case Kind of

                        1 - (none tagged)  first value is item hit enter on
                            (some tagged)  all values are passed that were
                                           tagged
                        2 - data is empty
                        3 -                first value passed is item insert
                                           was pressed on
                        4 - (none tagged)  first value is item hit del on
                            (some tagged)  all values are passed that were
                                           tagged
                        4 - (none tagged)  key is ignored
                            (some tagged)  all values are passed in order
                                           from top to bottom that were tagged
                                           and last item in data is the item
                                           to move all items (in order) in
                                           before
}


procedure listbox(var wind:windowrec;var return:returntype;var ti,si:integer;lp:listptr; TLX,TLY,BRX,BRY,tcolr,bcolr,
        boxtype:integer;title,title2:string;shadow:boolean);
var total,x,current,top,height:integer;
    bptr,topptr:listptr;
    c:char;
    s:string;
    done:boolean;
    w2:windowrec;
    ii4,ii5:integer;
    lastscroll,fnd:integer;


function findnumber:integer;
var n:integer;
    temp:listptr;
begin
        n:=0;
        temp:=lp;
        lp:=bptr;
        while (lp<>NIL) do begin
                inc(n);
                lp:=lp^.n;
        end;
        lp:=temp;
        findnumber:=n;
end;

procedure findptr(x:integer);
var t,n:integer;
begin
        lp:=bptr;
        t:=0;
        for n:=1 to x-1 do begin
                if (lp^.n<>NIL) then lp:=lp^.n
                else inc(t);
        end;
        x:=x-t;
end;

function istagged(x:integer):boolean;
var i:integer;
    d:boolean;
begin
        d:=false;
        for i:=1 to 99 do begin
                if (return.data[i]=x) then begin
                        d:=true;
                        i:=99;
                end;
        end;
        istagged:=d;
end;

procedure writescrolldown;
var p:real;
perc:integer;
    oldcol:integer;
    x2,x3,hgt,perc2:integer;
begin
window(1,1,80,25);
p:=(current/total);
perc:=trunc(p*100);
hgt:=((bry-2) - (tly+3))+1;
if (current=1) then begin
                oldcol:=textattr;
                textcolor(9);
                textbackground(bcolr);
                for x2:=(TLY+2) to (BRY-2) do begin
                        gotoxy(brx,x2);
                        write('°');
                end;
                gotoxy(brx,tly+2);
                write('Û');
                textattr:=oldcol;
                lastscroll:=0;
end {else if (current=total) then begin
                oldcol:=textattr;
                textcolor(9);
                textbackground(bcolr);
                for x2:=(TLY+2) to (BRY-2) do begin
                        gotoxy(brx,x2);
                        write('°');
                end;
                gotoxy(brx,bry-2);
                write('Û');
                textattr:=oldcol;
                lastscroll:=hgt+1;
end} else begin
for x3:=1 to hgt do begin
        p:=(x3/hgt);
        if ((perc>=trunc((x3/hgt)*100)) and (perc<trunc(((x3+1)/hgt)*100))){ or
                (lastscroll=0) }then begin
                if (x3<>lastscroll) then begin
                oldcol:=textattr;
                textcolor(9);
                textbackground(bcolr);
                for x2:=(TLY+2) to (BRY-2) do begin
                        gotoxy(brx,x2);
                        write('°');
                end;
                gotoxy(brx,(tly+3)+(x3-1));
                write('Û');
                textattr:=oldcol;
                lastscroll:=x3;
                x3:=hgt;
                end;
        end;
end;
end;
window(TLX+1,TLY+1,BRX-1,BRY-1);
end;


procedure redrawdata;
var x:integer;
begin
textcolor(7);
textbackground(0);
findptr(top);
for x:=1 to height do begin
        if (lp<>NIL) then begin
        if (istagged((top+x)-1)) then begin
        gotoxy(1,x+1);
        textcolor(14);
        textbackground(0);
        write('þ');
        textcolor(7);
        end else begin
        gotoxy(1,x+1);
        textcolor(7);
        textbackground(0);
        write(' ');
        end;
        gotoxy(2,x+1);
        cwrite(mln(lp^.list,brx-(tlx+3)));
        lp:=lp^.n;
        end;
end;
end;

function stripcolor(o:string):string;
var s,s2:string;
    count,i:integer;
    lc:boolean;
begin
  s2:=o;
  s:='';
  count:=0;
  i:=1;
  while (i<=length(o)-4) do begin
       if (o[i]='%') and (o[i+4]='%') and (o[i+1] in ['0'..'9']) and
                (o[i+2] in ['0'..'9']) and (o[i+3] in ['0'..'9']) then inc(i,4) else
                        s:=s+o[i];
       inc(i);
  end;
  if (length(o)>4) {and (i<length(o))} then begin
    if not((o[length(o)-4]='%') and (o[length(o)]='%') and (o[length(o)-3] in ['0'..'9'])
        and (o[length(o)-2] in ['0'..'9']) and (o[length(o)-1] in ['0'..'9'])) then begin
        for count:=i to (length(o)) do begin
                s:=s+(o[count]);
        end;
    end;
  end else begin
  s:=s2;
  end;
  stripcolor:=s;
end;

begin
listbox_f10_pressed:=FALSE;
cursoron(FALSE);
height:=bry-(tly+3);
if (height<2) then exit;
setwindow2(wind,TLX,TLY,BRX,BRY,tcolr,bcolr,boxtype,title,title2,shadow);
window(1,1,80,25);
gotoxy(1,25);
textcolor(7);
textbackground(0);
clreol;
textcolor(14);
textbackground(0);
if (listbox_escape) then begin
write('Esc');
textcolor(7);
write('=Exit ');
end;
if (listbox_help<>'') then begin
cwrite(listbox_help);
end;
if (listbox_enter) then begin
textcolor(14);
write('Enter');
textcolor(7);
write('=Select ');
end;
if (listbox_f10) then begin
textcolor(14);
write('F10');
textcolor(7);
write('=Save ');
end;
if (listbox_insert) then begin
textcolor(14);
write('Ins');
textcolor(7);
write('=Insert ');
end;
if (listbox_delete) then begin
textcolor(14);
write('Del');
textcolor(7);
write('=Delete ');
end;
if (listbox_move) then begin
textcolor(14);
write('Alt-M');
textcolor(7);
write('=Move ');
end;
if (listbox_tag) then begin
textcolor(14);
write('Space');
textcolor(7);
write('=Tag Item ');
end;
if (listbox_bottom<>'') then begin
cwrite(listbox_bottom);
end;
window(TLX+1,TLY+1,BRX-1,BRY-1);
current:=si;
top:=ti;
bptr:=lp;
done:=false;
total:=findnumber;
if (current>total) then current:=total;
if (top+height>total) and (top<>1) then top:=total-(height-1);
redrawdata;
lastscroll:=0;
if (total>height) then begin
    window(1,1,80,25);
    gotoxy(brx,tly+1);
    textcolor(9);
    textbackground(bcolr);
    write('');
    for x:=(TLY+2) to (BRY-2) do begin
        gotoxy(brx,x);
        write('°');
    end;
    gotoxy(brx,bry-1);
    write('');
    window(TLX+1,TLY+1,BRX-1,BRY-1);
    writescrolldown;
end;
repeat
gotoxy(2,(current-top)+2);
textcolor(15);
textbackground(1);
findptr(current);
write(mln(stripcolor(lp^.list),brx-(tlx+3)));
while not(keypressed) do begin end;
c:=readkey;
case ord(c) of
        0:begin
                c:=readkey;
                case ord(c) of
                        68:if (listbox_f10) then begin
                           listbox_f10_pressed:=TRUE;
                 if (return.data[1]<>-1) then begin
                                gotoxy(2,(current-top)+2);
                                textcolor(7);
                                textbackground(0);
                                cwrite(mln(lp^.list,brx-(tlx+3)));
                                return.kind:=1;
                 end else begin
                                for x:=1 to 100 do return.data[x]:=-1;
                                                return.kind:=2;
                 end;
                 done:=TRUE;
                 end;
                        71:begin
                                if (current>1) then begin
                                gotoxy(2,(current-top)+2);
                                textcolor(7);
                                textbackground(0);
                                cwrite(mln(lp^.list,brx-(tlx+3)));
                                current:=1;
                                if (current<top) then begin
                                        top:=current;
                                        redrawdata;
                                end;
                                if (total>height) then writescrolldown;
                                end;
                        end;
                        73:begin
                                if (current>1) then begin
                                gotoxy(2,(current-top)+2);
                                textcolor(7);
                                textbackground(0);
                                cwrite(mln(lp^.list,brx-(tlx+3)));
                                if (current-height<1) then begin
                                        current:=1;
                                        top:=1;
                                        end else begin
                                                dec(current,height);
                                                if (top-height<1) then
                                                        top:=1
                                                else
                                                dec(top,height);
                                        end;
                                redrawdata;
                                if (total>height) then
                                writescrolldown;
                                end;
                        end;
                        79:begin
                                if (current<total) then begin
                                gotoxy(2,(current-top)+2);
                                textcolor(7);
                                textbackground(0);
                                cwrite(mln(lp^.list,brx-(tlx+3)));
                                current:=total;
                                if (total-(height)>0) then top:=total-(height-1) else
                                        top:=1;
                                redrawdata;
                                if (total>height) then writescrolldown;
                                end;
                        end;
                        81:begin
                                if (current<total) then begin
                                gotoxy(2,(current-top)+2);
                                textcolor(7);
                                textbackground(0);
                                cwrite(mln(lp^.list,brx-(tlx+3)));
                                if (current+height>total) then begin
                                        current:=total;
                                        top:=total-(height-1);
                                        if (top<1) then top:=1;
                                        end else begin
                                inc(current,height);
                                inc(top,height);
                                if (top+height>total) then top:=total-(height-1);
                                end;
                                redrawdata;
                                if (total>height) then writescrolldown;
                                end;
                        end;
                        82:begin
                                if (listbox_insert) then begin
                                gotoxy(2,(current-top)+2);
                                textcolor(7);
                                textbackground(0);
                                cwrite(mln(lp^.list,brx-(tlx+3)));
                                for x:=1 to 100 do return.data[x]:=-1;
                                return.data[1]:=current;
                                return.kind:=3;
                                done:=TRUE;
                                end;
                           end;
                        83:begin
                                if (listbox_delete) then begin
                                gotoxy(2,(current-top)+2);
                                textcolor(7);
                                textbackground(0);
                                cwrite(mln(lp^.list,brx-(tlx+3)));
                                for x:=1 to 100 do if return.data[x]=-1 then
                                        begin
                                                return.data[1]:=current;
                                                return.kind:=4;
                                                done:=TRUE;
                                                x:=100;
                                        end else begin
                                                done:=TRUE;
                                                return.kind:=4;
                                                x:=100;
                                        end;
                                end;
                        end;
                        50:begin
                                if (listbox_move) then begin
                                gotoxy(2,(current-top)+2);
                                textcolor(7);
                                textbackground(0);
                                cwrite(mln(lp^.list,brx-(tlx+3)));
                                for x:=1 to 99 do if (return.data[x]<>-1) then
                                        begin
                                                return.data[100]:=current;
                                                return.kind:=5;
                                                done:=TRUE;
                                                x:=99;
                                        end;
                                        end;
                                end;
                        72:begin {UP}
                                if (current>1) then begin
                                gotoxy(2,(current-top)+2);
                                textcolor(7);
                                textbackground(0);
                                cwrite(mln(lp^.list,brx-(tlx+3)));
                                dec(current);
                                if (current<top) then begin
                                        top:=current;
                                        redrawdata;
                                end;
                                if (total>height) then
                                writescrolldown;
                                end;
                        end;
                        80:begin
                                if (current<total) then begin
                                gotoxy(2,(current-top)+2);
                                textcolor(7);
                                textbackground(0);
                                cwrite(mln(lp^.list,brx-(tlx+3)));
                                inc(current);
                                if ((current-top)+1>height) then begin
                                        top:=top+1;
                                        redrawdata;
                                end;
                                if (total>height) then writescrolldown;
                                end;
                        end;
                        else if (listbox_allow_extra_func) then begin
                                if (pos(c,listbox_extrakeys_func)<>0) then begin
                                return.kind:=0;
                                return.data[1]:=current;
                                return.data[100]:=ord(c);
                                done:=TRUE;
                                end;
                        end;
                end;
        end;
              ord('0')..ord('9'):if (listbox_goto) then begin

  setwindow(w2,29,12,52,14,3,0,8,'',TRUE);
  gotoxy(2,1);
  textcolor(7);
  textbackground(0);
  write('Goto Number  : ');
  gotoxy(17,1);
  s:=c;
  infield_inp_fgrd:=15;
  infield_inp_bkgd:=1;
  infield_out_fgrd:=3;
  infield_out_bkgd:=0;
  infield_allcaps:=false;
  infield_numbers_only:=TRUE;
  infield_escape_zero:=FALSE;
  infield_escape_blank:=TRUE;
  infield_putatend:=TRUE;
  infield_clear:=FALSE;
  infield_insert:=TRUE;
  infielde(s,5);
  infield_escape_blank:=FALSE;
  infield_putatend:=FALSE;
  infield_clear:=TRUE;
  infield_insert:=TRUE;
  ii4:=value(s);
  if ((ii4>=0) and (ii4<=total)) and (s<>'') then begin
  ii5:=current;
  current:=ii4+listbox_goto_offset;
  top:=ii4+listbox_goto_offset;
  if (top+height>total) then top:=total-(height-1);
  if (ii4+listbox_goto_offset>ii5) then begin
        if (total>height) then writescrolldown;
  end else begin
        if (total>height) then writescrolldown;
  end;
  end;
  removewindow(w2);
  window(TLX+1,TLY+1,BRX-1,BRY-1);
  redrawdata;
                        end;
        13:if (listbox_enter) then begin
                fnd:=-1;
                for x:=1 to 99 do begin
                        if return.data[x]=current then begin
                                fnd:=x;
                                x:=99;
                        end;
                end;
                if (fnd=-1) then begin
                for x:=1 to 98 do begin
                        if (current>return.data[x]) then begin
                                if (return.data[x]=-1) then begin
                                        fnd:=x;
                                        x:=98;
                                end else
                                if (current<return.data[x+1]) or (return.data[x+1]=-1) then
                                begin
                                fnd:=x+1;
                                x:=98;
                                end;
                        end;
                end;
                if (fnd<>-1) then begin
                        if (return.data[fnd]=-1) then begin
                                return.data[fnd]:=current;
                        end else begin
                                x:=99;
                                if (return.data[99]=-1) then begin
                                while (x>fnd) do begin
                                        return.data[x]:=return.data[x-1];
                                        dec(x);
                                end;
                                return.data[fnd]:=current;
                                end else begin
                                        gotoxy(1,(current-top)+2);
                                        textcolor(7);
                                        textbackground(0);
                                        write(' ');
                                end;
                        end;
                end;
                end;
                                gotoxy(2,(current-top)+2);
                                textcolor(7);
                                textbackground(0);
                                cwrite(mln(lp^.list,brx-(tlx+3)));
                                return.kind:=1;
                                done:=TRUE;
            end;
        32:if (listbox_tag) then begin
                fnd:=-1;
                for x:=1 to 99 do begin
                        if return.data[x]=current then begin
                                fnd:=x;
                                x:=99;
                        end;
                end;
                if (fnd=-1) then begin
                gotoxy(1,(current-top)+2);
                textcolor(14);
                textbackground(0);
                write('þ');
                for x:=1 to 98 do begin
                        if (current>return.data[x]) then begin
                                if (return.data[x]=-1) then begin
                                        fnd:=x;
                                        x:=98;
                                end else
                                if (current<return.data[x+1]) or (return.data[x+1]=-1) then
                                begin
                                fnd:=x+1;
                                x:=98;
                                end;
                        end;
                end;
                if (fnd<>-1) then begin
                        if (return.data[fnd]=-1) then begin
                                return.data[fnd]:=current;
                        end else begin
                                x:=99;
                                if (return.data[99]=-1) then begin
                                while (x>fnd) do begin
                                        return.data[x]:=return.data[x-1];
                                        dec(x);
                                end;
                                return.data[fnd]:=current;
                                end else begin
                                        gotoxy(1,(current-top)+2);
                                        textcolor(7);
                                        textbackground(0);
                                        write(' ');
                                end;
                        end;
                end;
                end else begin
                gotoxy(1,(current-top)+2);
                textcolor(7);
                textbackground(0);
                write(' ');
                for x:=fnd to 99 do begin
                        return.data[x]:=return.data[x+1];
                end;
                return.data[100]:=-1;
                end;
            end;
        27:if (listbox_escape) then begin
                if (return.data[1]<>-1) then begin
                   if pynqbox('Clear all items tagged? ') then begin
                                     for x:=1 to 100 do return.data[x]:=-1;
                                     return.kind:=2;
                   end else begin
                                window(TLX+1,TLY+1,BRX-1,BRY-1);
                                gotoxy(2,(current-top)+2);
                                textcolor(7);
                                textbackground(0);
                                cwrite(mln(lp^.list,brx-(tlx+3)));
                                return.kind:=1;
                   end;
                end else begin
                for x:=1 to 100 do return.data[x]:=-1;
                return.kind:=2;
                end;
                done:=TRUE;
        end;
        else if (listbox_allow_extra) then begin
             if (pos(c,listbox_extrakeys)<>0) then begin
                done:=TRUE;
                return.kind:=254;
                return.data[100]:=ord(c);
             end;
        end;
end;
until (done);
setwindow4(wind,TLX,TLY,BRX,BRY,8,0,boxtype,title,title2,shadow);
textcolor(7);
textbackground(0);
hback:=255;
ti:=top;
si:=current;
end;

procedure l_additem(fn,s:string);
begin

{ add items to a temp file for the new listbox procedure }

{ if the file doesn't exist, create it with the first item (leave blank rec)}

end;

{ new list box routine will use a temporary file instead of pointers for
storing larger amounts of entries in the menu.  Getting the }

procedure newlistbox(var wind:windowrec;var return:returntype;fname:string;var ti,si:longint; TLX,TLY,BRX,BRY,tcolr,bcolr,
        boxtype:integer;title,title2:string;shadow:boolean);
var total,x,current,top,height:integer;
    c:char;
    s:string;
    done:boolean;
    w2:windowrec;
    ii4,ii5:integer;
    lastscroll,fnd:integer;
    lf:file of listtemprec;
    l:listtemprec;


function findnumber:longint;
var n:integer;
begin
        findnumber:=filesize(lf);
end;

procedure findptr(x:longint);
var t,n:integer;
begin
        seek(lf,x-1);
        read(lf,l);
end;

function istagged(x:longint):boolean;
begin
        seek(lf,x-1);
        read(lf,l);
        istagged:=l.tagged;
end;

procedure writescrolldown;
var p:real;
perc:integer;
    oldcol:integer;
    x2,x3,hgt,perc2:integer;
begin
window(1,1,80,25);
p:=(current/total);
perc:=trunc(p*100);
hgt:=((bry-2) - (tly+3))+1;
if (current=1) then begin
                oldcol:=textattr;
                textcolor(tcolr);
                textbackground(bcolr);
                for x2:=(TLY+2) to (BRY-2) do begin
                        gotoxy(brx,x2);
                        write('°');
                end;
                gotoxy(brx,tly+2);
                write('Û');
                textattr:=oldcol;
                lastscroll:=0;
end {else if (current=total) then begin
                oldcol:=textattr;
                textcolor(tcolr);
                textbackground(bcolr);
                for x2:=(TLY+2) to (BRY-2) do begin
                        gotoxy(brx,x2);
                        write('°');
                end;
                gotoxy(brx,bry-2);
                write('Û');
                textattr:=oldcol;
                lastscroll:=hgt+1;
end} else begin
for x3:=1 to hgt do begin
        p:=(x3/hgt);
        if ((perc>=trunc((x3/hgt)*100)) and (perc<trunc(((x3+1)/hgt)*100))){ or
                (lastscroll=0) }then begin
                if (x3<>lastscroll) then begin
                oldcol:=textattr;
                textcolor(tcolr);
                textbackground(bcolr);
                for x2:=(TLY+2) to (BRY-2) do begin
                        gotoxy(brx,x2);
                        write('°');
                end;
                gotoxy(brx,(tly+3)+(x3-1));
                write('Û');
                textattr:=oldcol;
                lastscroll:=x3;
                x3:=hgt;
                end;
        end;
end;
end;
window(TLX+1,TLY+1,BRX-1,BRY-1);
end;


procedure redrawdata;
var x:integer;
begin
textcolor(7);
textbackground(0);
findptr(top);
for x:=1 to height do begin
        if (istagged((top+x)-1)) then begin
        gotoxy(1,x+1);
        textcolor(14);
        textbackground(0);
        write('þ');
        textcolor(7);
        end else begin
        gotoxy(1,x+1);
        textcolor(7);
        textbackground(0);
        write(' ');
        end;
        gotoxy(2,x+1);
        cwrite(mln(l.list,brx-(tlx+3)));
        if not(eof(lf)) then findptr(filepos(lf)+1);
end;
end;

function stripcolor(o:string):string;
var s,s2:string;
    count,i:integer;
    lc:boolean;
begin
  s2:=o;
  s:='';
  count:=0;
  i:=1;
  while (i<=length(o)-4) do begin
       if (o[i]='%') and (o[i+4]='%') and (o[i+1] in ['0'..'9']) and
                (o[i+2] in ['0'..'9']) and (o[i+3] in ['0'..'9']) then inc(i,4) else
                        s:=s+o[i];
       inc(i);
  end;
  if (length(o)>4) {and (i<length(o))} then begin
    if not((o[length(o)-4]='%') and (o[length(o)]='%') and (o[length(o)-3] in ['0'..'9'])
        and (o[length(o)-2] in ['0'..'9']) and (o[length(o)-1] in ['0'..'9'])) then begin
        for count:=i to (length(o)) do begin
                s:=s+(o[count]);
        end;
    end;
  end else begin
  s:=s2;
  end;
  stripcolor:=s;
end;

begin
assign(lf,fname);
{$I-} reset(lf); {$I+}
if (ioresult<>0) then begin
     displaybox('Error reading '+fname,2000);
     exit;
end;
seek(lf,0);
listbox_f10_pressed:=FALSE;
cursoron(FALSE);
height:=bry-(tly+3);
if (height<2) then exit;
setwindow2(wind,TLX,TLY,BRX,BRY,tcolr,bcolr,boxtype,title,title2,shadow);
window(1,1,80,25);
gotoxy(1,25);
textcolor(14);
textbackground(0);
clreol;
if (listbox_escape) then begin
write('Esc');
textcolor(7);
write('=Exit ');
end;
if (listbox_enter) then begin
textcolor(14);
write('Enter');
textcolor(7);
write('=Select ');
end;
if (listbox_f10) then begin
textcolor(14);
write('F10');
textcolor(7);
write('=Save ');
end;
if (listbox_insert) then begin
textcolor(14);
write('Ins');
textcolor(7);
write('=Insert ');
end;
if (listbox_delete) then begin
textcolor(14);
write('Del');
textcolor(7);
write('=Delete ');
end;
if (listbox_move) then begin
textcolor(14);
write('Alt-M');
textcolor(7);
write('=Move ');
end;
if (listbox_tag) then begin
textcolor(14);
write('Space');
textcolor(7);
write('=Tag Item ');
end;
if (listbox_bottom<>'') then begin
cwrite(listbox_bottom);
end;
window(TLX+1,TLY+1,BRX-1,BRY-1);
current:=si;
top:=ti;
done:=false;
total:=findnumber;
if (current>total) then current:=total;
if (top+height>total) and (top<>1) then top:=total-(height-1);
redrawdata;
lastscroll:=0;
if (total>height) then begin
    window(1,1,80,25);
    gotoxy(brx,tly+1);
    textcolor(tcolr);
    textbackground(bcolr);
    write('');
    for x:=(TLY+2) to (BRY-2) do begin
        gotoxy(brx,x);
        write('°');
    end;
    gotoxy(brx,bry-1);
    write('');
    window(TLX+1,TLY+1,BRX-1,BRY-1);
    writescrolldown;
end;
repeat
gotoxy(2,(current-top)+2);
textcolor(15);
textbackground(1);
findptr(current);
write(mln(stripcolor(l.list),brx-(tlx+3)));
while not(keypressed) do begin end;
c:=readkey;
case ord(c) of
        0:begin
                c:=readkey;
                case ord(c) of
                        68:if (listbox_f10) then begin
                           listbox_f10_pressed:=TRUE;
                 if (return.data[1]<>-1) then begin
                                gotoxy(2,(current-top)+2);
                                textcolor(7);
                                textbackground(0);
                                cwrite(mln(l.list,brx-(tlx+3)));
                                return.kind:=1;
                 end else begin
                                for x:=1 to 100 do return.data[x]:=-1;
                                                return.kind:=2;
                 end;
                 done:=TRUE;
                 end;
                        71:begin
                                if (current>1) then begin
                                gotoxy(2,(current-top)+2);
                                textcolor(7);
                                textbackground(0);
                                cwrite(mln(l.list,brx-(tlx+3)));
                                current:=1;
                                if (current<top) then begin
                                        top:=current;
                                        redrawdata;
                                end;
                                if (total>height) then writescrolldown;
                                end;
                        end;
                        73:begin
                                if (current>1) then begin
                                gotoxy(2,(current-top)+2);
                                textcolor(7);
                                textbackground(0);
                                cwrite(mln(l.list,brx-(tlx+3)));
                                if (current-height<1) then begin
                                        current:=1;
                                        top:=1;
                                        end else begin
                                                dec(current,height);
                                                if (top-height<1) then
                                                        top:=1
                                                else
                                                dec(top,height);
                                        end;
                                redrawdata;
                                if (total>height) then
                                writescrolldown;
                                end;
                        end;
                        79:begin
                                if (current<total) then begin
                                gotoxy(2,(current-top)+2);
                                textcolor(7);
                                textbackground(0);
                                cwrite(mln(l.list,brx-(tlx+3)));
                                current:=total;
                                if (total-(height)>0) then top:=total-(height-1) else
                                        top:=1;
                                redrawdata;
                                if (total>height) then writescrolldown;
                                end;
                        end;
                        81:begin
                                if (current<total) then begin
                                gotoxy(2,(current-top)+2);
                                textcolor(7);
                                textbackground(0);
                                cwrite(mln(l.list,brx-(tlx+3)));
                                if (current+height>total) then begin
                                        current:=total;
                                        top:=total-(height-1);
                                        if (top<1) then top:=1;
                                        end else begin
                                inc(current,height);
                                inc(top,height);
                                if (top+height>total) then top:=total-(height-1);
                                end;
                                redrawdata;
                                if (total>height) then writescrolldown;
                                end;
                        end;
                        82:begin
                                if (listbox_insert) then begin
                                gotoxy(2,(current-top)+2);
                                textcolor(7);
                                textbackground(0);
                                cwrite(mln(l.list,brx-(tlx+3)));
                                for x:=1 to 100 do return.data[x]:=-1;
                                return.data[1]:=current;
                                return.kind:=3;
                                done:=TRUE;
                                end;
                           end;
                        83:begin
                                if (listbox_delete) then begin
                                gotoxy(2,(current-top)+2);
                                textcolor(7);
                                textbackground(0);
                                cwrite(mln(l.list,brx-(tlx+3)));
                                for x:=1 to 100 do if return.data[x]=-1 then
                                        begin
                                                return.data[1]:=current;
                                                return.kind:=4;
                                                done:=TRUE;
                                                x:=100;
                                        end else begin
                                                done:=TRUE;
                                                return.kind:=4;
                                                x:=100;
                                        end;
                                end;
                        end;
                        50:begin
                                if (listbox_move) then begin
                                gotoxy(2,(current-top)+2);
                                textcolor(7);
                                textbackground(0);
                                cwrite(mln(l.list,brx-(tlx+3)));
                                for x:=1 to 99 do if (return.data[x]<>-1) then
                                        begin
                                                return.data[100]:=current;
                                                return.kind:=5;
                                                done:=TRUE;
                                                x:=99;
                                        end;
                                        end;
                                end;
                        72:begin {UP}
                                if (current>1) then begin
                                gotoxy(2,(current-top)+2);
                                textcolor(7);
                                textbackground(0);
                                cwrite(mln(l.list,brx-(tlx+3)));
                                dec(current);
                                if (current<top) then begin
                                        top:=current;
                                        redrawdata;
                                end;
                                if (total>height) then
                                writescrolldown;
                                end;
                        end;
                        80:begin
                                if (current<total) then begin
                                gotoxy(2,(current-top)+2);
                                textcolor(7);
                                textbackground(0);
                                cwrite(mln(l.list,brx-(tlx+3)));
                                inc(current);
                                if ((current-top)+1>height) then begin
                                        top:=top+1;
                                        redrawdata;
                                end;
                                if (total>height) then writescrolldown;
                                end;
                        end;
                        else if (listbox_allow_extra_func) then begin
                                if (pos(c,listbox_extrakeys_func)<>0) then begin
                                return.kind:=0;
                                return.data[100]:=ord(c);
                                done:=TRUE;
                                end;
                        end;
                end;
        end;
              ord('0')..ord('9'):if (listbox_goto) then begin

  setwindow(w2,29,12,52,14,3,0,8,'',TRUE);
  gotoxy(2,1);
  textcolor(7);
  textbackground(0);
  write('Goto Number  : ');
  gotoxy(17,1);
  s:=c;
  infield_inp_fgrd:=15;
  infield_inp_bkgd:=1;
  infield_out_fgrd:=3;
  infield_out_bkgd:=0;
  infield_allcaps:=false;
  infield_numbers_only:=TRUE;
  infield_escape_zero:=FALSE;
  infield_escape_blank:=TRUE;
  infield_putatend:=TRUE;
  infield_clear:=FALSE;
  infield_insert:=TRUE;
  infielde(s,5);
  infield_escape_blank:=FALSE;
  infield_putatend:=FALSE;
  infield_clear:=TRUE;
  infield_insert:=TRUE;
  ii4:=value(s);
  if ((ii4>=0) and (ii4<=total)) and (s<>'') then begin
  ii5:=current;
  current:=ii4+listbox_goto_offset;
  top:=ii4+listbox_goto_offset;
  if (top+height>total) then top:=total-(height-1);
  if (ii4+listbox_goto_offset>ii5) then begin
        if (total>height) then writescrolldown;
  end else begin
        if (total>height) then writescrolldown;
  end;
  end;
  removewindow(w2);
  window(TLX+1,TLY+1,BRX-1,BRY-1);
  redrawdata;
                        end;
        13:if (listbox_enter) then begin
                fnd:=-1;
                for x:=1 to 99 do begin
                        if return.data[x]=current then begin
                                fnd:=x;
                                x:=99;
                        end;
                end;
                if (fnd=-1) then begin
                for x:=1 to 98 do begin
                        if (current>return.data[x]) then begin
                                if (return.data[x]=-1) then begin
                                        fnd:=x;
                                        x:=98;
                                end else
                                if (current<return.data[x+1]) or (return.data[x+1]=-1) then
                                begin
                                fnd:=x+1;
                                x:=98;
                                end;
                        end;
                end;
                if (fnd<>-1) then begin
                        if (return.data[fnd]=-1) then begin
                                return.data[fnd]:=current;
                        end else begin
                                x:=99;
                                if (return.data[99]=-1) then begin
                                while (x>fnd) do begin
                                        return.data[x]:=return.data[x-1];
                                        dec(x);
                                end;
                                return.data[fnd]:=current;
                                end else begin
                                        gotoxy(1,(current-top)+2);
                                        textcolor(14);
                                        textbackground(0);
                                        write(' ');
                                end;
                        end;
                end;
                end;
                                gotoxy(2,(current-top)+2);
                                textcolor(7);
                                textbackground(0);
                                cwrite(mln(l.list,brx-(tlx+3)));
                                return.kind:=1;
                                done:=TRUE;
            end;
        32:if (listbox_tag) then begin
                fnd:=-1;
                for x:=1 to 99 do begin
                        if return.data[x]=current then begin
                                fnd:=x;
                                x:=99;
                        end;
                end;
                if (fnd=-1) then begin
                gotoxy(1,(current-top)+2);
                textcolor(14);
                textbackground(0);
                write('þ');
                for x:=1 to 98 do begin
                        if (current>return.data[x]) then begin
                                if (return.data[x]=-1) then begin
                                        fnd:=x;
                                        x:=98;
                                end else
                                if (current<return.data[x+1]) or (return.data[x+1]=-1) then
                                begin
                                fnd:=x+1;
                                x:=98;
                                end;
                        end;
                end;
                if (fnd<>-1) then begin
                        if (return.data[fnd]=-1) then begin
                                return.data[fnd]:=current;
                        end else begin
                                x:=99;
                                if (return.data[99]=-1) then begin
                                while (x>fnd) do begin
                                        return.data[x]:=return.data[x-1];
                                        dec(x);
                                end;
                                return.data[fnd]:=current;
                                end else begin
                                        gotoxy(1,(current-top)+2);
                                        textcolor(14);
                                        textbackground(0);
                                        write(' ');
                                end;
                        end;
                end;
                end else begin
                gotoxy(1,(current-top)+2);
                textcolor(14);
                textbackground(0);
                write(' ');
                for x:=fnd to 99 do begin
                        return.data[x]:=return.data[x+1];
                end;
                return.data[100]:=-1;
                end;
            end;
        27:if (listbox_escape) then begin
                if (return.data[1]<>-1) then begin
                   if pynqbox('Clear all items tagged? ') then begin
                                     for x:=1 to 100 do return.data[x]:=-1;
                                     return.kind:=2;
                   end else begin
                                window(TLX+1,TLY+1,BRX-1,BRY-1);
                                gotoxy(2,(current-top)+2);
                                textcolor(7);
                                textbackground(0);
                                cwrite(mln(l.list,brx-(tlx+3)));
                                return.kind:=1;
                   end;
                end else begin
                for x:=1 to 100 do return.data[x]:=-1;
                return.kind:=2;
                end;
                done:=TRUE;
        end;
        else if (listbox_allow_extra) then begin
             if (pos(c,listbox_extrakeys)<>0) then begin
                done:=TRUE;
                return.kind:=254;
                return.data[100]:=ord(c);
             end;
        end;
end;
until (done);
setwindow4(wind,TLX,TLY,BRX,BRY,8,0,boxtype,title,title2,shadow);
textcolor(7);
textbackground(0);
hback:=255;
ti:=top;
si:=current;
close(lf);
end;

procedure movewindow(wind:windowrec; TLX,TLY:integer);
var BRX,BRY,x,y,i:integer;
begin
  checkvidseg;

  window(1,1,80,25);
  color(14,0);

  BRX:=wind[4002]; BRY:=wind[4003];
  inc(BRX,TLX-wind[4000]); inc(BRY,TLY-wind[4001]);

  i:=0;
  for y:=TLY to BRY do
    for x:=TLX to BRX do begin
      inline($FA);
      mem[vidseg:(160*(y-1)+2*(x-1))]:=wind[i];
      mem[vidseg:(160*(y-1)+2*(x-1))+1]:=wind[i+1];
      inline($FB);
      inc(i,2);
    end;
end;

end.
