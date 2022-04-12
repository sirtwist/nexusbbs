{$A+,B+,D-,E+,F+,G+,I+,L-,N-,O-,R+,S+,V-}
{$M 65000,0,100000}      { Memory Allocation Sizes }
program emsetup;

uses dos,crt,misc,myio,keyunit;

const auto:boolean=FALSE;
      list:boolean=FALSE;
      gen:boolean=FALSE;

var   systatf:file of matrixrec;
      systf:file of systemrec;
      syst:systemrec;
    emf:file of nxEMAILREC;
    em:nxEMAILREC;

procedure endprogram;
begin
cursoron(TRUE);
halt;
end;

procedure helpscreen;
begin
writeln('EMSETUP v1.00 - nxEMAIL Setup for Nexus Bulletin Board System');
writeln('(c) Copyright 1997-2000 George A. Roberts IV. All rights reserved.');
writeln;
writeln('Syntax: EMSETUP [command]');
writeln;
writeln('Commands:');
writeln;
writeln('               GENERAL         General nxEMAIL configuration');
writeln('               AUTOBOT         AUTOBOT configuration');
writeln('               LISTSERV        Listserver configuration');
endprogram;
end;

function selectmbase:longint;
var memboard:boardrec;
    bf:file of boardrec;
    mbnum:longint;
    top,cur:integer;
    firstlp,lp,lp2:listptr;
    rt:returntype;
    w2:windowrec;
    x,ii2:integer;

  function getid:longint;
  var mbif:file of baseidx;
      mbi:baseidx;
      tl:longint;
  begin
  assign(mbif,adrv(systat.gfilepath)+'MBASES.IDX');
  {$I-} reset(mbif); {$I-}
  if (ioresult<>0) then begin
        displaybox('Error reading MBASES.IDX!',3000);
        exit;
  end;
  seek(mbif,mbnum);
  read(mbif,mbi);
  tl:=-1;
  if (mbi.offset=mbnum) then begin
        tl:=mbi.baseid;
        displaybox(cstr(mbnum)+' '+cstr(mbi.offset)+' '+cstr(tl),2000);
  end else displaybox('Error: Index is corrupt!',3000);
  getid:=tl;
  end;

  function Format2(b:byte):string;
  var s:string;
  begin
  case b of
        1:s:='Squish';
        2:s:='JAM   ';
        3:s:='*.MSG ';
  end;
  format2:=s;
  end;

  function Btype(b:byte):string;
  var s:string;
  begin
  case b of
        0:s:='Local          ';
        1:s:='Echomail       ';
        2:s:='Netmail        ';
        3:s:='Internet E-mail';
  end;
  Btype:=s;
  end;

begin
                                assign(bf,adrv(systat.gfilepath)+'MBASES.DAT');
                                {$I-} reset(bf); {$I+}
                                if (ioresult<>0) then begin
                                        displaybox('Error reading MBASES.DAT!',3000);
                                        exit;
                                end;
                                listbox_goto:=TRUE;
                                listbox_goto_offset:=1;
                                listbox_insert:=FALSE;
                                listbox_delete:=FALSE;
                                listbox_tag:=FALSE;
                                listbox_move:=FALSE;
                                displaybox2(w2,'Reading message bases...');
                                new(lp);
                                seek(bf,0);       
                                read(bf,memboard);
                                ii2:=0;
                                lp^.p:=NIL;
                                lp^.list:=mln(cstr(ii2),5)+mln(memboard.name,45)+'  %070%'+
                                        Btype(memboard.mbtype)+'   '+format2(memboard.messagetype);
                                firstlp:=lp;
                                while (not(eof(bf))) do begin
                                inc(ii2);
                                read(bf,memboard);
                                new(lp2);
                                lp2^.p:=lp;
                                lp^.n:=lp2;
                                lp2^.list:=mln(cstr(ii2),5)+mln(memboard.name,45)+' %070% '+
                                        Btype(memboard.mbtype)+'   '+format2(memboard.messagetype);
                                lp:=lp2;
                                end;
                                close(bf);
                                lp^.n:=NIL;
                                removewindow(w2);
                                top:=1;
                                cur:=1;
                                for x:=1 to 100 do rt.data[x]:=-1;
                                lp:=firstlp;
                                listbox(w2,rt,top,cur,lp,3,9,76,22,3,0,8,'Message Bases','',TRUE);
                                textcolor(7);
                                textbackground(0);
                                case rt.kind of
                                        1:begin
                                                removewindow(w2);
                                                if (rt.data[1])<>-1 then begin
                                                                mbnum:=rt.data[1]-1;
                                                                lp:=firstlp;
                                                                while (lp<>NIL) do begin
                                                                        lp2:=lp^.n;
                                                                        dispose(lp);
                                                                        lp:=lp2;
                                                                end;
                                                end;
                                          end;
                                        2:begin
                                                removewindow(w2);
                                                mbnum:=-1;
                                                lp:=firstlp;
                                                while (lp<>NIL) do begin
                                                        lp2:=lp^.n;
                                                        dispose(lp);
                                                        lp:=lp2;
                                                end;
                                        end;
                                end;
        mbnum:=getid;
        selectmbase:=mbnum;
end;

procedure getparams;
var np,np2:integer;
    sp:string;
begin
  np:=paramcount;
  if (np=0) then helpscreen;
  np2:=1;
  while (np2<=np) do begin
        sp:=allcaps(paramstr(np2));
        case sp[1] of
                '/','-':begin
                        case sp[2] of
                                '?','H':helpscreen;
                                'Z':nxe:=TRUE;
                        end;
                        end;
                 else begin
                        if (allcaps(sp)='AUTOBOT') then auto:=TRUE;
                        if (allcaps(sp)='LISTSERV') then list:=TRUE;
                        if (allcaps(sp)='GENERAL') then gen:=TRUE;
                 end;
        end;
        inc(np2);
   end;
end;

procedure savesystem;
begin
{$I-} reset(systf); {$I+}
if (ioresult<>0) then begin
        displaybox('Error opening SYSTEM.DAT!',3000);
        endprogram;
end;
write(systf,syst);
close(systf);
end;


procedure listsetup;
var uif:file of useridrec;
    ui:useridrec;
    s:string;
    lf:file of listservrec;
    l:listservrec;
    choices:array[1..9] of string[18];
    desc:array[1..9] of string;
    current:byte;
    cl,maxcl:integer;
    inserted,done,changed,auto,arrows,editing:boolean;
    c:char;

    function showaccess(b:byte):string;
    begin
        case b of
                0:showaccess:='Open List (anyone can post)                 ';
                1:showaccess:='Moderated List (msgs must be posted locally)';
                else showaccess:='ERROR!';
        end;
    end;

    function showmbase(ll:longint):string;
    var bf:file of boardrec;
        b:boardrec;
        bif:file of baseididx;
        bi:baseididx;
        ttl:longint;
    begin
        if (ll=-1) then begin
                showmbase:='UNSELECTED!';
                exit;
        end;
        ttl:=-1;
        assign(bif,adrv(systat.gfilepath)+'MBASEID.IDX');
        {$I-} reset(bif); {$I+}
        if (ioresult<>0) then begin
                displaybox('Error reading MBASEID.IDX!',3000);
                showmbase:='ERROR!';
                exit;
        end;
        seek(bif,ll);
        read(bif,bi);
        if (bi.baseid=ll) then begin
                ttl:=bi.offset;
        end else begin
                displaybox('Error: Index is corrupt!',3000);
                showmbase:='ERROR!';
                close(bif);
                exit;
        end;
        close(bif);
        assign(bf,adrv(systat.gfilepath)+'MBASES.DAT');
        {$I-} reset(bf); {$I+}
        if (ioresult<>0) then begin
                displaybox('Error reading MBASES.DAT!',3000);
                showmbase:='ERROR!';
                exit;
        end;
        if (ttl>-1) then begin
                seek(bf,ttl);
                read(bf,b);
                close(bf);
                showmbase:=b.name;
        end else showmbase:='ERROR!';
    end;

    function getuserid:longint;
    begin
        assign(uif,adrv(systat.gfilepath)+'USERID.IDX');
        {$I-} reset(uif); {$I+}
        if (ioresult<>0) then begin
                displaybox('Error reading USERID.IDX!',3000);
                getuserid:=-1;
                exit;
        end;
        readpermid;
        inc(perm.lastuserid);
        seek(uif,perm.lastuserid);
        ui.userid:=perm.lastuserid;
        ui.number:=-2;
        write(uif,ui);
        close(uif);
        updatepermid;
        getuserid:=perm.lastuserid;
    end;

begin
done:=FALSE;
changed:=FALSE;
auto:=FALSE;
arrows:=TRUE;
editing:=FALSE;
choices[1]:='Description      :';
choices[2]:='Trigger          :';
choices[3]:='Footer file      :';
choices[4]:='Subscribe file   :';
choices[5]:='Unsubscribe file :';
choices[6]:='Control level    :';
choices[7]:='Message base     :';
choices[8]:='Gateway #        :';
choices[9]:='Reply Address    :';
desc[1]:='Description of this list';
desc[2]:='The trigger of this list (i.e. the word needed to subscribe)';
desc[3]:='Text file placed at the bottom of each message';
desc[4]:='Text file sent when people subscribe';
desc[5]:='Text file sent when people unsubscribe';
desc[6]:='The type of control over posting on this list';
desc[7]:='The local message base used to maintain this list';
desc[8]:='This is the gateway number to use when sending messages';
desc[9]:='This is the address users reply to when posting to list';
setwindow2(w,2,9,78,21,3,0,8,'View Listserver','nxEMAIL',TRUE);
textcolor(7);
textbackground(0);
for current:=1 to 9 do begin
        gotoxy(2,current+1);
        write(choices[current]);
end;
assign(lf,adrv(systat.gfilepath)+'LISTSERV.DAT');
{$I-} reset(lf); {$I+}
if (ioresult<>0) then begin
        fillchar(l,sizeof(l),0);
        rewrite(lf);
        write(lf,l);
        l.name:='New ListServer List';
        l.mbaseid:=-1;
        l.userid:=-1;
        write(lf,l);
end;
cl:=1;
repeat
inserted:=FALSE;
maxcl:=filesize(lf)-1;
if (arrows) then begin
        if (cl>filesize(lf)-1) then begin
          fillchar(l,sizeof(l),#0);
          l.name:='New ListServer List';
          l.mbaseid:=-1;
          l.userid:=-1;
        end else begin
          seek(lf,cl);
          read(lf,l);
        end;
        if (editing) then begin
                setwindow3(w,2,9,78,21,3,0,8,'Edit Listserver '+cstr(cl)+'/'+cstr(maxcl)+
                ' (LIST'+cstrn(l.userid)+')','nxEMAIL',TRUE);
        end else begin
                setwindow3(w,2,9,78,21,3,0,8,'View Listserver '+cstr(cl)+'/'+cstr(maxcl)+
                ' (LIST'+cstrn(l.userid)+')','nxEMAIL',TRUE);
        end;
        textcolor(3);
        textbackground(0);
        gotoxy(21,2);
        write(mln(l.name,36));
        gotoxy(21,3);
        write(mln(l.trigger,36));
        gotoxy(21,4);
        write(mln(l.footer,55));
        gotoxy(21,5);
        write(mln(l.signup,55));
        gotoxy(21,6);
        write(mln(l.logoff,55));
        gotoxy(21,7);
        write(showaccess(l.access));
        gotoxy(21,8);
        cwrite(mln(showmbase(l.mbaseid),55));
        gotoxy(21,9);
        write(mln(cstr(l.gateway),2));
        gotoxy(21,10);
        write(mln(l.replyaddr,55));
        arrows:=FALSE;
end;
window(1,1,80,25);
gotoxy(1,25);
if (editing) then begin
cwrite('%140%Esc%070%=Exit %140%F10%070%=Save %140%'+mln(desc[current],60));
end else begin
cwrite('%140%Esc%070%=Exit %140%Enter%070%=Edit %140%Ins%070%=Insert %140%Del%070%=Delete'+mln('',37));
end;
window(3,10,77,20);
if (editing) then begin
        textcolor(15);
        textbackground(1);
        gotoxy(2,current+1);
        write(choices[current]);
end;
while not(keypressed) do begin end;
c:=readkey;
case c of
        #0:begin
                c:=readkey;
                case c of
                        #68:if (editing) then begin
                                auto:=TRUE;
                                changed:=TRUE;
                                arrows:=TRUE;
                                editing:=FALSE;
                                textcolor(7);
                                textbackground(0);
                                gotoxy(2,current+1);
                                write(choices[current]);
                            end;
                        #72:if (editing) then begin
                                textcolor(7);
                                textbackground(0);
                                gotoxy(2,current+1);
                                write(choices[current]);
                                dec(current);
                                if (current=0) then current:=9;
                            end;
                        #75:if not(editing) then begin
                                dec(cl);
                                if (cl=0) then cl:=maxcl;
                                arrows:=TRUE;
                            end;
                        #77:if not(editing) then begin
                                inc(cl);
                                if (cl>maxcl) then cl:=1;
                                arrows:=TRUE;
                            end;
                        #80:if (editing) then begin
                                textcolor(7);
                                textbackground(0);
                                gotoxy(2,current+1);
                                write(choices[current]);
                                inc(current);
                                if (current=10) then current:=1;
                            end;
                        #82:if not(editing) then begin
                                editing:=TRUE;
                                cl:=maxcl+1;
                                arrows:=TRUE;
                                changed:=TRUE;
                                inserted:=TRUE;
                                current:=1;
                            end;
                end;
           end;
       #13:begin
                if not(editing) then begin
                        editing:=TRUE;
                        arrows:=TRUE;
                        current:=1;
                end else begin
                        textcolor(7);
                        textbackground(0);
                        gotoxy(2,current+1);
                        write(choices[current]);
                        infield_inp_fgrd:=15;
                        infield_inp_bkgd:=1;
                        infield_out_fgrd:=3;
                        infield_out_bkgd:=0;
                        infield_allcaps:=false;
                        infield_numbers_only:=false;
                        infield_putatend:=TRUE;
                        infield_insert:=TRUE;
                        infield_clear:=TRUE;
                        infield_show_colors:=FALSE;
                        gotoxy(19,current+1);
                        textcolor(9);
                        textbackground(0);
                        write('>');
                        gotoxy(21,current+1);
                        case current of
                                1:begin
                                        s:=l.name;
                                        infielde(s,36);
                                        if (s<>l.name) then begin
                                                l.name:=s;
                                                changed:=TRUE;
                                        end;
                                  end;
                                2:begin
                                        s:=l.trigger;
                                        infielde(s,36);
                                        if (s<>l.trigger) then begin
                                                l.trigger:=s;
                                                changed:=TRUE;
                                        end;
                                  end;
                                3:begin
                                        s:=l.footer;
                                        infield_maxshow:=55;
                                        infielde(s,79);
                                        if (s<>l.footer) then begin
                                                l.footer:=s;
                                                changed:=TRUE;
                                        end;
                                        infield_maxshow:=0;
                                  end;
                                4:begin
                                        s:=l.signup;
                                        infield_maxshow:=55;
                                        infielde(s,79);
                                        if (s<>l.signup) then begin
                                                l.signup:=s;
                                                changed:=TRUE;
                                        end;
                                        infield_maxshow:=0;
                                  end;
                                5:begin
                                        s:=l.logoff;
                                        infield_maxshow:=55;
                                        infielde(s,79);
                                        if (s<>l.logoff) then begin
                                                l.logoff:=s;
                                                changed:=TRUE;
                                        end;
                                        infield_maxshow:=0;
                                  end;
                                6:begin
                                        if (l.access=0) then l.access:=1 else
                                        l.access:=0;
                                        textcolor(3);
                                        textbackground(0);
                                        gotoxy(21,7);
                                        write(showaccess(l.access));
                                  end;
                                7:begin
                setwindow4(w,2,9,78,21,8,0,8,'Edit Listserver '+cstr(cl)+'/'+cstr(maxcl),'nxEMAIL',TRUE);
                                        l.mbaseid:=selectmbase;
                setwindow5(w,2,9,78,21,3,0,8,'Edit Listserver '+cstr(cl)+'/'+cstr(maxcl),'nxEMAIL',TRUE);
                                        window(3,10,77,20);
                                        textcolor(3);
                                        textbackground(0);
                                        gotoxy(21,8);
                                        cwrite(showmbase(l.mbaseid));
                                  end;
                                8:begin
                                        s:=cstr(l.gateway);
                                        infield_numbers_only:=TRUE;
                                        infielde(s,2);
                                        if (value(s)<>l.gateway) then begin
                                                l.gateway:=value(s);
                                                changed:=TRUE;
                                        end;
                                        infield_numbers_only:=false;
                                  end;
                                9:begin
                                        s:=l.replyaddr;
                                        infield_maxshow:=55;
                                        infielde(s,70);
                                        if (s<>l.replyaddr) then begin
                                                l.replyaddr:=s;
                                                changed:=TRUE;
                                        end;
                                        infield_maxshow:=0;
                                  end;
                        end;
                end;
           end;
       #27:begin
                if (editing) then begin
                        textcolor(7);
                        textbackground(0);
                        gotoxy(2,current+1);
                        write(choices[current]);
                        editing:=FALSE;
                        arrows:=TRUE;
                end else begin
                        done:=TRUE;
                end;
           end;
end;
if (arrows) and (changed) and not(inserted) then begin
        if not(auto) then auto:=pynqbox('Save changes? ');
        if (auto) then begin
                if (l.userid=-1) then begin
                        l.userid:=getuserid;
                end;
                seek(lf,cl);
                write(lf,l);
        end else begin
                if (cl>maxcl) then cl:=maxcl;
        end;
        changed:=FALSE;
        auto:=FALSE;
end;
until (done);
removewindow(w);
end;

procedure generalsetup;
begin
end;

procedure autosetup;
begin
end;

procedure openfiles;
begin
nexusdir:=getenv('NEXUS');
if (nexusdir[length(nexusdir)]='\') then nexusdir:=copy(nexusdir,1,length(nexusdir)-1);
start_dir:=nexusdir;
keydir:=nexusdir+'\';
checkkey('NEXUS');
filemode:=66;
assign(systatf,nexusdir+'\MATRIX.DAT');
{$I-} reset(systatf); {$I+}
if (ioresult<>0) then begin
        displaybox('Error opening '+allcaps(nexusdir)+'\MATRIX.DAT!',3000);
        endprogram;
end;
read(systatf,systat);
close(systatf);
filemode:=66;
assign(systf,adrv(systat.gfilepath)+'SYSTEM.DAT');
{$I-} reset(systf); {$I+}
if (ioresult<>0) then begin
        displaybox('Error opening SYSTEM.DAT!',3000);
        endprogram;
end;
read(systf,syst);
close(systf);
filemode:=66;
assign(emf,adrv(systat.gfilepath)+'NXEMAIL.DAT');
{$I-} reset(emf); {$I+}
if (ioresult<>0) then begin
        displaybox('Error opening '+adrv(systat.gfilepath)+'NXEMAIL.DAT ... recreated.',3000);
        fillchar(em,sizeof(em),#0);
        em.nomovefile:=adrv(systat.gfilepath)+'NOIMPORT.TXT';
        em.nobouncefile:=adrv(systat.gfilepath)+'NOBOUNCE.TXT';
        em.bouncenoexist:=TRUE;
        rewrite(emf);
        write(emf,em);
        seek(emf,0);
end;
read(emf,em);
close(emf);
end;

begin
cursoron(FALSE);
getparams;
openfiles;
if (gen) then generalsetup;
if (auto) then autosetup;
if (list) then listsetup;
endprogram;
end.
