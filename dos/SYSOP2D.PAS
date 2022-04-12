(*****************************************************************************)
(*>                                                                         <*)
(*>  SYSOP2D .PAS -  Written by Eric Oman                                   <*)
(*>                                                                         <*)
(*>  SysOp functions: System Configuration Editor -- "D" command.           <*)
(*>                                                                         <*)
(*>                                                                         <*)
(*****************************************************************************)
{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R-,S+,V-}
unit sysop2d;

interface

uses
  crt, dos, inptmisc, myio, misc, procspec;

procedure pogenvar;

implementation

procedure pogenvar;
var s:string;
    c:char;
    current:integer;
    choice:array[1..15] of string;
    disp:array[1..15] of string;
    done,change:boolean;
begin
  done:=FALSE;
  choice[1]:='Maximum Feedback Sent Per Call   :';
  choice[2]:='Maximum Public Posts Per Call    :';
  choice[3]:='Maximum Chat Attempts Per Call   :';
  choice[4]:='Normal User Maximum Lines/Message:';
  choice[5]:='Co-Sysop Maximum Lines/Message   :';
  choice[6]:='Maximum Number Logon Attempts    :';
  choice[7]:='Keep Logs How Many Days          :';
  choice[8]:='Default Video Page Length        :';
  choice[9]:='System Caller Number             :';
  choice[10]:='Minimum Space For Posts          :';
  choice[11]:='New User Message Sent To User #  :';
  choice[12]:='Minutes Before Timeout Warning   :';
  choice[13]:='Minutes Before Timeout           :';
  choice[14]:='Sysop Chat Color                 :';
  choice[15]:='User Chat Color                  :';
  disp[1]:='Maximum Number of Feedback Messages a User May Send Per Call';
  disp[2]:='Maximum Number of Public Posts a User May Make Per Call';
  disp[3]:='Maximum Number of Times a User May Attempt to Chat Per Call';
  disp[4]:='Normal User''s Maximum Lines in a Message';
  disp[5]:='Co-Sysop''s Maximum Lines in a Message';
  disp[6]:='Maximum Number of Times a User May Attempt to Logon';
  disp[7]:='Number of Days to Keep System Logs';
  disp[8]:='Default Number of Lines for Users';
  disp[9]:='Current System Caller Number';
  disp[10]:='Minimum Drive Space in K to Allow Posting of Messages';
  disp[11]:='User # to Send New User Message To';
  disp[12]:='Number of Minutes of Inactivity Before Timeout Bell';
  disp[13]:='Number of Minutes of Inactivity Before Timeout';
  disp[14]:='Color Used for Sysop''s Text in Chat Mode';
  disp[15]:='Color Used for User''s Text in Chat Mode';
  setwindow(w,15,6,65,23,3,0,8,'System Variables',TRUE);
  textcolor(7);
  textbackground(0);
  gotoxy(2,2);
  write(choice[1]);
  gotoxy(2,3);
  write(choice[2]);
  gotoxy(2,4);
  write(choice[3]);
  gotoxy(2,5);
  write(choice[4]);
  gotoxy(2,6);
  write(choice[5]);
  gotoxy(2,7);
  write(choice[6]);
  gotoxy(2,8);
  write(choice[7]);
  gotoxy(2,9);
  write(choice[8]);
  gotoxy(2,10);
  write(choice[9]);
  gotoxy(2,11);
  write(choice[10]);
  gotoxy(2,12);
  write(choice[11]);
  gotoxy(2,13);
  write(choice[12]);
  gotoxy(2,14);
  write(choice[13]);
  gotoxy(2,15);
  write(choice[14]);
  gotoxy(2,16);
  write(choice[15]);
  textcolor(3);
  with systat do begin
  gotoxy(37,2);
  write(maxfback);
  gotoxy(37,3);
  write(maxpubpost);
  gotoxy(37,4);
  write(maxchat);
  gotoxy(37,5);
  write(maxlines);
  gotoxy(37,6);
  write(csmaxlines);
  gotoxy(37,7);
  write(maxlogontries);
  gotoxy(37,8);
  write(backsysoplogs);
  gotoxy(37,9);
  write(pagelen);
  gotoxy(37,10);
  write(syst.callernum);
  gotoxy(37,11);
  write(minspaceforpost);
  gotoxy(37,12);
  write(aonoff(trunc(newapp)<>0,cstr(trunc(newapp)),'Off'));
  gotoxy(37,13);
  write(timeoutbell);
  gotoxy(37,14);
  write(timeout);
  gotoxy(37,15);
  textattr:=sysopcolor;
  write('SYSOP');
  gotoxy(37,16);
  textattr:=usercolor;
  write('USER');
  current:=1;
  cursoron(FALSE);
  repeat
    with systat do begin
    window(1,1,80,25);    
    textcolor(14);
    textbackground(0);
    gotoxy(1,25);
    clreol;
    cwrite('%140%Esc%070%=Exit %140%'+disp[current]);
    window(16,7,64,22);
    gotoxy(2,current+1);
    textcolor(15);
    textbackground(1);
    write(choice[current]);
    while not(keypressed) do begin timeslice; end;
    c:=readkey;
    case c of
        #0:begin
                c:=readkey;
                checkkey(c);
                case c of
                        #68:done:=TRUE;
                        #72:begin       { Up Arrow }
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choice[current]);
                                dec(current);
                                if (current<1) then current:=15;
                                window(1,1,80,25);
                                gotoxy(1,25);
                                textcolor(7);
                                textbackground(0);
                                clreol;
                                window(16,7,64,22);
                        end;
                        #80:begin       { Down Arrow }
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choice[current]);
                                inc(current);
                                if (current>15) then current:=1;
                                window(1,1,80,25);
                                gotoxy(1,25);
                                textcolor(7);
                                textbackground(0);
                                clreol;
                                window(16,7,64,22);
                        end;
                end;
                end;
                #13:begin
                                case current of
                                        1:begin
                                          s:=cstr(trunc(maxfback));
                                          infield_inp_fgrd:=15;
                                          infield_inp_bkgd:=1;
                                          infield_out_fgrd:=3;
                                          infield_out_bkgd:=0;
                                          infield_allcaps:=false;
                                          infield_numbers_only:=TRUE;
                                          gotoxy(2,current+1);
                                          textcolor(7);
                                          textbackground(0);
                                          write(choice[current]);
                                          gotoxy(35,current+1);
                                          textcolor(9);
                                          textbackground(0);
                                          write('>');
                                          gotoxy(37,current+1);
                                          infielde(s,3);
                                          if ((s<>'') and (s<>cstr(trunc(maxfback)))) then begin
                                                maxfback:=value(s);
                                                end;
                                        end;
                                        2:begin
                                          s:=cstr(trunc(maxpubpost));
                                          infield_inp_fgrd:=15;
                                          infield_inp_bkgd:=1;
                                          infield_out_fgrd:=3;
                                          infield_out_bkgd:=0;
                                          infield_allcaps:=false;
                                          infield_numbers_only:=TRUE;
                                          gotoxy(2,current+1);
                                          textcolor(7);
                                          textbackground(0);
                                          write(choice[current]);
                                          gotoxy(35,current+1);
                                          textcolor(9);
                                          textbackground(0);
                                          write('>');
                                          gotoxy(37,current+1);
                                          infielde(s,3);
                                          if ((s<>'') and (s<>cstr(trunc(maxpubpost)))) then begin
                                                maxpubpost:=value(s);
                                                end;
                                        end;
                                        3:begin
                                          s:=cstr(trunc(maxchat));
                                          infield_inp_fgrd:=15;
                                          infield_inp_bkgd:=1;
                                          infield_out_fgrd:=3;
                                          infield_out_bkgd:=0;
                                          infield_allcaps:=false;
                                          infield_numbers_only:=TRUE;
                                          gotoxy(2,current+1);
                                          textcolor(7);
                                          textbackground(0);
                                          write(choice[current]);
                                          gotoxy(35,current+1);
                                          textcolor(9);
                                          textbackground(0);
                                          write('>');
                                          gotoxy(37,current+1);
                                          infielde(s,3);
                                          if ((s<>'') and (s<>cstr(trunc(maxchat)))) then begin
                                                maxchat:=value(s);
                                                
                                                end;
                                        end;
                                        4:begin
                                          s:=cstr(trunc(maxlines));
                                          infield_inp_fgrd:=15;
                                          infield_inp_bkgd:=1;
                                          infield_out_fgrd:=3;
                                          infield_out_bkgd:=0;
                                          infield_allcaps:=false;
                                          infield_numbers_only:=TRUE;
                                          gotoxy(2,current+1);
                                          textcolor(7);
                                          textbackground(0);
                                          write(choice[current]);
                                          gotoxy(35,current+1);
                                          textcolor(9);
                                          textbackground(0);
                                          write('>');
                                          gotoxy(37,current+1);
                                          infielde(s,3);
                                          if ((s<>'') and (s<>cstr(trunc(maxlines)))) then begin
                                                maxlines:=value(s);
                                                if (maxlines>160) then maxlines:=160;
                                                
                                                end;
                                        end;
                                        5:begin
                                          s:=cstr(trunc(csmaxlines));
                                          infield_inp_fgrd:=15;
                                          infield_inp_bkgd:=1;
                                          infield_out_fgrd:=3;
                                          infield_out_bkgd:=0;
                                          infield_allcaps:=false;
                                          infield_numbers_only:=TRUE;
                                          gotoxy(2,current+1);
                                          textcolor(7);
                                          textbackground(0);
                                          write(choice[current]);
                                          gotoxy(35,current+1);
                                          textcolor(9);
                                          textbackground(0);
                                          write('>');
                                          gotoxy(37,current+1);
                                          infielde(s,3);
                                          if ((s<>'') and (s<>cstr(trunc(csmaxlines)))) then begin
                                                csmaxlines:=value(s);
                                                if (csmaxlines>160) then csmaxlines:=160;
                                                
                                                end;
                                        end;
                                        6:begin
                                          s:=cstr(trunc(maxlogontries));
                                          infield_inp_fgrd:=15;
                                          infield_inp_bkgd:=1;
                                          infield_out_fgrd:=3;
                                          infield_out_bkgd:=0;
                                          infield_allcaps:=false;
                                          infield_numbers_only:=TRUE;
                                          gotoxy(2,current+1);
                                          textcolor(7);
                                          textbackground(0);
                                          write(choice[current]);
                                          gotoxy(35,current+1);
                                          textcolor(9);
                                          textbackground(0);
                                          write('>');
                                          gotoxy(37,current+1);
                                          infielde(s,3);
                                          if ((s<>'') and (s<>cstr(trunc(maxlogontries)))) then begin
                                                maxlogontries:=value(s);
                                                
                                                end;
                                        end;
                                        7:begin
                                          s:=cstr(trunc(backsysoplogs));
                                          infield_inp_fgrd:=15;
                                          infield_inp_bkgd:=1;
                                          infield_out_fgrd:=3;
                                          infield_out_bkgd:=0;
                                          infield_allcaps:=false;
                                          infield_numbers_only:=TRUE;
                                          gotoxy(2,current+1);
                                          textcolor(7);
                                          textbackground(0);
                                          write(choice[current]);
                                          gotoxy(35,current+1);
                                          textcolor(9);
                                          textbackground(0);
                                          write('>');
                                          gotoxy(37,current+1);
                                          infielde(s,3);
                                          if ((s<>'') and (s<>cstr(trunc(backsysoplogs)))) then begin
                                                backsysoplogs:=value(s);
                                                
                                                end;
                                        end;
                                        8:begin
                                          s:=cstr(trunc(pagelen));
                                          infield_inp_fgrd:=15;
                                          infield_inp_bkgd:=1;
                                          infield_out_fgrd:=3;
                                          infield_out_bkgd:=0;
                                          infield_allcaps:=false;
                                          infield_numbers_only:=TRUE;
                                          gotoxy(2,current+1);
                                          textcolor(7);
                                          textbackground(0);
                                          write(choice[current]);
                                          gotoxy(35,current+1);
                                          textcolor(9);
                                          textbackground(0);
                                          write('>');
                                          gotoxy(37,current+1);
                                          infielde(s,3);
                                          if ((s<>'') and (s<>cstr(trunc(pagelen)))) then begin
                                                pagelen:=value(s);
                                                if (pagelen<4) then pagelen:=4;
                                                if (pagelen>50) then pagelen:=50;
                                                
                                                end;
                                        end;
                                        9:begin
                                          s:=cstr(trunc(syst.callernum));
                                          infield_inp_fgrd:=15;
                                          infield_inp_bkgd:=1;
                                          infield_out_fgrd:=3;
                                          infield_out_bkgd:=0;
                                          infield_allcaps:=false;
                                          infield_numbers_only:=TRUE;
                                          gotoxy(2,current+1);
                                          textcolor(7);
                                          textbackground(0);
                                          write(choice[current]);
                                          gotoxy(35,current+1);
                                          textcolor(9);
                                          textbackground(0);
                                          write('>');
                                          gotoxy(37,current+1);
                                          infielde(s,6);
                                          if ((s<>'') and (s<>cstr(trunc(syst.callernum)))) then begin
                                                syst.callernum:=value(s);
                                                
                                                end;
                                        end;
                                        10:begin
                                          s:=cstr(trunc(minspaceforpost));
                                          infield_inp_fgrd:=15;
                                          infield_inp_bkgd:=1;
                                          infield_out_fgrd:=3;
                                          infield_out_bkgd:=0;
                                          infield_allcaps:=false;
                                          infield_numbers_only:=TRUE;
                                          gotoxy(2,current+1);
                                          textcolor(7);
                                          textbackground(0);
                                          write(choice[current]);
                                          gotoxy(35,current+1);
                                          textcolor(9);
                                          textbackground(0);
                                          write('>');
                                          gotoxy(37,current+1);
                                          infielde(s,5);
                                          if ((s<>'') and (s<>cstr(trunc(minspaceforpost)))) then begin
                                                if (value(s)>32767) then minspaceforpost:=32767 else
                                                minspaceforpost:=value(s);
                                                
                                                end;
                                        end;
                                        11:begin
                                if (newapp=0) then s:='1' else s:=cstr(newapp);
                                window(1,1,80,25);
                                gotoxy(1,25);
                                textcolor(14);
                                textbackground(0);
                                clreol;
                                write('F2');
                                textcolor(7);
                                write('=None ');
                                window(16,7,64,22);
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
                                infield_func_keys_allowed:=chr(60);
                                          gotoxy(2,current+1);
                                          textcolor(7);
                                          textbackground(0);
                                          write(choice[current]);
                                          gotoxy(35,current+1);
                                          textcolor(9);
                                          textbackground(0);
                                          write('>');
                                          gotoxy(37,current+1);
                                          write('        ');
                                          gotoxy(37,current+1);
                                infielde(s,5);
                                infield_func_keys:=FALSE;
                                infield_func_keys_allowed:='';
                                infield_min_value:=-1;
                                infield_max_value:=-1;
                                if (s='') then begin
                                        case infield_func_key_pressed of
                                                #0:begin
                                                if (value(s)<>newapp) and (value(s)<=32767) and
                                                (value(s)>=0) then begin
                                                        newapp:=value(s);
                                                end;
                                                end;
                                                chr(60):begin
                                                        newapp:=0;
                                                end;
                                      end;
                                      infield_func_key_pressed:=#0;
                                end else begin
                                if (value(s)<>newapp) and (value(s)<=32767) and
                                (value(s)>=0) then begin
                                        newapp:=value(s);
                                end;
                                end;
                                                gotoxy(37,12);
                                                textcolor(3);
                                                textbackground(0);
                                                write(aonoff(trunc(newapp)<>0,cstr(trunc(newapp)),'Off'));
                                        end;
                                        12:begin
                                          s:=cstr(trunc(timeoutbell));
                                          infield_inp_fgrd:=15;
                                          infield_inp_bkgd:=1;
                                          infield_out_fgrd:=3;
                                          infield_out_bkgd:=0;
                                          infield_allcaps:=false;
                                          infield_numbers_only:=TRUE;
                                          gotoxy(2,current+1);
                                          textcolor(7);
                                          textbackground(0);
                                          write(choice[current]);
                                          gotoxy(35,current+1);
                                          textcolor(9);
                                          textbackground(0);
                                          write('>');
                                          gotoxy(37,current+1);
                                          infielde(s,3);
                                          if ((s<>'') and (s<>cstr(trunc(timeoutbell)))) then begin
                                                timeoutbell:=value(s);
                                                
                                                end;
                                        end;
                                        13:begin
                                          s:=cstr(trunc(timeout));
                                          infield_inp_fgrd:=15;
                                          infield_inp_bkgd:=1;
                                          infield_out_fgrd:=3;
                                          infield_out_bkgd:=0;
                                          infield_allcaps:=false;
                                          infield_numbers_only:=TRUE;
                                          gotoxy(2,current+1);
                                          textcolor(7);
                                          textbackground(0);
                                          write(choice[current]);
                                          gotoxy(35,current+1);
                                          textcolor(9);
                                          textbackground(0);
                                          write('>');
                                          gotoxy(37,current+1);
                                          infielde(s,3);
                                          if ((s<>'') and (s<>cstr(trunc(timeout)))) then begin
                                                timeout:=value(s);
                                                
                                                end;
                                        end;
                                        14:begin
                                          sysopcolor:=getcolor(3,8,sysopcolor,'This is '+systat.sysopname+'...');
                                          gotoxy(37,15);
                                          textattr:=sysopcolor;
                                          write('SYSOP');
                                        end;
                                        15:begin
                                          usercolor:=getcolor(3,8,usercolor,'Hello, '+systat.sysopname+'!');
                                          gotoxy(37,16);
                                          textattr:=usercolor;
                                          write('USER');
                                        end;

                                end;
                end;
                #27:done:=TRUE;
                end;
    end;
    until(done);
    removewindow(w);
end;
end;

end.
