(*****************************************************************************)
(*>                                                                         <*)
(*>  SYSOP3  .PAS -  Written by Eric Oman                                   <*)
(*>                                                                         <*)
(*>  SysOp functions: User Editor.                                          <*)
(*>                                                                         <*)
(*****************************************************************************)
{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R-,S+,V-}
unit sysop3;

interface

uses
  crt, dos, myio, misc,procspec,mkmisc;

procedure uedit1(NexusDir:string);
procedure uedit(usern:integer);

implementation

uses init2, mkstring;

const nnnew:boolean=TRUE;

var ndir:string;
    w2:windowrec;


procedure uedit1(NexusDir:string);
begin
  Ndir:=NexusDir;
  uedit(1);
end;



function getsubscript:byte;
var firstlp,lp,lp2:listptr;
    ssf:file of subscriptionrec;
    ss:subscriptionrec;
    rt:returntype;
    w3:windowrec;
    x,x2,cur,top:integer;
    b:byte;
    s:string;

begin
assign(ssf,systat.gfilepath+'SUBSCRIP.DAT');
{$I-} reset(ssf); {$I+}
if (ioresult<>0) then begin
        displaybox('Error Reading SUBSCRIP.DAT.',3000);
        rewrite(ssf);
        with ss do begin
                Description:='';
                SL:=0;
                arflags:=[];
                ARmodifier:=0;
                ACflags:=[];
                acmodifier:=0;
                Filepoints:=0;
                FPmodifier:=0;
                Credits:=0;
                Cmodifier:=0;
                TimeBank:=0;
                TBmodifier:=0;
                SubLength:=0;
                NewSubLevel:=0;
                for x:=1 to 20 do reserved[x]:=0;
                write(ssf,ss);
                Description:='New User Subscription';
                SL:=10;
                arflags:=[];
                ARmodifier:=0;
                ACflags:=[];
                acmodifier:=0;
                Filepoints:=100;
                FPmodifier:=1;
                Credits:=0;
                Cmodifier:=0;
                TimeBank:=0;
                TBmodifier:=0;
                SubLength:=0;
                NewSubLevel:=0;
                for x:=1 to 20 do reserved[x]:=0;
                write(ssf,ss);
                end;
end;
listbox_tag:=FALSE;
listbox_move:=FALSE;
listbox_delete:=false;
listbox_insert:=false;
top:=1;
cur:=1;
new(lp);
seek(ssf,1);
read(ssf,ss);
lp^.p:=NIL;
lp^.list:=mln(mln(cstr(1),3)+ss.description,30);
firstlp:=lp;
x:=2;
while not(eof(ssf)) do begin
        read(ssf,ss);
        new(lp2);
        lp2^.p:=lp;
        lp^.n:=lp2;
        lp2^.list:=mln(mln(cstr(x),3)+ss.description,30);
        lp:=lp2;
        inc(x);
end;
lp^.n:=NIL;
lp:=firstlp;
for x:=1 to 100 do rt.data[x]:=-1;
b:=0;
listbox(w3,rt,top,cur,lp,43,7,77,20,3,0,8,'Subscription Levels','',TRUE);
case rt.kind of
        1:begin
              if (rt.data[1]<>-1) then begin
                   b:=rt.data[1];
              end;
          end;
end;
listbox_tag:=TRUE;
listbox_move:=TRUE;
listbox_delete:=TRUE;
listbox_insert:=TRUE;
removewindow(w3);
lp:=firstlp;
while (lp<>NIL) do begin
         lp2:=lp^.n;
         dispose(lp);
         lp:=lp2;
end;
close(ssf);
getsubscript:=b;
end;

function showsubscription(b:byte):string;
var ssf:file of subscriptionrec;
    ss:subscriptionrec;
    s:string;
    x:integer;
begin
assign(ssf,systat.gfilepath+'SUBSCRIP.DAT');
{$I-} reset(ssf); {$I+}
if (ioresult<>0) then begin
        displaybox('Error Reading SUBSCRIP.DAT.',3000);
        rewrite(ssf);
        with ss do begin
                Description:='';
                SL:=0;
                arflags:=[];
                ARmodifier:=0;
                ACflags:=[];
                acmodifier:=0;
                Filepoints:=0;
                FPmodifier:=0;
                Credits:=0;
                Cmodifier:=0;
                TimeBank:=0;
                TBmodifier:=0;
                SubLength:=0;
                NewSubLevel:=0;
                for x:=1 to 20 do reserved[x]:=0;
                write(ssf,ss);
                Description:='New User Subscription';
                SL:=10;
                arflags:=[];
                ARmodifier:=0;
                ACflags:=[];
                acmodifier:=0;
                Filepoints:=100;
                FPmodifier:=1;
                Credits:=0;
                Cmodifier:=0;
                TimeBank:=0;
                TBmodifier:=0;
                SubLength:=0;
                NewSubLevel:=0;
                for x:=1 to 20 do reserved[x]:=0;
                write(ssf,ss);
                end;
end;
s:='None';
if (b>filesize(ssf)-1) then s:='None' else begin
seek(ssf,b);
read(ssf,ss);
s:=ss.description;
end;
close(ssf);
showsubscription:=s;
end;

function getseclevel:byte;
var firstlp,lp,lp2:listptr;
    rt:returntype;
    foundat,x,x2,cur,top:integer;
    b,tempb:byte;
    s:string;
    securityf:file of securityrec;
    security:securityrec;
    update,done,changed,found,ok:boolean;

begin
tempb:=0;
assign(securityf,systat.gfilepath+'SECURITY.DAT');
{$I-} reset(securityf); {$I+}
if (ioresult<>0) then begin
        displaybox('Error Reading SECURITY.DAT.',3000);
        exit;
end;
listbox_tag:=FALSE;
listbox_move:=FALSE;
listbox_insert:=FALSE;
listbox_delete:=FALSE;
done:=FALSE;
update:=TRUE;
repeat
if (update) then begin
new(lp);
found:=FALSE;
foundat:=0;
seek(securityf,1);
while not(eof(securityf)) and not(found) do begin
read(securityf,security);
if (security.active) then begin
lp^.p:=NIL;
lp^.list:=mln(cstr(filepos(securityf)-1),3)+'  '+security.description;
firstlp:=lp;
found:=TRUE;
foundat:=filepos(securityf)-1;
end;
end;
if (found) then
for x:=(foundat+1) to 100 do begin
        {$I-} seek(securityf,x); {$I+}
        if (ioresult<>0) then begin
                displaybox('SECURITY.DAT has been corrupted.',3000);
                exit;
        end;
        read(securityf,security);
        if (security.active) then begin
        new(lp2);
        lp2^.p:=lp;
        lp^.n:=lp2;
        lp2^.list:=mln(cstr(filepos(securityf)-1),3)+'  '+security.description;
        lp:=lp2;
        end;
end;
lp^.n:=NIL;
lp:=firstlp;
top:=1;
cur:=1;
for x:=1 to 100 do rt.data[x]:=-1;
end;
listbox(w2,rt,top,cur,lp,25,7,55,20,3,0,8,'Security Levels','',TRUE);
case rt.kind of
        1:begin
              if (rt.data[1]<>-1) then begin
                   b:=rt.data[1];
                   x:=0;
                   seek(securityf,1);
                   while (x<b) and not(eof(securityf)) do begin
                        read(securityf,security);
                        if (security.active) then begin
                                inc(x);
                                x2:=filepos(securityf)-1;
                        end;
                   end;
                   tempb:=x2;
                   done:=TRUE;
              end;
          end;
        2:done:=TRUE;
end;
until (done);
listbox_tag:=TRUE;
listbox_move:=TRUE;
listbox_insert:=TRUE;
listbox_delete:=TRUE;
removewindow(w2);
lp:=firstlp;
while (lp<>NIL) do begin
         lp2:=lp^.n;
         dispose(lp);
         lp:=lp2;
end;
close(securityf);
getseclevel:=tempb;
end;

procedure finduserws2(var usernum:integer);
TYPE
  ulistptr = ^ulisttype;
  ulisttype = RECORD
        p:ulistptr;
        n:ulistptr;
        urecord:integer;
  end;

var user:userrec;
    sr:smalrec;
    nn,duh:astr;
    tp,x,t,i,i1,gg:integer;
    firstulp,ulp,ulp2:ulistptr;
    firstlp,lp,lp2:listptr;
    cur,top:integer;
    rt:returntype;
    s:string;
    c:char;
    ufo,done,asked:boolean;

{procedure sortlist;
function swapptrs;
begin
     lp^.n^.p:=lp^.p;
     lp^.n:=lp2^.n;
     lp2^n:=lp;
     lp^.p:=lp2;
end;

begin
end;}

begin
listbox_tag:=FALSE;
listbox_move:=FALSE;
listbox_insert:=FALSE;
listbox_delete:=FALSE;
  ufo:=(filerec(uf).mode<>fmclosed);
  if (not ufo) then reset(uf);
  if (nnnew) then begin
        nnnew:=FALSE;
        nn:='';
  end;
  asked:=FALSE;
  setwindow(w2,8,11,72,13,3,0,8,'Search for User',TRUE);
  gotoxy(2,1);
  textcolor(7);
  textbackground(0);
  write('Name or Partial String:');
  gotoxy(26,1);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=TRUE;
                                        infield_numbers_only:=FALSE;
                                        infield_show_colors:=FALSE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        infield_insert:=TRUE;
                                        infielde(nn,36);
                                        infield_maxshow:=0;
                                        infield_allcaps:=FALSE;
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
  removewindow(w2);
  usernum:=0;
  if (nn='SYSOP') then usernum:=1;
    if (nn<>'') then begin
      {$I-} reset(sf); {$I+}
      if (ioresult<>0) then begin
        displaybox('Error Reading USERS.IDX!',3000);
        usernum:=0;
        exit;
      end;
      done:=FALSE; asked:=FALSE;
      gg:=0;
      displaybox2(w2,'Searching for user...');
      while ((gg<filesize(sf)-1) and (not done)) do begin
      inc(gg);
      seek(sf,gg); read(sf,sr);
      if ((allcaps(sr.name)=allcaps(nn)) or (allcaps(sr.real)=allcaps(nn))) then begin
            usernum:=sr.number;
            done:=TRUE;
      end;
      end;
      if (done) then removewindow(w2);
      gg:=0;
      while ((gg<filesize(sf)-1) and (not done)) do begin
	inc(gg);
	seek(sf,gg); read(sf,sr);
	tp:=0;
        if (pos(allcaps(nn),allcaps(sr.real))<>0) then tp:=2 else
        if (pos(allcaps(nn),allcaps(sr.name))<>0) then tp:=1; 
        if (tp=1) then if (allcaps(sr.name)=allcaps(sr.real)) then tp:=2;
	if (tp<>0) then          
          begin
            if (not asked) then begin
            asked:=TRUE;
                                new(lp);
                                new(ulp);
                                lp^.p:=NIL;
                                ulp^.p:=NIL;
                                lp^.list:=mln(cstr(sr.UserID),5);
                                if (tp=1) then lp^.list:=lp^.list+' '+mln(sr.name,36)+' (Alias)'
                                else lp^.list:=lp^.list+' '+mln(sr.real,36)+'  (Real)';
                                ulp^.urecord:=sr.number;
                                firstlp:=lp;
                                firstulp:=ulp;
            end else begin
                                new(lp2);
                                new(ulp2);
                                lp2^.p:=lp;
                                lp^.n:=lp2;
                                ulp2^.p:=ulp;
                                ulp^.n:=ulp2;
                                lp2^.list:=mln(cstr(sr.UserID),5);
                                if (tp=1) then lp2^.list:=lp2^.list+' '+mln(sr.name,36)+' (Alias)'
                                else lp2^.list:=lp2^.list+' '+mln(sr.real,36)+'  (Real)';
                                ulp2^.urecord:=sr.number;
                                lp:=lp2;
                                ulp:=ulp2;
            end;
          end;
      end;
      if (usernum=0) and (asked) then begin
                                removewindow(w2);
                                lp^.n:=NIL;
                                ulp^.n:=NIL;
                                top:=1;
                                cur:=1;
                                for x:=1 to 100 do rt.data[x]:=-1;
                                lp:=firstlp;
                                ulp:=firstulp;
                                listbox(w2,rt,top,cur,lp,13,8,69,21,3,0,8,'Search User','',TRUE);
                                case rt.kind of
                                        1:begin
                                          if (rt.data[1]<>-1) then begin
                                          x:=1;
                                          while (x<rt.data[1]) do begin
                                                if (ulp^.n<>NIL) then begin
                                                        ulp:=ulp^.n;
                                                end else begin
                                                        usernum:=-1;
                                                        x:=rt.data[1];
                                                end;
                                                inc(x);
                                          end;
                                          if (usernum=-1) then usernum:=0 else
                                          begin
                                                usernum:=ulp^.urecord;
                                          end;
                                          end;
                                          end;
                                        2:begin
                                                usernum:=0;
                                          end;
                                end;
                                                lp:=firstlp;
                                                while (lp<>NIL) do begin
                                                        lp2:=lp^.n;
                                                        dispose(lp);
                                                        lp:=lp2;
                                                end;
                                                ulp:=firstulp;
                                                while (ulp<>NIL) do begin
                                                        ulp2:=ulp^.n;
                                                        dispose(ulp);
                                                        ulp:=ulp2;
                                                end;
                                                removewindow(w2);
      end;
      if (usernum=0) and not(asked) then begin
        removewindow(w2);
        displaybox('User not found.',3000);
      end;
      close(sf);
    end;
  if (not ufo) then close(uf);
listbox_tag:=TRUE;
listbox_move:=TRUE;
listbox_insert:=TRUE;
listbox_delete:=TRUE;
  pynqbox_escape:=FALSE;
end;




procedure isr(uname,ureal,nick:astr; usernum:integer; UID:LONGINT);
var x,t,i,ii:integer;
    sr:smalrec;
    found,sfo:boolean;
    uidf:file of useridrec;
    uid2:useridrec;
begin
  sfo:=(filerec(sf).mode<>fmclosed);
  if (not sfo) then reset(sf);

  if (filesize(sf)=1) then ii:=0
  else begin
    ii:=usernum;
    for i:=filesize(sf)-1 downto ii+1 do begin
      seek(sf,i); read(sf,sr);
      seek(sf,i+1); write(sf,sr);
    end;
  end;
  fillchar(sr,sizeof(sr),#0);
  with sr do begin
        name:=allcaps(uname);
        real:=caps(ureal);
        nickname:=nick;
        number:=usernum;
        UserID:=UID;
  end;
  seek(sf,ii+1); write(sf,sr);
  inc(syst.numusers); savesystat2(ndir);
  if (not sfo) then close(sf);
  found:=FALSE;
  assign(uidf,adrv(systat.gfilepath)+'USERID.IDX');
  {$I-} reset(uidf); {$I+}
  if (ioresult=0) then begin
        while not(eof(uidf)) and not(found) do begin
                read(uidf,uid2);
                if (uid2.UserID=UID) then begin
                        found:=TRUE;
                        uid2.number:=usernum;
                        seek(uidf,filepos(uidf)-1);
                        write(uidf,uid2);
                end;
        end;
  close(uidf);
  end;
end;

procedure dsr(uname:astr; unum:integer);
var t,ii:integer;
    sr:smalrec;
    uidf:file of useridrec;
    uid:useridrec;
    found,sfo:boolean;
begin
  sfo:=(filerec(sf).mode<>fmclosed);
  if (not sfo) then reset(sf);

  ii:=0; t:=1;
  while ((t<=filesize(sf)-1) and (ii=0)) do begin
    seek(sf,t); read(sf,sr);
    if (allcaps(sr.name)=allcaps(uname)) and (sr.number=unum) then ii:=t;
    inc(t);
  end;

  if (ii<>0) then begin
    if (ii<>filesize(sf)-1) then
      for t:=ii to filesize(sf)-2 do begin
        seek(sf,t+1); read(sf,sr);
        seek(sf,t); write(sf,sr);
      end;
    seek(sf,filesize(sf)-1); truncate(sf);
    dec(syst.numusers); savesystat2(NDir);
  end;
  if (not sfo) then close(sf);
  found:=FALSE;
  assign(uidf,adrv(systat.gfilepath)+'USERID.IDX');
  {$I-} reset(uidf); {$I+}
  if (ioresult=0) then begin
        while not(eof(uidf)) and not(found) do begin
                read(uidf,uid);
                if (uid.number=unum) then begin
                        found:=TRUE;
                        uid.number:=-1;
                        seek(uidf,filepos(uidf)-1);
                        write(uidf,uid);
                end;
        end;
  close(uidf);
  end;
end;

function spflags(u:userrec):astr;
var r:uflags;
    s:astr;
begin
  s:='';
  with u do begin
  if (rlogon in ac) then s:=s+'L' else s:=s+'-';
  if (rChat in ac) then s:=s+'C' else s:=s+'-';
  if (rPost in ac) then s:=s+'P' else s:=s+'-';
  if (rEmail in ac) then s:=s+'V' else s:=s+'-';
  if (rMsg in ac) then s:=s+'M' else s:=s+'-';
  if (alert in ac) then s:=s+'A' else s:=s+'-';
  s:=s+'/';
  if (fnodlratio in ac) then s:=s+'1' else s:=s+'-';
  if (fnopostratio in ac) then s:=s+'2' else s:=s+'-';
  if (fnofilepts in ac) then s:=s+'3' else s:=s+'-';
  if (fnodeletion in ac) then s:=s+'4' else s:=s+'-';
  s:=s+' ';
  if (ansi in ac) then s:=s+'AG ';
  if (color in ac) then s:=s+'CS ';
  if (pause in ac) then s:=s+'PS ';
  if (novice in ac) then s:=s+'NV ';
  if (onekey in ac) then s:=s+'QC ';
  if (usetaglines in ac) then s:=s+'TG';
  end;
  spflags:=s;
end;

procedure uedit(usern:integer);
const autolist:boolean=TRUE;
      userinfotyp:byte=1;
var user,user1:userrec;
    r:uflags;
    f:file;
    ii,is,s:astr;
    i,i1,x,oldusern:integer;
    byt2:integer;
    byt:byte;
    dt:DateTime;
    choices1:array[1..20] of string;
    choices2:array[1..15] of string;
    desc1:array[1..20] of string;
    desc2:array[1..15] of string;
    current,lr:integer;
    c:char;
    oldar:set of acrq;
    noread,noask,update,done,editing,arrows,save,save1,abort,next:boolean;

{
Message Records - Posts      : xxxxx   Feedback        : xxxxx
Upload Records  - Files      : xxxxx   Kb              : xxxxxxxxxxxk
DLoad Records   - Files      : xxxxx   Kb              : xxxxxxxxxxxk
Call Records    - Calls Today: xxxxx   Time Left Today : xxxxx
                  Total Calls: xxxxx   Total Time Spent: xxxxx }

   procedure rebuildidx;
   var sr:smalrec;
   begin
        rewrite(sf);
        sr.name:='';
        sr.real:='';
        sr.nickname:='';
        sr.number:=0;
        sr.UserID:=0;
        write(sf,sr);
        seek(uf,1);
        while not(eof(uf)) do begin
         read(uf,thisuser);
         if not(thisuser.deleted) then begin
                sr.name:=thisuser.name;
                sr.real:=thisuser.realname;
                sr.nickname:=thisuser.nickname;
                sr.number:=filepos(uf)-1;
                sr.UserID:=thisuser.UserID;
                write(sf,sr);
           end;
         end;
         systat.numusers:=filesize(sf);
         close(sf);
  end;

  procedure packusers;
  var tuser:userrec;
      ptr,numusers,curuser:longint;
      x3,x2:integer;
      w15:^windowrec;
  begin
  if pynqbox('Pack user database now? ') then begin
  new(w15);
  if (w15=NIL) then begin
        displaybox('Insufficient memory!',3000);
        exit;
  end;
  setwindow(w15^,18,10,62,15,3,0,8,'Packing User Database',TRUE);
  gotoxy(2,2);
  textcolor(3);
  textbackground(0);
  for x3:=1 to 40 do write('°');
  gotoxy(2,4);
  write('Status: Searching...');
  numusers:=filesize(uf)-1;
        seek(uf,1);
        curuser:=1;
        x3:=1;
        while not(eof(uf)) do begin
                read(uf,tuser);
                ptr:=filepos(uf);
                if (tuser.deleted) then begin
                        gotoxy(10,4);
                        textcolor(15);
                        clreol;
                        write('Removing user #',curuser);
                        dec(ptr);
                        while not(eof(uf)) do begin
                                read(uf,tuser);
                                seek(uf,filepos(uf)-2);
                                write(uf,tuser);
                                seek(uf,filepos(uf)+1);
                        end;
                        seek(uf,filesize(uf)-1);
                        truncate(uf);
                        gotoxy(10,4);
                        clreol;
                        textcolor(3);
                        write('Searching...');
                end;
gotoxy(33,1);
textcolor(15);
write(trunc(100*(curuser/numusers)));
gotoxy(36,1);
write('% Done');
textcolor(9);
for x2:=x3 to 40 do begin
if (curuser>=((numusers div 40)*x2)) then begin
                gotoxy(1+x3,2);
                write('Û');
                inc(x3);
                end;
end;
                seek(uf,ptr);
                inc(curuser);
        end;
        removewindow(w15^);
        dispose(w15);
        rebuildidx;
  end;
  end;


  function showstatus:string;
  var tmpstring:string;
  begin
  with user do begin
  if (deleted) then tmpstring:='Deleted' else
  if (trapactivity) then begin
      if (trapseperate) then tmpstring:='TrapSep' else tmpstring:='Trap';
  end else
      if (lockedout) then tmpstring:='Locked' else
      if (alert in ac) then tmpstring:='Alert' else
      tmpstring:='Normal';
  end;
  showstatus:=tmpstring;
  end;

  procedure showulinfo;
  begin
  with user do begin
  gotoxy(33,19);
  textcolor(3);
  textbackground(0);
  write(mn(uploads,5));
  gotoxy(59,19);
  write(mn(uk,10));
  end;
  end;

  procedure showdlinfo;
  begin
  with user do begin
  gotoxy(33,20);
  textcolor(3);
  textbackground(0);
  write(mn(downloads,5));
  gotoxy(59,20);
  write(mn(dk,10));
  end;
  end;

  procedure showmsginfo;
  begin
  with user do begin
  gotoxy(33,18);
  textcolor(3);
  textbackground(0);
  write(mn(msgpost,5));
  gotoxy(59,18);
  write(mn(feedback,5));
  end;
  end;

  procedure showcallinfo;
  begin
  with user do begin
  gotoxy(33,21);
  textcolor(3);
  textbackground(0);
  write(mn(ontoday,5));
  gotoxy(59,21);
  write(mn(tltoday,5));
  gotoxy(33,22);
  write(mn(loggedon,5));
  gotoxy(59,22);
  write(mn(ttimeon,10));
  end;
  end;



  procedure getrestrictions;
  var ch1:array[1..18] of string[30];
      desc1:array[1..18] of string;
      x1,current1:integer;
      c1:char;
      done:boolean;
  begin
  ch1[1]:='One Call Per Day    :';
  ch1[2]:='Alert SysOp         :';
  ch1[3]:='Cannot Page SysOp   :';
  ch1[4]:='No Special Keys     :';
  ch1[5]:='QuickKey Input Mode :';
  ch1[6]:='Screen Pausing      :';
  ch1[7]:='Novice Help Level   :';
  ch1[8]:='Cannot Post         :';
  ch1[9]:='Cannot Post Private :';
 ch1[10]:='Force Private Delete:';
 ch1[11]:='Use Taglines        :';
 ch1[12]:='RIPscrip Graphics   :';
 ch1[13]:='ANSI Graphics       :';
 ch1[14]:='Color Display       :';
 ch1[15]:='No UL/DL Ratio      :';
 ch1[16]:='No Post/Call Ratio  :';
 ch1[17]:='No File Point Check :';
 ch1[18]:='Permanent           :';
  current1:=1;
  setwindow(w2,10,3,40,23,3,0,8,'Restrictions/Special',TRUE);
  for x1:=1 to 18 do begin
        gotoxy(2,x1+1);
        textcolor(7);
        textbackground(0);
        write(ch1[x1]);
  end;
  textcolor(3);
  gotoxy(24,2);
  write(syn(rlogon in user.ac));
  gotoxy(24,3);
  write(syn(alert in user.ac));
  gotoxy(24,4);
  write(syn(rchat in user.ac));
  gotoxy(24,5);
  write(syn(rbackspace in user.ac));
  gotoxy(24,6);
  write(syn(onekey in user.ac));
  gotoxy(24,7);
  write(syn(pause in user.ac));
  gotoxy(24,8);
  write(syn(novice in user.ac));
  gotoxy(24,9);
  write(syn(rpost in user.ac));
  gotoxy(24,10);
  write(syn(remail in user.ac));
  gotoxy(24,11);
  write(syn(rmsg in user.ac));
  gotoxy(24,12);
  write(syn(usetaglines in user.ac));
  gotoxy(24,14);
  write(syn(ansi in user.ac));
  gotoxy(24,15);
  write(syn(color in user.ac));
  gotoxy(24,16);
  write(syn(fnodlratio in user.ac));
  gotoxy(24,17);
  write(syn(fnopostratio in user.ac));
  gotoxy(24,18);
  write(syn(fnofilepts in user.ac));
  gotoxy(24,19);
  write(syn(fnodeletion in user.ac));
  repeat
  gotoxy(2,current1+1);
  textcolor(15);
  textbackground(1);
  write(ch1[current1]);
  textbackground(0);
  done:=false;
  while not(keypressed) do begin timeslice; end;
  c1:=readkey;
  case c1 of
        #0:begin
                c1:=readkey;
                checkkey(c1);
                case c1 of
                   #72:begin
                          gotoxy(2,current1+1);
                          textcolor(7);
                          textbackground(0);
                          write(ch1[current1]);
                          dec(current1);
                          if (current1=0) then current1:=18;
                        end;
                    #80:begin
                          gotoxy(2,current1+1);
                          textcolor(7);
                          textbackground(0);
                          write(ch1[current1]);
                          inc(current1);
                          if (current1=19) then current1:=1;
                        end;  
                end;
           end;
       #13:begin
          save:=TRUE;
          textcolor(3);
          textbackground(0);
          case current1 of
          1:begin
          if (rlogon in user.ac) then
          user.ac:=user.ac-[rlogon]
          else
          user.ac:=user.ac+[rlogon];
          gotoxy(24,2);
          write(syn(rlogon in user.ac));
          end;
          2:begin
          if (alert in user.ac) then
          user.ac:=user.ac-[alert]
          else
          user.ac:=user.ac+[alert];
          gotoxy(24,3);
          write(syn(alert in user.ac));
          end;
          3:begin
          if (rchat in user.ac) then
          user.ac:=user.ac-[rchat]
          else
          user.ac:=user.ac+[rchat];
          gotoxy(24,4);
          write(syn(rchat in user.ac));
          end;
          4:begin
          if (rbackspace in user.ac) then
          user.ac:=user.ac-[rbackspace]
          else
          user.ac:=user.ac+[rbackspace];
          gotoxy(24,5);
          write(syn(rbackspace in user.ac));
          end;
          5:begin
          if (onekey in user.ac) then
          user.ac:=user.ac-[onekey]
          else
          user.ac:=user.ac+[onekey];
          gotoxy(24,6);
          write(syn(onekey in user.ac));
          end;
          6:begin
          if (pause in user.ac) then
          user.ac:=user.ac-[pause]
          else
          user.ac:=user.ac+[pause];
          gotoxy(24,7);
          write(syn(pause in user.ac));
          end;
          7:begin
          if (novice in user.ac) then
          user.ac:=user.ac-[novice]
          else
          user.ac:=user.ac+[novice];
          gotoxy(24,8);
          write(syn(novice in user.ac));
          end;
          8:begin
          if (rpost in user.ac) then
          user.ac:=user.ac-[rpost]
          else
          user.ac:=user.ac+[rpost];
          gotoxy(24,9);
          write(syn(rpost in user.ac));
          end;
          9:begin
          if (remail in user.ac) then
          user.ac:=user.ac-[remail]
          else
          user.ac:=user.ac+[remail];
          gotoxy(24,10);
          write(syn(remail in user.ac));
          end;
          10:begin
          if (rmsg in user.ac) then
          user.ac:=user.ac-[rmsg]
          else
          user.ac:=user.ac+[rmsg];
          gotoxy(24,11);
          write(syn(rmsg in user.ac));
          end;
          11:begin
          if (usetaglines in user.ac) then
          user.ac:=user.ac-[usetaglines]
          else
          user.ac:=user.ac+[usetaglines];
          gotoxy(24,12);
          write(syn(usetaglines in user.ac));
          end;
(*          12:begin
          if (rip in user.ac) then
          user.ac:=user.ac-[rip]
          else
          user.ac:=user.ac+[rip];
          gotoxy(24,13);
          write(syn(rip in user.ac));
          end; *)
          13:begin
          if (ansi in user.ac) then
          user.ac:=user.ac-[ansi]
          else
          user.ac:=user.ac+[ansi];
          gotoxy(24,14);
          write(syn(ansi in user.ac));
          end;
          14:begin
          if (color in user.ac) then
          user.ac:=user.ac-[color]
          else
          user.ac:=user.ac+[color];
          gotoxy(24,15);
          write(syn(color in user.ac));
          end;
          15:begin
          if (fnodlratio in user.ac) then
          user.ac:=user.ac-[fnodlratio]
          else
          user.ac:=user.ac+[fnodlratio];
          gotoxy(24,16);
          write(syn(fnodlratio in user.ac));
          end;
          16:begin
          if (fnopostratio in user.ac) then
          user.ac:=user.ac-[fnopostratio]
          else
          user.ac:=user.ac+[fnopostratio];
          gotoxy(24,17);
          write(syn(fnopostratio in user.ac));
          end;
          17:begin
          if (fnofilepts in user.ac) then
          user.ac:=user.ac-[fnofilepts]
          else
          user.ac:=user.ac+[fnofilepts];
          gotoxy(24,18);
          write(syn(fnofilepts in user.ac));
          end;
          18:begin
          if (fnodeletion in user.ac) then
          user.ac:=user.ac-[fnodeletion]
          else
          user.ac:=user.ac+[fnodeletion];
          gotoxy(24,19);
          write(syn(fnodeletion in user.ac));
          end;
          end;
         end;
       #27:begin
           done:=TRUE;
           end;
  end;
  until (done);
  removewindow(w2);
  end;

  procedure delusr;
  var i:integer;
  begin
    if (not user.deleted) then begin
      save:=TRUE; user.deleted:=TRUE;
      dsr(user.name,usern);
    end;
  end;

  procedure getulrecord;
  var cho:array[1..2] of string;
      cur:integer;
      s2:string;
      c2:char;
      dn2:boolean;
  begin
    cho[2]:='Upload KB    :';
    dn2:=FALSE;
    cho[1]:='Upload Files :';
    setwindow(w2,26,10,54,15,3,0,8,'Upload Record',TRUE);
    for cur:=1 to 2 do begin
    textcolor(7);
    textbackground(0);
    gotoxy(2,cur+1);
    write(cho[cur]);
    end;
    gotoxy(17,2);
    textcolor(3);
    write(mln(cstr(user.uploads),5));
    gotoxy(17,3);
    write(mln(cstr(user.uk),10));
    cur:=1;
    repeat
    gotoxy(2,cur+1);
    textcolor(15);
    textbackground(1);
    write(cho[cur]);
    while not(keypressed) do begin timeslice; end;
    c2:=readkey;
    case c2 of
         #0:begin
                c2:=readkey;
                checkkey(c2);
                case c2 of
                        #72:begin
                            gotoxy(2,cur+1);
                            textcolor(7);
                            textbackground(0);
                            write(cho[cur]);
                            dec(cur);
                            if (cur=0) then cur:=2;
                            end;
                        #80:begin
                            gotoxy(2,cur+1);
                            textcolor(7);
                            textbackground(0);
                            write(cho[cur]);
                            inc(cur);
                            if (cur=3) then cur:=1;
                            end;
                end;
            end;
        #13:begin
                gotoxy(2,cur+1);
                textcolor(7);
                textbackground(0);
                write(cho[cur]);
                gotoxy(15,cur+1);
                textcolor(9);
                write('>');
                gotoxy(17,cur+1);
                case cur of
                        1:begin
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_numbers_only:=TRUE;
                                        infield_show_colors:=FALSE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        infield_insert:=TRUE;
                                        infield_min_value:=0;
                                        infield_max_value:=32767;
                                        s:=cstr(user.uploads);
                                        infielde(s,5);
                                        infield_min_value:=-1;
                                        infield_max_value:=-1;
                                        infield_maxshow:=0;
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_show_colors:=FALSE;
                                        if (value(s)<>user.uploads) then begin
                                        user.uploads:=value(s);
                                        save:=TRUE;
                                        end;
                          end;
                        2:begin
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_numbers_only:=TRUE;
                                        infield_show_colors:=FALSE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        infield_insert:=TRUE;
                                        infield_min_value:=0;
                                        infield_max_value:=200000000;
                                        s:=cstr(user.uk);
                                        infielde(s,10);
                                        infield_min_value:=-1;
                                        infield_max_value:=-1;
                                        infield_maxshow:=0;
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_show_colors:=FALSE;
                                        if (value(s)<>user.uk) then begin
                                        user.uk:=value(s);
                                        save:=TRUE;
                                        end;
                          end;
                end;
            end;
        #27:dn2:=TRUE;
    end;
    until (dn2);
    removewindow(w2);
  end;

  procedure getdlrecord;
  var cho:array[1..2] of string;
      cur:integer;
      s2:string;
      c2:char;
      dn2:boolean;
  begin
    cho[1]:='Download Files :';
    cho[2]:='Download KB    :';
    dn2:=FALSE;
    setwindow(w2,25,10,55,15,3,0,8,'Download Record',TRUE);
    for cur:=1 to 2 do begin
    textcolor(7);
    textbackground(0);
    gotoxy(2,cur+1);
    write(cho[cur]);
    end;
    gotoxy(19,2);
    textcolor(3);
    write(mln(cstr(user.downloads),5));
    gotoxy(19,3);
    write(mln(cstr(user.dk),10));
    cur:=1;
    repeat
    gotoxy(2,cur+1);
    textcolor(15);
    textbackground(1);
    write(cho[cur]);
    while not(keypressed) do begin timeslice; end;
    c2:=readkey;
    case c2 of
         #0:begin
                c2:=readkey;
                checkkey(c2);
                case c2 of
                        #72:begin
                            gotoxy(2,cur+1);
                            textcolor(7);
                            textbackground(0);
                            write(cho[cur]);
                            dec(cur);
                            if (cur=0) then cur:=2;
                            end;
                        #80:begin
                            gotoxy(2,cur+1);
                            textcolor(7);
                            textbackground(0);
                            write(cho[cur]);
                            inc(cur);
                            if (cur=3) then cur:=1;
                            end;
                end;
            end;
        #13:begin
                gotoxy(2,cur+1);
                textcolor(7);
                textbackground(0);
                write(cho[cur]);
                gotoxy(17,cur+1);
                textcolor(9);
                write('>');
                gotoxy(19,cur+1);
                case cur of
                        1:begin
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_numbers_only:=TRUE;
                                        infield_show_colors:=FALSE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        infield_insert:=TRUE;
                                        infield_min_value:=0;
                                        infield_max_value:=32767;
                                        s:=cstr(user.downloads);
                                        infielde(s,5);
                                        infield_min_value:=-1;
                                        infield_max_value:=-1;
                                        infield_maxshow:=0;
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_show_colors:=FALSE;
                                        if (value(s)<>user.downloads) then begin
                                        user.downloads:=value(s);
                                        save:=TRUE;
                                        end;
                          end;
                        2:begin
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_numbers_only:=TRUE;
                                        infield_show_colors:=FALSE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        infield_insert:=TRUE;
                                        infield_min_value:=0;
                                        infield_max_value:=200000000;
                                        s:=cstr(user.dk);
                                        infielde(s,10);
                                        infield_min_value:=-1;
                                        infield_max_value:=-1;
                                        infield_maxshow:=0;
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_show_colors:=FALSE;
                                        if (value(s)<>user.dk) then begin
                                        user.dk:=value(s);
                                        save:=TRUE;
                                        end;
                          end;
                end;
            end;
        #27:dn2:=TRUE;
    end;
    until (dn2);
    removewindow(w2);
  end;

  procedure getnote;
  var s:string;
  begin
  setwindow(w2,8,11,72,13,3,0,8,'Enter User Note',TRUE);
  gotoxy(2,1);
  textcolor(7);
  textbackground(0);
  write('Enter User Note :');
  gotoxy(20,1);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=False;
                                        infield_numbers_only:=FALSE;
                                        infield_show_colors:=FALSE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        infield_insert:=TRUE;
                                        s:=user.note;
                                        infielde(s,40);
                                        infield_maxshow:=0;
                                        infield_allcaps:=FALSE;
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        if (s<>user.note) then begin
                                                user.note:=s;
                                                save:=TRUE;
                                        end;
  removewindow(w2);
  end;

  procedure getclearflags;
  var cho:array[1..12] of string;
      x,cur:integer;
      s2:string;
      c2:char;
      dn2:boolean;
  begin
  dn2:=false;
  cho[1]:='Address      :';
  cho[2]:='City, State  :';
  cho[3]:='Zipcode      :';
  cho[4]:='Birthdate    :';
  cho[5]:='Voice Phone  :';
  cho[6]:='Data Phone   :';
  cho[7]:=mln(uephone1,13)+':';
  cho[8]:=mln(uephone2,13)+':';
  cho[9]:=mln(ueopt1,13)+':';
 cho[10]:=mln(ueopt2,13)+':';
 cho[11]:=mln(ueopt3,13)+':';
 cho[12]:='Calling From :';
  setwindow(w2,29,7,51,22,3,0,8,'Re-Entry',TRUE);
  textcolor(7);
  textbackground(0);
  for cur:=1 to 12 do begin
  gotoxy(2,cur+1);
  write(cho[cur]);
  end;
  cur:=1;
  repeat
  for x:=1 to 12 do begin
        gotoxy(17,x+1);
        textcolor(3);
        textbackground(0);
        write(syn(user.clearentry[x]));
  end;
  gotoxy(2,cur+1);
  textcolor(15);
  textbackground(1);
  write(cho[cur]);
  while not(keypressed) do begin timeslice; end;
  c2:=readkey;
  case c2 of
        #0:begin
                c2:=readkey;
                checkkey(c2);
                case c2 of
                        #72:begin
                                gotoxy(2,cur+1);
                                textcolor(7);
                                textbackground(0);
                                write(cho[cur]);
                                dec(cur);
                                if (cur=0) then cur:=12;
                            end;
                        #80:begin
                                gotoxy(2,cur+1);
                                textcolor(7);
                                textbackground(0);
                                write(cho[cur]);
                                inc(cur);
                                if (cur=13) then cur:=1;
                            end;
                end;
           end;
       #13:begin
                user.clearentry[cur]:=not(user.clearentry[cur]);
                save:=TRUE;
           end;
       #27:dn2:=TRUE;
  end;
  until (dn2);
  removewindow(w2);
  end;


  procedure getcallrecord;
  var cho:array[1..4] of string;
      cur:integer;
      s2:string;
      c2:char;
      dn2:boolean;
  begin
    cho[1]:='Calls Today      :';
    cho[2]:='Time Left Today  :';
    cho[3]:='Total Calls      :';
    cho[4]:='Total Time Spent :';
    dn2:=FALSE;
    setwindow(w2,24,9,56,16,3,0,8,'Call Record',TRUE);
    for cur:=1 to 4 do begin
    textcolor(7);
    textbackground(0);
    gotoxy(2,cur+1);
    write(cho[cur]);
    end;
    gotoxy(21,2);
    textcolor(3);
    write(mln(cstr(user.ontoday),3));
    gotoxy(21,3);
    write(mln(cstr(user.tltoday),5));
    gotoxy(21,4);
    write(mln(cstr(user.loggedon),5));
    gotoxy(21,5);
    write(mln(cstr(user.ttimeon),10));
    cur:=1;
    repeat
    gotoxy(2,cur+1);
    textcolor(15);
    textbackground(1);
    write(cho[cur]);
    while not(keypressed) do begin timeslice; end;
    c2:=readkey;
    case c2 of
         #0:begin
                c2:=readkey;
                checkkey(c2);
                case c2 of
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
                gotoxy(2,cur+1);
                textcolor(7);
                textbackground(0);
                write(cho[cur]);
                gotoxy(19,cur+1);
                textcolor(9);
                write('>');
                gotoxy(21,cur+1);
                case cur of
                        1:begin
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_numbers_only:=TRUE;
                                        infield_show_colors:=FALSE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        infield_insert:=TRUE;
                                        infield_min_value:=0;
                                        infield_max_value:=255;
                                        s:=cstr(user.ontoday);
                                        infielde(s,3);
                                        infield_min_value:=-1;
                                        infield_max_value:=-1;
                                        infield_maxshow:=0;
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_show_colors:=FALSE;
                                        if (value(s)<>user.ontoday) then begin
                                        user.ontoday:=value(s);
                                        save:=TRUE;
                                        end;
                          end;
                        2:begin
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_numbers_only:=TRUE;
                                        infield_show_colors:=FALSE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        infield_insert:=TRUE;
                                        infield_min_value:=0;
                                        infield_max_value:=32767;
                                        s:=cstr(user.tltoday);
                                        infielde(s,5);
                                        infield_min_value:=-1;
                                        infield_max_value:=-1;
                                        infield_maxshow:=0;
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_show_colors:=FALSE;
                                        if (value(s)<>user.tltoday) then begin
                                        user.tltoday:=value(s);
                                        save:=TRUE;
                                        end;
                          end;
                        3:begin
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_numbers_only:=TRUE;
                                        infield_show_colors:=FALSE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        infield_insert:=TRUE;
                                        infield_min_value:=0;
                                        infield_max_value:=32767;
                                        s:=cstr(user.loggedon);
                                        infielde(s,5);
                                        infield_min_value:=-1;
                                        infield_max_value:=-1;
                                        infield_maxshow:=0;
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_show_colors:=FALSE;
                                        if (value(s)<>user.loggedon) then begin
                                        user.loggedon:=value(s);
                                        save:=TRUE;
                                        end;
                          end;
                        4:begin
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_numbers_only:=TRUE;
                                        infield_show_colors:=FALSE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        infield_insert:=TRUE;
                                        infield_min_value:=0;
                                        infield_max_value:=2000000000;
                                        s:=cstr(user.ttimeon);
                                        infielde(s,10);
                                        infield_min_value:=-1;
                                        infield_max_value:=-1;
                                        infield_maxshow:=0;
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_show_colors:=FALSE;
                                        if (value(s)<>user.ttimeon) then begin
                                        user.ttimeon:=value(s);
                                        save:=TRUE;
                                        end;
                          end;
                end;
            end;
        #27:dn2:=TRUE;
    end;
    until (dn2);
    removewindow(w2);
  end;

  procedure getmsgrecord;
  var cho:array[1..2] of string;
      cur:integer;
      s2:string;
      c2:char;
      dn2:boolean;
  begin
    cho[1]:='Number of Posts:';
    cho[2]:='Number Feedback:';
    dn2:=FALSE;
    setwindow(w2,27,10,53,15,3,0,8,'Message Record',TRUE);
    for cur:=1 to 2 do begin
    textcolor(7);
    textbackground(0);
    gotoxy(2,cur+1);
    write(cho[cur]);
    end;
    gotoxy(19,2);
    textcolor(3);
    write(mln(cstr(user.msgpost),5));
    gotoxy(19,3);
    write(mln(cstr(user.feedback),5));
    cur:=1;
    repeat
    gotoxy(2,cur+1);
    textcolor(15);
    textbackground(1);
    write(cho[cur]);
    while not(keypressed) do begin timeslice; end;
    c2:=readkey;
    case c2 of
         #0:begin
                c2:=readkey;
                checkkey(c2);
                case c2 of
                        #72:begin
                            gotoxy(2,cur+1);
                            textcolor(7);
                            textbackground(0);
                            write(cho[cur]);
                            dec(cur);
                            if (cur=0) then cur:=2;
                            end;
                        #80:begin
                            gotoxy(2,cur+1);
                            textcolor(7);
                            textbackground(0);
                            write(cho[cur]);
                            inc(cur);
                            if (cur=3) then cur:=1;
                            end;
                end;
            end;
        #13:begin
                gotoxy(2,cur+1);
                textcolor(7);
                textbackground(0);
                write(cho[cur]);
                gotoxy(17,cur+1);
                textcolor(9);
                write('>');
                gotoxy(19,cur+1);
                case cur of
                        1:begin
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_numbers_only:=TRUE;
                                        infield_show_colors:=FALSE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        infield_insert:=TRUE;
                                        infield_min_value:=0;
                                        infield_max_value:=32767;
                                        s:=cstr(user.msgpost);
                                        infielde(s,5);
                                        infield_min_value:=-1;
                                        infield_max_value:=-1;
                                        infield_maxshow:=0;
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_show_colors:=FALSE;
                                        if (value(s)<>user.msgpost) then begin
                                        user.msgpost:=value(s);
                                        save:=TRUE;
                                        end;
                          end;
                        2:begin
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_numbers_only:=TRUE;
                                        infield_show_colors:=FALSE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        infield_insert:=TRUE;
                                        infield_min_value:=0;
                                        infield_max_value:=32767;
                                        s:=cstr(user.feedback);
                                        infielde(s,5);
                                        infield_min_value:=-1;
                                        infield_max_value:=-1;
                                        infield_maxshow:=0;
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_show_colors:=FALSE;
                                        if (value(s)<>user.feedback) then begin
                                        user.feedback:=value(s);
                                        save:=TRUE;
                                        end;
                          end;
                end;
            end;
        #27:dn2:=TRUE;
    end;
    until (dn2);
    removewindow(w2);
  end;

procedure changesubscription(x:byte);
var ssf:file of subscriptionrec;
    ss:subscriptionrec;
    c:char;
    b:byte;
    oldflags:set of uflags;
begin
assign(ssf,adrv(systat.gfilepath)+'SUBSCRIP.DAT');
{$I-} reset(ssf); {$I+}
if (ioresult<>0) then begin
        displaybox('Error Opening SUBSCRIP.DAT',3000);
        exit;
end;
if (x<=filesize(ssf)-1) then begin
        seek(ssf,x);
        read(ssf,ss);
        close(ssf);
        user.sl:=ss.sl;
        if (ss.armodifier=0) then 
        user.ar:=ss.arflags
        else begin
        for c:='A' to 'Z' do
        if (c in ss.arflags) and not(c in user.ar) then user.ar:=user.ar+[c];
        end;
        if (ss.armodifier2=0) then 
        user.ar2:=ss.arflags2
        else begin
        for c:='A' to 'Z' do
        if (c in ss.arflags2) and not(c in user.ar2) then user.ar2:=user.ar2+[c];
        end;
        oldflags:=user.ac;
        if (ss.acmodifier=0) then begin
                for c:='A' to 'K' do
                        if (tacch(c) in ss.acflags) then user.ac:=user.ac+[tacch(c)]
                                else user.ac:=user.ac-[tacch(c)];
        end else begin
                for c:='A' to 'K' do
                if (tacch(c) in ss.acflags) then user.ac:=user.ac+[tacch(c)];
        end;
        case ss.fpmodifier of
                0:begin
                  user.filepoints:=ss.filepoints;
                  end;
                1:begin
                  user.filepoints:=user.filepoints+ss.filepoints;
                  end;
                2:begin
                  user.filepoints:=user.filepoints-ss.filepoints;
                  end;
        end;
        case ss.cmodifier of
                1:begin
                  user.credit:=ss.credits;
                  end;
                2:begin
                  user.credit:=user.credit+ss.credits;
                  end;
                3:begin
                  user.credit:=user.credit-ss.credits;
                  end;
        end;
        case ss.timebank of
                1:begin
                  user.timebank:=ss.timebank;
                  end;
                2:begin
                  user.timebank:=user.timebank+ss.timebank;
                  end;
                3:begin
                  user.timebank:=user.timebank-ss.timebank;
                  end;
        end;
        user.subscription:=x;
        user.subdate:=u_daynum(datelong+'  '+time);
end else begin
        close(ssf);
        if (x=1) then begin
                displaybox('Error Accessing SUBSCRIP.DAT',3000);
        end else begin
                displaybox('Invalid Subscription!',3000);
        end;
end;
end;

  procedure getsub;
  var cho:array[1..2] of string;
      cur:integer;
      s2:string;
      c2:char;
      b:byte;
      dn2:boolean;
  begin
    cho[1]:='Subscription   :';
    cho[2]:='Sub Start Date :';
    dn2:=FALSE;
    setwindow(w2,10,10,70,15,3,0,8,'Subscription',TRUE);
    for cur:=1 to 2 do begin
    textcolor(7);
    textbackground(0);
    gotoxy(2,cur+1);
    write(cho[cur]);
    end;
    cur:=1;
    repeat
    gotoxy(2,cur+1);
    textcolor(15);
    textbackground(1);
    write(cho[cur]);
    gotoxy(19,2);
    textcolor(3);
    textbackground(0);
    write(mln(showsubscription(user.subscription),40));
    gotoxy(19,3);
    write(mln(showdatestr(user.subdate),18));
    while not(keypressed) do begin timeslice; end;
    c2:=readkey;
    case c2 of
         #0:begin
                c2:=readkey;
                checkkey(c2);
                case c2 of
                        #68:dn2:=TRUE;
                        #72:begin
                            gotoxy(2,cur+1);
                            textcolor(7);
                            textbackground(0);
                            write(cho[cur]);
                            dec(cur);
                            if (cur=0) then cur:=2;
                            end;
                        #80:begin
                            gotoxy(2,cur+1);
                            textcolor(7);
                            textbackground(0);
                            write(cho[cur]);
                            inc(cur);
                            if (cur=3) then cur:=1;
                            end;
                end;
            end;
        #13:begin
                gotoxy(2,cur+1);
                textcolor(7);
                textbackground(0);
                write(cho[cur]);
                gotoxy(17,cur+1);
                textcolor(9);
                write('>');
                gotoxy(19,cur+1);
                case cur of
                        1:begin
                                        b:=getsubscript;
                                        if (b<>user.subscription) and (b<>0) then begin
                                        changesubscription(b);
                                        save:=TRUE;
                                        end;
                                        window(11,11,69,14);
                          end;
                        2:begin
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_numbers_only:=FALSE;
                                        infield_show_colors:=FALSE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        infield_insert:=TRUE;
                                        s:=showdatestr(user.subdate);
                                        infielde(s,18);
                                        infield_min_value:=-1;
                                        infield_max_value:=-1;
                                        infield_maxshow:=0;
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_show_colors:=FALSE;
                                        if (s<>showdatestr(user.subdate)) then begin
                                        user.subdate:=u_daynum(s);
                                        save:=TRUE;
                                        end;
                          end;
                end;
            end;
        #27:dn2:=TRUE;
    end;
    until (dn2);
    removewindow(w2);
  end;

  procedure getsysops(which:byte);
  var cho:array[1..20] of string;
      cur:integer;
      s2:string;
      c2:char;
      lr:integer;
      x:integer;
      dn2:boolean;

  function stype(wh:byte):string;
  begin
        case wh of
                1:stype:='MSG Base SysOp';
                2:stype:='FILE Base SysOp';
        end;
  end;

  begin
  dn2:=FALSE;
  for x:=1 to 20 do begin
        case which of
                1:cho[x]:='Msg Base #'+mln(cstr(x),2)+'  :';
                2:cho[x]:='File Base #'+mln(cstr(x),2)+' :';
        end;
  end;
  setwindow(w2,15,6,65,19,3,0,8,stype(which),TRUE);
  for x:=1 to 10 do begin
        textcolor(7);
        textbackground(0);
        gotoxy(2,x+1);
        write(cho[x]);
  end;
  for x:=11 to 20 do begin
        textcolor(7);
        textbackground(0);
        gotoxy(24,(x-10)+1);
        write(cho[x]);
  end;
  cur:=1;
  lr:=0;
  repeat
  for x:=1 to 10 do begin
  textcolor(3);
  textbackground(0);
  gotoxy(18,x+1);
        case which of
                1:write(mln(cstr(user.boardsysop[x]),5));
                2:write(mln(cstr(user.uboardsysop[x]),5));
        end;
  end;
  for x:=11 to 20 do begin
  textcolor(3);
  textbackground(0);
  gotoxy(40,(x-10)+1);
        case which of
                1:write(mln(cstr(user.boardsysop[x]),5));
                2:write(mln(cstr(user.uboardsysop[x]),5));
        end;
  end;
  gotoxy(2+(lr*22),cur+1);
  textcolor(15);
  textbackground(1);
  write(cho[cur+(lr*10)]);
  while not(keypressed) do begin timeslice; end;
  c2:=readkey;
  case c2 of
        #0:begin
                c2:=readkey;
                checkkey(c2);
                case c2 of
                        #72:begin
                                gotoxy(2+(lr*22),cur+1);
                                textcolor(7);
                                textbackground(0);
                                write(cho[cur+(lr*10)]);
                                dec(cur);
                                if (cur=0) then begin
                                        cur:=10;
                                        if (lr=0) then lr:=1 else lr:=0;
                                end;
                            end;
                        #75,#77:begin
                                gotoxy(2+(lr*22),cur+1);
                                textcolor(7);
                                textbackground(0);
                                write(cho[cur+(lr*10)]);
                                if (lr=0) then lr:=1 else lr:=0;
                            end;
                        #80:begin
                                gotoxy(2+(lr*22),cur+1);
                                textcolor(7);
                                textbackground(0);
                                write(cho[cur+(lr*10)]);
                                inc(cur);
                                if (cur=11) then begin
                                        cur:=1;
                                        if (lr=0) then lr:=1 else lr:=0;
                                end;
                            end;
                end;
           end;
       #13:begin
                                gotoxy(2+(lr*22),cur+1);
                                textcolor(7);
                                textbackground(0);
                                write(cho[cur+(lr*10)]);
                                gotoxy(16+(lr*22),cur+1);
                                textcolor(9);
                                write('>');
                                gotoxy(18+(lr*22),cur+1);

                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_numbers_only:=TRUE;
                                        infield_show_colors:=FALSE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        infield_insert:=TRUE;
                                        infield_min_value:=0;
                                        infield_max_value:=32767;
                case which of
                        1:s:=cstr(user.boardsysop[cur+(lr*10)]);
                        2:s:=cstr(user.uboardsysop[cur+(lr*10)]);
                end;
                                        infielde(s,5);
                                        infield_min_value:=-1;
                                        infield_max_value:=-1;
                                        infield_maxshow:=0;
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_show_colors:=FALSE;
                                        case which of
                                        1:begin
                                        if (value(s)<>user.boardsysop[cur+(lr*10)]) then begin
                                        user.boardsysop[cur+(lr*10)]:=value(s);
                                        save:=TRUE;
                                        end;
                                        end;
                                        2:begin
                                        if (value(s)<>user.uboardsysop[cur+(lr*10)]) then begin
                                        user.uboardsysop[cur+(lr*10)]:=value(s);
                                        save:=TRUE;
                                        end;
                                        end;
                                        end;
           end;
       #27:dn2:=TRUE;
  end;
  until (dn2);
  removewindow(w2);
  end;

  procedure gettimebank;
  var cho:array[1..3] of string;
      cur:integer;
      s2:string;
      c2:char;
      dn2:boolean;
  begin
    cho[1]:='Time Bank (min)    :';
    cho[2]:='Min Added Today    :';
    cho[3]:='Min Withdrawn Today:';
    dn2:=FALSE;
    setwindow(w2,25,10,55,16,3,0,8,'Time Bank',TRUE);
    for cur:=1 to 3 do begin
    textcolor(7);
    textbackground(0);
    gotoxy(2,cur+1);
    write(cho[cur]);
    end;
    gotoxy(23,2);
    textcolor(3);
    write(mln(cstr(user.timebank),5));
    gotoxy(23,3);
    write(mln(cstr(user.timebankadd),5));
    gotoxy(23,4);
    write(mln(cstr(user.timebankwith),5));
    cur:=1;
    repeat
    gotoxy(2,cur+1);
    textcolor(15);
    textbackground(1);
    write(cho[cur]);
    while not(keypressed) do begin timeslice; end;
    c2:=readkey;
    case c2 of
         #0:begin
                c2:=readkey;
                checkkey(c2);
                case c2 of
                        #72:begin
                            gotoxy(2,cur+1);
                            textcolor(7);
                            textbackground(0);
                            write(cho[cur]);
                            dec(cur);
                            if (cur=0) then cur:=3;
                            end;
                        #80:begin
                            gotoxy(2,cur+1);
                            textcolor(7);
                            textbackground(0);
                            write(cho[cur]);
                            inc(cur);
                            if (cur=4) then cur:=1;
                            end;
                end;
            end;
        #13:begin
                gotoxy(2,cur+1);
                textcolor(7);
                textbackground(0);
                write(cho[cur]);
                gotoxy(21,cur+1);
                textcolor(9);
                write('>');
                gotoxy(23,cur+1);
                case cur of
                        1:begin
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_numbers_only:=TRUE;
                                        infield_show_colors:=FALSE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        infield_insert:=TRUE;
                                        infield_min_value:=0;
                                        infield_max_value:=32767;
                                        s:=cstr(user.timebank);
                                        infielde(s,5);
                                        infield_min_value:=-1;
                                        infield_max_value:=-1;
                                        infield_maxshow:=0;
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_show_colors:=FALSE;
                                        if (value(s)<>user.timebank) then begin
                                        user.timebank:=value(s);
                                        save:=TRUE;
                                        end;
                          end;
                        2:begin
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_numbers_only:=TRUE;
                                        infield_show_colors:=FALSE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        infield_insert:=TRUE;
                                        infield_min_value:=0;
                                        infield_max_value:=32767;
                                        s:=cstr(user.timebankadd);
                                        infielde(s,5);
                                        infield_min_value:=-1;
                                        infield_max_value:=-1;
                                        infield_maxshow:=0;
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_show_colors:=FALSE;
                                        if (value(s)<>user.timebankadd) then begin
                                        user.timebankadd:=value(s);
                                        save:=TRUE;
                                        end;
                          end;
                        3:begin
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_numbers_only:=TRUE;
                                        infield_show_colors:=FALSE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        infield_insert:=TRUE;
                                        infield_min_value:=0;
                                        infield_max_value:=32767;
                                        s:=cstr(user.timebankwith);
                                        infielde(s,5);
                                        infield_min_value:=-1;
                                        infield_max_value:=-1;
                                        infield_maxshow:=0;
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_show_colors:=FALSE;
                                        if (value(s)<>user.timebankwith) then begin
                                        user.timebankwith:=value(s);
                                        save:=TRUE;
                                        end;
                          end;
                end;
            end;
        #27:dn2:=TRUE;
    end;
    until (dn2);
    removewindow(w2);
  end;

  procedure getmisc;
  var cho:array[1..6] of string;
      cur:integer;
      s2:string;
      c2:char;
      dn2:boolean;

      function showruler(b:byte):string;
      begin
      case b of
        0:showruler:='Off';
        1:showruler:='On ';
        else showruler:='On ';
      end;
      end;

  begin
    cho[1]:='User Locked Out :';
    cho[2]:='Locked File     :';
    cho[3]:='Screen Length   :';
    cho[4]:='Default Protocol:';
    cho[5]:='Message Ruler   :';
    cho[6]:='Message Editor  :';
    dn2:=FALSE;
    setwindow(w2,25,7,55,16,3,0,8,'Miscellaneous',TRUE);
    for cur:=1 to 6 do begin
    textcolor(7);
    textbackground(0);
    gotoxy(2,cur+1);
    write(cho[cur]);
    end;
    cur:=1;
    repeat
    gotoxy(20,2);
    textcolor(3);
    textbackground(0);
    write(syn(user.lockedout));
    gotoxy(20,3);
    write(mln(user.lockedfile,8));
    gotoxy(20,4);
    write(mln(cstr(user.pagelen),3));
    gotoxy(20,5);
    write(user.defprotocol);
    gotoxy(20,6);
    write(showruler(user.mruler));
    gotoxy(20,7);
    write(mln(cstr(user.msgeditor),3));
    gotoxy(2,cur+1);
    textcolor(15);
    textbackground(1);
    write(cho[cur]);
    while not(keypressed) do begin timeslice; end;
    c2:=readkey;
    case c2 of
         #0:begin
                c2:=readkey;
                checkkey(c2);
                case c2 of
                        #72:begin
                            gotoxy(2,cur+1);
                            textcolor(7);
                            textbackground(0);
                            write(cho[cur]);
                            dec(cur);
                            if (cur=0) then cur:=6;
                            end;
                        #80:begin
                            gotoxy(2,cur+1);
                            textcolor(7);
                            textbackground(0);
                            write(cho[cur]);
                            inc(cur);
                            if (cur=7) then cur:=1;
                            end;
                end;
            end;
        #13:begin
                gotoxy(2,cur+1);
                textcolor(7);
                textbackground(0);
                write(cho[cur]);
                gotoxy(18,cur+1);
                textcolor(9);
                write('>');
                gotoxy(20,cur+1);
                case cur of
                        1:begin
                                user.lockedout:=not(user.lockedout);
                                save:=TRUE;
                          end;
                        2:begin
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=TRUE;
                                        infield_numbers_only:=FALSE;
                                        infield_show_colors:=FALSE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        infield_insert:=TRUE;
                                        s:=user.lockedfile;
                                        infielde(s,8);
                                        infield_min_value:=-1;
                                        infield_max_value:=-1;
                                        infield_maxshow:=0;
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_allcaps:=FALSE;
                                        infield_show_colors:=FALSE;
                                        if (s<>user.lockedfile) then begin
                                        user.lockedfile:=s;
                                        save:=TRUE;
                                        end;
                          end;
                        3:begin
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_numbers_only:=TRUE;
                                        infield_show_colors:=FALSE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        infield_insert:=TRUE;
                                        infield_min_value:=0;
                                        infield_max_value:=50;
                                        s:=cstr(user.pagelen);
                                        infielde(s,3);
                                        infield_min_value:=-1;
                                        infield_max_value:=-1;
                                        infield_maxshow:=0;
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_show_colors:=FALSE;
                                        if (value(s)<>user.pagelen) then begin
                                        user.pagelen:=value(s);
                                        save:=TRUE;
                                        end;
                          end;
                        4:begin
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_numbers_only:=FALSE;
                                        infield_allcaps:=TRUE;
                                        infield_show_colors:=FALSE;
                                        infield_insert:=FALSE;
                                        infield_min_value:=0;
                                        infield_max_value:=32767;
                                        s:=user.defprotocol;
                                        infielde(s,1);
                                        infield_min_value:=-1;
                                        infield_max_value:=-1;
                                        infield_maxshow:=0;
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_allcaps:=TRUE;
                                        infield_show_colors:=FALSE;
                                        if (s[1]<>user.defprotocol) then begin
                                        user.defprotocol:=s[1];
                                        save:=TRUE;
                                        end;
                          end;
                        5:begin
                          if (user.mruler=0) then user.mruler:=1 else
                          user.mruler:=0;
                          save:=TRUE;
                          end;
                        6:begin
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_numbers_only:=TRUE;
                                        infield_show_colors:=FALSE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        infield_insert:=TRUE;
                                        infield_min_value:=-1;
                                        infield_max_value:=255;
                                        s:=cstr(user.msgeditor);
                                        infielde(s,3);
                                        infield_min_value:=-1;
                                        infield_max_value:=-1;
                                        infield_maxshow:=0;
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_show_colors:=FALSE;
                                        if (value(s)<>user.msgeditor) then begin
                                        user.msgeditor:=value(s);
                                        save:=TRUE;
                                        end;
                          end;
                end;
            end;
        #27:dn2:=TRUE;
    end;
    until (dn2);
    removewindow(w2);
  end;

  function showphone(phn:string):string;
  begin
  if (phn='000-000-0000') or (phn='') then showphone:='' else showphone:=phn;
  end;

  function showphone2(phn:string):string;
  begin
  if (phn='000-000-0000') then showphone2:='' else showphone2:=phn;
  end;

  procedure getphones;
  var cho:array[1..4] of string[20];
      cur:integer;
      s2:string;
      c2:char;
      dn2:boolean;

  begin
    with user do begin
    cho[1]:='Voice Phone     :';
    cho[2]:='Data Phone      :';
    cho[3]:=mln(uephone1,16)+':';
    cho[4]:=mln(uephone2,16)+':';
    dn2:=FALSE;
    setwindow(w2,19,8,61,15,3,0,8,'Phone Numbers',TRUE);
    for cur:=1 to 4 do begin
          textcolor(7);
          textbackground(0);
          gotoxy(2,cur+1);
          write(cho[cur]);
    end;
    cur:=1;
    repeat
    gotoxy(20,2);
    textcolor(3);
    textbackground(0);
    write(mln(showphone(phone1),20));
    gotoxy(20,3);
    write(mln(showphone(phone2),20));
    gotoxy(20,4);
    write(mln(showphone(phone3),20));
    gotoxy(20,5);
    write(mln(showphone(phone4),20));
    gotoxy(2,cur+1);
    textcolor(15);
    textbackground(1);
    write(cho[cur]);
    while not(keypressed) do begin timeslice; end;
    c2:=readkey;
    case c2 of
         #0:begin
                c2:=readkey;
                checkkey(c2);
                case c2 of
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
                gotoxy(2,cur+1);
                textcolor(7);
                textbackground(0);
                write(cho[cur]);
                gotoxy(18,cur+1);
                textcolor(9);
                write('>');
                gotoxy(20,cur+1);
                case cur of
                        1:begin
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=false;
                                        infield_numbers_only:=FALSE;
                                        infield_show_colors:=TRUE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        s:=showphone2(user.phone1);
                                        infielde(s,20);
                                        infield_maxshow:=0;
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_show_colors:=FALSE;
                                        if (s<>user.phone1) then begin
                                        if not((s='') and (user.phone1='000-000-0000')) then
                                        begin
                                        user.phone1:=s;
                                        save:=TRUE;
                                        end;
                                        end;
                                        textcolor(3);
                                        textbackground(0);
                                        gotoxy(20,2);
                                        write(mln(showphone(user.phone1),20));
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
                                        s:=showphone2(user.phone2);
                                        infielde(s,20);
                                        infield_maxshow:=0;
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_show_colors:=FALSE;
                                        if (s<>user.phone2) then begin
                                        if not((s='') and (user.phone2='000-000-0000')) then
                                        begin
                                        user.phone2:=s;
                                        save:=TRUE;
                                        end;
                                        end;
                                        textcolor(3);
                                        textbackground(0);
                                        gotoxy(20,2);
                                        write(mln(showphone(user.phone2),20));
                          end;
                        3:begin
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=false;
                                        infield_numbers_only:=FALSE;
                                        infield_show_colors:=TRUE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        s:=showphone2(user.phone3);
                                        infielde(s,20);
                                        infield_maxshow:=0;
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_show_colors:=FALSE;
                                        if (s<>user.phone3) then begin
                                        if not((s='') and (user.phone3='000-000-0000')) then
                                        begin
                                        user.phone3:=s;
                                        save:=TRUE;
                                        end;
                                        end;
                                        textcolor(3);
                                        textbackground(0);
                                        gotoxy(20,2);
                                        write(mln(showphone(user.phone3),20));
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
                                        s:=showphone2(user.phone4);
                                        infielde(s,20);
                                        infield_maxshow:=0;
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_show_colors:=FALSE;
                                        if (s<>user.phone4) then begin
                                        if not((s='') and (user.phone4='000-000-0000')) then
                                        begin
                                        user.phone4:=s;
                                        save:=TRUE;
                                        end;
                                        end;
                                        textcolor(3);
                                        textbackground(0);
                                        gotoxy(20,2);
                                        write(mln(showphone(user.phone4),20));
                          end;
                end;
            end;
        #27:dn2:=TRUE;
    end;
    until (dn2);
    removewindow(w2);
    end;
  end;

  function onoff(b:boolean; s1,s2:astr):astr;
  begin
    if b then onoff:=s1 else onoff:=s2;
  end;


begin
  filemode:=66;
  noask:=FALSE;
  {$I-} reset(uf); {$I+}
  if (ioresult<>0) then begin
        displaybox('Error opening USERS.DAT',3000);
        exit;
  end;
  if ((usern<1) or (usern>filesize(uf)-1)) then begin
        displaybox('User does not exist.',3000);
        close(uf); exit; end;
  cursoron(FALSE);
  choices1[1]:='Real Name       :';
  choices1[2]:='Alias           :';
  choices1[3]:='Nickname (chat) :';
  choices1[4]:='Address #1      :';
  choices1[5]:='Address #2      :';
  choices1[6]:='City, State     :';
  choices1[7]:='Zipcode         :';
  choices1[8]:='Phone Numbers   -';
  choices1[9]:='Calling From    :';
 choices1[10]:=mln(ueopt1,16)+':';
 choices1[11]:=mln(ueopt2,16)+':';
 choices1[12]:=mln(ueopt3,16)+':';
 choices1[13]:='Account Flags   :';
 choices1[14]:='';
 choices1[15]:='';
 choices1[16]:='Custom Flags    -';
 choices1[17]:='Message Records -';
 choices1[18]:='Upload Records  -';
 choices1[19]:='DLoad Records   -';
 choices1[20]:='Call Records    -';
  choices2[1]:='Security Level :';
  choices2[2]:='Birthdate      :';
  choices2[3]:='First On Date  :';
  choices2[4]:='Last On Date   :';
  choices2[5]:='Gender         :';
  choices2[6]:='Password       :';
  choices2[7]:='Filepoints     :';
  choices2[8]:='Credits        :';
  choices2[9]:='Subscription    ';
 choices2[10]:='Time Bank Info  ';
 choices2[11]:='Msg Base SysOp  ';
 choices2[12]:='File Base SysOp ';
 choices2[13]:='Miscellaneous   ';
  desc1[1]:='This User''s Real First and Last Name ';
  desc1[2]:='This User''s Alias - a fake name      ';
  desc1[3]:='This User''s Chat Nickname            ';
  desc1[4]:='Street (mailing) Address Line #1     ';
  desc1[5]:='Street (mailing) Address Line #2     ';
  desc1[6]:='City and State (or City, Country )   ';
  desc1[7]:='User''s Zipcode                       ';
  desc1[8]:='Phone Numbers                        ';
  desc1[9]:='Calling From (for User List, etc.)   ';
 desc1[10]:='Optional Data Field #1               ';
 desc1[11]:='Optional Data Field #2               ';
 desc1[12]:='Optional Data Field #3               ';
 desc1[13]:='Various user account settings        ';
 desc1[14]:='';
 desc1[15]:='';
 desc1[16]:='Can be used by SysOp for security    ';
 desc1[17]:='Message Records of User''s Activity   ';
 desc1[18]:='Upload Records of User''s Activity    ';
 desc1[19]:='Download Records of User''s Activity  ';
 desc1[20]:='Call Records of User''s Activity      ';
 desc1[20]:='Call Records of User''s Activity      ';
  desc2[1]:='Security Level of User               ';
  desc2[2]:='Date User was Born                   ';
  desc2[3]:='First Logged onto this BBS Date      ';
  desc2[4]:='Last Logged onto this BBS Date       ';
  desc2[5]:='User''s Gender (Male, Female, Unspec.)';
  desc2[6]:='User''s Password                      ';
  desc2[7]:='Number of Filepoints this User has   ';
  desc2[8]:='Number of Credits this User has      ';
  desc2[9]:='Edit information for Subscription    ';
 desc2[10]:='Edit Time Bank Information           ';
 desc2[11]:='Edit Bases which User is Sysop Of    ';
 desc2[12]:='Edit Bases which User is Sysop Of    ';
 desc2[13]:='Miscellaneous Information for User   ';
 setwindow2(w,1,1,79,24,3,0,8,'View User '+cstr(usern)+'/'+cstr(filesize(uf)-1),'User Editor',FALSE);
 for x:=1 to 20 do begin
 textcolor(7);
 textbackground(0);
 gotoxy(2,x+1);
 write(choices1[x]);
 end;
 for x:=1 to 13 do begin
 textcolor(7);
 textbackground(0);
 gotoxy(49,x+1);
 write(choices2[x]);
 end;
 update:=TRUE;
 editing:=FALSE;
 arrows:=FALSE;                              
 done:=FALSE;                                

  gotoxy(20,18);
  write('Posts      :');
  gotoxy(41,18);
  write('Feedback        :');
  gotoxy(20,19);
  write('Files      :');
  gotoxy(41,19);
  write('Kb              :');
  gotoxy(20,20);
  write('Files      :');
  gotoxy(41,20);
  write('Kb              :');
  gotoxy(20,21);
  write('Calls Today:');
  gotoxy(41,21);
  write('Time Left Today :');
  gotoxy(20,22);
  write('Total Calls:');
  gotoxy(41,22);
  write('Total Time Spent:');
  oldusern:=0;
  save:=FALSE;
  current:=1;
  noread:=FALSE;
  repeat
  arrows:=FALSE;
  if (update) then begin
  update:=FALSE;
  if (usern<1) then usern:=1;
  if (usern>filesize(uf)-1) then usern:=filesize(uf)-1;
  if not(noread) then begin
  seek(uf,usern); read(uf,user);
  end;
  noread:=FALSE;
  if (editing) then
   setwindow3(w,1,1,79,24,3,0,8,'Edit User '+cstr(usern)+'/'+cstr(filesize(uf)-1),'User Editor - '+
   showsubscription(user.subscription),FALSE)
  else
   setwindow3(w,1,1,79,24,3,0,8,'View User '+cstr(usern)+'/'+cstr(filesize(uf)-1),'User Editor - '+
   showsubscription(user.subscription),FALSE);
  gotoxy(20,2);
  textcolor(3);
  textbackground(0);
  with user do begin
  write(mln(realname,27));
  gotoxy(20,3);
  write(mln(name,27));
  gotoxy(20,4);
  write(mln(nickname,8));
  gotoxy(20,5);
  write(mln(street,27));
  gotoxy(20,6);
  write(mln(street2,27));
  gotoxy(20,7);
  write(mln(citystate,27));
  gotoxy(20,8);
  write(mln(zipcode,27));
  gotoxy(20,9);
  write(mln(showphone(phone1)+' (voice)',27));
  gotoxy(20,10);
  write(mln(business,27));
  gotoxy(20,11);
  write(mln(option1,27));
  gotoxy(20,12);
  write(mln(option2,27));
  gotoxy(20,13);
  write(mln(option3,27));
  gotoxy(20,14);
  write(mln(spflags(user),27));
  gotoxy(20,17);
  s:='';
  for c:='A' to 'Z' do
     if c in ar then s:=s+c else s:=s+'-';
  cwrite('%070%1:%030%'+s);
  s:='';
  for c:='A' to 'Z' do
     if c in ar2 then s:=s+c else s:=s+'-';
  cwrite(' %070%2:%030%'+s);
  textcolor(7);
  textbackground(0);
  gotoxy(49,1);
  write('Status: ');
  gotoxy(65,1);
  write('UserID: ');
  textcolor(3);
  textbackground(0);
  gotoxy(57,1);
  s:=showstatus;
  case s[1] of
        'D':textcolor(12);
        'A':textcolor(28);
        'L':textcolor(14);
        'T':textcolor(15);
  end;
  write(mln(showstatus,7));
  gotoxy(73,1);
  textcolor(3);
  write(mln(cstr(userID),5));
  textcolor(3);
  gotoxy(66,2);
  write(mln(cstr(sl),3));
  gotoxy(66,3);
  unixtodt(bday,dt);
  write(formatteddate(dt,'MM/DD/YYYY'));
  gotoxy(66,4);
  unixtodt(firston,dt);
  write(formatteddate(dt,'MM/DD/YYYY'));
  gotoxy(66,5);
  unixtodt(laston,dt);
  write(formatteddate(dt,'MM/DD/YYYY'));
  gotoxy(66,6);
  write(sex);
  gotoxy(66,7);
  write(mln(pw,10));
  gotoxy(66,8);
  write(mln(cstr(filepoints),5));
  gotoxy(66,9);
  write(mln(cstr(credit),5));
  end;
{                                            
User Name       :                              Security Level :
Real Name       :                              Status         :
Address #1      :                              Birthdate      :
Address #2      :                              First On Date  :
City, State     :                              Last On Date   :
Zipcode         :                              Gender         :
Phone #1        :                              Password       :
Phone #2        :                              Filepoints     :
Phone #3        :                              Credits        :
Phone #4        :                              Subscription
Calling From    :                              Timebank Record
Optional #1     :                              Logging Options
Optional #2     :                              Msg Base Sysop 
Optional #3     :                              File Base Sysop
User Flags      :                              Miscellaneous
AR Flags        :
Message Records - Posts      : xxxxx   Feedback        : xxxxxxxxxxx
Upload Records  - Files      : xxxxx   Kb              : xxxxxxxxxxxk
DLoad Records   - Files      : xxxxx   Kb              : xxxxxxxxxxxk
Call Records    - Calls Today: xxxxx   Time Left Today : xxxxx
                  Total Calls: xxxxx   Total Time Spent: xxxxx
}
  showmsginfo;
  showulinfo;
  showdlinfo;
  showcallinfo;
  end;
  if (editing) then begin
{ lr = 0  left  1 = right }
  gotoxy(2+(47*lr),current+1);
  textcolor(15);
  textbackground(1);
  if (lr=0) then
  write(choices1[current])
  else
  write(choices2[current]);
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
  write('=Help ');
  textcolor(14);
  if (lr=0) then
  write(desc1[current])
  else
  write(desc2[current]);
  window(2,2,78,23);
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
  write('F1');
  textcolor(7);
  write('=Help ');
  if (user.note<>'') then begin
        textcolor(12);
        write(mln(user.note,61));
  end else begin
        write(mln('',61));
  end;
  end;
    while not(keypressed) do begin timeslice; end;
    c:=readkey;
    case c of
      #0:begin
                c:=readkey;
                checkkey(c);
                case c of
                        #59:if not(editing) then begin
                                showhelp('NXSETUP',14);
                                window(2,2,78,23);
                            end else begin
                                showhelp('NXSETUP',15);
                                window(2,2,78,23);
                            end;
                        #68:if (editing) then begin
                                gotoxy(2+(47*lr),current+1);
                                textcolor(7);
                                textbackground(0);
                                if (lr=0) then 
                                write(choices1[current])
                                else
                                write(choices2[current]);
                                editing:=FALSE;
                                update:=TRUE;
                                arrows:=TRUE;
                                current:=1;
                                lr:=0;
                            if (save) then begin
                                noask:=TRUE;
                            end;
                            end;
                        #72:if (editing) then begin
                                gotoxy(2+(47*lr),current+1);
                                textcolor(7);
                                textbackground(0);
                                if (lr=0) then 
                                write(choices1[current])
                                else
                                write(choices2[current]);
                                dec(current);
                                if (lr=0) and (current=15) then begin
                                    current:=13;
                                end;
                                if ((lr=0) and (current=0)) or ((lr=1) and
                                        (current=0)) then
                                        if (lr=1) then begin
                                                lr:=0;
                                                current:=20;
                                        end else begin
                                                lr:=1;
                                                current:=13;
                                        end;
                            end;
                        #75:if (editing) then begin
                                gotoxy(2+(47*lr),current+1);
                                textcolor(7);
                                textbackground(0);
                                if (lr=0) then 
                                        write(choices1[current])
                                else
                                        write(choices2[current]);
                                if (lr=1) then begin
                                        lr:=0;
                                end else begin
                                        lr:=1;
                                        if (current>15) then current:=13;
                                end;
                            end else begin
                                dec(usern);
                                if (usern<1) then usern:=filesize(uf)-1;
                                update:=TRUE;
                                arrows:=TRUE;
                            end;
                        #77:if (editing) then begin
                                gotoxy(2+(47*lr),current+1);
                                textcolor(7);
                                textbackground(0);
                                if (lr=0) then 
                                        write(choices1[current])
                                else
                                        write(choices2[current]);
                                if (lr=1) then begin
                                        lr:=0;
                                end else begin
                                        if (current>15) then current:=13;
                                        lr:=1;
                                end;
                            end else begin
                                inc(usern);
                                if (usern>filesize(uf)-1) then usern:=1;
                                update:=TRUE;
                                arrows:=TRUE;
                            end;
                        #80:if (editing) then begin
                                gotoxy(2+(47*lr),current+1);
                                textcolor(7);
                                textbackground(0);
                                if (lr=0) then 
                                write(choices1[current])
                                else
                                write(choices2[current]);
                                inc(current);
                                if (lr=0) then begin
                                        if (current=14) then begin
                                          current:=16;
                                        end;
                                        if (current=21) then begin
                                          current:=1;
                                          lr:=1;
                                        end;
                                end else begin
                                        if (current=14) then begin
                                        current:=1;
                                        lr:=0;
                                        end;
                                end;
                            end;
             chr(31):if not(editing) then begin
 setwindow4(w,1,1,79,24,8,0,8,'View User '+cstr(usern)+'/'+cstr(filesize(uf)-1),'User Editor',FALSE);
                            finduserws2(i);
 setwindow5(w,1,1,79,24,3,0,8,'View User '+cstr(usern)+'/'+cstr(filesize(uf)-1),'User Editor',FALSE);
                            if (i>0) and (i<=filesize(uf)-1) then begin
                              usern:=i;
                              update:=TRUE;
                            end;
                        end;
             chr(49):if not(editing) then begin
 setwindow4(w,1,1,79,24,8,0,8,'View User '+cstr(usern)+'/'+cstr(filesize(uf)-1),'User Editor',FALSE);
                            getnote;
 setwindow5(w,1,1,79,24,3,0,8,'View User '+cstr(usern)+'/'+cstr(filesize(uf)-1),'User Editor',FALSE);
                            if (save) then begin
                                noask:=TRUE;
                                arrows:=TRUE;
                            end;
                        end;
             chr(46):if not(editing) then begin
 setwindow4(w,1,1,79,24,8,0,8,'View User '+cstr(usern)+'/'+cstr(filesize(uf)-1),'User Editor',FALSE);
                            getclearflags;
                            if (save) then begin
                                noask:=TRUE;
                                arrows:=TRUE;
                            end;
 setwindow5(w,1,1,79,24,3,0,8,'View User '+cstr(usern)+'/'+cstr(filesize(uf)-1),'User Editor',FALSE);
                            window(2,2,78,23);
                        end;
              #47:if not(editing) then begin
 setwindow4(w,1,1,79,24,8,0,8,'View User '+cstr(usern)+'/'+cstr(filesize(uf)-1),'User Editor',FALSE);
                                        getsub;
 setwindow5(w,1,1,79,24,3,0,8,'View User '+cstr(usern)+'/'+cstr(filesize(uf)-1),'User Editor',FALSE);
                                        window(2,2,78,23);
                                        noask:=TRUE;
                                        arrows:=TRUE;
                        end;
             chr(25):if not(editing) then begin
                            packusers;
                            window(2,2,78,23);
                            if (usern>filesize(uf)-1) then usern:=filesize(uf)-1;
                            update:=TRUE;
                        end;
                    #83:if not(editing) then begin
                    if (user.deleted) then begin
                      if pynqbox('User is currently Deleted. Restore This User? ') then begin
                        isr(user.name,user.realname,user.nickname,usern,user.userID);
                        user.deleted:=FALSE;
                        update:=TRUE;
                        save:=TRUE;
                        noask:=TRUE;
                        arrows:=TRUE;
                      end;
                    end else
                      if (fnodeletion in user.ac) then begin
                        displaybox('This User Is Protected From Deletion.',2000);
                      end else begin
                        if pynqbox('Delete This User? ') then begin
                                delusr;
                                update:=TRUE;
                                save:=TRUE;
                                noask:=TRUE;
                                arrows:=TRUE;
                        end;
                      end;
                   end;
                   end;
         end;
      #27:if (editing) then begin
                                gotoxy(2+(47*lr),current+1);
                                textcolor(7);
                                textbackground(0);
                                if (lr=0) then 
                                write(choices1[current])
                                else
                                write(choices2[current]);
                editing:=FALSE;
                update:=TRUE;
                arrows:=TRUE;
                current:=1;
                lr:=0;
          end else done:=TRUE;
     '0'..'9':if not(editing) then begin

  setwindow(w2,27,12,54,14,3,0,8,'',TRUE);
  gotoxy(2,1);
  textcolor(7);
  textbackground(0);
  write('Goto User Number : ');
  gotoxy(21,1);
  s:=c;
  infield_inp_fgrd:=15;
  infield_inp_bkgd:=1;
  infield_out_fgrd:=3;
  infield_out_bkgd:=0;
  infield_allcaps:=false;
  infield_numbers_only:=TRUE;
  infield_escape_zero:=FALSE;
  infield_escape_blank:=TRUE;
  infield_putatend:=TRUE;
  infield_insert:=TRUE;
  infield_clear:=FALSE;
  infielde(s,5);
  infield_escape_blank:=FALSE;
  infield_putatend:=FALSE;
  infield_insert:=TRUE;
  if (value(s)>0) and (value(s)<=filesize(uf)-1) then begin
  if (s<>'') then begin
  usern:=value(s);
  update:=TRUE;
  arrows:=TRUE;
  end;
  end;
  removewindow(w2);

                        end;
      #13:if not(editing) then begin
                editing:=TRUE;
                update:=TRUE;
                current:=1;
                lr:=0;
          end else begin
                                gotoxy(2+(47*lr),current+1);
                                textcolor(7);
                                textbackground(0);
                                if (lr=0) then 
                                write(choices1[current])
                                else
                                write(choices2[current]);
                case lr of
                        0:case current of
                                1:if not(user.deleted) then begin
                                        gotoxy(18,current+1);
                                        textcolor(9);
                                        textbackground(0);
                                        write('>');
                                        gotoxy(20,current+1);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=false;
                                        infield_maxshow:=27;
                                        infield_numbers_only:=FALSE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        infield_show_colors:=TRUE;
                                        s:=user.realname;
                                        infielde(s,36);
                                        infield_maxshow:=0;
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_show_colors:=FALSE;
                                        if (s<>user.realname) then begin
                                        dsr(user.name,usern); isr(user.name,s,user.nickname,usern,user.userid);
                                        user.realname:=s;
                                        save:=TRUE;
                                        end;
                                   end;
                                2:if not(user.deleted) then begin
                                        gotoxy(18,current+1);
                                        textcolor(9);
                                        textbackground(0);
                                        write('>');
                                        gotoxy(20,current+1);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=FALSE;
                                        infield_maxshow:=27;
                                        infield_numbers_only:=FALSE;
                                        infield_show_colors:=TRUE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        s:=user.name;
                                        infielde(s,36);
                                        infield_maxshow:=0;
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_show_colors:=FALSE;
                                        if (s<>user.name) then begin
                                        dsr(user.name,usern);
                                        isr(s,user.realname,user.nickname,usern,user.userid);
                                        user.name:=s;
                                        save:=TRUE;
                                        end;
                                  end;
                                3:if not(user.deleted) then begin
                                        gotoxy(18,current+1);
                                        textcolor(9);
                                        textbackground(0);
                                        write('>');
                                        gotoxy(20,current+1);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=false;
                                        infield_maxshow:=27;
                                        infield_numbers_only:=FALSE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        infield_show_colors:=TRUE;
                                        s:=user.nickname;
                                        infielde(s,8);
                                        infield_maxshow:=0;
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_show_colors:=FALSE;
                                        if (s<>user.nickname) then begin
                                        dsr(user.name,usern); isr(user.name,user.realname,s,usern,user.userid);
                                        user.nickname:=s;
                                        save:=TRUE;
                                        end;
                                   end;
                                4:begin
                                        gotoxy(18,current+1);
                                        textcolor(9);
                                        textbackground(0);
                                        write('>');
                                        gotoxy(20,current+1);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=false;
                                        infield_maxshow:=27;
                                        infield_numbers_only:=FALSE;
                                        infield_show_colors:=TRUE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        s:=user.street;
                                        infielde(s,30);
                                        infield_maxshow:=0;
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_show_colors:=FALSE;
                                        if (s<>user.street) then begin
                                        user.street:=s;
                                        save:=TRUE;
                                        end;
                                  end;
                                5:begin
                                        gotoxy(18,current+1);
                                        textcolor(9);
                                        textbackground(0);
                                        write('>');
                                        gotoxy(20,current+1);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=false;
                                        infield_maxshow:=27;
                                        infield_numbers_only:=FALSE;
                                        infield_show_colors:=TRUE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        s:=user.street2;
                                        infielde(s,30);
                                        infield_maxshow:=0;
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_show_colors:=FALSE;
                                        if (s<>user.street2) then begin
                                        user.street2:=s;
                                        save:=TRUE;
                                        end;
                                  end;
                                6:begin
                                        gotoxy(18,current+1);
                                        textcolor(9);
                                        textbackground(0);
                                        write('>');
                                        gotoxy(20,current+1);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=false;
                                        infield_maxshow:=27;
                                        infield_numbers_only:=FALSE;
                                        infield_show_colors:=TRUE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        s:=user.citystate;
                                        infielde(s,40);
                                        infield_maxshow:=0;
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_show_colors:=FALSE;
                                        if (s<>user.citystate) then begin
                                        user.citystate:=s;
                                        save:=TRUE;
                                        end;
                                  end;
                                7:begin
                                        gotoxy(18,current+1);
                                        textcolor(9);
                                        textbackground(0);
                                        write('>');
                                        gotoxy(20,current+1);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=false;
                                        infield_numbers_only:=FALSE;
                                        infield_show_colors:=TRUE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        s:=user.zipcode;
                                        infielde(s,20);
                                        infield_maxshow:=0;
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_show_colors:=FALSE;
                                        if (s<>user.zipcode) then begin
                                        user.zipcode:=s;
                                        save:=TRUE;
                                        end;
                                  end;
                                8:begin
 setwindow4(w,1,1,79,24,8,0,8,'View User '+cstr(usern)+'/'+cstr(filesize(uf)-1),'User Editor',FALSE);
                                  getphones;
 setwindow5(w,1,1,79,24,3,0,8,'View User '+cstr(usern)+'/'+cstr(filesize(uf)-1),'User Editor',FALSE);
                                  window(2,2,78,23);
                                  gotoxy(20,current+1);
                                  textcolor(3);
                                  write(mln(showphone(user.phone1)+' (voice)',27));
                                  end;
                                9:begin
                                        gotoxy(18,current+1);
                                        textcolor(9);
                                        textbackground(0);
                                        write('>');
                                        gotoxy(20,current+1);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=false;
                                        infield_maxshow:=27;
                                        infield_numbers_only:=FALSE;
                                        infield_show_colors:=TRUE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        s:=user.business;
                                        infielde(s,40);
                                        infield_maxshow:=0;
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_show_colors:=FALSE;
                                        if (s<>user.business) then begin
                                        user.business:=s;
                                        save:=TRUE;
                                        end;
                                  end;
                                10:begin
                                        gotoxy(18,current+1);
                                        textcolor(9);
                                        textbackground(0);
                                        write('>');
                                        gotoxy(20,current+1);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_maxshow:=27;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=false;
                                        infield_numbers_only:=FALSE;
                                        infield_show_colors:=TRUE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        s:=user.option1;
                                        infielde(s,30);
                                        infield_maxshow:=0;
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_show_colors:=FALSE;
                                        if (s<>user.option1) then begin
                                        user.option1:=s;
                                        save:=TRUE;
                                        end;
                                  end;
                                11:begin
                                        gotoxy(18,current+1);
                                        textcolor(9);
                                        textbackground(0);
                                        write('>');
                                        gotoxy(20,current+1);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=false;
                                        infield_maxshow:=27;
                                        infield_numbers_only:=FALSE;
                                        infield_show_colors:=TRUE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        s:=user.option2;
                                        infielde(s,40);
                                        infield_maxshow:=0;
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_show_colors:=FALSE;
                                        if (s<>user.option2) then begin
                                        user.option2:=s;
                                        save:=TRUE;
                                        end;
                                  end;
                                12:begin
                                        gotoxy(18,current+1);
                                        textcolor(9);
                                        textbackground(0);
                                        write('>');
                                        gotoxy(20,current+1);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_maxshow:=27;
                                        infield_allcaps:=false;
                                        infield_numbers_only:=FALSE;
                                        infield_show_colors:=TRUE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        s:=user.option3;
                                        infielde(s,40);
                                        infield_maxshow:=0;
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_show_colors:=FALSE;
                                        if (s<>user.option3) then begin
                                        user.option3:=s;
                                        save:=TRUE;
                                        end;
                                  end;
                               13:begin
 setwindow4(w,1,1,79,24,8,0,8,'View User '+cstr(usern)+'/'+cstr(filesize(uf)-1),'User Editor',FALSE);
                                  getrestrictions;
 setwindow5(w,1,1,79,24,3,0,8,'View User '+cstr(usern)+'/'+cstr(filesize(uf)-1),'User Editor',FALSE);
                                  window(2,2,78,23);
                                  gotoxy(57,1);
                                  textcolor(3);
                                  s:=showstatus;
                                  case s[1] of
                                        'D':textcolor(12);
                                        'A':textcolor(28);
                                        'L':textcolor(14);
                                        'T':textcolor(15);
                                  end;
                                  write(mln(showstatus,7));
                                  update:=TRUE;
                                  noread:=TRUE;
                                  end;
                               16:begin
                                        gotoxy(18,current+1);
                                        textcolor(9);
                                        textbackground(0);
                                        write('>');
                                        gotoxy(22,current+1);
                                        textcolor(15);
                                        textbackground(1);
                                        s:='';
                                        for c:='A' to 'Z' do
                                             if c in user.ar then s:=s+c else s:=s+'-';
                                        write(s);
                                        c:=#0;
                                        oldar:=user.ar;
                                        while (c<>#27) and (c<>#13) do begin
                                                while not(keypressed) do begin timeslice;
                                                end;
                                                c:=readkey;
                                                c:=upcase(c);
                                                if (c in ['A'..'Z']) then begin
                                                        if (c in user.ar) then user.ar:=
                                                                user.ar-[c] else
                                                        user.ar:=user.ar+[c];
                                                        gotoxy(22,current+1);
                                                        textcolor(15);
                                                        textbackground(1);
                                                        s:='';
                                                        save:=TRUE;
                                                        for c:='A' to 'Z' do
                                                             if c in user.ar then s:=s+c else s:=s+'-';
                                                        write(s);
                                                end;
                                        end;
                                        if (c=#27) then begin
                                                user.ar:=oldar;
                                                save:=FALSE;
                                        end;
                                        gotoxy(22,current+1);
                                        textcolor(3);
                                        textbackground(0);
                                        s:='';
                                        for c:='A' to 'Z' do
                                               if c in user.ar then s:=s+c else s:=s+'-';
                                        write(s);
                                        gotoxy(51,current+1);
                                        textcolor(15);
                                        textbackground(1);
                                        s:='';
                                        for c:='A' to 'Z' do
                                             if c in user.ar2 then s:=s+c else s:=s+'-';
                                        write(s);
                                        c:=#0;
                                        oldar:=user.ar2;
                                        while (c<>#27) and (c<>#13) do begin
                                                while not(keypressed) do begin timeslice;
                                                end;
                                                c:=readkey;
                                                c:=upcase(c);
                                                if (c in ['A'..'Z']) then begin
                                                        if (c in user.ar2) then user.ar2:=
                                                                user.ar2-[c] else
                                                        user.ar2:=user.ar2+[c];
                                                        gotoxy(51,current+1);
                                                        textcolor(15);
                                                        textbackground(1);
                                                        s:='';
                                                        save:=TRUE;
                                                        for c:='A' to 'Z' do
                                                             if c in user.ar2 then s:=s+c else s:=s+'-';
                                                        write(s);
                                                end;
                                        end;
                                        if (c=#27) then begin
                                                user.ar2:=oldar;
                                                save:=FALSE;
                                        end;
                                        gotoxy(51,current+1);
                                        textcolor(3);
                                        textbackground(0);
                                        s:='';
                                        for c:='A' to 'Z' do
                                               if c in user.ar2 then s:=s+c else s:=s+'-';
                                        write(s);
                                        c:=#13;
                                  end;
                               17:begin
 setwindow4(w,1,1,79,24,8,0,8,'View User '+cstr(usern)+'/'+cstr(filesize(uf)-1),'User Editor',FALSE);
                                  getmsgrecord;
 setwindow5(w,1,1,79,24,3,0,8,'View User '+cstr(usern)+'/'+cstr(filesize(uf)-1),'User Editor',FALSE);
                                  window(2,2,78,23);
                                  showmsginfo;
                                  end;
                               18:begin
 setwindow4(w,1,1,79,24,8,0,8,'View User '+cstr(usern)+'/'+cstr(filesize(uf)-1),'User Editor',FALSE);
                                  getulrecord;
 setwindow5(w,1,1,79,24,3,0,8,'View User '+cstr(usern)+'/'+cstr(filesize(uf)-1),'User Editor',FALSE);
                                  window(2,2,78,23);
                                  showulinfo;
                                  end;
                               19:begin
 setwindow4(w,1,1,79,24,8,0,8,'View User '+cstr(usern)+'/'+cstr(filesize(uf)-1),'User Editor',FALSE);
                                  getdlrecord;
 setwindow5(w,1,1,79,24,3,0,8,'View User '+cstr(usern)+'/'+cstr(filesize(uf)-1),'User Editor',FALSE);
                                  window(2,2,78,23);
                                  showdlinfo;
                                  end;
                               20:begin
 setwindow4(w,1,1,79,24,8,0,8,'View User '+cstr(usern)+'/'+cstr(filesize(uf)-1),'User Editor',FALSE);
                                  getcallrecord;
 setwindow5(w,1,1,79,24,3,0,8,'View User '+cstr(usern)+'/'+cstr(filesize(uf)-1),'User Editor',FALSE);
                                  window(2,2,78,23);
                                  showcallinfo;
                                  end;
                          end;
                        1:case current of
                                1:begin
 setwindow4(w,1,1,79,24,8,0,8,'View User '+cstr(usern)+'/'+cstr(filesize(uf)-1),'User Editor',FALSE);
                                        byt:=getseclevel;
 setwindow5(w,1,1,79,24,3,0,8,'View User '+cstr(usern)+'/'+cstr(filesize(uf)-1),'User Editor',FALSE);
                                        window(2,2,78,23);
                                        if (byt>0) and (byt<101) then begin
                                                user.sl:=byt;
                                                save:=TRUE;
                                                textcolor(3);
                                                textbackground(0);
                                                gotoxy(66,4);
                                                write(mln(cstr(user.sl),3));
                                        end;
                                  end;
                                2:begin
                                        gotoxy(64,current+1);
                                        textcolor(9);
                                        textbackground(0);
                                        write('>');
                                        gotoxy(66,current+1);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=false;
                                        infield_numbers_only:=FALSE;
                                        infield_show_colors:=TRUE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        unixtodt(user.bday,dt);
                                        s:=formatteddate(dt,'MM/DD/YYYY');
                                        infielde(s,10);
                                        infield_maxshow:=0;
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_show_colors:=FALSE;
                                        if (s<>formatteddate(dt,'MM/DD/YYYY')) then begin
                                        user.bday:=u_daynum(s);
                                        save:=TRUE;
                                        end;
                                  end;
                                3:begin
                                        gotoxy(64,current+1);
                                        textcolor(9);
                                        textbackground(0);
                                        write('>');
                                        gotoxy(66,current+1);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=false;
                                        infield_numbers_only:=FALSE;
                                        infield_show_colors:=TRUE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        unixtodt(user.firston,dt);
                                        s:=formatteddate(dt,'MM/DD/YYYY');
                                        infielde(s,10);
                                        infield_maxshow:=0;
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_show_colors:=FALSE;
                                        if (s<>formatteddate(dt,'MM/DD/YYYY')) then begin
                                        user.firston:=u_daynum(s);
                                        save:=TRUE;
                                        end;
                                  end;
                                4:begin
                                        gotoxy(64,current+1);
                                        textcolor(9);
                                        textbackground(0);
                                        write('>');
                                        gotoxy(66,current+1);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=false;
                                        infield_numbers_only:=FALSE;
                                        infield_show_colors:=TRUE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        unixtodt(user.laston,dt);
                                        s:=formatteddate(dt,'MM/DD/YYYY');
                                        infielde(s,10);
                                        infield_maxshow:=0;
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_show_colors:=FALSE;
                                        if (s<>formatteddate(dt,'MM/DD/YYYY')) then begin
                                        user.laston:=u_daynum(s);
                                        save:=TRUE;
                                        end;
                                  end;
                                5:begin
                                        gotoxy(64,current+1);
                                        textcolor(9);
                                        textbackground(0);
                                        write('>');
                                        gotoxy(66,current+1);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=TRUE;
                                        infield_numbers_only:=FALSE;
                                        infield_show_colors:=FALSE;
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_restrict_list:='MFUmfu';
                                        s:=user.sex;
                                        infielde(s,1);
                                        infield_restrict_list:='';
                                        infield_maxshow:=0;
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_show_colors:=FALSE;
                                        if (s[1]<>user.sex) and (s[1] in ['M','F','U'])
                                        then begin
                                        user.sex:=s[1];
                                        save:=TRUE;
                                        end;
                                  end;
                                6:begin
                                        gotoxy(64,current+1);
                                        textcolor(9);
                                        textbackground(0);
                                        write('>');
                                        gotoxy(66,current+1);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=TRUE;
                                        infield_numbers_only:=FALSE;
                                        infield_show_colors:=TRUE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        infield_maxshow:=10;
                                        s:=user.pw;
                                        infielde(s,20);
                                        infield_maxshow:=0;
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_show_colors:=FALSE;
                                        infield_allcaps:=FALSE;
                                        if (s<>user.pw) then begin
                                        user.pw:=s;
                                        save:=TRUE;
                                        end;
                                  end;
                                7:begin
                                        gotoxy(64,current+1);
                                        textcolor(9);
                                        textbackground(0);
                                        write('>');
                                        gotoxy(66,current+1);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=false;
                                        infield_numbers_only:=TRUE;
                                        infield_show_colors:=FALSE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        infield_min_value:=0;
                                        infield_max_value:=32767;
                                        s:=cstr(user.filepoints);
                                        infielde(s,5);
                                        infield_min_value:=-1;
                                        infield_max_value:=-1;
                                        infield_maxshow:=0;
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_show_colors:=FALSE;
                                        infield_numbers_only:=FALSE;
                                        if (value(s)<>user.filepoints) then begin
                                        user.filepoints:=value(s);
                                        save:=TRUE;
                                        end;
                                  end;
                               8:begin
                                        gotoxy(64,current+1);
                                        textcolor(9);
                                        textbackground(0);
                                        write('>');
                                        gotoxy(66,current+1);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=false;
                                        infield_numbers_only:=TRUE;
                                        infield_show_colors:=FALSE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        infield_min_value:=0;
                                        infield_max_value:=32767;
                                        s:=cstr(user.credit);
                                        infielde(s,5);
                                        infield_min_value:=-1;
                                        infield_max_value:=-1;
                                        infield_maxshow:=0;
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_show_colors:=FALSE;
                                        infield_numbers_only:=FALSE;
                                        if (value(s)<>user.credit) then begin
                                        user.credit:=value(s);
                                        save:=TRUE;
                                        end;
                                  end;
                               9:begin
 setwindow4(w,1,1,79,24,8,0,8,'View User '+cstr(usern)+'/'+cstr(filesize(uf)-1),'User Editor',FALSE);
                                        getsub;
 setwindow5(w,1,1,79,24,3,0,8,'View User '+cstr(usern)+'/'+cstr(filesize(uf)-1),'User Editor',FALSE);
                                        window(2,2,78,23);
                                        update:=TRUE;
                                        noread:=TRUE;
                                  end;
                               10:begin
 setwindow4(w,1,1,79,24,8,0,8,'View User '+cstr(usern)+'/'+cstr(filesize(uf)-1),'User Editor',FALSE);
                                        gettimebank;
 setwindow5(w,1,1,79,24,3,0,8,'View User '+cstr(usern)+'/'+cstr(filesize(uf)-1),'User Editor',FALSE);
                                        window(2,2,78,23);
                                  end;
                               11:begin
 setwindow4(w,1,1,79,24,8,0,8,'View User '+cstr(usern)+'/'+cstr(filesize(uf)-1),'User Editor',FALSE);
                                        getsysops(1);
 setwindow5(w,1,1,79,24,3,0,8,'View User '+cstr(usern)+'/'+cstr(filesize(uf)-1),'User Editor',FALSE);
                                        window(2,2,78,23);
                                  end;
                               12:begin
 setwindow4(w,1,1,79,24,8,0,8,'View User '+cstr(usern)+'/'+cstr(filesize(uf)-1),'User Editor',FALSE);
                                        getsysops(2);
 setwindow5(w,1,1,79,24,3,0,8,'View User '+cstr(usern)+'/'+cstr(filesize(uf)-1),'User Editor',FALSE);
                                        window(2,2,78,23);
                                  end;
                               13:begin
 setwindow4(w,1,1,79,24,8,0,8,'View User '+cstr(usern)+'/'+cstr(filesize(uf)-1),'User Editor',FALSE);
                                        getmisc;
 setwindow5(w,1,1,79,24,3,0,8,'View User '+cstr(usern)+'/'+cstr(filesize(uf)-1),'User Editor',FALSE);
                                        window(2,2,78,23);
                                  gotoxy(57,1);
                                  textcolor(3);
                                  s:=showstatus;
                                  case s[1] of
                                        'D':textcolor(12);
                                        'A':textcolor(28);
                                        'L':textcolor(14);
                                        'T':textcolor(15);
                                  end;
                                  write(mln(showstatus,7));
                                  end;
                          end;
                end;
          end;
    end;
    if (save) and ((done) or (arrows)) then begin
        if (noask) then begin
              seek(uf,usern); write(uf,user);
        end else
        if pynqbox('Save Changes? ') then begin
              seek(uf,usern); write(uf,user);
        end;
        window(2,2,78,23);
        update:=TRUE;
        save:=FALSE;
        noask:=FALSE;
    end;
  until (done);
  close(uf);
end;

end.
