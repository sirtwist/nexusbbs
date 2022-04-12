(*****************************************************************************)
(*>                                                                         <*)
(*>  SYSOP9  .PAS -  Written by Eric Oman                                   <*)
(*>                                                                         <*)
(*>  SysOp functions: File base editor                                      <*)
(*>                                                                         <*)
(*****************************************************************************)
{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R-,S+,V-}
unit sysop9;

interface

procedure dlboardedit;
procedure updatefconfs;
procedure updatefbaseidx;

implementation

uses
  crt, dos, misc, myio, sysop2m,procspec,usertag;

const reindex:boolean=FALSE;
      reindex2:boolean=FALSE;
      defaulttags:boolean=FALSE;

procedure updatefbaseidx;
  var bif:file of baseidx;
      ulf:file of ulrec;
      w2:windowrec;
      bi:baseidx;
      fb:ulrec;
  begin
  assign(ulf,adrv(systat.gfilepath)+'FBASES.DAT');
  {$I-} reset(ulf); {$I+}
  if (ioresult<>0) then begin
        displaybox('Error opening FBASES.DAT',3000);
        exit;
  end;
  seek(ulf,0);
  assign(bif,adrv(systat.gfilepath)+'FBASES.IDX');
  {$I-} rewrite(bif); {$I+}
  if (ioresult<>0) then begin
        displaybox('Error updating FBASES.IDX',3000);
        exit;
  end;
  displaybox3(11,w2,'Updating File Base Indexes...');
  while not(eof(ulf)) do begin
        bi.offset:=filepos(ulf);
        read(ulf,fb);
        bi.baseid:=fb.baseid;
        write(bif,bi);
  end;
  close(bif);
  close(ulf);
  removewindow(w2);
  end;

procedure updatefconfs;
TYPE
booleanrec=
        RECORD
        bool:array[0..32767] of boolean;
        end;

var w2:windowrec;
    ulf:file of ulrec;
    ul:ulrec;
    boolf:file of booleanrec;
    bol:^booleanrec;
    x:integer;
    c4:char;
    baseavail:boolean;
    conff:file of confrec;
    conf:confrec;

begin
new(bol);
setwindow(w2,18,10,62,13,3,0,8,'Updating File Conferences',TRUE);
assign(ulf,adrv(systat.gfilepath)+'FBASES.DAT');
{$I-} reset(ulf); {$I+}
if (ioresult<>0) then begin
        displaybox('Error opening FBASES.DAT',3000);
        removewindow(w2);
        exit;
end;
assign(conff,adrv(systat.gfilepath)+'CONFS.DAT');
{$I-} reset(conff); {$I+}
if (ioresult<>0) then begin
        displaybox('Error reading CONFS.DAT',3000);
        removewindow(w2);
        exit;
end;
read(conff,conf);
close(conff);
gotoxy(2,2);
textcolor(3);
textbackground(0);
write('Conference [ ]  Bases Available [     ]');
textcolor(15);
textbackground(0);
for c4:='A' to 'Z' do begin
if (conf.fileconf[ord(c4)-64].active) then begin
        gotoxy(14,2);
        write(c4);
        assign(boolf,adrv(systat.gfilepath)+'FCONF'+c4+'.IDX');
        {$I-} rewrite(boolf); {$I+}
        if (ioresult<>0) then begin
                displaybox('Error creating '+adrv(systat.gfilepath)+'FCONF'+c4+'.IDX',3000);
                exit;
        end;
        baseavail:=FALSE;
        fillchar(bol^,sizeof(bol^),#0);
        write(boolf,bol^);
        x:=0;
        seek(ulf,0);
        while not(eof(ulf)) do begin
                seek(ulf,x);
                read(ulf,ul);
                baseavail:=TRUE;
                if (c4 in ul.inconfs) then begin
                        gotoxy(35,2);
                        write(mln(cstr(x),5));
                        bol^.bool[x]:=baseavail;
                end;
                inc(x);
        end;
        seek(boolf,0);
        write(boolf,bol^);
        close(boolf);
        end;
end;
close(ulf);
dispose(bol);
removewindow(w2);
end;

procedure dlboardedit;
const ltype:integer=1;
var i1,ii,culb,i2,x,y,i3:integer;
    c,c3:char;
    cnode2:integer;
    s0:astr;
    s:string;
    f:file;
    dp,dels,abort,next,done:boolean;


  procedure idxdelete(bidx:longint);
  var bif:file of baseididx;
      bi:baseididx;
  begin
  assign(bif,adrv(systat.gfilepath)+'FBASEID.IDX');
  {$I-} reset(bif); {$I+}
  if (ioresult<>0) then begin
        displaybox('Error updating FBASEID.IDX',3000);
        exit;
  end;
  seek(bif,bidx);
  read(bif,bi);
  if (bi.baseid<>bidx) then begin
        displaybox('FBASEID.IDX is corrupted!',3000);
        exit;
  end;
  bi.offset:=-1;
  seek(bif,bidx);
  write(bif,bi);
  close(bif);
  end;

  function newindexno:longint;
  begin
    readpermid;
    inc(perm.lastfbaseid);
    updatepermid;
    newindexno:=perm.lastfbaseid;
  end;

  procedure idxadd(bidx:longint; x:integer);
  var bif:file of baseididx;
      bi:baseididx;
  begin
  assign(bif,adrv(systat.gfilepath)+'FBASEID.IDX');
  {$I-} reset(bif); {$I+}
  if (ioresult<>0) then begin
        displaybox('Error updating FBASEID.IDX',3000);
        exit;
  end;
  seek(bif,filesize(bif));
  bi.baseid:=bidx;
  bi.offset:=x;
  write(bif,bi);
  close(bif);
  end;

  procedure idxset(bidx:longint; x:integer);
  var bif:file of baseididx;
      bi:baseididx;
  begin
  assign(bif,adrv(systat.gfilepath)+'FBASEID.IDX');
  {$I-} reset(bif); {$I+}
  if (ioresult<>0) then begin
        displaybox('Error updating FBASEID.IDX',3000);
        exit;
  end;
  seek(bif,bidx);
  read(bif,bi);
  if (bi.baseid<>bidx) then begin
        displaybox('FBASEID.IDX is corrupted!',3000);
        exit;
  end;
  bi.offset:=x;
  seek(bif,bidx);
  write(bif,bi);
  close(bif);
  end;


  procedure dlbed(x:integer);
  var i,j:integer;
  begin
    if ((x>0) and (x<=maxulb)) then begin
      i:=x; {-1;}
      seek(ulf,i);
      read(ulf,memuboard);
      idxdelete(memuboard.baseid);
      if (i>=0) and (i<=filesize(ulf)-2) then
        for j:=i to filesize(ulf)-2 do begin
          seek(ulf,j+1); read(ulf,memuboard);
          seek(ulf,j); write(ulf,memuboard);
          idxset(memuboard.baseid,j);
        end;
      seek(ulf,filesize(ulf)-1); truncate(ulf);
      dec(maxulb);
      end;
  end;

function getcommenttype(oldtype:byte):byte;
var w2:windowrec;
    s2:string;
    cho:array[1..3] of string;
    cur:integer;
    c2:char;
    dn2:boolean;
begin
dn2:=FALSE;
cho[1]:=mln(systat.filearccomment[1],74);
cho[2]:=mln(systat.filearccomment[2],74);
cho[3]:=mln(systat.filearccomment[3],74);
setwindow(w2,1,9,78,15,3,0,8,'Archive Comment Files',TRUE);
for cur:=1 to 3 do begin
gotoxy(2,cur+1);
textcolor(7);
textbackground(0);
write(cho[cur]);
end;
cur:=oldtype;
repeat
gotoxy(2,cur+1);
textcolor(15);
textbackground(1);
write(cho[cur]);
while not(keypressed) do begin timeslice;
end;
c2:=readkey;
case c2 of
        #0:begin
                c2:=readkey;
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
                getcommenttype:=cur;
                dn2:=TRUE;
           end;
       #27:begin
                getcommenttype:=oldtype;
                dn2:=TRUE;
           end;
end;
until (dn2);
removewindow(w2);
end;

function getconfs:boolean;
var cf:file of confrec;
    cr:confrec;
    w3:windowrec;
    x3,curr,lr:integer;
    d3:boolean;
    c3:char;
    changed:boolean;

begin
d3:=false;
changed:=FALSE;
assign(cf,adrv(systat.gfilepath)+'CONFS.DAT');
{$I-} reset(cf); {$I+}
if (ioresult<>0) then begin
        displaybox('Error reading CONFS.DAT',3000);
        exit;
end;
read(cf,cr);
close(cf);
window(1,1,80,25);
gotoxy(1,25);
textcolor(14);
textbackground(0);
clreol;
write('Esc');
textcolor(7);
write('=Done ');
textcolor(14);
write('Space');
textcolor(7);
write('=Tag Conference');
setwindow(w3,5,6,75,22,3,0,8,'Select Conferences',TRUE);
for x3:=1 to 13 do begin
textcolor(7);
textbackground(0);
gotoxy(2,x3+1);
if (cr.fileconf[x3].active) then begin
        if (chr(x3+64) in memuboard.inconfs) then begin
                textcolor(14);
                textbackground(0);
                write('þ ');
                textcolor(7);
                textbackground(0);
        end else begin
                write('  ');
        end;
        cwrite(chr(x3+64)+' '+mln(cr.fileconf[x3].name,25));
end else begin
        write('  '+chr(x3+64)+mln('',26));
        memuboard.inconfs:=memuboard.inconfs-[chr(x3+64)];
end;
end;
for x3:=14 to 26 do begin
textcolor(7);
textbackground(0);
gotoxy(36,(x3 - 13)+1);
if (cr.fileconf[x3].active) then begin
        if (chr(x3+64) in memuboard.inconfs) then begin
                textcolor(14);
                textbackground(0);
                write('þ ');
                textcolor(7);
                textbackground(0);
        end else begin
                write('  ');
        end;
        cwrite(chr(x3+64)+' '+mln(cr.fileconf[x3].name,25));
end else begin
        write('  '+chr(x3+64)+mln('',26));
        memuboard.inconfs:=memuboard.inconfs-[chr(x3+64)];
end;
end;
lr:=0;
curr:=1;
repeat
gotoxy(4+(34*lr),curr+1);
if (cr.fileconf[curr+(13*lr)].active) then begin
textcolor(15);
textbackground(1);
write(chr(curr+(13*lr)+64)+' '+mln(stripcolor(cr.fileconf[curr+(13*lr)].name),25));
end else begin
textcolor(15);
textbackground(1);
write(chr(curr+(13*lr)+64)+' '+mln('',25));
end;
while not(keypressed) do begin timeslice; end;
c3:=readkey;
case c3 of
        #0:begin
                c3:=readkey;
                case c3 of
                        #72:begin
                                gotoxy(4+(34*lr),curr+1);
if (cr.fileconf[curr+(13*lr)].active) then begin
textcolor(7);
textbackground(0);
cwrite(chr(curr+(13*lr)+64)+' '+mln(cr.fileconf[curr+(13*lr)].name,25));
end else begin
textcolor(7);
textbackground(0);
cwrite(chr(curr+(13*lr)+64)+' '+mln('',25));
end;
                                dec(curr);
                                if (curr<1) then begin
                                        curr:=13;
                                        if (lr=0) then lr:=1 else lr:=0;
                                end;
                            end;
                        #75,#77:begin
                                gotoxy(4+(34*lr),curr+1);
if (cr.fileconf[curr+(13*lr)].active) then begin
textcolor(7);
textbackground(0);
cwrite(chr(curr+(13*lr)+64)+' '+mln(cr.fileconf[curr+(13*lr)].name,25));
end else begin
textcolor(7);
textbackground(0);
cwrite(chr(curr+(13*lr)+64)+' '+mln('',25));
end;
                        if (lr=0) then lr:=1 else lr:=0;
                        end;
                        #80:begin
                                gotoxy(4+(34*lr),curr+1);
if (cr.fileconf[curr+(13*lr)].active) then begin
textcolor(7);
textbackground(0);
cwrite(chr(curr+(13*lr)+64)+' '+mln(cr.fileconf[curr+(13*lr)].name,25));
end else begin
textcolor(7);
textbackground(0);
cwrite(chr(curr+(13*lr)+64)+' '+mln('',25));
end;
                                inc(curr);
                                if (curr>13) then begin
                                        curr:=1;
                                        if (lr=0) then lr:=1 else lr:=0;
                                end;
                            end;
                end;
           end;
       #32:begin
                if (cr.fileconf[curr+(13*lr)].active) then begin
                        if (chr(curr+(13*lr)+64) in memuboard.inconfs) then begin
                        memuboard.inconfs:=memuboard.inconfs-[chr(curr+(13*lr)+64)];
                        changed:=TRUE;
                        reindex:=TRUE;
                        gotoxy(2+(34*lr),curr+1);
                        textcolor(14);
                        textbackground(0);
                        write(' ');
                        end else begin
                        memuboard.inconfs:=memuboard.inconfs+[chr(curr+(13*lr)+64)];
                        changed:=TRUE;
                        reindex:=TRUE;
                        gotoxy(2+(34*lr),curr+1);
                        textcolor(14);
                        textbackground(0);
                        write('þ');
                        end;
                end;
           end;
       #27:begin
                if (memuboard.inconfs=[]) then begin
                        displaybox('You must have a Conference Tagged.',3000);
                        window(6,7,74,21);
                end else d3:=TRUE;
           end;
end;
until (d3);
removewindow(w3);
getconfs:=changed;
end;


  function getcd(oldcd:integer):integer;
  var firstlp,lp,lp2:listptr;
      x,cur,top:integer;
      rt:returntype;
      cdf:file of cdrec;
      cd:cdrec;
      w2:windowrec;
  begin
  assign(cdf,adrv(systat.gfilepath)+'CDS.DAT');
  {$I-} reset(cdf); {$I+}
  if (ioresult<>0) then begin
        displaybox('Error reading CDS.DAT!',3000);
        getcd:=0;
        exit;
  end;
                                new(lp);
                                seek(cdf,1);
                                read(cdf,cd);
                                lp^.p:=NIL;
                                lp^.list:=mln(cd.name+' ('+allcaps(cd.volumeid)+')',45);
                                firstlp:=lp;
                                while (not(eof(cdf))) do begin
                                read(cdf,cd);
                                new(lp2);
                                lp2^.p:=lp;
                                lp^.n:=lp2;
                                lp2^.list:=mln(cd.name+' ('+allcaps(cd.volumeid)+')',45);
                                lp:=lp2;
                                end;
                                close(cdf);
                                lp^.n:=NIL;
                                top:=1;
                                cur:=1;
                                for x:=1 to 100 do rt.data[x]:=-1;
                                x:=0;
                                repeat
                                lp:=firstlp;
                                listbox_tag:=FALSE;
                                listbox_insert:=FALSE;
                                listbox_delete:=FALSE;
                                listbox_move:=FALSE;
                                listbox(w2,rt,top,cur,lp,11,8,69,21,3,0,8,'Select CD-ROM Disk','File Base Editor',TRUE);
                                case rt.kind of
                                        0:begin
                                                c3:=chr(rt.data[100]);
                                                removewindow(w2);
                                                checkkey(c3);
                                                rt.data[100]:=-1;
                                                x:=-1;
                                        end;
                                        1:begin
                                        if (rt.data[1]<>-1) then x:=rt.data[1] else x:=0;
                                        end;
                                        2:begin
                                        x:=oldcd;
                                        end;
                                        else x:=0;
                                end;
                                until (x<>-1);
                                listbox_tag:=TRUE;
                                listbox_insert:=TRUE;
                                listbox_delete:=TRUE;
                                listbox_move:=TRUE;
                                                lp:=firstlp;
                                                while (lp<>NIL) do begin
                                                        lp2:=lp^.n;
                                                        dispose(lp);
                                                        lp:=lp2;
                                                end;
                                removewindow(w2);
                                getcd:=x;
                                
  end;

  function displaycd(x:integer):string;
  var cdf:file of cdrec;
      cd:cdrec;

  begin
  assign(cdf,adrv(systat.gfilepath)+'CDS.DAT');
  {$I-} reset(cdf); {$I+}
  if (ioresult<>0) then begin
        displaybox('Error reading CDS.DAT!',3000);
        displaycd:='None';
        exit;
  end;
  if (x>filesize(cdf)-1) or (x<1) then begin
        displaycd:='None';
        close(cdf);
        exit;
  end;
  seek(cdf,x);
  read(cdf,cd);
  close(cdf);
  displaycd:=mln(cd.name+' ('+allcaps(cd.volumeid)+')',45);
  end;

  procedure dlbei(x:integer);
  var i,j,k:integer;
  begin
    i:=x; {-1;}
    if ((i>=0) and (i<=filesize(ulf)) and (maxulb<maxuboards)) then begin
      for j:=filesize(ulf)-1 downto i do begin
        seek(ulf,j); read(ulf,memuboard);
        write(ulf,memuboard); { ...to next record }
        idxset(memuboard.baseid,j+1);
      end;
      with memuboard do begin
        name:='%080%[%150%Local%080%]%030% New Nexus File Base';
        filename:='NEWBASE';
        dlpath:=systat.filepath;
        maxfiles:=2000;
        password:='';
        arctype:=1; cmttype:=1;
        fbstat:=[];
        acs:='';
        ulacs:='';
        nameacs:='';
        tagtype:=0;
        defaulttags:=TRUE;
        cdrom:=false;
        cdul:=false;
        cdnum:=0;
        BaseID:=newindexno;
        TicArea:='';
        for k:=1 to sizeof(res) do res[k]:=0;
      end;
      seek(ulf,i); write(ulf,memuboard);
      idxadd(memuboard.BaseID,i);
      inc(maxulb);
      end;
  end;

  procedure dlbep(x,y:integer);
  var tempuboard:ulrec;
      i,j,k:integer;
  begin
    k:=y; if (y>x) then dec(y);
{    dec(x); dec(y);}
    seek(ulf,x); read(ulf,tempuboard);
    i:=x; if (x>y) then j:=-1 else j:=1;
    while (i<>y) do begin
      if (i+j<filesize(ulf)) then begin
        seek(ulf,i+j); read(ulf,memuboard);
        seek(ulf,i); write(ulf,memuboard);
        idxset(memuboard.baseid,i);
      end;
      inc(i,j);
    end;
    seek(ulf,y); write(ulf,tempuboard);
    idxset(tempuboard.baseid,y);
{    inc(x); inc(y);} {y:=k;}

  end;      

  function onoff(b:boolean):string;
  begin
  if (b) then onoff:='Yes' else onoff:='No ';
  end;


  function flagstate(fb:ulrec):astr;
  var s:astr;
  begin
    s:='';
    with fb do begin
      if (fbticbase in fbstat) then s:=s+'TicBase ';
      if (fbusegifspecs in fbstat) then s:=s+'GIFspecs ';
{      if (fbdirdlpath in fbstat) then s:=s+'NFB-in-DLPATH ';}
      if (fbnoratio in fbstat) then s:=s+'Free ';
      if (fbunhidden in fbstat) then s:=s+'Unhidden ';
      if (fballowofflinerequest in fbstat) then s:=s+'OfflineReq';
    end;
    if (s='') then s:='None';
    flagstate:=s;
  end;

        function getarc:boolean;
        var af:file of archiverrec;
            a:archiverrec;
    x:integer;
    top,cur:integer;
    firstlp,lp,lp2:listptr;
    rt:returntype;
    w2:windowrec;
    c:char;
    done:boolean;

procedure getlistbox;
var x:integer;
begin
                                new(lp);
                                lp^.p:=NIL;
                                lp^.list:=mln('---  Do not convert archives',40);
                                firstlp:=lp;
                                for x:=1 to 22 do begin
                                seek(af,x);
                                read(af,a);
                                new(lp2);
                                lp2^.p:=lp;
                                lp^.n:=lp2;
                                lp2^.list:=mln(a.extension,3)+'  '+mln(a.name,40);
                                lp:=lp2;
                                end;
                                lp^.n:=NIL;
end;


        begin
        assign(af,adrv(systat.gfilepath)+'ARCHIVER.DAT');
        {$I-} reset(af); {$I+}
        if (ioresult<>0) then begin
                displaybox('Error reading ARCHIVER.DAT!',3000);
                exit;
        end;
  listbox_goto:=FALSE;
  listbox_goto_offset:=0;
  listbox_insert:=FALSE;
  listbox_delete:=FALSE;
  listbox_tag:=FALSE;
  listbox_move:=FALSE;
  getlistbox;
                                top:=1;
                                cur:=1;
                                repeat
                                for x:=1 to 100 do rt.data[x]:=-1;
                                lp:=firstlp;
                                listbox(w2,rt,top,cur,lp,13,10,67,20,3,0,8,'Select Archiver','',TRUE);
                                case rt.kind of
                                        0:begin
                                                c:=chr(rt.data[100]);
                                                removewindow(w2);
                                                checkkey(c);
                                                rt.data[100]:=-1;
                                          end;
                                        1:begin
                                               memuboard.arctype:=rt.data[1]-1;
                                               getarc:=TRUE;
                                                                lp:=firstlp;
                                                                while (lp<>NIL) do begin
                                                                        lp2:=lp^.n;
                                                                        dispose(lp);
                                                                        lp:=lp2;
                                                                end;
                                                removewindow(w2);
                                                done:=TRUE;
                                          end;
                                        2:begin
                                                done:=TRUE;
                                                getarc:=FALSE;
                                                removewindow(w2);
                                                                lp:=firstlp;
                                                                while (lp<>NIL) do begin
                                                                        lp2:=lp^.n;
                                                                        dispose(lp);
                                                                        lp:=lp2;
                                                                end;
                                          end;
                                end;
                                until (done);


  listbox_insert:=TRUE;
  listbox_delete:=TRUE;
  listbox_tag:=TRUE;
  listbox_move:=TRUE;
  listbox_goto_offset:=0;

        close(af);
        end;



        function showarc(i:integer):string;
        var af:file of archiverrec;
            a:archiverrec;
        begin
        if (i=0) then begin
                showarc:='Do not convert archives';
                exit;
        end;
        assign(af,adrv(systat.gfilepath)+'ARCHIVER.DAT');
        {$I-} reset(af); {$I+}
        if (ioresult<>0) then begin
                displaybox('Error reading ARCHIVER.DAT!',3000);
                showarc:='None';
                exit;
        end;
        if (i>filesize(af)-1) then begin
                showarc:='None';
                close(af);
                exit;
        end;
        seek(af,i);
        read(af,a);
        if (a.active) then showarc:=a.name else
            showarc:='None';
        close(af);
        end;

        function showcmt(i:integer):string;
        begin
        if (i=0) then showcmt:='None' else showcmt:=systat.filearccomment[i];
        end;

  function showconferences:string;
  var c:char;
      s:string;
  begin
  s:='';
  for c:='A' to 'Z' do begin
        if (c in memuboard.inconfs) then s:=s+c;
  end;
  if (s='') then s:='NONE - Base MUST be in a conference!';
  showconferences:=s;
  end;

  function showtagtype:string;
  begin
        case memuboard.tagtype of
                0:showtagtype:='Default On ';
                1:showtagtype:='Default Off';
                2:showtagtype:='Mandatory  ';
                else showtagtype:='Error!     ';
        end;
  end;

  procedure dlbem;
  var f:file;
      dirinfo:searchrec;
      lastcdnum,xloaded,i,ii,ii4:integer;
      cddisp:string;
      c:char;
      s,s1,s2:astr;
      b,b2:byte;
      w2:windowrec;
      x,current:integer;
      choices:array[1..14] of string[30];
      desc:array[1..14] of string;
      autosave,done,arrows,editing,update,changed,nospace,ok:boolean;

      procedure getcdrom;
      var savecdnum:integer;
      begin
                                savecdnum:=memuboard.cdnum;
                                memuboard.cdnum:=getcd(memuboard.cdnum);
                                if (memuboard.cdnum<>savecdnum) then changed:=TRUE;
                                window(2,7,77,22);
                                if (memuboard.cdnum<>lastcdnum) then begin
                                        cddisp:=displaycd(memuboard.cdnum)
                                end;
                                textcolor(3);
                                textbackground(0);
                                gotoxy(21,13);
                                cwrite(cddisp);
      end;

  procedure getflags;
  var w2:windowrec;
      current,x10:integer;
      cho:array[1..5] of string[25];
      des:array[1..5] of string;
      dnt:boolean;
  begin
  dnt:=false;
  cho[1]:='FileEcho Base    :';
  cho[2]:='GIF Specs in Desc:';
  cho[3]:='All Files Free   :';
  cho[4]:='Unhidden         :';
  cho[5]:='Offline Requests :';
  des[1]:='Whether This is a FileEcho Attached File Base            ';
  des[2]:='Should Nexus import GIF Specifications into Descriptions?';
  des[3]:='Are all files able to be downloaded for free?            ';
  des[4]:='Should base be visible even when access not allowed?     ';
  des[5]:='Allow users to request offline files?                    ';
setwindow(w,27,9,53,17,3,0,8,'Flags',TRUE);
for x10:=1 to 5 do begin
textcolor(7);
textbackground(0);
gotoxy(2,x10+1);
write(cho[x10]);
end;
current:=1;
cursoron(FALSE);
gotoxy(21,2);
textcolor(3);
write(syn(fbticbase in memuboard.fbstat));
gotoxy(21,3);
textcolor(3);
write(syn(fbusegifspecs in memuboard.fbstat));
gotoxy(21,4);
textcolor(3);
write(syn(fbnoratio in memuboard.fbstat));
gotoxy(21,5);
textcolor(3);
write(syn(fbunhidden in memuboard.fbstat));
gotoxy(21,6);
textcolor(3);
write(syn(fballowofflinerequest in memuboard.fbstat));
done:=FALSE;
repeat
gotoxy(2,current+1);
textcolor(15);
textbackground(1);
write(cho[current]);
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
                                write(cho[current]);
                                dec(current);
                                if (current<1) then current:=5;
                        end;
                        #80:begin       
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(cho[current]);
                                inc(current);
                                if (current>5) then current:=1;
                        end;
              end;
           end;
           #13:begin
                changed:=TRUE;
                with memuboard do
                case current of
                        1:begin
                        if (fbticbase in memuboard.fbstat) then
                                memuboard.fbstat:=memuboard.fbstat-[fbticbase] else
                                memuboard.fbstat:=memuboard.fbstat+[fbticbase];
                                gotoxy(21,2);
                                textcolor(3);
                                textbackground(0);
                                write(syn(fbticbase in memuboard.fbstat));

if (fbticbase in memuboard.fbstat) then begin
  setwindow(w2,5,12,75,14,3,0,8,'',TRUE);
  gotoxy(2,1);
  textcolor(7);
  textbackground(0);
  write('FileEcho Tag Name : ');
  gotoxy(22,1);
  s:=memuboard.ticarea;
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
  infield_maxshow:=0;
  infielde(s,40);
  infield_escape_blank:=FALSE;
  infield_putatend:=FALSE;
  infield_insert:=TRUE;
  if (s<>memuboard.ticarea) then begin
        memuboard.ticarea:=s;
  end;
  if (memuboard.ticarea='') then begin
        memuboard.fbstat:=memuboard.fbstat-[fbticbase];
  end;
  removewindow(w2);
  window(28,10,52,16);
end;
                          end;
                        2:begin
                        if (fbusegifspecs in memuboard.fbstat) then
                                memuboard.fbstat:=memuboard.fbstat-[fbusegifspecs] else
                                memuboard.fbstat:=memuboard.fbstat+[fbusegifspecs];
                                gotoxy(21,3);
                                textcolor(3);
                                textbackground(0);
                                write(syn(fbusegifspecs in memuboard.fbstat));
                          end;
                        3:begin
                        if (fbnoratio in memuboard.fbstat) then
                                memuboard.fbstat:=memuboard.fbstat-[fbnoratio] else
                                memuboard.fbstat:=memuboard.fbstat+[fbnoratio];
                                gotoxy(21,4);
                                textcolor(3);
                                textbackground(0);
                                write(syn(fbnoratio in memuboard.fbstat));
                          end;
                        4:begin
                        if (fbunhidden in memuboard.fbstat) then
                                memuboard.fbstat:=memuboard.fbstat-[fbunhidden] else
                                memuboard.fbstat:=memuboard.fbstat+[fbunhidden];
                                gotoxy(21,5);
                                textcolor(3);
                                textbackground(0);
                                write(syn(fbunhidden in memuboard.fbstat));
                          end;
                        5:begin
                        if (fballowofflinerequest in memuboard.fbstat) then
                                memuboard.fbstat:=memuboard.fbstat-[fballowofflinerequest] else
                                memuboard.fbstat:=memuboard.fbstat+[fballowofflinerequest];
                                gotoxy(21,6);
                                textcolor(3);
                                textbackground(0);
                                write(syn(fballowofflinerequest in memuboard.fbstat));
                          end;
                 end;
            end;
            #27:dnt:=TRUE;
        end;
until (dnt);
removewindow(w);
window(2,8,77,22);
  end;

  begin
    xloaded:=-1;
    ii:=0;
    c:=' ';
    choices[1]:='Name             :';
    choices[2]:='Filename         :';
    choices[3]:='Path to Files    :';
    choices[4]:='Default Tag Type :';
    choices[5]:='Password         :';
    choices[6]:='Access String    :';
    choices[7]:='UL Access String :';
    choices[8]:='Maximum Files    :';
    choices[9]:='Achiver Type     :';
   choices[10]:='Comment Type     :';
   choices[11]:='Base on CD-ROM   :';
   choices[12]:='CD-ROM Disk #    :';
   choices[13]:='Base Flags       -';
   choices[14]:='Conferences      -';
   desc[1]:='Name of File Base displayed to Users                       ';
   desc[2]:='Filename of .NFB to store files in                         ';
   desc[3]:='Path where the Files in this base are kept                 ';
   desc[4]:='Default Tagged, Untagged or Mandatory                      ';
   desc[5]:='Password required to allow access to this base             ';
   desc[6]:='Access String to specify allowable access                  ';
   desc[7]:='Access String to specify allowable access to Upload        ';
   desc[8]:='Maximum Files allowed in this base                         ';
   desc[9]:='Archiver Type for this base                                ';
   desc[10]:='Comment File type for this base                            ';
   desc[11]:='Is this base located on a CD-ROM Disk?                     ';
   desc[12]:='Which CD-ROM Disk number is this located on?               ';
   desc[13]:='Flags determining characteristics of this base             ';
   desc[14]:='Conferences that this File Base is available in            ';
    editing:=FALSE;
    update:=TRUE;
    done:=FALSE;
    arrows:=FALSE;
    current:=1;
    setwindow2(w,1,6,78,23,3,0,8,'View File Base '+cstr(ii)+' (ID#'+cstr(memuboard.baseid)+') of '+cstr(maxulb),
                 'File Base Editor',TRUE);
    textcolor(7);
    textbackground(0);
    for x:=1 to 14 do begin
        gotoxy(2,x+1);
        write(choices[x]);
    end;
    lastcdnum:=0;
    while not(done) do begin
        if (xloaded<>ii) then begin
          seek(ulf,ii); read(ulf,memuboard);
          xloaded:=ii; changed:=FALSE;
        end;
        autosave:=FALSE;
        if (update) then begin
        if (editing) then begin
    setwindow3(w,1,6,78,23,3,0,8,'Edit File Base '+cstr(ii)+' (ID#'+cstr(memuboard.baseid)+') of '+cstr(maxulb),
                 'File Base Editor',TRUE);
        window(1,1,80,25);
        textcolor(14);
        textbackground(0);
        gotoxy(1,25);
        write('Esc');
        textcolor(7);
        write('=Quit Editing ');
        textcolor(14);
        write(desc[current]);
        window(2,7,77,22);
        end else begin
    setwindow3(w,1,6,78,23,3,0,8,'View File Base '+cstr(ii)+' (ID#'+cstr(memuboard.baseid)+') of '+cstr(maxulb),
                 'File Base Editor',TRUE);
        window(1,1,80,25);
        textcolor(14);
        textbackground(0);
        gotoxy(1,25);
        write('Esc');
        textcolor(7);
        write('=Exit ');
        textcolor(14);
        write('Enter');
        textcolor(7);
        write('=Edit ');
        textcolor(14);
        write('Ins');
        textcolor(7);
        write('=Insert ');
        textcolor(14);
        write('Del');
        textcolor(7);
        write('=Delete ');
        textcolor(14);
        write('Alt-E');
        textcolor(7);
        write('=Edit Files ');
        textcolor(14);
        write('Alt-L');
        textcolor(7);
        write('=List Bases');
        window(2,7,77,22);
        with memuboard do begin
        if not(cdrom) then cddisp:=mln('N/A',45);
        if (cdnum<>lastcdnum) then begin
                cddisp:=displaycd(cdnum)
        end;
        end;
        end;
        with memuboard do begin
        textcolor(7);
        textbackground(0);
        gotoxy(21,2);
        cwrite(mln(name,50));
        textcolor(3);
        textbackground(0);
        gotoxy(21,3);
        write(mln(filename,8));
        if ((ticarea<>'') and (fbticbase in memuboard.fbstat)) then write(mln(' (Fileecho: '+ticarea+')',42)) else
                write(mln(' ',42));
        gotoxy(21,4);
        write(mln(dlpath,40));
        gotoxy(21,5);
        write(showtagtype);
        gotoxy(21,6);
        write(mln(password,20));
        gotoxy(21,7);
        write(mln(acs,20));
        gotoxy(21,8);
        write(mln(ulacs,20));
        gotoxy(21,9);
        write(mln(cstr(maxfiles),5));
        gotoxy(21,10);
        write(mln(showarc(arctype),45));
        gotoxy(21,11);
        write(mln(showcmt(cmttype),45));
        gotoxy(21,12);
        write(onoff(cdrom));
        gotoxy(21,13);
        cwrite(cddisp);
        textcolor(3);
        textbackground(0);
        gotoxy(21,14);
        write(mln(flagstate(memuboard),45));
        gotoxy(21,15);
        write(mln(showconferences,26));
        end;
        update:=FALSE;
        end;
        current:=1;
        with memuboard do
          repeat
              arrows:=FALSE;
        if (update) then begin
        if (editing) then begin
    setwindow3(w,1,6,78,23,3,0,8,'Edit File Base '+cstr(ii)+' (ID#'+cstr(memuboard.baseid)+') of '+cstr(maxulb),
                 'File Base Editor',TRUE);
        window(1,1,80,25);
        textcolor(14);
        textbackground(0);
        gotoxy(1,25);
        write('Esc');
        textcolor(7);
        write('=Quit Editing ');
        textcolor(14);
        write(desc[current]);
        window(2,7,77,22);
        end else begin
    setwindow3(w,1,6,78,23,3,0,8,'View File Base '+cstr(ii)+' (ID#'+cstr(memuboard.baseid)+') of '+cstr(maxulb),
                 'File Base Editor',TRUE);
        window(1,1,80,25);
        textcolor(14);
        textbackground(0);
        gotoxy(1,25);
        write('Esc');
        textcolor(7);
        write('=Exit ');
        textcolor(14);
        write('Enter');
        textcolor(7);
        write('=Edit ');
        textcolor(14);
        write('Ins');
        textcolor(7);
        write('=Insert ');
        textcolor(14);
        write('Del');
        textcolor(7);
        write('=Delete ');
        textcolor(14);
        write('Alt-E');
        textcolor(7);
        write('=Edit Files ');
        textcolor(14);
        write('Alt-L');
        textcolor(7);
        write('=List Bases');
        window(2,7,77,22);
        end;
        end;
              if (editing) then begin
                textcolor(15);
                textbackground(1);
                gotoxy(2,current+1);
                write(choices[current]);
              end;
              cursoron(FALSE);
              while not(keypressed) do begin timeslice; end;
              c:=readkey;
              case c of
                #0:begin
                        c:=readkey;
                        checkkey(c);
                        case c of
                              #18:if not(editing) then begin
                                  filebasemanager(start_dir,'-B'+cstr(ii));
                                  window(2,8,77,22);
                              end;
                              #50:if not(editing) then begin
                                
  setwindow(w2,21,12,60,14,3,0,8,'',TRUE);
  gotoxy(2,1);
  textcolor(7);
  textbackground(0);
  s:='Move Before Which [1-'+mln(cstr(maxulb)+']',6)+' : ';
  write(s);
  gotoxy(31,1);
  s:='1';
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
  infield_clear:=TRUE;
  infielde(s,5);
  infield_escape_blank:=FALSE;
  infield_putatend:=FALSE;
  infield_insert:=TRUE;
  infield_clear:=FALSE;
  if (s='') then ii4:=0 else
  ii4:=value(s);
  if (ii4>=0) and (ii4<=maxulb) then begin
  if (s<>'') then begin
  dlbep(ii,ii4);
  if (ii<ii4) then ii:=ii4-1 else
  ii:=ii4;
  update:=TRUE;
  arrows:=TRUE;
                                        reindex:=TRUE;
                                        reindex2:=TRUE;
  end;
  end;
  removewindow(w2);
                                  end;
                              #68:if (editing) then begin
                                        editing:=FALSE;
                                        update:=TRUE;
                                        autosave:=TRUE;
                                        textcolor(7);
                                        textbackground(0);
                                        gotoxy(2,current+1);
                                        write(choices[current]);
                                        current:=1;
                              end;
                              #72:if (editing) then begin
                                        textcolor(7);
                                        textbackground(0);
                                        gotoxy(2,current+1);
                                        write(choices[current]);
                                        dec(current);
                                        if not(cdrom) and (current=12) then
                                        current:=11;
                                        if (current=0) then current:=14;
                                  end;
                              #75:if not(editing) then begin
                                      arrows:=TRUE; update:=TRUE;    
                                      if (ii>0) then dec(ii) else ii:=maxulb;
                                  end;
                              #77:if not(editing) then begin
                                      arrows:=TRUE; update:=TRUE;    
                                      if (ii<maxulb) then inc(ii) else ii:=0;
                                  end;
                              #80:if (editing) then begin
                                        textcolor(7);
                                        textbackground(0);
                                        gotoxy(2,current+1);
                                        write(choices[current]);
                                        inc(current);
                                        if not(cdrom) and (current=12) then
                                                current:=13;
                                        if (current=15) then current:=1;
                                  end;
                              #82:if not(editing) then begin
                                        inc(ii);
                                        dlbei(ii);
                                        reindex:=TRUE;
                                        reindex2:=TRUE;
                                        arrows:=TRUE;
                                        update:=TRUE;
                                  end;
                              #83:if not(editing) then begin
                                       if pynqbox('Delete this base? ') then begin
                                       if (pynqbox('Delete File Database also? ')) then begin
                                                assign(f,adrv(systat.filepath)+memuboard.filename+'.NFB');
                                                {$I-} erase(f); {$I+}
                                                if (ioresult<>0) then begin
                                                        displaybox('Error deleting '+adrv(systat.filepath)+memuboard.filename+
                                                                '.NFB',3000);
                                                end;
                                       end;
                                       reindex:=TRUE;
                                       reindex2:=TRUE;
                                       defaulttags:=TRUE;
                                       dlbed(ii);
                                       if (ii>maxulb) then ii:=maxulb;
                                       xloaded:=-1;
                                       arrows:=TRUE;
                                       update:=TRUE;
                                       end;
                                       window(2,7,77,22);
                                  end;
                        end;
                end;
              '0'..'9':begin

  setwindow(w2,27,12,54,14,3,0,8,'',TRUE);
  gotoxy(2,1);
  textcolor(7);
  textbackground(0);
  write('Goto File Base   : ');
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
  if (s='') then ii4:=0 else
  ii4:=value(s);
  if (ii4>=0) and (ii4<=maxulb) then begin
  if (s<>'') then begin
  ii:=ii4;
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
                  end else begin
                        infield_insert:=TRUE;
                        case current of
                                1:begin
                                        textcolor(7);
                                        textbackground(0);
                                        gotoxy(2,current+1);
                                        write(choices[current]);
                                        textcolor(9);
                                        gotoxy(19,current+1);
                                        write('>');
                                        gotoxy(21,current+1);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=false;
                                        infield_numbers_only:=FALSE;
                                        infield_maxshow:=50;
                                        infield_show_colors:=TRUE;
                                        infield_putatend:=TRUE;
                                        infield_insert:=TRUE;
                                        infield_clear:=TRUE;
                                        s:=name;
                                        infielde(s,70);
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        if (s<>name) then changed:=TRUE;
                                        name:=s;
                                end;
                                2:begin
                                        textcolor(7);
                                        textbackground(0);
                                        gotoxy(2,current+1);
                                        write(choices[current]);
                                        textcolor(9);
                                        gotoxy(19,current+1);
                                        write('>');
                                        gotoxy(21,current+1);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_insert:=TRUE;
                                        infield_allcaps:=TRUE;
                                        infield_numbers_only:=FALSE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        s:=filename;
                                        infielde(s,8);
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        if (s<>filename) then changed:=TRUE;
                                        filename:=s;
                                end;
                                3:begin
                                        textcolor(7);
                                        textbackground(0);
                                        gotoxy(2,current+1);
                                        write(choices[current]);
                                        textcolor(9);
                                        gotoxy(19,current+1);
                                        write('>');
                                        gotoxy(21,current+1);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=TRUE;
                                        infield_insert:=TRUE;
                                        infield_numbers_only:=FALSE;
                                        infield_put_slash:=TRUE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        infield_maxshow:=50;
                                        if (dlpath='') then s:=systat.filepath else
                                        s:=dlpath;
                                        infielde(s,79);
                                        infield_maxshow:=0;
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_put_slash:=FALSE;
                                        if (s<>dlpath) then begin
                                        changed:=TRUE;
                                        dlpath:=s;
                                        if not(memuboard.cdrom) then
                                        if not(existdir(bslash(FALSE,dlpath))) then
                                                if pynqbox('Create Directory? ') then begin
                                                        {$I-} mkdir(bslash(FALSE,dlpath)); {$I+}
                                                        if (ioresult<>0) then begin
                                                                displaybox('Unable to Create Directory.',3000);
                                                        end;
                                                end;
                                                window(2,7,77,22);
                                        end;
                                 end;
                                4:begin
                                        defaulttags:=TRUE;
                                        inc(tagtype);
                                        if (tagtype>2) then tagtype:=0;
                                        changed:=TRUE;
                                        gotoxy(21,current+1);
                                        textcolor(3);
                                        textbackground(0);
                                        write(showtagtype);
                                  end;
                                5:begin
                                        textcolor(7);
                                        textbackground(0);
                                        gotoxy(2,current+1);
                                        write(choices[current]);
                                        textcolor(9);
                                        gotoxy(19,current+1);
                                        write('>');
                                        gotoxy(21,current+1);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=TRUE;
                                        infield_numbers_only:=FALSE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        infield_insert:=TRUE;
                                        s:=password;
                                        infielde(s,20);
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        if (s<>password) then changed:=TRUE;
                                        password:=s;
                                end;
                                6:begin
                                        textcolor(7);
                                        textbackground(0);
                                        gotoxy(2,current+1);
                                        write(choices[current]);
                                        textcolor(9);
                                        gotoxy(19,current+1);
                                        write('>');
                                        gotoxy(21,current+1);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_insert:=TRUE;
                                        infield_allcaps:=TRUE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        infield_numbers_only:=FALSE;
                                        s:=acs;
                                        infielde(s,20);
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        if (s<>acs) then changed:=TRUE;
                                        acs:=s;
                                end;
                                7:begin
                                        textcolor(7);
                                        textbackground(0);
                                        gotoxy(2,current+1);
                                        write(choices[current]);
                                        textcolor(9);
                                        gotoxy(19,current+1);
                                        write('>');
                                        gotoxy(21,current+1);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=TRUE;
                                        infield_putatend:=TRUE;
                                        infield_clear:=TRUE;
                                        infield_numbers_only:=FALSE;
                                        infield_insert:=TRUE;
                                        s:=ulacs;
                                        infielde(s,20);
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        if (s<>ulacs) then changed:=TRUE;
                                        ulacs:=s;
                                end;
                                8:begin
                                        textcolor(7);
                                        textbackground(0);
                                        gotoxy(2,current+1);
                                        write(choices[current]);
                                        textcolor(9);
                                        gotoxy(19,current+1);
                                        write('>');
                                        gotoxy(21,current+1);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=TRUE;
                                        infield_numbers_only:=TRUE;
                                        infield_putatend:=TRUE;
                                        infield_insert:=TRUE;
                                        infield_clear:=TRUE;
                                        s:=cstr(maxfiles);
                                        infielde(s,5);
                                        infield_putatend:=FALSE;
                                        infield_clear:=FALSE;
                                        infield_numbers_only:=FALSE;
                                        if (s<>cstr(maxfiles)) then changed:=TRUE;
                                        maxfiles:=value(s);
                                end;
                                9:begin
                                        if (getarc) then changed:=TRUE;
                                        window(2,7,77,22);
                                        textcolor(3);
                                        gotoxy(21,10);
                                        write(mln(showarc(arctype),45));
                                end;
                                10:begin
                                        b2:=getcommenttype(memuboard.cmttype);
                                        if (b2<>cmttype) then begin
                                                cmttype:=b2;
                                                changed:=TRUE;
                                        end;
                                        window(2,7,77,22);
                                        textcolor(3);
                                        gotoxy(21,11);
                                        write(mln(showcmt(cmttype),45));
                                end;
                                11:begin
                                changed:=TRUE;
                                cdrom:=not(cdrom);
                                gotoxy(21,current+1);
                                textcolor(3);
                                textbackground(0);
                                write(onoff(cdrom));
                                if not(cdrom) then begin
                                cddisp:=mln('N/A',45);
                                cdnum:=0;
                                textcolor(3);
                                textbackground(0);
                                gotoxy(21,13);
                                cwrite(cddisp);
                                end else begin
                                        getcdrom;
                                        if (tagtype=0) then begin
                                                if pynqbox('Would you like this CD-ROM base untagged '+
                                                'for new users by default? ') then begin
                                                tagtype:=1;
                                                defaulttags:=TRUE;
                                                end;
                                        end;
                                        window(2,7,77,22);
                                end;
                                end;
                                12:begin
                                getcdrom;
                                end;
                                13:begin
                                getflags;
                                window(2,7,77,22);
        textcolor(3);
        textbackground(0);
        gotoxy(21,3);
        write(mln(filename,8));
        if ((ticarea<>'') and (fbticbase in memuboard.fbstat)) then write(mln(' (Fileecho: '+ticarea+')',42)) else
                write(mln(' ',42));
                                gotoxy(21,14);
                                textcolor(3);
                                textbackground(0);
                                write(mln(flagstate(memuboard),45));
                                end;
                                14:begin
                                        if (getconfs) then changed:=TRUE;
                                        window(2,7,77,22);
                                        gotoxy(21,15);
                                        write(mln(showconferences,26));
                                end;
                        end;
                  end;
              #27:if not(editing) then begin
                        done:=TRUE;
                  end else begin
                        editing:=FALSE;
                        update:=TRUE;
                        textcolor(7);
                        textbackground(0);
                        gotoxy(2,current+1);
                        write(choices[current]);
                        current:=1;
                end;
            end;
          until (arrows) or (done) or not(editing);
          if (changed) then begin
          if (autosave) then begin
             seek(ulf,xloaded); write(ulf,memuboard);
             autosave:=FALSE;
          end else
          if pynqbox('Save Changes? ') then begin
             seek(ulf,xloaded); write(ulf,memuboard);
             end else begin
             seek(ulf,xloaded); read(ulf,memuboard);
             end;
             window(2,7,77,22);
             changed:=FALSE;
          end;
        end;
        removewindow(w);
  end;

begin
  c:=#0;
  filemode:=66;
  assign(ulf,systat.gfilepath+'FBASES.DAT');
  {$I-} reset(ulf); {$I-}
  if (ioresult<>0) then begin
        displaybox('Error Opening FBASES.DAT. Create one with INSTALL.EXE.',4000);
        halt;
  end;
  reindex:=FALSE;
  reindex2:=FALSE;
  defaulttags:=FALSE;
  dlbem;
  close(ulf);
  if (reindex) then updatefconfs;
  if (reindex2) then updatefbaseidx;
  if (defaulttags) then createdefaulttags(2);
end;

end.
