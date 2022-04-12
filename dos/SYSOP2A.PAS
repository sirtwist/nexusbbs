(*****************************************************************************)
(*>                                                                         <*)
(*>  Copyright 1993 Intuitive Vision Software.                              <*)
(*>  All Rights Reserved.                                                   <*)
(*>                                                                         <*)
(*>  Module name:       SYSOP2A.PAS                                         <*)
(*>  Module purpose:    System Configuration "A" command                    <*)
(*>                     (Modem Configuration)                               <*)
(*>                                                                         <*)
(*****************************************************************************)
{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R+,S+,V-}
unit sysop2a;

interface

uses
  crt, dos, myio, misc, procspec;

procedure pomodem;

implementation

type modemrec2=^modemrec;
var  thisnode:integer;
     modemr2:modemrec2;
     changed:boolean;


function phours(s:string; lotime,hitime:integer):string;
begin
  if (lotime<>0) or (hitime<>0) then
    phours:=tch(cstr(lotime div 60))+':'+tch(cstr(lotime mod 60))+' to '+
            tch(cstr(hitime div 60))+':'+tch(cstr(hitime mod 60))
  else
    phours:=s;
end;

function phours2(lotime,hitime:integer):string;
begin
  phours2:=tch(cstr(lotime div 60))+':'+tch(cstr(lotime mod 60))+' to '+
            tch(cstr(hitime div 60))+':'+tch(cstr(hitime mod 60))
end;

procedure inu2(var i:integer);
var s:string;
begin
  infield_inp_fgrd:=15;
  infield_inp_bkgd:=1;
  infield_out_fgrd:=3;
  infield_out_bkgd:=0;
  infield_allcaps:=false;
  infield_numbers_only:=TRUE;
  infield_min_value:=0;
  infield_max_value:=24;
  infield_putatend:=TRUE;
  infield_clear:=TRUE;
  infield_insert:=FALSE;
  s:=copy(cstrn(i),3,2);
  infielde(s,2);
  infield_putatend:=FALSE;
  infield_clear:=FALSE;
  infield_insert:=TRUE;
  i:=value(s);
end;

procedure inu3(var i:integer);
var s:string;
begin
  infield_inp_fgrd:=15;
  infield_inp_bkgd:=1;
  infield_out_fgrd:=3;
  infield_out_bkgd:=0;
  infield_allcaps:=false;
  infield_numbers_only:=TRUE;
  infield_min_value:=0;
  infield_max_value:=59;
  infield_putatend:=TRUE;
  infield_clear:=TRUE;
  infield_insert:=FALSE;
  s:=copy(cstrn(i),3,2);
  infielde(s,2);
  infield_putatend:=FALSE;
  infield_clear:=FALSE;
  infield_insert:=TRUE;
  i:=value(s);
end;

procedure gettimerange(s:string; var st1,st2:integer);
var startx,starty,t1,t2,t1h,t1m,t2h,t2m:integer;
    s2:string;
begin
  startx:=wherex;
  starty:=wherey;
  textcolor(3);
  textbackground(0);
  write(mln(' ',length(s)));
  gotoxy(startx,starty);
  t1:=st1;
  t2:=st2;
  t1h:=trunc(t1/60);
  t1m:=t1 mod 60;
  t2h:=trunc(t2/60);
  t2m:=t2 mod 60;
  s2:=phours2(t1,t2);
  write(s2);
  gotoxy(startx,starty);
  inu2(t1h);
  if (t1h<0) or (t1h>23) then t1h:=0;
  gotoxy(startx+3,starty);
  inu3(t1m);
  if (t1m<0) or (t1m>59) then t1m:=0;
  gotoxy(startx+9,starty);
  inu2(t2h);
  if (t2h<0) or (t2h>23) then t2h:=0;
  gotoxy(startx+12,starty);
  inu3(t2m);
  if (t2m<0) or (t2m>59) then t2m:=0;
  t1:=(t1h*60)+t1m; t2:=(t2h*60)+t2m;
  if (t1<>0) and (t2=0) then t2:=(23*60)+59;
  gotoxy(startx,starty);
  s2:=phours(s,t1,t2);
  textcolor(3);
  textbackground(0);
  write(s2);
  st1:=t1;
  st2:=t2;
end;

function swapchoice(i:byte):string;
var s:string;
begin
case i of
        0:s:='None       ';
        1:s:='Disk       ';
        2:s:='XMS        ';
        3:s:='EMS        ';
        4:s:='Best Method';
end;
swapchoice:=s;
end;

procedure getpagehours(s:string;b:byte);
var choices:array[1..7] of string[20];
    current,x:integer;
    w2:windowrec;
    c:char;
    done:boolean;
begin
with modemr2^ do begin
    setwindow(w2,20,9,60,19,3,0,8,s,TRUE);
    choices[1]:='Sunday    :';
    choices[2]:='Monday    :';
    choices[3]:='Tuesday   :';
    choices[4]:='Wednesday :';
    choices[5]:='Thursday  :';
    choices[6]:='Friday    :';
    choices[7]:='Saturday  :';
    for x:=1 to 7 do begin
        textcolor(7);
        textbackground(0);
        gotoxy(2,x+1);
        write(choices[x]);
        textcolor(3);
        textbackground(0);
        write(' ');
        case b of
                1:write(mln(phours('Always Available',lowtime[x],hitime[x]),16));
                2:write(mln(phours('Never Allowed',lockbegintime[x],lockendtime[x]),16));
                3:write(mln(phours('Never Allowed',lockbegin_dltime[x],lockend_dltime[x]),16));
                4:write(mln(phours('Always Allowed',dllowtime[x],dlhitime[x]),16));
        end;
    end;
    current:=1;
    done:=FALSE;
    repeat
    gotoxy(2,current+1);
    textcolor(15);
    textbackground(1);
    write(choices[current]);
    while not(keypressed) do begin timeslice; end;
    c:=readkey;
    case c of
                #0:begin
                        c:=readkey;
                        case c of
                                #68:done:=TRUE;
                                #72:begin
                                        gotoxy(2,current+1);
                                        textcolor(7);
                                        textbackground(0);
                                        write(choices[current]);
                                        dec(current);
                                        if (current<1) then current:=7;
                                    end;
                                #80:begin
                                        gotoxy(2,current+1);
                                        textcolor(7);
                                        textbackground(0);
                                        write(choices[current]);
                                        inc(current);
                                        if (current>7) then current:=1;
                                    end;
                        end;
                   end;
              #13:begin
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choices[current]);
                                gotoxy(12,current+1);
                                textcolor(9);
                                textbackground(0);
                                write('>');
                                gotoxy(14,current+1);
                                case b of
                                1:gettimerange('Always Available          ',lowtime[current],hitime[current]);
                                2:gettimerange('Never Allowed             ',lockbegintime[current],lockendtime[current]);
                                3:gettimerange('Never Allowed             ',
                                        lockbegin_dltime[current],lockend_dltime[current]);
                                4:gettimerange('Always Allowed            ',dllowtime[current],dlhitime[current]);
                                end;
                                changed:=TRUE;
                  end;
              #27:done:=TRUE;
         end;
until (done);
removewindow(w2);
end;
end;

procedure pomodem;
var modemrf:file of modemrec;
    x,i,c1,c2,cc,current:integer;
    s,s2:string;
    c,ccc:char;
    choices:array[1..18] of string[30];
    desc:array[1..18] of string;
    maxshown,line,current2:integer;
    d:searchrec;
    redraw,update,autosave,abort,next,done:boolean;



procedure getswap;
var choice:array[1..6] of string[15];
    x2,curr:integer;
    c2:char;
    w2:windowrec;
    done2:boolean;

begin
done2:=false;
choice[1]:='Protocols   :';
choice[2]:='Archivers   :';
choice[3]:='Doors       :';
choice[4]:='Editors     :';
choice[5]:='Ext. Chat   :';
choice[6]:='Local Shell :';
curr:=1;
setwindow(w2,25,10,55,19,3,0,8,'Swapping',TRUE);
        textcolor(7);
        textbackground(0);
for x2:=1 to 6 do begin
        gotoxy(2,x2+1);
        write(choice[x2]);
end;
repeat
gotoxy(16,2);
textcolor(3);
textbackground(0);
write(swapchoice(modemr2^.swapprotocol));
gotoxy(16,3);
textcolor(3);
write(swapchoice(modemr2^.swaparchiver));
gotoxy(16,4);
textcolor(3);
write(swapchoice(modemr2^.swapdoor));
gotoxy(16,5);
textcolor(3);
write(swapchoice(modemr2^.swapeditor));
gotoxy(16,6);
textcolor(3);
write(swapchoice(modemr2^.swapchat));
gotoxy(16,7);
textcolor(3);
write(swapchoice(modemr2^.swaplocalshell));
gotoxy(2,curr+1);
textcolor(15);
textbackground(1);
write(choice[curr]);
while not(keypressed) do begin timeslice; end;
c2:=readkey;
case c2 of
        #0:begin
                c2:=readkey;
                checkkey(c2);
                case c2 of
                        #68:done:=TRUE;
                        #72:begin
                                gotoxy(2,curr+1);
                                textcolor(7);
                                textbackground(0);
                                write(choice[curr]);
                                dec(curr);
                                if (curr=0) then curr:=6;
                        end;
                        #80:begin
                                gotoxy(2,curr+1);
                                textcolor(7);
                                textbackground(0);
                                write(choice[curr]);
                                inc(curr);
                                if (curr=7) then curr:=1;
                        end;
                end;
        end;
        #13:begin
                changed:=TRUE;
                case curr of
                        1:begin
                                inc(modemr2^.swapprotocol);
                                if (modemr2^.swapprotocol>4) then modemr2^.swapprotocol:=0;
                          end;
                        2:begin
                                inc(modemr2^.swaparchiver);
                                if (modemr2^.swaparchiver>4) then modemr2^.swaparchiver:=0;
                          end;
                        3:begin
                                inc(modemr2^.swapdoor);
                                if (modemr2^.swapdoor>4) then modemr2^.swapdoor:=0;
                          end;
                        4:begin
                                inc(modemr2^.swapeditor);
                                if (modemr2^.swapeditor>4) then modemr2^.swapeditor:=0;
                          end;
                        5:begin
                                inc(modemr2^.swapchat);
                                if (modemr2^.swapchat>4) then modemr2^.swapchat:=0;
                          end;
                        6:begin
                                inc(modemr2^.swaplocalshell);
                                if (modemr2^.swaplocalshell>4) then modemr2^.swaplocalshell:=0;
                          end;
                end;
        end;
        #27:done2:=TRUE;
end;
until (done2);
removewindow(w2);
end;

procedure getrespmain;
var choice:array[1..5] of string[15];
    x2,curr:integer;
    c2:char;
    w2:windowrec;
    done2:boolean;

begin
done2:=false;
choice[1]:='Successful    :';
choice[2]:='Error         :';
choice[3]:='No carrier    :';
choice[4]:='Ring          :';
choice[5]:='Connect/Other :';
curr:=1;
setwindow(w2,4,11,76,19,3,0,8,'Modem Responses',TRUE);
        textcolor(7);
        textbackground(0);
for x2:=1 to 5 do begin
        gotoxy(2,x2+1);
        write(choice[x2]);
end;
repeat
gotoxy(18,2);
textcolor(3);
textbackground(0);
write(mln(modemr2^.rspok,40));
gotoxy(18,3);
textcolor(3);
write(mln(modemr2^.rsperror,40));
gotoxy(18,4);
textcolor(3);
write(mln(modemr2^.rspcarrier,40));
gotoxy(18,5);
textcolor(3);
write(mln(modemr2^.rspring,40));
gotoxy(2,curr+1);
textcolor(15);
textbackground(1);
write(choice[curr]);
while not(keypressed) do begin timeslice; end;
c2:=readkey;
case c2 of
        #0:begin
                c2:=readkey;
                checkkey(c2);
                case c2 of
                        #68:done:=TRUE;
                        #72:begin
                                gotoxy(2,curr+1);
                                textcolor(7);
                                textbackground(0);
                                write(choice[curr]);
                                dec(curr);
                                if (curr=0) then curr:=5;
                        end;
                        #80:begin
                                gotoxy(2,curr+1);
                                textcolor(7);
                                textbackground(0);
                                write(choice[curr]);
                                inc(curr);
                                if (curr=6) then curr:=1;
                        end;
                end;
        end;
        #13:begin
                changed:=TRUE;
                              gotoxy(2,curr+1);
                              textcolor(7);
                              textbackground(0);
                              write(choice[curr]);
                              gotoxy(16,curr+1);
                              textcolor(9);
                              textbackground(0);
                              write('>');
                              gotoxy(18,curr+1);
                case curr of
                        1:begin
                              s:=modemr2^.rspok;
                              infield_inp_fgrd:=15;
                              infield_inp_bkgd:=1;
                              infield_out_fgrd:=3;
                              infield_out_bkgd:=0;
                              infield_allcaps:=TRUE;
                              infield_insert:=TRUE;
                              infield_putatend:=TRUE;
                              infield_clear:=TRUE;
                              infield_numbers_only:=FALSE;
                              infielde(s,20);
                              infield_maxshow:=0;
                              if (s<>modemr2^.rspok) then begin
                                    modemr2^.rspok:=s;
                                    changed:=TRUE;
                              end;
                        end;
                        2:begin
                              s:=modemr2^.rsperror;
                              infield_inp_fgrd:=15;
                              infield_inp_bkgd:=1;
                              infield_out_fgrd:=3;
                              infield_out_bkgd:=0;
                              infield_allcaps:=TRUE;
                              infield_insert:=TRUE;
                              infield_putatend:=TRUE;
                              infield_clear:=TRUE;
                              infield_numbers_only:=FALSE;
                              infielde(s,20);
                              infield_maxshow:=0;
                              if (s<>modemr2^.rsperror) then begin
                                    modemr2^.rsperror:=s;
                                    changed:=TRUE;
                              end;
                        end;
                        3:begin
                              s:=modemr2^.rspcarrier;
                              infield_inp_fgrd:=15;
                              infield_inp_bkgd:=1;
                              infield_out_fgrd:=3;
                              infield_out_bkgd:=0;
                              infield_allcaps:=TRUE;
                              infield_insert:=TRUE;
                              infield_putatend:=TRUE;
                              infield_clear:=TRUE;
                              infield_numbers_only:=FALSE;
                              infielde(s,20);
                              infield_maxshow:=0;
                              if (s<>modemr2^.rspcarrier) then begin
                                    modemr2^.rspcarrier:=s;
                                    changed:=TRUE;
                              end;
                        end;
                        4:begin
                              s:=modemr2^.rspring;
                              infield_inp_fgrd:=15;
                              infield_inp_bkgd:=1;
                              infield_out_fgrd:=3;
                              infield_out_bkgd:=0;
                              infield_allcaps:=TRUE;
                              infield_insert:=TRUE;
                              infield_putatend:=TRUE;
                              infield_clear:=TRUE;
                              infield_numbers_only:=FALSE;
                              infielde(s,20);
                              infield_maxshow:=0;
                              if (s<>modemr2^.rspring) then begin
                                    modemr2^.rspring:=s;
                                    changed:=TRUE;
                              end;
                        end;
                end;
        end;
        #27:done2:=TRUE;
end;
until (done2);
removewindow(w2);
end;

procedure getmodemstrings;
var choice:array[1..8] of string[15];
    x2,curr:integer;
    c2:char;
    w2:windowrec;
    done2:boolean;

begin
done2:=false;
choice[1]:='Init #1     :';
choice[2]:='Init #2     :';
choice[3]:='Init #3     :';
choice[4]:='Answer      :';
choice[5]:='Hangup      :';
choice[6]:='Offhook     :';
choice[7]:='Onhook      :';
choice[8]:='Responses    ';
curr:=1;
setwindow(w2,4,9,76,20,3,0,8,'Modem Strings',TRUE);
        textcolor(7);
        textbackground(0);
for x2:=1 to 8 do begin
        gotoxy(2,x2+1);
        write(choice[x2]);
end;
repeat
gotoxy(16,2);
textcolor(3);
textbackground(0);
write(mln(modemr2^.init1,40));
gotoxy(16,3);
textcolor(3);
write(mln(modemr2^.init2,40));
gotoxy(16,4);
textcolor(3);
write(mln(modemr2^.init3,40));
gotoxy(16,5);
textcolor(3);
write(mln(modemr2^.answer,40));
gotoxy(16,6);
textcolor(3);
write(mln(modemr2^.hangup,40));
gotoxy(16,7);
textcolor(3);
write(mln(modemr2^.offhook,40));
gotoxy(16,8);
textcolor(3);
write(mln(modemr2^.onhook,40));
gotoxy(2,curr+1);
textcolor(15);
textbackground(1);
write(choice[curr]);
while not(keypressed) do begin timeslice; end;
c2:=readkey;
case c2 of
        #0:begin
                c2:=readkey;
                checkkey(c2);
                case c2 of
                        #68:done:=TRUE;
                        #72:begin
                                gotoxy(2,curr+1);
                                textcolor(7);
                                textbackground(0);
                                write(choice[curr]);
                                dec(curr);
                                if (curr=0) then curr:=8;
                        end;
                        #80:begin
                                gotoxy(2,curr+1);
                                textcolor(7);
                                textbackground(0);
                                write(choice[curr]);
                                inc(curr);
                                if (curr=9) then curr:=1;
                        end;
                end;
        end;
        #13:begin
                changed:=TRUE;
                case curr of
                        1:begin
                  s:=modemr2^.init1;
                  gotoxy(2,curr+1);
                  textcolor(7);
                  textbackground(0);
                  write(choice[curr]);
                  gotoxy(14,curr+1);
                  textcolor(9);
                  textbackground(0);
                  write('>');
                  gotoxy(16,curr+1);
                  infield_inp_fgrd:=15;
                  infield_inp_bkgd:=1;
                  infield_out_fgrd:=3;
                  infield_out_bkgd:=0;
                  infield_allcaps:=TRUE;
                  infield_insert:=TRUE;
                  infield_putatend:=TRUE;
                  infield_clear:=TRUE;
                  infield_maxshow:=40;
                  infield_numbers_only:=FALSE;
                  infielde(s,80);
                  infield_maxshow:=0;
                  if (s<>modemr2^.init1) then begin
                        modemr2^.init1:=s;
                        changed:=TRUE;
                  end;
                          end;
                        2:begin
                  s:=modemr2^.init2;
                  gotoxy(2,curr+1);
                  textcolor(7);
                  textbackground(0);
                  write(choice[curr]);
                  gotoxy(14,curr+1);
                  textcolor(9);
                  textbackground(0);
                  write('>');
                  gotoxy(16,curr+1);
                  infield_inp_fgrd:=15;
                  infield_inp_bkgd:=1;
                  infield_out_fgrd:=3;
                  infield_out_bkgd:=0;
                  infield_numbers_only:=FALSE;
                  infield_allcaps:=TRUE;
                  infield_insert:=TRUE;
                  infield_putatend:=TRUE;
                  infield_clear:=TRUE;
                  infield_maxshow:=40;
                  infielde(s,80);
                  infield_maxshow:=0;
                  if (s<>modemr2^.init2) then begin
                        modemr2^.init2:=s;
                        changed:=TRUE;
                  end;
                          end;
                        3:begin
                  s:=modemr2^.init3;
                  gotoxy(2,curr+1);
                  textcolor(7);
                  textbackground(0);
                  write(choice[curr]);
                  gotoxy(14,curr+1);
                  textcolor(9);
                  textbackground(0);
                  write('>');
                  gotoxy(16,curr+1);
                  infield_inp_fgrd:=15;
                  infield_inp_bkgd:=1;
                  infield_out_fgrd:=3;
                  infield_numbers_only:=FALSE;
                  infield_out_bkgd:=0;
                  infield_allcaps:=TRUE;
                  infield_insert:=TRUE;
                  infield_putatend:=TRUE;
                  infield_clear:=TRUE;
                  infield_maxshow:=40;
                  infielde(s,80);
                  infield_maxshow:=0;
                  if (s<>modemr2^.init3) then begin
                        modemr2^.init3:=s;
                        changed:=TRUE;
                  end;
                          end;
                        4:begin
                  s:=modemr2^.answer;
                  gotoxy(2,curr+1);
                  textcolor(7);
                  textbackground(0);
                  write(choice[curr]);
                  gotoxy(14,curr+1);
                  textcolor(9);
                  textbackground(0);
                  write('>');
                  gotoxy(16,curr+1);
                  infield_inp_fgrd:=15;
                  infield_inp_bkgd:=1;
                  infield_out_fgrd:=3;
                  infield_out_bkgd:=0;
                  infield_allcaps:=TRUE;
                  infield_numbers_only:=FALSE;
                  infield_insert:=TRUE;
                  infield_putatend:=TRUE;
                  infield_clear:=TRUE;
                  infield_maxshow:=40;
                  infielde(s,80);
                  infield_maxshow:=0;
                  if (s<>modemr2^.answer) then begin
                        modemr2^.answer:=s;
                        changed:=TRUE;
                  end;
                          end;
                        5:begin
                  s:=modemr2^.hangup;
                  gotoxy(2,curr+1);
                  textcolor(7);
                  textbackground(0);
                  write(choice[curr]);
                  gotoxy(14,curr+1);
                  textcolor(9);
                  textbackground(0);
                  write('>');
                  gotoxy(16,curr+1);
                  infield_inp_fgrd:=15;
                  infield_inp_bkgd:=1;
                  infield_out_fgrd:=3;
                  infield_out_bkgd:=0;
                  infield_numbers_only:=FALSE;
                  infield_allcaps:=TRUE;
                  infield_insert:=TRUE;
                  infield_putatend:=TRUE;
                  infield_clear:=TRUE;
                  infielde(s,40);
                  if (s<>modemr2^.hangup) then begin
                        modemr2^.hangup:=s;
                        changed:=TRUE;
                  end;
                          end;
                        6:begin
                  s:=modemr2^.offhook;
                  gotoxy(2,curr+1);
                  textcolor(7);
                  textbackground(0);
                  write(choice[curr]);
                  gotoxy(14,curr+1);
                  textcolor(9);
                  textbackground(0);
                  write('>');
                  gotoxy(16,curr+1);
                  infield_inp_fgrd:=15;
                  infield_numbers_only:=FALSE;
                  infield_inp_bkgd:=1;
                  infield_out_fgrd:=3;
                  infield_out_bkgd:=0;
                  infield_allcaps:=TRUE;
                  infield_insert:=TRUE;
                  infield_putatend:=TRUE;
                  infield_clear:=TRUE;
                  infielde(s,40);
                  if (s<>modemr2^.offhook) then begin
                        modemr2^.offhook:=s;
                        changed:=TRUE;
                  end;
                          end;
                        7:begin
                  s:=modemr2^.onhook;
                  gotoxy(2,curr+1);
                  textcolor(7);
                  textbackground(0);
                  write(choice[curr]);
                  gotoxy(14,curr+1);
                  textcolor(9);
                  textbackground(0);
                  write('>');
                  gotoxy(16,curr+1);
                  infield_inp_fgrd:=15;
                  infield_inp_bkgd:=1;
                  infield_out_fgrd:=3;
                  infield_out_bkgd:=0;
                  infield_numbers_only:=FALSE;
                  infield_allcaps:=TRUE;
                  infield_insert:=TRUE;
                  infield_putatend:=TRUE;
                  infield_clear:=TRUE;
                  infielde(s,40);
                  if (s<>modemr2^.onhook) then begin
                        modemr2^.onhook:=s;
                        changed:=TRUE;
                  end;
                          end;
                        8:begin
                        setwindow4(w2,4,9,76,20,8,0,8,'Modem Strings','',TRUE);
                        getrespmain;
                        setwindow5(w2,4,9,76,20,3,0,8,'Modem Strings','',TRUE);
                        window(5,10,75,19);                              
                          end;
                end;
        end;
        #27:done2:=TRUE;
end;
until (done2);
removewindow(w2);
end;

function showcomtype(b:byte):string;
var s3:string;
begin
s3:='None';
case b of
        0:s3:='Local    ';
        1:s3:='Fossil   ';
        2:s3:='Digiboard';
        3:s3:='Interrupt';
end;
showcomtype:=s3;
end;


begin
  changed:=FALSE;
  autosave:=FALSE;
  done:=FALSE;
  new(modemr2);
  setwindow(w,27,11,53,13,3,0,8,'',TRUE);
  gotoxy(2,1);
  textcolor(7);
  textbackground(0);
  write('Enter Node Number: ');
  gotoxy(21,1);
  s:=cstr(1);
  infield_inp_fgrd:=15;
  infield_inp_bkgd:=1;
  infield_out_fgrd:=3;
  infield_out_bkgd:=0;
  infield_allcaps:=false;
  infield_numbers_only:=TRUE;
  infield_escape_blank:=TRUE;
  infield_insert:=FALSE;
  infield_putatend:=TRUE;
  infield_clear:=TRUE;
  infielde(s,4);
  infield_insert:=TRUE;
  infield_putatend:=FALSE;
  infield_clear:=FALSE;
  infield_escape_blank:=FALSE;
  thisnode:=value(s);
  removewindow(w);
  if (s='') then exit;
  assign(modemrf,adrv(systat.gfilepath)+'NODE'+cstrn(thisnode)+'.DAT');
  if not(exist(adrv(systat.gfilepath)+'NODE'+cstrn(thisnode)+'.DAT')) then begin
        if pynqbox('Create NODE'+cstrn(thisnode)+'.DAT now? ') then begin
                rewrite(modemrf);
                fillchar(modemr2^,sizeof(modemr2^),#0);
                with modemr2^ do begin
                        comport:=1;
                        waitbaud:=2400;
                        lockport:=FALSE;
                        ctype:=3;
                        minimumbaud:=2400;
                        closedsystem:=FALSE;
                for x:=1 to 7 do lowtime[x]:=0;
                for x:=1 to 7 do hitime[x]:=0;
                for x:=1 to 7 do dllowtime[x]:=0;
                for x:=1 to 7 do dlhitime[x]:=0;
                for x:=1 to 7 do lockbegintime[x]:=0;
                for x:=1 to 7 do lockendtime[x]:=0;
                for x:=1 to 7 do lockbegin_dltime[x]:=0;
                for x:=1 to 7 do lockend_dltime[x]:=0;
                        swapprotocol:=4;
                        swaparchiver:=4;
                        swapdoor:=4;
                        swapeditor:=4;
                        swapchat:=4;
                        swaplocalshell:=4;
                        swapfrontend:=4;
                        usefrontend:=FALSE;
                        frontendpath:='';
                        init1:='~ATZ|';
                        init2:='';
                        init3:='';
                        answer:='~ATA|';
                        hangup:='~~+++~~ATH|';
                        offhook:='ATH1|';
                        onhook:='ATH0|';
                        rspok:='OK';
                        rsperror:='ERROR';
                        rspcarrier:='CARRIER';
                        rspring:='RING';

                        with responses[1] do begin
                                response:='CONNECT';
                                outelevel:=101;
                                action:=1;
                                baud:=300;
                        end;
                        with responses[2] do begin
                                response:='CONNECT 1200';
                                outelevel:=101;
                                action:=1;
                                baud:=1200;
                        end;
                        with responses[3] do begin
                                response:='CONNECT 1275';
                                outelevel:=101;
                                action:=1;
                                baud:=1275;
                        end;
                        with responses[4] do begin
                                response:='CONNECT 2400';
                                outelevel:=101;
                                action:=1;
                                baud:=2400;
                        end;
                        with responses[5] do begin
                                response:='CONNECT 4800';
                                outelevel:=101;
                                action:=1;
                                baud:=4800;
                        end;
                        with responses[6] do begin
                                response:='CONNECT 7200';
                                outelevel:=101;
                                action:=1;
                                baud:=7200;
                        end;
                        with responses[7] do begin
                                response:='CONNECT 9600';
                                outelevel:=101;
                                action:=1;
                                baud:=9600;
                        end;
                        with responses[8] do begin
                                response:='CONNECT 12000';
                                outelevel:=101;
                                action:=1;
                                baud:=12000;
                        end;
                        with responses[9] do begin
                                response:='CONNECT 14400';
                                outelevel:=101;
                                action:=1;
                                baud:=14400;
                        end;
                        with responses[10] do begin
                                response:='CONNECT 16800';
                                outelevel:=101;
                                action:=1;
                                baud:=16800;
                        end;
                        with responses[11] do begin
                                response:='CONNECT 19200';
                                outelevel:=101;
                                action:=1;
                                baud:=19200;
                        end;
                        with responses[12] do begin
                                response:='CONNECT 21600';
                                outelevel:=101;
                                action:=1;
                                baud:=21600;
                        end;
                        with responses[13] do begin
                                response:='CONNECT 24000';
                                outelevel:=101;
                                action:=1;
                                baud:=24000;
                        end;
                        with responses[14] do begin
                                response:='CONNECT 26400';
                                outelevel:=101;
                                action:=1;
                                baud:=26400;
                        end;
                        with responses[15] do begin
                                response:='CONNECT 28800';
                                outelevel:=101;
                                action:=1;
                                baud:=28800;
                        end;
                        with responses[16] do begin
                                response:='CONNECT 31200';
                                outelevel:=101;
                                action:=1;
                                baud:=31200;
                        end;
                        with responses[17] do begin
                                response:='CONNECT 33600';
                                outelevel:=101;
                                action:=1;
                                baud:=33600;
                        end;
                        with responses[18] do begin
                                response:='CONNECT 38400';
                                outelevel:=101;
                                action:=1;
                                baud:=38400;
                        end;
                        with responses[19] do begin
                                response:='CONNECT 57600';
                                outelevel:=101;
                                action:=1;
                                baud:=57600;
                        end;
                        with responses[20] do begin
                                response:='CONNECT 64000';
                                outelevel:=101;
                                action:=1;
                                baud:=64000;
                        end;
                        with responses[21] do begin
                                response:='CONNECT 31200';
                                outelevel:=101;
                                action:=1;
                                baud:=31200;
                        end;
                end;
                write(modemrf,modemr2^);
                close(modemrf);
        end else exit;
  end else begin
        {$I-} reset(modemrf); {$I+}
        if (ioresult<>0) then begin
            close(modemrf);
            {$I-} erase(modemrf); {$I+}
            if (ioresult<>0) then begin end;
            if pynqbox('Create NODE'+cstrn(thisnode)+'.DAT now? ') then begin
                fillchar(modemr2^,sizeof(modemr2^),#0);
                with modemr2^ do begin
                        comport:=1;
                        waitbaud:=2400;
                        lockport:=FALSE;
                        ctype:=3;
                        minimumbaud:=2400;
                        closedsystem:=FALSE;
                for x:=1 to 7 do lowtime[x]:=0;
                for x:=1 to 7 do hitime[x]:=0;
                for x:=1 to 7 do dllowtime[x]:=0;
                for x:=1 to 7 do dlhitime[x]:=0;
                for x:=1 to 7 do lockbegintime[x]:=0;
                for x:=1 to 7 do lockendtime[x]:=0;
                for x:=1 to 7 do lockbegin_dltime[x]:=0;
                for x:=1 to 7 do lockend_dltime[x]:=0;
                        swapprotocol:=4;
                        swaparchiver:=4;
                        swapdoor:=4;
                        swapeditor:=4;
                        swapchat:=4;
                        swaplocalshell:=4;
                        swapfrontend:=4;
                        usefrontend:=FALSE;
                        frontendpath:='';
                        init1:='~ATZ|';
                        init2:='';
                        init3:='';
                        answer:='~ATA|';
                        hangup:='~~+++~~ATH|';
                        offhook:='ATH1|';
                        onhook:='ATH0|';
                        rspok:='OK';
                        rsperror:='ERROR';
                        rspcarrier:='CARRIER';
                        rspring:='RING';

                        with responses[1] do begin
                                response:='CONNECT';
                                outelevel:=101;
                                action:=1;
                                baud:=300;
                        end;
                        with responses[2] do begin
                                response:='CONNECT 1200';
                                outelevel:=101;
                                action:=1;
                                baud:=1200;
                        end;
                        with responses[3] do begin
                                response:='CONNECT 1275';
                                outelevel:=101;
                                action:=1;
                                baud:=1275;
                        end;
                        with responses[4] do begin
                                response:='CONNECT 2400';
                                outelevel:=101;
                                action:=1;
                                baud:=2400;
                        end;
                        with responses[5] do begin
                                response:='CONNECT 4800';
                                outelevel:=101;
                                action:=1;
                                baud:=4800;
                        end;
                        with responses[6] do begin
                                response:='CONNECT 7200';
                                outelevel:=101;
                                action:=1;
                                baud:=7200;
                        end;
                        with responses[7] do begin
                                response:='CONNECT 9600';
                                outelevel:=101;
                                action:=1;
                                baud:=9600;
                        end;
                        with responses[8] do begin
                                response:='CONNECT 12000';
                                outelevel:=101;
                                action:=1;
                                baud:=12000;
                        end;
                        with responses[9] do begin
                                response:='CONNECT 14400';
                                outelevel:=101;
                                action:=1;
                                baud:=14400;
                        end;
                        with responses[10] do begin
                                response:='CONNECT 16800';
                                outelevel:=101;
                                action:=1;
                                baud:=16800;
                        end;
                        with responses[11] do begin
                                response:='CONNECT 19200';
                                outelevel:=101;
                                action:=1;
                                baud:=19200;
                        end;
                        with responses[12] do begin
                                response:='CONNECT 21600';
                                outelevel:=101;
                                action:=1;
                                baud:=21600;
                        end;
                        with responses[13] do begin
                                response:='CONNECT 24000';
                                outelevel:=101;
                                action:=1;
                                baud:=24000;
                        end;
                        with responses[14] do begin
                                response:='CONNECT 26400';
                                outelevel:=101;
                                action:=1;
                                baud:=26400;
                        end;
                        with responses[15] do begin
                                response:='CONNECT 28800';
                                outelevel:=101;
                                action:=1;
                                baud:=28800;
                        end;
                        with responses[16] do begin
                                response:='CONNECT 31200';
                                outelevel:=101;
                                action:=1;
                                baud:=31200;
                        end;
                        with responses[17] do begin
                                response:='CONNECT 33600';
                                outelevel:=101;
                                action:=1;
                                baud:=33600;
                        end;
                        with responses[18] do begin
                                response:='CONNECT 38400';
                                outelevel:=101;
                                action:=1;
                                baud:=38400;
                        end;
                        with responses[19] do begin
                                response:='CONNECT 57600';
                                outelevel:=101;
                                action:=1;
                                baud:=57600;
                        end;
                        with responses[20] do begin
                                response:='CONNECT 64000';
                                outelevel:=101;
                                action:=1;
                                baud:=64000;
                        end;
                        with responses[21] do begin
                                response:='CONNECT 31200';
                                outelevel:=101;
                                action:=1;
                                baud:=31200;
                        end;
                end;
                write(modemrf,modemr2^);
                close(modemrf);
                {$I-} reset(modemrf); {$I+}
                if (ioresult<>0) then begin
                        displaybox('Error Opening COM'+cstrn(thisnode)+'.DAT',4000);
                        exit;
                end;
        end else exit;
        end;
        read(modemrf,modemr2^);
        close(modemrf);
  end;
  setwindow2(w,1,7,78,22,3,0,8,'Node Configuration','Node '+cstr(thisnode),TRUE);
  current:=1;
  update:=TRUE;
  redraw:=FALSE;
  repeat
  if (redraw) then begin
        window(2,8,77,21);
        clrscr;
        redraw:=FALSE;
  end;
  if (update) then begin
  case modemr2^.ctype of
        0:begin
                choices[1]:='Communications Type   :';
                choices[2]:='New Users             :';
                choices[3]:='Swap Settings          ';
                desc[1]:='What type of communications: Local/Fossil/Digiboard/Interrupt  ';
                desc[2]:='Whether New Users are Accepted or Rejected by the system       ';
                desc[3]:='Swapping settings for this Node                                ';
                maxshown:=3;
          end;
        1,3:begin
                choices[1]:='Communications Type   :';
                choices[2]:='Com Port              :';
                if modemr2^.lockport then
                  choices[3]:='Locked Baud Rate      :'
                else
                  choices[3]:='Maximum Baud Rate     :';
                choices[4]:='Com Port Locked       :';
                choices[5]:='SysOp Page Hours       ';
                choices[6]:='Minimum Baud          :';
                choices[7]:='Below Min Baud Hrs     ';
                choices[8]:='Below Min Baud DL Hrs  ';
                choices[9]:='Regular Download Hrs   ';
                choices[10]:='New Users             :';
                choices[11]:='Swap Settings          ';
                choices[12]:='Modem Strings          ';
                desc[1]:='What type of communications: Local/Fossil/Digiboard/Interrupt  ';
                desc[2]:='Com Port that this Node should use                             ';
                if (modemr2^.lockport) then
                  desc[3]:='Locked Baud Rate that this node should use                     '
                else
                  desc[3]:='Maximum Baud Rate that this node can use                       ';
                desc[4]:='Should Nexus lock the com port for this Node?                  ';
                desc[5]:='Defined Hours that users are able to Page SysOp                ';
                desc[6]:='Minimum Baud Rate a caller must have to log on to this system  ';
                desc[7]:='Defined Hours that callers with lower than minimum may log on  ';
                desc[8]:='Defined Hours that callers with lower than minimum may download';
                desc[9]:='Defined Hours that users are able to Download                  ';
                desc[10]:='Whether New Users are Accepted or Rejected by the system       ';
                desc[11]:='Swapping settings for this node                                ';
                desc[12]:='Modem Strings for this node                                    ';
                maxshown:=12;
          end;
        2:begin
                choices[1]:='Communications Type   :';
                choices[2]:='Digiboard Port        :';
                if modemr2^.lockport then
                  choices[3]:='Locked Baud Rate      :'
                else
                  choices[3]:='Maximum Baud Rate     :';
                choices[4]:='Digiboard Port Locked :';
                choices[5]:='SysOp Page Hours       ';
                choices[6]:='Minimum Baud          :';
                choices[7]:='Below Min Baud Hrs     ';
                choices[8]:='Below Min Baud DL Hrs  ';
                choices[9]:='Regular Download Hrs   ';
                choices[10]:='New Users             :';
                choices[11]:='Swap Settings          ';
                choices[12]:='Modem Strings          ';
                desc[1]:='What type of communications: Local/Fossil/Digiboard/Interrupt  ';
                desc[2]:='Digiboard Port that this node should use                       ';
                if (modemr2^.lockport) then
                  desc[3]:='Locked Baud Rate that this node should use                     '
                else
                  desc[3]:='Maximum Baud Rate that this node can use                       ';
                desc[4]:='Should Nexus lock the digiboard port for this node?            ';
                desc[5]:='Defined Hours that users are able to Page SysOp                ';
                desc[6]:='Minimum Baud Rate a caller must have to log on to this system  ';
                desc[7]:='Defined Hours that callers with lower than minimum may log on  ';
                desc[8]:='Defined Hours that callers with lower than minimum may download';
                desc[9]:='Defined Hours that users are able to Download                  ';
                desc[10]:='Whether New Users are Accepted or Rejected by the system       ';
                desc[11]:='Swapping settings for this node                                ';
                desc[12]:='Modem strings for this node                                    ';
                maxshown:=12;
          end;
  end;
  done:=FALSE;
  for x:=1 to maxshown do begin
        gotoxy(2,x+1);
        textcolor(7);
        textbackground(0);
        write(choices[x]);
  end;
  gotoxy(26,2);
  textcolor(3);
  textbackground(0);
  if (modemr2^.ctype=0) then begin
  with modemr2^ do begin
  write(showcomtype(modemr2^.ctype));
  gotoxy(26,3);
  write(aonoff(closedsystem,'Rejected','Accepted'));
  end;
  end else begin
  with modemr2^ do begin
  write(showcomtype(modemr2^.ctype));
  gotoxy(26,3);
  write(mln(cstr(modemr2^.comport),3));
  gotoxy(26,4);
  write(mln(cstr(modemr2^.waitbaud),6));
  gotoxy(26,5);
  write(syn(modemr2^.lockport));
  gotoxy(26,7);
  write(cstr(minimumbaud));
  gotoxy(26,11);
  write(aonoff(closedsystem,'Rejected','Accepted'));
  update:=FALSE;
  end;
  end;
  end;
    with modemr2^ do begin

    window(1,1,80,25);
    gotoxy(1,25);
    textcolor(14);
    textbackground(0);
    cwrite('%140%Esc%070%=Exit %140%'+desc[current]);
    window(2,8,77,21);
    gotoxy(2,current+1);
    textcolor(15);
    textbackground(1);
    write(choices[current]);
    while not(keypressed) do begin timeslice; end;
    c:=readkey;
    case c of
         #0:begin
            c:=readkey;
            checkkey(c);
            case c of
                #68:begin
                        done:=TRUE;
                        autosave:=TRUE;
                    end;
                #72:begin
                        gotoxy(2,current+1);
                        textcolor(7);
                        textbackground(0);
                        write(choices[current]);
                        dec(current);
                        if (current=0) then current:=maxshown;
                    end;
                #80:begin
                        gotoxy(2,current+1);
                        textcolor(7);
                        textbackground(0);
                        write(choices[current]);
                        inc(current);
                        if (current>maxshown) then current:=1;
                    end;
            end;
            end;
        #13:begin
            gotoxy(2,current+1);
            textcolor(7);
            textbackground(0);
            write(choices[current]);
            case modemr2^.ctype of
                0:begin
                        case current of
                        1:current2:=current;
                        2:current2:=10;
                        3:current2:=11;
                        end;
                  end;
                else begin
                  current2:=current;
                  end;
            end;
            case current2 of
                1:begin
                  changed:=TRUE;
                  inc(ctype);
                  if (ctype>3) then ctype:=0;
                  gotoxy(26,2);
                  textcolor(3);
                  textbackground(0);
                  write(showcomtype(ctype));
                  textcolor(7);
                  textbackground(0);
                  case ctype of
                        0:begin
                                gotoxy(2,3);
                                write('                           ');
                          end;
                        1:begin
                        gotoxy(2,3);
                        write('Com Port              :');
                        if (modemr2^.comport>99) then begin
                                modemr2^.comport:=1;
                                textcolor(3);
                                textbackground(0);
                                gotoxy(26,3);
                                write(mln(cstr(modemr2^.comport),3));
                        end;
                          end;
                        2:begin
                        gotoxy(2,3);
                        write('Digiboard Port        :');
                          end;
                        3:begin
                        gotoxy(2,3);
                        write('Com Port              :');
                        if (modemr2^.comport>8) then begin
                                modemr2^.comport:=1;
                                textcolor(3);
                                textbackground(0);
                                gotoxy(26,3);
                                write(mln(cstr(modemr2^.comport),3));
                        end;
                          end;
                    end;
                  if (modemr2^.ctype=2) then
                          choices[2]:='Digiboard Port        :'
                  else
                        if (modemr2^.ctype=0) then
                          choices[2]:='                       '
                          else
                          choices[2]:='Com Port              :';
                  if (modemr2^.ctype=2) then
                  desc[2]:='Digiboard Port that this Node should use for communications    '
                  else
                  desc[2]:='Com Port that this Node should use for communications          ';
                  if (modemr2^.ctype<>0) then begin
                  gotoxy(26,3);
                  textcolor(3);
                  textbackground(0);
                  write(mln(cstr(modemr2^.comport),3));
                  end;
                  update:=TRUE;
                  redraw:=TRUE;
                  end;
                2:begin
                  s:=cstr(modemr2^.comport);
                  gotoxy(2,current+1);
                  textcolor(7);
                  textbackground(0);
                  write(choices[current]);
                  gotoxy(24,current+1);
                  textcolor(9);
                  textbackground(0);
                  write('>');
                  gotoxy(26,current+1);
                  infield_inp_fgrd:=15;
                  infield_inp_bkgd:=1;
                  infield_out_fgrd:=3;
                  infield_out_bkgd:=0;
                  infield_min_value:=0;
                  case modemr2^.ctype of
                        1:infield_max_value:=99;
                        2:infield_max_value:=30;
                        3:infield_max_value:=8;
                  end;
                  infield_allcaps:=FALSE;
                  infield_numbers_only:=TRUE;
                  infield_insert:=TRUE;
                  infield_putatend:=TRUE;
                  infield_clear:=TRUE;
                  case modemr2^.ctype of
                        1,2:infielde(s,2);
                        0,3:infielde(s,1);
                  end;
                  if (value(s)<>modemr2^.comport) then begin
                        modemr2^.comport:=value(s);
                        changed:=TRUE;
                  end;
                  end;
                3:begin
                  with modemr2^ do
                  case (waitbaud div 10) of
                        30:waitbaud:=600;
                        60:waitbaud:=1200;
                        120:waitbaud:=2400;
                        240:waitbaud:=4800;
                        480:waitbaud:=9600;
                        960:waitbaud:=19200;
                        1920:waitbaud:=38400;
                        3840:waitbaud:=57600;
                        5760:waitbaud:=76800;
                        7680:waitbaud:=115200;
                        11520:waitbaud:=300;
                  end;
                  textcolor(3);
                  textbackground(0);
                  gotoxy(26,4);
                  write(mln(cstr(modemr2^.waitbaud),6));
                  changed:=TRUE;
                  end;
                4:begin
                  lockport:=not(lockport);
                  gotoxy(26,5);
                  textcolor(3);
                  textbackground(0);
                  write(syn(modemr2^.lockport));
                  if modemr2^.lockport then
                  choices[3]:='Locked Baud Rate      :'
                  else
                  choices[3]:='Maximum Baud Rate     :';
                  gotoxy(2,4);
                  textcolor(7);
                  textbackground(0);
                  write(choices[3]);
  if (modemr2^.lockport) then
  desc[3]:='Locked Baud Rate that this node should use                     '
  else
  desc[3]:='Maximum Baud Rate that this node can use                       ';
                  changed:=TRUE;
                  end;
                5:begin
  setwindow4(w,1,7,78,22,8,0,8,'Node Configuration','Node '+cstr(thisnode),TRUE);
                                getpagehours('SysOp Page Availability Hours',1);
  setwindow5(w,1,7,78,22,3,0,8,'Node Configuration','Node '+cstr(thisnode),TRUE);
                end;
                6:begin
                  case (minimumbaud div 10) of
                        30:minimumbaud:=600;
                        60:minimumbaud:=1200;
                        120:minimumbaud:=2400;
                        240:minimumbaud:=4800;
                        480:minimumbaud:=9600;
                        960:minimumbaud:=19200;
                        1920:minimumbaud:=38400;
                        3840:minimumbaud:=57600;
                        5760:minimumbaud:=76800;
                        7680:minimumbaud:=115200;
                        11520:minimumbaud:=300;
                  end;
                  textcolor(3);
                  textbackground(0);
                  gotoxy(26,current+1);
                  write(mln(cstr(modemr2^.minimumbaud),6));
                  changed:=TRUE;
                end;
                7:begin
  setwindow4(w,1,7,78,22,8,0,8,'Node Configuration','Node '+cstr(thisnode),TRUE);
                                getpagehours('Below Minimum Baud Hours',2);
  setwindow5(w,1,7,78,22,3,0,8,'Node Configuration','Node '+cstr(thisnode),TRUE);
                end;
                8:begin
  setwindow4(w,1,7,78,22,8,0,8,'Node Configuration','Node '+cstr(thisnode),TRUE);
                                getpagehours('Below Min Baud DL Hours',3);
  setwindow5(w,1,7,78,22,3,0,8,'Node Configuration','Node '+cstr(thisnode),TRUE);
                end;
                9:begin
  setwindow4(w,1,7,78,22,8,0,8,'Node Configuration','Node '+cstr(thisnode),TRUE);
                                getpagehours('Download Hours',4);
  setwindow5(w,1,7,78,22,3,0,8,'Node Configuration','Node '+cstr(thisnode),TRUE);
                end;
                10:begin
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choices[current]);
                                gotoxy(24,current+1);
                                textcolor(9);
                                textbackground(0);
                                write('>');
                                gotoxy(26,current+1);
                                closedsystem:=not(closedsystem);
                                changed:=TRUE;
                                textcolor(3);
                                textbackground(0);
                                write(aonoff(closedsystem,'Rejected','Accepted'));
                                gotoxy(24,current+1);
                                textcolor(9);
                                textbackground(0);
                                write(' ');
                end;
                11:begin
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choices[current]);
  setwindow4(w,1,7,78,22,8,0,8,'Node Configuration','Node '+cstr(thisnode),TRUE);
                                getswap;
  setwindow5(w,1,7,78,22,3,0,8,'Node Configuration','Node '+cstr(thisnode),TRUE);
                                window(2,8,77,21);
                end;
                12:begin
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choices[current]);
  setwindow4(w,1,7,78,22,8,0,8,'Node Configuration','Node '+cstr(thisnode),TRUE);
                                getmodemstrings;
  setwindow5(w,1,7,78,22,3,0,8,'Node Configuration','Node '+cstr(thisnode),TRUE);
                end;
            end;
            end;
        #27:done:=TRUE;
      end;
    end;
  until (done);
  if (changed) then begin
  if not(autosave) then autosave:=pynqbox('Save changes? ');
  if (autosave) then begin
  assign(modemrf,adrv(systat.gfilepath)+'NODE'+cstrn(thisnode)+'.DAT');
  filemode:=66;
  {$I-} reset(modemrf); {$I+}
  if (ioresult<>0) then begin
        writeln('Error Opening NODE'+cstrn(thisnode)+'.DAT');
        halt(0);
  end;
  write(modemrf,modemr2^); 
  close(modemrf);
  end;
  end;
  removewindow(w);
  dispose(modemr2);
end;

end.
