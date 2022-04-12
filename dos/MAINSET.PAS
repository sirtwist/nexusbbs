{$A+,B+,D-,E+,F+,G+,I+,L-,N-,O+,R+,S+,V-}
unit mainset;

interface

uses dos, crt, myio, misc, init2, pconfig, aconfig, sysop1, sysop2f,
  sysop2a, sysop2b, sysop2c, sysop2d, sysop2e, sysop2g, sysop2h, sysop2i,
  sysop2m, sysop2s, sysop3,  sysop7,  sysop7m, sysop8,  sysop9, 
  mtemp,   dsetup,  procspec;


procedure changestuff(nexusdir:string);

implementation


procedure showabout;
var w2:^windowrec;
    c:char;
begin
        new(w2);
        window(1,1,80,25);
        textcolor(14);
        textbackground(0);
        gotoxy(1,25);
        clreol;
        write('Press any key to continue...');
        setwindow(w2^,2,7,78,22,3,0,8,'About nxSETUP ...',TRUE);
        textcolor(15);
        textbackground(0);
        gotoxy(2,2);
        writecentered(72,'nxSETUP - Nexus Bulletin Board System Setup');
        gotoxy(2,4);
        textcolor(14);
        writecentered(72,'Version '+ver);
        gotoxy(2,6);
        textcolor(11);
        writecentered(72,'(c) Copyr. 1996-2001 George A. Roberts IV. All rights reserved.');
        gotoxy(2,7);
        textcolor(11);
        writecentered(72,'(c) Copyr. 1994-95 Internet Pro''s Network LLC. All rights reserved.');
        gotoxy(2,13);
        textcolor(3);
        writecentered(72,'Developed using Borland Turbo Pascal v7.0');
        while not(keypressed) do begin timeslice; end;
        while (keypressed) do begin
        c:=readkey;
        end;
        removewindow(w2^);
        window(1,1,80,25);
        textcolor(14);
        textbackground(0);
        gotoxy(1,25);
        clreol;
        dispose(w2);
end;

procedure changestuff(nexusdir:string);
var c,c2:char;
    win,oldwind,ow2:^windowrec;
    choices:array[1..9] of string;
    desc2:array[1..9] of string;
    choices2:array[1..9] of string;
    x4,line2,maxshown,line,x,oldx,oldy:integer;
    done2,entered,done,abort,next,savepause:boolean;

begin
  new(win);
  new(oldwind);
  new(ow2);
  listbox_allow_extra_func:=TRUE;
  listbox_extrakeys_func:=listbox_extrakeys_func+#59;
  listbox_extrakeys_func:=listbox_extrakeys_func+#36;
  for x4:=1 to 10 do begin
        if (nxset.speckey[x4].path<>'') then begin
                listbox_extrakeys_func:=listbox_extrakeys_func+chr(x4+103);
        end;
  end;
  line:=1;
  choices[1]:='Main System Configuration     ';
  choices[2]:='File System Configuration     ';
  choices[3]:='Message System Configuration  ';
  choices[4]:='User Configuration            ';
  choices[5]:='Menu Configuration            ';
  choices[6]:='External Program Configuration';
  choices[7]:='Language Configuration        ';
  choices[8]:='Utilities                     ';
  choices[9]:='About nxSETUP                 ';
 cursoron(false);
 oldx:=wherex;
 oldy:=wherey;
    setwindow2(win^,23,9,56,21,3,0,8,'Main Menu','',TRUE);
    for x:=1 to 9 do begin
        gotoxy(2,x+1);
        textcolor(7);
        textbackground(0);
        write(choices[x]);
    end;
 savescreen(oldwind^,1,1,80,25);
 repeat
    entered:=false;
    done:=FALSE;
    repeat
                                gotoxy(2,line+1);
                                textcolor(15);
                                textbackground(1);
                                write(choices[line]);
                                window(1,1,80,25);
                                gotoxy(1,25);
                                textcolor(14);
                                textbackground(0);
                                clreol;
                                write('Esc');
                                textcolor(7);
                                write('=Exit ');
                                textcolor(14);
                                write('F1');
                                textcolor(7);
                                write('=Help Contents');
                                window(24,10,56,19);
    
    c:=readkey;
    case c of
      #0:begin
                c:=readkey;
                checkkey(c);
                case c of
                        #68:begin done:=true; entered:=true; end;
                        #59:begin
                                showhelp('NXSETUP',3);
                        end;
                        #72:begin
                                gotoxy(2,line+1);
                                textcolor(7);
                                textbackground(0);
                                write(choices[line]);
                                dec(line);
                                if (line=0) then line:=9;
                             end;
                         #80:begin
                                gotoxy(2,line+1);
                                textcolor(7);
                                textbackground(0);
                                write(choices[line]);
                                inc(line);
                                if (line=10) then line:=1;
                             end;
             end;
      end;
      #13:begin
    setwindow4(win^,23,9,56,21,8,0,8,'Main Menu','',TRUE);
        entered:=true;
        done2:=FALSE;
        gotoxy(2,line+1);
        textcolor(7);
        textbackground(0);
        write(choices[line]);
        case line of
                1:begin
  choices2[1]:='System Name and Settings  ';
  choices2[2]:='Directory Configuration   ';
  choices2[3]:='Filename Configuration    ';
  choices2[4]:='Node Configuration        ';
  choices2[5]:='System Variables          ';
  choices2[6]:='System Access Settings    ';
  choices2[7]:='System Flags              ';
  choices2[8]:='nxSETUP Specific Options  ';
  desc2[1]:='Main System Configuration - BBS Name, etc.';
  desc2[2]:='Directories that Nexus will use             ';
  desc2[3]:='Filename configuration for Nexus and nxSETUP';
  desc2[4]:='Configuration for Node Specific information';
  desc2[5]:='Various System variables that need to be set up';
  desc2[6]:='Access settings for various aspects of Nexus';
  desc2[7]:='Flags that need to be set for various options';
  desc2[8]:='nxSETUP specific options and toggles';
  setwindow(w,26,8,55,19,3,0,8,'Main Setup',TRUE);
  maxshown:=8;
  end;
  2:begin
  choices2[1]:='File Base Editor          ';
  choices2[2]:='File Conference Editor    ';
  choices2[3]:='File System Variables     ';
  choices2[4]:='Protocol Editor           ';
  choices2[5]:='Archiver Editor           ';
  choices2[6]:='Archive Comment Filenames ';
  choices2[7]:='CD-ROM Disk Configuration ';
  choices2[8]:='CD-ROM Drive Configuration';
  choices2[9]:='File Base Management      ';
  desc2[1]:='Configuration of your File Bases';
  desc2[2]:='Configuration of your File Conferences';
  desc2[3]:='Variables that need to be set for the file system';
  desc2[4]:='Configuration for your File Transfer Protocols';
  desc2[5]:='Configuration for your Archivers';
  desc2[6]:='Archive Comment Files that Nexus uses';
  desc2[7]:='CD-ROM Setup for your CD-ROM Disks';
  desc2[8]:='CD-ROM Setup for your CD-ROM drives';
  desc2[9]:='Management of File Bases - Moving, Deleting, Editing';
  setwindow(w,26,10,55,22,3,0,8,'File Setup',TRUE);
  maxshown:=9;
  end;
  3:begin
  choices2[1]:='Message Base Editor       ';
  choices2[2]:='Message Base Templates    ';
  choices2[3]:='Message Conference Editor ';
  choices2[4]:='Network Configuration     ';
  choices2[5]:='Offline Mail Configuration';
  desc2[1]:='Configuration of your Message Bases';
  desc2[2]:='Edit Templates for creation of Message Bases';
  desc2[3]:='Configuration of your Message Conferences';
  desc2[4]:='Set up for Mail Networks';
  desc2[5]:='Configuration for Offline Mail System';
  setwindow(w,26,10,55,18,3,0,8,'Message Setup',TRUE);
  maxshown:=5;
  end;
  4:begin
  choices2[1]:='User Editor               ';
  choices2[2]:='Subscription Level Config ';
  choices2[3]:='Security Level Config     ';
  desc2[1]:='User Editor to edit your User''s Accounts';
  desc2[2]:='Set up for Subscription Levels           ';
  desc2[3]:='Security Level Configuration             ';
  setwindow(w,26,11,55,17,3,0,8,'User Setup',TRUE);
  maxshown:=3;
  end;
  5:menu_edit;
  6:dset;
  7:begin
  choices2[1]:='Language Editor           ';
  choices2[2]:='String Configuration      ';
  desc2[1]:='Language Editor to set up Language Support    ';
  desc2[2]:='Configuration for various configurable strings';
  setwindow(w,26,11,55,16,3,0,8,'Language Setup',TRUE);
  maxshown:=2;
  end;
  8:externalutilities;
  9:showabout;
  end;
  line2:=1;
  if not(line in [5,6,8,9]) then begin
  textcolor(7);
  textbackground(0);
  for x:=1 to maxshown do begin
        gotoxy(2,x+1);
        write(choices2[x]);
  end;
  repeat
  case line of
        1:window(27,9,54,18);
        2:window(27,11,54,21);
        3:window(27,11,54,17);
        4:window(27,12,54,16);
        7:window(27,12,54,15);
  end;
  savescreen(ow2^,1,1,80,25);
  gotoxy(2,line2+1);
  textcolor(15);
  textbackground(1);
  write(choices2[line2]);
  window(1,1,80,25);
  gotoxy(1,25);
  textcolor(14);
  textbackground(0);
  clreol;
  gotoxy(1,25);
  write('Esc');
  textcolor(7);
  write('=Exit ');
  textcolor(14);
  write('F1');
  textcolor(7);
  write('=Help Contents ');
  textcolor(14);
  write(desc2[line2]);
  case line of
        1:window(27,9,54,18);
        2:window(27,11,54,21);
        3:window(27,11,54,17);
        4:window(27,12,54,16);
        7:window(27,12,54,15);
  end;
  infield_clear:=TRUE;
  infield_putatend:=TRUE;
  while not(keypressed) do begin timeslice; end;
  c2:=readkey;
  case c2 of
        #0:begin
                c2:=readkey;
                checkkey(c2);
                case c2 of
        #68:begin
                if (line<>5) and (line<>6) then begin
                removewindow(w);
                end;
                window(24,10,56,19);
                done2:=TRUE;
        end;
                        #59:begin
                                showhelp('NXSETUP',3);
                            end;
                        #72:begin
                                gotoxy(2,line2+1);
                                textcolor(7);
                                textbackground(0);
                                write(choices2[line2]);
                                dec(line2);
                                if (line2=0) then line2:=maxshown;
                        end;
                        #80:begin
                                gotoxy(2,line2+1);
                                textcolor(7);
                                textbackground(0);
                                write(choices2[line2]);
                                inc(line2);
                                if (line2>maxshown) then line2:=1;
                        end;
                end;
        end;
        #13:begin
                gotoxy(2,line2+1);
                textcolor(7);
                textbackground(0);
                write(choices2[line2]);
                case line of
                        1:begin
  setwindow4(w,26,8,55,19,8,0,8,'Main Setup','',TRUE);
                                case line2 of
                                        1:pofile;
                                        2:pomisc1(false);
                                        3:pomisc2(false);
                                        4:pomodem;
                                        5:pogenvar;
                                        6:poslsettings;
                                        7:poflagfunc;
                                        8:nxsetupstuff;
                                end;
  setwindow5(w,26,8,55,19,3,0,8,'Main Setup','',TRUE);
                        end;
                        2:begin
                          setwindow4(w,26,10,55,22,8,0,8,'File Setup','',TRUE);
                                case line2 of
                                        1:dlboardedit;
                                        2:confeditor(1);
                                        3:pofilesconfig;
                                        4:protconfig;
                                        5:poarcconfig;
                                        6:getarctype;
                                        7:cdromdisks;
                                        8:cdromdrives;
                                        9:filebasemanager(Nexusdir,'-Z');
                                end;
                          setwindow5(w,26,10,55,22,3,0,8,'File Setup','',TRUE);
                        end;
                        3:begin
  setwindow4(w,26,10,55,18,8,0,8,'Message Setup','',TRUE);
                                case line2 of
                                        1:boardedit;
                                        2:mbasetempedit;
                                        3:confeditor(0);
                                        4:pofido;
                                        5:omssetup(nexusdir,'');
                                end;
  setwindow5(w,26,10,55,18,3,0,8,'Message Setup','',TRUE);
                        end;
                        4:begin
                  setwindow4(w,26,11,55,17,8,0,8,'User Setup','',TRUE);
                                case line2 of
                                        1:uedit1(NexusDir);
                                        2:subscriptconfig;
                                        3:seclevelconfig;
                                end;
                  setwindow5(w,26,11,55,17,3,0,8,'User Setup','',TRUE);
                        end;
                        7:begin
  setwindow4(w,26,11,55,16,8,0,8,'Language Setup','',TRUE);
                                case line2 of
                                        1:editlanguage;
                                        2:postring;
                                end;
  setwindow5(w,26,11,55,16,3,0,8,'Language Setup','',TRUE);
                          end;
                end;
                case line of
        1:window(27,9,54,18);
        2:window(27,11,54,21);
        3:window(27,11,54,17);
        4:window(27,12,54,16);
        7:window(27,12,54,15);
                end;
        removewindow(ow2^);
        end;
        #27:begin
                if (line<>5) and (line<>6) then begin
                removewindow(w);
                end;
                window(24,10,56,19);
                done2:=TRUE;
        end;
  end;
        until (done2);
        end;
        end;
      #27:begin done:=true; entered:=true; end;
    end;
    until (entered);
    removewindow(oldwind^);
    window(24,10,56,19);
    setwindow5(win^,23,9,56,21,3,0,8,'Main Menu','',TRUE);
  until (done);
  savesystat2(nexusdir);
  updatesystem;
  removewindow(win^);
  dispose(win);
  dispose(oldwind);
  dispose(ow2);
end;

end.
