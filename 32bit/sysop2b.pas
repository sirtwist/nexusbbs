(*****************************************************************************)
(*>                                                                         <*)
(*>                                                                         <*)
(*>  SysOp functions: System Configuration Editor -- "B" command.           <*)
(*>                                                                         <*)
(*>                                                                         <*)
(*****************************************************************************)
{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R-,S+,V-}
unit sysop2b;

interface

uses
  crt, dos, sysop3, myio, misc, procspec;

procedure pofile;

implementation


procedure gettimezone;
var x:integer;
    done:boolean;
    top,cur:integer;
    firstlp,lp,lp2:listptr;
    c3:char;
    rt:returntype;
    w2:windowrec;
    s:string;
begin
done:=false;
                                new(lp);
                                lp^.p:=NIL;
                                lp^.list:='(GMT-12:00) Eniwetok, Kwajalein';
                                firstlp:=lp;

for x:=2 to 51 do begin
case x of
2:s:='(GMT-11:00) Midway Island, Samoa';
3:s:='(GMT-10:00) Hawaii';
4:s:='(GMT-09:00) Alaska';
5:s:='(GMT-08:00) Pacific Time (U.S. & Canada); Tijuana';
6:s:='(GMT-07:00) Arizona';
7:s:='(GMT-07:00) Mountain Time (U.S. & Canada)';
8:s:='(GMT-06:00) Central Time (U.S. & Canada)';
9:s:='(GMT-06:00) Mexico City, Tegucigalpa';
10:s:='(GMT-06:00) Saskatchewan';
11:s:='(GMT-05:00) Bogota, Lima';
12:s:='(GMT-05:00) Eastern Time (U.S. & Canada)';
13:s:='(GMT-05:00) Indiana (East)';
14:s:='(GMT-04:00) Atlantic Time (Canada)';
15:s:='(GMT-04:00) Caracas, La Paz';
16:s:='(GMT-03:30) Newfoundland';
17:s:='(GMT-03:00) Brasilia';
18:s:='(GMT-03:00) Buenos Aires, Georgetown';
19:s:='(GMT-02:00) Mid-Atlantic';
20:s:='(GMT-01:00) Azores, Cape Verde Is.';
21:s:='(GMT) Greenwich Mean Time; Dublin, Edinburgh, London';
22:s:='(GMT) Monrovia, Casablanca';
23:s:='(GMT+01:00) Berlin, Stockholm, Rome, Vienna, Amsterdam';
24:s:='(GMT+01:00) Lisbon, Warsaw';
25:s:='(GMT+01:00) Paris, Madrid';
26:s:='(GMT+01:00) Prague';
27:s:='(GMT+02:00) Athens, Helsinki, Istanbul';
28:s:='(GMT+02:00) Cairo';
29:s:='(GMT+02:00) Eastern Europe';
30:s:='(GMT+02:00) Harare, Pretoria';
31:s:='(GMT+02:00) Israel';
32:s:='(GMT+03:00) Baghdad, Kuwait, Nairobi, Riyadh';
33:s:='(GMT+03:00) Moscow, St. Petersburg';
34:s:='(GMT+03:30) Tehran';
35:s:='(GMT+04:00) Abu Dhabi, Muscat, Tbalisi, Kazan, Volgograd';
36:s:='(GMT+04:30) Kabul';
37:s:='(GMT+05:00) Islamabad, Karachi, Ekaterinburg, Tashkent';
38:s:='(GMT+05:30) Bombay, Calcutta, Madras, New Delhi, Colombo';
39:s:='(GMT+06:00) Almaty, Dhaka';
40:s:='(GMT+07:00) Bangkok, Jakarta, Hanoi';
41:s:='(GMT+08:00) Beijing, Chongqing, Urumqi';
42:s:='(GMT+08:00) Hong Kong, Perth, Singapore, Taipei';
43:s:='(GMT+09:00) Toyko, Osaka, Sapporo, Seoul, Yakutsk';
44:s:='(GMT+09:30) Adelaide';
45:s:='(GMT+09:30) Darwin';
46:s:='(GMT+10:00) Brisbane, Melbourne, Sydney';
47:s:='(GMT+10:00) Guam, Port Moresby, Vladivostok';
48:s:='(GMT+10:00) Hobart';
49:s:='(GMT+11:00) Magadan, Solomon Is., New Caledonia';
50:s:='(GMT+12:00) Fiji, Kamchatka, Marshall Is.';
51:s:='(GMT+12:00) Wellington, Auckland';
end;
                                new(lp2);
                                lp2^.p:=lp;
                                lp^.n:=lp2;
                                lp2^.list:=s;
                                lp:=lp2;
end;
                                lp^.n:=NIL;
                                if (systat.timezone>0) and (systat.timezone<=51) then begin
                                top:=systat.timezone;
                                cur:=systat.timezone;
                                end else begin
                                top:=1;
                                cur:=1;
                                end;
                                repeat
                                for x:=1 to 100 do rt.data[x]:=-1;
                                lp:=firstlp;
                                listbox_f10:=FALSE;
                                listbox_escape:=TRUE;
                                listbox_enter:=TRUE;
                                listbox_insert:=FALSE;
                                listbox_delete:=FALSE;
                                listbox_tag:=FALSE;
                                listbox_move:=FALSE;
                                listbox(w2,rt,top,cur,lp,3,9,76,22,3,0,8,'Time Zone','',TRUE);
                                listbox_f10:=TRUE;
                                listbox_escape:=TRUE;
                                listbox_enter:=TRUE;
                                listbox_insert:=TRUE;
                                listbox_delete:=TRUE;
                                listbox_tag:=TRUE;
                                listbox_move:=TRUE;
                                textcolor(7);
                                textbackground(0);
                                case rt.kind of
                                        0:begin
                                                c3:=chr(rt.data[100]);
                                                removewindow(w2);
                                                checkkey(c3);
                                                rt.data[100]:=-1;
                                          end;
                                        1:begin
                                                removewindow(w2);
                                                if (rt.data[1])<>-1 then begin
                                                                systat.timezone:=rt.data[1];
                                                                done:=TRUE;
                                                                lp:=firstlp;
                                                                while (lp<>NIL) do begin
                                                                        lp2:=lp^.n;
                                                                        dispose(lp);
                                                                        lp:=lp2;
                                                                end;
                                                end;
                                          end;
                                        2:begin
                                                removewindow(w2);
                                                lp:=firstlp;
                                                while (lp<>NIL) do begin
                                                        lp2:=lp^.n;
                                                        dispose(lp);
                                                        lp:=lp2;
                                                end;
                                                done:=TRUE;
                                        end;
                                   end;
until (done);
end;

function showtimezone:string;
var s:string;
begin
case systat.timezone of
1:s:='(GMT-12:00) Eniwetok, Kwajalein';
2:s:='(GMT-11:00) Midway Island, Samoa';
3:s:='(GMT-10:00) Hawaii';
4:s:='(GMT-09:00) Alaska';
5:s:='(GMT-08:00) Pacific Time (U.S. & Canada); Tijuana';
6:s:='(GMT-07:00) Arizona';
7:s:='(GMT-07:00) Mountain Time (U.S. & Canada)';
8:s:='(GMT-06:00) Central Time (U.S. & Canada)';
9:s:='(GMT-06:00) Mexico City, Tegucigalpa';
10:s:='(GMT-06:00) Saskatchewan';
11:s:='(GMT-05:00) Bogota, Lima';
12:s:='(GMT-05:00) Eastern Time (U.S. & Canada)';
13:s:='(GMT-05:00) Indiana (East)';
14:s:='(GMT-04:00) Atlantic Time (Canada)';
15:s:='(GMT-04:00) Caracas, La Paz';
16:s:='(GMT-03:30) Newfoundland';
17:s:='(GMT-03:00) Brasilia';
18:s:='(GMT-03:00) Buenos Aires, Georgetown';
19:s:='(GMT-02:00) Mid-Atlantic';
20:s:='(GMT-01:00) Azores, Cape Verde Is.';
21:s:='(GMT) Greenwich Mean Time; Dublin, Edinburgh, London';
22:s:='(GMT) Monrovia, Casablanca';
23:s:='(GMT+01:00) Berlin, Stockholm, Rome, Vienna, Amsterdam';
24:s:='(GMT+01:00) Lisbon, Warsaw';
25:s:='(GMT+01:00) Paris, Madrid';
26:s:='(GMT+01:00) Prague';
27:s:='(GMT+02:00) Athens, Helsinki, Istanbul';
28:s:='(GMT+02:00) Cairo';
29:s:='(GMT+02:00) Eastern Europe';
30:s:='(GMT+02:00) Harare, Pretoria';
31:s:='(GMT+02:00) Israel';
32:s:='(GMT+03:00) Baghdad, Kuwait, Nairobi, Riyadh';
33:s:='(GMT+03:00) Moscow, St. Petersburg';
34:s:='(GMT+03:30) Tehran';
35:s:='(GMT+04:00) Abu Dhabi, Muscat, Tbalisi, Kazan, Volgograd';
36:s:='(GMT+04:30) Kabul';
37:s:='(GMT+05:00) Islamabad, Karachi, Ekaterinburg, Tashkent';
38:s:='(GMT+05:30) Bombay, Calcutta, Madras, New Delhi, Colombo';
39:s:='(GMT+06:00) Almaty, Dhaka';
40:s:='(GMT+07:00) Bangkok, Jakarta, Hanoi';
41:s:='(GMT+08:00) Beijing, Chongqing, Urumqi';
42:s:='(GMT+08:00) Hong Kong, Perth, Singapore, Taipei';
43:s:='(GMT+09:00) Toyko, Osaka, Sapporo, Seoul, Yakutsk';
44:s:='(GMT+09:30) Adelaide';
45:s:='(GMT+09:30) Darwin';
46:s:='(GMT+10:00) Brisbane, Melbourne, Sydney';
47:s:='(GMT+10:00) Guam, Port Moresby, Vladivostok';
48:s:='(GMT+10:00) Hobart';
49:s:='(GMT+11:00) Magadan, Solomon Is., New Caledonia';
50:s:='(GMT+12:00) Fiji, Kamchatka, Marshall Is.';
51:s:='(GMT+12:00) Wellington, Auckland';
else s:='Not defined';
end;
showtimezone:=s;
end;

procedure pofile;
var s:string[80];
    x,current,i:integer;
    c:char;
    choice:array[1..6] of string[25];
    desc:array[1..6] of string;
    abort,next,done:boolean;
begin
  choice[1]:='BBS Name            :';
  choice[2]:='SysOp''s Name/Alias  :';
  choice[3]:='Pre-Event Warning   :';
  choice[4]:='SysOp Password      :';
  choice[5]:='New User Password   :';
  choice[6]:='Your Time Zone      :';
  desc[1]:='Name of this Bulletin Board System';
  desc[2]:='SysOp''s name or alias';
  desc[3]:='Warning time before an event takes place in minutes';
  desc[4]:='Password for those with security level above Sysop Password SL';
  desc[5]:='Password to be able to log on as a New User';
  desc[6]:='The local Time Zone of where you are located';
  setwindow(w,2,10,77,19,3,0,8,'Main System Configuration',TRUE);
  current:=1;
  textcolor(7);
  textbackground(0);
  for x:=1 to 6 do begin
        gotoxy(2,x+1);
        write(choice[x]);
  end;        
  with systat do begin
  textcolor(3);
  gotoxy(24,2);
  write(bbsname);  
  gotoxy(24,3);
  write(sysopname);
  gotoxy(24,4);
  write(cstr(eventwarningtime));
  gotoxy(24,5);
  write(sysoppw);
  gotoxy(24,6);
  write(newuserpw);
  gotoxy(24,7);
  write(mln(showtimezone,50));
  end;
  done:=FALSE;
  repeat
    with systat do begin
    textcolor(14);
    textbackground(0);
    window(1,1,80,25);
    gotoxy(1,25);
    clreol;
    cwrite('%140%Esc%070%=Exit %140%'+desc[current]);
    window(3,11,76,17);
    gotoxy(2,current+1);
    textcolor(15);
    textbackground(1);
    write(choice[current]);
    while not(keypressed) do begin timeslice; end;
    c:=readkey;
    case ord(c) of
        0:begin
                c:=readkey;
                checkkey(c);
                case ord(c) of
                        68:done:=TRUE;
                        72:begin
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choice[current]);
                                dec(current);
                                if (current=0) then current:=6;
                        end;
                        80:begin
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choice[current]);
                                inc(current);
                                if (current=7) then current:=1;
                        end;
                end;
        end;
        13:begin
                case current of
                1:begin
                                infield_inp_fgrd:=15;
                                infield_inp_bkgd:=1;
                                infield_out_fgrd:=3;
                                infield_out_bkgd:=0;
                                infield_allcaps:=False;
                                infield_numbers_only:=false;
                                infield_address:=false;
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choice[current]);
                                gotoxy(22,current+1);
                                textcolor(9);
                                textbackground(0);
                                write('>');
                                gotoxy(24,current+1);
                                s:=bbsname;
                                infielde(s,40);
                                bbsname:=s;
                end;
                2:begin
                                infield_inp_fgrd:=15;
                                infield_inp_bkgd:=1;
                                infield_out_fgrd:=3;
                                infield_out_bkgd:=0;
                                infield_allcaps:=False;
                                infield_numbers_only:=false;
                                infield_address:=false;
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choice[current]);
                                gotoxy(22,current+1);
                                textcolor(9);
                                textbackground(0);
                                write('>');
                                gotoxy(24,current+1);
                                s:=sysopname;
                                infielde(s,30);
                                sysopname:=s;
                end;
                3:begin
                                infield_inp_fgrd:=15;
                                infield_inp_bkgd:=1;
                                infield_out_fgrd:=3;
                                infield_out_bkgd:=0;
                                infield_allcaps:=False;
                                infield_numbers_only:=TRUE;
                                infield_address:=false;
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choice[current]);
                                gotoxy(22,current+1);
                                textcolor(9);
                                textbackground(0);
                                write('>');
                                gotoxy(24,current+1);
                                s:=cstr(eventwarningtime);
                                infielde(s,5);
                                eventwarningtime:=value(s);
                                infield_numbers_only:=false;
                end;
                4:begin
                                infield_inp_fgrd:=15;
                                infield_inp_bkgd:=1;
                                infield_out_fgrd:=3;
                                infield_out_bkgd:=0;
                                infield_allcaps:=TRUE;
                                infield_numbers_only:=false;
                                infield_address:=false;
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choice[current]);
                                gotoxy(22,current+1);
                                textcolor(9);
                                textbackground(0);
                                write('>');
                                gotoxy(24,current+1);
                                s:=sysoppw;
                                infielde(s,20);
                                infield_allcaps:=TRUE;
                                if (s<>sysoppw) then begin
                                        sysoppw:=s;
                                end;
                end;
                5:begin
                                infield_inp_fgrd:=15;
                                infield_inp_bkgd:=1;
                                infield_out_fgrd:=3;
                                infield_out_bkgd:=0;
                                infield_allcaps:=False;
                                infield_numbers_only:=false;
                                infield_address:=false;
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choice[current]);
                                gotoxy(22,current+1);
                                textcolor(9);
                                textbackground(0);
                                write('>');
                                gotoxy(24,current+1);
                                s:=newuserpw;
                                infielde(s,20);
                                newuserpw:=s;
                end;
              6:begin
                gettimezone;
                window(3,11,76,17);
                gotoxy(24,7);
                textcolor(3);
                write(mln(showtimezone,50));
                end;
    end;
    end;
    27:done:=TRUE;
    end;
  end;
until (done);
removewindow(w);
end;

end.
