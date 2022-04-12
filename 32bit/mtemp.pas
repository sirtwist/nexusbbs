(*****************************************************************************)
(*>                                                                         <*)
(*>  SYSOP8  .PAS -  Written by Eric Oman                                   <*)
(*>                                                                         <*)
(*>  SysOp functions: Message base editor                                   <*)
(*>                                                                         <*)
(*****************************************************************************)
{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R+,S+,V-}
unit mtemp;

interface

uses
  crt, dos, misc, myio, {inptmisc,}procspec;

procedure mbasetempedit;

implementation


var btf:file of MsgBaseTemp;
    mtmp:msgbasetemp;

procedure getflags;
var c:char;
    current:integer;
    choice:array[1..3] of string;
    done:boolean;

begin
choice[1]:='Real Names  :';
choice[2]:='Unhidden    :';
choice[3]:='Filter 8-bit:';
setwindow(w,30,10,50,16,3,0,8,'Flags',TRUE);
crt.textcolor(7);
textbackground(0);
gotoxy(2,2);
write(choice[1]);
gotoxy(2,3);
write(choice[2]);
gotoxy(2,4);
write(choice[3]);
current:=1;
cursoron(FALSE);
gotoxy(16,2);
crt.textcolor(3);
write(syn(mbrealname in mtmp.mbflag));
gotoxy(16,3);
crt.textcolor(3);
write(syn(mbunhidden in mtmp.mbflag));
gotoxy(16,4);
crt.textcolor(3);
write(syn(mbfilter in mtmp.mbflag));
done:=FALSE;
repeat
gotoxy(2,current+1);
crt.textcolor(15);
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
                                crt.textcolor(7);
                                textbackground(0);
                                write(choice[current]);
                                dec(current);
                                if (current<1) then current:=3;
                        end;
                        #80:begin
                                gotoxy(2,current+1);
                                crt.textcolor(7);
                                textbackground(0);
                                write(choice[current]);
                                inc(current);
                                if (current>3) then current:=1;
                        end;
              end;
           end;
           #13:begin
                with mtmp do
                case current of
                        1:begin
                        if (mbrealname in mtmp.mbflag) then
                                mtmp.mbflag:=mtmp.mbflag-[mbrealname] else
                                mtmp.mbflag:=mtmp.mbflag+[mbrealname];
                                gotoxy(16,2);
                                crt.textcolor(3);
                                textbackground(0);
                                write(syn(mbrealname in mtmp.mbflag));
                          end;
                        2:begin
                        if (mbunhidden in mtmp.mbflag) then
                                mtmp.mbflag:=mtmp.mbflag-[mbunhidden] else
                                mtmp.mbflag:=mtmp.mbflag+[mbunhidden];
                                gotoxy(16,3);
                                textbackground(0);
                                crt.textcolor(3);
                                write(syn(mbunhidden in mtmp.mbflag));
                          end;
                        3:begin
                        if (mbfilter in mtmp.mbflag) then
                                mtmp.mbflag:=mtmp.mbflag-[mbfilter] else
                                mtmp.mbflag:=mtmp.mbflag+[mbfilter];
                                gotoxy(16,4);
                                crt.textcolor(3);
                                textbackground(0);
                                write(syn(mbfilter in mtmp.mbflag));
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
crt.textcolor(7);
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
crt.textcolor(3);
write(syn(mbskludge in mtmp.mbflag));
gotoxy(23,3);
crt.textcolor(3);
write(syn(mbsseenby in mtmp.mbflag));
gotoxy(23,4);
crt.textcolor(3);
write(syn(mbsorigin in mtmp.mbflag));
done:=FALSE;
window(1,1,80,25);
gotoxy(1,25);
crt.textcolor(14);
textbackground(0);
clreol;
write('Esc');
crt.textcolor(7);
write('=Exit ');
crt.textcolor(14);
write(desc[current]);
window(29,12,55,16);
repeat
gotoxy(2,current+1);
crt.textcolor(15);
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
                                crt.textcolor(7);
                                textbackground(0);
                                write(choice[current]);
                                dec(current);
                                if (current<1) then current:=3;
                        end;
                        #80:begin
                                gotoxy(2,current+1);
                                crt.textcolor(7);
                                textbackground(0);
                                write(choice[current]);
                                inc(current);
                                if (current>3) then current:=1;
                        end;
              end;
           end;
           #13:begin
                with mtmp do
                case current of
                        1:begin

                        if (mbskludge in mtmp.mbflag) then
                                mtmp.mbflag:=mtmp.mbflag-[mbskludge] else
                                mtmp.mbflag:=mtmp.mbflag+[mbskludge];
                                gotoxy(23,2);
                                crt.textcolor(3);
                                textbackground(0);
                                write(syn(mbskludge in mtmp.mbflag));
                          end;
                        2:begin
                        if (mbsseenby in mtmp.mbflag) then
                                mtmp.mbflag:=mtmp.mbflag-[mbsseenby] else
                                mtmp.mbflag:=mtmp.mbflag+[mbsseenby];
                                gotoxy(23,3);
                                textbackground(0);
                                crt.textcolor(3);
                                write(syn(mbsseenby in mtmp.mbflag));
                          end;
                        3:begin
                        if (mbsorigin in mtmp.mbflag) then
                                mtmp.mbflag:=mtmp.mbflag-[mbsorigin] else
                                mtmp.mbflag:=mtmp.mbflag+[mbsorigin];
                                gotoxy(23,4);
                                crt.textcolor(3);
                                textbackground(0);
                                write(syn(mbsorigin in mtmp.mbflag));
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
crt.textcolor(7);
write('Filter: ');
if (mbskludge in mtmp.mbflag) then s:=s+'Kludge ';
if (mbsseenby in mtmp.mbflag) then s:=s+'Seen-By ';
if (mbsorigin in mtmp.mbflag) then s:=s+'Origin';
if (s='') then s:='None';
crt.textcolor(3);
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
crt.textcolor(7);
textbackground(0);
gotoxy(2,2);
write(choice[1]);
gotoxy(2,3);
write(choice[2]);
gotoxy(2,4);
write(choice[3]);
gotoxy(2,5);
if (mtmp.mbtype<>1) then crt.textcolor(8);
write(choice[4]);
crt.textcolor(7);
gotoxy(2,6);
write(choice[5]);
gotoxy(2,7);
write(choice[6]);
current:=1;
cursoron(FALSE);
done:=FALSE;
repeat
gotoxy(2,current+1);
if (current=4) and (mtmp.mbtype<>1) then begin
crt.textcolor(0);
textbackground(1);
end else begin
crt.textcolor(15);
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
                                crt.textcolor(7);
                                if (current=4) and (mtmp.mbtype<>1) then crt.textcolor(8);
                                textbackground(0);
                                write(choice[current]);
                                dec(current);
                                if (current<1) then current:=6;
                        end;
                        #80:begin       { Down Arrow }
                                gotoxy(2,current+1);
                                crt.textcolor(7);
                                if (current=4) and (mtmp.mbtype<>1) then crt.textcolor(8);
                                textbackground(0);
                                write(choice[current]);
                                inc(current);
                                if (current>6) then current:=1;
                        end;
              end;
           end;
           #13:begin
{                with mtmp do
                case current of
                        1:txtcolor:=getcolor(3,8,txtcolor,'Hello there!');
                        2:quotecolor:=getcolor(3,8,quotecolor,'GR> How are you doing?');
                        3:tearcolor:=getcolor(3,8,tearcolor,'--- Nexus '+ver);
                        4:if (mtmp.mbtype=1) then origincolor:=getcolor(3,8,origincolor,' * Origin: Here (0:0/0)');
                        5:tagcolor:=getcolor(3,8,tagcolor,'... Wow! A tagline!');
                        6:oldtearcolor:=getcolor(3,8,oldtearcolor,'~~~ ivOMS 1.00');
                 end;}
                 window(33,10,47,17);
            end;
            #27:done:=TRUE;
        end;
until (done);
removewindow(w3);
end;

procedure mbasetempedit;
const ltype:integer=1;
var f1:file;
    s,subs:string;
    cnode2:integer;
    fidorf:file of fidorec;
    fidor:fidorec;
    y,x,i1,i2,ii,i3:integer;
    c:char;
    delt,done3,dp,dels,abort,next:boolean;
    top,cur:integer;
    firstlp,lp,lp2:listptr;
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
crt.textcolor(14);
textbackground(0);
clreol;
write('Esc');
crt.textcolor(7);
write('=Done ');
crt.textcolor(14);
write('Enter');
crt.textcolor(7);
write('=Tag Conference');
setwindow(w3,5,6,75,22,3,0,8,'Select Conferences',TRUE);
for x3:=1 to 13 do begin
crt.textcolor(7);
textbackground(0);
gotoxy(2,x3+1);
if (cr.msgconf[x3].active) then begin
        if (chr(x3+64) in mtmp.inconfs) then begin
                crt.textcolor(14);
                textbackground(0);
                write('þ ');
                crt.textcolor(7);
                textbackground(0);
        end else begin
                write('  ');
        end;
        cwrite(chr(x3+64)+' '+mln(cr.msgconf[x3].name,25));
end else begin
        write('  '+chr(x3+64)+mln('',26));
        mtmp.inconfs:=mtmp.inconfs-[chr(x3+64)];
end;
end;
for x3:=14 to 26 do begin
crt.textcolor(7);
textbackground(0);
gotoxy(36,(x3 - 13)+1);
if (cr.msgconf[x3].active) then begin
        if (chr(x3+64) in mtmp.inconfs) then begin
                crt.textcolor(14);
                textbackground(0);
                write('þ ');
                crt.textcolor(7);
                textbackground(0);
        end else begin
                write('  ');
        end;
        cwrite(chr(x3+64)+' '+mln(cr.msgconf[x3].name,25));
end else begin
        write('  '+chr(x3+64)+mln('',26));
        mtmp.inconfs:=mtmp.inconfs-[chr(x3+64)];
end;
end;
lr:=0;
curr:=1;
repeat
gotoxy(4+(34*lr),curr+1);
if (cr.msgconf[curr+(13*lr)].active) then begin
crt.textcolor(15);
textbackground(1);
write(chr(curr+(13*lr)+64)+' '+mln(stripcolor(cr.msgconf[curr+(13*lr)].name),25));
end else begin
crt.textcolor(15);
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
                if (mtmp.inconfs=[]) then begin
                        displaybox('You must have a Conference Tagged.',3000);
                        window(6,7,74,21);
                end else d3:=TRUE;
                            end;
                        #72:begin
                                gotoxy(4+(34*lr),curr+1);
if (cr.msgconf[curr+(13*lr)].active) then begin
crt.textcolor(7);
textbackground(0);
cwrite(chr(curr+(13*lr)+64)+' '+mln(cr.msgconf[curr+(13*lr)].name,25));
end else begin
crt.textcolor(7);
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
crt.textcolor(7);
textbackground(0);
cwrite(chr(curr+(13*lr)+64)+' '+mln(cr.msgconf[curr+(13*lr)].name,25));
end else begin
crt.textcolor(7);
textbackground(0);
cwrite(chr(curr+(13*lr)+64)+' '+mln('',25));
end;
                        if (lr=0) then lr:=1 else lr:=0;
                        end;
                        #80:begin
                                gotoxy(4+(34*lr),curr+1);
if (cr.msgconf[curr+(13*lr)].active) then begin
crt.textcolor(7);
textbackground(0);
cwrite(chr(curr+(13*lr)+64)+' '+mln(cr.msgconf[curr+(13*lr)].name,25));
end else begin
crt.textcolor(7);
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
                        if (c3 in mtmp.inconfs) then begin
                        mtmp.inconfs:=mtmp.inconfs-[c3];
                        changed:=TRUE;
                        gotoxy(2,(ord(c3)-64)+1);
                        crt.textcolor(14);
                        textbackground(0);
                        write(' ');
                        end else begin
                        mtmp.inconfs:=mtmp.inconfs+[c3];
                        changed:=TRUE;
                        gotoxy(2,(ord(c3)-64)+1);
                        crt.textcolor(14);
                        textbackground(0);
                        write('þ');
                        end;
                end;
       end;
       'N'..'Z':begin
                if (cr.msgconf[ord(c3)-64].active) then begin
                        if (c3 in mtmp.inconfs) then begin
                        mtmp.inconfs:=mtmp.inconfs-[c3];
                        changed:=TRUE;
                        gotoxy(36,(((ord(c3)-64)-13)+1));
                        crt.textcolor(14);
                        textbackground(0);
                        write(' ');
                        end else begin
                        mtmp.inconfs:=mtmp.inconfs+[c3];
                        changed:=TRUE;
                        gotoxy(36,(((ord(c3)-64)-13)+1));
                        crt.textcolor(14);
                        textbackground(0);
                        write('þ');
                        end;
                end;
       end;
       #32:begin
                if (cr.msgconf[curr+(13*lr)].active) then begin
                        if (chr(curr+(13*lr)+64) in mtmp.inconfs) then begin
                        mtmp.inconfs:=mtmp.inconfs-[chr(curr+(13*lr)+64)];
                        changed:=TRUE;
                        gotoxy(2+(34*lr),curr+1);
                        crt.textcolor(14);
                        textbackground(0);
                        write(' ');
                        end else begin
                        mtmp.inconfs:=mtmp.inconfs+[chr(curr+(13*lr)+64)];
                        changed:=TRUE;
                        gotoxy(2+(34*lr),curr+1);
                        crt.textcolor(14);
                        textbackground(0);
                        write('þ');
                        end;
                end;
           end;
       #27:begin
                if (mtmp.inconfs=[]) then begin
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
        if (mtmp.address[x]) then aof:='þ' else aof:=' ';
        end;


  begin
  d:=FALSE;
  x:=1;
  setwindow(w,2,9,77,22,3,0,8,'Network Addresses',TRUE);
        textbackground(0);
        window(3,10,76,21);
        for x:=1 to 10 do begin
                gotoxy(2,x+1);
                crt.textcolor(14);
                write(aof(x)+' ');
                crt.textcolor(7);
                write(mln(cstr(x),2)+' ');
                crt.textcolor(3);
                write(mln(showadr(x),18)+' ');
                crt.textcolor(14);
                write(aof(x+10)+' ');
                crt.textcolor(7);
                write(mln(cstr(x+10),2)+' ');
                crt.textcolor(3);
                write(mln(showadr(x+10),18)+' ');
                crt.textcolor(14);
                write(aof(x+20)+' ');
                crt.textcolor(7);
                write(mln(cstr(x+20),2)+' ');
                crt.textcolor(3);
                write(mln(showadr(x+20),18));
                end;
  column:=0;
  current:=1;
  cursoron(FALSE);
  window(1,1,80,25);
  crt.textcolor(14);
  textbackground(0);
  gotoxy(1,25);
  clreol;
  write('Esc');
  crt.textcolor(7);
  write('=Exit ');
  crt.textcolor(14);
  write('Enter');
  crt.textcolor(7);
  if (mtmp.mbtype=1) then
  write('=Select Address                                                ')
  else
  write('=Tag Address                                                   ');
  window(3,10,76,21);
  repeat
        gotoxy(2+(2+(column*24)),current+1);
        crt.textcolor(15);
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
                                    crt.textcolor(7);
                                    textbackground(0);
                                    write(mln(cstr(current+(column*10)),2)+' ');
                                    crt.textcolor(3);
                                    write(mln(showadr(current+(column*10)),18));
                                    dec(current);
                                    if (current<1) then current:=10;
                                    end;
                                #75:begin
                                    gotoxy(2+(2+(column*24)),current+1);
                                    crt.textcolor(7);
                                    textbackground(0);
                                    write(mln(cstr(current+(column*10)),2)+' ');
                                    crt.textcolor(3);
                                    write(mln(showadr(current+(column*10)),18));
                                    dec(column);
                                    if (column<0) then column:=2;
                                    end;
                                #77:begin
                                    gotoxy(2+(2+(column*24)),current+1);
                                    crt.textcolor(7);
                                    textbackground(0);
                                    write(mln(cstr(current+(column*10)),2)+' ');
                                    crt.textcolor(3);
                                    write(mln(showadr(current+(column*10)),18));
                                    inc(column);
                                    if (column>2) then column:=0;
                                    end;
                                #80:begin
                                    gotoxy(2+(2+(column*24)),current+1);
                                    crt.textcolor(7);
                                    textbackground(0);
                                    write(mln(cstr(current+(column*10)),2)+' ');
                                    crt.textcolor(3);
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
                   if (mtmp.mbtype=1) then begin
                   d:=TRUE;
                        for x:=1 to 30 do begin
                                mtmp.address[x]:=FALSE;
                        end;
                        mtmp.address[current+(column*10)]:=TRUE;
                        textbackground(0);
        for x:=1 to 10 do begin
                gotoxy(2,x+1);
                crt.textcolor(14);
                write(aof(x)+' ');
                crt.textcolor(7);
                write(mln(cstr(x),2)+' ');
                crt.textcolor(3);
                write(mln(showadr(x),18)+' ');
                crt.textcolor(14);
                write(aof(x+10)+' ');
                crt.textcolor(7);
                write(mln(cstr(x+10),2)+' ');
                crt.textcolor(3);
                write(mln(showadr(x+10),18)+' ');
                crt.textcolor(14);
                write(aof(x+20)+' ');
                crt.textcolor(7);
                write(mln(cstr(x+20),2)+' ');
                crt.textcolor(3);
                write(mln(showadr(x+20),18));
                end;

                   end else begin
                        mtmp.address[current+(column*10)]:=
                                        not(mtmp.address[current+(column*10)]);
                        textbackground(0);
        for x:=1 to 10 do begin
                gotoxy(2,x+1);
                crt.textcolor(14);
                write(aof(x)+' ');
                crt.textcolor(7);
                write(mln(cstr(x),2)+' ');
                crt.textcolor(3);
                write(mln(showadr(x),18)+' ');
                crt.textcolor(14);
                write(aof(x+10)+' ');
                crt.textcolor(7);
                write(mln(cstr(x+10),2)+' ');
                crt.textcolor(3);
                write(mln(showadr(x+10),18)+' ');
                crt.textcolor(14);
                write(aof(x+20)+' ');
                crt.textcolor(7);
                write(mln(cstr(x+20),2)+' ');
                crt.textcolor(3);
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


  function restrb(x:integer):boolean;
  begin
  if (x=0) then restrb:=true else restrb:=false;
  end;

  function restrb2(x:integer):boolean;
  begin
  if (x<>1) then restrb2:=true else restrb2:=false;
  end;


  procedure flagstate(mb:msgbasetemp;x1:integer);
  var s:string;
  begin
    s:='';
    with mb do begin
      case x1 of
      1:begin
      crt.textcolor(7);
      textbackground(0);
      write('Real Names : ');
      crt.textcolor(3);
      if (mbrealname in mbflag) then s:='Yes' else s:='No ';
      write(s);
      end;
      2:begin
      crt.textcolor(7);
      textbackground(0);
      write('Unhidden : ');
      crt.textcolor(3);
      if (mbunhidden in mbflag) then s:='Yes' else s:='No ';
      write(s);
      end;
      3:begin
      crt.textcolor(7);
      textbackground(0);
      write('8-bit Filter: ');
      crt.textcolor(3);
      if (mbfilter in mbflag) then s:='Yes' else s:='No ';
      write(s);
      end;
      end;
    end;
  end;

  procedure fidoflags(mb:msgbasetemp);
  var s:string;
  begin
    s:='';
    with mb do begin
      crt.textcolor(7);
      textbackground(0);
      write('Strip Kludge: ');
      crt.textcolor(3);
      if (mbskludge in mbflag) then s:='Yes' else s:='No ';
      write(s);
      crt.textcolor(7);
      textbackground(0);
      write(' Strip Seen-by: ');
      crt.textcolor(3);
      if (mbsseenby in mbflag) then s:='Yes' else s:='No ';
      write(s);
      crt.textcolor(7);
      textbackground(0);
      write(' Strip Origin: ');
      crt.textcolor(3);
      if (mbsorigin in mbflag) then s:='Yes' else s:='No ';
      write(s);
    end;
  end;

  function pp(mb:msgbasetemp):string;
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
        if (mtmp.origin=x) then s:='þ' else s:=' ';
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
                crt.textcolor(14);
                textbackground(0);
                write(aof2(x)+' ');
                crt.textcolor(7);
                write(mln(cstr(x),2)+' ');
                crt.textcolor(3);
                write(mln(fidor.origins[x],50));
                end;
  window(1,1,80,25);
  gotoxy(1,25);
  crt.textcolor(14);
  textbackground(0);
  clreol;
  write('Esc');
  crt.textcolor(7);
  write('=Exit ');
  crt.textcolor(14);
  write('Enter');
  crt.textcolor(7);
  write('=Select Origin Line                                           ');
  window(11,2,69,22);
  current:=1;
  repeat
        gotoxy(4,current+1);
        crt.textcolor(15);
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
                                    crt.textcolor(7);
                                    textbackground(0);
                                    write(mln(cstr(current),2)+' ');
                                    crt.textcolor(3);
                                    write(mln(fidor.origins[current],50));
                                    dec(current);
                                    if (current<1) then current:=20;
                                    end;
                                #80:begin
                                    gotoxy(4,current+1);
                                    crt.textcolor(7);
                                    textbackground(0);
                                    write(mln(cstr(current),2)+' ');
                                    crt.textcolor(3);
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
                   mtmp.origin:=current;
        for x:=1 to 20 do begin
                gotoxy(2,x+1);
                crt.textcolor(14);
                textbackground(0);
                write(aof2(x)+' ');
                crt.textcolor(7);
                write(mln(cstr(x),2)+' ');
                crt.textcolor(3);
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
    with mtmp do
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
                                               mtmp.address[ir.gateways[rt.data[1]].fromaddress]:=TRUE;
                                               mtmp.gateway:=rt.data[1];
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
if (mtmp.mbtype=3) then
choice[1]:='Gateway      '
else
choice[1]:='Address Setup';
choice[2]:='Origin Line  ';
choice[3]:='Network Flags';
if (mtmp.mbtype=1) then
desc[1]:='Address associated with this echomail message base'
else
if (mtmp.mbtype=3) then
desc[1]:='Gateway with which this base is associated        '
else
desc[1]:='Which addresses are used by this netmail base     ';
if (mtmp.mbtype=1) then
desc[2]:='Which origin line should be placed in messages    '
else
desc[2]:='Unused except in ECHOMAIL bases                   ';
desc[3]:='Network flags for this network message base       ';
setwindow(w3,25,10,41,16,3,0,8,'Network',TRUE);
crt.textcolor(7);
textbackground(0);
gotoxy(2,2);
write(choice[1]);
gotoxy(2,3);
if (mtmp.mbtype<>1) then crt.textcolor(8);
write(choice[2]);
gotoxy(2,4);
crt.textcolor(7);
write(choice[3]);
current:=1;
cursoron(FALSE);
window(1,1,80,25);
gotoxy(1,25);
crt.textcolor(14);
textbackground(0);
clreol;
write('Esc');
crt.textcolor(7);
write('=Exit ');
crt.textcolor(14);
write(desc[current]);
window(26,11,40,15);
done:=FALSE;
repeat
gotoxy(2,current+1);
if (current=2) and (mtmp.mbtype<>1) then begin
crt.textcolor(0);
end else
crt.textcolor(15);
textbackground(1);
write(choice[current]);
window(1,1,80,25);
gotoxy(10,25);
crt.textcolor(14);
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
                                crt.textcolor(7);
                                if (current=2) and (mtmp.mbtype<>1) then crt.textcolor(8);
                                textbackground(0);
                                write(choice[current]);
                                dec(current);
                                if (current<1) then current:=3;
                        end;
                        #80:begin       { Down Arrow }
                                gotoxy(2,current+1);
                                crt.textcolor(7);
                                if (current=2) and (mtmp.mbtype<>1) then crt.textcolor(8);
                                textbackground(0);
                                write(choice[current]);
                                inc(current);
                                if (current>3) then current:=1;
                        end;
              end;
           end;
           #13:begin
                with mtmp do
                case current of
                        1:begin
                                if (mtmp.mbtype=3) then
                                getgateway else
                                getaddress;
                          end;
                        2:if (mtmp.mbtype=1) then getorigin;
                        3:getnetworkflags;
                 end;
                window(1,1,80,25);
                gotoxy(10,25);
                crt.textcolor(14);
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
        if (c in mtmp.inconfs) then s:=s+c;
  end;
  if (s='') then s:='NONE - Base MUST be in a conference!';
  showconferences:=s;
  end;

  procedure showcolors;

        procedure space;
        begin
        crt.textcolor(7);
        textbackground(0);
        write(' ');
        end;

  begin
  textattr:=mtmp.txtcolor;
  write('Text');
  space;
  textattr:=mtmp.quotecolor;
  write('Quote');
  space;
  textattr:=mtmp.tagcolor;
  write('Tag');
  space;
  textattr:=mtmp.oldtearcolor;
  write('OldTear');
  space;
  textattr:=mtmp.tearcolor;
  write('Tear');
  space;
  textattr:=mtmp.origincolor;
  write('Origin');
  crt.textcolor(7);
  textbackground(0);
  end;

  function showtagtype:string;
  begin
        case mtmp.tagtype of
                0:showtagtype:='Default On ';
                1:showtagtype:='Default Off';
                2:showtagtype:='Mandatory  ';
                else showtagtype:='Error!     ';
        end;
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
    crt.textcolor(7);
    textbackground(0);
    savescreen(w3,1,1,80,24);
    current:=1;
    choices[1]:='Template Description:';
    choices[2]:='Base Name           :';
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
    desc[1]:='Template Description                       ';
    desc[2]:='Message Base Name (Description)            ';
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
    if ((ii>=0) and (ii<=20)) then begin
        if (editing) then begin
        setwindow2(w,1,6,78,23,3,0,8,'Edit Message Base Template '+cstr(ii),
                 'Message Base Editor',TRUE);
        window(1,1,80,25);
        gotoxy(1,25);
        crt.textcolor(14);
        textbackground(0);
        clreol;
        write('Esc');
        crt.textcolor(7);
        write('=Quit Editing ');
        crt.textcolor(14);
        write('F1');
        crt.textcolor(7);
        write('=Help ');
        crt.textcolor(14);
        write(desc[current]);
        window(2,7,77,22);
        end else begin
        setwindow2(w,1,6,78,23,3,0,8,'View Message Base Template '+cstr(ii),
                 'Message Base Editor',TRUE);
        window(1,1,80,25);
        gotoxy(1,25);
        crt.textcolor(14);
        textbackground(0);
        clreol;
        write('Esc');
        crt.textcolor(7);
        write('=Exit ');
        crt.textcolor(14);
        write('F1');
        crt.textcolor(7);
        write('=Help ');
        crt.textcolor(14);
        write('View Message Base Configuration');
        clreol;
        window(2,7,77,22);
        end;
      while not(dn) do begin
        numboards:=20;
        if (xloaded<>ii) then begin
          if (ii>numboards) then ii:=numboards;
          seek(btf,ii); read(btf,mtmp);
          xloaded:=ii; changed:=FALSE;
          origtag:=mtmp.nettagname;
        end;
        if (update) or (arrows) then begin
        if (editing) then begin
        setwindow3(w,1,6,78,23,3,0,8,'Edit Message Base Template '+cstr(ii),
                 'Message Base Editor',TRUE);
        window(1,1,80,25);
        gotoxy(1,25);
        crt.textcolor(14);
        textbackground(0);
        clreol;
        write('Esc');
        crt.textcolor(7);
        write('=Quit Editing ');
        crt.textcolor(14);
        write('F1');
        crt.textcolor(7);
        write('=Help ');
        crt.textcolor(14);
        write(desc[current]);
        window(2,7,77,22);

        end else begin
        setwindow3(w,1,6,78,23,3,0,8,'View Message Base Template '+cstr(ii),
                 'Message Base Editor',TRUE);
        window(1,1,80,25);
        gotoxy(1,25);
        crt.textcolor(14);
        textbackground(0);
        clreol;
        write('Esc');
        crt.textcolor(7);
        write('=Exit ');
        crt.textcolor(14);
        write('F1');
        crt.textcolor(7);
        write('=Help ');
        crt.textcolor(14);
        write('View Message Base Configuration');
        clreol;
        window(2,7,77,22);

        end;
        end;
        for x:=1 to 14 do begin
        crt.textcolor(7);
        case x of
                14:if (mtmp.mbtype=0) then crt.textcolor(8);
        end;
        gotoxy(2,x+1);
        textbackground(0);
        write(choices[x]);
        end;
        with mtmp do begin
                    gotoxy(24,2);
                    crt.textcolor(7);
                    textbackground(0);
                    cwrite(mln(mtmp.template,50));
                    gotoxy(24,3);
                    crt.textcolor(3);
                    textbackground(0);
                    cwrite(mln(mtmp.name,50));
                    gotoxy(24,4);
                    crt.textcolor(3);
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
                    crt.textcolor(3);
                    gotoxy(24,6);
                    write(mln(msgpath+filename,40));
                    end;
                    crt.textcolor(3);
                    gotoxy(24,7);
                    write(showtagtype);
                    gotoxy(24,8);
                    write(mln(pp(mtmp),20));
                    gotoxy(24,9);
                    write(allcaps(mln(accesskey,20)));
                    gotoxy(24,10);
                    write(mln(access,20));
                    gotoxy(24,11);
                    write(mln(postaccess,20));
                    gotoxy(24,12);
                    flagstate(mtmp,1);
                    gotoxy(42,12);
                    flagstate(mtmp,2);
                    gotoxy(58,12);
                    flagstate(mtmp,3);
                    gotoxy(24,13);
                    write(mln(showconferences,26));
                    gotoxy(24,14);
                    showcolors;
                    crt.textcolor(7);
                    gotoxy(24,15);
                    clreol;
                    gotoxy(24,15);
                    case mtmp.mbtype of
                        1:shownetworkinfo;
                        2:shownetworkinfo;
                        3:write(showgateway(mtmp.gateway));
                        4:begin
                                crt.textcolor(8);
                                write('N/A');
                          end;
                    end;
        end;


        with mtmp do
          repeat
            if (c<>'?') then begin
              arrows:=false;
              if (update) then begin
              if (editing) then begin
        setwindow3(w,1,6,78,23,3,0,8,'Edit Message Base Template '+cstr(ii),
                 'Message Base Editor',TRUE);
        window(1,1,80,25);
        gotoxy(1,25);
        crt.textcolor(14);
        textbackground(0);
        clreol;
        write('Esc');
        crt.textcolor(7);
        write('=Quit Editing ');
        crt.textcolor(14);
        write('F1');
        crt.textcolor(7);
        write('=Help ');
        crt.textcolor(14);
        write(desc[current]);
        window(2,7,77,22);

              end else begin
        setwindow3(w,1,6,78,23,3,0,8,'View Message Base Template '+cstr(ii),
                 'Message Base Editor',TRUE);
        window(1,1,80,25);
        gotoxy(1,25);
        crt.textcolor(14);
        textbackground(0);
        clreol;
        write('Esc');
        crt.textcolor(7);
        write('=Exit ');
        crt.textcolor(14);
        write('F1');
        crt.textcolor(7);
        write('=Help ');
        crt.textcolor(14);
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
                crt.textcolor(15);
                textbackground(1);
                write(choices[current]);
        window(1,1,80,25);
        gotoxy(1,25);
        crt.textcolor(14);
        textbackground(0);
        clreol;
        write('Esc');
        crt.textcolor(7);
        write('=Quit Editing ');
        crt.textcolor(14);
        write('Enter');
        crt.textcolor(7);
        write('=Edit Field ');
        crt.textcolor(14);
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
{        setwindow4(w,1,6,78,23,8,0,8,'View Message Base Template '+cstr(ii),
                 'Message Base Editor',TRUE);}
                                listbox_goto:=TRUE;
                                listbox_goto_offset:=1;
                                displaybox2(w2,'Reading Message Base Files...');
                                new(lp);
                                seek(btf,0);
                                read(btf,mtmp);
                                ii2:=0;
                                lp^.p:=NIL;
                                lp^.list:=mln(cstr(ii2),5)+mln(mtmp.name,45)+'  %070%'+
                                        Btype(mtmp.mbtype)+'   '+format2(mtmp.messagetype);
                                firstlp:=lp;
                                while (not(eof(bf))) do begin
                                inc(ii2);
                                read(btf,mtmp);
                                new(lp2);
                                lp2^.p:=lp;
                                lp^.n:=lp2;
                                lp2^.list:=mln(cstr(ii2),5)+mln(mtmp.name,45)+' %070% '+
                                        Btype(mtmp.mbtype)+'   '+format2(mtmp.messagetype);
                                lp:=lp2;
                                end;
                                seek(btf,ii);
                                read(btf,mtmp);
                                lp^.n:=NIL;
                                removewindow(w2);
                                done3:=false;
                                top:=ii+1;
                                cur:=ii+1;
                                ii4:=ii;
                                repeat
                                for x:=1 to 100 do rt.data[x]:=-1;
                                lp:=firstlp;
                                listbox(w2,rt,top,cur,lp,3,9,76,22,3,0,8,'Message Bases','',TRUE);
                                crt.textcolor(7);
                                textbackground(0);
                                case rt.kind of
                                        0:begin
                                                c3:=chr(rt.data[100]);
                                                removewindow(w2);
                                                checkkey(c3);
                                                rt.data[100]:=-1;
{        setwindow5(w,1,6,78,23,3,0,8,'View Message Base Template '+cstr(ii),
                 'Message Base Editor',TRUE);}
                                          end;
                                        1:begin
                                                removewindow(w2);
                                                if (rt.data[1])<>-1 then begin
                                                                ii:=rt.data[1]-1;
                                                                done3:=TRUE;
                                                                arrows:=TRUE;
                                                                update:=TRUE;
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
                                                ii:=ii4;
                                                lp:=firstlp;
                                                while (lp<>NIL) do begin
                                                        lp2:=lp^.n;
                                                        dispose(lp);
                                                        lp:=lp2;
                                                end;
                                                done3:=TRUE;
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
                                        crt.textcolor(7);
                                        textbackground(0);
                                        write(choices[current]);
                                        dec(current);
                                        if (mtmp.mbtype=0) then begin
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
                                        crt.textcolor(7);
                                        textbackground(0);
                                        write(choices[current]);
                                        inc(current);
                                        if (mtmp.mbtype=0) then begin
                                                if (current>13) then current:=1;
                                        end else begin
                                                if (current>14) then current:=1;
                                        end;
                                   end;
                        end;
              end;
              '0'..'9':begin

  setwindow(w2,27,12,54,14,3,0,8,'',TRUE);
  gotoxy(2,1);
  crt.textcolor(7);
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
  seek(btf,ii);
  read(btf,mtmp);
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
                                        crt.textcolor(7);
                                        textbackground(0);
                                        write(choices[current]);
                                        gotoxy(22,current+1);
                                        crt.textcolor(9);
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
                                        s:=template;
                                        infielde(s,70);
                                        infield_maxshow:=0;
                                        infield_show_colors:=FALSE;
                                        if (s<>template) then changed:=TRUE;
                                        template:=s;
                                   end;
                                2:begin
                                        gotoxy(2,current+1);
                                        crt.textcolor(7);
                                        textbackground(0);
                                        write(choices[current]);
                                        gotoxy(22,current+1);
                                        crt.textcolor(9);
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
                                 3:begin
                                        inc(mtmp.mbtype);
                                        changed:=TRUE;
                                        if (mtmp.mbtype>3) then mtmp.mbtype:=0;
                                                gotoxy(2,15);
                                                if (mtmp.mbtype=0) then crt.textcolor(8) else
                                                crt.textcolor(7);
                                                textbackground(0);
                                                write(choices[14]);
                                                gotoxy(24,15);
                                                clreol;
                                                gotoxy(24,15);
                                                case mtmp.mbtype of
                                                        1:shownetworkinfo;
                                                        2:shownetworkinfo;
                                                        3:write(showgateway(mtmp.gateway));
                                                        4:begin
                                                                crt.textcolor(8);
                                                                write('N/A');
                                                          end;
                                                end;
                                        gotoxy(24,4);
                                        crt.textcolor(3);
                                        textbackground(0);
                                        case mtmp.mbtype of
                                                0:write('Local          ');
                                                1:write('Echomail       ');
                                                2:write('Netmail        ');
                                                3:write('Internet E-mail');
                                        end;
                                        if ((mtmp.mbtype=0) or (mtmp.mbtype=1)) and
                                                (mtmp.messagetype=3) then begin
                                                mtmp.messagetype:=2;
                                                gotoxy(24,5);
                                                write(format(mtmp.messagetype));
                                                crt.textcolor(3);
                                                gotoxy(24,6);
                                                filename:='NEWBASE';
                                                write(mln(allcaps(msgpath+filename),40));
                                        end;
                                 end;
                                 4:begin
                                        inc(mtmp.messagetype);
                                        changed:=TRUE;
                                        if (mtmp.mbtype<2) then begin
                                                if (mtmp.messagetype>2) then mtmp.messagetype:=1;
                                        end else begin
                                                if (mtmp.messagetype>3) then mtmp.messagetype:=1;
                                        end;
                                        if (mtmp.messagetype=3) then begin
                                                gotoxy(24,6);
                                                filename:='';
                                                write(mln(msgpath,40));
                                        end;
                                        if (mtmp.messagetype<>3) then begin
                                                gotoxy(24,6);
                                                crt.textcolor(3);
                                                write(mln(allcaps(msgpath+filename),40));
                                        end;
                                        gotoxy(24,5);
                                        crt.textcolor(3);
                                        textbackground(0);
                                        write(format(mtmp.messagetype));
                                 end;
                                 5:begin
                                        gotoxy(2,current+1);
                                        crt.textcolor(7);
                                        textbackground(0);
                                        write(choices[current]);
                                        gotoxy(22,current+1);
                                        crt.textcolor(9);
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
                                        case mtmp.messagetype of
                                                1,2:s:=msgpath+filename;
                                                  3:s:=msgpath;
                                        end;
                                        infielde(s,48);
                                        infield_maxshow:=0;
                                        infield_clear:=FALSE;
                                        infield_putatend:=FALSE;
                                        if (mtmp.messagetype=3) then begin
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
                                                        if pynqbox('Rename files? ') then begin
                                                        end;
                                                end;
                                                end;
                                        window(2,7,77,22);
                                        end;
                                 end;
                                 6:begin
                                        inc(mtmp.tagtype);
                                        if (mtmp.tagtype>2) then
                                                mtmp.tagtype:=0;
                                        changed:=TRUE;
                                        gotoxy(24,current+1);
                                        crt.textcolor(3);
                                        write(showtagtype);
                                 end;
                                 7:begin
                                 if not(mtmp.mbtype=2) then begin
                                 changed:=TRUE;
                                 if (public in mtmp.mbpriv) then begin
                                        mtmp.mbpriv:=[private];
                                 end else
                                 if (private in mtmp.mbpriv) then begin
                                        mtmp.mbpriv:=[pubpriv];
                                 end else
                                 if (pubpriv in mtmp.mbpriv) then begin
                                        mtmp.mbpriv:=[public];
                                 end;
                                 gotoxy(24,current+1);
                                 crt.textcolor(3);
                                 textbackground(0);
                                 write(mln(pp(mtmp),20));

                                 end else begin
                                        changed:=TRUE;
                                        if (private in mtmp.mbpriv) then changed:=FALSE;
                                        mtmp.mbpriv:=[private];
                                 gotoxy(24,current+1);
                                 crt.textcolor(3);
                                 textbackground(0);
                                 write(mln(pp(mtmp),20));
                                 end;
                                 end;
                                 8:begin
                                        gotoxy(2,current+1);
                                        crt.textcolor(7);
                                        textbackground(0);
                                        write(choices[current]);
                                        gotoxy(22,current+1);
                                        crt.textcolor(9);
                                        textbackground(0);
                                        write('>');
                                        gotoxy(24,current+1);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=TRUE;
                                        infield_numbers_only:=FALSE;
                                        s:=accesskey;
                                        infielde(s,20);
                                        if (s<>accesskey) then changed:=TRUE;
                                        accesskey:=s;
                                 end;
                                 9:begin
                                        gotoxy(2,current+1);
                                        crt.textcolor(7);
                                        textbackground(0);
                                        write(choices[current]);
                                        gotoxy(22,current+1);
                                        crt.textcolor(9);
                                        textbackground(0);
                                        write('>');
                                        gotoxy(24,current+1);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=TRUE;
                                        infield_numbers_only:=FALSE;
                                        s:=access;
                                        infielde(s,20);
                                        if (s<>access) then changed:=TRUE;
                                        access:=s;
                                 end;
                                 10:begin
                                        gotoxy(2,current+1);
                                        crt.textcolor(7);
                                        textbackground(0);
                                        write(choices[current]);
                                        gotoxy(22,current+1);
                                        crt.textcolor(9);
                                        textbackground(0);
                                        write('>');
                                        gotoxy(24,current+1);
                                        infield_inp_fgrd:=15;
                                        infield_inp_bkgd:=1;
                                        infield_out_fgrd:=3;
                                        infield_out_bkgd:=0;
                                        infield_allcaps:=TRUE;
                                        infield_numbers_only:=FALSE;
                                        s:=postaccess;
                                        infielde(s,20);
                                        if (s<>postaccess) then changed:=TRUE;
                                        postaccess:=s;
                                 end;
                                 11:begin
                                        getflags;
                                        window(2,7,77,22);
                                        gotoxy(24,12);
                                        flagstate(mtmp,1);
                                        gotoxy(42,12);
                                        flagstate(mtmp,2);
                                        gotoxy(58,12);
                                        flagstate(mtmp,3);
                                        changed:=TRUE;
                                 end;
                                 12:begin
                                        changed2:=getconfs;
                                        if not(changed) then changed:=changed2;
                                        window(2,7,77,22);
                                        crt.textcolor(7);
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
                if (mtmp.msgpath='') and (mtmp.filename='') then begin
                        displaybox('Must set base filename!',2000);
                        changed:=TRUE;
                        editing:=TRUE;
                        update:=FALSE;
                        arrows:=FALSE;
                        autosave:=FALSE;
                        dn:=FALSE;
                end else begin
                   if (not existdir(mtmp.msgpath)) then begin
                        displaybox3(7,w4,mtmp.msgpath+' does not exist.');
                        if (pynqbox('Create Directory? ')) then begin
                          {$I-} mkdir(bslash(FALSE,mtmp.msgpath)); {$I+}
                          if (ioresult<>0) then begin
                            displaybox('Error creating directory.',3000);
                          end;
                        end;
                        removewindow(w4);
                      end;
                  seek(btf,xloaded); write(btf,mtmp);
          changed:=FALSE;
          editing:=FALSE;
          update:=TRUE;
          arrows:=TRUE;
          autosave:=FALSE;
          dn:=FALSE;
                end;
          end else begin
                seek(btf,xloaded); read(btf,mtmp);
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
  assign(btf,systat.gfilepath+'MBASES.TMP');
  {$I-} reset(btf); {$I-}
  if (ioresult<>0) then begin
            displaybox('Error Opening MBASES.TMP... Creating...',3000);
            rewrite(btf);
            fillchar(mtmp,sizeof(mtmp),#0);
        with mtmp do begin
        name:='';
        filename:='';
        nettagname:='';
        mbtype:=0;
        msgpath:='';
        access:='S30';
        postaccess:='S30';
        maxmsgs:=100;
        accesskey:='';
        address[1]:=TRUE;
        for ii:=2 to 30 do address[ii]:=FALSE;
        messagetype:=2;
        origin:=1;
        tagtype:=1;
        nameusage:=0;
        txtcolor:=fidor.text_color;
        quotecolor:=fidor.quote_color;
        tearcolor:=fidor.tear_color;
        origincolor:=fidor.origin_color;
        tagcolor:=fidor.tag_color;
        oldtearcolor:=fidor.oldtear_color;
        if (systat.allowalias) and (systat.aliasprimary) then
        mbflag:=[MBFilter] else
        mbflag:=[MBRealname,MBFilter];
        mbpriv:=[public];
        inconfs:=['A'];
        if (fidor.skludge) then mbflag:=mbflag+[mbskludge];
        if (fidor.sseenby) then mbflag:=mbflag+[mbsseenby];
        if (fidor.sorigin) then mbflag:=mbflag+[mbsorigin];
           end;
            for ii:=0 to 20 do begin
                write(btf,mtmp);
            end;
            seek(btf,0);
  end;
  ii:=0;
  bem;
  close(btf);
end;

end.

