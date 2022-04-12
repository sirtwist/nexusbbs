(*****************************************************************************)
(*>                                                                         <*)
(*>  SYSOP2H .PAS -  Written by Eric Oman                                   <*)
(*>                                                                         <*)
(*>  SysOp functions: System Configuration Editor -- "H" command.           <*)
(*>                                                                         <*)
(*>                                                                         <*)
(*****************************************************************************)
{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R+,S+,V-}
unit sysop2h;

interface

uses
  crt, dos, myio, procspec,
  misc;

procedure pomisc1(notfound:boolean);
procedure pomisc2(notfound:boolean);
procedure nxsetupstuff;

implementation

var nxchanged:boolean;

procedure pomisc1(notfound:boolean);
var 
  s       : string;
  desc    : array[1..15] of string;
  disp    : array[1..15] of string;
  c       : char;
  current,
  x       : integer;
  done,
  changed : boolean;

begin
  done:=FALSE;
  desc[1] := 'Data Files         :';
  desc[2] := 'Display Files      :';
  desc[3] := 'Message Tags/Info  :';
  desc[4] := 'Menu Files         :';
  desc[5] := 'Nexus File Database:';
  desc[6] := 'Utility Programs   :';
  desc[7] := 'Semaphore Files    :';
  desc[8] := 'FileRequest Holding:';
  desc[9] := 'System Logs        :';
  desc[10] := 'Temp. Work Files   :';
  desc[11] := 'Swap To Disk       :';
  desc[12] := 'Nexecutable        :';
  desc[13] := 'Netmail            :';
(*  desc[14]:='RESERVED   :';
  desc[15]:='RESERVED   :'; *)
  disp[1] := 'Data directory where system data files are stored';
  disp[2] := 'Display directory where your .ANS and .TXT files are stored';
  disp[3] := 'Message directory where your message tags and info are stored';
  disp[4] := 'Menu directory where your menu files (.MNU) are stored';
  disp[5] := 'Nexus File Database <tm> directory';
  disp[6] := 'Utility programs directory where Nexus utilities are stored';
  disp[7] := 'Semaphore directory where Nexus and utilities write semaphores';
  disp[8] := 'Directory where Nexus will move offline files when requested';
  disp[9] := 'System log directory where Nexus and utilities will write logs';
  disp[10] := 'Temp. work directory where Nexus writes temp. files';
  disp[11] := 'Swap directory where Nexus writes swap files on shell';
  disp[12] := 'Directory where your Nexecutable files are located';
  disp[13] := 'Netmail directory for nxEMAIL to find incoming netmail';
  disp[14] := 'RESERVED for Future Expansion';
  disp[15] := 'RESERVED for Future Expansion';
{$IFNDEF LINUX}
  setwindow(w,2,7,78,23,3,0,8,'Directory Configuration',TRUE);
{$ENDIF}
  textcolor(7);
  textbackground(0);
  for x:=1 to 13 do begin
    gotoxy(2,x+1);
    write(desc[x]);
  end;
  with systat do begin
    gotoxy(23,2);
    textcolor(3);
    textbackground(0);
    write(copy(gfilepath,1,50));
    gotoxy(23,3);
    write(copy(afilepath,1,50));
    gotoxy(23,4);
    write(copy(userpath,1,50));
    gotoxy(23,5);
    write(copy(menupath,1,50));
    gotoxy(23,6);
    write(copy(filepath,1,50));
    gotoxy(23,7);
    write(copy(utilpath,1,50));
    gotoxy(23,8);
    write(copy(semaphorepath,1,50));
    gotoxy(23,9);
    write(copy(filereqpath,1,50));
    gotoxy(23,10);
    write(copy(trappath,1,50));
    gotoxy(23,11);
    write(copy(temppath,1,50));
    gotoxy(23,12);
    write(copy(swappath,1,50));
    gotoxy(23,13);
    write(copy(nexecutepath,1,50));
    gotoxy(23,14);
    write(copy(netmailpath,1,50));
    current:=1;
    repeat
      window(1,1,80,25);
      gotoxy(1,25);
      textcolor(14);
      textbackground(0);
      clreol;
      gotoxy(1,25);
      cwrite('%140%Esc%070%=Exit %140%'+disp[current]);
      window(3,8,77,22);
      gotoxy(2,1+current);  
      textcolor(15);
      textbackground(1);
      write(desc[current]);
  // while not(keypressed) do begin timeslice; end;
{$IFNDEF LINUX}
      repeat until keypressed;
      c:=readkey;
      case c of
        #0 : begin
               c:=readkey;
               checkkey(c);
               case c of
                 #68 : done:=TRUE;
                 #72 : begin
                         gotoxy(2,1+current);
                         textcolor(7);
                         textbackground(0);
                         write(desc[current]);
                         dec(current);
                         if (current=0) then 
		           current:=13;
		       end;
                 #80 : begin
                         gotoxy(2,1+current);
                         textcolor(7);
                         textbackground(0);
                         write(desc[current]);
                         inc(current);
                         if (current=14) then 
		           current:=1;
                       end;
               end;
             end;
       #13 : begin
               case current of
                 1:s:=gfilepath;
                 2:s:=afilepath;
                 3:s:=userpath;
                 4:s:=menupath;
                 5:s:=filepath;
                 6:s:=utilpath;
                 7:s:=semaphorepath;
                 8:s:=filereqpath;
                 9:s:=trappath;
                 10:s:=temppath;
                 11:s:=swappath;
                 12:s:=nexecutepath;
                 13:s:=netmailpath;
               end;
               infield_inp_fgrd:=15;
               infield_inp_bkgd:=1;
               infield_out_fgrd:=3;
               infield_out_bkgd:=0;
               infield_allcaps:=TRUE;
               infield_numbers_only:=false;
               infield_putatend:=TRUE;
               infield_clear:=TRUE;
               infield_insert:=TRUE;
               infield_put_slash:=TRUE;
               infield_address:=false;
               gotoxy(2,current+1);
               textcolor(7);
               textbackground(0);
               write(desc[current]);
               gotoxy(21,current+1);
               textcolor(9);
               textbackground(0);
               write('>');
               gotoxy(23,current+1);
               infielde(s,50);
               infield_putatend:=FALSE;
               infield_clear:=FALSE;
               infield_insert:=FALSE;
               infield_put_slash:=FALSE;
               case current of
                 1:gfilepath:=s;
                 2:afilepath:=s;
                 3:userpath:=s;
                 4:menupath:=s;
                 5:filepath:=s;
                 6:utilpath:=s;
                 7:semaphorepath:=s;
                 8:filereqpath:=s;
                 9:trappath:=s;
                 10:temppath:=s;
                 11:swappath:=s;
                 12:nexecutepath:=s;
                 13:netmailpath:=s;
               end;
             end;
        #27 : done := TRUE;
      end;
    until (done);
    removewindow(w);
{$ELSE}  // ************* Linux ONLY! *************************** //
      repeat until keypressed;
      c:=readkey;
      case upcase(c) of
        #27 : Done := true;
 
        'P' : begin
                gotoxy(2, 1 + Current);
                textcolor(7);
                textbackground(0);
                write(desc[Current]);
                dec(current);
                if(current = 0) then
                  current := 13;
              end;
        'N' : begin
                gotoxy(2,1+current);
                textcolor(7);
                textbackground(0);
                write(desc[current]);
                inc(current);
                if (current=14) then
                  current:=1;
              end;
       #13 :  begin
                case current of
                  1:s:=gfilepath;
                  2:s:=afilepath;
                  3:s:=userpath;
                  4:s:=menupath;
                  5:s:=filepath;
                  6:s:=utilpath;
                  7:s:=semaphorepath;
                  8:s:=filereqpath;
                  9:s:=trappath;
                  10:s:=temppath;
                  11:s:=swappath;
                  12:s:=nexecutepath;
                  13:s:=netmailpath;
                end;
                infield_inp_fgrd:=15;
                infield_inp_bkgd:=1;
                infield_out_fgrd:=3;
                infield_out_bkgd:=0;
                infield_allcaps:=TRUE;
                infield_numbers_only:=false;
                infield_putatend:=TRUE;
                infield_clear:=TRUE;
                infield_insert:=TRUE;
                infield_put_slash:=TRUE;
                infield_address:=false;
                gotoxy(2,current+1);
                textcolor(7);
                textbackground(0);
                write(desc[current]);
                gotoxy(21,current+1);
                textcolor(9);
                textbackground(0);
                write('>');
                gotoxy(23,current+1);
                infielde(s,50);
                infield_putatend:=FALSE;
                infield_clear:=FALSE;
                infield_insert:=FALSE;
                infield_put_slash:=FALSE;
                case current of
                  1:gfilepath:=s;
                  2:afilepath:=s;
                  3:userpath:=s;
                  4:menupath:=s;
                  5:filepath:=s;
                  6:utilpath:=s;
                  7:semaphorepath:=s;
                  8:filereqpath:=s;
                  9:trappath:=s;
                  10:temppath:=s;
                  11:swappath:=s;
                  12:nexecutepath:=s;
                  13:netmailpath:=s;
                end;
              end;
      end;
{$ENDIF}
    until (done);
    removewindow(w);
writeln('************************** done *************************');

  end;
end;

procedure pomisc2(notfound:boolean);
var s:string;
    desc:array[1..3] of string;
    disp:array[1..3] of string;
    c:char;
    current,x:integer;
    done,changed:boolean;

begin
  done:=FALSE;
  desc[1]:='After Upload       :';
  desc[2]:='File Manager       :';
  desc[3]:='Offline Mail Setup :';
  disp[1]:='After Upload External Program (full path and filename)';
  disp[2]:='File Base Manager (full path and filename)';
  disp[3]:='Offline Mail Setup (full path and filename)';
  setwindow(w,6,10,74,16,3,0,8,'Filename Configuration',TRUE);
  textcolor(7);
  textbackground(0);
  for x:=1 to 3 do begin
  gotoxy(2,x+1);
  write(desc[x]);
  end;
  with systat do begin
  gotoxy(23,2);
  textcolor(3);
  textbackground(0);
  write(copy(extuploadpath,1,40));
  gotoxy(23,3);
  write(copy(nxset.fbmgr,1,40));
  gotoxy(23,4);
  write(copy(nxset.ommgr,1,40));
  current:=1;
  repeat
  window(1,1,80,25);
  gotoxy(1,25);
  textcolor(14);
  textbackground(0);
  clreol;
  gotoxy(1,25);
  cwrite('%140%Esc%070%=Exit %140%'+disp[current]);
  window(1,1,80,25);
  gotoxy(2,1+current);  
  textcolor(15);
  textbackground(1);
  write(desc[current]);
  while not(keypressed) do begin timeslice; end;
  c:=readkey;
  case c of
        #0:begin
                c:=readkey;
                checkkey(c);
                case c of
                        #72:begin
                                gotoxy(2,1+current);
                                textcolor(7);
                                textbackground(0);
                                write(desc[current]);
                                dec(current);
                                if (current=0) then current:=3;
                        end;
                        #80:begin
                                gotoxy(2,1+current);
                                textcolor(7);
                                textbackground(0);
                                write(desc[current]);
                                inc(current);
                                if (current=4) then current:=1;
                        end;
                end;
        end;
        #13:begin
                case current of
                        1:s:=extuploadpath;
                        2:s:=nxset.fbmgr;
                        3:s:=nxset.ommgr;
                end;
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
                                write(desc[current]);
                                gotoxy(21,current+1);
                                textcolor(9);
                                textbackground(0);
                                write('>');
                                gotoxy(23,current+1);
                                infield_maxshow:=40;
                                infielde(s,79);
                                infield_maxshow:=0;
                                case current of
                        1:extuploadpath:=s;
                        2:if (s<>nxset.fbmgr) then begin
                                nxset.fbmgr:=s;
                                changed:=TRUE;
                          end;
                        3:if (s<>nxset.ommgr) then begin
                                nxset.ommgr:=s;
                                changed:=TRUE;
                          end;
                        end;
                end;
        #27:done:=TRUE;
  end;
  until (done);
  if (changed) then begin
        {$I-} reset(nxsetf); {$I+}
        if (ioresult<>0) then begin
                displaybox('Error updating NXSETUP.DAT',3000);
                exit;
        end;
        write(nxsetf,nxset);
        close(nxsetf);
  end;
  removewindow(w);
  end;
end;

procedure pomisc3(notfound:boolean);
var s:string;
    desc:array[1..10] of string;
    c:char;
    current,x:integer;
    done:boolean;

        procedure getspeckey(b:byte);
        var w2:windowrec;
            ch:array[1..2] of string[20];
            c2:char;
            s:string;
            cur:integer;
            d2:boolean;
        begin
        d2:=FALSE;
        ch[1]:='Description   :';
        ch[2]:='Path/Filename :';
        s:='Alt-F'+cstr(b);
        setwindow(w2,2,12,78,17,3,0,8,'Special Key: '+s,TRUE);
        textcolor(7);
        textbackground(0);
        for cur:=1 to 2 do begin
                gotoxy(2,cur+1);
                write(ch[cur]);
        end;
        textcolor(3);
        textbackground(0);
        gotoxy(18,2);
        cwrite(mln(nxset.speckey[b].name,40));
        textcolor(3);
        textbackground(0);
        gotoxy(18,3);
        cwrite(mln(nxset.speckey[b].path,50));
        cur:=1;
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
                                #72,#80:begin
                                        gotoxy(2,cur+1);
                                        textcolor(7);
                                        textbackground(0);
                                        write(ch[cur]);
                                        if (cur=1) then cur:=2 else cur:=1;
                                    end;
                        end;
                   end;
               #13:begin
                    case cur of
                    1:begin
                        gotoxy(2,cur+1);
                        textcolor(7);
                        textbackground(0);
                        write(ch[cur]);
                                infield_inp_fgrd:=15;
                                infield_inp_bkgd:=1;
                                infield_out_fgrd:=3;
                                infield_out_bkgd:=0;
                                infield_allcaps:=FALSE;
                                infield_numbers_only:=false;
                                infield_putatend:=FALSE;
                                infield_show_colors:=TRUE;
                                infield_clear:=FALSE;
                                infield_insert:=TRUE;
                                infield_put_slash:=FALSE;
                                infield_address:=false;
                                gotoxy(16,cur+1);
                                textcolor(9);
                                textbackground(0);
                                write('>');
                                gotoxy(18,cur+1);
                                s:=nxset.speckey[b].name;
                                infielde(s,50);
                                infield_putatend:=FALSE;
                                infield_clear:=FALSE;
                                infield_insert:=FALSE;
                                infield_put_slash:=FALSE;
                                if (s<>nxset.speckey[b].name) then
                                nxset.speckey[b].name:=s;
                             end;
                           2:begin
                        gotoxy(2,cur+1);
                        textcolor(7);
                        textbackground(0);
                        write(ch[cur]);
                                infield_inp_fgrd:=15;
                                infield_inp_bkgd:=1;
                                infield_out_fgrd:=3;
                                infield_out_bkgd:=0;
                                infield_allcaps:=FALSE;
                                infield_numbers_only:=false;
                                infield_putatend:=TRUE;
                                infield_clear:=TRUE;
                                infield_insert:=TRUE;
                                infield_put_slash:=FALSE;
                                infield_address:=false;
                                infield_maxshow:=50;
                                gotoxy(16,cur+1);
                                textcolor(9);
                                textbackground(0);
                                write('>');
                                gotoxy(18,cur+1);
                                s:=nxset.speckey[b].path;
                                infielde(s,79);
                                infield_putatend:=FALSE;
                                infield_clear:=FALSE;
                                infield_insert:=FALSE;
                                infield_put_slash:=FALSE;
                                if (s<>nxset.speckey[b].path) then begin
                                        nxset.speckey[b].path:=s;
                                        nxchanged:=TRUE;
                                end;
                           end;
                       end;
                   end;
               #27:d2:=TRUE;
        end;
        until (d2);
        removewindow(w2);
        end;


begin
  done:=FALSE;
  desc[1]:='Alt-F1 :';
  desc[2]:='Alt-F2 :';
  desc[3]:='Alt-F3 :';
  desc[4]:='Alt-F4 :';
  desc[5]:='Alt-F5 :';
  desc[6]:='Alt-F6 :';
  desc[7]:='Alt-F7 :';
  desc[8]:='Alt-F8 :';
  desc[9]:='Alt-F9 :';
  desc[10]:='Alt-F10:';
  setwindow(w,11,8,69,21,3,0,8,'Special Function Keys',TRUE);
  textcolor(7);
  textbackground(0);
  for x:=1 to 10 do begin
  gotoxy(2,x+1);
  write(desc[x]);
  end;
  current:=1;
  repeat
  for x:=1 to 10 do begin
  gotoxy(11,x+1);
  textcolor(3);
  textbackground(0);
  write(mln(nxset.speckey[x].name,40));
  end;
  gotoxy(2,1+current);  
  textcolor(15);
  textbackground(1);
  write(desc[current]);
  while not(keypressed) do begin timeslice; end;
  c:=readkey;
  case c of
        #0:begin
                c:=readkey;
                checkkey(c);
                case c of
                        #72:begin
                                gotoxy(2,1+current);
                                textcolor(7);
                                textbackground(0);
                                write(desc[current]);
                                dec(current);
                                if (current=0) then current:=10;
                        end;
                        #80:begin
                                gotoxy(2,1+current);
                                textcolor(7);
                                textbackground(0);
                                write(desc[current]);
                                inc(current);
                                if (current=11) then current:=1;
                        end;
                end;
        end;
        #13:begin
                gotoxy(2,current+1);
                textcolor(7);
                textbackground(0);
                write(desc[current]);
                getspeckey(current);
                window(12,9,68,20);
            end;
        #27:done:=TRUE;
  end;
  until (done);
  removewindow(w);
end;

procedure nxsetupstuff;
var choices:array[1..3] of string[20];
    desc:array[1..3] of string[70];
    current:byte;
    c:char;
    done,autosave:boolean;
    w2:windowrec;

function swapchoice(i:byte):string;
var s:string;
begin
case i of
        0:s:='None       ';
        1:s:='Disk       ';
        2:s:='XMS        ';
        3:s:='EMS        ';
        4:s:='Best Method';
        else s:='Error!     ';
end;
swapchoice:=s;
end;

begin
nxchanged:=FALSE;
autosave:=FALSE;
choices[1]:='Function Keys    ';
choices[2]:='Swapping Method :';
choices[3]:='Secure nxSETUP  :';
desc[1]:='Special definable function keys to run external programs';
desc[2]:='Swapping method: None, Disk, XMS, EMS, or Best Method';
desc[3]:='Restrict access to nxSETUP by Sysop password?';
setwindow(w2,24,10,56,16,3,0,8,'nxSETUP Options',TRUE);
done:=FALSE;
textcolor(7);
textbackground(0);
for current:=1 to 3 do begin
        gotoxy(2,current+1);
        write(choices[current]);
end;
gotoxy(20,3);
textcolor(3);
write(swapchoice(nxset.swaptype));
gotoxy(20,4);
write(syn(nxset.restrict));
current:=1;
repeat
textcolor(15);
textbackground(1);
gotoxy(2,current+1);
write(choices[current]);
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
window(25,11,55,15);
while not(keypressed) do begin timeslice; end;
c:=readkey;
case c of
        #0:begin
                c:=readkey;
                case c of
                #68:begin
                        done:=TRUE;
                        autosave:=TRUE;
                    end;
                #72:begin
                                textcolor(7);
                                textbackground(0);
                                gotoxy(2,current+1);
                                write(choices[current]);
                                dec(current);
                                if (current=0) then current:=3;
                        end;
                #80:begin
                                textcolor(7);
                                textbackground(0);
                                gotoxy(2,current+1);
                                write(choices[current]);
                                inc(current);
                                if (current=4) then current:=1;
                        end;
                end;
           end;
       #13:begin
                case current of
                        1:begin
                          pomisc3(FALSE);
                          window(25,11,55,14);
                          end;
                        2:begin
                                inc(nxset.swaptype);
                                if (nxset.swaptype>=5) then nxset.swaptype:=0;
                                nxchanged:=TRUE;
                                gotoxy(20,3);
                                textcolor(3);
                                textbackground(0);
                                write(swapchoice(nxset.swaptype));
                          end;
                        3:begin
                                nxset.restrict:=not(nxset.restrict);
                                nxchanged:=TRUE;
                                gotoxy(20,4);
                                textcolor(3);
                                textbackground(0);
                                write(syn(nxset.restrict));
                          end;
                end;
           end;
       #27:done:=TRUE;
end;
until(done);
if (nxchanged) then begin
if not(autosave) then autosave:=pynqbox('Save changes? ');
if (autosave) then begin
  {$I-} reset(nxsetf); {$I+}
  if (ioresult<>0) then begin
                displaybox('Error updating NXSETUP.DAT',3000);
                exit;
  end;
  write(nxsetf,nxset);
  close(nxsetf);
end;
end;
end;

end.
