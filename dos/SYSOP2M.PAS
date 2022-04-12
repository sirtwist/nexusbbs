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
unit sysop2m;

interface

uses
  crt, dos, myio, misc, procspec,spawno;

procedure cdromdrives;
procedure cdromdisks;
procedure filebasemanager(nexusdir:string; ppath:string);
procedure omssetup(nexusdir:string; ppath:string);
procedure editlanguage;

implementation

procedure editlanguage;
var langf:file of languagerec;
    lang:languagerec;
    choices:array[1..7] of string[30];
    desc:array[1..7] of string;
    langread,numlang,current,clang:integer;
    x:integer;
    s:string;
    c:char;
    changed,update,arrows,editing,ok,done:boolean;


        procedure langi(inum:integer);
        var i:integer;
        begin
        if (inum+1<=numlang) then
        for i:=numlang downto (inum+1) do begin
                seek(langf,i);
                read(langf,lang);
                seek(langf,i+1);
                write(langf,lang);
        end;
        seek(langf,inum+1);
        lang.name:='New Nexus Language';
        lang.filename:='NEWLANG';
        lang.menuname:='ENGLISH';
        lang.displaypath:='';
        lang.checkdefpath:=FALSE;
        lang.access:='';
        lang.startmenu:=6;
        write(langf,lang);
        inc(numlang);
        end;

        procedure langd(inum:integer);
        var i:integer;
        begin
        for i:=(inum+1) to numlang do begin
                seek(langf,i);
                read(langf,lang);
                seek(langf,i-1);
                write(langf,lang);
        end;
        seek(langf,numlang);
        truncate(langf);
        dec(numlang);
        end;

begin
ok:=FALSE;
done:=FALSE;
update:=TRUE;
arrows:=FALSE;
editing:=FALSE;
changed:=FALSE;
assign(langf,adrv(systat.gfilepath)+'LANGUAGE.DAT');
filemode:=66;
{$I-} reset(langf); {$I+}
if (ioresult<>0) then begin
        ok:=recreatelanguage;
        if not(ok) then begin
        displaybox('Error Opening LANGUAGE.DAT',3000);
        exit;
        end;
        {$I-} reset(langf); {$I+}
        if (ioresult<>0) then begin
        displaybox('Error Opening LANGUAGE.DAT',3000);
        exit;
        end;
end;
langread:=-1;
choices[1]:='Description        :';
choices[2]:='Language Filename  :';
choices[3]:='Menu Filename      :';
choices[4]:='Access String      :';
choices[5]:='Graphics Path      :';
choices[6]:='Check Default Path :';
choices[7]:='Main Menu          :';
desc[1]:='Description of this Language to be shown to users       ';
desc[2]:='Filename of .NXL string file that this Language uses    ';
desc[3]:='Filename of .NXM menu file that this Language uses      ';
desc[4]:='Access String to allow users to select this Language    ';
desc[5]:='Graphics Path for this Language File (Blank=Use Default)';
desc[6]:='Check Default Path if Graphics File not found in above  ';
desc[7]:='Menu to use as Main Menu for this Language              ';
numlang:=filesize(langf)-1;
clang:=1;
current:=1;
setwindow2(w,2,10,78,20,3,0,8,'View Language '+cstr(clang)+'/'+cstr(numlang),
        'Language Editor',TRUE);
textcolor(7);
textbackground(0);
for x:=1 to 7 do begin
        gotoxy(2,x+1);
        write(choices[x]);
end;
repeat
if (update) then begin
numlang:=filesize(langf)-1;
arrows:=FALSE;
if (clang<>langread) then begin
        {$I-} seek(langf,clang); {$I+}
        if (ioresult<>0) then begin
                seek(langf,filesize(langf)-1);
        end;
        read(langf,lang);
        langread:=clang;
end;
if (editing) then
        setwindow3(w,2,10,78,20,3,0,8,'Edit Language '+cstr(clang)+'/'+cstr(numlang),
        'Language Editor',TRUE)
else
        setwindow3(w,2,10,78,20,3,0,8,'View Language '+cstr(clang)+'/'+cstr(numlang),
        'Language Editor',TRUE);
with lang do begin
textcolor(3);
textbackground(0);
gotoxy(23,2);
write(mln(name,40));
textcolor(3);
textbackground(0);
gotoxy(23,3);
write(mln(filename,8));
gotoxy(23,4);
write(mln(menuname,8));
gotoxy(23,5);
write(mln(access,20));
gotoxy(23,6);
write(mln(displaypath,50));
gotoxy(23,7);
write(syn(checkdefpath));
gotoxy(23,8);
{ Show Menu here }
write(cstr(startmenu));
end;
end;
if (editing) then begin
gotoxy(2,current+1);
textcolor(15);
textbackground(1);
write(choices[current]);
end;
window(1,1,80,25);
gotoxy(1,25);
textcolor(14);
textbackground(0);
clreol;
write('Esc');
textcolor(7);
write('=Exit ');
textcolor(14);
if (editing) then
write(desc[current])
else begin
textcolor(14);
write('Enter');
textcolor(7);
write('=Edit');
end;
window(3,11,77,19);
while not(keypressed) do begin timeslice; end;
c:=readkey;
case c of
        #0:begin
                c:=readkey;
                checkkey(c);
                case c of
                        #72:if (editing) then begin
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choices[current]);
                                dec(current);
                                if (current=0) then current:=7;
                            end;
                        #75:if not(editing) then begin
                                dec(clang);
                                if (clang=0) then clang:=1 else begin
                                        update:=TRUE;
                                        arrows:=TRUE;
                                end;
                            end;
                        #77:if not(editing) then begin
                                inc(clang);
                                if (clang>numlang) then clang:=numlang else
                                begin
                                        update:=TRUE;
                                        arrows:=TRUE;
                                end;
                            end;
                        #80:if (editing) then begin
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choices[current]);
                                inc(current);
                                if (current=8) then current:=1;
                            end;
                        #82:if not(editing) then begin
                                langi(clang);
                                inc(clang);
                                update:=TRUE;
                                current:=1;
                            end;
                        #83:if not(editing) and (clang>1) then begin
                                if pynqbox('Delete '+lang.name+'? ') then begin
                                        langd(clang);
                                        if (clang>numlang) then clang:=numlang;
                                        update:=TRUE;
                                end;
                             end;
                end;
           end;
       #13:if not(editing) then begin
                current:=1;
                editing:=TRUE;
                update:=TRUE;
           end else begin
                gotoxy(2,current+1);
                textcolor(7);
                textbackground(0);
                write(choices[current]);
                gotoxy(21,current+1);
                textcolor(9);
                write('>');
                gotoxy(23,current+1);
                case current of
                        1:begin
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=false;
                                        infield_numbers_only:=FALSE;
                                        infield_show_colors:=TRUE;
                                        infield_insert:=TRUE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        s:=lang.name;
                                        infielde(s,40);
                                        infield_insert:=TRUE;
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        if (s<>lang.name) then begin
                                        changed:=TRUE;
                                        lang.name:=s;
                                        end;
                        end;
                        2:begin
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=TRUE;
                                        infield_numbers_only:=FALSE;
                                        infield_insert:=TRUE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        s:=lang.filename;
                                        infielde(s,8);
                                        infield_insert:=TRUE;
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        if (s<>lang.filename) then begin
                                        changed:=TRUE;
                                        lang.filename:=s;
                                        end;
                        end;
                        3:begin
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=false;
                                        infield_numbers_only:=FALSE;
                                        infield_insert:=TRUE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        s:=lang.menuname;
                                        infielde(s,8);
                                        infield_insert:=TRUE;
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        if (s<>lang.menuname) then begin
                                        changed:=TRUE;
                                        lang.menuname:=s;
                                        end;
                        end;
                        4:begin
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=TRUE;
                                        infield_numbers_only:=FALSE;
                                        infield_insert:=TRUE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        s:=lang.access;
                                        infielde(s,20);
                                        infield_insert:=TRUE;
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        if (s<>lang.access) then begin
                                        changed:=TRUE;
                                        lang.access:=s;
                                        end;
                        end;
                        5:begin
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=TRUE;
                                        infield_numbers_only:=FALSE;
                                        infield_insert:=TRUE;
                                        infield_put_slash:=TRUE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        infield_maxshow:=50;
                                        s:=lang.displaypath;
                                        infielde(s,79);
                                        infield_put_slash:=FALSE;
                                        infield_insert:=TRUE;
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        if (s<>lang.displaypath) then begin
                                        changed:=TRUE;
                                        lang.displaypath:=s;
                                        end;
                        end;
                        6:begin
                                lang.checkdefpath:=not(lang.checkdefpath);
                                textcolor(3);
                                textbackground(0);
                                gotoxy(23,current+1);
                                write(syn(lang.checkdefpath));
                                changed:=TRUE;
                        end;
                        7:begin
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_numbers_only:=TRUE;
                                        infield_insert:=TRUE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        infield_escape_blank:=TRUE;
                                        s:=cstr(lang.startmenu);
                                        infielde(s,5);
                                        infield_insert:=TRUE;
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        if (s<>'') then
                                        if (value(s)<>lang.startmenu) then begin
                                        changed:=TRUE;
                                        lang.startmenu:=value(s);
                                        end;
                        end;
                end;
           end;
       #27:begin
           if (editing) then begin
                gotoxy(2,current+1);
                textcolor(7);
                textbackground(0);
                write(choices[current]);
                editing:=FALSE;
                arrows:=TRUE;
                update:=TRUE;
                current:=1;
           end else begin
                done:=TRUE;
           end;
           end;
end;
if (changed) and ((arrows) or (done)) then begin
        if pynqbox('Save Changes? ') then begin
                seek(langf,langread);
                write(langf,lang);
                update:=TRUE;
        end;
        arrows:=FALSE;
        changed:=FALSE;
end;
until (done);
removewindow(w);
close(langf);
end;

procedure filebasemanager(nexusdir:string; ppath:string);
begin
     Init_spawno(nexusdir,swap_all,20,0);
     if (spawn(getenv('COMSPEC'),' /c '+nxset.fbmgr+' '+ppath,0)=-1) then begin
        exec(getenv('COMSPEC'),' /c '+nxset.fbmgr+' '+ppath);
     end;
     cursoron(FALSE);
end;

procedure omssetup(nexusdir:string; ppath:string);
begin
     Init_spawno(nexusdir,swap_all,20,0);
     if (spawn(getenv('COMSPEC'),' /c '+nxset.ommgr+' '+ppath,0)=-1) then begin
        exec(getenv('COMSPEC'),' /c '+nxset.ommgr+' '+ppath);
     end;
     cursoron(FALSE);
end;

procedure cdromdrives;
var cdi:cdidxrec;
    cdif:file of cdidxrec;
    z,x,x2,x3,cur,top:integer;
    firstlp,lp,lp2:listptr;
    rt:returntype;
    w2:windowrec;
    c,c3:char;
    s:string;
    tm:array[1..26] of byte;
    done,dn,changed,quit:boolean;

begin
changed:=false;
quit:=false;
filemode:=66;
listbox_tag:=FALSE;
listbox_move:=FALSE;
listbox_enter:=FALSE;
assign(cdif,adrv(systat.gfilepath)+'CDS.IDX');
{$I-} reset(cdif); {$I+}
if ioresult<>0 then begin
   displaybox('Error Opening '+adrv(systat.gfilepath)+
                'CDS.IDX... Created.',3000);
        for x:=1 to 26 do cdi.drives[x]:=#0;
        rewrite(cdif);
        write(cdif,cdi);
end;
                                top:=1;
                                cur:=1;
repeat
seek(cdif,0);
read(cdif,cdi);
x2:=1;
dn:=false;
done:=FALSE;
for x:=1 to 26 do tm[x]:=0;
while (x2<27) and not(dn) do begin
        if (cdi.drives[x2]<>#0) then begin
                tm[x2]:=1;
                dec(x2);
                dn:=TRUE;
        end;
        inc(x2);
end;
        
                                new(lp);
                                lp^.p:=NIL;
                                if not(dn) then begin
                                lp^.list:='No Drives';
                                end else begin
                                lp^.list:='Drive '+cdi.drives[x2];
                                end;
                                firstlp:=lp;
                                x3:=2;
for x:=(x2+1) to 26 do begin
                                if (cdi.drives[x]<>#0) then begin
                                tm[x]:=x3;
                                inc(x3);
                                new(lp2);
                                lp2^.p:=lp;
                                lp^.n:=lp2;
                                lp2^.list:='Drive '+cdi.drives[x];
                                lp:=lp2;
                                end;
end;
                                listbox_escape:=TRUE;
                                listbox_enter:=TRUE;
                                listbox_insert:=TRUE;
                                listbox_delete:=TRUE;
                                lp^.n:=NIL;
                                for x:=1 to 100 do rt.data[x]:=-1;
                                lp:=firstlp;
                                listbox(w2,rt,top,cur,lp,37,8,53,19,3,0,8,'CD Drives','',TRUE);
                                textcolor(7);
                                textbackground(0);
                                case rt.kind of
                                0:begin
                                        c3:=chr(rt.data[100]);
                                        removewindow(w2);
                                        checkkey(c3);
                                        rt.data[100]:=-1;
                                end;
  2:done:=TRUE;
  3:begin
  setwindow(w,28,12,52,14,3,0,8,'',TRUE);
  gotoxy(2,1);
  textcolor(7);
  textbackground(0);
  write('Enter Drive Letter: ');
  repeat
  gotoxy(22,1);
  s:='';
  infield_inp_fgrd:=15;
  infield_inp_bkgd:=1;
  infield_out_fgrd:=3;
  infield_out_bkgd:=0;
  infield_allcaps:=TRUE;
  infield_numbers_only:=false;
  infield_escape_zero:=FALSE;
  infield_escape_blank:=TRUE;
  infield_insert:=TRUE;
  infield_putatend:=TRUE;
  infield_clear:=TRUE;
  infielde(s,1);
  infield_escape_zero:=FALSE;
  infield_clear:=FALSE;
  infield_putatend:=FALSE;
  infield_escape_blank:=FALSE;
  infield_insert:=TRUE;
  until (s[1] in ['A'..'Z']) or (s='');
  removewindow(w);
  if (s<>'') then begin
        cdi.drives[ord(s[1])-64]:=upcase(s[1]);
  end;
  lp:=firstlp;
  while (lp<>NIL) do begin
    lp2:=lp^.n;
    dispose(lp);
    lp:=lp2;
  end;
  if (lp<>NIL) then dispose(lp);
  seek(cdif,0);
  write(cdif,cdi);
  end;
  4:begin
  for x:=1 to 26 do begin
        if (tm[x]=rt.data[1]) then x3:=x;
  end;
  if pynqbox('Delete Drive '+cdi.drives[x3]+'? ') then begin
        cdi.drives[x3]:=#0;
  end;
  lp:=firstlp;
  while (lp<>NIL) do begin
    lp2:=lp^.n;
    dispose(lp);
    lp:=lp2;
  end;
  if (lp<>NIL) then dispose(lp);
  seek(cdif,0);
  write(cdif,cdi);
  end;
end;
removewindow(w2);
until (done);
lp:=firstlp;
while (lp<>NIL) do begin
    lp2:=lp^.n;
    dispose(lp);
    lp:=lp2;
end;
if (lp<>NIL) then dispose(lp);
close(cdif);
listbox_tag:=TRUE;
listbox_move:=TRUE;
listbox_enter:=TRUE;
end;

procedure cdromdisks;
var cds:cdrec;
    cdf:file of cdrec;
    curnum,x,x1,x3,x2,x4:integer;
    s:string;
    new,quit,changed:boolean;
    choices:array[1..5] of string;
    disp:array[1..5] of string;
    c:char;
    w2:windowrec;
    editing:boolean;
    
begin
quit:=false;
changed:=false;
new:=FALSE;
editing:=FALSE;
x1:=1;
choices[1]:='CD-ROM Name For Display :';
choices[2]:='Volume ID               :';
choices[3]:='Unique Filename         :';
choices[4]:='Use Unique Filename?    :';
choices[5]:='View Available Access   :';
disp[1]:='Name Displayed to Users when checking for CD-ROMs         ';
disp[2]:='Volume ID of CD-ROM Disk                                  ';
disp[3]:='Unique Filename on CD-ROM... format \[DIR\][DIR\]Filename ';
disp[4]:='Use Unique Filename instead of Volume ID Check?           ';
disp[5]:='Access String: User can see availability at logon         ';
assign(cdf,adrv(systat.gfilepath)+'CDS.DAT');
{$I-} reset(cdf); {$I+}
if ioresult<>0 then begin
        displaybox2(w2,'Creating CDS.DAT...');
        cds.name:='';
        cds.volumeid:='';
        cds.uniquefile:='';
        cds.useunique:=FALSE;
        cds.viewacs:='';
        for x:=1 to sizeof(cds.reserved) do cds.reserved[x]:=0;
        rewrite(cdf);
        write(cdf,cds);
        write(cdf,cds);
        removewindow(w2);
end;
curnum:=1;
if not(curnum>filesize(cdf)-1) and (curnum>=1) then begin
        seek(cdf,curnum);
        read(cdf,cds);
end;
setwindow2(w,10,10,70,18,3,0,8,'View CD-ROM Disk','Disk '+cstr(curnum)+'/'+cstr(filesize(cdf)-1),TRUE);
gotoxy(2,2);
textcolor(7);
write(choices[1]);
textcolor(3);
cwrite(mln(' '+cds.name,30));
gotoxy(2,3);
textcolor(7);
write(choices[2]);
textcolor(3);
write(mln(' '+cds.volumeid,30));
gotoxy(2,4);
textcolor(7);
write(choices[3]);
textcolor(3);
write(mln(' '+cds.uniquefile,30));
gotoxy(2,5);
textcolor(7);
write(choices[4]);
textcolor(3);
write(mln(' '+syn(cds.useunique),30));
gotoxy(2,6);
textcolor(7);
write(choices[5]);
textcolor(3);
write(mln(' '+cds.viewacs,20));
new:=false;
window(1,1,80,25);
gotoxy(1,25);
textcolor(14);
textbackground(0);
write('Esc');
textcolor(7);
write('=Exit ');
textcolor(14);
write('Enter');
textcolor(7);
write('=Edit Disk ');
textcolor(14);
write('Ins');
textcolor(7);
write('=Insert Disk ');
textcolor(14);
write('Del');
textcolor(7);
write('=Delete Disk                     ');

window(11,11,69,17);
repeat
cursoron(FALSE);
if not(curnum>filesize(cdf)-1) and (curnum>=1) then begin
        seek(cdf,curnum);
        read(cdf,cds);
end;
if (new) then begin
if (editing) then
setwindow3(w,10,10,70,18,3,0,8,'Edit CD-ROM Disk','Disk '+cstr(curnum)+'/'+cstr(filesize(cdf)-1),TRUE)
else
setwindow3(w,10,10,70,18,3,0,8,'View CD-ROM Disk','Disk '+cstr(curnum)+'/'+cstr(filesize(cdf)-1),TRUE);
gotoxy(2,2);
textbackground(0);
textcolor(7);
write(choices[1]);
textcolor(3);
cwrite(' '+mln(cds.name,30));
gotoxy(2,3);
textcolor(7);
write(choices[2]);
textcolor(3);
write(' '+mln(cds.volumeid,12));
gotoxy(2,4);
textcolor(7);
write(choices[3]);
textcolor(3);
write(' '+mln(cds.uniquefile,30));
gotoxy(2,5);
textcolor(7);
write(choices[4]);
textcolor(3);
write(' '+mln(syn(cds.useunique),30));
gotoxy(2,6);
textcolor(7);
write(choices[5]);
textcolor(3);
write(' '+mln(cds.viewacs,20));
new:=false;
end;
if (editing) then begin
textcolor(15);
textbackground(1);
gotoxy(2,x1+1);
write(choices[x1]);
textbackground(0);
end;
c:=readkey;
case c of
        #0:begin
                c:=readkey;
                checkkey(c);
                case c of
                        #72:if (editing) then begin
                                gotoxy(2,x1+1);
                                textcolor(7);
                                write(choices[x1]);
                                textcolor(3);
                                dec(x1);
                                if (x1=0) then x1:=5;
                                window(1,1,80,25);
                                gotoxy(10,25);
                                clreol;
                                textcolor(14);
                                textbackground(0);
                                write(disp[x1]);
                                window(11,11,69,17);
                        end;
                        #80:if (editing) then begin
                                gotoxy(2,x1+1);
                                textcolor(7);
                                write(choices[x1]);
                                textcolor(3);
                                inc(x1);
                                if (x1=6) then x1:=1;
                                window(1,1,80,25);
                                gotoxy(10,25);
                                clreol;
                                textcolor(14);
                                textbackground(0);
                                write(disp[x1]);
                                window(11,11,69,17);
                        end;
                        #75:if not(editing) then
                        begin
                        dec(curnum); new:=true;
                        if (curnum>filesize(cdf)-1) or (curnum<1) then begin
                        if (curnum>filesize(cdf)-1) then begin
                                curnum:=1;
                        end else begin
                                curnum:=filesize(cdf)-1;
                        end;
                        end;
                        end;
                        #77:if not(editing) then
                        begin
                        inc(curnum); new:=true;
                        if (curnum>filesize(cdf)-1) or (curnum<1) then begin
                        if (curnum>filesize(cdf)-1) then begin
                                curnum:=1;
                        end else begin
                                curnum:=filesize(cdf)-1;
                        end;
                        end;
                        end;
                        #82:if not(editing) then begin
  setwindow(w2,27,12,53,14,3,0,8,'',TRUE);
  gotoxy(2,1);
  textcolor(7);
  textbackground(0);
  write('Insert How Many : ');
  repeat
  gotoxy(20,1);
  s:='1';
  infield_inp_fgrd:=15;
  infield_inp_bkgd:=1;
  infield_out_fgrd:=3;
  infield_out_bkgd:=0;
  infield_allcaps:=false;
  infield_numbers_only:=TRUE;
  infield_escape_zero:=TRUE;
  infielde(s,4);
  infield_escape_zero:=FALSE;

  x2:=value(s);
  until (x2>=0) and (x2<=1000);
                                if (x2<>0) then begin
                                x3:=filesize(cdf);
                                for x4:=1 to x2 do begin
                                gotoxy(2,1);
                                textcolor(7);
                                textbackground(0);
                                write('Inserting CD-ROM #',x4);
                                seek(cdf,filesize(cdf));
                                cds.name:='';
                                cds.volumeid:='';
                                cds.uniquefile:='';
                                cds.useunique:=FALSE;
                                cds.viewacs:='';
                                for x:=1 to sizeof(cds.reserved) do cds.reserved[x]:=0;
                                write(cdf,cds);
                                end;
                                curnum:=x3;
                                seek(cdf,curnum);
                                new:=true;
                                end;
                                removewindow(w2);
                        end;
                        #83:if not(editing) then begin
                               if pynqbox('Delete CD-ROM Disk #'+cstr(curnum)+'? ') then begin
                               if ((filesize(cdf)-1)=1) then begin
                               cds.name:='';
                               cds.volumeid:='';
                               cds.uniquefile:='';
                               cds.useunique:=FALSE;
                               cds.viewacs:='';
                               for x:=1 to sizeof(cds.reserved) do cds.reserved[x]:=0;
                               seek(cdf,1);
                               write(cdf,cds);
                               seek(cdf,1);
                               end else begin
                               x3:=curnum;
                               while (x3<=filesize(cdf)-2) do begin
                                   if (x3+1<=filesize(cdf)-1) then begin
                                   seek(cdf,x3+1);
                                   read(cdf,cds);
                                   seek(cdf,x3);
                                   write(cdf,cds);
                                   end;
                                   inc(x3);
                               end;
                               seek(cdf,filesize(cdf)-1);
                               truncate(cdf);
                               end;
                               if (curnum>(filesize(cdf)-1)) then curnum:=filesize(cdf)-1;
                               new:=TRUE;
                               end;
                        end;
                end;
        end;
        #13:begin
                if not(editing) then begin
                        editing:=TRUE;
                        x1:=1;
                window(1,1,80,25);
                gotoxy(1,25);
                textcolor(14);
                textbackground(0);
                write('Esc');
                textcolor(7);
                write('=Exit ');
                textcolor(14);
                write(disp[x1]);
                window(11,11,69,17);
                end else begin
                cursoron(TRUE);
                case x1 of
                        1:begin
                                gotoxy(2,2);
                                textcolor(7);
                                write(choices[x1]);
                                gotoxy(26,2);
                                textcolor(9);
                                write('> ');
                                s:='';
                                infield_inp_fgrd:=15;
                                infield_inp_bkgd:=1;
                                infield_out_fgrd:=3;
                                infield_out_bkgd:=0;
                                infield_allcaps:=false;
                                infield_show_colors:=TRUE;
                                infield_numbers_only:=FALSE;
                                s:=cds.name;
                                infielde(s,30);
                                if (s<>cds.name) then begin
                                cds.name:=s;
                                changed:=true;
                                end;

                        end;
                        2:begin
                                gotoxy(2,3);
                                textcolor(7);
                                write(choices[x1]);
                                gotoxy(26,3);
                                textcolor(9);
                                write('> ');
                                infield_inp_fgrd:=15;
                                infield_inp_bkgd:=1;
                                infield_out_fgrd:=3;
                                infield_out_bkgd:=0;
                                infield_allcaps:=true;
                                infield_show_colors:=false;
                                infield_numbers_only:=FALSE;
                                s:='';
                                s:=cds.volumeid;
                                infielde(s,12);
                                if (s<>cds.volumeid) then begin
                                        cds.volumeid:=s;
                                        changed:=true;
                                end;
                        end;
                        3:begin
                                gotoxy(2,4);
                                textcolor(7);
                                write(choices[x1]);
                                gotoxy(26,4);
                                textcolor(9);
                                write('> ');
                                s:='';
                                infield_inp_fgrd:=15;
                                infield_inp_bkgd:=1;
                                infield_out_fgrd:=3;
                                infield_out_bkgd:=0;
                                infield_allcaps:=TRUE;
                                infield_show_colors:=FALSE;
                                infield_numbers_only:=FALSE;
                                infield_maxshow:=30;
                                s:=cds.uniquefile;
                                infielde(s,40);
                                infield_maxshow:=0;
                                if (s<>cds.uniquefile) then begin
                                cds.uniquefile:=s;
                                changed:=true;
                                end;
                        end;
                        4:begin
                                cds.useunique:=not(cds.useunique);
                                changed:=TRUE;
                                gotoxy(2,5);
                                textcolor(7);
                                write(choices[4]);
                                textcolor(3);
                                write(' '+mln(syn(cds.useunique),30));
                          end;
                        5:begin
                                gotoxy(2,6);
                                textcolor(7);
                                write(choices[x1]);
                                gotoxy(26,6);
                                textcolor(9);
                                write('> ');
                                infield_inp_fgrd:=15;
                                infield_inp_bkgd:=1;
                                infield_out_fgrd:=3;
                                infield_out_bkgd:=0;
                                infield_allcaps:=true;
                                infield_show_colors:=false;
                                infield_numbers_only:=FALSE;
                                s:='';
                                s:=cds.viewacs;
                                infielde(s,20);
                                if (s<>cds.viewacs) then begin
                                        cds.viewacs:=s;
                                        changed:=true;
                                end;
                        end;
                end;
                cursoron(FALSE);
                end;
        end;
        #27:if (editing) then begin
                editing:=FALSE;
                new:=TRUE;
                window(1,1,80,25);
                gotoxy(1,25);
                textcolor(14);
                textbackground(0);
                write('Esc');
                textcolor(7);
                write('=Exit ');
                textcolor(14);
                write('Enter');
                textcolor(7);
                write('=Edit Disk ');
                textcolor(14);
                write('Ins');
                textcolor(7);
                write('=Insert Disk ');
                textcolor(14);
                write('Del');
                textcolor(7);
                write('=Delete Disk                  ');
                window(11,11,69,17);
                x1:=1;
            end else quit:=true;
end;
if (changed) then begin
        seek(cdf,curnum);
        write(cdf,cds);
        changed:=false;
end;
until (quit);
close(cdf);
end;


end.
