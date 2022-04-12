(*****************************************************************************)
(*>                                                                         <*)
(*>  SYSOP8  .PAS -  Written by Eric Oman                                   <*)
(*>                                                                         <*)
(*>  SysOp functions: Message base editor                                   <*)
(*>                                                                         <*)
(*****************************************************************************)
{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R+,S+,V-}
unit sysop8;

interface

uses
  crt, dos, misc, myio, inptmisc,procspec, usertag,mkdos,mkstring;

procedure boardedit;
procedure updatemconfs;
procedure updatembaseidx;

implementation

const reindex:boolean=FALSE;
      reindex2:boolean=FALSE;
      defaulttags:boolean=FALSE;

var memboard2:boardrec;

procedure updatembaseidx;
var btf:file of basetagidx;
      bt:basetagidx;
      w2:windowrec;
      bf:file of boardrec;
      bif:file of baseidx;
      bi:baseidx;
      mb:boardrec;
  begin
  filemode:=66;
  assign(bf,adrv(systat.gfilepath)+'MBASES.DAT');
  {$I-} reset(bf); {$I+}
  if (ioresult<>0) then begin
        displaybox('Error opening MBASES.DAT',3000);
        exit;
  end;
  seek(bf,0);
  assign(btf,adrv(systat.gfilepath)+'MBTAGS.IDX');
  {$I-} rewrite(btf); {$I+}
  if (ioresult<>0) then begin
        displaybox('Error updating MBTAGS.IDX',3000);
        exit;
  end;
  displaybox3(11,w2,'Updating Message Base Tag Indexes...');
  while not(eof(bf)) do begin
        read(bf,mb);
        bt.nettagname:=mb.nettagname;
        write(btf,bt);
  end;
  close(btf);
  removewindow(w2);
  seek(bf,0);
  assign(bif,adrv(systat.gfilepath)+'MBASES.IDX');
  {$I-} rewrite(bif); {$I+}
  if (ioresult<>0) then begin
        displaybox('Error updating MBASES.IDX',3000);
        exit;
  end;
  displaybox3(11,w2,'Updating Message Base Indexes...');
  while not(eof(bf)) do begin
        bi.offset:=filepos(bf);
        read(bf,mb);
        bi.baseid:=mb.baseid;
        write(bif,bi);
  end;
  close(bif);
  close(bf);
  removewindow(w2);
  end;

procedure updatemconfs;
TYPE
booleanrec=
        RECORD
        bool:array[0..32767] of boolean;
        end;

var w2:windowrec;
    bf:file of boardrec;
    b:boardrec;
    boolf:file of booleanrec;
    bol:^booleanrec;
    x:integer;
    c4:char;
    baseavail:boolean;
    conff:file of confrec;
    conf:confrec;

begin
new(bol);
setwindow(w2,18,10,62,13,3,0,8,'Updating Message Conferences',TRUE);
filemode:=66;
assign(bf,adrv(systat.gfilepath)+'MBASES.DAT');
{$I-} reset(bf); {$I+}
if (ioresult<>0) then begin
        displaybox('Error opening MBASES.DAT',3000);
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
if (conf.msgconf[ord(c4)-64].active) then begin
        gotoxy(14,2);
        write(c4);
        assign(boolf,adrv(systat.gfilepath)+'MCONF'+c4+'.IDX');
        {$I-} rewrite(boolf); {$I+}
        if (ioresult<>0) then begin
                displaybox('Error creating '+adrv(systat.gfilepath)+'MCONF'+c4+'.IDX',3000);
                exit;
        end;
        baseavail:=FALSE;
        fillchar(bol^,sizeof(bol^),#0);
        write(boolf,bol^);
        x:=0;
        seek(bf,0);
        while not(eof(bf)) do begin
                seek(bf,x);
                read(bf,b);
                baseavail:=TRUE;
                if (c4 in b.inconfs) then begin
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
close(bf);
dispose(bol);
removewindow(w2);
end;

  procedure idxdelete(bidx:longint);
  var bif:file of baseididx;
      bi:baseididx;
  begin
  assign(bif,adrv(systat.gfilepath)+'MBASEID.IDX');
  {$I-} reset(bif); {$I+}
  if (ioresult<>0) then begin
        displaybox('Error updating MBASEID.IDX',3000);
        exit;
  end;
  seek(bif,bidx);
  read(bif,bi);
  if (bi.baseid<>bidx) then begin
        displaybox('MBASEID.IDX is corrupted!',3000);
        exit;
  end;
  bi.offset:=-1;
  seek(bif,bidx);
  write(bif,bi);
  close(bif);
  end;

  procedure idxadd(bidx:longint; x:integer);
  var bif:file of baseididx;
      bi:baseididx;
  begin
  assign(bif,adrv(systat.gfilepath)+'MBASEID.IDX');
  {$I-} reset(bif); {$I+}
  if (ioresult<>0) then begin
        displaybox('Error updating MBASEID.IDX',3000);
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
  assign(bif,adrv(systat.gfilepath)+'MBASEID.IDX');
  {$I-} reset(bif); {$I+}
  if (ioresult<>0) then begin
        displaybox('Error updating MBASEID.IDX',3000);
        exit;
  end;
  seek(bif,bidx);
  read(bif,bi);
  if (bi.baseid<>bidx) then begin
        displaybox('MBASEID.IDX is corrupted!',3000);
        exit;
  end;
  bi.offset:=x;
  seek(bif,bidx);
  write(bif,bi);
  close(bif);
  end;

procedure getflags;
var c:char;
    current:integer;
    choice:array[1..4] of string;
    done:boolean;

begin
choice[1]:='Real Names  :';
choice[2]:='Unhidden    :';
choice[3]:='Show 8-bit  :';
choice[4]:='Show Color  :';
setwindow(w,30,10,50,17,3,0,8,'Flags',TRUE);
textcolor(7);
textbackground(0);
gotoxy(2,2);
write(choice[1]);
gotoxy(2,3);
write(choice[2]);
gotoxy(2,4);
write(choice[3]);
gotoxy(2,5);
write(choice[4]);
current:=1;
cursoron(FALSE);
gotoxy(16,2);
textcolor(3);
write(syn(mbrealname in memboard.mbstat));
gotoxy(16,3);
textcolor(3);
write(syn(mbunhidden in memboard.mbstat));
gotoxy(16,4);
textcolor(3);
write(syn(not(mbfilter in memboard.mbstat)));
gotoxy(16,5);
textcolor(3);
write(syn(mbshowcolor in memboard.mbstat));
done:=FALSE;
repeat
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
                        #68:begin
                                done:=TRUE;
                            end;
                        #72:begin       
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choice[current]);
                                dec(current);
                                if (current<1) then current:=4;
                        end;
                        #80:begin       
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choice[current]);
                                inc(current);
                                if (current>4) then current:=1;
                        end;
              end;
           end;
           #13:begin
                with memboard do
                case current of
                        1:begin
                        if (mbrealname in memboard.mbstat) then
                                memboard.mbstat:=memboard.mbstat-[mbrealname] else
                                memboard.mbstat:=memboard.mbstat+[mbrealname];
                                gotoxy(16,2);
                                textcolor(3);
                                textbackground(0);
                                write(syn(mbrealname in memboard.mbstat));
                          end;
                        2:begin
                        if (mbunhidden in memboard.mbstat) then
                                memboard.mbstat:=memboard.mbstat-[mbunhidden] else
                                memboard.mbstat:=memboard.mbstat+[mbunhidden];
                                gotoxy(16,3);
                                textbackground(0);
                                textcolor(3);
                                write(syn(mbunhidden in memboard.mbstat));
                          end;
                        3:begin
                        if (mbfilter in memboard.mbstat) then
                                memboard.mbstat:=memboard.mbstat-[mbfilter] else
                                memboard.mbstat:=memboard.mbstat+[mbfilter];
                                gotoxy(16,4);
                                textcolor(3);
                                textbackground(0);
                                write(syn(not(mbfilter in memboard.mbstat)));
                          end;
                        4:begin
                        if (mbshowcolor in memboard.mbstat) then
                                memboard.mbstat:=memboard.mbstat-[mbshowcolor] else
                                memboard.mbstat:=memboard.mbstat+[mbshowcolor];
                                gotoxy(16,5);
                                textcolor(3);
                                textbackground(0);
                                write(syn(mbshowcolor in memboard.mbstat));
                          end;
                 end;
                 window(31,11,49,15);
            end;
            #27:done:=TRUE;
        end;
until (done);
removewindow(w);
end;

procedure getnetworkflags;
var c:char;
    current:integer;
    choice:array[1..3] of string;
    desc:array[1..3] of string;
    done:boolean;

begin
choice[1]:='Filter Kludge      :';
choice[2]:='Filter SEEN-BY     :';
choice[3]:='Filter Origin Line :';
desc[1]:='Filter Kludge lines when displaying messages        ';
desc[2]:='Filter SEEN-BY lines when displaying messages       ';
desc[3]:='Filter Origin Line when displaying messages         ';
setwindow(w,28,11,56,17,3,0,8,'Flags',TRUE);
textcolor(7);
textbackground(0);
gotoxy(2,2);
write(choice[1]);
gotoxy(2,3);
write(choice[2]);
gotoxy(2,4);
write(choice[3]);
current:=1;
cursoron(FALSE);
gotoxy(23,2);
textcolor(3);
write(syn(mbskludge in memboard.mbstat));
gotoxy(23,3);
textcolor(3);
write(syn(mbsseenby in memboard.mbstat));
gotoxy(23,4);
textcolor(3);
write(syn(mbsorigin in memboard.mbstat));
done:=FALSE;
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
window(29,12,55,16);
repeat
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
                        #68:begin
                                done:=TRUE;
                            end;
                        #72:begin       
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choice[current]);
                                dec(current);
                                if (current<1) then current:=3;
                        end;
                        #80:begin       
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choice[current]);
                                inc(current);
                                if (current>3) then current:=1;
                        end;
              end;
           end;
           #13:begin
                with memboard do
                case current of
                        1:begin

                        if (mbskludge in memboard.mbstat) then
                                memboard.mbstat:=memboard.mbstat-[mbskludge] else
                                memboard.mbstat:=memboard.mbstat+[mbskludge];
                                gotoxy(23,2);
                                textcolor(3);
                                textbackground(0);
                                write(syn(mbskludge in memboard.mbstat));
                          end;
                        2:begin
                        if (mbsseenby in memboard.mbstat) then
                                memboard.mbstat:=memboard.mbstat-[mbsseenby] else
                                memboard.mbstat:=memboard.mbstat+[mbsseenby];
                                gotoxy(23,3);
                                textbackground(0);
                                textcolor(3);
                                write(syn(mbsseenby in memboard.mbstat));
                          end;
                        3:begin
                        if (mbsorigin in memboard.mbstat) then
                                memboard.mbstat:=memboard.mbstat-[mbsorigin] else
                                memboard.mbstat:=memboard.mbstat+[mbsorigin];
                                gotoxy(23,4);
                                textcolor(3);
                                textbackground(0);
                                write(syn(mbsorigin in memboard.mbstat));
                          end;
                 end;
            end;
            #27:done:=TRUE;
        end;
until (done);
removewindow(w);
end;

procedure shownetworkinfo;
var s:string;
begin
s:='';
textcolor(7);
write('Filter: ');
if (mbskludge in memboard.mbstat) then s:=s+'Kludge ';
if (mbsseenby in memboard.mbstat) then s:=s+'Seen-By ';
if (mbsorigin in memboard.mbstat) then s:=s+'Origin';
if (s='') then s:='None';
textcolor(3);
write(s);
end;

procedure getcolors;
var c:char;
    current:integer;
    choice:array[1..6] of string;
    done:boolean;
    w3:windowrec;

begin
choice[1]:='Normal Text  ';
choice[2]:='Quoted Text  ';
choice[3]:='Tear Line    ';
choice[4]:='Origin Line  ';
choice[5]:='Tagline      ';
choice[6]:='Old Tear Line';
setwindow(w3,32,9,48,18,3,0,8,'Colors',TRUE);
textcolor(7);
textbackground(0);
gotoxy(2,2);
write(choice[1]);
gotoxy(2,3);
write(choice[2]);
gotoxy(2,4);
write(choice[3]);
gotoxy(2,5);
if (memboard.mbtype<>1) then textcolor(8);
write(choice[4]);
textcolor(7);
gotoxy(2,6);
write(choice[5]);
gotoxy(2,7);
write(choice[6]);
current:=1;
cursoron(FALSE);
done:=FALSE;
repeat
gotoxy(2,current+1);
if (current=4) and (memboard.mbtype<>1) then begin
textcolor(0);
textbackground(1);
end else begin
textcolor(15);
textbackground(1);
end;
write(choice[current]);
while not(keypressed) do begin timeslice; end;
c:=readkey;
case c of
        #0:begin
                c:=readkey;
                checkkey(c);
                case c of
                        #68:begin
                                done:=TRUE;
                            end;
                        #72:begin       { Up Arrow }
                                gotoxy(2,current+1);
                                textcolor(7);
                                if (current=4) and (memboard.mbtype<>1) then textcolor(8);
                                textbackground(0);
                                write(choice[current]);
                                dec(current);
                                if (current<1) then current:=6;
                        end;
                        #80:begin       { Down Arrow }
                                gotoxy(2,current+1);
                                textcolor(7);
                                if (current=4) and (memboard.mbtype<>1) then textcolor(8);
                                textbackground(0);
                                write(choice[current]);
                                inc(current);
                                if (current>6) then current:=1;
                        end;
              end;
           end;
           #13:begin
                with memboard do
                case current of
                        1:text_color:=getcolor(3,8,text_color,'Hello there!');
                        2:quote_color:=getcolor(3,8,quote_color,'GR> How are you doing?');
                        3:tear_color:=getcolor(3,8,tear_color,'--- Nexus '+ver);
                        4:if (memboard.mbtype=1) then origin_color:=getcolor(3,8,origin_color,' * Origin: Here (0:0/0)');
                        5:tag_color:=getcolor(3,8,tag_color,'... Wow! A tagline!');
                        6:oldtear_color:=getcolor(3,8,oldtear_color,'~~~ ivOMS 1.00');
                 end;
                 window(33,10,47,17);
            end;
            #27:done:=TRUE;
        end;
until (done);
removewindow(w3);
end;

procedure boardedit;
const ltype:integer=1;
var f1:file;
    s,subs:string;
    cnode2:integer;
    fidorf:file of fidorec;
    fidor:fidorec;
    y,x,i1,i2,ii,i3:integer;
    tfn:string;
    c:char;
    delt,done3,dp,dels,abort,next:boolean;
    top,cur:longint;
    rt:returntype;
    w2:windowrec;



function showadr(x:integer):string;
  var s:string;
  begin
        s:=cstr(fidor.address[x].zone)+':'+cstr(fidor.address[x].net)+'/'+
                cstr(fidor.address[x].node);
        if (fidor.address[x].point<>0) then s:=s+'.'+cstr(fidor.address[x].point);
  showadr:=s;
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
write('Enter');
textcolor(7);
write('=Tag Conference');
setwindow(w3,5,6,75,22,3,0,8,'Select Conferences',TRUE);
for x3:=1 to 13 do begin
textcolor(7);
textbackground(0);
gotoxy(2,x3+1);
if (cr.msgconf[x3].active) then begin
        if (chr(x3+64) in memboard.inconfs) then begin
                textcolor(14);
                textbackground(0);
                write('þ ');
                textcolor(7);
                textbackground(0);
        end else begin
                write('  ');
        end;
        cwrite(chr(x3+64)+' '+mln(cr.msgconf[x3].name,25));
end else begin
        write('  '+chr(x3+64)+mln('',26));
        memboard.inconfs:=memboard.inconfs-[chr(x3+64)];
end;
end;
for x3:=14 to 26 do begin
textcolor(7);
textbackground(0);
gotoxy(36,(x3 - 13)+1);
if (cr.msgconf[x3].active) then begin
        if (chr(x3+64) in memboard.inconfs) then begin
                textcolor(14);
                textbackground(0);
                write('þ ');
                textcolor(7);
                textbackground(0);
        end else begin
                write('  ');
        end;
        cwrite(chr(x3+64)+' '+mln(cr.msgconf[x3].name,25));
end else begin
        write('  '+chr(x3+64)+mln('',26));
        memboard.inconfs:=memboard.inconfs-[chr(x3+64)];
end;
end;
lr:=0;
curr:=1;
repeat
gotoxy(4+(34*lr),curr+1);
if (cr.msgconf[curr+(13*lr)].active) then begin
textcolor(15);
textbackground(1);
write(chr(curr+(13*lr)+64)+' '+mln(stripcolor(cr.msgconf[curr+(13*lr)].name),25));
end else begin
textcolor(15);
textbackground(1);
write(chr(curr+(13*lr)+64)+' '+mln('',25));
end;
while not(keypressed) do begin timeslice; end;
c3:=upcase(readkey);
case c3 of
        #0:begin
                c3:=readkey;
                case c3 of
                        #68:begin
                if (memboard.inconfs=[]) then begin
                        displaybox('You must have a Conference Tagged.',3000);
                        window(6,7,74,21);
                end else d3:=TRUE;
                            end;
                        #72:begin
                                gotoxy(4+(34*lr),curr+1);
if (cr.msgconf[curr+(13*lr)].active) then begin
textcolor(7);
textbackground(0);
cwrite(chr(curr+(13*lr)+64)+' '+mln(cr.msgconf[curr+(13*lr)].name,25));
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
if (cr.msgconf[curr+(13*lr)].active) then begin
textcolor(7);
textbackground(0);
cwrite(chr(curr+(13*lr)+64)+' '+mln(cr.msgconf[curr+(13*lr)].name,25));
end else begin
textcolor(7);
textbackground(0);
cwrite(chr(curr+(13*lr)+64)+' '+mln('',25));
end;
                        if (lr=0) then lr:=1 else lr:=0;
                        end;
                        #80:begin
                                gotoxy(4+(34*lr),curr+1);
if (cr.msgconf[curr+(13*lr)].active) then begin
textcolor(7);
textbackground(0);
cwrite(chr(curr+(13*lr)+64)+' '+mln(cr.msgconf[curr+(13*lr)].name,25));
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
       'A'..'M':begin
                if (cr.msgconf[ord(c3)-64].active) then begin
                        if (c3 in memboard.inconfs) then begin
                        memboard.inconfs:=memboard.inconfs-[c3];
                        changed:=TRUE;
                        reindex:=TRUE;                          
                        gotoxy(2,(ord(c3)-64)+1);
                        textcolor(14);
                        textbackground(0);
                        write(' ');
                        end else begin
                        memboard.inconfs:=memboard.inconfs+[c3];
                        changed:=TRUE;
                        reindex:=TRUE;
                        gotoxy(2,(ord(c3)-64)+1);
                        textcolor(14);
                        textbackground(0);
                        write('þ');
                        end;
                end;
       end;
       'N'..'Z':begin
                if (cr.msgconf[ord(c3)-64].active) then begin
                        if (c3 in memboard.inconfs) then begin
                        memboard.inconfs:=memboard.inconfs-[c3];
                        changed:=TRUE;
                        reindex:=TRUE;                          
                        gotoxy(36,(((ord(c3)-64)-13)+1));
                        textcolor(14);
                        textbackground(0);
                        write(' ');
                        end else begin
                        memboard.inconfs:=memboard.inconfs+[c3];
                        changed:=TRUE;
                        reindex:=TRUE;
                        gotoxy(36,(((ord(c3)-64)-13)+1));
                        textcolor(14);
                        textbackground(0);
                        write('þ');
                        end;
                end;
       end;
       #32:begin
                if (cr.msgconf[curr+(13*lr)].active) then begin
                        if (chr(curr+(13*lr)+64) in memboard.inconfs) then begin
                        memboard.inconfs:=memboard.inconfs-[chr(curr+(13*lr)+64)];
                        changed:=TRUE;
                        reindex:=TRUE;
                        gotoxy(2+(34*lr),curr+1);
                        textcolor(14);
                        textbackground(0);
                        write(' ');
                        end else begin
                        memboard.inconfs:=memboard.inconfs+[chr(curr+(13*lr)+64)];
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
                if (memboard.inconfs=[]) then begin
                        displaybox('You must have a Conference Tagged.',3000);
                        window(6,7,74,21);
                end else d3:=TRUE;
           end;
end;
until (d3);
removewindow(w3);
getconfs:=changed;
end;

procedure getaddress;
  var d:boolean;
      x,x2,xit:integer;
      s:string;
      current,column:integer;
        
        function aof(x:integer):string;
        begin
        if (memboard.address[x]) then aof:='þ' else aof:=' ';
        end;

  
  begin
  d:=FALSE;
  x:=1;
  setwindow(w,2,9,77,22,3,0,8,'Network Addresses',TRUE);
        textbackground(0);
        window(3,10,76,21);
        for x:=1 to 10 do begin
                gotoxy(2,x+1);
                textcolor(14);
                write(aof(x)+' ');
                textcolor(7);
                write(mln(cstr(x),2)+' ');
                textcolor(3);
                write(mln(showadr(x),18)+' ');
                textcolor(14);
                write(aof(x+10)+' ');
                textcolor(7);
                write(mln(cstr(x+10),2)+' ');
                textcolor(3);
                write(mln(showadr(x+10),18)+' ');
                textcolor(14);
                write(aof(x+20)+' ');
                textcolor(7);
                write(mln(cstr(x+20),2)+' ');
                textcolor(3);
                write(mln(showadr(x+20),18));
                end;                                    
  column:=0;
  current:=1;
  cursoron(FALSE);
  window(1,1,80,25);
  textcolor(14);
  textbackground(0);
  gotoxy(1,25);
  clreol;
  write('Esc');
  textcolor(7);
  write('=Exit ');
  textcolor(14);
  write('Enter');
  textcolor(7);
  if (memboard.mbtype=1) then
  write('=Select Address                                                ')
  else
  write('=Tag Address                                                   ');
  window(3,10,76,21);
  repeat
        gotoxy(2+(2+(column*24)),current+1);
        textcolor(15);
        textbackground(1);
        write(mln(cstr(current+(column*10)),2)+' '+mln(showadr(current+(column*10)),18));
        while not(keypressed) do begin timeslice; end;
        c:=readkey;
        case c of
                #0:begin
                        c:=readkey;
                        checkkey(c);
                        case c of
                                #68:begin
                                        d:=TRUE;
                                    end;
                                #72:begin {Up Arrow}
                                    gotoxy(2+(2+(column*24)),current+1);
                                    textcolor(7);
                                    textbackground(0);
                                    write(mln(cstr(current+(column*10)),2)+' ');
                                    textcolor(3);
                                    write(mln(showadr(current+(column*10)),18));
                                    dec(current);
                                    if (current<1) then current:=10;
                                    end;
                                #75:begin
                                    gotoxy(2+(2+(column*24)),current+1);
                                    textcolor(7);
                                    textbackground(0);
                                    write(mln(cstr(current+(column*10)),2)+' ');
                                    textcolor(3);
                                    write(mln(showadr(current+(column*10)),18));
                                    dec(column);
                                    if (column<0) then column:=2;
                                    end;
                                #77:begin
                                    gotoxy(2+(2+(column*24)),current+1);
                                    textcolor(7);
                                    textbackground(0);
                                    write(mln(cstr(current+(column*10)),2)+' ');
                                    textcolor(3);
                                    write(mln(showadr(current+(column*10)),18));
                                    inc(column);
                                    if (column>2) then column:=0;
                                    end;
                                #80:begin
                                    gotoxy(2+(2+(column*24)),current+1);
                                    textcolor(7);
                                    textbackground(0);
                                    write(mln(cstr(current+(column*10)),2)+' ');
                                    textcolor(3);
                                    write(mln(showadr(current+(column*10)),18));
                                    inc(current);
                                    if (current>10) then current:=1;
                                    end;
                        end;
                   end;
               #27:begin
                   d:=TRUE;
                   end;
               #13:begin
                   if (memboard.mbtype=1) then begin
                   d:=TRUE;
                        for x:=1 to 30 do begin
                                memboard.address[x]:=FALSE;
                        end;
                        memboard.address[current+(column*10)]:=TRUE;
                        textbackground(0);
        for x:=1 to 10 do begin
                gotoxy(2,x+1);
                textcolor(14);
                write(aof(x)+' ');
                textcolor(7);
                write(mln(cstr(x),2)+' ');
                textcolor(3);
                write(mln(showadr(x),18)+' ');
                textcolor(14);
                write(aof(x+10)+' ');
                textcolor(7);
                write(mln(cstr(x+10),2)+' ');
                textcolor(3);
                write(mln(showadr(x+10),18)+' ');
                textcolor(14);
                write(aof(x+20)+' ');
                textcolor(7);
                write(mln(cstr(x+20),2)+' ');
                textcolor(3);
                write(mln(showadr(x+20),18));
                end;                                    

                   end else begin
                        memboard.address[current+(column*10)]:=
                                        not(memboard.address[current+(column*10)]);
                        textbackground(0);
        for x:=1 to 10 do begin
                gotoxy(2,x+1);
                textcolor(14);
                write(aof(x)+' ');
                textcolor(7);
                write(mln(cstr(x),2)+' ');
                textcolor(3);
                write(mln(showadr(x),18)+' ');
                textcolor(14);
                write(aof(x+10)+' ');
                textcolor(7);
                write(mln(cstr(x+10),2)+' ');
                textcolor(3);
                write(mln(showadr(x+10),18)+' ');
                textcolor(14);
                write(aof(x+20)+' ');
                textcolor(7);
                write(mln(cstr(x+20),2)+' ');
                textcolor(3);
                write(mln(showadr(x+20),18));
                end;                                    

                   end;
                   end;
        end;
  until (d);
  removewindow(w);
end;


  function validtagname(tname:string):boolean;
  var btf:file of basetagidx;
      bt:basetagidx;
      isok:boolean;
  begin
  isok:=TRUE;
  assign(btf,adrv(systat.gfilepath)+'MBTAGS.IDX');
  {$I-} reset(btf); {$I+}
  if (ioresult<>0) then begin
        displaybox('Error reading MBTAGS.IDX',3000);
        exit;
  end;
  while not(eof(btf)) do begin
        read(btf,bt);
        if (allcaps(tname)=allcaps(bt.nettagname)) then begin
                close(btf);
                validtagname:=FALSE;
                isok:=FALSE;
                exit;
        end;
  end;
  close(btf);
  validtagname:=isok;
  end;

  function newindexno:longint;
  begin
    readpermid;
    inc(perm.lastmbaseid);
    updatepermid;
    newindexno:=perm.lastmbaseid;
  end;

  function restrb(x:integer):boolean;
  begin
  if (x=0) then restrb:=true else restrb:=false;
  end;

  function restrb2(x:integer):boolean;
  begin
  if (x<>1) then restrb2:=true else restrb2:=false;
  end;

  procedure bed(x:integer);
  var i,j:integer;
  begin
    if ((x>=0) and (x<=numboards)) then begin
      i:=x;
      seek(bf,i);
      read(bf,memboard);
      idxdelete(memboard.baseid);
      if (i>=0) and (i<=filesize(bf)-2) then
        for j:=i to filesize(bf)-2 do begin
          seek(bf,j+1); read(bf,memboard);
          seek(bf,j); write(bf,memboard);
          idxset(memboard.baseid,j);
        end;
      seek(bf,filesize(bf)-1); truncate(bf);
      dec(numboards);
    end;
  end;

  function newmemboard:boolean;
  var btf:file of msgbasetemp;
      mtmp:msgbasetemp;
      done:boolean;
      flp,l,l2:listptr;
      top8,cur8:integer;
      rt2:returntype;
      x,x2:integer;
      w6:windowrec;

procedure getlistbox;
var x:integer;
begin
                                read(btf,mtmp);
                                new(l);
                                l^.p:=NIL;
                                l^.list:=mln(cstr(0),3)+mln(mtmp.template,45);
                                flp:=l;
                                for x:=1 to 20 do begin
                                read(btf,mtmp);
                                new(l2);
                                l2^.p:=l;
                                l^.n:=l2;
                                l2^.list:=mln(cstr(x),3)+mln(mtmp.template,45);
                                l:=l2;
                                end;
                                l^.n:=NIL;
end;

  begin
      assign(btf,adrv(systat.gfilepath)+'MBASES.TMP');
      {$I-} reset(btf); {$I+}
      if (ioresult<>0) then begin
        displaybox('No Templates Available!  Please Create Templates!',3000);
        newmemboard:=FALSE;
        exit;
      end;
  listbox_goto:=FALSE;
  listbox_goto_offset:=0;
  listbox_insert:=FALSE;
  listbox_delete:=FALSE;
  listbox_tag:=FALSE;
  listbox_move:=FALSE;
  getlistbox;
                                top8:=1;
                                cur8:=1;
                                done:=FALSE;
                                repeat
                                for x:=1 to 100 do rt2.data[x]:=-1;
                                l:=flp;
                                listbox(w6,rt2,top8,cur8,l,13,8,67,22,3,0,8,'Message Base Templates','',TRUE);
                                case rt2.kind of
                                        0:begin
                                                c:=chr(rt2.data[100]);
                                                removewindow(w6);
                                                checkkey(c);
                                                rt2.data[100]:=-1;
                                          end;
                                        1:begin
                                               seek(btf,rt2.data[1]-1);
                                               read(btf,mtmp);
                                               fillchar(memboard2,sizeof(memboard2),#0);
      with memboard2 do begin
        name:=mtmp.name;
        filename:=mtmp.filename;
        mbtype:=mtmp.mbtype;
        msgpath:=mtmp.msgpath;
        acs:=mtmp.access;
        postacs:=mtmp.postaccess;
        maxmsgs:=mtmp.maxmsgs;
        password:=mtmp.accesskey;
        for x2:=1 to 30 do address[x2]:=mtmp.address[x2];
        group:=1;
        messagetype:=mtmp.messagetype;
        origin:=mtmp.origin;
        tagtype:=mtmp.tagtype;
        nameusage:=mtmp.nameusage;
        text_color:=mtmp.txtcolor;
        quote_color:=mtmp.quotecolor;
        tear_color:=mtmp.tearcolor;
        origin_color:=mtmp.origincolor;
        tag_color:=mtmp.tagcolor;
        oldtear_color:=mtmp.oldtearcolor;
        mbstat:=mtmp.mbflag;
        mbpriv:=mtmp.mbpriv;
        inconfs:=mtmp.inconfs;
      end;
                                                                l:=flp;
                                                                while (l<>NIL) do begin
                                                                        l2:=l^.n;
                                                                        dispose(l);
                                                                        l:=l2;
                                                                end;
                                                removewindow(w6);
                                                done:=TRUE;
                                                newmemboard:=TRUE;
                                          end;
                                        2:begin
                                                done:=TRUE;
                                                newmemboard:=FALSE;
                                                removewindow(w6);
                                                                l:=flp;
                                                                while (l<>NIL) do begin
                                                                        l2:=l^.n;
                                                                        dispose(l);
                                                                        l:=l2;
                                                                end;
                                          end;
                                end;
                                until (done);


  listbox_insert:=TRUE;
  listbox_delete:=TRUE;
  listbox_tag:=TRUE;
  listbox_move:=TRUE;
  close(btf);

  end;

  procedure bei(x:integer);
  var i,j,x2:integer;
  begin
    i:=x;
    if ((i>=0) and (i<=filesize(bf)) and (numboards<maxboards)) then begin
      if (i<=filesize(bf)-1) then begin
      for j:=filesize(bf)-1 downto i do begin
        seek(bf,j); read(bf,memboard);
        write(bf,memboard); { ...to next record }
        idxset(memboard.baseid,j+1);
      end;
      end;
      memboard:=memboard2;
      memboard.BaseID:=newindexno;
      memboard.nettagname:='MB'+cstr(memboard.baseid);
      memboard.msgid:=getdosdate;
      seek(bf,i); write(bf,memboard);
      idxadd(memboard.BaseID,i);
      inc(numboards);
    end;
  end;

  procedure bep(x,y:integer);
  var tempboard:boardrec;
      i,j,k:integer;
  begin
(*
            y   x
          012345678901234567890
   (k) 1> xxxxxxOxxx...........
   (j) 2> xxOxxxxxxx...........

            x   y
          012345678901234567890
   (k) 1> xxOxxxxxxx...........
   (j) 2> xxxxxxOxxx...........

           y  x         x  y
          0123456      0123456
          XxxxOXX      XOxxxXX
          X.xxxXX      Xxxx.XX
          XOxxxXX      XxxxOXX
          0312456      0231456

*)

    k:=y; if (y<x) then inc(y);
    seek(bf,x); read(bf,tempboard);
    i:=x; if (x>y) then j:=-1 else j:=1;
    while (i<>y) do begin
      if (i+j<filesize(bf)) then begin
        seek(bf,i+j); read(bf,memboard);
        seek(bf,i); write(bf,memboard);
        idxset(memboard.baseid,i);
      end;
      inc(i,j);
    end;
    seek(bf,y); write(bf,tempboard);
    idxset(tempboard.baseid,y);
    {y:=k;}

  end;

  procedure flagstate(mb:boardrec;x1:integer);
  var s:string;
  begin
    s:='';
    with mb do begin
      case x1 of
      1:begin
      textcolor(7);
      textbackground(0);
      write('Real: ');
      textcolor(3);
      if (mbrealname in mbstat) then s:='Yes' else s:='No ';
      write(s);
      end;
      2:begin
      textcolor(7);
      textbackground(0);
      write('Unhidden: ');
      textcolor(3);
      if (mbunhidden in mbstat) then s:='Yes' else s:='No ';
      write(s);
      end;
      3:begin
      textcolor(7);
      textbackground(0);
      write('8-bit: ');
      textcolor(3);
      if not(mbfilter in mbstat) then s:='Yes' else s:='No ';
      write(s);
      end;
      4:begin
      textcolor(7);
      textbackground(0);
      write('Color: ');
      textcolor(3);
      if (mbshowcolor in mbstat) then s:='Yes' else s:='No ';
      write(s);
      end;
      end;
    end;
  end;

  procedure fidoflags(mb:boardrec);
  var s:string;
  begin
    s:='';
    with mb do begin
      textcolor(7);
      textbackground(0);
      write('Strip Kludge: ');
      textcolor(3);
      if (mbskludge in mbstat) then s:='Yes' else s:='No ';
      write(s);
      textcolor(7);
      textbackground(0);
      write(' Strip Seen-by: ');
      textcolor(3);
      if (mbsseenby in mbstat) then s:='Yes' else s:='No ';
      write(s);
      textcolor(7);
      textbackground(0);
      write(' Strip Origin: ');
      textcolor(3);
      if (mbsorigin in mbstat) then s:='Yes' else s:='No ';
      write(s);
    end;
  end;

  function pp(mb:boardrec):string;
  var s:string;
  begin
        s:='';
        with mb do begin
                if (public in mbpriv) then s:='Public';
                if (private in mbpriv) then s:='Private';
                if (pubpriv in mbpriv) then s:='Public/Private';
        end;
  pp:=s;
  end;

 function aof2(x:byte):string;
 var s:string;
 begin
        if (memboard.origin=x) then s:='þ' else s:=' ';
 aof2:=s;
 end;

 procedure getorigin;
  var d:boolean;
      x:integer;
      current:byte;
      s:string;
  begin
  d:=FALSE;
  setwindow(w,10,1,70,23,3,0,8,'Origin Line',TRUE);
        for x:=1 to 20 do begin
                gotoxy(2,x+1);
                textcolor(14);
                textbackground(0);
                write(aof2(x)+' ');
                textcolor(7);
                write(mln(cstr(x),2)+' ');
                textcolor(3);
                write(mln(fidor.origins[x],50));
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
  write('Enter');
  textcolor(7);
  write('=Select Origin Line                                           ');
  window(11,2,69,22);
  current:=1;
  repeat
        gotoxy(4,current+1);
        textcolor(15);
        textbackground(1);
        write(mln(cstr(current),2)+' '+mln(fidor.origins[current],50));
        while not(keypressed) do begin timeslice; end;
        c:=readkey;
        case c of
                #0:begin
                        c:=readkey;
                        checkkey(c);
                        case c of
                                #68:begin
                                        d:=TRUE;
                                    end;
                                #72:begin {Up Arrow}
                                    gotoxy(4,current+1);
                                    textcolor(7);
                                    textbackground(0);
                                    write(mln(cstr(current),2)+' ');
                                    textcolor(3);
                                    write(mln(fidor.origins[current],50));
                                    dec(current);
                                    if (current<1) then current:=20;
                                    end;
                                #80:begin
                                    gotoxy(4,current+1);
                                    textcolor(7);
                                    textbackground(0);
                                    write(mln(cstr(current),2)+' ');
                                    textcolor(3);
                                    write(mln(fidor.origins[current],50));
                                    inc(current);
                                    if (current>20) then current:=1;
                                    end;
                        end;
                   end;
               #27:begin
                   d:=TRUE;
                   end;
               #13:begin
                   memboard.origin:=current;
        for x:=1 to 20 do begin
                gotoxy(2,x+1);
                textcolor(14);
                textbackground(0);
                write(aof2(x)+' ');
                textcolor(7);
                write(mln(cstr(x),2)+' ');
                textcolor(3);
                write(mln(fidor.origins[x],50));
                end;
                d:=TRUE;
               end;
            end;
  until (d);
  removewindow(w);
end;




  function Format(b:byte):string;
  var s:string;
  begin
  case b of
        1:s:='Squish      ';
        2:s:='JAM(mbp)(tm)';
        3:s:='.MSG        ';
  end;
  format:=s;
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

  function getaddr(zone,net,node,point:integer):string;
  begin
    if (zone=0) then getaddr:='None' else
      getaddr:=cstr(zone)+':'+cstr(net)+'/'+cstr(node)+'.'+cstr(point);
  end;



  procedure getbrdspec(var s:string);
  begin
    with memboard do
      s:=fexpand(systat.userpath+filename+'.DAT');
  end;

procedure getgateway;
var iff:file of internetrec;
    ir:internetrec;
    x:integer;
    top,cur:integer;
    firstlp,lp,lp2:listptr;
    rt:returntype;
    w2:windowrec;
    c:char;
    done:boolean;
      fidor:fidorec;
      fidof:file of fidorec;


procedure getlistbox;
var x:integer;
begin
                                new(lp);
                                lp^.p:=NIL;
                                lp^.list:=mln(cstr(1),3)+mln(ir.gateways[1].name,45);
                                firstlp:=lp;
                                for x:=2 to 30 do begin
                                new(lp2);
                                lp2^.p:=lp;
                                lp^.n:=lp2;
                                lp2^.list:=mln(cstr(x),3)+mln(ir.gateways[x].name,45);
                                lp:=lp2;
                                end;
                                lp^.n:=NIL;
end;

begin
assign(iff,adrv(systat.gfilepath)+'INTERNET.DAT');
{$I-} reset(iff); {$I+}
if (ioresult<>0) then begin
        displaybox('Error opening INTERNET.DAT!',2000);
        displaybox('Configure Gateways in Network Setup!',2000);
        exit;
end;
read(iff,ir);
close(iff);
done:=FALSE;
  assign(fidof,adrv(systat.gfilepath)+'NETWORK.DAT');
  {$I-} reset(fidof); {$I+}
  if (ioresult<>0) then begin
        displaybox('Error Opening NETWORK.DAT!',3000);
        exit;
  end;
  read(fidof,fidor);
  close(fidof);

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
                                listbox(w2,rt,top,cur,lp,13,8,67,22,3,0,8,'Internet Gateways','',TRUE);
                                case rt.kind of
                                        0:begin
                                                c:=chr(rt.data[100]);
                                                removewindow(w2);
                                                checkkey(c);
                                                rt.data[100]:=-1;
                                          end;
                                        1:begin
                                               if (ir.gateways[rt.data[1]].fromaddress in [1..30]) then begin
                                               for x:=1 to 30 do memboard.address[x]:=FALSE;
                                               memboard.address[ir.gateways[rt.data[1]].fromaddress]:=TRUE;
                                               memboard.gateway:=rt.data[1];
                                               end;
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
end;


procedure getnetwork;
var c:char;
    current:integer;
    choice:array[1..3] of string[20];
    desc:array[1..3] of string;
    done:boolean;
    w3:windowrec;

begin
if (memboard.mbtype=3) then
choice[1]:='Gateway      '
else
choice[1]:='Address Setup';
choice[2]:='Origin Line  ';
choice[3]:='Network Flags';
if (memboard.mbtype=1) then
desc[1]:='Address associated with this echomail message base'
else
if (memboard.mbtype=3) then
desc[1]:='Gateway with which this base is associated        '
else
desc[1]:='Which addresses are used by this netmail base     ';
if (memboard.mbtype=1) then
desc[2]:='Which origin line should be placed in messages    '
else
desc[2]:='Unused except in ECHOMAIL bases                   ';
desc[3]:='Network flags for this network message base       ';
setwindow(w3,25,10,41,16,3,0,8,'Network',TRUE);
textcolor(7);
textbackground(0);
gotoxy(2,2);
write(choice[1]);
gotoxy(2,3);
if (memboard.mbtype<>1) then textcolor(8);
write(choice[2]);
gotoxy(2,4);
textcolor(7);
write(choice[3]);
current:=1;
cursoron(FALSE);
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
window(26,11,40,15);
done:=FALSE;
repeat
gotoxy(2,current+1);
if (current=2) and (memboard.mbtype<>1) then begin
textcolor(0);
end else
textcolor(15);
textbackground(1);
write(choice[current]);
window(1,1,80,25);
gotoxy(10,25);
textcolor(14);
textbackground(0);
write(desc[current]);
window(26,11,40,15);
while not(keypressed) do begin timeslice; end;
c:=readkey;
case c of
        #0:begin
                c:=readkey;
                checkkey(c);
                case c of
                        #68:begin
                                done:=TRUE;
                            end;
                        #72:begin       { Up Arrow }
                                gotoxy(2,current+1);
                                textcolor(7);
                                if (current=2) and (memboard.mbtype<>1) then textcolor(8);
                                textbackground(0);
                                write(choice[current]);
                                dec(current);
                                if (current<1) then current:=3;
                        end;
                        #80:begin       { Down Arrow }
                                gotoxy(2,current+1);
                                textcolor(7);
                                if (current=2) and (memboard.mbtype<>1) then textcolor(8);
                                textbackground(0);
                                write(choice[current]);
                                inc(current);
                                if (current>3) then current:=1;
                        end;
              end;
           end;
           #13:begin
                with memboard do
                case current of
                        1:begin
                                if (memboard.mbtype=3) then
                                getgateway else
                                getaddress;
                          end;
                        2:if (memboard.mbtype=1) then getorigin;
                        3:getnetworkflags;
                 end;
                window(1,1,80,25);
                gotoxy(10,25);
                textcolor(14);
                textbackground(0);
                write(desc[current]);
                window(26,11,40,15);
            end;
            #27:done:=TRUE;
        end;
until (done);
removewindow(w3);
end;

  function showgateway(xx:byte):string;
  var iff:file of internetrec;
      ir:internetrec;
  begin
  assign(iff,adrv(systat.gfilepath)+'INTERNET.DAT');
  {$I-} reset(iff); {$I+}
  if (ioresult<>0) then begin
        showgateway:='Error!';
        exit;
  end;
  read(iff,ir);
  close(iff);
  if (xx<1) or (xx>30) then showgateway:='Error!' else
  showgateway:=ir.gateways[xx].name;
  end;

  function showconferences:string;
  var c:char;
      s:string;
  begin
  s:='';
  for c:='A' to 'Z' do begin
        if (c in memboard.inconfs) then s:=s+c;
  end;
  if (s='') then s:='NONE - Base MUST be in a conference!';
  showconferences:=s;
  end;

  procedure showcolors;

        procedure space;
        begin
        textcolor(7);
        textbackground(0);
        write(' ');
        end;

  begin
  textattr:=memboard.text_color;
  write('Text');
  space;
  textattr:=memboard.quote_color;
  write('Quote');
  space;
  textattr:=memboard.tag_color;
  write('Tag');
  space;
  textattr:=memboard.oldtear_color;
  write('OldTear');
  space;
  textattr:=memboard.tear_color;
  write('Tear');
  space;
  textattr:=memboard.origin_color;
  write('Origin');
  textcolor(7);
  textbackground(0);
  end;

  function showtagtype:string;
  begin
        case memboard.tagtype of
                0:showtagtype:='Default On ';
                1:showtagtype:='Default Off';
                2:showtagtype:='Mandatory  ';
                else showtagtype:='Error!     ';
        end;
  end;

  procedure loadmsgbasesforlist;
  var lf:file of listtemprec;
      l:listtemprec;
      ii2:longint;
  begin
                                displaybox2(w2,'Reading Message Base Files...');
                                tfn:=systat.temppath+hexlong(u_daynum(date+'  '+time))+'.LST';
                                assign(lf,tfn);
                                {$I-} rewrite(lf); {$I+}
                                if (ioresult<>0) then begin
                                   exit;
                                end;
                                seek(bf,0);
                                ii2:=0;
                                while (not(eof(bf))) do begin
                                     read(bf,memboard);
                                     l.list:=mln(cstr(ii2),5)+mln(memboard.name,45)+' %070% '+
                                       Btype(memboard.mbtype)+'   '+format2(memboard.messagetype);
                                     l.tagged:=false;
                                     write(lf,l);
                                     inc(ii2);
                                end;
                                close(lf);
                                removewindow(w2);
  end;

  procedure bem;
  var f:file;
      dirinfo:searchrec;
      s,s1,s2,s3,origtag:string;
      jt,current,ii4,ii3,ii2,x,i,i1,i2,xloaded:integer;
      c,c1,c3:char;
      b:byte;
      choices:array[1..14] of string[30];
      desc:array[1..14] of string;
      vtn,dn,editing,update,arrows,askaddress,autosave,changed,err,changed2:boolean;
      w3,w4:windowrec;

  begin
    arrows:=false;
    dn:=FALSE;
    update:=false;
    editing:=FALSE;
    c:=' '; xloaded:=-1;
    changed:=FALSE;
    autosave:=FALSE;
    textcolor(7);
    textbackground(0);
    savescreen(w3,1,1,80,24);
    current:=1;
    choices[1]:='Name                :';
    choices[2]:='Base Tag Name       :';
    choices[3]:='Base Type           :';
    choices[4]:='Message Format      :';
    choices[5]:='Message Base        :';
    choices[6]:='Default Tag Type    :';
    choices[7]:='Public/Private      :';
    choices[8]:='Password            :';
    choices[9]:='Access              :';
    choices[10]:='Post Access         :';
    choices[11]:='Base Flags          -';
    choices[12]:='Conferences         -';
    choices[13]:='Color Setup         -';
    choices[14]:='Network Setup       -';
    desc[1]:='Description of base shown to users         ';
    desc[2]:='Network/Blue Wave Tag Name                 ';
    desc[3]:='Local, Echomail, Netmail, Internet E-mail  ';
    desc[4]:='Message Format: JAM, Squish, .MSG (netmail)';
    desc[5]:='*.MSG - Path\  JAM/Squish - Path\Filename  ';
    desc[6]:='Default Tagged, Untagged or Mandatory      ';
    desc[7]:='Public, Private, or Public/Private         ';
    desc[8]:='Password to access base                    ';
    desc[9]:='Access String to Access/View this base     ';
   desc[10]:='Access String to Post in this base         ';
   desc[11]:='Real Names only, Unhidden, Strip 8-bit     ';
   desc[12]:='Conferences this Base is Available in      ';
   desc[13]:='Access base color setup menu               ';
   desc[14]:='Access base network setup menu             ';
        numboards:=filesize(bf)-1;
    if ((ii>=0) and (ii<=numboards)) then begin
        if (editing) then begin
        setwindow2(w,1,6,78,23,3,0,8,'Edit Message Base '+cstr(ii)+' (ID#'+cstr(memboard.baseid)+') of '+cstr(numboards),
                 'Message Base Editor',TRUE);
        window(1,1,80,25);
        gotoxy(1,25);
        textcolor(14);
        textbackground(0);
        clreol;
        write('Esc');
        textcolor(7);
        write('=Quit Editing ');
        textcolor(14);
        write('F1');
        textcolor(7);
        write('=Help ');
        textcolor(14);
        write(desc[current]);
        window(2,7,77,22);
        end else begin
        setwindow2(w,1,6,78,23,3,0,8,'View Message Base '+cstr(ii)+' (ID#'+cstr(memboard.baseid)+') of '+cstr(numboards),
                 'Message Base Editor',TRUE);
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
        write('View Message Base Configuration');
        clreol;
        window(2,7,77,22);
        end;
      while not(dn) do begin
        if (xloaded<>ii) then begin
          if (ii>numboards) then ii:=numboards;
          seek(bf,ii); read(bf,memboard);
          xloaded:=ii; changed:=FALSE;
          origtag:=memboard.nettagname;
        end;
        if (update) or (arrows) then begin
        if (editing) then begin
        setwindow3(w,1,6,78,23,3,0,8,'Edit Message Base '+cstr(ii)+' (ID#'+cstr(memboard.baseid)+') of '+cstr(numboards),
                 'Message Base Editor',TRUE);
        window(1,1,80,25);
        gotoxy(1,25);
        textcolor(14);
        textbackground(0);
        clreol;
        write('Esc');
        textcolor(7);
        write('=Quit Editing ');
        textcolor(14);
        write('F1');
        textcolor(7);
        write('=Help ');
        textcolor(14);
        write(desc[current]);
        window(2,7,77,22);

        end else begin
        setwindow3(w,1,6,78,23,3,0,8,'View Message Base '+cstr(ii)+' (ID#'+cstr(memboard.baseid)+') of '+cstr(numboards),
                 'Message Base Editor',TRUE);
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
        write('View Message Base Configuration');
        clreol;
        window(2,7,77,22);

        end;
        end;
        for x:=1 to 14 do begin
        textcolor(7);
        case x of
                14:if (memboard.mbtype=0) then textcolor(8);
        end;
        gotoxy(2,x+1);
        textbackground(0);
        write(choices[x]);
        end;
        with memboard do begin
                    gotoxy(24,2);
                    textcolor(7);
                    textbackground(0);
                    cwrite(mln(memboard.name,50));
                    gotoxy(24,3);
                    textcolor(3);
                    textbackground(0);
                    cwrite(mln(memboard.nettagname,50));
                    gotoxy(24,4);
                    textcolor(3);
                    textbackground(0);
                    case mbtype of
                        0:write('Local          ');
                        1:write('Echomail       ');
                        2:write('Netmail        ');
                        3:write('Internet E-mail');
                    end;
                    gotoxy(24,5);
                    write(format(messagetype));
                    if (messagetype=3) then begin
                    gotoxy(24,6);
                    write(mln(msgpath,40));
                    end else begin
                    textcolor(3);
                    gotoxy(24,6);
                    write(mln(msgpath+filename,40));
                    end;
                    textcolor(3);
                    gotoxy(24,7);
                    write(showtagtype);
                    gotoxy(24,8);
                    write(mln(pp(memboard),20));
                    gotoxy(24,9);
                    write(allcaps(mln(password,20)));
                    gotoxy(24,10);
                    write(mln(acs,20));
                    gotoxy(24,11);
                    write(mln(postacs,20));
                    gotoxy(24,12);
                    flagstate(memboard,1);
                    gotoxy(34,12);
                    flagstate(memboard,2);
                    gotoxy(48,12);
                    flagstate(memboard,3);
                    gotoxy(59,12);
                    flagstate(memboard,4);
                    gotoxy(24,13);
                    write(mln(showconferences,26));
                    gotoxy(24,14);
                    showcolors;
                    textcolor(7);
                    gotoxy(24,15);
                    clreol;
                    gotoxy(24,15);
                    case memboard.mbtype of
                        1:shownetworkinfo;
                        2:shownetworkinfo;
                        3:write(showgateway(memboard.gateway));
                        4:begin
                                textcolor(8);
                                write('N/A');
                          end;
                    end;
        end;


        with memboard do
          repeat
            if (c<>'?') then begin
              arrows:=false;
              if (update) then begin
              if (editing) then begin
        setwindow3(w,1,6,78,23,3,0,8,'Edit Message Base '+cstr(ii)+' (ID#'+cstr(memboard.baseid)+') of '+cstr(numboards),
                 'Message Base Editor',TRUE);
        window(1,1,80,25);
        gotoxy(1,25);
        textcolor(14);
        textbackground(0);
        clreol;
        write('Esc');
        textcolor(7);
        write('=Quit Editing ');
        textcolor(14);
        write('F1');
        textcolor(7);
        write('=Help ');
        textcolor(14);
        write(desc[current]);
        window(2,7,77,22);

              end else begin
        setwindow3(w,1,6,78,23,3,0,8,'View Message Base '+cstr(ii)+' (ID#'+cstr(memboard.baseid)+') of '+cstr(numboards),
                 'Message Base Editor',TRUE);
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
        write('View Message Base Configuration');
        clreol;
        window(2,7,77,22);

              end;
              end;
              update:=false;
            end;
            cursoron(FALSE);
            if (editing) then begin
                gotoxy(2,current+1);
                textcolor(15);
                textbackground(1);
                write(choices[current]);
        window(1,1,80,25);
        gotoxy(1,25);
        textcolor(14);
        textbackground(0);
        clreol;
        write('Esc');
        textcolor(7);
        write('=Quit Editing ');
        textcolor(14);
        write('Enter');
        textcolor(7);
        write('=Edit Field ');
        textcolor(14);
        write(desc[current]);
        window(2,7,77,22);
            end;
            while not(keypressed) do begin timeslice; end;
            c:=upcase(readkey);
            case c of
              #00:begin
                        c:=readkey;
                        checkkey(c);
                        case c of
                            #59:begin
                                if (editing) then
                                showhelp('nxsetup',14)
                                else
                                showhelp('nxsetup',13);
                             end;
                                #38:if not(editing) then begin
{        setwindow4(w,1,6,78,23,8,0,8,'View Message Base '+cstr(ii)+' (ID#'+cstr(memboard.baseid)+') of '+cstr(numboards),
                 'Message Base Editor',TRUE);}
                                listbox_goto:=TRUE;
                                listbox_goto_offset:=1;
                                loadmsgbasesforlist;
                                seek(bf,ii);
                                read(bf,memboard);
                                removewindow(w2);
                                done3:=false;
                                top:=ii+1;
                                cur:=ii+1;
                                ii4:=ii;
                                repeat
                                for x:=1 to 100 do rt.data[x]:=-1;
                                newlistbox(w2,rt,tfn,top,cur,3,9,76,22,3,0,8,'Message Bases','',TRUE);
                                textcolor(7);
                                textbackground(0);
                                case rt.kind of
                                        0:begin
                                                c3:=chr(rt.data[100]);
                                                removewindow(w2);
                                                checkkey(c3);
                                                rt.data[100]:=-1;
{        setwindow5(w,1,6,78,23,3,0,8,'View Message Base '+cstr(ii)+' (ID#'+cstr(memboard.baseid)+') of '+cstr(numboards),
                 'Message Base Editor',TRUE);}
                                          end;
                                        1:begin
                                                removewindow(w2);
                                                if (rt.data[1])<>-1 then begin
                                                                ii:=rt.data[1]-1;
                                                                done3:=TRUE;
                                                                arrows:=TRUE;
                                                                update:=TRUE;
                                                end;
                                          end;
                                        2:begin
                                                removewindow(w2);
                                                ii:=ii4;
                                                done3:=TRUE;
                                        end;
                                        3:begin
                                                removewindow(w2);
                                                textcolor(7);
                                                textbackground(0);
                                                if (newmemboard) then begin
                                                delt:=FALSE;
                                                setwindow(w2,27,11,53,13,3,0,8,'',TRUE);
                                                gotoxy(2,1);
                                                textcolor(7);
                                                textbackground(0);
                                                write('Insert how many  : ');
                                                gotoxy(21,1);
                                                s:='1';
                                                infield_inp_fgrd:=15;
                                                infield_inp_bkgd:=1;
                                                infield_out_fgrd:=3;
                                                infield_out_bkgd:=0;
                                                infield_allcaps:=false;
                                                infield_numbers_only:=TRUE;
                                                infielde(s,4);
                                                x:=value(s);
                                                ii3:=rt.data[1];
                                                removewindow(w2);
            if ((x>0) and (x<=(maxboards-(numboards+1))) and 
                        (numboards<maxboards)) then begin
              setwindow(w2,26,12,54,14,3,0,8,'',TRUE);
              for ii2:=1 to x do begin
                textcolor(12);
                textbackground(0);
                gotoxy(2,1);
                write('Inserting Base : '+mln(cstr(ii3+(ii2-1)),4));
              bei(ii3);
              end;
              removewindow(w2);
              if (cur>numboards) then begin
                cur:=numboards;
              end;
              delt:=TRUE;
            end;
                                                if (delt) then begin
                                                reindex:=TRUE;
                                                reindex2:=TRUE;
                                                loadmsgbasesforlist;
                                                end;
                                end;
                end;

                                        4:begin
                                                removewindow(w2);
                                                textcolor(7);
                                                textbackground(0);
                                                delt:=FALSE;
                                                for x:=1 to 100 do begin
                                                        if ((rt.data[x]-1)<>-1) and ((rt.data[x]-1)<>0) then begin
                                                                
                                                if ((rt.data[x]-1>=1) and (rt.data[x]-1<=numboards)) then begin
                                                dp:=true;
                                                seek(bf,rt.data[x]-1);
                                                read(bf,memboard);
                                                displaybox3(8,w2,'Message Base: '+stripcolor(memboard.name));
                                                if (dp) then dels:=pynqbox('Delete This Base? ') else dels:=true;
                                                if (dels) then begin
                                                        reindex:=TRUE;
                                                        reindex2:=TRUE;
                                                        defaulttags:=TRUE;
                                                        ii3:=rt.data[x]-1;
                                                        bed(ii3);
                                                        removewindow(w2);
                                                end;
                                                xloaded:=-1;
                                                update:=TRUE;
                                                delt:=TRUE;
                                                end;
                                                end;
                                                end;
                                                if (delt) then begin
                                                if (ii>numboards) then begin
                                                                ii:=numboards;
                                                end;
                                                if (cur>numboards) then begin
                                                        cur:=numboards;
                                                end;
                                                loadmsgbasesforlist;
                                                seek(bf,ii);
                                                read(bf,memboard);
                                                end;
                                end;
                                5:begin { Move }
                                if (rt.data[100]<>-1) then begin
                                        jt:=0;
                                        ii:=0;
                                        for x:=1 to 99 do begin
                                                if (rt.data[x]<>-1) and (rt.data[x]<>rt.data[100])
                                                        and (rt.data[x]<>0)
                                                        then begin
                                                        reindex:=TRUE;
                                                        reindex2:=TRUE;
                                                    bep(rt.data[x]-1-jt,rt.data[100]-1);
                                                    if (rt.data[x]>rt.data[100]) then begin
                                                        inc(rt.data[100]);
                                                        inc(ii);
                                                    end;
                                                    if (rt.data[x]<rt.data[100]) then begin
                                                        inc(jt);
                                                    end;
                                                    if (rt.data[x+1]>rt.data[100]) then jt:=0;
                                                end;
                                        end;
                                    end;
                                                ii:=(rt.data[100]-1) - ii;
                                                loadmsgbasesforlist;
                                                seek(bf,ii);
                                                read(bf,memboard);

                                end;
  end;
  until (done3);
                                arrows:=TRUE;
                                end;
                                #68:if (editing) then begin
                                            editing:=FALSE;
                                            update:=TRUE;
                                            arrows:=TRUE;
                                            autosave:=TRUE;
                                    end else dn:=TRUE;
                                #72:if (editing) then begin
                                        gotoxy(2,current+1);
                                        textcolor(7);
                                        textbackground(0);
                                        write(choices[current]);
                                        dec(current);
                                        if (memboard.mbtype=0) then begin
                                                if (current<1) then current:=13;
                                        end else begin
                                                if (current<1) then current:=14;
                                        end;
                                     end;
                                #75:begin
                                    if not(editing) then
                                    if (ii>0) then begin
                                        arrows:=true;
                                        dec(ii) 
                                    end else begin
                                        arrows:=true;
                                        ii:=numboards;
                                    end;
                                    end;
                                #77:begin
                                    if not(editing) then
                                    if (ii<numboards) then begin
                                        arrows:=true;
                                        inc(ii) 
                                    end else begin
                                        arrows:=true;
                                        ii:=0;
                                    end;
                                    end;
                                #80:if (editing) then begin
                                        gotoxy(2,current+1);
                                        textcolor(7);
                                        textbackground(0);
                                        write(choices[current]);
                                        inc(current);
                                        if (memboard.mbtype=0) then begin
                                                if (current>13) then current:=1;
                                        end else begin
                                                if (current>14) then current:=1;
                                        end;
                                   end;
                                #82:if not(editing) then begin
                                                if (newmemboard) then begin
                                                setwindow(w,27,11,53,13,3,0,8,'',TRUE);
                                                gotoxy(2,1);
                                                textcolor(7);
                                                textbackground(0);
                                                write('Insert how many  : ');
                                                gotoxy(21,1);
                                                s:='1';
                                                infield_inp_fgrd:=15;
                                                infield_inp_bkgd:=1;
                                                infield_out_fgrd:=3;
                                                infield_out_bkgd:=0;
                                                infield_allcaps:=false;
                                                infield_numbers_only:=TRUE;
                                                infield_insert:=FALSE;
                                                infield_escape_zero:=TRUE;
                                                infielde(s,4);
                                                infield_escape_zero:=FALSE;
                                                infield_insert:=TRUE;
                                                x:=value(s);
                                                ii3:=ii+1;
                                                removewindow(w);
                            if ((x>0) and (x<=(maxboards-(numboards+1))) and 
                                (numboards<maxboards)) then begin
                                      displaybox2(w,'Inserting base : '+mln(cstr(ii3+(ii2-1)),4));
                                      for ii2:=1 to x do begin
                                              reindex:=TRUE;
                                              reindex2:=TRUE;
                                              textcolor(12);
                                              textbackground(0);
                                              gotoxy(1,19);
                                              write(mln(cstr(ii3+(ii2-1)),4));
                                              bei(ii3);
                                      end;
                                      inc(ii);
                                      update:=TRUE;
                                      arrows:=TRUE;
                                      xloaded:=-1;
                                      removewindow(w);
                                      if (ii>numboards) then begin
                                                ii:=numboards;
                                      end;
                                    end;
                                    end;
                                end;
                                #83:if (ii<>0) and not(editing) then begin
                                                dels:=pynqbox('Delete this base? ');
                                                if (dels) then begin
                                                        ii3:=ii;
                                                        reindex:=TRUE;
                                                        reindex2:=TRUE;
                                                        bed(ii3);
                                                        update:=TRUE;
                                                        arrows:=TRUE;
                                                        xloaded:=-1;
                                                end;

                                end;
                        end;
              end;
              '0'..'9':begin

  setwindow(w2,27,12,54,14,3,0,8,'',TRUE);
  gotoxy(2,1);
  textcolor(7);
  textbackground(0);
  write('Goto Message Base: ');
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
  if (ii4>=0) and (ii4<=numboards) then begin
  if (s<>'') then begin
  ii:=ii4;
  seek(bf,ii);
  read(bf,memboard);
  update:=TRUE;
  arrows:=TRUE;
  end;
  end;
  removewindow(w2);

                        end;
              #13:begin
                        if not(editing) then begin
                                editing:=TRUE;
                                current:=1;
                                update:=TRUE;
                        end else
                        begin
                                case current of
                                1:begin
                                        gotoxy(2,current+1);
                                        textcolor(7);
                                        textbackground(0);
                                        write(choices[current]);
                                        gotoxy(22,current+1);
                                        textcolor(9);
                                        textbackground(0);
                                        write('>');
                                        gotoxy(24,current+1);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=false;
                                        infield_numbers_only:=FALSE;
                                        infield_maxshow:=50;
                                        infield_show_colors:=TRUE;
                                        s:=name;
                                        infielde(s,70);
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        if (s<>name) then changed:=TRUE;
                                        name:=s;
                                   end;
                                2:begin
                                        gotoxy(2,current+1);
                                        textcolor(7);
                                        textbackground(0);
                                        write(choices[current]);
                                        gotoxy(22,current+1);
                                        textcolor(9);
                                        textbackground(0);
                                        write('>');
                                        gotoxy(24,current+1);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=TRUE;
                                        infield_numbers_only:=FALSE;
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        s:=nettagname;
                                        infielde(s,50);
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        infield_allcaps:=FALSE;
                                        if (s<>nettagname) then begin
                                                changed:=TRUE;
                                                nettagname:=s;
                                                reindex2:=TRUE;
                                        end;
                                   end;
                                 3:begin
                                        inc(memboard.mbtype);
                                        changed:=TRUE;
                                        if (memboard.mbtype>3) then memboard.mbtype:=0;
                                                gotoxy(2,15);
                                                if (memboard.mbtype=0) then textcolor(8) else
                                                textcolor(7);
                                                textbackground(0);
                                                write(choices[14]);
                                                gotoxy(24,15);
                                                clreol;
                                                gotoxy(24,15);
                                                case memboard.mbtype of
                                                        1:shownetworkinfo;
                                                        2:shownetworkinfo;
                                                        3:write(showgateway(memboard.gateway));
                                                        4:begin
                                                                textcolor(8);
                                                                write('N/A');
                                                          end;
                                                end;
                                        gotoxy(24,4);
                                        textcolor(3);
                                        textbackground(0);
                                        case memboard.mbtype of
                                                0:write('Local          ');
                                                1:write('Echomail       ');
                                                2:write('Netmail        ');
                                                3:write('Internet E-mail');
                                        end;
                                        if ((memboard.mbtype=0) or (memboard.mbtype=1)) and
                                                (memboard.messagetype=3) then begin
                                                memboard.messagetype:=2;
                                                gotoxy(24,5);
                                                write(format(memboard.messagetype));
                                                textcolor(3);
                                                gotoxy(24,6);
                                                filename:='NEWBASE';
                                                reindex2:=TRUE;
                                                write(mln(allcaps(msgpath+filename),40));
                                        end;
                                 end;
                                 4:begin
                                        inc(memboard.messagetype);
                                        changed:=TRUE;
                                        if (memboard.mbtype<2) then begin
                                                if (memboard.messagetype>2) then memboard.messagetype:=1;
                                        end else begin
                                                if (memboard.messagetype>3) then memboard.messagetype:=1;
                                        end;
                                        if (memboard.messagetype=3) then begin
                                                gotoxy(24,6);
                                                filename:='';
                                                reindex2:=TRUE;
                                                write(mln(msgpath,40));
                                        end;
                                        if (memboard.messagetype<>3) then begin
                                                gotoxy(24,6);
                                                textcolor(3);
                                                write(mln(allcaps(msgpath+filename),40));
                                        end;
                                        gotoxy(24,5);
                                        textcolor(3);
                                        textbackground(0);
                                        write(format(memboard.messagetype));
                                 end;
                                 5:begin
                                        gotoxy(2,current+1);
                                        textcolor(7);
                                        textbackground(0);
                                        write(choices[current]);
                                        gotoxy(22,current+1);
                                        textcolor(9);
                                        textbackground(0);
                                        write('>');
                                        gotoxy(24,current+1);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=TRUE;
                                        infield_numbers_only:=FALSE;
                                        infield_maxshow:=40;
                                        infield_clear:=TRUE;
                                        infield_putatend:=TRUE;
                                        case memboard.messagetype of
                                                1,2:s:=msgpath+filename;
                                                  3:s:=msgpath;
                                        end;
                                        infielde(s,48);
                                        infield_maxshow:=0;
                                        infield_clear:=FALSE;
                                        infield_putatend:=FALSE;
                                        if (memboard.messagetype=3) then begin
                                                if (s<>msgpath) then begin
                                                changed:=TRUE;
                                                filename:='';
                                                msgpath:=s;
                      if (not existdir(bslash(FALSE,msgpath))) then begin
                        displaybox3(7,w4,msgpath+' Does Not Exist.');
                        if (pynqbox('Create Directory? ')) then begin
                          {$I-} mkdir(bslash(FALSE,msgpath)); {$I+}
                          if (ioresult<>0) then begin
                            displaybox('Error Creating Directory.',3000);
                          end;
                        end;
                        removewindow(w4);
                      end;
                                        window(2,7,77,22);
                                                end;
                                        end else begin
                                                if (s<>msgpath+filename) then begin
                                                changed:=TRUE;
                                                msgpath:=pathonly(s);
                      if (not existdir(bslash(FALSE,msgpath))) then begin
                        displaybox3(7,w4,msgpath+' Does Not Exist.');
                        if (pynqbox('Create Directory? ')) then begin
                          {$I-} mkdir(bslash(FALSE,msgpath)); {$I+}
                          if (ioresult<>0) then begin
                            displaybox('Error Creating Directory.',3000);
                          end;
                        end;
                        removewindow(w4);
                      end;
                                                filename:=fileonly(s);
                                                if (filename<>fileonly(s)) then begin
                                                        reindex2:=TRUE;
                                                        if pynqbox('Rename files? ') then begin
                                                        end;
                                                end;
                                                end;
                                        window(2,7,77,22);
                                        end;
                                 end;
                                 6:begin
                                        defaulttags:=TRUE;
                                        inc(memboard.tagtype);
                                        if (memboard.tagtype>2) then
                                                memboard.tagtype:=0;
                                        changed:=TRUE;
                                        gotoxy(24,current+1);
                                        textcolor(3);
                                        write(showtagtype);
                                 end;
                                 7:begin
                                 if not(memboard.mbtype=2) then begin
                                 changed:=TRUE;
                                 if (public in memboard.mbpriv) then begin
                                        memboard.mbpriv:=[private];
                                 end else
                                 if (private in memboard.mbpriv) then begin
                                        memboard.mbpriv:=[pubpriv];
                                 end else
                                 if (pubpriv in memboard.mbpriv) then begin
                                        memboard.mbpriv:=[public];
                                 end;
                                 gotoxy(24,current+1);
                                 textcolor(3);
                                 textbackground(0);
                                 write(mln(pp(memboard),20));

                                 end else begin
                                        changed:=TRUE;
                                        if (private in memboard.mbpriv) then changed:=FALSE;
                                        memboard.mbpriv:=[private];
                                 gotoxy(24,current+1);
                                 textcolor(3);
                                 textbackground(0);
                                 write(mln(pp(memboard),20));
                                 end;
                                 end;
                                 8:begin
                                        gotoxy(2,current+1);
                                        textcolor(7);
                                        textbackground(0);
                                        write(choices[current]);
                                        gotoxy(22,current+1);
                                        textcolor(9);
                                        textbackground(0);
                                        write('>');
                                        gotoxy(24,current+1);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=TRUE;
                                        infield_numbers_only:=FALSE;
                                        s:=password;
                                        infielde(s,20);
                                        if (s<>password) then changed:=TRUE;
                                        password:=s;
                                 end;
                                 9:begin
                                        gotoxy(2,current+1);
                                        textcolor(7);
                                        textbackground(0);
                                        write(choices[current]);
                                        gotoxy(22,current+1);
                                        textcolor(9);
                                        textbackground(0);
                                        write('>');
                                        gotoxy(24,current+1);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=TRUE;
                                        infield_numbers_only:=FALSE;
                                        s:=acs;
                                        infielde(s,20);
                                        if (s<>acs) then changed:=TRUE;
                                        acs:=s;
                                 end;
                                 10:begin
                                        gotoxy(2,current+1);
                                        textcolor(7);
                                        textbackground(0);
                                        write(choices[current]);
                                        gotoxy(22,current+1);
                                        textcolor(9);
                                        textbackground(0);
                                        write('>');
                                        gotoxy(24,current+1);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=TRUE;
                                        infield_numbers_only:=FALSE;
                                        s:=postacs;
                                        infielde(s,20);
                                        if (s<>postacs) then changed:=TRUE;
                                        postacs:=s;
                                 end;
                                 11:begin
                                        getflags;
                                        window(2,7,77,22);
                    gotoxy(24,12);
                    flagstate(memboard,1);
                    gotoxy(34,12);
                    flagstate(memboard,2);
                    gotoxy(48,12);
                    flagstate(memboard,3);
                    gotoxy(59,12);
                    flagstate(memboard,4);
                                        changed:=TRUE;
                                 end;
                                 12:begin
                                        changed2:=getconfs;
                                        if not(changed) then changed:=changed2;
                                        window(2,7,77,22);
                                        textcolor(7);
                                        textbackground(0);
                                    end;
                                 13:begin
                                        getcolors;
                                        window(2,7,77,22);
                                        changed:=TRUE;
                                 end;
                                 14:begin
                                        getnetwork;
                                        window(2,7,77,22);
                                        changed:=TRUE;
                                 end;
                                 end;
                             end;
                         end;
              #27:if (editing) then begin
                        arrows:=TRUE;
                        dn:=FALSE;
                        editing:=FALSE;
                  end else begin
                        dn:=TRUE;
                  end;
            end;
          until (dn) or (arrows);
          if (changed) then begin
          if not(autosave) then autosave:=pynqbox('Save changes? ');
          if (autosave) then begin
                if (memboard.msgpath='') and (memboard.filename='') then begin
                        displaybox('Must set base filename!',2000);
                        changed:=TRUE;
                        editing:=TRUE;
                        update:=TRUE;
                        arrows:=FALSE;
                        autosave:=FALSE;
                        dn:=FALSE;
                end else begin
                  if (not existdir(memboard.msgpath)) then begin
                        displaybox3(7,w4,memboard.msgpath+' does not exist.');
                        if (pynqbox('Create directory? ')) then begin
                          {$I-} mkdir(bslash(FALSE,memboard.msgpath)); {$I+}
                          if (ioresult<>0) then begin
                            displaybox('Error creating directory!',3000);
                          end;
                        end;
                        removewindow(w4);
                  end;
                  seek(bf,xloaded); write(bf,memboard);
                  idxset(memboard.baseid,xloaded);
                  changed:=FALSE;
                  editing:=FALSE;
                  update:=TRUE;
                  arrows:=TRUE;
                  autosave:=FALSE;
                  dn:=FALSE;
                end;
          end else begin
                  seek(bf,xloaded); read(bf,memboard);
                  changed:=FALSE;
                  editing:=FALSE;
                  update:=TRUE;
                  arrows:=TRUE;
                  autosave:=FALSE;
                  dn:=FALSE;
          end;
        end; 
      end;
      removewindow(w);
    end;
  removewindow(w3);
  end;

  procedure bepi(movewhich,movebefore:integer);
  var i,j:integer;
  begin
    i:=movewhich;
    if ((i>=1) and (i<=numboards)) then begin
      j:=movebefore;
      if ((j>=1) and (j<=numboards+1) and
          (j<>i) and (j<>i+1)) then begin
        bep(i,j);
      end;
    end;
  end;

begin
  c:=#0;
  filemode:=66;
  assign(fidorf,systat.gfilepath+'NETWORK.DAT');
  {$I-} reset(fidorf); {$I+}
  if (ioresult<>0) then begin
        displaybox('Error Opening NETWORK.DAT!',3000);
        exit;
  end;
  read(fidorf,fidor);
  close(fidorf);
  filemode:=66;
  assign(bf,systat.gfilepath+'MBASES.DAT');
  {$I-} reset(bf); {$I-}
  if (ioresult<>0) then begin
            displaybox('Error Opening MBASES.DAT. Create one with INSTALL.EXE.',4000);
            halt;
  end;
  ii:=0;
  reindex:=FALSE;
  reindex2:=FALSE;
  defaulttags:=FALSE;
  bem;
  close(bf);
  if (reindex) then updatemconfs;
  if (reindex2) then updatembaseidx;
  if (defaulttags) then createdefaulttags(1);
end;

end.

