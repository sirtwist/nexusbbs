(*****************************************************************************)
(*>                                                                         <*)
(*>  SYSOP2I .PAS -  Written by George A. Roberts IV                        <*)
(*>                                                                         <*)
(*>  SysOp functions: System Configuration Editor -- "I" command.           <*)
(*>                                                                         <*)
(*>                                                                         <*)
(*****************************************************************************)
{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R-,S+,V-}
unit sysop2i;

interface

uses
  crt, dos,inptmisc, myio, misc, fidonet,procspec;

procedure pofido;

implementation

var fidor:fidorec;

procedure gateways;
var top,cur:integer;
    firstlp,lp,lp2:listptr;
    rt:returntype;
    intf:file of internetrec;
    int,oldint:internetrec;
    w2:windowrec;
    c:char;
    x,i:integer;
    changed,done:boolean;

function editgateway(i2:integer):boolean;
var x2,current:integer;
    choices:array[1..5] of string;
    desc:array[1..5] of string;
    w3:windowrec;
    d2,cg,as:boolean;
    c2:char;
    s:string;

  function showadr(x3:integer):string;
  var s:string;
  begin
        if (fidor.address[x3].zone<>0) then begin
        s:=cstr(fidor.address[x3].zone)+':'+cstr(fidor.address[x3].net)+'/'+
                cstr(fidor.address[x3].node);
        if (fidor.address[x3].point<>0) then s:=s+'.'+cstr(fidor.address[x3].point);
        end else s:='';
  showadr:=s;
  end;

procedure getaddress;
  var d:boolean;
      x,x2,xit:integer;
      s:string;
      curr,column:integer;
        
        function aof(x3:integer):string;
        begin
        if (int.gateways[i2].fromaddress=x3) then aof:='þ' else aof:=' ';
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
  curr:=1;
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
  write('=Select Address                                                ');
  window(3,10,76,21);
  repeat
        gotoxy(2+(2+(column*24)),curr+1);
        textcolor(15);
        textbackground(1);
        write(mln(cstr(curr+(column*10)),2)+' '+mln(showadr(curr+(column*10)),18));
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
                                    gotoxy(2+(2+(column*24)),curr+1);
                                    textcolor(7);
                                    textbackground(0);
                                    write(mln(cstr(curr+(column*10)),2)+' ');
                                    textcolor(3);
                                    write(mln(showadr(curr+(column*10)),18));
                                    dec(curr);
                                    if (curr<1) then curr:=10;
                                    end;
                                #75:begin
                                    gotoxy(2+(2+(column*24)),curr+1);
                                    textcolor(7);
                                    textbackground(0);
                                    write(mln(cstr(curr+(column*10)),2)+' ');
                                    textcolor(3);
                                    write(mln(showadr(curr+(column*10)),18));
                                    dec(column);
                                    if (column<0) then column:=2;
                                    end;
                                #77:begin
                                    gotoxy(2+(2+(column*24)),curr+1);
                                    textcolor(7);
                                    textbackground(0);
                                    write(mln(cstr(curr+(column*10)),2)+' ');
                                    textcolor(3);
                                    write(mln(showadr(curr+(column*10)),18));
                                    inc(column);
                                    if (column>2) then column:=0;
                                    end;
                                #80:begin
                                    gotoxy(2+(2+(column*24)),curr+1);
                                    textcolor(7);
                                    textbackground(0);
                                    write(mln(cstr(curr+(column*10)),2)+' ');
                                    textcolor(3);
                                    write(mln(showadr(curr+(column*10)),18));
                                    inc(curr);
                                    if (curr>10) then curr:=1;
                                    end;
                        end;
                   end;
               #27:begin
                   d:=TRUE;
                   end;
               #13:begin
                   d:=TRUE;
                   if (int.gateways[i2].fromaddress<>curr+(column*10)) then begin
                        int.gateways[i2].fromaddress:=curr+(column*10);
                        textbackground(0);
                        cg:=TRUE;
                   end;
                   end;
        end;
  until (d);
  removewindow(w);
end;


  function showadr2:string;
  var s2:string;
  begin
        if (int.gateways[i2].toaddress.zone<>0) then begin
        s2:=cstr(int.gateways[i2].toaddress.zone)+':'+cstr(int.gateways[i2].toaddress.net)+'/'+
                cstr(int.gateways[i2].toaddress.node);
        if (int.gateways[i2].toaddress.point<>0) then s2:=s2+'.'+cstr(int.gateways[i2].toaddress.point);
        end else s2:='';
  showadr2:=s2;
  end;

  function showgatewaytype:string;
  begin
        case int.gateways[i2].gatewaytype of
                0:showgatewaytype:='MsgToName in Header, TO: <site> first line of msg';
                1:showgatewaytype:='<site> as MsgToName in Header, msg text is normal';
                else showgatewaytype:='Error - please reconfigure!';
        end;
  end;

begin

(*
InternetREC=
RECORD
    Gateways:ARRAY[1..30] of
        RECORD
        Name:STRING[40];
        ToName:STRING[36];
        ToAddress:RECORD
                Zone  : WORD;     { Zone number                              }
                Net   : WORD;     { Net number                               }
                Node  : WORD;     { Node number                              }
                Point : WORD;     { Point number                             }
        END;
        FromAddress:BYTE;
        GatewayType:BYTE;         { 0: Place ToName in Header, TO: <site> in }
                                  {    first line of text.                   }
                                  { 1: Place <site> in Header                }
        RESERVED1:ARRAY[1..29] of BYTE;
        END;
    RESERVED2:ARRAY[1..50] of BYTE;
END;
*)
oldint:=int;
d2:=FALSE;
cg:=FALSE;
as:=FALSE;
choices[1]:='Gateway Name        :';
choices[2]:='Message To Name     :';
choices[3]:='Message To Address  :';
choices[4]:='Message From Address:';
choices[5]:='Gateway Type        :';
desc[1]:='This is the description of this e-mail gateway';
desc[2]:='This is the To: name for the message header';
desc[3]:='This is the To: address (Fido-style) for the message header';
desc[4]:='This is the From: address (Fido-style) for the message header';
desc[5]:='This determines how Nexus will handle the e-mail addressing';
setwindow2(w3,2,10,78,18,3,0,8,'Edit Gateway '+cstr(i2)+'/30','Gateway Editor',TRUE);
textcolor(7);
textbackground(0);
for x2:=1 to 5 do begin
        gotoxy(2,x2+1);
        write(choices[x2]);
end;
gotoxy(24,2);
textcolor(3);
write(mln(int.gateways[i2].name,40));
gotoxy(24,3);
write(mln(int.gateways[i2].toname,36));
gotoxy(24,4);
write(mln(showadr2,40));
gotoxy(24,5);
write(mln(showadr(int.gateways[i2].fromaddress),40));
gotoxy(24,6);
write(showgatewaytype);
current:=1;
repeat
gotoxy(2,current+1);
textcolor(15);
textbackground(1);
write(choices[current]);
window(1,1,80,25);
textcolor(14);
textbackground(0);
gotoxy(1,25);
write('Esc');
textcolor(7);
write('=Exit ');
clreol;
textcolor(14);
write(desc[current]);
window(3,11,77,17);
while not(keypressed) do begin timeslice; end;
c2:=readkey;
case c2 of
        #0:begin
                c2:=readkey;
                case c2 of
                        #68:begin
                            d2:=TRUE;
                            as:=TRUE;
                            end;
                        #72:begin
                                textcolor(7);
                                textbackground(0);
                                gotoxy(2,current+1);
                                write(choices[current]);
                                dec(current);
                                if (current=0) then current:=5;
                            end;
                        #80:begin
                                textcolor(7);
                                textbackground(0);
                                gotoxy(2,current+1);
                                write(choices[current]);
                                inc(current);
                                if (current=6) then current:=1;
                            end;
                end;
             end;
        #13:begin
                gotoxy(2,current+1);
                textcolor(7);
                textbackground(0);
                write(choices[current]);
                gotoxy(22,current+1);
                                textcolor(9);
                                textbackground(0);
                                write('>');
                                gotoxy(24,current+1);
                case current of
                        1:begin
                                s:=int.gateways[i2].name;
                                infield_clear:=TRUE;
                                infield_putatend:=TRUE;
                                infield_inp_fgrd:=15;
                                infield_inp_bkgd:=1;
                                infield_out_fgrd:=3;
                                infield_out_bkgd:=0;
                                infield_allcaps:=false;
                                infield_numbers_only:=false;
                                infield_address:=FALSE;
                                infielde(s,40);
                                if (s<>int.gateways[i2].name) then begin
                                int.gateways[i2].name:=s;
                                cg:=TRUE;
                                end;
                          end;
                        2:begin
                                s:=int.gateways[i2].toname;
                                infield_inp_fgrd:=15;
                                infield_inp_bkgd:=1;
                                infield_out_fgrd:=3;
                                infield_out_bkgd:=0;
                                infield_clear:=TRUE;
                                infield_putatend:=TRUE;
                                infield_allcaps:=false;
                                infield_numbers_only:=false;
                                infield_address:=FALSE;
                                infielde(s,36);
                                if (s<>int.gateways[i2].toname) then begin
                                int.gateways[i2].toname:=s;
                                cg:=TRUE;
                                end;
                          end;
                        3:begin
                                s:=showadr2;
                                infield_inp_fgrd:=15;
                                infield_inp_bkgd:=1;
                                infield_out_fgrd:=3;
                                infield_out_bkgd:=0;
                                infield_allcaps:=false;
                                infield_numbers_only:=false;
                                infield_clear:=TRUE;
                                infield_putatend:=TRUE;
                                infield_address:=FALSE;
                                infielde(s,40);
                                if (s<>showadr2) then begin
                                conv_netnode(s,int.gateways[i2].toaddress.zone,
                                int.gateways[i2].toaddress.net,int.gateways[i2].toaddress.node,
                                int.gateways[i2].toaddress.point);
                                cg:=TRUE;
                                end;
                          end;
                        4:begin
setwindow4(w3,2,10,78,18,8,0,8,'Edit Gateway '+cstr(i2)+'/30','Gateway Editor',TRUE);
                                getaddress;
setwindow5(w3,2,10,78,18,3,0,8,'Edit Gateway '+cstr(i2)+'/30','Gateway Editor',TRUE);
                                window(3,11,77,17);
                                textcolor(3);
                                textbackground(0);
                                gotoxy(24,5);
                                write(mln(showadr(int.gateways[i2].fromaddress),40));
                          end;
                        5:begin
                                if (int.gateways[i2].gatewaytype=0) then
                                        int.gateways[i2].gatewaytype:=1
                                        else
                                        int.gateways[i2].gatewaytype:=0;
                                textcolor(3);
                                textbackground(0);
                                gotoxy(24,6);
                                write(showgatewaytype);
                          end;
                    end;
            end;
        #27:d2:=TRUE;
end;
until (d2);
if (as) then editgateway:=TRUE else begin
        if (cg) then begin
                if pynqbox('Save Changes? ') then
                editgateway:=TRUE
                else begin
                editgateway:=FALSE;
                int:=oldint;
                end;
        end else begin
                editgateway:=FALSE;
                int:=oldint;
               end;
end;
removewindow(w3);
end;

procedure loaddata;
var i:integer;
begin
                                new(lp);
                                i:=1;
                                lp^.p:=NIL;
                                lp^.list:=mln(cstr(i),5)+mln(int.gateways[1].name,45);
                                firstlp:=lp;
                                for i:=2 to 30 do begin
                                new(lp2);
                                lp2^.p:=lp;
                                lp^.n:=lp2;
                                lp2^.list:=mln(cstr(i),5)+mln(int.gateways[i].name,45);
                                lp:=lp2;
                                end;
                                lp^.n:=NIL;
end;

begin
        changed:=FALSE;
        done:=FALSE;
        assign(intf,adrv(systat.gfilepath)+'INTERNET.DAT');
        {$I-} reset(intf); {$I+}
        if (ioresult<>0) then begin
                displaybox('Error reading INTERNET.DAT... recreating.',3000);
                fillchar(int,sizeof(int),#0);
                rewrite(intf);
                write(intf,int);
                seek(intf,0);
        end;
        read(intf,int);
        close(intf);
        top:=1;
        cur:=1;
        loaddata;
                                repeat
                                for x:=1 to 100 do rt.data[x]:=-1;
                                lp:=firstlp;
  listbox_escape:=TRUE;
  listbox_enter:=TRUE;
  listbox_insert:=FALSE;
  listbox_delete:=FALSE;
  listbox_tag:=FALSE;
  listbox_move:=FALSE;
  listbox_goto:=TRUE;
                                listbox(w2,rt,top,cur,lp,3,9,76,22,3,0,8,'Internet Gateways','',TRUE);
                                case rt.kind of
                                        0:begin
                                                c:=chr(rt.data[100]);
                                                removewindow(w2);
                                                checkkey(c);
                                                rt.data[100]:=-1;
                                          end;
                                        1:begin
                                                if (editgateway(rt.data[1])) then
                                                        if not(changed) then changed:=TRUE;
                                                if (changed) then begin
                                                                lp:=firstlp;
                                                                while (lp<>NIL) do begin
                                                                        lp2:=lp^.n;
                                                                        dispose(lp);
                                                                        lp:=lp2;
                                                                end;
                                                loaddata;
                                                end;
                                                removewindow(w2);
                                          end;
                                        2:begin
                                                                lp:=firstlp;
                                                                while (lp<>NIL) do begin
                                                                        lp2:=lp^.n;
                                                                        dispose(lp);
                                                                        lp:=lp2;
                                                                end;
                                                removewindow(w2);
                                                done:=TRUE;
                                          end;
                                     end;                                        
                                until (done);
        if (changed) then begin
                rewrite(intf);
                write(intf,int);
                close(intf);
        end;
end;

procedure pofido;
var fidorf:file of fidorec;
    c:char;
    x,x2,current,anum,cc:integer;
    s:string;
    w2:windowrec;
    choice:array[1..10] of string;
    desc:array[1..10] of string;
    adone,abort,next,done,changed:boolean;


function toggle(b:boolean):boolean;
begin
  if (b) then toggle:=FALSE else toggle:=TRUE;
end;
  
  function showadr(x3:integer):string;
  var s:string;
  begin
        if (fidor.address[x3].zone<>0) then begin
        s:=cstr(fidor.address[x3].zone)+':'+cstr(fidor.address[x3].net)+'/'+
                cstr(fidor.address[x3].node);
        if (fidor.address[x3].point<>0) then s:=s+'.'+cstr(fidor.address[x3].point);
        end else s:='';
  showadr:=s;
  end;


  procedure getaddress;
  var d:boolean;
      bf:file of boardrec;
      br:boardrec;
      currents,column:integer;
      c:char;
      zone,net,node,point,x,x2:integer;
      s:string;
  begin
  d:=FALSE;
  setwindow(w,2,7,78,21,3,0,8,'Network Addresses',TRUE);
  column:=0;
  repeat
        for x:=1 to 10 do begin
                gotoxy(2+(24*column),x+1);
                textcolor(7);
                textbackground(0);
                write(mln(cstr(x+(10*column)),2));
                gotoxy(6+(24*column),x+1);
                textcolor(3);
                write(showadr(x+(10*column)));
        end;
        inc(column);
  until (column=3);
  currents:=1;
  column:=0;
  repeat
        gotoxy(2+(24*column),currents+1);
        textcolor(15);
        textbackground(1);
        write(mln(cstr(currents+(10*column)),2));        
        while not(keypressed) do begin timeslice; end;
        c:=readkey;
        case c of
                #0:begin
                        c:=readkey;
                        checkkey(c);
                        case c of
                                #72:begin { Up Arrow }
                                        gotoxy(2+(24*column),currents+1);
                                        textcolor(7);
                                        textbackground(0);
                                        write(mln(cstr(currents+(10*column)),2));        
                                        dec(currents);
                                        if (currents=0) then begin
                                                currents:=10;
                                                if (column=0) then column:=2 else
                                                        dec(column);
                                                end;
                                end;
                                #75:begin { Left }
                                        gotoxy(2+(24*column),currents+1);
                                        textcolor(7);
                                        textbackground(0);
                                        write(mln(cstr(currents+(10*column)),2));        
                                        if (column=0) then column:=2 else
                                        dec(column);
                                        end;
                                #77:begin { Right }
                                        gotoxy(2+(24*column),currents+1);
                                        textcolor(7);
                                        textbackground(0);
                                        write(mln(cstr(currents+(10*column)),2));        
                                        if (column=2) then column:=0 else
                                        inc(column);
                                    end;
                                #80:begin { Down Arrow }
                                        gotoxy(2+(24*column),currents+1);
                                        textcolor(7);
                                        textbackground(0);
                                        write(mln(cstr(currents+(10*column)),2));        
                                        inc(currents);
                                        if (currents=11) then begin
                                                currents:=1;
                                                if (column=2) then column:=0 else
                                                        inc(column);
                                                end;
                                end;
                        end;
                end;
                #13:begin
                                s:=showadr(currents+(10*column));
                                infield_inp_fgrd:=15;
                                infield_inp_bkgd:=1;
                                infield_out_fgrd:=3;
                                infield_out_bkgd:=0;
                                infield_allcaps:=false;
                                infield_numbers_only:=false;
                                infield_address:=TRUE;
                                gotoxy(2+(24*column),currents+1);
                                textcolor(7);
                                textbackground(0);
                                write(mln(cstr(currents+(10*column)),2));
                                gotoxy(4+(24*column),currents+1);
                                textcolor(9);
                                textbackground(0);
                                write('>');
                                gotoxy(6+(24*column),currents+1);
                                infielde(s,19);
                                infield_address:=FALSE;
                                gotoxy(4+(24*column),currents+1);
                                textcolor(9);
                                textbackground(0);
                                write(' ');
                                gotoxy(2+(24*column),currents+1);
                                textcolor(15);
                                textbackground(1);
                                write(mln(cstr(currents+(10*column)),2));
                                zone:=fidor.address[currents+(10*column)].zone;
                                net:=fidor.address[currents+(10*column)].net;
                                node:=fidor.address[currents+(10*column)].node;
                                point:=fidor.address[currents+(10*column)].point;
  conv_netnode(s,fidor.address[currents+(10*column)].zone,fidor.address[currents+(10*column)].net,
        fidor.address[currents+(10*column)].node,fidor.address[currents+(10*column)].point);
                                if (fidor.address[currents+(10*column)].zone=0) and not(s='') then begin
                                        fidor.address[currents+(10*column)].zone:=zone;
                                        fidor.address[currents+(10*column)].net:=net;
                                        fidor.address[currents+(10*column)].node:=node;
                                        fidor.address[currents+(10*column)].point:=point;
                                end;
                                changed:=TRUE;
                end;
                #27:d:=true;
            end;
  until (d);
  removewindow(w);
end;

  procedure getorigin;
  var d:boolean;
      currents,x:integer;
      choices:array[1..20] of string;
      s:string;
      c:char;
      
  begin
  d:=FALSE;
  setwindow(w,10,1,70,23,3,0,8,'Origin Lines',TRUE);
  for x:=1 to 20 do begin
                choices[x]:=mln(cstr(x),2);
                textcolor(7);
                textbackground(0);
                gotoxy(2,x+1);
                write(choices[x]);
                gotoxy(6,x+1);
                textcolor(3);
                write(mln(fidor.origins[x],50));
  end;
  currents:=1;
  repeat
        gotoxy(2,currents+1);
        textcolor(15);
        textbackground(1);
        write(choices[currents]);
        while not(keypressed) do begin timeslice; end;
        c:=readkey;
        case c of
                #0:begin
                        c:=readkey;
                        checkkey(c);
                        case c of
                                #72:begin { Up Arrow }
                                        gotoxy(2,currents+1);
                                        textcolor(7);
                                        textbackground(0);
                                        write(choices[currents]);
                                        dec(currents);
                                        if (currents=0) then currents:=20;
                                end;
                                #80:begin { Down Arrow }
                                        gotoxy(2,currents+1);
                                        textcolor(7);
                                        textbackground(0);
                                        write(choices[currents]);
                                        inc(currents);
                                        if (currents=21) then currents:=1;
                                end;
                        end;
                end;
                #13:begin
                        s:=fidor.origins[currents];
                                infield_inp_fgrd:=15;
                                infield_inp_bkgd:=1;
                                infield_out_fgrd:=3;
                                infield_out_bkgd:=0;
                                infield_allcaps:=false;
                                infield_numbers_only:=false;
                                infield_address:=FALSE;
                                gotoxy(2,currents+1);
                                textcolor(7);
                                textbackground(0);
                                write(mln(cstr(currents),2));
                                gotoxy(4,currents+1);
                                textcolor(9);
                                textbackground(0);
                                write('>');
                                gotoxy(6,currents+1);
                                infielde(s,50);
                                gotoxy(4,currents+1);
                                textcolor(9);
                                textbackground(0);
                                write(' ');
                                gotoxy(2,currents+1);
                                textcolor(15);
                                textbackground(1);
                                write(mln(cstr(currents),2));
                                if (s<>fidor.origins[currents]) then begin
                                fidor.origins[currents]:=s;
                                changed:=TRUE;
                                end;
                end;
                #27:d:=true;
            end;
  until (d);
  removewindow(w);
end;


function showflags:string;
var s2:string;
begin

with fidor do begin
s2:='Local ';
if (isprivate) then s2:=s2+'Priv ';
if (iscrash) then s2:=s2+'Crash ';
if (iskillsent) then s2:=s2+'Kill ';
if (ishold) then s2:=s2+'Hold ';
if (isfattach) then s2:=s2+'Attach ';
if (isfilereq) then s2:=s2+'Request ';
if (isreqrct) then s2:=s2+'Receipt ';
if (isdirect) then s2:=s2+'Direct';
end;
showflags:=s2;
end;

procedure getflags;
var x:integer;
    d:boolean;
    c:char;
    choices:array[1..8] of string;

function check(i:integer):boolean;
begin
check:=FALSE;
case i of
        1:if (fidor.isprivate) then check:=TRUE;
        2:if (fidor.iscrash) then check:=TRUE;
        3:if (fidor.iskillsent) then check:=TRUE;
        4:if (fidor.ishold) then check:=TRUE;
        5:if (fidor.isreqrct) then check:=TRUE;
        6:if (fidor.isfilereq) then check:=TRUE;
        7:if (fidor.isfattach) then check:=TRUE;
        8:if (fidor.isdirect) then check:=TRUE;
end;
end;


begin
choices[1]:='Private      :';
choices[2]:='Crash        :';
choices[3]:='Kill/Sent    :';
choices[4]:='Hold         :';
choices[5]:='Receipt Req  :';
choices[6]:='File Request :';
choices[7]:='File Attach  :';
choices[8]:='Direct       :';
setwindow(w,29,7,51,18,3,0,8,'Netmail',TRUE);
textcolor(7);
textbackground(0);
for x:=1 to 8 do begin
        textcolor(7);
        textbackground(0);
        gotoxy(2,x+1);
        write(choices[x]);
        gotoxy(17,x+1);
        textcolor(3);
        write(syn(check(x)));
end;
d:=false;
x:=1;
repeat
gotoxy(2,x+1);
textcolor(15);
textbackground(1);
write(choices[x]);
while not(keypressed) do begin timeslice; end;
c:=readkey;
case c of
        #0:begin
                c:=readkey;
                checkkey(c);
                case c of
                        #72:begin 
                                gotoxy(2,x+1);
                                textcolor(7);
                                textbackground(0);
                                write(choices[x]);
                                if (x=1) then x:=8 else dec(x);
                        end;
                        #80:begin
                                gotoxy(2,x+1);
                                textcolor(7);
                                textbackground(0);
                                write(choices[x]);
                                if (x=8) then x:=1 else inc(x);
                        end;
                end;
        end;
        #13:begin
                if (x in [1..8]) then changed:=TRUE;
                case x of
                        1:begin
                                fidor.isprivate:=not(fidor.isprivate);
                                gotoxy(17,x+1);
                                textcolor(3);
                                textbackground(0);
                                write(syn(check(x)));
                                end;
                        2:begin
                                fidor.iscrash:=not(fidor.iscrash);
                                gotoxy(17,x+1);
                                textcolor(3);
                                textbackground(0);
                                write(syn(check(x)));
                                end;
                        3:begin
                                fidor.iskillsent:=not(fidor.iskillsent);
                                gotoxy(17,x+1);
                                textcolor(3);
                                textbackground(0);
                                write(syn(check(x)));
                                end;
                        4:begin
                                fidor.ishold:=not(fidor.ishold);
                                gotoxy(17,x+1);
                                textcolor(3);
                                textbackground(0);
                                write(syn(check(x)));
                                end;
                        5:begin
                                fidor.isreqrct:=not(fidor.isreqrct);
                                gotoxy(17,x+1);
                                textcolor(3);
                                textbackground(0);
                                write(syn(check(x)));
                                end;
                        6:begin
                                fidor.isfilereq:=not(fidor.isfilereq);
                                gotoxy(17,x+1);
                                textcolor(3);
                                textbackground(0);
                                write(syn(check(x)));
                                end;
                        7:begin
                                fidor.isfattach:=not(fidor.isfattach);
                                gotoxy(17,x+1);
                                textcolor(3);
                                textbackground(0);
                                write(syn(check(x)));
                                end;
                        8:begin
                                fidor.isdirect:=not(fidor.isdirect);
                                gotoxy(17,x+1);
                                textcolor(3);
                                textbackground(0);
                                write(syn(check(x)));
                                end;
                end;
            end;
        #27:d:=TRUE;
        end;
until (d);
removewindow(w);
end;

procedure getcolors;
var x:integer;
    d:boolean;
    c:char;
    tempbyte:byte;
    choices:array[1..6] of string;

procedure showcolor(i:integer);
begin
        case i of
                1:begin                      
                        textattr:=fidor.text_color;
                        write('Hello there!  This is what you said to me:');
                  end;
                2:begin
                        textattr:=fidor.quote_color;
                        write('YN> I am using Nexus Bulletin Board System!  It''s great!');
                  end;
                3:begin
                        textattr:=fidor.tag_color;
                        write('... Strike any user when ready ...');
                  end;
                4:begin
                        textattr:=fidor.oldtear_color;
                        write('___ Offline Mail Reader');
                  end;
                5:begin
                        textattr:=fidor.tear_color;
                        write('--- Nexus v'+ver);
                  end;
                6:begin
                        textattr:=fidor.origin_color;
                        write('* Origin: '+copy(fidor.origins[1],1,38));
                  end;
        end;
        textattr:=7;
end;

begin
with fidor do begin
choices[1]:='Text         :';
choices[2]:='Quote        :';
choices[3]:='Tagline      :';
choices[4]:='Old Tearline :';
choices[5]:='Tearline     :';
choices[6]:='Origin Line  :';
setwindow(w,2,9,77,18,3,0,8,'Message Colors',TRUE);
textcolor(7);
textbackground(0);
for x:=1 to 6 do begin
        textcolor(7);
        textbackground(0);
        gotoxy(2,x+1);
        write(choices[x]);
        gotoxy(17,x+1);
        textcolor(3);
        showcolor(x);
end;
d:=false;
x:=1;
repeat
window(3,10,76,17);
gotoxy(2,x+1);
textcolor(15);
textbackground(1);
write(choices[x]);
while not(keypressed) do begin timeslice; end;
c:=readkey;
case c of
        #0:begin
                c:=readkey;
                checkkey(c);
                case c of
                        #72:begin 
                                gotoxy(2,x+1);
                                textcolor(7);
                                textbackground(0);
                                write(choices[x]);
                                dec(x);
                                if (x=0) then x:=6;
                        end;
                        #80:begin
                                gotoxy(2,x+1);
                                textcolor(7);
                                textbackground(0);
                                write(choices[x]);
                                inc(x);
                                if (x=7) then x:=1;
                        end;
                end;
        end;
        #13:begin
                case x of
                        1:begin
                                setwindow4(w,2,9,77,18,8,0,8,'Message Colors','',TRUE);
                                tempbyte:=getcolor(3,8,text_color,'Hello there!');
                                setwindow5(w,2,9,77,18,3,0,8,'Message Colors','',TRUE);
                                window(3,10,76,17);
                                if (tempbyte<>text_color) then begin
                                changed:=TRUE;
                                text_color:=tempbyte;
                                end;
                                gotoxy(17,2);
                                textattr:=text_color;
                                write('Hello there!  This is what you said to me:');
                          end;
                        2:begin 
                                setwindow4(w,2,9,77,18,8,0,8,'Message Colors','',TRUE);
                                tempbyte:=getcolor(3,8,quote_color,'YN>  How are you?');
                                setwindow5(w,2,9,77,18,3,0,8,'Message Colors','',TRUE);
                                window(3,10,76,17);
                                if (tempbyte<>quote_color) then begin
                                changed:=TRUE;
                                quote_color:=tempbyte;
                                end;
                                textattr:=quote_color;
                                gotoxy(17,3);
                                write('YN> I am using Nexus Bulletin Board System!  It''s great!');
                          end;
                        3:begin
                                setwindow4(w,2,9,77,18,8,0,8,'Message Colors','',TRUE);
                                tempbyte:=getcolor(3,8,tag_color,'... Strike any user when ready.');
                                setwindow5(w,2,9,77,18,3,0,8,'Message Colors','',TRUE);
                                window(3,10,76,17);
                                if (tempbyte<>tag_color) then begin
                                changed:=TRUE;
                                tag_color:=tempbyte;
                                end;
                                textattr:=tag_color;
                                gotoxy(17,4);
                                write('... Strike any user when ready ...');
                          end;
                        4:begin 
                                setwindow4(w,2,9,77,18,8,0,8,'Message Colors','',TRUE);
                                tempbyte:=getcolor(3,8,oldtear_color,'___ Offline Mail Reader');
                                setwindow5(w,2,9,77,18,3,0,8,'Message Colors','',TRUE);
                                window(3,10,76,17);
                                if (tempbyte<>oldtear_color) then begin
                                changed:=TRUE;
                                oldtear_color:=tempbyte;
                                end;
                                textattr:=oldtear_color;
                                gotoxy(17,5);
                                write('___ Offline Mail Reader');
                           end;
                        5:begin
                                setwindow4(w,2,9,77,18,8,0,8,'Message Colors','',TRUE);
                                tempbyte:=getcolor(3,8,tear_color,'--- Nexus v'+ver);
                                setwindow5(w,2,9,77,18,3,0,8,'Message Colors','',TRUE);
                                window(3,10,76,17);
                                if (tempbyte<>tear_color) then begin
                                changed:=TRUE;
                                tear_color:=tempbyte;
                                end;
                                textattr:=tear_color;
                                gotoxy(17,6);
                                write('--- Nexus v'+ver);
                           end;    
                        6:begin
                                setwindow4(w,2,9,77,18,8,0,8,'Message Colors','',TRUE);
                                tempbyte:=getcolor(3,8,origin_color,' * Origin: Here!');
                                setwindow5(w,2,9,77,18,3,0,8,'Message Colors','',TRUE);
                                window(3,10,76,17);
                                if (tempbyte<>origin_color) then begin
                                changed:=TRUE;
                                origin_color:=tempbyte;
                                end;
                                textattr:=origin_color;
                                gotoxy(17,7);
                                write(' * Origin: '+copy(origins[1],1,38));
                           end;
                end;
            end;
        #27:d:=TRUE;
        end;
until (d);
removewindow(w);
end;
end;

procedure showcolors;

        procedure blank;
        begin
        textattr:=7;
        write(' ');
        end;
begin
  with fidor do begin
  textattr:=text_color;
  write('Text'); blank;
  textattr:=quote_color;
  write('Quote'); blank;
  textattr:=tag_color;
  write('Tagline'); blank;
  textattr:=oldtear_color;
  write('OldTear'); blank;
  textattr:=tear_color;
  write('Tear'); blank;
  textattr:=origin_color;
  write('Origin');
  end;
  textattr:=7;
end;

begin
  changed:=FALSE;
  done:=FALSE;
  assign(fidorf,systat.gfilepath+'NETWORK.DAT');
  {$I-} reset(fidorf); {$I+}
  if (ioresult<>0) then begin
        displaybox('Error Reading NETWORK.DAT!',3000);
        exit;
  end;
  read(fidorf,fidor);
  close(fidorf);
  current:=1;
  choice[1]:='Network Addresses      ';
  choice[2]:='Origin Lines           ';
  choice[3]:='Internet Gateways      ';
  choice[4]:='Suppress Kludge Lines :';
  choice[5]:='Suppress SEEN-BY Lines:';
  choice[6]:='Suppress Origin Line  :';
  choice[7]:='Default Netmail Flags :';
  choice[8]:='Path to Nodelist Files:';
  choice[9]:='Node # in Tear Line?  :';
  choice[10]:='Default Message Colors:';
  desc[1]:='Network Addresses available for message bases';
  desc[2]:='Origin Lines used when setting up message bases';
  desc[3]:='Internet Gateway Configuration';
  desc[4]:='Suppress display of ^A Kludge Lines';
  desc[5]:='Suppress display of SEEN-BY Lines';
  desc[6]:='Suppress display of * Origin: Lines';
  desc[7]:='Default Netmail Flags';
  desc[8]:='Path to Version 7 Nodelist Files';
  desc[9]:='Place the node number in message tear lines?';
  desc[10]:='Default Colors used to display Messages';
  setwindow(w2,1,8,78,21,3,0,8,'Network Configuration',TRUE);
  for x:=1 to 10 do begin
          textcolor(7);
          textbackground(0);
          gotoxy(2,x+1);
          write(choice[x]);
  end;
  gotoxy(26,5);
  textcolor(3);
  textbackground(0);
  with fidor do begin
  write(syn(skludge));
  gotoxy(26,6);
  textcolor(3);
  textbackground(0);
  write(syn(sseenby));
  gotoxy(26,7);
  textcolor(3);
  textbackground(0);
  write(syn(sorigin));
  gotoxy(26,8);
  textcolor(3);
  textbackground(0);
  write(showflags);
  gotoxy(26,9);
  textcolor(3);
  textbackground(0);
  write(copy(nodelistpath,1,50));
  textcolor(3);
  textbackground(0);
  gotoxy(26,10);
  write(syn(nodeintear));
  gotoxy(26,11);
  showcolors;
  end;
  window(1,1,80,25);
  gotoxy(1,25);
  clreol;
  window(2,9,79,22);
  current:=1;
  repeat
    with fidor do begin
        cursoron(false);
        gotoxy(2,current+1);
        textcolor(15);
        textbackground(1);
        write(choice[current]);
        window(1,1,80,25);
        gotoxy(1,25);
        textcolor(14);
        textbackground(0);
        write('Esc');
        textcolor(7);
        write('=Exit ');
        textcolor(14);
        write(desc[current]);
        window(2,9,79,22);
        while not(keypressed) do begin timeslice; end;
        c:=readkey;
        case c of
        #0:begin
                c:=readkey;
                checkkey(c);
                case c of
                        #72:begin { up arrow }
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choice[current]);
                                window(1,1,80,25);
                                gotoxy(1,25);
                                clreol;
                                window(2,9,79,22);
                                dec(current);
                                if (current<1) then current:=10;
                                end;
                        #80:begin { down arrow }
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choice[current]);
                                window(1,1,80,25);
                                gotoxy(1,25);
                                clreol;
                                window(2,9,79,22);
                                inc(current);
                                if (current>10) then current:=1;
                                end;
                end;
        end;        
        #13:begin
                case current of
                        1:begin
                                setwindow4(w2,1,8,78,21,8,0,8,'Network Configuration','',TRUE);
                                getaddress;
                                setwindow5(w2,1,8,78,21,3,0,8,'Network Configuration','',TRUE);
                                window(2,9,79,22);
                        end;
                        2:begin
                                setwindow4(w2,1,8,78,21,8,0,8,'Network Configuration','',TRUE);
                                getorigin;
                                setwindow5(w2,1,8,78,21,3,0,8,'Network Configuration','',TRUE);
                                window(2,9,79,22);
                        end;
                        3:begin
                                setwindow4(w2,1,8,78,21,8,0,8,'Network Configuration','',TRUE);
                                gateways;
                                setwindow5(w2,1,8,78,21,3,0,8,'Network Configuration','',TRUE);
                                window(2,9,79,22);
                          end;
                        4:begin
                                skludge:=not(skludge);
                                gotoxy(26,current+1);
                                textcolor(3);
                                textbackground(0);
                                write(syn(skludge));
                                changed:=TRUE;
                           end;
                        5:begin
                                sseenby:=not(sseenby);
                                gotoxy(26,current+1);
                                textcolor(3);
                                textbackground(0);
                                write(syn(sseenby));
                                changed:=TRUE;
                           end;
                        6:begin
                                sorigin:=not(sorigin);
                                gotoxy(26,current+1);
                                textcolor(3);
                                textbackground(0);
                                write(syn(sorigin));
                                changed:=TRUE;
                           end;
                        7:begin
                                setwindow4(w2,1,8,78,21,8,0,8,'Network Configuration','',TRUE);
                                getflags;
                                setwindow5(w2,1,8,78,21,3,0,8,'Network Configuration','',TRUE);
                                window(2,9,79,22);
                                gotoxy(26,8);
                                textcolor(3);
                                textbackground(0);
                                write('                                             ');
                                gotoxy(26,8);
                                write(showflags);
                           end;
                        8:begin
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choice[current]);
                                s:=allcaps(nodelistpath);
                                infield_inp_fgrd:=15;
                                infield_inp_bkgd:=1;
                                infield_out_fgrd:=3;
                                infield_out_bkgd:=0;
                                infield_allcaps:=TRUE;
                                infield_numbers_only:=FALSE;
                                infield_put_slash:=TRUE;
                                gotoxy(24,9);
                                textcolor(9);
                                textbackground(0);
                                write('>');
                                gotoxy(26,9);
                                infielde(s,50);
                                infield_put_slash:=FALSE;
                                if (s<>nodelistpath) then begin
                                        nodelistpath:=s;
                                        changed:=TRUE;
                                end;
                        end;
                        9:begin
                                fidor.nodeintear:=not(fidor.nodeintear);
                                gotoxy(26,10);
                                textcolor(3);
                                textbackground(0);
                                write(syn(fidor.nodeintear));
                                changed:=TRUE;
                          end;
                        10:begin
                                setwindow4(w2,1,8,78,21,8,0,8,'Network Configuration','',TRUE);
                                getcolors;
                                setwindow5(w2,1,8,78,21,3,0,8,'Network Configuration','',TRUE);
                                window(2,9,79,22);
                          end;
                end;
        end;
        #27:done:=TRUE;
      end;
    end;
  until (done);
  if (changed) then
  if pynqbox('Save Changes? ') then begin
  assign(fidorf,systat.gfilepath+'NETWORK.DAT');
  reset(fidorf);
  seek(fidorf,0);
  write(fidorf,fidor);
  close(fidorf);
  end;
  removewindow(w2);
end;

end.
