(*****************************************************************************)
(*>                                                                         <*)
(*>  SYSOP2G .PAS -  Written by Eric Oman                                   <*)
(*>                                                                         <*)
(*>  SysOp functions: System Configuration Editor -- "G" command.           <*)
(*>                                                                         <*)
(*>                                                                         <*)
(*****************************************************************************)
{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R-,S+,V-}
unit sysop2g;

interface

uses
  crt, dos, myio, misc,procspec;

procedure seclevelconfig;
procedure subscriptconfig;
procedure confeditor(tp1:byte);

implementation

function editsecurity(var sec:securityrec; seclevel:integer):boolean;
var c:char;
    choice:array[1..10] of string[30];
    desc:array[1..10] of string;
    x,current:integer;
    done,changed,autosave:boolean;
    s:string;

    procedure gettb;
    var ch:array[1..5] of string[30];
        cur:integer;
        w2:windowrec;
        x2:integer;
        d2:boolean;
        c2:char;
    begin
        d2:=FALSE;
        ch[1]:='Maximum in Time Bank (min)   :';
        ch[2]:='Max Add Per Day (min)        :';
        ch[3]:='Max Add Per Call (min)       :';
        ch[4]:='Max Withdraw Per Day (min)   :';
        ch[5]:='Max Withdraw Per Call (min)  :';
        setwindow(w2,20,10,60,18,3,0,8,'Time Bank Options',TRUE);
        textcolor(7);
        textbackground(0);
        for x2:=1 to 5 do begin
                gotoxy(2,x2+1);
                write(ch[x2]);
        end;
        cur:=1;
        gotoxy(33,2);
        textcolor(3);
        textbackground(0);
        write(mln(cstr(sec.maxintb),5));
        gotoxy(33,3);
        write(mln(cstr(sec.addtbday),4));
        gotoxy(33,4);
        write(mln(cstr(sec.addtbcall),4));
        gotoxy(33,5);
        write(mln(cstr(sec.withtbday),4));
        gotoxy(33,6);
        write(mln(cstr(sec.withtbcall),4));
        repeat
        gotoxy(2,cur+1);
        textcolor(15);
        textbackground(1);
        write(ch[cur]);
        while not(keypressed) do begin timeslice; end;
        c2:=readkey;
        case c2 of
                #0:begin
                        c2:=readkey;
                        checkkey(c2);
                        case c2 of
                        #68:d2:=TRUE;
                        #72:begin
                                gotoxy(2,cur+1);
                                textcolor(7);
                                textbackground(0);
                                write(ch[cur]);
                                dec(cur);
                                if (cur=0) then cur:=5;
                            end;
                        #80:begin
                                gotoxy(2,cur+1);
                                textcolor(7);
                                textbackground(0);
                                write(ch[cur]);
                                inc(cur);
                                if (cur=6) then cur:=1;
                            end;
                          end;
                   end;
               #13:begin
                        gotoxy(2,cur+1);
                        textcolor(7);
                        textbackground(0);
                        write(ch[cur]);
                        gotoxy(31,cur+1);
                        textcolor(9);
                        write('>');
                        gotoxy(33,cur+1);
                        case cur of
                                1:begin
                                infield_inp_fgrd:=15;
                                infield_inp_bkgd:=1;
                                infield_out_fgrd:=3;
                                infield_out_bkgd:=0;
                                infield_allcaps:=false;
                                infield_numbers_only:=TRUE;
                                infield_putatend:=TRUE;
                                infield_insert:=FALSE;
                                infield_clear:=TRUE;
                                infield_min_value:=0;
                                infield_max_value:=32767;
                                s:=cstr(sec.maxintb);
                                infielde(s,5);
                                infield_min_value:=-1;
                                infield_max_value:=-1;
                                if (value(s)<>sec.maxintb) then begin
                                        changed:=TRUE;
                                        sec.maxintb:=value(s);
                                end;
                                infield_putatend:=FALSE;
                                infield_clear:=FALSE;
                                  end;
                                2:begin
                                infield_inp_fgrd:=15;
                                infield_inp_bkgd:=1;
                                infield_out_fgrd:=3;
                                infield_out_bkgd:=0;
                                infield_allcaps:=false;
                                infield_numbers_only:=TRUE;
                                infield_putatend:=TRUE;
                                infield_insert:=FALSE;
                                infield_clear:=TRUE;
                                infield_min_value:=0;
                                infield_max_value:=1440;
                                s:=cstr(sec.addtbday);
                                infielde(s,4);
                                infield_min_value:=-1;
                                infield_max_value:=-1;
                                if (value(s)<>sec.addtbday) then begin
                                        changed:=TRUE;
                                        sec.addtbday:=value(s);
                                end;
                                infield_putatend:=FALSE;
                                infield_clear:=FALSE;
                                  end;
                                3:begin
                                infield_inp_fgrd:=15;
                                infield_inp_bkgd:=1;
                                infield_out_fgrd:=3;
                                infield_out_bkgd:=0;
                                infield_allcaps:=false;
                                infield_numbers_only:=TRUE;
                                infield_putatend:=TRUE;
                                infield_insert:=FALSE;
                                infield_clear:=TRUE;
                                infield_min_value:=0;
                                infield_max_value:=1440;
                                s:=cstr(sec.addtbcall);
                                infielde(s,4);
                                infield_min_value:=-1;
                                infield_max_value:=-1;
                                if (value(s)<>sec.addtbcall) then begin
                                        changed:=TRUE;
                                        sec.addtbcall:=value(s);
                                end;
                                infield_putatend:=FALSE;
                                infield_clear:=FALSE;
                                  end;
                                4:begin
                                infield_inp_fgrd:=15;
                                infield_inp_bkgd:=1;
                                infield_out_fgrd:=3;
                                infield_out_bkgd:=0;
                                infield_allcaps:=false;
                                infield_numbers_only:=TRUE;
                                infield_putatend:=TRUE;
                                infield_insert:=FALSE;
                                infield_clear:=TRUE;
                                infield_min_value:=0;
                                infield_max_value:=1440;
                                s:=cstr(sec.withtbday);
                                infielde(s,4);
                                infield_min_value:=-1;
                                infield_max_value:=-1;
                                if (value(s)<>sec.withtbday) then begin
                                        changed:=TRUE;
                                        sec.withtbday:=value(s);
                                end;
                                infield_putatend:=FALSE;
                                infield_clear:=FALSE;
                                  end;
                                5:begin
                                infield_inp_fgrd:=15;
                                infield_inp_bkgd:=1;
                                infield_out_fgrd:=3;
                                infield_out_bkgd:=0;
                                infield_allcaps:=false;
                                infield_numbers_only:=TRUE;
                                infield_putatend:=TRUE;
                                infield_insert:=FALSE;
                                infield_clear:=TRUE;
                                infield_min_value:=0;
                                infield_max_value:=1440;
                                s:=cstr(sec.withtbcall);
                                infielde(s,4);
                                infield_min_value:=-1;
                                infield_max_value:=-1;
                                if (value(s)<>sec.withtbcall) then begin
                                        changed:=TRUE;
                                        sec.withtbcall:=value(s);
                                end;
                                infield_putatend:=FALSE;
                                infield_clear:=FALSE;
                                  end;
                        end;
                   end;
               #27:d2:=TRUE;
        end;
        until (d2);
        removewindow(w2);
    end;

begin
done:=false;
changed:=false;
autosave:=FALSE;
choice[1]:='Description       :';
choice[2]:='Calls Per Day     :';
choice[3]:='Time Per Call     :';
choice[4]:='Time Per Day      :';
choice[5]:='Posts Per Call    :';
choice[6]:='DL Ratio Files    :';
choice[7]:='DL Ratio KB       :';
choice[8]:='Files DL Per Call  ';
choice[9]:='KB DL Per Call     ';
choice[10]:='Time Bank Options  ';
desc[1]:='Description of Security Level for Reference Purposes          ';
desc[2]:='Number of Calls per Day Allowed Users with this Security Level';
desc[3]:='Minutes Per Call allowed Users with this Security Level       ';
desc[4]:='Minutes Per Day allowed Users with this Security Level        ';
desc[5]:='Posts required per call for users with this Security Level    ';
desc[6]:='Number of Files Downloaded before an UL is required           ';
desc[7]:='Number of Kb Downloaded before UL of 1Kb is required          ';
desc[8]:='Max Files Downloadable per call based on on baud rate         ';
desc[9]:='Max Kb Downloadable per call based on baud rate               ';
desc[10]:='Time Bank minimums and maximums by Security Level            ';
cursoron(FALSE);
setwindow2(w,3,9,49,22,3,0,8,'Edit SL '+cstr(seclevel),'',TRUE);
for x:=1 to 10 do begin
        gotoxy(2,x+1);
        textcolor(7);
        textbackground(0);
        write(choice[x]);
end;
with sec do begin
textcolor(3);
textbackground(0);
gotoxy(22,2);
write(mln(description,20));
gotoxy(22,3);
write(mln(cstr(callsperday),3));
gotoxy(22,4);
write(mln(cstr(timepercall),5));
gotoxy(22,5);
write(mln(cstr(timeperday),5));
gotoxy(22,6);
write(mln(cstr(postpercall),5));
gotoxy(22,7);
write(mln(cstr(DLRatioFiles),5));
gotoxy(22,8);
write(mln(cstr(DlRatioKb),5));
end;
current:=1;
repeat
gotoxy(2,current+1);
textcolor(15);
textbackground(1);
write(choice[current]);
window(1,1,80,25);
gotoxy(1,25);
textcolor(14);
textbackground(0);
write('Esc');
textcolor(7);
write('=Exit ');
textcolor(14);
write(desc[current]);
window(4,10,48,21);
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
                                write(choice[current]);
                                dec(current);
                                if (current<1) then current:=10;
                            end;
                        #80:begin
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choice[current]);
                                inc(current);
                                if (current>10) then current:=1;
                            end;
                end;
           end;
        #13:begin
                case current of
                        1:begin
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choice[current]);
                                gotoxy(20,current+1);
                                textcolor(9);
                                write('>');
                                gotoxy(22,current+1);
                                infield_inp_fgrd:=15;
                                infield_inp_bkgd:=1;
                                infield_out_fgrd:=3;
                                infield_out_bkgd:=0;
                                infield_allcaps:=false;
                                infield_numbers_only:=False;
                                infield_putatend:=TRUE;
                                infield_insert:=TRUE;
                                infield_clear:=TRUE;
                                s:=sec.description;
                                infielde(s,20);
                                infield_maxshow:=0;
                                if (s<>sec.description) then begin
                                        changed:=TRUE;
                                        sec.description:=s;
                                end;
                                infield_putatend:=FALSE;
                                infield_clear:=FALSE;
                        end;
                        2:begin
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choice[current]);
                                gotoxy(20,current+1);
                                textcolor(9);
                                write('>');
                                gotoxy(22,current+1);
                                infield_inp_fgrd:=15;
                                infield_inp_bkgd:=1;
                                infield_out_fgrd:=3;
                                infield_out_bkgd:=0;
                                infield_allcaps:=false;
                                infield_numbers_only:=TRUE;
                                infield_putatend:=TRUE;
                                infield_insert:=FALSE;
                                infield_clear:=TRUE;
                                infield_min_value:=0;
                                infield_max_value:=255;
                                s:=cstr(sec.callsperday);
                                infielde(s,3);
                                infield_min_value:=-1;
                                infield_max_value:=-1;
                                if (value(s)<>sec.callsperday) then begin
                                        changed:=TRUE;
                                        sec.callsperday:=value(s);
                                end;
                                infield_putatend:=FALSE;
                                infield_clear:=FALSE;
                        end;
                        3:begin
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choice[current]);
                                gotoxy(20,current+1);
                                textcolor(9);
                                write('>');
                                gotoxy(22,current+1);
                                infield_inp_fgrd:=15;
                                infield_inp_bkgd:=1;
                                infield_out_fgrd:=3;
                                infield_out_bkgd:=0;
                                infield_allcaps:=false;
                                infield_numbers_only:=TRUE;
                                infield_putatend:=TRUE;
                                infield_insert:=FALSE;
                                infield_clear:=TRUE;
                                infield_min_value:=0;
                                infield_max_value:=1440;
                                s:=cstr(sec.Timepercall);
                                infielde(s,4);
                                infield_min_value:=-1;
                                infield_max_value:=-1;
                                if (value(s)<>sec.timepercall) then begin
                                        changed:=TRUE;
                                        sec.timepercall:=value(s);
                                end;
                                infield_putatend:=FALSE;
                                infield_clear:=FALSE;
                        end;
                        4:begin
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choice[current]);
                                gotoxy(20,current+1);
                                textcolor(9);
                                write('>');
                                gotoxy(22,current+1);
                                infield_inp_fgrd:=15;
                                infield_inp_bkgd:=1;
                                infield_out_fgrd:=3;
                                infield_out_bkgd:=0;
                                infield_allcaps:=false;
                                infield_numbers_only:=TRUE;
                                infield_putatend:=TRUE;
                                infield_insert:=FALSE;
                                infield_clear:=TRUE;
                                infield_min_value:=0;
                                infield_max_value:=1440;
                                s:=cstr(sec.Timeperday);
                                infielde(s,4);
                                infield_min_value:=-1;
                                infield_max_value:=-1;
                                if (value(s)<>sec.timeperday) then begin
                                        changed:=TRUE;
                                        sec.timeperday:=value(s);
                                end;
                                infield_putatend:=FALSE;
                                infield_clear:=FALSE;
                        end;
                        5:begin
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choice[current]);
                                gotoxy(20,current+1);
                                textcolor(9);
                                write('>');
                                gotoxy(22,current+1);
                                infield_inp_fgrd:=15;
                                infield_inp_bkgd:=1;
                                infield_out_fgrd:=3;
                                infield_out_bkgd:=0;
                                infield_allcaps:=false;
                                infield_numbers_only:=TRUE;
                                infield_putatend:=TRUE;
                                infield_insert:=FALSE;
                                infield_clear:=TRUE;
                                infield_min_value:=0;
                                infield_max_value:=32767;
                                s:=cstr(sec.postpercall);
                                infielde(s,5);
                                infield_min_value:=-1;
                                infield_max_value:=-1;
                                if (value(s)<>sec.postpercall) then begin
                                        changed:=TRUE;
                                        sec.postpercall:=value(s);
                                end;
                                infield_putatend:=FALSE;
                                infield_clear:=FALSE;
                        end;
                        6:begin
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choice[current]);
                                gotoxy(20,current+1);
                                textcolor(9);
                                write('>');
                                gotoxy(22,current+1);
                                infield_inp_fgrd:=15;
                                infield_inp_bkgd:=1;
                                infield_out_fgrd:=3;
                                infield_out_bkgd:=0;
                                infield_allcaps:=false;
                                infield_numbers_only:=TRUE;
                                infield_putatend:=TRUE;
                                infield_insert:=FALSE;
                                infield_clear:=TRUE;
                                s:=cstr(sec.dlratiofiles);
                                infield_min_value:=0;
                                infield_max_value:=32767;
                                infielde(s,5);
                                infield_min_value:=-1;
                                infield_max_value:=-1;
                                if (value(s)<>sec.dlratiofiles) then begin
                                        changed:=TRUE;
                                        sec.dlratiofiles:=value(s);
                                end;
                                infield_putatend:=FALSE;
                                infield_clear:=FALSE;
                        end;
                        7:begin
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choice[current]);
                                gotoxy(20,current+1);
                                textcolor(9);
                                write('>');
                                gotoxy(22,current+1);
                                infield_inp_fgrd:=15;
                                infield_inp_bkgd:=1;
                                infield_out_fgrd:=3;
                                infield_out_bkgd:=0;
                                infield_allcaps:=false;
                                infield_numbers_only:=TRUE;
                                infield_putatend:=TRUE;
                                infield_insert:=FALSE;
                                infield_clear:=TRUE;
                                s:=cstr(sec.dlratiokb);
                                infield_min_value:=0;
                                infield_max_value:=32767;
                                infielde(s,5);
                                infield_min_value:=-1;
                                infield_max_value:=-1;
                                if (value(s)<>sec.dlratiokb) then begin
                                        changed:=TRUE;
                                        sec.dlratiokb:=value(s);
                                end;
                                infield_putatend:=FALSE;
                                infield_clear:=FALSE;
                        end;
                        8:begin
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choice[current]);
                        end;
                        9:begin
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choice[current]);
                        end;
                        10:begin
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choice[current]);
                                gettb;
                                window(4,10,48,21);
                                end;
               end;
        end;
        #27:done:=TRUE;
end;
until (done);
editsecurity:=FALSE;
if (changed) then begin
if not(autosave) then autosave:=pynqbox('Save changes? ');
editsecurity:=autosave;
end;
removewindow(w);
end;

procedure seclevelconfig;
var firstlp,lp,lp2:listptr;
    security:securityrec;
    securityf:file of securityrec;
    rt:returntype;
    w2:windowrec;
    numactive,foundat,x,x2,cur,top:integer;
    b:byte;
    s:string;
    c:char;
    update,done,changed,found,ok:boolean;

begin
assign(securityf,systat.gfilepath+'SECURITY.DAT');
{$I-} reset(securityf); {$I+}
if (ioresult<>0) then begin
        displaybox('Error Reading SECURITY.DAT.',3000);
        exit;
end;
listbox_tag:=FALSE;
listbox_move:=FALSE;
done:=FALSE;
update:=TRUE;
top:=1;
cur:=1;
repeat
if (update) then begin
new(lp);
found:=FALSE;
foundat:=0;
numactive:=0;
seek(securityf,1);
while not(eof(securityf)) and not(found) do begin
read(securityf,security);
if (security.active) then begin
lp^.p:=NIL;
lp^.list:=mln(cstr(filepos(securityf)-1),3)+'  '+security.description;
firstlp:=lp;
found:=TRUE;
inc(numactive);
foundat:=filepos(securityf)-1;
end;
end;
if (found) then
for x:=(foundat+1) to 100 do begin
        {$I-} seek(securityf,x); {$I+}
        if (ioresult<>0) then begin
                displaybox('SECURITY.DAT has been corrupted.',3000);
                exit;
        end;
        read(securityf,security);
        if (security.active) then begin
        new(lp2);
        lp2^.p:=lp;
        lp^.n:=lp2;
        lp2^.list:=mln(cstr(filepos(securityf)-1),3)+'  '+security.description;
        lp:=lp2;
        inc(numactive);
        end;
end;
lp^.n:=NIL;
lp:=firstlp;
if (numactive=0) then numactive:=1;
if (cur>numactive) then cur:=numactive;
if (top>cur) then top:=cur;
for x:=1 to 100 do rt.data[x]:=-1;
end;
listbox(w2,rt,top,cur,lp,25,7,55,20,3,0,8,'Security Levels','',TRUE);
case rt.kind of
        0:begin
                                                c:=chr(rt.data[100]);
                                                removewindow(w2);
                                                checkkey(c);
                                                rt.data[100]:=-1;
          end;
        1:begin
              if (rt.data[1]<>-1) then begin
                   b:=rt.data[1];
                   x:=0;
                   seek(securityf,1);
                   while (x<b) and not(eof(securityf)) do begin
                        read(securityf,security);
                        if (security.active) then begin
                                inc(x);
                                x2:=filepos(securityf)-1;
                        end;
                   end;
                   window(19,8,61,19);
                   seek(securityf,x2);
                   read(securityf,security);
                   changed:=editsecurity(security,x2);
                   if (changed) then begin
                                seek(securityf,x2);
                                write(securityf,security);
                   end;
              end;
          end;
        2:done:=TRUE;
        3:begin { insert pressed }
                setwindow(w,27,12,53,14,3,0,8,'',TRUE);
                gotoxy(2,1);
                textcolor(7);
                textbackground(0);
                write('Security Level   : ');
                repeat
                  gotoxy(21,1);
                  s:='';
                  infield_inp_fgrd:=15;
                  infield_inp_bkgd:=1;
                  infield_out_fgrd:=3;
                  infield_out_bkgd:=0;
                  infield_allcaps:=false;
                  infield_numbers_only:=TRUE;
                  infield_escape_zero:=TRUE;
                  infield_insert:=FALSE;
                  infielde(s,4);
                  infield_escape_zero:=FALSE;
                  infield_insert:=TRUE;
                until (value(s)>=0) and (value(s)<=100);
                removewindow(w);
                if (value(s)<>0) then begin
                        seek(securityf,value(s));
                        read(securityf,security);
                        security.active:=TRUE;
                        changed:=editsecurity(security,value(s));
                        if (changed) then begin
                                seek(securityf,value(s));
                                write(securityf,security);
                                removewindow(w2);
                                lp:=firstlp;
                                while (lp<>NIL) do begin
                                         lp2:=lp^.n;
                                         dispose(lp);
                                         lp:=lp2;
                                end;
                                update:=TRUE;
                        end;
                end;
             end;
         4:begin { delete }
                if (rt.data[1]<>-1) then begin
                   b:=rt.data[1];
                   x:=0;
                   seek(securityf,1);
                   while (x<b) and not(eof(securityf)) do begin
                        read(securityf,security);
                        if (security.active) then begin
                                inc(x);
                                x2:=filepos(securityf)-1;
                        end;
                   end;
                   if (x2<>100) then begin
                   seek(securityf,x2);
                   read(securityf,security);
                   security.active:=false;
                   seek(securityf,x2);
                   write(securityf,security);
                   removewindow(w2);
                   lp:=firstlp;
                   while (lp<>NIL) do begin
                         lp2:=lp^.n;
                         dispose(lp);
                         lp:=lp2;
                   end;
                   update:=TRUE;
                   end;
        end;
        end;
end;
until (done);
listbox_tag:=TRUE;
listbox_move:=TRUE;
removewindow(w2);
lp:=firstlp;
while (lp<>NIL) do begin
         lp2:=lp^.n;
         dispose(lp);
         lp:=lp2;
end;
close(securityf);
end;

function editsubs(var ss:subscriptionrec; sublevel:integer):boolean;
var c:char;
    choice:array[1..16] of string[30];
    desc:array[1..16] of string;
    x,current:integer;
    done,changed,autosave:boolean;
    oldar:set of acrq;
    s:string;

    function showmod1(b:byte):string;
    begin
    case b of
        0:showmod1:='Hard';
        1:showmod1:='Soft';
    end;
    end;

    function showmod2(b:byte):string;
    begin
    case b of
        0:showmod2:='Set';
        1:showmod2:='Add';
        2:showmod2:='Sub';
    end;
    end;

    function showlength(i:integer):string;
    begin
    if (i=0) then showlength:='Never     '
    else showlength:=mln(cstr(i)+' days',10);
    end;

    function showexpire(i:integer):string;
    begin
    if (i=0) then showexpire:='No Expire ' else
    if (i=-1) then showexpire:='Delete    ' else
    if (i=-2) then showexpire:='Lockout   '
    else showexpire:='Level '+mln(cstr(i),4);
    end;


    function showarflags:string;
    var c:char;
        tmp:string;
    begin
    tmp:='';
    for c:='A' to 'Z' do begin
        if (c in ss.arflags) then 
            tmp:=tmp+c
        else tmp:=tmp+'-';
    end;
    showarflags:=tmp;
    end;

    function showarflags2:string;
    var c:char;
        tmp:string;
    begin
    tmp:='';
    for c:='A' to 'Z' do begin
        if (c in ss.arflags2) then 
            tmp:=tmp+c
        else tmp:=tmp+'-';
    end;
    showarflags2:=tmp;
    end;

  procedure getrestrictions;
  var ch1:array[1..18] of string[30];
      w2:windowrec;
      desc1:array[1..18] of string;
      x1,current1:integer;
      c1:char;
      done2:boolean;
  begin
  ch1[1]:='One Call Per Day    :';
  ch1[2]:='Alert SysOp         :';
  ch1[3]:='Cannot Page SysOp   :';
  ch1[4]:='No Special Keys     :';
  ch1[5]:='Cannot Post         :';
  ch1[6]:='Cannot Post Private :';
  ch1[7]:='Force Private Delete:';
  ch1[8]:='No UL/DL Ratio      :';
  ch1[9]:='No Post/Call Ratio  :';
  ch1[10]:='No File Point Check :';
  ch1[11]:='Permanent           :';
  current1:=1;
  setwindow(w2,10,8,40,21,3,0,8,'Restrictions/Special',TRUE);
  for x1:=1 to 11 do begin
        gotoxy(2,x1+1);
        textcolor(7);
        textbackground(0);
        write(ch1[x1]);
  end;
  textcolor(3);
  gotoxy(24,2);
  write(syn(rlogon in ss.acflags));
  gotoxy(24,3);
  write(syn(alert in ss.acflags));
  gotoxy(24,4);
  write(syn(rchat in ss.acflags));
  gotoxy(24,5);
  write(syn(rbackspace in ss.acflags));
  gotoxy(24,6);
  write(syn(rpost in ss.acflags));
  gotoxy(24,7);
  write(syn(remail in ss.acflags));
  gotoxy(24,8);
  write(syn(rmsg in ss.acflags));
  gotoxy(24,9);
  write(syn(fnodlratio in ss.acflags));
  gotoxy(24,10);
  write(syn(fnopostratio in ss.acflags));
  gotoxy(24,11);
  write(syn(fnofilepts in ss.acflags));
  gotoxy(24,12);
  write(syn(fnodeletion in ss.acflags));
  repeat
  gotoxy(2,current1+1);
  textcolor(15);
  textbackground(1);
  write(ch1[current1]);
  textbackground(0);
  done2:=false;
  while not(keypressed) do begin timeslice; end;
  c1:=readkey;
  case c1 of
        #0:begin
                c1:=readkey;
                checkkey(c1);
                case c1 of
                   #72:begin
                          gotoxy(2,current1+1);
                          textcolor(7);
                          textbackground(0);
                          write(ch1[current1]);
                          dec(current1);
                          if (current1=0) then current1:=11;
                        end;
                    #80:begin
                          gotoxy(2,current1+1);
                          textcolor(7);
                          textbackground(0);
                          write(ch1[current1]);
                          inc(current1);
                          if (current1=12) then current1:=1;
                        end;  
                end;
           end;
       #13:begin
          changed:=TRUE;
          textcolor(3);
          textbackground(0);
          case current1 of
          1:begin
          if (rlogon in ss.acflags) then
          ss.acflags:=ss.acflags-[rlogon]
          else
          ss.acflags:=ss.acflags+[rlogon];
          gotoxy(24,2);
          write(syn(rlogon in ss.acflags));
          end;
          2:begin
          if (alert in ss.acflags) then
          ss.acflags:=ss.acflags-[alert]
          else
          ss.acflags:=ss.acflags+[alert];
          gotoxy(24,3);
          write(syn(alert in ss.acflags));
          end;
          3:begin
          if (rchat in ss.acflags) then
          ss.acflags:=ss.acflags-[rchat]
          else
          ss.acflags:=ss.acflags+[rchat];
          gotoxy(24,4);
          write(syn(rchat in ss.acflags));
          end;
          4:begin
          if (rbackspace in ss.acflags) then
          ss.acflags:=ss.acflags-[rbackspace]
          else
          ss.acflags:=ss.acflags+[rbackspace];
          gotoxy(24,5);
          write(syn(rbackspace in ss.acflags));
          end;
          5:begin
          if (rpost in ss.acflags) then
          ss.acflags:=ss.acflags-[rpost]
          else
          ss.acflags:=ss.acflags+[rpost];
          gotoxy(24,6);
          write(syn(rpost in ss.acflags));
          end;
          6:begin
          if (remail in ss.acflags) then
          ss.acflags:=ss.acflags-[remail]
          else
          ss.acflags:=ss.acflags+[remail];
          gotoxy(24,7);
          write(syn(remail in ss.acflags));
          end;
          7:begin
          if (rmsg in ss.acflags) then
          ss.acflags:=ss.acflags-[rmsg]
          else
          ss.acflags:=ss.acflags+[rmsg];
          gotoxy(24,8);
          write(syn(rmsg in ss.acflags));
          end;
          8:begin
          if (fnodlratio in ss.acflags) then
          ss.acflags:=ss.acflags-[fnodlratio]
          else
          ss.acflags:=ss.acflags+[fnodlratio];
          gotoxy(24,9);
          write(syn(fnodlratio in ss.acflags));
          end;
          9:begin
          if (fnopostratio in ss.acflags) then
          ss.acflags:=ss.acflags-[fnopostratio]
          else
          ss.acflags:=ss.acflags+[fnopostratio];
          gotoxy(24,10);
          write(syn(fnopostratio in ss.acflags));
          end;
          10:begin
          if (fnofilepts in ss.acflags) then
          ss.acflags:=ss.acflags-[fnofilepts]
          else
          ss.acflags:=ss.acflags+[fnofilepts];
          gotoxy(24,11);
          write(syn(fnofilepts in ss.acflags));
          end;
          11:begin
          if (fnodeletion in ss.acflags) then
          ss.acflags:=ss.acflags-[fnodeletion]
          else
          ss.acflags:=ss.acflags+[fnodeletion];
          gotoxy(24,12);
          write(syn(fnodeletion in ss.acflags));
          end;
          end;
         end;
       #27:begin
           done2:=TRUE;
           end;
  end;
  until (done2);
  removewindow(w2);
  end;

    function showacflags:string;
    var tmp:string;
    begin
    tmp:='';
    with ss do begin
    if (rLogon in acflags) then tmp:=tmp+'OneCall ';
    if (rChat in acflags) then tmp:=tmp+'NoChat ';
    if (rPost in acflags) then tmp:=tmp+'NoPost ';
    if (rEmail in acflags) then tmp:=tmp+'NoPriv ';
    if (rMsg in acflags) then tmp:=tmp+'PrivDel ';
    if (onekey in acflags) then tmp:=tmp+'QKey ';
    if (novice in acflags) then tmp:=tmp+'Nov ';
    if (alert in acflags) then tmp:=tmp+'Alert ';
    if (fnodlratio in acflags) then tmp:=tmp+'NoULDL ';
    if (fnofilepts in acflags) then tmp:=tmp+'NoFPts ';
    if (fnodeletion in acflags) then tmp:=tmp+'NoDel ';
    end;
    if (tmp='') then tmp:='None';
    showacflags:=tmp;
    end;


begin
done:=false;
changed:=false;
autosave:=false;
choice[1]:='Description       :';
choice[2]:='Security Level    :';
choice[3]:='AR Flags #1       :';
choice[4]:='AR Modifier #1    :';
choice[5]:='AR Flags #2       :';
choice[6]:='AR Modifier #2    :';
choice[7]:='AC Flags          :';
choice[8]:='AC Modifier       :';
choice[9]:='Filepoints        :';
choice[10]:='Filepoint Modifier:';
choice[11]:='Credits           :';
choice[12]:='Credit Modifier   :';
choice[13]:='Time Bank (min)   :';
choice[14]:='TB Modifier       :';
choice[15]:='Expires In (days) :';
choice[16]:='Expires To (level):';
desc[1]:='Description of this Subscription Level for Future Reference   ';
desc[2]:='Security Level to Set User to upon start of this Subscription ';
desc[3]:='AR Flags (A..Z) #1 to set user''s AR Flags To                     ';
desc[4]:='Soft: Turn these flags on  Hard: Set Flags to this set        ';
desc[5]:='AR Flags (A..Z) #2 to set user''s AR Flags To                     ';
desc[6]:='Soft: Turn these flags on  Hard: Set Flags to this set        ';
desc[7]:='AC Flags to set user''s AC Flags To                            ';
desc[8]:='Soft: Turn these flags on  Hard: Set Flags to this set        ';
desc[9]:='Filepoints to give user at start of this Subscription Level   ';
desc[10]:='Set: Set to this #  Add: Add this #  Sub: Subtract this #     ';
desc[11]:='Credits to give user at start of this Subscription Level      ';
desc[12]:='Set: Set to this #  Add: Add this #  Sub: Subtract this #    ';
desc[13]:='Time Bank minutes to give user at start of this Subscription  ';
desc[14]:='Set: Set to this #  Add: Add this #  Sub: Subtract this #     ';
desc[15]:='Number of days User should have this Subscription (0=Infinite)';
desc[16]:='If subscription ends, which subscription to change to         ';


cursoron(FALSE);
setwindow2(w,3,4,66,23,3,0,8,'Edit Subscription','Level '+cstr(sublevel),TRUE);
for x:=1 to 16 do begin
        gotoxy(2,x+1);
        textcolor(7);
        textbackground(0);
        write(choice[x]);
end;
with ss do begin
textcolor(3);
textbackground(0);
gotoxy(22,2);
write(mln(description,30));
gotoxy(22,3);
write(mln(cstr(sl),3));
gotoxy(22,4);
write(showarflags);
gotoxy(22,5);
write(showmod1(armodifier));
gotoxy(22,6);
write(showarflags2);
gotoxy(22,7);
write(showmod1(armodifier2));
gotoxy(22,8);
write(showacflags);
gotoxy(22,9);
write(showmod1(acmodifier));
gotoxy(22,10);
write(mln(cstr(filepoints),5));
gotoxy(22,11);
write(showmod2(fpmodifier));
gotoxy(22,12);
write(mln(cstr(credits),5));
gotoxy(22,13);
write(showmod2(cmodifier));
gotoxy(22,14);
write(mln(cstr(timebank),5));
gotoxy(22,15);
write(showmod2(tbmodifier));
gotoxy(22,16);
write(showlength(sublength));
gotoxy(22,17);
write(showexpire(newsublevel));
end;
current:=1;
repeat
gotoxy(2,current+1);
textcolor(15);
textbackground(1);
write(choice[current]);
window(1,1,80,25);
gotoxy(1,25);
textcolor(14);
textbackground(0);
write('Esc');
textcolor(7);
write('=Exit ');
textcolor(14);
write(desc[current]);
window(4,5,65,22);
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
                                write(choice[current]);
                                dec(current);
                                if (current<1) then current:=16;
                            end;
                        #80:begin
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choice[current]);
                                inc(current);
                                if (current>16) then current:=1;
                            end;
                end;
           end;
        #13:begin
                gotoxy(2,current+1);
                textcolor(7);
                textbackground(0);
                write(choice[current]);
                gotoxy(20,current+1);
                textcolor(9);
                textbackground(0);
                write('>');
                gotoxy(22,current+1);
                case current of
                        1:begin
                                s:=ss.description;
                                infield_inp_fgrd:=15;
                                infield_inp_bkgd:=1;
                                infield_out_fgrd:=3;
                                infield_out_bkgd:=0;
                                infield_allcaps:=false;
                                infield_numbers_only:=false;
                                infield_putatend:=TRUE;
                                infield_insert:=TRUE;
                                infield_clear:=TRUE;
                                infield_maxshow:=30;
                                infielde(s,40);
                                infield_maxshow:=0;
                                if (s<>ss.description) then begin
                                        changed:=TRUE;
                                        ss.description:=s;
                                end;
                        end;
                        2:begin
                                s:=cstr(ss.sl);
                                infield_inp_fgrd:=15;
                                infield_inp_bkgd:=1;
                                infield_out_fgrd:=3;
                                infield_out_bkgd:=0;
                                infield_allcaps:=false;
                                infield_numbers_only:=TRUE;
                                infield_putatend:=TRUE;
                                infield_insert:=TRUE;
                                infield_clear:=TRUE;
                                infield_min_value:=0;
                                infield_max_value:=100;
                                infielde(s,3);
                                infield_min_value:=-1;
                                infield_max_value:=-1;
                                if (value(s)<>ss.sl) and (value(s)<=100) and
                                (value(s)>0) then begin
                                        changed:=TRUE;
                                        ss.sl:=value(s);
                                end;
                        end;
                        3:begin
                                        s:='';
                                        textcolor(15);
                                        textbackground(1);
                                        for c:='A' to 'Z' do
                                             if c in ss.arflags then s:=s+c else s:=s+'-';
                                        write(s);
                                        c:=#0;
                                        oldar:=ss.arflags;
                                        while (c<>#27) and (c<>#13) do begin
                                                while not(keypressed) do begin timeslice; end;
                                                c:=readkey;
                                                c:=upcase(c);
                                                if (c in ['A'..'Z']) then begin
                                                        if (c in ss.arflags) then ss.arflags:=
                                                                ss.arflags-[c] else
                                                        ss.arflags:=ss.arflags+[c];
                                                        gotoxy(22,current+1);
                                                        textcolor(15);
                                                        textbackground(1);
                                                        s:='';
                                                        changed:=TRUE;
                                                        for c:='A' to 'Z' do
                                                             if c in ss.arflags then s:=s+c else s:=s+'-';
                                                        write(s);
                                                end;
                                        end;
                                        if (c=#27) then begin
                                                ss.arflags:=oldar;
                                                changed:=FALSE;
                                        end;
                                        gotoxy(22,current+1);
                                        textcolor(3);
                                        textbackground(0);
                                        s:='';
                                        for c:='A' to 'Z' do
                                               if c in ss.arflags then s:=s+c else s:=s+'-';
                                        write(s);
                                        c:=#13;
                        end;
                        4:begin
                        inc(ss.armodifier);
                        if (ss.armodifier=2) then ss.armodifier:=0;
                        textcolor(3);
                        textbackground(0);
                        gotoxy(22,5);
                        write(showmod1(ss.armodifier));
                        changed:=TRUE;
                        end;
                        5:begin
                                        s:='';
                                        textcolor(15);
                                        textbackground(1);
                                        for c:='A' to 'Z' do
                                             if c in ss.arflags2 then s:=s+c else s:=s+'-';
                                        write(s);
                                        c:=#0;
                                        oldar:=ss.arflags2;
                                        while (c<>#27) and (c<>#13) do begin
                                                while not(keypressed) do begin timeslice;
                                                end;
                                                c:=readkey;
                                                c:=upcase(c);
                                                if (c in ['A'..'Z']) then begin
                                                        if (c in ss.arflags2) then ss.arflags2:=
                                                                ss.arflags2-[c] else
                                                        ss.arflags2:=ss.arflags2+[c];
                                                        gotoxy(22,current+1);
                                                        textcolor(15);
                                                        textbackground(1);
                                                        s:='';
                                                        changed:=TRUE;
                                                        for c:='A' to 'Z' do
                                                             if c in ss.arflags2 then s:=s+c else s:=s+'-';
                                                        write(s);
                                                end;
                                        end;
                                        if (c=#27) then begin
                                                ss.arflags2:=oldar;
                                                changed:=FALSE;
                                        end;
                                        gotoxy(22,current+1);
                                        textcolor(3);
                                        textbackground(0);
                                        s:='';
                                        for c:='A' to 'Z' do
                                               if c in ss.arflags2 then s:=s+c else s:=s+'-';
                                        write(s);
                                        c:=#13;
                        end;
                        6:begin
                        inc(ss.armodifier2);
                        if (ss.armodifier2=2) then ss.armodifier2:=0;
                        textcolor(3);
                        textbackground(0);
                        gotoxy(22,7);
                        write(showmod1(ss.armodifier2));
                        changed:=TRUE;
                        end;
                        7:begin
                        getrestrictions;
                        window(4,5,65,22);
                        textcolor(3);
                        textbackground(0);
                        gotoxy(22,current+1);
                        write(showacflags);
                        end;
                        8:begin
                        inc(ss.acmodifier);
                        if (ss.acmodifier=2) then ss.acmodifier:=0;
                        textcolor(3);
                        textbackground(0);
                        gotoxy(22,current+1);
                        write(showmod1(ss.acmodifier));
                        changed:=TRUE;
                        end;
                        9:begin
                                s:=cstr(ss.filepoints);
                                infield_inp_fgrd:=15;
                                infield_inp_bkgd:=1;
                                infield_out_fgrd:=3;
                                infield_out_bkgd:=0;
                                infield_allcaps:=false;
                                infield_numbers_only:=TRUE;
                                infield_putatend:=TRUE;
                                infield_insert:=TRUE;
                                infield_clear:=TRUE;
                                infield_min_value:=0;
                                infield_max_value:=32767;
                                infielde(s,5);
                                infield_min_value:=-1;
                                infield_max_value:=-1;
                                if (value(s)<>ss.filepoints) and (value(s)<=32767) and
                                (value(s)>0) then begin
                                        changed:=TRUE;
                                        ss.filepoints:=value(s);
                                end;
                        end;
                        10:begin
                        inc(ss.fpmodifier);
                        if (ss.fpmodifier=3) then ss.fpmodifier:=0;
                        textcolor(3);
                        textbackground(0);
                        gotoxy(22,current+1);
                        write(showmod2(ss.fpmodifier));
                        changed:=TRUE;
                        end;
                        11:begin
                                s:=cstr(ss.credits);
                                infield_inp_fgrd:=15;
                                infield_inp_bkgd:=1;
                                infield_out_fgrd:=3;
                                infield_out_bkgd:=0;
                                infield_allcaps:=false;
                                infield_numbers_only:=TRUE;
                                infield_putatend:=TRUE;
                                infield_insert:=TRUE;
                                infield_clear:=TRUE;
                                infield_min_value:=0;
                                infield_max_value:=32767;
                                infielde(s,5);
                                infield_min_value:=-1;
                                infield_max_value:=-1;
                                if (value(s)<>ss.credits) and (value(s)<=32767) and
                                (value(s)>0) then begin
                                        changed:=TRUE;
                                        ss.credits:=value(s);
                                end;
                        end;
                        12:begin
                        inc(ss.cmodifier);
                        if (ss.cmodifier=3) then ss.cmodifier:=0;
                        textcolor(3);
                        textbackground(0);
                        gotoxy(22,current+1);
                        write(showmod2(ss.cmodifier));
                        changed:=TRUE;
                        end;
                        13:begin
                                s:=cstr(ss.timebank);
                                infield_inp_fgrd:=15;
                                infield_inp_bkgd:=1;
                                infield_out_fgrd:=3;
                                infield_out_bkgd:=0;
                                infield_min_value:=0;
                                infield_max_value:=32767;
                                infield_allcaps:=false;
                                infield_numbers_only:=TRUE;
                                infield_putatend:=TRUE;
                                infield_insert:=TRUE;
                                infield_clear:=TRUE;
                                infielde(s,5);
                                infield_min_value:=-1;
                                infield_max_value:=-1;
                                if (value(s)<>ss.timebank) and (value(s)<=32767) and
                                (value(s)>0) then begin
                                        changed:=TRUE;
                                        ss.timebank:=value(s);
                                end;
                        end;
                        14:begin
                        inc(ss.tbmodifier);
                        if (ss.tbmodifier=3) then ss.tbmodifier:=0;
                        textcolor(3);
                        textbackground(0);
                        gotoxy(22,current+1);
                        write(showmod2(ss.tbmodifier));
                        changed:=TRUE;
                        end;
                        15:begin
                                write('             ');
                                if (ss.sublength<1) then s:='1' else
                                s:=cstr(ss.sublength);
                                window(1,1,80,25);
                                gotoxy(1,25);
                                textcolor(14);
                                textbackground(0);
                                clreol;
                                write('F2');
                                textcolor(7);
                                write('=Never ');
                                window(4,5,65,22);
                                gotoxy(22,current+1);
                                infield_inp_fgrd:=15;
                                infield_inp_bkgd:=1;
                                infield_out_fgrd:=3;
                                infield_out_bkgd:=0;
                                infield_allcaps:=false;
                                infield_numbers_only:=TRUE;
                                infield_putatend:=TRUE;
                                infield_insert:=TRUE;
                                infield_clear:=TRUE;
                                infield_min_value:=0;
                                infield_max_value:=32767;
                                infield_func_keys:=TRUE;
                                infield_func_keys_allowed:=chr(60)+chr(61)+chr(62);
                                infielde(s,5);
                                infield_func_keys:=FALSE;
                                infield_func_keys_allowed:='';
                                infield_min_value:=-1;
                                infield_max_value:=-1;
                                if (s='') then begin
                                case infield_func_key_pressed of
                                        #0:begin
                                        if (value(s)<>ss.sublength) and (value(s)<=32767) and
                                        (value(s)>=-2) then begin
                                        changed:=TRUE;
                                        ss.sublength:=value(s);
                                        end;
                                        end;
                                        chr(60):begin
                                                ss.sublength:=0;
                                                changed:=TRUE;
                                                end;
                                        chr(61):begin
                                                ss.sublength:=-1;
                                                changed:=TRUE;
                                                end;
                                        chr(62):begin
                                                ss.sublength:=-2;
                                                changed:=TRUE;
                                                end;
                                end;
                                infield_func_key_pressed:=#0;
                                end else begin
                                if (value(s)<>ss.sublength) and (value(s)<=32767) and
                                (value(s)>=-2) then begin
                                        changed:=TRUE;
                                        ss.sublength:=value(s);
                                end;
                                end;
                                textcolor(3);
                                textbackground(0);
                                gotoxy(22,current+1);
                                write(showlength(ss.sublength));
                        end;
                        16:begin
                                s:=cstr(ss.newsublevel);
                                window(1,1,80,25);
                                gotoxy(1,25);
                                textcolor(14);
                                textbackground(0);
                                clreol;
                                write('F2');
                                textcolor(7);
                                write('=No Expiration ');
                                textcolor(14);
                                write('F3');
                                textcolor(7);
                                write('=Delete ');
                                textcolor(14);
                                write('F4');
                                textcolor(7);
                                write('=Lockout ');
                                window(4,5,65,22);
                                gotoxy(22,current+1);
                                write(mln(' ',15));
                                gotoxy(22,current+1);
                                infield_inp_fgrd:=15;
                                infield_inp_bkgd:=1;
                                infield_out_fgrd:=3;
                                infield_out_bkgd:=0;
                                infield_allcaps:=false;
                                infield_numbers_only:=TRUE;
                                infield_putatend:=TRUE;
                                infield_insert:=TRUE;
                                infield_clear:=TRUE;
                                infield_min_value:=0;
                                infield_max_value:=255;
                                infield_func_keys:=TRUE;
                                infield_func_keys_allowed:=chr(60)+chr(61)+chr(62);
                                infielde(s,3);
                                infield_func_keys:=FALSE;
                                infield_func_keys_allowed:='';
                                infield_min_value:=-1;
                                infield_max_value:=-1;
                                if (s='') then begin
                                case infield_func_key_pressed of
                                        #0:begin
                                        if (value(s)<>ss.newsublevel) and (value(s)<=255) and
                                        (value(s)>=-2) then begin
                                        changed:=TRUE;
                                        ss.newsublevel:=value(s);
                                        end;
                                        end;
                                        chr(60):begin
                                                ss.newsublevel:=0;
                                                changed:=TRUE;
                                                end;
                                        chr(61):begin
                                                ss.newsublevel:=-1;
                                                changed:=TRUE;
                                                end;
                                        chr(62):begin
                                                ss.newsublevel:=-2;
                                                changed:=TRUE;
                                                end;
                                end;
                                infield_func_key_pressed:=#0;
                                end else begin
                                if (value(s)<>ss.newsublevel) and (value(s)<=255) and
                                (value(s)>=0) then begin
                                        changed:=TRUE;
                                        ss.newsublevel:=value(s);
                                end;
                                end;
                                textcolor(3);
                                textbackground(0);
                                gotoxy(22,current+1);
                                write(showexpire(ss.newsublevel));
                        end;
                end;
        end;
        #27:done:=TRUE;
end;
until (done);
editsubs:=false;
if (changed) then begin
        if not(autosave) then autosave:=pynqbox('Save changes? ');
        editsubs:=autosave;
end;
removewindow(w);
end;

procedure subscriptconfig;
var firstlp,lp,lp2:listptr;
    ssf:file of subscriptionrec;
    ss:subscriptionrec;
    rt:returntype;
    w2:windowrec;
    foundat,x,x2,cur,top:integer;
    b:byte;
    s:string;
    c:char;
    update,done,changed,found,ok:boolean;

begin
assign(ssf,systat.gfilepath+'SUBSCRIP.DAT');
{$I-} reset(ssf); {$I+}
if (ioresult<>0) then begin
        displaybox('Error Reading SUBSCRIP.DAT.',3000);
        rewrite(ssf);
        with ss do begin
                Description:='';
                SL:=0;
                arflags:=[];
                ARmodifier:=0;
                arflags2:=[];
                ARmodifier2:=0;
                ACflags:=[];
                acmodifier:=0;
                Filepoints:=0;
                FPmodifier:=0;
                Credits:=0;
                Cmodifier:=0;
                TimeBank:=0;
                TBmodifier:=0;
                SubLength:=0;
                NewSubLevel:=0;
                for x:=1 to 20 do reserved[x]:=0;
                write(ssf,ss);
                Description:='New User Subscription';
                SL:=10;
                arflags:=[];
                ARmodifier:=0;
                arflags2:=[];
                ARmodifier2:=0;
                ACflags:=[];
                acmodifier:=0;
                Filepoints:=100;
                FPmodifier:=1;
                Credits:=0;
                Cmodifier:=0;
                TimeBank:=0;
                TBmodifier:=0;
                SubLength:=0;
                NewSubLevel:=0;
                for x:=1 to 20 do reserved[x]:=0;
                write(ssf,ss);
                end;
end;
listbox_tag:=FALSE;
listbox_move:=FALSE;
done:=FALSE;
update:=TRUE;
top:=1;
cur:=1;
repeat
if (update) then begin
new(lp);
found:=FALSE;
foundat:=0;
seek(ssf,1);
read(ssf,ss);
lp^.p:=NIL;
lp^.list:=mln(mln(cstr(1),3)+ss.description,30);
firstlp:=lp;
x:=2;
while not(eof(ssf)) do begin
        read(ssf,ss);
        new(lp2);
        lp2^.p:=lp;
        lp^.n:=lp2;
        lp2^.list:=mln(mln(cstr(x),3)+ss.description,30);
        lp:=lp2;
        inc(x);
end;
lp^.n:=NIL;
lp:=firstlp;
for x:=1 to 100 do rt.data[x]:=-1;
end;
listbox(w2,rt,top,cur,lp,43,7,77,20,3,0,8,'Subscription Levels','',TRUE);
case rt.kind of
        0:begin
                                                c:=chr(rt.data[100]);
                                                removewindow(w2);
                                                checkkey(c);
                                                rt.data[100]:=-1;
          end;
        1:begin
              if (rt.data[1]<>-1) then begin
                   b:=rt.data[1];
                   x:=0;
                   seek(ssf,b);
                   read(ssf,ss);
                   changed:=editsubs(ss,b);
                   if (changed) then begin
                                seek(ssf,b);
                                write(ssf,ss);
                   end;
              end;
          end;
        2:done:=TRUE;
        3:begin { insert pressed }
                seek(ssf,filesize(ssf));
                with ss do begin
                Description:='New Subscription Level';
                SL:=10;
                arflags:=[];
                ARmodifier:=0;
                ACflags:=[];
                acmodifier:=0;
                Filepoints:=0;
                FPmodifier:=0;
                Credits:=0;
                Cmodifier:=0;
                TimeBank:=0;
                TBmodifier:=0;
                SubLength:=0;
                NewSubLevel:=0;
                for x:=1 to 20 do reserved[x]:=0;
                end;
                changed:=editsubs(ss,filesize(ssf));
                if (changed) then begin
                                seek(ssf,filesize(ssf));
                                write(ssf,ss);
                                removewindow(w2);
                                lp:=firstlp;
                                while (lp<>NIL) do begin
                                         lp2:=lp^.n;
                                         dispose(lp);
                                         lp:=lp2;
                                end;
                                update:=TRUE;
                end;
             end;
         4:begin { delete }
                if (rt.data[1]<>-1) then begin
                   b:=rt.data[1];
                   if (b=1) then exit;
                   x:=0;
                   while not(eof(ssf)) do begin
                            seek(ssf,b+1);
                            read(ssf,ss);
                            seek(ssf,filepos(ssf)-2);
                            write(ssf,ss);
                            inc(b);
                   end;
                   seek(ssf,filesize(ssf)-1);
                   truncate(ssf);
                   removewindow(w2);
                   lp:=firstlp;
                   while (lp<>NIL) do begin
                         lp2:=lp^.n;
                         dispose(lp);
                         lp:=lp2;
                   end;
                   update:=TRUE;
                   end;
        end;
end;
until (done);
listbox_tag:=TRUE;
listbox_move:=TRUE;
removewindow(w2);
lp:=firstlp;
while (lp<>NIL) do begin
         lp2:=lp^.n;
         dispose(lp);
         lp:=lp2;
end;
close(ssf);
end;

function confedit(var conf:confrec; seclevel:byte; tp1:byte):boolean;
var c:char;
    choice:array[1..3] of string[30];
    desc:array[1..3] of string;
    x,current:integer;
    done,changed,autosave:boolean;
    s,s2:string;
begin
done:=false;
changed:=false;
choice[1]:='Description       :';
choice[2]:='Access String     :';
choice[3]:='Hidden            :';
desc[1]:='Description of Conference for Display Purposes                ';
desc[2]:='Access String to allow users to access this conference        ';
desc[3]:='Is this conference hidden from the user''s view?               ';
cursoron(FALSE);
setwindow2(w,3,10,49,17,3,0,8,'Edit Conference '+char(ord(seclevel)+64),'',TRUE);
for x:=1 to 3 do begin
        gotoxy(2,x+1);
        textcolor(7);
        textbackground(0);
        write(choice[x]);
end;
case tp1 of
        0:begin
with conf.msgconf[seclevel] do begin
textcolor(3);
textbackground(0);
gotoxy(22,2);
cwrite(mln(name,20));
textcolor(3);
textbackground(0);
gotoxy(22,3);
write(mln(access,20));
textcolor(3);
textbackground(0);
gotoxy(22,4);
write(syn(hidden));
end;
end;
1:begin
with conf.fileconf[seclevel] do begin
textcolor(3);
textbackground(0);
gotoxy(22,2);
cwrite(mln(name,20));
gotoxy(22,3);
textcolor(3);
textbackground(0);
write(mln(access,20));
textcolor(3);
textbackground(0);
gotoxy(22,4);
write(syn(hidden));
end;
end;
end;
autosave:=FALSE;
current:=1;
repeat
gotoxy(2,current+1);
textcolor(15);
textbackground(1);
write(choice[current]);
window(1,1,80,25);
gotoxy(1,25);
textcolor(14);
textbackground(0);
write('Esc');
textcolor(7);
write('=Exit ');
textcolor(14);
write(desc[current]);
window(4,11,48,16);
while not(keypressed) do begin timeslice; end;
c:=readkey;
case c of
        #0:begin
                c:=readkey;
                checkkey(c);
                case c of
                        #68:begin
                                autosave:=TRUE;
                                done:=TRUE;
                            end;
                        #72:begin
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choice[current]);
                                dec(current);
                                if (current<1) then current:=3;
                            end;
                        #80:begin
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choice[current]);
                                inc(current);
                                if (current>3) then current:=1;
                            end;
                end;
           end;
        #13:begin
                case current of
                        1:begin
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choice[current]);
                                gotoxy(20,current+1);
                                textcolor(9);
                                write('>');
                                gotoxy(22,current+1);
                                infield_inp_fgrd:=15;
                                infield_inp_bkgd:=1;
                                infield_out_fgrd:=3;
                                infield_out_bkgd:=0;
                                infield_allcaps:=false;
                                infield_numbers_only:=False;
                                infield_putatend:=TRUE;
                                infield_insert:=TRUE;
                                infield_maxshow:=20;
                                infield_clear:=TRUE;
                                infield_show_colors:=TRUE;
                                case tp1 of
                                0:s2:=conf.msgconf[seclevel].name;
                                1:s2:=conf.fileconf[seclevel].name;
                                end;
                                s:=s2;
                                infielde(s,40);
                                infield_maxshow:=0;
                                infield_show_colors:=FALSE;
                                if (s<>s2) then begin
                                        changed:=TRUE;
                                        case tp1 of
                                        0:conf.msgconf[seclevel].name:=s;
                                        1:conf.fileconf[seclevel].name:=s;
                                        end;
                                end;
                                infield_putatend:=FALSE;
                                infield_clear:=FALSE;
                        end;
                        2:begin
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choice[current]);
                                gotoxy(20,current+1);
                                textcolor(9);
                                write('>');
                                gotoxy(22,current+1);
                                infield_inp_fgrd:=15;
                                infield_inp_bkgd:=1;
                                infield_out_fgrd:=3;
                                infield_out_bkgd:=0;
                                infield_allcaps:=TRUE;
                                infield_numbers_only:=FALSE;
                                infield_putatend:=TRUE;
                                infield_insert:=FALSE;
                                infield_clear:=TRUE;
                                case tp1 of
                                0:s2:=conf.msgconf[seclevel].access;
                                1:s2:=conf.fileconf[seclevel].access;
                                end;
                                s:=s2;
                                infielde(s,20);
                                if (s<>s2) then begin
                                        changed:=TRUE;
                                        case tp1 of
                                        0:conf.msgconf[seclevel].access:=s;
                                        1:conf.fileconf[seclevel].access:=s;
                                        end;
                                end;
                                infield_putatend:=FALSE;
                                infield_clear:=FALSE;
                        end;
                        3:begin
                                case tp1 of
                                0:begin
                                        conf.msgconf[seclevel].hidden:=not(
                                        conf.msgconf[seclevel].hidden);
                                        gotoxy(22,4);
                                        textcolor(3);
                                        textbackground(0);
                                        write(syn(conf.msgconf[seclevel].hidden));
                                  end;
                                1:begin
                                        conf.fileconf[seclevel].hidden:=not(
                                        conf.fileconf[seclevel].hidden);
                                        gotoxy(22,4);
                                        textcolor(3);
                                        textbackground(0);
                                        write(syn(conf.fileconf[seclevel].hidden));
                                  end;
                                end;
                        end;
               end;
        end;
        #27:done:=TRUE;
end;
until (done);
confedit:=false;
if (changed) then begin
        if not(autosave) then autosave:=pynqbox('Save changes? ');
        confedit:=autosave;
end;
removewindow(w);
end;

procedure confeditor(tp1:byte);
var firstlp,lp,lp2:listptr;
    conff:file of confrec;
    conf:confrec;
    rt:returntype;
    w2,w3:windowrec;
    f:file;
    lastfound,foundat,x,x2,cur,top:integer;
    b:byte;
    s:string;
    c:char;
    foundlist:array[1..26] of byte;
    update,done,changed,found,ok:boolean;

begin
assign(conff,systat.gfilepath+'CONFS.DAT');
{$I-} reset(conff); {$I+}
if (ioresult<>0) then begin
        displaybox('Error Reading CONFS.DAT.',3000);
        rewrite(conff);
        case tp1 of
        0:begin
        with conf.msgconf[1] do begin
                access:='';
                name:='%030%Main Message Conference';
                active:=TRUE;
                hidden:=false;
        end;
        for x:=2 to 26 do
        with conf.msgconf[x] do begin
                access:='';
                name:='';
                active:=false;
                hidden:=false;
        end;
        end;
        1:begin
        with conf.fileconf[1] do begin
                access:='';
                name:='%030%Main File Conference';
                active:=TRUE;
                hidden:=false;
        end;
        for x:=2 to 26 do
        with conf.fileconf[x] do begin
                access:='';
                name:='';
                active:=false;
                hidden:=false;
        end;
        end;
        end;
end;
listbox_tag:=FALSE;
listbox_move:=FALSE;
done:=FALSE;
update:=TRUE;
top:=1;
cur:=1;
repeat
if (update) then begin
found:=FALSE;
foundat:=0;
{$I-} reset(conff); {$I+}
if (ioresult<>0) then begin
        displaybox('Error Reading CONFS.DAT',3000);
        exit;
end;
seek(conff,0);
read(conff,conf);
close(conff);
new(lp);
lp^.p:=NIL;
x:=1;
while not(found) and (x<27) do begin
        case tp1 of
        0:begin
                if (conf.msgconf[x].active) then begin
                        found:=TRUE;
                        foundat:=x;
                        foundlist[1]:=foundat;
                        lastfound:=1;
                end;
          end;
        1:begin
                if (conf.fileconf[x].active) then begin
                        found:=TRUE;
                        foundat:=x;
                        foundlist[1]:=foundat;
                        lastfound:=1;
                end;
          end;
        end;
        inc(x);
end;
if not(found) then begin
        case tp1 of
        0:lp^.list:=mln('No Message Conferences',33);
        1:lp^.list:=mln('No File Conferences',33);
        end;
        foundat:=26;
end else begin
case tp1 of
0:lp^.list:=mln(mln(chr(foundat+64),3)+conf.msgconf[1].name,30);
1:lp^.list:=mln(mln(chr(foundat+64),3)+conf.fileconf[1].name,30);
end;
end;
firstlp:=lp;
for x:=foundat+1 to 26 do begin
        case tp1 of
        0:if (conf.msgconf[x].active) then begin
        new(lp2);
        lp2^.p:=lp;
        lp^.n:=lp2;
        inc(lastfound);
        foundlist[lastfound]:=x;
        case tp1 of
                0:lp2^.list:=mln(mln(chr(x+64),3)+conf.msgconf[x].name,30);
                1:lp2^.list:=mln(mln(chr(x+64),3)+conf.fileconf[x].name,30);
        end;
        lp:=lp2;
        end;
        1:if (conf.fileconf[x].active) then begin
        new(lp2);
        lp2^.p:=lp;
        lp^.n:=lp2;
        inc(lastfound);
        foundlist[lastfound]:=x;
        case tp1 of
                0:lp2^.list:=mln(mln(chr(x+64),3)+conf.msgconf[x].name,30);
                1:lp2^.list:=mln(mln(chr(x+64),3)+conf.fileconf[x].name,30);
        end;
        lp:=lp2;
        end;
        end;
end;
lp^.n:=NIL;
lp:=firstlp;
for x:=1 to 100 do rt.data[x]:=-1;
end;
case tp1 of
0:listbox(w2,rt,top,cur,lp,43,7,77,20,3,0,8,'Message Conferences','',TRUE);
1:listbox(w2,rt,top,cur,lp,43,7,77,20,3,0,8,'File Conferences','',TRUE);
end;
case rt.kind of
        0:begin
                                                c:=chr(rt.data[100]);
                                                removewindow(w2);
                                                checkkey(c);
                                                rt.data[100]:=-1;
          end;
        1:begin
              if (rt.data[1]<>-1) then begin
                   b:=rt.data[1];
                   x:=0;
                   changed:=confedit(conf,foundlist[b],tp1);
              end;
          end;
        2:begin
              done:=TRUE;
          end;
        3:begin { insert pressed }
                setwindow(w3,27,12,53,14,3,0,8,'',TRUE);
                gotoxy(2,1);
                textcolor(7);
                textbackground(0);
                write('Conference Letter: ');

                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_numbers_only:=FALSE;
                                        infield_allcaps:=TRUE;
                                        infield_show_colors:=FALSE;
                                        infield_insert:=FALSE;
                                        infield_min_value:=0;
                                        infield_max_value:=32767;
                                        s:='';
                                        infielde(s,1);
                                        infield_min_value:=-1;
                                        infield_max_value:=-1;
                                        infield_maxshow:=0;
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_allcaps:=TRUE;
                                        infield_show_colors:=FALSE;
                                        removewindow(w3);
                                        if (s[1] in ['A'..'Z']) and (s<>'') then begin
                                        case tp1 of
                                        0:begin
                                          if (conf.msgconf[ord(s[1])-64].active) then begin
                                                  displaybox('Conference already exists!',3000);
                                          end else begin
                                          with conf.msgconf[ord(s[1])-64] do begin
                                                name:='New Message Conference';
                                                active:=TRUE;
                                                hidden:=FALSE;
                                                access:='';
                                          end;
                                          changed:=confedit(conf,ord(s[1])-64,tp1);
                                          if (changed) then begin
                                             removewindow(w2);
                                             lp:=firstlp;
                                             while (lp<>NIL) do begin
                                                 lp2:=lp^.n;
                                                 dispose(lp);
                                                 lp:=lp2;
                                             end;
                                             update:=TRUE;
                                          end;
                                          end;
                                          end;
                                        1:begin
                                          if (conf.fileconf[ord(s[1])-64].active) then begin
                                          displaybox('Conference already exists!',3000);
                                          end else begin
                                          with conf.fileconf[ord(s[1])-64] do begin
                                                name:='New File Conference';
                                                active:=TRUE;
                                                hidden:=FALSE;
                                                access:='';
                                          end;
                                          changed:=confedit(conf,ord(s[1])-64,tp1);
                                          if (changed) then begin
                                             removewindow(w2);
                                             lp:=firstlp;
                                             while (lp<>NIL) do begin
                                                 lp2:=lp^.n;
                                                 dispose(lp);
                                                 lp:=lp2;
                                             end;
                                             update:=TRUE;
                                          end;
                                          end;
                                          end;
                                          end;
                                          end;
             end;
         4:begin { delete }
                if (rt.data[1]<>-1) then begin
                   b:=rt.data[1];
                   if (b=1) then begin
                   displaybox('Cannot Delete Conference A!',3000);
                   end else begin
                   if pynqbox('Delete Conference '+chr(foundlist[b]+64)+'? ') then begin
                        case tp1 of
                                0:begin
                                        conf.msgconf[foundlist[b]].active:=FALSE;
                                        conf.msgconf[foundlist[b]].name:='';
                                        conf.msgconf[foundlist[b]].access:='';
                                        conf.msgconf[foundlist[b]].hidden:=FALSE;
                                        changed:=TRUE;
                                  end;
                                1:begin
                                        conf.fileconf[foundlist[b]].active:=FALSE;
                                        conf.fileconf[foundlist[b]].name:='';
                                        conf.fileconf[foundlist[b]].access:='';
                                        conf.fileconf[foundlist[b]].hidden:=FALSE;
                                        changed:=TRUE;
                                  end;
                        end;
                   end;
                   if pynqbox('Delete Conference Index also? ') then begin
                        case tp1 of
                                0:assign(f,adrv(systat.gfilepath)+'MCONF'+chr(foundlist[b]+64)+'.IDX');
                                1:assign(f,adrv(systat.gfilepath)+'FCONF'+chr(foundlist[b]+64)+'.IDX');
                        end;
                        {$I-} erase(f); {$I+}
                        if (ioresult<>0) then begin
                                displaybox('Error deleting Conference '+chr(foundlist[b]+64)+' index!',3000);
                        end;
                   end;
                   removewindow(w2);
                   lp:=firstlp;
                   while (lp<>NIL) do begin
                         lp2:=lp^.n;
                         dispose(lp);
                         lp:=lp2;
                   end;
                   update:=TRUE;
                   end;
                   end;
        end;
end;
if (changed) then begin
        {$I-} reset(conff); {$I+}
        if (ioresult<>0) then begin
                displaybox('Error Updating CONFS.DAT',3000);
        end else begin
        seek(conff,0);
        write(conff,conf);
        end;
end;
until (done);
listbox_tag:=TRUE;
listbox_move:=TRUE;
removewindow(w2);
lp:=firstlp;
while (lp<>NIL) do begin
         lp2:=lp^.n;
         dispose(lp);
         lp:=lp2;
end;
end;

end.
