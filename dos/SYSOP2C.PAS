(*****************************************************************************)
(*>                                                                         <*)
(*>  SYSOP2C .PAS -  Written by Eric Oman                                   <*)
(*>                                                                         <*)
(*>  SysOp functions: System Configuration Editor -- "C" command.           <*)
(*>                                                                         <*)
(*>                                                                         <*)
(*****************************************************************************)
{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R-,S+,V-}
unit sysop2c;

interface

uses
  crt, dos, myio, misc, procspec;

procedure poslsettings;

implementation

function qq(s:string):string;
var ss:string[22];
begin
  ss:=s;
  if (length(ss)<16) then ss:=mln(ss,16);
  qq:=ss;
end;

procedure poslsettings1;
var s2,s:acstring;
    choices:array[1..10] of string;
    current:integer;
    c:char;
    x:integer;
    abort,next,done:boolean;
begin
  done:=FALSE;
  choices[1]:='SysOp Access              :';
  choices[2]:='Co-SysOp Access           :';
  choices[3]:='Msg Sysop Access          :';
  choices[4]:='File SysOp Access         :';
  choices[5]:='SysOp Password at Logon   :';
  choices[6]:='Logon in Invisible Mode   :';
  choices[7]:='See Invisible Logins      :';
  choices[8]:='See Passwords Remotely    :';
  choices[9]:='Post Messages Publicly    :';
  choices[10]:='Post Netmail              :';
 setwindow(w,14,9,66,22,3,0,8,'Access Settings #1',TRUE);
 textcolor(7);
 textbackground(0);
 for x:=1 to 10 do begin
        gotoxy(2,x+1);
        write(choices[x]);
 end;
 with systat do begin
 gotoxy(30,2);
 textcolor(3);
 textbackground(0);
 write(mln(sop,20));
 gotoxy(30,3);
 write(mln(csop,20));
 gotoxy(30,4);
 write(mln(msop,20));
 gotoxy(30,5);
 write(mln(fsop,20));
 gotoxy(30,6);
 write(mln(spw,20));
 gotoxy(30,7);
 write(mln(loginvisible,20));
 gotoxy(30,8);
 write(mln(seeinvisible,20));
 gotoxy(30,9);
 write(mln(seepw,20));
 gotoxy(30,10);
 write(mln(normpubpost,20));
 gotoxy(30,11);
 write(mln(netmail,20));
 end;
 current:=1;
 repeat
 with systat do begin
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
                        #68:done:=TRUE;
                        #72:begin
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choices[current]);
                                dec(current);
                                if (current=0) then current:=10;
                            end;
                        #80:begin
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choices[current]);
                                inc(current);
                                if (current=11) then current:=1;
                            end;
                end;
           end;
       #13:begin
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choices[current]);
                gotoxy(28,current+1);
                textcolor(9);
                write('>');
                gotoxy(30,current+1);
                case current of
              1:s:=sop;           2:s:=csop;
              3:s:=msop;          4:s:=fsop;
              5:s:=spw;           6:s:=loginvisible;  7:s:=seeinvisible;
              8:s:=seepw;         9:s:=normpubpost;   10:s:=netmail;
                end;
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=TRUE;
                                        infield_numbers_only:=FALSE;
                                        infield_show_colors:=FALSE;
                                        infielde(s,20);
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                case current of
              1:s2:=sop;           2:s2:=csop;
              3:s2:=msop;          4:s2:=fsop;
              5:s2:=spw;           6:s2:=loginvisible;
              7:s2:=seeinvisible;  8:s2:=seepw;
              9:s2:=normpubpost;   10:s2:=netmail;
                end;
                                        if (s<>s2) then begin
                case current of
              1:sop:=s;           2:csop:=s;
              3:msop:=s;          4:fsop:=s;
              5:spw:=s;           6:loginvisible:=s;
              7:seeinvisible:=s;  8:seepw:=s;
              9:normpubpost:=s;   10:netmail:=s;
                end;

                                        end;

           end;
       #27:done:=TRUE;
 end;
 end;
 until (done);
 removewindow(w);
end;

procedure poslsettings2;
var s2,s:acstring;
    choices:array[1..8] of string;
    current:integer;
    c:char;
    x:integer;
    abort,next,done:boolean;
begin
  done:=FALSE;
  choices[1]:='Netmail Unlisted Zones    :';
 choices[2]:='No Nodelist Check         :';
 choices[3]:='Set Netmail Flags         :';
 choices[4]:='See Unvalidated Files     :';
 choices[5]:='No UL/DL Ratio            :';
 choices[6]:='No File Point Checking    :';
 choices[7]:='Uploads Auto-Credited     :';
 choices[8]:='Untag Mandatory Bases     :';
 setwindow(w,14,10,66,21,3,0,8,'Access Settings #2',TRUE);
 textcolor(7);
 textbackground(0);
 for x:=1 to 8 do begin
        gotoxy(2,x+1);
        write(choices[x]);
 end;
 with systat do begin
 gotoxy(30,2);
 textcolor(3);
 textbackground(0);
 write(mln(netmailoutofzone,20));
 gotoxy(30,3);
 write(mln(nonodelist,20));
 gotoxy(30,4);
 write(mln(setnetmailflags,20));
 gotoxy(30,5);
 write(mln(seeunval,20));
 gotoxy(30,6);
 write(mln(nodlratio,20));
 gotoxy(30,7);
 write(mln(nofilepts,20));
 gotoxy(30,8);
 write(mln(ulvalreq,20));
 gotoxy(30,9);
 write(mln(untagmandatory,20));
 end;
 current:=1;
 repeat
 with systat do begin
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
                        #72:begin
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choices[current]);
                                dec(current);
                                if (current=0) then current:=8;
                            end;
                        #80:begin
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choices[current]);
                                inc(current);
                                if (current=9) then current:=1;
                            end;
                end;
           end;
       #13:begin
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choices[current]);
                gotoxy(28,current+1);
                textcolor(9);
                write('>');
                gotoxy(30,current+1);
                case current of
              1:s:=netmailoutofzone; 2:s:=nonodelist;
              3:s:=setnetmailflags;
              4:s:=seeunval;      
              5:s:=nodlratio;     
              6:s:=nofilepts;     7:s:=ulvalreq;
              8:s:=untagmandatory;
                end;
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=TRUE;
                                        infield_numbers_only:=FALSE;
                                        infield_show_colors:=FALSE;
                                        infielde(s,20);
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                case current of
              1:s2:=netmailoutofzone; 2:s2:=nonodelist;
              3:s2:=setnetmailflags;
              4:s2:=seeunval;      
              5:s2:=nodlratio;     
              6:s2:=nofilepts;     7:s2:=ulvalreq;
              8:s2:=untagmandatory;
                end;
                                        if (s<>s2) then begin
                case current of
              1:netmailoutofzone:=s; 2:nonodelist:=s;
              3:setnetmailflags:=s;
              4:seeunval:=s;      
              5:nodlratio:=s;     
              6:nofilepts:=s;     7:ulvalreq:=s;
              8:untagmandatory:=s;
                end;

                                        end;

           end;
       #27:done:=TRUE;
 end;
 end;
 until (done);
 removewindow(w);
end;

procedure poslsettings;
var choices:array[1..2] of string[18];
    current:integer;
    c:char;
    w2:windowrec;
    done:boolean;
begin
done:=FALSE;
choices[1]:='Access Settings #1';
choices[2]:='Access Settings #2';
setwindow(w2,30,12,52,17,3,0,8,'Access Settings',TRUE);
textcolor(7);
textbackground(0);
for current:=1 to 2 do begin
        gotoxy(2,current+1);
        write(choices[current]);
end;
current:=1;
repeat
textcolor(15);
textbackground(1);
gotoxy(2,current+1);
write(choices[current]);
while not(keypressed) do begin timeslice; end;
c:=readkey;
case c of
        #0:begin
                c:=readkey;
                case c of
                        #72,#80:begin
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choices[current]);
                                if (current=1) then current:=2 else current:=1;
                            end;
                end;
           end;
      #13:begin
                case current of
                        1:begin
                                setwindow4(w2,30,12,52,17,8,0,8,'Access Settings','',TRUE);
                                poslsettings1;
                                setwindow5(w2,30,12,52,17,3,0,8,'Access Settings','',TRUE);
                                window(31,13,51,16);
                          end;
                        2:begin
                                setwindow4(w2,30,12,52,17,8,0,8,'Access Settings','',TRUE);
                                poslsettings2;
                                setwindow5(w2,30,12,52,17,3,0,8,'Access Settings','',TRUE);
                                window(31,13,51,16);
                          end;
                end;
          end;
     #27:done:=TRUE;
end;
until (done);
removewindow(w2);
end;

end.
