(*****************************************************************************)
(*>                                                                         <*)
(*>  SYSOP7M .PAS -  Written by Eric Oman                                   <*)
(*>                                                                         <*)
(*>  SysOp functions: Menu editor -- "M" command (modify commands)          <*)
(*>                                                                         <*)
(*****************************************************************************)
{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R-,S+,V-}
unit sysop7m;

interface

uses
  crt, dos, misc, myio,procspec{,inptmisc};

type cmdrtype=array[1..50] of commandrec; { command information                }

var cmdr:^cmdrtype;
    editcmd:commandrec;
    noc:integer;                  { # of commands on menu                 }
    mdf:file of commandrec;

type menuptr=^menurec;

const editingmenu:integer=0;

var menur:menuptr;
    mf:file of menurec;
    c4:char;
    firstlp,lp,lp2:listptr;
    rt:returntype;
    cur,top:integer;
    mfilename:string;

procedure memm(scurmenu:astr);
procedure readinpointers2;
procedure disposeall2;

implementation

  procedure newcmds(n:integer);                          { new command stuff }
  begin
    with editcmd do begin
    if (editingmenu in [1..5]) then begin
      if (editingmenu=1) then begin
        ldesc:='(G)oodbye and logoff';
        sdesc:='(G)oodbye';
        ckeys:='G';
        acs:='';
        cmdkeys:='D1';
        mstring:='%120%Are you sure you want to log off? %110%';
        commandflags:=[];
      end else begin
        ldesc:='';
        sdesc:='';
        ckeys:='';
        acs:='';
        cmdkeys:='12';
        mstring:='';
        commandflags:=[AutoExec];
      end;
    end else begin
      ldesc:='(Q)uit to Main Menu';
      sdesc:='(Q)uit to Main';
      ckeys:='Q';
      acs:='';
      cmdkeys:='01';
      mstring:='6';
      commandflags:=[];
    end;
    end;
    seek(mdf,n);
    write(mdf,editcmd);
  end;

function readin:boolean;                    (* read in the menu file curmenu *)
var s:astr;
    i:integer;
begin
  noc:=0;
  assign(mdf,systat.menupath+menur^.mnufile+'.MNU');
  {$I-} reset(mdf); {$I+}
  if (ioresult<>0) then begin
    if pynqbox('Create new menu commands? ') then begin
            rewrite(mdf);
            readin:=TRUE;
            newcmds(0);
            noc:=1;
    end else readin:=FALSE;
    window(2,7,77,22);
  end else begin
    noc:=filesize(mdf);
    if (noc=0) then begin
    if pynqbox('Create new menu commands? ') then begin
            rewrite(mdf);
            readin:=TRUE;
            newcmds(0);
            noc:=1;
    end else begin
        readin:=FALSE;
        close(mdf);
    end;
    window(2,7,77,22);
    end else readin:=TRUE;
  end;
end;


        procedure readinpointers2;
        var d1:listptr;
            size,x,ii2:integer;
            xx:longint;
        begin
                                xx:=filepos(mf);
                                new(lp);
                                seek(mf,0);       
                                read(mf,menur^);
                                ii2:=1;
                                lp^.p:=NIL;
                                lp^.list:=mln(cstr(ii2),5)+mln(menur^.name,50);
                                firstlp:=lp;
                                while (not(eof(mf))) do begin
                                inc(ii2);
                                read(mf,menur^);
                                new(lp2);
                                lp2^.p:=lp;
                                lp^.n:=lp2;
                                lp2^.list:=mln(cstr(ii2),5)+mln(menur^.name,50);
                                lp:=lp2;
                                end;
                                lp^.n:=NIL;
                                lp:=firstlp;
                                seek(mf,xx);

        end;

        procedure disposeall2;
        begin
                                                lp:=firstlp;
                                                while (lp<>NIL) do begin
                                                        lp2:=lp^.n;
                                                        dispose(lp);
                                                        lp:=lp2;
                                                end;
        end;

function getmenucmd:string;
var w2,w3,w4:windowrec;
    choices:array[1..11] of string;
    choices2:array[1..10] of string;
    current,current2:integer;
    tmpcmd:string;
    c,c2:char;
    s:string;
    maxshow,x:integer;
    enteredcmd,done,done2:boolean;


begin
done:=FALSE;
enteredcmd:=FALSE;
tmpcmd:='';
choices[1]:='Misc: Menus, Doors          ';
choices[2]:='Misc: Info, Chat, News      ';
choices[3]:='Misc: Timebank, User, Sysop ';
choices[4]:='Misc: Display               ';
choices[5]:='File: Base, List, Search    ';
choices[6]:='File: Flagged, Misc         ';
choices[7]:='File: Upload, Download      ';
choices[8]:='File: Archive Handling      ';
choices[9]:='Mail: Base, Read, Post      ';
choices[10]:='Mail: New, Search, Waiting  ';
choices[11]:='Quit: Hangup                ';
setwindow2(w2,12,8,43,22,3,0,8,'Command Types','',TRUE);
for x:=1 to 11 do begin
gotoxy(2,x+1);
textcolor(7);
textbackground(0);
write(choices[x]);
end;
current:=1;
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
                checkkey(c);
                case c of
                        #72:begin
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choices[current]);
                                dec(current);
                                if (current=0) then current:=11;
                            end;
                        #80:begin
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choices[current]);
                                inc(current);
                                if (current=12) then current:=1;
                            end;
                end;
            end;
        'A'..'Z','0'..'9':begin
          setwindow4(w2,12,8,43,22,8,0,8,'Command Types','',TRUE);
          setwindow(w4,30,12,50,14,3,0,8,'',TRUE);
          gotoxy(2,1);
          textcolor(7);
          textbackground(0);
          write('Menu Command : ');
          gotoxy(17,1);
          s:=c;
          infield_inp_fgrd:=15;
          infield_inp_bkgd:=1;
          infield_out_fgrd:=3;
          infield_out_bkgd:=0;
          infield_allcaps:=TRUE;
          infield_numbers_only:=FALSE;
          infield_escape_zero:=FALSE;
          infield_escape_blank:=TRUE;
          infield_putatend:=TRUE;
          infield_insert:=TRUE;
          infield_clear:=FALSE;
          infielde(s,2);
          infield_escape_blank:=FALSE;
          infield_putatend:=FALSE;
          infield_insert:=TRUE;
          if (s<>'') then begin
                tmpcmd:=s;
                done:=TRUE;
                enteredcmd:=FALSE;
          end;
         removewindow(w4);
         setwindow5(w2,12,8,43,22,3,0,8,'Command Types','',TRUE);
         end;
        #13:begin
                gotoxy(2,current+1);
                textcolor(7);
                textbackground(0);
                write(choices[current]);
                setwindow4(w2,12,8,43,22,8,0,8,'Command Types','',TRUE);
                case current of
                        1:begin
                        choices2[1]:='01  Goto Menu                       ';
                        choices2[2]:='02  Gosub Menu                      ';
                        choices2[3]:='03  Return from Gosub               ';
                        choices2[4]:='04  Place Line in LOG file          ';
                        choices2[5]:='05  Run Nexecutable (v1.00)         ';
                        choices2[6]:='06  Run Nexecutable (v2.00)         ';
                        choices2[7]:='07  Stuff sequence into buffer      ';
                        choices2[8]:='08  Prompt user for a password      ';
                        choices2[9]:='09  Run External DOOR Program       ';
                        maxshow:=9;
                          end;
                        2:begin
                        choices2[1]:='80  Nexus Product Information       ';
                        choices2[2]:='81  Page/Chat with SysOp            ';
                        choices2[3]:='83  Log of Callers                  ';
                        choices2[4]:='84  SysOp Chat Availability Status  ';
                        choices2[5]:='85  User Settings Change            ';
                        choices2[6]:='86  News System                     ';
                        choices2[7]:='87  List Which News Files Updated   ';
                        choices2[8]:='88  AutoPost a Message              ';
                        maxshow:=8;
                          end;
                        3:begin
                        choices2[1]:='90  Add Time to User TimeBank       ';
                        choices2[2]:='91  Withdraw Time from User TimeBank';
                        choices2[3]:='92  User Listing                    ';
                        choices2[4]:='93  User Information/Statistics     ';
                        choices2[5]:='94  Ask user paging status          ';
                        choices2[6]:='95  Who''s on what node?             ';
                        choices2[7]:='96  Page a user on another node     ';
                        choices2[8]:='97  nxCHAT - Multiuser Chat         ';
                        choices2[9]:='99  SymSys<tm> - OS Shell    (SYSOP)';
                        maxshow:=9;
                          end;
                        4:begin
                        choices2[1]:='10  Display File                    ';
                        choices2[2]:='11  Prompt String (no Line Feed)    ';
                        choices2[3]:='12  Print String (include Line Feed)';
                        choices2[4]:='13  Clear Screen                    ';
                        choices2[5]:='14  Pause Screen                    ';
                        choices2[6]:='15  Goto Screen Position            ';
                        choices2[7]:='16  Ask Yes/No Question             ';
                        choices2[8]:='17  Draw Window                     ';
                        maxshow:=8;
                          end;
                        5:begin
                        choices2[1]:='30  Join File Conference            ';
                        choices2[2]:='31  Change/List File Base(s)        ';
                        choices2[3]:='32  Tag File Bases For New Scan     ';
                        choices2[4]:='33  Scan For New Files              ';
                        choices2[5]:='34  Search for Files                ';
                        choices2[6]:='35  List Files in Current Base      ';
                        choices2[7]:='36  Set File New Scan Pointer Date  ';
                        choices2[8]:='37  Show User File Information      ';
                        choices2[9]:='38  File Base QuickChange<tm>       ';
                       choices2[10]:='39  Show Available CD-ROM Disks     ';
                        maxshow:=10;
                          end;
                        6:begin
                        choices2[1]:='40  Clear Flagged Files             ';
                        choices2[2]:='41  List Flagged Files              ';
                        choices2[3]:='42  Remove Flagged Files            ';
                        choices2[4]:='48  Expanded Directory List         ';
                        choices2[5]:='49  Condensed Directory List        ';
                        maxshow:=5;
                          end;
                        7:begin
                        choices2[1]:='50  Download File(s)                ';
                        choices2[2]:='51  Flag File(s)                    '; 
                        choices2[3]:='52  Upload File(s)                  ';
                        choices2[4]:='53  Unlisted Download               ';
                        choices2[5]:='55  Validate Files                  ';
                        choices2[6]:='57  DL Specific File From Base      ';
                        maxshow:=6;
                          end;
                        8:begin
                        choices2[1]:='20  Add File to Archive             ';
                        choices2[2]:='21  Convert Archive Format          ';
                        choices2[3]:='22  Update Archive Comment          ';
                        choices2[4]:='23  Test Archive Integrity          ';
                        choices2[5]:='24  Extract File from Archive       ';
                        choices2[6]:='25  View Contents of Archive        ';
                        maxshow:=6;
                          end;
                        9:begin
                        choices2[1]:='60  Join Message Conference         ';
                        choices2[2]:='61  Change/List Message Base(s)     ';
                        choices2[3]:='62  Tag Message Bases for Scans     ';
                        choices2[4]:='63  Read Messages in Current Base   ';
                        choices2[5]:='64  Post New Message in Current Base';
                        choices2[6]:='65  Post Feedback in Msg Base #0    ';
                        choices2[7]:='66  Download Messages (ivOMS)       ';
                        choices2[8]:='67  Upload Messages (ivOMS)         ';
                        choices2[9]:='68  Message Base QuickChange<tm>    ';
                        choices2[10]:='69  ivOMS Offline Mail System       ';
                        maxshow:=10;
                          end;
                        10:begin
                        choices2[1]:='70  Scan for New Messages           ';
                        choices2[2]:='71  Search Messages                 ';
                        choices2[3]:='72  Scan for Waiting Messages       ';
                        maxshow:=3;
                          end;
                       11:begin
                        choices2[1]:='D0  Hangup Cautiously (Ask First)   ';
                        choices2[2]:='D1  Hangup Immediately              ';
                        choices2[3]:='D2  Hangup with Message             ';
                        choices2[4]:='D3  Hangup with Carrier High        ';
                        choices2[5]:='D4  Logoff with loop back to logon  ';
                        maxshow:=5;
                          end;
                end;
                setwindow(w3,21,9,60,12+maxshow,3,0,8,'Command',TRUE);
                for x:=1 to maxshow do begin
                        gotoxy(2,x+1);
                        textcolor(7);
                        textbackground(0);
                        write(choices2[x]);
                end;
                current2:=1;
                done2:=FALSE;
                repeat
                gotoxy(2,current2+1);
                textcolor(15);
                textbackground(1);
                write(choices2[current2]);
                while not(keypressed) do begin timeslice; end;
                c2:=readkey;
                case c2 of
                         #0:begin
                                c2:=readkey;
                                checkkey(c2);
                                case c2 of
                                        #72:begin
                                                gotoxy(2,current2+1);
                                                textcolor(7);
                                                textbackground(0);
                                                write(choices2[current2]);
                                                dec(current2);
                                                if (current2=0) then current2:=maxshow;
                                            end;
                                        #80:begin
                                                gotoxy(2,current2+1);
                                                textcolor(7);
                                                textbackground(0);
                                                write(choices2[current2]);
                                                inc(current2);
                                                if (current2>maxshow) then current2:=1;
                                            end;
                                end;
                            end;
        'A'..'Z','a'..'z','0'..'9':begin
          setwindow4(w3,21,9,60,12+maxshow,8,0,8,'Command','',TRUE);
          setwindow(w4,30,12,50,14,3,0,8,'',TRUE);
          gotoxy(2,1);
          textcolor(7);
          textbackground(0);
          write('Menu Command : ');
          gotoxy(17,1);
          s:=c2;
          infield_inp_fgrd:=15;
          infield_inp_bkgd:=1;
          infield_out_fgrd:=3;
          infield_out_bkgd:=0;
          infield_allcaps:=TRUE;
          infield_numbers_only:=FALSE;
          infield_escape_zero:=FALSE;
          infield_escape_blank:=TRUE;
          infield_putatend:=TRUE;
          infield_insert:=TRUE;
          infield_clear:=FALSE;
          infielde(s,2);
          infield_escape_blank:=FALSE;
          infield_putatend:=FALSE;
          infield_insert:=TRUE;
          if (s<>'') then begin
                tmpcmd:=s;
                done:=TRUE;
                done2:=TRUE;
                enteredcmd:=FALSE;
          end;
         removewindow(w4);
         setwindow5(w3,21,9,60,12+maxshow,3,0,8,'Command','',TRUE);
         end;
                        #13:begin
                                enteredcmd:=TRUE;
                                done2:=TRUE;
                            end;
                        #27:done2:=TRUE;
                end;
                until (done2);
                removewindow(w3);
                setwindow5(w2,12,8,43,22,3,0,8,'Command Types','',TRUE);
                window(13,9,42,21);
            end;
        #27:done:=TRUE;
end;
if (enteredcmd) then begin
case current of
        1:begin
                case current2 of
                        1:tmpcmd:='01';
                        2:tmpcmd:='02';
                        3:tmpcmd:='03';
                        4:tmpcmd:='04';
                        5:tmpcmd:='05';
                        6:tmpcmd:='06';
                        7:tmpcmd:='07';
                        8:tmpcmd:='08';
                        9:tmpcmd:='09';
                end;
          end;
        2:begin
                case current2 of
                        1:tmpcmd:='80';
                        2:tmpcmd:='81';
                        3:tmpcmd:='83';
                        4:tmpcmd:='84';
                        5:tmpcmd:='85';
                        6:tmpcmd:='86';
                        7:tmpcmd:='87';
                        8:tmpcmd:='88';
                end;
          end;
        3:begin
                case current2 of
                        1:tmpcmd:='90';
                        2:tmpcmd:='91';
                        3:tmpcmd:='92';
                        4:tmpcmd:='93';
                        5:tmpcmd:='94';
                        6:tmpcmd:='95';
                        7:tmpcmd:='96';
                        8:tmpcmd:='97';
                        9:tmpcmd:='99';
                end;
          end;
        4:begin
                case current2 of
                        1:tmpcmd:='10';
                        2:tmpcmd:='11';
                        3:tmpcmd:='12';
                        4:tmpcmd:='13';
                        5:tmpcmd:='14';
                        6:tmpcmd:='15';
                        7:tmpcmd:='16';
                        8:tmpcmd:='17';
                end;
          end;
        5:begin
                case current2 of
                        1:tmpcmd:='30';
                        2:tmpcmd:='31';
                        3:tmpcmd:='32';
                        4:tmpcmd:='33';
                        5:tmpcmd:='34';
                        6:tmpcmd:='35';
                        7:tmpcmd:='36';
                        8:tmpcmd:='37';
                        9:tmpcmd:='38';
                       10:tmpcmd:='39';
                end;
          end;
        6:begin
                case current2 of
                        1:tmpcmd:='40';
                        2:tmpcmd:='41';
                        3:tmpcmd:='42';
                        4:tmpcmd:='48';
                        5:tmpcmd:='49';
                end;
          end;
        7:begin
                case current2 of
                        1:tmpcmd:='50';
                        2:tmpcmd:='51';
                        3:tmpcmd:='52';
                        4:tmpcmd:='53';
                        5:tmpcmd:='55';
                        6:tmpcmd:='57';
                end;
          end;
        8:begin
                case current2 of
                        1:tmpcmd:='20';
                        2:tmpcmd:='21';
                        3:tmpcmd:='22';
                        4:tmpcmd:='23';
                        5:tmpcmd:='24';
                        6:tmpcmd:='25';
                end;
          end;
        9:begin
                case current2 of
                        1:tmpcmd:='60';
                        2:tmpcmd:='61';
                        3:tmpcmd:='62';
                        4:tmpcmd:='63';
                        5:tmpcmd:='64';
                        6:tmpcmd:='65';
                        7:tmpcmd:='66';
                        8:tmpcmd:='67';
                        9:tmpcmd:='68';
                        10:tmpcmd:='69';
               end;
          end;
       10:begin
                case current2 of
                        1:tmpcmd:='70';
                        2:tmpcmd:='71';
                        3:tmpcmd:='72';
               end;
          end;
       11:begin
                case current2 of
                        1:tmpcmd:='D0';
                        2:tmpcmd:='D1';
                        3:tmpcmd:='D2';
                        4:tmpcmd:='D3';
                        5:tmpcmd:='D4';
               end;
          end;
end;
done:=TRUE;
end;
until (done);
removewindow(w2);
getmenucmd:=tmpcmd;
end;


procedure memm(scurmenu:astr);
var oldii,x,current,i1,i2,ii,z:integer;
    c:char;
    s,s2,ts,ts2,ts3:astr;
    b:byte;
    choice:array[1..8] of string[30];
    desc:array[1..8] of string;
    auto,arrows,changed,editing,done,update,abort,next,bb:boolean;

function restrm:boolean;
begin
if ((allcaps(scurmenu)='FASTLOG') or (allcaps(scurmenu)='PRELOGON') 
        or (allcaps(scurmenu)='LOGON') or (allcaps(scurmenu)='NEWUSER')) then
        restrm:=true else restrm:=false;
end;

function dispcmd(s:string):string;
var s2:string;
begin
s:=allcaps(s);
s2:=s;
if (titleline in editcmd.commandflags) then begin
s2:='Unused';
end else
case s[1] of
        '0':case s[2] of
                        '1':s2:='01  Goto Menu';
                        '2':s2:='02  Gosub Menu';
                        '3':s2:='03  Return from Gosub';
                        '4':s2:='04  Place Line in LOG file';
                        '5':s2:='05  Run Nexecutable (v1.00)';
                        '6':s2:='06  Run Nexecutable (v2.00)';
{                        '6':s2:='06  Read Questionaire Answers'; }
                        '7':s2:='07  Stuff sequence into buffer';
                        '8':s2:='08  Prompt user for a password';
                        '9':s2:='09  Run External DOOR Program';
            end;
        '1':case s[2] of
                        '0':s2:='10  Display File';
                        '1':s2:='11  Prompt String (no Line Feed)';
                        '2':s2:='12  Print String (include Line Feed)';
                        '3':s2:='13  Clear Screen';
                        '4':s2:='14  Pause Screen';
                        '5':s2:='15  Goto Screen Position';
                        '6':s2:='16  Ask Yes/No Question';
                        '7':s2:='17  Draw Window';
            end;
        '2':case s[2] of
                        '0':s2:='20  Add File to Archive';
                        '1':s2:='21  Convert Archive Format';
                        '2':s2:='22  Update Archive Comment';
                        '3':s2:='23  Test Archive Integrity';
                        '4':s2:='24  Extract File from Archive';
                        '5':s2:='25  View Contents of Archive';
            end;
        '3':case s[2] of
                        '0':s2:='30  Join File Conference';
                        '1':s2:='31  Change/List File Base(s)';
                        '2':s2:='32  Tag File Bases For New Scan';
                        '3':s2:='33  Scan For New Files';
                        '4':s2:='34  Search for Files';
                        '5':s2:='35  List Files in Current Base';
                        '6':s2:='36  Set File New Scan Pointer Date';
                        '7':s2:='37  Show User File Information';
                        '8':s2:='38  File Base QuickChange<tm>';
                        '9':s2:='39  Show Available CD-ROM Disks';
            end;
        '4':case s[2] of
                        '0':s2:='40  Clear Flagged Files';
                        '1':s2:='41  List Flagged Files';
                        '2':s2:='42  Remove Flagged Files';
                        '8':s2:='48  Expanded Directory List';
                        '9':s2:='49  Condensed Directory List';
            end;
        '5':case s[2] of
                        '0':s2:='50  Download File(s)';
                        '1':s2:='51  Flag File(s)';
                        '2':s2:='52  Upload File(s)';
                        '3':s2:='53  Unlisted Download';
                        '5':s2:='55  Validate Files';
                        '7':s2:='57  DL Specific File From Base';
            end;
        '6':case s[2] of
                        '0':s2:='60  Join Message Conference';
                        '1':s2:='61  Change/List Message Base(s)';
                        '2':s2:='62  Tag Message Bases for Scans';
                        '3':s2:='63  Read Messages in Current Base';
                        '4':s2:='64  Post New Message in Current Base';
                        '5':s2:='65  Post Feedback in Msg Base #0';
                        '6':s2:='66  Download Messages (ivOMS)';
                        '7':s2:='67  Upload Messages (ivOMS)';
                        '8':s2:='68  Message Base QuickChange<tm>';
                        '9':s2:='69  ivOMS Offline Mail System';
            end;
        '7':case s[2] of
                        '0':s2:='70  Scan for New Messages';
                        '1':s2:='71  Search Messages';
                        '2':s2:='72  Scan for Waiting Messages';
            end;
        '8':case s[2] of
                        '0':s2:='80  Nexus Product Information';
                        '1':s2:='81  Page/Chat with SysOp';
                        '3':s2:='83  Log of Callers';
                        '4':s2:='84  SysOp Chat Availability Status';
                        '5':s2:='85  User Settings Change';
                        '6':s2:='86  News System';
                        '7':s2:='87  List Which News Files Updated';
                        '8':s2:='88  Auto-Post a Message';
            end;
        '9':case s[2] of
                        '0':s2:='90  Add Time to User TimeBank';
                        '1':s2:='91  Withdraw Time from User TimeBank';
                        '2':s2:='92  User Listing';
                        '3':s2:='93  User Information/Statistics';
                        '4':s2:='94  Ask user paging status';
                        '5':s2:='95  Who''s on what node?';
                        '6':s2:='96  Page a user on another node';
                        '7':s2:='97  nxCHAT - Multiuser Chat';
                        '9':s2:='99  SymSys<tm> - OS Shell  (SYSOP)';
            end;
        'D':case s[2] of
                        '0':s2:='D0  Hangup Cautiously (Ask First)';
                        '1':s2:='D1  Hangup Immediately';
                        '2':s2:='D2  Hangup with Message';
                        '3':s2:='D3  Hangup with Carrier High';
                        '4':s2:='D4  Logoff with loop back to logon prompt';
            end;
end;
dispcmd:=mln(s2,45);
end;

  function showcflags:string;
  var s:string;
  begin
  s:='';
  if (hidden in editcmd.commandflags) then s:=s+'Hidden ';
  if (unhidden in editcmd.commandflags) then s:=s+'Unhidden ';
  if (autoexec in editcmd.commandflags) then s:=s+'AutoExec ';
  if (titleline in editcmd.commandflags) then s:=s+'TitleLine';
  if (s='') then s:='None';
  showcflags:=s;
  end;

  procedure getcflags;
  var w2:windowrec;
      cho:array[1..4] of string[10];
      cit:char;
      xit,cur:integer;
      done3:boolean;
  begin
      done3:=FALSE;
      cho[1]:='Hidden   :';
      cho[2]:='Unhidden :';
      cho[3]:='AutoExec :';
      cho[4]:='TitleLine:';
      setwindow(w2,31,12,49,19,3,0,8,'Flags',TRUE);
      cur:=1;
      textcolor(7);
      textbackground(0);
      for xit:=1 to 4 do begin
        gotoxy(2,xit+1);
        write(cho[xit]);
      end;
      cursoron(FALSE);
      repeat
      gotoxy(13,2);
      textcolor(3);
      textbackground(0);
      write(syn(hidden in editcmd.commandflags));
      gotoxy(13,3);
      write(syn(unhidden in editcmd.commandflags));
      gotoxy(13,4);
      write(syn(autoexec in editcmd.commandflags));
      gotoxy(13,5);
      write(syn(titleline in editcmd.commandflags));
      gotoxy(2,cur+1);
      textcolor(15);
      textbackground(1);
      write(cho[cur]);
      while not(keypressed) do begin timeslice; end;
      cit:=readkey;
      case cit of
                #0:begin
                        cit:=readkey;
                        checkkey(cit);
                        case cit of
                                #72:begin
                                        gotoxy(2,cur+1);
                                        textcolor(7);
                                        textbackground(0);
                                        write(cho[cur]);
                                        dec(cur);
                                        if (cur=0) then cur:=4;
                                end;
                                #80:begin
                                        gotoxy(2,cur+1);
                                        textcolor(7);
                                        textbackground(0);
                                        write(cho[cur]);
                                        inc(cur);
                                        if (cur=5) then cur:=1;
                                end;
                        end;
                   end;
               #13:begin
                   case cur of
                        1:begin
                                changed:=TRUE;
                                if (hidden in editcmd.commandflags) then
                                        editcmd.commandflags:=
                                                editcmd.commandflags-[hidden] else
                                        editcmd.commandflags:=
                                                editcmd.commandflags+[hidden];
                        end;
                        2:begin
                                changed:=TRUE;
                                if (unhidden in editcmd.commandflags) then
                                        editcmd.commandflags:=
                                                editcmd.commandflags-[unhidden] else
                                        editcmd.commandflags:=
                                                editcmd.commandflags+[unhidden];
                        end;
                        3:begin
                                changed:=TRUE;
                                if (autoexec in editcmd.commandflags) then
                                        editcmd.commandflags:=
                                                editcmd.commandflags-[autoexec] else
                                        editcmd.commandflags:=
                                                editcmd.commandflags+[autoexec];
                        end;
                        4:begin
                                changed:=TRUE;
                                if (titleline in editcmd.commandflags) then
                                        editcmd.commandflags:=
                                                editcmd.commandflags-[titleline] else
                                        editcmd.commandflags:=
                                                editcmd.commandflags+[titleline];
                        end;
                   end;
                   end;
               #27:begin
                   done3:=TRUE;
                   end;
      end;
      until(done3);
      removewindow(w2);
  end;
        

  procedure newcmd;                          { new command stuff }
  begin
    with editcmd do begin
      ldesc:='';
      sdesc:='';
      ckeys:='';
      acs:='';
      cmdkeys:='12';
      mstring:='';
      commandflags:=[];
      if (editingmenu in [2..5]) then commandflags:=[AutoExec];
    end;
  end;

    procedure memd(i:integer);                   (* delete command from list *)
    var x:integer;
    begin
      if (i>=0) and (i<=noc-1) then begin
        for x:=i+1 to noc-1 do begin
                seek(mdf,x);
                read(mdf,editcmd);
                seek(mdf,x-1);
                write(mdf,editcmd);
        end;
        seek(mdf,noc-1);
        truncate(mdf);
        dec(noc);
      end;
    end;

    procedure memi(i:integer);             (* insert a command into the list *)
    var x:integer;
        s:astr;
    begin
      if (i>=0) and (i<=noc) and (noc<50) then begin
          for x:=noc downto i+1 do begin
                seek(mdf,x-1);
                read(mdf,editcmd);
                seek(mdf,x);
                write(mdf,editcmd);
          end;
        newcmd;
        seek(mdf,i);
        write(mdf,editcmd);
        inc(noc);
      end;
    end;

    procedure memp(i:integer);
    var j,k:integer;
        w2:windowrec;
        s2:string;
        oldcmd:commandrec;
    begin
      if ((i>=1) and (i<=noc)) then begin
      oldcmd:=editcmd;

  setwindow(w2,27,12,53,14,3,0,8,'',TRUE);
  gotoxy(2,1);
  textcolor(7);
  textbackground(0);
  write('Move before which? ');
  repeat
  gotoxy(21,1);
  s2:=cstr(1);
  infield_inp_fgrd:=15;
  infield_inp_bkgd:=1;
  infield_out_fgrd:=3;
  infield_out_bkgd:=0;
  infield_allcaps:=false;
  infield_numbers_only:=TRUE;
  infield_escape_zero:=TRUE;
  infield_insert:=FALSE;
  infielde(s2,4);
  infield_escape_zero:=FALSE;
  infield_insert:=TRUE;
  j:=value(s2);
  until (j>=0) and (j<=noc+1);
  removewindow(w2);
  if (j=0) then begin
        exit;
  end;

         if ((j<>i) and (j<>i+1)) then begin
          memi(j-1);
          if j>i then k:=i else k:=i+1;
          seek(mdf,j-1);
          write(mdf,oldcmd);
          if j>i then memd(i-1) else memd(i);
        end;
      end;
    end;

    function showcolor(b:byte):STRING;
    var f1,b1:integer;
        tmpstr:string;
    begin
    tmpstr:='';
    f1:=0;
    b1:=0;
    if (b and 7<>0) then f1:=(b and 7);
    if (b and $70<>0) then b1:=((b shr 4) and 7);
    if (b and 128<>0) then inc(f1,16);
    if (b and 8<>0) then inc(f1,8);
    tmpstr:=cstr(f1);
    if length(tmpstr)=1 then tmpstr:='0'+tmpstr;
    tmpstr:='%'+tmpstr+cstr(b1)+'%';
    showcolor:=tmpstr;
    end;

    function showcommand(s1:string):STRING;
    var mf:file of menurec;
        m:menurec;
    begin
    if (titleline in editcmd.commandflags) then begin
        if (length(s1)<3) then begin
                showcommand:='None';
        end else
        showcommand:=showcolor(ord(s1[1]))+'Bracket%070% '+showcolor(ord(s1[2]))+
                'Command%070% '+showcolor(ord(s1[3]))+'Description%070%';
    end else
    case editcmd.cmdkeys[1] of
        '0':begin
                case editcmd.cmdkeys[2] of
                        '1','2':begin
                        assign(mf,adrv(systat.gfilepath)+mfilename+'.NXM');
                        {$I-} reset(mf); {$I+}
                        if (ioresult<>0) then begin
                                showcommand:='None';
                                exit;
                        end;
                        if (value(editcmd.mstring)>0) and (value(editcmd.mstring)<=filesize(mf))
                        then begin
                                seek(mf,value(editcmd.mstring)-1);
                                read(mf,m);
                                close(mf);
                                showcommand:='%150%'+cstr(value(editcmd.mstring))+' %030%'+m.name;
                        end else showcommand:='None';
                        end;
                        else begin
                            showcommand:=editcmd.mstring;
                        end;
                 end;
            end;
         else begin
            showcommand:=editcmd.mstring;
         end;
    end;
    end;

        procedure getcommandstring;
        var w8:windowrec;
            ch8:array[1..3] of string;
            c8,c3:char;
            cur8,cur2,top2,x8:integer;
            wback:windowrec;
            menub:menuptr;
            done8,done4:boolean;
        begin
        done8:=FALSE;
        if (titleline in editcmd.commandflags) then begin
            if pynqbox('Have this TitleLine Command change menu colors? ') then begin
            editcmd.mstring:=chr(menur^.gcol[1])+chr(menur^.gcol[2])+chr(menur^.gcol[3]);
            ch8[1]:='Bracket Color    ';
            ch8[2]:='Command Color    ';
            ch8[3]:='Description Color';
            setwindow(w8,20,10,60,15,3,0,8,'TitleLine Colors',TRUE);
            for cur8:=1 to 3 do begin
                gotoxy(2,cur8+1);
                textcolor(7);
                textbackground(0);
                write(ch8[cur8]);
            end;
            cur8:=1;
            repeat
            gotoxy(2,cur8+1);
            textcolor(15);
            textbackground(1);
            write(ch8[cur8]);
            while not(keypressed) do begin timeslice; end;
            c8:=readkey;
            case c8 of
                #0:begin
                        c8:=readkey;
                        case c8 of
                                #72:begin
                                    gotoxy(2,cur8+1);
                                    textcolor(7);
                                    textbackground(0);
                                    write(ch8[cur8]);
                                    dec(cur8);
                                    if (cur8=0) then cur8:=3;
                                    end;
                                #80:begin
                                    gotoxy(2,cur8+1);
                                    textcolor(7);
                                    textbackground(0);
                                    write(ch8[cur8]);
                                    inc(cur8);
                                    if (cur8=4) then cur8:=1;
                                    end;
                        end;
                   end;
               #13:begin
{                   
editcmd.mstring[cur8]:=chr(getcolor(3,8,ord(editcmd.mstring[cur8]),'Sample 
String'));}
                   changed:=TRUE;
                   end;
               #27:done8:=TRUE;
            end;
            until (done8);
            removewindow(w8);
         end else begin
                if (editcmd.mstring<>'') then begin
                editcmd.mstring:='';
                changed:=TRUE;
                end;
             end;
        end else
        case editcmd.cmdkeys[1] of
                '0':begin
                    case editcmd.cmdkeys[2] of
                    '1','2':begin
                    new(menub);
        menub^:=menur^;
  disposeall2;
  readinpointers2;
  menur^:=menub^;
  dispose(menub);
  cur2:=1;
  top2:=1;
  done4:=false;
  repeat
    for x8:=1 to 100 do rt.data[x8]:=-1;
    lp:=firstlp;
    listbox(wback,rt,top2,cur2,lp,6,8,74,21,3,0,8,'Menus - '+mfilename,'Menu Editor',TRUE);
    case rt.kind of
        0:begin
                c3:=chr(rt.data[100]);
                removewindow(wback);
                checkkey(c3);
                rt.data[100]:=-1;
          end;
        1:if rt.data[1]<>-1 then begin
                if (cstr(rt.data[1])<>editcmd.mstring) then begin
                editcmd.mstring:=cstr(rt.data[1]);
                changed:=TRUE;
                end;
                done4:=TRUE;
        end;
        2:begin
                done4:=TRUE;
        end;
      end;
  until (done4);
                        removewindow(wback);
                        window(4,11,75,20);
                        end;
                        else begin
                                infield_inp_fgrd:=15;
                                infield_inp_bkgd:=1;
                                infield_out_fgrd:=3;
                                infield_out_bkgd:=0;
                                infield_allcaps:=false;
                                infield_numbers_only:=false;
                                infield_show_colors:=TRUE;
                                infield_insert:=FALSE;
                                infield_maxshow:=45;
                                gotoxy(23,current+1);
                                textcolor(9);
                                textbackground(0);
                                write('>');
                                gotoxy(25,current+1);
                                s:=editcmd.mstring;
                                infielde(s,80);
                                gotoxy(25,current+1);
                                if (s<>editcmd.mstring) then begin
                                        changed:=TRUE;
                                        editcmd.mstring:=s;
                                end;
                                infield_insert:=TRUE;
                                infield_maxshow:=0;
                          end;
                       end;
                    end;
                 else begin
                                infield_inp_fgrd:=15;
                                infield_inp_bkgd:=1;
                                infield_out_fgrd:=3;
                                infield_out_bkgd:=0;
                                infield_allcaps:=false;
                                infield_numbers_only:=false;
                                infield_show_colors:=TRUE;
                                infield_insert:=FALSE;
                                infield_maxshow:=45;
                                gotoxy(23,current+1);
                                textcolor(9);
                                textbackground(0);
                                write('>');
                                gotoxy(25,current+1);
                                s:=editcmd.mstring;
                                infielde(s,80);
                                gotoxy(25,current+1);
                                if (s<>editcmd.mstring) then begin
                                        changed:=TRUE;
                                        editcmd.mstring:=s;
                                end;
                                infield_insert:=TRUE;
                                infield_maxshow:=0;
                       end;
              end;
      end;

begin
  if (readin) then begin
  ii:=1;
  changed:=FALSE;
  c:=' ';
  done:=FALSE;
  choice[1]:='Long Description     :';
  choice[2]:='Short Description    :';
  choice[3]:='Lightbar Description :';
  choice[4]:='Key(s) to Execute    :';
  choice[5]:='Menu Command         :';
  choice[6]:='Command Data         :';
  choice[7]:='Access String        :';
  choice[8]:='Command Flags        :';
  desc[1]:='Description Used for Generic Menu if ? is pressed                   ';
  desc[2]:='Description Used for Generic Menu Display                           ';
  desc[3]:='Description Used if Lightbar Menu Type selected                     ';
  desc[4]:='Key(s) to press to execute Menu Command                             ';
  desc[5]:='Menu Command Type                                                   ';
  desc[6]:='Data to control how this Menu Command functions                     ';
  desc[7]:='Access required to execute this Menu Command                        ';
  desc[8]:='Flags to control aspects of this Menu Command                       ';
  cursoron(FALSE);
  setwindow2(w,3,10,76,21,3,0,8,'View Menu Command '+cstr(ii)+'/'+cstr(noc),
        'Menu Editor: '+scurmenu,TRUE);
  for x:=1 to 8 do begin
        gotoxy(2,x+1);
        textcolor(7);
        textbackground(0);
        write(choice[x]);
  end;
  update:=TRUE;
  editing:=FALSE;
  current:=1;
  arrows:=FALSE;
  auto:=FALSE;
  seek(mdf,ii-1);
  read(mdf,editcmd);
  repeat
  oldii:=ii;
  if (update) then begin
  if (editing) then
  setwindow3(w,3,10,76,21,3,0,8,'Edit Menu Command '+cstr(ii)+'/'+cstr(noc),
        'Menu Editor: '+scurmenu,TRUE)
  else
  setwindow3(w,3,10,76,21,3,0,8,'View Menu Command '+cstr(ii)+'/'+cstr(noc),
        'Menu Editor: '+scurmenu,TRUE);
  if (arrows) then begin
        seek(mdf,ii-1);
        read(mdf,editcmd);
  end;
  with editcmd do begin
  gotoxy(25,2);
  textcolor(3);
  textbackground(0);
  cwrite(mln(ldesc,45));
  gotoxy(25,3);
  textcolor(3);
  textbackground(0);
  cwrite(mln(sdesc,35));
  gotoxy(25,5);
  textcolor(3);
  textbackground(0);
  write(mln(ckeys,14));
  gotoxy(25,6);
  write(dispcmd(cmdkeys));
  gotoxy(25,7);
  cwrite(mln(showcommand(mstring),45));
  gotoxy(25,8);
  write(mln(acs,20));
  gotoxy(25,9);
  write(mln(showcflags,45));
  update:=FALSE;
  arrows:=FALSE;
  end;
  end;
  if (editing) then begin
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
        window(4,11,75,20);
  end else begin
        window(1,1,80,25);
        gotoxy(1,25);
        textcolor(14);
        textbackground(0);
        clreol;
        write('Esc');
        textcolor(7);
        write('=Exit ');
        textcolor(14);
        textbackground(0);
        write('Enter');
        textcolor(7);
        write('=Edit Cmd ');
        textcolor(14);
        textbackground(0);
        write('Ins');
        textcolor(7);
        write('=Insert Cmd ');
        textcolor(14);
        textbackground(0);
        write('Del');
        textcolor(7);
        write('=Delete Cmd ');
        textcolor(14);
        textbackground(0);
        write('Alt-M');
        textcolor(7);
        write('=Move Cmd ');
        window(4,11,75,20);
  end;      
        with editcmd do begin
          while not(keypressed) do begin timeslice; end;
          c:=readkey;
          case c of
            #0:begin
                c:=readkey;
                checkkey(c);
                case c of
                  #68:if (editing) then begin
                          gotoxy(2,current+1);
                          textcolor(7);
                          textbackground(0);
                          write(choice[current]);
                          current:=1;
                          editing:=FALSE;
                          update:=TRUE;
                          if (changed) then begin
                                auto:=TRUE;
                                changed:=TRUE;
                          end;
                      end;
                    #72:if (editing) then begin
                          gotoxy(2,current+1);
                          textcolor(7);
                          textbackground(0);
                          write(choice[current]);
                          dec(current);
                          if (current=0) then current:=8;
                        end;
                    #75:if not(editing) then begin
                        if (ii>1) then dec(ii) else ii:=noc;
                        update:=TRUE;
                        arrows:=TRUE;
                       end;
                    #77:if not(editing) then begin
                        if (ii<noc) then inc(ii) else ii:=1;
                        update:=TRUE;
                        arrows:=TRUE;
                        end;
                    #80:if (editing) then begin
                          gotoxy(2,current+1);
                          textcolor(7);
                          textbackground(0);
                          write(choice[current]);
                          inc(current);
                          if (current=9) then current:=1;
                        end;
                    #82:if not(editing) then begin
                        memi(ii-1);
                        update:=TRUE;
                        arrows:=TRUE;
                        end;
                    #83:if not(editing) then begin
                        if pynqbox('Delete this Menu Command? ') then begin
                        memd(ii-1);
                        if (ii>noc) then ii:=noc;
                        if (noc=0) then begin
                                done:=TRUE;
                                changed:=FALSE;
                                editing:=FALSE;
                        end;
                        update:=TRUE;
                        arrows:=TRUE;
                        end;
                        end;
                    #50:if not(editing) then begin
                        memp(ii);
                        window(4,11,75,20);
                        update:=TRUE;
                        arrows:=TRUE;
                        end;
                end;
               end;
            #13:if (editing) then begin
                          gotoxy(2,current+1);
                          textcolor(7);
                          textbackground(0);
                          write(choice[current]);
                case current of
                        1:begin
                                infield_inp_fgrd:=15;
                                infield_inp_bkgd:=1;
                                infield_out_fgrd:=3;
                                infield_out_bkgd:=0;
                                infield_allcaps:=false;
                                infield_numbers_only:=false;
                                infield_show_colors:=TRUE;
                                infield_maxshow:=45;
                                infield_insert:=TRUE;
                                gotoxy(23,current+1);
                                textcolor(9);
                                textbackground(0);
                                write('>');
                                gotoxy(25,current+1);
                                s:=ldesc;
                                infielde(s,70);
                                gotoxy(25,current+1);
                                if (s<>ldesc) then begin
                                        changed:=TRUE;
                                        ldesc:=s;
                                end;
                                infield_maxshow:=0;
                                infield_insert:=TRUE;
                        end;
                        2:begin
                                infield_inp_fgrd:=15;
                                infield_inp_bkgd:=1;
                                infield_out_fgrd:=3;
                                infield_out_bkgd:=0;
                                infield_allcaps:=false;
                                infield_numbers_only:=false;
                                infield_show_colors:=TRUE;
                                infield_insert:=TRUE;
                                gotoxy(23,current+1);
                                textcolor(9);
                                textbackground(0);
                                write('>');
                                gotoxy(25,current+1);
                                s:=sdesc;
                                infielde(s,35);
                                gotoxy(25,current+1);
                                if (s<>sdesc) then begin
                                        changed:=TRUE;
                                        sdesc:=s;
                                end;
                                infield_insert:=TRUE;
                        end;
                        3:begin
                        end;
                        4:begin
                                infield_inp_fgrd:=15;
                                infield_inp_bkgd:=1;
                                infield_out_fgrd:=3;
                                infield_out_bkgd:=0;
                                infield_allcaps:=false;
                                infield_numbers_only:=false;
                                infield_show_colors:=FALSE;
                                infield_insert:=TRUE;
                                infield_clear:=TRUE;
                                gotoxy(23,current+1);
                                textcolor(9);
                                textbackground(0);
                                write('>');
                                gotoxy(25,current+1);
                                s:=ckeys;
                                infielde(s,14);
                                gotoxy(25,current+1);
                                if (s<>ckeys) then begin
                                        changed:=TRUE;
                                        ckeys:=s;
                                end;
                                infield_insert:=TRUE;
                                infield_clear:=FALSE;
                        end;
                        5:begin
                                if not(titleline in editcmd.commandflags) then
                                begin
                                s:=getmenucmd;
                                if (s<>cmdkeys) and (s<>'') then begin
                                        changed:=TRUE;
                                        cmdkeys:=s;
                                end;
                                window(4,11,75,20);
                                textcolor(3);
                                textbackground(0);
                                gotoxy(25,6);
                                write(dispcmd(cmdkeys));
                                end;
                        end;
                        6:begin
                        getcommandstring;
                        window(4,11,75,20);
                        gotoxy(25,7);
                        textcolor(3);
                        textbackground(0);
                        cwrite(mln(showcommand(mstring),45));
                        end;
                        7:begin
                                infield_inp_fgrd:=15;
                                infield_inp_bkgd:=1;
                                infield_out_fgrd:=3;
                                infield_out_bkgd:=0;
                                infield_allcaps:=false;
                                infield_numbers_only:=false;
                                infield_show_colors:=FALSE;
                                infield_insert:=FALSE;
                                gotoxy(23,current+1);
                                textcolor(9);
                                textbackground(0);
                                write('>');
                                gotoxy(25,current+1);
                                s:=acs;
                                infielde(s,20);
                                gotoxy(25,current+1);
                                if (s<>acs) then begin
                                        changed:=TRUE;
                                        acs:=s;
                                end;
                                infield_insert:=TRUE;
                        end;
                        8:begin
                                getcflags;
                                window(4,11,75,20);
                                textcolor(3);
                                textbackground(0);
                                gotoxy(25,9);
                                write(mln(showcflags,45));
                                if not(titleline in editcmd.commandflags)
                                then begin
                                gotoxy(25,6);
                                write(dispcmd(cmdkeys));
                                end;
                        end;
                end;
                end else begin
                        editing:=TRUE;
                        update:=TRUE;
                end;
            #27:if (editing) then begin
                          gotoxy(2,current+1);
                          textcolor(7);
                          textbackground(0);
                          write(choice[current]);
                          current:=1;
                          editing:=FALSE;
                          update:=TRUE
                end else done:=TRUE;
          end;
        end;
      if (changed) and ((done) or (arrows) or not(editing)) then begin
        if not(auto) then auto:=pynqbox('Save changes? ');
        if (auto) then begin
                seek(mdf,oldii-1);
                write(mdf,editcmd);
        end else begin
                arrows:=TRUE;
        end;
        changed:=FALSE;
        auto:=FALSE;
        end;
      until (done);
      removewindow(w);
      if (filesize(mdf)=0) then begin
        close(mdf);
        {$I-} erase(mdf); {$I+}
        if (ioresult<>0) then begin end;
      end else close(mdf);
  end;
end;

end.
