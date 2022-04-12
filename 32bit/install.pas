{----------------------------------------------------------------------------}
{ Nexus Bulletin Board System - Nexus BBS Software                           }
{                                                                            }
{ All material contained herein is                                           }
{  (c) Copyright 1996 Epoch Software.  All Rights Reserved.                  }
{  (c) Copyright 1995-96 Intuitive Vision Software.  All Rights Reserved.    }
{                                                                            }
{ MODULE     :  INSTALL.PAS (Main Installation Program)                      }
{ AUTHOR     :  George A. Roberts IV                                         }
{                                                                            }
{----------------------------------------------------------------------------}
{ Nexus is a trademarks of Epoch Software.                                   }
{----------------------------------------------------------------------------}
{$A+,B+,D-,E+,F+,G-,I+,L-,N-,O-,R+,S+,V-}
{.M 60000,0,100000}      { Memory Allocation Sizes }

program Install;

uses crt,dos,myio,misc,spawno,usertag,mkstring,mkmisc;
// extract was used here, but no unit exists for it.

var wind,w10:windowrec;
    oldx,oldy,x:integer;
    s:string;
    systatf:file of MatrixREC;
    syst:systemrec;
    fddt:datetime;
    systf:file of systemrec;
    uf:file of userrec;
    user:userrec;
    startdir,
    start_dir,
    NexusDir:string;
    c:char;

procedure showad(x:integer);
begin
setwindow(w10,2,6,77,15,3,0,8,'',TRUE);
case x of
        1:begin
                gotoxy(2,2);
                cwrite('%150%Thank you for choosing Nexus Bulletin Board System!');
                gotoxy(2,4);
                cwrite('%150%See LICENSE.TXT for more information on licensing this fine bulletin');
                gotoxy(2,5);
                cwrite('%150%board software package.  The unlicensed freeware version of Nexus is');
                gotoxy(2,6);
                cwrite('%150%now being installed on your system.  This version is fully functional');
                gotoxy(2,7);
                cwrite('%150%and is only limited in the number of nodes it supports.');
          end;
        2:begin
                gotoxy(2,2);
                cwrite('%150%Nexus provides all the standard features found in BBS software,');
                gotoxy(2,3);
                cwrite('%150%and it also allows a level of customization not normally found');
                gotoxy(2,4);
                cwrite('%150%in other BBS software packages.');
                gotoxy(2,5);
                cwrite('%150%');
                gotoxy(2,6);
                cwrite('%150%Some features include:');
          end;
        3:begin
                gotoxy(2,2);
                cwrite('%150%o Full featured setup program');
                gotoxy(2,3);
                cwrite('%150%o Blue Wave offline mail');
                gotoxy(2,4);
                cwrite('%150%o Group and individual chat');
                gotoxy(2,5);
                cwrite('%150%o Many bundled utilities');
                gotoxy(2,6);
                cwrite('%150%o Configurable/powerful security');
                gotoxy(2,7);
                cwrite('%150%o Subscription System');
          end;
end;
end;

function tch(s:string):string;
begin
  if (length(s)>2) then s:=copy(s,length(s)-1,2) else
    if (length(s)=1) then s:='0'+s;
  tch:=s;
end;

function time:string;
var h,m,s:string[3];
    hh,mm,ss,ss100:word;
begin
  gettime(hh,mm,ss,ss100);
  str(hh,h); str(mm,m); str(ss,s);
  time:=tch(h)+':'+tch(m)+':'+tch(s);
end;

function date:string;
var r:registers;
    y,m,d:string[3];
    yy,mm,dd,dow:word;
begin
  getdate(yy,mm,dd,dow);
  str(yy-1900,y); str(mm,m); str(dd,d);
  date:=tch(m)+'/'+tch(d)+'/'+tch(y);
end;
function value(s:string):longint;
var i:longint;
    j:integer;
begin
  val(s,i,j);
  if (j<>0) then begin
    s:=copy(s,1,j-1);
    val(s,i,j)
  end;
  value:=i;
  if (s='') then value:=0;
end;
function leapyear(yr:integer):boolean;
begin
  leapyear:=(yr mod 4=0) and ((yr mod 100<>0) or (yr mod 400=0));
end;

function days(mo,yr:integer):integer;
var d:integer;
begin
  d:=value(copy('312831303130313130313031',1+(mo-1)*2,2));
  if ((mo=2) and (leapyear(yr))) then inc(d);
  days:=d;
end;

function daycount(mo,yr:integer):integer;
var m,t:integer;
begin
  t:=0;
  for m:=1 to (mo-1) do t:=t+days(m,yr);
  daycount:=t;
end;

function daynum(dt:string):integer;
var d,m,y,t,c:integer;
begin
  t:=0;
  m:=value(copy(dt,1,2));
  d:=value(copy(dt,4,2));
  y:=value(copy(dt,7,2))+1900;
  for c:=1970 to y-1 do
    if (leapyear(c)) then inc(t,366) else inc(t,365);
  t:=t+daycount(m,y)+(d-1);
  daynum:=t;
  if y<1970 then daynum:=0;
end;

procedure sgetdatetime(var dt:datetimerec);
var w1,w2,w3,w4:word;
begin
  gettime(w1,w2,w3,w4);
  with dt do begin
    day:=daynum(date);
    hour:=w1;
    min:=w2;
    sec:=w3;
  end;
end;

function caps(s:string):string;
var i:integer;
begin
  for i:=1 to length(s) do
    if (s[i] in ['A'..'Z']) then s[i]:=chr(ord(s[i])+32);
  for i:=1 to length(s) do
    if (not (s[i] in ['A'..'Z','a'..'z'])) then
      if (s[i+1] in ['a'..'z']) then s[i+1]:=upcase(s[i+1]);
  s[1]:=upcase(s[1]);
  caps:=s;
end;

function allcaps(s:string):string;
var i:integer;
begin
  for i:=1 to length(s) do s[i]:=upcase(s[i]);
  allcaps:=s;
end;

procedure cf(var ok:byte; var nospace:boolean; showprog:boolean;
                   srcname,destname:astr);
var buffer:array[1..16384] of byte;
    totread,fs,dfs:longint;
    startx,nrec,i,x,x2,x3:integer;
    b:byte;
    src,dest:file;
    cont:boolean;

  procedure dodate;
  var tm:longint;
  begin
    getftime(src,tm);
    setftime(dest,tm);
  end;

  function getresponse:byte;
  var w4:windowrec;
      x4:integer;
      current:byte;
      c:char;
      choices:array[1..3] of string[30];
      dn:boolean;
  begin
  choices[1]:='Replace Existing File';
  choices[2]:='Delete Source File   ';
  choices[3]:='Abort Move           ';
  setwindow(w4,20,10,60,16,3,0,8,destname,TRUE);
  for x4:=1 to 3 do begin
        gotoxy(2,x4+1);
        textcolor(7);
        textbackground(0);
        write(choices[x4]);
  end;
  dn:=FALSE;
  current:=1;
  repeat
        gotoxy(2,current+1);
        textcolor(15);
        textbackground(1);
        write(choices[current]);
        while not(keypressed) do begin end;
        c:=readkey;
        case c of
                #0:begin
                        c:=readkey;
                        case c of
                                #72:begin
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choices[current]);
                                dec(current);
                                if (current=0) then current:=3;
                                end;
                                #80:begin
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choices[current]);
                                inc(current);
                                if (current=4) then current:=1;
                                end;
                        end;
                   end;
                #13:begin
                    getresponse:=current;
                    dn:=TRUE;
                end;
       end;
  until (dn);
  removewindow(w4);
  textcolor(7);
  textbackground(0);
  end;




begin
  ok:=0; nospace:=FALSE;
  assign(src,srcname);
  filemode:=64;
  {$I-} reset(src,1); {$I+}
  if (ioresult<>0) then begin ok:=1;
  displaybox('File: '+srcname+' - Error!',2000);
  exit; end;
  dfs:=freek(exdrv(destname));
  fs:=trunc(filesize(src)/1024.0)+1;
  if (fs>=dfs) then begin
    close(src);
    nospace:=TRUE; ok:=1;
    exit;
  end else begin
    cont:=TRUE;
    fs:=filesize(src);
    assign(dest,destname);
    filemode:=66;
    if (exist(destname)) then begin
        { 1: replace
          2: delete source
          3: quit }
          b:=getresponse;
          case b of
                1:begin
                  cont:=TRUE;
                  end;
                2:begin
                  close(src);
                  cont:=FALSE;
                  ok:=2;
                  end;
                3:begin
                  close(src);
                  cont:=FALSE;
                  ok:=3;
                  end;
          end;
    end;
    if (cont) then begin
    {$I-} rewrite(dest,1); {$I+}
    if (ioresult<>0) then begin ok:=4; exit; end;
    textbackground(0);
    textcolor(15);
    write('0% ');
    textcolor(3);
    startx:=(wherex-1);
    for i:=1 to 40 do write('°');
    textcolor(15);
    write(' 100%');

    x:=1;
    totread:=0;
    repeat
      filemode:=64;
      blockread(src,buffer,16384,nrec);
      filemode:=66;
      blockwrite(dest,buffer,nrec);
      totread:=totread+nrec;
      if (showprog) then begin
        for x2:=x to 40 do begin
        if (totread>=((fs div 40)*x2)) then begin
                gotoxy(startx+x,wherey);
                textcolor(1);
                textbackground(0);
                write('Û');
                inc(x);
                end;
        end;
      end;
      until (nrec<16384);
    dodate;
    filemode:=66;
    close(dest);
    filemode:=64;
    close(src);
    filemode:=66;
    end;
  end;
end;

function substall(src,old,anew:astr):astr;
var p:integer;
begin
  p:=1;
  while p>0 do begin
    p:=pos(old,src);
    if p>0 then begin
      insert(anew,src,p+length(old));
      delete(src,p,length(old));
    end;
  end;
  substall:=src;
end;

procedure movline(var src:astr; s1,s2:astr);
begin
  src:=substall(src,'@F',s1);
  src:=substall(src,'@I',s2);
end;

function mf(srcname,destname:astr):byte;
var dfs,dft:longint;
    f:file;
    s,s1,s2,s3,opath:astr;
    ok:byte;
    nospace:boolean;
begin
  ok:=0; nospace:=FALSE;

  getdir(0,opath);
  assign(f,srcname);
  filemode:=64;
  {$I-} reset(f,1); {$I+}
  if (ioresult=0) then begin
  dft:=trunc(filesize(f)/1024.0)+1; close(f);
  end;
  dfs:=freek(exdrv(destname));
  cf(ok,nospace,TRUE,srcname,destname);
  if (ok=1) then begin
        if (nospace) then
        displaybox('Error Moving File: Insufficient Space!',3000)
        else
        displaybox('Error Reading Source File!',3000);
  end;
  if (ok=4) then begin
        displaybox('Error Creating Target File!',3000);
  end;
  if (((ok=0) or (ok=2)) and (not nospace)) then begin
    filemode:=17;
    {$I-} erase(f); {$I+}
    if (ioresult<>0) then begin
    displaybox('Error Removing File '+srcname,3000);
    end;
  end;
  chdir(opath);
  filemode:=66;
  mf:=ok;
end;

procedure ee(tp:byte);
var f:file;
begin
case tp of
        1:begin
                assign(f,'INSTALL.DAT');
                {$I-} rename(f,'EXTRACT.EXE'); {$I+}
                if (ioresult<>0) then begin
                        displaybox('Error opening extraction tool.',3000);
                        {$I-} chdir(start_dir); {$I+}
                        if (ioresult<>0) then begin end;
                        clrscr;
                        cursoron(TRUE);
                end;
          end;
        2:begin
                assign(f,'EXTRACT.EXE');
                {$I-} rename(f,'INSTALL.DAT'); {$I+}
                if (ioresult<>0) then begin end;
          end;
end;
end;

procedure endprogram;
begin
ee(2);
{$I-} chdir(start_dir); {$I+}
if (ioresult<>0) then begin end;
textcolor(7);
textbackground(0);
clrscr;
cursoron(TRUE);
halt;
end;

procedure movefile(srcname,destname:astr);
var ok:byte;
    opath:string;
begin
  getdir(0,opath);
  ok:=mf(srcname,destname);
  case ok of
        1,4:if not(pynqbox('Continue installation? ')) then begin
                displaybox('Installation NOT completed!',3000);
                endprogram;
            end;
  end;
  chdir(opath);
end;



procedure newsystem;
begin
with syst do begin
        callernum:=1;
        numusers:=1;
        highnode:=1;
        lastdate:=u_daynum(datelong);
        sgetdatetime(ordate);
        ordone:=TRUE;
        nDescLines:=10;
        nKeywords:=10;
end;
with perm do begin
        LastUserID:=1;
        LastFBaseID:=1;
        LastMBaseID:=1;
        LastDoorID:=0;
        LastEditorID:=0;
end;
end;

procedure newsystat;
var x,k:integer;
    w2:windowrec;
    s:string;
    c2:char;
begin
  repeat
  setwindow(w2,5,11,75,13,3,0,8,'',TRUE);
  gotoxy(2,1);
  textcolor(7);
  textbackground(0);
  write('Main Nexus path: ');
  gotoxy(19,1);
  s:='C:\NEXUS\';
  infield_inp_fgrd:=15;
  infield_inp_bkgd:=1;
  infield_out_fgrd:=3;
  infield_out_bkgd:=0;
  infield_allcaps:=TRUE;
  infield_numbers_only:=FALSE;
  infield_putatend:=TRUE;
  infield_put_slash:=TRUE;
  infield_insert:=TRUE;
  infield_clear:=TRUE;
  infield_escape_blank:=TRUE;
  infielde(s,50);
  infield_put_slash:=FALSE;
  infield_putatend:=FALSE;
  infield_insert:=FALSE;
  infield_clear:=FALSE;
  removewindow(w2);
  if (s='') then begin
  if pynqbox('Abort installation? ') then begin
         endprogram;
  end;
  end;
  until (s<>'');
  NexusDir:=s;
  with systat do begin
    majorversion:=majversion;
    minorversion:=minversion;
    gfilepath:=s+'DATA\';
    afilepath:=s+'DISPLAY\';
    menupath:=s+'MENUS\';
    trappath:=s+'LOGS\';
    userpath:=s+'USERS\';
    utilpath:=s+'UTILS\';
    semaphorepath:=s+'SEMA\';
    filereqpath:=s+'REQUESTS\';
    filepath:=s+'FILEBASE\';
    temppath:=s+'TEMP\';
    swappath:=s+'SWAP\';
    nexecutepath:=s+'NEXECUTE\';
    extuploadpath:='';
    Reserved4path:='';
    netmailpath:='';
    
    bbsname:='New Nexus BBS';
    bbscitystate:='Somewhere, USA';
    bbsphone:='000-000-0000';
    sysopname:='New Nexus Sysop';
    maxusers:=500;
    sysoppw:='SYSOP';
    newuserpw:='';
    eventwarningtime:=3;
    fillchar(res1,sizeof(res1),#0);
    
    sop:='S100';
    csop:='S100';
    msop:='S100';
    fsop:='S100';
    spw:='S100';
    seepw:='S100';
    normpubpost:='S20';
    netmail:='S100';
    seeunval:='S100';
    dlunval:='S100';
    nodlratio:='S100';
    nopostratio:='S100';
    nofilepts:='S100';
    ulvalreq:='S100';
    setnetmailflags:='S100';
    netmailoutofzone:='S100';
    nonodelist:='S100';
    fillchar(res2,sizeof(res2),#0);
    
    maxfback:=3;
    maxpubpost:=50;
    maxchat:=3;
    maxlines:=120;
    csmaxlines:=160;
    maxlogontries:=3;
    sysopcolor:=4;
    usercolor:=3;
    minspaceforpost:=50;
    minspaceforupload:=500;
    backsysoplogs:=7;
    pagelen:=24;
    lastlogdelete:=0;
    fillchar(res3,sizeof(res3),#0);
    
    allowalias:=FALSE;
    aliasprimary:=FALSE;
    phonepw:=FALSE;
    localsec:=FALSE;
    localscreensec:=FALSE;
    globaltrap:=FALSE;
    autochatopen:=TRUE;
    
    newapp:=1;
    timeoutbell:=1;
    timeout:=3;
    usebios:=FALSE;
    cgasnow:=FALSE;
    showlocaloutput:=TRUE;
    showlocaloutput2:=TRUE;
    useextchat:=FALSE;
    fillchar(res4,sizeof(res4),#0);
    fillchar(mxunused2,sizeof(mxunused2),#0);
    
    for x:=1 to 3 do filearccomment[x]:='';
    uldlratio:=TRUE;
    fileptratio:=FALSE;
    fileptcomp:=10;
    fileptcompbasesize:=10;
    ulrefund:=100;
    tosysopdir:=0;
    validateallfiles:=TRUE;
    remdevice:='CON';
    maxintemp:=500;
    minresume:=100;
    searchdup:=0;
    searchdupstrict:=FALSE;
    listtype:=0;
    convertwithav:=FALSE;
    convertsame:=TRUE;
    addwithav:=FALSE;
    
    numusers:=1;
    fillchar(rsrec,sizeof(rsrec),#0);
    fillchar(res8,sizeof(res8),#0);
    fillchar(res,sizeof(res),#0);
end;
end;

procedure getinfo;
var w2:windowrec;
    choices:array[1..4] of string;
    x,current:integer;
    c:char;
    s:string;
    done:boolean;
begin
done:=false;
choices[1]:='BBS name       :';
choices[2]:='Your real name :';
choices[3]:='Your password  :';
choices[4]:='Your birthdate :';
setwindow(w2,10,10,70,17,3,0,8,'System Information',TRUE);
for x:=1 to 4 do begin
gotoxy(2,x+1);
textcolor(7);
textbackground(0);
write(choices[x]);
end;
gotoxy(19,2);
textcolor(3);
write(systat.bbsname); {80}
gotoxy(19,3);
write(user.realname); {36}
gotoxy(19,4);
write(user.pw); {20}
gotoxy(19,5);
unixtodt(user.bday,fddt);
write(formatteddate(fddt,'MM/DD/YYYY')); {8}
current:=1;
  window(1,1,80,25);
  gotoxy(1,25);
  textcolor(14);
  textbackground(0);
  write('Esc');
  textcolor(7);
  write('=Exit');
  textcolor(14);
  write(' F10');
  textcolor(7);
  write('=Done  ');
  textcolor(14);
  write('Configuration of BBS Name and Your Info                 ');
window(11,11,69,16);
repeat
gotoxy(2,current+1);
textcolor(15);
textbackground(1);
write(choices[current]);
while not(keypressed) do begin end;
c:=readkey;
case c of
        #0:begin
                c:=readkey;
                case c of
                        #72:begin
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choices[current]);
                                dec(current);
                                if (current=0) then current:=4;
                            end;
                        #80:begin
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choices[current]);
                                inc(current);
                                if (current=5) then current:=1;
                            end;
                        #68,#77:done:=TRUE;
                end;
           end;
       #13:begin
                gotoxy(2,current+1);
                textcolor(7);
                textbackground(0);
                write(choices[current]);
                gotoxy(17,current+1);
                textcolor(9);
                write('>');
                gotoxy(19,current+1);
                case current of
                        1:begin
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=false;
                                        infield_numbers_only:=FALSE;
                                        infield_show_colors:=TRUE;
                                        infield_maxshow:=38;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        infield_insert:=TRUE;
                                        s:=systat.bbsname;
                                        infielde(s,80);
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        if (s<>systat.bbsname) then begin
                                                systat.bbsname:=s;
                                        end;
                          end;
                        2:begin
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=false;
                                        infield_numbers_only:=FALSE;
                                        infield_show_colors:=TRUE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        infield_insert:=TRUE;
                                        s:=user.realname;
                                        infielde(s,36);
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        if (s<>user.realname) then begin
                                                user.realname:=caps(s);
                                                user.name:=(caps(s));
                                                systat.sysopname:=s;
                                        end;
                          end;
                        3:begin
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=TRUE;
                                        infield_numbers_only:=FALSE;
                                        infield_show_colors:=TRUE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        infield_insert:=TRUE;
                                        s:=user.pw;
                                        infielde(s,20);
                                        infield_allcaps:=FALSE;
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        if (s<>user.pw) then begin
                                                user.pw:=s;
                                        end;
                          end;
                        4:begin
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=false;
                                        infield_numbers_only:=FALSE;
                                        infield_show_colors:=TRUE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        infield_insert:=TRUE;
                                        unixtodt(user.bday,fddt);
                                        s:=formatteddate(fddt,'MM/DD/YYYY');
                                        infielde(s,10);
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        if (s<>formatteddate(fddt,'MM/DD/YYYY')) then begin
                                                user.bday:=u_daynum(s);
                                        end;
                          end;
                end;
           end;
       #27:begin
                endprogram;
           end;
end;
until (done);
removewindow(w2);
end;

procedure newurec;
var c:char;
begin
with user do begin
Name:='New Nexus Sysop';
RealName:='New Nexus Sysop';
UserID:=1;
pw:='SYSOP';
phone1:='000-000-0000';
phone2:='000-000-0000';
phone3:='000-000-0000';
phone4:='000-000-0000';
street:='';
street2:='';
citystate:='';
zipcode:='00000-0000';
bday:=u_daynum('01/01/1970');
firston:=u_daynum(datelong);
laston:=u_daynum(datelong);
filescandate:=u_daynum(datelong);
sex:='U';
option1:='';
option2:='';
option3:='';
note:='The SysOp of this fine Nexus BBS!';
business:='A New Nexus BBS';
title:='';
for x:=1 to 4 do desc[x]:='';
for x:=1 to 20 do clearentry[x]:=FALSE;
for x:=1 to sizeof(reserved1) do reserved1[x]:=0;
phentrytype:=1;
zipentrytype:=1;
sl:=100;
ac:=[onekey,ansi,color,usetaglines,pause,novice,fnodlratio,fnopostratio,fnofilepts,fnodeletion];
ar:=[];
for c:='A' to 'Z' do
ar:=ar+[c];
lockedout:=FALSE;
deleted:=FALSE;
lockedfile:='';

for x:=1 to sizeof(reserved2) do reserved2[x]:=0;
ttimeon:=0;
loggedon:=0;
tltoday:=500;
ontoday:=0;
illegal:=0;
credit:=0;
filepoints:=1000;
timebank:=0;
timebankadd:=0;
trapactivity:=FALSE;
trapseperate:=FALSE;
chatauto:=FALSE;
chatseperate:=FALSE;
slogseperate:=FALSE;
pagelen:=24;
uscheme:=1;
userstartmenu:=6;

for x:=1 to sizeof(reserved3) do reserved3[x]:=0;

lastfconf:=0;
lastfil:=0;
uk:=0;
dk:=0;
uploads:=0;
downloads:=0;
defprotocol:='@';
for x:=1 to 20 do uboardsysop[x]:=-1;
for x:=1 to 20 do boardsysop[x]:=-1;
for x:=1 to sizeof(reserved4) do reserved4[x]:=0;

lastmconf:=0;
lastmsg:=0;
msgpost:=0;
feedback:=0;
mruler:=1;
msgeditor:=0;
subscription:=3;
subdate:=u_daynum(datelong+'  '+time);
for x:=1 to sizeof(reserved5) do reserved5[x]:=0;
END;

end;

function exist(fn:string):boolean;
var srec:searchrec;
begin
  findfirst(fn,anyfile,srec);
  exist:=(doserror=0);
end;

procedure info(s:string);
begin
window(1,1,80,25);
gotoxy(1,25);
textcolor(14);
textbackground(0);
clreol;
write(s);
window(1,1,80,24);
end;

procedure unpack(s,s2,s3:string);
var x:integer;
    skip:boolean;
    f:file;
    w2:windowrec;
begin
cursoron(FALSE);
skip:=FALSE;
if not(exist(startdir+'\'+s+'.DAT')) then begin
        if not(pynqbox(s+'.DAT does not exist. Continue anyway? ')) then begin
                endprogram;
        end else skip:=TRUE;
end;
if not(skip) then begin
extractfiles(2,18,77,23,3,0,8,'Extraction Progress: '+s3,TRUE,startdir+'\'+s+'.DAT','.\NEXTEMP\',s2);
{ savescreen(w2,1,1,80,25);
assign(f,s+'.DAT');
rename(f,s+'.EXE');
Init_spawno(start_dir,swap_all,20,0);
if (spawn(getenv('COMSPEC'),'/c '+startdir+'\'+s+'.EXE',0)=-1) then begin
        displaybox('Error uncompressing '+s+'.DAT!',3000);
        if not(pynqbox('Continue installation? ')) then begin
        endprogram;
        end;
end;
assign(f,s+'.EXE');
rename(f,s+'.DAT');
removewindow(w2); }
end;
end;

procedure move(srcname,destname,s3:string);
var x:integer;
    ok,nospace:boolean;
    sr:searchrec;
    w15:windowrec;
begin
cursoron(FALSE);
setwindow(w15,2,18,77,23,3,0,8,'Moving Files: '+s3,TRUE);
textcolor(3);
textbackground(0);
gotoxy(2,2);
window(3,19,76,22);
findfirst(srcname,anyfile-directory-volumeid,sr);
while (doserror=0) do begin
textcolor(15);
write(mln(sr.name,12)+' ');
movefile(pathonly(srcname)+sr.name,destname+'\'+sr.name);
writeln;
findnext(sr);
end;
removewindow(w15);
end;


procedure getdirs;
var s:string[80];
    desc:array[0..14] of string;
    c:char;
    current:integer;
    done,changed:boolean;
begin
  done:=FALSE;
  desc[0]:='Main Nexus Directory     :';
  desc[1]:='Data Files               :';
  desc[2]:='Display Files            :';
  desc[3]:='Default Message Path     :';
  desc[4]:='Menu Files               :';
  desc[5]:='File Databases           :';
  desc[6]:='Utility Files            :';
  desc[7]:='Semaphore Files          :';
  desc[8]:='Offline File Request Path:';
  desc[9]:='Log Files                :';
  desc[10]:='Temporary Files          :';
  desc[11]:='Swap Files               :';
  desc[12]:='Nexecutable Directory    :';
  {desc[13]:='System Start-Out Menu    :';
  desc[14]:='Default News Prefix File :';}
  window(1,1,80,25);
  gotoxy(1,25);
  textcolor(14);
  textbackground(0);
  write('Esc');
  textcolor(7);
  write('=Exit ');
  textcolor(14);
  write('F10');
  textcolor(7);
  write('=Done  ');
  textcolor(14);
  write('Edit Nexus Directories To Determine Where To Install');
  window(1,1,80,24);
  setwindow2(wind,3,6,77,22,3,0,8,'Nexus Install','Set Directories',TRUE);
  for x:=0 to 12 do begin
  gotoxy(2,x+2);
  textcolor(7);
  textbackground(0);
  write(desc[x]);
  end;
  textcolor(3);
  textbackground(0);
  gotoxy(29,2);
  write(NexusDir);
  gotoxy(29,3);
  write(systat.gfilepath);
  gotoxy(29,4);
  write(systat.afilepath);
  gotoxy(29,5);
  write(systat.userpath);
  gotoxy(29,6);
  write(systat.menupath);
  gotoxy(29,7);
  write(systat.filepath);
  gotoxy(29,8);
  write(systat.utilpath);
  gotoxy(29,9);
  write(systat.semaphorepath);
  gotoxy(29,10);
  write(systat.filereqpath);
  gotoxy(29,11);
  write(systat.trappath);
  gotoxy(29,12);
  write(systat.temppath);
  gotoxy(29,13);
  write(systat.swappath);
  gotoxy(29,14);
  write(systat.nexecutepath);
  current:=0;
  cursoron(FALSE);
  with systat do begin
  repeat
  gotoxy(2,current+2);
  textcolor(15);
  textbackground(1);
  write(desc[current]);
  c:=readkey;
  case c of
        #0:begin
                c:=readkey;
                case c of
                        #68,#77:done:=TRUE;
                        #72:begin
                                textcolor(7);
                                textbackground(0);
                                gotoxy(2,current+2);
                                write(desc[current]);
                                if current=0 then current:=12 else dec(current);
                        end;
                        #80:begin
                                textcolor(7);
                                textbackground(0);
                                gotoxy(2,current+2);
                                write(desc[current]);
                                if current=12 then current:=0 else inc(current);
                        end;
                end;
        end;
        #13:begin
                textcolor(7);
                textbackground(0);
                gotoxy(2,current+2);
                write(desc[current]);
                case current of
                0:s:=NexusDir;
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
                end;
                                infield_inp_fgrd:=15;
                                infield_inp_bkgd:=1;
                                infield_out_fgrd:=3;
                                infield_out_bkgd:=0;
                                infield_allcaps:=TRUE;
                                infield_numbers_only:=false;
                                gotoxy(27,current+2);
                                textcolor(9);
                                textbackground(0);
                                write('>');
                                gotoxy(29,current+2);
                                infielde(s,45);
                                if copy(s,length(s),1)<>'\' then begin
                                        s:=s+'\';
                                        gotoxy(29,current+2);
                                        textcolor(3);
                                        textbackground(0);
                                        write(s);
                                end;
                case current of
                0:NexusDir:=s;
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
                end;
         end;
         #27:begin
                if pynqbox('Abort installation? ') then begin
                endprogram;
                end;
         end;
  end;
  until (done);
  removewindow(wind);
  end;
end;

procedure bscreen;
var  wfcFile : file;
begin
   window(1,1,80,25);
   //cursoron(FALSE);
   //assign(wfcFile,bslash(true,pathonly(paramstr(0)))+'INSTALL.BIN');
   //{$I-} reset(wfcFile,1); {$I+}
   //if (ioresult<>0) then begin
   //     displaybox('Error reading '+bslash(true,pathonly(paramstr(0)))+'INSTALL.BIN',2000);
   //     halt;
   //end;
   //if (filesize(wfcfile)<4000) then begin
   //     displaybox(bslash(true,pathonly(paramstr(0)))+'INSTALL.BIN is an invalid size!',2000);
   //     halt;
   //end;
   //blockRead(wfcFile,mem[$B800:0],4000);
   //close(wfcFile);
end;

begin
    filemode:=66;
    getdir(0,start_dir);
    startdir:=bslash(false,start_dir);
    textcolor(7);
    textbackground(0);
    bscreen;
    ee(1);
    if exist('NEXTEMP') then
    purgedir('NEXTEMP');
    newsystat;
    newsystem;
    newurec;
    getdirs;
    getinfo;

    info('Creating directory structure for Nexus BBS Software...');
    showad(1);
    {$I-} mkdir(copy(NexusDir,1,length(Nexusdir)-1)); {$I+}
    if (ioresult<>0) then begin
        if not(pynqbox(Nexusdir+' already exists. Continue? ')) then begin
                endprogram;
        end;
    end;
    {$I-}      mkdir(copy(systat.gfilepath,1,length(systat.gfilepath)-1)); {$I+}
    if (ioresult<>0) then begin
        if not(pynqbox(systat.gfilepath+' already exists. Continue? ')) then begin
                endprogram;
        end;
    end;
    {$I-}      mkdir(systat.gfilepath+'THEMES'); {$I+}
    if (ioresult<>0) then begin
        if not(pynqbox(systat.gfilepath+'THEMES already exists. Continue? ')) then begin
                endprogram;
        end;
    end;
    {$I-}      mkdir(copy(systat.afilepath,1,length(systat.afilepath)-1)); {$I+}
    if (ioresult<>0) then begin
        if not(pynqbox(systat.afilepath+' already exists. Continue? ')) then begin
                endprogram;
        end;
    end;
    {$I-}      mkdir(copy(systat.userpath,1,length(systat.userpath)-1));     {$I+}
    if (ioresult<>0) then begin
        if not(pynqbox(systat.userpath+' already exists. Continue? ')) then begin
                endprogram;
        end;
    end;
    {$I-}      mkdir(systat.userpath+'00000001'); {$I+}
    if (ioresult<>0) then begin end;
    {$I-}      mkdir(systat.userpath+'00000001\FATTACH'); {$I+}
    if (ioresult<>0) then begin end;
    {$I-}      mkdir(copy(systat.menupath,1,length(systat.menupath)-1));   {$I+}
    if (ioresult<>0) then begin
        if not(pynqbox(systat.menupath+' already exists. Continue? ')) then begin
                endprogram;
        end;
    end;
    {$I-}      mkdir(copy(systat.filepath,1,length(systat.filepath)-1));   {$I+}
    if (ioresult<>0) then begin
        if not(pynqbox(systat.filepath+' already exists. Continue? ')) then begin
                endprogram;
        end;
    end;
    {$I-}      mkdir(copy(systat.filereqpath,1,length(systat.filereqpath)-1));   {$I+}
    if (ioresult<>0) then begin
        if not(pynqbox(systat.filereqpath+' already exists. Continue? ')) then begin
                endprogram;
        end;
    end;
    {$I-}      mkdir(copy(systat.utilpath,1,length(systat.utilpath)-1));   {$I+}
    if (ioresult<>0) then begin
        if not(pynqbox(systat.utilpath+' already exists. Continue? ')) then begin
                endprogram;
        end;
    end;
    {$I-}      mkdir(copy(systat.utilpath,1,length(systat.utilpath)-1)+'\NXFLC');   {$I+}
    if (ioresult<>0) then begin
        if not(pynqbox(systat.utilpath+'\NXFLC\ already exists. Continue? ')) then begin
                endprogram;
        end;
    end;
    {$I-}      mkdir(copy(systat.semaphorepath,1,length(systat.semaphorepath)-1)); {$I+}
    if (ioresult<>0) then begin
        if not(pynqbox(systat.semaphorepath+' already exists. Continue? ')) then begin
                endprogram;
        end;
    end;
    {$I-}      mkdir(copy(systat.trappath,1,length(systat.trappath)-1));   {$I+}
    if (ioresult<>0) then begin
        if not(pynqbox(systat.trappath+' already exists. Continue? ')) then begin
                endprogram;
        end;
    end;
    {$I-}      mkdir(copy(systat.temppath,1,length(systat.temppath)-1));   {$I+}
    if (ioresult<>0) then begin
        if not(pynqbox(systat.temppath+' already exists. Continue? ')) then begin
                endprogram;
        end;
    end;
    {$I-}      mkdir(copy(systat.swappath,1,length(systat.swappath)-1));   {$I+}
    if (ioresult<>0) then begin
        if not(pynqbox(systat.swappath+' already exists. Continue? ')) then begin
                endprogram;
        end;
    end;
    {$I-}      mkdir(copy(systat.nexecutepath,1,length(systat.nexecutepath)-1)); {$I+}
    if (ioresult<>0) then begin
        if not(pynqbox(systat.nexecutepath+' already exists. Continue? ')) then begin
                endprogram;
        end;
    end;
    {$I-}      mkdir(copy(systat.nexecutepath,1,length(systat.nexecutepath)-1)+'\SOURCE'); {$I+}
    if (ioresult<>0) then begin
        if not(pynqbox(systat.nexecutepath+'SOURCE\ already exists. Continue? ')) then begin
                endprogram;
        end;
    end;
    {$I-} mkdir(NexusDir+'DOCS'); {$I+}
    if (ioresult<>0) then begin
        if not(pynqbox(Nexusdir+'DOCS\ already exists. Continue? ')) then begin
                endprogram;
        end;
    end;
    {$I-} mkdir(NexusDir+'CHAT'); {$I+}
    if (ioresult<>0) then begin
        if not(pynqbox(Nexusdir+'CHAT\ already exists. Continue? ')) then begin
                endprogram;
        end;
    end;
    {$I-} mkdir(NexusDir+'CHAT\MSG'); {$I+}
    if (ioresult<>0) then begin
        if not(pynqbox(Nexusdir+'CHAT\MSG\ already exists. Continue? ')) then begin
                endprogram;
        end;
    end;
    info('Unpacking Main System Directory...');
    unpack('EXES','*.*','EXECUTABLES');
    move('NEXTEMP\*.*',copy(NexusDir,1,length(Nexusdir)-1),'EXECUTABLES');
    removewindow(w10);
    showad(2);
    info('Unpacking utilities...');
    unpack('UTIL','*.*','UTILITIES');
    move('NEXTEMP\*.*',copy(systat.utilpath,1,length(systat.utilpath)-1),'UTILITIES');
    info('Unpacking nxFLC File List Compiler...');
    unpack('UTILFLC','*.*','nxFLC Compiler');
    removewindow(w10);
    showad(3);
    move('NEXTEMP\*.*',copy(systat.utilpath,1,length(systat.utilpath)-1)+'\NXFLC','nxFLC Compiler');
    info('Unpacking data files...');
    unpack('DATA','*.*','DATA Files');
    move('NEXTEMP\*.*',copy(systat.gfilepath,1,length(systat.gfilepath)-1),'DATA Files');
    move('NEXTEMP\THEMES\*.*',systat.gfilepath+'THEMES','WFC Themes');
    info('Unpacking menu files...');
    unpack('MENU','*.*','MENU Files');
    move('NEXTEMP\*.*',copy(systat.menupath,1,length(systat.menupath)-1),'MENU Files');
    info('Unpacking display files...');
    unpack('MISC','*.*','DISPLAY Files');
    move('NEXTEMP\*.*',copy(systat.afilepath,1,length(systat.afilepath)-1),'DISPLAY Files');
    info('Unpacking Nexecutables, compiler, and example source...');
    unpack('NPX','*.*','Nexecutables');
    move('NEXTEMP\*.*',copy(systat.nexecutepath,1,length(systat.nexecutepath)-1),'Nexecutables');
    unpack('NPXSRC','*.*','Nexecutable Source');
    move('NEXTEMP\*.*',copy(systat.nexecutepath,1,length(systat.nexecutepath)-1)+'\SOURCE','Nexecutable Source');
    info('Unpacking documentation...');
    unpack('DOCS','*.*','Documentation');
    move('NEXTEMP\*.*',NexusDir+'DOCS','Documentation');
    move(startdir+'\CONTACT.TXT',nexusdir+'DOCS','Contact Information');
    move(startdir+'\LICENSE.TXT',nexusdir+'DOCS','License Information');
    removewindow(w10);
    info('Creating MATRIX.DAT ...');
    assign(systatf,Nexusdir+'MATRIX.DAT');
    {$I-} rewrite(systatf); {$I+}
    write(systatf,systat);
    close(systatf);
    info('Creating User Database...');
    assign(uf,systat.gfilepath+'USERS.DAT');
    {$I-} rewrite(uf); {$I+}
    if (ioresult<>0) then begin
        displaybox('Error Creating USERS.DAT! Contact Nexus Support!',3000);
        endprogram;
    end;
    write(uf,user);
    write(uf,user);
    close(uf);
    info('Creating SYSTEM.DAT...');
    assign(systf,systat.gfilepath+'SYSTEM.DAT');
    {$I-} rewrite(systf); {$I+}
    if (ioresult<>0) then begin
        displaybox('Error creating SYSTEM.DAT! Contact Nexus Support!',3000);
        endprogram;
    end;
    write(systf,syst);
    close(systf);
    info('Creating PERMID.DAT...');
    assign(permf,systat.gfilepath+'PERMID.DAT');
    {$I-} rewrite(permf); {$I+}
    if (ioresult<>0) then begin
        displaybox('Error creating PERMID.DAT! Contact Nexus Support!',3000);
        endprogram;
    end;
    write(permf,perm);
    close(permf);
    info('Removing Temporary Directories...');
    if (exist('NEXTEMP\THEMES')) then begin
        purgedir('NEXTEMP\THEMES');
        {$I+} rmdir('NEXTEMP\THEMES'); {$I-}
        if (ioresult<>0) then begin
                displaybox('Error Removing Temprorary Directory .\NEXTEMP\THEMES\ ...',3000);
        end;
    end;
    if (exist('NEXTEMP')) then begin
        purgedir('NEXTEMP');
        {$I+} rmdir('NEXTEMP'); {$I-}
        if (ioresult<>0) then begin
                displaybox('Error Removing Temprorary Directory .\NEXTEMP\ ...',3000);
        end;
    end;
    CreateDefaultTags(1);
    CreateDefaultTags(2);
    {$I-} chdir(start_dir); {$I+}
    if (ioresult<>0) then begin end;
    info('Successfully completed Nexus Bulletin Board System Installation!');
    displaybox('Installation Complete.',3000);
    delay(500);
    nexusdir:=bslash(FALSE,nexusdir);
    setwindow(wind,2,8,78,23,3,0,8,'Reminder...',TRUE);
    textcolor(7);
    textbackground(0);
    gotoxy(1,2);
    writeln(' Be sure to set your Nexus environment variable before running any portion');
    writeln(' of Nexus.  (ex. set NEXUS=',nexusdir,' )');
    writeln;
    writeln(' To configure Nexus, run NXSETUP.EXE, which is in your UTILS directory.');
    writeln(' For help with Nexus command line parameters, run NEXUS -?.');
    writeln;
    writeln(' Thank you for installing the Unlicensed Freeware copy of Nexus Bulletin');
    writeln(' Board System. We hope that Nexus will provide you with all that you need');
    writeln(' for your Bulletin Board System. Please let us know if you have any');
    writeln(' problems, questions, concerns, or general comments.  Information on how');
    writeln(' to contact the Nexus Development Team is listed in the CONTACT.TXT file');
    writeln(' in your Documentation (DOCS) directory.');
    info('Press any key to continue...');
    while not(keypressed) do begin end;
    c:=readkey;
    removewindow(wind);
    window(1,1,80,25);
    textcolor(7);
    textbackground(0);
    endprogram;
end.
