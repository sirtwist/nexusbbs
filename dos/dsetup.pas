{----------------------------------------------------------------------------}
{ Nexus Bulletin Board System                                                }
{                                                                            }
{ All material contained herein is                                           }
{  (c) Copyright 1996 Epoch Software.  All Rights Reserved.                  }
{  (c) Copyright 1994-95 Intuitive Vision Software.  All Rights Reserved.    }
{                                                                            }
{ MODULE     :  DSETUP.PAS  (Door/Editors/Chat Configuration Module)         }
{ AUTHOR     :  George A. Roberts IV                                         }
{                                                                            }
{----------------------------------------------------------------------------}
{ Nexus and Nexecutable are trademarks of Epoch Software.                    }
{----------------------------------------------------------------------------}
{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R-,S+,V-}
unit dsetup;

interface

uses dos,crt,misc,myio,procspec;

procedure dset;

implementation

function doortype(b:byte):string;
begin
case b of
        1:doortype:='DOOR.SYS              ';
        2:doortype:='DOORFILE.SR (SR Games)';
        3:doortype:='CHAIN.TXT             ';
        4:doortype:='DORINFO1.DEF          ';
        5:doortype:='SFDOORS.DAT           ';
        6:doortype:='CALLINFO.BBS          ';
        7:doortype:='No Drop File          ';
        else 
          doortype:='Not Defined           ';
end;
end;

function doortype2(b:byte):string;
begin
case b of
        1:doortype2:='%070%(DOOR.SYS)    ';
        2:doortype2:='%070%(DOORFILE.SR) ';
        3:doortype2:='%070%(CHAIN.TXT)   ';
        4:doortype2:='%070%(DORINFO1.DEF)';
        5:doortype2:='%070%(SFDOORS.DAT) ';
        6:doortype2:='%070%(CALLINFO.BBS)';
        7:doortype2:='%070%(No Drop File)';
        else 
          doortype2:='%070%(Not Defined) ';
end;
end;

procedure dsetup1(dtype:byte);
var df:file of doorrec;
    door:doorrec;
    currentdoor,x:integer;
    tags:array[1..10] of string[25];
    desc:array[1..10] of string;
    top,cur,maxdesc,x2,maxdoors,savey,Y:integer;
    firstlp,lp,lp2:listptr;
    chat:boolean;
    rt:returntype;
    c,c3:char;
    wind,w2:windowrec;
    s:string;
    auto,delt,done3,insert,noread,newd,editing,changed,done,done2:boolean;

function fname(b:byte):string;
begin
case b of
        1,3:fname:='DOORS.DAT';
        2:fname:='EDITORS.DAT';
end;
end;

procedure deldoor(i:integer);
var x,currentdoor2:integer;
begin
                                        currentdoor2:=i;
                                        if not(currentdoor2>=filesize(df)-1) then
                                        for x:=(currentdoor2+1) to (filesize(df)-1) do begin
                                        seek(df,x);
                                        read(df,door);
                                        seek(df,x-1);
                                        write(df,door);
                                        end;
                                        if (filesize(df)>2) then begin
                                        seek(df,filesize(df)-1);
                                        truncate(df);
                                        end else begin
                                        seek(df,1);
                                        fillchar(door,sizeof(door),#0);
                                        door.doordroptype:=7;
                                        door.showloadingstring:=TRUE;
                                        door.eflags:=[selecttagline];
                                        write(df,door);
                                        end;
                                        if (currentdoor>filesize(df)-1) then currentdoor:=filesize(df)-1;
                                        seek(df,currentdoor);
                                        read(df,door);
end;

begin
y:=1;
newd:=true;
cursoron(false);
chat:=false;
currentdoor:=1;
savey:=currentdoor;
editing:=false;
changed:=false;
auto:=FALSE;
case dtype of
        1:begin
tags[1]:='Description of Door    :';
tags[2]:='Path/Filename To Door  :';
tags[3]:='Drop File Format       :';
tags[4]:='Drop File Path         :';
tags[5]:='Door Uses RIPscrip     :';
tags[6]:='Use Real Name          :';
tags[7]:='Maximum Time Allowed   :';
tags[8]:='Swapping Type          :';
tags[9]:='Show "Loading" String  :';
desc[1]:='Description/Name of Door to be used for Display Purposes';
desc[2]:='Path/Filename to .BAT or .EXE file for Door';
desc[3]:='Drop File Format to use when running Door';
desc[4]:='Path to place Drop File in.  MCI codes are valid.';
desc[5]:='Does this Door use RIP Graphics?  Tells Nexus to enable RIP.';
desc[6]:='Use Real Name in Drop File?  Only certain formats.';
desc[7]:='Max Time Allowed in Door.  "0" to always use User Time Left.';
desc[8]:='Swapping Setting for this door.                 ';
desc[9]:='Show "Loading <Description>..." to User Before Running.';
maxdesc:=9;
          end;
        2:begin
tags[1]:='Description of Editor  :';
tags[2]:='Path/Filename To Editor:';
tags[3]:='Drop File Format       :';
tags[4]:='Drop File Path         :';
tags[5]:='Editor Uses RIPscrip   :';
tags[6]:='Use Real Name          :';
tags[7]:='Maximum Time Allowed   :';
tags[8]:='Swapping Type          :';
tags[9]:='Show "Loading" String  :';
tags[10]:='Tagline prompt after?  :';
maxdesc:=10;
desc[1]:='Description/Name of Editor to be used for Display Purposes';
desc[2]:='Path/Filename to .BAT or .EXE file for Editor';
desc[3]:='Drop File Format to use when running Editor';
desc[4]:='Path to place Drop File in.  MCI codes are valid.';
desc[5]:='Does this Editor use RIP Graphics?  Tells Nexus to enable RIP.';
desc[6]:='Use Real Name in Drop File?  Only certain formats.';
desc[7]:='Max Time Allowed in Editor.  -1 to always use User Time Left.';
desc[8]:='Swapping Setting for this Editor.                 ';
desc[9]:='Show "Loading <Description>..." to User Before Running.';
desc[10]:='Should Nexus prompt the user for a tagline after returning?';
          end;
        3:begin
tags[1]:='Description of Chat    :';
tags[2]:='Path/Filename To Chat  :';
tags[3]:='Drop File Format       :';
tags[4]:='Drop File Path         :';
tags[5]:='Chat Uses RIPscrip     :';
tags[6]:='Use Real Name          :';
tags[7]:='Maximum Time Allowed   :';
tags[8]:='Swapping Type          :';
tags[9]:='Show "Loading" String  :';
desc[1]:='Description/Name of Chat Program to be used for Display Purposes';
desc[2]:='Path/Filename to .BAT or .EXE file for Chat Program';
desc[3]:='Drop File Format to use when running Chat Program';
desc[4]:='Path to place Drop File in.  MCI codes are valid.';
desc[5]:='Does this Chat Program use RIP Graphics?  Tells Nexus to enable RIP.';
desc[6]:='Use Real Name in Drop File?  Only certain formats.';
desc[7]:='Max Time Allowed in Chat.  "0" to always use User Time Left.';
desc[8]:='Swapping Setting for this Chat Program.                 ';
desc[9]:='Show "Loading <Description>..." to User Before Running.';
maxdesc:=9;
chat:=TRUE;
currentdoor:=0;
savey:=0;
end;
end;
insert:=false;
fillchar(door,sizeof(door),#0);
door.doordroptype:=7;
door.showloadingstring:=TRUE;
door.eflags:=[SelectTagline];
if (dtype=2) then assign(df,adrv(systat.gfilepath)+'EDITORS.DAT') else
assign(df,adrv(systat.gfilepath)+'DOORS.DAT');
filemode:=66;
{$I-} reset(df); {$I+}
if (ioresult<>0) then begin
        if pynqbox('Error opening '+fname(dtype)+'.  Recreate? ') then begin
        rewrite(df);
        write(df,door);
        write(df,door);
        maxdoors:=1;
        end else exit;
end;
done:=false;
maxdoors:=filesize(df)-1;
done2:=false;
if (chat) then
setwindow2(wind,1,6,78,23,3,0,8,'View External Chat Setup ',
                'Door Editor',TRUE)
else
if (dtype=2) then
setwindow2(wind,1,6,78,23,3,0,8,'View Editor '+cstr(currentdoor)+'/'+cstr(maxdoors),
                'Door Editor',TRUE)
else
setwindow2(wind,1,6,78,23,3,0,8,'View Door '+cstr(currentdoor)+'/'+cstr(maxdoors),
                'Door Editor',TRUE);

repeat
seek(df,currentdoor);
read(df,door);
maxdoors:=filesize(df)-1;
savey:=currentdoor;
if (editing) then begin
        if (chat) then begin
                setwindow3(wind,1,6,78,23,3,0,8,'Edit External Chat Setup ',
                        'Door Editor',TRUE);
        end else
                if (dtype=2) then begin
                setwindow3(wind,1,6,78,23,3,0,8,'Edit Editor '+cstr(currentdoor)+'/'+cstr(maxdoors),
                        'Door Editor',TRUE);
                end else begin
                setwindow3(wind,1,6,78,23,3,0,8,'Edit Door '+cstr(currentdoor)+'/'+cstr(maxdoors),
                        'Door Editor',TRUE);
                end;

end else if not(newd) then begin
        if (chat) then begin
                setwindow3(wind,1,6,78,23,3,0,8,'View External Chat Setup ',
                        'Door Editor',TRUE);
                end else
                if (dtype=2) then begin
                setwindow3(wind,1,6,78,23,3,0,8,'View Editor '+cstr(currentdoor)+'/'+cstr(maxdoors),
                        'Door Editor',TRUE);
                end else begin
                setwindow3(wind,1,6,78,23,3,0,8,'View Door '+cstr(currentdoor)+'/'+cstr(maxdoors),
                        'Door Editor',TRUE);
                end;

end;
if (newd) then newd:=false;
for y:=1 to maxdesc do begin
if (door.doordroptype=7) and (y in [4,6,7]) then begin end else begin
gotoxy(2,y+1);
textcolor(7);
textbackground(0);
write(tags[y]);
end;
end;
textcolor(3);
textbackground(0);
gotoxy(27,2);
write(mln('',40));
gotoxy(27,2);
cwrite(mln(door.doorname,40));
gotoxy(27,3);
textcolor(3);
textbackground(0);
write(mln(door.doorfilename,45));
gotoxy(27,4);
write(doortype(door.doordroptype));
gotoxy(27,5);
if (door.doordroptype=7) then 
        write(mln('',45))
else
write(mln(door.doordroppath,45));
gotoxy(27,6);
(* write(syn(door.ripenabled)); *)
gotoxy(27,7);
if (door.doordroptype=7) then 
        write(mln('',45))
else
write(syn(door.realname));
gotoxy(27,8);
if (door.doordroptype=7) then 
        write(mln('',45))
else
write(mln(cstr(trunc(door.maxminutes)),5));
gotoxy(27,10);
write(syn(door.showloadingstring));
if (dtype=2) then begin
gotoxy(27,11);
write(syn(selecttagline in door.eflags));
end;
gotoxy(2,13);
textcolor(7);
textbackground(0);
write('Today''s Activity     -   Times Used: ');
textcolor(12);
write(mln(cstr(door.Tracktoday.Timesused),10));
textcolor(7);
write('  Minutes Used: ');
textcolor(12);
write(mln(cstr(door.Tracktoday.MinutesUsed),16));
gotoxy(2,14);
textcolor(7);
write('Yesterday''s Activity -   Times Used: ');
textcolor(12);
write(mln(cstr(door.Trackyesterday.Timesused),10));
textcolor(7);
write('  Minutes Used: ');
textcolor(12);
write(mln(cstr(door.Trackyesterday.MinutesUsed),16));
gotoxy(2,15);
textcolor(7);
write('Total Activity       -   Times Used: ');
textcolor(12);
write(mln(cstr(door.Trackforever.Timesused),10));
textcolor(7);
write('  Minutes Used: ');
textcolor(12);
write(mln(cstr(door.Trackforever.MinutesUsed),16));
y:=1;
done2:=FALSE;
repeat
if (editing) then begin
        window(1,1,80,25);
        gotoxy(1,25);
        textbackground(0);
        clreol;
        cwrite('%140%Esc%070%=Exit %140%'+desc[y]);
        window(2,7,77,22);
        gotoxy(2,y+1);
        textcolor(15);
        textbackground(1);
        write(tags[y]);
        textcolor(7);
end else begin
window(1,1,80,25);
gotoxy(1,25);
        textbackground(0);
clreol;
if (chat) then begin
cwrite('%140%Esc%070%=Exit %140%F1%070%=Help %140%Enter%070%=Edit %140%This is the external chat command configuration');
end else begin
cwrite('%140%Esc%070%=Exit %140%F1%070%=Help %140%Enter%070%=Edit %140%Ins%070%=Add %140%Del%070%=Delete'+
       ' %140%Alt-L%070%=List');
end;
window(2,7,77,22);
end;
while not(keypressed) do begin timeslice; end;
c:=readkey;
case c of
        #0:begin
                c:=readkey;
                checkkey(c);
                case c of
                        #38:begin { List Function }
                                if not(chat) and not(editing) then begin
                                if not((maxdoors=1) and (currentdoor=1) and 
                                        (door.doorname='') and not(filesize(df)=1)) then begin
                                new(lp);
                                seek(df,1);       
                                read(df,door);
                                lp^.p:=NIL;
                                lp^.list:=mln(door.doorname,30)+'   '+doortype2(door.doordroptype);
                                firstlp:=lp;
                                x:=1;
                                while not(eof(df)) do begin
                                read(df,door);
                                new(lp2);
                                lp2^.p:=lp;
                                lp^.n:=lp2;
                                lp2^.list:=mln(door.doorname,30)+'   '+doortype2(door.doordroptype);
                                lp:=lp2;
                                end;
                                seek(df,currentdoor);
                                read(df,door);
                                maxdoors:=filesize(df)-1;
                                lp^.n:=NIL;
                                done3:=false;
                                for x:=1 to 100 do rt.data[x]:=-1;
                                repeat
                                lp:=firstlp;
                                top:=currentdoor;
                                cur:=currentdoor;
                                listbox(w2,rt,top,cur,lp,15,8,65,21,3,0,8,'Door Editor','',TRUE);
                                case rt.kind of
                                        0:begin
                                                c3:=chr(rt.data[100]);
                                                checkkey(c3);
                                                rt.data[100]:=-1;
                                                removewindow(w2);
                                          end;
                                        1:begin
                                                removewindow(w2);
                                                savey:=currentdoor;
                                                if rt.data[1]<>-1 then begin
                                                                currentdoor:=rt.data[1];
                                                                x:=100;
                                                                done2:=TRUE;
                                                                done3:=TRUE;
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
                                                done3:=TRUE;
                                        end;
                                        4:begin
                                                delt:=FALSE;
                                                for x:=1 to 100 do begin
                                                        if rt.data[x]<>-1 then deldoor(rt.data[x]);
                                                        delt:=TRUE;
                                                end;
                                                if (delt) then begin
                                                while (lp<>NIL) do begin
                                                        lp2:=lp^.n;
                                                        dispose(lp);
                                                        lp:=lp2;
                                                end;
                                new(lp);
                                seek(df,1);       
                                read(df,door);
                                lp^.p:=NIL;
                                lp^.list:=mln(door.doorname,30);
                                firstlp:=lp;
                                x:=1;
                                while (x<99) and (not(eof(df))) do begin
                                inc(x);
                                seek(df,x);
                                read(df,door);
                                new(lp2);
                                lp2^.p:=lp;
                                lp^.n:=lp2;
                                lp2^.list:=mln(door.doorname,30);
                                lp:=lp2;
                                end;
                                seek(df,currentdoor);
                                read(df,door);
                                maxdoors:=filesize(df)-1;
                                lp^.n:=NIL;
                                end;
                                        end;
                                end;
                                until(done3);
                                end;
                                removewindow(w2);
                                end;
                        end;
                        #68:begin
                                if (editing) then begin
                                        editing:=false;
                                        auto:=TRUE;
                                end else done:=TRUE; 
                                savey:=currentdoor;
                                done2:=TRUE;
                            end;
                        #72:begin       { Up Arrow }
                                gotoxy(2,y+1);
                                textcolor(7);
                                textbackground(0);
                                write(tags[y]);
                                dec(y);
                                if (door.doordroptype=7) then begin
                                case y of
                                        4:dec(y);
                                        7:dec(y,2);
                                end;
                                end;
                                if (y<1) then y:=maxdesc;
                        end;
                        #75:begin       { Left Arrow }
                                if not(chat) and not(editing) then begin
                                        dec(currentdoor);
                                        savey:=currentdoor+1;
                                        done2:=TRUE;
                                        if (currentdoor<1) then 
                                                currentdoor:=filesize(df)-1;
                                end;
                        end;
                        #77:begin       { Right Arrow }
                                if not(chat) and not(editing) then begin
                                        inc(currentdoor);
                                        savey:=currentdoor-1;
                                        done2:=TRUE;
                                        if (currentdoor>filesize(df)-1) then
                                                currentdoor:=1;
                                end;
                        end;
                        #80:begin       { Down Arrow }
                                gotoxy(2,y+1);
                                textcolor(7);
                                textbackground(0);
                                write(tags[y]);
                                inc(y);
                                if (door.doordroptype=7) then begin
                                        case y of
                                                4:inc(y);
                                                6:inc(y,2);
                                        end;
                                end;
                                if (y>maxdesc) then y:=1;
                        end;
                        #82:begin       { Insert Door }
                                if not(editing) and not(chat) then begin
                                if (maxdoors=1) and (currentdoor=1) and (door.doorname='') then begin
                                        insert:=TRUE;
                                        done2:=TRUE;
                                        editing:=TRUE;
                                end else begin

                                savey:=currentdoor;
                                seek(df,filesize(df));
                                fillchar(door,sizeof(door),#0);
                                door.doordroptype:=7;
                                door.showloadingstring:=TRUE;
                                door.eflags:=[SelectTagline];
                                write(df,door);
                                currentdoor:=filesize(df)-1;
                                insert:=TRUE;
                                done2:=TRUE;
                                editing:=TRUE;
                                end;
                                end;
                        end;
                        #83:begin {delete door}
                                if not(editing) then begin
                                        deldoor(currentdoor);
                                        done2:=TRUE;
                                        editing:=FALSE;
                                end;
                        end;

                end;
        end;
        #13:begin  { Edit Data }
                if (editing) then begin
                gotoxy(2,y+1);
                textcolor(7);
                textbackground(0);
                write(tags[y]);
                cursoron(TRUE);
                case y of
                     1:begin
                        s:=door.Doorname;
                                infield_inp_fgrd:=15;
                                infield_inp_bkgd:=1;
                                infield_out_fgrd:=3;
                                infield_out_bkgd:=0;
                                infield_allcaps:=false;
                                infield_numbers_only:=false;
                                infield_show_colors:=TRUE;
                                gotoxy(25,y+1);
                                textcolor(9);
                                textbackground(0);
                                write('>');
                                gotoxy(27,y+1);
                                infielde(s,40);
                                gotoxy(27,y+1);
                                if (s<>door.doorname) then begin
                                        door.doorname:=s;
                                        changed:=TRUE;
                                end;
                                infield_show_colors:=FALSE;
                        end;
                     2:begin
                        s:=door.Doorfilename;
                                infield_inp_fgrd:=15;
                                infield_inp_bkgd:=1;
                                infield_out_fgrd:=3;
                                infield_out_bkgd:=0;
                                infield_allcaps:=TRUE;
                                infield_numbers_only:=false;
                                infield_maxshow:=45;
                                gotoxy(25,y+1);
                                textcolor(9);
                                textbackground(0);
                                write('>');
                                gotoxy(27,y+1);
                                infielde(s,79);
                                infield_maxshow:=0;
                                if (s<>door.doorfilename) then begin
                                        door.doorfilename:=s;
                                        changed:=TRUE;
                                end;
                        end;
                     3:begin
                        inc(door.doordroptype);
                        if (door.doordroptype>7) then door.doordroptype:=1;
                        gotoxy(27,y+1);
                        textcolor(3);
                        textbackground(0);
                        write(doortype(door.doordroptype));
                        changed:=TRUE;
                        if (door.doordroptype=7) then begin
                                textcolor(3);
                                textbackground(0);
                                gotoxy(2,5);
                                write(mln('',70));
                                gotoxy(2,7);
                                write(mln('',70));
                                gotoxy(2,8);
                                write(mln('',70));
                        end;
                        if (door.doordroptype=1) then begin
                                textcolor(7);
                                textbackground(0);
                                gotoxy(2,5);
                                write(tags[4]);
                                gotoxy(2,7);
                                write(tags[6]);
                                gotoxy(2,8);
                                write(tags[7]);
                                textcolor(3);
                                textbackground(0);
                                gotoxy(27,5);
                                write(mln(door.doordroppath,45));
                                gotoxy(27,7);
                                write(syn(door.realname)+'      ');
                                gotoxy(27,8);
                                write(cstr(trunc(door.maxminutes))+'     ');
                        end;
                        end;
                     4:begin
                        if (door.doordroptype<7) then begin
                        s:=door.Doordroppath;
                                infield_inp_fgrd:=15;
                                infield_inp_bkgd:=1;
                                infield_out_fgrd:=3;
                                infield_out_bkgd:=0;
                                infield_allcaps:=TRUE;
                                infield_numbers_only:=false;
                                infield_put_slash:=TRUE;
                                gotoxy(25,y+1);
                                textcolor(9);
                                textbackground(0);
                                write('>');
                                gotoxy(27,y+1);
                                infield_maxshow:=45;
                                infielde(s,79);
                                infield_maxshow:=0;
                                infield_put_slash:=FALSE;
                                if (s<>door.doordroppath) then begin
                                        door.doordroppath:=s;
                                        if door.doordroppath[length(door.doordroppath)]<>'\' then
                                                door.doordroppath:=door.doordroppath+'\';
                                        changed:=TRUE;
                                end;
                        end;
                        end;
(*                     5:begin
                        door.ripenabled:=not(door.ripenabled);
                        gotoxy(27,y+1);
                        textcolor(3);
                        textbackground(0);
                        write(syn(door.ripenabled));
                        changed:=TRUE;
                        end; *)
                     6:begin
                        if (door.doordroptype<7) then begin
                        door.realname:=not(door.realname);
                        gotoxy(27,y+1);
                        textcolor(3);
                        textbackground(0);
                        write(syn(door.realname));
                        changed:=TRUE;
                        end;
                        end;
                     7:begin  { Max Minutes }
                        if (door.doordroptype<7) then begin
                        s:=cstr(trunc(door.maxminutes));
                                infield_inp_fgrd:=15;
                                infield_inp_bkgd:=1;
                                infield_out_fgrd:=3;
                                infield_out_bkgd:=0;
                                infield_allcaps:=false;
                                infield_numbers_only:=TRUE;
                                gotoxy(25,y+1);
                                textcolor(9);
                                textbackground(0);
                                write('>');
                                gotoxy(27,y+1);
                                infielde(s,4);
                                if ((s<>'') and (s<>cstr(trunc(door.maxminutes)))) then begin
                                        door.maxminutes:=value(s);
                                        changed:=TRUE;
                                end;
                                end;
                     end;
                     8:begin
                       end;
                     9:begin
                        door.showloadingstring:=not(door.showloadingstring);
                        gotoxy(27,y+1);
                        textcolor(3);
                        textbackground(0);
                        write(syn(door.showloadingstring));
                        changed:=TRUE;
                        end;
                     10:begin
                        if (SelectTagline in door.eflags) then
                                door.eflags:=door.eflags-[SelectTagline]
                                else
                                door.eflags:=door.eflags+[SelectTagline];
                        gotoxy(27,y+1);
                        textcolor(3);
                        textbackground(0);
                        write(syn(selecttagline in door.eflags));
                        changed:=TRUE;
                        end;
                end;
                cursoron(FALSE);
                gotoxy(2,y+1);
                textcolor(15);
                textbackground(1);
                write(tags[y]);
                end else begin 
                        editing:=TRUE;
                        done2:=TRUE;
                end;
        end;
        #27:begin 
                if (editing) then begin
                        editing:=false;
                end else done:=TRUE; 
                savey:=currentdoor; done2:=TRUE; 
        end;
end;
until (done2);
if (changed) then begin
        if (door.doorname='') then begin
                case dtype of
                        1:begin
                          displaybox('A Defined Door Must have a Name.',2000);
                          editing:=TRUE;
                          end;
                        2:begin
                          displaybox('A Defined Editor Must have a Name.',2000);
                          editing:=TRUE;
                          end;
                        3:begin
                          changed:=FALSE;
                          end;
                end;
        end else begin
        if not(auto) then auto:=pynqbox('Save changes? ');
        if (auto) then begin
        seek(df,savey);
        write(df,door);
        auto:=FALSE;
        end;
        changed:=false;
        insert:=false;
        end;
end else if (insert) and not(editing) then begin
        if (filesize(df)-1>1) then begin
        seek(df,filesize(df)-1);
        truncate(df);
        if (currentdoor>filesize(df)-1) then currentdoor:=filesize(df)-1;
        seek(df,currentdoor);
        read(df,door);
        end;
        insert:=false;
end;
until (done);
close(df);
removewindow(wind);
end;

procedure dset;
  var d:boolean;
      current,x:integer;
      choice:array[1..3] of string[40];
      desc:array[1..3] of string;
      s:string;
      c:char;
      w:windowrec;
  begin
  d:=FALSE;
  setwindow(w,25,11,55,17,3,0,8,'External Programs',TRUE);
  choice[1]:='External Chat Program Setup';
  choice[2]:='External Editors Setup     ';
  choice[3]:='External Door Program Setup';
  desc[1]:='Configuration for and external sysop-user chat program';
  desc[2]:='Configuration for your external message editors       ';
  desc[3]:='Configuration for your external door programs         ';
  for x:=1 to 3 do begin
                textcolor(7);
                textbackground(0);
                gotoxy(2,x+1);
                write(choice[x]);
  end;
  current:=1;
  repeat
        window(1,1,80,25);
        gotoxy(1,25);
        textbackground(0);
        clreol;
        cwrite('%140%Esc%070%=Exit %140%'+desc[current]);
        window(26,12,54,16);
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
                                #72:begin { Up Arrow }
                                        gotoxy(2,current+1);
                                        textcolor(7);
                                        textbackground(0);
                                        write(choice[current]);
                                        dec(current);
                                        if (current=0) then current:=3;
                                end;
                                #80:begin { Down Arrow }
                                        gotoxy(2,current+1);
                                        textcolor(7);
                                        textbackground(0);
                                        write(choice[current]);
                                        inc(current);
                                        if (current=4) then current:=1;
                                end;
                        end;
                end;
                #13:begin
                    case current of
                        1:dsetup1(3);
                        2:dsetup1(2);
                        3:dsetup1(1);
                    end;
                    window(26,12,54,16);
                end;
                #27:d:=true;
            end;
  until (d);
  removewindow(w);
end;


end.


