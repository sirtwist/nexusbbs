(*****************************************************************************)
(*>                                                                         <*)
(*>  SYSOP2E .PAS -  Written by Eric Oman                                   <*)
(*>                                                                         <*)
(*>  SysOp functions: System Configuration Editor -- "E" command.           <*)
(*>                                                                         <*)
(*****************************************************************************)
{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R-,S+,V-}
unit sysop2e;

interface

uses
  crt, dos, myio, misc,procspec;

procedure poflagfunc;

implementation

procedure poflagfunc;
  var d:boolean;
      current,x:integer;
      choice:array[1..14] of string[27];
      desc:array[1..14] of string[70];
      s:string;
      c:char;
      
  
  function currentflag(x:integer):boolean;
  begin
  with systat do
  case x of
        1:currentflag:=allowalias;
        2:currentflag:=aliasprimary;
        3:currentflag:=phonepw;
        4:currentflag:=localsec;
        5:currentflag:=localscreensec;
        6:currentflag:=globaltrap;
        7:currentflag:=autochatopen;
        8:currentflag:=useextchat;
        9:currentflag:=usebios;
        10:currentflag:=cgasnow;
        11:currentflag:=timeoutlocal;
        12:currentflag:=showlocaloutput;
        13:currentflag:=showlocaloutput2;
        14:currentflag:=allowiemsi;
  end;
  end;

  procedure toggleflag(x:integer);
  begin
  with systat do
  case x of
        1:allowalias:=not(allowalias);
        2:aliasprimary:=not(aliasprimary);
        3:phonepw:=not(phonepw);
        4:localsec:=not(localsec);
        5:localscreensec:=not(localscreensec);
        6:globaltrap:=not(globaltrap);
        7:autochatopen:=not(autochatopen);
        8:useextchat:=not(useextchat);
        9:begin
                usebios:=not(usebios);
                directvideo:=not(usebios);
        end;
        10:begin
                cgasnow:=not(cgasnow);
                checksnow:=cgasnow;
        end;
        11:timeoutlocal:=not(timeoutlocal);
        12:showlocaloutput:=not(showlocaloutput);
        13:showlocaloutput2:=not(showlocaloutput2);
        14:allowiemsi:=not(allowiemsi);
  end;
  end;

  
  begin
  d:=FALSE;
  setwindow(w,20,6,60,23,3,0,8,'System Settings Flags',TRUE);
  cursoron(false);
  choice[1]:='Aliases Allowed On System :';
  choice[2]:='Alias Is Primary Name     :';
  choice[3]:='Phone Number In Logon     :';
  choice[4]:='Local Security Protection :';
  choice[5]:='Local Screen Security     :';
  choice[6]:='Global Activity Trapping  :';
  choice[7]:='Automatically Log Chats   :';
  choice[8]:='Use External Chat Program :';
  choice[9]:='Use BIOS Video Output     :';
  choice[10]:='Suppress Snow for CGA     :';
  choice[11]:='Timeout in Local Logins   :';
  choice[12]:='Show Output for Protocols :';
  choice[13]:='Show Output for Archivers :';
  choice[14]:='Allow IEMSI Session Logon :';
   desc[1]:='Ask new users for an Alias?                           ';
   desc[2]:='Use Alias as the user''s primary name on the BBS?     ';
   desc[3]:='Prompt user for last 4 digits of phone number at logon';
   desc[4]:='Should Nexus prompt Local Users for their password?   ';
   desc[5]:='Should Nexus display passwords locally?               ';
   desc[6]:='Globally Trap all activity of Nexus (UNUSED)          ';
   desc[7]:='Automatically Log all Chat activity?                  ';
   desc[8]:='Use the external Chat program instead of internal     ';
   desc[9]:='Use BIOS video output instead of Direct Screen writes?';
  desc[10]:='Suppress snow on CGA equipped systems?                ';
  desc[11]:='Use system timeout information for local logins?      ';
  desc[12]:='Show screen output when running protocols?            ';
  desc[13]:='Show screen output when running archivers?            ';
  desc[14]:='Allow users to log on with IEMSI?                     ';
  for x:=1 to 14 do begin
                textcolor(7);
                textbackground(0);
                gotoxy(2,x+1);
                write(choice[x]);
                gotoxy(30,x+1);
                textcolor(3);
                write(syn(currentflag(x)));
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
        clreol;
        write('Esc');
        textcolor(7);
        write('=Exit ');
        textcolor(14);
        write(desc[current]);
        window(21,7,59,22);
        while not(keypressed) do begin timeslice; end;
        c:=readkey;
        case c of
                #0:begin
                        c:=readkey;
                        checkkey(c);
                        case c of
                                #68:d:=TRUE;
                                #72:begin { Up Arrow }
                                        gotoxy(2,current+1);
                                        textcolor(7);
                                        textbackground(0);
                                        write(choice[current]);
                                        dec(current);
                                        if (current=0) then current:=14;
                                end;
                                #80:begin { Down Arrow }
                                        gotoxy(2,current+1);
                                        textcolor(7);
                                        textbackground(0);
                                        write(choice[current]);
                                        inc(current);
                                        if (current=15) then current:=1;
                                end;
                        end;
                end;
                #13:begin
                        if (current=2) then begin
                                if (systat.allowalias) then toggleflag(current);
                        end else
                        toggleflag(current);
                        gotoxy(30,current+1);
                        textcolor(3);
                        textbackground(0);
                        write(syn(currentflag(current)));
                    end;
                #27:d:=true;
            end;
  until (d);
  removewindow(w);
end;

end.
